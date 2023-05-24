Config.Dealers = {
  ["FruitsPed"] = {
    PedModel = 'u_m_m_bikehire_01',
    Locations = {
      vector4(163.8197,6633.2573,31.5882, 144.56),
      vector4(159.2703,6639.2836,31.5714, 130.73)
    },
    Prices = {
        ['pumpkin'] = 3, -- Item name and price for 1
        ['cabbage'] = 3,  -- Item name and price for 1
        ['tomato'] = 1,  -- Item name and price for 1
        ['apple'] = 2,  -- Item name and price for 1
        ['orange'] = 2,  -- Item name and price for 1
    },
    Sells = {
        ['pumpkin_seed'] = 1,
        ['tomato_seed'] = 1,
        ['cabbage_seed'] = 1,
        ['orange_seed'] = 1,
        ['apple_seed'] = 1,
        ['purified_water'] = 8,
        ['wateringcan'] = 3,
        ['lowgradefert'] = 10,
        ['highgradefert'] = 15
    },
    Labels = {  --Add your own translation for each item you want to sell or buy
        ['potato'] = "Bulvė",
        ['cucumber'] = "Agurkas",
        ['pumpkin'] = "Moliūgas",
        ['pumpkin_seed'] = "Moliūgo sėkla",
        ['cucumber_seed'] = "Agurko sėkla",
        ['purified_water'] = "Purified Water",
        ['wateringcan'] = "Vandens laistytuvas",
        ['lowgradefert'] = "Low Grade Fertilizer",
        ['highgradefert'] = "High Grade Fertilizer"
    },
    Sold = {}, --DONT CHANGE
    Availability = {
      {hourFrom = -1, hourTo = 0, weekDay= "everyday"}, -- first dealer available everyday from 17:00 to 23:59
      {hourFrom = 1, hourTo = 5, weekDay= "friday"}, -- first dealer available exclusively on friday from 01:00 to 4:49
    },
    scenario = nil, -- TO_DO
    animDict = nil, -- TO_DO
    animName = nil, -- TO_DO
  },
}

Config.DealerTicksToChangeLocaltion = 10 --Time = GlobalTickRate*20 -> 30*120 = 60 minutes

Dealer = {
    tick = 0, --DONT CHANGE
    locations = {}, --DONT CHANGE
    availability = {}, --DONT CHANGE
    locationIndex = 1, --DONT CHANGE
    currentLocation = nil --DONT CHANGE
}
local Utils = {}
function Dealer:getTick()
    return self.tick
end

function Dealer:incrementTick()
    self.tick += 1
    return self.tick
end

function Dealer:resetTick()
    self.tick = 0
    return self.tick
end

function Dealer:generateNewLocation()
    local currentIndex = self.locationIndex
    local nextIndex = #self.locations == 1 and 1 or math.random(1,#self.locations)
    if #self.locations > 1 and currentIndex == nextIndex then
        return Dealer.generateNewLocation(self)
    end
    self.locationIndex = nextIndex
    self.currentLocation = self.locations[self.locationIndex]
    Dealer.resetTick(self)
    return self.locationIndex, self.currentLocation
end

function Dealer:getCurrentLocationIndex()
    return self.locationIndex
end

function Dealer:getCurrentLocation()
    return self.currentLocation
end

function Dealer:getDealerKey()
    return self.dealerKey
end

function Dealer:IsAvailable()
    local currentWeekDay, currentHour, currentMinutes = Utils:GetCurrentWeekDayAndTime()
    for i=1, #self.availability, 1 do
        local currentValue = self.availability[i]
        local weekDay = (currentValue.weekDay or "everyday"):lower()
        local hourFrom = currentValue.hourFrom or 23
        local hourTo = (currentValue.hourTo == nil or currentValue.hourTo == 0) and 24 or currentValue.hourTo
        if currentHour >= hourFrom and currentHour < hourTo then
            if weekDay == "everyday" or currentWeekDay == weekDay then
                local remainingMinutes = (hourTo - (currentHour + 1)) * 60 + 60 - currentMinutes
                return true,remainingMinutes
            end
        end
    end
    return false, -1
end

function Dealer:GetPrice(itemName, itemCount)
    if itemCount <= 0 then
        return 0
    end
    return self.prices[itemName] * itemCount
end

function Dealer:GetSellPrice(itemName, itemCount)
    if itemCount <= 0 then
        return 0
    end
    return self.sells[itemName] * itemCount
end

function Dealer:AddSoldByPlayer(identifier,itemName,itemCount)
    self.Sold.Player = self.Sold.Player or {}
    self.Sold.Player[identifier] = self.Sold.Player[identifier] or {}
    self.Sold.Player[identifier][itemName] = (self.Sold.Player[identifier][itemName] or 0) + itemCount
end
function Dealer:AddSoldToTotal(itemName,itemCount)
    self.Sold.Total =  self.Sold.Total or {}
    self.Sold.Total[itemName] = self.Sold.Total[itemName] or 0
    self.Sold.Total[itemName] += itemCount
end

