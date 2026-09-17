local component = require("component")
local event = require("event")

local gpu = component.gpu
local Pgauge = component.ntm_power_gauge
local Sgauge = component.ntm_fluid_gauge
local PWR = component.ntm_pwr_control 

function getFuelData() -- 3 indexes 1: Fuel count, 2: Fuel depletion, 3: Max Depletion
    local table = {}
    for item in PWR.getFuelInfo() do
        table.insert(fuelTable, item)
    end
    return table
end 

function fluxDecay(fuelData)
    local count = fuelData[1]
    local depletion = fuelData[2]
    local maxDepletion = fuelData[3]
    local decay =  1 - (depletion / maxDepletion)
    if decay == 0 then
        return nil
    else 
        local instance = totalFlux / count
        local stat = instance * decay
        return stat
    end
end

function getReactionInput(Y, D) --Placeholder for parabola involved in collisions, seperate page graph entirely
    local x = (Y/(25*D))^2
    return x
end

while true
    local Flux = PWR.getFlux() 
    local TU = totalFlux * 7.5
    local fuelInfo = getFuelData()
    local snapshot = fluxDecay(getFuelData())
    local newFlux = totalFlux - snapshot

    print("Dial flux:" .. Flux .. "Actual flux:" .. newFlux)
    print("Rods remaining:" .. fuelInfo[1] .. "Current rod depletion:" .. snapshot)
end