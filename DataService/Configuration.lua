local DataServiceOptions = {
	DEFAULT_TEMPLATE =  {
		Coins = 0,
		Inventory = {},
		Stats = {
			Strength = 1,
			Stamina = 100,
			Level = 1
		},
		Settings = {
			Music = true
		}
	},
	SESSION_LOCK_TIMEOUT = 10 * 60, -- 10 minutes in seconds
	REQUEST_QUEUE_CONFIG = {
		MAX_REQUESTS_PER_SECOND = 5,
		MAX_QUEUE_SIZE = 500,
		MAX_RETRIES = 3
	},
}

return DataServiceOptions