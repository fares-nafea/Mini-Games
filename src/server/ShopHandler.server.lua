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
            return
        end

        if player.Items:FindFirstChild(itemInfo["Name"]) then
            return
        end

    elseif itemInfo["Type"] == "Power" and player.CurrentPower.Value == false then

        player.CurrentPower.Value = true
        PowerPurchased(player, playerCharacter, itemInfo, playerWins)

    else
        return
    end

    player.leaderstats.Wins.Value -= itemInfo["Price"]

    return "Successful"
end



function ItemPurchase(player, playerCharacter, itemInfo, playerWins)

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
        newItemValue.Parent = player.Items
    end

    return true
end

function PowerPurchased(player, playerCharacter, itemInfo, playerWins)
    local powerFunction = Powers[itemInfo["Name"]]
    if not powerFunction then return false end

    local success, powerError = pcall(function()
        powerFunction(player, playerCharacter)
    end)

    if not success then
        warn(player, powerError)
        return false
    end

    return true
end