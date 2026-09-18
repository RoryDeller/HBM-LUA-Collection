local component = require("component")
local event = require("event")

local gpu = component.gpu
local Pgauge = component.ntm_power_gauge
local Sgauge = component.ntm_fluid_gauge
local PWR = component.ntm_pwr_control 
local flux
local Y
local X
local TU
local totalFuel

function getFuelData() -- 3 indexes 1: Fuel count, 2: Fuel depletion, 3: Max Depletion
    local fuelTable = {PWR.getFuelInfo()}
    return fuelTable
end 

function fluxDecay(fuelData)
    local rods = fuelData[1]
    local depletion = fuelData[2]
    local maxDepletion = fuelData[3]
    local percent = (depletion / maxDepletion) * 100  --Percentage of current fuel rod depleted of flux
    local instance = flux / rods                
    local stat = instance * (percent/100)
    return stat, percent
end

function getReactionInput(Y) --Parabola input in collisions, seperate page graph entirely
    local x = (1/625)*Y^2
    return x
end

while true do
    flux = PWR.getFlux() 
    TU = flux * 7.5
    local fuelInfo = getFuelData()
    local snapshot, depletion = fluxDecay(getFuelData())
    totalFuel = fuelInfo[1] - (depletion / 100)
    Y = flux - snapshot
    X = getReactionInput(Y) 
    print("Current flux redacted " .. math.floor(snapshot) .. "     At " .. math.floor(depletion) .. "%" .. "     Totalling fuel at " .. totalFuel)
    print(" Rods Remaining: " .. fuelInfo[1] .. "     Dial flux: " .. math.floor(flux) .. "     Actual flux: " .. math.floor(Y))
    print(" Input flux during reactivity " .. X)
    os.sleep(15)
end


function drawYX() 

end


function drawOutput() --y height for both pages from 1-30 px

end


function drawDials() -- y height 30-40 px

end

function drawControl() -- y height 40-50 px, with touch screen buttons

end