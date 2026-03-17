-- DataStoreManager
-- PURPOSE:
-- The only module that directs communication with DataStoreService

local RequestQueue = require(script.RequestQueue)
local DefaultData = require(script.Parent.DefaultData)

RequestQueue:Start()

local DataStoreService = game:GetService("DataStoreService")
local datastore = DataStoreService:GetDataStore("PlayerData")

local SESSION_LOCK_TIMEOUT = require(script.Parent.Configuration).SESSION_LOCK_TIMEOUT or 120

local DataStoreManager = {}

local function getKey(player: Player)
	return "Player_" .. player.UserId
end

function DataStoreManager:Load(player: Player)
	local key = getKey(player)
	local result = nil
	local done = Instance.new("BindableEvent")

	RequestQueue:AddRequest(function()
		local success, data = pcall(function()
			return datastore:UpdateAsync(key, function(oldData)
				oldData = oldData or DefaultData.GetDefaultData()
				oldData = DefaultData.Reconcile(oldData)

				local lock = oldData.SessionLock
				if lock and lock.Server ~= game.JobId then
					if os.time() - lock.Time < SESSION_LOCK_TIMEOUT then
						return nil
					end
				end

				oldData.SessionLock = {
					Server = game.JobId,
					Time = os.time()
				}
				return oldData
			end)
		end)

		if success then
			result = data
		else
			warn("DataStoreManager: Load failed for", player.Name, data)
		end
		done:Fire()

	end, function(err)
		warn("DataStoreManager: Load permanently failed for", player.Name, err)
		done:Fire()
	end)

	done.Event:Wait()
	done:Destroy()
	return result
end

function DataStoreManager:Save(player: Player, data: {any}, releaseLock: boolean, onFail)
	local key = getKey(player)

	RequestQueue:AddRequest(function()
		local success, err = pcall(function()
			datastore:UpdateAsync(key, function(oldData)
				oldData = oldData or {}
				if releaseLock then
					data.SessionLock = nil
				else
					data.SessionLock = oldData.SessionLock
				end
				return data
			end)
		end)
		if not success then
			warn("DataStoreManager: Save failed for", player.Name, err)
		end
	end, function(err)
		warn("DataStoreManager: Save permanently failed for", player.Name, err)
		if onFail then onFail(err) end
	end)
end

function DataStoreManager:Update(player: Player, transformFunction)
	local key = getKey(player)

	RequestQueue:AddRequest(function()
		local success, err = pcall(function()
			datastore:UpdateAsync(key, function(oldData)
				local ok, result = pcall(transformFunction, oldData)
				if not ok then
					warn("DataStoreManager: Update transform error:", result)
					return nil
				end
				return result
			end)
		end)
		if not success then
			warn("DataStoreManager: Update failed for", player.Name, err)
		end
	end, function(err)
		warn("DataStoreManager: Update permanently failed for", player.Name, err)
	end)
end

return DataStoreManager