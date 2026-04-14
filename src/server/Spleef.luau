local Spleef = {}
local gameModel = script.GameModel
local tileSize = gameModel:FindFirstChild("Tile", true).Size

local RUNNING = false
local roundTime = 60

local minusHeight = .4

local TweenService = game:GetService("TweenService")
tileAnimationInfo = TweenInfo.new(
    .3,
    Enum.EasingStyle.Quart,
    Enum.EasingDirection.Out,
    0,
    true
)

gameModel.KillBrick.Touched:Connect(_G.KillFunction)

local hitTiles = {}

for i, tile in ipairs(gameModel.Levels:GetDescendants()) do
    if tile.ClassName ~= "Part" then continue end

    tile.Touched:Connect(function(hit)

        if not hit.Parent:FindFirstChild("Humanoid") then return end
        if not RUNNING then return end
        if table.find(hitTiles, tile) then return end
        table.insert(hitTiles, tile)

        local Anim = TweenService:Create(
            tile,
            tileAnimationInfo,
            {CFrame = tile.CFrame - Vector3.yAxis*.5, Size = tile.Size - Vector3.one*.2}
        )

        Anim:Play()
        Anim:GetPropertyChangedSignal("PlaybackState"):Wait()

        tile.Transparency = 1
        tile.CanCollide = false

    end)

end

function Spleef.RunGame()

    local spawnPoint = gameModel.Spawn
    spawnPoint.Parent = workspace
    task.wait()

    gameModel.Parent = workspace


    _G.TeleportPlayers(spawnPoint.CFrame + Vector3.yAxis* 10, true)

    local players = workspace.InGame:GetChildren()
    for i, char in ipairs(players) do
        char.Humanoid.HipHeight -= minusHeight
    end

    for countDown = 10, 1, -1 do
        task.wait(1)
        _G.gameStatus.Value = "Game starting in " .. countDown
    end

    RUNNING = true

    local spawnTransparency = spawnPoint.Transparency
    spawnPoint.Transparency = 1
    spawnPoint.CanCollide = false
    spawnPoint.Parent = gameModel

    _G.gameStatus.Value = "Last one alive wins!"

    while #workspace.InGame:GetChildren() > 1 do
        workspace.InGame.ChildRemoved:Wait()
    end

    RUNNING = false
    _G.BasicEnding()

    for i, char in ipairs(players) do
        if char then
            char.Humanoid.HipHeight += minusHeight
        end
    end

    gameModel.Parent = script

    coroutine.wrap(function()
        for i, tile in ipairs(hitTiles) do
            
            tile.Size = tileSize
            tile.Transparency = 0
            tile.CanCollide = true

        end
    end)()

    table.clear(hitTiles)

    spawnPoint.Transparency = spawnTransparency
    spawnPoint.CanCollide = true

end

return Spleef
