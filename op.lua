--Feito por Frawd

local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local PlayerGui= player.PlayerGui
local boosting = false
local boostPercent = 10
local boostKey = Enum.KeyCode.F
local baseSpeed = nil 
local guiVisible = true
local TweenService = game:GetService("TweenService")

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

local function showNotice(msg, duration)
	duration = duration or 3

	local screenGui = PlayerGui:FindFirstChild("KeybindNotice") or Instance.new("ScreenGui")
	screenGui.Name = "KeybindNotice"
	screenGui.Parent = PlayerGui

	local label = screenGui:FindFirstChild("NoticeLabel")
	if not label then
		label = Instance.new("TextLabel")
		label.Name = "NoticeLabel"
		label.Size = UDim2.new(0, 300, 0, 50)
		label.Position = UDim2.new(0.9, -140, 0.9, 0) 
		label.BackgroundTransparency = 0.3
		label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.TextScaled = true
		label.Font = Enum.Font.SourceSansBold
		label.Parent = screenGui
	end

	label.Text = msg
	label.Visible = true
	label.TextTransparency = 0
	label.BackgroundTransparency = 0.3

	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out) 
	local goal = {TextTransparency = 1, BackgroundTransparency = 1}

	task.delay(duration, function()
		local tween = TweenService:Create(label, tweenInfo, goal)
		tween:Play()
		tween.Completed:Connect(function()
			label.Visible = false
		end)
	end)
end
showNotice("V = Modo Stream\nBoost Key = " .. boostKey.Name, 5)

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
local lastVehicle = nil

local function startBoost()
	local vehicle = getVehicle()
	if not vehicle then return end

	if vehicle ~= lastVehicle or not baseSpeed then
		local vel = vehicle.AssemblyLinearVelocity
		baseSpeed = Vector3.new(vel.X, 0, vel.Z).Magnitude
		lastVehicle = vehicle
		boostProgress = 0
	end

	if renderConn then
		renderConn:Disconnect()
	end

	renderConn = RunService.Heartbeat:Connect(function(dt)
		local currentVehicle = getVehicle()
		if boosting and currentVehicle and currentVehicle.Parent then

			boostProgress = math.clamp(boostProgress + dt * 2, 0, 1)


			local currentBoostPercent = boostPercent * boostProgress
			local boostMultiplier = 1 + (currentBoostPercent / 100)

			local currentVel = currentVehicle.AssemblyLinearVelocity
			local horizontalVel = Vector3.new(currentVel.X, 0, currentVel.Z)

			if horizontalVel.Magnitude > 0 and baseSpeed > 0 then

				local targetSpeed = baseSpeed * boostMultiplier
				local currentSpeed = horizontalVel.Magnitude


				if currentSpeed < targetSpeed then
					local boostDirection = horizontalVel.Unit
					local newVel = boostDirection * targetSpeed

					currentVehicle.AssemblyLinearVelocity = Vector3.new(
						newVel.X,
						currentVel.Y,
						newVel.Z
					)
				end
			end


			boostLabel.Text = "Boost: " .. math.floor(currentBoostPercent) .. "%"

		else

			boostProgress = 0
			boostLabel.Text = "Boost: 0%"

			if renderConn then
				renderConn:Disconnect()
				renderConn = nil
			end
		end
	end)
end

function toggleGUI()
	guiVisible = not guiVisible
	boostLabel.Visible = guiVisible
	boostBox.Visible = guiVisible
	keyButton.Visible = guiVisible
end

local UserInputTypes = {
	Keyboard = Enum.UserInputType.Keyboard,
	Gamepad1 = Enum.UserInputType.Gamepad1,
}

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if waitingForKey and (input.UserInputType == UserInputTypes.Keyboard or input.UserInputType == UserInputTypes.Gamepad1) then
		boostKey = input.KeyCode
		keyButton.Text = "Boost Key: " .. boostKey.Name
		waitingForKey = false
		return
	end
	if gameProcessed then return end
	if input.KeyCode == boostKey then
		boosting = true
		startBoost()
	elseif input.KeyCode == Enum.KeyCode.V then
		toggleGUI()
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == boostKey then
		boosting = false
	end
end)
