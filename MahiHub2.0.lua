-- Mahi Hub v2.0 - Steal a Brainrot (Versão Aprimorada)
-- Desenvolvido com tratamento de erros e otimizações avançadas

local success, Library = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/AlexR32/Wind-UI/main/source.lua"))()
end)

if not success then
    warn("Erro ao carregar WindUi Library!")
    return
end

-- Configuração da janela principal com tema aprimorado
local Window = Library:CreateWindow({
    Title = "🧠 Mahi Hub",
    Subtitle = "Steal a Brainrot - Premium Edition",
    Size = UDim2.fromOffset(580, 450),
    Theme = "Midnight", -- Tema mais sofisticado
    ShowMinimizeButton = true,
    ShowCloseButton = true,
    Resizable = true,
    CloseCallback = function()
        print("🔥 Mahi Hub fechado - Até logo!")
    end
})

-- Serviços otimizados
local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    TweenService = game:GetService("TweenService"),
    Workspace = game:GetService("Workspace"),
    UserInputService = game:GetService("UserInputService"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    StarterGui = game:GetService("StarterGui"),
    CoreGui = game:GetService("CoreGui")
}

local LocalPlayer = Services.Players.LocalPlayer
local Camera = Services.Workspace.CurrentCamera

-- Sistema de configuração avançado
local Config = {
    Speed = {
        Enabled = false,
        Value = 16,
        MaxSpeed = 500,
        BypassMethod = "Heartbeat" -- Método de bypass mais eficiente
    },
    ESP = {
        Brainrot = {
            Enabled = false,
            Color = Color3.fromRGB(255, 0, 0),
            Distance = 1000,
            ShowDistance = true
        },
        Players = {
            Enabled = false,
            Color = Color3.fromRGB(0, 255, 0),
            ShowHealth = true,
            ShowDistance = true
        },
        Time = {
            Enabled = false,
            Color = Color3.fromRGB(0, 150, 255),
            Format = "digital" -- digital ou analog
        },
        Checkpoints = {
            Enabled = false,
            Color = Color3.fromRGB(255, 255, 0),
            ShowOwner = true
        }
    },
    Teleport = {
        Speed = 0.3,
        Method = "Tween", -- Tween ou Instant
        AutoSteal = false,
        SafeDistance = 5
    },
    UI = {
        Notifications = true,
        SoundEffects = true,
        Transparency = 0.1
    }
}

-- Variáveis globais otimizadas
local Connections = {}
local ESPObjects = {}
local LastUpdate = tick()
local PerformanceMonitor = {
    FPS = 0,
    Memory = 0,
    LastCheck = tick()
}

-- Sistema de notificações aprimorado
local function SendNotification(title, text, duration)
    if not Config.UI.Notifications then return end
    
    pcall(function()
        Services.StarterGui:SetCore("SendNotification", {
            Title = "🧠 " .. title,
            Text = text,
            Duration = duration or 3,
            Button1 = "OK"
        })
    end)
end

