
-- Declaración de variables globales
local HasAlreadyEnteredMarker, IsInShopMenu = false, false
local CurrentAction, CurrentActionMsg, LastZone, currentDisplayVehicle, CurrentVehicleData
local CurrentActionData, Vehicles, Categories = {}, {}, {}
local VehiclesByModel = {}
local vehiclesByCategory = {}

-- Función para obtener vehículo desde el modelo
function getVehicleFromModel(model)
    return VehiclesByModel[model]
end

-- Evento cuando el jugador es cargado
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    TriggerServerEvent("esx_vehicleshopvip:getVehiclesAndCategories")
end)

-- Evento para actualizar vehículos y categorías
RegisterNetEvent('esx_vehicleshopvip:updateVehiclesAndCategories', function(vehicles, categories, vehiclesByModel)
    Vehicles = vehicles
    Categories = categories
    VehiclesByModel = vehiclesByModel

    table.sort(Vehicles, function(a, b)
        return a.name < b.name
    end)

    for _, vehicle in ipairs(Vehicles) do
        if IsModelInCdimage(joaat(vehicle.model)) then
            local category = vehicle.category
            if not vehiclesByCategory[category] then
                vehiclesByCategory[category] = {}
            end
            table.insert(vehiclesByCategory[category], vehicle)
        else
            print(('[^3WARNING^7] Ignoring vehicle ^5%s^7 due to invalid model'):format(vehicle.model))
        end
    end
end)

-- Función para eliminar vehículo en display
function DeleteDisplayVehicleInsideShop()
    local attempt = 0

    if currentDisplayVehicle and DoesEntityExist(currentDisplayVehicle) then
        while DoesEntityExist(currentDisplayVehicle) and not NetworkHasControlOfEntity(currentDisplayVehicle) and attempt < 100 do
            Wait(100)
            NetworkRequestControlOfEntity(currentDisplayVehicle)
            attempt = attempt + 1
        end

        if DoesEntityExist(currentDisplayVehicle) and NetworkHasControlOfEntity(currentDisplayVehicle) then
            ESX.Game.DeleteVehicle(currentDisplayVehicle)
        end
    end
end

-- Función para iniciar restricciones en la tienda
function StartShopRestriction()
    CreateThread(function()
        while IsInShopMenu do
            Wait(0)
            DisableControlAction(0, 75, true) -- Desactivar salir del vehículo
            DisableControlAction(27, 75, true) -- Desactivar salir del vehículo
        end
    end)
end

