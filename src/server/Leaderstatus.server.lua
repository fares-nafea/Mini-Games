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

    local currentPower = Instance.new("ObjectValue", player)
    currentPower.Name = "CurrentPower"

    player.CharacterAdded:Connect(function()
        currentItem.Value = nil
        if player.Character then
            player.Character.Humanoid.Died:Once(function()
                local power = currentPower.Value
                if power then
                    power:Destroy()
                end
            end)
        end
    end)

    -- Load data if it exits
    local winsOk, plrWinsData = pcall(function()
        return WinsDataStore:GetAsync(player.UserId)
    end)
    if winsOk and plrWinsData then
        winsStat.Value = plrWinsData
    elseif not winsOk then
        warn("Failed to load wins for", player.Name, ":", plrWinsData)
    end

    local itemsOk, itemsData = pcall(function()
        return ItemDataStore:GetAsync(player.UserId)
    end)
    if itemsOk and itemsData then
        for i, savedItem in ipairs(itemsData) do
            local itemValue = Instance.new("StringValue", itemsFolder)
            itemValue.Name = savedItem
        end
    elseif not itemsOk then
        warn("Failed to load items for", player.Name, ":", itemsData)
    end

end)

local function SaveData(player)

    local currentWins = player.leaderstats.Wins.Value
    local winsOk, winsErr = pcall(function()
        WinsDataStore:SetAsync(player.UserId, currentWins)
    end)
    if not winsOk then
        warn("Failed to save wins for", player.Name, ":", winsErr)
    end

    -- Saved Items
    local savedItems = {}
    for i, itemValue in ipairs(player.Items:GetChildren()) do
        table.insert(savedItems, itemValue.Name)
    end

    local itemsOk, itemsErr = pcall(function()
        ItemDataStore:SetAsync(player.UserId, savedItems)
    end)
    if not itemsOk then
        warn("Failed to save items for", player.Name, ":", itemsErr)
    end
end

Players.PlayerRemoving:Connect(SaveData)

-- Back up save
game:BindToClose(function()
    for i, plr in ipairs(Players:GetPlayers()) do

        SaveData(plr)

    end
end)