# 📦 Remote Packer
## About Module
Your game loses a lot of performance cause of tons of RemoteEvent's Fire calls at the same time?

This module is your solution!

Use this module instead of RemoteEvent/s and gain a good performance boost to your game
## How to Use
Place any RemoteEvent inside the module instance or set the correct path to it here:
```lua
--RemotePacker
local remote = script:FindFirstChildOfClass("RemoteEvent") -- THIS IS THE REMOTE EVENT THAT MAKES THE WHOLE SCRIPT WORK
```
Require a module:
```lua
local RemotePacker = require(RemotePacker)
```
Connect on Event:
```lua
--Server:
local Connection:RBXScriptConnection = RemotePacker:ConnectOnServer("key", function(plr, ...)
  --1st argument is a key for calls, similar to multiple RemoteEvents with different names
  print(plr, ...) --for example
end)
--Client:
local Connection:RBXScriptConnection = RemotePacker:ConnectOnClient("key", function(...)
  print(...) --for example
end)
```
Send something:
```lua
--Send to Server
RemotePacker:FireServer("key", {5, 0.1}, ...)
--1st argument is a key for calls, similar to multiple RemoteEvents with different names
--2nd argument is an amount of "calls" can be stored until real remote event will be fire
--i.e. remote event will be fired when RemotePacker:FireServer() called 5 times for one key
--3rd argument is kind of timeout that fires when time passed and "calls" amount did not reach needed
--Send to One Client
RemotePacker:FireClient(player, "key", {5, 0.1}, ...)
--Send to All Clients
RemotePacker:FireAllClients("key", {5, 0.1}, ...)
```
## How It Works
Keys system:

Let's see type of key
```lua
type key_data = {
  remote_type:"Server"|"Client"|"AllClients",
  key_player:Player?,
  key_capacity:number,
  key_timer:number,
  key_delta:number,
  key_data:{{any}}
}
```
remote_type sets on RemotePacker:Fire. It helps choose the way to fire remote (FireServer, FireClient, FireAllClients) for the timeout method

code part:
```lua
if key.key_player then
  remote["Fire"..key.remote_type](remote, key.key_player, i, key.key_data)
else
  remote["Fire"..key.remote_type](remote, i, key.key_data)
end
```
key_player only sets for FireClient method

key_delta basically is the time in seconds from the first data on key appearing, resets when data pack sent

key_data stores data like this:
```lua
key_data = {
  [1] = {"arg1", 123, true},
  [2] = {"arg2", 456, false}
}
```
Now look how function connecting works:
```lua
function RemotePacker:ConnectOnServer(key:string, func:(Player, ...any)->RBXScriptConnection)
	if not is_init then return end
	return remote.OnServerEvent:Connect(function(player, key, key_data)
		for _, data in key_data do
			func(player, unpack(data))
		end
	end)
end
function RemotePacker:ConnectOnClient(key:string, func:(...any)->RBXScriptConnection)
	if not is_init then return end
	return remote.OnClientEvent:Connect(function(key, key_data)
		for _, data in key_data do
			func(unpack(data))
		end
	end)
end
```
Kinda simple, isn't it?

Soo that's it!
## Thanks for paying attention to README.md!
### If you have any remaining questions or suggestions, feel free to dm me in discord: blin4ik63
