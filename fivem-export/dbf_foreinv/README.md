# 📦 dbf_foreinv - ForeState Inventory System

Ein vollständiges, multi-framework kompatibles Inventar-System für FiveM.

![ForeState Logo](html/assets/logo.png)

## ✨ Features

- 🎮 **Multi-Framework Support**: ESX, QB-Core, ox_core, ND_Core, Standalone
- 🎨 **Modernes UI**: Glassmorphism Design mit ForeState Purple Theme
- 🖱️ **Drag & Drop**: Intuitives Item-Management
- ⌨️ **Hotkeys**: Schnellzugriff-Leiste (1-6)
- 📦 **Item Stacking**: Automatisches Stapeln gleicher Items
- ⚖️ **Gewichtssystem**: Realistische Traglast
- 🛡️ **Ausrüstungs-Slots**: 12 Equipment-Plätze
- 📍 **Drop System**: Items auf dem Boden ablegen
- 🔍 **Suche & Filter**: Nach Kategorie und Name filtern
- 💾 **MySQL Support**: oxmysql oder mysql-async

## 📋 Voraussetzungen

- FiveM Server
- oxmysql ODER mysql-async
- ESX / QB-Core / ox_core / ND_Core (optional für Standalone)
- ox_lib (optional, für bessere Notifications)

## 🚀 Installation

1. **Ordner kopieren**
   ```
   Kopiere dbf_foreinv nach resources/[inventory]/
   ```

2. **Server.cfg anpassen**
   ```cfg
   ensure oxmysql
   ensure es_extended  # oder qb-core
   ensure dbf_foreinv
   ```

3. **Logo hinzufügen**
   ```
   Kopiere dein Logo nach html/assets/logo.png
   ```

4. **Server starten**
   - Die Datenbank-Tabellen werden automatisch erstellt

## ⚙️ Konfiguration

Bearbeite `shared/config.lua`:

```lua
Config.Framework = 'auto'      -- 'auto', 'esx', 'qb', 'standalone'
Config.MaxSlots = 40           -- Inventar-Slots
Config.MaxWeight = 50.0        -- Max. Gewicht in kg
Config.OpenKey = 'TAB'         -- Taste zum Öffnen
Config.EnableDrops = true      -- Drop-System aktivieren
Config.DropDespawnTime = 300   -- Drops verschwinden nach X Sekunden
```

## 🎮 Steuerung

| Taste | Funktion |
|-------|----------|
| TAB | Inventar öffnen/schließen |
| 1-6 | Schnellzugriff-Slots |
| Linksklick | Item auswählen |
| Rechtsklick | Kontextmenü öffnen |
| Drag & Drop | Items verschieben |
| ESC | Schließen |

## 📦 Items hinzufügen

Bearbeite `shared/items.lua`:

```lua
Items['neues_item'] = {
    name = 'neues_item',
    label = 'Neues Item',
    description = 'Beschreibung des Items',
    weight = 0.5,
    maxStack = 50,
    category = 'misc',
    rarity = 'common',  -- common, uncommon, rare, epic, legendary
    usable = true,
    icon = 'neues_item.png'
}
```

## 🔧 Exports

### Server-seitig

```lua
-- Item hinzufügen
exports['dbf_foreinv']:AddItem(source, 'item_name', amount, metadata)

-- Item entfernen
exports['dbf_foreinv']:RemoveItem(source, 'item_name', amount, slotId)

-- Item prüfen
exports['dbf_foreinv']:HasItem(source, 'item_name', amount)

-- Item-Anzahl abrufen
exports['dbf_foreinv']:GetItemCount(source, 'item_name')

-- Inventar abrufen
exports['dbf_foreinv']:GetInventory(source)

-- Kann tragen?
exports['dbf_foreinv']:CanCarryItem(source, 'item_name', amount)
```

### Client-seitig

```lua
-- Inventar öffnen
exports['dbf_foreinv']:OpenInventory()

-- Inventar schließen
exports['dbf_foreinv']:CloseInventory()

-- Toggle
exports['dbf_foreinv']:ToggleInventory()

-- Ist offen?
exports['dbf_foreinv']:IsInventoryOpen()
```

## 📁 Ordnerstruktur

```
dbf_foreinv/
├── fxmanifest.lua
├── README.md
├── shared/
│   ├── config.lua
│   ├── framework.lua
│   └── items.lua
├── client/
│   ├── main.lua
│   └── drops.lua
├── server/
│   ├── main.lua
│   └── drops.lua
└── html/
    ├── index.html
    ├── style.css
    ├── script.js
    └── assets/
        └── logo.png
```

## 🎨 Anpassung

### Farben ändern

Bearbeite `html/style.css`:

```css
:root {
    --primary: #a200ff;        /* Hauptfarbe */
    --primary-light: #c44dff;  /* Hellere Variante */
    --primary-dark: #7a00bf;   /* Dunklere Variante */
}
```

### Item-Icons

Platziere PNG-Dateien in `html/assets/` und referenziere sie in `items.lua`:

```lua
icon = 'mein_icon.png'
```

## 🐛 Fehlerbehebung

### Inventar öffnet nicht
- Prüfe ob das Framework korrekt erkannt wird
- Aktiviere `Config.Debug = true` für mehr Logs

### Items werden nicht gespeichert
- Prüfe die Datenbankverbindung
- Stelle sicher, dass oxmysql/mysql-async läuft

### UI zeigt keine Items
- Prüfe die Browser-Konsole (F8 → F12)
- Stelle sicher, dass die NUI-Callbacks funktionieren

## 📞 Support

Bei Fragen oder Problemen:
- Discord: [ForeState RP]
- GitHub Issues

## 📄 Lizenz

© 2024 ForeState Development. Alle Rechte vorbehalten.

---

**Made with 💜 by ForeState Development**
