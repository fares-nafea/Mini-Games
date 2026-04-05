local Players = game:GetService("Players")

local DataStoreService = game:GetService("DataStoreService")
local WinsDataStore = DataStoreService:GetOrderedDataStore("WinsData-2")
local ItemDataStore = DataStoreService:GetDataStore("Items-2")

Players.PlayerAdded:Connect(function(player)

    local leaderstatsFolder = Instance.new("Folder", player)
    leaderstatsFolder.Name = "leaderstats"

    local winsStat = Instance.new("NumberValue", leaderstatsFolder)
    winsStat.Name = "Wins"

    local itemsFolder = Instance.new("Folder", player)
    itemsFolder.Name = "Items"

    local currentItem = Instance.new("ObjectValue", player)
    currentItem.Name = "CurrentItem"

    local currentPower = Instance.new("BoolValue", player)
    currentPower.Name = "CurrentPower"

    -- Load data if it exits
    local plrWinsData = WinsDataStore:GetAsync(player.UserId)

    if plrWinsData then
        winsStat.Value = plrWinsData
    end

    local itemsData = ItemDataStore:GetAsync(player.UserId)

    if itemsData then
        for i, savedItem in ipairs(itemsData) do

            local itemValue = Instance.new("StringValue", itemsFolder)
            itemValue.Name = savedItem

        end
    end

    player.CharacterAdded:Connect(function()
        currentItem.Value = nil
        currentPower.Value = nil
    end)

end)

local function SaveData(player)

    local currentWins = player.leaderstats.Wins.Value
    WinsDataStore:SetAsync(player.UserId, currentWins)

    -- Saved Items
    local savedItems = {}

    local playersItems = player.Items:GetChildren()
    for i, itemValue in ipairs(playersItems) do

        table.insert(savedItems, itemValue.Name)

    end

    ItemDataStore:SetAsync(player.UserId, savedItems)
end

Players.PlayerRemoving:Connect(SaveData)

-- Back up save
game:BindToClose(function()
    for i, plr in ipairs(Players:GetPlayers()) do

        SaveData(plr)

    end
end)