function Dealer:AddSold(identifier, itemName, itemCount)
    identifier = identifier or "unknown"
    itemName = itemName or "unknown"
    itemCount = itemCount or 0
    self.Sold = self.Sold or {}
    Dealer.AddSoldByPlayer(self,identifier,itemName,itemCount)
    Dealer.AddSoldToTotal(self, itemName,itemCount)
end


function Dealer:GetSold()
    return self.Sold
end

function Dealer:GetSoldAsString()
    if self.Sold then
        local totalSoldText = ""
        for k,v in pairs(self.Sold.Total) do
            totalSoldText = ("%s\n\t\tItem: %s, amount: %s"):format(totalSoldText,k,v)
        end
        local playersSoldText = ""
        for k,v in pairs(self.Sold.Player) do
            playersSoldText = ("%s\n\t\tPlayer: %s"):format(playersSoldText,k)
            for k2,v2 in pairs(v) do
                playersSoldText = ("%s\n\t\t\t item: %s, amount: %s"):format(playersSoldText,k2,v2)
            end
        end
        local message = ("Dealer key: %s. Info:\n\tTotals: %s\n\tBy identifiers:%s\n"):format(self.dealerKey, totalSoldText,playersSoldText)
        return message
    else
        return ("Dealer key: %s has no information about solds"):format(self.dealerKey)
    end
end

function Dealer:GetSoldByIdentifier(identifier)
    return self.Sold.Player[identifier]
end

function Dealer:GetSoldTotal(optional_itemName)
    return optional_itemName and self.Sold.Total[optional_itemName] or self.Sold.Total
end

function Dealer:AddBuysByPlayer(identifier,itemName,itemCount)
    self.Buys.Player = self.Buys.Player or {}
    self.Buys.Player[identifier] = self.Buys.Player[identifier] or {}
    self.Buys.Player[identifier][itemName] = (self.Buys.Player[identifier][itemName] or 0) + itemCount
end

function Dealer:AddBuysToTotal(itemName,itemCount)
    self.Buys.Total =  self.Buys.Total or {}
    self.Buys.Total[itemName] = self.Buys.Total[itemName] or 0
    self.Buys.Total[itemName] += itemCount
end

function Dealer:AddBuys(identifier, itemName, itemCount)
    identifier = identifier or "unknown"
    itemName = itemName or "unknown"
    itemCount = itemCount or 0
    self.Buys = self.Buys or {}
    Dealer.AddBuysByPlayer(self,identifier,itemName,itemCount)
    Dealer.AddBuysToTotal(self, itemName,itemCount)
end


function Dealer:GetBuys()
    return self.Buys
end

function Dealer:GetBuysAsString()
    if self.Buys then
        local totalBuysText = ""
        for k,v in pairs(self.Buys.Total) do
            totalBuysText = ("%s\n\t\tItem: %s, amount: %s"):format(totalBuysText,k,v)
        end
        local playersBuysText = ""
        for k,v in pairs(self.Buys.Player) do
            playersBuysText = ("%s\n\t\tPlayer: %s"):format(playersBuysText,k)
            for k2,v2 in pairs(v) do
                playersBuysText = ("%s\n\t\t\t item: %s, amount: %s"):format(playersBuysText,k2,v2)
            end
        end
        local message = ("Dealer key: %s. Info:\n\tTotals: %s\n\tBy identifiers:%s\n"):format(self.dealerKey, totalBuysText,playersBuysText)
        return message
    else
        return ("Dealer key: %s has no information about Buys"):format(self.dealerKey)
    end
end

function Dealer:GetBuysByIdentifier(identifier)
    return self.Buys.Player[identifier]
end

function Dealer:GetBuysTotal(optional_itemName)
    return optional_itemName and self.Buys.Total[optional_itemName] or self.Buys.Total
end

function Dealer:toString()
    local isDealerAvailable, remainingMinutes = Dealer.IsAvailable(self)
    if  isDealerAvailable then
        return ("Dealer key: %s, Tick count: %s,is Dealer available: %s, Dealer available for: %s minutes, Dealer location: %s"):format(self.dealerKey,Dealer.getTick(self), isDealerAvailable, remainingMinutes,Dealer.getCurrentLocation(self))
    else
        return ("Dealer key: %s, Tick count: %s,is Dealer available: %s, Dealer location: %s"):format(self.dealerKey,Dealer.getTick(self), isDealerAvailable ,Dealer.getCurrentLocation(self))
    end
end

function Dealer:getMinimalInfo()
    local minimalInfo =  {
        currentLocation = self.currentLocation,
        tick = self.tick,
        dealerKey = self.dealerKey,
        prices = self.prices,
        sells = self.sells,
        pedModel = self.PedModel,
        labels = self.labels,
        animDict = self.animDict or nil,
        animName = self.animName or nil,
        scenario = self.scenario or nil,
        maxTicks = Config.DealerTicksToChangeLocaltion,
    }
    minimalInfo.isAvailable, minimalInfo.remainingTime = Dealer.IsAvailable(self)
    return minimalInfo
