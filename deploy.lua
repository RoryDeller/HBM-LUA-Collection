local internet = require("internet")
local term = require("term")

local result, err = internet.request("http://127.0.0.1:8080")
if not result then
    print("Connection failed: " .. tostring(err))
    return
end

local response = ""
for chunk in result do
    response = response .. chunk
end

-- Compile the incoming code
local code, load_err = load(response)
if not code then
    print("Compile Error: " .. tostring(load_err))
    return
end

-- Run the code and catch any crashes
local success, run_err = pcall(code)
if not success then
    print("Runtime Error inside code: " .. tostring(run_err))
end