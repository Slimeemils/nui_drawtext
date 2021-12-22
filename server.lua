local QBCore = exports['qb-core']:GetCoreObject()
RegisterNetEvent('nui_drawtext:server:sendDrawText', function()
    local result = exports.oxmysql:executeSync('SELECT * FROM draw_text', {})
    if result[1] then
        for k, v in pairs(result) do
            params={
                xyz=json.decode(v.xyz),
                text={
                    content = v.content,
                    rgb = v.color,
                    scaleMultiplier = v.scale_multiplier,
                    font = tonumber(v.font),
                },
                perspectiveScale = 4,
                radius = tonumber(v.radius),
            }
            TriggerClientEvent('nui_drawtext:client:drawText', -1, params, source)
        end
    end
end)


RegisterNetEvent('nui_drawtext:server:drawText', function(content, font, xyz,rgb, scaleMultiplier, radius)
    local ped = QBCore.Functions.GetPlayer(source)
    exports.oxmysql:insert('INSERT INTO draw_text (content, font, color, creator, radius, xyz, scale_multiplier ) VALUES (?,?, ?, ?, ?, ?, ?)', {
        content,
        font,
        rgb,
        ped.PlayerData.citizenid,
        radius,
        json.encode(xyz),
        scaleMultiplier
     })
     Wait(50)
    TriggerEvent("nui_drawtext:server:sendDrawText")
end)
