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
local start_time = socket.gettime()
local max_attempts_per_loop = 3
local connected = false

while true do
	for attempt = 1, max_attempts_per_loop do
		client = assert(socket.tcp())
		client:settimeout(1)
		local success, err = client:connect(host, port)
		if success or err == "already connected" then
			connected = true
			break
		end
		client:close()
		socket.sleep(0.01)
	end

	if connected then
		break
	end

	if socket.gettime() - start_time > 8 then
		-- If timeout reached without success
		send_channel:supply("Could not connect to server")
		return
	end

	socket.sleep(0.05) -- small pause before retrying full loop
end
send_channel:supply("connected")

while true do
	local received_data = client:receive("*l")
	if received_data then
		if received_data == "exit" then
			receive_channel:supply("exit")
			return
		end
		-- print("Received data: " .. received_data)
		local received_data = json.decode(received_data)
		receive_channel:push(received_data)
		-- print("Pushed: ", receive_channel:peek())
	end
	local send_data = send_channel:pop()
	if send_data then
		-- print("Sending data to server")
		-- print("Sending: " .. json.encode(send_data))
		client:send(json.encode(send_data) .. "\n")
		if send_data.type == "shutdown" then
			print("Sent shutdown")
		end
	end

	socket.sleep(0.01)
end
