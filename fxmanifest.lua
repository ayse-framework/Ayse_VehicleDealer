author "helmimarif"
description "Vehicle Dealer for AyseFramework"
version "1.0"

fx_version "cerulean"
game "gta5"
lua54 "yes"

shared_scripts {
    "@ox_lib/init.lua",
    "config.lua"
}
client_scripts {
    "client/functions.lua",
    "client/client.lua"
}
server_script "server/server.lua"

dependencies {
    "Ayse_Core",
    "Ayse_VehicleSystem",
    "ox_lib"
}
