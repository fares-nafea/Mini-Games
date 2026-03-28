local Players = game:GetService("Players")

local function TeleportPlayers(teleCFrame, ToGame)
    for i, plr in ipairs(Players:GetPlayers()) do

        local char = plr.Character

        if char and char:FindFirstChild("HumanoidRootPart") then

            if ToGame then

                if plr:GetAttribute("AFK") then
                    continue
                end
                
                char.Parent = workspace.InGame
            else
                char.Parent = workspace
            end

            char.HumanoidRootPart.CFrame = teleCFrame

        end

    end
end

return TeleportPlayers