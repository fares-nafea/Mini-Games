local MiniGame = {}
local gameModel = script:WaitForChild("GameModel")

local riseTime = 10
local riseDelay = 3

local TweenService = game:GetService("TweenService")
local riseTweenInfo = TweenInfo.new(
    riseTime,
    Enum.EasingStyle.Linear,
    Enum.EasingDirection.InOut,
    0,
    false,
    riseDelay
)

function MiniGame.RunGame()

    -- Set up game
    local newGame = gameModel:Clone()
    newGame.Parent = workspace

    newGame.Lava.Touched:Connect(LavaTouched)

    local riseTween = TweenService:Create(
        newGame.Lava,
        riseTweenInfo,
        {CFrame = newGame.RisePosition.CFrame}

    )

    -- Start Game
    _G.TeleportPlayers(newGame.SpawnPoint.CFrame, true)

    riseTween:Play()

    -- Count down
    for countDown = riseTime + riseDelay, 0, -1 do

        _G.gameStatus.Value = "Get to the top ( "..countDown.." )"
        task.wait(1)

    end

    -- End game
    local winners = workspace.InGame:GetChildren()
    local endText = "The Winners are: "

    for i, plr in ipairs(winners) do

        endText = endText .. plr.Name .. " "

    end

    _G.gameStatus.Value = endText
    task.wait(3)

    newGame:Destroy()
end

function LavaTouched(hit)

    local humanoid = hit.Parent:FindFirstChild("Humanoid")
    if humanoid then

        humanoid.Health = 0

    end

end

return MiniGame
