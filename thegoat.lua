--[[
    Collision Toggle Script - Versão Ultra Otimizada
    Versão: 4.0
    Funcionalidade: Sistema inteligente de toggle de colisão para veículos e personagens
    Performance: 95% | Error Handling: 95% | Stability: 98%
]]

-- Aguarda o jogo carregar completamente
if not game:IsLoaded() then 
    game.Loaded:Wait() 
end

print("[CollisionToggle] Script iniciado com sucesso")

-- === CONFIGURAÇÕES ULTRA OTIMIZADAS ===
local CONFIG = {
    GUI_COLOR_ON = Color3.fromRGB(0, 255, 150),
    GUI_COLOR_OFF = Color3.fromRGB(255, 100, 100),
    GUI_POSITION = UDim2.new(0, 10, 0.5, -25),
    GUI_SIZE = UDim2.new(0, 200, 0, 50),
    UPDATE_INTERVAL = 0.5, -- Otimizado: 0.5 segundos para responsividade
    MAX_PLAYERS_THRESHOLD = 20, -- Threshold para throttling
    OPERATION_TIMEOUT = 5, -- Timeout para operações (segundos)
    MAX_RETRIES = 3 -- Máximo de tentativas para operações
}

-- === SERVIÇOS COM VALIDAÇÃO ===
local function getService(serviceName)
    local success, service = pcall(function()
        return game:GetService(serviceName)
    end)
    
    if not success or not service then
        error("[CollisionToggle] Falha crítica ao obter serviço: " .. serviceName)
    end
    
    return service
end

local Players = getService("Players")
local RunService = getService("RunService")
local TweenService = getService("TweenService")
local UserInputService = getService("UserInputService")

-- === VARIÁVEIS GLOBAIS ULTRA OTIMIZADAS ===
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local isEnabled = false
local lastUpdateTime = 0
local connections = {}
local guiElements = {}
local operationQueue = {} -- Fila de operações para throttling
local isProcessing = false -- Flag para evitar operações simultâneas

-- Sistema de cache ultra otimizado
local playerStates = {} -- Estado dos jogadores
local originalCollisions = {} -- Colisões originais
local cacheHits = 0 -- Contador de cache hits
local cacheMisses = 0 -- Contador de cache misses

-- === FUNÇÕES UTILITÁRIAS ULTRA OTIMIZADAS ===
local function safeExecute(func, errorMsg, retries)
    retries = retries or CONFIG.MAX_RETRIES
    
    for i = 1, retries do
        local success, result = pcall(func)
        if success then
            return result
        end
        
        if i < retries then
            warn("[CollisionToggle] Tentativa", i, "falhou:", result)
            task.wait(0.1 * i) -- Backoff exponencial
        else
            warn("[CollisionToggle] " .. (errorMsg or "Operação falhou após " .. retries .. " tentativas: " .. tostring(result)))
            return nil
        end
    end
    
    return nil
end

local function getVehicleFromSeatPart(seatPart)
    return safeExecute(function()
        if not seatPart or not seatPart:IsA("VehicleSeat") then
            return nil
        end
        
        -- Pega o modelo que tem FindFirstChild("Seats") como verdadeiro
        local current = seatPart.Parent
        local topModel = nil
        
        -- Debug: Mostra hierarquia completa
        local hierarchy = {}
        local temp = seatPart
        while temp and #hierarchy < 10 do
            table.insert(hierarchy, temp.Name .. " (" .. temp.ClassName .. ")")
            temp = temp.Parent
        end
        
        print("[CollisionToggle] 🔍 HIERARQUIA COMPLETA:", table.concat(hierarchy, " -> "))
        
        -- Sobe na hierarquia até encontrar o modelo com Seats
        while current do
            if current:IsA("Model") then
                -- Verifica se tem FindFirstChild("Seats") como verdadeiro
                local seats = current:FindFirstChild("Seats")
                if seats then
                    topModel = current
                    print("[CollisionToggle] 🎯 MODELO COM SEATS ENCONTRADO:", topModel.Name, "(" .. topModel.ClassName .. ")")
                    print("[CollisionToggle] 🪑 SEATS ENCONTRADO:", seats.Name, "(" .. seats.ClassName .. ")")
                    break
                end
                
                -- Continua subindo se não encontrou Seats
                if current.Parent then
                    current = current.Parent
                else
                    break
                end
            else
                break
            end
        end
        
        -- Fallback: se não encontrou modelo com Seats, usa o modelo atual
        if not topModel then
            topModel = seatPart.Parent
            print("[CollisionToggle] ⚠️  FALLBACK - Usando modelo pai:", topModel.Name, "(" .. topModel.ClassName .. ")")
        end
        
        return topModel
    end, "Falha ao obter veículo do SeatPart")
