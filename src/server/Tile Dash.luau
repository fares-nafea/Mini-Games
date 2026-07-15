local TileDash = {}
local gameModel = script:WaitForChild("GameModel")

local TweenService = game:GetService("TweenService")

local gameTime = 35
local startingDropTime = .5
local dropTimeDecrease = .4
local tileBlinkCount = 2
local tilesToFall = 20
local tileWarningColor = Color3.fromRGB(255, 73, 49)

local tileTweenInfo = TweenInfo.new(
    .7,
    Enum.EasingStyle.Quint,
    Enum.EasingDirection.Out,
    0,
    true
)

function TileDash.RunGame()

    -- Setup game
    local newGame = gameModel:Clone()
    newGame.Parent = workspace
    newGame.Lava.Touched:Connect(_G.KillFunction)

    -- Setup players
    _G.TeleportPlayers(newGame.Spawn.CFrame, true)

    for countDown = 3, 0, -1 do
        _G.gameStatus.Value = "Avoid the falling tiles in " .. countDown
        task.wait(1)
    end

    -- Begin game
    local gameThread = coroutine.create(function()

        local dropTime = startingDropTime

        while true do --> Main Game
            
            -- Chose tiles
            local chosenTiles = {}
            local totalTiles = newGame.Tiles:GetChildren()

            for i = 1, tilesToFall do

                local tileIndex = math.random(1, #totalTiles)
                local tile = totalTiles[tileIndex]
                tile:SetAttribute("tileColor", tile.Color)

                table.insert(chosenTiles, tile)
                table.remove(totalTiles, tileIndex)

            end

            -- tile Drop animation
            for i = tileBlinkCount, 1, -1 do

                task.wait(dropTime)

                -- To warning color
                for i, chosenTiles in ipairs(chosenTiles) do
                    chosenTiles.Color = tileWarningColor
                end

                task.wait(dropTime)

                -- Back to normal
                for i, chosenTiles in ipairs(chosenTiles) do
                    chosenTiles.Color = chosenTiles:GetAttribute("tileColor")
                end

            end

            -- Drop tiles
            local dropDecrease = 20
            for i, chosenTiles in ipairs(chosenTiles) do
                TweenService:Create(
                    chosenTiles,
                    tileTweenInfo,
                    {Position = chosenTiles.Position - Vector3.yAxis*dropDecrease}
                ):Play()
            end


            task.wait(tileTweenInfo.Time * 2)
            dropTime += dropTimeDecrease

        end

    end)

    coroutine.resume(gameThread)

    for countDown = gameTime, 0, -1 do
        if #workspace.InGame:GetChildren() == 0 then break end
        _G.gameStatus.Value = countDown .. " seconds remain"
        task.wait(1)
    end

    coroutine.close(gameThread)

    _G.BasicEnding()

    newGame:Destroy()

end


TileDash.MinPlayers = 1

return TileDash
