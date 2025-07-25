-- simple_test.lua
local socket = require("socket")

print("Trying to connect...")
local client = socket.connect("localhost", 12345)
if client then
    print("SUCCESS: Connected to server!")
    client:send("TEST\n")
    print("SUCCESS: Sent test message!")
    client:close()
else
    print("FAILED: Could not connect to server")
end
