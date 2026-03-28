local localPlayer = game.Players.LocalPlayer

local afkEvent = game.ReplicatedStorage:WaitForChild("Events"):WaitForChild("AfkMode")
local afkButton = script.Parent:WaitForChild("AfkButton")
local afkStatusLabel = afkButton:WaitForChild("AfkStatus")

afkButton.Activated:Connect(function()

    afkEvent:FireServer()

end)

localPlayer:GetAttributeChangedSignal("AFK"):Connect(function()

    local isAfk = localPlayer:GetAttribute("AFK")

    if isAfk then
        afkStatusLabel.Text = "On"
        afkStatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)

    else
        afkStatusLabel.Text = "Off"
        afkStatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)

    end 

end)