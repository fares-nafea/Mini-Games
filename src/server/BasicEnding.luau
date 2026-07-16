function BasicEnding()
    local winners = workspace.InGame:GetChildren()
    local endText = "The Winners are: "
    local anyWinners = false

    for i, plrChar in ipairs(winners) do

        if plrChar.Humanoid.Health <= 0 then continue end
        local plr = game.Players:GetPlayerFromCharacter(plrChar)
        plr.leaderstats.Wins.Value += 1

        endText = endText .. plr.Name .. " "
        anyWinners = true

    end

    _G.gameStatus.Value = anyWinners and endText or "No winners"
    task.wait(3)
end

return BasicEnding