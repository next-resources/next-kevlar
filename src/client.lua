local equippedVest, pedArmor, plateMeta

CreateThread(function()
    exports.ox_inventory:displayMetadata('health', 'Plate Health')
end)

local function PlayVestAnimation(action)
    local ped = PlayerPedId()
    local dict = 'clothingtie'
    local anim = 'try_tie_neutral_c'

    lib.requestAnimDict(dict)

    local label = action == 'equip' and 'Putting on vest...' or 'Removing vest...'
    local duration = 2000

    TaskPlayAnim(ped, dict, anim, 8.0, -8.0, duration, 49, 0, false, false, false)
    
    local success = lib.progressCircle({
        duration = duration,
        position = 'bottom',
        label = label,
        useWhileDead = false,
        canCancel = false,
        disable = { car = true, combat = true }
    })

    ClearPedTasks(ped)

    if success then return end
end

exports('useVest', function(item, data)
    if not CanEquipVest() then return end

    local ped = PlayerPedId()
    local itemName = data.name
    local metadata = data.metadata

    local validItem = Config.PlateCarriers[itemName]
    local hasVest = exports.ox_inventory:Search('count', itemName) > 0
    if not hasVest or not validItem then return end

    if equippedVest then
        PlayVestAnimation('remove')
        SetPedArmour(ped, 0)
        SetPedComponentVariation(ped, equippedVest.original.category, equippedVest.original.drawable, equippedVest.original.texture, 0)
        pedArmor = 0

        if equippedVest.carrierId == metadata.carrierId then
            equippedVest = nil
            return
        end
    end

    equippedVest = {}

    local model = GetEntityModel(ped)
    local isMale = model == `mp_m_freemode_01`
    local vest = Config.PlateCarriers[itemName]
    local category = vest.clothing[isMale and "male" or "female"].drawableCategory

    equippedVest.itemName = itemName
    equippedVest.carrierId = metadata.carrierId
    equippedVest.original = {
        category = category,
        drawable = GetPedDrawableVariation(ped, category),
        texture = GetPedTextureVariation(ped, category)
    }

    local vestAppearance = vest.clothing[isMale and "male" or "female"]
    if vestAppearance then
        PlayVestAnimation('equip')
        SetPedComponentVariation(ped, vestAppearance.drawableCategory, vestAppearance.drawable, vestAppearance.texture, 0)

        local totalArmor = 0
        plateMeta = metadata.plates
        if plateMeta and next(plateMeta) then
            for _, plate in ipairs(metadata.plates) do
                if plate.health > 0 then
                    totalArmor += plate.health
                end
            end
        end

        local armor = math.min(totalArmor, 100)
        SetPedArmour(ped, armor)
        pedArmor = armor
    end
end)

exports('managePlates', function(slot)
    exports.ox_inventory:closeInventory()
    TriggerServerEvent('next-kevlar:openVest', slot)
end)

RegisterNetEvent('next-kevlar:onMetadataUpdate', function(itemName, metadata)
    if not equippedVest or equippedVest.carrierId ~= metadata.carrierId then return end

    local data = exports.ox_inventory:GetSlotWithItem(itemName, {carrierId = metadata.carrierId}, false)
    if not data then return end

    local totalArmor = 0
    plateMeta = data.metadata.plates
    if plateMeta and next(plateMeta) then
        for _, plate in ipairs(metadata.plates) do
            if plate.health > 0 then
                totalArmor += plate.health
            end
        end
    end

    local armor = math.min(totalArmor, 100)
    SetPedArmour(PlayerPedId(), armor)
    pedArmor = armor
end)

RegisterNetEvent('next-kevlar:droppedVest', function(metadata)
    if not equippedVest or equippedVest.carrierId ~= metadata.carrierId then return end

    local ped = PlayerPedId()
    SetPedArmour(ped, 0)
    SetPedComponentVariation(ped, equippedVest.original.category, equippedVest.original.drawable, equippedVest.original.texture, 0)
    pedArmor = 0
    equippedVest = nil
end)

AddEventHandler('gameEventTriggered', function(name, args)
    if name ~= 'CEventNetworkEntityDamage' or not equippedVest then return end

    local victim = args[1]
    local ped = PlayerPedId()
    if victim ~= ped or not plateMeta or #plateMeta == 0 then return end

    local currentArmor = GetPedArmour(ped)
    if currentArmor >= pedArmor then
        pedArmor = currentArmor
        return
    end

    local armorLost = pedArmor - currentArmor
    pedArmor = currentArmor

    local plateBroken = false
    for i, plate in ipairs(plateMeta) do
        if plate.health > 0 then
            local absorb = math.min(plate.health, armorLost)
            plate.health -= absorb
            armorLost -= absorb

            if plate.health <= 0 then
                plateBroken = true
            end

            if armorLost <= 0 then break end
        end
    end

    if Config.SyncPlatesEveryHit or plateBroken then
        TriggerServerEvent('next-kevlar:syncArmor', equippedVest.itemName, equippedVest.carrierId, plateMeta)
    end
end)