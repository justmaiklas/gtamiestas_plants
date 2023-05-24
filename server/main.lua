ESX = nil
-- local Plants = {}
local DryingSpots = Config.Drying
TriggerEvent("Gtamiestas_getSharedObject", function(obj) ESX = obj end)

MySQL.ready(function ()
    Init()
end)
CreateThread(function ()
    Citizen.Wait(50000)
    Init()

end)
local InitRan = false
local scriptReady = false
Trace = function (msg, override)
    if Config.Debug or override then
        print(("[^2%s^7][^3DEBUG^7] %s"):format(GetCurrentResourceName(), msg))
    end
end

ExecuteSql =  function (wait, query,table, cb)
    if GetResourceState(Config.oxmysql_name) ~= "started" then
        Trace("^1[ox_mysql] is not running! Current resource state:" .. GetResourceState(Config.oxmysql_name))
        return "ERROR"
    end
	if wait then
		return MySQL.query.await(query, table)
	else
		if type(cb) ~= nil then
			MySQL.query(query,table, cb)
		else
			MySQL.query(query,table)
		end
	end
	return "SQL DONE TASKS"
end
    
function Init()
    if not InitRan then
    InitRan = true
    Trace("Initiliazing script")
    Dealers:Init()
    Plants:Init()
    SetInterval(Dealers.Tick, 1000 * Config.GlobalTickRate)
    SetInterval(Plants.Tick, 1000 * Config.GlobalTickRate)
    end
end
function SpawnPlants()
    for k, v in pairs(Plants) do
        SpawnPlant(v.type, v.coords, v.info.growth, k)
    end
end
function GetPlantSizeString(growth)
    local plantSize = "small"
    if growth < 30 then
        plantSize = "small"
    elseif growth < 60 then
        plantSize = "medium"
    elseif growth < 95 then
        plantSize = "large"
    elseif growth <= 100 then
        plantSize = "finished"
    end
    return plantSize
end

 SpawnObject = function(model, coords, heading, cb)
	if type(model) == 'string' then model = GetHashKey(model) end
	CreateThread(function()
		local entity = CreateObjectNoOffset(model, coords, true, true, false)
		while not DoesEntityExist(entity) and entity ~= 0 do Wait(1) end
		SetEntityHeading(entity, heading)
		Entity(entity).state.createdByServer = true

		cb(entity)
	end)
end

function plant(player, type)
    TriggerClientEvent("plantz:plant", player, type)
end

RegisterServerEvent("plantz:addPlant")
AddEventHandler(
"plantz:addPlant",
    function(plantType, coords)
        local Player = ESX.GetPlayerFromId(source)
        Plants:CreatePlant(plantType, coords, source)
        Player.removeInventoryItem(type, 1)
    end
)

RegisterServerEvent("plantz:removeItem")
AddEventHandler(
"plantz:removeItem",
    function(item, count)
        local Player = ESX.GetPlayerFromId(source)

        Player.removeInventoryItem(item, count)
    end
)


function GetPlantsInfo(minimal)
    while not scriptReady do
        Citizen.Wait(100)
    end
    if minimal then
        local minimalInfo = {}
        for k,v in pairs(Plants) do
            minimalInfo[k] = {}
            minimalInfo[k].coords = v.coords
            minimalInfo[k].id = v.id
        end
        return minimalInfo
    else
        return Plants
    end
end
-- ESX.RegisterServerCallback("plantz:getInfo", function (_, cb)
--     cb(GetPlantsInfo(false), DryingSpots, Dealers.GetDealers(true))
-- end)

function deleteEntity(entity)
    if entity ~= nil and DoesEntityExist(entity) then
        DeleteEntity(entity)
    end
end

