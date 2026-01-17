-- ═══════════════════════════════════════════════════════════════════
-- DBF_FOREINV - SERVER DROPS
-- Ground Item Drops System
-- ═══════════════════════════════════════════════════════════════════

if not Config.EnableDrops then return end

local Drops = {}
local dropCounter = 0

-- ═══════════════════════════════════════════════════════════════════
-- DROP CREATION
-- ═══════════════════════════════════════════════════════════════════

RegisterNetEvent('dbf_foreinv:server:createDrop', function(source, itemName, amount, coords)
    dropCounter = dropCounter + 1
    local dropId = 'drop_' .. os.time() .. '_' .. dropCounter
    
    local itemData = Items[itemName]
    if not itemData then return end
    
    Drops[dropId] = {
        id = dropId,
        items = {
            {
                name = itemName,
                label = itemData.label,
                quantity = amount
            }
        },
        coords = coords,
        createdAt = os.time()
    }
    
    -- Notify all players
    TriggerClientEvent('dbf_foreinv:client:createDrop', -1, dropId, Drops[dropId].items, coords)
    
    -- Set despawn timer
    if Config.DropDespawnTime > 0 then
        SetTimeout(Config.DropDespawnTime * 1000, function()
            if Drops[dropId] then
                RemoveDrop(dropId)
            end
        end)
    end
    
    if Config.Debug then
        print('[dbf_foreinv] Drop created: ' .. dropId .. ' with ' .. amount .. 'x ' .. itemName)
    end
end)

-- ═══════════════════════════════════════════════════════════════════
-- DROP PICKUP
-- ═══════════════════════════════════════════════════════════════════

RegisterNetEvent('dbf_foreinv:server:pickupDrop', function(dropId)
    local source = source
    local drop = Drops[dropId]
    
    if not drop then
        Framework.Notify(source, 'Dieses Item existiert nicht mehr', 'error')
        return
    end
    
    -- Check distance
    local ped = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(ped)
    local dropCoords = vector3(drop.coords.x, drop.coords.y, drop.coords.z)
    
    if #(playerCoords - dropCoords) > Config.MaxDropDistance + 1 then
        Framework.Notify(source, 'Du bist zu weit entfernt', 'error')
        return
    end
    
    -- Try to add all items
    local allAdded = true
    for _, item in ipairs(drop.items) do
        if not exports['dbf_foreinv']:CanCarryItem(source, item.name, item.quantity) then
            allAdded = false
            Framework.Notify(source, 'Du kannst nicht mehr tragen!', 'error')
            break
        end
        
        if not exports['dbf_foreinv']:AddItem(source, item.name, item.quantity) then
            allAdded = false
            break
        end
    end
    
    if allAdded then
        RemoveDrop(dropId)
    end
end)

-- ═══════════════════════════════════════════════════════════════════
-- DROP MANAGEMENT
-- ═══════════════════════════════════════════════════════════════════

function RemoveDrop(dropId)
    if Drops[dropId] then
        Drops[dropId] = nil
        TriggerClientEvent('dbf_foreinv:client:removeDrop', -1, dropId)
        
        if Config.Debug then
            print('[dbf_foreinv] Drop removed: ' .. dropId)
        end
    end
end

-- Sync drops for newly connected players
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local source = source
    
    Citizen.SetTimeout(5000, function()
        if Drops and next(Drops) then
            TriggerClientEvent('dbf_foreinv:client:syncDrops', source, Drops)
        end
    end)
end)

-- ═══════════════════════════════════════════════════════════════════
-- CLEANUP
-- ═══════════════════════════════════════════════════════════════════

-- Periodic cleanup of expired drops
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000) -- Check every minute
        
        if Config.DropDespawnTime > 0 then
            local now = os.time()
            for dropId, drop in pairs(Drops) do
                if now - drop.createdAt > Config.DropDespawnTime then
                    RemoveDrop(dropId)
                end
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════
-- EXPORTS
-- ═══════════════════════════════════════════════════════════════════

exports('GetDrops', function() return Drops end)
exports('RemoveDrop', RemoveDrop)
