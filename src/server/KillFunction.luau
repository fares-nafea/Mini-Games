function KillFunction(hit)

    local humanoid = hit.Parent:FindFirstChild("Humanoid")
    if humanoid then

        humanoid.Health = 0

    end

end

return KillFunction 