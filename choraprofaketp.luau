local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local humanoid = player.Character:FindFirstChildOfClass('Humanoid')
_G.Ativado = true
mouse.Button1Down:Connect(function()
	local destination = mouse.Hit.p -- Posição no mundo a partir do mouse

	if _G.Ativado then
		if humanoid and humanoid.Parent then
			local humanoidRootPart = humanoid.Parent:FindFirstChild("HumanoidRootPart")

			-- Verificar se o humanoide está sentado em algum Seat
			if humanoidRootPart and humanoid.SeatPart then
				local seat = humanoid.SeatPart
				local model = seat.Parent -- O modelo ao qual o Seat pertence

				-- Verificar se o modelo tem uma PrimaryPart definida
				if model:IsA("Model") and model.PrimaryPart then
					model:SetPrimaryPartCFrame(CFrame.new(destination)) -- Mover o modelo usando a PrimaryPart
				else

					humanoidRootPart.CFrame = CFrame.new(destination) -- Teleportar o HumanoidRootPart
				end
			end
		end
	end
end)
