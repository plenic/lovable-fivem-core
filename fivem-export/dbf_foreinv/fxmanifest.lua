fx_version 'cerulean'
game 'gta5'

name 'dbf_foreinv'
author 'ForeState Development'
description 'ForeState Inventory System - Multi-Framework Compatible'
version '1.0.0'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua', -- Optional: for notifications
    'shared/config.lua',
    'shared/framework.lua',
    'shared/items.lua'
}

client_scripts {
    'client/main.lua',
    'client/drops.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua', -- or mysql-async
    'server/main.lua',
    'server/drops.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/assets/*.png',
    'html/assets/*.jpg'
}

dependencies {
    'oxmysql' -- or 'mysql-async'
}
