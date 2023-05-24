Plant = {
    id = nil,
    plantType = nil,
    coordinates = {
        x = 0,
        y = 0,
        z = 0,
    },
    water = 0,
    food = 0,
    growth = 0,
    quality = 0,
    rate = Config.DefaultRate,
    deathTimer = 0,
    plantSize = "",
    estimatedGrowthTime = 0
}
function Plant:SpawnEntity() 
    local PlantModelInfos = GetPlantByType(self.plantType).PlantModelSizes
    local plantSize = GetPlantSizeString(self.growth)
    
    local plantModel = PlantModelInfos[plantSize].model
    Trace(string.format("Spawning entity.. \nPlant id %s, Plant type: %s; Plant size: %s, Plant model: %s, Coordinates: %s", self.id, self.plantType, plantSize, plantModel, json.encode(self.coordinates)))
    local plantOffsetZ = PlantModelInfos[plantSize].offsetZ
    local coords = vec3(self.coordinates.x,self.coordinates.y,self.coordinates.z) + vec3(0.0, 0.0, plantOffsetZ)
    local busy = true
    SpawnObject(plantModel,coords,0.0, function(entityId)
        SetEntityDistanceCullingRadius(entityId, Config.DistanceToLoad)
        self.entityId = entityId
        if entityId == 0 then
            Trace(string.format("[^1ERROR^7] ^7Plant not spawned. ID: %s", self.id),true)
        end
        self.networkId = NetworkGetNetworkIdFromEntity(entityId)
        self.plantSize = plantSize
        busy = false
    end)
    while busy do
        Trace("Waiting for plant to spawn")
        Wait(5)
    end
end

function Plant:DoesEntityExists()
    if DoesEntityExist(self.entityId) then
        return true
    end
    
    if  NetworkGetEntityFromNetworkId(self.networkId) ~= 0 then
        return true
    end
    return false
end

function Plant:DeleteEntity()
    if not self.entityId then return end
    DeleteEntity(self.entityId)
    local tries = 0
    while self:DoesEntityExists() do
        if tries < 2 then
            DeleteEntity(self.entityId)
        elseif tries >= 2 and tries < 5 then
            DeleteEntity(NetworkGetEntityFromNetworkId(self.networkId))
        elseif tries >= 5 then
            Trace("^1ERROR^7] Plant entity cannot be deleted! Deleting with entityId and netId failed, aborted")
            return
        end
        tries+= 1
        Wait(5)
    end
    self.entityId = nil
    self.networkId = nil
    Trace(string.format("Deleting entity.. Plant id %s, \nPlant type: %s; Plant size: %s, Coordinates: %s", self.id, self.plantType, self.plantSize, json.encode(self.coordinates)))


end

function Plant:DeletePlant()
    self:DeleteEntity()
    Trace(string.format("Deleting plant (incl. database).. \nPlant id %s, Plant type: %s; Plant size: %s, Coordinates: %s", self.id, self.plantType, self.plantSize, json.encode(self.coordinates)))
    ExecuteSql(false, "DELETE FROM plants where id = @id", {["@id"] = tonumber(self.id)})
    TriggerClientEvent("plantz:deletePlant" , -1, self.id)
    Trace("Plant deleted:",self.id)
    self = nil
end

function Plant:IsDying()
    if self.water < 1 then
        return true
    end
    return false
end

function Plant:IncreaseDeathTimer()
    self.deathTimer += 1
    Trace(string.format("Increased deathTimer for plant.. \nPlant id %s, Plant type: %s; Plant water level: %s, Death timer: %s, Coordinates: %s", self.id, self.plantType, self.water, self.deathTimer, json.encode(self.coordinates)))

end

function Plant:ResetDeathTimer()
    self.deathTimer = 0
    Trace(string.format("Reseted deathTimer for plant.. \nPlant id %s, Plant type: %s; Plant water level: %s, Death timer: %s, Coordinates: %s", self.id, self.plantType, self.water, self.deathTimer, json.encode(self.coordinates)))
end

function Plant:DeleteIfNeeded()
    Trace(string.format("Checking if plant must be deleted.. \nPlant id %s, Plant type: %s; Plant water level: %s, Death timer: %s, Coordinates: %s", self.id, self.plantType, self.water, self.deathTimer, json.encode(self.coordinates)))
    if self.deathTimer >= GetPlantByType(self.plantType).MaxDeathTimer then
        Plants:DeletePlantById(self.id)
    end
end

