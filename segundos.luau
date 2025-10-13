
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")


local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = nil
local attempts = 0
while not rootPart and attempts < 3 do
	attempts += 1
	rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then
		local timeout = 5
		local elapsed = 0
		while elapsed < timeout and not rootPart do
			task.wait(0.1)
			elapsed += 0.1
			rootPart = character:FindFirstChild("HumanoidRootPart")
		end
	end
end

if not rootPart then
    player:Kick("idk why not working btw.")
	return
end


local cachedValue = nil
local cachedText = nil
local blacklistedPlayers = {}
local playerButtons = {}
local monitoredPlayer = nil


local function makeDraggable(frame)
	local dragging = false
	local dragInput = nil
	local dragStart = nil
	local startPos = nil


	local function update(input)
		if dragging and dragStart and startPos then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position

			local conn
			conn = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					dragStart = nil
					startPos = nil
					if conn then
						conn:Disconnect()
					end
				end
			end)
		end
	end)

	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput then
			update(input)
		end
	end)
end


local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.Name = "TimeDifferenceGui"


local TextLabel = Instance.new("TextLabel")
TextLabel.Parent = ScreenGui
TextLabel.Size = UDim2.new(0.2, 0, 0.05, 0)
TextLabel.Position = UDim2.new(0.748, 0, 0.02, 0)
TextLabel.BackgroundColor3 = Color3.new(0, 0, 0)
TextLabel.TextColor3 = Color3.new(1, 1, 1)
TextLabel.TextScaled = true
TextLabel.Text = "+0.000s"


local PlayerSelectionGui = Instance.new("Frame")
PlayerSelectionGui.Parent = ScreenGui
PlayerSelectionGui.Size = UDim2.new(0.25, 0, 0.6, 0)
PlayerSelectionGui.Position = UDim2.new(0.02, 0, 0.1, 0)
PlayerSelectionGui.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
PlayerSelectionGui.BorderSizePixel = 2
PlayerSelectionGui.BorderColor3 = Color3.new(0.3, 0.3, 0.3)


local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = PlayerSelectionGui
TitleLabel.Size = UDim2.new(1, 0, 0.1, 0)
TitleLabel.Position = UDim2.new(0, 0, 0, 0)
TitleLabel.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
TitleLabel.TextColor3 = Color3.new(1, 1, 1)
TitleLabel.Text = "Lista"
TitleLabel.TextScaled = true


local PlayerListFrame = Instance.new("ScrollingFrame")
PlayerListFrame.Parent = PlayerSelectionGui
PlayerListFrame.Size = UDim2.new(1, -10, 0.9, -10)
PlayerListFrame.Position = UDim2.new(0, 5, 0.1, 5)
PlayerListFrame.BackgroundColor3 = Color3.new(0.05, 0.05, 0.05)
PlayerListFrame.BorderSizePixel = 0
PlayerListFrame.ScrollBarThickness = 8


local PlayerListLayout = Instance.new("UIListLayout")
PlayerListLayout.Parent = PlayerListFrame
PlayerListLayout.SortOrder = Enum.SortOrder.LayoutOrder
PlayerListLayout.Padding = UDim.new(0, 2)


makeDraggable(PlayerSelectionGui)

PlayerListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	PlayerListFrame.CanvasSize = UDim2.new(0, 0, 0, PlayerListLayout.AbsoluteContentSize.Y)
end)


local blacklistedPlayers = {}
local playerButtons = {}

local function createPlayerButton(targetPlayer)
	local button = Instance.new("TextButton")
	button.Parent = PlayerListFrame
	button.Size = UDim2.new(1, -10, 0, 30)
	button.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
	button.BorderSizePixel = 1
	button.BorderColor3 = Color3.new(0.3, 0.3, 0.3)
	button.Text = targetPlayer.Name
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextScaled = true


	local function updateButtonVisual()
		if monitoredPlayer == targetPlayer then

			button.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
			button.TextColor3 = Color3.new(0, 0, 0)
		elseif blacklistedPlayers[targetPlayer] then

			button.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
			button.TextColor3 = Color3.new(1, 1, 1)
		else

			button.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
			button.TextColor3 = Color3.new(1, 1, 1)
		end
	end

	button.MouseButton1Click:Connect(function()
		if blacklistedPlayers[targetPlayer] then
			blacklistedPlayers[targetPlayer] = nil
		else
			blacklistedPlayers[targetPlayer] = true
			if monitoredPlayer == targetPlayer then
				monitoredPlayer = nil
			end
		end
		updateButtonVisual()
	end)

	button.MouseButton2Click:Connect(function()
		if monitoredPlayer == targetPlayer then
			monitoredPlayer = nil
		else
			monitoredPlayer = targetPlayer
			blacklistedPlayers[targetPlayer] = nil
		end
		updateButtonVisual()
	end)

	playerButtons[targetPlayer] = button
	updateButtonVisual()
	return button
