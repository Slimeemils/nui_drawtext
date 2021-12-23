local QBCore = exports['qb-core']:GetCoreObject()
local showMenu = false
local drawText = false
local activeLaser = false
local deleteLaser = false
local isUpdating = false
local text = {}

RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
    Wait(100)
    QBCore.Functions.TriggerCallback('nui_drawtext:server:getText', function(data)
        text = data
    end)
end)

AddEventHandler('onResourceStart', function()
    Wait(2000)
    QBCore.Functions.TriggerCallback('nui_drawtext:server:getText', function(data)
        text = data
    end)
end)

RegisterNUICallback('closeMenu', function()
    Wait(50)
    showMenu = false
    SetNuiFocus(false, false)
end) 

RegisterKeyMapping('activeLaser', 'Open Menu', 'keyboard', Config.OpenKeyActiveLaser)
RegisterKeyMapping('deleteLaser', 'Delete Text', 'keyboard', Config.OpenKeyDeleteLaser)

local function RotationToDirection(rotation)
	local adjustedRotation =
	{
		x = (math.pi / 180) * rotation.x,
		y = (math.pi / 180) * rotation.y,
		z = (math.pi / 180) * rotation.z
	}
	local direction =
	{
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		z = math.sin(adjustedRotation.x)
	}
	return direction
end

local function RayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
	local cameraCoord = GetGameplayCamCoord()
	local direction = RotationToDirection(cameraRotation)
	local destination =
	{
		x = cameraCoord.x + direction.x * distance,
		y = cameraCoord.y + direction.y * distance,
		z = cameraCoord.z + direction.z * distance
	}
	local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
	return c, e
end

local function rgbToHex(hex)
    hex = hex:gsub("#","")
    return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
end

local function Draw2DText(content, font, colour, scale, x, y)
    SetTextFont(font)
    SetTextScale(scale, scale)
    SetTextColour(colour[1],colour[2],colour[3], 255)
    SetTextEntry("STRING")
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextDropShadow()
    SetTextEdge(4, 0, 0, 0, 255)
    SetTextOutline()
    AddTextComponentString(content)
    DrawText(x, y)
end

RegisterCommand('activeLaser', function()
    Wait(50)
    activeLaser = not activeLaser
    TriggerEvent('nui_drawtext:client:laserAdd')
end)

RegisterNetEvent('nui_drawtext:client:laserAdd', function()
    while true do 
        Wait(1000)
        while activeLaser do
            Wait(0)
            local color = {r = 2, g = 241, b = 181, a = 200}
            local position = GetEntityCoords(PlayerPedId())
            local coords, entity = RayCastGamePlayCamera(1000.0)
            Draw2DText('PRESS ~g~E~w~ TO OPEN DRAWTEXT MENU', 4, {255, 255, 255}, 0.4, 0.43, 0.888 + 0.025)
            if IsControlJustReleased(0, 38) then
                SetNuiFocus(true, true)
                SendNUIMessage({ action = "open"}) 
                showMenu = true
                activeLaser = false
            end
            DrawLine(position.x, position.y, position.z, coords.x, coords.y, coords.z, color.r, color.g, color.b, color.a)
            DrawMarker(28, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.1, 0.1, 0.1, color.r, color.g, color.b, color.a, false, true, 2, nil, nil, false)      
        end
    end
end)

RegisterNUICallback('deleteLaser', function()
    Wait(50)
    deleteLaser = not deleteLaser
    showMenu = false
    SetNuiFocus(false, false)
    TriggerEvent('nui_drawtext:client:deletelaser')
end) 

RegisterCommand('deleteLaser', function()
    Wait(50)
    deleteLaser = not deleteLaser
    TriggerEvent('nui_drawtext:client:deletelaser')
end)

