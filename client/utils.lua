PlantsToLoad = {}
DryingSpotsToLoad = {}
LoadedPlantsCount = 0
TotalPlantsInArea = 0
Citizen.CreateThread(function ()
	while true do
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local isInVehicle = IsPedInAnyVehicle(ped, false)
        if not ScriptIsReady then goto END end
        if next(Plants) and not isInVehicle then
            local tempPlantsCount = 0
            for plantId,plantData in pairs(Plants) do
                local distance = #(coords - plantData.coords) 
                if distance <= Config.AreaRadius then
                    tempPlantsCount += 1
                end
                if distance <= Config.DistanceToLoad then
                    if PlantsToLoad == nil then
                        PlantsToLoad = {}
                    end
                    local found = PlantsToLoad[plantId] ~= nil and true or false
                    if not found then
                        PlantsToLoad[plantId] = {coords = plantData.coords}
                        if Config.Debug then
                            Plants[plantId].clientNetworkId = NetworkGetEntityFromNetworkId(plantData.networkId)
                        end
                    end

                end

            end
            if TotalPlantsInArea ~= tempPlantsCount then
                TotalPlantsInArea = tempPlantsCount
            end
            if PlantsToLoad ~= nil then
                LoadedPlantsCount = 0
                for plantId,plantData in pairs(PlantsToLoad) do
                    LoadedPlantsCount +=1
                    if #(coords - plantData.coords) > Config.DistanceToLoad then
                        PlantsToLoad[plantId] = nil
                        LoadedPlantsCount -= 1
                    end
                end
            else
                LoadedPlantsCount = 0
            end
        elseif PlantsToLoad ~= nil and next(PlantsToLoad) then
            PlantsToLoad = nil
        end
        if not isInVehicle then
            for spot,spotData in pairs(DryingSpots) do
                local distance = #(coords - spotData.coords) 
                if distance < Config.DistanceToLoad then
                    local found = DryingSpotsToLoad[spot] ~= nil and true or false
                    if not found then
                        if DryingSpotsToLoad == nil then
                            DryingSpotsToLoad = {}
                        end
                        DryingSpotsToLoad[spot] = {coords = spotData.coords}
                    end
                end
            end
            if DryingSpotsToLoad ~= nil then
                for spot,spotData in pairs(DryingSpotsToLoad) do
                    if #(coords - spotData.coords) > Config.DistanceToLoad then
                        DryingSpotsToLoad[spot] = nil
                    end
                end
            end
        end

        -- if not isInVehicle then
            for dealerKey,dealerData in pairs(Dealers) do
                local distance = #(coords - dealerData.currentLocation.xyz) 
                if distance < Config.DistanceToLoad and dealerData.isAvailable then
                    local found = DealersToLoad[dealerKey] ~= nil and true or false
                    if not found then
                        if DealersToLoad == nil then
                            DealersToLoad = {}
                        end
                        DealersToLoad[dealerKey] = {currentLocation = dealerData.currentLocation}
                        if distance < Config.DistanceToLoad and not DealersToLoad[dealerKey].spawnedPed then
                            DealersToLoad[dealerKey].spawnedPed = NearPed(dealerData.pedModel, dealerData.currentLocation, dealerData.animDict, dealerData.animName, dealerData.scenario)
                        end
                    end
                end

            end
            if DealersToLoad ~= nil then
                for dealerKey,dealerData in pairs(DealersToLoad) do
                    if #(coords - dealerData.currentLocation.xyz) > Config.DistanceToLoad or not Dealers[dealerKey].isAvailable then
                        if dealerData.spawnedPed ~= nil then
                            DeleteDealerPed(dealerKey)
                        end
                        DealersToLoad[dealerKey] = nil
                    end
                end
            end
        -- end
        -- print(GetNearestPlantId(),LoadedPlantsCount)
        ::END::
	Citizen.Wait(1000)
	end
end)

