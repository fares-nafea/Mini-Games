function BasicEnding()
    local winners = workspace.InGame:GetChildren()
    local endText = "The Winners are: "

    for i, plrChar in ipairs(winners) do

        if plrChar.Humanoid.Health <= 0 then continue end
        local plr = game.Players:GetPlayerFromCharacter(plrChar)
        plr.leaderstats.Wins.Value += 5

        endText = endText .. plr.Name .. " "

    end

    _G.gameStatus.Value = endText
    task.wait(3)
end

return BasicEnding