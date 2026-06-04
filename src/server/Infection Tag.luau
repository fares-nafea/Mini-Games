local MiniGame = {}
local gameModel = script:WaitForChild("GameModel")

local taggedSpeed = 25
local runnerSpeed = 22

function MiniGame.RunGame()

    -- Set up Game
    local newGame = gameModel:Clone()
    newGame.Parent = workspace

    -- Start Game 
    _G.TeleportPlayers(newGame.Cage.PlayerSpawn.CFrame, true)

    -- Create Tagger
    local taggedFolder = Instance.new("Folder", workspace)
    taggedFolder.Name = "Tagged"

    local taggedHighlight = Instance.new("Highlight")
    taggedHighlight.FillColor = Color3.fromRGB(155, 255, 48)
    taggedHighlight.FillTransparency = .9
    taggedHighlight.OutlineColor = Color3.fromRGB(55, 255, 0)
    taggedHighlight.OutlineTransparency = .1
    taggedHighlight.Enabled = true
    taggedHighlight.DepthMode = Enum.HighlightDepthMode.Occluded

    local currentInGame = workspace.InGame:GetChildren()
    local taggerChar = currentInGame[math.random(#currentInGame)]
    taggerChar.HumanoidRootPart.CFrame = newGame.Cage.TaggerSpawn.CFrame

    local tagConns = {}
    local function taggerTouched(hit)
        local humanoid = hit.Parent:FindFirstChild("Humanoid") -- ✅ #1
        if not humanoid then return end

        if humanoid:GetAttribute("Tagged") then print('is tagged') return end
        humanoid:SetAttribute("Tagged", true)
        humanoid.WalkSpeed = taggedSpeed

        local highlight = taggedHighlight:Clone()
        highlight.Parent = hit.Parent

        hit.Parent.Parent = taggedFolder
        table.insert(tagConns, hit.Parent.HumanoidRootPart.Touched:Connect(taggerTouched))
    end

    for i, char in ipairs(currentInGame) do
        char.Humanoid.WalkSpeed = runnerSpeed

        local plr = game.Players:GetPlayerFromCharacter(char)
        plr.CameraMaxZoomDistance = 35
    end

    taggerTouched(taggerChar.HumanoidRootPart) -- ✅ #2

    for countDown = 10, 0 , -1 do

        _G.gameStatus.Value = taggerChar.Name .. " is it. Game will begin in" .. countDown
        task.wait(1)

    end

    newGame.Cage:Destroy()

    -- Count down
    for countDown = 60, 0, -1 do

        if #taggedFolder:GetChildren() == 0 or #workspace.InGame:GetChildren() == 0 then
            break
        end

        _G.gameStatus.Value = "(" .. countDown .. ")"
        task.wait(1)

    end

    -- End of game
    local winners
    if #workspace.InGame:GetChildren() == 0 then -- Tagger won
        _G.gameStatus.Value = "Taggers have won"
        winners = {taggerChar}
    else -- Runners won
        _G.gameStatus.Value = "Runners have won"
        winners = workspace.InGame:GetChildren()
    end

    -- Untag Taggers
    for i,conn in ipairs(tagConns) do
        conn:Disconnect()
    end
    for i, tagger in ipairs(taggedFolder:GetChildren()) do
        tagger.Humanoid:SetAttribute("Tagged", nil)
        tagger.Highlight:Destroy()
    end

    for i, winner in ipairs(winners) do
        local plr = game.Players:GetPlayerFromCharacter(winner) -- ✅ #4
        plr.leaderstats.Wins.Value += 1
    end

    -- Reset Players
    for i, plr in ipairs(game.Players:GetPlayers()) do
        plr.CameraMaxZoomDistance = game.StarterPlayer.CameraMaxZoomDistance
        if plr.Character then
            plr.Character.Humanoid.WalkSpeed = game.StarterPlayer.CharacterWalkSpeed
            plr.Character.Parent = workspace
        end
    end

    task.wait(5)
    newGame:Destroy()
    taggedFolder:Destroy()
end

return MiniGame