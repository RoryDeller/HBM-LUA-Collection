local component = require("component")
local event = require("event")

local valve_address = component.list("ntm_fluid_counter_valve")()
local valve = component.proxy(valve_address)
local Turbo_power = 616000
local Turbo_buffer_power = 185800000
local New_headroom = 0
local Is_burning = false
local Start_count = 0
local threshold = 0
component.modem.open(42)


while true do

	local _,_,_,_,_, energy, max_energy = event.pull("modem_message")
	local headroom = max_energy - energy
	--print(headroom ..": " .. max_energy .. "/" .. energy)
	
	if Is_burning == false and energy < (max_energy - Turbo_buffer_power) then --If energy stored is less than max storage, including a turbofan buffer
		valve.setState(1)
		New_headroom = headroom - Turbo_buffer_power
		Is_burning = true
		Start_count = valve.getCounter() / 10000
		print("Buffer is free - Valve opening at: " .. energy .."/" .. max_energy) 
	end
	
	threshold = valve.getCounter() / 10000
	
	if Is_burning == true and (threshold - Start_count) * Turbo_power > New_headroom then
		valve.setState(0)
		Is_burning = false
		print("Start Time:"..Start_count.." End Time:"..threshold.." * "..Turbo_power.."HE/T")
		print("Buffer left - Valve closing at: " .. energy .. "/" .. max_energy)
		--break
	end
end