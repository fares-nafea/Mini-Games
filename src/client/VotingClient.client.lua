local VotingEvent = game.ReplicatedStorage.Events:WaitForChild("Voting")
local UpdateVotes = game.ReplicatedStorage.Events:WaitForChild("UpdateVotes")

local MainFrame = script.Parent

local votingColumns = {}
for i, column in ipairs(MainFrame:WaitForChild("Columns"):GetChildren()) do
    if column:IsA("ImageButton") then
        table.insert(votingColumns, column)
    end
end

local defaultSize = votingColumns[1].Size
local selectedSize = defaultSize + UDim2.fromOffset(15, 15)
local selectedBorder = script:WaitForChild("Selected")
local animTime = .2


-- Voting Starting / Ending
VotingEvent.OnClientEvent:Connect(function(choices)
    if choices then
        MainFrame.Visible = true

        local connections = {}
        selectedBorder.Parent = script 

        -- Render choice
        for index, choice in ipairs(choices) do
            votingColumns[index].Name = choice.Name
            votingColumns[index].NameLabel.Text = choice.Name
            votingColumns[index].Image = choice.Img
            votingColumns[index].Size = defaultSize
            votingColumns[index].VotesLabel.Text = "0 Votes"

            local voteConn = votingColumns[index].Activated:Connect(function()
                local updates = UpdateVotes:InvokeServer(choice.Name)

                selectedBorder.Parent = votingColumns[index]

                for i, column in ipairs(votingColumns) do
                    column.VotesLabel.Text = updates[column.Name] .. " Votes"

                    if column == votingColumns[index] then -- Seleceted
                        column:TweenSize(
                            selectedSize,
                            Enum.EasingDirection.Out,
                            Enum.EasingStyle.Back,
                            animTime,
                            true
                        )
                    else -- Unseleceted
                        column:TweenSize(
                            selectedSize,
                            Enum.EasingDirection.Out,
                            Enum.EasingStyle.Quad,
                            animTime,
                            false
                        )
                    end

                end
            end)

            table.insert(connections, voteConn)
        end

        local updateThread = coroutine.create(function()
            while true do
                local updates = UpdateVotes:InvokeServer()

                for i, column in ipairs(votingColumns) do
                    column.VotesLabel.Text = updates[column.Name] .. " Votes"
                end

                task.wait(.6)
            end
        end)

        coroutine.resume(updateThread)

        VotingEvent.OnClientEvent:Wait()
        coroutine.close(updateThread)

        for i, conn in ipairs(connections) do
            conn :Disconnect() 
        end

    else
        MainFrame.Visible = false

    end
end)


-- Gradient Spining
local RunService = game:GetService("RunService")
local speed = 2

RunService.Heartbeat:Connect(function()
    selectedBorder.UIGradient.Rotation += speed
end)