RegisterNetEvent('nui_drawtext:client:deletelaser', function()
    while true do 
        Wait(1000)
        while deleteLaser do
            Wait(0)
            local color = {r = 255, g = 0, b = 0, a = 200}
            local position = GetEntityCoords(PlayerPedId())
            local coords, entity = RayCastGamePlayCamera(1000.0)
            Draw2DText('PRESS ~r~E~w~ WHEN POINTING AT DRAWTEXT TO REMOVE', 4, {255, 255, 255}, 0.4, 0.40, 0.888 + 0.025)
            if IsControlJustReleased(0, 38) then
                TriggerServerEvent('nui_drawtext:server:getAllDrawText')
                deleteLaser = false
            end
            DrawLine(position.x, position.y, position.z, coords.x, coords.y, coords.z, color.r, color.g, color.b, color.a)
            DrawMarker(28, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.1, 0.1, 0.1, color.r, color.g, color.b, color.a, false, true, 2, nil, nil, false)      
        end
    end
end)

RegisterNUICallback('createDrawText', function(data, cb)
    local coords, entity = RayCastGamePlayCamera(1000.0)
    arg = data
    if arg.font == 4 then
        arg.font = 7
    elseif arg.font == 3 then
        arg.font = 4
    elseif arg.font == 2 then
        arg.font = 1
    elseif arg.font == 1 then
        arg.font = 0
    end
   
    TriggerServerEvent('nui_drawtext:server:drawText', arg.content, arg.font, coords,arg.color,  arg.size, arg.radius)
    activeLaser = false
    cb('ok')
end)

RegisterNetEvent('nui_drawtext:client:getClosestDrawText', function(result)
    local position = RayCastGamePlayCamera(1000.0)
    local closestDrawText = nil
    local shortestDistance = 100000000
    if result[1] then
        for k, v in pairs(result) do
            local coords = json.decode(v.xyz)
            local distance =  #(position - vector3(coords.x, coords.y, coords.z))
            if distance < shortestDistance then
                closestDrawText = v.id
                shortestDistance = distance
            end
        end
    end
    TriggerServerEvent('nui_drawtext:server:deleteDrawText', closestDrawText)
end)

RegisterNetEvent('nui_drawtext:client:addText', function(params)
    text[#text+1] = params
end)

RegisterNetEvent('nui_drawtext:client:overwriteText', function(drawText)
    isUpdating = true
    Wait(50)
    text = drawText
    isUpdating = false
end)

local function Draw3DText(id)
    CreateThread(function()
        while (text[id].isActive) do 
            Wait(0) 
            if isUpdating then break end
            if Vdist2(GetEntityCoords(PlayerPedId(), false), text[id].xyz.x,text[id].xyz.y,text[id].xyz.z) < (text[id].radius) then
                local onScreen, _x, _y = World3dToScreen2d(text[id].xyz.x,text[id].xyz.y,text[id].xyz.z)
                local p = GetGameplayCamCoords()
                local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, text[id].xyz.x,text[id].xyz.y,text[id].xyz.z, 1)
                local fov = (1 / GetGameplayCamFov()) * 75
                local scale = (1 / distance) * (text[id].perspectiveScale) * fov * (text[id].text.scaleMultiplier)
                local r,g,b=rgbToHex(text[id].text.rgb)
                if onScreen then
                    SetTextScale(0.0, scale)
                    SetTextFont(text[id].text.font)
                    SetTextProportional(true)
                    SetTextColour(r, g, b, 255)
                    SetTextOutline()
                    SetTextEntry("STRING")
                    SetTextCentre(true)
                    AddTextComponentString(text[id].text.content)
                    DrawText(_x,_y)
                end
            else   
                text[id].isActive = false
            end
        end
    end)
end

CreateThread(function()
    while true do
        for k=1, #text do
            local position = GetEntityCoords(PlayerPedId())
            local closestDrawText = nil
            local distance =  #(position - vector3(text[k].xyz.x, text[k].xyz.y, text[k].xyz.z))
            if distance < text[k].radius then
                if not text[k].isActive then
                    text[k].isActive = true
                    Draw3DText(k)
                end
            end
        end
        Wait(1000)
    end
end)
