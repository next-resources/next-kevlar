local waited = 0
while GetResourceState('ox_inventory') ~= 'started' and waited < 10000 do
    Wait(500)
    waited += 500
end

local usingOx = GetResourceState('ox_inventory') == 'started'

if not usingOx then
    print('^3[next-kevlar] ^1[error]^0 ⚠️ Could not find a valid ox_inventory resource running. ^4This script requires ox_inventory to function.^0')
    return
end

RegisterNetEvent('next-kevlar:openVest', function(slot)
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

    if not metadata.carrierId then
        metadata = {
            carrierId = 'carrier_' .. os.time() .. math.random(1000, 9999),
            plate_type = Config.PlateCarriers[itemdata.name].plateType
        }
        
        exports.ox_inventory:SetMetadata(source, itemdata.slot, metadata)
    end

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
                    health = plate.health or 0
                }
            }
        end
    end

    local plateType = metadata.plate_type or 'light'
    local slots = plateType == 'heavy' and 3 or 2
    local stash = exports.ox_inventory:CreateTemporaryStash({
        label = 'Vest Plate Slots',
        slots = slots,
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
        if plate.health then
            if plate.health > 0 then
                filteredPlates[#filteredPlates + 1] = plate
            else
                if Config.UseBrokenPlates then
                    filteredPlates[#filteredPlates + 1] = {
                        itemName = Config.BrokenPlateItem
                    }
                end
            end
        end
    end

    data.metadata.plates = filteredPlates
    exports.ox_inventory:SetMetadata(source, data.slot, data.metadata)
end)

lib.callback.register('next-kevlar:registerCarrier', function(source, slot)
    local data = exports.ox_inventory:GetSlot(source, slot)
    if not data or not Config.PlateCarriers[data.name] then
        PunishPlayer(source, 'Tried to register a plate carrier using an executor.')
        return
    end

    local metadata = {
        carrierId = 'carrier_' .. os.time() .. math.random(1000, 9999),
        plate_type = Config.PlateCarriers[data.name].plateType
    }

    exports.ox_inventory:SetMetadata(source, data.slot, metadata)
    return metadata
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
                if fromInv == toInv then
                    plates[from.slot] = nil
                    plates[to] = {
                        itemName = from.name,
                        health = from.metadata?.health
                    }
                else
                    plates[from.slot] = nil
                end
            else
                return false
            end
        elseif vestStash == toInv then
            if not Config.Plates[from.name] and from.name ~= Config.BrokenPlateItem then return false end
            plates[to] = {
                itemName = from.name,
                health = from.metadata?.health
            }
        end
    elseif action == 'swap' then
        if vestStash == fromInv then
            if not Config.Plates[to.name] and to.name ~= Config.BrokenPlateItem then return false end
            if fromInv == toInv then
                if not Config.Plates[from.name] then return false end
                plates[from.slot] = {
                    itemName = to.name,
                    health = to.metadata?.health
                }
                plates[to.slot] = {
                    itemName = from.name,
                    health = from.metadata?.health
                }
            else
                if from.slot ~= 1 then
                    plates[from.slot] = {
                        itemName = to.name,
                        health = to.metadata?.health
                    }
                else
                    return false
                end
            end
        elseif vestStash == toInv then
            if not Config.Plates[from.name] and from.name ~= Config.BrokenPlateItem then return false end
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

    local targetVest
    for name, _ in pairs(Config.PlateCarriers) do
        local vest = exports.ox_inventory:GetSlotWithItem(source, name, {carrierId = carrierId}, false)
        if vest then
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


local ValidCarriers = {}
for item, carrier in pairs(Config.PlateCarriers) do
    ValidCarriers[item] = true
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

exports.ox_inventory:registerHook('swapItems', function(payload)
    local source = payload.source
    local fromInv = payload.fromInventory
    local toInv = payload.toInventory

    if fromInv == source and toInv ~= source then
        TriggerClientEvent('next-kevlar:droppedVest', source, payload.fromSlot.metadata)
    end
end, {
    itemFilter = ValidCarriers
})

for item, armor in pairs(Config.Plates) do
    exports.ox_inventory:registerHook('createItem', function(payload)
        if payload.item.name ~= item then return end
        if payload.metadata?.health then return end
    
        return {
            itemName = item,
            health = math.min(50, math.max(0, armor))
        }
    end, {
        itemFilter = { [item] = true }
    })
end