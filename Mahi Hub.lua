-- Mahi Hub v5.0 - Steal a Brainrot (Versão Mobile Otimizada)
-- Tamanho reduzido para celular + Fly System + Base própria

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

-- Configuração da janela (TAMANHO REDUZIDO PARA MOBILE)
local Window = WindUI:CreateWindow({
    Title = "🧠 Mahi Hub",
    Icon = "brain",
    Author = "Mobile v5.0",
    Folder = "MahiHub",
    Size = UDim2.fromOffset(400, 350), -- TAMANHO REDUZIDO
    Transparent = false,
    Theme = "Dark",
    HasOutline = true,
    SideBarWidth = 120 -- SIDEBAR MENOR
})

-- Configuração do script
local Config = {
    Speed = {
        Enabled = false,
        Value = 50, -- VELOCIDADE FIXA EM 50
        Connection = nil
    },
    ESP = {
        Bases = {
            Enabled = false,
            Objects = {}
        },
        Players = {
            Enabled = false,
            Objects = {}
        }
    },
    Fly = {
        Enabled = true, -- JÁ ATIVADO POR PADRÃO
        Speed = 20,
        Connection = nil,
        BodyVelocity = nil
    },
    AutoSteal = {
        Enabled = false,
        Connection = nil
    },
    PlayerPlotId = nil -- ID do plot do player
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

-- Função para encontrar o plot do player
local function FindPlayerPlot()
    local plotsFolder = Services.Workspace:FindFirstChild("Plots")
    if not plotsFolder then return nil end
    
    -- Procurar por plots que pertencem ao player
    for _, plot in pairs(plotsFolder:GetChildren()) do
        if plot:IsA("Model") then
            -- Verificar se o plot tem alguma indicação de propriedade
            local owner = plot:GetAttribute("Owner") or plot:FindFirstChild("Owner")
            if owner then
                if (type(owner) == "string" and owner == LocalPlayer.Name) or
                   (owner.Value and owner.Value == LocalPlayer.Name) then
                    Config.PlayerPlotId = plot.Name
                    return plot
                end
            end
        end
    end
    
    return nil
end

-- Função para encontrar objetos do player
local function FindPlayerObjects()
    local objects = {
        DeliveryHitboxes = {},
        Purchases = {}
    }
    
    local plotsFolder = Services.Workspace:FindFirstChild("Plots")
    if not plotsFolder then return objects end
    
    -- Se não temos o plot ID, tentar encontrar
    if not Config.PlayerPlotId then
        FindPlayerPlot()
    end
    
    -- Buscar no plot do player
    if Config.PlayerPlotId then
        local playerPlot = plotsFolder:FindFirstChild(Config.PlayerPlotId)
        if playerPlot then
            -- Buscar DeliveryHitbox
            local deliveryHitbox = playerPlot:FindFirstChild("DeliveryHitbox")
            if deliveryHitbox then
                table.insert(objects.DeliveryHitboxes, deliveryHitbox)
            end
            
            -- Buscar Purchases
            local purchases = playerPlot:FindFirstChild("Purchases")
            if purchases then
                local plotBlock = purchases:FindFirstChild("PlotBlock")
                if plotBlock then
                    local hitbox = plotBlock:FindFirstChild("Hitbox")
                    if hitbox then
                        table.insert(objects.DeliveryHitboxes, hitbox)
                    end
                end
            end
        end
    end
    
    return objects
end

-- Sistema de ESP (SEM BRAINROT)
local function CreateESP(object, text, color, showDistance)
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

-- Sistema de velocidade (VELOCIDADE FIXA EM 50)
local function SetupSpeed()
    if Config.Speed.Connection then
        Config.Speed.Connection:Disconnect()
    end
    
    Config.Speed.Connection = Services.RunService.Heartbeat:Connect(function()
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.WalkSpeed = Config.Speed.Value
        end
    end)
end

-- Sistema de Fly com botões móveis
local function CreateFlyButtons()
    -- Criar ScreenGui para os botões
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MahiFlyButtons"
    screenGui.Parent = Services.Players.LocalPlayer.PlayerGui
    
    -- Botão de movimento para frente
    local forwardButton = Instance.new("TextButton")
    forwardButton.Name = "ForwardButton"
    forwardButton.Size = UDim2.fromOffset(80, 80)
    forwardButton.Position = UDim2.fromOffset(20, 200)
    forwardButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
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
    toggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    toggleButton.Text = "FLY"
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

-- Sistema de Fly
local function SetupFly()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local rootPart = character.HumanoidRootPart
    
    -- Criar BodyVelocity
    if not Config.Fly.BodyVelocity then
        Config.Fly.BodyVelocity = Instance.new("BodyVelocity")
        Config.Fly.BodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        Config.Fly.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        Config.Fly.BodyVelocity.Parent = rootPart
    end
    
    -- Conexão do fly
    if Config.Fly.Connection then
        Config.Fly.Connection:Disconnect()
    end
    
    Config.Fly.Connection = Services.RunService.Heartbeat:Connect(function()
        if not Config.Fly.Enabled or not Config.Fly.BodyVelocity then return end
        
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

-- Teleporte seguro (APENAS PARA SUA BASE)
local function SafeTeleport(position)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        Notify("❌ Erro", "Personagem não encontrado!")
        return false
    end
    
    local rootPart = character.HumanoidRootPart
    local safePosition = position + Vector3.new(0, 5, 0)
    
    local tween = Services.TweenService:Create(rootPart,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {CFrame = CFrame.new(safePosition)}
    )
    tween:Play()
    Notify("✅ Teleporte", "Teleportado para sua base!")
    
    return true
end

-- Auto Steal (APENAS SUA BASE)
local function SetupAutoSteal()
    if Config.AutoSteal.Connection then
        Config.AutoSteal.Connection:Disconnect()
    end
    
    Config.AutoSteal.Connection = Services.RunService.Heartbeat:Connect(function()
        local playerObjects = FindPlayerObjects()
        
        if #playerObjects.DeliveryHitboxes > 0 then
            local targetHitbox = playerObjects.DeliveryHitboxes[1] -- Usar primeiro hitbox encontrado
            
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local playerPosition = LocalPlayer.Character.HumanoidRootPart.Position
                local distance = (targetHitbox.Position - playerPosition).Magnitude
                
                if distance > 15 then
                    SafeTeleport(targetHitbox.Position)
                    task.wait(3) -- Delay maior para evitar spam
                end
            end
        end
    end)
end

-- Criação das abas (INTERFACE REDUZIDA)
local Tabs = {
    Main = Window:Tab({ Title = "🏠 Principal", Icon = "home" }),
    ESP = Window:Tab({ Title = "👁️ ESP", Icon = "eye" }),
    Teleport = Window:Tab({ Title = "🚀 Teleporte", Icon = "zap" }),
    Auto = Window:Tab({ Title = "🤖 Auto", Icon = "bot" })
}

-- Aba Principal
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

-- Aba ESP (SEM BRAINROT)
Tabs.ESP:Toggle({
    Title = "🏠 ESP Sua Base",
    Description = "Mostra apenas sua base",
    Value = Config.ESP.Bases.Enabled,
    Callback = function(value)
        Config.ESP.Bases.Enabled = value
        if value then
            local playerObjects = FindPlayerObjects()
            
            for _, hitbox in pairs(playerObjects.DeliveryHitboxes) do
                local esp = CreateESP(hitbox, "🏠 Sua Base", Color3.fromRGB(0, 255, 255), true)
                table.insert(Config.ESP.Bases.Objects, esp)
            end
            
            Notify("✅ ESP", "ESP da sua base ativado!")
        else
            for _, esp in pairs(Config.ESP.Bases.Objects) do
                if esp and esp.Parent then
                    esp:Destroy()
                end
            end
            Config.ESP.Bases.Objects = {}
            Notify("❌ ESP", "ESP desativado!")
        end
    end
})

Tabs.ESP:Toggle({
    Title = "👤 ESP Jogadores",
    Description = "Mostra outros jogadores",
    Value = Config.ESP.Players.Enabled,
    Callback = function(value)
        Config.ESP.Players.Enabled = value
        if value then
            for _, player in pairs(Services.Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                    local esp = CreateESP(player.Character.Head, "👤 " .. player.Name, Color3.fromRGB(0, 255, 0), false)
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

-- Aba Teleporte
Tabs.Teleport:Button({
    Title = "🏠 Teleporte Sua Base",
    Description = "Teleporta para sua base",
    Callback = function()
        local playerObjects = FindPlayerObjects()
        if #playerObjects.DeliveryHitboxes > 0 then
            SafeTeleport(playerObjects.DeliveryHitboxes[1].Position)
        else
            Notify("❌ Erro", "Sua base não foi encontrada!")
        end
    end
})

-- Aba Auto
Tabs.Auto:Toggle({
    Title = "🤖 Auto Steal",
    Description = "Teleporte automático para sua base",
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

-- Inicialização do sistema de Fly
local function InitializeFly()
    CreateFlyButtons()
    SetupFly()
    
    -- Configurar botões
    if FlyButtons.ForwardButton then
        FlyButtons.ForwardButton.MouseButton1Down:Connect(function()
            FlyButtons.Moving = true
        end)
        
        FlyButtons.ForwardButton.MouseButton1Up:Connect(function()
            FlyButtons.Moving = false
        end)
        
        -- Suporte para touch
        FlyButtons.ForwardButton.TouchTap:Connect(function()
            FlyButtons.Moving = not FlyButtons.Moving
        end)
    end
    
    if FlyButtons.ToggleButton then
        FlyButtons.ToggleButton.MouseButton1Click:Connect(function()
            Config.Fly.Enabled = not Config.Fly.Enabled
            if Config.Fly.Enabled then
                FlyButtons.ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                FlyButtons.ToggleButton.Text = "FLY ON"
                Notify("✅ Fly", "Fly ativado!")
            else
                FlyButtons.ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                FlyButtons.ToggleButton.Text = "FLY OFF"
                Notify("❌ Fly", "Fly desativado!")
            end
        end)
    end
end

-- Inicialização quando o personagem spawna
local function OnCharacterAdded(character)
    wait(1) -- Aguardar carregamento
    if Config.Fly.Enabled then
        SetupFly()
    end
end

LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)

-- Inicialização
pcall(function()
    Window:SelectTab(1)
end)

-- Inicializar sistema de Fly
InitializeFly()

-- Definir cor inicial do botão toggle
if FlyButtons.ToggleButton then
    FlyButtons.ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    FlyButtons.ToggleButton.Text = "FLY ON"
end

Notify("🎉 Mahi Hub", "Versão Mobile carregada! Fly ativado!")
print("✅ Mahi Hub v5.0 Mobile - Todas as modificações implementadas!")
