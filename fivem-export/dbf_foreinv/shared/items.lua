-- ═══════════════════════════════════════════════════════════════════
-- ITEMS DATABASE - All items with their properties
-- ═══════════════════════════════════════════════════════════════════

Items = {}

-- ═══════════════════════════════════════════════════════════════════
-- ITEM RARITIES
-- ═══════════════════════════════════════════════════════════════════
-- 'common', 'uncommon', 'rare', 'epic', 'legendary'

-- ═══════════════════════════════════════════════════════════════════
-- ITEM CATEGORIES  
-- ═══════════════════════════════════════════════════════════════════
-- 'weapon', 'ammo', 'food', 'drink', 'medical', 'clothing', 'tool', 
-- 'material', 'key', 'money', 'drug', 'misc'

-- ═══════════════════════════════════════════════════════════════════
-- WEAPONS
-- ═══════════════════════════════════════════════════════════════════
Items['weapon_pistol'] = {
    name = 'weapon_pistol',
    label = 'Pistole',
    description = 'Eine Standard 9mm Pistole',
    weight = 1.2,
    maxStack = 1,
    category = 'weapon',
    rarity = 'uncommon',
    usable = true,
    equipSlot = 'weapon_secondary',
    weaponHash = 'WEAPON_PISTOL',
    icon = 'weapon_pistol.png'
}

Items['weapon_combatpistol'] = {
    name = 'weapon_combatpistol',
    label = 'Combat Pistol',
    description = 'Kompakte Kampfpistole mit hoher Feuerrate',
    weight = 1.4,
    maxStack = 1,
    category = 'weapon',
    rarity = 'rare',
    usable = true,
    equipSlot = 'weapon_secondary',
    weaponHash = 'WEAPON_COMBATPISTOL',
    icon = 'weapon_combatpistol.png'
}

Items['weapon_smg'] = {
    name = 'weapon_smg',
    label = 'SMG',
    description = 'Maschinenpistole für den Nahkampf',
    weight = 2.8,
    maxStack = 1,
    category = 'weapon',
    rarity = 'rare',
    usable = true,
    equipSlot = 'weapon_primary',
    weaponHash = 'WEAPON_SMG',
    icon = 'weapon_smg.png'
}

Items['weapon_assaultrifle'] = {
    name = 'weapon_assaultrifle',
    label = 'Sturmgewehr',
    description = 'AR-15 Sturmgewehr - Präzise und tödlich',
    weight = 4.5,
    maxStack = 1,
    category = 'weapon',
    rarity = 'epic',
    usable = true,
    equipSlot = 'weapon_primary',
    weaponHash = 'WEAPON_ASSAULTRIFLE',
    icon = 'weapon_assaultrifle.png'
}

Items['weapon_pumpshotgun'] = {
    name = 'weapon_pumpshotgun',
    label = 'Pumpgun',
    description = 'Pump-Action Schrotflinte',
    weight = 3.5,
    maxStack = 1,
    category = 'weapon',
    rarity = 'uncommon',
    usable = true,
    equipSlot = 'weapon_primary',
    weaponHash = 'WEAPON_PUMPSHOTGUN',
    icon = 'weapon_pumpshotgun.png'
}

Items['weapon_knife'] = {
    name = 'weapon_knife',
    label = 'Messer',
    description = 'Ein scharfes Messer',
    weight = 0.3,
    maxStack = 1,
    category = 'weapon',
    rarity = 'common',
    usable = true,
    equipSlot = 'weapon_secondary',
    weaponHash = 'WEAPON_KNIFE',
    icon = 'weapon_knife.png'
}

-- ═══════════════════════════════════════════════════════════════════
-- AMMUNITION
-- ═══════════════════════════════════════════════════════════════════
Items['ammo_pistol'] = {
    name = 'ammo_pistol',
    label = '9mm Munition',
    description = 'Munition für Pistolen',
    weight = 0.1,
    maxStack = 500,
    category = 'ammo',
    rarity = 'common',
    usable = true,
    ammoType = 'AMMO_PISTOL',
    icon = 'ammo_pistol.png'
}

Items['ammo_rifle'] = {
    name = 'ammo_rifle',
    label = 'Gewehrmunition',
    description = 'Munition für Gewehre',
    weight = 0.15,
    maxStack = 500,
    category = 'ammo',
    rarity = 'common',
    usable = true,
    ammoType = 'AMMO_RIFLE',
    icon = 'ammo_rifle.png'
}

Items['ammo_shotgun'] = {
    name = 'ammo_shotgun',
    label = 'Schrotmunition',
    description = 'Patronen für Schrotflinten',
    weight = 0.2,
    maxStack = 200,
    category = 'ammo',
    rarity = 'common',
    usable = true,
    ammoType = 'AMMO_SHOTGUN',
    icon = 'ammo_shotgun.png'
}

