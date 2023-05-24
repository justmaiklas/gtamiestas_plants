ESX = nil

Plants = {}
DryingSpots = {}
CurrentPlant = nil
CurrentPlantInfo = nil
CurrentTable = nil

local nearPlant = true
local shown = false
local interactive = false
local action = false
local processing = false
ScriptIsReady = false
font = nil
Citizen.CreateThread(
function()
    while ESX == nil do
        TriggerEvent("Gtamiestas_getSharedObject", function(obj) ESX = obj end)
        Citizen.Wait(500)
    end

    ESX.TriggerServerCallback("Plantz:GetPlantsInfo",function(plants)
        Plants = plants
        print(json.encode(Plants))
    end)
    font = exports["font"].GetFontId()
    

    ScriptIsReady = true
    -- ESX.TriggerServerCallback("plantz:getInfo",function(plants, dryingSpots, dealers)
    --     Plants = plants
    --     DryingSpots = dryingSpots
    --     Dealers = dealers
    --     ScriptIsReady = true
    -- end)
    -- ESX.TriggerServerCallback(
    -- "plantz:getInfo",
    --     function(plants, process)
    --         Plants = plants
    --         ProcessingTables = process

    --         for k, v in pairs(Plants) do

    --             spawnPlant(v.type, v.coords, v.growth, k)
    --         end

    --         for b, g in pairs(ProcessingTables) do
    --             spawnProcessingTable(g.type, g.coords, b, g.rot)
    --         end
    --     end
    -- )
end
)


RegisterNetEvent("plantz:sendMessage")
AddEventHandler(
"plantz:sendMessage",
    function(msg, type)
        SendTextMessage(msg, type)
    end
)

RegisterNetEvent("Plantz:UpdatePlants",function(plants)
    Plants = plants
end)

RegisterNetEvent("plantz:updateAll",function(plants,dryingSpots)
    Plants = plants
    DryingSpots = dryingSpots
end)

RegisterNetEvent("plantz:updatePlant",function(id, plantData)
    Plants[id] = Plants[id] or {}
    Plants[id] = plantData
end)

RegisterNetEvent("plantz:deletePlant",function(id)
    Plants[id] = nil
    PlantsToLoad[id] = nil
end)

RegisterNetEvent("plantz:UseItem", function(itemName, label, duration, animDic, animName, scenario)
    local plantId = GetNearestPlantId()
    local canUse= false
    if Plants[plantId] and Plants[plantId] then
        for k,v in pairs (Config.UsableItems[itemName]) do
            if Plants[plantId][v.increaseType] < 100 and Plants[plantId][v.increaseType] < v.max then
                canUse = true
                break
            end
        end
    else
        SendTextMessage(Config.Text["error"], 'error')
    end
    if not canUse then
        SendTextMessage(Config.Text["plant_already_at_max"], 'warning')
    elseif plantId and not action then
        if label and duration then
        StartAnimation(false,label,duration,true,animDic,animName,scenario,
            function()
                action = true
            end,
            function (cancelled)
                if not cancelled then
                    TriggerServerEvent("plantz:UseItem",plantId,itemName)
                end
                action = false
            end
        )        
        else
            TriggerServerEvent("plantz:UseItem",plantId,itemName)
        end
    else
        SendTextMessage(Config.Text["plant_not_found"], 'error')
    end
end)

RegisterNetEvent("plantz:updateDryingSpotId",function(id, spotData)
    DryingSpots[id] = spotData
end)

RegisterNetEvent("plantz:plant")
AddEventHandler(
"plantz:plant",
    function(type)
        plant(type)
    end
)

