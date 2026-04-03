local Powers = {}

local lowGravityEvent = game.ReplicatedStorage:WaitForChild("Events"):WaitForChild("LowGravity")
local gravityTime = 30

function Powers.LowGravity(player, plrChar)

    local effect = script.LowGravity:Clone()
    effect.Parent = plrChar.HumanoidRootPart

    lowGravityEvent:FireClient(player, gravityTime)

    task.wait(gravityTime)

    effect:Destroy()
    player.CurrentPower.Value = false

end


-- Extra Speed
local speedBonus = 10
local speedTime = 60

function Powers.ExtraSpeed(player, plrChar)

    local effect = script.ExtraSpeed:Clone()
    effect.Parent = plrChar.HumanoidRootPart

    plrChar.Humanoid.WalkSpeed += speedBonus

    task.wait(speedTime)

    plrChar.Humanoid.WalkSpeed -= speedBonus

    effect:Destroy()
    player.CurrentPower.Value = false
end

return Powers