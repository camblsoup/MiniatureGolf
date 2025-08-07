local socket = require("socket")
local json = require("lib/json")

local host, port = ...

local receive_channel = love.thread.getChannel("receive_channel")
local send_channel = love.thread.getChannel("send_channel")

if not host or type(host) ~= "string" then
	send_channel:supply("Host is not provided or is not a string")
	return
end

if not port or type(port) ~= "number" then
	send_channel:supply("Port is not provided or is not a number")
	return
end

local client
local success, err = false, nil
local start_time = socket.gettime()
while true do
	client = assert(socket.tcp())
	client:settimeout(1)
	success, err = client:connect(host, port)
	if success or err == "already connected" or client:getpeername() then
		break
	end
	if err and err ~= "timeout" then
		client:close()
		send_channel:supply("Could not connect to server " .. err)
		return
	end
	if socket.gettime() - start_time > 11 then
		client:close()
		send_channel:supply("Could not connect to server")
		return
	end
	client:close()
	socket.sleep(0.01)
end
send_channel:supply("connected")

while true do
	local received_data = client:receive("*l")
	if received_data then
		-- print("Received data: " .. received_data)
<<<<<<< HEAD
		--print(received_data)
		local received_data = json.decode(received_data)
		receive_channel:push(received_data)
		-- print("Pushed: ", receive_channel:peek())
	end
	local send_data = send_channel:pop()
	if send_data then
		-- print("Sending data to server")
		--print("Sending: " .. json.encode(send_data))
		client:send(json.encode(send_data) .. "\n")
		if send_data.type == "shutdown" then
			print("Sent shutdown")
		end
	end

	socket.sleep(0.01)
end
