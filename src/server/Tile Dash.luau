local TileDash = {}
local gameModel = script:WaitForChild("GameModel")

local TweenService = game:GetService("TweenService")

local gameTime = 35
local startingWarnTime = .75
local warnTimeDecrease = .8
local dropAnimationCount = 3
local tilesToFall = 6
local tileWarningColor = Color3.fromRGB(255, 73, 49)

local tileTweenInfo = TweenInfo.new(
    .7,
    Enum.EasingStyle.Quint,
    Enum.EasingDirection.Out,
    0,
    true
)

-- formule

function TileDash.RunGame()

    -- Setup game
    local newGame = gameModel:Clone()
    newGame.Parent = workspace
    newGame.KillBrick.Touched:Connect(_G.KillFunction)
end)

return TileDash