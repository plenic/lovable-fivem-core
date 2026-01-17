-- ═══════════════════════════════════════════════════════════════════
-- DBF_FOREINV - SERVER MAIN
-- ForeState Inventory System
-- ═══════════════════════════════════════════════════════════════════

local Inventories = {} -- Player inventories cache
local Equipment = {}   -- Player equipment cache

-- ═══════════════════════════════════════════════════════════════════
-- DATABASE FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════

local function ExecuteQuery(query, params)
    if Config.UseOxmysql then
        return MySQL.query.await(query, params)
    else
        return exports['mysql-async']:mysql_fetch_all(query, params)
    end
end

local function ExecuteInsert(query, params)
    if Config.UseOxmysql then
        return MySQL.insert.await(query, params)
    else
        return exports['mysql-async']:mysql_insert(query, params)
    end
end

local function ExecuteUpdate(query, params)
    if Config.UseOxmysql then
        return MySQL.update.await(query, params)
    else
        return exports['mysql-async']:mysql_execute(query, params)
    end
end

-- ═══════════════════════════════════════════════════════════════════
-- INVENTORY LOADING
-- ═══════════════════════════════════════════════════════════════════

function LoadPlayerInventory(source)
    local identifier = Framework.GetIdentifier(source)
    if not identifier then return nil end
    
    local result = ExecuteQuery('SELECT inventory, equipment FROM dbf_inventory WHERE identifier = ?', { identifier })
    
    if result and result[1] then
        local inventory = json.decode(result[1].inventory) or CreateEmptyInventory()
        local equipment = json.decode(result[1].equipment) or CreateEmptyEquipment()
        return inventory, equipment
    else
        -- Create new inventory for player
        local inventory = CreateEmptyInventory()
        local equipment = CreateEmptyEquipment()
        
        ExecuteInsert('INSERT INTO dbf_inventory (identifier, inventory, equipment) VALUES (?, ?, ?)', {
            identifier,
            json.encode(inventory),
            json.encode(equipment)
        })
        
        return inventory, equipment
    end
end

function SavePlayerInventory(source)
    local identifier = Framework.GetIdentifier(source)
    if not identifier then return end
    
    if Inventories[source] then
        ExecuteUpdate('UPDATE dbf_inventory SET inventory = ?, equipment = ? WHERE identifier = ?', {
            json.encode(Inventories[source]),
            json.encode(Equipment[source] or CreateEmptyEquipment()),
            identifier
        })
        
        if Config.Debug then
            print('[dbf_foreinv] Saved inventory for: ' .. identifier)
        end
    end
end

function CreateEmptyInventory()
    local inventory = {}
    for i = 1, Config.MaxSlots do
        inventory[i] = { slotId = i, item = nil }
    end
    return inventory
end

function CreateEmptyEquipment()
    local equipment = {}
    for _, slot in ipairs(Config.EquipmentSlots) do
        equipment[slot] = { slot = slot, item = nil }
    end
    return equipment
end

-- ═══════════════════════════════════════════════════════════════════
-- WEIGHT CALCULATION
-- ═══════════════════════════════════════════════════════════════════

function CalculateWeight(inventory)
    local weight = 0
    for _, slot in pairs(inventory) do
        if slot.item then
            local itemData = Items[slot.item.name]
            if itemData then
                weight = weight + (itemData.weight * (slot.item.quantity or 1))
            end
        end
    end
    return weight
end

function CanCarryItem(source, itemName, amount)
    local inventory = Inventories[source]
    if not inventory then return false end
    
    local itemData = Items[itemName]
    if not itemData then return false end
    
    local currentWeight = CalculateWeight(inventory)
    local addedWeight = itemData.weight * amount
    
    return (currentWeight + addedWeight) <= Config.MaxWeight
end

-- ═══════════════════════════════════════════════════════════════════
-- ITEM MANAGEMENT
-- ═══════════════════════════════════════════════════════════════════

