local Items = game.ServerStorage:WaitForChild("Items")
local ItemPurchased = game.ReplicatedStorage:WaitForChild("Events"):WaitForChild("ItemPurchased")
local Powers = require(game.ServerStorage:WaitForChild("Powers"))

ItemPurchased.OnServerInvoke = function(player, frame)
    local playerCharacter = player.Character
    if not playerCharacter then return end

    local itemInfo = frame:GetAttributes()
    local playerWins = player.leaderstats.Wins.Value

    -- لو الفلوس أقل من السعر → ارجع فورًا
    if playerWins < itemInfo["Price"] then return end

    local success = false

    if itemInfo["Type"] == "Aura" then
        success = ItemPurchase(player, playerCharacter, itemInfo, playerWins)

    elseif itemInfo["Type"] == "Powers" and not player.CurrentPower.Value then
        success = PowerPurchased(player, playerCharacter, itemInfo, playerWins)
        if success then
            player.CurrentPower.Value = true
        end
    end

    -- خصم Wins فقط لو الشراء نجح
    if success then
        player.leaderstats.Wins.Value -= itemInfo["Price"]
        return "Successful"
    end
end

function ItemPurchase(player, playerCharacter, itemInfo, playerWins)
    local chosenItem = Items:FindFirstChild(itemInfo["Name"])
    if not chosenItem then
        warn(itemInfo["Name"], "does not exist")
        return false
    end

    -- لو عند اللاعب Item حالي → شوف لو نفس الـ Item
    if player.CurrentItem.Value then
        if player.CurrentItem.Value.Name == itemInfo["Name"] then
            return false
        end
        player.CurrentItem.Value:Destroy()
    end

    local equippedItem = chosenItem:Clone()
    equippedItem.Parent = playerCharacter:FindFirstChild("HumanoidRootPart")
    player.CurrentItem.Value = equippedItem

    -- إضافة الـ Item في مجلد اللاعب لو مش موجود
    if not player.Items:FindFirstChild(itemInfo["Name"]) then
        local newItemValue = Instance.new("StringValue")
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