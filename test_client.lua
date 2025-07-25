local socket = require("socket")

local client = assert(socket.connect("localhost", 8080))
client:settimeout(0)

print("Connected to server!")

client:send("HELLO\n")
print("Sent: HELLO")

--receive a response
local response, err = client:receive()
if response then
    print("Received:", response)
else
    print("No response yet")
end

client:close()
print("Disconnected")
