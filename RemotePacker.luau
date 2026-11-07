local RemotePacker = {}
local RunService = game:GetService("RunService")

type key_data = {remote_type:"Server"|"Client"|"AllClients", key_player:Player?, key_capacity:number, key_timer:number, key_delta:number, key_data:{{any}}}
local keys = {} :: {key_data}

local remote = script:FindFirstChildOfClass("RemoteEvent")or Instance.new("RemoteEvent",script) -- THIS IS THE REMOTE EVENT THAT MAKES THE WHOLE SCRIPT WORK
local is_init = false

function RemotePacker:FireServer(key:string, info:{key_capacity:number, key_timer:number}, ...:any)
	if not is_init then return end
	info = info or {}
	if not keys[key] then
		keys[key] = {
			remote_type = "Server",
			key_capacity = info.key_capacity or 1,
			key_timer = info.key_timer or 0,
			key_delta = 0,
			key_data = {}
		}
	end
	table.insert(keys[key].key_data, {...})
	if #keys[key].key_data < keys[key].key_capacity and keys[key].key_delta < keys[key].key_timer then return end
	local key_data = keys[key].key_data
	keys[key] = nil
	remote:FireServer(key, key_data)
end
function RemotePacker:FireClient(player:Player, key:string, info:{key_capacity:number, key_timer:number}, ...:any)
	if not is_init then return end
	if not keys[key] then
		keys[key] = {
			remote_type = "Client",
			key_player = player,
			key_capacity = info.key_capacity or 1,
			key_timer = info.key_timer or 0,
			key_delta = 0,
			key_data = {}
		}
	end
	table.insert(keys[key].key_data, {...})
	if #keys[key].key_data < keys[key].key_capacity and keys[key].key_delta < keys[key].key_timer then return end
	local key_data = keys[key].key_data
	keys[key] = nil
	remote:FireClient(player, key, key_data)
end
function RemotePacker:FireAllClients(key:string, info:{key_capacity:number, key_timer:number}, ...:any)
	if not is_init then return end
	if not keys[key] then
		keys[key] = {
			remote_type = "AllClients",
			key_capacity = info.key_capacity or 1,
			key_timer = info.key_timer or 0,
			key_delta = 0,
			key_data = {}
		}
	end
	table.insert(keys[key].key_data, {...})
	if #keys[key].key_data < keys[key].key_capacity and keys[key].key_delta < keys[key].key_timer then return end
	local key_data = keys[key].key_data
	keys[key] = nil
	remote:FireAllClients(key, key_data)
end

function RemotePacker:ConnectOnServer(key:string, func:(Player, ...any)->()):RBXScriptConnection
	if not is_init then return end
	return remote.OnServerEvent:Connect(function(player, key, key_data)
		for _, data in key_data do
			func(player, unpack(data))
		end
	end)
end
function RemotePacker:ConnectOnClient(key:string, func:(...any)->()):RBXScriptConnection
	if not is_init then return end
	return remote.OnClientEvent:Connect(function(key, key_data)
		for _, data in key_data do
			func(unpack(data))
		end
	end)
end

local function InitRunService(delta)
	for i, key:key_data in keys do
		task.spawn(function()
			key.key_delta = key.key_delta or 0
			key.key_delta += delta	
			if key.key_delta < key.key_timer then return end
			keys[i] = nil
			if key.key_player then
				remote["Fire"..key.remote_type](remote, key.key_player, i, key.key_data)
			else
				remote["Fire"..key.remote_type](remote, i, key.key_data)
			end
		end)
	end
end

--\\ on require()
if RunService:IsClient() then
	RunService.RenderStepped:Connect(InitRunService)
else
	RunService.Heartbeat:Connect(InitRunService)
end
is_init = true
--//

return RemotePacker
