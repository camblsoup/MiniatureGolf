-- test_client_2.lua
local socket = require("socket")

print(" CLIENT 2 STARTING ")
print("Trying to connect to server...")

local client = socket.connect("localhost", 12345)

if client then
    print("SUCCESS: Client 2 connected to Love2D server!")
    
    client:send("HELLO FROM CLIENT 2\n")
    print("Sent: HELLO FROM CLIENT 2")

    local response, err = client:receive()
    if response then
        print("Client 2 received:", response)
    else
        print("Client 2: No response received")
    end
    

    client:send("TEST MESSAGE FROM CLIENT 2\n")
    print("Sent: TEST MESSAGE FROM CLIENT 2")

    local echo, err = client:receive()
    if echo then
        print("Client 2 received echo:", echo)
    else
        print("Client 2: No echo received")
    end
    
    client:close()
    print("Client 2 disconnected")
else
    print("FAILED: Client 2 could not connect to server")
end

print("=== CLIENT 2 FINISHED ===")
