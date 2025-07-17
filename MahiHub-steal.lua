-- ============================================
-- STEAL A BRAINROT HUB - ESP TIME VERSION
-- ============================================

-- Verificação de jogo
local gameId = "109983668079237"
if tostring(game.PlaceId) ~= gameId then
    game.Players.LocalPlayer:Kick("⚠️ ERRO: Este script só funciona no jogo Steal a Brainrot!\n🎮 ID do jogo correto: " .. gameId)
    return
end

-- Carregamento da biblioteca WindUI
local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if not success then
    game.Players.LocalPlayer:Kick("⚠️ ERRO: Falha ao carregar WindUI Library!")
    return
end

-- Serviços do Roblox
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Variáveis globais
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Atualização de Character quando respawna
Player.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    RootPart = Character:WaitForChild("HumanoidRootPart")
end)

-- Configurações do script
local Config = {
    AutoFarm = {
        AutoCollectCash = false,
        AutoSteal = false,
        AutoLock = false,
        AutoEquip = false,
        AutoSell = false,
        StealRange = 20,
        CashRange = 30,
        StealDelay = 0.1
    },
    Movement = {
        Speed = 16,
        JumpPower = 50,
        Fly = false,
        NoClip = false,
        SpeedBoost = false,
        SuperSpeed = 50
    },
    ESP = {
        Players = false,
        Cash = false,
        Brainrots = false,
        Weapons = false,
        Chests = false,
        BaseTime = false,
        ShowDistance = true,
        ShowHealth = true
    },
    Combat = {
        SilentAim = false,
        AutoAttack = false,
        KillAura = false,
        AntiKick = false,
        GodMode = false
    },
    Teleport = {
        TeleportToCash = false,
        TeleportToPlayers = false,
        TeleportSpeed = 300
    },
    Misc = {
        AntiAFK = false,
        FPSBoost = false,
        AutoRebirth = false,
        InfiniteJump = false
    }
}

-- Sistema de base e tempo
local BasesData = {}
local BaseTimers = {}

-- ====================
-- SISTEMA DE BASE TIME
-- ====================

local BaseTimeManager = {}
BaseTimeManager.__index = BaseTimeManager

function BaseTimeManager:new()
    local self = setmetatable({}, BaseTimeManager)
    self.connections = {}
    self.baseData = {}
    self.baseStates = {}
    return self
end

function BaseTimeManager:FormatTime(seconds)
    if seconds <= 0 then
        return "ABERTA"
    end
    
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    
    if hours > 0 then
        return string.format("%02d:%02d:%02d", hours, minutes, secs)
    else
        return string.format("%02d:%02d", minutes, secs)
    end
end

function BaseTimeManager:GetPlayerBaseState(player)
    if not player or not player.Character then return nil end
    
    -- Procurar por base do jogador
    local baseName = player.Name .. "Base"
    local playerBase = Workspace:FindFirstChild(baseName) or Workspace:FindFirstChild(player.Name .. "_Base")
    
    if not playerBase then
        -- Tentar encontrar base por proximidade
        for _, obj in pairs(Workspace:GetChildren()) do
            if obj.Name:find("Base") and obj:FindFirstChild("Owner") then
                if obj.Owner.Value == player.Name then
                    playerBase = obj
                    break
                end
            end
        end
    end
    
    if not playerBase then return nil end
    
    -- Verificar se base está aberta ou fechada
    local isOpen = true
    local timeLeft = 0
    
    -- Procurar por indicadores de estado da base
    local lockPart = playerBase:FindFirstChild("Lock") or playerBase:FindFirstChild("Door")
    if lockPart then
        -- Verificar se tem timer ou estado
        local timerValue = lockPart:FindFirstChild("Timer") or lockPart:FindFirstChild("Time")
        if timerValue and timerValue:IsA("NumberValue") then
            timeLeft = timerValue.Value
            isOpen = timeLeft <= 0
        else
            -- Verificar transparência ou cor para determinar estado
            if lockPart:IsA("Part") then
                isOpen = lockPart.Transparency > 0.5 or lockPart.BrickColor == BrickColor.new("Bright green")
            end
        end
    end
    
    -- Se não encontrou indicadores, assumir que está aberta
    return {
        base = playerBase,
        isOpen = isOpen,
        timeLeft = timeLeft,
        lastUpdate = tick()
    }
end

