local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local boosting = false
local boostPercent = 10
local boostKey = Enum.KeyCode.F
local originalSpeed = nil
local guiVisible = true

-- Create GUI
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
			boostPercent = math.clamp(value, 0, 1000) 
		else
			boostBox.Text = tostring(boostPercent)
		end
	end
end)

local keyButton = Instance.new("TextButton")
keyButton.Size = UDim2.new(0, 150, 0, 40)
keyButton.Position = UDim2.new(0.5, -75, 0.78, 0)
keyButton.BackgroundColor3 = Color3.fromRGB(70,70,70)
keyButton.TextColor3 = Color3.fromRGB(255,255,255)
keyButton.Font = Enum.Font.SourceSans
keyButton.TextScaled = true
keyButton.Text = "Boost Key: " .. boostKey.Name
keyButton.Parent = screenGui

local waitingForKey = false
keyButton.MouseButton1Click:Connect(function()
	waitingForKey = true
	keyButton.Text = "Press a key..."
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
local boostProgress = 0
local function boostCar(seat)
	if not seat then return end


	if not originalSpeed then
		local currentVel = seat.AssemblyLinearVelocity
		originalSpeed = Vector3.new(currentVel.X, 0, currentVel.Z).Magnitude
	end

	if not renderConn then
		renderConn = RunService.Heartbeat:Connect(function(dt)
			local vehicle = getVehicle()
			if boosting and vehicle and vehicle.Parent then

				boostProgress = math.clamp(boostProgress + dt * 2, 0, 1)


				local boostMultiplier = 1 + (boostPercent / 100) * boostProgress

			
				local currentVel = vehicle.AssemblyLinearVelocity
				local lookDir = vehicle.CFrame.LookVector

			
				local newVel = lookDir * originalSpeed * boostMultiplier
				vehicle.AssemblyLinearVelocity = Vector3.new(newVel.X, currentVel.Y, newVel.Z)

				
				local currentSpeed = Vector3.new(vehicle.AssemblyLinearVelocity.X, 0, vehicle.AssemblyLinearVelocity.Z).Magnitude
				local percent = 0
				if originalSpeed > 0 then
					percent = math.clamp(((currentSpeed / originalSpeed) - 1) * 100, 0, 999)
				end

				boostLabel.Text = "Boost: " .. math.floor(percent) .. "%"
			else
				
				boostProgress = 0
				originalSpeed = nil
				boostLabel.Text = "Boost: 0%"
			end
		end)
	end
end

function toggleGUI()
	guiVisible = not guiVisible
	boostLabel.Visible = guiVisible
	boostBox.Visible = guiVisible
	keyButton.Visible = guiVisible
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if waitingForKey and input.UserInputType == Enum.UserInputType.Keyboard then
		boostKey = input.KeyCode
		keyButton.Text = "Boost Key: " .. boostKey.Name
		waitingForKey = false
		return
	end
	if gameProcessed then return end
	if input.KeyCode == boostKey then
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
	if input.KeyCode == boostKey then
		boosting = false
	end
end)