-- Función para abrir el menú de la tienda
function OpenShopMenu()
    print("Abriendo el menú de la tienda...")

    if #Vehicles == 0 then
        print('[^3ERROR^7] Vehicleshop has ^50^7 vehicles, please add some!')
        return
    end

    IsInShopMenu = true

    StartShopRestriction()
    ESX.UI.Menu.CloseAll()

    local playerPed = PlayerPedId()
    FreezeEntityPosition(playerPed, true)
    SetEntityVisible(playerPed, false)
    SetEntityCoords(playerPed, Config.Zones.ShopInside.Pos)

    local elements = {}
    local firstVehicleData = nil

    for i = 1, #Categories, 1 do
        local category = Categories[i]
        local categoryVehicles = vehiclesByCategory[category.name]
        local options = {}
        if categoryVehicles == nil then
            print("Categoría sin vehículos: " .. category.name)
            goto continue
        end

        for j = 1, #categoryVehicles, 1 do
            local vehicle = categoryVehicles[j]

            if i == 1 and j == 1 then
                firstVehicleData = vehicle
            end

            local priceDisplay = TranslateCap('generic_shopitem_ultra', ESX.Math.GroupDigits(vehicle.price))
            table.insert(options, ('%s <span style="color:green;">%s</span>'):format(vehicle.name, priceDisplay))
        end

        table.sort(options)

        table.insert(elements, {
            name = category.name,
            label = category.label,
            value = 0,
            type = 'slider',
            max = #Categories[i],
            options = options
        })
        ::continue::
    end

    if not firstVehicleData then
        print("[^3ERROR^7] No se encontraron datos del primer vehículo.")
        return
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_shop', {
        title = TranslateCap('car_dealer'),
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        local vehicleData = vehiclesByCategory[data.current.name][data.current.value + 1]
        if not vehicleData then
            print("[^3ERROR^7] No se encontraron datos del vehículo seleccionado.")
            return
        end
        print("Seleccionado: " .. vehicleData.name)

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop_confirm', {
            title = TranslateCap('buy_vehicle_shop_ultra', vehicleData.name, ESX.Math.GroupDigits(vehicleData.price)),
            align = 'top-left',
            elements = {
                { label = TranslateCap('no'), value = 'no' },
                { label = TranslateCap('yes'), value = 'yes' }
            }}, function(data2, menu2)
                if data2.current.value == 'yes' then
                    local generatedPlate = GeneratePlate()

                    ESX.TriggerServerCallback('esx_vehicleshopvip:buyVehicle', function(success)
                        if success then
                            IsInShopMenu = false
                            menu2.close()
                            menu.close()
                            DeleteDisplayVehicleInsideShop()
                            FreezeEntityPosition(playerPed, false)
                            SetEntityVisible(playerPed, true)
                        else
                            ESX.ShowNotification(TranslateCap('not_enough_ultra_coins'))
                        end
                    end, vehicleData.model, generatedPlate)
                else
                    menu2.close()
                end
            end, function(data2, menu2)
                menu2.close()
            end)
    end, function(data, menu)
        menu.close()
        DeleteDisplayVehicleInsideShop()
        local playerPed = PlayerPedId()

        CurrentAction = 'shop_menu'
        CurrentActionMsg = TranslateCap('shop_menu')
        CurrentActionData = {}

        FreezeEntityPosition(playerPed, false)
        SetEntityVisible(playerPed, true)
        SetEntityCoords(playerPed, Config.Zones.ShopEntering.Pos)
        IsInShopMenu = false
    end, function(data, menu)
        local vehicleData = vehiclesByCategory[data.current.name][data.current.value + 1]
        if not vehicleData then
            print("[^3ERROR^7] No se encontraron datos del vehículo durante la vista previa.")
            return
        end
        local playerPed = PlayerPedId()

        WaitForVehicleToLoad(vehicleData.model)

        ESX.Game.SpawnLocalVehicle(vehicleData.model, Config.Zones.ShopInside.Pos, Config.Zones.ShopInside.Heading, function(vehicle)
            DeleteDisplayVehicleInsideShop()
            currentDisplayVehicle = vehicle
            TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
            FreezeEntityPosition(vehicle, true)
            SetModelAsNoLongerNeeded(vehicleData.model)
        end)
    end)
    WaitForVehicleToLoad(firstVehicleData.model)

    ESX.Game.SpawnLocalVehicle(firstVehicleData.model, Config.Zones.ShopInside.Pos, Config.Zones.ShopInside.Heading, function(vehicle)
        DeleteDisplayVehicleInsideShop()
        currentDisplayVehicle = vehicle
        TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
        FreezeEntityPosition(vehicle, true)
        SetModelAsNoLongerNeeded(firstVehicleData.model)
    end)
end

-- Función para esperar a que el modelo de vehículo cargue
function WaitForVehicleToLoad(modelHash)
    modelHash = (type(modelHash) == 'number' and modelHash or joaat(modelHash))

    if not HasModelLoaded(modelHash) then
        RequestModel(modelHash)

        BeginTextCommandBusyspinnerOn('STRING')
        AddTextComponentSubstringPlayerName(TranslateCap('shop_awaiting_model'))
        EndTextCommandBusyspinnerOn(4)

        while not HasModelLoaded(modelHash) do
            Wait(0)
            DisableAllControlActions(0)
        end

        BusyspinnerOff()
    end
end

-- Función cuando se entra en el marcador
function hasEnteredMarker(zone)
    if zone == 'ShopEntering' then
        CurrentAction = 'shop_menu'
        CurrentActionMsg = TranslateCap('shop_menu')
        CurrentActionData = {}
    end
end

-- Función cuando se sale del marcador
function hasExitedMarker(zone)
    if not IsInShopMenu then
        ESX.UI.Menu.CloseAll()
    end
    ESX.HideUI()
    CurrentAction = nil
end