function BaseTimeManager:UpdateBaseTimers()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player then
            local baseState = self:GetPlayerBaseState(player)
            if baseState then
                self.baseData[player.Name] = baseState
                
                -- Atualizar timer se base está fechada
                if not baseState.isOpen and baseState.timeLeft > 0 then
                    local elapsed = tick() - baseState.lastUpdate
                    baseState.timeLeft = math.max(0, baseState.timeLeft - elapsed)
                    baseState.lastUpdate = tick()
                    
                    if baseState.timeLeft <= 0 then
                        baseState.isOpen = true
                    end
                end
            end
        end
    end
end

function BaseTimeManager:GetBaseTimeText(player)
    local baseState = self.baseData[player.Name]
    if not baseState then
        return "Base: N/A"
    end
    
    if baseState.isOpen then
        return "Base: ABERTA"
    else
        return "Base: " .. self:FormatTime(baseState.timeLeft)
    end
end

function BaseTimeManager:StartMonitoring()
    self.connections.Monitor = RunService.Heartbeat:Connect(function()
        self:UpdateBaseTimers()
    end)
end

function BaseTimeManager:StopMonitoring()
    if self.connections.Monitor then
        self.connections.Monitor:Disconnect()
        self.connections.Monitor = nil
    end
end

-- ====================
-- MANAGERS ATUALIZADOS
-- ====================

-- ESPManager atualizado com ESP Time
local ESPManager = {}
ESPManager.__index = ESPManager

function ESPManager:new()
    local self = setmetatable({}, ESPManager)
    self.espObjects = {}
    self.connections = {}
    self.baseTimeManager = BaseTimeManager:new()
    return self
end

function ESPManager:CreateESP(object, color, text, distance, extraInfo)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_" .. object.Name .. "_" .. tostring(object)
    billboard.Parent = CoreGui
    billboard.Adornee = object
    billboard.Size = UDim2.new(0, 250, 0, 80)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    
    local frame = Instance.new("Frame")
    frame.Parent = billboard
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    
    local mainLabel = Instance.new("TextLabel")
    mainLabel.Parent = frame
    mainLabel.Size = UDim2.new(1, 0, 0.5, 0)
    mainLabel.Position = UDim2.new(0, 0, 0, 0)
    mainLabel.BackgroundTransparency = 1
    mainLabel.Text = text .. (distance and " [" .. math.floor(distance) .. "m]" or "")
    mainLabel.TextColor3 = color
    mainLabel.TextScaled = true
    mainLabel.Font = Enum.Font.SourceSansBold
    mainLabel.TextStrokeTransparency = 0
    mainLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Parent = frame
    infoLabel.Size = UDim2.new(1, 0, 0.5, 0)
    infoLabel.Position = UDim2.new(0, 0, 0.5, 0)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = extraInfo or ""
    infoLabel.TextColor3 = Color3.new(1, 1, 0)
    infoLabel.TextScaled = true
    infoLabel.Font = Enum.Font.SourceSans
    infoLabel.TextStrokeTransparency = 0
    infoLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    
    return billboard
end

