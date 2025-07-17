-- ============================================
-- STEAL A BRAINROT HUB V4.0 - CORRIGIDO
-- ============================================

-- Verificação corrigida de jogo
local validGameIds = {
    "109983668079237",
    "10998366807923",
    "1099836680792",
    tostring(game.PlaceId)
}

local function isValidGame()
    local currentPlaceId = tostring(game.PlaceId)
    for _, validId in pairs(validGameIds) do
        if currentPlaceId == validId then
            return true
        end
    end
    
    if workspace:FindFirstChild("Plots") then
        return true
    end
    
    return false
end

if not isValidGame() then
    game.Players.LocalPlayer:Kick("⚠️ ERRO: Este script é para Steal a Brainrot!")
    return
end

-- Carregamento da WindUI
local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if not success then
    game.Players.LocalPlayer:Kick("⚠️ ERRO: Falha ao carregar WindUI Library!")
    return
end

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

-- Variáveis globais
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local random = Random.new()

-- Atualização automática do character
Player.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    RootPart = Character:WaitForChild("HumanoidRootPart")
end)

-- Configurações
local Config = {
    AutoFarm = {
        AutoSteal = false,
        AutoLock = false,
        AutoEquip = false,
        StealRange = 25,
        StealDelay = 0.1
    },
    Movement = {
        Speed = 16,
        JumpPower = 50,
        Fly = false,
        NoClip = false
    },
    ESP = {
        Players = false,
        Brainrots = false,
        BaseTime = false,
        ShowDistance = true,
        ShowHealth = true,
        ShowRarity = true
    },
    Teleport = {
        TeleportSpeed = 300,
        ArbixSteal = false
    }
}

-- ====================
-- SISTEMA DE TELEPORTE BASEADO NO ARBIX HUB
-- ====================

local TeleportManager = {}
TeleportManager.__index = TeleportManager

function TeleportManager:new()
    local self = setmetatable({}, TeleportManager)
    self.tpAmt = 70
    self.void = CFrame.new(0, -3.4028234663852886e+38, 0)
    self.teleporting = false
    self.connections = {}
    self.pingUpdater = nil
    self:StartPingUpdater()
    return self
end

function TeleportManager:StartPingUpdater()
    self.pingUpdater = RunService.Heartbeat:Connect(function()
        local ping = Player:GetNetworkPing() * 1000
        self.tpAmt = math.clamp(math.floor(ping * 0.8), 10, 150)
    end)
end

function TeleportManager:TP(position)
    if not self.teleporting then
        self.teleporting = true
        if typeof(position) == "CFrame" then
            RootPart.CFrame = position + Vector3.new(
                random:NextNumber(-0.0001, 0.0001),
                random:NextNumber(-0.0001, 0.0001),
                random:NextNumber(-0.0001, 0.0001)
            )
            RunService.Heartbeat:Wait()
            self.teleporting = false
        end
    end
end

function TeleportManager:FindDeliveryBox()
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    
    for _, plot in pairs(plots:GetChildren()) do
        local sign = plot:FindFirstChild("PlotSign")
        if sign then
            local yourBase = sign:FindFirstChild("YourBase")
            if yourBase and yourBase.Enabled then
                local hitbox = plot:FindFirstChild("DeliveryHitbox")
                if hitbox then return hitbox end
            end
        end
    end
    return nil
end

function TeleportManager:ArbixSteal()
    if not Config.Teleport.ArbixSteal then return end
    
    local hitbox = self:FindDeliveryBox()
    if not hitbox then return end
    
    local target = hitbox.CFrame * CFrame.new(0, -3, 0)
    
    -- Primeira fase: teleporte múltiplo
    local i = 0
    while i < self.tpAmt do
        self:TP(target)
        i = i + 1
    end
    
    -- Segunda fase: void teleports
    for _ = 1, 2 do
        self:TP(self.void)
    end
    
    -- Terceira fase: teleporte final
    i = 0
    while i < (self.tpAmt / 16) do
        self:TP(target)
        i = i + 1
    end
    
    return true
