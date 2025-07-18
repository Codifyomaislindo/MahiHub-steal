-- Mahi Hub v4.0 - Steal a Brainrot (Versão com Paths Específicos)
-- Atualizado com a estrutura real do workspace

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

print("✅ WindUI carregado com sucesso!")

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
    Author = "Steal a Brainrot v4.0",
    Folder = "MahiHub",
    Size = UDim2.fromOffset(650, 550),
    Transparent = false,
    Theme = "Dark",
    HasOutline = true,
    SideBarWidth = 200
})

-- Configuração do script
local Config = {
    Speed = {
        Enabled = false,
        Value = 16,
        Connection = nil
    },
    ESP = {
        Brainrot = {
            Enabled = false,
            Objects = {}
        },
        Bases = {
            Enabled = false,
            Objects = {}
        },
        Players = {
            Enabled = false,
            Objects = {}
        }
    },
    AutoSteal = {
        Enabled = false,
        Connection = nil,
        Target = "nearest"
    },
    Teleport = {
        Method = "Tween",
        Speed = 0.5
    }
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

-- Função para encontrar objetos específicos do jogo
local function FindGameObjects()
    local objects = {
        Plots = {},
        DeliveryHitboxes = {},
        Purchases = {},
        MapParts = {}
    }
    
    -- Buscar por plots específicos
    local plotsFolder = Services.Workspace:FindFirstChild("Plots")
    if plotsFolder then
        for _, plot in pairs(plotsFolder:GetChildren()) do
            if plot:IsA("Model") then
                table.insert(objects.Plots, plot)
                
                -- Buscar DeliveryHitbox em cada plot
                local deliveryHitbox = plot:FindFirstChild("DeliveryHitbox")
                if deliveryHitbox then
                    table.insert(objects.DeliveryHitboxes, deliveryHitbox)
                end
                
                -- Buscar sistema de compras
                local purchases = plot:FindFirstChild("Purchases")
                if purchases then
                    table.insert(objects.Purchases, purchases)
                    
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
    end
    
    -- Buscar objetos do mapa
    local mapFolder = Services.Workspace:FindFirstChild("Map")
    if mapFolder then
        for _, obj in pairs(mapFolder:GetDescendants()) do
            if obj:IsA("Part") and obj.Name == "Part" then
                table.insert(objects.MapParts, obj)
            end
        end
    end
    
    return objects
end

-- Função para buscar brainrots específicos
local function FindBrainrots()
    local brainrots = {}
    
    -- Buscar em diferentes locais possíveis
    for _, obj in pairs(Services.Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = obj.Name:lower()
            if name:find("brainrot") or name:find("brain") or name:find("rot") then
                table.insert(brainrots, obj)
            end
        end
    end
    
    return brainrots
end

-- Sistema de ESP avançado
local function CreateESP(object, text, color, showDistance)
    if not object or not object.Parent then return end
    
    local existingESP = object:FindFirstChild("MahiESP")
    if existingESP then
        existingESP:Destroy()
    end
    
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "MahiESP"
    billboardGui.StudsOffset = Vector3.new(0, 3, 0)
    billboardGui.Size = UDim2.fromOffset(200, 60)
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
    textLabel.Size = UDim2.fromScale(1, 0.6)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = color
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    textLabel.Parent = frame
    
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Size = UDim2.fromScale(1, 0.4)
    distanceLabel.Position = UDim2.fromScale(0, 0.6)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = "Calculando..."
    distanceLabel.TextColor3 = Color3.new(1, 1, 1)
    distanceLabel.TextScaled = true
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.TextStrokeTransparency = 0
    distanceLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    distanceLabel.Parent = frame
    
    -- Atualizar distância em tempo real
    if showDistance then
        local connection
        connection = Services.RunService.Heartbeat:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local distance = (object.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                distanceLabel.Text = string.format("📏 %.0f studs", distance)
            end
        end)
        
        billboardGui.AncestryChanged:Connect(function()
            if billboardGui.Parent == nil then
                connection:Disconnect()
            end
        end)
    end
    
    return billboardGui
end

-- Limpeza de ESP
local function ClearESP(category)
    if category == "all" then
        for _, espList in pairs(Config.ESP) do
            if type(espList) == "table" and espList.Objects then
                for _, esp in pairs(espList.Objects) do
                    if esp and esp.Parent then
                        esp:Destroy()
                    end
                end
                espList.Objects = {}
            end
        end
    else
        if Config.ESP[category] and Config.ESP[category].Objects then
            for _, esp in pairs(Config.ESP[category].Objects) do
                if esp and esp.Parent then
                    esp:Destroy()
                end
            end
            Config.ESP[category].Objects = {}
        end
    end
end

-- Sistema de velocidade
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

-- Teleporte seguro
local function SafeTeleport(position, method)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        Notify("❌ Erro", "Personagem não encontrado!")
        return false
    end
    
    local rootPart = character.HumanoidRootPart
    local safePosition = position + Vector3.new(0, 5, 0)
    
    if method == "Instant" then
        rootPart.CFrame = CFrame.new(safePosition)
        Notify("✅ Teleporte", "Teleportado instantaneamente!")
    else
        local tween = Services.TweenService:Create(rootPart,
            TweenInfo.new(Config.Teleport.Speed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {CFrame = CFrame.new(safePosition)}
        )
        tween:Play()
        Notify("✅ Teleporte", "Teleportando suavemente...")
    end
    
    return true
end

-- Sistema de Auto Steal
local function SetupAutoSteal()
    if Config.AutoSteal.Connection then
        Config.AutoSteal.Connection:Disconnect()
    end
    
    Config.AutoSteal.Connection = Services.RunService.Heartbeat:Connect(function()
        local gameObjects = FindGameObjects()
        local targets = {}
        
        -- Adicionar todos os delivery hitboxes como alvos
        for _, hitbox in pairs(gameObjects.DeliveryHitboxes) do
            table.insert(targets, hitbox)
        end
        
        if #targets > 0 then
            local closestTarget = nil
            local shortestDistance = math.huge
            
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local playerPosition = LocalPlayer.Character.HumanoidRootPart.Position
                
                for _, target in pairs(targets) do
                    if target and target.Position then
                        local distance = (target.Position - playerPosition).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            closestTarget = target
                        end
                    end
                end
                
                if closestTarget and shortestDistance > 15 then
                    SafeTeleport(closestTarget.Position, Config.Teleport.Method)
                    task.wait(2) -- Delay para evitar spam
                end
            end
        end
    end)
end

-- Criação das abas
local Tabs = {
    Main = Window:Tab({ Title = "🏠 Principal", Icon = "home" }),
    ESP = Window:Tab({ Title = "👁️ ESP", Icon = "eye" }),
    Teleport = Window:Tab({ Title = "🚀 Teleporte", Icon = "zap" }),
    Auto = Window:Tab({ Title = "🤖 Automático", Icon = "bot" }),
    Debug = Window:Tab({ Title = "🔧 Debug", Icon = "wrench" })
}

-- Aba Principal
Tabs.Main:Toggle({
    Title = "🏃 Velocidade Ativada",
    Description = "Ativa o sistema de velocidade com bypass",
    Value = Config.Speed.Enabled,
    Callback = function(value)
        Config.Speed.Enabled = value
        if value then
            SetupSpeed()
            Notify("✅ Velocidade", "Sistema ativado!")
        else
            if Config.Speed.Connection then
                Config.Speed.Connection:Disconnect()
            end
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = 16
            end
            Notify("❌ Velocidade", "Sistema desativado!")
        end
    end
})

Tabs.Main:Slider({
    Title = "⚡ Valor da Velocidade",
    Description = "Ajuste a velocidade do movimento",
    Value = {
        Min = 16,
        Max = 300,
        Default = 16
    },
    Callback = function(value)
        Config.Speed.Value = value
    end
})

-- Aba ESP
Tabs.ESP:Toggle({
    Title = "💀 ESP Brainrot",
    Description = "Mostra a localização dos brainrots",
    Value = Config.ESP.Brainrot.Enabled,
    Callback = function(value)
        Config.ESP.Brainrot.Enabled = value
        if value then
            ClearESP("Brainrot")
            local brainrots = FindBrainrots()
            for _, brainrot in pairs(brainrots) do
                local esp = CreateESP(brainrot, "💀 Brainrot", Color3.fromRGB(255, 0, 0), true)
                table.insert(Config.ESP.Brainrot.Objects, esp)
            end
            Notify("✅ ESP", "Brainrot ESP ativado! Encontrados: " .. #brainrots)
        else
            ClearESP("Brainrot")
            Notify("❌ ESP", "Brainrot ESP desativado!")
        end
    end
})

Tabs.ESP:Toggle({
    Title = "🏠 ESP Bases/Hitboxes",
    Description = "Mostra delivery hitboxes e bases",
    Value = Config.ESP.Bases.Enabled,
    Callback = function(value)
        Config.ESP.Bases.Enabled = value
        if value then
            ClearESP("Bases")
            local gameObjects = FindGameObjects()
            
            -- ESP para delivery hitboxes
            for _, hitbox in pairs(gameObjects.DeliveryHitboxes) do
                local esp = CreateESP(hitbox, "📦 Delivery", Color3.fromRGB(0, 255, 255), true)
                table.insert(Config.ESP.Bases.Objects, esp)
            end
            
            -- ESP para plots
            for _, plot in pairs(gameObjects.Plots) do
                local esp = CreateESP(plot, "🏠 Plot", Color3.fromRGB(255, 255, 0), true)
                table.insert(Config.ESP.Bases.Objects, esp)
            end
            
            local totalFound = #gameObjects.DeliveryHitboxes + #gameObjects.Plots
            Notify("✅ ESP", "Base ESP ativado! Encontrados: " .. totalFound)
        else
            ClearESP("Bases")
            Notify("❌ ESP", "Base ESP desativado!")
        end
    end
})

Tabs.ESP:Toggle({
    Title = "👤 ESP Jogadores",
    Description = "Mostra informações dos jogadores",
    Value = Config.ESP.Players.Enabled,
    Callback = function(value)
        Config.ESP.Players.Enabled = value
        if value then
            ClearESP("Players")
            for _, player in pairs(Services.Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                    local esp = CreateESP(player.Character.Head, "👤 " .. player.Name, Color3.fromRGB(0, 255, 0), true)
                    table.insert(Config.ESP.Players.Objects, esp)
                end
            end
            Notify("✅ ESP", "Player ESP ativado!")
        else
            ClearESP("Players")
            Notify("❌ ESP", "Player ESP desativado!")
        end
    end
})

-- Aba Teleporte
Tabs.Teleport:Button({
    Title = "🎯 Teleporte para Delivery Hitbox",
    Description = "Teleporta para o delivery hitbox mais próximo",
    Callback = function()
        local gameObjects = FindGameObjects()
        if #gameObjects.DeliveryHitboxes > 0 then
            local closestHitbox = nil
            local shortestDistance = math.huge
            
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local playerPosition = LocalPlayer.Character.HumanoidRootPart.Position
                
                for _, hitbox in pairs(gameObjects.DeliveryHitboxes) do
                    if hitbox and hitbox.Position then
                        local distance = (hitbox.Position - playerPosition).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            closestHitbox = hitbox
                        end
                    end
                end
                
                if closestHitbox then
                    SafeTeleport(closestHitbox.Position, Config.Teleport.Method)
                else
                    Notify("❌ Erro", "Nenhum hitbox válido!")
                end
            end
        else
            Notify("❌ Erro", "Nenhum delivery hitbox encontrado!")
        end
    end
})

Tabs.Teleport:Button({
    Title = "🧠 Teleporte para Brainrot",
    Description = "Teleporta para um brainrot aleatório",
    Callback = function()
        local brainrots = FindBrainrots()
        if #brainrots > 0 then
            local randomBrainrot = brainrots[math.random(1, #brainrots)]
            if randomBrainrot and randomBrainrot.Position then
                SafeTeleport(randomBrainrot.Position, Config.Teleport.Method)
            else
                Notify("❌ Erro", "Brainrot inválido!")
            end
        else
            Notify("❌ Erro", "Nenhum brainrot encontrado!")
        end
    end
})

Tabs.Teleport:Dropdown({
    Title = "🎮 Método de Teleporte",
    Description = "Escolha como teleportar",
    Options = {"Tween", "Instant"},
    Value = Config.Teleport.Method,
    Callback = function(value)
        Config.Teleport.Method = value
        Notify("🎮 Método", "Alterado para: " .. value)
    end
})

-- Aba Automático
Tabs.Auto:Toggle({
    Title = "🤖 Auto Steal",
    Description = "Teleporte automático para delivery hitboxes",
    Value = Config.AutoSteal.Enabled,
    Callback = function(value)
        Config.AutoSteal.Enabled = value
        if value then
            SetupAutoSteal()
            Notify("✅ Auto Steal", "Sistema ativado!")
        else
            if Config.AutoSteal.Connection then
                Config.AutoSteal.Connection:Disconnect()
            end
            Notify("❌ Auto Steal", "Sistema desativado!")
        end
    end
})

-- Aba Debug
Tabs.Debug:Button({
    Title = "🔍 Escanear Workspace",
    Description = "Mostra objetos encontrados no workspace",
    Callback = function()
        local gameObjects = FindGameObjects()
        local brainrots = FindBrainrots()
        
        print("=== SCAN DO WORKSPACE ===")
        print("Plots encontrados:", #gameObjects.Plots)
        print("Delivery Hitboxes:", #gameObjects.DeliveryHitboxes)
        print("Purchases:", #gameObjects.Purchases)
        print("Map Parts:", #gameObjects.MapParts)
        print("Brainrots:", #brainrots)
        
        Notify("🔍 Scan", string.format("Plots: %d | Hitboxes: %d | Brainrots: %d", 
            #gameObjects.Plots, #gameObjects.DeliveryHitboxes, #brainrots))
    end
})

Tabs.Debug:Button({
    Title = "🧹 Limpar Todos os ESPs",
    Description = "Remove todos os ESPs ativos",
    Callback = function()
        ClearESP("all")
        Notify("✅ Limpeza", "Todos os ESPs removidos!")
    end
})

-- Inicialização
pcall(function()
    Window:SelectTab(1)
end)

-- Limpeza automática
Services.Players.PlayerRemoving:Connect(function(player)
    if player.Character and player.Character:FindFirstChild("Head") then
        for i, esp in pairs(Config.ESP.Players.Objects) do
            if esp.Parent == player.Character.Head then
                esp:Destroy()
                table.remove(Config.ESP.Players.Objects, i)
                break
            end
        end
    end
end)

Notify("🎉 Mahi Hub", "Carregado com paths específicos! v4.0")
print("✅ Mahi Hub v4.0 - Steal a Brainrot carregado com paths específicos!")
