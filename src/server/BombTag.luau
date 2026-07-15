local MiniGame = {}
local gameModel = script:WaitForChild("GameModel")

local BOMB_TIME = 10
local PASS_COOLDOWN = 0.3

function MiniGame.RunGame()

	local newGame = gameModel:Clone()
	newGame.Parent = workspace

	newGame.Lava.Touched:Connect(_G.KillFunction)

	_G.TeleportPlayers(newGame.Spawn.CFrame, true)

	for countDown = 3, 1, -1 do
		_G.gameStatus.Value = "Bomb Tag starting in " .. countDown
		task.wait(1)
	end


	local bomb = newGame.BOMB
	local bombPart = bomb.Bomb

	local highlight = bomb.Highlight
	local pointLight = bomb.PointLight
	local tickSound = bomb.Tick
	local boomSound = bomb.Boom
	local explosion = bomb.Attachment.Explosion


	bombPart.Anchored = false
	bombPart.CanCollide = false
	bombPart.Massless = true


	local holder = nil
	local timeLeft = BOMB_TIME
	local passOnCooldown = false
	local weld = nil


	-- Get alive players
	local function getAlivePlayers()

		local alive = {}

		for _, char in ipairs(workspace.InGame:GetChildren()) do

			local humanoid = char:FindFirstChild("Humanoid")

			if humanoid and humanoid.Health > 0 then
				table.insert(alive,char)
			end
		end

		return alive
	end

	-- Remove old weld
	local function clearWeld()

		if weld then
			weld:Destroy()
			weld = nil
		end

	end
    
	-- Give bomb
	local function giveBombTo(char)
		clearWeld()

		holder = char

		local hand =
			char:FindFirstChild("RightHand")
			or char:FindFirstChild("Right Arm")

		if hand then
			bombPart.CFrame =
				hand.CFrame
				* CFrame.new(0,-0.5,0)
				* CFrame.Angles(
					math.rad(90),
					0,
					0
				)
			weld = Instance.new("Motor6D")

			weld.Part0 = hand
			weld.Part1 = bombPart

			weld.C0 =
				CFrame.new(
					0,
					-0.5,
					0
				)
				*
				CFrame.Angles(
					math.rad(90),
					0,
					0
				)

			weld.Parent = hand
		end


		highlight.Adornee = char

		timeLeft = BOMB_TIME

	end

	local players = getAlivePlayers()

	if #players < 2 then
		newGame:Destroy()
		return
	end


	giveBombTo(
		players[
			math.random(
				1,
				#players
			)
		]
	)
	-- Passing bomb
	local touchConnection

	touchConnection =
		bombPart.Touched:Connect(function(hit)

			if passOnCooldown then
				return
			end

			local char = hit.Parent

			if char == holder then
				return
			end

			if char.Parent ~= workspace.InGame then
				return
			end



			local humanoid =
				char:FindFirstChild("Humanoid")


			if not humanoid
				or humanoid.Health <= 0 then

				return
			end



			passOnCooldown = true


			giveBombTo(char)



			task.delay(
				PASS_COOLDOWN,
				function()

					passOnCooldown = false

				end
			)


		end)



	tickSound:Play()



	while true do


		local alive = getAlivePlayers()


		if #alive <= 1 then
			break
		end



		timeLeft -= 0.1



		tickSound.PlaybackSpeed =
			1 +
			((BOMB_TIME-timeLeft)
				/BOMB_TIME)
			*2



		pointLight.Enabled =
			math.floor(timeLeft*10)%2==0



		_G.gameStatus.Value =
			"Pass the bomb! "
			..
			math.ceil(
				math.max(timeLeft,0)
			)



		if timeLeft <= 0 then



			tickSound:Stop()


			-- Save explosion position
			local explosionPosition =
				bombPart.Position



			clearWeld()



			bombPart.CFrame =
				CFrame.new(
					explosionPosition
				)



			boomSound:Play()

			explosion:Emit(50)



			task.wait(0.15)



			if holder
				and holder:FindFirstChild("Humanoid") then

				holder.Humanoid.Health = 0

			end



			task.wait(1)



			local remaining =
				getAlivePlayers()



			if #remaining <= 1 then
				break
			end



			giveBombTo(
				remaining[
					math.random(
						1,
						#remaining
					)
				]
			)

			tickSound:Play()
		end
		task.wait(0.1)
	end

	touchConnection:Disconnect()

	clearWeld()

	tickSound:Stop()

	pointLight.Enabled = false

	highlight.Adornee = nil

	_G.gameStatus.Value =
		"Bomb Tag Finished!"

	task.wait(1)

	_G.BasicEnding()

	newGame:Destroy()
end



MiniGame.MinPlayers = 2

return MiniGame