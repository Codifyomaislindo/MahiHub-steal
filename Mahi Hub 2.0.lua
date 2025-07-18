-- Mahi Hub v6.0 - Steal a Brainrot (Versão Simplificada com Fly)
-- Removido teleporte, ESP base, Fly integrado na tab velocidade

-- Carregamento seguro do WindUI
local WindUI
local success, error = pcall(function()
    WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if not success then
    warn("❌ Erro ao carregar WindUI: " .. tostring(error))
    warn("🔧 Tentando URL alternativa...")
    
    local success2, error2 = pcall(function()
        WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/Source.lua"))()
    end)
    
    if not success2 then
        warn("❌ Falha ao carregar WindUI: " .. tostring(error2))
        return
    end
end

if not WindUI then
    warn("❌ WindUI não foi carregado!")
    return
end

-- Serviços do Roblox
local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    TweenService = game:GetService("TweenService"),
    Workspace = game:GetService("Workspace"),
    UserInputService = game:GetService("UserInputService"),
    HttpService = game:GetService("HttpService")
}

local LocalPlayer = Services.Players.LocalPlayer
local Camera = Services.Workspace.CurrentCamera

-- Configuração da janela
local Window = WindUI:CreateWindow({
    Title = "🧠 Mahi Hub",
    Icon = "brain",
    Author = "Simplificado v6.0",
    Folder = "MahiHub",
    Size = UDim2.fromOffset(400, 300),
    Transparent = false,
    Theme = "Dark",
    HasOutline = true,
    SideBarWidth = 120
})

-- Configuração do script
local Config = {
    Speed = {
        Enabled = false,
        Value = 50,
        Connection = nil
    },
    ESP = {
        Players = {
            Enabled = false,
            Objects = {}
        }
    },
    Fly = {
        Enabled = false, -- Começa desabilitado, só ativa com botão
        Speed = 20,
        Connection = nil,
        BodyVelocity = nil,
        ButtonsEnabled = false -- Controla se os botões funcionam
    },
    AutoSteal = {
        Enabled = false,
        Connection = nil
    }
}

-- Variáveis do sistema de Fly
local FlyButtons = {
    ForwardButton = nil,
    ToggleButton = nil,
    Moving = false
}

-- Notificações
local function Notify(title, content, duration)
    WindUI:Notify({
        Title = title,
        Content = content,
        Duration = duration or 3,
        Icon = "info"
    })
end

-- Sistema de ESP apenas para jogadores
local function CreateESP(object, text, color)
    if not object or not object.Parent then return end
    
    local existingESP = object:FindFirstChild("MahiESP")
    if existingESP then
        existingESP:Destroy()
    end
    
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "MahiESP"
    billboardGui.StudsOffset = Vector3.new(0, 3, 0)
    billboardGui.Size = UDim2.fromOffset(150, 40)
    billboardGui.AlwaysOnTop = true
    billboardGui.Parent = object
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromScale(1, 1)
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = billboardGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.fromScale(1, 1)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = color
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    textLabel.Parent = frame
    
    return billboardGui
end

-- Sistema de velocidade persistente
local function SetupSpeed()
    if Config.Speed.Connection then
        Config.Speed.Connection:Disconnect()
    end
    
    Config.Speed.Connection = Services.RunService.Heartbeat:Connect(function()
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") and Config.Speed.Enabled then
            character.Humanoid.WalkSpeed = Config.Speed.Value
        end
    end)
end

-- Sistema de Fly com botões móveis
local function CreateFlyButtons()
    -- Verificar se já existem botões
    local existingGui = Services.Players.LocalPlayer.PlayerGui:FindFirstChild("MahiFlyButtons")
    if existingGui then
        existingGui:Destroy()
    end
    
    -- Criar ScreenGui para os botões
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MahiFlyButtons"
    screenGui.Parent = Services.Players.LocalPlayer.PlayerGui
    
    -- Botão de movimento para frente
    local forwardButton = Instance.new("TextButton")
    forwardButton.Name = "ForwardButton"
    forwardButton.Size = UDim2.fromOffset(80, 80)
    forwardButton.Position = UDim2.fromOffset(20, 200)
    forwardButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100) -- Começa desabilitado
    forwardButton.Text = "➤"
    forwardButton.TextColor3 = Color3.new(1, 1, 1)
    forwardButton.TextScaled = true
    forwardButton.Font = Enum.Font.GothamBold
    forwardButton.Parent = screenGui
    
    local forwardCorner = Instance.new("UICorner")
    forwardCorner.CornerRadius = UDim.new(0, 15)
    forwardCorner.Parent = forwardButton
    
    -- Botão de toggle
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.fromOffset(80, 80)
    toggleButton.Position = UDim2.fromOffset(20, 290)
    toggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Começa OFF
    toggleButton.Text = "FLY OFF"
    toggleButton.TextColor3 = Color3.new(1, 1, 1)
    toggleButton.TextScaled = true
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.Parent = screenGui
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 15)
    toggleCorner.Parent = toggleButton
    
    -- Tornar os botões draggable
    local function makeDraggable(button)
        local dragging = false
        local dragStart = nil
        local startPos = nil
        
        button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = button.Position
            end
        end)
        
        button.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                button.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        
        button.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end
    
    makeDraggable(forwardButton)
    makeDraggable(toggleButton)
    
    FlyButtons.ForwardButton = forwardButton
    FlyButtons.ToggleButton = toggleButton
    
    return screenGui
