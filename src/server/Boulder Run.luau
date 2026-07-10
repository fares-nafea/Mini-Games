local MiniGame = {}
local gameModel = script:WaitForChild("GameModel")

local debris = game:GetService("Debris")

local stunTime = 2.5

-- Boulder info
local boulderTemplate = script.Boulder
local spawnMin = .5
local spanwMax = 1.5
local sizeMax = 17
local sizeMin = 6
local lifetime = 10

function MiniGame.RunGame()

    -- Set up game
    local newGame = gameModel:Clone()
    local boulderSpawn = newGame.BoulderSpawn
    newGame.Parent = workspace

    -- Start Game
    _G.TeleportPlayers(newGame.Spawn.CFrame, true)

    local function SpawnBoulder()
        local newBoulder = boulderTemplate:Clone()
        newBoulder.Size = Vector3.one * math.random(sizeMin, sizeMax)

        local rav = 15
        newBoulder.AssemblyAngularVelocity = Vector3.new(
            math.random(-rav, rav),
            math.random(-rav, rav),
            math.random(-rav, rav)
        )

        local rlv = 60
        newBoulder.AssemblyLinearVelocity = Vector3.new(
            math.random(-rlv, rlv),
            math.random(-rlv, rlv),
            math.random(-rlv, rlv)
        )

        local posXMin = boulderSpawn.Position.X - (boulderSpawn.Size.X / 2)
        local posXMax = boulderSpawn.Position.X + (boulderSpawn.Size.X / 2)

        newBoulder.Position = Vector3.new(
            math.random(posXMin, posXMax),
            boulderSpawn.Position.Y,
            boulderSpawn.Position.Z
        )

        newBoulder.Touched:Connect(function(hit)
            local humanoid = hit.Parent:FindFirstChild("Humanoid")
            if not humanoid then return end

            humanoid.PlatformStand = true

            hit.Parent.HumanoidRootPart.AssemblyLinearVelocity = newBoulder.AssemblyLinearVelocity

            task.wait(stunTime)
            humanoid.PlatformStand = false
        end)

        newBoulder.Parent = newGame.Boulders
        debris:AddItem(newBoulder, lifetime)
    end

    -- Boulder spawn thread
    local boulderThread = coroutine.create(function()
        while true do
            SpawnBoulder()
            task.wait(spawnMin + math.random() * (spanwMax - spawnMin))
        end
    end)

    coroutine.resume(boulderThread)

    local gameWon = false

    newGame.Win.Touched:Connect(function(hit)
        local plr = game.Players:GetPlayerFromCharacter(hit.Parent)
        if not plr then return end

        gameWon = plr
    end)

    -- Count down
    for countDown = 60, 0, -1 do
        _G.gameStatus.Value = "Get to the Top (" .. countDown .. ")"
        task.wait(1)

        if gameWon then
            break
        end
    end

    -- End of game
    if gameWon then
        gameWon.leaderstats.Wins.Value += 1
        _G.gameStatus.Value = gameWon.Name .. " got to the top!"
    else
        _G.gameStatus.Value = "No one reached the top"
    end

    task.wait(5)
    newGame:Destroy()

end

return MiniGame