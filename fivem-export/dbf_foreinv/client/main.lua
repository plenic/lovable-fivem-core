-- ═══════════════════════════════════════════════════════════════════
-- DBF_FOREINV - CLIENT MAIN
-- ForeState Inventory System
-- ═══════════════════════════════════════════════════════════════════

local isOpen = false
local PlayerData = {}
local Inventory = {}
local Equipment = {}

-- ═══════════════════════════════════════════════════════════════════
-- NUI CALLBACKS
-- ═══════════════════════════════════════════════════════════════════

RegisterNUICallback('close', function(data, cb)
    CloseInventory()
    cb('ok')
end)

RegisterNUICallback('useItem', function(data, cb)
    local itemName = data.item
    local slotId = data.slot
    
    if Config.Debug then
        print('[dbf_foreinv] Using item: ' .. itemName .. ' from slot ' .. slotId)
    end
    
    TriggerServerEvent('dbf_foreinv:server:useItem', itemName, slotId)
    cb('ok')
end)

RegisterNUICallback('dropItem', function(data, cb)
    local itemName = data.item
    local slotId = data.slot
    local amount = data.amount or 1
    
    TriggerServerEvent('dbf_foreinv:server:dropItem', itemName, slotId, amount)
    cb('ok')
end)

RegisterNUICallback('giveItem', function(data, cb)
    local itemName = data.item
    local slotId = data.slot
    local amount = data.amount or 1
    local targetId = data.targetId
    
    TriggerServerEvent('dbf_foreinv:server:giveItem', itemName, slotId, amount, targetId)
    cb('ok')
end)

RegisterNUICallback('splitItem', function(data, cb)
    local itemName = data.item
    local slotId = data.slot
    local amount = data.amount
    
    TriggerServerEvent('dbf_foreinv:server:splitItem', itemName, slotId, amount)
    cb('ok')
end)

RegisterNUICallback('moveItem', function(data, cb)
    local fromSlot = data.fromSlot
    local toSlot = data.toSlot
    local fromType = data.fromType or 'inventory'
    local toType = data.toType or 'inventory'
    
    TriggerServerEvent('dbf_foreinv:server:moveItem', fromSlot, toSlot, fromType, toType)
    cb('ok')
end)

RegisterNUICallback('equipItem', function(data, cb)
    local itemName = data.item
    local slotId = data.slot
    local equipSlot = data.equipSlot
    
    TriggerServerEvent('dbf_foreinv:server:equipItem', itemName, slotId, equipSlot)
    cb('ok')
end)

RegisterNUICallback('unequipItem', function(data, cb)
    local equipSlot = data.equipSlot
    
    TriggerServerEvent('dbf_foreinv:server:unequipItem', equipSlot)
    cb('ok')
end)

RegisterNUICallback('destroyItem', function(data, cb)
    local itemName = data.item
    local slotId = data.slot
    
    TriggerServerEvent('dbf_foreinv:server:destroyItem', itemName, slotId)
    cb('ok')
end)

RegisterNUICallback('getPlayerName', function(data, cb)
    local playerData = Framework.GetPlayerData()
    local name = 'Unbekannt'
    
    if Framework.Name == 'esx' then
        name = playerData.firstName .. ' ' .. playerData.lastName
    elseif Framework.Name == 'qb' then
        name = playerData.charinfo.firstname .. ' ' .. playerData.charinfo.lastname
    else
        name = GetPlayerName(PlayerId())
    end
    
    cb({ name = name, id = GetPlayerServerId(PlayerId()) })
end)

RegisterNUICallback('getNearbyPlayers', function(data, cb)
    local players = {}
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    for _, playerId in ipairs(GetActivePlayers()) do
        if playerId ~= PlayerId() then
            local targetPed = GetPlayerPed(playerId)
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(playerCoords - targetCoords)
            
            if distance < 5.0 then
                table.insert(players, {
                    id = GetPlayerServerId(playerId),
                    name = GetPlayerName(playerId),
                    distance = distance
                })
            end
        end
    end
    
    cb(players)
end)

-- ═══════════════════════════════════════════════════════════════════
-- INVENTORY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════

function OpenInventory()
    if isOpen then return end
    
    isOpen = true
    
    -- Request inventory data from server
    TriggerServerEvent('dbf_foreinv:server:getInventory')
    
    SetNuiFocus(true, true)
    
    SendNUIMessage({
        action = 'open',
        config = {
            maxSlots = Config.MaxSlots,
            maxWeight = Config.MaxWeight,
            primaryColor = Config.PrimaryColor,
            enableAnimations = Config.EnableAnimations,
            equipmentSlots = Config.EquipmentSlots
        }
    })
    
    if Config.Debug then
        print('[dbf_foreinv] Inventory opened')
    end
