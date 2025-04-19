local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")


local function criarGUI(part)
	local gui = Instance.new("BillboardGui")
	gui.Name = "VelocidadeGui"
	gui.Size = UDim2.new(0, 120, 0, 40)
	gui.StudsOffset = Vector3.new(0, 5, 0)
	gui.AlwaysOnTop = true
	gui.Parent = part

	local texto = Instance.new("TextLabel")
	texto.Size = UDim2.new(1, 0, 1, 0)
	texto.BackgroundTransparency = 1
	texto.TextColor3 = Color3.new(1, 1, 1)
	texto.TextStrokeTransparency = 0.4
	texto.TextScaled = true
	texto.Font = Enum.Font.GothamBold
	texto.Text = "0 m/s   Média: 0"
	texto.Parent = gui

	return texto
end


local veiculos = {}


local function atualizarVeiculos()
	for _, model in ipairs(Workspace:GetDescendants()) do
		if model:IsA("Model") and model:FindFirstChildWhichIsA("VehicleSeat") then
			local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
			if part and not model:FindFirstChild("VelocidadeGui") then 
				local texto = criarGUI(part)
				table.insert(veiculos, {
					model = model,
					part = part,
					texto = texto,
					ultimaPos = part.Position, 
					soma = 0,
					frames = 0,
					mediaSuavizada = 0
				})
			end
		end
	end
end


Workspace.DescendantAdded:Connect(function(descendant)

	if descendant:IsA("Model") and descendant:FindFirstChildWhichIsA("VehicleSeat") then
		local part = descendant.PrimaryPart or descendant:FindFirstChildWhichIsA("BasePart")
		if part then

			local ultimaPos = part.Position or Vector3.new(0, 0, 0) 
			local texto = criarGUI(part)
			table.insert(veiculos, {
				model = descendant,
				part = part,
				texto = texto,
				ultimaPos = ultimaPos,  
				soma = 0,
				frames = 0,
				mediaSuavizada = 0 
			})
		end
	end
end)


atualizarVeiculos()


RunService.Heartbeat:Connect(function(dt)
	for _, info in pairs(veiculos) do
		if info.model and info.part and info.texto then
			local novaPos = info.part.Position
			local velocidade = (novaPos - info.ultimaPos).Magnitude / dt


			if velocidade ~= velocidade then

				info.texto.Text = "0 m/s   Média: 0"
			else
				info.ultimaPos = novaPos
				info.soma += velocidade
				info.frames += 1
				info.mediaSuavizada = (info.mediaSuavizada or velocidade) * 0.9 + velocidade * 0.1
				info.texto.Text = string.format("%.1f m/s \n  Média: %.1f", velocidade, info.mediaSuavizada)
			end
		end
	end
end)