RegisterNetEvent("plantz:process")
AddEventHandler(
"plantz:process",
    function(type)
        process(type)
    end
)
MenuIsOpen = false
Citizen.CreateThread(function ()
	while true do
        local sleep = 3
        local playerCoords = GetEntityCoords(PlayerPedId())
        local plantId = GetNearestPlantId(playerCoords)
        local dryingSpotId = GetNearestDryingSpotId(playerCoords)
        if MenuIsOpen then sleep = 500; goto END end
        if plantId then
            local plant = Plants[plantId]
            if plant ~= nil then
                local upperText, lowerText, fullText = GeneratePlantInfoText(plant)
                local scale = GetScaleFor3DText(plant.coords)
                DrawText3D(plant.coords,upperText,scale)
                DrawText3D(plant.coords+vec3(0.0,0.0,-0.15),lowerText,scale)
                DrawMarkerForPlant(plant.coords)
                if plant.deathTimer > 0 then
                    DrawText3D(plant.coords+vec3(0.0,0.0,0.15),Config.Text["plant_dying"],scale)
                end
                if plant.growth >= 100 then
                    sleep = 1
                    --custom@pickfromground pickfromground
                    --PROP_HUMAN_BUM_BIN scenario
                    DrawText3D(plant.coords+vec3(0.0,0.0,0.30),Config.Text["E_TO_HARVEST"],scale)
                    if IsControlJustPressed(0, 38) then
                        MenuIsOpen = true
                        StartAnimation(false,Config.Text["harvesting_1"], Config.HarvestTime, true,nil,nil,"PROP_HUMAN_BUM_BIN",nil,function(cancelledFirst)
                            if not cancelledFirst then
                                StartAnimation(false,Config.Text["harvesting_2"], Config.HarvestTime2, true,"custom@pickfromground", "pickfromground",nil,nil,function(cancelledSecond)
                                    if not cancelledSecond then
                                        TriggerServerEvent("plantz:harvest", plantId)
                                    end
                                    MenuIsOpen = false
                                end)
                            else
                                MenuIsOpen = false
                            end
                        end)
                    end
                end
                if Config.Debug then
                    local debugText = ("PlantServerId: %s | PlantNetId: %s | PlantClientId: %s | PlantId: %s"):format(plant.entityId,plant.networkId,plant.clientNetworkId, plant.id)
                    DrawText3D(plant.coords+vec3(0.0,0.0,-0.45),debugText,scale)
                end
                -- DrawText3D(plant.coords[1],plant.coords[2],plant.coords[3], upperText)
                -- DrawText3D(plant.coords[1],plant.coords[2],plant.coords[3]-0.15, lowerText)
            else
                sleep = 500
            end
        elseif dryingSpotId then
            sleep = 1
            local dryingSpot = DryingSpots[dryingSpotId]
            local scale = GetScaleFor3DText(dryingSpot.coords)
            local totalCount = dryingSpot.rawCount + dryingSpot.driedCount
            if totalCount > 0 then
                if dryingSpot.rawCount > 0 then
                    local progress = (Config.Text["dries_yield_units"]):format(dryingSpot.rawCount, dryingSpot.max, dryingSpot.itemLabel, dryingSpot.driedCount)
                    DrawText3D(dryingSpot.coords+vec3(0.0,0.0,0.15),progress,scale)
                elseif dryingSpot.rawCount == 0 and dryingSpot.driedCount > 0 then
                    local text = (Config.Text["yield"]):format(dryingSpot.driedCount, dryingSpot.itemLabel)
                    DrawText3D(dryingSpot.coords+vec3(0.0,0.0,0.15),text,scale)
                end
                if dryingSpot.driedCount > 0 then
                    DrawText3D(dryingSpot.coords+vec3(0.0,0.0,0.0),Config.Text["G_TO_HARVEST"],scale)
                    if IsControlJustPressed(0, 47) then
                        MenuIsOpen = true
                        StartAnimation(false,Config.Text["leaves"], 250 * dryingSpot.driedCount, true,"amb@prop_human_movie_bulb@base", "base",nil,nil,function(cancelled)
                            if not cancelled then
                                TriggerServerEvent("plantz:getDriedItems", dryingSpotId)
                            end
                            MenuIsOpen = false
                        end)
                        
                    end
                end
            end
            if totalCount < dryingSpot.max then
                DrawText3D(dryingSpot.coords+vec3(0.0,0.0,0.30),Config.Text["E_TO_DRY"],scale)
                if IsControlJustPressed(0, 38) and not MenuIsOpen then
                    local playerItems = GetFilteredItems(dryingSpot.exclusives)
                    local elements = {}
                    for k, v in pairs (playerItems) do
                        table.insert(elements, {label = ("%s - x%s"):format(v.label,v.count),count = v.count,dryingSpotId = dryingSpotId, value=k})
                    end
                    if #elements > 0 then
                        MenuIsOpen = true
                        ESX.UI.Menu.Open('default', GetCurrentResourceName(), "plantz_drying_menu",
                            {
                                title    = Config.Text["choose_plant"],
                                align    = "top-right",
                                elements = elements
                            },
                        function(data, menu)
                            ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count', {
                                title = (Config.Text["choose_quantity_max"]):format(dryingSpot.max)
                            }, function(data2, menu2)
                                local count = tonumber(data2.value)
                
                                if count == nil or count > dryingSpot.max or totalCount + count > dryingSpot.max and data.current.count < count then
                                    ESX.ShowNotification(Config.Text["dealer_sell_wrong_quantity"],'error')
                                else
                                    menu2.close()
                                    menu.close()
                                    
                                    StartAnimation(false,Config.Text["attaching_leaves"], 250 * count, true,"amb@prop_human_movie_bulb@base", "base",nil,nil,function(cancelled)
                                        if not cancelled then
                                            TriggerServerEvent("plantz:startDrying", data.current.dryingSpotId,data.current.value,count)
                                        end
                                        MenuIsOpen = false
                                    end)
                                end
                            end, function(data2, menu2)
                                menu2.close()
                            end)
                        end, function(data, menu)
                            menu.close()
                            MenuIsOpen = false
                            -- EmployeesMainMenu(id,val)
                        end)
                    else
                        ESX.ShowNotification(Config.Text["no_req_prods"], 'error')
                    end
                    -- TriggerServerEvent("plantz:harvest", plantId)
                end
            end
        elseif GetNearestDealer(playerCoords,50.0) ~= nil and not MenuIsOpen then
            DealerTick(playerCoords)
        elseif DryingSpotsToLoad then
            for k,v in pairs(DryingSpotsToLoad) do
                local dryingSpot = DryingSpots[k]
                local scale = GetScaleFor3DText(dryingSpot.coords)
                local totalCount = dryingSpot.rawCount + dryingSpot.driedCount
                if totalCount > 0 then
                    if dryingSpot.rawCount > 0 then
                        local progress = (Config.Text["dries_yield_units"]):format(dryingSpot.rawCount, dryingSpot.max, dryingSpot.itemLabel, dryingSpot.driedCount)
                        DrawText3D(dryingSpot.coords+vec3(0.0,0.0,0.15),progress,scale)
                    elseif dryingSpot.rawCount == 0 and dryingSpot.driedCount > 0 then
                        local text = (Config.Text["yield"]):format(dryingSpot.driedCount, dryingSpot.itemLabel)
                        DrawText3D(dryingSpot.coords+vec3(0.0,0.0,0.15),text,scale)
                    end
                else
                    DrawText3D(dryingSpot.coords+vec3(0.0,0.0,0.15),Config.Text['empty'],scale)
                end
            end
        else
            sleep = 500
        end
        ::END::
        Citizen.Wait(sleep)
    end
