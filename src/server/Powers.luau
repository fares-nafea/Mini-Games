local Powers = {}

local lowGravityEvent = game.ReplicatedStorage:WaitForChild("Events"):WaitForChild("LowGravity")
local gravityTime = 30

-- LowGravity Power
function Powers.LowGravity(player, plrChar)

    local root = plrChar:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local effect = script:FindFirstChild("LowGravity")
    if not effect then return end

    effect = effect:Clone()
    effect.Parent = root

    -- Fire client to handle low gravity
    lowGravityEvent:FireClient(player, gravityTime)

    -- Wait power duration
    task.wait(gravityTime)

    -- Cleanup
    if effect then
        effect:Destroy()
    end

    -- Unlock power
    if player and player:FindFirstChild("CurrentPower") then
        player.CurrentPower.Value = false
    end
end


-- ExtraSpeed Power
local speedBonus = 10
local speedTime = 60

function Powers.ExtraSpeed(player, plrChar)

    local humanoid = plrChar:FindFirstChild("Humanoid")
    local root = plrChar:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return end

    local effect = script:FindFirstChild("ExtraSpeed")
    if not effect then return end

    effect = effect:Clone()
    effect.Parent = root

    humanoid.WalkSpeed = humanoid.WalkSpeed + speedBonus

    task.wait(speedTime)

    -- Restore WalkSpeed
    if humanoid then
        humanoid.WalkSpeed = humanoid.WalkSpeed - speedBonus
    end

    if effect then
        effect:Destroy()
    end

    -- Unlock power
    if player and player:FindFirstChild("CurrentPower") then
        player.CurrentPower.Value = false
    end
end


-- Generic safe call for any power
function Powers.ActivatePower(powerName, player, plrChar)
    local powerFunction = Powers[powerName]
    if not powerFunction then
        warn("Power not found:", powerName)
        if player and player:FindFirstChild("CurrentPower") then
            player.CurrentPower.Value = false
        end
        return
    end

    local success, err = pcall(function()
        powerFunction(player, plrChar)
    end)

    if not success then
        warn("Error activating power:", powerName, err)
        if player and player:FindFirstChild("CurrentPower") then
            player.CurrentPower.Value = false
        end
    end
end

return Powers