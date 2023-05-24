Config = {

  Debug = false,
  oxmysql_name = "oxmysql",
  MaxPlantsInArea = 60,
  AreaRadius = 300,

  OnlyZones = false, -- Allow growth only in defined zones
  GlobalTickRate = 10, -- In how many seconds it takes to update the plant.
  TickRateCountForSave = 5, -- GlobalTickRate * entered number, i.e if GlobalTickRate = 10 and TickRateCountForSave = 5, then autosave will happen every  10*5= 50 seconds.
  DefaultRate = 100, -- Plants planted outside zone default growth rate percentage (MAX: 50)
  WeightSystem = true, -- Using ESX Weight System
  DistanceToLoad = 50.0,
  DistanceToInteract = 1.3,
  MinimumWaterForQuality = 40,
  PlantingTime = 10000,
  HarvestTime = 7500,
  HarvestTime2 = 7500,
  Zones = {
      {
      Coords = vec3(249.055, 6474.079, 30.507),
      Radius = 65.0,
      GrowthRate = 33.0,
      Display = false,
      DisplayBlip = 469,
      DisplayColor = 2, 
      DisplayText = '',
      Exclusive = { '' }
      },
  },

  UsableItems = {
    ["wateringcan"] = {
      {increaseType = "water", amount = 25.0, min = 0, max = 100.0},
      {increaseType = "quality", amount = -0.5, min = 0, max = 100.0}
    },
    ["purifiedwater"] = {
      {increaseType = "water", amount = 40.0, min = 0, max = 100.0}
    },
    ["lowgradefert"] = {
      {increaseType = "rate", amount = 2, min = 0, max = 30.0}
    },
    ["highgradefert"] = {
      {increaseType = "rate", amount = 4, min = 0, max = 50.0}
    },
  },


  Plants = { -- Create seeds for plants
    ['tomato_seed'] = {
      Label = 'Pomidoro sėkla', --
      Type = 'tomato', -- Type of plant
      GrowthPercentToAdd = 0.05, -- How much percent from 0.0 to 1.0 plant will grow every "Config.GlobalTickRate". If Plant is growing in zone, then it grow GrowthPercentToAdd * Zone.GrowthRate percents
      FoodPercentToRemove = 0.25,  -- How much percent from 0.0 to 1.0 plant will consume food every "Config.GlobalTickRate". If Plant is growing in zone, then it consume food "FoodPercentToAdd * Zone.GrowthRate" percents
      WaterPercentToRemove = 0.05, -- How much percent from 0.0 to 1.0 plant will consume water every "Config.GlobalTickRate" If Plant is growing in zone, then it consume water "FoodPercentToAdd * Zone.GrowthRate" percents
      QualityPercentToAdd = 0.06, -- How much percent from 0.0 to 1.0 plant will consume water every "Config.GlobalTickRate" If Plant is growing in zone, then it add/remove quality "QualityPercentToAdd * Zone.GrowthRate" percents
      MinimumWaterForQuality = 40,
      PlantType = 'tomato', -- Choose plant types from (plant1, plant2, small_plant) also you can change plants yourself in main/client.lua line: 2
      Produce = 'tomato', -- Item the plant is going to produce when harvested
      Amount = 15, -- The max amount you can harvest from the plant
      MaxDeathTimer = 15,
      PlantModelSizes = {
        small = {model = `potato_plant_1`, offsetZ = -1.5 },
        medium = {model = `potato_plant_1`, offsetZ = -1.32 },
        large = {model = `potato_plant_1`, offsetZ = -1.15 },
        finished = {model = `tomato_plant`, offsetZ = -1.0 },
      },
      UsableItems = {
        ["wateringcan"] = {
          {increaseType = "water", amount = 25.0, min = 0, max = 100.0},
          {increaseType = "quality", amount = -0.5, min = 0, max = 100.0}
        },
        ["purifiedwater"] = {
          {increaseType = "water", amount = 40.0, min = 0, max = 100.0}
        },
        ["lowgradefert"] = {
          {increaseType = "rate", amount = 2, min = 0, max = 30.0}
        },
        ["highgradefert"] = {
          {increaseType = "rate", amount = 4, min = 0, max = 50.0}
        },
      },
    },
    ['apple_seed'] = {
      Label = 'Pomidoro sėkla', --
      Type = 'apple', -- Type of plant
      GrowthPercentToAdd = 0.01, -- How much percent from 0.0 to 1.0 plant will grow every "Config.GlobalTickRate". If Plant is growing in zone, then it grow GrowthPercentToAdd * Zone.GrowthRate percents
      FoodPercentToRemove = 0.25,  -- How much percent from 0.0 to 1.0 plant will consume food every "Config.GlobalTickRate". If Plant is growing in zone, then it consume food "FoodPercentToAdd * Zone.GrowthRate" percents
      WaterPercentToRemove = 0.02, -- How much percent from 0.0 to 1.0 plant will consume water every "Config.GlobalTickRate" If Plant is growing in zone, then it consume water "FoodPercentToAdd * Zone.GrowthRate" percents
      QualityPercentToAdd = 0.05, -- How much percent from 0.0 to 1.0 plant will consume water every "Config.GlobalTickRate" If Plant is growing in zone, then it add/remove quality "QualityPercentToAdd * Zone.GrowthRate" percents
      MinimumWaterForQuality = 20,
      PlantType = 'apple', -- Choose plant types from (plant1, plant2, small_plant) also you can change plants yourself in main/client.lua line: 2
      Produce = 'apple', -- Item the plant is going to produce when harvested
      Amount = 45, -- The max amount you can harvest from the plant
      MaxDeathTimer = 25,
      PlantModelSizes = {
        small = {model = `small_tree`, offsetZ = -1.0 },
        medium = {model = `medium_tree`, offsetZ = -1.0 },
        large = {model = `large_tree`, offsetZ = -1.0 },
        finished = {model = `finished_tree`, offsetZ = -1.0 },
      },
      UsableItems = {
        ["wateringcan"] = {
          {increaseType = "water", amount = 25.0, min = 0, max = 100.0},
          {increaseType = "quality", amount = -0.5, min = 0, max = 100.0}
        },
        ["purifiedwater"] = {
          {increaseType = "water", amount = 40.0, min = 0, max = 100.0}
        },
        ["lowgradefert"] = {
          {increaseType = "rate", amount = 2, min = 0, max = 30.0}
        },
        ["highgradefert"] = {
          {increaseType = "rate", amount = 4, min = 0, max = 50.0}
        },
      },
    },
    ['orange_seed'] = {
      Label = 'Apelsino sodinukas', --
      Type = 'orange', -- Type of plant
      GrowthPercentToAdd = 0.01, -- How much percent from 0.0 to 1.0 plant will grow every "Config.GlobalTickRate". If Plant is growing in zone, then it grow GrowthPercentToAdd * Zone.GrowthRate percents
      FoodPercentToRemove = 0.25,  -- How much percent from 0.0 to 1.0 plant will consume food every "Config.GlobalTickRate". If Plant is growing in zone, then it consume food "FoodPercentToAdd * Zone.GrowthRate" percents
      WaterPercentToRemove = 0.02, -- How much percent from 0.0 to 1.0 plant will consume water every "Config.GlobalTickRate" If Plant is growing in zone, then it consume water "FoodPercentToAdd * Zone.GrowthRate" percents
      QualityPercentToAdd = 0.05, -- How much percent from 0.0 to 1.0 plant will consume water every "Config.GlobalTickRate" If Plant is growing in zone, then it add/remove quality "QualityPercentToAdd * Zone.GrowthRate" percents
      MinimumWaterForQuality = 20,
      PlantType = 'orange', -- Choose plant types from (plant1, plant2, small_plant) also you can change plants yourself in main/client.lua line: 2
      Produce = 'orange', -- Item the plant is going to produce when harvested
      Amount = 45, -- The max amount you can harvest from the plant
      MaxDeathTimer = 25,
      PlantModelSizes = {
        small = {model = `small_tree`, offsetZ = -1.0 },
        medium = {model = `medium_tree`, offsetZ = -1.0 },
        large = {model = `large_tree`, offsetZ = -1.0 },
        finished = {model = `prop_veg_crop_orange`, offsetZ = -1.75 },
      },
      UsableItems = {
        ["wateringcan"] = {
          {increaseType = "water", amount = 25.0, min = 0, max = 100.0},
          {increaseType = "quality", amount = -0.5, min = 0, max = 100.0}
        },
        ["purifiedwater"] = {
          {increaseType = "water", amount = 40.0, min = 0, max = 100.0}
        },
        ["lowgradefert"] = {
          {increaseType = "rate", amount = 2, min = 0, max = 30.0}
        },
        ["highgradefert"] = {
          {increaseType = "rate", amount = 4, min = 0, max = 50.0}
        },
      },
    },
    ['cabbage_seed'] = {
      Label = 'Kopūsto sėkla', --
      Type = 'cabbage', -- Type of plant
      GrowthPercentToAdd = 0.08, -- How much percent from 0.0 to 1.0 plant will grow every "Config.GlobalTickRate". If Plant is growing in zone, then it grow GrowthPercentToAdd * Zone.GrowthRate percents
      WaterPercentToRemove = 0.01, -- How much percent from 0.0 to 1.0 plant will consume water every "Config.GlobalTickRate" If Plant is growing in zone, then it consume water "FoodPercentToAdd * Zone.GrowthRate" percents
      QualityPercentToAdd = 0.03, -- How much percent from 0.0 to 1.0 plant will consume water every "Config.GlobalTickRate" If Plant is growing in zone, then it add/remove quality "QualityPercentToAdd * Zone.GrowthRate" percents
      MinimumWaterForQuality = 40,
      PlantType = 'cabbage', -- Choose plant types from (plant1, plant2, small_plant) also you can change plants yourself in main/client.lua line: 2
      Produce = 'cabbage', -- Item the plant is going to produce when harvested
      Amount = 1, -- The max amount you can harvest from the plant
      MaxDeathTimer = 30,
      PlantModelSizes = {
        --prop_plant_01b
        --prop_plant_int_01a
        --prop_plant_int_04a
        --prop_plant_paradise
        --prop_plant_paradise_b
        --prop_veg_crop_02
        --prop_veg_corn_01
        --prop_veg_crop_03_cab
        --prop_veg_crop_04_leaf
        --prop_veg_crop_03_pump
        --prop_sprink_crop_01
        --prop_veg_crop_orange
        small = {model = `potato_plant_1`, offsetZ = -1.35 },
        medium = {model = `potato_plant_1`, offsetZ = -1.2 },
        large = {model = `potato_plant_2`, offsetZ = -1.05 },
        finished = {model = `prop_veg_crop_03_cab`, offsetZ = -1.0 }
      },
      UsableItems = {
        ["wateringcan"] = {
          {increaseType = "water", amount = 25.0, min = 0, max = 100.0},
          {increaseType = "quality", amount = -0.5, min = 0, max = 100.0}
        },
        ["purifiedwater"] = {
          {increaseType = "water", amount = 40.0, min = 0, max = 100.0}
        },
        ["lowgradefert"] = {
          {increaseType = "rate", amount = 2, min = 0, max = 30.0}
        },
        ["highgradefert"] = {
          {increaseType = "rate", amount = 4, min = 0, max = 50.0}
        },
      },
    },
    ['pumpkin_seed'] = {
      Label = 'Moliūgo sėkla', --
      Type = 'pumpkin', -- Type of plant
      GrowthPercentToAdd = 0.08, -- How much percent from 0.0 to 1.0 plant will grow every "Config.GlobalTickRate". If Plant is growing in zone, then it grow GrowthPercentToAdd * Zone.GrowthRate percents
      WaterPercentToRemove = 0.04, -- How much percent from 0.0 to 1.0 plant will consume water every "Config.GlobalTickRate" If Plant is growing in zone, then it consume water "FoodPercentToAdd * Zone.GrowthRate" percents
      QualityPercentToAdd = 0.04, -- How much percent from 0.0 to 1.0 plant will consume water every "Config.GlobalTickRate" If Plant is growing in zone, then it add/remove quality "QualityPercentToAdd * Zone.GrowthRate" percents
      MinimumWaterForQuality = 20,
      PlantType = 'pumpkin', -- Choose plant types from (plant1, plant2, small_plant) also you can change plants yourself in main/client.lua line: 2
      Produce = 'pumpkin', -- Item the plant is going to produce when harvested
      Amount = 1, -- The max amount you can harvest from the plant
      MaxDeathTimer = 30,
      PlantModelSizes = {
        --prop_plant_01b
        --prop_plant_int_01a
        --prop_plant_int_04a
        --prop_plant_paradise
        --prop_plant_paradise_b
        --prop_veg_crop_02
        --prop_veg_corn_01
        --prop_veg_crop_03_cab
        --prop_veg_crop_04_leaf
        --prop_veg_crop_03_pump
        --prop_sprink_crop_01
        --prop_veg_crop_orange
        small = {model = `potato_plant_1`, offsetZ = -1.35 },
        medium = {model = `potato_plant_1`, offsetZ = -1.2 },
        large = {model = `potato_plant_2`, offsetZ = -1.05 },
        finished = {model = `prop_veg_crop_03_pump`, offsetZ = -1.0 }
        -- small = {model = `prop_plant_int_04a`, offsetZ = -1.54 },
        -- medium = {model = `prop_plant_int_04a`, offsetZ = -1.1 },
        -- large = {model = `prop_veg_crop_04_leaf`, offsetZ = -1.0 },
        -- finished = {model = `prop_veg_crop_03_pump`, offsetZ = -1.9 }
      },
      UsableItems = {
        ["wateringcan"] = {
          {increaseType = "water", amount = 25.0, min = 0, max = 100.0},
          {increaseType = "quality", amount = -0.5, min = 0, max = 100.0}
        },
        ["purifiedwater"] = {
          {increaseType = "water", amount = 40.0, min = 0, max = 100.0}
        },
        ["lowgradefert"] = {
          {increaseType = "rate", amount = 2, min = 0, max = 30.0}
        },
        ["highgradefert"] = {
          {increaseType = "rate", amount = 4, min = 0, max = 50.0}
        },
      },
    },
  },
  Text = {
    ['planted'] = 'Seed was planted!',
    ['feed'] = 'Plant was fed!',
    ['water'] = 'Plant was watered!',
    ['destroy'] = 'Plant was destroyed!',
    ['harvest'] = 'You harvested the plant!',
    ['cant_plant'] = 'Klaida! Negalima pasodinti augalo',
    ['processing_table_holo'] = '~r~E~w~  Processing Table',
    ['cant_hold'] = 'You dont have space for this item!',
    ['missing_ingrediants'] = 'You dont have these ingrediants',
    ['dealer_holo'] = '[~g~E~s~] ~s~Parduoti ~g~produktus~s~',
    ['dealer_holo_buy'] = '[~b~G~s~] Pirkti ~b~produktus~s~',
    ['plant_not_found'] = "Plant not found",
    ['E_TO_HARVEST'] = "[~b~E~s~] Nurinkti",
    ['G_TO_HARVEST'] = "[~b~G~s~] Nurinkti",
    ['E_TO_DESTROY'] = "[~r~E~s~] Sunaikinti",
    ['E_TO_DRY'] = "[~r~E~s~] Džiovinti",
    ["plant_already_at_max"] = "Pasiekta maksimali reikšmė. Bandykite vėliau",
    ["one_price"] = "%s - x%s. Vieneto kaina: %s€",
    ["one_price2"] = "%s. Vieneto kaina: %s€",
    ["dealear_leaving"] = "Pardavėjas išvyksta už %s minučių. Paskubėk!",
    ["dealear_leaving_seconds"] = "Pardavėjas išvyksta už %s sekundžių. Paskubėk!",
    ["dealear_closing"] = "Pardavėjas užsidaro už %s minučių. Paskubėk!",
    ["dealear_closing_seconds"] = "Pardavėjas užsidaro už %s sekundžių. Paskubėk!",
    ["dealer_sell_name"] = "Pasirink produktą pardavimui",
    ["dealer_sell_quantity"] = "Įveskite kiekį",
    ["dealer_sell_wrong_quantity"] = "Nurodytas blogas kiekas",
    ["dealer_selling_products"] = "Parduodami produktai",
    ["dealer_sell_nothing"] = "Tu neturi ką parduoti!",
    ["dealer_buy_name"] = "Pasirinkite produktą, kurį norite įsigyti",
    ["dealer_buying_products"] = "Perkami produktai",
    ["dealer_has_nothing_to_sell"] = "Šis pardavėjas neturi ką parduoti",
    ["plant_dying"] = "~r~ Augalas miršta!",
    ["harvesting_1"] = "Nurenkamas derlius [1/2]",
    ["harvesting_2"] = "Nurenkamas derlius [2/2]",
    ["dries_yield_units"] = "~y~ Dries ~s~%s /%s ~g~%s ~s~ | ~p~ Yield ~s~:%s units.",
    ["yield"] = "~p~ Yield: ~s~%s ~g~%s ~s~",
    ["leaves"] = "Prefabricated leaves",
    ["choose_plant"] = "Choose a plant",
    ["choose_quantity_max"] = "Enter quantity (max:%s)",
    ["attaching_leaves"] = "Attaching leaves",
    ["no_req_prods"] = "No don't have required products",
    ["empty"] = "~y~ Empty",
    ["planting_plant"] = "Planting plant",
    ["error"] = "Įvyko klaida.",
    ['error_not_enough_items'] = "Klaida. Neturite pakankamai produktų inventoriuje",
    ['error_wrong_items_or_cant_add'] = "Klaida. Neteisingi daiktai",
    ['error_inventory_full'] = "Klaida. Jūsų inventorius pilnas",
    ['error_not_enough_money'] = "Klaida. Jums nepakanka pinigų",
    
    ["soil_quality"] = "Žemės kokybė: ",
    ['Water'] = "Vanduo: ",
    ['Growth'] = "Užaugo: ",
    ["EstimatedGrowthTime"] = "Likęs augimo laikas: ",
    ['plant_quality'] = "Augalo kokybė: ",
    ['Worst'] = "Blogiausia",
    ['Bad'] = "Bloga",
    ['Not_Bad'] = "Nebloga",
    ['Average'] = "Patenkinama",
    ['Good'] = "Gera",
    ['Best'] = "Geriausia",
  },
  DryingRandomness = true, -- Randomize drying produced items
  DryingRandomValues = {negative = -2, positive = 4}, -- Randomize drying produced items, give in addition random value between these values
  Drying = {
    ["spot1"] = {
      coords = vector3(1033.2791,-3207.7979,-38.1868),
      rate = 10, -- every GlobalTickRate how many leaves will dry
      max = 100,
      rawCount = 0, --dont touch
      driedCount = 0, --dont touch
      itemName = nil, --dont touch
      itemLabel = nil, --dont touch
      exclusives = {"meta"}, -- what can be dried here, DONT FORGET to add what it produces below
      produces = {
        ['meta'] = "dziovinta_meta", -- meta gives dziovinta_meta
      },
    }
  }
}