end

-- Sistema de Fly persistente
local function SetupFly()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local rootPart = character.HumanoidRootPart
    
    -- Remover BodyVelocity existente
    local existingBV = rootPart:FindFirstChild("BodyVelocity")
    if existingBV then
        existingBV:Destroy()
    end
    
    -- Criar BodyVelocity
    Config.Fly.BodyVelocity = Instance.new("BodyVelocity")
    Config.Fly.BodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
    Config.Fly.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
    Config.Fly.BodyVelocity.Parent = rootPart
    
    -- Conexão do fly
    if Config.Fly.Connection then
        Config.Fly.Connection:Disconnect()
    end
    
    Config.Fly.Connection = Services.RunService.Heartbeat:Connect(function()
        if not Config.Fly.Enabled or not Config.Fly.ButtonsEnabled or not Config.Fly.BodyVelocity then return end
        
        local camera = Services.Workspace.CurrentCamera
        local moveVector = Vector3.new(0, 0, 0)
        
        -- Verificar input de teclado
        if Services.UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveVector = moveVector + camera.CFrame.LookVector
        end
        if Services.UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveVector = moveVector - camera.CFrame.LookVector
        end
        if Services.UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveVector = moveVector - camera.CFrame.RightVector
        end
        if Services.UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveVector = moveVector + camera.CFrame.RightVector
        end
        
        -- Verificar botão de movimento
        if FlyButtons.Moving then
            moveVector = moveVector + camera.CFrame.LookVector
        end
        
        -- Aplicar movimento
        if moveVector.Magnitude > 0 then
            Config.Fly.BodyVelocity.Velocity = moveVector.Unit * Config.Fly.Speed
        else
            Config.Fly.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end

-- Função para encontrar objetos do player
local function FindPlayerObjects()
    local objects = {
        DeliveryHitboxes = {}
    }
    
    local plotsFolder = Services.Workspace:FindFirstChild("Plots")
    if not plotsFolder then return objects end
    
    for _, plot in pairs(plotsFolder:GetChildren()) do
        if plot:IsA("Model") then
            local deliveryHitbox = plot:FindFirstChild("DeliveryHitbox")
            if deliveryHitbox then
                table.insert(objects.DeliveryHitboxes, deliveryHitbox)
            end
        end
    end
    
    return objects
end

-- Auto Steal
local function SetupAutoSteal()
    if Config.AutoSteal.Connection then
        Config.AutoSteal.Connection:Disconnect()
    end
    
    Config.AutoSteal.Connection = Services.RunService.Heartbeat:Connect(function()
        if not Config.AutoSteal.Enabled then return end
        
        local playerObjects = FindPlayerObjects()
        
        if #playerObjects.DeliveryHitboxes > 0 then
            local closestHitbox = nil
            local shortestDistance = math.huge
            
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local playerPosition = LocalPlayer.Character.HumanoidRootPart.Position
                
                for _, hitbox in pairs(playerObjects.DeliveryHitboxes) do
                    local distance = (hitbox.Position - playerPosition).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestHitbox = hitbox
                    end
                end
                
                if closestHitbox and shortestDistance > 15 then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(closestHitbox.Position + Vector3.new(0, 5, 0))
                    task.wait(3)
                end
            end
        end
    end)
end

-- Criação das abas (APENAS 2 ABAS)
local Tabs = {
    Main = Window:Tab({ Title = "🏠 Principal", Icon = "home" }),
    ESP = Window:Tab({ Title = "👁️ ESP", Icon = "eye" })
}

-- Aba Principal - Velocidade e Fly
Tabs.Main:Toggle({
    Title = "🏃 Velocidade (50)",
    Description = "Ativa velocidade fixada em 50",
    Value = Config.Speed.Enabled,
    Callback = function(value)
        Config.Speed.Enabled = value
        if value then
            SetupSpeed()
            Notify("✅ Velocidade", "Velocidade 50 ativada!")
        else
            if Config.Speed.Connection then
                Config.Speed.Connection:Disconnect()
            end
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = 16
            end
            Notify("❌ Velocidade", "Velocidade normal!")
        end
    end
})

Tabs.Main:Toggle({
    Title = "✈️ Fly System",
    Description = "Ativa/desativa o sistema de Fly",
    Value = Config.Fly.ButtonsEnabled,
    Callback = function(value)
        Config.Fly.ButtonsEnabled = value
        if value then
            Config.Fly.Enabled = true
            SetupFly()
            
            -- Ativar botões visuais
            if FlyButtons.ForwardButton then
                FlyButtons.ForwardButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            end
            if FlyButtons.ToggleButton then
                FlyButtons.ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                FlyButtons.ToggleButton.Text = "FLY ON"
            end
            
            Notify("✅ Fly", "Sistema de Fly ativado!")
        else
            Config.Fly.Enabled = false
            Config.Fly.ButtonsEnabled = false
            
            -- Desativar botões visuais
            if FlyButtons.ForwardButton then
                FlyButtons.ForwardButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            end
            if FlyButtons.ToggleButton then
                FlyButtons.ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                FlyButtons.ToggleButton.Text = "FLY OFF"
            end
            
            -- Parar movimento
            if Config.Fly.BodyVelocity then
                Config.Fly.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
            end
            
            Notify("❌ Fly", "Sistema de Fly desativado!")
        end
    end
})

Tabs.Main:Toggle({
    Title = "🤖 Auto Steal",
    Description = "Teleporte automático para bases",
    Value = Config.AutoSteal.Enabled,
    Callback = function(value)
        Config.AutoSteal.Enabled = value
        if value then
            SetupAutoSteal()
            Notify("✅ Auto Steal", "Auto steal ativado!")
        else
            if Config.AutoSteal.Connection then
                Config.AutoSteal.Connection:Disconnect()
            end
            Notify("❌ Auto Steal", "Auto steal desativado!")
        end
    end
})

-- Aba ESP (APENAS JOGADORES)
Tabs.ESP:Toggle({
    Title = "👤 ESP Jogadores",
    Description = "Mostra outros jogadores",
    Value = Config.ESP.Players.Enabled,
    Callback = function(value)
        Config.ESP.Players.Enabled = value
        if value then
            for _, player in pairs(Services.Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                    local esp = CreateESP(player.Character.Head, "👤 " .. player.Name, Color3.fromRGB(0, 255, 0))
                    table.insert(Config.ESP.Players.Objects, esp)
                end
            end
            Notify("✅ ESP", "ESP de jogadores ativado!")
        else
            for _, esp in pairs(Config.ESP.Players.Objects) do
                if esp and esp.Parent then
                    esp:Destroy()
                end
            end
            Config.ESP.Players.Objects = {}
            Notify("❌ ESP", "ESP de jogadores desativado!")
        end
    end
})

-- Função para manter conexões após respawn
local function OnCharacterAdded(character)
    task.wait(2) -- Aguardar carregamento
    
    -- Reativar velocidade se estava ativada
    if Config.Speed.Enabled then
        SetupSpeed()
    end
    
    -- Reativar fly se estava ativado
    if Config.Fly.ButtonsEnabled then
        SetupFly()
    end
    
    -- Reativar auto steal se estava ativado
    if Config.AutoSteal.Enabled then
        SetupAutoSteal()
    end
end

LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)

-- Inicialização dos botões de Fly
local function InitializeFlyButtons()
    CreateFlyButtons()
    
    -- Configurar botão de movimento
    if FlyButtons.ForwardButton then
        FlyButtons.ForwardButton.MouseButton1Down:Connect(function()
            if Config.Fly.ButtonsEnabled then
                FlyButtons.Moving = true
            end
        end)
        
        FlyButtons.ForwardButton.MouseButton1Up:Connect(function()
            FlyButtons.Moving = false
        end)
        
        -- Suporte para touch
        FlyButtons.ForwardButton.TouchTap:Connect(function()
            if Config.Fly.ButtonsEnabled then
                FlyButtons.Moving = not FlyButtons.Moving
            end
        end)
    end
    
    -- Configurar botão de toggle (apenas visual, não funcional)
    if FlyButtons.ToggleButton then
        FlyButtons.ToggleButton.MouseButton1Click:Connect(function()
            -- Este botão é apenas visual, o controle real é pelo script
            if Config.Fly.ButtonsEnabled then
                Notify("ℹ️ Info", "Use o botão no script para controlar o Fly!")
            else
                Notify("⚠️ Aviso", "Ative o Fly System no script primeiro!")
            end
        end)
    end
end

-- Inicialização
pcall(function()
    Window:SelectTab(1)
end)

-- Inicializar botões de Fly
InitializeFlyButtons()

-- Configurar persistência após respawn
if LocalPlayer.Character then
    OnCharacterAdded(LocalPlayer.Character)
end

Notify("🎉 Mahi Hub", "Versão Simplificada carregada!")
print("✅ Mahi Hub v6.0 - Versão simplificada com Fly integrado!")
