-- AutoSaveManager
-- PURPOSE:
-- Periodically trigger autosaves

local RequestQueue = require(script.Parent.DataStoreManager.RequestQueue)

local AutoSaveManager = {}

local AutoSaveInterval = 120
local SaveAllProfiles = nil
local Running = false

function AutoSaveManager:Init(saveFunction)
	if AutoSaveManager._initialized then
		warn("AutoSaveManager: already initialized")
		return
	end

	if not saveFunction then
		warn("AutoSaveManager: requires a SaveAllProfiles function")
		return
	end

	AutoSaveManager._initialized = true
	SaveAllProfiles = saveFunction
	Running = true

	-- Autosave loop
	task.spawn(function()
		while Running do
			task.wait(AutoSaveInterval)
			if Running then
				SaveAllProfiles()
			end
		end
	end)

	-- Flush all pending saves before server closes
	game:BindToClose(function()
		Running = false
		if SaveAllProfiles then
			SaveAllProfiles()
		end
		RequestQueue:Flush() -- blocks until queue is fully drained
	end)
end

function AutoSaveManager:Stop()
	Running = false
end

return AutoSaveManager