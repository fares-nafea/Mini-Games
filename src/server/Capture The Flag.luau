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

        else -- Add to Blue

        end
        
    end

end

return MiniGame