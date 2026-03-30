local localPlayer = game.Players.LocalPlayer
local leaderstats = localPlayer:WaitForChild("leaderstats")

local StatsGui = script.Parent

local WinsFrame = StatsGui:WaitForChild("Wins")
local WinsLabel = WinsFrame:WaitForChild("WinsLabel")

local function UpdateWins()

    local currentWins = leaderstats.Wins.Value
    WinsLabel.Text = currentWins

end

UpdateWins()
leaderstats.Wins:GetPropertyChangedSignal("Value"):Connect(UpdateWins)