local Items = game.ServerStorage:WaitForChild("Items")
local ItemPurchasedRemote = game.ReplicatedStorage:WaitForChild("Events"):WaitForChild("ItemPurchased")
local Powers = require(game.ServerStorage:WaitForChild("Powers"))

ItemPurchasedRemote.OnServerInvoke = function(player, frame)

	local playerCharacter = player.Character
	if not playerCharacter and not playerCharacter:FindFirstChild("HumanoidRootPart") then
		return 'Invalid character' 
	end

	local itemInfo = frame:GetAttributes()
	local playerWins = player.leaderstats.Wins.Value

	-- User has enough wins
	local canBuy = playerWins >= itemInfo["Price"]
	
	-- Equip / Activate
	local result = "Successful"
	local shouldCharge = false
	
	if itemInfo["Type"] == "Aura" and (player.Items:FindFirstChild(itemInfo["Name"]) or canBuy) then 
		result, shouldCharge = ItemPurchased(player, playerCharacter, itemInfo, canBuy)
	elseif itemInfo["Type"] == "Power" and canBuy then
		result, shouldCharge = PowerPurchased(player, playerCharacter, itemInfo)
	else
		return "Not enough wins to purchase"
	end
	
	-- do not charge in case of error
	if not result then
		return "Error during purchase"
	end

	-- return message and charge if needed
	if shouldCharge then
		player.leaderstats.Wins.Value -= itemInfo["Price"]
	end
	
	return result
end

function ItemPurchased(player, playerCharacter, itemInfo, needsBought)

	local chosenItem = Items:FindFirstChild(itemInfo["Name"])
	if not chosenItem then warn(itemInfo["Name"],"does not exist") return end
	
	-- Equip item
	local currentItem = player.CurrentItem
	if currentItem.Value then
		if currentItem.Value.Name == itemInfo["Name"] then return "Item already equipped" end
		currentItem.Value:Destroy()
		currentItem.Value = nil
	end
	
	local equippedItem = chosenItem:Clone()
	equippedItem.Parent = playerCharacter.HumanoidRootPart
	player.CurrentItem.Value = equippedItem
	
	local userOwns = player.Items:FindFirstChild(itemInfo["Name"])
	if not userOwns then -- User needs to be charged and item needs saved
		
		local savedItem = Instance.new("StringValue")
		savedItem.Name = itemInfo["Name"]
		savedItem.Parent = player.Items
		
		return "Item purchased and equipped", true
	else
		
		return "Item equipped", false
	end
end

function PowerPurchased(player, playerCharacter, itemInfo)

	if _G[itemInfo["Name"]] == "DISABLED" then 
		return "This power is disabled for this game"
	end
	if player.CurrentPower.Value then 
		return "A Power is already active"
	end

	local success, result = pcall(function()

		local args = Powers[itemInfo["Name"]](player, playerCharacter)
		player.CurrentPower.Value = args[1]
		
		args[1].Destroying:Connect(function()
			player.CurrentPower.Value = nil
			args[2]() -- Reverse power
		end)
		
	end)

	if success then
		return itemInfo['Name'] .. ' activated', true
	else
		warn(result)
		return false
	end

end