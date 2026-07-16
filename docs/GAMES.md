# Mini-Games — Per-Game Reference

All game modules live in `src/server/` and are registered under `ServerStorage.MiniGames` via `default.project.json`. Each exports a `RunGame()` function.

**Empty-game early exit:** In Lava Rising, Tile Dash, Crazy Colors, and Capture The Flag, the main countdown loop checks `#workspace.InGame:GetChildren() == 0` each tick and `break`s immediately if everyone has left/died, instead of waiting out the full timer. Spleef and BombTag get the same effect naturally since their loops already exit once `<= 1` player remains. When no one survives, `BasicEnding()` sets `_G.gameStatus.Value = "No winners"` instead of an empty "The Winners are: " string.

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

## 3. Spleef (`Spleef.luau`)

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

## 4. Bomb Tag (`BombTag.luau`)

**Concept:** One random player starts holding the bomb. Touching the bomb holder passes it to you. When the timer runs out, whoever is holding it dies. Repeats until one player is left.

**Win condition:** Loop while `#getAlivePlayers() > 1` (alive = in `workspace.InGame` with `Humanoid.Health > 0`) → `BasicEnding()`.

**Key parameters:**
| Constant | Value |
|----------|-------|
| `BOMB_TIME` | 10 s per holder before it explodes |
| `PASS_COOLDOWN` | 0.3 s (prevents instant bounce-back after a pass) |

**GameModel parts required:**
- `Spawn` — Player spawn point
- `Lava` — Kill zone (`.Touched → _G.KillFunction`)
- `BOMB` — Model containing:
  - `Bomb` — Part welded (`Motor6D`) to the holder's `RightHand`
  - `Highlight` — Adorned to the current holder
  - `PointLight`, `Tick` sound, `Boom` sound — blink/speed up as the timer runs down
  - `Attachment.Explosion` — ParticleEmitter fired when the bomb goes off

**Notes:**
- 3 s "Bomb Tag starting in..." prep countdown before the bomb is live
- If fewer than 2 players are alive when the round would start, the game model is destroyed and `RunGame()` returns immediately without calling `BasicEnding()` (mirrors `MiniGame.MinPlayers = 2`)
- Tick sound `PlaybackSpeed` and `PointLight` blink rate both ramp up as `timeLeft` approaches 0
- On explosion the holder's `Humanoid.Health` is set to `0`; a new holder is picked from remaining alive players and the round continues

---

## 5. Crazy Colors (`CrazyColors.luau`)

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

## 6. Capture The Flag (`Capture The Flag.luau`)

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

---

## Mini-Game Comparison

| Game | Win Condition | Uses BasicEnding | Custom Powers | Respawn | Timer |
|------|--------------|-----------------|---------------|---------|-------|
| Lava Rising | Survive timer | Yes | No | No | 28 s |
| Tile Dash | Survive timer | Yes | No | No | 35 s |
| Spleef | Last standing | Yes | No | No | Until 1 left |
| Bomb Tag | Last standing | Yes | No | No | 10 s per holder |
| Crazy Colors | Survive rounds | Yes | No | No | 5 rounds |
| Capture The Flag | Capture flag | **No** (manual) | No | **Yes** | 100 s |
