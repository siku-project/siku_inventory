fx_version 'cerulean'
game 'gta5'

author 'Siku Studio'
description 'The official inventory system of the SIKU ecosystem — a modern, modular and high-performance resource for managing items, weight, hotbars, ground drops, metadata, unique item instances, and seamless player interactions.'
version '0.5.0'

name 'siku_inventory'

lua54 'yes'

shared_scripts {
  '@siku_core/init.lua',
  'config/*.lua',
  'shared/utils/locale.lua',
  'shared/items.lua',
  'shared/ammo.lua',
  'shared/weapons.lua',
  'shared/components.lua',
  'shared/stashes.lua',
  'shared/modules/**/*.lua',
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server/init.lua',
  'server/modules/**/*.lua',
}

client_scripts {
  'client/modules/**/*.lua',
}

ui_page 'web/dist/index.html'

files {
  'translations/*.lua',
  'web/dist/**/*',
}

dependencies {
  'siku_core',
  'oxmysql',
}
