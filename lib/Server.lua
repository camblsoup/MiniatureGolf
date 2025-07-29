local socket = require("socket")

local Server = {
    instance = nil,
    clients = nil
}

function Server.start()
    Server.instance = socket.bind("*", 12345)
    Server.instance:settimeout(0)
    Server.clients = {}
    print("Server started on port 12345")
end

function Server.listen()
    while true do
        local client = Server:accept()
        if client then
            client:settimeout(0)
            local clientObj = {
                socket = client,
                id = #clients
            }
            table.insert(clients, clientObj)
            print("New client connected! ID:", clientObj.id)

            -- Send welcome message
            client:send("WELCOME:Client " .. clientObj.id .. "\n")
        end

        for i = #clients, 1, -1 do
            local clientObj = clients[i]
            local data, err = clientObj.socket:receive()

            if data then
                print("Received from client", clientObj.id, ":", data)

                clientObj.socket:send("ECHO: " .. data)
            elseif err == "closed" then
                print("Client", clientObj.id, "disconnected")
                clientObj.socket:close()
                table.remove(clients, i)
            end
        end
    end
end

--[[
local Server = socket.bind("*", 12345)
Server:settimeout(0)

local clients = {}

print("Server started on port 12345")

while true do
    local client = Server:accept()
    if client then
        client:settimeout(0)
        local clientObj = {
            socket = client,
            id = #clients
        }
        table.insert(clients, clientObj)
        print("New client connected! ID:", clientObj.id)

        -- Send welcome message
        client:send("WELCOME:Client " .. clientObj.id .. "\n")
    end

    for i = #clients, 1, -1 do
        local clientObj = clients[i]
        local data, err = clientObj.socket:receive()

        if data then
            print("Received from client", clientObj.id, ":", data)

            clientObj.socket:send("ECHO: " .. data)
        elseif err == "closed" then
            print("Client", clientObj.id, "disconnected")
            clientObj.socket:close()
            table.remove(clients, i)
        end
    end
end
--]]
