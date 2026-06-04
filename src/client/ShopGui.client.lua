local ScreenGui = script.Parent
local MainFrame = ScreenGui:WaitForChild("ShopFrame")
local ShopButton = ScreenGui:WaitForChild("ShopButton")
local ItemFrames = MainFrame:WaitForChild("ScrollingFrame"):GetChildren()

local NoticeLabel = MainFrame:WaitForChild("NoticeLabel")

local ItemPurchased = game.ReplicatedStorage:WaitForChild("Events"):WaitForChild("ItemPurchased")

-- Setup
for i, frame in ipairs(ItemFrames) do

    if not frame:IsA("TextButton") then continue end
    frame.PriceLabel.Text = tostring(frame:GetAttribute("Price"))

    frame.Activated:Connect(function()

        local purchaseSuccess = ItemPurchased:InvokeServer(frame)

        if purchaseSuccess ~= "Successful" then
            local newLabel = NoticeLabel:Clone()
            newLabel.Text = tostring(purchaseSuccess)
            newLabel.Parent = NoticeLabel.Parent
            task.wait(3)
            newLabel:Destroy()
        end

    end)

end

local defaultSize = MainFrame.Size
local animTime = .25
local animSize = .3

ShopButton.Activated:Connect(function()

    if MainFrame.Visible then

        MainFrame:TweenSize(
            defaultSize - UDim2.fromScale(animSize, animSize),
            Enum.EasingDirection.In,
            Enum.EasingStyle.Back,
            animTime,
            true
        )

        task.wait(animTime)
        MainFrame.Visible = false

    else

        MainFrame.Size = defaultSize - UDim2.fromScale(animSize, animSize)
        MainFrame.Visible = true

        MainFrame:TweenSize(
            defaultSize,
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Back,
            animTime,
            true
        )

    end
    
end)