-- Evento cuando el recurso se detiene
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if IsInShopMenu then
            ESX.UI.Menu.CloseAll()
            local playerPed = PlayerPedId()
            FreezeEntityPosition(playerPed, false)
            SetEntityVisible(playerPed, true)
            SetEntityCoords(playerPed, Config.Zones.ShopEntering.Pos)
        end
        DeleteDisplayVehicleInsideShop()
    end
end)

-- Crear marcadores si está habilitado en la configuración
if Config.Blip.show then
    CreateThread(function()
        local blip = AddBlipForCoord(Config.Zones.ShopEntering.Pos)
        SetBlipSprite(blip, Config.Blip.Sprite)
        SetBlipDisplay(blip, Config.Blip.Display)
        SetBlipScale(blip, Config.Blip.Scale)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(TranslateCap('car_dealer'))
        EndTextCommandSetBlipName(blip)
    end)
end

    
    -- Eventos de entrada/salida de marcador y dibujar marcadores
    CreateThread(function()
        while true do
            Wait(0)
            local playerCoords = GetEntityCoords(PlayerPedId())
            local isInMarker, letSleep, currentZone = false, true
    
            for k, v in pairs(Config.Zones) do
                local distance = #(playerCoords - v.Pos)
    
                if distance < Config.DrawDistance then
                    letSleep = false
    
                    if v.Type ~= -1 then
                        DrawMarker(v.Type, v.Pos, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, nil, nil, false)
                    end
    
                    if distance < v.Size.x then
                        isInMarker, currentZone = true, k
                    end
                end
            end
    
            if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
                HasAlreadyEnteredMarker, LastZone = true, currentZone
                LastZone = currentZone
                hasEnteredMarker(currentZone)
            end
    
            if not isInMarker and HasAlreadyEnteredMarker then
                HasAlreadyEnteredMarker = false
                hasExitedMarker(LastZone)
            end
    
            if letSleep then
                Wait(500)
            end
        end
    end)
    
    -- Controles de teclas
    CreateThread(function()
        while true do
            Wait(0)
    
            if CurrentAction then
                ESX.TextUI(CurrentActionMsg)
    
                if IsControlJustReleased(0, 38) then
                    if CurrentAction == 'shop_menu' then
                        if Config.LicenseEnable then
                            ESX.TriggerServerCallback('esx_license:checkLicense', function(hasDriversLicense)
                                if hasDriversLicense then
                                    OpenShopMenu()
                                else
                                    ESX.ShowNotification(TranslateCap('license_missing'))
                                end
                            end, GetPlayerServerId(PlayerId()), 'drive')
                        else
                            OpenShopMenu()
                        end
                    end
                    ESX.HideUI()
                    CurrentAction = nil
                end
            else
                Wait(500)
            end
        end
    end)
    
    -- Cargar paredes y suelo
    CreateThread(function()
        RequestIpl('shr_int')
    
        local interiorID = 7170
        PinInteriorInMemory(interiorID)
        ActivateInteriorEntitySet(interiorID, 'csr_beforeMission') -- Cargar ventana grande
        RefreshInterior(interiorID)
    end)
    
    -- Desactivar disparos dentro del vehículo
    function DisableWeaponFire()
        CreateThread(function()
            while true do
                Wait(0)
                local playerPed = PlayerPedId()
                if IsPedInAnyVehicle(playerPed, false) then
                    DisableControlAction(0, 24, true) -- Attack
                    DisableControlAction(0, 69, true) -- Vehicle Attack
                    DisableControlAction(0, 70, true) -- Vehicle Attack 2
                    DisableControlAction(0, 92, true) -- Vehicle Passenger Attack
                    DisableControlAction(0, 114, true) -- Vehicle Attack Alternative
                    DisableControlAction(0, 121, true) -- Vehicle Attack Helicopter
                    DisableControlAction(0, 140, true) -- Melee Attack Light
                    DisableControlAction(0, 141, true) -- Melee Attack Heavy
                    DisableControlAction(0, 142, true) -- Melee Attack Alternative
                    DisableControlAction(0, 257, true) -- Melee Attack 2
                    DisableControlAction(0, 263, true) -- Melee Attack 3
                    DisableControlAction(0, 264, true) -- Melee Attack 4
                end
            end
        end)
    end
    
    -- Llamar a la función para desactivar disparos
    DisableWeaponFire()
    