function AddItem(source, itemName, amount, metadata)
    local inventory = Inventories[source]
    if not inventory then return false end
    
    local itemData = Items[itemName]
    if not itemData then
        print('[dbf_foreinv] ERROR: Item not found: ' .. itemName)
        return false
    end
    
    amount = amount or 1
    
    if not CanCarryItem(source, itemName, amount) then
        Framework.Notify(source, 'Du kannst nicht mehr tragen!', 'error')
        return false
    end
    
    -- Try to stack with existing items
    for _, slot in pairs(inventory) do
        if slot.item and slot.item.name == itemName then
            local canAdd = itemData.maxStack - slot.item.quantity
            if canAdd > 0 then
                local toAdd = math.min(amount, canAdd)
                slot.item.quantity = slot.item.quantity + toAdd
                amount = amount - toAdd
                
                if amount <= 0 then
                    UpdateClientInventory(source)
                    SavePlayerInventory(source)
                    return true
                end
            end
        end
    end
    
    -- Add to empty slots
    while amount > 0 do
        local emptySlot = FindEmptySlot(inventory)
        if not emptySlot then
            Framework.Notify(source, 'Inventar ist voll!', 'error')
            UpdateClientInventory(source)
            SavePlayerInventory(source)
            return false
        end
        
        local toAdd = math.min(amount, itemData.maxStack)
        inventory[emptySlot].item = {
            name = itemName,
            quantity = toAdd,
            durability = itemData.durability or 100,
            metadata = metadata or {}
        }
        amount = amount - toAdd
    end
    
    UpdateClientInventory(source)
    SavePlayerInventory(source)
    Framework.Notify(source, itemData.label .. ' erhalten (x' .. (amount or 1) .. ')', 'success')
    return true
end

function RemoveItem(source, itemName, amount, slotId)
    local inventory = Inventories[source]
    if not inventory then return false end
    
    amount = amount or 1
    local removed = 0
    
    if slotId then
        -- Remove from specific slot
        local slot = inventory[slotId]
        if slot and slot.item and slot.item.name == itemName then
            local toRemove = math.min(amount, slot.item.quantity)
            slot.item.quantity = slot.item.quantity - toRemove
            removed = removed + toRemove
            
            if slot.item.quantity <= 0 then
                slot.item = nil
            end
        end
    else
        -- Remove from any slot
        for _, slot in pairs(inventory) do
            if slot.item and slot.item.name == itemName then
                local toRemove = math.min(amount - removed, slot.item.quantity)
                slot.item.quantity = slot.item.quantity - toRemove
                removed = removed + toRemove
                
                if slot.item.quantity <= 0 then
                    slot.item = nil
                end
                
                if removed >= amount then break end
            end
        end
    end
    
    if removed > 0 then
        UpdateClientInventory(source)
        SavePlayerInventory(source)
        return true
    end
    
    return false
end

function HasItem(source, itemName, amount)
    local inventory = Inventories[source]
    if not inventory then return false end
    
    amount = amount or 1
    local count = 0
    
    for _, slot in pairs(inventory) do
        if slot.item and slot.item.name == itemName then
            count = count + slot.item.quantity
        end
    end
    
    return count >= amount
end

function GetItemCount(source, itemName)
    local inventory = Inventories[source]
    if not inventory then return 0 end
    
    local count = 0
    for _, slot in pairs(inventory) do
        if slot.item and slot.item.name == itemName then
            count = count + slot.item.quantity
        end
    end
    
    return count
end

function FindEmptySlot(inventory)
    for i, slot in ipairs(inventory) do
        if not slot.item then
            return i
        end
    end
    return nil
end

-- ═══════════════════════════════════════════════════════════════════
-- CLIENT SYNC
-- ═══════════════════════════════════════════════════════════════════

