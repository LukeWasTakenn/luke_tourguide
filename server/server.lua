ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterNetEvent('luke_tourguide:Paycheck')
AddEventHandler('luke_tourguide:Paycheck', function(numberOfStops)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local totalAmount = numberOfStops * Config.MoneyPerStop

    if xPlayer.job.name == 'tourguide' then
        if Config.PaymentInBank == false then
            xPlayer.addAccountMoney('bank', totalAmount)
            TriggerClientEvent('esx:showAdvancedNotification', src, 'Vinewood Tours', '', 'You completed the touring route, you recieved $~g~'..totalAmount, 'CHAR_MULTIPLAYER', 9)
        else
            xPlayer.addMoney(totalAmount)
            TriggerClientEvent('esx:showAdvancedNotification', src, 'Vinewood Tours', '', 'You completed the touring route, you recieved $~g~'..totalAmount, 'CHAR_MULTIPLAYER', 9)
        end
    end
end)
