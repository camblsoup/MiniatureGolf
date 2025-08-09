local socket = require("socket")

print("Trying to connect to server...")
local client = socket.connect("localhost", 12345)

if client then
    print("SUCCESS: Connected to Love2D server!")
    
    -- test message
    client:send("HELLO FROM CLIENT\n")
    print("Sent: HELLO FROM CLIENT")
    
    local response, err = client:receive()
    if response then
        print("Received:", response)
    else
        print("No response received")
    end
    
    client:close()
    print("Disconnected")
else
    print("FAILED: Could not connect to server")
end
