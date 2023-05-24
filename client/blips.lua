Citizen.CreateThread(
function()
    for _, v in ipairs(Config.Zones) do
        if v.Display then
            local radius = AddBlipForRadius(v.Coords[1],v.Coords[2],v.Coords[3], v.Radius)
            local radiusColor = 2
            if v.GrowthRate < 10 then
                radiusColor = 1
            elseif v.GrowthRate < 20 then
                radiusColor = 11
            elseif v.GrowthRate < 30 then
                radiusColor = 25
            elseif v.GrowthRate < 40 then
                radiusColor = 2
            else
                radiusColor = 83
            end
            SetBlipSprite(radius, 9)
            SetBlipColour(radius, radiusColor)
            SetBlipAlpha(radius, 75)
            local blip = AddBlipForCoord(v.Coords[1],v.Coords[2],v.Coords[3])

            SetBlipSprite(blip, v.DisplayBlip)
            SetBlipColour(blip, v.DisplayColor)
            SetBlipAsShortRange(blip, true)
            SetBlipScale(blip, 0.9)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(v.DisplayText)
            EndTextCommandSetBlipName(blip)
        end
    end
end
)