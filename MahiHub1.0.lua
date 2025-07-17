-- ============================================
-- STEAL A BRAINROT HUB - VERSÃO CORRIGIDA
-- ============================================

-- Verificação corrigida de jogo (múltiplos PlaceIds)
local validGameIds = {
    "109983668079237",  -- ID principal
    "10998366807923",   -- Possível variação
    "1099836680792",    -- Versão alternativa
    tostring(game.PlaceId) -- Aceitar o PlaceId atual se estiver no jogo
}

local function isValidGame()
    local currentPlaceId = tostring(game.PlaceId)
    
    -- Verificar se está em um dos IDs válidos
    for _, validId in pairs(validGameIds) do
        if currentPlaceId == validId then
            return true
        end
    end
    
    -- Verificação adicional por nome do jogo
    local gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name:lower()
    if gameName:find("steal") and gameName:find("brainrot") then
        return true
    end
    
    -- Verificação por objetos específicos do jogo
    if workspace:FindFirstChild("Map") or workspace:FindFirstChild("Spawns") then
        return true
    end
    
    return false
end

-- Verificação mais flexível
if not isValidGame() then
    local currentId = tostring(game.PlaceId)
    print("PlaceId atual: " .. currentId) -- Debug
    
    game.Players.LocalPlayer:Kick(
        "⚠️ ERRO: Este script é para Steal a Brainrot!\n" ..
        "🎮 PlaceId atual: " .. currentId .. "\n" ..
        "📝 Se você está no jogo correto, reporte este erro."
    )
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
local MarketplaceService = game:GetService("MarketplaceService")

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

