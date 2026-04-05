local Items = game.ServerStorage:WaitForChild("Items")
local ItemPurchased = game.ReplicatedStorage:WaitForChild("Events"):WaitForChild("ItemPurchased")
local Powers = require(game.ServerStorage:WaitForChild("Powers"))


ItemPurchased.OnServerInvoke = function(player, frame)

    local playerCharacter = player.Character
    if not playerCharacter then return end

    local itemInfo = frame:GetAttributes()
    local playerWins = player.leaderstats.Wins.Value

    if playerWins < itemInfo["Price"] then return end

    if itemInfo["Type"] == "Aura" then

        if HandleItemPurchase(player, playerCharacter, itemInfo, playerWins) == false then
            return
        end

        if player.Items:FindFirstChild(itemInfo["Name"]) then
            return
        end

    elseif itemInfo["Type"] == "Powers" and player.CurrentPower.Value == false then

        player.CurrentPower.Value = true
        PowerPurchased(player, playerCharacter, itemInfo, playerWins)

    else
        return
    end

    player.leaderstats.Wins.Value -= itemInfo["Price"]

    return "Successful"
end



function HandleItemPurchase(player, playerCharacter, itemInfo, playerWins)

    local chosenItem = Items:FindFirstChild(itemInfo["Name"])
    if not chosenItem then warn(itemInfo["Name"],"does not exist") return end

    if player.CurrentItem.Value then
        local oldItem = player.CurrentItem.Value
        player.CurrentItem.Value = nil
        oldItem:Destroy()

        if oldItem.Name == itemInfo["Name"] then
            return false
        end
    end

    local equippedItem = chosenItem:Clone()
    player.CurrentItem.Value = equippedItem

    local root = playerCharacter:FindFirstChild("HumanoidRootPart")
    if root then
        equippedItem.Parent = root
    end

    if not player.Items:FindFirstChild(itemInfo["Name"]) then
        local newItemValue = Instance.new("StringValue", player.Items)
        newItemValue.Name = itemInfo["Name"]

        return true
    end

    return false
end


function PowerPurchased(player, playerCharacter, itemInfo, playerWins)

    local powerFunction = Powers[itemInfo["Name"]]
    if not powerFunction then return end

    local success, powerError = pcall(function()
        powerFunction(player, playerCharacter)
    end)

    if not success then
        warn(player, powerError)
    end

end