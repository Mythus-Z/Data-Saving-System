# Roblox DataStore System

Short 2-3 sentence description of what the system is and what problem it solves.
(e.g. "A modular, production-ready DataStore system for Roblox games. Handles 
player data loading, saving, and session management with built-in rate limiting 
and data protection.")

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

Short paragraph explaining the responsibility of each module.

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
