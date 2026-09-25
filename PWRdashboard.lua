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
local historyL = 1000
local history = {}

gpu.fill(1,1,W,H," ") --clear screen


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


function recordPlot(x,y)
    table.insert(history, {x = x, y = y})
    if #history > historyL then
        table.remove(history, 1)
    end
end


function drawGraph(maxX, maxY)
    gpu.setForeground(0xFFFFFF)
    gpu.fill(xMin+5,yMin,xMax,yMax+1," ") --reset graph area
    gpu.fill(xMin+5,yMin,1,yMax,"|")
    gpu.fill(xMin+5,yMax,xMax,1, "_") --Draw graph axis 
    gpu.fill(xMin,yMax,1,1,"0")
    gpu.set(xMax+5,31,tostring(math.floor(maxX)))
    gpu.set(xMax+5,1,tostring(math.floor(maxY)))
    gpu.fill(1,35,160,1,"=")
end


function drawXY()
    local snapshot, _ = fluxDecay(getFuelData())
    Y = getYFlux() - snapshot
    X = getReactionInputX(Y) 
    recordPlot(X,Y)
    if X > topX then
        topX = X
    end
    if Y > topY then
        topY = Y
    end
    drawGraph(topX, topY)
    gpu.setForeground(0x00FF00)
    for i, point in ipairs(history) do
        local Xplot = xMin+6+(point.x/topX * xMax) --percentage ratio according to graph bounds
        local Yplot = 1+yMax-(point.y/topY * yMax-1)
        gpu.fill(Xplot, Yplot, 1, 1, "*")
        
    end
end    

while true do 
    drawXY()
    os.sleep(0.5)
end

function drawOutput() 
    --totalFuel = fuelInfo[1] - (depletion / 100)
end

function drawDials() -- y height 30-40 px
end

function drawControl() -- y height 40-50 px, with touch screen buttons
end

