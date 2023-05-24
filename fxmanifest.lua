fx_version 'cerulean'
game 'gta5'

author 'Funeral DJ'
version '1.0.0'
lua54    'yes'
shared_script 'shared.lua'
server_scripts{
    '@oxmysql/lib/MySQL.lua',
    '@es_extended/common/interval.lua',
    'config.lua',
    'server/main.lua',
    'server/classes/*.lua',
    'UsableItems.lua'
}

client_scripts{
    'config.lua',
    'client/main.lua',
    'client/utils.lua',
    'client/blips.lua',
    'client/dealer.lua',
}

dependencies {
    'es_extended',
    'oxmysql',
    'esx_menu_default',
    'esx_menu_dialog',
    'rprogress'
}
