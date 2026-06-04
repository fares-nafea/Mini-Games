local Items = game.ServerStorage:WaitForChild("Items")
local ItemPurchased = game.ReplicatedStorage:WaitForChild("Events"):WaitForChild("ItemPurchased")
local Powers = require(game.ServerStorage:WaitForChild("Powers"))


ItemPurchased.OnServerInvoke = function(player, frame)

    local playerCharacter = player.Character
    if not playerCharacter then return end

    local itemInfo = frame:GetAttributes()
    local playerWins = player.leaderstats.Wins.Value

    -- print

    if playerWins < itemInfo["Price"] then return end

    if itemInfo["Type"] == "Aura" then

        if ItemPurchased(player, playerCharacter, itemInfo, playerWins) == false then
            return "Successful"
        end

    elseif itemInfo["Type"] == "Power" then

        return PowerPurchased(player, playerCharacter, itemInfo, playerWins)

    else
        return "Item type not found"
    end

    player.leaderstats.Wins.Value -= itemInfo["Price"]
    
    return "Successful"
end



function ItemPurchased(player, playerCharacter, itemInfo, playerWins)

    local chosenItem = Items:FindFirstChild(itemInfo["Name"])
    if not chosenItem then warn(itemInfo["Name"], "does not exist") return end

    -- Equip
    if player.CurrentItem.Value then
        player.CurrentItem.Value:Destroy()

        if player.CurrentItem.Value.Name == itemInfo["Name"] then
            return false
        end
    end

    local equippedItem = chosenItem:Clone()
    player.CurrentItem.Value = equippedItem

    equippedItem.Parent = playerCharacter.HumanoidRootPart

    if not player.Items:FindFirstChild(itemInfo["Name"]) then
        local newItemValue = Instance.new("StringValue", player.Items)
        newItemValue.Name = itemInfo["Name"]

        return true
    end

    return false

end


function PowerPurchased(player, playerCharacter, itemInfo, playerWins)

    if _G[itemInfo["Name"]] == "DISABLED" then
        return "This power is disabled for this game"
    end
    if player.CurrentPower.Value then
        return "A Power is already active"
    end

    local success, powerError = pcall(function()

        local args = Powers[itemInfo["Name"]](player, playerCharacter)
        player.CurrentPower.Value = args[1]

        args[1].Destroying:Connect(function()
            player.CurrentPower.Value = nil
            args[2]() -- Reverse power
        end)
    end)

    if success then
        return itemInfo['Name'] .. " activated"
    else
        return 'Error during purchase'
    end

end