Config = {}

-- ═══════════════════════════════════════════════════════════════════
-- FRAMEWORK DETECTION (auto-detect or manual)
-- ═══════════════════════════════════════════════════════════════════
Config.Framework = 'auto' -- 'auto', 'esx', 'qb', 'standalone'

-- ═══════════════════════════════════════════════════════════════════
-- INVENTORY SETTINGS
-- ═══════════════════════════════════════════════════════════════════
Config.MaxSlots = 40                    -- Maximum inventory slots
Config.MaxWeight = 50.0                 -- Maximum carry weight in kg
Config.MaxStackSize = 999               -- Default max stack size

-- ═══════════════════════════════════════════════════════════════════
-- KEYBINDS
-- ═══════════════════════════════════════════════════════════════════
Config.OpenKey = 'TAB'                  -- Key to open inventory
Config.UseKey = 'E'                     -- Key to use item in hand

-- ═══════════════════════════════════════════════════════════════════
-- DROP SYSTEM
-- ═══════════════════════════════════════════════════════════════════
Config.EnableDrops = true               -- Enable item drops on ground
Config.DropDespawnTime = 300            -- Seconds until drops despawn (0 = never)
Config.MaxDropDistance = 2.0            -- Max distance to pick up drops

-- ═══════════════════════════════════════════════════════════════════
-- UI SETTINGS
-- ═══════════════════════════════════════════════════════════════════
Config.PrimaryColor = '#a200ff'         -- ForeState purple
Config.EnableAnimations = true          -- Enable UI animations
Config.EnableSounds = true              -- Enable UI sounds

-- ═══════════════════════════════════════════════════════════════════
-- SECONDARY INVENTORIES
-- ═══════════════════════════════════════════════════════════════════
Config.TrunkSlots = 50                  -- Vehicle trunk slots
Config.GloveboxSlots = 10               -- Glovebox slots
Config.StashSlots = 100                 -- Personal stash slots

-- ═══════════════════════════════════════════════════════════════════
-- DATABASE
-- ═══════════════════════════════════════════════════════════════════
Config.UseOxmysql = true                -- true = oxmysql, false = mysql-async

-- ═══════════════════════════════════════════════════════════════════
-- EQUIPMENT SLOTS
-- ═══════════════════════════════════════════════════════════════════
Config.EquipmentSlots = {
    'head',
    'face',
    'torso',
    'vest',
    'legs',
    'feet',
    'bag',
    'weapon_primary',
    'weapon_secondary',
    'phone',
    'keys',
    'wallet'
}

-- ═══════════════════════════════════════════════════════════════════
-- WEAPON CONFIG
-- ═══════════════════════════════════════════════════════════════════
Config.WeaponAsItems = true             -- Weapons are inventory items
Config.RemoveWeaponOnDrop = true        -- Remove weapon when dropped

-- ═══════════════════════════════════════════════════════════════════
-- NOTIFICATIONS
-- ═══════════════════════════════════════════════════════════════════
Config.NotifySystem = 'auto'            -- 'auto', 'ox_lib', 'esx', 'qb', 'custom'

-- ═══════════════════════════════════════════════════════════════════
-- DEBUG
-- ═══════════════════════════════════════════════════════════════════
Config.Debug = false                    -- Enable debug prints
