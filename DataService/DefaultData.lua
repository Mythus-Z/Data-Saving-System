-- DefaultData
-- PURPOSE:
-- Default data structure for new players.

-- RESPONSIBILITIES:
-- 1. Provide default values
-- 2. Ensure all required fields exist
-- 3. Used for data reconciliation

local DefaultData = {}
local config = require(script.Parent.Configuration)
local defaultTemplate = config.DEFAULT_TEMPLATE
local function deepCopy(original)
	if type(original) ~= "table" then
		return original
	end

	local copy = {}
	for key, value in pairs(original) do
		copy[key] = deepCopy(value)
	end

	return copy
end

local function deepReconcile(target, template)
	for key, value in pairs(template) do
		if type(key) == "string" then -- Only string keys
			if target[key] == nil then
				if type(value) == "table" then
					target[key] = deepCopy(value)
				else
					target[key] = value
				end
			elseif type(value) == "table" then
				if type(target[key]) ~= "table" then
					target[key] = deepCopy(value)
				else
					deepReconcile(target[key], value)
				end
			end
		end
	end
	return target
end

function DefaultData.GetTemplate()
	return deepCopy(defaultTemplate)
end


function DefaultData.Reconcile(data)
	return deepReconcile(data, defaultTemplate)
end


return DefaultData