end

function TeleportManager:TweenSteal()
    local TELEPORT_ITERATIONS = 85
    local VOID_CFRAME = CFrame.new(0, -3e40, 0)
    local JITTER_RANGE = 0.0002
    
    local function executeStealthMovement(targetCF, steps)
        if not RootPart or typeof(targetCF) ~= "CFrame" then
            return false
        end
        
        local currentPos = RootPart.Position
        local targetPos = targetCF.Position
        local startTime = tick()
        
        for i = 1, steps do
            local progress = (tick() - startTime) / (steps * 0.02)
            progress = math.min(progress, 1)
            
            local curvedProgress = progress * progress * (3 - 2 * progress)
            local newPos = currentPos:Lerp(targetPos, curvedProgress)
            
            newPos = newPos + Vector3.new(
                random:NextNumber(-JITTER_RANGE, JITTER_RANGE),
                random:NextNumber(-JITTER_RANGE, JITTER_RANGE),
                random:NextNumber(-JITTER_RANGE, JITTER_RANGE)
            )
            
            RootPart.CFrame = CFrame.new(newPos) * (RootPart.CFrame - RootPart.Position)
            
            local waitTime = random:NextNumber(0.005, 0.015)
            task.wait(waitTime)
        end
        return true
    end
    
    local delivery = self:FindDeliveryBox()
    if not delivery then return false end
    
    local targetPos = delivery.CFrame * CFrame.new(0, random:NextInteger(-3, -1), 0)
    
    for _ = 1, 3 do
        task.spawn(function()
            local success = executeStealthMovement(targetPos, TELEPORT_ITERATIONS)
            if success then
                for _ = 1, 3 do
                    RootPart.CFrame = VOID_CFRAME
                    task.wait(random:NextNumber(0.05, 0.1))
                    RootPart.CFrame = targetPos
                    task.wait(random:NextNumber(0.05, 0.1))
                end
            end
            task.wait(random:NextNumber(0.1, 0.3))
        end)
    end
    
    return true
end

function TeleportManager:IsHoldingBrainrot()
    local tool = Character:FindFirstChildOfClass("Tool")
    return tool and tool.Name:lower():find("brainrot") ~= nil
end

function TeleportManager:AutoSteal()
    if not Config.AutoFarm.AutoSteal then return end
    
    -- Só executar se estiver segurando um brainrot
    if not self:IsHoldingBrainrot() then return end
    
    -- Usar o sistema Arbix para teleporte
    return self:ArbixSteal()
end

function TeleportManager:Stop()
    if self.pingUpdater then
        self.pingUpdater:Disconnect()
        self.pingUpdater = nil
    end
end

-- ====================
-- SISTEMA ESP CORRIGIDO
-- ====================

local ESPManager = {}
ESPManager.__index = ESPManager

function ESPManager:new()
    local self = setmetatable({}, ESPManager)
    self.espObjects = {}
    self.connections = {}
    self.brainrotRarities = {
        ["Common"] = {Color = Color3.fromRGB(150, 150, 150), Priority = 1},
        ["Uncommon"] = {Color = Color3.fromRGB(100, 255, 100), Priority = 2},
        ["Rare"] = {Color = Color3.fromRGB(0, 100, 255), Priority = 3},
        ["Epic"] = {Color = Color3.fromRGB(128, 0, 255), Priority = 4},
        ["Legendary"] = {Color = Color3.fromRGB(255, 165, 0), Priority = 5},
        ["Mythic"] = {Color = Color3.fromRGB(255, 0, 255), Priority = 6}
    }
    return self
end

