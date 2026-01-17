-- ═══════════════════════════════════════════════════════════════════
-- DBF_FOREINV - CLIENT DROPS
-- Ground Item Drops System
-- ═══════════════════════════════════════════════════════════════════

if not Config.EnableDrops then return end

local Drops = {}
local nearbyDrop = nil

-- ═══════════════════════════════════════════════════════════════════
-- DROP MANAGEMENT
-- ═══════════════════════════════════════════════════════════════════

RegisterNetEvent('dbf_foreinv:client:createDrop', function(dropId, items, coords)
    Drops[dropId] = {
        id = dropId,
        items = items,
        coords = vector3(coords.x, coords.y, coords.z - 0.9)
    }
    
    -- Create prop
    local propHash = GetHashKey('prop_cs_cardbox_01')
    RequestModel(propHash)
    while not HasModelLoaded(propHash) do
        Citizen.Wait(10)
    end
    
    local prop = CreateObject(propHash, Drops[dropId].coords.x, Drops[dropId].coords.y, Drops[dropId].coords.z, false, false, false)
    PlaceObjectOnGroundProperly(prop)
    FreezeEntityPosition(prop, true)
    
    Drops[dropId].prop = prop
    
    if Config.Debug then
        print('[dbf_foreinv] Drop created: ' .. dropId)
    end
end)

RegisterNetEvent('dbf_foreinv:client:removeDrop', function(dropId)
    if Drops[dropId] then
        if Drops[dropId].prop and DoesEntityExist(Drops[dropId].prop) then
            DeleteEntity(Drops[dropId].prop)
        end
        Drops[dropId] = nil
        
        if nearbyDrop == dropId then
            nearbyDrop = nil
        end
        
        if Config.Debug then
            print('[dbf_foreinv] Drop removed: ' .. dropId)
        end
    end
end)

RegisterNetEvent('dbf_foreinv:client:syncDrops', function(serverDrops)
    -- Clear existing drops
    for dropId, drop in pairs(Drops) do
        if drop.prop and DoesEntityExist(drop.prop) then
            DeleteEntity(drop.prop)
        end
    end
    Drops = {}
    
    -- Create synced drops
    for dropId, dropData in pairs(serverDrops) do
        TriggerEvent('dbf_foreinv:client:createDrop', dropId, dropData.items, dropData.coords)
    end
end)

-- ═══════════════════════════════════════════════════════════════════
-- PROXIMITY CHECK
-- ═══════════════════════════════════════════════════════════════════

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local closestDrop = nil
        local closestDistance = Config.MaxDropDistance
        
        for dropId, drop in pairs(Drops) do
            local distance = #(coords - drop.coords)
            
            if distance < closestDistance then
                closestDistance = distance
                closestDrop = dropId
            end
        end
        
        nearbyDrop = closestDrop
    end
end)

-- ═══════════════════════════════════════════════════════════════════
-- PICKUP PROMPT
-- ═══════════════════════════════════════════════════════════════════

Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        
        if nearbyDrop then
            sleep = 0
            
            local drop = Drops[nearbyDrop]
            if drop then
                -- Draw 3D text
                local coords = drop.coords
                DrawText3D(coords.x, coords.y, coords.z + 0.3, '[E] Aufheben')
                
                -- Check for pickup
                if IsControlJustPressed(0, 38) then -- E key
                    TriggerServerEvent('dbf_foreinv:server:pickupDrop', nearbyDrop)
                end
            end
        end
        
        Citizen.Wait(sleep)
    end
end)

-- ═══════════════════════════════════════════════════════════════════
-- HELPER FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════

function DrawText3D(x, y, z, text)
    local onScreen, screenX, screenY = World3dToScreen2d(x, y, z)
    local camCoords = GetGameplayCamCoords()
    local distance = #(camCoords - vector3(x, y, z))
    
    if onScreen then
        local scale = (1 / distance) * 2
        local fov = (1 / GetGameplayCamFov()) * 100
        scale = scale * fov
        
        SetTextScale(0.0, 0.35 * scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(screenX, screenY)
    end
end

-- ═══════════════════════════════════════════════════════════════════
-- RESOURCE CLEANUP
-- ═══════════════════════════════════════════════════════════════════

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for dropId, drop in pairs(Drops) do
            if drop.prop and DoesEntityExist(drop.prop) then
                DeleteEntity(drop.prop)
            end
        end
    end
end)