function ESPManager:TogglePlayersESP(enabled)
    if enabled then
        -- Iniciar monitoramento de bases
        self.baseTimeManager:StartMonitoring()
        
        self.connections.Players = RunService.Heartbeat:Connect(function()
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= Player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local existingESP = CoreGui:FindFirstChild("ESP_" .. player.Name .. "_" .. tostring(player.Character.HumanoidRootPart))
                    
                    if not existingESP then
                        local distance = (RootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                        local extraInfo = ""
                        
                        -- Adicionar informações extras
                        if Config.ESP.ShowHealth and player.Character:FindFirstChild("Humanoid") then
                            local health = math.floor(player.Character.Humanoid.Health)
                            local maxHealth = math.floor(player.Character.Humanoid.MaxHealth)
                            extraInfo = extraInfo .. "HP: " .. health .. "/" .. maxHealth
                        end
                        
                        if Config.ESP.BaseTime then
                            local baseTimeText = self.baseTimeManager:GetBaseTimeText(player)
                            if extraInfo ~= "" then
                                extraInfo = extraInfo .. " | " .. baseTimeText
                            else
                                extraInfo = baseTimeText
                            end
                        end
                        
                        local esp = self:CreateESP(
                            player.Character.HumanoidRootPart, 
                            Color3.new(1, 0, 0), 
                            player.Name, 
                            distance,
                            extraInfo
                        )
                        self.espObjects[player.Name] = esp
                    else
                        -- Atualizar informações existentes
                        local distance = (RootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                        local extraInfo = ""
                        
                        if Config.ESP.ShowHealth and player.Character:FindFirstChild("Humanoid") then
                            local health = math.floor(player.Character.Humanoid.Health)
                            local maxHealth = math.floor(player.Character.Humanoid.MaxHealth)
                            extraInfo = extraInfo .. "HP: " .. health .. "/" .. maxHealth
                        end
                        
                        if Config.ESP.BaseTime then
                            local baseTimeText = self.baseTimeManager:GetBaseTimeText(player)
                            if extraInfo ~= "" then
                                extraInfo = extraInfo .. " | " .. baseTimeText
                            else
                                extraInfo = baseTimeText
                            end
                        end
                        
                        existingESP.Frame.TextLabel.Text = player.Name .. " [" .. math.floor(distance) .. "m]"
                        existingESP.Frame.TextLabel2.Text = extraInfo
                    end
                end
            end
        end)
    else
        -- Parar monitoramento de bases
        self.baseTimeManager:StopMonitoring()
        
        if self.connections.Players then
            self.connections.Players:Disconnect()
            self.connections.Players = nil
        end
        for name, esp in pairs(self.espObjects) do
            if esp and esp.Parent then
                esp:Destroy()
            end
            self.espObjects[name] = nil
        end
    end
end

function ESPManager:ToggleCashESP(enabled)
    if enabled then
        self.connections.Cash = RunService.Heartbeat:Connect(function()
            pcall(function()
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj.Name == "Cash" or obj.Name == "Money" or obj.Name == "Coin" then
                        local existingESP = CoreGui:FindFirstChild("ESP_Cash_" .. tostring(obj))
                        if not existingESP then
                            local distance = (RootPart.Position - obj.Position).Magnitude
                            local esp = self:CreateESP(obj, Color3.new(0, 1, 0), "Cash", distance)
                            esp.Name = "ESP_Cash_" .. tostring(obj)
                            self.espObjects["Cash_" .. tostring(obj)] = esp
                        else
                            local distance = (RootPart.Position - obj.Position).Magnitude
                            existingESP.Frame.TextLabel.Text = "Cash [" .. math.floor(distance) .. "m]"
                        end
                    end
                end
            end)
        end)
    else
        if self.connections.Cash then
            self.connections.Cash:Disconnect()
            self.connections.Cash = nil
        end
        for name, esp in pairs(self.espObjects) do
            if name:find("Cash") and esp and esp.Parent then
                esp:Destroy()
                self.espObjects[name] = nil
            end
        end
    end
end

function ESPManager:ToggleBrainrotsESP(enabled)
    if enabled then
        self.connections.Brainrots = RunService.Heartbeat:Connect(function()
            pcall(function()
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Tool") and obj.Name:lower():find("brainrot") then
                        local existingESP = CoreGui:FindFirstChild("ESP_Brainrot_" .. tostring(obj))
                        if not existingESP then
                            local distance = (RootPart.Position - obj.Handle.Position).Magnitude
                            local esp = self:CreateESP(obj.Handle, Color3.new(1, 0, 1), obj.Name, distance)
                            esp.Name = "ESP_Brainrot_" .. tostring(obj)
                            self.espObjects["Brainrot_" .. tostring(obj)] = esp
                        else
                            local distance = (RootPart.Position - obj.Handle.Position).Magnitude
                            existingESP.Frame.TextLabel.Text = obj.Name .. " [" .. math.floor(distance) .. "m]"
                        end
                    end
                end
            end)
        end)
    else
        if self.connections.Brainrots then
            self.connections.Brainrots:Disconnect()
            self.connections.Brainrots = nil
        end
        for name, esp in pairs(self.espObjects) do
            if name:find("Brainrot") and esp and esp.Parent then
                esp:Destroy()
                self.espObjects[name] = nil
            end
        end
    end
end

function ESPManager:ToggleBaseTimeESP(enabled)
    Config.ESP.BaseTime = enabled
    if enabled then
        self.baseTimeManager:StartMonitoring()
    else
        self.baseTimeManager:StopMonitoring()
    end
end

-- ====================
-- MANAGERS ORIGINAIS (SEM ALTERAÇÕES)
-- ====================

-- AutoFarmManager
local AutoFarmManager = {}
AutoFarmManager.__index = AutoFarmManager

function AutoFarmManager:new()
    local self = setmetatable({}, AutoFarmManager)
    self.connections = {}
    self.isRunning = false
    return self
end

function AutoFarmManager:StartAutoCollectCash()
    if self.connections.AutoCollectCash then return end
    
    self.connections.AutoCollectCash = RunService.Heartbeat:Connect(function()
        if not Config.AutoFarm.AutoCollectCash then return end
        
        pcall(function()
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj.Name == "Cash" or obj.Name == "Money" or obj.Name == "Coin" then
                    if obj:FindFirstChild("Handle") or obj:IsA("Part") then
                        local distance = (RootPart.Position - obj.Position).Magnitude
                        if distance <= Config.AutoFarm.CashRange then
                            RootPart.CFrame = obj.CFrame
                            wait(0.1)
                            if obj:FindFirstChild("ClickDetector") then
                                fireclickdetector(obj.ClickDetector)
                            end
                        end
                    end
                end
            end
        end)
    end)
end

function AutoFarmManager:StartAutoSteal()
    if self.connections.AutoSteal then return end
    
    self.connections.AutoSteal = RunService.Heartbeat:Connect(function()
        if not Config.AutoFarm.AutoSteal then return end
        
        pcall(function()
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= Player and player.Character then
                    local targetCharacter = player.Character
                    local targetRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
                    
                    if targetRootPart then
                        local distance = (RootPart.Position - targetRootPart.Position).Magnitude
                        if distance <= Config.AutoFarm.StealRange then
                            for _, item in pairs(targetCharacter:GetChildren()) do
                                if item:IsA("Tool") and item.Name:lower():find("brainrot") then
                                    local args = {
                                        [1] = "Steal",
                                        [2] = player,
                                        [3] = item
                                    }
                                    if ReplicatedStorage:FindFirstChild("RemoteEvent") then
                                        ReplicatedStorage.RemoteEvent:FireServer(unpack(args))
                                    end
                                    wait(Config.AutoFarm.StealDelay)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end)
end

function AutoFarmManager:Stop()
    for name, connection in pairs(self.connections) do
        if connection then
            connection:Disconnect()
            self.connections[name] = nil
        end
    end
end

-- MovementManager
local MovementManager = {}
MovementManager.__index = MovementManager

function MovementManager:new()
    local self = setmetatable({}, MovementManager)
    self.connections = {}
    self.bodyVelocity = nil
    return self
end

function MovementManager:SetSpeed(speed)
    if Character and Humanoid then
        Humanoid.WalkSpeed = speed
    end
end

function MovementManager:ToggleFly(enabled)
    if enabled then
        self.bodyVelocity = Instance.new("BodyVelocity")
        self.bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        self.bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        self.bodyVelocity.Parent = RootPart
        
        self.connections.Fly = RunService.Heartbeat:Connect(function()
            if Character and RootPart then
                local camera = Workspace.CurrentCamera
                local moveVector = Humanoid.MoveDirection
                
                if moveVector.Magnitude > 0 then
                    local velocity = (camera.CFrame.LookVector * moveVector.Z + camera.CFrame.RightVector * moveVector.X) * 50
                    self.bodyVelocity.Velocity = velocity
                else
                    self.bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                end
                
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    self.bodyVelocity.Velocity = self.bodyVelocity.Velocity + Vector3.new(0, 50, 0)
                end
            end
        end)
    else
        if self.connections.Fly then
            self.connections.Fly:Disconnect()
            self.connections.Fly = nil
        end
        if self.bodyVelocity then
            self.bodyVelocity:Destroy()
            self.bodyVelocity = nil
        end
    end
end

function MovementManager:ToggleNoClip(enabled)
    if enabled then
        self.connections.NoClip = RunService.Stepped:Connect(function()
            if Character then
                for _, part in pairs(Character:GetChildren()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if self.connections.NoClip then
            self.connections.NoClip:Disconnect()
            self.connections.NoClip = nil
        end
    end
end

-- ====================
-- INICIALIZAÇÃO DOS MANAGERS
-- ====================

local autoFarmManager = AutoFarmManager:new()
local movementManager = MovementManager:new()
local espManager = ESPManager:new()

-- ====================
-- CRIAÇÃO DA UI
-- ====================

-- Popup de boas-vindas
WindUI:Popup({
    Title = "Steal a Brainrot Hub",
    Icon = "zap",
    Content = "🎯 ESP Time ativado!\nVeja o tempo das bases em tempo real.",
    Buttons = {
        {
            Title = "Começar",
            Icon = "play",
            Callback = function() end,
            Variant = "Primary"
        }
    }
})

-- Criação da janela principal
local Window = WindUI:CreateWindow({
    Title = "Steal a Brainrot Hub - ESP Time",
    Icon = "zap",
    Author = "StealBrainrot Team",
    Folder = "StealBrainrotHub",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 200,
    HasOutline = true
})

-- Criação das abas
local Tabs = {
    Main = Window:Tab({ Title = "Main", Icon = "home", Desc = "Controles principais" }),
    AutoFarm = Window:Tab({ Title = "Auto Farm", Icon = "zap", Desc = "Automação de farm" }),
    Movement = Window:Tab({ Title = "Movement", Icon = "move", Desc = "Controles de movimento" }),
    ESP = Window:Tab({ Title = "ESP", Icon = "eye", Desc = "Visualizações ESP" }),
    Settings = Window:Tab({ Title = "Settings", Icon = "cog", Desc = "Configurações" })
}

-- ====================
-- IMPLEMENTAÇÃO DAS ABAS
-- ====================

-- ABA MAIN
Tabs.Main:Paragraph({
    Title = "Steal a Brainrot Hub v3.0",
    Desc = "🎯 Agora com ESP Time para monitorar bases em tempo real!",
    Image = "zap",
    Color = "Blue"
})

Tabs.Main:Section({ Title = "Controles Rápidos" })

Tabs.Main:Button({
    Title = "Reconnect",
    Icon = "refresh-cw",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, Player)
    end
})

Tabs.Main:Button({
    Title = "Server Hop",
    Icon = "shuffle",
    Callback = function()
        pcall(function()
            local servers = {}
            local req = game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
            local body = HttpService:JSONDecode(req)
            
            for _, server in pairs(body.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    table.insert(servers, server.id)
                end
            end
            
            if #servers > 0 then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], Player)
            end
        end)
    end
})

-- ABA AUTO FARM
Tabs.AutoFarm:Section({ Title = "Coleta Automática" })

Tabs.AutoFarm:Toggle({
    Title = "Auto Collect Cash",
    Icon = "dollar-sign",
    Value = false,
    Callback = function(state)
        Config.AutoFarm.AutoCollectCash = state
        if state then
            autoFarmManager:StartAutoCollectCash()
        else
            if autoFarmManager.connections.AutoCollectCash then
                autoFarmManager.connections.AutoCollectCash:Disconnect()
                autoFarmManager.connections.AutoCollectCash = nil
            end
        end
    end
})

Tabs.AutoFarm:Toggle({
    Title = "Auto Steal",
    Icon = "user-x",
    Value = false,
    Callback = function(state)
        Config.AutoFarm.AutoSteal = state
        if state then
            autoFarmManager:StartAutoSteal()
        else
            if autoFarmManager.connections.AutoSteal then
                autoFarmManager.connections.AutoSteal:Disconnect()
                autoFarmManager.connections.AutoSteal = nil
            end
        end
    end
})

Tabs.AutoFarm:Section({ Title = "Configurações" })

Tabs.AutoFarm:Slider({
    Title = "Alcance de Roubo",
    Value = {
        Min = 5,
        Max = 50,
        Default = 20
    },
    Callback = function(value)
        Config.AutoFarm.StealRange = value
    end
})

Tabs.AutoFarm:Slider({
    Title = "Alcance de Cash",
    Value = {
        Min = 10,
        Max = 100,
        Default = 30
    },
    Callback = function(value)
        Config.AutoFarm.CashRange = value
    end
})

-- ABA MOVEMENT
Tabs.Movement:Section({ Title = "Controles de Movimento" })

Tabs.Movement:Toggle({
    Title = "Fly",
    Icon = "plane",
    Value = false,
    Callback = function(state)
        Config.Movement.Fly = state
        movementManager:ToggleFly(state)
    end
})

Tabs.Movement:Toggle({
    Title = "NoClip",
    Icon = "ghost",
    Value = false,
    Callback = function(state)
        Config.Movement.NoClip = state
        movementManager:ToggleNoClip(state)
    end
})

Tabs.Movement:Slider({
    Title = "Velocidade",
    Value = {
        Min = 16,
        Max = 100,
        Default = 16
    },
    Callback = function(value)
        Config.Movement.Speed = value
        movementManager:SetSpeed(value)
    end
})

-- ABA ESP (PRINCIPAL COM ESP TIME)
Tabs.ESP:Section({ Title = "ESP Visualizações" })

Tabs.ESP:Toggle({
    Title = "ESP Jogadores",
    Icon = "users",
    Value = false,
    Callback = function(state)
        Config.ESP.Players = state
        espManager:TogglePlayersESP(state)
    end
})

Tabs.ESP:Toggle({
    Title = "ESP Cash",
    Icon = "dollar-sign",
    Value = false,
    Callback = function(state)
        Config.ESP.Cash = state
        espManager:ToggleCashESP(state)
    end
})

Tabs.ESP:Toggle({
    Title = "ESP Brainrots",
    Icon = "brain",
    Value = false,
    Callback = function(state)
        Config.ESP.Brainrots = state
        espManager:ToggleBrainrotsESP(state)
    end
})

Tabs.ESP:Section({ Title = "🎯 ESP Time - Novidade!" })

Tabs.ESP:Toggle({
    Title = "ESP Base Time",
    Icon = "clock",
    Value = false,
    Callback = function(state)
        espManager:ToggleBaseTimeESP(state)
        WindUI:Notify({
            Title = "ESP Base Time",
            Content = state and "ESP Time ativado! Veja o tempo das bases." or "ESP Time desativado.",
            Duration = 3,
            Icon = state and "check" or "x"
        })
    end
})

Tabs.ESP:Toggle({
    Title = "Mostrar Distância",
    Icon = "ruler",
    Value = true,
    Callback = function(state)
        Config.ESP.ShowDistance = state
    end
})

Tabs.ESP:Toggle({
    Title = "Mostrar Vida",
    Icon = "heart",
    Value = true,
    Callback = function(state)
        Config.ESP.ShowHealth = state
    end
})

Tabs.ESP:Paragraph({
    Title = "Como funciona o ESP Time:",
    Desc = "• Mostra o tempo restante para cada base abrir\n• Atualiza em tempo real\n• Indica quando a base está ABERTA\n• Funciona com ESP Jogadores ativado",
    Color = "Yellow"
})

-- ABA SETTINGS
Tabs.Settings:Section({ Title = "Configurações do Script" })

Tabs.Settings:Button({
    Title = "Unload Script",
    Icon = "x",
    Callback = function()
        -- Parar todos os managers
        autoFarmManager:Stop()
        for _, connection in pairs(movementManager.connections) do
            if connection then connection:Disconnect() end
        end
        for _, connection in pairs(espManager.connections) do
            if connection then connection:Disconnect() end
        end
        espManager.baseTimeManager:StopMonitoring()
        
        -- Limpar ESP
        for _, esp in pairs(espManager.espObjects) do
            if esp and esp.Parent then
                esp:Destroy()
            end
        end
        
        -- Destruir UI
        Window:Destroy()
        
        WindUI:Notify({
            Title = "Script Unloaded",
            Content = "Todas as funcionalidades foram descarregadas!",
            Duration = 3
        })
    end
})

Tabs.Settings:Button({
    Title = "Resetar Configurações",
    Icon = "rotate-ccw",
    Callback = function()
        -- Resetar todas as configurações
        Config.AutoFarm.AutoCollectCash = false
        Config.AutoFarm.AutoSteal = false
        Config.Movement.Fly = false
        Config.Movement.NoClip = false
        Config.ESP.Players = false
        Config.ESP.Cash = false
        Config.ESP.Brainrots = false
        Config.ESP.BaseTime = false
        
        WindUI:Notify({
            Title = "Configurações Resetadas",
            Content = "Todas as configurações foram restauradas!",
            Duration = 3
        })
    end
})

-- ====================
-- PROTEÇÃO ANTI-CHEAT
-- ====================

-- Proteção contra AFK
spawn(function()
    while wait(60) do
        pcall(function()
            game:GetService("VirtualUser"):CaptureController()
            game:GetService("VirtualUser"):ClickButton2(Vector2.new())
        end)
    end
end)

-- Proteção contra kick
pcall(function()
    local mt = getrawmetatable(game)
    local oldindex = mt.__index
    setreadonly(mt, false)
    mt.__index = function(t, k)
        if k == "Kick" then
            return function() end
        end
        return oldindex(t, k)
    end
    setreadonly(mt, true)
end)

-- Seleção da primeira aba
Window:SelectTab(1)

-- Notificação de carregamento
WindUI:Notify({
    Title = "Steal a Brainrot Hub",
    Content = "🎯 ESP Time carregado! Monitore bases em tempo real.",
    Duration = 5,
    Icon = "check"
})
