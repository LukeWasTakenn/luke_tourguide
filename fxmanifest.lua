fx_version 'cerulean'

game 'gta5'

author 'Luke'
description 'Tour Guide Job for ESX Server'
version '1.0.0'

client_scripts{
    "@warmenu/warmenu.lua",
    'client/client.lua',
    'config.lua',
}

server_scripts{
    'server/server.lua',
    'config.lua',
}