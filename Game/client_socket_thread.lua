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
		--print("Received data: " .. received_data)
		local success, received_data = pcall(json.decode, received_data)
		if not success then
			print(received_data)
			goto continue
		end
		if received_data.type == "shutdown" then
			client:close()
			receive_channel:supply(received_data)
			return
		end
		receive_channel:push(received_data)
	end
	local send_data = send_channel:pop()
	if send_data then
		print("Sending: " .. json.encode(send_data))
		client:send(json.encode(send_data) .. "\n")
	end

	socket.sleep(0.01)
	::continue::
end