RegisterServerEvent("plantz:harvest", function(plantId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local plant = Plants:GetPlantById(plantId, true)
    if plant and plant.growth >= 100.0 then
        local plantInfo = GetPlantByType(plant.plantType)
        local amount = plantInfo.Amount
        local producedItem = plantInfo.Produce
        local totalAmount = math.floor(amount * (plant.quality/100))
        xPlayer.addInventoryItem(producedItem, totalAmount)
        Plants:DeletePlantById(plantId)
    else
        xPlayer.showNotification(Config.Text["error"], 'error')
    end
end)
RegisterServerEvent("plantz:startDrying", function(dryingSpotId,itemName,count)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xItem = xPlayer.getInventoryItem(itemName)
    local totalSpotAmount = DryingSpots[dryingSpotId].rawCount + DryingSpots[dryingSpotId].driedCount + count
    local canAdd = totalSpotAmount <= DryingSpots[dryingSpotId].max and (DryingSpots[dryingSpotId].itemName == nil or DryingSpots[dryingSpotId].itemName == itemName)
    if not canAdd then
        xPlayer.showNotification(Config.Text["error_wrong_items_or_cant_add"], 'error')
        return
    end
    if xItem and xItem.count >= count then
        DryingSpots[dryingSpotId].taken = true
        DryingSpots[dryingSpotId].rawCount += count
        DryingSpots[dryingSpotId].itemName = itemName
        DryingSpots[dryingSpotId].itemLabel = xItem.label
        xPlayer.removeInventoryItem(itemName,count)
        TriggerClientEvent("plantz:updateDryingSpotId", -1, dryingSpotId, DryingSpots[dryingSpotId])
    else
        xPlayer.showNotification(Config.Text["error_not_enough_items"], 'error')
    end
end)

RegisterServerEvent("plantz:getDriedItems", function(dryingSpotId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if DryingSpots[dryingSpotId].driedCount > 0 then
        local countToGive = DryingSpots[dryingSpotId].driedCount
        DryingSpots[dryingSpotId].driedCount = 0
        local orignalItem = DryingSpots[dryingSpotId].itemName
        local producedItem = DryingSpots[dryingSpotId].produces[orignalItem]
        xPlayer.addInventoryItem(producedItem,countToGive)
        if DryingSpots[dryingSpotId].driedCount <= 0 and DryingSpots[dryingSpotId].rawCount <= 0 then
            DryingSpots[dryingSpotId].rawCount = 0
            DryingSpots[dryingSpotId].itemName = nil
            DryingSpots[dryingSpotId].itemLabel = nil
        end
        TriggerClientEvent("plantz:updateDryingSpotId", -1, dryingSpotId, DryingSpots[dryingSpotId])
    else
        xPlayer.showNotification(Config.Text["error"], 'error')
    end
end)

RegisterServerEvent("plantz:UseItem", function(plantId, itemName)
    local xPlayer = ESX.GetPlayerFromId(source)
    if Config.UsableItems[itemName] and xPlayer.getInventoryItem(itemName).count > 0 then
        local canRemove = false
        
        for _,v in pairs (Config.UsableItems[itemName]) do
            if Plants:GetPlantById(plantId)[v.increaseType] < 100 and Plants:GetPlantById(plantId)[v.increaseType] < v.max then
                canRemove = true
                if v.amount > 0 then
                    Plants:GetPlantById(plantId):IncreaseStat(v.increaseType, v.amount, v.max)
                else
                    Plants:GetPlantById(plantId):DecreaseStat(v.increaseType, v.amount, v.min)

                end
                -- Plants[plantId].info[v.increaseType] += v.amount
                -- Plants[plantId].info[v.increaseType] = Plants[plantId].info[v.increaseType] > v.max and v.max or Plants[plantId].info[v.increaseType]
            end
        end
        if canRemove then
            xPlayer.removeInventoryItem(itemName, 1)
            TriggerClientEvent("plantz:updatePlant", -1, plantId, Plants:GetPlantById(plantId, true))
        end
    end
end)

SavePlants = function()
    print("SAVING")
    Plants:SavePlants(function ()
        
    end)

end
SetInterval(SavePlants, Config.GlobalTickRate * Config.TickRateCountForSave * 1000)
AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end
    Plants:SavePlants()
    local plants = Plants:GetPlants()
        for k, v in pairs(plants) do
            DeleteEntity(v.entityId)
        end
    Dealers.SendInfos()
end)

AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
	if eventData.secondsRemaining == 60 then
		CreateThread(function()
			Wait(50000)
            Dealers.SendInfos()
			SavePlants()
		end)
	end
end)

ESX.RegisterCommand('savePlants', 'admin', function()
	SavePlants()
end, true, {help = "Save all plants"})