function UpdateClientInventory(source)
    local inventory = Inventories[source]
    local equipment = Equipment[source]
    local weight = CalculateWeight(inventory)
    
    -- Enhance inventory with item data
    local enhancedInventory = {}
    for i, slot in pairs(inventory) do
        if slot.item then
            local itemData = Items[slot.item.name]
            if itemData then
                enhancedInventory[i] = {
                    slotId = slot.slotId,
                    item = {
                        name = slot.item.name,
                        label = itemData.label,
                        description = itemData.description,
                        icon = itemData.icon,
                        quantity = slot.item.quantity,
                        weight = itemData.weight,
                        maxStack = itemData.maxStack,
                        category = itemData.category,
                        rarity = itemData.rarity,
                        usable = itemData.usable,
                        durability = slot.item.durability,
                        metadata = slot.item.metadata
                    }
                }
            end
        else
            enhancedInventory[i] = { slotId = i, item = nil }
        end
    end
    
    TriggerClientEvent('dbf_foreinv:client:updateInventory', source, enhancedInventory, equipment, weight)
end

-- ═══════════════════════════════════════════════════════════════════
-- EVENTS
-- ═══════════════════════════════════════════════════════════════════

RegisterNetEvent('dbf_foreinv:server:getInventory', function()
    local source = source
    local identifier = Framework.GetIdentifier(source)
    
    if not Inventories[source] then
        Inventories[source], Equipment[source] = LoadPlayerInventory(source)
    end
    
    UpdateClientInventory(source)
end)

RegisterNetEvent('dbf_foreinv:server:useItem', function(itemName, slotId)
    local source = source
    local inventory = Inventories[source]
    
    if not inventory or not inventory[slotId] then return end
    
    local slot = inventory[slotId]
    if not slot.item or slot.item.name ~= itemName then return end
    
    local itemData = Items[itemName]
    if not itemData or not itemData.usable then return end
    
    -- Handle different item categories
    if itemData.category == 'food' then
        TriggerClientEvent('dbf_foreinv:client:useFood', source, itemData)
        
    elseif itemData.category == 'drink' then
        TriggerClientEvent('dbf_foreinv:client:useDrink', source, itemData)
        
    elseif itemData.category == 'medical' then
        TriggerClientEvent('dbf_foreinv:client:useMedical', source, itemData)
        
    elseif itemData.category == 'weapon' then
        -- Give weapon to player
        if itemData.weaponHash then
            Framework.GiveWeapon(source, itemData.weaponHash, 0)
        end
        
    elseif itemData.category == 'ammo' then
        -- Add ammo to current weapon
        TriggerClientEvent('dbf_foreinv:client:addAmmo', source, itemData.ammoType, slot.item.quantity)
        RemoveItem(source, itemName, slot.item.quantity, slotId)
        
    elseif itemData.armor then
        TriggerClientEvent('dbf_foreinv:client:useArmor', source, itemData)
    end
    
    if Config.Debug then
        print('[dbf_foreinv] ' .. Framework.GetPlayerName(source) .. ' used item: ' .. itemName)
    end
end)

RegisterNetEvent('dbf_foreinv:server:finishUseItem', function(itemName, category)
    local source = source
    
    -- Remove 1 of the used item
    RemoveItem(source, itemName, 1)
    
    local itemData = Items[itemName]
    if itemData then
        -- Apply effects based on category
        if category == 'food' and itemData.hunger then
            -- Integrate with hunger system if available
            if Framework.Name == 'qb' then
                TriggerClientEvent('hud:client:UpdateNeeds', source, itemData.hunger, false)
            elseif Framework.Name == 'esx' and GetResourceState('esx_status') == 'started' then
                TriggerClientEvent('esx_status:add', source, 'hunger', itemData.hunger * 10000)
            end
        elseif category == 'drink' and itemData.thirst then
            if Framework.Name == 'qb' then
                TriggerClientEvent('hud:client:UpdateNeeds', source, false, itemData.thirst)
            elseif Framework.Name == 'esx' and GetResourceState('esx_status') == 'started' then
                TriggerClientEvent('esx_status:add', source, 'thirst', itemData.thirst * 10000)
            end
        end
    end
end)

RegisterNetEvent('dbf_foreinv:server:dropItem', function(itemName, slotId, amount)
    local source = source
    local inventory = Inventories[source]
    
    if not inventory or not inventory[slotId] then return end
    
    local slot = inventory[slotId]
    if not slot.item or slot.item.name ~= itemName then return end
    
    amount = math.min(amount, slot.item.quantity)
    
    if RemoveItem(source, itemName, amount, slotId) then
        -- Create ground drop
        local ped = GetPlayerPed(source)
        local coords = GetEntityCoords(ped)
        
        TriggerEvent('dbf_foreinv:server:createDrop', source, itemName, amount, coords)
        
        local itemData = Items[itemName]
        Framework.Notify(source, (itemData and itemData.label or itemName) .. ' abgelegt (x' .. amount .. ')', 'info')
    end
end)