GetNearestPlantId = function (playerCoords)
    if LoadedPlantsCount <= 0 or PlantsToLoad == nil then
        return nil
    end
    playerCoords = playerCoords or GetEntityCoords(PlayerPedId())
    for plantId,plantData in pairs(PlantsToLoad) do
        if #(playerCoords - plantData.coords) < Config.DistanceToInteract then
            return plantId
        end
    end
end

GetNearestDryingSpotId = function (playerCoords)
    if DryingSpotsToLoad == nil then
        return nil
    end
    playerCoords = playerCoords or GetEntityCoords(PlayerPedId())
    for spot,spotData in pairs(DryingSpotsToLoad) do

        if #(playerCoords - spotData.coords) < Config.DistanceToInteract then
            return spot
        end
    end
end

GetNearestDealer = function(playerCoords, customDistance)
    if DealersToLoad == nil then
        return nil
    end
    local distance = customDistance ~= nil and customDistance or Config.DistanceToInteract
    playerCoords = playerCoords or GetEntityCoords(PlayerPedId())
    for dealerKey,dealerData in pairs(DealersToLoad) do
        if #(playerCoords - dealerData.currentLocation.xyz) < distance then
            return dealerKey
        end
    end
    return nil
end

local function generateWaterText(number)
    if number < 20.0 then
        return "~r~"..Config.Text["Water"].. number
    elseif number < 40.0 then
        return "~o~"..Config.Text["Water"].. number
    elseif number < 60.0 then
        return "~y~"..Config.Text["Water"].. number
    elseif number < 80.0 then
        return "~g~"..Config.Text["Water"].. number
    elseif number <= 100.0 then
        return "~p~"..Config.Text["Water"].. number
    end
end

local function generateGrowthText(number)
    if number < 20.0 then
        return "~r~"..Config.Text["Growth"].. number
    elseif number < 40.0 then
        return "~o~"..Config.Text["Growth"].. number
    elseif number < 60.0 then
        return "~y~"..Config.Text["Growth"].. number
    elseif number < 80.0 then
        return "~g~"..Config.Text["Growth"].. number
    elseif number <= 100.0 then
        return "~p~"..Config.Text["Growth"].. number
    end
end

local function generateQualityText(quality, food, water)
    
    local firstText = (Config.Text["plant_quality"].." %s "):format((--[[food > Config.MinimumFoodForQuality and--]] water > Config.MinimumWaterForQuality) and "↗" or "↘")
    local qualityText = ""
    if quality <= 5.0 then
        qualityText = "~r~"..Config.Text["Worst"]

    elseif quality < 20.0 then
        qualityText = "~r~"..Config.Text["Bad"]
    elseif quality < 50.0 then
        qualityText = "~o~"..Config.Text["Not_Bad"]
    elseif quality < 80.0 then
        qualityText = "~y~"..Config.Text["Average"]
    elseif quality < 100 then
        qualityText = "~g~"..Config.Text["Good"]
    elseif quality >= 100 then
        qualityText = "~p~"..Config.Text["Best"]
    end
    return firstText .. qualityText
end

local function generateRateText(number)
    
    if number <= 10.0 then
        return Config.Text["soil_quality"] .."~r~".. Config.Text["Worst"]
    elseif number < 20.0 then
        return Config.Text["soil_quality"] .."~o~".. Config.Text["Bad"]
    elseif number < 30.0 then
        return Config.Text["soil_quality"] .."~y~".. Config.Text["Not_Bad"]
    elseif number < 50.0 then
        return Config.Text["soil_quality"] .."~g~".. Config.Text["Good"]
    elseif number >= 50.0 then
        return Config.Text["soil_quality"] .."~p~".. Config.Text["Best"]
    end
end

local function generateRemainingTime(number)
    local minutes = math.floor(number / 60.0)
    local seconds = math.floor(number - minutes * 60)
    return "~b~"..Config.Text["EstimatedGrowthTime"] .. minutes .." min " .. seconds .. " s"
end