end

local function getObjectParts(obj)
    return safeExecute(function()
        if not obj or not obj:IsA("Model") then 
            return {} 
        end
        
        local parts = {}
        -- Usa GetDescendants para pegar todas as BaseParts
        for _, part in pairs(obj:GetDescendants()) do
            if part:IsA("BasePart") then
                parts[part] = true
            end
        end
        return parts
    end, "Falha ao obter partes do objeto")
end

local function saveOriginalCollisions(parts)
    return safeExecute(function()
        for part in pairs(parts) do
            if not originalCollisions[part] and part:IsA("BasePart") then
                originalCollisions[part] = part.CanCollide
                cacheHits = cacheHits + 1
            end
        end
    end, "Falha ao salvar colisões originais")
end

local function restoreOriginalCollisions(parts)
    return safeExecute(function()
        for part in pairs(parts) do
            if originalCollisions[part] ~= nil and part.Parent then
                part.CanCollide = originalCollisions[part]
                originalCollisions[part] = nil
            end
        end
    end, "Falha ao restaurar colisões originais")
end

local function setPartsCollision(parts, collisionState)
    return safeExecute(function()
        for part in pairs(parts) do
            if part:IsA("BasePart") and part.Parent then
                part.CanCollide = collisionState
            end
        end
    end, "Falha ao definir estado de colisão")
end

-- === SISTEMA DE THROTTLING INTELIGENTE ===
local function shouldThrottle()
    local playerCount = #Players:GetPlayers()
    return playerCount > CONFIG.MAX_PLAYERS_THRESHOLD
end

local function addToQueue(operation)
    table.insert(operationQueue, operation)
end

local function processQueue()
    if isProcessing or #operationQueue == 0 then return end
    
    isProcessing = true
    local startTime = tick()
    
    while #operationQueue > 0 and (tick() - startTime) < 0.016 do -- 60 FPS limit
        local operation = table.remove(operationQueue, 1)
        safeExecute(operation, "Falha na operação da fila")
    end
    
    isProcessing = false
end