end
Dealer.__index = Dealer
function Dealer:new (dealerKey)
    if not GetDealerByKey(dealerKey) then return nil end
    local this = {
        dealerKey = dealerKey,
        locations = Config.Dealers[dealerKey].Locations,
        prices = Config.Dealers[dealerKey].Prices or nil,
        sells = Config.Dealers[dealerKey].Sells or nil,
        labels = Config.Dealers[dealerKey].Labels or {},
        availability =  Config.Dealers[dealerKey].Availability,
        PedModel =  Config.Dealers[dealerKey].PedModel,
    }
    
    Dealer.generateNewLocation(this)
    setmetatable(this, Dealer)
    return this
end

Dealers = {}
function Dealers:Init()
    local dealersInfo = {}
    for k in pairs(Config.Dealers) do
        self[k] = Dealer:new(k)
    end
    TriggerClientEvent("plantz:update", -1, dealersInfo)
    function self.Tick(cb)
        for k, v in pairs(self) do
            if type(v) == "table" and Config.Dealers[k] then
                if v:IsAvailable() then
                    v:incrementTick()
                    if v:getTick() > Config.DealerTicksToChangeLocaltion then
                        v:generateNewLocation()
                    end
                end
                dealersInfo[k] = v:getMinimalInfo()
            end
        end
        TriggerClientEvent("plantz:update", -1, dealersInfo)
        if type(cb) == "function" then
            cb()
        end
    end
    function self.GetDealers(minimal)
        minimal = minimal == true
        local dealers = {}
        for k, v in pairs(self) do
            if type(v) == "table" and Config.Dealers[k] then
                if minimal then
                    dealersInfo[k] = v:getMinimalInfo()
                else
                    dealers[k] = self.GetDealer(k)
                end
            end
        end
        if minimal then
            return dealersInfo
        else
            return dealers
        end
    end
    function self.GetDealer(dealerKey)
        return self[dealerKey]
    end
    function self.SendSoldInfo()
        for _,v in pairs(self.GetDealers(false)) do
            Trace(v:GetSoldAsString())
        end
    end
    function self.SendBuysInfo()
        for _,v in pairs(self.GetDealers(false)) do
            Trace(v:GetBuysAsString())
        end
    end

    function self.SendInfos()
        self.SendSoldInfo()
        self.SendBuysInfo()
    end
end

RegisterServerEvent("plantz:sell",function(dealerKey, itemName, count)
    local xPlayer = ESX.GetPlayerFromId(source)
    local dealer = Dealers.GetDealer(dealerKey)
    if dealer and dealer.prices[itemName] and Utils:IsPlayerNearCoords(source,dealer:getCurrentLocation()) then
        local xItem = xPlayer.getInventoryItem(itemName)
        if xItem and xItem.count >= count then
            xPlayer.removeInventoryItem(itemName, count)
            xPlayer.addAccountMoney("money", dealer:GetPrice(itemName, count))
            dealer:AddSold(xPlayer.identifier,itemName,count)
        else
            xPlayer.showNotification(Config.Text["error_not_enough_items"], 'error')
        end
    else
        xPlayer.showNotification(Config.Text["error"], 'error')

    end
end)

RegisterServerEvent("plantz:buy",function(dealerKey, itemName, count)
    local xPlayer = ESX.GetPlayerFromId(source)
    local dealer = Dealers.GetDealer(dealerKey)
    if dealer and dealer.sells[itemName] and Utils:IsPlayerNearCoords(source,dealer:getCurrentLocation()) then
        
        if xPlayer.getAccount('money').money >= dealer:GetSellPrice(itemName, count) then
            if xPlayer.canCarryItem(itemName, count) then
                xPlayer.removeAccountMoney('money', dealer:GetSellPrice(itemName, count))
                xPlayer.addInventoryItem(itemName, count)
                dealer:AddBuys(xPlayer.identifier,itemName,count)

            else
                xPlayer.showNotification(Config.Text["error_inventory_full"], 'error')
            end
        else
            xPlayer.showNotification(Config.Text["error_not_enough_money"], 'error')
        end
    else
        xPlayer.showNotification(Config.Text["error"], 'error')
    end
end)



--Utils
function Utils:GetCurrentWeekDayAndTime()
    local currentWeekDay = os.date("%A"):lower()
    local currentHour = tonumber(os.date("%H"))
    local currentMinutes = tonumber(os.date("%M"))
    return currentWeekDay, currentHour, currentMinutes
end

function Utils:IsPlayerNearCoords(source,coords, distance)
    distance = distance or 10.0
    local ped = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(ped)
    if #(playerCoords.xyz - coords.xyz) < distance then
        return true
    else
        return false
    end
end

--Dealer commands

ESX.RegisterCommand('dealerDebug', 'admin', function()
	for _,v in pairs(Dealers.GetDealers(false)) do
        Trace(v:toString(),true)
    end
end, true, {help = "Print debug text to console"})

ESX.RegisterCommand('dealerSales', 'admin', function()
	for _,v in pairs(Dealers.GetDealers(false)) do
        Trace("-----^3Dealers sales^7----")
        Trace(v:GetSoldAsString(), true)
        Trace("-----^3Dealers boughts^7----")
        Trace(v:GetBuysAsString(), true)
    end
end, true, {help = "Print debug text to console"})