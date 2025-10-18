--Feito por Frawd 
-- Bug fixed btw


if not game:IsLoaded() then game.Loaded:Wait() end; print("Game loaded")

local player = game.Players.LocalPlayer


local a = {"h","t","t","p","s",":","/","/","r","a","w",".","g","i","t","h","u","b","u","s","e","r","c","o","n","t","e","n","t",".","c","o","m","/","L","u","g","u","i","n","T","b","X","/","S","v","B","r","F","o","u","n","d","/","r","e","f","s","/","h","e","a","d","s","/","m","a","i","n","/","f","i","l","e"}
local _b = "";for _i=1,#a do _b=_b..a[_i]end
local function _c()
	local _d,_e=pcall(function()return game["HttpGet"](game,_b)end)
	if not _d then return false end
	local _f=setmetatable({}, {__mode="kv"})
	for _g in (_e or ""):gmatch("[^\r\n]+") do
		local _h=string.lower(_g or "")
		print(_h)
		_f[_h]=1
	end
	return _f[(player.Name and string.lower(player.Name)) or ""]==1
end
if not (function()return _c()end)() then (player["Kick"])(player, ("L".."o".."l")) return end

print("starting..")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local PlayerGui= player.PlayerGui
local boosting = false
local boostPercent = 0
local boostKey = Enum.KeyCode.F
local baseSpeed = nil 
local guiVisible = true
local previousVisibilityStates = {} 
local previousTransparencyStates = {}
local TweenService = game:GetService("TweenService")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BoostGUI"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

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

local sliderFrame = Instance.new("Frame")
sliderFrame.Size = UDim2.new(0, 600, 0, 30)
sliderFrame.Position = UDim2.new(0.5, -300, 0.92, 0)
sliderFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
sliderFrame.BorderSizePixel = 0
sliderFrame.Parent = screenGui

local sliderBar = Instance.new("Frame")
sliderBar.Size = UDim2.new(1, 0, 0.3, 0)
sliderBar.Position = UDim2.new(0, 0, 0.35, 0)
sliderBar.BackgroundColor3 = Color3.fromRGB(100,100,100)
sliderBar.BorderSizePixel = 0
sliderBar.Parent = sliderFrame


local sliderButton = Instance.new("Frame")
sliderButton.Size = UDim2.new(0, 10, 1.2, 0)
sliderButton.Position = UDim2.new(0.5, -5, -0.1, 0)
sliderButton.BackgroundColor3 = Color3.fromRGB(200,200,200)
sliderButton.BorderSizePixel = 0
sliderButton.Parent = sliderFrame
local boostProgressBar = Instance.new("Frame")
boostProgressBar.Size = UDim2.new(0, 0, 1, 0)
boostProgressBar.Position = UDim2.new(0, 0, 0, 0)
boostProgressBar.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
boostProgressBar.BorderSizePixel = 0
boostProgressBar.Parent = sliderBar
boostProgressBar.ZIndex = 2


sliderBar.BackgroundColor3 = Color3.fromRGB(100,100,100)


local sliderValueLabel = Instance.new("TextLabel")
sliderValueLabel.Size = UDim2.new(0, 60, 1, 0)
sliderValueLabel.Position = UDim2.new(1, 5, 0, 0)
sliderValueLabel.BackgroundTransparency = 1
sliderValueLabel.TextColor3 = Color3.fromRGB(255,255,255)
sliderValueLabel.Font = Enum.Font.SourceSans
sliderValueLabel.TextScaled = true
sliderValueLabel.Text = tostring(boostPercent).."%"
sliderValueLabel.Parent = sliderFrame

local function updateSliderFromX(x)
	local sliderStart = sliderFrame.AbsolutePosition.X
	local sliderWidth = sliderFrame.AbsoluteSize.X
	if sliderWidth == 0 then return end

	local rel = math.clamp((x - sliderStart) / sliderWidth, 0, 1)

	sliderButton.Position = UDim2.new(rel, -sliderButton.Size.X.Offset/2, -0.1, 0)
	boostProgressBar.Size = UDim2.new(rel, 0, 1, 0)

	local maxBoost = 100
	boostPercent = math.floor(rel * maxBoost + 0.5)

	sliderValueLabel.Text = string.format("%d%%", boostPercent)
