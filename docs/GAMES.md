# Mini-Games — Per-Game Reference

All game modules live in `src/server/` and are registered under `ServerStorage.MiniGames` via `default.project.json`. Each exports a `RunGame()` function.

---

## 1. Lava Rising (`LavaRising.luau`)

**Concept:** Survive as lava slowly rises from below. Reach the top.

**Win condition:** Survivors in `workspace.InGame` when time runs out → `BasicEnding()` awards wins.

**Key timings:**
| Constant | Value |
|----------|-------|
| `riseDelay` | 3 s (before lava moves) |
| `riseTime` | 25 s (tween duration) |

**GameModel parts required:**
- `Lava` — Part that rises (tweened to `RisePosition.CFrame`)
- `RisePosition` — Part marking the lava's final position
- `SpawnPoint` — Where players teleport

**Notes:**
- Uses TweenService with `Enum.EasingStyle.Linear` for smooth rise
- Lava `.Touched` is connected to `_G.KillFunction`

---

## 2. Tile Dash (`Tile Dash.luau`)

**Concept:** Tiles randomly blink warning red then drop. Last player standing wins.

**Win condition:** Survivors when 35-second timer expires → `BasicEnding()`.

**Key timings:**
| Constant | Value |
|----------|-------|
| `gameTime` | 35 s |
| `startingDropTime` | 0.5 s per blink |
| `dropTimeDecrease` | +0.4 s per cycle (slows over time) |
| `tileBlinkCount` | 2 blinks before drop |
| `tilesToFall` | 20 tiles per cycle |

**GameModel parts required:**
- `Tiles` — Folder of tile Parts
- `Lava` — Kill zone below tiles (`.Touched → _G.KillFunction`)
- `Spawn` — Player spawn point

**Notes:**
- Game loop runs in a separate coroutine; `coroutine.close()` stops it when timer ends
- Tiles are tweened downward 20 studs (`tileTweenInfo: 0.7s, Quint`)
- Warning color: `RGB(255, 73, 49)`

---

## 3. Boulder Run (`Boulder Run.luau`)

**Concept:** Race to the top while dodging randomly spawned rolling boulders. First player to reach the Win part wins.

**Win condition:** First player to touch `GameModel.Win` part — custom logic, does **not** call `BasicEnding()` and does **not** add a win to `leaderstats`. (Known gap — add `gameWon.leaderstats.Wins.Value += 1` if desired.)

**Boulder parameters:**
| Constant | Value |
|----------|-------|
| `sizeMin` / `sizeMax` | 6–17 studs |
| `spawnMin` / `spawnMax` | 0.5–1.5 s between spawns |
| `lifetime` | 10 s (Debris service) |
| `stunTime` | 2.5 s (PlatformStand on hit) |
| `rav` | ±15 rad/s angular velocity |
| `rlv` | ±60 stud/s linear velocity |

**GameModel parts required:**
- `BoulderSpawn` — Part defining the X/Z spawn zone (boulders spawn along its face)
- `Spawn` — Player spawn point
- `Win` — Part players must touch to win
- `Boulders` — Folder where boulder clones are parented

**Boulder template:** `script.Boulder` Part (defined in `default.project.json`)

**Notes:**
- `Debris:AddItem(boulder, 10)` auto-cleans boulders
- Boulder hit stuns player (PlatformStand) and copies boulder's velocity

---

## 4. Spleef (`Spleef.luau`)

**Concept:** Break tiles under opponents. Last player on a tile wins.

**Win condition:** Loop until `#workspace.InGame:GetChildren() <= 1` → `BasicEnding()`.

**Key parameters:**
| Constant | Value |
|----------|-------|
| `minusHeight` | 0.4 studs (HipHeight reduction to prevent floating) |
| Tile blink animation | 0.3 s (Quart, yoyo) |
| Tile drop distance | 0.5 studs down |

**GameModel parts required:**
- `Levels` — Folder containing tile Parts (all named `"Tile"`)
- `KillBrick` — Kill zone below tiles
- `SpawnPoint` — Spawn point (temporarily moved to `workspace` for teleport, then re-parented)

**Notes:**
- `gameModel` is kept as a child of `script` (not cloned) and re-parented to workspace; restored to `script` at game end
- Tile connections are set up at **module load time** (outside `RunGame`), including `KillBrick.Touched`
- Tiles are NOT destroyed — they become transparent/non-collidable and are restored after game via coroutine
- `tileData` table stores original `{size, cframe}` per tile for reset

---

## 5. Infection Tag (`Infection Tag.luau`)

**Concept:** One random tagger tries to infect all runners. Runners win if any survive 60 seconds; tagger wins if all are infected.

**Win condition:** Custom — checks `workspace.InGame` vs `taggedFolder`:
- All runners infected → tagger and infected win (wins added manually)
- Timer expires → remaining runners in `workspace.InGame` win

**Key parameters:**
| Constant | Value |
|----------|-------|
| `taggedSpeed` | 25 WalkSpeed |
| `runnerSpeed` | 22 WalkSpeed |
| Game timer | 60 s |
| Tagger highlight | Green `RGB(155, 255, 48)` fill + `RGB(55, 255, 0)` outline |

