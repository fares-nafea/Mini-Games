local MiniGame = {}
local gameModel = script:WaitForChild("GameModel")

local riseTime = 25
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

    newGame.Lava.Touched:Connect(_G.KillFunction)

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

        if #workspace.InGame:GetChildren() == 0 then break end

        _G.gameStatus.Value = "Get to the top ( "..countDown.." )"
        task.wait(1)

    end

    -- End game
    _G.BasicEnding()

    newGame:Destroy()
end

MiniGame.MinPlayers = 1

return MiniGame
