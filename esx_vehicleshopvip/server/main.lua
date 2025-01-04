-- Asegúrate de que Config está definido antes de usarlo
Config = {}
Config.PlateLetters = 3
Config.PlateNumbers = 3
Config.PlateUseSpace = true

local categories, vehicles = {}, {}
local vehiclesByModel = {}

-- Verificar el límite de caracteres para las matrículas
CreateThread(function()
    local char = Config.PlateLetters or 0 -- Asegurarse de que PlateLetters esté definido
    char = char + (Config.PlateNumbers or 0) -- Asegurarse de que PlateNumbers esté definido
    if Config.PlateUseSpace then char = char + 1 end

    if char > 8 then
        print(('[^3WARNING^7] Character Limit Exceeded, ^5%s/8^7!'):format(char))
    end
end)

-- Eliminar vehículo de propiedad
function RemoveOwnedVehicle(plate)
    MySQL.update('DELETE FROM owned_vehicles WHERE plate = ?', {plate})
end

-- Evento cuando el recurso se inicia
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        SQLVehiclesAndCategories()
    end
end)

-- Obtener vehículos y categorías de la base de datos
function SQLVehiclesAndCategories()
    categories = MySQL.query.await('SELECT * FROM vehicle_categories2')
    vehicles = MySQL.query.await('SELECT vehicles2.*, vehicle_categories2.label AS categoryLabel FROM vehicles2 JOIN vehicle_categories2 ON vehicles2.category = vehicle_categories2.name')

    for _, vehicle in pairs(vehicles) do
        vehiclesByModel[vehicle.model] = vehicle
    end

    TriggerClientEvent("esx_vehicleshopvip:updateVehiclesAndCategories", -1, vehicles, categories, vehiclesByModel)
end

-- Actualizar datos de vehículos y categorías cada 5 minutos
CreateThread(function()
    while true do
        Wait(300000) -- 5 minutos en milisegundos
        SQLVehiclesAndCategories()
    end
end)

-- Obtener vehículo por modelo
function getVehicleFromModel(model)
    return vehiclesByModel[model]
end

-- Evento para obtener vehículos y categorías
RegisterNetEvent("esx_vehicleshopvip:getVehiclesAndCategories", function()
    TriggerClientEvent("esx_vehicleshopvip:updateVehiclesAndCategories", source, vehicles, categories, vehiclesByModel)
end)

-- Callback para comprar un vehículo
ESX.RegisterServerCallback('esx_vehicleshopvip:buyVehicle', function(source, cb, model, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    local modelPrice = getVehicleFromModel(model).price

    MySQL.scalar('SELECT ultra_coins FROM users_vip_credits WHERE identifier = ?', {xPlayer.identifier}, function(vipCoins)
        if modelPrice and vipCoins and vipCoins >= modelPrice then
            MySQL.update('UPDATE users_vip_credits SET ultra_coins = ultra_coins - ? WHERE identifier = ?', {modelPrice, xPlayer.identifier})

            MySQL.insert('INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (?, ?, ?)', {xPlayer.identifier, plate, json.encode({model = joaat(model), plate = plate})},
            function(rowsChanged)
                xPlayer.showNotification(TranslateCap('vehicle_belongs', plate))
                ESX.OneSync.SpawnVehicle(joaat(model), Config.Zones.ShopOutside.Pos, Config.Zones.ShopOutside.Heading, {plate = plate}, function(vehicle)
                    Wait(100)
                    local vehicle = NetworkGetEntityFromNetworkId(vehicle)
                    Wait(300)
                    TaskWarpPedIntoVehicle(GetPlayerPed(source), vehicle, -1)
                end)
                cb(true)
            end)
        else
            cb(false)
        end
    end)
end)

-- Callback para obtener el inventario del jugador
ESX.RegisterServerCallback('esx_vehicleshopvip:getPlayerInventory', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local items = xPlayer.inventory

    cb({items = items})
end)

-- Callback para verificar si la matrícula está en uso
ESX.RegisterServerCallback('esx_vehicleshopvip:isPlateTaken', function(source, cb, plate)
    MySQL.scalar('SELECT plate FROM owned_vehicles WHERE plate = ?', {plate},
    function(result)
        cb(result ~= nil)
    end)
end)

-- Callback para recuperar vehículos de trabajo
ESX.RegisterServerCallback('esx_vehicleshopvip:retrieveJobVehicles', function(source, cb, type)
    local xPlayer = ESX.GetPlayerFromId(source)

    MySQL.query('SELECT * FROM owned_vehicles WHERE owner = ? AND type = ? AND job = ?', {xPlayer.identifier, type, xPlayer.job.name},
    function(result)
        cb(result)
    end)
end)

-- Evento para establecer el estado del vehículo de trabajo
RegisterNetEvent('esx_vehicleshopvip:setJobVehicleState')
AddEventHandler('esx_vehicleshopvip:setJobVehicleState', function(plate, state)
    local xPlayer = ESX.GetPlayerFromId(source)

    MySQL.update('UPDATE owned_vehicles SET `stored` = ? WHERE plate = ? AND job = ?', {state, plate, xPlayer.job.name},
    function(rowsChanged)
        if rowsChanged == 0 then
            print(('[^3WARNING^7] Player ^5%s^7 Attempted To Exploit the Garage!'):format(source, plate))
        end
    end)
end)