function Plant:SetStat(statType, amount)
    if self[statType] == nil then return end
    self[statType] = amount
    self:RoundStat(statType, 2)
    Trace(string.format("Setted stat for plant.. \nPlant id %s, Plant type: %s; Stat: %s, amount: %s, currentValue: %s, Coordinates: %s", self.id, self.plantType, statType, amount, self[statType], json.encode(self.coordinates)))
end

function Plant:IncreaseStat(increaseType, amount, max)
    if self[increaseType] == nil then return end
    self[increaseType] += amount
    if max ~= nil then
        self[increaseType] = self[increaseType] > max and max or self[increaseType]
    end
    self:RoundStat(increaseType, 2)
    Trace(string.format("Increased stat for plant.. \nPlant id %s, Plant type: %s; Stat: %s, amount: %s, max amount: %s, currentValue: %s, Coordinates: %s", self.id, self.plantType, increaseType, amount, max, self[increaseType], json.encode(self.coordinates)))
end

function Plant:DecreaseStat(decreaseType, amount, min)
    if self[decreaseType] == nil then return end
    self[decreaseType] -= amount
    if min ~= nil then
        self[decreaseType] = self[decreaseType] < min and min or self[decreaseType]
    end
    self:RoundStat(decreaseType, 2)
    Trace(string.format("Decreased stat for plant.. \nPlant id %s, Plant type: %s; Stat: %s, amount: %s, min amount: %s, currentValue: %s, Coordinates: %s", self.id, self.plantType, decreaseType, amount, min, self[decreaseType], json.encode(self.coordinates)))
end

function Plant:RoundStat(stat,decimalPrecision)
    self[stat] = ESX.Math.Round(self[stat], decimalPrecision)

end

function Plant:CalculateGrowthTime()
    local remainingGrowth = 100 - self.growth
    local remainingTicks = remainingGrowth / (GetPlantByType(self.plantType).GrowthPercentToAdd * self.rate)
    local estimatedGrowthTime = remainingTicks * Config.GlobalTickRate
    self.estimatedGrowthTime = estimatedGrowthTime
end

function Plant:IncreaseGrowthTick()
    self:IncreaseStat("growth",GetPlantByType(self.plantType).GrowthPercentToAdd * self.rate, 100)
    Trace(string.format("Increased growth(tick) for plant.. \nPlant id %s, Plant type: %s; current growth: %s, Estimated Growth Time: %s(s); Coordinates: %s", self.id, self.plantType, self.growth, self:CalculateGrowthTime(), json.encode(self.coordinates)))

end

function Plant:RemoveWaterTick()
    self:DecreaseStat("water",GetPlantByType(self.plantType).WaterPercentToRemove * self.rate, 0)
end

function Plant:CalculateNewQuality()
    local plantTypeData = GetPlantByType(self.plantType)
    if not plantTypeData then return end
    if self.water > plantTypeData.MinimumWaterForQuality then
        self.quality += plantTypeData.QualityPercentToAdd * self.rate
        self.quality = self.quality > 100 and 100 or self.quality
    else
        self.quality += plantTypeData.QualityPercentToAdd * self.rate
        self.quality = self.quality < 0 and 0 or self.quality
    end
end

function Plant:ChangeEntityModel()
    self:DeleteEntity()
    self:SpawnEntity()
    Trace(string.format("Changed entity model for plant.. \nPlant id %s:, Plant type: %s; current size: %s, Coordinates: %s", self.id, self.plantType, self.plantSize, json.encode(self.coordinates)))

end

function Plant:CheckEntityModel()
    if GetPlantSizeString(self.growth) ~= self.plantSize then
        self:ChangeEntityModel()
    end
end

function Plant:UpdateProgress(cb)
    if self:IsDying() then
        Trace("Plant is dying. ID:" .. self.id)
        self:IncreaseDeathTimer()
        self:DeleteIfNeeded()

        return type(cb) == 'function' and cb() or nil
    end
    self:IncreaseGrowthTick()
    self:RemoveWaterTick()
    self:CalculateNewQuality()
    self:ResetDeathTimer()
    self:CheckEntityModel()
    Trace("Updated progress for plant. ID:" .. self.id)
    if type(cb) == 'function' then cb() end
end

function Plant:RefreshPlantSync()
    self:CheckEntityModel()
    TriggerClientEvent("plantz:updatePlant",-1, self.id, self:GetMinimalInfo())
end

function Plant:GetZoneFromCoords(coords)
    for _, v in ipairs(Config.Zones) do
        if #(v.Coords - coords) < v.Radius then
            return v
        end
    end
    Trace(string.format("Zone not found at %s", coords))

    return nil
end

