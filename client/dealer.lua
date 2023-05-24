Dealers = {}
DealersToLoad = {}
DealerPeds = {}
local warned = false
RegisterNetEvent("plantz:update", function(newDealersData)
    for k,v in pairs(newDealersData) do
        if DealersToLoad[k] then
            if DealersToLoad[k].currentLocation ~= v.currentLocation then
                UpdateDealerLocation(k,v.currentLocation)
            end

            if DealersToLoad[k].menuIsOpen then
                if v.tick + 2 >= v.maxTicks then
                    local remainingSeconds = (v.maxTicks + 1 - v.tick) * Config.GlobalTickRate
                    local text = Config.Text['dealear_leaving']:format(math.floor(remainingSeconds/60))
                    if remainingSeconds/60 < 1 then
                        text = Config.Text['dealear_leaving_seconds']:format(math.floor(remainingSeconds))
                    end
                    ESX.ShowNotification(text,'warning')
                end
                if v.remainingTime <= 10 then
                    ESX.ShowNotification((Config.Text['dealear_closing']):format(math.floor(v.remainingTime)),'warning')
                end
            end
        end
    end
    Dealers = newDealersData
end)
function UpdateDealerLocation(dealerKey, coords)
    if DealersToLoad[dealerKey] then
        DealersToLoad[dealerKey].currentLocation = coords
        if DealersToLoad[dealerKey].spawnedPed then
            PedFadeOut(DealersToLoad[dealerKey].spawnedPed)
            SetEntityCoords(DealersToLoad[dealerKey].spawnedPed, coords.x, coords.y, coords.z-1.0,false, false, false, true)
            SetEntityHeading(DealersToLoad[dealerKey].spawnedPed, coords.w)
            PedFadeIn(DealersToLoad[dealerKey].spawnedPed)
        end
        CloseDealerMenu(dealerKey)
    end
end

function CloseDealerMenu(dealerKey)
    local isDealerMenuOpen = ESX.UI.Menu.IsOpen('default', GetCurrentResourceName(), 'dealer_menu_'..dealerKey)
    local isDealerDialogOpen = ESX.UI.Menu.IsOpen('dialog', GetCurrentResourceName(), 'dealer_dialog_'..dealerKey)
    if isDealerMenuOpen then ESX.UI.Menu.Close('default', GetCurrentResourceName(), 'dealer_menu_'..dealerKey) end
    if isDealerDialogOpen then ESX.UI.Menu.Close('dialog', GetCurrentResourceName(), 'dealer_dialog_'..dealerKey) end
    DealersToLoad[dealerKey].menuIsOpen = false
    MenuIsOpen = false
end