end

function CloseInventory()
    if not isOpen then return end
    
    isOpen = false
    SetNuiFocus(false, false)
    
    SendNUIMessage({
        action = 'close'
    })
    
    if Config.Debug then
        print('[dbf_foreinv] Inventory closed')
    end
end

function ToggleInventory()
    if isOpen then
        CloseInventory()
    else
        OpenInventory()
    end
end

function UpdateInventory(inventory, equipment, weight)
    Inventory = inventory
    Equipment = equipment
    
    SendNUIMessage({
        action = 'updateInventory',
        inventory = inventory,
        equipment = equipment,
        currentWeight = weight,
        maxWeight = Config.MaxWeight
    })
end

-- ═══════════════════════════════════════════════════════════════════
-- SERVER EVENTS
-- ═══════════════════════════════════════════════════════════════════

RegisterNetEvent('dbf_foreinv:client:updateInventory', function(inventory, equipment, weight)
    UpdateInventory(inventory, equipment, weight)
end)

RegisterNetEvent('dbf_foreinv:client:notify', function(message, type)
    Framework.NotifyClient(message, type)
    
    -- Also send to NUI for visual feedback
    SendNUIMessage({
        action = 'notify',
        message = message,
        type = type
    })
end)

RegisterNetEvent('dbf_foreinv:client:refreshInventory', function()
    if isOpen then
        TriggerServerEvent('dbf_foreinv:server:getInventory')
    end
end)

RegisterNetEvent('dbf_foreinv:client:closeInventory', function()
    CloseInventory()
end)

-- ═══════════════════════════════════════════════════════════════════
-- WEAPON HANDLING
-- ═══════════════════════════════════════════════════════════════════

RegisterNetEvent('dbf_foreinv:client:giveWeapon', function(weapon, ammo)
    local ped = PlayerPedId()
    local weaponHash = GetHashKey(weapon)
    
    GiveWeaponToPed(ped, weaponHash, ammo, false, false)
    SetCurrentPedWeapon(ped, weaponHash, true)
end)

RegisterNetEvent('dbf_foreinv:client:removeWeapon', function(weapon)
    local ped = PlayerPedId()
    local weaponHash = GetHashKey(weapon)
    
    RemoveWeaponFromPed(ped, weaponHash)
end)

-- ═══════════════════════════════════════════════════════════════════
-- KEYBINDS
-- ═══════════════════════════════════════════════════════════════════

-- Primary inventory key
RegisterCommand('openinv', function()
    ToggleInventory()
end, false)

RegisterKeyMapping('openinv', 'Inventar öffnen', 'keyboard', Config.OpenKey)

-- Close on ESC when open
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        if isOpen then
            DisableControlAction(0, 1, true) -- LookLeftRight
            DisableControlAction(0, 2, true) -- LookUpDown
            DisableControlAction(0, 142, true) -- MeleeAttackAlternate
            DisableControlAction(0, 18, true) -- Enter
            DisableControlAction(0, 322, true) -- ESC
            DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
            
            if IsDisabledControlJustReleased(0, 322) then -- ESC
                CloseInventory()
            end
        else
            Citizen.Wait(200)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════
-- HOTBAR / QUICKSLOTS
-- ═══════════════════════════════════════════════════════════════════

RegisterCommand('hotbar1', function() UseQuickSlot(1) end, false)
RegisterCommand('hotbar2', function() UseQuickSlot(2) end, false)
RegisterCommand('hotbar3', function() UseQuickSlot(3) end, false)
RegisterCommand('hotbar4', function() UseQuickSlot(4) end, false)
RegisterCommand('hotbar5', function() UseQuickSlot(5) end, false)
RegisterCommand('hotbar6', function() UseQuickSlot(6) end, false)

RegisterKeyMapping('hotbar1', 'Schnellslot 1', 'keyboard', '1')
RegisterKeyMapping('hotbar2', 'Schnellslot 2', 'keyboard', '2')
RegisterKeyMapping('hotbar3', 'Schnellslot 3', 'keyboard', '3')
RegisterKeyMapping('hotbar4', 'Schnellslot 4', 'keyboard', '4')
RegisterKeyMapping('hotbar5', 'Schnellslot 5', 'keyboard', '5')
RegisterKeyMapping('hotbar6', 'Schnellslot 6', 'keyboard', '6')