-- Função de ESP avançada com otimizações
local function CreateAdvancedESP(object, config, customText)
    if not object or not object.Parent then return end
    
    local existingESP = object:FindFirstChild("MahiESP")
    if existingESP then
        existingESP:Destroy()
    end
    
    local espGui = Instance.new("BillboardGui")
    espGui.Name = "MahiESP"
    espGui.StudsOffset = Vector3.new(0, 3, 0)
    espGui.Size = UDim2.fromOffset(200, 50)
    espGui.AlwaysOnTop = true
    espGui.LightInfluence = 0
    espGui.Parent = object
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromScale(1, 1)
    frame.BackgroundTransparency = 0.3
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BorderSizePixel = 0
    frame.Parent = espGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.fromScale(1, 0.6)
    textLabel.Position = UDim2.fromScale(0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = customText or object.Name
    textLabel.TextColor3 = config.Color
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    textLabel.Parent = frame
    
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.fromScale(1, 0.4)
    infoLabel.Position = UDim2.fromScale(0, 0.6)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = ""
    infoLabel.TextColor3 = Color3.new(1, 1, 1)
    infoLabel.TextScaled = true
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextStrokeTransparency = 0
    infoLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    infoLabel.Parent = frame
    
    -- Adicionar à lista de ESPs
    ESPObjects[object] = {
        GUI = espGui,
        Config = config,
        MainLabel = textLabel,
        InfoLabel = infoLabel,
        Object = object
    }
    
    return espGui
end

-- Sistema de busca otimizado
local function FindObjectsOptimized(searchTerms, searchIn)
    local found = {}
    local searchArea = searchIn or Services.Workspace
    
    for _, term in pairs(searchTerms) do
        for _, obj in pairs(searchArea:GetDescendants()) do
            if obj.Name:lower():find(term:lower()) and not table.find(found, obj) then
                table.insert(found, obj)
            end
        end
    end
    
    return found
end

-- Função de velocidade com bypass avançado
local function SetupSpeedBypass()
    if Connections.Speed then
        Connections.Speed:Disconnect()
    end
    
    Connections.Speed = Services.RunService.Heartbeat:Connect(function()
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        
        if humanoid and rootPart then
            -- Método de bypass mais eficiente
            humanoid.WalkSpeed = Config.Speed.Value
            
            -- Bypass adicional para anticheat
            local bodyVelocity = rootPart:FindFirstChild("BodyVelocity")
            if not bodyVelocity and Config.Speed.Value > 50 then
                bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.MaxForce = Vector3.new(4000, 0, 4000)
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                bodyVelocity.Parent = rootPart
            end
        end
    end)
end

-- Sistema de teleporte aprimorado
local function TeleportToPosition(position, method)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        SendNotification("Erro", "Personagem não encontrado!")
        return false
    end
    
    local rootPart = character.HumanoidRootPart
    local targetCFrame = CFrame.new(position + Vector3.new(0, Config.Teleport.SafeDistance, 0))
    
    if method == "Instant" then
        rootPart.CFrame = targetCFrame
        SendNotification("Sucesso", "Teleportado instantaneamente!")
    else
        local tween = Services.TweenService:Create(rootPart, 
            TweenInfo.new(Config.Teleport.Speed, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {CFrame = targetCFrame}
        )
        tween:Play()
        SendNotification("Sucesso", "Teleportando suavemente...")
    end
    
    return true
end

-- Sistema de atualização de ESP otimizado
local function UpdateESPSystem()
    if tick() - LastUpdate < 0.1 then return end -- Limitar atualizações
    LastUpdate = tick()
    
    -- Atualizar ESP de Brainrots
    if Config.ESP.Brainrot.Enabled then
        local brainrots = FindObjectsOptimized({"brainrot", "brain", "rot"})
        for _, brainrot in pairs(brainrots) do
            if not ESPObjects[brainrot] then
                CreateAdvancedESP(brainrot, Config.ESP.Brainrot, "💀 Brainrot")
            end
        end
    end
    
    -- Atualizar ESP de Players
    if Config.ESP.Players.Enabled then
        for _, player in pairs(Services.Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local head = player.Character.Head
                if not ESPObjects[head] then
                    CreateAdvancedESP(head, Config.ESP.Players, "👤 " .. player.Name)
                end
                
                -- Atualizar informações do player
                if ESPObjects[head] then
                    local humanoid = player.Character:FindFirstChild("Humanoid")
                    local distance = (head.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    
                    local info = string.format("❤️ %.0f | 📏 %.0fm", 
                        humanoid and humanoid.Health or 0, 
                        distance
                    )
                    ESPObjects[head].InfoLabel.Text = info
                end
            end
        end
    end
    
    -- Atualizar ESP de Checkpoints
    if Config.ESP.Checkpoints.Enabled then
        local checkpoints = FindObjectsOptimized({"checkpoint", "base", "spawn"})
        for _, checkpoint in pairs(checkpoints) do
            if not ESPObjects[checkpoint] then
                CreateAdvancedESP(checkpoint, Config.ESP.Checkpoints, "🏠 Checkpoint")
            end
        end
    end
    
    -- Limpar ESPs de objetos removidos
    for obj, espData in pairs(ESPObjects) do
        if not obj.Parent then
            if espData.GUI then
                espData.GUI:Destroy()
            end
            ESPObjects[obj] = nil
        end
    end
end

-- Monitor de performance
local function UpdatePerformanceMonitor()
    if tick() - PerformanceMonitor.LastCheck < 1 then return end
    
    PerformanceMonitor.FPS = math.floor(1 / Services.RunService.Heartbeat:Wait())
    PerformanceMonitor.Memory = math.floor(collectgarbage("count"))
    PerformanceMonitor.LastCheck = tick()
end

-- Criação das abas com design aprimorado
local MainTab = Window:CreateTab("🏠 Principal", "rbxassetid://7733717447")
local ESPTab = Window:CreateTab("👁️ ESP", "rbxassetid://7733717447")
local TeleportTab = Window:CreateTab("🚀 Teleporte", "rbxassetid://7733717447")
local SettingsTab = Window:CreateTab("⚙️ Configurações", "rbxassetid://7733717447")

-- Seção Principal - Velocidade
local SpeedSection = MainTab:CreateSection("💨 Sistema de Velocidade")

SpeedSection:CreateToggle({
    Name = "🏃 Velocidade Ativada",
    Description = "Ativa o sistema de velocidade com bypass",
    CurrentValue = Config.Speed.Enabled,
    Flag = "SpeedToggle",
    Callback = function(value)
        Config.Speed.Enabled = value
        if value then
            SetupSpeedBypass()
            SendNotification("Velocidade", "Sistema ativado!")
        else
            if Connections.Speed then
                Connections.Speed:Disconnect()
            end
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = 16
            end
            SendNotification("Velocidade", "Sistema desativado!")
        end
    end
})

SpeedSection:CreateSlider({
    Name = "⚡ Velocidade",
    Description = "Ajuste a velocidade do movimento",
    Range = {16, Config.Speed.MaxSpeed},
    Increment = 1,
    CurrentValue = Config.Speed.Value,
    Flag = "SpeedSlider",
    Callback = function(value)
        Config.Speed.Value = value
    end
})

-- Seção ESP Aprimorada
local BrainrotESPSection = ESPTab:CreateSection("💀 ESP Brainrot")

BrainrotESPSection:CreateToggle({
    Name = "👁️ ESP Brainrot",
    Description = "Mostra a localização dos brainrots",
    CurrentValue = Config.ESP.Brainrot.Enabled,
    Flag = "BrainrotESP",
    Callback = function(value)
        Config.ESP.Brainrot.Enabled = value
        if not value then
            -- Limpar ESPs de brainrot
            for obj, espData in pairs(ESPObjects) do
                if obj.Name:lower():find("brainrot") or obj.Name:lower():find("brain") then
                    if espData.GUI then
                        espData.GUI:Destroy()
                    end
                    ESPObjects[obj] = nil
                end
            end
        end
        SendNotification("ESP", value and "Brainrot ESP ativado!" or "Brainrot ESP desativado!")
    end
})

local PlayerESPSection = ESPTab:CreateSection("👤 ESP Jogadores")

PlayerESPSection:CreateToggle({
    Name = "🔍 ESP Jogadores",
    Description = "Mostra informações dos jogadores",
    CurrentValue = Config.ESP.Players.Enabled,
    Flag = "PlayerESP",
    Callback = function(value)
        Config.ESP.Players.Enabled = value
        if not value then
            -- Limpar ESPs de players
            for _, player in pairs(Services.Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("Head") then
                    local head = player.Character.Head
                    if ESPObjects[head] then
                        ESPObjects[head].GUI:Destroy()
                        ESPObjects[head] = nil
                    end
                end
            end
        end
        SendNotification("ESP", value and "Player ESP ativado!" or "Player ESP desativado!")
    end
})

local CheckpointESPSection = ESPTab:CreateSection("🏠 ESP Checkpoints")

CheckpointESPSection:CreateToggle({
    Name = "🎯 ESP Checkpoints",
    Description = "Mostra localização dos checkpoints",
    CurrentValue = Config.ESP.Checkpoints.Enabled,
    Flag = "CheckpointESP",
    Callback = function(value)
        Config.ESP.Checkpoints.Enabled = value
        SendNotification("ESP", value and "Checkpoint ESP ativado!" or "Checkpoint ESP desativado!")
    end
})

-- Seção Teleporte Aprimorada
local StealSection = TeleportTab:CreateSection("🎯 Sistema de Steal")

StealSection:CreateButton({
    Name = "🚀 Super Steal",
    Description = "Teleporta para o checkpoint mais próximo",
    Callback = function()
        local checkpoints = FindObjectsOptimized({"checkpoint", "base", "spawn"})
        if #checkpoints > 0 then
            local closestCheckpoint = nil
            local shortestDistance = math.huge
            
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local playerPosition = LocalPlayer.Character.HumanoidRootPart.Position
                
                for _, checkpoint in pairs(checkpoints) do
                    local distance = (checkpoint.Position - playerPosition).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestCheckpoint = checkpoint
                    end
                end
                
                if closestCheckpoint then
                    TeleportToPosition(closestCheckpoint.Position, Config.Teleport.Method)
                else
                    SendNotification("Erro", "Nenhum checkpoint válido encontrado!")
                end
            end
        else
            SendNotification("Erro", "Nenhum checkpoint encontrado!")
        end
    end
})

local TeleportMethodSection = TeleportTab:CreateSection("⚙️ Método de Teleporte")

TeleportMethodSection:CreateDropdown({
    Name = "🎮 Método",
    Description = "Escolha o método de teleporte",
    Options = {"Tween", "Instant"},
    CurrentOption = Config.Teleport.Method,
    Flag = "TeleportMethod",
    Callback = function(option)
        Config.Teleport.Method = option
        SendNotification("Teleporte", "Método alterado para: " .. option)
    end
})

TeleportMethodSection:CreateSlider({
    Name = "🕒 Velocidade do Tween",
    Description = "Velocidade da animação de teleporte",
    Range = {0.1, 2},
    Increment = 0.1,
    CurrentValue = Config.Teleport.Speed,
    Flag = "TeleportSpeed",
    Callback = function(value)
        Config.Teleport.Speed = value
    end
})

-- Seção Configurações
local UISection = SettingsTab:CreateSection("🎨 Interface")

UISection:CreateToggle({
    Name = "🔔 Notificações",
    Description = "Ativa/desativa notificações",
    CurrentValue = Config.UI.Notifications,
    Flag = "Notifications",
    Callback = function(value)
        Config.UI.Notifications = value
    end
})

local PerformanceSection = SettingsTab:CreateSection("📊 Performance")

local performanceLabel = PerformanceSection:CreateLabel("FPS: 0 | Memória: 0 KB")

-- Conexão principal otimizada
Connections.Main = Services.RunService.Heartbeat:Connect(function()
    UpdateESPSystem()
    UpdatePerformanceMonitor()
    
    -- Atualizar label de performance
    pcall(function()
        performanceLabel:Set(string.format("FPS: %d | Memória: %d KB", 
            PerformanceMonitor.FPS, 
            PerformanceMonitor.Memory
        ))
    end)
end)

-- Limpeza quando o jogador sai
Services.Players.PlayerRemoving:Connect(function(player)
    if player.Character and player.Character:FindFirstChild("Head") then
        local head = player.Character.Head
        if ESPObjects[head] then
            ESPObjects[head].GUI:Destroy()
            ESPObjects[head] = nil
        end
    end
end)

-- Inicialização completa
SendNotification("Mahi Hub", "Sistema carregado com sucesso! 🔥")
print("🧠 Mahi Hub v2.0 - Steal a Brainrot carregado!")
print("✨ Todas as funcionalidades otimizadas e prontas para uso!")