Items['ammo_smg'] = {
    name = 'ammo_smg',
    label = 'SMG Munition',
    description = 'Munition für Maschinenpistolen',
    weight = 0.1,
    maxStack = 500,
    category = 'ammo',
    rarity = 'common',
    usable = true,
    ammoType = 'AMMO_SMG',
    icon = 'ammo_smg.png'
}

-- ═══════════════════════════════════════════════════════════════════
-- FOOD
-- ═══════════════════════════════════════════════════════════════════
Items['burger'] = {
    name = 'burger',
    label = 'Burger',
    description = 'Ein saftiger Burger',
    weight = 0.3,
    maxStack = 20,
    category = 'food',
    rarity = 'common',
    usable = true,
    hunger = 25,
    icon = 'burger.png'
}

Items['pizza'] = {
    name = 'pizza',
    label = 'Pizza',
    description = 'Frische Pizza vom Italiener',
    weight = 0.5,
    maxStack = 10,
    category = 'food',
    rarity = 'common',
    usable = true,
    hunger = 40,
    icon = 'pizza.png'
}

Items['sandwich'] = {
    name = 'sandwich',
    label = 'Sandwich',
    description = 'Belegtes Sandwich',
    weight = 0.2,
    maxStack = 30,
    category = 'food',
    rarity = 'common',
    usable = true,
    hunger = 20,
    icon = 'sandwich.png'
}

Items['donut'] = {
    name = 'donut',
    label = 'Donut',
    description = 'Süßer Donut mit Glasur',
    weight = 0.1,
    maxStack = 50,
    category = 'food',
    rarity = 'common',
    usable = true,
    hunger = 10,
    icon = 'donut.png'
}

-- ═══════════════════════════════════════════════════════════════════
-- DRINKS
-- ═══════════════════════════════════════════════════════════════════
Items['water'] = {
    name = 'water',
    label = 'Wasser',
    description = 'Eine Flasche Wasser',
    weight = 0.5,
    maxStack = 20,
    category = 'drink',
    rarity = 'common',
    usable = true,
    thirst = 30,
    icon = 'water.png'
}

Items['cola'] = {
    name = 'cola',
    label = 'eCola',
    description = 'Erfrischende eCola',
    weight = 0.5,
    maxStack = 20,
    category = 'drink',
    rarity = 'common',
    usable = true,
    thirst = 25,
    icon = 'cola.png'
}

Items['coffee'] = {
    name = 'coffee',
    label = 'Kaffee',
    description = 'Heißer Kaffee',
    weight = 0.3,
    maxStack = 20,
    category = 'drink',
    rarity = 'common',
    usable = true,
    thirst = 20,
    stress = -10,
    icon = 'coffee.png'
}

Items['beer'] = {
    name = 'beer',
    label = 'Bier',
    description = 'Kühles Bier',
    weight = 0.5,
    maxStack = 20,
    category = 'drink',
    rarity = 'common',
    usable = true,
    thirst = 15,
    alcohol = 10,
    icon = 'beer.png'
}

-- ═══════════════════════════════════════════════════════════════════
-- MEDICAL
-- ═══════════════════════════════════════════════════════════════════
Items['bandage'] = {
    name = 'bandage',
    label = 'Bandage',
    description = 'Einfache Bandage zur Wundversorgung',
    weight = 0.1,
    maxStack = 50,
    category = 'medical',
    rarity = 'common',
    usable = true,
    heal = 15,
    icon = 'bandage.png'
}

Items['firstaid'] = {
    name = 'firstaid',
    label = 'Erste-Hilfe-Kit',
    description = 'Professionelles Erste-Hilfe-Set',
    weight = 0.8,
    maxStack = 10,
    category = 'medical',
    rarity = 'uncommon',
    usable = true,
    heal = 50,
    icon = 'firstaid.png'
}

Items['medkit'] = {
    name = 'medkit',
    label = 'Medkit',
    description = 'Vollständiges medizinisches Kit',
    weight = 1.5,
    maxStack = 5,
    category = 'medical',
    rarity = 'rare',
    usable = true,
    heal = 100,
    icon = 'medkit.png'
}

Items['painkillers'] = {
    name = 'painkillers',
    label = 'Schmerzmittel',
    description = 'Lindert Schmerzen',
    weight = 0.1,
    maxStack = 30,
    category = 'medical',
    rarity = 'common',
    usable = true,
    heal = 20,
    stress = -20,
    icon = 'painkillers.png'
}

