worker = 0
dealerShown = false
pedCoords = vec3(0, 0, 0)
displayVehicle = 0
testDriveVehicle = 0
tablet = 0
dummyPed = 0
vehicleView = false
currentDealer = nil
AyseCore = exports.Ayse_Core:GetCoreObject()
selectedCharacter = AyseCore.Functions.GetSelectedCharacter()
dealerBlips = {}

RegisterNetEvent("Ayse:setCharacter", function(character)
    if selectedCharacter and character.id == selectedCharacter.id then return end
    selectedCharacter = character

    for _, blip in pairs(dealerBlips) do
        RemoveBlip(blip)
    end

    for dealership, dealerInfo in pairs(Config.dealerships) do
        if jobHasAccess(selectedCharacter.job, dealerInfo) then
            local blip = AddBlipForCoord(dealerInfo.pedCoords.x, dealerInfo.pedCoords.y, dealerInfo.pedCoords.z)
            dealerBlips[#dealerBlips+1] = blip
            SetBlipSprite(blip, 523)
            SetBlipColour(blip, 3)
            SetBlipScale(blip, 0.8)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString('Dealership')
            EndTextCommandSetBlipName(blip)
        end
    end
end)

for dealership, dealerInfo in pairs(Config.dealerships) do
    lib.registerMenu({
        id = 'Ayse_VehicleDealer:' .. dealership,
        title = dealership,
        position = 'top-right',
        onClose = function()
            dealerShown = false
        end,
        options = getDealerMenu(dealerInfo.categories)
    }, function(_, scrollIndex, args)
        for i = 1, #Config.vehicles[args.category] do
            if i == scrollIndex then
                lib.hideMenu()
                createVehicleView(Config.vehicles[args.category][i].model, Config.vehicles[args.category][i].price)
            end
        end
    end)
end

AddEventHandler('onResourceStart', function(resourceName)
    if cache.resource ~= resourceName then return end
    selectedCharacter = AyseCore.Functions.GetSelectedCharacter()
    for dealership, dealerInfo in pairs(Config.dealerships) do
        if jobHasAccess(selectedCharacter.job, dealerInfo) then
            local blip = AddBlipForCoord(dealerInfo.pedCoords.x, dealerInfo.pedCoords.y, dealerInfo.pedCoords.z)
            dealerBlips[#dealerBlips+1] = blip
            SetBlipSprite(blip, 523)
            SetBlipColour(blip, 3)
            SetBlipScale(blip, 0.8)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString('Dealership')
            EndTextCommandSetBlipName(blip)
        end
    end

    for _, vehicles in pairs(Config.vehicles) do
        for _, vehicle in pairs(vehicles) do
            if vehicle.label then
                AddTextEntryByHash(vehicle.model, vehicle.label)
            end
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if cache.resource ~= resourceName then return end

    TriggerServerEvent('Ayse_VehicleDealer:setTestDriveBucket', true)

    lib.hideMenu()
    lib.hideTextUI()
    if worker > 0 then
        DeletePed(worker)
    end

    if displayVehicle > 0 then
        DeleteVehicle(displayVehicle)
    end

    if testDriveVehicle > 0 then
        SetEntityAsMissionEntity(testDriveVehicle, true, true)
        DeleteVehicle(testDriveVehicle)
    end

    if dummyPed > 0 then
        DeletePed(dummyPed)
    end

    if tablet > 0 then
        SetEntityAsMissionEntity(tablet, true, true)
        DeleteObject(tablet)
    end
end)

CreateThread(function()
    while true do
        pedCoords = GetEntityCoords(cache.ped)
        Wait(500)
    end
end)

CreateThread(function()
    local sleep = 500
    local notified = false

    while true do
        Wait(sleep)
        local nearDealer = false
        for dealership, dealerInfo in pairs(Config.dealerships) do
            local dist = #(pedCoords - vec3(dealerInfo.pedCoords.x, dealerInfo.pedCoords.y, dealerInfo.pedCoords.z))
            if selectedCharacter and dist <= 60.0 and jobHasAccess(selectedCharacter.job, dealerInfo) then
                nearDealer = true
                if worker == 0 then
                    worker = spawnWorker(dealerInfo)
                end

                if dist < 1.6 then
                    sleep = 0

                    if not dealerShown or not notified then
                        notified = true
                        lib.showTextUI('[E] - Open Dealer Menu', {
                            icon = 'car'
                        })
                    end

                    if not dealerShown and IsControlJustPressed(0, 54) then
                        currentDealer = dealerInfo
                        dealerShown = true
                        lib.hideTextUI()
                        lib.showMenu('Ayse_VehicleDealer:' .. dealership)
                    end
                else
                    if lib.getOpenMenu() ~= nil then lib.hideMenu(true) end
                    if notified and not vehicleView then
                        notified = false
                        lib.hideTextUI()
                    end
                    sleep = 500
                end
                break
            end
        end
        if not nearDealer and worker > 0 then
            DeletePed(worker)
            worker = 0
        end
    end
end)
