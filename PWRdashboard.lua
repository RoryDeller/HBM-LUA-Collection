local component = require("component")
local event = require("event")


local gpu = component.gpu
local Pgauge = component.ntm_power_gauge
local Sgauge = component.ntm_fluid_gauge
local PWR = component.ntm_pwr_control 
local Y, X, TU, totalFuel
local W, H = gpu.getResolution() 
local xMin, xMax = 1, 150        --Graph bounds   
local yMin, yMax = 30, 1
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


function drawGraph(maxX, maxY) 
    gpu.setForeground(0xFFFFFF)
    gpu.fill(xMin+1,yMin-1,xMin+1,yMax+1,"|")
    gpu.fill(yMin-1,xMin+1,xMax-1,yMin-1, "_") --Draw graph axis with a pixel space for marking 0,0, 0,Max and Max,0
    gpu.fill(xMin,yMin, "0")
    gpu.fill(xMin,yMax, string.char(math.floor(maxX)))
    gpu.fill(yMin,xMax, string.char(math.floor(maxY)))
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
    gpu.fill(Xplot, Yplot, "*")
end


function drawOutput() 
    totalFuel = fuelInfo[1] - (depletion / 100)
end

function drawDials() -- y height 30-40 px
end

function drawControl() -- y height 40-50 px, with touch screen buttons
end

while true do
    TU = getYFlux() * 7.5
    local fuelInfo = getFuelData()
    totalFuel = fuelInfo[1] - (depletion / 100)
end


function drawYX() 

end


function drawOutput() --y height for both pages from 1-30 px

end


function drawDials() -- y height 30-40 px

end

function drawControl() -- y height 40-50 px, with touch screen buttons

end