-- Mahi Hub v3.0 - Steal a Brainrot (Versão Corrigida)
-- Corrigido baseado na documentação oficial do WindUI

-- Carregamento seguro do WindUI com URL correta
local WindUI
local success, error = pcall(function()
    WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if not success then
    warn("❌ Erro ao carregar WindUI: " .. tostring(error))
    warn("🔧 Tentando URL alternativa...")
    
    -- Tentativa com URL alternativa
    local success2, error2 = pcall(function()
        WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/Source.lua"))()
    end)
    
    if not success2 then
        warn("❌ Falha completa ao carregar WindUI: " .. tostring(error2))
        return
    end
end

-- Verificação de carregamento
if not WindUI then
    warn("❌ WindUI não foi carregado corretamente!")
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
    HttpService = game:GetService("HttpService"),
    ReplicatedStorage = game:GetService("ReplicatedStorage")
}

local LocalPlayer = Services.Players.LocalPlayer
local Camera = Services.Workspace.CurrentCamera

-- Configuração usando sintaxe correta do WindUI
local Window = WindUI:CreateWindow({
    Title = "🧠 Mahi Hub",
    Icon = "brain",
    Author = "Mahi Hub v3.0",
    Folder = "MahiHub",
    Size = UDim2.fromOffset(600, 500),
    Transparent = false,
    Theme = "Dark",
    HasOutline = true,
    SideBarWidth = 180
})

-- Variáveis de controle
local Config = {
    Speed = {
        Enabled = false,
        Value = 16,
        Connection = nil
    },
    ESP = {
        Enabled = false,
        Objects = {},
        Connections = {}
    },
    AutoSteal = {
        Enabled = false,
        Connection = nil
    }
}

-- Sistema de notificações
local function Notify(title, content, duration)
    WindUI:Notify({
        Title = title,
        Content = content,
        Duration = duration or 3,
        Icon = "info"
    })
end

-- Função de ESP otimizada
local function CreateESP(object, text, color)
    if not object or not object.Parent then return end
    
    -- Remove ESP existente
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
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Parent = billboardGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
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
    
    Config.ESP.Objects[object] = billboardGui
    return billboardGui
end

-- Função de limpeza de ESP
local function ClearESP()
    for object, esp in pairs(Config.ESP.Objects) do
        if esp and esp.Parent then
            esp:Destroy()
        end
    end
    Config.ESP.Objects = {}
end

-- Função para encontrar objetos do jogo
local function FindGameObjects(searchTerms)
    local found = {}
    for _, term in pairs(searchTerms) do
        for _, obj in pairs(Services.Workspace:GetDescendants()) do
            if obj.Name and obj.Name:lower():find(term:lower()) then
                table.insert(found, obj)
            end
        end
    end
    return found
end

-- Sistema de velocidade com bypass
local function SetupSpeed()
    if Config.Speed.Connection then
        Config.Speed.Connection:Disconnect()
    end
    
    Config.Speed.Connection = Services.RunService.Heartbeat:Connect(function()
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            local humanoid = character.Humanoid
            humanoid.WalkSpeed = Config.Speed.Value
            
            -- Bypass adicional para velocidades altas
            if Config.Speed.Value > 50 then
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    local bodyVelocity = rootPart:FindFirstChild("BodyVelocity")
                    if not bodyVelocity then
                        bodyVelocity = Instance.new("BodyVelocity")
                        bodyVelocity.MaxForce = Vector3.new(4000, 0, 4000)
                        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                        bodyVelocity.Parent = rootPart
                    end
                end
            end
        end
    end)
end

-- Função de teleporte seguro
local function SafeTeleport(position)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        Notify("❌ Erro", "Personagem não encontrado!")
        return false
    end
    
    local rootPart = character.HumanoidRootPart
    local safePosition = position + Vector3.new(0, 5, 0)
    
    -- Teleporte com tween suave
    local tween = Services.TweenService:Create(rootPart,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {CFrame = CFrame.new(safePosition)}
    )
    
    tween:Play()
    Notify("✅ Sucesso", "Teleportado com segurança!")
    return true
end

-- Sistema de Auto Steal
local function SetupAutoSteal()
    if Config.AutoSteal.Connection then
        Config.AutoSteal.Connection:Disconnect()
    end
    
    Config.AutoSteal.Connection = Services.RunService.Heartbeat:Connect(function()
        local checkpoints = FindGameObjects({"checkpoint", "base", "spawn"})
        if #checkpoints > 0 then
            local closestCheckpoint = nil
            local shortestDistance = math.huge
            
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local playerPosition = LocalPlayer.Character.HumanoidRootPart.Position
                
                for _, checkpoint in pairs(checkpoints) do
                    if checkpoint and checkpoint.Position then
                        local distance = (checkpoint.Position - playerPosition).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            closestCheckpoint = checkpoint
                        end
                    end
                end
                
                if closestCheckpoint and shortestDistance > 10 then
                    SafeTeleport(closestCheckpoint.Position)
                    wait(1) -- Delay para evitar spam
                end
            end
        end
    end)
end