function UseQuickSlot(slot)
    if not isOpen then
        TriggerServerEvent('dbf_foreinv:server:useQuickSlot', slot)
    end
end

-- ═══════════════════════════════════════════════════════════════════
-- ANIMATIONS
-- ═══════════════════════════════════════════════════════════════════

local currentAnim = nil

function PlayItemAnimation(animDict, animName, duration)
    local ped = PlayerPedId()
    
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(10)
    end
    
    TaskPlayAnim(ped, animDict, animName, 8.0, 8.0, duration or 3000, 0, 0, false, false, false)
    currentAnim = { dict = animDict, name = animName }
end

function StopItemAnimation()
    if currentAnim then
        local ped = PlayerPedId()
        StopAnimTask(ped, currentAnim.dict, currentAnim.name, 1.0)
        currentAnim = nil
    end
end

RegisterNetEvent('dbf_foreinv:client:playAnimation', function(animDict, animName, duration)
    PlayItemAnimation(animDict, animName, duration)
end)

RegisterNetEvent('dbf_foreinv:client:stopAnimation', function()
    StopItemAnimation()
end)

-- ═══════════════════════════════════════════════════════════════════
-- PROGRESSBAR (Optional: ox_lib integration)
-- ═══════════════════════════════════════════════════════════════════

function StartProgressBar(duration, label, animDict, animName)
    if GetResourceState('ox_lib') == 'started' then
        return exports.ox_lib:progressBar({
            duration = duration,
            label = label,
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                move = true,
                combat = true
            },
            anim = animDict and {
                dict = animDict,
                clip = animName
            } or nil
        })
    else
        -- Fallback: Simple wait
        Citizen.Wait(duration)
        return true
    end
end

-- ═══════════════════════════════════════════════════════════════════
-- ITEM USE EFFECTS (Client-side effects)
-- ═══════════════════════════════════════════════════════════════════

RegisterNetEvent('dbf_foreinv:client:useFood', function(item)
    local progress = StartProgressBar(3000, 'Essen...', 'mp_player_inteat@burger', 'mp_player_int_eat_burger')
    
    if progress then
        TriggerServerEvent('dbf_foreinv:server:finishUseItem', item.name, 'food')
    end
end)

RegisterNetEvent('dbf_foreinv:client:useDrink', function(item)
    local progress = StartProgressBar(2000, 'Trinken...', 'amb@world_human_drinking@beer@male@idle_a', 'idle_c')
    
    if progress then
        TriggerServerEvent('dbf_foreinv:server:finishUseItem', item.name, 'drink')
    end
end)

RegisterNetEvent('dbf_foreinv:client:useMedical', function(item)
    local progress = StartProgressBar(5000, 'Behandeln...', 'anim@heists@narcotics@funding@gang_idle', 'gang_chatting_idle01')
    
    if progress then
        TriggerServerEvent('dbf_foreinv:server:finishUseItem', item.name, 'medical')
        
        -- Apply healing
        if item.heal then
            local ped = PlayerPedId()
            local currentHealth = GetEntityHealth(ped)
            local newHealth = math.min(currentHealth + item.heal, GetEntityMaxHealth(ped))
            SetEntityHealth(ped, newHealth)
        end
    end
end)

RegisterNetEvent('dbf_foreinv:client:useArmor', function(item)
    local progress = StartProgressBar(4000, 'Anziehen...', nil, nil)
    
    if progress then
        local ped = PlayerPedId()
        SetPedArmour(ped, item.armor or 50)
        TriggerServerEvent('dbf_foreinv:server:finishUseItem', item.name, 'armor')
    end
end)

-- ═══════════════════════════════════════════════════════════════════
-- EXPORTS
-- ═══════════════════════════════════════════════════════════════════

exports('OpenInventory', OpenInventory)
exports('CloseInventory', CloseInventory)
exports('ToggleInventory', ToggleInventory)
exports('IsInventoryOpen', function() return isOpen end)
exports('GetInventory', function() return Inventory end)
exports('GetEquipment', function() return Equipment end)

-- ═══════════════════════════════════════════════════════════════════
-- INITIALIZATION
-- ═══════════════════════════════════════════════════════════════════

Citizen.CreateThread(function()
    while Framework.Object == nil do
        Citizen.Wait(100)
    end
    
    if Config.Debug then
        print('[dbf_foreinv] Client initialized with framework: ' .. Framework.Name)
    end
end)
