local table_msg        = {}
local ESX              = exports["es_extended"]:getSharedObject()
local status_giocatore = {}

RegisterNetEvent('external:rqmsg')
AddEventHandler('external:rqmsg', function()
    TriggerClientEvent('external:settamsg', source, table_msg, status_giocatore)
end)


RegisterNetEvent('external:sync')
AddEventHandler('external:sync', function(message, coords)
    table_msg[coords] = message
    TriggerClientEvent('external:settadio', -1, message, coords)
end)

RegisterNetEvent('external:togli')
AddEventHandler('external:togli', function(coords)
    table_msg[coords] = nil
    TriggerClientEvent('external:rimuovimsg', -1, coords)
end)



AddEventHandler('playerDropped', function(reason)
    for k, v in pairs(table_msg) do
        if v.owner == source then
            table_msg[k] = nil
            TriggerClientEvent('external:rimuovimsg', -1, k)
        end
    end
    if status_giocatore[source] then
        TriggerClientEvent('external:rimuovistatus', -1, source)
    end
end)

RegisterCommand(external.commando, function(source, args, rawCommand)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if xPlayer then
        if status_giocatore[_source] then
            status_giocatore[_source] = nil
            TriggerClientEvent('external:rimuovistatus', -1, _source)

            TriggerClientEvent('external:notify', -1, 'Successo', "Hai rimosso il tuo status!")
        else
            local message = table.concat(args, ' ', 1)
            status_giocatore[_source] = message
            TriggerClientEvent('external:settastatus', -1, _source, message)

            TriggerClientEvent('external:notify', -1, 'Successo', "Il tuo nuovo status: " .. message)
        end
    end
end, false)
