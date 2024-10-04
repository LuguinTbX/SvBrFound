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
TextButton.Position = UDim2.new(0, 0, 0.548780501, 0)
TextButton.Size = UDim2.new(0, 200, 0, 50)
TextButton.Font = Enum.Font.SourceSans
TextButton.Text = "Off"
TextButton.TextColor3 = Color3.fromRGB(0, 0, 0)
TextButton.TextScaled = true
TextButton.TextSize = 14.000
TextButton.TextWrapped = true

-- Scripts:

local function WTPYMLH_fake_script() -- TextButton.LocalScript 
	local script = Instance.new('LocalScript', TextButton)

	local on = false
	
	script.Parent.MouseButton1Click:Connect(function()
		on = not on -- Alterna entre verdadeiro e falso
	
		local player = game.Players.LocalPlayer
		local character = player.Character or player.CharacterAdded:Wait()
		local Players = game.Players
	
		-- Função para obter todos os personagens no jogo
		local function getAllCharacters()
			local characters = {}
			for _, player in ipairs(Players:GetPlayers()) do
				if player.Character then
					table.insert(characters, player.Character) -- Adiciona o personagem à tabela
				end
			end
			return characters
		end
	
		if on then
			script.Parent.Text = 'On'
	
			local function checkCurrentSeat()
				while true do
					wait(0.5)
					local seat = character.Humanoid.SeatPart
	
					if seat and seat:IsA("VehicleSeat") then
						local model = seat.Parent
						print("O jogador está sentado no modelo: " .. model.Name)
						return model
					else
						print("O jogador não está sentado em um VehicleSeat.")
					end
				end
			end
	
			-- Chamar a função para obter o modelo atual
			local model = checkCurrentSeat()
	
			if model then
				-- Desativa colisão com outros veículos
				for _, v in pairs(game.Workspace:GetDescendants()) do
					if v:IsA('Model') and v ~= model then
						if v:FindFirstChildOfClass('VehicleSeat') then
							for _, part in pairs(v:GetDescendants()) do
								if part:IsA('BasePart') then
									part.CanCollide = false -- Desativa a colisão
								end
							end
						end
					end
				end
	
				-- Desativa colisão para personagens de outros jogadores
				local allCharacters = getAllCharacters()
				for _, cha in ipairs(allCharacters) do
					if cha ~= character then
						for _, part in ipairs(cha:GetDescendants()) do
							if part:IsA("BasePart") then
								part.CanCollide = false -- Desativa a colisão
							end
						end
					end
				end
			end
	
		else
			-- Caso o botão seja desligado (Off)
			script.Parent.Text = 'Off'
	
			-- Reativar colisão para todos os veículos
			for _, v in pairs(game.Workspace:GetDescendants()) do
				if v:IsA('Model') then
					if v:FindFirstChildOfClass('VehicleSeat') then
						for _, part in pairs(v:GetDescendants()) do
							if part:IsA('BasePart') then
								part.CanCollide = true -- Reativa a colisão
							end
						end
					end
				end
			end
	
			-- Reativa colisão para personagens de outros jogadores
			local allCharacters = getAllCharacters()
			for _, cha in ipairs(allCharacters) do
				if cha ~= character then
					for _, part in ipairs(cha:GetDescendants()) do
						if part:IsA("BasePart") then
							part.CanCollide = true -- Reativa a colisão
						end
					end
				end
			end
		end
	end)
end
coroutine.wrap(WTPYMLH_fake_script)()
