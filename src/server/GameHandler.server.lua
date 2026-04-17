local miniGames = game.ServerStorage:WaitForChild("MiniGames"):GetChildren()
local gameStatus = game.ReplicatedStorage:WaitForChild("GameStatus")
_G.gameStatus = gameStatus

local lobbyCFrame = workspace:WaitForChild("Lobby"):WaitForChild("SpawnLocation"):WaitForChild("SpawnLocation").CFrame + Vector3.yAxis*5

local TeleportPlayers = require(game.ServerStorage:WaitForChild("TeleportPlayers"))
_G.TeleportPlayers = TeleportPlayers

local BasicEnding = require(game.ServerStorage:WaitForChild("BasicEnding"))
_G.BasicEnding = BasicEnding

local KillFunction = require(game.ServerStorage:WaitForChild("KillFunction"))
_G.KillFunction = KillFunction

local VotingEvent = game.ReplicatedStorage.Events:WaitForChild("Voting")
local UpdateVotes = game.ReplicatedStorage.Events:WaitForChild("UpdateVotes")

local INTERMISSION = 10
local MIN_PLAYERS = 1
local VOTE_TIME = 8

_G.GameQueue = {}

while true do

    -- Player requirement
    if #game.Players:GetPlayers() < MIN_PLAYERS then
        gameStatus.Value = MIN_PLAYERS .. "players needed to start"
        repeat
            task.wait(1)
        until #game.Players:GetPlayers() >= MIN_PLAYERS
    end
 
    -- Intermission
    for countDown = INTERMISSION, 0, -1 do

        gameStatus.Value = "Intermission " ..countDown
        task.wait(1)

    end

    local chosenGameModule = nil

    -- dev product
    if # _G.GameQueue ~= 0 then
        chosenGameModule = _G.GameQueue[1]
        table.remove(_G.GameQueue, 1)

    else --> Voting

        local gameVotes = {}
        local plrVotes = {}
        local selectedGames = {}
        local games = game.ServerStorage.MiniGames:GetChildren()

        for i = 1, 3 do

            local chosenGame = games[math.random(#games)]
            table.remove(games, table.find(games, chosenGame))
            table.insert(selectedGames, {
                Name = chosenGame.Name,
                Img = chosenGame:GetAttribute("Img")
            })

            print(#games)
            gameVotes[chosenGame.Name] = 0
        end

        VotingEvent:FireAllClients(selectedGames)

        UpdateVotes.OnServerInvoke = function(player, vote)
            if vote then

                local gameModule = game.ServerStorage.MiniGames:FindFirstChild(vote)
                if not gameModule or not gameVotes[gameModule.Name] then
                    warn(tostring(vote) .. " is not a votable minigame")
                    return gameVotes
                end

                local playerVote = plrVotes[player.UserId]
                if playerVote then
                    gameVotes[playerVote] -= 1
                end
                plrVotes[player.UserId] = vote

                gameVotes[vote] += 1

            end

            return gameVotes
        end

        -- Let players vote
        for countDown = VOTE_TIME, 0, -1 do

            gameStatus.Value = "Vote ( " .. countDown .. " )"
            task.wait(1)

        end

        -- End of Voting
        VotingEvent:FireAllClients(nil)
        UpdateVotes.OnServerInvoke = nil

        -- choose heighest voted game
        local heighestVotes = 0
        for name, votes in pairs(gameVotes) do
            if votes >= heighestVotes then
                
                chosenGameModule = game.ServerStorage.MiniGames:FindFirstChild(name)
                heighestVotes = votes
                
            end
        end
    end



    gameStatus.Value = chosenGameModule.Name .. " has been chosen!"
    task.wait(2)

    -- Run mini game
    require(chosenGameModule).RunGame()

    -- End mini game
    TeleportPlayers(lobbyCFrame)
    gameStatus.Value = "End of Game!"
    task.wait(1)

end