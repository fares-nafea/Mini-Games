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

        player.leaderstats.Wins.Value -= itemInfo["Price"]

        if ItemPurchased(player, playerCharacter, itemInfo, playerWins) == false then
            return
        end

        if player.Items:FindFirstChild(itemInfo["Name"]) then
            return
        end


    elseif itemInfo["Type"] == "Power" and player.CurrentPower.Value == false then

        player.leaderstats.Wins.Value -= itemInfo["Price"]

        player.CurrentPower.Value = true
        PowerPurchased(player, playerCharacter, itemInfo, playerWins)


    else
        return
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

    local success, powerError = pcall(function()

        Powers[itemInfo["Name"]](player, playerCharacter)

    end)

    if not success then
        warn(player, powerError)
    end
end