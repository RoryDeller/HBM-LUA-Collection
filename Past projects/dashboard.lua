
local component = require("component")
local event = require("event")
local term = require("term")

local gpu = component.gpu
local w, h = gpu.getResolution()
local modem = component.modem
modem.open(42)

 
local function drawLine(x, y, width, current, max)
	local  ratio = current / max
	local filled = math.floor(ratio * width)
	
	gpu.setBackground(0x000000)
	gpu.setForeground(0xFFFFFF)
	gpu.fill(x, y, width, 1, "-")
	
	gpu.setBackground(0x000000)
	gpu.setForeground(0xFFFFFF)
	gpu.fill(x, y, filled, 1, "#")
end

term.clear()

while true do
	
	
	local _,_,_,_,_, pull_energy, pull_max_energy, pull_throughput = event.pull("modem_message")
	
	local function printLine(y, text)
            term.setCursor(1, y)
            term.clearLine() 
            print(text)
        end
	
	if pull_energy and  pull_max_energy and pull_throughput ~= nil then
		drawLine(1, 2, 20, pull_energy, pull_max_energy)
		term.setCursor(1, 3)
		printLine(3, "Current energy total: " .. pull_energy)
		printLine(4, "Current energy storage: ".. pull_max_energy)
		printLine(5, "Current energy useage per tick: ".. pull_throughput)
		
		if pull_throughput < 0 then
			local time_left = math.floor(pull_energy / (pull_throughput * -1))
			printLine(6, "Hours left until discharge: ".. math.floor(time_left / 60^2 ))
		else
			term.setCursor(1, 6)
			term.clearLine()
		
		end
	end
end