--Inside a while true thread
function DealerTick(playerCoords)
    if DealersToLoad == nil then return false end
    local nearestDealerKey = GetNearestDealer(playerCoords)
    if not nearestDealerKey or not Dealers[nearestDealerKey] then
        return
    else
        local nearestDealer = Dealers[nearestDealerKey]
        local scale = GetScaleFor3DText(nearestDealer.currentLocation.xyz)
        local text = ("%s\n%s"):format(nearestDealer.prices ~= nil and Config.Text['dealer_holo'] or "", nearestDealer.sells ~= nil and Config.Text['dealer_holo_buy'] or "")
        DrawText3D(nearestDealer.currentLocation.xyz,text,scale)
        if IsControlJustPressed(0, 38) and not MenuIsOpen then
            local playerItems = GetFilteredItems(Dealers[nearestDealerKey].prices)
            local elements = {}
            for k, v in pairs (playerItems) do
                table.insert(elements, {label = (Config.Text['one_price']):format(v.label,v.count, Dealers[nearestDealerKey].prices[k]),count = v.count,dealerKey = nearestDealerKey, value=k})
            end
            if #elements > 0 then
                DealersToLoad[nearestDealerKey].menuIsOpen = true
                MenuIsOpen = true

                if nearestDealer.remainingTime <= 5 then
                    ESX.ShowNotification((Config.Text['dealear_closing']):format(nearestDealer.remainingTime), 'warning')
                end
                if nearestDealer.tick + 1 >= nearestDealer.maxTicks then
                    ESX.ShowNotification((Config.Text['dealear_leaving']):format(math.floor(Config.GlobalTickRate/60)), 'warning')
                end
                
                ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'dealer_menu_'..nearestDealerKey,
                {
                    title    = Config.Text["dealer_sell_name"],
                    align    = "top-right",
                    elements = elements
                },
                function(data, menu)
                    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'dealer_dialog_'..nearestDealerKey, {
                        title = Config.Text["dealer_sell_quantity"]
                    }, function(data2, menu2)
                        local count = tonumber(data2.value)
                        if count == nil or count <= 0 then
                            ESX.ShowNotification(Config.Text["dealer_sell_wrong_quantity"],'error')
                        else
                            menu2.close()
                            menu.close()
                            StartAnimation(false,Config.Text["dealer_selling_products"], math.floor(125 * count/2), true,nil,nil,nil,nil,function(cancelled)
                                if not cancelled then
                                    TriggerServerEvent("plantz:sell", data.current.dealerKey,data.current.value,count)
                                end
                                MenuIsOpen = false
                                DealersToLoad[nearestDealerKey].menuIsOpen = false
                            end)
                        end
                    end, function(data2, menu2)
                        menu2.close()
                    end)
                end, function(data, menu)
                    menu.close()
                    MenuIsOpen = false
                    DealersToLoad[nearestDealerKey].menuIsOpen = false
                end)
            else
                ESX.ShowNotification(Config.Text["dealer_sell_nothing"], 'error')
            end
        elseif nearestDealer.sells ~= nil and IsControlJustPressed(0, 47) and not MenuIsOpen then
            local elements = {}
            local ox_inventory_state = GetResourceState("ox_inventory")
            if ox_inventory_state ~= "started" and not warned then print('^3ox_inventory not started. This may cause bugs, however u may proceed'); warned = true end
            for k, v in pairs (nearestDealer.sells) do
                if ox_inventory_state ~= "started" then
                    table.insert(elements, 
                            {
                                label = (Config.Text['one_price2']):format(nearestDealer.labels[k], v),
                                dealerKey = nearestDealerKey,
                                value = k
                            }
                        )
                else
                    local item = exports.ox_inventory:Items(k)
                    if item then
                        table.insert(elements, 
                            {
                                label = (Config.Text['one_price2']):format(item.label, v),
                                dealerKey = nearestDealerKey,
                                value = k
                            }
                        )
                    end
                end
            end
            if next(elements) then
                DealersToLoad[nearestDealerKey].menuIsOpen = true
                MenuIsOpen = true
                ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'dealer_menu_'..nearestDealerKey,
                {
                    title    = Config.Text["dealer_buy_name"],
                    align    = "top-right",
                    elements = elements
                },function(data,menu)
                    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'dealer_dialog_'..nearestDealerKey, {
                        title = Config.Text["dealer_sell_quantity"]
                    }, function(data2, menu2)
                        local count = tonumber(data2.value)
                        if count == nil or count <= 0 then
                            ESX.ShowNotification(Config.Text["dealer_sell_wrong_quantity"],'error')
                        else
                            menu2.close()
                            menu.close()
                            StartAnimation(false,Config.Text["dealer_buying_products"], math.floor(500 * count/1.5), true,nil,nil,nil,nil,function(cancelled)
                                if not cancelled then
                                    TriggerServerEvent("plantz:buy", data.current.dealerKey,data.current.value,count)
                                end
                                MenuIsOpen = false
                                DealersToLoad[nearestDealerKey].menuIsOpen = false
                            end)
                        end
                    end, function(data2, menu2)
                        menu2.close()
                    end)
                end, function(data, menu)
                    menu.close()
                    MenuIsOpen = false
                    DealersToLoad[nearestDealerKey].menuIsOpen = false
                end)
            else
                ESX.ShowNotification(Config.Text["dealer_has_nothing_to_sell"], 'error')
            end
        end
    end
end

function DeleteDealerPed(dealerKey)
    PedFadeOut(DealersToLoad[dealerKey].spawnedPed)
    CloseDealerMenu(dealerKey)
    SetEntityAsNoLongerNeeded(DealersToLoad[dealerKey].spawnedPed)
    DeletePed(DealersToLoad[dealerKey].spawnedPed)
    DealersToLoad[dealerKey].spawnedPed = nil
end

function NearPed(model, coords, animDict, animName, scenario)
	RequestModel(model)
	while not HasModelLoaded(model) do
		Citizen.Wait(50)
	end
    local spawnedPed = CreatePed(4, model, coords.x, coords.y, coords.z - 1.0, coords.w, false, true)
	SetEntityAlpha(spawnedPed, 0, false)
    SetBlockingOfNonTemporaryEvents(spawnedPed, true)
    TaskSetBlockingOfNonTemporaryEvents(spawnedPed, 1)
    FreezeEntityPosition(spawnedPed, true)
    SetPedRandomComponentVariation(spawnedPed)
    SetPedRandomProps(spawnedPed)
    SetPedCanRagdoll(spawnedPed, true)
    SetEntityCollision(spawnedPed, 1, 0)
    SetEntityInvincible(spawnedPed, true)

	if animDict and animName then
		RequestAnimDict(animDict)
		while not HasAnimDictLoaded(animDict) do
			Citizen.Wait(50)
		end
		TaskPlayAnim(spawnedPed, animDict, animName, 8.0, 0, -1, 1, 0, 0, 0)
	end
	if scenario then
		TaskStartScenarioInPlace(spawnedPed, scenario, 0, true)
	end
    PedFadeIn(spawnedPed)
	SetEntityAsMissionEntity(spawnedPed, true, true)
	return spawnedPed
end

function PedFadeOut(spawnedPed)
    for i = 255, 0, -51 do
        Citizen.Wait(50)
        SetEntityAlpha(spawnedPed, i, false)
    end
end

function PedFadeIn(spawnedPed)
    for i = 0, 255, 51 do
        Citizen.Wait(50)
        SetEntityAlpha(spawnedPed, i, false)
    end
end