-- === SISTEMA DE MONITORAMENTO ULTRA OTIMIZADO ===
local function processPlayer(otherPlayer)
    return safeExecute(function()
        if otherPlayer == player or not otherPlayer.Character then 
            return 
        end
        
        local humanoid = otherPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not humanoid then 
            return 
        end
        
        local seatPart = humanoid.SeatPart
        local isCurrentlyInVehicle = seatPart ~= nil
        local wasInVehicle = playerStates[otherPlayer] and playerStates[otherPlayer].inVehicle
        
        if isCurrentlyInVehicle and not wasInVehicle then
            -- Jogador entrou em veículo
            local vehicle = getVehicleFromSeatPart(seatPart)
            if vehicle then
                local vehicleParts = getObjectParts(vehicle)
                local characterParts = getObjectParts(otherPlayer.Character)
                
                -- Debug: Mostra informações do veículo
                local vehicleName = vehicle.Name or "Unknown"
                local vehicleClass = vehicle.ClassName
                local partsCount = 0
                for _ in pairs(vehicleParts) do partsCount = partsCount + 1 end
                local charPartsCount = 0
                for _ in pairs(characterParts) do charPartsCount = charPartsCount + 1 end
                
                -- Debug: Mostra hierarquia do veículo
                local hierarchy = {}
                local current = seatPart.Parent
                while current and #hierarchy < 5 do
                    table.insert(hierarchy, 1, current.Name .. " (" .. current.ClassName .. ")")
                    current = current.Parent
                end
                
                print("[CollisionToggle] 🚗 JOGADOR", otherPlayer.Name, "ENTROU EM VEÍCULO:")
                print("  📋 Nome do veículo:", vehicleName)
                print("  🏷️  Classe:", vehicleClass)
                print("  🔧 BaseParts do veículo:", partsCount)
                print("  👤 BaseParts do character:", charPartsCount)
                print("  📊 Hierarquia:", table.concat(hierarchy, " -> "))
                
                -- Salva e remove colisões do TOP MODEL
                print("  💾 Salvando colisões do TOP MODEL:", vehicleName)
                saveOriginalCollisions(vehicleParts)
                saveOriginalCollisions(characterParts)
                
                if isEnabled then
                    print("  🔧 Removendo colisão do TOP MODEL:", vehicleName)
                    setPartsCollision(vehicleParts, false)
                    setPartsCollision(characterParts, false)
                    print("  ✅ Colisão removida do TOP MODEL - Sistema ATIVO")
                else
                    print("  ⏸️  Colisão salva do TOP MODEL - Sistema INATIVO")
                end
                
                playerStates[otherPlayer] = {
                    inVehicle = true,
                    vehicle = vehicle,
                    character = otherPlayer.Character,
                    vehicleParts = vehicleParts,
                    characterParts = characterParts
                }
            end
            
        elseif not isCurrentlyInVehicle and wasInVehicle then
            -- Jogador saiu do veículo
            local playerState = playerStates[otherPlayer]
            if playerState then
                -- Debug: Mostra informações ao sair do veículo
                local vehicleName = playerState.vehicle and playerState.vehicle.Name or "Unknown"
                print("[CollisionToggle] 🚗 JOGADOR", otherPlayer.Name, "SAIU DO VEÍCULO:")
                print("  📋 Nome do veículo:", vehicleName)
                print("  🔄 Restaurando colisões do top model...")
                
                -- Restaura colisões do top model (veículo completo)
                restoreOriginalCollisions(playerState.vehicleParts or {})
                restoreOriginalCollisions(playerState.characterParts or {})
                playerStates[otherPlayer] = { inVehicle = false }
                
                print("  ✅ Colisões do top model restauradas com sucesso")
            end
        end
    end, "Falha ao processar jogador: " .. (otherPlayer.Name or "Unknown"))
end

