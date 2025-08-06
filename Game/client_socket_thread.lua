local socket = require("socket")
local json = require("lib/json")

local host, port = ...

local receive_channel = love.thread.getChannel("receive_channel")
local send_channel = love.thread.getChannel("send_channel")

local client = assert(socket.tcp())
local success, err = client:connect(host, port)
client:settimeout(0)
local start_time = socket.gettime()
while true do
	local ok, err = client:getpeername()
	if ok then
		break
	end
	if err ~= "timeout" then
		error("Connect failed: " .. tostring(err))
	end
	if socket.gettime() - start_time > 5 then
		--send_channel:supply("not connected")
		return
	end
	socket.sleep(0.01)
end
assert(success)

--send_channel:supply("connected")

while true do
	local received_data = client:receive("*l")
	if received_data then
		-- print("Received data: " .. received_data)
		local received_data = json.decode(received_data)
		receive_channel:push(received_data)
		-- print("Pushed: ", receive_channel:peek())
	end
	local send_data = send_channel:pop()
	if send_data then
		-- print("Sending data to server")
		client:send(json.encode(send_data) .. "\n")
		if send_data.type == "shutdown" then
			return
		end
	end

	socket.sleep(0.01)
end