**GameModel parts required:**
- `Cage.PlayerSpawn` — All players spawn here initially
- `Cage.TaggerSpawn` — Tagger is moved here
- `Cage` — Destroyed when game starts (keeps tagger separated during prep)

**Power interactions:**
- `_G.ExtraSpeed = "DISABLED"` at game start; cleared to `nil` after game ends
- Active ExtraSpeed power is destroyed from players at game start

**Camera:**
- `CameraMaxZoomDistance = 35` during game; restored to `StarterPlayer.CameraMaxZoomDistance` after

**Notes:**
- Tagged players move to `workspace.Tagged` folder (a new Folder created per game, NOT `workspace.InGame`)
- Tagged players spread the tag via their `HumanoidRootPart.Touched`
- `Humanoid:SetAttribute("Tagged", true)` prevents double-tagging
- Survivors use `BasicEnding()` is NOT called — wins are added manually

---

## 6. Crazy Colors (`CrazyColors.luau`)

**Concept:** Stand on safe-colored platforms. Every round a random color is eliminated (removed briefly). Players on the eliminated color fall into lava.

**Win condition:** Survivors after all rounds → `BasicEnding()`.

**Key parameters:**
| Constant | Value |
|----------|-------|
| `totalRounds` | 5 |
| `choosingTime` | 5 s per round to pick a color |
| Divider tween | 1.2 s (Quad InOut) |
| Elimination window | 3 s (color goes non-collidable + transparent) |

**GameModel parts required:**
- `Colors` — Folder of colored Platform Parts (each named after its color, e.g. `"Red"`)
- `Divider.Base` — Part that tweens up to open the arena
- `Lava` — Kill zone (`.Touched → _G.KillFunction`)

**Flow per round:**
1. Countdown (`choosingTime` seconds) — players pick a color
2. Divider closes (tweens down)
3. Random color chosen → its Part becomes transparent + non-collidable for 3 s
4. Divider opens → survivors continue

---

## 7. Capture The Flag (`Capture The Flag.luau`)

**Concept:** Team PvP. Steal the enemy flag and return it to your base to win. Uses swords.

**Win condition:** Team that captures the enemy flag wins → wins added manually for each team member. Tie if timer expires (`roundTime`) with no capture.

**Key parameters:**
| Constant | Value |
|----------|-------|
| `prepTime` | 2 s (walls up, no swords) |
| `roundTime` | 100 s |
| `carrierDebuff` | −6 WalkSpeed for flag carrier |

**GameModel parts required:**
- `Flags` — Folder containing flag Models (named `"Red"` and `"Blue"`)
  - Each flag has a `HitBox` Part for touch detection
- `RedSpawn` / `BlueSpawn` — Team spawn points
- `Walls` — Model destroyed when prep ends
- `Markers` — Folder where Highlights and BillboardGuis are parented
- `Rocks` — Decorative Model
- `Base` — Base Part

**Tools & Modules:**
- `script.ClassicSword` — Classic sword Tool cloned into each player's character at game start
- `script.FlaggedMarker` — BillboardGui shown above flag carrier's head

**Team mechanics:**
- Teams alternate Red/Blue by toggling a `switch` bool while iterating `Players:GetPlayers()`
- `plr.Character:SetAttribute("Team", "Red"/"Blue")` used for flag touch validation
- Highlights (`Highlight` instance) added to each player's character (colored by team)
- **Respawn:** Players respawn at team spawn with a new sword; `Humanoid.Died:Once` re-fires `onDeath()`

**Flag mechanics:**
- Carrier picks up flag → `flag.Parent = nil` (removed from Flags folder) + WalkSpeed reduced
- Carrier dies → flag returns to `Flags` folder, `BillboardGui` destroyed
- Carrier touches own team's base → win registered

**Notes:**
- Does NOT use `BasicEnding()` — wins are awarded manually
- Swords dictionary is `swords[player.UserId] = swordInstance` for reliable lookup across respawns
- All connections (`deathConns`, `flagConns`) are explicitly disconnected at game end
- Known bug: when `blueCarrier` restores WalkSpeed at game end, the code references `redCarrier` instead of `blueCarrier` (line ~207)

---

## Mini-Game Comparison

| Game | Win Condition | Uses BasicEnding | Custom Powers | Respawn | Timer |
|------|--------------|-----------------|---------------|---------|-------|
| Lava Rising | Survive timer | Yes | No | No | 28 s |
| Tile Dash | Survive timer | Yes | No | No | 35 s |
| Boulder Run | Reach top first | **No** | No | No | 60 s |
| Spleef | Last standing | Yes | No | No | Until 1 left |
| Infection Tag | Survive/infect | **No** (manual) | ExtraSpeed disabled | No | 60 s |
| Crazy Colors | Survive rounds | Yes | No | No | 5 rounds |
| Capture The Flag | Capture flag | **No** (manual) | No | **Yes** | 100 s |
