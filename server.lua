local QBCore = exports['qb-core']:GetCoreObject()
local text = {}

local updateDrawText = function()
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
                isActive = false
            }
            text[#text+1] = params
        end
    end
end

CreateThread(function()
    Wait(100)
    updateDrawText()
end)

QBCore.Functions.CreateCallback('nui_drawtext:server:getText', function(source, cb)
    cb(text)
end)

RegisterNetEvent('nui_drawtext:server:getAllDrawText', function()
    local src = source
    local tablelength = 0
    local result = exports.oxmysql:executeSync('SELECT * FROM draw_text', {})
    local drawtext =  TriggerClientEvent("nui_drawtext:client:getClosestDrawText", src, result)

end)

RegisterNetEvent('nui_drawtext:server:deleteDrawText', function(closestDrawText)
    exports.oxmysql:execute('DELETE FROM draw_text WHERE id = ?', {closestDrawText})
    Wait(100)
    text = {}
    updateDrawText()
    TriggerClientEvent("nui_drawtext:client:overwriteText", -1, text)
end)

RegisterNetEvent('nui_drawtext:server:drawText', function(content, font, xyz, rgb, scaleMultiplier, radius)
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
    local params = {
        xyz= xyz,
        text={
            content = content,
            rgb = rgb,
            scaleMultiplier = scaleMultiplier,
            font = tonumber(font),
        },
        perspectiveScale = 4,
        radius = tonumber(radius),
        isActive = false
    }
    Wait(50)
    text[#text+1] = params
    TriggerClientEvent("nui_drawtext:client:addText", -1, params)
end)