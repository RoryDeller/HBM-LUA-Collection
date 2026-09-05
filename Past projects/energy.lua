
local component = require("component")
local sides =  require("sides")

local m = component.modem
local net = m.open(42)
local generators = component.list("ntm_combustion_engine")

while true do
	local all_sockets = component.list("ntm_energy_storage")
	local total_energy = 0
	local total_max = 0
	local total_throughput = 0
	local switch = component.redstone.getInput(sides.left)
	

	
	for address in all_sockets do
		local socket = component.proxy(address)
		local current, max, throughput = socket.getInfo()
		
		--print(current, max, socket)

		if max ~= 0 then
			total_energy = total_energy + current
			total_max = total_max + max	
			total_throughput = total_throughput + throughput
		end

	end
	
	print("Your total power is " .. total_energy)
	print("Your max energy storage is " .. total_max)
	print("Your current gain/loss of total energy is" .. " "..total_throughput.."/t")
	m.broadcast(42, total_energy, total_max, total_throughput)

	os.sleep(1)
	
		for address in generators do
		local toggle = component.proxy(address)
			if switch > 0 then
				toggle.start()
			else 
				toggle.stop()
			end
		end
end
