---------Variable defaulting-----------
local JobIsTourGuide = false
local InService = false
local InRange = false
local PedIsCloseToLocker = false
local PedIsCloseToRouteMenu = false
local PedIsCloseToReturnVehicle = false
local PedIsCloseToObjective = false
local PedIsCloseToPassangers = false
local WorkVehicle = false
local JobVehicle = ''
local BlipExists = false
local FunctionHasRan = false
local RouteOver = false
local routeStarted = false
local pickedUp = false
local droppedOff = false
local currentBlip = 1
local PlayerData = {}
---------------------------------------

local style = { --Styles for WarMenu, ignore if you're not using it
    x = 0.750,
    y = 0.025,
    titleBackgroundColor = {6, 69, 115},
    subTitleColor = { 255, 255, 255},
    titleColor = {255, 255, 255},
}

--Initializing WarMenu menus
WarMenu.CreateMenu('locker', 'Locker Menu', 'Vinewood Tours', style)
WarMenu.CreateMenu('routeSelect', 'Route Select', 'Vinewood Tours', style)
WarMenu.CreateMenu('jobComplete', 'Job Complete', 'Vinewood Tours', style)
WarMenu.CreateSubMenu('completeRouteSelect', 'jobComplete', 'Viewewood Tours', style)

--General ESX initialization stuff
ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        Citizen.Wait(0)
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(PlayerData)
    PlayerData = xPlayer
end)

--Grabbing job on job change, if job is tourguide
RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    if job ~= nil then
        if PlayerData == nil then
            PlayerData = ESX.GetPlayerData()
        end
    end

    PlayerData.job = job

    if PlayerData.job.name == 'tourguide' then
        JobIsTourGuide = true
        Locker()
    else
        JobIsTourGuide = false
        RemoveBlip(LockerBlip)
        RemoveBlip(RouteMenuBlip)
        RemoveBlip(DeleteVehicleBlip)
        RemoveBlip(RouteBlip)
        RemoveBlip(passangerDropOffBlip)
        RemoveBlip(passangerPickupBlip)
        PedIsCloseToLocker = false
    end
end)

--Same as above but works on new instance
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if ESX ~= nil then
            PlayerData = ESX.GetPlayerData()
            if PlayerData.job ~= nil and PlayerData.job.name == 'tourguide' then
                JobIsTourGuide = true
                Locker()
                break
            else
                PedIsCloseToLocker = false
                JobIsTourGuide = false
            end
        end
    end
end)

