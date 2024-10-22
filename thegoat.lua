-- Gui to Lua
-- Version: 3.2

-- Instances:

local ScreenGui = Instance.new("ScreenGui")
local TextButton = Instance.new("TextButton")

--Properties:

ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

TextButton.Parent = ScreenGui
TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextButton.BorderSizePixel = 0
TextButton.Position = UDim2.new(0, 0, 0.548, 0)
TextButton.Size = UDim2.new(0, 200, 0, 50)
TextButton.Font = Enum.Font.SourceSans
TextButton.Text = "Off"
TextButton.TextColor3 = Color3.fromRGB(0, 0, 0)
TextButton.TextScaled = true
TextButton.TextSize = 14.000
TextButton.TextWrapped = true

-- Scripts:

local function toggleCollision(on, model, character)
	-- Desativa ou reativa a colisão para veículos e personagens de outros jogadores
	for _, v in pairs(game.Workspace:GetDescendants()) do
		if v:IsA('Model') and v ~= model then
			if v:FindFirstChildOfClass('VehicleSeat') then
				for _, part in pairs(v:GetDescendants()) do
					if part:IsA('BasePart') then
						part.CanCollide = not on -- Desativa ou ativa a colisão
					end
				end
			end
		end
	end

	for _, cha in pairs(game.Players:GetPlayers()) do
		if cha.Character and cha.Character ~= character then
			for _, part in pairs(cha.Character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = not on -- Desativa ou ativa a colisão
				end
			end
		end
	end
end

local function detectSeat(character)
	local humanoid = character:WaitForChild("Humanoid")
	if humanoid.SeatPart and humanoid.SeatPart:IsA("VehicleSeat") then
		return humanoid.SeatPart.Parent -- Retorna o modelo em que o jogador está sentado
	end
	return nil
end

local function setupButton(button)
	local on = false
	local player = game.Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()

	button.MouseButton1Click:Connect(function()
		on = not on
		button.Text = on and "On" or "Off"

		local model = detectSeat(character)
		if model then
			toggleCollision(on, model, character)
		else
			print("O jogador não está sentado em um VehicleSeat.")
		end
	end)
end

setupButton(TextButton)
