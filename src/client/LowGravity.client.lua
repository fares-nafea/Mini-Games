local LowGravityEvent = game.ReplicatedStorage:WaitForChild("Events"):WaitForChild("LowGravity")

LowGravityEvent.OnClientEvent:Connect(function(newGravity)

    workspace.Gravity = newGravity

end)