--Thread for handling distances
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        playerPed = PlayerPedId()
        if JobIsTourGuide == true then
            PlayerCoords = GetEntityCoords(playerPed)
            if GetDistanceBetweenCoords(PlayerCoords.x, PlayerCoords.y, PlayerCoords.z, Config.LockerBlip.x, Config.LockerBlip.y, Config.LockerBlip.z, true) < Config.MarkerDrawDistance then
                PedIsCloseToLocker = true
                if GetDistanceBetweenCoords(PlayerCoords.x, PlayerCoords.y, PlayerCoords.z, Config.LockerBlip.x, Config.LockerBlip.y, Config.LockerBlip.z, true) < 1.5 then
                    InRange = true
                else
                    InRange = false
                end
            else
                PedIsCloseToLocker = false
            end
            if InService == true and GetDistanceBetweenCoords(PlayerCoords.x, PlayerCoords.y, PlayerCoords.z, Config.RouteSelectBlip.x, Config.RouteSelectBlip.y, Config.RouteSelectBlip.z, true) < Config.MarkerDrawDistance then
                PedIsCloseToRouteMenu = true
                if GetDistanceBetweenCoords(PlayerCoords.x, PlayerCoords.y, PlayerCoords.z, Config.RouteSelectBlip.x, Config.RouteSelectBlip.y, Config.RouteSelectBlip.z, true) < 1.5 then
                    InRange = true
                else
                    InRange = false
                end
            else
                PedIsCloseToRouteMenu = false
            end
            if WorkVehicle == true and JobVehicle ~= '' and GetDistanceBetweenCoords(PlayerCoords.x, PlayerCoords.y, PlayerCoords.z, Config.VehicleDeleteBlip.x, Config.VehicleDeleteBlip.y, Config.VehicleDeleteBlip.z, true) < 10.0 then
                PedIsCloseToReturnVehicle = true
                if GetDistanceBetweenCoords(PlayerCoords.x, PlayerCoords.y, PlayerCoords.z, Config.VehicleDeleteBlip.x, Config.VehicleDeleteBlip.y, Config.VehicleDeleteBlip.z, true) < 2.0 then
                    InRange = true
                else
                    InRange = false
                end
            else
                PedIsCloseToReturnVehicle = false
            end
            if DoesBlipExist(RouteBlip) == 1 then
                if GetDistanceBetweenCoords(PlayerCoords.x, PlayerCoords.y, PlayerCoords.z, blipPos.x, blipPos.y, blipPos.z, true) < 10.0 then
                    PedIsCloseToObjective = true
                    if GetDistanceBetweenCoords(PlayerCoords.x, PlayerCoords.y, PlayerCoords.z, blipPos.x, blipPos.y, blipPos.z, true) < 2.0 then
                        InRange = true
                    else
                        InRange = false
                    end
                else
                    PedIsCloseToObjective = false
                end
            end
            if GetDistanceBetweenCoords(PlayerCoords.x, PlayerCoords.y, PlayerCoords.z, Config.PassangerPickUpLocation.x, Config.PassangerPickUpLocation.y, Config.PassangerPickUpLocation.z, true) < 10.0 then
                if DoesBlipExist(passangerPickupBlip) == 1 or DoesBlipExist(passangerDropOffBlip) == 1 then
                    PedIsCloseToPassangers = true
                    if GetDistanceBetweenCoords(PlayerCoords.x, PlayerCoords.y, PlayerCoords.z, Config.PassangerPickUpLocation.x, Config.PassangerPickUpLocation.y, Config.PassangerPickUpLocation.z, true) < 2.0 then
                        InRange = true
                    else
                        InRange = false
                    end
                end
            else
                PedIsCloseToPassangers = false
            end
        end
    end
end)

--Marker and Text drawing (it's not pretty)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        isPedInVehicle = IsPedInAnyVehicle(playerPed, false)
        if PedIsCloseToLocker == true and not isPedInVehicle then
            Draw3DText(Config.LockerBlip.x, Config.LockerBlip.y, Config.LockerBlip.z+1, "Press [~b~E~w~] To Open The Locker Menu")
            DrawMarker(27, Config.LockerBlip.x, Config.LockerBlip.y, Config.LockerBlip.z, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 6, 69, 115, 255, false, false, 0, 0)
            if IsControlJustReleased(0, 51) and InRange == true then
                TriggerEvent('luke_tourguide:OpenLockerMenu')
            end
        elseif PedIsCloseToRouteMenu == true and WorkVehicle == false then
            Draw3DText(Config.RouteSelectBlip.x, Config.RouteSelectBlip.y, Config.RouteSelectBlip.z+1, "Press [~b~E~w~] To Open The Route Select Menu")
            DrawMarker(27, Config.RouteSelectBlip.x, Config.RouteSelectBlip.y, Config.RouteSelectBlip.z, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 6, 69, 115, 255, false, false, 0, 0)
            if IsControlJustReleased(0, 51) and InRange == true then
                TriggerEvent('luke_tourguide:OpenRouteMenu')
            end
        elseif PedIsCloseToReturnVehicle == true and isPedInVehicle then
            DrawMarker(1, Config.VehicleDeleteBlip.x, Config.VehicleDeleteBlip.y, Config.VehicleDeleteBlip.z, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 6, 69, 115, 255, false, false, 0, 0)
            if InRange == true then
                ESX.ShowHelpNotification('Press ~INPUT_CONTEXT~ to ~b~Return ~w~The Vehicle')
            end
            if IsControlJustReleased(0, 51) and InRange == true and PedIsCloseToReturnVehicle == true then
                if GetVehiclePedIsIn(GetPlayerPed(-1), false) == JobVehicle then
                    DeleteVehicle()
                else
                    ESX.ShowNotification('This is not the work vehicle')
                end
            end
        elseif DoesBlipExist(RouteBlip) == 1 and PedIsCloseToObjective == true and isPedInVehicle then
            DrawMarker(1, blipPos.x, blipPos.y, blipPos.z-1, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 6, 69, 115, 255, false, false, 0, 0) 
            if InRange == true then
                ESX.ShowHelpNotification('Press ~INPUT_CONTEXT~ to ~b~Admire ~w~the View!')
            end
        elseif PedIsCloseToPassangers == true and isPedInVehicle then
            if DoesBlipExist(passangerPickupBlip) == 1 or DoesBlipExist(passangerDropOffBlip) == 1 then
                DrawMarker(1, Config.PassangerPickUpLocation.x, Config.PassangerPickUpLocation.y, Config.PassangerPickUpLocation.z, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 6, 69, 115, 255, false, false, 0, 0)
                if InRange == true and DoesBlipExist(passangerPickupBlip) and PedIsCloseToPassangers == true then
                    ESX.ShowHelpNotification('Press ~INPUT_CONTEXT~ to ~b~Pick up ~w~The Tourists!')
                elseif InRange == true and DoesBlipExist(passangerDropOffBlip) then
                    ESX.ShowHelpNotification('Press ~INPUT_CONTEXT~ to ~b~Drop off ~w~The Tourists!')
                end
            end
        end
    end
end)

