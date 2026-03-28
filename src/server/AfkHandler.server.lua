local AfkEvent = game.ReplicatedStorage:WaitForChild("Events"):WaitForChild("AfkMode")

AfkEvent.OnServerEvent:Connect(function(pleyer)

    local isAfk = pleyer:GetAttribute("AFK")
    pleyer:SetAttribute("AFK", not isAfk)
    
end)