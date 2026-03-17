-- Profile

-- PURPOSE:
-- Represents one player's data in memory.
-- Provides clean functions to read and modify data.

-- RESPONSIBILITIES:
-- 1. Store the player's data table
-- 2. Provide helper functions (Get, Set, Increment)
-- 3. Track if data changed (dirty flag)

-- STRUCTURE:
-- Profile = {
--     Player
--     Data
--     IsDirty
-- }

local Profile = {}

local function resolvePath(data, path)
	local keys = string.split(path, ".")
	local current = data
	for i = 1, #keys - 1 do
		local key = keys[i]
		if type(current[key]) ~= "table" then
			return nil, nil, "Path '" .. path .. "' is invalid at key '" .. key .. "'"
		end
		current = current[key]
	end
	return current, keys[#keys], nil
end

function Profile.new(player, data)
	local self = setmetatable({}, { __index = Profile })
	self.Player = player
	self.Data = data
	self.IsDirty = false
	return self
end

function Profile:MarkDirty()
	self.IsDirty = true
end

function Profile:Get(path)
	local parent, lastKey, err = resolvePath(self.Data, path)
	if err then
		warn("Profile:Get -", err)
		return nil
	end
	return parent[lastKey]
end

function Profile:Set(path, value)
	local parent, lastKey, err = resolvePath(self.Data, path)
	if err then
		warn("Profile:Set -", err)
		return
	end

	local existing = parent[lastKey]

	if type(value) ~= "table" and existing == value then
		return
	end

	parent[lastKey] = value
	self:MarkDirty()
end

function Profile:Increment(path, amount)
	if type(amount) ~= "number" then
		warn("Profile:Increment - amount must be a number, got " .. type(amount))
		return
	end
	local current = self:Get(path)
	if current ~= nil and type(current) ~= "number" then
		warn("Profile:Increment - key '" .. path .. "' is not a number")
		return
	end
	self:Set(path, (current or 0) + amount)
end

function Profile:GetFullData()
	return self.Data
end

return Profile