--Main gameplay thread
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if WorkVehicle == true then
            if pickedUp == false then
                PassangerPickup()
                if IsControlJustReleased(0, 51) and GetVehiclePedIsIn(PlayerPedId(), false) == JobVehicle and GetDistanceBetweenCoords(PlayerCoords.x, PlayerCoords.y, PlayerCoords.z, Config.PassangerPickUpLocation.x, Config.PassangerPickUpLocation.y, Config.PassangerPickUpLocation.z) < 2.0 then
                    Freeze(JobVehicle, Config.PickUpTimer*1000, 'Tourists are getting in...')
                    RemoveBlip(passangerPickupBlip)
                    LoadPeds(JobVehicle)
                    ESX.ShowHelpNotification('Follow the tour points on your GPS.')
                    pickedUp = true
                    droppedOff = false
                end
            else
                if FunctionHasRan == false then
                    Routing(1, selectedRoute)
                end
                if IsControlJustReleased(0, 51) and PedIsCloseToObjective == true and InRange == true and RouteOver == false and GetVehiclePedIsIn(PlayerPedId(), false) == JobVehicle then
                    currentBlip = currentBlip + 1
                    RemoveBlip(RouteBlip)
                    Routing(currentBlip, selectedRoute)
                    Freeze(JobVehicle, Config.ViewTimer*1000, 'Admiring the View')
                end
            end
        end
        if RouteOver == true and pickedUp == true and droppedOff == false then
            PassangerDropOff()
            if IsControlJustReleased(0, 51) and GetVehiclePedIsIn(PlayerPedId(), false) == JobVehicle and GetDistanceBetweenCoords(PlayerCoords.x, PlayerCoords.y, PlayerCoords.z, Config.PassangerPickUpLocation.x, Config.PassangerPickUpLocation.y, Config.PassangerPickUpLocation.z) < 2.0 then
                Freeze(JobVehicle, Config.DropOffTimer*1000, 'Dropping off the Tourists')
                DropOff()
                RemoveBlip(passangerDropOffBlip)
                TriggerServerEvent('luke_tourguide:Paycheck', #selectedRoute)
                TriggerEvent('luke_tourguide:OpenJobCompleteMenu')
                droppedOff = true
                currentBlip = 1
            end
        end
    end
end)

--Warmenu events
RegisterNetEvent('luke_tourguide:OpenLockerMenu')
AddEventHandler('luke_tourguide:OpenLockerMenu', function()

    if WarMenu.IsAnyMenuOpened() then
        return 
    end

    WarMenu.OpenMenu('locker')

    while true do
        Citizen.Wait(0)
        if WarMenu.Begin('locker') then
            if WarMenu.Button('Start Touring') then
                RouteSelectBlip()
                InService = true
                ESX.ShowHelpNotification('Clocked in, get a vehicle and start a tour.')
                WarMenu.CloseMenu()
            elseif WarMenu.Button('Stop Touring') then
                RemoveBlip(RouteMenuBlip)
                RemoveBlip(DeleteVehicleBlip)
                InService = false
                WarMenu.CloseMenu()
            elseif WarMenu.Button('Close Menu') then
                WarMenu.CloseMenu()
            end
            WarMenu.End()
        else
            return
        end
    end
end)

