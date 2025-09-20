local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local boosting = false
local boostPercent = 10
local originalVelocity = nil
local guiVisible = true
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BoostGUI"
screenGui.Parent = player:WaitForChild("PlayerGui")
local boostLabel = Instance.new("TextLabel")
boostLabel.Size = UDim2.new(0, 150, 0, 50)
boostLabel.Position = UDim2.new(0.5, -75, 0.85, 0)
boostLabel.BackgroundColor3 = Color3.fromRGB(0,0,0)
boostLabel.BackgroundTransparency = 0.5
boostLabel.TextColor3 = Color3.fromRGB(255,255,255)
boostLabel.Font = Enum.Font.SourceSansBold
boostLabel.TextScaled = true
boostLabel.Text = "Boost: 0%"
boostLabel.Parent = screenGui
local boostBox = Instance.new("TextBox")
boostBox.Size = UDim2.new(0, 100, 0, 30)
boostBox.Position = UDim2.new(0.5, -50, 0.92, 0)
boostBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
boostBox.TextColor3 = Color3.fromRGB(255,255,255)
boostBox.Font = Enum.Font.SourceSans
boostBox.TextScaled = true
boostBox.Text = tostring(boostPercent)
boostBox.ClearTextOnFocus = false
boostBox.Parent = screenGui
boostBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local value = tonumber(boostBox.Text)
		if value then
			boostPercent = value
		else
			boostBox.Text = tostring(boostPercent)
		end
	end
end)
local function getVehicle()
	local character = player.Character
	if not character then return nil end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.SeatPart and humanoid.SeatPart:IsA("VehicleSeat") then
		return humanoid.SeatPart
	end
	return nil
end
local renderConn
local boostProgress = 0.1
local function boostCar(seat)
	if not seat then return end
	if renderConn then renderConn:Disconnect() end 
	local lastPercent = -1 
	renderConn = RunService.Heartbeat:Connect(function(dt)
		if boosting and seat and seat.Parent then
			if not originalVelocity then
				originalVelocity = seat.AssemblyLinearVelocity
			end
			boostProgress = math.clamp(boostProgress + dt * 2, 0, 1)
			local boostMultiplier = 1 + (boostPercent / 100) * boostProgress
			local currentVel = seat.AssemblyLinearVelocity

			
			local lookDirection = seat.CFrame.LookVector
			local currentSpeed = currentVel.Magnitude
			local originalSpeed = originalVelocity.Magnitude

			
			local boostedSpeed = originalSpeed * boostMultiplier
			local newVelocity = lookDirection * boostedSpeed


			seat.AssemblyLinearVelocity = Vector3.new(
				newVelocity.X,
				currentVel.Y, 
				newVelocity.Z
			)

			local horizontalVel = Vector3.new(currentVel.X, 0, currentVel.Z).Magnitude
			local originalHorVel = Vector3.new(originalVelocity.X, 0, originalVelocity.Z).Magnitude
			local percent = 0
			if originalHorVel > 0 then
				percent = math.clamp((horizontalVel / originalHorVel - 1) * 100, 0, 999)
			end
			if math.floor(percent) ~= lastPercent then
				boostLabel.Text = "Boost: " .. math.floor(percent) .. "%"
				lastPercent = math.floor(percent)
			end
		else
			boostProgress = 0
			originalVelocity = nil
			if lastPercent ~= 0 then
				boostLabel.Text = "Boost: 0%"
				lastPercent = 0
			end
		end
	end)
end
local function toggleGUI()
	guiVisible = not guiVisible
	boostLabel.Visible = guiVisible
	boostBox.Visible = guiVisible
end
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.F then
		boosting = true
		local vehicle = getVehicle()
		if vehicle then
			boostCar(vehicle)
		end
	elseif input.KeyCode == Enum.KeyCode.V then
		toggleGUI()
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.F then
		boosting = false
	end
end) 
