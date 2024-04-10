ESX                    = exports["es_extended"]:getSharedObject()
local playerLoaded     = false
local table_msg        = {}
local status_giocatori = {}

Citizen.CreateThread(function()
    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(100)
    end
    playerLoaded = true
end)


external_draw = function(x, y, z, text)
    local _, x1, y1 = World3dToScreen2d(x, y, z)
    SetTextScale(0.55, 0.31)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextEntry("STRING")
    SetTextCentre(true)
    SetTextDropshadow(10, 100, 100, 100, 255)
    SetTextColour(255, 255, 255, 215)
    AddTextComponentString(text)

    DrawText(x1, y1)
    local factor = (string.len(text)) / 320
    if not external.bgscuro then
        DrawRect(x1, y1 + 0.0135, 0.025 + factor, 0.03, 0, 0, 0, 68)
    end
end

external_draw3d = function(x, y, z, text)
    local _, _x, _y = World3dToScreen2d(x, y, z)
    SetTextScale(0.55, 0.31)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextEntry("STRING")
    SetTextCentre(true)
    SetTextDropshadow(10, 100, 100, 100, 255)
    SetTextColour(255, 255, 255, 215)
    AddTextComponentString(text)

    DrawText(_x, _y)
    local factor = (string.len(text)) / 320
    if external.bgscuro then
        DrawRect(_x, _y + 0.0135, 0.025 + factor, 0.03, 0, 0, 0, 68)
    end
end



RegisterNetEvent('external:settadio')
AddEventHandler('external:settadio', function(message, coords)
    table_msg[coords] = message
end)

RegisterNetEvent('external:rimuovimsg')
AddEventHandler('external:rimuovimsg', function(coords)
    table_msg[coords] = nil
end)



RegisterNetEvent('external:settamsg')
AddEventHandler('external:settamsg', function(heres, statuses)
    status_giocatori = statuses
    table_msg = heres
end)

RegisterNetEvent('external:settastatus')
AddEventHandler('external:settastatus', function(playerId, message)
    status_giocatori[playerId] = message
end)

RegisterNetEvent('external:rimuovistatus')
AddEventHandler('external:rimuovistatus', function(playerId)
    status_giocatori[playerId] = nil
end)

RegisterNetEvent('external:notify')
AddEventHandler('external:notify', function(title, desc)
    lib.notify({
        title = title,
        description = desc,
        position = "top",
        icon = "comments",
        iconColor = "white",
        iconAnimation = "bounce",
        style = {
            borderRadius = 5,
            backgroundColor = '#001F3F',
            color = 'white',
            textAlign = 'center',
            padding = '10px',
            width = '200px',
            margin = '20px auto',
            --border = '2px solid #00BFFF',
            boxShadow = '0 0 50px #00BFFF',
        },
    })
end)

Citizen.CreateThread(function()
    local id_server = GetPlayerServerId(PlayerId())
    while true do
        Wait(0)
        local pausa = true
        local plocal_coords = GetEntityCoords(PlayerPedId())
        if status_giocatori[id_server] then
            external_draw3d(plocal_coords.x, plocal_coords.y, plocal_coords.z, status_giocatori[id_server])
            pausa = false
        end
        for k, v in pairs(status_giocatori) do
            local player = GetPlayerFromServerId(k)
            if player ~= -1 and player ~= id_server then
                local targetCoords = GetEntityCoords(GetPlayerPed(player))
                local dist = #(targetCoords - plocal_coords)
                if dist < 8.0 then
                    external_draw3d(targetCoords.x, targetCoords.y, targetCoords.z, v)
                    pausa = false
                end
            end
        end
        if pausa then
            Wait(500)
        end
    end
end)

Citizen.CreateThread(function()
    TriggerServerEvent('external:rqmsg')
    while true do
        Wait(0)
        local pausa = true
        local plocal_coords = GetEntityCoords(PlayerPedId())
        for k, v in pairs(table_msg) do
            local dist = #(v.coords - plocal_coords)
            if dist < 5.5 then
                pausa = false
                external_draw(v.coords.x, v.coords.y, v.coords.z, v.message)
            end
        end
        if pausa then Wait(135) end
    end
end)