--Handles the Route menu
RegisterNetEvent('luke_tourguide:OpenRouteMenu')
AddEventHandler('luke_tourguide:OpenRouteMenu', function()
    if WarMenu.IsAnyMenuOpened() then
        return
    end

    WarMenu.OpenMenu('routeSelect')

    while true do
        Citizen.Wait(0)
        if WarMenu.Begin('routeSelect') then
            for k, v in pairs(Config.Routes) do
                if WarMenu.Button(v.name) then
                    ESX.ShowHelpNotification('Go to the location and pick up the tourists.')
                    SpawnJobVehicle()
                    VehicleDeleteBlip()
                    selectedRoute = v.path
                    WarMenu.CloseMenu()
                end
            end
            WarMenu.End()
        else
            return
        end
    end
end)

RegisterNetEvent('luke_tourguide:OpenJobCompleteMenu')
AddEventHandler('luke_tourguide:OpenJobCompleteMenu', function()
    if WarMenu.IsAnyMenuOpened() then
        return
    end

    WarMenu.OpenMenu('jobComplete')

    while true do
        Citizen.Wait(0)
        if WarMenu.Begin('jobComplete') then
            WarMenu.MenuButton('Choose a New Route', 'completeRouteSelect')
            local pressedButton = WarMenu.Button('Go Back and Return the Vehicle')

            if pressedButton then
                SetBlipRoute(DeleteVehicleBlip, true)
                SetBlipAsShortRange(DeleteVehicleBlip, false)
                WarMenu.CloseMenu()
            end
            WarMenu.End()

        elseif WarMenu.Begin('completeRouteSelect') then
            for k,v in pairs(Config.Routes) do
                if WarMenu.Button(v.name) then
                    selectedRoute = v.path
                    pickedUp = false
                    RouteOver = false
                    FunctionHasRan = false
                    WarMenu.CloseMenu()
                end
            end
            WarMenu.End()
        else
            return
        end
    end
end)

function Freeze(vehicle, time, text)
    exports['pogressBar']:drawBar(time, text)
    FreezeEntityPosition(vehicle, true)
    Citizen.Wait(time)
    FreezeEntityPosition(vehicle, false)
end

