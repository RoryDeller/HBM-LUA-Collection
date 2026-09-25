local component = require("component")
local event = require("event")


local gpu = component.gpu
local Pgauge = component.ntm_power_gauge
local Sgauge = component.ntm_fluid_gauge
local PWR = component.ntm_pwr_control 
local Y, X, TU, totalFuel
local W, H = gpu.getResolution() 
local xMin, xMax = 1, 130        --Graph bounds  
local yMin, yMax = 1, 30
local topX, topY = 0, 0


function getFuelData() 
    local fuelTable = {PWR.getFuelInfo()}
    return fuelTable
end 


function fluxDecay(fuelData)
    local rods = fuelData[1]
    local depletion = fuelData[2]
    local maxDepletion = fuelData[3]
    local percent = (depletion / maxDepletion) * 100  
    local instance = getYFlux() / rods                
    local stat = instance * (percent/100)
    return stat, percent
end


function getReactionInputX(Y) --Parabola input in collisions
    local x = (1/625)*Y^2
    return x
end


function getYFlux()
    flux = PWR.getFlux() 
    return flux
end

function drawGraph(maxX, maxY)
    gpu.setForeground(0xFFFFFF)
    gpu.fill(1,1,W,H," ") --clear screen
    gpu.fill(xMin+5,yMin,1,yMax,"|")
    gpu.fill(xMin+5,yMax,xMax,1, "_") --Draw graph axis 
    gpu.fill(xMin,yMax,1,1,"0")
    gpu.set(xMax+2,31,tostring(math.floor(maxX)))
    gpu.set(xMax+2,1,tostring(math.floor(maxY)))
    gpu.fill(1,35,160,1,"=")
end


function drawXY()
    local snapshot, _ = fluxDecay(getFuelData())
    Y = getYFlux() - snapshot
    X = getReactionInputX(Y) 
    if X > topX then
        topX = X
    end
    if Y > topY then
        topY = Y
    end
    drawGraph(topX, topY)
    gpu.setForeground(0x000066)
    local Xplot = math.floor(X/topX) * xMax  --percentage ratio according to graph bounds
    local Yplot = math.floor(Y/topY) * yMin
    gpu.fill(Xplot, Yplot, 1, 1, "*")
end

 drawXY()

function drawOutput() 
    --totalFuel = fuelInfo[1] - (depletion / 100)
end

function drawDials() -- y height 30-40 px
end

function drawControl() -- y height 40-50 px, with touch screen buttons
end

while true do
    --TU = getYFlux() * 7.5
    --local fuelInfo = getFuelData()
    --totalFuel = fuelInfo[1] - (depletion / 100)
end



function drawOutput() --y height for both pages from 1-30 px

end


function drawDials() -- y height 30-40 px

end

function drawControl() -- y height 40-50 px, with touch screen buttons

end