local miniGames = game.ServerStorage:WaitForChild("MiniGames"):GetChildren()
local gameStatus = game.ReplicatedStorage:WaitForChild("GameStatus")
_G.gameStatus = gameStatus

local lobbyCFrame = workspace:WaitForChild("Lobby"):WaitForChild("SpawnLocation").CFrame + Vector3.yAxis*5

local TeleportPlayers = require(game.ServerStorage:WaitForChild("TeleportPlayers"))
_G.TeleportPlayers = TeleportPlayers

local BasicEnding = require(game.ServerStorage:WaitForChild("BasicEnding"))
_G.BasicEnding = BasicEnding

local INTERMISSION = 10

while true do
 
    -- Intermission
    for countDown = INTERMISSION, 0, -1 do

        gameStatus.Value = "Intermission " ..countDown
        task.wait(1)

    end

    -- Choose mini game
    gameStatus.Value = "Choosing game..."
    task.wait(2)

    local chosenGameModule = miniGames[math.random(#miniGames)]

    gameStatus.Value = chosenGameModule.Name .. " has been chosen!"
    task.wait(2)

    -- Run mini game
    require(chosenGameModule).RunGame()

    -- End mini game
    TeleportPlayers(lobbyCFrame)
    gameStatus.Value = "End of Game!"
    task.wait(1)

end