function LoadRandomPedModel()
    pedModel = Config.PedModels[math.random(1, #Config.PedModels)]
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Citizen.Wait(0)
    end
    return pedModel
end

function LoadPeds(vehicle)
    spawnedNPCS = {}
    for i = 1, 8, 1 do
        LoadRandomPedModel()
        spawnedNPCS[i] = CreatePedInsideVehicle(vehicle, 0 , pedModel, i, Config.PedsVisibleToOtherPlayers, false)
        Citizen.Wait(50)
    end
end

function DropOff()
    for i = 1, #spawnedNPCS, 1 do
        DeleteEntity(spawnedNPCS[i])
        Citizen.Wait(50)
    end
end

function PassangerDropOff()
    if DoesBlipExist(passangerDropOffBlip) then
        return
    end

    ESX.ShowHelpNotification('Drop the tourists off at the location.')


    passangerDropOffBlip = AddBlipForCoord(Config.PassangerPickUpLocation.x, Config.PassangerPickUpLocation.y, Config.PassangerPickUpLocation.z)
    SetBlipSprite(passangerDropOffBlip, 280)
    SetBlipColour(passangerDropOffBlip, 3)
    SetBlipAsShortRange(passangerDropOffBlip, false)
    SetBlipRoute(passangerDropOffBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Tourist Drop off')
    EndTextCommandSetBlipName(passangerDropOffBlip)
end

--Function on start of a mission, first stop - passengers
function PassangerPickup()
    if DoesBlipExist(passangerPickupBlip) then
        return
    end

    passangerPickupBlip = AddBlipForCoord(Config.PassangerPickUpLocation.x, Config.PassangerPickUpLocation.y, Config.PassangerPickUpLocation.z)
    SetBlipSprite(passangerPickupBlip, 280)
    SetBlipColour(passangerPickupBlip, 3)
    SetBlipAsShortRange(passangerPickupBlip, false)
    SetBlipRoute(passangerPickupBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Tourist Pickup')
    EndTextCommandSetBlipName(passangerPickupBlip)

end

--Main function that handles the route
function Routing(index, route)
    if DoesBlipExist(RouteBlip) then
        return
    end

    if index > #route then
            RouteOver = true 
        return
    else
        blipPos = route[index]
        RouteBlip = AddBlipForCoord(blipPos.x, blipPos.y, blipPos.z)
        FunctionHasRan = true

        SetBlipColour(RouteBlip, 3)
        SetBlipAsShortRange(RouteBlip, false)
        SetBlipRoute(RouteBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString('Next Route Point')
        EndTextCommandSetBlipName(RouteBlip)
    end
end

--General function to spawn the work vehicle
function SpawnJobVehicle()
    ESX.Game.SpawnVehicle(Config.JobVehicle, vector3(Config.VehicleSpawnLocation.x, Config.VehicleSpawnLocation.y, Config.VehicleSpawnLocation.z), Config.VehicleSpawnHeading, function(vehicle)
        if Config.WarpPedIntoJobVehicleOnSpawn == true then
            TaskWarpPedIntoVehicle(GetPlayerPed(-1), vehicle, -1)
        end
        JobVehicle = vehicle
        WorkVehicle = true
    end)
end

--3D Text drawing - Fairly basic but works really well
function Draw3DText(x, y, z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)

    local scale = 0.4

    if onScreen then
        SetTextScale(scale, scale)
        SetTextFont(6)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end

function DeleteVehicle()
    exports['pogressBar']:drawBar(Config.VehicleDeleteTimer*1000, 'Putting the Vehicle Away')
    Citizen.Wait(Config.VehicleDeleteTimer*1000)
    DeleteEntity(GetVehiclePedIsIn(GetPlayerPed(-1), false))
    RemoveBlip(DeleteVehicleBlip)
    RemoveBlip(passangerPickupBlip)
    RemoveBlip(RouteBlip)
    RouteSelectBlip()
    pickedUp = false
    FunctionHasRan = false
    RouteOver =  false
    currentBlip = 1
    JobVehicle = ''
    WorkVehicle = false
end

--Self explanatory
function VehicleDeleteBlip()
    if DoesBlipExist(DeleteVehicleBlip) then
        return
    else
        RemoveBlip(RouteMenuBlip)
        DeleteVehicleBlip = AddBlipForCoord(Config.VehicleDeleteBlip.x, Config.VehicleDeleteBlip.y, Config.VehicleDeleteBlip.z)
            
        SetBlipSprite(DeleteVehicleBlip, 289)
        SetBlipScale(DeleteVehicleBlip, 0.9)
        SetBlipColour(DeleteVehicleBlip, 3)
        SetBlipDisplay(DeleteVehicleBlip, 2)
        SetBlipAsShortRange(DeleteVehicleBlip, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString('Return Work Vehicle')
        EndTextCommandSetBlipName(DeleteVehicleBlip)
    end
end

--Function for the route select blip
function RouteSelectBlip()
    if DoesBlipExist(RouteMenuBlip) then
        return
    else
        RouteMenuBlip = AddBlipForCoord(Config.RouteSelectBlip.x, Config.RouteSelectBlip.y, Config.RouteSelectBlip.z)

        SetBlipSprite(RouteMenuBlip, 67)
        SetBlipScale(RouteMenuBlip, 0.9)
        SetBlipColour(RouteMenuBlip, 3)
        SetBlipDisplay(RouteMenuBlip, 2)
        SetBlipAsShortRange(RouteMenuBlip, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString('Tour Route Select')
        EndTextCommandSetBlipName(RouteMenuBlip)
    end
end

--Function for the locker blip
function Locker()
    if DoesBlipExist(LockerBlip) then
        return
    else
        LockerBlip = AddBlipForCoord(Config.LockerBlip.x, Config.LockerBlip.y, Config.LockerBlip.z)

        SetBlipSprite(LockerBlip, 79)
        SetBlipScale(LockerBlip, 0.9)
        SetBlipColour(LockerBlip, 3)
        SetBlipDisplay(LockerBlip, 2)
        SetBlipAsShortRange(LockerBlip, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString('Tour Guide Locker')
        EndTextCommandSetBlipName(LockerBlip)
    end
end