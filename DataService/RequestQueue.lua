-- RequestQueue
-- PURPOSE:
-- Central queue that processes DataStore requests at a controlled rate.
-- Prevents request bursts that exceed Roblox DataStore limits.
-- Handles retries for failed requests.

local RequestQueue = {}

local config = require(script.Parent.Parent.Configuration)
local MAX_REQUESTS_PER_SECOND = config.REQUEST_QUEUE_CONFIG.MAX_REQUESTS_PER_SECOND
local REQUEST_INTERVAL = 1 / MAX_REQUESTS_PER_SECOND
local MAX_RETRIES = config.REQUEST_QUEUE_CONFIG.MAX_RETRIES
local MAX_QUEUE_SIZE = config.REQUEST_QUEUE_CONFIG.MAX_QUEUE_SIZE

local Queue = {}
local Processing = false
local Running = false

function RequestQueue:AddRequest(callback, onFail)
	if #Queue >= MAX_QUEUE_SIZE then
		warn("RequestQueue: queue is full, dropping request")
		if onFail then onFail("Queue full") end
		return
	end
	table.insert(Queue, {
		callback = callback,
		retries = 0,
		onFail = onFail
	})
end

local function processNext()
	if #Queue == 0 then return end

	local request = table.remove(Queue, 1)
	local success, result = pcall(request.callback)

	if not success then
		if request.retries < MAX_RETRIES then
			request.retries += 1
			table.insert(Queue, 1, request)
		else
			warn("RequestQueue: request failed after retries:", result)
			if request.onFail then
				request.onFail(result)
			end
		end
	end
end

function RequestQueue:Start()
	if Processing then return end
	Processing = true
	Running = true

	task.spawn(function()
		while Running do
			processNext()
			task.wait(REQUEST_INTERVAL)
		end
		Processing = false
	end)
end


function RequestQueue:Flush()
	Running = false
	while #Queue > 0 do
		processNext()
		task.wait(REQUEST_INTERVAL) -- respect rate limit during flush
	end
end

return RequestQueue