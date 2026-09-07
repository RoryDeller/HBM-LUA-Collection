local component = require("component")
local event = require("event")
local computer = require("computer") 

local valve = component.ntm_fluid_counter_valve
local Turbo_power = 616000
local Turbo_buffer_power = 185800000
local BUFFER_BURN_TIME = 300 

local New_headroom = 0
local Is_burning = false
local Start_count = 0
local threshold = 0
local last_close_time = 0 -- Tracks when the valve last shut

component.modem.open(42)

while true do
    local _,_,_,_,_, energy, max_energy = event.pull("modem")
    local headroom = max_energy - energy
    local current_time = computer.uptime()

    -- State open when demand exceeds buffer and last cycle is done
    if Is_burning == false and energy < (max_energy - Turbo_buffer_power) and (current_time - last_close_time) > BUFFER_BURN_TIME then
        valve.setState(1)
        New_headroom = headroom - Turbo_buffer_power
        Is_burning = true
        Start_count = valve.getCounter() / 10000
        print("Buffer is free - Valve opening at: " .. energy .."/" .. max_energy) 
    end

   
    if Is_burning == true then
        threshold = valve.getCounter() / 10000
        
        if (threshold - Start_count) * Turbo_power > New_headroom then
            valve.setState(0)
            Is_burning = false
            last_close_time = computer.uptime()
            print("Start Time:"..Start_count.." End Time:"..threshold.." * "..Turbo_power.."HE/T")
            print("Valve closing. Entering 5-minute buffer burn phase...")
        end
    end
end