
if not game:IsLoaded() then game.Loaded:Wait() end
print("Game loaded")

local player = game.Players.LocalPlayer

print("starting..")

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PlayerGui = player.PlayerGui

local boosting = false
local boostPercent = 0
local boostKey = Enum.KeyCode.F
local baseSpeed = nil
local guiVisible = true
local previousVisibilityStates = {}
local previousTransparencyStates = {}
local wheelDensity = 0.7
local wheelFriction = 0.3
local wheelElasticity = 0.5
local wheelParts = {}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BoostGUI"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

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


local function showNotice(msg, duration)
	duration = duration or 3

	local noticeScreenGui = PlayerGui:FindFirstChild("KeybindNotice")
	if not noticeScreenGui then
		noticeScreenGui = Instance.new("ScreenGui")
		noticeScreenGui.Name = "KeybindNotice"
		noticeScreenGui.IgnoreGuiInset = true
		noticeScreenGui.ResetOnSpawn = false
		noticeScreenGui.Parent = PlayerGui
	end

	local label = noticeScreenGui:FindFirstChild("NoticeLabel")
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
		label.Parent = noticeScreenGui

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 14)
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

local function getVehicle()
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	local seat = humanoid and humanoid.SeatPart
	return seat and seat:IsA("VehicleSeat") and seat or nil
end



local function updateSliderFromX(x)
	local sliderStart = sliderFrame.AbsolutePosition.X
	local sliderWidth = sliderFrame.AbsoluteSize.X
	local clampedX = math.clamp(x, sliderStart, sliderStart + sliderWidth)
	local rel = (clampedX - sliderStart) / sliderWidth

	sliderButton.Position = UDim2.new(rel, -sliderButton.Size.X.Offset/2, -0.1, 0)
	boostProgressBar.Size = UDim2.new(rel, 0, 1, 0)

	local maxBoost = 100
	local step = 1
	local rawValue = rel * maxBoost
	local roundedValue = math.floor((rawValue + step/2) / step) * step
	boostPercent = math.clamp(roundedValue, 0, maxBoost)

	sliderValueLabel.Text = string.format("%d%%", boostPercent)
end

local function isWKeyPressed()
	for _, key in ipairs(UserInputService:GetKeysPressed()) do
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
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		updateSliderFromX(input.Position.X)
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

