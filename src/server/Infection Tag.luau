local MiniGame = {}
local gameModel = script:WaitForChild("GameModel")

local taggedSpeed = 25
local runnerSpeed = 22

function MiniGame.RunGame()

    -- Set up Game
    local newGame = gameModel:Clone()
    newGame.Parent = workspace

end

return MiniGame