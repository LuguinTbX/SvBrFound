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
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("VehicleSeat") and v.Occupant == character:FindFirstChild("Humanoid") then
			return v
		end
	end
	return nil
end
local renderConn

local function boostCar(seat)
	if not seat then return end
	if renderConn then renderConn:Disconnect() end 

	renderConn = RunService.RenderStepped:Connect(function()
		if boosting and seat and seat.Parent then
			if not originalVelocity then
				originalVelocity = seat.AssemblyLinearVelocity
			end

			local boostMultiplier = 1 + boostPercent/100
			local boostVel = Vector3.new(
				originalVelocity.X * boostMultiplier,
				seat.AssemblyLinearVelocity.Y,
				originalVelocity.Z * boostMultiplier
			)
			seat.AssemblyLinearVelocity = boostVel

			local horizontalVel = Vector3.new(seat.AssemblyLinearVelocity.X,0,seat.AssemblyLinearVelocity.Z).Magnitude
			local originalHorVel = Vector3.new(originalVelocity.X,0,originalVelocity.Z).Magnitude
			local percent = 0
			if originalHorVel > 0 then
				percent = math.clamp((horizontalVel/originalHorVel-1)*100,0,999)
			end
			boostLabel.Text = "Boost: "..math.floor(percent).."%"
		else
			originalVelocity = nil
			boostLabel.Text = "Boost: 0%"
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