-- Only change if you know what are you doing!
function SendTextMessage(msg, type)

    -- SetNotificationTextEntry('STRING')
    -- AddTextComponentString(msg)
    -- DrawNotification(0, 1)
    ESX.ShowNotification(msg, type)
end


GetGrowTime = function (plantType, zoneId)
  if zoneId == nil then
    local growthEveryTick = Config.Plants[plantType].GrowthPercentToAdd * 50
    local growthTickCount = math.ceil(100/growthEveryTick)
    local totalAmountOfSeconds = math.floor(growthTickCount*Config.GlobalTickRate)
    local totalAmountOfMinutes = math.floor(totalAmountOfSeconds / 60.0)
    local totalAmountOfHours = (totalAmountOfMinutes / 60.0)
    print(("Total growth time in hours: %s, or in minutes: %s, total seconds: %s"):format(totalAmountOfHours, totalAmountOfMinutes, totalAmountOfSeconds))
    local waterEveryTick = Config.Plants[plantType].WaterPercentToRemove *  50
    local waterTickCount = math.ceil(100/waterEveryTick)
    totalAmountOfSeconds =  math.floor(waterTickCount*Config.GlobalTickRate)
    totalAmountOfMinutes = math.floor(totalAmountOfSeconds / 60.0)
    totalAmountOfHours = (totalAmountOfMinutes / 60.0)
    print(("Plant will need water in hours: %s or in minutes: %s"):format(totalAmountOfHours, totalAmountOfMinutes))
    local foodEveryTick = Config.Plants[plantType].FoodPercentToRemove * 50
    local foodTickCount = math.ceil(100/foodEveryTick)
    totalAmountOfSeconds =  math.floor(foodTickCount*Config.GlobalTickRate)
    totalAmountOfMinutes = math.floor(totalAmountOfSeconds / 60.0)
    totalAmountOfHours = (totalAmountOfMinutes / 60.0)
    print(("Plant will need food in hours: %s, or in minutes: %s"):format(totalAmountOfHours, totalAmountOfMinutes))
  end
  return "Not implemented"
end

GetPlantByType = function (plantType)
  if Config.Plants[plantType] == nil then ESX.Trace(("^Plant type \"^6%s^1\" not found in Config.Plants table. ^4Check key"):format(plantType)) return nil end
  return Config.Plants[plantType]
end

GetDealerByKey = function (dealerKey)
  if Config.Dealers[dealerKey] == nil then ESX.Trace(("^3Dealer \"^6%s^1\" not found in Config.Dealers table. ^4Check key"):format(dealerKey)) return nil end
  return Config.Dealers[dealerKey]
end
GetDealersCount = function()
  local count = 0
  for _,_ in pairs (Config.Dealers) do
    count += 1
  end
  return count
end



