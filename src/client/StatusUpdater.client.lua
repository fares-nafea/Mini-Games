local gameStatus = game.ReplicatedStorage:WaitForChild("GameStatus")
local statusLabel = script.Parent:WaitForChild("StatusLabel")

local function UpdateLabel()

    local status = gameStatus.Value
    statusLabel.Text = status

end

UpdateLabel()
gameStatus:GetPropertyChangedSignal("Value"):Connect(UpdateLabel)