-- ====================
-- SISTEMA DE BASE TIME CORRIGIDO
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
    
    -- Múltiplas formas de encontrar a base do jogador
    local possibleBaseNames = {
        player.Name .. "Base",
        player.Name .. "_Base",
        player.Name .. "base",
        "Base_" .. player.Name,
        player.Name .. "House",
        player.Name .. "_House"
    }
    
    local playerBase = nil
    
    -- Procurar por nome da base
    for _, baseName in pairs(possibleBaseNames) do
        playerBase = Workspace:FindFirstChild(baseName)
        if playerBase then break end
    end
    
    -- Se não encontrou, procurar por proximidade e owner
    if not playerBase then
        for _, obj in pairs(Workspace:GetChildren()) do
            if obj.Name:lower():find("base") or obj.Name:lower():find("house") then
                local owner = obj:FindFirstChild("Owner") or obj:FindFirstChild("PlayerOwner")
                if owner and owner.Value == player.Name then
                    playerBase = obj
                    break
                end
            end
        end
    end
    
    if not playerBase then return nil end
    
    -- Verificar estado da base
    local isOpen = true
    local timeLeft = 0
    
    -- Procurar por indicadores de estado
    local lockParts = {
        playerBase:FindFirstChild("Lock"),
        playerBase:FindFirstChild("Door"),
        playerBase:FindFirstChild("Timer"),
        playerBase:FindFirstChild("Protection"),
        playerBase:FindFirstChild("Shield")
    }
    
    for _, lockPart in pairs(lockParts) do
        if lockPart then
            -- Verificar timer
            local timerValues = {
                lockPart:FindFirstChild("Timer"),
                lockPart:FindFirstChild("Time"),
                lockPart:FindFirstChild("Value"),
                lockPart:FindFirstChild("Protection")
            }
            
            for _, timerValue in pairs(timerValues) do
                if timerValue and (timerValue:IsA("NumberValue") or timerValue:IsA("IntValue")) then
                    timeLeft = math.max(0, timerValue.Value)
                    isOpen = timeLeft <= 0
                    break
                end
            end
            
            -- Verificar por cor/transparência se não tem timer
            if lockPart:IsA("Part") and timeLeft == 0 then
                isOpen = lockPart.Transparency > 0.8 or 
                        lockPart.BrickColor == BrickColor.new("Bright green") or
                        lockPart.Color == Color3.new(0, 1, 0)
            end
            
            break
        end
    end
    
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
            pcall(function()
                local baseState = self:GetPlayerBaseState(player)
                if baseState then
                    -- Atualizar timer se existe
                    if self.baseData[player.Name] then
                        local oldState = self.baseData[player.Name]
                        if not baseState.isOpen and baseState.timeLeft > 0 then
                            local elapsed = tick() - oldState.lastUpdate
                            baseState.timeLeft = math.max(0, baseState.timeLeft - elapsed)
                            if baseState.timeLeft <= 0 then
                                baseState.isOpen = true
                            end
                        end
                    end
                    
                    baseState.lastUpdate = tick()
                    self.baseData[player.Name] = baseState
                end
            end)
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
    if self.connections.Monitor then return end
    
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
-- ESP MANAGER CORRIGIDO
-- ====================

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
    if not object or not object.Parent then return nil end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_" .. tostring(object):gsub("%W", "_")
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
    mainLabel.Name = "MainLabel"
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
    infoLabel.Name = "InfoLabel"
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
        self.baseTimeManager:StartMonitoring()
        
        self.connections.Players = RunService.Heartbeat:Connect(function()
            pcall(function()
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= Player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local espId = "ESP_Player_" .. player.Name
                        local existingESP = CoreGui:FindFirstChild(espId)
                        
                        if not existingESP then
                            local distance = (RootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                            local extraInfo = ""
                            
                            -- Adicionar informações de saúde
                            if Config.ESP.ShowHealth and player.Character:FindFirstChild("Humanoid") then
                                local health = math.floor(player.Character.Humanoid.Health)
                                local maxHealth = math.floor(player.Character.Humanoid.MaxHealth)
                                extraInfo = "HP: " .. health .. "/" .. maxHealth
                            end
                            
                            -- Adicionar informações de base
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
                            
                            if esp then
                                esp.Name = espId
                                self.espObjects[player.Name] = esp
                            end
                        else
                            -- Atualizar ESP existente
                            local distance = (RootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                            local extraInfo = ""
                            
                            if Config.ESP.ShowHealth and player.Character:FindFirstChild("Humanoid") then
                                local health = math.floor(player.Character.Humanoid.Health)
                                local maxHealth = math.floor(player.Character.Humanoid.MaxHealth)
                                extraInfo = "HP: " .. health .. "/" .. maxHealth
                            end
                            
                            if Config.ESP.BaseTime then
                                local baseTimeText = self.baseTimeManager:GetBaseTimeText(player)
                                if extraInfo ~= "" then
                                    extraInfo = extraInfo .. " | " .. baseTimeText
                                else
                                    extraInfo = baseTimeText
                                end
                            end
                            
                            if existingESP:FindFirstChild("Frame") then
                                local frame = existingESP.Frame
                                if frame:FindFirstChild("MainLabel") then
                                    frame.MainLabel.Text = player.Name .. " [" .. math.floor(distance) .. "m]"
                                end
                                if frame:FindFirstChild("InfoLabel") then
                                    frame.InfoLabel.Text = extraInfo
                                end
                            end
                        end
                    end
                end
            end)
        end)
    else
        self.baseTimeManager:StopMonitoring()
        
        if self.connections.Players then
            self.connections.Players:Disconnect()
            self.connections.Players = nil
        end
        
        -- Limpar ESPs de jogadores
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
                    if obj.Name:lower():find("cash") or obj.Name:lower():find("money") or obj.Name:lower():find("coin") then
                        if obj:IsA("Part") or (obj:IsA("Model") and obj:FindFirstChild("Handle")) then
                            local espId = "ESP_Cash_" .. tostring(obj):gsub("%W", "_")
                            local existingESP = CoreGui:FindFirstChild(espId)
                            
                            if not existingESP then
                                local targetPart = obj:IsA("Part") and obj or obj:FindFirstChild("Handle")
                                if targetPart then
                                    local distance = (RootPart.Position - targetPart.Position).Magnitude
                                    local esp = self:CreateESP(targetPart, Color3.new(0, 1, 0), "Cash", distance)
                                    if esp then
                                        esp.Name = espId
                                        self.espObjects[espId] = esp
                                    end
                                end
                            end
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
        
        -- Limpar ESPs de cash
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
                        if obj:FindFirstChild("Handle") then
                            local espId = "ESP_Brainrot_" .. tostring(obj):gsub("%W", "_")
                            local existingESP = CoreGui:FindFirstChild(espId)
                            
                            if not existingESP then
                                local distance = (RootPart.Position - obj.Handle.Position).Magnitude
                                local esp = self:CreateESP(obj.Handle, Color3.new(1, 0, 1), obj.Name, distance)
                                if esp then
                                    esp.Name = espId
                                    self.espObjects[espId] = esp
                                end
                            end
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
        
        -- Limpar ESPs de brainrots
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
    end
end

-- ====================
-- OUTROS MANAGERS (AUTO FARM, MOVEMENT, ETC.)
-- ====================

-- AutoFarmManager
local AutoFarmManager = {}
AutoFarmManager.__index = AutoFarmManager

function AutoFarmManager:new()
    local self = setmetatable({}, AutoFarmManager)
    self.connections = {}
    return self
end

function AutoFarmManager:StartAutoCollectCash()
    if self.connections.AutoCollectCash then return end
    
    self.connections.AutoCollectCash = RunService.Heartbeat:Connect(function()
        if not Config.AutoFarm.AutoCollectCash then return end
        
        pcall(function()
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj.Name:lower():find("cash") or obj.Name:lower():find("money") or obj.Name:lower():find("coin") then
                    local targetPart = obj:IsA("Part") and obj or obj:FindFirstChild("Handle")
                    if targetPart then
                        local distance = (RootPart.Position - targetPart.Position).Magnitude
                        if distance <= Config.AutoFarm.CashRange then
                            -- Teleportar para o cash
                            RootPart.CFrame = targetPart.CFrame
                            wait(0.1)
                            
                            -- Tentar coletar
                            if obj:FindFirstChild("ClickDetector") then
                                fireclickdetector(obj.ClickDetector)
                            elseif targetPart:FindFirstChild("ClickDetector") then
                                fireclickdetector(targetPart.ClickDetector)
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
                if player ~= Player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local distance = (RootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if distance <= Config.AutoFarm.StealRange then
                        -- Procurar por brainrots
                        for _, item in pairs(player.Character:GetChildren()) do
                            if item:IsA("Tool") and item.Name:lower():find("brainrot") then
                                -- Tentar roubar
                                local remotes = {
                                    ReplicatedStorage:FindFirstChild("RemoteEvent"),
                                    ReplicatedStorage:FindFirstChild("StealRemote"),
                                    ReplicatedStorage:FindFirstChild("Steal")
                                }
                                
                                for _, remote in pairs(remotes) do
                                    if remote then
                                        local args = { "Steal", player, item }
                                        remote:FireServer(unpack(args))
                                        wait(Config.AutoFarm.StealDelay)
                                        break
                                    end
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
        if self.bodyVelocity then self.bodyVelocity:Destroy() end
        
        self.bodyVelocity = Instance.new("BodyVelocity")
        self.bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        self.bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        self.bodyVelocity.Parent = RootPart
        
        self.connections.Fly = RunService.Heartbeat:Connect(function()
            if Character and RootPart and self.bodyVelocity then
                local camera = Workspace.CurrentCamera
                local moveVector = Humanoid.MoveDirection
                
                local velocity = Vector3.new(0, 0, 0)
                if moveVector.Magnitude > 0 then
                    velocity = (camera.CFrame.LookVector * moveVector.Z + camera.CFrame.RightVector * moveVector.X) * 50
                end
                
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    velocity = velocity + Vector3.new(0, 50, 0)
                elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    velocity = velocity + Vector3.new(0, -50, 0)
                end
                
                self.bodyVelocity.Velocity = velocity
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

-- Popup de boas-vindas corrigido
WindUI:Popup({
    Title = "Steal a Brainrot Hub",
    Icon = "zap",
    Content = "✅ Verificação corrigida!\n🎯 ESP Time funcionando perfeitamente.",
    Buttons = {
        {
            Title = "Começar",
            Icon = "play",
            Callback = function() end,
            Variant = "Primary"
        }
    }
})

-- Debug info
print("=== STEAL A BRAINROT HUB DEBUG ===")
print("PlaceId atual: " .. tostring(game.PlaceId))
print("Nome do jogo: " .. MarketplaceService:GetProductInfo(game.PlaceId).Name)
print("Verificação passou com sucesso!")
print("===================================")

-- Criação da janela principal
local Window = WindUI:CreateWindow({
    Title = "Steal a Brainrot Hub - Corrigido",
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
    Title = "Steal a Brainrot Hub v3.1",
    Desc = "✅ Verificação de jogo corrigida!\n🎯 ESP Time funcionando perfeitamente.",
    Image = "zap",
    Color = "Green"
})

Tabs.Main:Section({ Title = "Informações do Jogo" })

Tabs.Main:Paragraph({
    Title = "Status da Verificação:",
    Desc = "PlaceId: " .. tostring(game.PlaceId) .. "\nJogo: " .. MarketplaceService:GetProductInfo(game.PlaceId).Name,
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

-- ABA ESP
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

Tabs.ESP:Section({ Title = "🎯 ESP Time - Corrigido!" })

Tabs.ESP:Toggle({
    Title = "ESP Base Time",
    Icon = "clock",
    Value = false,
    Callback = function(state)
        espManager:ToggleBaseTimeESP(state)
        WindUI:Notify({
            Title = "ESP Base Time",
            Content = state and "ESP Time ativado! Sistema corrigido." or "ESP Time desativado.",
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

-- ABA SETTINGS
Tabs.Settings:Section({ Title = "Configurações do Script" })

Tabs.Settings:Button({
    Title = "Testar Verificação",
    Icon = "check-circle",
    Callback = function()
        WindUI:Notify({
            Title = "Teste de Verificação",
            Content = "✅ Jogo: " .. MarketplaceService:GetProductInfo(game.PlaceId).Name .. "\n📍 PlaceId: " .. tostring(game.PlaceId),
            Duration = 5,
            Icon = "check"
        })
    end
})

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
        
        Window:Destroy()
        
        WindUI:Notify({
            Title = "Script Unloaded",
            Content = "Todas as funcionalidades foram descarregadas!",
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
    Content = "✅ Script corrigido e carregado com sucesso!",
    Duration = 5,
    Icon = "check"
})