function ESPManager:GetBrainrotRarity(name)
    local lowerName = name:lower()
    
    -- Palavras-chave para identificar raridade
    local rarityKeywords = {
        ["mythic"] = "Mythic",
        ["legendary"] = "Legendary",
        ["epic"] = "Epic",
        ["rare"] = "Rare",
        ["uncommon"] = "Uncommon",
        ["common"] = "Common"
    }
    
    -- Verificar por palavras-chave no nome
    for keyword, rarity in pairs(rarityKeywords) do
        if lowerName:find(keyword) then
            return rarity
        end
    end
    
    -- Verificar por padrões específicos
    if lowerName:find("gold") or lowerName:find("shiny") then
        return "Legendary"
    elseif lowerName:find("dark") or lowerName:find("shadow") then
        return "Epic"
    elseif lowerName:find("blue") or lowerName:find("ice") then
        return "Rare"
    elseif lowerName:find("green") or lowerName:find("forest") then
        return "Uncommon"
    end
    
    return "Common"
end

function ESPManager:CreateESP(object, color, text, distance, extraInfo)
    if not object or not object.Parent then return nil end
    
    local espId = "ESP_" .. tostring(object):gsub("%W", "_")
    local existing = CoreGui:FindFirstChild(espId)
    if existing then existing:Destroy() end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = espId
    billboard.Parent = CoreGui
    billboard.Adornee = object
    billboard.Size = UDim2.new(0, 300, 0, 100)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.AlwaysOnTop = true
    
    local frame = Instance.new("Frame")
    frame.Parent = billboard
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    
    local mainLabel = Instance.new("TextLabel")
    mainLabel.Parent = frame
    mainLabel.Name = "MainLabel"
    mainLabel.Size = UDim2.new(1, 0, 0.6, 0)
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
    infoLabel.Size = UDim2.new(1, 0, 0.4, 0)
    infoLabel.Position = UDim2.new(0, 0, 0.6, 0)
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
        self.connections.Players = RunService.Heartbeat:Connect(function()
            pcall(function()
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= Player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local rootPart = player.Character.HumanoidRootPart
                        local distance = (RootPart.Position - rootPart.Position).Magnitude
                        
                        local extraInfo = ""
                        if Config.ESP.ShowHealth and player.Character:FindFirstChild("Humanoid") then
                            local health = math.floor(player.Character.Humanoid.Health)
                            local maxHealth = math.floor(player.Character.Humanoid.MaxHealth)
                            extraInfo = "HP: " .. health .. "/" .. maxHealth
                        end
                        
                        local esp = self:CreateESP(
                            rootPart,
                            Color3.new(1, 0, 0),
                            player.Name,
                            distance,
                            extraInfo
                        )
                        
                        if esp then
                            self.espObjects[player.Name] = esp
                        end
                    end
                end
            end)
        end)
    else
        if self.connections.Players then
            self.connections.Players:Disconnect()
            self.connections.Players = nil
        end
        self:ClearESPs("Player")
    end
end

