local TileFall = {}
local gameModel = script:WaitForChild("GameModel")

local TweenService = game:GetService("TweenService")

--// CONFIGURATION ----------------------------------------------------------
-- Every tunable number for this minigame lives here.

local EXPECTED_TILE_COUNT = 80     -- GameModel.Tiles should contain exactly this many tile parts
local GAME_DURATION = 35           -- Total round length, in seconds
local PREROUND_COUNTDOWN = 3       -- "Get ready" seconds before tiles start falling


local WAVE_START_DROP_COUNT = 10   -- Tiles dropped per wave at the start of the round
local WAVE_END_DROP_COUNT = 60     -- Tiles dropped per wave by the end of the round
local WARNING_TIME_START = 1       -- Total blink-warning duration at the start of the round
local WARNING_TIME_END = 0.4       -- Total blink-warning duration by the end of the round
local WAVE_INTERVAL_START = 1.4    -- Seconds between waves at the start of the round
local WAVE_INTERVAL_END = 0.4      -- Seconds between waves by the end of the round

local WARNING_BLINK_COUNT = 3      -- Number of on/off blinks during a tile's warning phase
local WARNING_COLOR = Color3.fromRGB(255, 45, 45)

local TILE_DROP_DISTANCE = 8       -- Studs a tile sinks down when it falls
local TILE_DROP_TIME = 0.35        -- Seconds for the drop tween
local TILE_RETURN_TIME = 0.45      -- Seconds for the return tween
local SUBMERGED_TRANSPARENCY = 0.65 -- Transparency applied while a tile is down
local SUBMERGED_WAIT_MIN = 0.3     -- Minimum time a tile stays down before resetting
local SUBMERGED_WAIT_MAX = 0.7     -- Maximum time a tile stays down before resetting

local SELECTION_ATTEMPT_MULTIPLIER = 8 -- Caps random-selection retries per wave (perf safety net)

