local LowGravityEvent = game.ReplicatedStorage:WaitForChild("Events"):WaitForChild("LowGravity")
local gravityMod = 175

LowGravityEvent.OnClientEvent:Connect(function(powerTime)

    local originalGravity = workspace.Gravity

    workspace.Gravity = originalGravity - gravityMod

    task.wait(powerTime)

    workspace.Gravity = originalGravity
    
end)