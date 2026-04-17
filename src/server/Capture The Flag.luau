local MiniGame = {}
local sword = script:WaitForChild("ClassicSword")

local Debris = game:GetService("Debris")

local blueColor = Color3.fromRGB(0, 123, 255)
local redColor = Color3.fromRGB(255, 58, 51)
local prepTime = 2
local roundTime = 100

function MiniGame.RunGame()

    -- Set up game
    local newGame = script.GameModel:Clone()
    newGame.Parent = workspace

    local swords = {}

    -- Decide Teams
    local redTeam = {}
    local blueTeam = {}
    local deathConns = {}

    local switch = false
    for i, plr in game.Players:GetPlayers() do
        if plr:GetAttribute("AFK") or not plr.Character then continue end

        local Root = plr.Character.HumanoidRootPart
        plr.Character.Parent = workspace.InGame

        switch = not switch

        local spawnCF = nil
        local color = nil
        local team = nil

        if switch then -- Add to Red
            table.insert(redTeam, plr)
            color = redColor
            spawnCF = newGame.RedSpawn.CFrame
            team = "Red"

        else -- Add to Blue
            table.insert(blueTeam, plr)
            color = blueColor
            spawnCF = newGame.BlueSpawn.CFrame
            team = "Blue"

        end

        -- Respawn User on death
        local function onDeath(first)
            if not first then
                swords[plr.UserId].Parent = nil

                plr.CharacterAppearanceLoaded:Wait()

                swords[plr.UserId].Parent = plr.Backpack
            end

            plr.Character.Parent = workspace.InGame
            plr.Character:SetAttribute("Team", team)

            local teamHighlight = Instance.new("Highlight", newGame.Markers)
            teamHighlight.Adornee = plr.Character
            teamHighlight.DepthMode = Enum.HighlightDepthMode.Occluded
            teamHighlight.OutlineColor = color
            teamHighlight.FillTransparency = 1

            plr.Character.HumanoidRootPart.CFrame = spawnCF
            deathConns[i] = plr.Character.Humanoid.Died:Once(onDeath)
        end
        onDeath(true)
        
    end

    -- Script Flags
    local winner = nil
    local blueCarrier = nil
    local redCarrier = nil

    local flagConns = {}

    for i, flag in ipairs(newGame.Flags:GetChildren()) do
        flagConns[i] = flag.HitBox.Touched:Connect(function(hit)
            if not hit.Parent:FindFirstChild("Humanoid") then return end -- Not Humanoid
            if hit.Parent.Humanoid.Health <= 0 then return end

            if hit.Parent:GetAttribute("Team") == flag.Name then -- Team flag Touched

                if winner ~= nil then return end

                if flag.Name == "Red" and blueCarrier == hit.Parent then
                    winner = "Red"
                elseif flag.Name == "Blue" and redCarrier == hit.Parent then
                    winner = "Blue"
                else
                    return
                end

            else -- Enemy Flag touched
                
                flag.Parent = nil

                local newMarker = script.FlaggedMarker:Clone()
                newMarker.Parent = newGame.Markers
                newMarker.Adornee = hit.Parent.HumanoidRootPart

                hit.Parent.Humanoid.WalkSpeed = 11 -- Slow down carrier

                if flag.Name == "Red" then -- Red Stolen
                    newMarker.MainFrame.BackgroundColor3 = redColor
                    redCarrier = hit.Parent
                else -- Blue Stolen
                    newMarker.MainFrame.BackgroundColor3 = blueColor
                    blueCarrier = hit.Parent
                end

                -- Carrier dies
                deathConns[#deathConns + 1] = hit.Parent.Humanoid.Died:Once(function()
                    flag.Parent = newGame.Flags

                    newMarker:Destroy()
                    if flag.Name == "Red" then
                        redCarrier = nil
                    else
                        blueCarrier = nil
                    end
                end)

            end
        end)
    end

    -- Peperation
    for countDown = prepTime, 0, -1 do

        _G.gameStatus.Value = "Capture the other teams flag while protecting your own. Swords will be given in " .. countDown
        task.wait(1)

    end

    -- Begin Game 
    newGame.Walls: Destroy()

    -- Give swords
    for i, char in workspace. InGame: GetChildren() do

        local newSword = sword:Clone()
        newSword. Parent = char
        swords[game.Players:GetPlayerFromCharacter(char).UserId] = newSword

    end


    -- Count Down
    for countDown = roundTime, 0, -1 do

        if winner ~= nil then break end
        _G.gameStatus.Value = countDown
        task.wait(1)

    end

    -- End of Game

    -- Disconnect
    for i, conn in ipairs(deathConns) do
        if not conn then continue end
        conn:Disconnect()
    end     
    for i, conn in ipairs(flagConns) do
        if not conn then continue end
        conn:Disconnect()
    end

    -- Destroy Swords
    for _, sword in pairs(swords) do
        sword:Destroy()
    end

    -- Declare Winner
    if winner == nil then
        _G.gameStatus.Value = "No team has won"
    else
        _G.gameStatus.Value = "Team " ..winner.. " Has won!"

        if winner == "Blue" then
            winner = blueTeam
        else
            winner = redTeam
        end

        -- Award points
        for i, plr in ipairs(winner) do
            plr.leaderstats.Wins.Value += 1
        end
    end

    if redCarrier then
        redCarrier.Humanoid.WalkSpeed = game.StarterPlayer.CharacterWalkSpeed
    end

    if blueCarrier then
        redCarrier.Humanoid.WalkSpeed = game.StarterPlayer.CharacterWalkSpeed
    end
    task.wait(4)

    newGame:Destroy()

end

return MiniGame