function Plant:IsPlantZoneExclusive(zone, plantType)
    for _, exclusivePlantType in ipairs(zone.Exclusive) do
        if exclusivePlantType == plantType then
            Trace(string.format("Plant %s is exlusive for zone %s", plantType, zone.DisplayText))
            return true
        end
    end
    return false
end

function Plant:InsertPlantToDb(this)
    local busy = true
    Trace(string.format("Inserting new plant to DB... \nPlant type: %s, Coordinates: %s", this.plantType,this.coordinates))
    ExecuteSql(false,
        "INSERT INTO plants (coords, type, data) VALUES (@coords, @type, @data)",
        {
            ["@coords"] = json.encode(this.coordinates),
            ["@type"] = this.plantType,
            ['@data'] = json.encode(this)
        },
        function(response)
            local id = tostring(response.insertId)
            this.id = id
            busy = false
            Trace(string.format("New plant saved to DB... \nNew plant ID:", this.id))
        end
    )
    while busy do
        Wait(100)
    end
    return this.id
end


function Plant:new (plantType, coords, src)
    if not GetPlantByType(plantType) then
         return "ERROR_INVALID_PLANT_TYPE"
         end
    local zone = Config.OnlyZones and Plant.GetZoneFromCoords(coords) or nil
    if Config.OnlyZones and zone == nil then
        Trace(string.format("Error. Player not in zone. Can not plant"))
        return "ERROR_PLAYER_NOT_IN_ZONE"
    end
    if Config.OnlyZones and not Plant.IsPlantZoneExclusive(zone, plantType) then
        Trace(string.format("Error. This seed is not plantable in this zone: \nplant type: %s, zone labe;:", plantType,zone.DisplayText))
        return "ERROR_PLANT_TYPE_IS_NOT_ALLOWED_ZONE"
    end
    
    local this = {
        id = nil,
        plantType = plantType,
        coordinates = {
            x = coords[1],
            y = coords[2],
            z = coords[3],
        },
        water = 5,
        food = 0,
        growth = 0,
        quality = 0,
        rate = zone ~= nil and zone.GrowthRate or Config.DefaultRate,
        deathTimer = 0,
        plantSize = "",
        estimatedGrowthTime = 0
    }
    Plant:InsertPlantToDb(this)
    setmetatable(this, Plant)
    this:CalculateGrowthTime()
    return this
end

function Plant:Save()
    local parameters = {json.encode(self:GetMinimalInfo()), tonumber(self.id)}
    MySQL.prepare('UPDATE plants SET data = ? WHERE id = ?', parameters)
end

function Plant:GetMinimalInfo()
    local minimalInfo = {
    id = self.id,
    plantType = self.plantType,
    coordinates = self.coordinates,
    coords = vector3(self.coordinates.x,self.coordinates.y,self.coordinates.z),
    water = self.water,
    food = self.food,
    growth = self.growth,
    quality = self.growth,
    rate = self.rate,
    deathTimer = self.deathTimer,
    plantSize = self.deathTimer,
    entityId = self.entityId,
    networkId = self.networkId,
    estimatedGrowthTime = self.estimatedGrowthTime

    }
    return minimalInfo
end

Plant.__index = Plant

Plants = {
    plants = {}
}

