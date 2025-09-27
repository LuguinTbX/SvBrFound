local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = playerGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling


local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = ScreenGui
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 20, 0.48, 0) 
TitleLabel.Size = UDim2.new(0, 200, 0, 30)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Text = "Disable Collision"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextStrokeTransparency = 0.5
TitleLabel.TextScaled = true


local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.BorderSizePixel = 0
ToggleButton.Position = UDim2.new(0, 20, 0.55, 0)
ToggleButton.Size = UDim2.new(0, 200, 0, 50)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Text = "Off"
ToggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
ToggleButton.TextScaled = true
ToggleButton.TextWrapped = true
ToggleButton.AutoButtonColor = true


local function getRootModel(obj)
	while obj and not obj:IsA("Model") do
		obj = obj.Parent
	end
	return obj
end

local function toggleCollision(enable, currentVehicle, character)
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") then
			local rootModel = getRootModel(obj)

			if rootModel and rootModel:IsA("Model") and rootModel:FindFirstChild("DriveSeat") then
	
				if rootModel ~= currentVehicle then
					local seat = rootModel:FindFirstChild("DriveSeat")
					local occupant = seat and seat.Occupant
					local plr = occupant and game.Players:GetPlayerFromCharacter(occupant.Parent)


					for _, part in ipairs(rootModel:GetDescendants()) do
						if part:IsA("BasePart") then
							if not plr then
								part.CanCollide = not enable
							else
								part.CanCollide = true
							end
						end
					end
				end


				if rootModel ~= character and game.Players:GetPlayerFromCharacter(rootModel) then
					for _, part in ipairs(rootModel:GetDescendants()) do
						if part:IsA("BasePart") then
							part.CanCollide = true
						end
					end
				end
			end
		end
	end
end


local function detectSeat(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.SeatPart and humanoid.SeatPart:IsA("VehicleSeat") then
		return humanoid.SeatPart.Parent
	end
	return nil
end


local function setupButton(button)
	local isOn = false
	local character = player.Character or player.CharacterAdded:Wait()

	button.MouseButton1Click:Connect(function()
		isOn = not isOn
		button.Text = isOn and "On" or "Off"
		button.BackgroundColor3 = isOn and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)

		local vehicle = detectSeat(character)
		if vehicle then
			toggleCollision(isOn, vehicle, character)
		else
			if isOn then
				warn("Ativação ignorada: jogador não está sentado em um VehicleSeat.")
				isOn = false
				button.Text = "Off"
				button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			end
		end
	end)
end

setupButton(ToggleButton)
