# Mini-Games — AI Agent Guide

## What This Project Is

A **Roblox mini-games framework** built with [Rojo](https://rojo.space) (file-sync tool for Roblox Studio). Players join a lobby, vote on one of three randomly chosen mini-games, play it, and accumulate wins. The project has 7 mini-games, a shop (auras + powers), persistent data storage, and an AFK system.

## Toolchain & Workflow

| Tool | Purpose |
|------|---------|
| `rojo serve` | Sync source files into Roblox Studio live |
| `rojo build -o "RPG-Game.rbxlx"` | Build a place file from scratch |
| `aftman.toml` / `rokit.toml` | Pin Rojo v7.6.1 via toolchain managers |

**File extensions:**
- `.server.lua` — server Scripts (auto-wrapped in a Script by Rojo)
- `.client.lua` — client LocalScripts
- `.luau` — ModuleScripts (required at runtime)

The file tree is defined in `default.project.json`, which maps source paths to Roblox services. **Any new file or folder must be added to `default.project.json`** to appear in the game.

## Project Structure

```
src/
├── server/                  # ServerScriptService + ServerStorage modules
│   ├── GameHandler.server.lua      # Main game loop (entry point)
│   ├── Leaderstatus.server.lua     # Player data + DataStore persistence
│   ├── ShopHandler.server.lua      # Shop purchase handler
│   ├── AfkHandler.server.lua       # AFK toggle server side
│   ├── KillFunction.luau           # Kills any humanoid on touch
│   ├── TeleportPlayers.luau        # Moves players to/from game area
│   ├── BasicEnding.luau            # Scans InGame folder for survivors → awards wins
│   ├── Powers.luau                 # LowGravity + ExtraSpeed power definitions
│   ├── SwordScript.server.lua      # Classic sword tool logic (CTF only)
│   └── <GameName>.luau             # One module per mini-game (7 total)
│
├── client/                  # StarterGui + StarterPlayer scripts
│   ├── VotingClient.client.lua     # Voting UI, listens for VotingEvent
│   ├── ShopGui.client.lua          # Shop UI, invokes ItemPurchased RemoteFunction
│   ├── StatusUpdater.client.lua    # Game status label
│   ├── StatusUpdaterWins.client.lua# Wins counter display
│   ├── AfkGui.client.lua           # AFK button
│   ├── LowGravity.client.lua       # Applies gravity value from server event
│   └── MouseIcon.client.lua        # Custom cursor for sword (inside CTF Tool)
│
└── shared/                  # Empty — no shared modules yet
```

## Game Loop (GameHandler.server.lua)

```
Server starts
│
├── Wait until MIN_PLAYERS (1) are present
├── Intermission countdown (10 s)
├── Voting phase (8 s)
│   ├── Pick 3 random games from ServerStorage.MiniGames
│   ├── Fire VotingEvent → clients show UI
│   └── UpdateVotes RemoteFunction tracks per-player votes
├── Winning game's module: require(module).RunGame()
├── TeleportPlayers(lobbyCFrame)    ← returns everyone to lobby
└── Loop
```

**Key constants in GameHandler:**
```lua
local INTERMISSION = 10   -- seconds
local MIN_PLAYERS  = 1    -- minimum to start a round
local VOTE_TIME    = 8    -- seconds for voting window
```

**`_G` globals set by GameHandler** (available to all server modules):
```lua
_G.gameStatus       -- StringValue in ReplicatedStorage (shown to clients)
_G.TeleportPlayers  -- function(cframe, toGame?)
_G.BasicEnding      -- function() — announces winners, adds wins
_G.KillFunction     -- function(hit) — kills humanoid on touch
_G.GameQueue        -- table — insert a game module here to skip voting
```

## ReplicatedStorage Events

All events live in `ReplicatedStorage.Events`:

| Name | Type | Direction | Purpose |
|------|------|-----------|---------|
| `Voting` | RemoteEvent | Server → Client | Send 3 game options (or nil to hide UI) |
| `UpdateVotes` | RemoteFunction | Client → Server | Cast/update a vote, returns current vote table |
| `MinigameChosen` | RemoteEvent | Server → Client | Announce winning game |
| `ItemPurchased` | RemoteFunction | Client → Server | Request shop purchase |
| `LowGravity` | RemoteEvent | Server → Client | Set client's workspace.Gravity value |
| `AfkMode` | RemoteEvent | Server ↔ Client | Toggle AFK state |

## Player State (set in Leaderstatus.server.lua)

Each player gets these objects on join:

| Path | Type | Purpose |
|------|------|---------|
| `player.leaderstats.Wins` | NumberValue | Win count (shows on leaderboard) |
| `player.Items` | Folder | StringValues named after owned aura items |
| `player.CurrentItem` | ObjectValue | Currently equipped aura ParticleEmitter |
| `player.CurrentPower` | ObjectValue | Currently active power's ParticleEmitter |

**DataStores:**
- `WinsData-2` (OrderedDataStore) — stores `player.userId → wins`
- `Items-2` (DataStore) — stores `player.userId → {item names array}`

Data saves on `PlayerRemoving` and `game:BindToClose`.

## workspace.InGame

During a game, `TeleportPlayers(cframe, true)` moves non-AFK player characters under `workspace.InGame`. `BasicEnding()` reads this folder to find survivors (Humanoid.Health > 0) and award wins. At game end, `TeleportPlayers(lobbyCFrame)` (no second arg) moves characters back to `workspace`.

## Adding a New Mini-Game

### 1. Create the module file
`src/server/<GameName>.luau`:

```lua
local MiniGame = {}
local gameModel = script:WaitForChild("GameModel")

function MiniGame.RunGame()
    -- Clone map into workspace
    local newGame = gameModel:Clone()
    newGame.Parent = workspace

    -- Hook kill zones
    newGame.KillBrick.Touched:Connect(_G.KillFunction)

    -- Move players into game (skips AFK players, puts chars in workspace.InGame)
    _G.TeleportPlayers(newGame.SpawnPoint.CFrame, true)

    -- Countdown
    for t = 30, 0, -1 do
        _G.gameStatus.Value = "Game name ( " .. t .. " )"
        task.wait(1)
    end

    -- Award wins to survivors
    _G.BasicEnding()

    -- Cleanup
    newGame:Destroy()
end

return MiniGame
```

### 2. Register in default.project.json
Add an entry under `"ServerStorage" > "MiniGames"`:

```json
"GameName": {
    "$path": "src/server/GameName.luau",
    "GameModel": {
        "$className": "Folder",
        "SpawnPoint": { "$className": "Part" },
        "KillBrick":  { "$className": "Part" }
    }
}
```

### 3. Set the voting image attribute
In Roblox Studio, select `ServerStorage.MiniGames.<GameName>` and add a string Attribute named `Img` with the asset ID string (e.g. `"rbxassetid://123456"`). This is what the voting UI displays.

## Shop System

**Types:** `Aura` (cosmetic ParticleEmitter, persisted) | `Power` (temporary buff, not persisted)

Each shop item frame has these Attributes:
- `Name` — matches an item in `ServerStorage.Items` (Aura) or a key in `Powers` module (Power)
- `Type` — `"Aura"` or `"Power"`
- `Price` — win cost

**Aura flow:** Deducts wins → clones ParticleEmitter into `HumanoidRootPart` → saves item name to `player.Items` folder → persisted by DataStore.

**Power flow:** Checks `_G[itemInfo["Name"]] ~= "DISABLED"` → calls `Powers[name](player, char)` → stores returned ParticleEmitter in `player.CurrentPower` → auto-reverses when the emitter is destroyed.

## Powers System (Powers.luau)

Each power function receives `(player, playerCharacter)` and returns `{effectInstance, cleanupFn}`:
- `effectInstance` — ParticleEmitter parented to HumanoidRootPart; destroying it triggers cleanup
- `cleanupFn` — reverses the power effect (e.g., restore gravity/speed)

| Power | Effect | Duration |
|-------|--------|---------|
| `LowGravity` | `workspace.Gravity = 25` (client-side via RemoteEvent) | 30 s |
| `ExtraSpeed` | `WalkSpeed += 10` | 10 s |

**To disable a power in a specific game**, set `_G["PowerName"] = "DISABLED"` at the start of `RunGame()` and clear it after the game ends.

## AFK System

- `player:SetAttribute("AFK", true/false)` — set server-side by AfkHandler
- `TeleportPlayers` skips players where `plr:GetAttribute("AFK")` is truthy
- AFK players remain in lobby during games

## Conventions

- Module files use `local MiniGame = {}` table pattern and `return MiniGame`
- `script.GameModel` is always the folder holding the map for a mini-game module
- Power/item names must exactly match `ServerStorage.Items` children or `Powers` module function names
- `workspace.InGame` folder must exist in the live place; characters move here during games
- Lobby spawn is at `workspace.Lobby.SpawnLocation.SpawnLocation.CFrame + Vector3.yAxis * 5`
