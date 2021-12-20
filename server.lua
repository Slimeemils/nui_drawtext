local function sendDrawText(params)
    for _, playerId in ipairs(GetPlayers()) do
        TriggerClientEvent('nui_drawtext:client:drawText', playerId, params)
      end 
end


RegisterNetEvent('nui_drawtext:server:drawText', function(params)
    sendDrawText(params)
end)