RegisterNetEvent('dbf_foreinv:server:giveItem', function(itemName, slotId, amount, targetId)
    local source = source
    local inventory = Inventories[source]
    
    if not inventory or not inventory[slotId] then return end
    
    local slot = inventory[slotId]
    if not slot.item or slot.item.name ~= itemName then return end
    
    -- Verify target is nearby
    local sourcePed = GetPlayerPed(source)
    local targetPed = GetPlayerPed(targetId)
    
    if not targetPed then
        Framework.Notify(source, 'Spieler nicht gefunden', 'error')
        return
    end
    
    local sourceCoords = GetEntityCoords(sourcePed)
    local targetCoords = GetEntityCoords(targetPed)
    
    if #(sourceCoords - targetCoords) > 5.0 then
        Framework.Notify(source, 'Spieler zu weit entfernt', 'error')
        return
    end
    
    amount = math.min(amount, slot.item.quantity)
    
    if not CanCarryItem(targetId, itemName, amount) then
        Framework.Notify(source, 'Der andere Spieler kann nicht mehr tragen', 'error')
        return
    end
    
    if RemoveItem(source, itemName, amount, slotId) then
        AddItem(targetId, itemName, amount, slot.item.metadata)
        
        local itemData = Items[itemName]
        local itemLabel = itemData and itemData.label or itemName
        
        Framework.Notify(source, itemLabel .. ' gegeben (x' .. amount .. ')', 'success')
        Framework.Notify(targetId, itemLabel .. ' erhalten (x' .. amount .. ')', 'success')
    end
end)

RegisterNetEvent('dbf_foreinv:server:splitItem', function(itemName, slotId, amount)
    local source = source
    local inventory = Inventories[source]
    
    if not inventory or not inventory[slotId] then return end
    
    local slot = inventory[slotId]
    if not slot.item or slot.item.name ~= itemName then return end
    
    if slot.item.quantity <= 1 then return end
    
    local emptySlot = FindEmptySlot(inventory)
    if not emptySlot then
        Framework.Notify(source, 'Kein freier Slot zum Teilen', 'error')
        return
    end
    
    amount = math.min(amount, slot.item.quantity - 1)
    
    -- Create split stack
    inventory[emptySlot].item = {
        name = itemName,
        quantity = amount,
        durability = slot.item.durability,
        metadata = slot.item.metadata
    }
    
    -- Reduce original stack
    slot.item.quantity = slot.item.quantity - amount
    
    UpdateClientInventory(source)
    SavePlayerInventory(source)
    
    Framework.Notify(source, 'Item geteilt', 'success')
end)

RegisterNetEvent('dbf_foreinv:server:moveItem', function(fromSlot, toSlot, fromType, toType)
    local source = source
    local inventory = Inventories[source]
    
    if not inventory then return end
    
    if fromType == 'inventory' and toType == 'inventory' then
        local fromItem = inventory[fromSlot] and inventory[fromSlot].item
        local toItem = inventory[toSlot] and inventory[toSlot].item
        
        if fromItem and toItem and fromItem.name == toItem.name then
            -- Stack items
            local itemData = Items[fromItem.name]
            local maxStack = itemData and itemData.maxStack or Config.MaxStackSize
            local canAdd = maxStack - toItem.quantity
            
            if canAdd > 0 then
                local toAdd = math.min(fromItem.quantity, canAdd)
                toItem.quantity = toItem.quantity + toAdd
                fromItem.quantity = fromItem.quantity - toAdd
                
                if fromItem.quantity <= 0 then
                    inventory[fromSlot].item = nil
                end
            end
        else
            -- Swap items
            inventory[fromSlot].item = toItem
            inventory[toSlot].item = fromItem
        end
        
        UpdateClientInventory(source)
        SavePlayerInventory(source)
    end
end)

