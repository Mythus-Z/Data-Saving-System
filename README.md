# Roblox DataStore System

This is a modular (proper responsibility separation), production-ready DataStore wrapper for Roblox games. It's got all the fundamental functionalities of a standard DataStore system with some additional critical features as well (e.g. Session locking) without which data loss occured

This DataStore wrapper solves common problems of data loss and insecurities in real world usage, and makes saving and interacting with the data really convenient and easy.

---

## Features
- Session locking (prevents data corruption across servers)
- Request queue (respects Roblox DataStore rate limits)
- Autosave + graceful shutdown (no data loss on server close)
- Dirty flagging (only saves when data actually changed)
- Dot-path notation (e.g. Set("Stats.Level", 5))
- Data reconciliation (missing fields auto-filled from template)

---

## Architecture
```
DataService
├── AutoSaveManager
├── DataStoreManager
│   └── RequestQueue
├── DataTemplate
├── Configuration
└── Profile
```

### Responsibilities
- DataService: The public API for player data operations. It hides DataStore complexity behind simple methods (Get(), Set(), Increment(), etc.)
- AutoSaveManager: Manages autosaves
- DataStoreManager: The only module that communicates with DataStore through RequestQueue.
- RequestQueue: Queues and throttle DataStore requests, respecting the DataStore Rate limits.
- DataTemplate: Defines default data and Reconcile() method.
- Configuration: Exposes common configurations for easier configuration.
- Profile: The copy of the data stored on the server for instantaneous data operations, which is later pushed to the DataStore.

---

## Usage

- Give a player coins
```lua
DataService:Increment(player, "Coins", 50)
```

- Update a nested value
```lua
DataService:Set(player, "Stats.Level", 10)
```
- Read a value
```lua
local coins = DataService:Get(player, "Coins")
```

- Transform a value
```lua
DataService:Update(player, "Coins", function(current)
    return current * 2
end)
```
---

## Setup
1. Place all modules under a single folder in ServerScriptService
2. Call DataService:Init() from your main server script
3. Define your data structure in Configuration

For example:
- Initialize the service and define the default data template in Configuration.lua
```lua
--DataService.lua
DataService:Init()
```
```lua
--Configuration.lua
-- just configure the settings like DEFAULT_TEMPLATE etc. according to your use case. Or leave as-is if experimenting.
-- You can experiment with other settings too, just be careful and ensure you understand the option first.
```
---

## Design Decisions
Short paragraph for each key decision. e.g.:
- Why UpdateAsync over SetAsync for session locking
- Why a request queue instead of direct DataStore calls
- Why dirty flagging instead of saving on every change

- Used RequestQueue → to prevent DataStore rate limit issues (pros: stable multiple operations, cons: slight delay, usually goes unnoticed)
- Using UpdateAsync instead of SetAsync under the hood → to avoid overwriting data (Tradeoff: UpdateAsync is slightly more complex. But it's not a performance issue in my system because I used in-memory profile system for faster real time data access)

- Creating DataTemplate → to ensure safe data reconciliation and deep copying of default template

- Adding AutoSaveManager → to reduce data loss risk

- Structuring with a DataService layer → to centralize logic
---

## Known Limitations
- No schema versioning (intentional for scope of project)
- Single DataStore key per player

---

## What I'd Add Next
- Schema versioning and migrations
- Per-profile save callbacks
- Logging system to replace warn() calls

---

## Tech
- Lua / Roblox Luau
- Roblox DataStoreService