-- Criar as abas usando sintaxe correta do WindUI
local Tabs = {
    Main = Window:Tab({ Title = "🏠 Principal", Icon = "home" }),
    ESP = Window:Tab({ Title = "👁️ ESP", Icon = "eye" }),
    Teleport = Window:Tab({ Title = "🚀 Teleporte", Icon = "zap" }),
    Auto = Window:Tab({ Title = "🤖 Automático", Icon = "bot" }),
    Config = Window:Tab({ Title = "⚙️ Configurações", Icon = "settings" })
}

-- Aba Principal - Velocidade
Tabs.Main:Toggle({
    Title = "🏃 Velocidade Ativada",
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
    Title = "⚡ Velocidade",
    Value = {
        Min = 16,
        Max = 200,
        Default = 16
    },
    Callback = function(value)
        Config.Speed.Value = value
    end
})

-- Aba ESP
Tabs.ESP:Toggle({
    Title = "💀 ESP Brainrot",
    Value = Config.ESP.Enabled,
    Callback = function(value)
        Config.ESP.Enabled = value
        if value then
            local brainrots = FindGameObjects({"brainrot", "brain", "rot"})
            for _, brainrot in pairs(brainrots) do
                CreateESP(brainrot, "💀 Brainrot", Color3.fromRGB(255, 0, 0))
            end
            Notify("✅ ESP", "Brainrot ESP ativado!")
        else
            ClearESP()
            Notify("❌ ESP", "ESP desativado!")
        end
    end
})

Tabs.ESP:Toggle({
    Title = "👤 ESP Jogadores",
    Value = false,
    Callback = function(value)
        if value then
            for _, player in pairs(Services.Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                    CreateESP(player.Character.Head, "👤 " .. player.Name, Color3.fromRGB(0, 255, 0))
                end
            end
            Notify("✅ ESP", "Player ESP ativado!")
        else
            ClearESP()
            Notify("❌ ESP", "Player ESP desativado!")
        end
    end
})

Tabs.ESP:Toggle({
    Title = "🏠 ESP Checkpoints",
    Value = false,
    Callback = function(value)
        if value then
            local checkpoints = FindGameObjects({"checkpoint", "base", "spawn"})
            for _, checkpoint in pairs(checkpoints) do
                CreateESP(checkpoint, "🏠 Base", Color3.fromRGB(255, 255, 0))
            end
            Notify("✅ ESP", "Checkpoint ESP ativado!")
        else
            ClearESP()
            Notify("❌ ESP", "Checkpoint ESP desativado!")
        end
    end
})

-- Aba Teleporte
Tabs.Teleport:Button({
    Title = "🎯 Steal Instantâneo",
    Callback = function()
        local checkpoints = FindGameObjects({"checkpoint", "base", "spawn"})
        if #checkpoints > 0 then
            local closestCheckpoint = nil
            local shortestDistance = math.huge
            
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local playerPosition = LocalPlayer.Character.HumanoidRootPart.Position
                
                for _, checkpoint in pairs(checkpoints) do
                    if checkpoint and checkpoint.Position then
                        local distance = (checkpoint.Position - playerPosition).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            closestCheckpoint = checkpoint
                        end
                    end
                end
                
                if closestCheckpoint then
                    SafeTeleport(closestCheckpoint.Position)
                else
                    Notify("❌ Erro", "Nenhum checkpoint válido!")
                end
            end
        else
            Notify("❌ Erro", "Nenhum checkpoint encontrado!")
        end
    end
})

Tabs.Teleport:Button({
    Title = "🧠 Teleportar para Brainrot",
    Callback = function()
        local brainrots = FindGameObjects({"brainrot", "brain", "rot"})
        if #brainrots > 0 then
            local randomBrainrot = brainrots[math.random(1, #brainrots)]
            if randomBrainrot and randomBrainrot.Position then
                SafeTeleport(randomBrainrot.Position)
            else
                Notify("❌ Erro", "Brainrot inválido!")
            end
        else
            Notify("❌ Erro", "Nenhum brainrot encontrado!")
        end
    end
})

-- Aba Automático
Tabs.Auto:Toggle({
    Title = "🤖 Auto Steal",
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

-- Aba Configurações
Tabs.Config:Button({
    Title = "🔄 Atualizar ESPs",
    Callback = function()
        ClearESP()
        if Config.ESP.Enabled then
            local brainrots = FindGameObjects({"brainrot", "brain", "rot"})
            for _, brainrot in pairs(brainrots) do
                CreateESP(brainrot, "💀 Brainrot", Color3.fromRGB(255, 0, 0))
            end
        end
        Notify("✅ Atualizado", "ESPs atualizados!")
    end
})

Tabs.Config:Button({
    Title = "🧹 Limpar Todos os ESPs",
    Callback = function()
        ClearESP()
        Notify("✅ Limpo", "Todos os ESPs removidos!")
    end
})

-- Limpeza automática quando o jogador sai
Services.Players.PlayerRemoving:Connect(function(player)
    if player.Character and player.Character:FindFirstChild("Head") then
        local esp = Config.ESP.Objects[player.Character.Head]
        if esp then
            esp:Destroy()
            Config.ESP.Objects[player.Character.Head] = nil
        end
    end
end)

-- Inicialização final
pcall(function()
    Window:SelectTab(1)
end)

Notify("🎉 Mahi Hub", "Carregado com sucesso! Versão 3.0 corrigida!")
print("✅ Mahi Hub v3.0 - Steal a Brainrot carregado e funcionando!")