function Plants:LoadFromDb()
    Trace(string.format("Loading plants from DB.."))

    ExecuteSql(false,"SELECT id, data FROM plants WHERE 1", {},
        function(infoPlants)
            for _, v in ipairs(infoPlants) do
                local id = tostring(v.id)
                local data = json.decode(v.data)
                data.id = id
                Plants.plants[id] = data
                setmetatable(Plants.plants[id], Plant)
            end
            Trace(string.format("Loaded %s plants from DB..", #infoPlants))
            Plants:SpawnPlants()
        end
    )
end
function Plants:SpawnPlants()
    for _,v in pairs(self.plants) do
        Trace(string.format("Spawning plant: \nID %s, Plant type: %s, coordinates: %s", v.id, v.plantType, json.encode(v.coordinates)))
        v:SpawnEntity()
    end
end

function Plants:SavePlants(cb)
        local time = os.nanotime()
        local plants = Plants.plants
        local parameters = {}
        local count = 0
        for _,v in pairs (plants) do
            count = count + 1
            parameters[count] = {json.encode({plantType = v.plantType,water = v.water, food = v.food, growth = v.growth, quality = v.quality, rate = v.rate, deathTimer = v.deathTimer, coordinates = v.coordinates}), tonumber(v.id)}
        end
        if count > 0 then
            MySQL.prepare('UPDATE plants SET data = ? WHERE id = ?', parameters)
        end
        Trace(("%s plants saved successfully in: %s ms"):format(count,(os.nanotime() - time) / 1000000))
    if type(cb) == "function" then
        cb()
    end
end

function Plants:SavePlantById(plantId, cb)
    Plants[plantId].Save()
    if type(cb) == "function" then
        cb()
    end
end

function Plants:DeletePlantById(plantId, cb)
    local plant = Plants:GetPlantById(plantId)
    if plant then
        plant:DeletePlant()
        Plants.plants[plantId] = nil
    else
        Trace("^1ERROR^7] Plant cannot be deleted, not found in memory! Plant Id:" .. plantId, true)
    end
    if type(cb) == "function" then
        cb()
    end
end

function Plants:GetPlantById(plantId,minimal)
    if minimal then
        return Plants.plants[plantId]:GetMinimalInfo()
    end
    return Plants.plants[plantId]
end
function Plants:GetPlants(minimal)
    if minimal then
        local minimalPlantsInfo = {}
        for k, v in pairs(Plants.plants) do
            minimalPlantsInfo[k] = v:GetMinimalInfo()
        end
        return minimalPlantsInfo
    end
    return Plants.plants
end

function Plants:CreatePlant(plantType, coords, src)
    local newPlant = Plant:new(plantType, coords, src)
    newPlant:SpawnEntity()
    TriggerClientEvent("plantz:updatePlant",-1, newPlant.id, newPlant:GetMinimalInfo())
    Plants.plants[newPlant.id]=newPlant
end

function Plants:Init()
    self:LoadFromDb()
    ESX.RegisterServerCallback("Plantz:GetPlantsInfo", function (_, cb)
        cb(Plants:GetPlants(true))
    end)
    function self.Tick(cb)
        local time = os.nanotime()
        local minimalPlantsInfo = {}
        local plantsCount = 0
        for k, v in pairs(self.plants) do
            plantsCount +=1
            v:UpdateProgress()
            v:Save()
            Trace(string.format("Tick for plant: \nID %s, Plant type: %s, coordinates: %s", v.id, v.plantType, json.encode(v.coordinates)))
            minimalPlantsInfo[k] = v:GetMinimalInfo()
        end
        TriggerClientEvent("Plantz:UpdatePlants",-1,minimalPlantsInfo)
        minimalPlantsInfo =nil
        Trace(("%s plants globally updated successfully in: %s ms"):format(plantsCount,(os.nanotime() - time) / 1000000),true)

        if type(cb) == "function" then
            cb()
        end
    end
    -- function self.Tick(cb)
    --     local minimalPlantsInfo = {}
    --     for k, v in pairs(self.plants) do
    --         v:UpdateProgress()
    --         minimalPlantsInfo[k] = v:GetMinimalInfo()
    --     end
    --     TriggerClientEvent("Plantz:UpdatePlants",-1,minimalPlantsInfo)
    --     if type(cb) == "function" then
    --         cb()
    --     end
    -- end
    Trace("Plants loaded")
end

SetPlantStat = function(plantId, stat, amount, xPlayer)
    if not stat then
        xPlayer.showNotification("stat is nil")
        return end
    if not plantId then
        xPlayer.showNotification("plantId is nil")
        return end
    if not amount then
        xPlayer.showNotification("amount is nil")
        return end
        if not Plants:GetPlantById(plantId) then
            xPlayer.showNotification("Plant not found by that id ".. plantId)
            return
        end
        Trace(string.format("Setting stat %s to %s for plant by ID %s", stat,amount,plantId))
    local plant = Plants:GetPlantById(plantId)
    plant:SetStat(stat, amount)
    plant:RefreshPlantSync()
end

ESX.RegisterCommand({'plantall_setstat'}, 'admin', function(xPlayer, args, _)
    for _,v in pairs(Plants.plants) do
        SetPlantStat(v.id, args.stat,args.amount, xPlayer)
    end
  end, false, {help = "Set stat of plant by id", arguments = {
      {name = 'stat', help = "water/growth/deathTimer/rate/quality", type = 'string'},
      {name = 'amount', help = "0-100", type = 'number'},
    }
  })

ESX.RegisterCommand({'plant_setstat'}, 'admin', function(xPlayer, args, _)
    SetPlantStat(args.plantId,args.stat,args.amount, xPlayer)
  end, false, {help = "Set stat of plant by id", arguments = {
      {name = 'stat', help = "water/growth/deathTimer/rate/quality", type = 'string'},
      {name = 'plantId', help = "Plant ID", type = 'string'},
      {name = 'amount', help = "0-100", type = 'number'},
    }
  })