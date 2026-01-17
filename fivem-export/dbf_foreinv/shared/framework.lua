-- ═══════════════════════════════════════════════════════════════════
-- FRAMEWORK BRIDGE - ESX / QB-Core / Standalone Compatibility
-- ═══════════════════════════════════════════════════════════════════

Framework = {}
Framework.Name = nil
Framework.Object = nil

-- ═══════════════════════════════════════════════════════════════════
-- AUTO-DETECT FRAMEWORK
-- ═══════════════════════════════════════════════════════════════════
local function DetectFramework()
    if Config.Framework ~= 'auto' then
        return Config.Framework
    end
    
    -- Check for ESX
    if GetResourceState('es_extended') == 'started' then
        return 'esx'
    end
    
    -- Check for QB-Core
    if GetResourceState('qb-core') == 'started' then
        return 'qb'
    end
    
    -- Check for ox_core
    if GetResourceState('ox_core') == 'started' then
        return 'ox'
    end
    
    -- Check for ND_Core
    if GetResourceState('ND_Core') == 'started' then
        return 'nd'
    end
    
    return 'standalone'
end

-- ═══════════════════════════════════════════════════════════════════
-- INITIALIZE FRAMEWORK
-- ═══════════════════════════════════════════════════════════════════
Citizen.CreateThread(function()
    Framework.Name = DetectFramework()
    
    if Framework.Name == 'esx' then
        -- ESX Legacy / ESX 1.x Compatibility
        if exports['es_extended'] then
            Framework.Object = exports['es_extended']:getSharedObject()
        else
            TriggerEvent('esx:getSharedObject', function(obj) Framework.Object = obj end)
            while Framework.Object == nil do Citizen.Wait(0) end
        end
        
    elseif Framework.Name == 'qb' then
        Framework.Object = exports['qb-core']:GetCoreObject()
        
    elseif Framework.Name == 'ox' then
        Framework.Object = exports.ox_core
        
    elseif Framework.Name == 'nd' then
        Framework.Object = exports['ND_Core']
    end
    
    if Config.Debug then
        print('[dbf_foreinv] Framework detected: ' .. Framework.Name)
    end
end)

-- ═══════════════════════════════════════════════════════════════════
-- PLAYER DATA FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════

-- Get Player Data (Client-side)
function Framework.GetPlayerData()
    if Framework.Name == 'esx' then
        return Framework.Object.GetPlayerData()
        
    elseif Framework.Name == 'qb' then
        return exports['qb-core']:GetCoreObject().Functions.GetPlayerData()
        
    elseif Framework.Name == 'ox' then
        return Ox.GetPlayer()
        
    else
        return { identifier = GetPlayerServerId(PlayerId()) }
    end
end

-- Get Player Identifier (Server-side)
function Framework.GetIdentifier(source)
    if Framework.Name == 'esx' then
        local xPlayer = Framework.Object.GetPlayerFromId(source)
        return xPlayer and xPlayer.identifier or nil
        
    elseif Framework.Name == 'qb' then
        local Player = Framework.Object.Functions.GetPlayer(source)
        return Player and Player.PlayerData.citizenid or nil
        
    elseif Framework.Name == 'ox' then
        local player = Ox.GetPlayer(source)
        return player and player.charid or nil
        
    else
        for _, id in ipairs(GetPlayerIdentifiers(source)) do
            if string.match(id, 'license:') then
                return id
            end
        end
        return nil
    end
end

-- Get Player Name
function Framework.GetPlayerName(source)
    if Framework.Name == 'esx' then
        local xPlayer = Framework.Object.GetPlayerFromId(source)
        return xPlayer and xPlayer.getName() or 'Unknown'
        
    elseif Framework.Name == 'qb' then
        local Player = Framework.Object.Functions.GetPlayer(source)
        if Player then
            local charinfo = Player.PlayerData.charinfo
            return charinfo.firstname .. ' ' .. charinfo.lastname
        end
        return 'Unknown'
        
    else
        return GetPlayerName(source) or 'Unknown'
    end
end