end


local function removePlayerButton(targetPlayer)
	if playerButtons[targetPlayer] then
		playerButtons[targetPlayer]:Destroy()
		playerButtons[targetPlayer] = nil
		blacklistedPlayers[targetPlayer] = nil

		if monitoredPlayer == targetPlayer then
			monitoredPlayer = nil
		end
	end
end


local function addPlayer(targetPlayer)
	if targetPlayer ~= player and not playerButtons[targetPlayer] then
		createPlayerButton(targetPlayer)
	end
end


local function removePlayer(targetPlayer)
	removePlayerButton(targetPlayer)
end


for _, p in ipairs(Players:GetPlayers()) do
	if p ~= player then
		addPlayer(p)
	end
end


Players.PlayerAdded:Connect(addPlayer)


Players.PlayerRemoving:Connect(removePlayer)


local function isRaycastFromFront(rayOrigin, rayDirection)
	if not rootPart then return false end

	local playerForward = rootPart.CFrame.LookVector
	local dot = playerForward:Dot(-rayDirection.Unit)
	return dot < 0
end


local function updateTimeDifference(timeDifference, isFromFront, playerName)
	timeDifference = math.min(timeDifference, 99.999)
	local sign = isFromFront and "+" or "-"
	local newText = string.format("%s: %s%.3fs", playerName, sign, timeDifference)

	if cachedText ~= newText then
		cachedValue = timeDifference
		cachedText = newText
		TextLabel.Text = cachedText
	end
end


RunService.Heartbeat:Connect(function()

	if not humanoid.SeatPart then
		TextLabel.Text = "--"
		return
	end

	local seat = humanoid.SeatPart
	local speed = seat.AssemblyLinearVelocity.Magnitude


	if speed <= 0.5 then
		TextLabel.Text = "--"
		return
	end

	local targetPlayer = nil
	local shortestDistance = math.huge

	if monitoredPlayer then
		if monitoredPlayer.Character and monitoredPlayer.Character.Parent then
			local character = monitoredPlayer.Character
			local otherRootPart = character:FindFirstChild("HumanoidRootPart")
			if otherRootPart then
				local otherHumanoid = character:FindFirstChildWhichIsA("Humanoid")
				if otherHumanoid and otherHumanoid.Health > 0 and otherHumanoid.SeatPart then
					targetPlayer = monitoredPlayer
					shortestDistance = (rootPart.Position - otherRootPart.Position).Magnitude
				end
			end
		end
	else

		local playerList = Players:GetPlayers()

		for i = 1, #playerList do
			local otherPlayer = playerList[i]

			if otherPlayer ~= player and not blacklistedPlayers[otherPlayer] then
				local character = otherPlayer.Character
				if character and character.Parent then
					local otherRootPart = character:FindFirstChild("HumanoidRootPart")
					if otherRootPart then
						local otherHumanoid = character:FindFirstChildWhichIsA("Humanoid")
						if otherHumanoid and otherHumanoid.Health > 0 and otherHumanoid.SeatPart then
							local distance = (rootPart.Position - otherRootPart.Position).Magnitude
							if distance < shortestDistance then
								shortestDistance = distance
								targetPlayer = otherPlayer
							end
						end
					end
				end
			end
		end
	end

	if targetPlayer then
		local targetRootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
		if targetRootPart then
			local rayOrigin = targetRootPart.Position
			local rayDirection = (rootPart.Position - targetRootPart.Position).Unit
			local isFromFront = isRaycastFromFront(rayOrigin, rayDirection)
			local estimatedTime = math.max(shortestDistance / speed, 0)

			updateTimeDifference(estimatedTime, isFromFront, targetPlayer.Name)
		else
			TextLabel.Text = "--"
		end
	else
		TextLabel.Text = "--"
	end
end)