local Spleef = {}

local roundTime = 60

local TweenService = game:GetService("TweenService")
tileAnimationInfo = TweenInfo.new(
    .3,
    Enum.EasingStyle.Quart,
    Enum.EasingDirection.Out,
    0,
    true
)

function Spleef.RunGame()

    local gameModel = script.GameModel:Clone()
    gameModel.Parent = workspace

    for i, tile in ipairs(gameModel.Levels:GetDescendants()) do
        if tile.ClassName ~= "Part" then continue end

        tile.Touched:Connect(function(hit)
            if tile:GetAttribute("Tweening") then return end
            if not hit.Parent:FindFirstChild("Humanoid") then return end
            tile:SetAttribute("Tweening", true)

            local Anim = TweenService:Create(
                tile,
                tileAnimationInfo,
                {CFrame = tile.CFrame - Vector3.yAxis*.5, Size = tile.Size - Vector3.one*.2}
            )

            Anim:Play()
            Anim:GetPropertyChangedSignal("PlaybackState"):Wait()

            tile:Destroy()

        end)

    end

    gameModel.KillBrick.Touched:Connect(_G.KillFunction)

    _G.TeleportPlayers(gameModel.SpawnPoint.CFrame + Vector3.yAxis* 10, true)

    for countDown = 10, 1, -1 do
        task.wait(1)
        _G.gameStatus.Value = "Game starting in " .. countDown
    end

    gameModel.SpawnPoint:Destroy()
    _G.gameStatus.Value = "Last one alive wins!"

    while #workspace.InGame:GetChildren() > 1 do
        workspace.InGame.ChildRemoved:Wait()
    end

    _G.BasicEnding()
    
end


return Spleef