GeneratePlantInfoText = function(plant)
    local upperText = ("%s%% ~s~| %s%% ~s~| %s ~s~"):format(generateWaterText(plant.water),generateGrowthText(plant.growth), generateRemainingTime(plant.estimatedGrowthTime))
    local lowerText = ("%s ~s~| %s (%s)"):format(generateQualityText(plant.quality,plant.food, plant.water),generateRateText(plant.rate),plant.rate)
    local fullText = ("%s ~s~| %s"):format(upperText,lowerText)
    
    return upperText, lowerText, fullText
end

GetScaleFor3DText = function (coords,size)
    coords = type(coords) == 'vector3' and coords or type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or error('expected xyz coordinates when drawing text, received '..type(coords))
	local camCoords = GetGameplayCamCoords()
	local distance = #(coords - camCoords)
	if not size then size = 1 end
	local scale = (size / distance) * 2
	local fov = (1 / GetGameplayCamFov()) * 100
	return scale * fov
end

DrawMarkerForPlant = function(coords)
    DrawMarker(27, coords - vec3(0,0,0.99), 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.DistanceToInteract, Config.DistanceToInteract, Config.DistanceToInteract, 100, 255, 100, 100, false, true, 2, true, false, false, false)

end

StartAnimation = function (async, label, duration, canCancel, animDict, animName,scenario, onProgressStart, onProgressComplete )
    exports.rprogress:Custom({
        Async = async,
        canCancel = canCancel,       -- Allow cancelling
        Duration = duration,        -- Duration of the progress
        Label = label,
        Animation = {
            scenario = scenario,
            animationDictionary = animDict, -- https://alexguirre.github.io/animations-list/
            animationName = animName,
        },
        DisableControls = {
            Player = true,
            Vehicle = true,
            Combat = true,
        },    
        onStart = function()
            if onProgressStart then
                onProgressStart()
            end
        end,
        onComplete = function(cancelled)
            if onProgressComplete then
                onProgressComplete(cancelled)
            end
        end
    })
end

function GetFilteredItems(items)
    ESX.UI.Menu.CloseAll()
    local PlayerData = ESX.GetPlayerData()
    local elements = {}
    local playerItems = {}
    for k,v in pairs(PlayerData.inventory) do
        if DoesExistsInTable(items, v.name) then
            playerItems[v.name] = playerItems[v.name] or {}
            playerItems[v.name].label = playerItems[v.name].label or v.label
            playerItems[v.name].count = (playerItems[v.name].count or 0) + v.count
        end
    end
    return playerItems
end





local entityEnumerator = {
    __gc = function(enum)
      if enum.destructor and enum.handle then
        enum.destructor(enum.handle)
      end
      enum.destructor = nil
      enum.handle = nil
    end
  }
  
  local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
    return coroutine.wrap(function()
      local iter, id = initFunc()
      if not id or id == 0 then
        disposeFunc(iter)
        return
      end
      
      local enum = {handle = iter, destructor = disposeFunc}
      setmetatable(enum, entityEnumerator)
      
      local next = true
      repeat
        coroutine.yield(id)
        next, id = moveFunc(iter)
      until not next
      
      enum.destructor, enum.handle = nil, nil
      disposeFunc(iter)
    end)
  end
  
  function EnumerateObjects()
    return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
  end
  
  function EnumeratePeds()
    return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
  end
  
  function EnumerateVehicles()
    return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
  end
  
  function EnumeratePickups()
    return EnumerateEntities(FindFirstPickup, FindNextPickup, EndFindPickup)
  end
  
  function GetAllEnumerators()
    return {vehicles = EnumerateVehicles, objects = EnumerateObjects, peds = EnumeratePeds, pickups = EnumeratePickups}
  end

  RegisterCommand("entityDelete",function()
    Citizen.CreateThread(function() 
        for k,v in pairs(GetAllEnumerators()) do 
            local enum = v
            for entity in enum() do 
                local owner = NetworkGetEntityOwner(entity)
                local playerID = GetPlayerServerId(owner)
                if (owner ~= -1 and (id == playerID or id == -1)) then
                    NetworkDelete(entity)
                end
            end
        end
    end)
end,false)