-- ═══════════════════════════════════════════════════════════════════
-- NOTIFICATION SYSTEM
-- ═══════════════════════════════════════════════════════════════════

function Framework.Notify(source, message, type)
    type = type or 'info'
    
    if Config.NotifySystem == 'ox_lib' or (Config.NotifySystem == 'auto' and GetResourceState('ox_lib') == 'started') then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Inventar',
            description = message,
            type = type
        })
        
    elseif Framework.Name == 'esx' then
        TriggerClientEvent('esx:showNotification', source, message)
        
    elseif Framework.Name == 'qb' then
        TriggerClientEvent('QBCore:Notify', source, message, type)
        
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = {162, 0, 255},
            args = {'[Inventar]', message}
        })
    end
end

-- Client-side notification
function Framework.NotifyClient(message, type)
    type = type or 'info'
    
    if Config.NotifySystem == 'ox_lib' or (Config.NotifySystem == 'auto' and GetResourceState('ox_lib') == 'started') then
        exports.ox_lib:notify({
            title = 'Inventar',
            description = message,
            type = type
        })
        
    elseif Framework.Name == 'esx' then
        Framework.Object.ShowNotification(message)
        
    elseif Framework.Name == 'qb' then
        Framework.Object.Functions.Notify(message, type)
        
    else
        TriggerEvent('chat:addMessage', {
            color = {162, 0, 255},
            args = {'[Inventar]', message}
        })
    end
end

-- ═══════════════════════════════════════════════════════════════════
-- MONEY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════

function Framework.GetMoney(source, account)
    account = account or 'cash'
    
    if Framework.Name == 'esx' then
        local xPlayer = Framework.Object.GetPlayerFromId(source)
        if account == 'cash' then
            return xPlayer.getMoney()
        else
            return xPlayer.getAccount(account).money
        end
        
    elseif Framework.Name == 'qb' then
        local Player = Framework.Object.Functions.GetPlayer(source)
        return Player.PlayerData.money[account] or 0
        
    else
        return 0
    end
end

function Framework.AddMoney(source, account, amount)
    if Framework.Name == 'esx' then
        local xPlayer = Framework.Object.GetPlayerFromId(source)
        if account == 'cash' then
            xPlayer.addMoney(amount)
        else
            xPlayer.addAccountMoney(account, amount)
        end
        
    elseif Framework.Name == 'qb' then
        local Player = Framework.Object.Functions.GetPlayer(source)
        Player.Functions.AddMoney(account, amount)
    end
end

function Framework.RemoveMoney(source, account, amount)
    if Framework.Name == 'esx' then
        local xPlayer = Framework.Object.GetPlayerFromId(source)
        if account == 'cash' then
            xPlayer.removeMoney(amount)
        else
            xPlayer.removeAccountMoney(account, amount)
        end
        
    elseif Framework.Name == 'qb' then
        local Player = Framework.Object.Functions.GetPlayer(source)
        Player.Functions.RemoveMoney(account, amount)
    end
end

-- ═══════════════════════════════════════════════════════════════════
-- WEAPON FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════

function Framework.GiveWeapon(source, weapon, ammo)
    if Framework.Name == 'esx' then
        local xPlayer = Framework.Object.GetPlayerFromId(source)
        xPlayer.addWeapon(weapon, ammo or 0)
        
    elseif Framework.Name == 'qb' then
        TriggerClientEvent('dbf_foreinv:client:giveWeapon', source, weapon, ammo or 0)
        
    else
        TriggerClientEvent('dbf_foreinv:client:giveWeapon', source, weapon, ammo or 0)
    end
end

function Framework.RemoveWeapon(source, weapon)
    if Framework.Name == 'esx' then
        local xPlayer = Framework.Object.GetPlayerFromId(source)
        xPlayer.removeWeapon(weapon)
        
    elseif Framework.Name == 'qb' then
        TriggerClientEvent('dbf_foreinv:client:removeWeapon', source, weapon)
        
    else
        TriggerClientEvent('dbf_foreinv:client:removeWeapon', source, weapon)
    end
end
