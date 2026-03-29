local Players = game:GetService("Players")

local DataStoreService = game:GetService("DataStoreService")
local WinsDataStore = DataStoreService:GetOrderedDataStore("WinsData-0")

Players.PlayerAdded:Connect(function(player)

    local leaderstatsFolder = Instance.new("Folder", player)
    leaderstatsFolder.Name = "leaderstats"

    local winsStat = Instance.new("NumberValue", leaderstatsFolder)
    winsStat.Name = "Wins"

    -- Load data if it exits
    local plrWinsData = WinsDataStore:GetAsync(player.UserId)

    if plrWinsData then
        winsStat.Value = plrWinsData
    end

end)

local function SaveData(player)

    local currentWins = player.leaderstats.Wins.Value
    WinsDataStore:SetAsync(player.UserId, currentWins)

end

Players.PlayerRemoving:Connect(SaveData)

-- Back up save
game:BindToClose(function()
    for i, plr in ipairs(Players:GetPlayers()) do

        SaveData(plr)

    end
end)