Items['adrenaline'] = {
    name = 'adrenaline',
    label = 'Adrenalinspritze',
    description = 'Kann bewusstlose Personen wiederbeleben',
    weight = 0.2,
    maxStack = 5,
    category = 'medical',
    rarity = 'epic',
    usable = true,
    revive = true,
    icon = 'adrenaline.png'
}

-- ═══════════════════════════════════════════════════════════════════
-- CLOTHING / ARMOR
-- ═══════════════════════════════════════════════════════════════════
Items['armor'] = {
    name = 'armor',
    label = 'Kevlar-Weste',
    description = 'Schusssichere Weste',
    weight = 5.0,
    maxStack = 1,
    category = 'clothing',
    rarity = 'rare',
    usable = true,
    equipSlot = 'vest',
    armor = 50,
    icon = 'armor.png'
}

Items['heavyarmor'] = {
    name = 'heavyarmor',
    label = 'Schwere Schutzweste',
    description = 'Maximaler Schutz',
    weight = 8.0,
    maxStack = 1,
    category = 'clothing',
    rarity = 'epic',
    usable = true,
    equipSlot = 'vest',
    armor = 100,
    icon = 'heavyarmor.png'
}

-- ═══════════════════════════════════════════════════════════════════
-- TOOLS
-- ═══════════════════════════════════════════════════════════════════
Items['lockpick'] = {
    name = 'lockpick',
    label = 'Dietrich',
    description = 'Zum Öffnen von Schlössern',
    weight = 0.1,
    maxStack = 20,
    category = 'tool',
    rarity = 'uncommon',
    usable = true,
    breakChance = 20,
    icon = 'lockpick.png'
}

Items['advancedlockpick'] = {
    name = 'advancedlockpick',
    label = 'Profi-Dietrich',
    description = 'Hochwertiger Dietrich',
    weight = 0.2,
    maxStack = 10,
    category = 'tool',
    rarity = 'rare',
    usable = true,
    breakChance = 5,
    icon = 'advancedlockpick.png'
}

Items['repairkit'] = {
    name = 'repairkit',
    label = 'Reparatur-Kit',
    description = 'Zur Fahrzeugreparatur',
    weight = 2.0,
    maxStack = 5,
    category = 'tool',
    rarity = 'uncommon',
    usable = true,
    icon = 'repairkit.png'
}

Items['advancedrepairkit'] = {
    name = 'advancedrepairkit',
    label = 'Profi-Reparatur-Kit',
    description = 'Vollständige Fahrzeugreparatur',
    weight = 4.0,
    maxStack = 3,
    category = 'tool',
    rarity = 'rare',
    usable = true,
    icon = 'advancedrepairkit.png'
}

Items['radio'] = {
    name = 'radio',
    label = 'Funkgerät',
    description = 'Zur Kommunikation',
    weight = 0.5,
    maxStack = 1,
    category = 'tool',
    rarity = 'common',
    usable = true,
    icon = 'radio.png'
}

Items['binoculars'] = {
    name = 'binoculars',
    label = 'Fernglas',
    description = 'Für Beobachtungen',
    weight = 0.8,
    maxStack = 1,
    category = 'tool',
    rarity = 'uncommon',
    usable = true,
    icon = 'binoculars.png'
}

-- ═══════════════════════════════════════════════════════════════════
-- MATERIALS
-- ═══════════════════════════════════════════════════════════════════
Items['iron'] = {
    name = 'iron',
    label = 'Eisen',
    description = 'Roheisen',
    weight = 0.5,
    maxStack = 100,
    category = 'material',
    rarity = 'common',
    usable = false,
    icon = 'iron.png'
}

Items['steel'] = {
    name = 'steel',
    label = 'Stahl',
    description = 'Verarbeiteter Stahl',
    weight = 0.6,
    maxStack = 100,
    category = 'material',
    rarity = 'uncommon',
    usable = false,
    icon = 'steel.png'
}

Items['aluminum'] = {
    name = 'aluminum',
    label = 'Aluminium',
    description = 'Leichtes Metall',
    weight = 0.3,
    maxStack = 100,
    category = 'material',
    rarity = 'common',
    usable = false,
    icon = 'aluminum.png'
}

Items['plastic'] = {
    name = 'plastic',
    label = 'Plastik',
    description = 'Kunststoff',
    weight = 0.1,
    maxStack = 200,
    category = 'material',
    rarity = 'common',
    usable = false,
    icon = 'plastic.png'
}

Items['glass'] = {
    name = 'glass',
    label = 'Glas',
    description = 'Zerbrechliches Material',
    weight = 0.2,
    maxStack = 100,
    category = 'material',
    rarity = 'common',
    usable = false,
    icon = 'glass.png'
}

Items['rubber'] = {
    name = 'rubber',
    label = 'Gummi',
    description = 'Elastisches Material',
    weight = 0.2,
    maxStack = 100,
    category = 'material',
    rarity = 'common',
    usable = false,
    icon = 'rubber.png'
}

