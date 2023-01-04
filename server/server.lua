local random = math.random
local seed = math.randomseed
local time = os.time

AyseCore = exports.Ayse_Core:GetCoreObject()

local function getPriceFromModel(model)
    for _, category in pairs(Config.vehicles) do
        for _, veh in pairs(category) do
            if veh.model == model then
                return veh.price
            end
        end
    end
    return false
end

RegisterNetEvent('Ayse_VehicleDealer:purchaseVehicle', function(props, inGarage, method)
    local source = source
    local player = AyseCore.Functions.GetPlayer(source)
    local price = getPriceFromModel(props.model)

    if not price or (player[method] < price) then return end
    AyseCore.Functions.DeductMoney(price, source, method)

    local vehid = exports.Ayse_VehicleSystem:setVehicleOwned(source, props, true)
    if not inGarage then
        exports.Ayse_VehicleSystem:spawnOwnedVehicle(source, vehid, Config.purchasedVehicleSpawns)
    end
end)

RegisterNetEvent('Ayse_VehicleDealer:setTestDriveBucket', function(returnToDefaultBucket, netId)
    local source = source
    local bucket = 0

    if not returnToDefaultBucket then
        seed(time())
        bucket = random(1, 100)
    else
        bucket = bucket
    end

    SetPlayerRoutingBucket(source, tonumber(bucket))

    print(GetPlayerRoutingBucket(source))
end)