local DROP_TWEEN_INFO = TweenInfo.new(TILE_DROP_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local RETURN_TWEEN_INFO = TweenInfo.new(TILE_RETURN_TIME, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local DROP_OFFSET = Vector3.yAxis * TILE_DROP_DISTANCE

--// HELPERS ------------------------------------------------------------------

local function Lerp(startValue, endValue, alpha)
    return startValue + (endValue - startValue) * alpha
end

--// MAIN GAME LOOP -----------------------------------------------------------

function TileFall.RunGame()

    -- Set up the arena, cloned exactly like every other minigame in this framework.
    local newGame = gameModel:Clone()
    newGame.Parent = workspace
    newGame.Lava.Touched:Connect(_G.KillFunction)

    -- Cache every tile once and record its original state (position, color,
    -- transparency). The wave loop below only ever reads from these cached
    -- tables, so it never has to touch Attributes or recompute anything.
    local cachedTiles = newGame.Tiles:GetChildren()
    local tileCount = #cachedTiles

    if tileCount ~= EXPECTED_TILE_COUNT then
        warn(("TileFall: expected %d tiles but found %d - continuing anyway"):format(EXPECTED_TILE_COUNT, tileCount))
    end

    local originalPositions = table.create(tileCount)
    local originalColors = table.create(tileCount)
    local originalTransparency = table.create(tileCount)

    for _, tile in ipairs(cachedTiles) do
        originalPositions[tile] = tile.Position
        originalColors[tile] = tile.Color
        originalTransparency[tile] = tile.Transparency
    end

    -- activeTiles doubles as both a "this tile is mid-animation" guard (so a
    -- new wave can never grab a tile that's already tweening - the race
    -- condition the spec calls out) and a registry of the coroutine driving
    -- it, so every straggling animation can be cancelled the instant the
    -- round ends.
    local activeTiles = {}
    local waveSelectionBuffer = table.create(WAVE_END_DROP_COUNT)

    -- Teleport players onto the platform.
    _G.TeleportPlayers(newGame.Spawn.CFrame, true)

    -- Pre-round countdown.
    for countDown = PREROUND_COUNTDOWN, 1, -1 do
        _G.gameStatus.Value = "Tiles start falling in " .. countDown
        task.wait(1)
    end

    -- Picks up to desiredCount tiles that are not already mid-animation.
    -- Reuses waveSelectionBuffer every call instead of allocating a new
    -- table each wave.
    local function SelectWaveTiles(desiredCount)
        table.clear(waveSelectionBuffer)
        if desiredCount <= 0 then
            return waveSelectionBuffer
        end

        local maxAttempts = desiredCount * SELECTION_ATTEMPT_MULTIPLIER
        local attempts = 0

        while #waveSelectionBuffer < desiredCount and attempts < maxAttempts do
            attempts += 1
            local candidate = cachedTiles[math.random(1, tileCount)]
            if not activeTiles[candidate] then
                activeTiles[candidate] = true
                waveSelectionBuffer[#waveSelectionBuffer + 1] = candidate
            end
        end

        return waveSelectionBuffer
    end

    -- Runs one tile's full blink -> drop -> submerge -> return cycle, then
    -- frees the tile so a later wave may pick it again.
    local function AnimateTileDrop(tile, warningDuration)
        local originalPosition = originalPositions[tile]
        local originalColor = originalColors[tile]

        -- Warning: blink between the tile's normal color and the warning color.
        local blinkInterval = warningDuration / (WARNING_BLINK_COUNT * 2)
        for _ = 1, WARNING_BLINK_COUNT do
            tile.Color = WARNING_COLOR
            task.wait(blinkInterval)
            tile.Color = originalColor
            task.wait(blinkInterval)
        end

        -- Drop: turn off collision so players fall through, then tween down.
        tile.CanCollide = false
        TweenService:Create(tile, DROP_TWEEN_INFO, {
            Position = originalPosition - DROP_OFFSET,
            Transparency = SUBMERGED_TRANSPARENCY,
        }):Play()
        task.wait(DROP_TWEEN_INFO.Time)

        -- Stay submerged for a short random beat before resetting.
        task.wait(SUBMERGED_WAIT_MIN + math.random() * (SUBMERGED_WAIT_MAX - SUBMERGED_WAIT_MIN))

        -- Return: tween back to the original spot and restore collision.
        TweenService:Create(tile, RETURN_TWEEN_INFO, {
            Position = originalPosition,
            Transparency = originalTransparency[tile],
        }):Play()
        task.wait(RETURN_TWEEN_INFO.Time)
        tile.CanCollide = true

        activeTiles[tile] = nil
    end

    -- Background loop: keeps spawning waves with escalating difficulty
    -- (more tiles per wave, shorter warnings, shorter gaps between waves)
    -- until the round timer runs out.
    local roundStartClock = os.clock()
    local roundActive = true

    local waveThread = task.spawn(function()
        while roundActive do
            local elapsed = os.clock() - roundStartClock
            local progress = math.clamp(elapsed / GAME_DURATION, 0, 1)

            local dropCount = math.clamp(
                math.floor(Lerp(WAVE_START_DROP_COUNT, WAVE_END_DROP_COUNT, progress) + 0.5),
                1,
                tileCount
            )
            local warningDuration = Lerp(WARNING_TIME_START, WARNING_TIME_END, progress)
            local waveInterval = Lerp(WAVE_INTERVAL_START, WAVE_INTERVAL_END, progress)

            local selectedTiles = SelectWaveTiles(dropCount)
            for _, tile in ipairs(selectedTiles) do
                activeTiles[tile] = task.spawn(AnimateTileDrop, tile, warningDuration)
            end

            task.wait(waveInterval)
        end
    end)

    -- Foreground loop: drives the visible countdown and bails out early if
    -- everyone has left the arena.
    for countDown = GAME_DURATION, 1, -1 do
        if #workspace.InGame:GetChildren() == 0 then break end
        _G.gameStatus.Value = "Survive the falling tiles! " .. countDown
        task.wait(1)
    end

    -- Round over: stop generating new waves and cancel any tile animation
    -- still mid-flight so nothing keeps running against a destroyed model.
    roundActive = false
    task.cancel(waveThread)

    for _, activeThread in pairs(activeTiles) do
        if type(activeThread) == "thread" then
            task.cancel(activeThread)
        end
    end

    _G.BasicEnding()

    newGame:Destroy()
end

TileFall.MinPlayers = 1

return TileFall

