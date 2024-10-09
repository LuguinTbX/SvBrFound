local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local character = game.Players.LocalPlayer.Character

-- Função para criar uma nova Part e retorná-la
local function createPart()
	local newPart = Instance.new("Part")
	newPart.Anchored = false
	newPart.Size = Vector3.new(15.88, 1, 0.97)
	newPart.Material = Enum.Material.Plastic
	newPart.Color = Color3.new(1, 0, 0)
	newPart.CanCollide = false
	newPart.Parent = Workspace
	return newPart
end

-- Função para atualizar a posição da Part na frente de um modelo
local function updatePartPosition(model, part)
	if model and model:FindFirstChild("HumanoidRootPart") then
		local humanoidRootPart = model:FindFirstChild("HumanoidRootPart")
		local distanceInFront = 9
		local frontPosition = humanoidRootPart.Position + (humanoidRootPart.CFrame.LookVector * distanceInFront)
		local rotationY = CFrame.Angles(0, math.rad(-90.663), 0)
		part.CFrame = CFrame.new(frontPosition, frontPosition + humanoidRootPart.CFrame.LookVector) * rotationY
	end
end

-- Função para adicionar Part a um Model com Humanoid
local function addPartToModel(model)
	local part = createPart()

	RunService.Heartbeat:Connect(function()
		if model and model.Parent == Workspace then
			updatePartPosition(model, part)
		end
	end)
end

-- Função para verificar e adicionar Part para todos os Models com Humanoids no Workspace
local function initializePartsForAllModels()
	for _, obj in pairs(Workspace:GetChildren()) do
		if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and obj ~= character and _G.Active then
			addPartToModel(obj)
		end
	end
end

-- Detectar quando um novo Model é adicionado ao Workspace
Workspace.ChildAdded:Connect(function(child)
	if child:IsA("Model") and child:FindFirstChildOfClass("Humanoid") and child ~= character and _G.Active then
		addPartToModel(child)
	end
end)

-- Inicializar para todos os Models já presentes no Workspace
initializePartsForAllModels()

-- Função para monitorar a variável global _G.Active
local function monitorGlobalVar()
	while true do
		if not _G.Active then
			-- Destruir todas as Parts criadas
			for i, v in pairs(Workspace:GetDescendants()) do
				if v:IsA("Part") and v.Size == Vector3.new(15.88, 1, 0.97) then
					v:Destroy()
				end
			end
		elseif _G.Active then
			-- Se _G.Active for true, recria as partes para todos os modelos
			initializePartsForAllModels()
		end
		wait(1)  -- Verifica a cada 1 segundo
	end
end

-- Inicia o monitoramento da variável global
spawn(monitorGlobalVar)
