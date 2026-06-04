local Powers = {}

 -- Low Gravity
local lowGravityEvent = game.ReplicatedStorage:WaitForChild("Events"):WaitForChild("LowGravity")
local defaultGravity = workspace.Gravity
local setGravity = 25
local gravityTime = 30

function Powers.LowGravity(player, plrChar)

    local effect = script.LowGravity:Clone()
    effect.Parent = plrChar.HumanoidRootPart

    lowGravityEvent:FireClient(player, setGravity)

    coroutine.wrap(function()
        task.wait(gravityTime)
        effect:Destroy()
    end)()

    return {effect, function()
        lowGravityEvent:FireClient(player, defaultGravity)
    end}
end

-- Extra Speed
local speedBonus = 10
local speedTime = 10

function Powers.ExtraSpeed(player, plrChar)

    local effect = script.ExtraSpeed:Clone()
    effect.Parent = plrChar.HumanoidRootPart

    plrChar.Humanoid.WalkSpeed += speedBonus

    coroutine.wrap(function()
        task.wait(speedTime)
        effect:Destroy()
    end)()

    return {effect, function()
        plrChar.Humanoid.WalkSpeed -= speedBonus
    end}
end

return Powers