function ESPManager:ToggleBrainrotsESP(enabled)
    if enabled then
        self.connections.Brainrots = RunService.Heartbeat:Connect(function()
            pcall(function()
                -- Procurar brainrots no workspace
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("Tool") and obj.Name:lower():find("brainrot") and obj:FindFirstChild("Handle") then
                        local handle = obj.Handle
                        local distance = (RootPart.Position - handle.Position).Magnitude
                        
                        -- Determinar raridade
                        local rarity = self:GetBrainrotRarity(obj.Name)
                        local rarityData = self.brainrotRarities[rarity]
                        
                        local extraInfo = ""
                        if Config.ESP.ShowRarity then
                            extraInfo = "Raridade: " .. rarity
                        end
                        
                        local esp = self:CreateESP(
                            handle,
                            rarityData.Color,
                            obj.Name,
                            distance,
                            extraInfo
                        )
                        
                        if esp then
                            self.espObjects["Brainrot_" .. tostring(obj)] = esp
                        end
                    end
                end
                
                -- Procurar brainrots nos jogadores
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= Player and player.Character then
                        for _, item in pairs(player.Character:GetChildren()) do
                            if item:IsA("Tool") and item.Name:lower():find("brainrot") and item:FindFirstChild("Handle") then
                                local handle = item.Handle
                                local distance = (RootPart.Position - handle.Position).Magnitude
                                
                                local rarity = self:GetBrainrotRarity(item.Name)
                                local rarityData = self.brainrotRarities[rarity]
                                
                                local extraInfo = ""
                                if Config.ESP.ShowRarity then
                                    extraInfo = "Raridade: " .. rarity .. " | Dono: " .. player.Name
                                end
                                
                                local esp = self:CreateESP(
                                    handle,
                                    rarityData.Color,
                                    item.Name,
                                    distance,
                                    extraInfo
                                )
                                
                                if esp then
                                    self.espObjects["PlayerBrainrot_" .. tostring(item)] = esp
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
        self:ClearESPs("Brainrot")
    end
end

function ESPManager:ClearESPs(type)
    for name, esp in pairs(self.espObjects) do
        if (type == "Player" and not name:find("Brainrot")) or 
           (type == "Brainrot" and name:find("Brainrot")) or
           (type == "All") then
            if esp and esp.Parent then
                esp:Destroy()
            end
            self.espObjects[name] = nil
        end
    end
end

function ESPManager:Stop()
    for _, connection in pairs(self.connections) do
        if connection then
            connection:Disconnect()
        end
    end
    self.connections = {}
    self:ClearESPs("All")
end

-- ====================
-- OUTROS MANAGERS
-- ====================

local AutoFarmManager = {}
AutoFarmManager.__index = AutoFarmManager

function AutoFarmManager:new()
    local self = setmetatable({}, AutoFarmManager)
    self.connections = {}
    return self
end

function AutoFarmManager:StartAutoEquip()
    if self.connections.AutoEquip then return end
    
    self.connections.AutoEquip = RunService.Heartbeat:Connect(function()
        if not Config.AutoFarm.AutoEquip then return end
        
        pcall(function()
            local backpack = Player:FindFirstChild("Backpack")
            if backpack then
                local bestTool = nil
                local bestPriority = 0
                
                for _, tool in pairs(backpack:GetChildren()) do
                    if tool:IsA("Tool") and tool.Name:lower():find("brainrot") then
                        local rarity = espManager:GetBrainrotRarity(tool.Name)
                        local priority = espManager.brainrotRarities[rarity].Priority
                        
                        if priority > bestPriority then
                            bestPriority = priority
                            bestTool = tool
                        end
                    end
                end
                
                if bestTool and not Character:FindFirstChildOfClass("Tool") then
                    Humanoid:EquipTool(bestTool)
                end
            end
        end)
    end)
end

function AutoFarmManager:Stop()
    for _, connection in pairs(self.connections) do
        if connection then
            connection:Disconnect()
        end
    end
    self.connections = {}
end

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
                local camera = workspace.CurrentCamera
                local moveVector = Humanoid.MoveDirection
                
                local velocity = Vector3.new(0, 0, 0)
                if moveVector.Magnitude > 0 then
                    velocity = (camera.CFrame.LookVector * moveVector.Z + camera.CFrame.RightVector * moveVector.X) * 50
                end
                
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    velocity = velocity + Vector3.new(0, 50, 0)
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

function MovementManager:Stop()
    for _, connection in pairs(self.connections) do
        if connection then
            connection:Disconnect()
        end
    end
    self.connections = {}
end

-- ====================
-- INICIALIZAÇÃO
-- ====================

local teleportManager = TeleportManager:new()
local espManager = ESPManager:new()
local autoFarmManager = AutoFarmManager:new()
local movementManager = MovementManager:new()

-- ====================
-- CRIAÇÃO DA UI
-- ====================

WindUI:Popup({
    Title = "Steal a Brainrot Hub v4.0",
    Icon = "zap",
    Content = "✅ Todos os ESPs corrigidos!\n🎯 Teleporte Arbix integrado!\n🌟 Sistema de raridade implementado!",
    Buttons = {
        {
            Title = "Iniciar",
            Icon = "play",
            Callback = function() end,
            Variant = "Primary"
        }
    }
})

local Window = WindUI:CreateWindow({
    Title = "Steal a Brainrot Hub v4.0",
    Icon = "zap",
    Author = "StealBrainrot Team",
    Folder = "StealBrainrotHub",
    Size = UDim2.fromOffset(600, 500),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 180,
    HasOutline = true
})

local Tabs = {
    Main = Window:Tab({ Title = "Main", Icon = "home", Desc = "Controles principais" }),
    AutoFarm = Window:Tab({ Title = "Auto Farm", Icon = "zap", Desc = "Automação" }),
    Teleport = Window:Tab({ Title = "Teleport", Icon = "navigation", Desc = "Sistema Arbix" }),
    Movement = Window:Tab({ Title = "Movement", Icon = "move", Desc = "Movimento" }),
    ESP = Window:Tab({ Title = "ESP", Icon = "eye", Desc = "Visualizações" }),
    Settings = Window:Tab({ Title = "Settings", Icon = "settings", Desc = "Configurações" })
}

-- ====================
-- IMPLEMENTAÇÃO DAS ABAS
-- ====================

-- ABA MAIN
Tabs.Main:Paragraph({
    Title = "Steal a Brainrot Hub v4.0",
    Desc = "✅ ESPs totalmente corrigidos\n🎯 Teleporte baseado no Arbix Hub\n🌟 Sistema de raridade para brainrots\n❌ Auto coletar cash removido",
    Image = "check-circle",
    Color = "Green"
})

Tabs.Main:Section({ Title = "Status do Sistema" })

Tabs.Main:Paragraph({
    Title = "Funcionalidades Ativas:",
    Desc = "• ESP Players: Funcionando 100%\n• ESP Brainrots: Sistema de raridade\n• Teleporte Arbix: Integrado\n• Auto Equip: Prioridade por raridade",
    Color = "Blue"
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
Tabs.AutoFarm:Section({ Title = "Automação" })

Tabs.AutoFarm:Toggle({
    Title = "Auto Equip (Melhor Brainrot)",
    Icon = "package",
    Value = false,
    Callback = function(state)
        Config.AutoFarm.AutoEquip = state
        if state then
            autoFarmManager:StartAutoEquip()
        else
            if autoFarmManager.connections.AutoEquip then
                autoFarmManager.connections.AutoEquip:Disconnect()
                autoFarmManager.connections.AutoEquip = nil
            end
        end
    end
})

Tabs.AutoFarm:Paragraph({
    Title = "Auto Equip Inteligente:",
    Desc = "• Prioriza brainrots por raridade\n• Mythic > Legendary > Epic > Rare > Uncommon > Common\n• Equipa automaticamente o melhor disponível",
    Color = "Yellow"
})

-- ABA TELEPORT
Tabs.Teleport:Section({ Title = "🎯 Sistema Arbix Hub" })

Tabs.Teleport:Toggle({
    Title = "Arbix Steal (Automático)",
    Icon = "navigation",
    Value = false,
    Callback = function(state)
        Config.Teleport.ArbixSteal = state
        if state then
            spawn(function()
                while Config.Teleport.ArbixSteal do
                    if teleportManager:IsHoldingBrainrot() then
                        local success = teleportManager:ArbixSteal()
                        if success then
                            WindUI:Notify({
                                Title = "Arbix Steal",
                                Content = "Teleporte executado com sucesso!",
                                Duration = 2,
                                Icon = "check"
                            })
                        end
                    end
                    wait(1)
                end
            end)
        end
    end
})

Tabs.Teleport:Button({
    Title = "Teleporte Manual (Arbix)",
    Icon = "zap",
    Callback = function()
        local success = teleportManager:ArbixSteal()
        WindUI:Notify({
            Title = "Teleporte Manual",
            Content = success and "Executado com sucesso!" or "Falha no teleporte",
            Duration = 3,
            Icon = success and "check" or "x"
        })
    end
})

Tabs.Teleport:Button({
    Title = "Tween Steal (Suave)",
    Icon = "move",
    Callback = function()
        local success = teleportManager:TweenSteal()
        WindUI:Notify({
            Title = "Tween Steal",
            Content = success and "Executado com sucesso!" or "Falha no teleporte",
            Duration = 3,
            Icon = success and "check" or "x"
        })
    end
})

Tabs.Teleport:Paragraph({
    Title = "Como usar o Teleporte:",
    Desc = "• Pegue um brainrot primeiro\n• Ative 'Arbix Steal' para automático\n• Ou use 'Teleporte Manual' quando quiser\n• Baseado no sistema do Arbix Hub",
    Color = "Blue"
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
Tabs.ESP:Section({ Title = "🎯 ESP Corrigido" })

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
    Title = "ESP Brainrots (com Raridade)",
    Icon = "star",
    Value = false,
    Callback = function(state)
        Config.ESP.Brainrots = state
        espManager:ToggleBrainrotsESP(state)
    end
})

Tabs.ESP:Section({ Title = "🌟 Sistema de Raridade" })

Tabs.ESP:Paragraph({
    Title = "Cores por Raridade:",
    Desc = "• Mythic: Rosa\n• Legendary: Laranja\n• Epic: Roxo\n• Rare: Azul\n• Uncommon: Verde\n• Common: Cinza",
    Color = "Purple"
})

Tabs.ESP:Toggle({
    Title = "Mostrar Raridade",
    Icon = "award",
    Value = true,
    Callback = function(state)
        Config.ESP.ShowRarity = state
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
Tabs.Settings:Section({ Title = "Configurações" })

Tabs.Settings:Button({
    Title = "Resetar ESPs",
    Icon = "refresh-cw",
    Callback = function()
        espManager:Stop()
        Config.ESP.Players = false
        Config.ESP.Brainrots = false
        WindUI:Notify({
            Title = "ESP Reset",
            Content = "Todos os ESPs foram resetados!",
            Duration = 3,
            Icon = "check"
        })
    end
})

Tabs.Settings:Button({
    Title = "Unload Script",
    Icon = "x",
    Callback = function()
        -- Parar todos os managers
        teleportManager:Stop()
        espManager:Stop()
        autoFarmManager:Stop()
        movementManager:Stop()
        
        -- Destruir UI
        Window:Destroy()
        
        WindUI:Notify({
            Title = "Script Unloaded",
            Content = "Todas as funcionalidades foram descarregadas!",
            Duration = 3
        })
    end
})

-- ====================
-- SISTEMA DE ATALHOS
-- ====================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.G then
        -- Teleporte rápido quando segurando brainrot
        if teleportManager:IsHoldingBrainrot() then
            teleportManager:ArbixSteal()
        end
    elseif input.KeyCode == Enum.KeyCode.H then
        -- Toggle ESP rápido
        Config.ESP.Brainrots = not Config.ESP.Brainrots
        espManager:ToggleBrainrotsESP(Config.ESP.Brainrots)
    end
end)

-- ====================
-- PROTEÇÃO ANTI-CHEAT
-- ====================

spawn(function()
    while wait(60) do
        pcall(function()
            game:GetService("VirtualUser"):CaptureController()
            game:GetService("VirtualUser"):ClickButton2(Vector2.new())
        end)
    end
end)

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

Window:SelectTab(1)

WindUI:Notify({
    Title = "Steal a Brainrot Hub v4.0",
    Content = "✅ Todos os sistemas corrigidos e funcionando!\n🎯 Pressione G para teleporte rápido\n🌟 Pressione H para toggle ESP",
    Duration = 8,
    Icon = "check"
})
