-- DataService
-- PURPOSE:
-- Central service managing player data lifecycle.

local DataService = {}
local ActiveProfiles = {}

local DataStoreManager = require(script.DataStoreManager)
local AutoSaveManager = require(script.AutoSaveManager)
local Profile = require(script.Profile)

local Players = game:GetService("Players")

-- INIT
function DataService:Init()
	for _, player in pairs(Players:GetPlayers()) do
		self:LoadPlayer(player)
	end

	Players.PlayerAdded:Connect(function(player)
		self:LoadPlayer(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self:ReleasePlayer(player)
	end)

	AutoSaveManager:Init(function()
		self:SaveAllProfiles()
	end)
	print("DataService initialized")
end

-- LOAD / RELEASE / SAVE
function DataService:LoadPlayer(player:Player)
	if ActiveProfiles[player] then return end

	local data = DataStoreManager:Load(player)
	if not data then
		player:Kick("Failed to load your data. Please rejoin.")
		return
	end

	local profile = Profile.new(player, data)
	ActiveProfiles[player] = profile
end

function DataService:ReleasePlayer(player:Player)
	if not ActiveProfiles[player] then return end
	self:SavePlayer(player, true)
	ActiveProfiles[player] = nil
end

function DataService:SavePlayer(player:Player, releaseLock:boolean)
	local profile = ActiveProfiles[player]
	if not profile or not profile.IsDirty then return end

	DataStoreManager:Save(player, profile:GetFullData(), releaseLock, function(err)
		-- Save permanently failed — mark dirty again so next cycle retries
		warn("DataService: permanently failed to save", player.Name, err)
		profile.IsDirty = true
	end)

	profile.IsDirty = false
end

-- save all profiles (autosave)
function DataService:SaveAllProfiles()
	for player, profile in pairs(ActiveProfiles) do
		self:SavePlayer(player)
	end
end

-- GETTERS / SETTERS
function DataService:GetProfile(player:Player):"Profile"
	return ActiveProfiles[player]
end

function DataService:GetAllProfiles():{ [Player]: "Profile" }
	return ActiveProfiles
end
function DataService:Get(player:Player, key:string)
	local profile = ActiveProfiles[player]
	if not profile then return nil end
	return profile:Get(key)
end

function DataService:Set(player:Player, key:string, value:any)
	local profile = ActiveProfiles[player]
	if not profile then return end
	profile:Set(key, value)
end

function DataService:Increment(player:Player, key:string, amount:number)
	local profile = ActiveProfiles[player]
	if not profile then return end
	profile:Increment(key, amount)
end

function DataService:Update(player:Player, key:string, transformFunction)
	local profile = ActiveProfiles[player]
	if not profile then return end
	local value = profile:Get(key)
	local newValue = transformFunction(value)
	if newValue == nil then
		warn("DataService:Update - transform returned nil for key:", key)
		return
	end
	profile:Set(key, newValue)
end

return DataService