-- ═══════════════════════════════════════════════════════════════════
-- KEYS
-- ═══════════════════════════════════════════════════════════════════
Items['carkeys'] = {
    name = 'carkeys',
    label = 'Autoschlüssel',
    description = 'Schlüssel für ein Fahrzeug',
    weight = 0.1,
    maxStack = 1,
    category = 'key',
    rarity = 'common',
    usable = true,
    icon = 'carkeys.png'
}

Items['housekeys'] = {
    name = 'housekeys',
    label = 'Hausschlüssel',
    description = 'Schlüssel für ein Haus',
    weight = 0.1,
    maxStack = 1,
    category = 'key',
    rarity = 'common',
    usable = true,
    icon = 'housekeys.png'
}

-- ═══════════════════════════════════════════════════════════════════
-- MONEY
-- ═══════════════════════════════════════════════════════════════════
Items['money'] = {
    name = 'money',
    label = 'Bargeld',
    description = 'Schmutziges Geld',
    weight = 0.0,
    maxStack = 999999,
    category = 'money',
    rarity = 'common',
    usable = true,
    icon = 'money.png'
}

Items['black_money'] = {
    name = 'black_money',
    label = 'Schwarzgeld',
    description = 'Illegales Geld',
    weight = 0.0,
    maxStack = 999999,
    category = 'money',
    rarity = 'uncommon',
    usable = false,
    icon = 'black_money.png'
}

Items['markedcash'] = {
    name = 'markedcash',
    label = 'Markierte Scheine',
    description = 'Vom Bankraub',
    weight = 0.1,
    maxStack = 10000,
    category = 'money',
    rarity = 'rare',
    usable = false,
    icon = 'markedcash.png'
}

-- ═══════════════════════════════════════════════════════════════════
-- DRUGS (Example - Adjust as needed)
-- ═══════════════════════════════════════════════════════════════════
Items['weed'] = {
    name = 'weed',
    label = 'Cannabis',
    description = 'Getrocknete Blüten',
    weight = 0.1,
    maxStack = 100,
    category = 'drug',
    rarity = 'common',
    usable = true,
    stress = -30,
    icon = 'weed.png',
    illegal = true
}

Items['coke'] = {
    name = 'coke',
    label = 'Kokain',
    description = 'Weißes Pulver',
    weight = 0.1,
    maxStack = 50,
    category = 'drug',
    rarity = 'rare',
    usable = true,
    stress = -50,
    stamina = 50,
    icon = 'coke.png',
    illegal = true
}

-- ═══════════════════════════════════════════════════════════════════
-- MISC
-- ═══════════════════════════════════════════════════════════════════
Items['phone'] = {
    name = 'phone',
    label = 'Smartphone',
    description = 'iFruit Smartphone',
    weight = 0.2,
    maxStack = 1,
    category = 'misc',
    rarity = 'common',
    usable = true,
    equipSlot = 'phone',
    icon = 'phone.png'
}

Items['wallet'] = {
    name = 'wallet',
    label = 'Geldbörse',
    description = 'Enthält Ausweise und Karten',
    weight = 0.1,
    maxStack = 1,
    category = 'misc',
    rarity = 'common',
    usable = true,
    equipSlot = 'wallet',
    icon = 'wallet.png'
}

Items['id_card'] = {
    name = 'id_card',
    label = 'Personalausweis',
    description = 'Dein Ausweis',
    weight = 0.0,
    maxStack = 1,
    category = 'misc',
    rarity = 'common',
    usable = true,
    icon = 'id_card.png'
}

Items['driver_license'] = {
    name = 'driver_license',
    label = 'Führerschein',
    description = 'Fahrerlaubnis',
    weight = 0.0,
    maxStack = 1,
    category = 'misc',
    rarity = 'common',
    usable = true,
    icon = 'driver_license.png'
}

Items['rolex'] = {
    name = 'rolex',
    label = 'Goldene Rolex',
    description = 'Luxusuhr im Wert von Tausenden',
    weight = 0.3,
    maxStack = 1,
    category = 'misc',
    rarity = 'legendary',
    usable = false,
    icon = 'rolex.png'
}

-- ═══════════════════════════════════════════════════════════════════
-- HELPER FUNCTION
-- ═══════════════════════════════════════════════════════════════════

function GetItemData(itemName)
    if Items[itemName] then
        return Items[itemName]
    end
    return nil
end

function RegisterItem(itemName, data)
    if not Items[itemName] then
        Items[itemName] = data
        if Config.Debug then
            print('[dbf_foreinv] Registered new item: ' .. itemName)
        end
    end
end
