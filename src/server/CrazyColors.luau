local MiniGames = {}
local gamemodel = script:WaitForChild("GameModel")

local TweenService = game:GetService("TweenService")
local dividerTweenInfo = TweenInfo.new(
    1.2, 
    Enum.EasingStyle.Quad,
    Enum.EasingDirection.InOut
)

local totalRounds = 5
local choosingTime = 5

function MiniGames.RunGame()

    -- Set game
    local newGame = gamemodel:Clone()
    local dividerBase = newGame.Divider.Base
    local colors = newGame.Colors:GetChildren()
    newGame.Parent = workspace

    newGame.Lava.Touched:Connect(_G.KillFunction)

    local closeTween = TweenService:Create(
        dividerBase,
        dividerTweenInfo,
        {CFrame = dividerBase.CFrame}
    )

    local openTween = TweenService:Create(
        dividerBase,
        dividerTweenInfo,
        {CFrame = dividerBase.CFrame + Vector3.yAxis*25}
    )

    _G.TeleportPlayers(newGame.Colors.Red.CFrame + Vector3.yAxis*5, true)
    _G.gameStatus.Value = "Avoid the chosen color!"

    task.wait(2)
    openTween:Play()

    -- Start game
    for round = 1, totalRounds do
      if #workspace.InGame:GetChildren() == 0 then break end

      --choosing time
     for countDown = choosingTime,0,-1 do
        if #workspace.InGame:GetChildren() == 0 then break end
        _G.gameStatus.Value = "Round " .. round .. "; Pick a color (" .. countDown .. ")"
        task.wait(1)
    end

    if #workspace.InGame:GetChildren() == 0 then break end

    closeTween:Play()
    task.wait(1.2)

    -- Eliminate color
    local chosenColor = colors[math.random(1, #colors)]
    dividerBase.Color = chosenColor.Color

    chosenColor.CanCollide = false
    chosenColor.Transparency = 1
     
    task.wait(3)

    chosenColor.CanCollide = true
    chosenColor.Transparency = 0

    openTween:Play()

    end

    -- End game
    _G.BasicEnding()

    newGame:Destroy()
end


MiniGames.MinPlayers = 1

return MiniGames