RegisterNetEvent('dbf_foreinv:server:destroyItem', function(itemName, slotId)
    local source = source
    
    if RemoveItem(source, itemName, 999999, slotId) then
        Framework.Notify(source, 'Item zerstört', 'info')
    end
end)

RegisterNetEvent('dbf_foreinv:server:useQuickSlot', function(slot)
    local source = source
    local inventory = Inventories[source]
    
    if not inventory or not inventory[slot] then return end
    
    local invSlot = inventory[slot]
    if invSlot.item then
        TriggerEvent('dbf_foreinv:server:useItem', invSlot.item.name, slot)
    end
end)

-- ═══════════════════════════════════════════════════════════════════
-- PLAYER EVENTS
-- ═══════════════════════════════════════════════════════════════════

-- Player loaded
if Framework.Name == 'esx' then
    RegisterNetEvent('esx:playerLoaded', function(playerId, xPlayer)
        local source = playerId
        Inventories[source], Equipment[source] = LoadPlayerInventory(source)
    end)
elseif Framework.Name == 'qb' then
    RegisterNetEvent('QBCore:Server:PlayerLoaded', function(player)
        local source = player.PlayerData.source
        Inventories[source], Equipment[source] = LoadPlayerInventory(source)
    end)
end

-- Player dropped
AddEventHandler('playerDropped', function()
    local source = source
    SavePlayerInventory(source)
    Inventories[source] = nil
    Equipment[source] = nil
end)

-- Resource stop - save all inventories
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for source, _ in pairs(Inventories) do
            SavePlayerInventory(source)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════
-- EXPORTS
-- ═══════════════════════════════════════════════════════════════════

exports('AddItem', AddItem)
exports('RemoveItem', RemoveItem)
exports('HasItem', HasItem)
exports('GetItemCount', GetItemCount)
exports('GetInventory', function(source) return Inventories[source] end)
exports('GetEquipment', function(source) return Equipment[source] end)
exports('CanCarryItem', CanCarryItem)
exports('SaveInventory', SavePlayerInventory)

-- ═══════════════════════════════════════════════════════════════════
-- ADMIN COMMANDS
-- ═══════════════════════════════════════════════════════════════════

RegisterCommand('giveitem', function(source, args, rawCommand)
    local targetId = tonumber(args[1])
    local itemName = args[2]
    local amount = tonumber(args[3]) or 1
    
    if not targetId or not itemName then
        print('Usage: /giveitem [playerid] [item] [amount]')
        return
    end
    
    if AddItem(targetId, itemName, amount) then
        print('[dbf_foreinv] Gave ' .. amount .. 'x ' .. itemName .. ' to player ' .. targetId)
    else
        print('[dbf_foreinv] Failed to give item')
    end
end, true) -- Admin only

RegisterCommand('clearinv', function(source, args, rawCommand)
    local targetId = tonumber(args[1]) or source
    
    if Inventories[targetId] then
        Inventories[targetId] = CreateEmptyInventory()
        UpdateClientInventory(targetId)
        SavePlayerInventory(targetId)
        Framework.Notify(targetId, 'Inventar geleert', 'info')
    end
end, true)

-- ═══════════════════════════════════════════════════════════════════
-- DATABASE INITIALIZATION
-- ═══════════════════════════════════════════════════════════════════

Citizen.CreateThread(function()
    -- Wait for database connection
    Citizen.Wait(1000)
    
    -- Create tables if not exist
    ExecuteQuery([[
        CREATE TABLE IF NOT EXISTS `dbf_inventory` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `identifier` VARCHAR(60) NOT NULL UNIQUE,
            `inventory` LONGTEXT,
            `equipment` LONGTEXT,
            `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )
    ]], {})
    
    ExecuteQuery([[
        CREATE TABLE IF NOT EXISTS `dbf_drops` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `drop_id` VARCHAR(60) NOT NULL UNIQUE,
            `items` LONGTEXT,
            `coords` VARCHAR(255),
            `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ]], {})
    
    print('[dbf_foreinv] Database initialized')
end)