end)
function DrawText3D(coords, text,scale)
    coords = type(coords) == 'vector3' and coords or type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or error('expected xyz coordinates when drawing text, received '..type(coords))
	if font == nil then font = exports["font"].GetFontId() end
	SetTextScale(1.0 * scale, 0.55 * scale)
	SetTextFont(font)
	SetTextProportional(1)
	SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(1, 1, 1, 1, 255)
	SetTextEntry('STRING')
	SetTextCentre(true)
	AddTextComponentString(text)
	SetDrawOrigin(coords.x, coords.y, coords.z, 0)
	DrawText(0.0, 0.0)
	ClearDrawOrigin()
end


function loadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(500)
    end
end


function process(type)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.5, -1.2)
    local rot = GetEntityHeading(ped)

    TriggerServerEvent("plantz:addProcess", type, coords, rot)
    TaskStartScenarioInPlace(ped, "PROP_HUMAN_BUM_BIN", 0, false)

    Citizen.Wait(2000)

    ClearPedTasks(ped)
end

local AllowedGroundHashes = {
    -1286696947,-1885547121,223086562,-461750719,1109728704,1187676648,834144982
}
function DoesExistsInTable(table,value)
    for k,v in pairs(table) do
        if k == value or v == value then
            return true
        end
    end
    return false
end

function IsMaximumPlantsInArea(coords)
    if TotalPlantsInArea > Config.MaxPlantsInArea then return true end
    return false
end

function IsAnyPlantNear(coords)
    if PlantsToLoad == nil then return false end
    for k, v in pairs(PlantsToLoad) do
        if #(coords - v.coords) < (Config.DistanceToInteract+0.1) then
            print(#(coords - v.coords), "<",  (Config.DistanceToInteract+0.1), v.id)
            return true
        end
    end
    return false
end

function CanPlayerPlantHere(coords)
    return not IsMaximumPlantsInArea(coords) and not IsAnyPlantNear(coords)
end
function plant(plant)
    local ped = PlayerPedId()
    -- local coords = GetEntityCoords(ped)
    local offset = GetOffsetFromEntityInWorldCoords(ped,0.0, 0.8, 0.0)
    coords = offset
    local groundHash = GetGroundHash(ped)
    local isValidGround = DoesExistsInTable(AllowedGroundHashes,groundHash)
    if isValidGround and CanPlayerPlantHere(coords) and not action then
            StartAnimation(false, Config.Text["planting_plant"], Config.PlantingTime, true,nil,nil,"world_human_gardener_plant",function() action = true end,function (canceled)
                if not canceled then
                    TriggerServerEvent("plantz:addPlant", plant, coords)
                end
                action = false
            end)
    else
        local message = ". "
        if not isValidGround then
            message = message .. "Netinkamas žėmės paviršius" .. (Config.Debug == true and ("GroundHash:" .. groundHash) or ". ")
        end
        if IsAnyPlantNear(coords) then
            message = message .. "Per arti kito augalo "
        end
        if IsMaximumPlantsInArea(coords) then
            message = message .. "Maximum capacity reached for this area. Try to move further. Max is: ".. Config.MaxPlantsInArea
        end
        if action then
            message = message .. " You are busy with other action "
        end
        SendTextMessage(Config.Text["cant_plant"].. message, 'error')
    end
end


function GetGroundHash(ped)
    local posped = GetEntityCoords(ped)
    local num =
    StartShapeTestCapsule(posped.x, posped.y, posped.z + 2, posped.x, posped.y, posped.z - 2.0, 2, 1, ped, 7)
    local _retval, _hit, _endCoords, _surfaceNormal, materialHash, _entityHit = GetShapeTestResultEx(num)
    return materialHash
end

function nearProccesing(ped)
    for k, v in pairs(ProcessingTables) do
        if #(v.coords - GetEntityCoords(ped)) < 2.0 then
            return k
        end
    end

    return false
end

AddEventHandler(
"playerDropped",
    function(reason)
        TriggerServerEvent("plantz:tableStatus", CurrentTable, true)
    end
)