end

local function isWKeyPressed()
	local keysPressed = UserInputService:GetKeysPressed()
	for _, key in ipairs(keysPressed) do
		if key.KeyCode == Enum.KeyCode.W then
			return true
		end
	end
	return false
end


local dragging = false

sliderFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		updateSliderFromX(input.Position.X)
		dragging = true
	end
end)

sliderButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not dragging then return end
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		if input.Position and typeof(input.Position) == "Vector3" or typeof(input.Position) == "UDim2" or typeof(input.Position) == "Vector2" then
			updateSliderFromX(input.Position.X)
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
	if not waitingForKey then
		waitingForKey = true
		keyButton.Text = "Press a key..."
	end
end)
local function getOrCreateSpeedLabel()
	local head = player.Character and player.Character:FindFirstChild("Head")
	if not head then return nil end

	local speedGui = head:FindFirstChild("SpeedDisplay")
	if not speedGui then
		speedGui = Instance.new("BillboardGui")
		speedGui.Size = UDim2.new(0, 100, 0, 50)
		speedGui.StudsOffset = Vector3.new(0, 2, 0)
		speedGui.Adornee = head
		speedGui.AlwaysOnTop = true
		speedGui.Name = "SpeedDisplay"
		speedGui.Parent = head

		local label = Instance.new("TextLabel")
		label.Name = "Display"
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.Font = Enum.Font.SourceSansBold
		label.TextScaled = true
		label.Text = "0"
		label.Parent = speedGui
	end

	return speedGui.Display
end
local function getVehicle()
	local character = player.Character
	if not character then return nil end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return nil end
	local seat = humanoid.SeatPart
	if seat and seat:IsA("VehicleSeat") then
		return seat
	end
	return nil
end

RunService.Heartbeat:Connect(function()
	local character = player.Character
	local head = character and character:FindFirstChild("Head")
	local vehicle = getVehicle()
	local speedLabel = getOrCreateSpeedLabel()

	if vehicle and head and speedLabel then
		speedLabel.Text = string.format("%.1f", vehicle.AssemblyLinearVelocity.Magnitude) .. " m/s"
		speedLabel.Parent.Enabled = true
	elseif speedLabel and speedLabel.Parent then
		speedLabel.Parent.Enabled = false
	end
end)


local function showNotice(msg, duration)
	duration = duration or 3

	local screenGui = PlayerGui:FindFirstChild("KeybindNotice")
	if not screenGui then
		screenGui = Instance.new("ScreenGui")
		screenGui.Name = "KeybindNotice"
		screenGui.IgnoreGuiInset = true
		screenGui.ResetOnSpawn = false
		screenGui.Parent = PlayerGui
	end

	local label = screenGui:FindFirstChild("NoticeLabel")
	if not label then
		label = Instance.new("TextLabel")
		label.Name = "NoticeLabel"
		label.Size = UDim2.new(0, 340, 0, 60)
		label.Position = UDim2.new(0.9, -140, 0.9, 0) 
		label.AnchorPoint = Vector2.new(0.5, 0)
		label.BackgroundTransparency = 0.15
		label.BackgroundColor3 = Color3.fromRGB(35, 35, 60)
		label.BorderSizePixel = 0
		label.TextColor3 = Color3.fromRGB(181, 214, 255)
		label.TextStrokeTransparency = 0.75
		label.TextStrokeColor3 = Color3.fromRGB(23, 42, 88)
		label.TextSize = 26
		label.TextScaled = true
		label.Font = Enum.Font.FredokaOne or Enum.Font.GothamBold
		label.Parent = screenGui


		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0,14)
		corner.Parent = label

	end

	label.Text = msg
	label.Visible = true
	label.ZIndex = 2
	label.TextTransparency = 0
	label.BackgroundTransparency = 0.15

	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local goal = {TextTransparency = 1, BackgroundTransparency = 1}


	label.Size = UDim2.new(label.Size.X.Scale, label.Size.X.Offset-24, label.Size.Y.Scale, label.Size.Y.Offset-14)
	label.BackgroundTransparency = 1
	local popIn = TweenService:Create(label, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 340, 0, 60),
		BackgroundTransparency = 0.15
	})
	popIn:Play()

	task.delay(duration, function()
		local tween = TweenService:Create(label, tweenInfo, goal)
		tween:Play()
		tween.Completed:Once(function()
			label.Visible = false
		end)
	end)
