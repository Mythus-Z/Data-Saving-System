# Roblox DataStore System

This is a modular (proper responsibility separation), production-ready DataStore system for Roblox games. It's all the fundamental functionalities of a standard DataStore system with some additional super helpful features as well (e.g. Session locking)

This DataStore wrapper API solves common problems of data loss and insecurities in real world usage, and makes saving and interacting with the data really convenient and easy.
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
DataService
├── AutoSaveManager
├── DataStoreManager
│   └── RequestQueue
├── DataTemplate
└── Profile

### Responsibilities
-DataService: The public API for player data operations. It hides DataStore complexity behind simple methods (Get(), Set(), Increment(), etc.)
-AutoSaveManager: Manages autosaves
-DataStoreManager: The only module that communicates with DataStore through RequestQueue.
-RequestQueue: Queues and throttle DataStore requests, respecting the DataStore Rate limits.
-DataTemplate: Defines default data and Reconcile() method.
-Profile: The copy of the data stored on the server for instantaneous data operations, which is later pushed to the DataStore.

---

## Usage
-- Give a player coins
DataService:Increment(player, "Coins", 50)

-- Update a nested value
DataService:Set(player, "Stats.Level", 10)

-- Read a value
local coins = DataService:Get(player, "Coins")

-- Transform a value
DataService:Update(player, "Coins", function(current)
    return current * 2
end)

---

## Setup
1. Place all modules under a single folder in ServerScriptService
2. Call DataService:Init() from your main server script
3. Define your data structure in DataTemplate

---

## Design Decisions
Short paragraph for each key decision. e.g.:
- Why UpdateAsync over SetAsync for session locking
- Why a request queue instead of direct DataStore calls
- Why dirty flagging instead of saving on every change

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
