local Spleef = {}
local gameModel = script.GameModel

local RUNNING = false
local minusHeight = .4

local TweenService = game:GetService("TweenService")

local tileAnimationInfo = TweenInfo.new(
	.3,
	Enum.EasingStyle.Quart,
	Enum.EasingDirection.Out,
	0,
	true
)

gameModel.KillBrick.Touched:Connect(_G.KillFunction)

-- تخزين البيانات الأصلية لكل تايل
local tileData = {}
local hitTiles = {}

for _, tile in ipairs(gameModel.Levels:GetChildren()) do
	if tile.Name ~= "Tile" then continue end

	-- حفظ الحجم والموضع الأصلي لكل تايل على حدة
	tileData[tile] = {
		size = tile.Size,
		cframe = tile.CFrame,
	}

	tile.Touched:Connect(function(hit)
        if not hit.Parent:FindFirstChild("Humanoid") then return end
        if not RUNNING then return end
        if table.find(hitTiles, tile) then return end
    
        table.insert(hitTiles, tile)
    
        local original = tileData[tile]
        local Anim = TweenService:Create(
            tile,
            tileAnimationInfo,
            {
                CFrame = original.cframe - Vector3.yAxis * 0.5,
                Size = original.size - Vector3.one * 0.2
            }
        )
    
        Anim:Play()
        task.wait(tileAnimationInfo.Time * 2)
    
        tile.Transparency = 1
        tile.CanCollide = false
    end)
end

function Spleef.RunGame()
	local spawnPoint = gameModel.SpawnPoint
	spawnPoint.Parent = workspace
	task.wait()

	gameModel.Parent = workspace

	_G.TeleportPlayers(spawnPoint.CFrame + Vector3.yAxis * 10, true)

	local players = workspace.InGame:GetChildren()
	for _, char in ipairs(players) do
		if char and char:FindFirstChild("Humanoid") then
			char.Humanoid.HipHeight -= minusHeight
		end
	end

	for countDown = 10, 1, -1 do
		task.wait(1)
		_G.gameStatus.Value = "Game starting in " .. countDown
	end

	RUNNING = true

	local spawnTransparency = spawnPoint.Transparency
	spawnPoint.Transparency = 1
	spawnPoint.CanCollide = false
	spawnPoint.Parent = gameModel

	_G.gameStatus.Value = "Last one alive wins!"

	while #workspace.InGame:GetChildren() > 1 do
		task.wait(0.2)
	end

	RUNNING = false
	_G.BasicEnding()

	for _, char in ipairs(players) do
		if char and char:FindFirstChild("Humanoid") then
			char.Humanoid.HipHeight += minusHeight
		end
	end

	gameModel.Parent = script

	-- reset كل تايل لحجمه وموضعه الأصلي
	coroutine.wrap(function()
		for _, tile in ipairs(hitTiles) do
			local original = tileData[tile]
			tile.CFrame = original.cframe
			tile.Size = original.size
			tile.Transparency = 0
			tile.CanCollide = true
		end
		table.clear(hitTiles)
	end)()

	spawnPoint.Transparency = spawnTransparency
	spawnPoint.CanCollide = true
end

return Spleef