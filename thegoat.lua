local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer


local screenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
local button = Instance.new("TextButton", screenGui)
button.Size = UDim2.new(0, 150, 0, 50)
button.Position = UDim2.new(0.5, -75, 0.9, 0)
button.Text = "Toggle OFF"


local function makeRightDraggable(guiObject)
	local dragging = false
	local dragStart, startPos

	guiObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			dragging = true
			dragStart = input.Position
			startPos = guiObject.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			guiObject.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

makeRightDraggable(button)


local InstanceUtils = {}
InstanceUtils.__index = InstanceUtils

function InstanceUtils:getTopParent(instance)
	assert(typeof(instance) == "Instance", "Parâmetro deve ser uma instância válida")

	local parent = instance
	while parent.Parent and parent.Parent ~= workspace do
		parent = parent.Parent
	end
	return parent
end

function InstanceUtils.new()
	return setmetatable({}, InstanceUtils)
end

local utils = InstanceUtils.new()


local active = false
local modifiedParts = {}

local function hasOwner(seat)
	local occ = seat.Occupant
	if not occ then
		return true
	end
	return occ.Parent == LocalPlayer.Character
end

local function disablePart(part)
	if not part or not part:IsA("BasePart") then return end
	if modifiedParts[part] == nil then
		modifiedParts[part] = part.CanCollide
		part.CanCollide = false
	end
end

local function enablePart(part)
	if not part or not part:IsA("BasePart") then return end
	local original = modifiedParts[part]
	if original ~= nil then
		part.CanCollide = original
		modifiedParts[part] = nil
	end
end

local function disableCollisionsOnce()
	for _, seat in pairs(workspace:GetDescendants()) do
		if seat:IsA("VehicleSeat") or seat:IsA("DriverSeat") then
			if not hasOwner(seat) then
				local occ = seat.Occupant
				if occ and occ.Parent then
					for _, p in pairs(occ.Parent:GetDescendants()) do
						disablePart(p)
					end
				end

				local top = utils:getTopParent(seat)
				for _, p in pairs(top:GetDescendants()) do
					disablePart(p)
				end
			end
		end
	end
end

local function enableAllCollisions()
	local parts = {}
	for part in pairs(modifiedParts) do
		table.insert(parts, part)
	end
	for _, part in ipairs(parts) do
		enablePart(part)
	end
end

RunService.Heartbeat:Connect(function()
	if not active then return end
	for _, seat in pairs(workspace:GetDescendants()) do
		if seat:IsA("VehicleSeat") or seat:IsA("DriverSeat") then
			if not hasOwner(seat) then
				local occ = seat.Occupant
				if occ and occ.Parent then
					for _, p in pairs(occ.Parent:GetDescendants()) do
						disablePart(p)
					end
				end
				local top = utils:getTopParent(seat)
				for _, p in pairs(top:GetDescendants()) do
					disablePart(p)
				end
			end
		end
	end
end)

button.MouseButton1Click:Connect(function()
	active = not active
	button.Text = active and "Toggle ON" or "Toggle OFF"

	if active then
		disableCollisionsOnce()
	else
		enableAllCollisions()
	end
end)