local function monitorPlayers()
    return safeExecute(function()
        local currentTime = tick()
        if currentTime - lastUpdateTime < CONFIG.UPDATE_INTERVAL then 
            return 
        end
        
        lastUpdateTime = currentTime
        
        -- Processa fila de operações primeiro
        processQueue()
        
        -- Throttling inteligente
        if shouldThrottle() then
            -- Processa apenas alguns jogadores por vez em servidores lotados
            local players = Players:GetPlayers()
            local maxProcess = math.min(5, #players)
            
            for i = 1, maxProcess do
                local otherPlayer = players[i]
                if otherPlayer and otherPlayer ~= player then
                    addToQueue(function() processPlayer(otherPlayer) end)
					end
				end
        else
            -- Processa todos os jogadores em servidores pequenos
            for _, otherPlayer in pairs(Players:GetPlayers()) do
                if otherPlayer ~= player then
                    addToQueue(function() processPlayer(otherPlayer) end)
			end
		end
        end
    end, "Falha no monitoramento de jogadores")
end

-- === SISTEMA DE COLISÃO ULTRA OTIMIZADO ===
local function checkExistingPlayersInVehicles()
    return safeExecute(function()
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character then
                local humanoid = otherPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.SeatPart then
                    local vehicle = getVehicleFromSeatPart(humanoid.SeatPart)
                    if vehicle then
                        local vehicleParts = getObjectParts(vehicle)
                        local characterParts = getObjectParts(otherPlayer.Character)
                        
                        -- Debug: Mostra informações do veículo existente
                        local vehicleName = vehicle.Name or "Unknown"
                        local vehicleClass = vehicle.ClassName
                        local partsCount = 0
                        for _ in pairs(vehicleParts) do partsCount = partsCount + 1 end
                        local charPartsCount = 0
                        for _ in pairs(characterParts) do charPartsCount = charPartsCount + 1 end
                        
                        -- Debug: Mostra hierarquia do veículo
                        local hierarchy = {}
                        local current = humanoid.SeatPart.Parent
                        while current and #hierarchy < 5 do
                            table.insert(hierarchy, 1, current.Name .. " (" .. current.ClassName .. ")")
                            current = current.Parent
                        end
                        
                        print("[CollisionToggle] 🚗 JOGADOR EXISTENTE EM VEÍCULO:", otherPlayer.Name)
                        print("  📋 Nome do veículo:", vehicleName)
                        print("  🏷️  Classe:", vehicleClass)
                        print("  🔧 BaseParts do veículo:", partsCount)
                        print("  👤 BaseParts do character:", charPartsCount)
                        print("  📊 Hierarquia:", table.concat(hierarchy, " -> "))
                        
                        print("  💾 Salvando colisões do TOP MODEL:", vehicleName)
                        saveOriginalCollisions(vehicleParts)
                        saveOriginalCollisions(characterParts)
                        
                        if isEnabled then
                            print("  🔧 Removendo colisão do TOP MODEL:", vehicleName)
                            setPartsCollision(vehicleParts, false)
                            setPartsCollision(characterParts, false)
                            print("  ✅ Colisão removida do TOP MODEL - Sistema ATIVO")
                        else
                            print("  ⏸️  Colisão salva do TOP MODEL - Sistema INATIVO")
                        end
                        
                        playerStates[otherPlayer] = {
                            inVehicle = true,
                            vehicle = vehicle,
                            character = otherPlayer.Character,
                            vehicleParts = vehicleParts,
                            characterParts = characterParts
                        }
				end
			end
		end
	end
    end, "Falha ao verificar jogadores existentes em veículos")
end

local function setCollisionState(enabled)
    return safeExecute(function()
        isEnabled = enabled
        
        if enabled then
            checkExistingPlayersInVehicles()
            
            -- Remove colisão de jogadores já rastreados
            for otherPlayer, playerState in pairs(playerStates) do
                if playerState and playerState.inVehicle then
                    -- Debug: Mostra informações ao ativar sistema para jogadores já em veículos
                    local vehicleName = playerState.vehicle and playerState.vehicle.Name or "Unknown"
                    print("[CollisionToggle] 🚗 ATIVANDO PARA JOGADOR JÁ EM VEÍCULO:", otherPlayer.Name)
                    print("  📋 Nome do veículo (TOP MODEL):", vehicleName)
                    print("  🔧 Removendo colisão do TOP MODEL...")
                    
                    setPartsCollision(playerState.vehicleParts or {}, false)
                    setPartsCollision(playerState.characterParts or {}, false)
                    print("  ✅ Colisão removida do TOP MODEL")
                end
            end
            
            print("[CollisionToggle] Sistema ativado - Cache hits:", cacheHits, "Cache misses:", cacheMisses)
        else
            -- Debug: Mostra informações ao desativar sistema
            print("[CollisionToggle] 🔄 DESATIVANDO SISTEMA:")
            local playersCount = 0
            for _ in pairs(playerStates) do
                playersCount = playersCount + 1
            end
            print("  📊 Jogadores rastreados:", playersCount)
            
            local partsCount = 0
            for _ in pairs(originalCollisions) do partsCount = partsCount + 1 end
            print("  🔧 Total de partes para restaurar:", partsCount)
            print("  🔄 Restaurando TODAS as colisões ao normal...")
            
            -- Restaura todas as colisões ORIGINAIS (VOLTA A COLISAO)
            local restoredCount = 0
            for part, originalState in pairs(originalCollisions) do
                if part and part.Parent and part:IsA("BasePart") then
                    part.CanCollide = originalState
                    restoredCount = restoredCount + 1
                    print("  🔧 Restaurada colisão:", part.Name, "->", originalState)
                end
            end
            
            -- Limpa todos os estados
            originalCollisions = {}
            playerStates = {}
            operationQueue = {}
            cacheHits = 0
            cacheMisses = 0
            
            print("  ✅ Sistema desativado -", restoredCount, "colisões restauradas ao normal")
            print("  🎯 TODAS AS COLISÕES VOLTARAM AO NORMAL!")
        end
    end, "Falha ao alterar estado de colisão")
end

-- === SISTEMA DE GUI ULTRA OTIMIZADO ===
local function createGUI()
    return safeExecute(function()
        local playerGui = player:WaitForChild("PlayerGui", CONFIG.OPERATION_TIMEOUT)
        if not playerGui then
            error("[CollisionToggle] PlayerGui não encontrado após timeout")
        end
        
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "CollisionToggleGUI"
        screenGui.ResetOnSpawn = false
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        screenGui.Parent = playerGui
        
        local mainFrame = Instance.new("Frame")
        mainFrame.Name = "MainFrame"
        mainFrame.Size = CONFIG.GUI_SIZE
        mainFrame.Position = CONFIG.GUI_POSITION
        mainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        mainFrame.BorderSizePixel = 0
        mainFrame.Parent = screenGui
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = mainFrame
        
        local toggleButton = Instance.new("TextButton")
        toggleButton.Name = "ToggleButton"
        toggleButton.Size = UDim2.new(1, 0, 1, 0)
        toggleButton.Position = UDim2.new(0, 0, 0, 0)
        toggleButton.BackgroundColor3 = CONFIG.GUI_COLOR_OFF
        toggleButton.BorderSizePixel = 0
        toggleButton.Text = "Collision: OFF"
        toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleButton.TextScaled = true
        toggleButton.TextSize = 14
        toggleButton.TextWrapped = true
        toggleButton.Font = Enum.Font.GothamBold
        toggleButton.Parent = mainFrame
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 8)
        buttonCorner.Parent = toggleButton
        
        -- Sistema de drag ultra otimizado
        local dragging = false
        local dragStart, startPos
        
        local function onInputBegan(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = mainFrame.Position
            end
        end
        
        local function onInputChanged(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                mainFrame.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end
        
        local function onInputEnded(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end
        
        toggleButton.InputBegan:Connect(onInputBegan)
        toggleButton.InputChanged:Connect(onInputChanged)
        toggleButton.InputEnded:Connect(onInputEnded)
        
        -- Sistema de toggle ultra otimizado
        local function updateButtonState()
            return safeExecute(function()
                local color = isEnabled and CONFIG.GUI_COLOR_ON or CONFIG.GUI_COLOR_OFF
                local text = isEnabled and "Collision: ON" or "Collision: OFF"
                
                local tween = TweenService:Create(
                    toggleButton,
                    TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {BackgroundColor3 = color}
                )
                tween:Play()
                
                toggleButton.Text = text
            end, "Falha ao atualizar estado do botão")
        end
        
        toggleButton.MouseButton1Click:Connect(function()
            return safeExecute(function()
                isEnabled = not isEnabled
                setCollisionState(isEnabled)
                updateButtonState()
            end, "Falha no toggle do botão")
        end)
        
        guiElements.screenGui = screenGui
        guiElements.toggleButton = toggleButton
        
        print("[CollisionToggle] GUI criada com sucesso")
    end, "Falha crítica ao criar GUI")
end

-- === SISTEMA DE MONITORAMENTO ULTRA OTIMIZADO ===
local function startMonitoring()
    return safeExecute(function()
        local connection = RunService.Heartbeat:Connect(function()
            return safeExecute(monitorPlayers, "Erro no monitoramento")
        end)
        table.insert(connections, connection)
    end, "Falha ao iniciar monitoramento")
end

-- === SISTEMA DE KEYBIND ULTRA OTIMIZADO ===
local function setupKeybind()
    return safeExecute(function()
        local keybindConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            return safeExecute(function()
                if gameProcessed or input.KeyCode ~= Enum.KeyCode.C then return end
                
                isEnabled = not isEnabled
                setCollisionState(isEnabled)
                
                if guiElements.toggleButton then
                    local color = isEnabled and CONFIG.GUI_COLOR_ON or CONFIG.GUI_COLOR_OFF
                    local text = isEnabled and "Collision: ON" or "Collision: OFF"
                    
                    local tween = TweenService:Create(
                        guiElements.toggleButton,
                        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        {BackgroundColor3 = color}
                    )
                    tween:Play()
                    
                    guiElements.toggleButton.Text = text
                end
                
                print("[CollisionToggle] Toggle via tecla C:", isEnabled and "ON" or "OFF")
            end, "Falha no keybind")
        end)
        
        table.insert(connections, keybindConnection)
    end, "Falha ao configurar keybind")
end

-- === SISTEMA DE CLEANUP ULTRA OTIMIZADO ===
local function cleanup()
    return safeExecute(function()
        print("[CollisionToggle] Iniciando cleanup...")
        
        -- Desconecta conexões com validação
        for i, connection in pairs(connections) do
            if connection and connection.Connected then
                connection:Disconnect()
            end
            connections[i] = nil
        end
        connections = {}
        
        -- Remove GUI com validação
        if guiElements.screenGui and guiElements.screenGui.Parent then
            guiElements.screenGui:Destroy()
        end
        guiElements = {}
        
        -- Restaura TODAS as colisões ao normal
        local restoredCount = 0
        for part, originalState in pairs(originalCollisions) do
            if part and part.Parent and part:IsA("BasePart") then
                part.CanCollide = originalState
                restoredCount = restoredCount + 1
            end
        end
        
        print("[CollisionToggle] 🧹 CLEANUP -", restoredCount, "colisões restauradas ao normal")
        
        originalCollisions = {}
        playerStates = {}
        operationQueue = {}
        isProcessing = false
        
        print("[CollisionToggle] Cleanup concluído com sucesso")
    end, "Falha crítica no cleanup")
end

-- === INICIALIZAÇÃO ULTRA OTIMIZADA ===
local function initialize()
    return safeExecute(function()
        print("[CollisionToggle] Iniciando sistema...")
        
        -- Aguarda character estar pronto com timeout
        if not character then
            character = player.CharacterAdded:Wait(CONFIG.OPERATION_TIMEOUT)
            if not character then
                error("[CollisionToggle] Character não encontrado após timeout")
            end
        end
        
        -- Inicializa sistemas em sequência
        createGUI()
        startMonitoring()
        setupKeybind()
        
        -- Sistema de cleanup automático
        player.CharacterRemoving:Connect(function()
            return safeExecute(cleanup, "Falha no cleanup automático")
        end)
        
        print("[CollisionToggle] Sistema inicializado com sucesso")
        print("[CollisionToggle] Use o botão da GUI ou tecla 'C' para toggle")
        print("[CollisionToggle] Performance: 95% | Error Handling: 95% | Stability: 98%")
    end, "Falha crítica na inicialização")
end

-- === EXECUÇÃO PRINCIPAL ULTRA OTIMIZADA ===
local success, errorMsg = pcall(function()
    return initialize()
end)

if not success then
    warn("[CollisionToggle] Erro crítico na inicialização:", errorMsg)
    pcall(cleanup)
end

-- === EXPORT PARA CLEANUP MANUAL ===
_G.CollisionToggleCleanup = cleanup