local function findWheels()
	local vehicle = getVehicle()
	if not vehicle then
		print("[Wheels Debug] âŒ Nenhum veÃ­culo encontrado")
		return {}
	end
	
	print(string.format("[Wheels Debug] âœ… VeÃ­culo encontrado: %s", vehicle.Name))
	print(string.format("[Wheels Debug] ðŸ“ VeÃ­culo.Parent: %s (tipo: %s)",
		vehicle.Parent and vehicle.Parent.Name or "nil",
		vehicle.Parent and vehicle.Parent.ClassName or "nil"))
	
	local wheels = {}
	
	local current = vehicle
	local topModel = nil
	
	print("[Wheels Debug] ðŸ” Subindo pela hierarquia usando TopModel...")
	while current do
		print(string.format("[Wheels Debug]   Verificando: %s (tipo: %s)", current.Name, current.ClassName))
		
		if current:IsA("Model") then
			local chassis = current:FindFirstChild("Chassis")
			local body = current:FindFirstChild("Body")
			
			if chassis or body then
				topModel = current
				print(string.format("[Wheels Debug]   âœ… Model encontrado com Chassis/Body: %s", current.Name))
				break
			else
				print(string.format("[Wheels Debug]   âš ï¸ Model sem Chassis/Body: %s", current.Name))
			end
		end
		
		current = current.Parent
	end
	
	if not topModel then
		print("[Wheels Debug] âŒ Nenhum Model com Chassis/Body encontrado na hierarquia")
		return {}
	end
	
	print(string.format("[Wheels Debug] âœ… TopModel final: %s", topModel.Name))
	
	print("[Wheels Debug] ðŸ” MÃ©todo 1: Buscando Chassis -> Wheels -> PhysicalWheel")
	
	local chassis = topModel:FindFirstChild("Chassis")
	if not chassis then
		chassis = topModel:FindFirstChild("Body")
	end
	
	if not chassis then
		print("[Wheels Debug] âŒ Chassis/Body nÃ£o encontrado no TopModel")
		print(string.format("[Wheels Debug] ðŸ“‹ Filhos do TopModel: %s",
			table.concat((function()
				local names = {}
				for _, child in ipairs(topModel:GetChildren()) do
					table.insert(names, child.Name .. " (" .. child.ClassName .. ")")
				end
				return names
			end)(), ", ")))
	else
		print(string.format("[Wheels Debug] âœ… Chassis/Body encontrado: %s (tipo: %s)", chassis.Name, chassis.ClassName))
		
		local wheelsFolder = chassis:FindFirstChild("Wheels")
		if not wheelsFolder then
			print("[Wheels Debug] âŒ Wheels nÃ£o encontrado em Chassis/Body")
			print(string.format("[Wheels Debug] ðŸ“‹ Filhos do Chassis/Body: %s",
				table.concat((function()
					local names = {}
					for _, child in ipairs(chassis:GetChildren()) do
						table.insert(names, child.Name .. " (" .. child.ClassName .. ")")
					end
					return names
				end)(), ", ")))
		else
			print(string.format("[Wheels Debug] âœ… Wheels encontrado: %s (tipo: %s)", wheelsFolder.Name, wheelsFolder.ClassName))
			print(string.format("[Wheels Debug] ðŸ“‹ Itens em Wheels: %d", #wheelsFolder:GetChildren()))
			
			for i, wheelModel in ipairs(wheelsFolder:GetChildren()) do
				print(string.format("[Wheels Debug]   [%d] %s (tipo: %s)", i, wheelModel.Name, wheelModel.ClassName))
				
				if wheelModel:IsA("Model") then
					local physicalWheel = wheelModel:FindFirstChild("PhysicalWheel")
					if not physicalWheel then
						print(string.format("[Wheels Debug]     âŒ PhysicalWheel nÃ£o encontrado em %s", wheelModel.Name))
						print(string.format("[Wheels Debug]     ðŸ“‹ Filhos: %s",
							table.concat((function()
								local names = {}
								for _, child in ipairs(wheelModel:GetChildren()) do
									table.insert(names, child.Name .. " (" .. child.ClassName .. ")")
								end
								return names
							end)(), ", ")))
					else
						if physicalWheel:IsA("BasePart") then
							table.insert(wheels, physicalWheel)
							print(string.format("[Wheels Debug]     âœ… PhysicalWheel encontrado: %s (tipo: %s)",
								physicalWheel.Name, physicalWheel.ClassName))
						else
							print(string.format("[Wheels Debug]     âŒ PhysicalWheel nÃ£o Ã© BasePart (Ã© %s)", physicalWheel.ClassName))
						end
					end
				else
					print(string.format("[Wheels Debug]     âš ï¸ %s nÃ£o Ã© Model (Ã© %s)", wheelModel.Name, wheelModel.ClassName))
				end
			end
		end
	end
	
	print(string.format("[Wheels Debug] ðŸ“Š MÃ©todo 1 encontrou %d rodas", #wheels))
	
	if #wheels == 0 then
		print("[Wheels Debug] ðŸ” MÃ©todo 2: Buscando todas PhysicalWheel via GetDescendants no TopModel")
		print(string.format("[Wheels Debug] ðŸ” Buscando em TopModel: %s", topModel.Name))
		
		local allDescendants = topModel:GetDescendants()
		print(string.format("[Wheels Debug] ðŸ“‹ Total de descendentes: %d", #allDescendants))
		
		for _, descendant in ipairs(allDescendants) do
			if descendant.Name == "PhysicalWheel" then
				print(string.format("[Wheels Debug]   âœ… Encontrado: %s (tipo: %s, path: %s)",
					descendant.Name, descendant.ClassName, descendant:GetFullName()))
				
				if descendant:IsA("BasePart") then
					table.insert(wheels, descendant)
					print(string.format("[Wheels Debug]     âœ… Adicionado Ã  lista (total: %d)", #wheels))
				else
					print(string.format("[Wheels Debug]     âŒ NÃ£o Ã© BasePart (Ã© %s)", descendant.ClassName))
				end
			end
		end
		
		print(string.format("[Wheels Debug] ðŸ“Š MÃ©todo 2 encontrou %d rodas", #wheels))
	end
	
	print(string.format("[Wheels Debug] ðŸŽ¯ Total final de rodas encontradas: %d", #wheels))
	if #wheels > 0 then
		for i, wheel in ipairs(wheels) do
			print(string.format("[Wheels Debug]   [%d] %s (path: %s)", i, wheel.Name, wheel:GetFullName()))
		end
	end
	
	return wheels
end

local function applyWheelProperties()
	wheelParts = findWheels()
	
	if #wheelParts == 0 then
		print("[Wheels] Nenhuma roda encontrada")
		return false
	end
	
	print(string.format("[Wheels] Encontradas %d rodas", #wheelParts))
	
	local successCount = 0
	for _, wheel in ipairs(wheelParts) do
		local success, err = pcall(function()
			if wheel:IsA("BasePart") then
				local currentProps = wheel.CustomPhysicalProperties
				if not currentProps then
					currentProps = PhysicalProperties.new(0.7, 0.3, 0.5, 1, 1)
				end
				
				local newProps = PhysicalProperties.new(
					wheelDensity,
					wheelFriction,
					wheelElasticity,
					currentProps.FrictionWeight,
					currentProps.ElasticityWeight
				)
				wheel.CustomPhysicalProperties = newProps
				successCount = successCount + 1
			end
		end)
		
		if not success then
			warn("[Wheels] Erro ao modificar roda:", wheel.Name, err)
		end
	end
	
	print(string.format("[Wheels] Propriedades aplicadas em %d/%d rodas", successCount, #wheelParts))
	return successCount > 0
end

local wheelsFrame = Instance.new("Frame")
wheelsFrame.Size = UDim2.new(0, 200, 0, 100)
wheelsFrame.Position = UDim2.new(0.5, -100, 0.64, 0)
wheelsFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
wheelsFrame.BorderSizePixel = 0
wheelsFrame.Parent = screenGui

local wheelsCorner = Instance.new("UICorner")
wheelsCorner.CornerRadius = UDim.new(0, 5)
wheelsCorner.Parent = wheelsFrame

local densityLabel = Instance.new("TextLabel")
densityLabel.Size = UDim2.new(0, 80, 0, 30)
densityLabel.Position = UDim2.new(0, 5, 0, 5)
densityLabel.BackgroundTransparency = 1
densityLabel.TextColor3 = Color3.fromRGB(255,255,255)
densityLabel.Font = Enum.Font.SourceSans
densityLabel.TextScaled = true
densityLabel.Text = "Density:"
densityLabel.TextXAlignment = Enum.TextXAlignment.Left
densityLabel.Parent = wheelsFrame

local densityTextBox = Instance.new("TextBox")
densityTextBox.Size = UDim2.new(0, 60, 0, 25)
densityTextBox.Position = UDim2.new(1, -65, 0, 7)
densityTextBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
densityTextBox.BorderSizePixel = 1
densityTextBox.BorderColor3 = Color3.fromRGB(100,100,100)
densityTextBox.TextColor3 = Color3.fromRGB(255,255,255)
densityTextBox.Font = Enum.Font.SourceSans
densityTextBox.TextSize = 12
densityTextBox.Text = string.format("%.2f", wheelDensity)
densityTextBox.ClearTextOnFocus = false
densityTextBox.Parent = wheelsFrame

local densityTextBoxCorner = Instance.new("UICorner")
densityTextBoxCorner.CornerRadius = UDim.new(0, 3)
densityTextBoxCorner.Parent = densityTextBox

local frictionLabel = Instance.new("TextLabel")
frictionLabel.Size = UDim2.new(0, 80, 0, 30)
frictionLabel.Position = UDim2.new(0, 5, 0, 35)
frictionLabel.BackgroundTransparency = 1
frictionLabel.TextColor3 = Color3.fromRGB(255,255,255)
frictionLabel.Font = Enum.Font.SourceSans
frictionLabel.TextScaled = true
frictionLabel.Text = "Friction:"
frictionLabel.TextXAlignment = Enum.TextXAlignment.Left
frictionLabel.Parent = wheelsFrame

local frictionTextBox = Instance.new("TextBox")
frictionTextBox.Size = UDim2.new(0, 60, 0, 25)
frictionTextBox.Position = UDim2.new(1, -65, 0, 37)
frictionTextBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
frictionTextBox.BorderSizePixel = 1
frictionTextBox.BorderColor3 = Color3.fromRGB(100,100,100)
frictionTextBox.TextColor3 = Color3.fromRGB(255,255,255)
frictionTextBox.Font = Enum.Font.SourceSans
frictionTextBox.TextSize = 12
frictionTextBox.Text = string.format("%.2f", wheelFriction)
frictionTextBox.ClearTextOnFocus = false
frictionTextBox.Parent = wheelsFrame

local frictionTextBoxCorner = Instance.new("UICorner")
frictionTextBoxCorner.CornerRadius = UDim.new(0, 3)
frictionTextBoxCorner.Parent = frictionTextBox
 
local elasticityLabel = Instance.new("TextLabel")
elasticityLabel.Size = UDim2.new(0, 80, 0, 30)
elasticityLabel.Position = UDim2.new(0, 5, 0, 65)
elasticityLabel.BackgroundTransparency = 1
elasticityLabel.TextColor3 = Color3.fromRGB(255,255,255)
elasticityLabel.Font = Enum.Font.SourceSans
elasticityLabel.TextScaled = true
elasticityLabel.Text = "Elasticity:"
elasticityLabel.TextXAlignment = Enum.TextXAlignment.Left
elasticityLabel.Parent = wheelsFrame

local elasticityTextBox = Instance.new("TextBox")
elasticityTextBox.Size = UDim2.new(0, 60, 0, 25)
elasticityTextBox.Position = UDim2.new(1, -65, 0, 67)
elasticityTextBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
elasticityTextBox.BorderSizePixel = 1
elasticityTextBox.BorderColor3 = Color3.fromRGB(100,100,100)
elasticityTextBox.TextColor3 = Color3.fromRGB(255,255,255)
elasticityTextBox.Font = Enum.Font.SourceSans
elasticityTextBox.TextSize = 12
elasticityTextBox.Text = string.format("%.2f", wheelElasticity)
elasticityTextBox.ClearTextOnFocus = false
elasticityTextBox.Parent = wheelsFrame

local elasticityTextBoxCorner = Instance.new("UICorner")
elasticityTextBoxCorner.CornerRadius = UDim.new(0, 3)
elasticityTextBoxCorner.Parent = elasticityTextBox
 
local hasInitializedDefaults = false
local function setDefaultsFromCar()
	local wheels = findWheels()
	if #wheels == 0 then return end
	
	local sumDensity, sumFriction, sumElasticity = 0, 0, 0
	local count = 0
	for _, w in ipairs(wheels) do
		if w and w:IsA("BasePart") then
			local p = w.CustomPhysicalProperties
			if not p then
				p = PhysicalProperties.new(0.7, 0.3, 0.5, 1, 1)
			end
			sumDensity += p.Density
			sumFriction += p.Friction
			sumElasticity += p.Elasticity
			count += 1
		end
	end
	if count > 0 then
		wheelDensity = sumDensity / count
		wheelFriction = sumFriction / count
		wheelElasticity = sumElasticity / count
		
		if densityTextBox then
			densityTextBox.Text = string.format("%.2f", wheelDensity)
		end
		if frictionTextBox then
			frictionTextBox.Text = string.format("%.2f", wheelFriction)
		end
		if elasticityTextBox then
			elasticityTextBox.Text = string.format("%.2f", wheelElasticity)
		end
		hasInitializedDefaults = true
	end
end

local function validateAndSetDensity(input)
	local numValue = tonumber(input)
	
	if not numValue or numValue <= 0 then
		showNotice("âŒ Valor invÃ¡lido!\nUse apenas nÃºmeros > 0", 2)
		densityTextBox.Text = string.format("%.2f", wheelDensity)
		return false
	end
	
	wheelDensity = numValue
	densityTextBox.Text = string.format("%.2f", wheelDensity)
	
	if applyWheelProperties() then
		showNotice(string.format("âœ… Density: %.2f", wheelDensity), 1.5)
		print(string.format("[Wheels] Density atualizado: %.2f", wheelDensity))
	else
		showNotice("âš ï¸ Nenhuma roda encontrada", 2)
	end
	
	return true
end

local function validateAndSetFriction(input)
	local numValue = tonumber(input)
	
	if not numValue or numValue <= 0 then
		showNotice("âŒ Valor invÃ¡lido!\nUse apenas nÃºmeros > 0", 2)
		frictionTextBox.Text = string.format("%.2f", wheelFriction)
		return false
	end
	
	wheelFriction = numValue
	frictionTextBox.Text = string.format("%.2f", wheelFriction)
	
	if applyWheelProperties() then
		showNotice(string.format("âœ… Friction: %.2f", wheelFriction), 1.5)
		print(string.format("[Wheels] Friction atualizado: %.2f", wheelFriction))
	else
		showNotice("âš ï¸ Nenhuma roda encontrada", 2)
	end
	
	return true
end

local function validateAndSetElasticity(input)
	local numValue = tonumber(input)
	
	if not numValue or numValue < 0 then
		showNotice("âŒ Valor invÃ¡lido!\nUse apenas nÃºmeros â‰¥ 0", 2)
		elasticityTextBox.Text = string.format("%.2f", wheelElasticity)
		return false
	end
	
	wheelElasticity = numValue
	elasticityTextBox.Text = string.format("%.2f", wheelElasticity)
	
	if applyWheelProperties() then
		showNotice(string.format("âœ… Elasticity: %.2f", wheelElasticity), 1.5)
		print(string.format("[Wheels] Elasticity atualizado: %.2f", wheelElasticity))
	else
		showNotice("âš ï¸ Nenhuma roda encontrada", 2)
	end
	
	return true
end

densityTextBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		validateAndSetDensity(densityTextBox.Text)
	else
		densityTextBox.Text = string.format("%.2f", wheelDensity)
	end
end)

frictionTextBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		validateAndSetFriction(frictionTextBox.Text)
	else
		frictionTextBox.Text = string.format("%.2f", wheelFriction)
	end
end)

elasticityTextBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		validateAndSetElasticity(elasticityTextBox.Text)
	else
		elasticityTextBox.Text = string.format("%.2f", wheelElasticity)
	end
end)

densityTextBox.Changed:Connect(function(property)
	if property == "Text" then
		local text = densityTextBox.Text
		local cleaned = string.gsub(text, "[^%d.]", "")
		if cleaned ~= text then
			densityTextBox.Text = cleaned
		end
	end
end)

frictionTextBox.Changed:Connect(function(property)
	if property == "Text" then
		local text = frictionTextBox.Text
		local cleaned = string.gsub(text, "[^%d.]", "")
		if cleaned ~= text then
			frictionTextBox.Text = cleaned
		end
	end
end)

elasticityTextBox.Changed:Connect(function(property)
	if property == "Text" then
		local text = elasticityTextBox.Text
		local cleaned = string.gsub(text, "[^%d.]", "")
		if cleaned ~= text then
			elasticityTextBox.Text = cleaned
		end
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

local lastVehicleState = false

RunService.Heartbeat:Connect(function()
	local character = player.Character
	local head = character and character:FindFirstChild("Head")
	local vehicle = getVehicle()
	local speedLabel = getOrCreateSpeedLabel()
	local isInVehicle = vehicle ~= nil

	if isInVehicle ~= lastVehicleState then
		lastVehicleState = isInVehicle
	end

	if vehicle and head and speedLabel then
		speedLabel.Text = string.format("%.1f", vehicle.AssemblyLinearVelocity.Magnitude) .. " m/s"
		speedLabel.Parent.Enabled = true
	elseif speedLabel and speedLabel.Parent then
		speedLabel.Parent.Enabled = false
	end
end)

local currentWheelUI = nil

local function createWheelUI(wheelPart)
	if currentWheelUI then
		currentWheelUI:Destroy()
		currentWheelUI = nil
	end
	
	local wheelClickDetector = wheelPart:FindFirstChildOfClass("ClickDetector")
	local previousClickDistance
	if wheelClickDetector then
		previousClickDistance = wheelClickDetector.MaxActivationDistance
		wheelClickDetector.MaxActivationDistance = 0
	end
	
	local mainFrame = Instance.new("Frame")
	mainFrame.Size = UDim2.new(0, 300, 0, 200)
	mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = screenGui
	mainFrame.Active = true
	mainFrame.Selectable = true
	mainFrame.ZIndex = 10
	
	local dragging = false
	local dragStart
	local startPos
	local inputChangedConn
	
	mainFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = mainFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	
	inputChangedConn = UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			mainFrame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
	
	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 10)
	mainCorner.Parent = mainFrame
	
	local border = Instance.new("UIStroke")
	border.Color = Color3.fromRGB(0, 255, 150)
	border.Thickness = 2
	border.Parent = mainFrame
	
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -20, 0, 30)
	titleLabel.Position = UDim2.new(0, 10, 0, 10)
	titleLabel.BackgroundTransparency = 1
	titleLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 18
	titleLabel.Text = "Editar Roda: " .. wheelPart.Name
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = mainFrame
	titleLabel.ZIndex = 11
	
	local closeButton = Instance.new("TextButton")
	closeButton.Size = UDim2.new(0, 25, 0, 25)
	closeButton.Position = UDim2.new(1, -30, 0, 5)
	closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.Font = Enum.Font.GothamBold
	closeButton.TextSize = 16
	closeButton.Text = "Ã—"
	closeButton.Parent = mainFrame
	closeButton.ZIndex = 12
	
	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 5)
	closeCorner.Parent = closeButton
	
	closeButton.MouseButton1Click:Connect(function()
		if wheelClickDetector then
			wheelClickDetector.MaxActivationDistance = previousClickDistance or 50
		end
		if inputChangedConn then
			inputChangedConn:Disconnect()
			inputChangedConn = nil
		end
		if currentWheelUI then
			currentWheelUI:Destroy()
			currentWheelUI = nil
		end
	end)
	
	local currentProps = wheelPart.CustomPhysicalProperties
	if not currentProps then
		currentProps = PhysicalProperties.new(0.7, 0.3, 0.5, 1, 1)
	end
	
	local currentDensity = currentProps.Density
	local currentFriction = currentProps.Friction
	local currentElasticity = currentProps.Elasticity
	
	local densityFrame = Instance.new("Frame")
	densityFrame.Size = UDim2.new(1, -20, 0, 60)
	densityFrame.Position = UDim2.new(0, 10, 0, 45)
	densityFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	densityFrame.BorderSizePixel = 0
	densityFrame.Parent = mainFrame
	densityFrame.ZIndex = 11
	
	local densityCorner = Instance.new("UICorner")
	densityCorner.CornerRadius = UDim.new(0, 5)
	densityCorner.Parent = densityFrame
	
	local densityLabel = Instance.new("TextLabel")
	densityLabel.Size = UDim2.new(0, 80, 0, 25)
	densityLabel.Position = UDim2.new(0, 5, 0, 5)
	densityLabel.BackgroundTransparency = 1
	densityLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	densityLabel.Font = Enum.Font.Gotham
	densityLabel.TextSize = 14
	densityLabel.Text = "Density:"
	densityLabel.TextXAlignment = Enum.TextXAlignment.Left
	densityLabel.Parent = densityFrame
	densityLabel.ZIndex = 12
	
	local densityTextBox = Instance.new("TextBox")
	densityTextBox.Size = UDim2.new(0, 80, 0, 25)
	densityTextBox.Position = UDim2.new(0, 90, 0, 5)
	densityTextBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	densityTextBox.BorderSizePixel = 1
	densityTextBox.BorderColor3 = Color3.fromRGB(100, 100, 100)
	densityTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	densityTextBox.Font = Enum.Font.Gotham
	densityTextBox.TextSize = 14
	densityTextBox.Text = string.format("%.2f", currentDensity)
	densityTextBox.ClearTextOnFocus = false
	densityTextBox.Parent = densityFrame
	densityTextBox.Active = true
	densityTextBox.Selectable = true
	densityTextBox.ZIndex = 12
	
	local densityTextBoxCorner = Instance.new("UICorner")
	densityTextBoxCorner.CornerRadius = UDim.new(0, 3)
	densityTextBoxCorner.Parent = densityTextBox
	
	local densityApplyButton = Instance.new("TextButton")
	densityApplyButton.Size = UDim2.new(0, 60, 0, 25)
	densityApplyButton.Position = UDim2.new(0, 175, 0, 5)
	densityApplyButton.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
	densityApplyButton.TextColor3 = Color3.fromRGB(0, 0, 0)
	densityApplyButton.Font = Enum.Font.GothamBold
	densityApplyButton.TextSize = 12
	densityApplyButton.Text = "Aplicar"
	densityApplyButton.Parent = densityFrame
	densityApplyButton.ZIndex = 12
	
	local densityApplyCorner = Instance.new("UICorner")
	densityApplyCorner.CornerRadius = UDim.new(0, 3)
	densityApplyCorner.Parent = densityApplyButton
	
	local frictionFrame = Instance.new("Frame")
	frictionFrame.Size = UDim2.new(1, -20, 0, 60)
	frictionFrame.Position = UDim2.new(0, 10, 0, 110)
	frictionFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	frictionFrame.BorderSizePixel = 0
	frictionFrame.Parent = mainFrame
	frictionFrame.ZIndex = 11
	
	local frictionCorner = Instance.new("UICorner")
	frictionCorner.CornerRadius = UDim.new(0, 5)
	frictionCorner.Parent = frictionFrame
	
	local frictionLabel = Instance.new("TextLabel")
	frictionLabel.Size = UDim2.new(0, 80, 0, 25)
	frictionLabel.Position = UDim2.new(0, 5, 0, 5)
	frictionLabel.BackgroundTransparency = 1
	frictionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	frictionLabel.Font = Enum.Font.Gotham
	frictionLabel.TextSize = 14
	frictionLabel.Text = "Friction:"
	frictionLabel.TextXAlignment = Enum.TextXAlignment.Left
	frictionLabel.Parent = frictionFrame
	frictionLabel.ZIndex = 12
	
	local frictionTextBox = Instance.new("TextBox")
	frictionTextBox.Size = UDim2.new(0, 80, 0, 25)
	frictionTextBox.Position = UDim2.new(0, 90, 0, 5)
	frictionTextBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	frictionTextBox.BorderSizePixel = 1
	frictionTextBox.BorderColor3 = Color3.fromRGB(100, 100, 100)
	frictionTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	frictionTextBox.Font = Enum.Font.Gotham
	frictionTextBox.TextSize = 14
	frictionTextBox.Text = string.format("%.2f", currentFriction)
	frictionTextBox.ClearTextOnFocus = false
	frictionTextBox.Parent = frictionFrame
	frictionTextBox.Active = true
	frictionTextBox.Selectable = true
	frictionTextBox.ZIndex = 12
	
	local frictionTextBoxCorner = Instance.new("UICorner")
	frictionTextBoxCorner.CornerRadius = UDim.new(0, 3)
	frictionTextBoxCorner.Parent = frictionTextBox
	
	local frictionApplyButton = Instance.new("TextButton")
	frictionApplyButton.Size = UDim2.new(0, 60, 0, 25)
	frictionApplyButton.Position = UDim2.new(0, 175, 0, 5)
	frictionApplyButton.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
	frictionApplyButton.TextColor3 = Color3.fromRGB(0, 0, 0)
	frictionApplyButton.Font = Enum.Font.GothamBold
	frictionApplyButton.TextSize = 12
	frictionApplyButton.Text = "Aplicar"
	frictionApplyButton.Parent = frictionFrame
	frictionApplyButton.Active = true
	frictionApplyButton.Selectable = true
	frictionApplyButton.ZIndex = 12
	local frictionApplyCorner = Instance.new("UICorner")
	frictionApplyCorner.CornerRadius = UDim.new(0, 3)
	frictionApplyCorner.Parent = frictionApplyButton
	
	local elasticityFrame = Instance.new("Frame")
	elasticityFrame.Size = UDim2.new(1, -20, 0, 60)
	elasticityFrame.Position = UDim2.new(0, 10, 0, 175)
	elasticityFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	elasticityFrame.BorderSizePixel = 0
	elasticityFrame.Parent = mainFrame
	elasticityFrame.ZIndex = 11
	
	local elasticityCorner = Instance.new("UICorner")
	elasticityCorner.CornerRadius = UDim.new(0, 5)
	elasticityCorner.Parent = elasticityFrame
	
	local elasticityLabel = Instance.new("TextLabel")
	elasticityLabel.Size = UDim2.new(0, 80, 0, 25)
	elasticityLabel.Position = UDim2.new(0, 5, 0, 5)
	elasticityLabel.BackgroundTransparency = 1
	elasticityLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	elasticityLabel.Font = Enum.Font.Gotham
	elasticityLabel.TextSize = 14
	elasticityLabel.Text = "Elasticity:"
	elasticityLabel.TextXAlignment = Enum.TextXAlignment.Left
	elasticityLabel.Parent = elasticityFrame
	elasticityLabel.ZIndex = 12
	
	local elasticityTextBox = Instance.new("TextBox")
	elasticityTextBox.Size = UDim2.new(0, 80, 0, 25)
	elasticityTextBox.Position = UDim2.new(0, 90, 0, 5)
	elasticityTextBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	elasticityTextBox.BorderSizePixel = 1
	elasticityTextBox.BorderColor3 = Color3.fromRGB(100, 100, 100)
	elasticityTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	elasticityTextBox.Font = Enum.Font.Gotham
	elasticityTextBox.TextSize = 14
	elasticityTextBox.Text = string.format("%.2f", currentElasticity)
	elasticityTextBox.ClearTextOnFocus = false
	elasticityTextBox.Parent = elasticityFrame
	elasticityTextBox.Active = true
	elasticityTextBox.Selectable = true
	elasticityTextBox.ZIndex = 12
	
	local elasticityTextBoxCorner = Instance.new("UICorner")
	elasticityTextBoxCorner.CornerRadius = UDim.new(0, 3)
	elasticityTextBoxCorner.Parent = elasticityTextBox
	
	local elasticityApplyButton = Instance.new("TextButton")
	elasticityApplyButton.Size = UDim2.new(0, 60, 0, 25)
	elasticityApplyButton.Position = UDim2.new(0, 175, 0, 5)
	elasticityApplyButton.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
	elasticityApplyButton.TextColor3 = Color3.fromRGB(0, 0, 0)
	elasticityApplyButton.Font = Enum.Font.GothamBold
	elasticityApplyButton.TextSize = 12
	elasticityApplyButton.Text = "Aplicar"
	elasticityApplyButton.Parent = elasticityFrame
	elasticityApplyButton.ZIndex = 12
	
	local elasticityApplyCorner = Instance.new("UICorner")
	elasticityApplyCorner.CornerRadius = UDim.new(0, 3)
	elasticityApplyCorner.Parent = elasticityApplyButton
	
	local function applyDensity()
		local numValue = tonumber(densityTextBox.Text)
		if not numValue or numValue <= 0 then
			showNotice("âŒ Density invÃ¡lido!", 1.5)
			densityTextBox.Text = string.format("%.2f", currentDensity)
			return
		end
		
		local success, err = pcall(function()
			local props = wheelPart.CustomPhysicalProperties
			if not props then
				props = PhysicalProperties.new(0.7, 0.3, 0.5, 1, 1)
			end
			
			local newProps = PhysicalProperties.new(
				numValue,
				props.Friction,
				props.Elasticity,
				props.FrictionWeight,
				props.ElasticityWeight
			)
			wheelPart.CustomPhysicalProperties = newProps
			currentDensity = numValue
		end)
		
		if success then
			showNotice(string.format("âœ… Density: %.2f", numValue), 1.5)
			print(string.format("[WheelEdit] Density aplicado em %s: %.2f", wheelPart.Name, numValue))
		else
			showNotice("âŒ Erro ao aplicar!", 1.5)
			warn("[WheelEdit] Erro:", err)
		end
	end
	
	local function applyFriction()
		local numValue = tonumber(frictionTextBox.Text)
		if not numValue or numValue <= 0 then
			showNotice("âŒ Friction invÃ¡lido!", 1.5)
			frictionTextBox.Text = string.format("%.2f", currentFriction)
			return
		end
		
		local success, err = pcall(function()
			local props = wheelPart.CustomPhysicalProperties
			if not props then
				props = PhysicalProperties.new(0.7, 0.3, 0.5, 1, 1)
			end
			
			local newProps = PhysicalProperties.new(
				props.Density,
				numValue,
				props.Elasticity,
				props.FrictionWeight,
				props.ElasticityWeight
			)
			wheelPart.CustomPhysicalProperties = newProps
			currentFriction = numValue
		end)
		
		if success then
			showNotice(string.format("âœ… Friction: %.2f", numValue), 1.5)
			print(string.format("[WheelEdit] Friction aplicado em %s: %.2f", wheelPart.Name, numValue))
		else
			showNotice("âŒ Erro ao aplicar!", 1.5)
			warn("[WheelEdit] Erro:", err)
		end
	end
	
	local function applyElasticity()
		local numValue = tonumber(elasticityTextBox.Text)
		if not numValue or numValue < 0 then
			showNotice("âŒ Elasticity invÃ¡lido! (mÃ­nimo 0)", 1.5)
			elasticityTextBox.Text = string.format("%.2f", currentElasticity)
			return
		end
		
		local success, err = pcall(function()
			local props = wheelPart.CustomPhysicalProperties
			if not props then
				props = PhysicalProperties.new(0.7, 0.3, 0.5, 1, 1)
			end
			
			local newProps = PhysicalProperties.new(
				props.Density,
				props.Friction,
				numValue,
				props.FrictionWeight,
				props.ElasticityWeight
			)
			wheelPart.CustomPhysicalProperties = newProps
			currentElasticity = numValue
		end)
		
		if success then
			showNotice(string.format("âœ… Elasticity: %.2f", numValue), 1.5)
			print(string.format("[WheelEdit] Elasticity aplicado em %s: %.2f", wheelPart.Name, numValue))
		else
			showNotice("âŒ Erro ao aplicar!", 1.5)
			warn("[WheelEdit] Erro:", err)
		end
	end
	
	densityApplyButton.MouseButton1Click:Connect(applyDensity)
	frictionApplyButton.MouseButton1Click:Connect(applyFriction)
	elasticityApplyButton.MouseButton1Click:Connect(applyElasticity)
	
	densityTextBox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			applyDensity()
		else
			densityTextBox.Text = string.format("%.2f", currentDensity)
		end
	end)
	
	frictionTextBox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			applyFriction()
		else
			frictionTextBox.Text = string.format("%.2f", currentFriction)
		end
	end)
	
	elasticityTextBox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			applyElasticity()
		else
			elasticityTextBox.Text = string.format("%.2f", currentElasticity)
		end
	end)
	
	densityTextBox.Changed:Connect(function(property)
		if property == "Text" then
			local text = densityTextBox.Text
			local cleaned = string.gsub(text, "[^%d.]", "")
			if cleaned ~= text then
				densityTextBox.Text = cleaned
			end
		end
	end)
	
	frictionTextBox.Changed:Connect(function(property)
		if property == "Text" then
			local text = frictionTextBox.Text
			local cleaned = string.gsub(text, "[^%d.]", "")
			if cleaned ~= text then
				frictionTextBox.Text = cleaned
			end
		end
	end)
	
	elasticityTextBox.Changed:Connect(function(property)
		if property == "Text" then
			local text = elasticityTextBox.Text
			local cleaned = string.gsub(text, "[^%d.]", "")
			if cleaned ~= text then
				elasticityTextBox.Text = cleaned
			end
		end
	end)
	
	currentWheelUI = mainFrame
	
	local endSize = UDim2.new(0, 300, 0, 260)
	local startSize = UDim2.new(0, 0, 0, 0)
	mainFrame.Size = startSize
	local sizeTween = TweenService:Create(
		mainFrame,
		TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Size = endSize}
	)
	sizeTween:Play()
	
	mainFrame.BackgroundTransparency = 1
	local fadeTween = TweenService:Create(
		mainFrame,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{BackgroundTransparency = 0}
	)
	fadeTween:Play()
	
	print(string.format("[WheelEdit] UI criada com animaÃ§Ã£o para roda: %s", wheelPart:GetFullName()))
end

local wheelClickDetectors = {}

local function addClickDetectorsToWheels()
	for _, detector in pairs(wheelClickDetectors) do
		if detector and detector.Parent then
			detector:Destroy()
		end
	end
	wheelClickDetectors = {}
	
	local wheels = findWheels()
	
	if #wheels == 0 then
		print("[WheelClick] Nenhuma roda encontrada para adicionar ClickDetector")
		return
	end
	
	print(string.format("[WheelClick] Adicionando ClickDetector em %d rodas", #wheels))
	
	for _, wheel in ipairs(wheels) do
		if wheel and wheel.Parent then
			local oldDetector = wheel:FindFirstChildOfClass("ClickDetector")
			if oldDetector then
				oldDetector:Destroy()
			end
			
			local clickDetector = Instance.new("ClickDetector")
			clickDetector.MaxActivationDistance = 50
			clickDetector.Parent = wheel
			
			table.insert(wheelClickDetectors, clickDetector)
			
			clickDetector.MouseClick:Connect(function(playerWhoClicked)
				if playerWhoClicked == player then
					createWheelUI(wheel)
					print(string.format("[WheelClick] Clique detectado na roda: %s", wheel:GetFullName()))
				end
			end)
		end
	end
	
	print(string.format("[WheelClick] ClickDetectors adicionados em %d rodas", #wheelClickDetectors))
end

local lastVehicleForWheels = nil
local wheelApplyDelay = 0
RunService.Heartbeat:Connect(function()
	local vehicle = getVehicle()
	
	if vehicle and vehicle ~= lastVehicleForWheels then
		lastVehicleForWheels = vehicle
		wheelApplyDelay = 10
	end
	
	if vehicle and wheelApplyDelay > 0 then
		wheelApplyDelay = wheelApplyDelay - 1
		if wheelApplyDelay == 0 then
			if not hasInitializedDefaults then
				setDefaultsFromCar()
			end
			applyWheelProperties()
			task.wait(0.2)
			addClickDetectorsToWheels()
		end
	end
end)

showNotice("ðŸ”¸ Controles:\nðŸŽ¥ Modo Stream: V\nðŸš€ Boost: " .. boostKey.Name, 3)

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
			
			local currentVel = currentVehicle.AssemblyLinearVelocity
			local horizontalVel = Vector3.new(currentVel.X, 0, currentVel.Z)
			
			if horizontalVel.Magnitude > 0 then
				local currentSpeed = horizontalVel.Magnitude
				local targetSpeed = baseSpeed * boostMultiplier
				
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
			baseSpeed = nil
			
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
	keyButton,
	wheelsFrame
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
