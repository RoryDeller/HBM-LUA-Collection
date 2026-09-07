local component = require("component")
local event = require("event")
local computer = require("computer") 

local CCGT = component.ntm_gas_turbine
local Turbo_buffer_power = 185800000
local cooldown = 10
local warmup = 30
local Start_time
local state = "OFF"
component.modem.open(42)


while true do

	local _,_,_,_,_, energy, max_energy, throughput = event.pull("modem")
	local Energy_defecit = max_energy - energy
	local Current_time = computer.uptime()
	 
	--print (energy.. " " .. max_energy .. " " .. throughput)

	if state == "OFF" then
			if throughput < -3000 and Energy_defecit > Turbo_buffer_power then
					CCGT.start()
					print("Starting engine, waiting startup")
					CCGT.setAuto(true)
					print("AUTO is on")
					state = "RUNNING" -- bug if throughput goes under just as fast as it goes back on
					os.sleep(30)
			end
	end

	if state == "RUNNING" then
		if  throughput >= 370000 then
			CCGT.stop()
			print("Engine is over buffer/throughput, winding down")
			state = "COOLDOWN"
			Start_time = computer.uptime()
		end
	elseif state == "COOLDOWN" then
		if  Current_time - Start_time >= cooldown then
			state = "OFF"
			print("Engine OFF")
		end
	end
		
		
end 
