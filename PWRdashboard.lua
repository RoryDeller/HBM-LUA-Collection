local component = require("component")
local event = require("event")


local gpu = component.gpu
local Pgauge = component.ntm_power_gauge
local Sgauge = component.ntm_fluid_gauge
local PWR = component.ntm_pwr_control

local total_Flux = 