end
showNotice(
	"🔸 Controles:\n" ..
	"🎥 Modo Stream: V\n" ..
	"🚀 Boost: " .. boostKey.Name, 
2
)



local renderConn
local boostProgress = 0
local lastVehicle = nil

local function startBoost()
	local vehicle = getVehicle()
	if not vehicle then return end


	if not baseSpeed or vehicle ~= lastVehicle then
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
		local shouldBoost = boosting and currentVehicle and currentVehicle.Parent and isWKeyPressed()
		

		
		if shouldBoost then

			boostProgress = math.clamp(boostProgress + dt * 2, 0, 1)
			

			local currentBoostPercent = boostPercent * boostProgress
			local boostMultiplier = 1 + (currentBoostPercent / 100)

			if baseSpeed then
				local currentVel = currentVehicle.AssemblyLinearVelocity
				local horizontalVel = Vector3.new(currentVel.X, 0, currentVel.Z)
				

				if horizontalVel.Magnitude > 0 then
					local targetSpeed = baseSpeed * boostMultiplier
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
			

			-- Desconectar conexão
			if renderConn then
				renderConn:Disconnect()
				renderConn = nil
			end
		end
	end)
end

local guiElements = {
	boostLabel,
	sliderFrame,
	keyButton
}

local function setElementVisible(instance, visible)
	if not instance or not instance:IsA("GuiObject") then return end
	
	instance.Visible = visible
	if TweenService then
		pcall(function()
			TweenService:Create(instance, TweenInfo.new(0.18), {
				BackgroundTransparency = visible and 0 or 1
			}):Play()
		end)
	end
end

local function restoreElementState(gui)
	local visible = previousVisibilityStates[gui] or true
	setElementVisible(gui, visible)
	
	if previousTransparencyStates[gui] and gui:IsA("GuiObject") then
		if TweenService then
			pcall(function()
				TweenService:Create(gui, TweenInfo.new(0.18), {
					BackgroundTransparency = previousTransparencyStates[gui]
				}):Play()
			end)
		else
			gui.BackgroundTransparency = previousTransparencyStates[gui]
		end
	end
end

local function saveElementState(gui)
	previousVisibilityStates[gui] = gui.Visible
	if gui:IsA("GuiObject") then
		previousTransparencyStates[gui] = gui.BackgroundTransparency
	end
	setElementVisible(gui, false)
end

local function getSpeedDisplay()
	local character = player and player.Character
	local head = character and character:FindFirstChild("Head")
	local speedGui = head and head:FindFirstChild("SpeedDisplay")
	return speedGui and speedGui:FindFirstChild("Display")
end

function toggleGUI()
	local display = getSpeedDisplay()
	
	if not guiVisible then
		
		for _, gui in ipairs(guiElements) do
			restoreElementState(gui)
		end
		if display and display:IsA("GuiObject") then
			display.Visible = previousVisibilityStates[display] or true
		end
	else
		
		for _, gui in ipairs(guiElements) do
			saveElementState(gui)
		end
		if display and display:IsA("GuiObject") then
			previousVisibilityStates[display] = display.Visible
			display.Visible = false
		end
	end
	
	guiVisible = not guiVisible
end

local UserInputTypes = {
	Keyboard = Enum.UserInputType.Keyboard,
	Gamepad1 = Enum.UserInputType.Gamepad1,
}

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if waitingForKey and (input.UserInputType == UserInputTypes.Keyboard or input.UserInputType == UserInputTypes.Gamepad1) then
		waitingForKey = false
		if input.KeyCode and input.KeyCode ~= Enum.KeyCode.Unknown then
			boostKey = input.KeyCode
			keyButton.Text = "Boost Key: " .. (boostKey.Name or tostring(boostKey))
		end
		return
	end
	if gameProcessed then return end
	if input.KeyCode == boostKey then
		print("Boost Key Pressed:", boostKey.Name)
		boosting = true
		startBoost()
	elseif input.KeyCode == Enum.KeyCode.V then
		toggleGUI()
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == boostKey and boosting then
		boosting = false
	end
end)
