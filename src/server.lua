local usingOx = GetResourceState('ox_inventory') == 'started'

if not usingOx then
    print('^3[next-kevlar] ^1[error]^0 ⚠️ Could not find a valid ox_inventory resource running. ^4This script requires ox_inventory to function.^0')
    return
end

RegisterNetEvent('next-kevlar:openVest', function(data)
    local slot = data?.slot
    local itemdata = exports.ox_inventory:GetSlot(source, slot)
    if not slot or not itemdata?.metadata then
        PunishPlayer(source, 'Invalid vest parameters provided.')
        return
    end

    if not Config.PlateCarriers[itemdata.name] then
        PunishPlayer(source, 'Invalid vest item parsed.')
        return
    end

    local metadata = itemdata.metadata
    local items = {
        {
            itemdata.name,
            1,
            metadata
        }
    }

    local plates = metadata.plates or {}
    if next(plates) then
        for _, plate in ipairs(plates) do
            items[#items + 1] = {
                plate.itemName,
                1,
                {
                    itemName = plate.itemName,
                    health = plate.health
                }
            }
            print(plate.health)
        end
    end

    local stash = exports.ox_inventory:CreateTemporaryStash({
        label = 'Vest Plate Slots',
        slots = 3,
        maxWeight = 5000,
        owner = true,
        items = items
    })

    TriggerClientEvent('ox_inventory:openInventory', source, 'stash', stash)
end)

RegisterNetEvent('next-kevlar:syncArmor', function(itemName, carrier, meta)
    local data = exports.ox_inventory:GetSlotWithItem(source, itemName, {carrierId = carrier}, false)
    if not data then
        PunishPlayer(source, 'Tried to sync metadata using an executor.')
        return
    end

    local filteredPlates = {}
    for _, plate in ipairs(meta or {}) do
        if plate.health and plate.health > 0 then
            filteredPlates[#filteredPlates + 1] = plate
        end
    end

    data.metadata.plates = filteredPlates
    exports.ox_inventory:SetMetadata(source, data.slot, data.metadata)
end)

-- Hook that detects inserting or removing plates into the plate carriers
exports.ox_inventory:registerHook('swapItems', function(payload)
    local source = payload.source
    local fromInv = payload.fromInventory
    local toInv = payload.toInventory
    local from = payload.fromSlot
    local to = payload.toSlot

    local function isVestEditStash(name)
        local name = tostring(name)
        return name and name:match('^temp%-%d+$')
    end

    if not (isVestEditStash(fromInv) or isVestEditStash(toInv)) then return end

    local vestStash = isVestEditStash(fromInv) and fromInv or toInv
    local items = exports.ox_inventory:GetInventory(vestStash, false).items or {}

    local carrierItem = items[1]
    local carrierId = carrierItem?.metadata?.carrierId
    if not carrierId then return end

    local plates = {}
    for i = 2, 3 do
        local item = items[i]
        if item?.name and item.metadata?.health then
            plates[i] = {
                itemName = item.name,
                health = item.metadata.health
            }
        end
    end

    local action = payload.action
    if action == 'move' then
        if vestStash == fromInv then
            if from.slot ~= 1 then
                plates[from.slot] = nil
            else
                return false
            end
        elseif vestStash == toInv then
            plates[to] = {
                itemName = from.name,
                health = from.metadata?.health
            }
        end
    elseif action == 'swap' then
        if vestStash == fromInv then
            if from.slot ~= 1 then
                plates[from.slot] = {
                    itemName = to.name,
                    health = to.metadata?.health
                }
            else
                return false
            end
        elseif vestStash == toInv then
            if to.slot ~= 1 then
                plates[to.slot] = {
                    itemName = from.name,
                    health = from.metadata?.health
                }
            else 
                return false
            end
        end
    end

    local vests = exports.ox_inventory:Search(source, 'slots', 'platecarrier')
    local targetVest
    for _, vest in ipairs(vests) do
        if vest.metadata?.carrierId == carrierId then
            targetVest = vest
            break
        end
    end

    if not targetVest then return end

    targetVest.metadata.plates = {}
    for _, plate in pairs(plates) do
        if plate then
            targetVest.metadata.plates[#targetVest.metadata.plates + 1] = plate
        end
    end

    exports.ox_inventory:SetMetadata(source, targetVest.slot, targetVest.metadata)

    TriggerClientEvent('next-kevlar:onMetadataUpdate', source, carrierItem.name, targetVest.metadata)
end, {
    inventoryFilter = {
        '^temp%-%d+$'
    }
})


-- Hooks that attaches unique metadata to each item on creation
for item, carrier in pairs(Config.PlateCarriers) do
    exports.ox_inventory:registerHook('createItem', function(payload)
        if payload.item.name ~= item then return end
        if payload.metadata?.carrierId then return end
    
        return {
            carrierId = 'carrier_' .. os.time() .. math.random(1000, 9999),
            plate_type = carrier.plateType
        }
    end, {
        itemFilter = { [item] = true }
    })
end

for _, plate in ipairs(Config.Plates) do
    exports.ox_inventory:registerHook('createItem', function(payload)
        if payload.item.name ~= plate.name then return end
        if payload.metadata?.health then return end
    
        return {
            plate_type = plate.plateType,
            health = plate.armor
        }
    end, {
        itemFilter = { [plate.name] = true }
    })
end