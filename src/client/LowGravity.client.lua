local LowGravityEvent = game.ReplicatedStorage:WaitForChild("Events"):WaitForChild("LowGravity")
local gravityMod = 175

LowGravityEvent.OnClientEvent:Connect(function(powerTime)

    workspace.Gravity -= gravityMod
    task.wait(powerTime)
    workspace.Gravity += gravityMod
    
end)