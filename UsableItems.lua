
-- SEED USABLE ITEM REGISTER
-- Register every seed only changing the name of it between ''


ESX.RegisterUsableItem('pumpkin_seed', function(playerId)
	plant(playerId, 'pumpkin_seed')
end)

ESX.RegisterUsableItem('cucumber_seed', function(playerId)
	plant(playerId, 'cucumber_seed')
end)

ESX.RegisterUsableItem('tomato_seed', function(playerId)
	plant(playerId, 'tomato_seed')
end)

ESX.RegisterUsableItem('apple_seed', function(playerId)
	plant(playerId, 'apple_seed')
end)

ESX.RegisterUsableItem('orange_seed', function(playerId)
	plant(playerId, 'orange_seed')
end)

ESX.RegisterUsableItem('cabbage_seed', function(playerId)
	plant(playerId, 'cabbage_seed')
end)




-- PLANTS USABLE ITEM REGISTER
-- Register every ITEM only changing the name of it between ''

ESX.RegisterUsableItem('wateringcan', function(source)
	TriggerClientEvent('plantz:UseItem',source,"wateringcan", 'Laistomas augalas', 5000)
end)

ESX.RegisterUsableItem('purifiedwater', function(source)
	TriggerClientEvent('plantz:UseItem',source,"purifiedwater", 'Laistomas augalas', 5000)
end)

ESX.RegisterUsableItem('lowgradefert', function(source)
	TriggerClientEvent('plantz:UseItem',source,"lowgradefert", 'Tręšiamas augalas', 5000)
end)

ESX.RegisterUsableItem('highgradefert', function(source)
	TriggerClientEvent('plantz:UseItem',source,"highgradefert", 'Tręšiamas augalas', 5000)
end)

