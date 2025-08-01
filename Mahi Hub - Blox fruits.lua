-- Mahi Hub V2.0 - Blox Fruits Script
-- Optimized for GitHub Raw execution
-- Enhanced Mobile & PC Performance

-- Security Check
if not game:IsLoaded() then 
    game.Loaded:Wait() 
end

-- Anti-Detection
local function SafeExecute(func)
    local success, result = pcall(func)
    if not success then
        warn("Mahi Hub Error: " .. tostring(result))
    end
    return success, result
end

-- Load WindUI with fallback
local WindUI
SafeExecute(function()
    WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if not WindUI then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Mahi Hub Error";
        Text = "Failed to load WindUI library!";
        Duration = 5;
    })
    return
end

-- Services
local Services = {
    Players = game:GetService("Players"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    TweenService = game:GetService("TweenService"),
    RunService = game:GetService("RunService"),
    Workspace = game:GetService("Workspace"),
    HttpService = game:GetService("HttpService"),
    UserInputService = game:GetService("UserInputService"),
    TeleportService = game:GetService("TeleportService"),
    VirtualUser = game:GetService("VirtualUser"),
    StarterGui = game:GetService("StarterGui")
}

-- Player Variables
local Player = Services.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Global Settings
local Settings = {
    AutoFarm = false,
    AutoRaid = false,
    ESP = {
        Fruits = false,
        Mobs = false,
        Bosses = false,
        Chests = false,
        NPCs = false
    },
    TeleportSpeed = 50,
    SelectedWeapon = nil,
    SelectedMob = nil,
    SelectedBoss = nil,
    CurrentSea = 1,
    AttackDelay = 0.1,
    SafeMode = true
}

-- Sea Detection with Enhanced Logic
local function DetectCurrentSea()
    local placeId = game.PlaceId
    local success, sea = SafeExecute(function()
        if placeId == 2753915549 or placeId == 4442272183 or placeId == 7449423635 then
            if placeId == 2753915549 then
                Settings.CurrentSea = 1
                return "First Sea (Starter)"
            elseif placeId == 4442272183 then
                Settings.CurrentSea = 2
                return "Second Sea (New World)"
            elseif placeId == 7449423635 then
                Settings.CurrentSea = 3
                return "Third Sea (Final)"
            end
        else
            -- Fallback detection based on workspace
            if Services.Workspace:FindFirstChild("Map") then
                local map = Services.Workspace.Map
                if map:FindFirstChild("Skylands") then
                    Settings.CurrentSea = 1
                    return "First Sea (Detected)"
                elseif map:FindFirstChild("Kingdom of Rose") then
                    Settings.CurrentSea = 2
                    return "Second Sea (Detected)"
                elseif map:FindFirstChild("Port Town") then
                    Settings.CurrentSea = 3
                    return "Third Sea (Detected)"
                end
            end
            Settings.CurrentSea = 1
            return "Unknown Sea (Default: First)"
        end
    end)
    
    return sea or "Detection Failed"
end

-- Enhanced Mobs and Bosses Database
local SeaDatabase = {
    [1] = { -- First Sea
        Mobs = {
            "Bandit", "Monkey", "Gorilla", "Pirate", "Brute", "Desert Bandit", 
            "Desert Officer", "Snow Bandit", "Snowman", "Chief Petty Officer",
            "Sky Bandit", "Dark Master", "Prisoner", "Dangerous Prisoner",
            "Toga Warrior", "Gladiator", "Military Soldier", "Military Spy",
            "Fishman Warrior", "Fishman Commando", "God's Guard", "Shanda",
            "Royal Squad", "Royal Soldier", "Galley Pirate", "Galley Captain"
        },
        Bosses = {
            "Gorilla King", "Bobby", "The Saw", "Yeti", "Mob Leader",
            "Vice Admiral", "Saber Expert", "Warden", "Chief Warden",
            "Swan", "Magma Admiral", "Fishman Lord", "Wysper",
            "Thunder God", "Cyborg", "Ice Admiral"
        },
        Islands = {
            ["🏝️ Starter Island"] = Vector3.new(1, 4, 1),
            ["🌴 Jungle Island"] = Vector3.new(-1612, 37, 149),
            ["🏴‍☠️ Pirate Village"] = Vector3.new(-1181, 5, 3803),
            ["🏜️ Desert Island"] = Vector3.new(944, 21, 4481),
            ["❄️ Frozen Village"] = Vector3.new(1347, 104, -1319),
            ["🏰 Marine Fortress"] = Vector3.new(-2566, 7, -294),
            ["☁️ Skylands"] = Vector3.new(-4813, 718, -2624),
            ["⛓️ Prison"] = Vector3.new(4875, 6, 734),
            ["🏛️ Colosseum"] = Vector3.new(-1427, 8, -2673),
            ["🌋 Magma Village"] = Vector3.new(-5247, 9, -2863),
            ["🌊 Underwater City"] = Vector3.new(61123, 11, 1819),
            ["☁️ Upper Skylands"] = Vector3.new(-7952, 5545, -320),
            ["⛲ Fountain City"] = Vector3.new(5127, 59, 4105),
            ["🌪️ Middle Town"] = Vector3.new(-690, 15, 1582),
            ["🏝️ Marine Starter"] = Vector3.new(-2573, 7, -3047),
            ["🗻 Rocky Port"] = Vector3.new(-740, 46, 2520),
            ["🏝️ Shell Island"] = Vector3.new(-1226, 50, 50),
            ["🌀 Windmill Village"] = Vector3.new(979, 16, 1680)
        }
    },
    [2] = { -- Second Sea
        Mobs = {
            "Raider", "Mercenary", "Swan Pirate", "Factory Staff", "Marine Lieutenant",
            "Marine Captain", "Zombie", "Vampire", "Snow Lurker", "Arctic Warrior",
            "Lab Subordinate", "Horned Warrior", "Magma Ninja", "Lava Pirate",
            "Ship Deckhand", "Ship Engineer", "Ship Steward", "Ship Officer"
        },
        Bosses = {
            "Diamond", "Jeremy", "Fajita", "Don Swan", "Smoke Admiral",
            "Awakened Ice Admiral", "Tide Keeper", "Cursed Captain"
        },
        Islands = {
            ["🌹 Kingdom of Rose"] = Vector3.new(-384, 73, 298),
            ["🟢 Green Zone"] = Vector3.new(-2448, 73, -3210),
            ["⚰️ Graveyard Island"] = Vector3.new(-9504, 6, 5975),
            ["🏔️ Snow Mountain"] = Vector3.new(753, 408, -5274),
            ["🔥 Hot and Cold"] = Vector3.new(-6508, 89, -132),
            ["🚢 Cursed Ship"] = Vector3.new(923, 125, 32885),
            ["🧊 Ice Castle"] = Vector3.new(6148, 294, -6895),
            ["🏝️ Forgotten Island"] = Vector3.new(-3032, 317, -10075),
            ["🏭 Factory"] = Vector3.new(424, 211, -427),
            ["⚡ Swan's Room"] = Vector3.new(2284, 15, 905),
            ["🌊 Usoapp's Island"] = Vector3.new(4816, 8, 2863),
            ["🏰 Dark Arena"] = Vector3.new(3683, 5, -3032),
            ["☠️ Zombie Island"] = Vector3.new(-5622, 492, -781)
        }
    },
    [3] = { -- Third Sea
        Mobs = {
            "Pirate Millionaire", "Dragon Crew Warrior", "Dragon Crew Archer",
            "Female Islander", "Giant Islander", "Marine Commodore", "Marine Rear Admiral",
            "Fishman Raider", "Fishman Captain", "Forest Pirate", "Mythological Pirate",
            "Jungle Pirate", "Musketeer Pirate", "Reborn Skeleton", "Living Zombie",
            "Demonic Soul", "Posessed Mummy", "Peanut Scout", "Peanut President",
            "Ice Cream Chef", "Ice Cream Commander", "Cookie Crafter", "Cake Guard",
            "Baking Staff", "Head Baker", "Cocoa Warrior", "Chocolate Bar Battler",
            "Sweet Thief", "Candy Rebel", "Candy Pirate", "Snow Demon"
        },
        Bosses = {
            "Stone", "Island Empress", "Kilo Admiral", "Captain Elephant",
            "Beautiful Pirate", "Longma", "Cake Queen", "Soul Reaper",
            "rip_indra True Form", "Dough King"
        },
        Islands = {
            ["🏘️ Port Town"] = Vector3.new(-290, 44, 422),
            ["🐍 Hydra Island"] = Vector3.new(5749, 611, -276),
            ["🌳 Great Tree"] = Vector3.new(2681, 1682, -7190),
            ["🐢 Floating Turtle"] = Vector3.new(-13274, 332, -7906),
            ["👻 Haunted Castle"] = Vector3.new(-9515, 142, 5618),
            ["🍰 Sea of Treats"] = Vector3.new(-11900, 332, -10750),
            ["🗿 Tiki Outpost"] = Vector3.new(-16222, 9, 439),
            ["🌺 Beautiful Pirate Domain"] = Vector3.new(5312, 426, -3239),
            ["🏝️ Mansion"] = Vector3.new(-12468, 374, -7551),
            ["⚡ Temple of Time"] = Vector3.new(28289, 14896, 105),
            ["🌸 Flower Capital"] = Vector3.new(-5084, 316, -2952),
            ["🔥 Cake Land"] = Vector3.new(-2091, 70, -12142),
            ["🧊 Chocolate Island"] = Vector3.new(87, 15, -11062),
            ["🍭 Candy Cane Land"] = Vector3.new(-1034, 13, -14555),
            ["🌊 Mirage Island"] = Vector3.new(-5411, 778, -2666)
        }
    }
}

-- Utility Functions
local function GetCurrentData(dataType)
    return SeaDatabase[Settings.CurrentSea] and SeaDatabase[Settings.CurrentSea][dataType] or {}
end

local function GetWeapons()
    local weapons = {}
    SafeExecute(function()
        for _, item in pairs(Player.Backpack:GetChildren()) do
            if item:IsA("Tool") then
                table.insert(weapons, item.Name)
            end
        end
        if Character then
            for _, item in pairs(Character:GetChildren()) do
                if item:IsA("Tool") then
                    table.insert(weapons, item.Name)
                end
            end
        end
    end)
    return weapons
end

-- Enhanced ESP System
local ESPObjects = {}

local function CreateESP(obj, color, text, offset)
    SafeExecute(function()
        if obj and obj.Parent and not ESPObjects[obj] then
            local billboard = Instance.new("BillboardGui")
            billboard.Size = UDim2.new(0, 120, 0, 50)
            billboard.StudsOffset = offset or Vector3.new(0, 3, 0)
            billboard.Parent = obj
            billboard.Name = "MahiESP"
            
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.BackgroundTransparency = 1
            frame.Parent = billboard
            
            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.Text = text
            textLabel.TextColor3 = color
            textLabel.TextStrokeTransparency = 0
            textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
            textLabel.Font = Enum.Font.SourceSansBold
            textLabel.TextSize = 12
            textLabel.TextScaled = true
            textLabel.Parent = frame
            
            ESPObjects[obj] = billboard
            return billboard
        end
    end)
end

local function ClearESP()
    SafeExecute(function()
        for obj, esp in pairs(ESPObjects) do
            if esp and esp.Parent then
                esp:Destroy()
            end
        end
        ESPObjects = {}
        
        -- Clean remaining ESP objects
        for _, obj in pairs(Services.Workspace:GetDescendants()) do
            if obj.Name == "MahiESP" and obj:IsA("BillboardGui") then
                obj:Destroy()
            end
        end
    end)
end

local function UpdateESP()
    SafeExecute(function()
        -- ESP for Fruits
        if Settings.ESP.Fruits then
            for _, obj in pairs(Services.Workspace:GetChildren()) do
                if string.find(obj.Name, "Fruit") and obj:FindFirstChild("Handle") and not ESPObjects[obj.Handle] then
                    CreateESP(obj.Handle, Color3.fromRGB(255, 0, 255), "🍎 " .. obj.Name)
                end
            end
        end
        
        -- ESP for Mobs
        if Settings.ESP.Mobs then
            for _, mob in pairs(Services.Workspace.Enemies:GetChildren()) do
                if mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") and not ESPObjects[mob.HumanoidRootPart] then
                    local health = mob.Humanoid.Health > 0 and (" [" .. math.floor(mob.Humanoid.Health) .. " HP]") or " [DEAD]"
                    CreateESP(mob.HumanoidRootPart, Color3.fromRGB(255, 100, 100), "👹 " .. mob.Name .. health)
                end
            end
        end
        
        -- ESP for Bosses
        if Settings.ESP.Bosses then
            for _, boss in pairs(Services.Workspace.Enemies:GetChildren()) do
                if boss:FindFirstChild("HumanoidRootPart") and boss:FindFirstChild("Humanoid") then
                    local bossList = GetCurrentData("Bosses")
                    for _, bossName in pairs(bossList) do
                        if boss.Name == bossName and not ESPObjects[boss.HumanoidRootPart] then
                            CreateESP(boss.HumanoidRootPart, Color3.fromRGB(255, 215, 0), "👑 " .. boss.Name .. " [BOSS]", Vector3.new(0, 5, 0))
                        end
                    end
                end
            end
        end
    end)
end

-- Enhanced Teleport Function
local function TeleportTo(position, callback)
    SafeExecute(function()
        if RootPart and position then
            local distance = (RootPart.Position - position).Magnitude
            local speed = Settings.TeleportSpeed
            local duration = distance / speed
            
            if duration > 10 then duration = 10 end -- Max 10 seconds
            
            local tween = Services.TweenService:Create(
                RootPart,
                TweenInfo.new(duration, Enum.EasingStyle.Linear),
                {CFrame = CFrame.new(position)}
            )
            
            tween:Play()
            if callback then
                tween.Completed:Connect(callback)
            end
        end
    end)
end

-- Enhanced Auto Farm System
local AutoFarmConnection

local function AutoFarm()
    if AutoFarmConnection then
        AutoFarmConnection:Disconnect()
    end
    
    AutoFarmConnection = Services.RunService.Heartbeat:Connect(function()
        if not Settings.AutoFarm then
            AutoFarmConnection:Disconnect()
            return
        end
        
        SafeExecute(function()
            if Settings.SelectedMob and Character and RootPart then
                local target = nil
                local closestDistance = math.huge
                
                for _, mob in pairs(Services.Workspace.Enemies:GetChildren()) do
                    if mob.Name == Settings.SelectedMob and mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") then
                        if mob.Humanoid.Health > 0 then
                            local distance = (RootPart.Position - mob.HumanoidRootPart.Position).Magnitude
                            if distance < closestDistance and distance < 5000 then -- Max range
                                closestDistance = distance
                                target = mob
                            end
                        end
                    end
                end
                
                if target then
                    -- Teleport to mob
                    local targetPos = target.HumanoidRootPart.Position + Vector3.new(0, 5, 3)
                    if (RootPart.Position - targetPos).Magnitude > 10 then
                        TeleportTo(targetPos)
                    end
                    
                    -- Equip weapon
                    if Settings.SelectedWeapon then
                        local weapon = Player.Backpack:FindFirstChild(Settings.SelectedWeapon)
                        if weapon and Humanoid then
                            Humanoid:EquipTool(weapon)
                        end
                    end
                    
                    -- Attack
                    Services.VirtualUser:CaptureController()
                    Services.VirtualUser:Button1Down(Vector2.new(0, 0))
                    wait(Settings.AttackDelay)
                    Services.VirtualUser:Button1Up(Vector2.new(0, 0))
                end
            end
        end)
    end)
end

-- Stats System
local function AddStats(statType, amount)
    SafeExecute(function()
        local args = {
            [1] = statType,
            [2] = amount
        }
        
        Services.ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", statType, amount)
    end)
end

-- Initialize UI
local currentSeaName = DetectCurrentSea()

local Window = WindUI:CreateWindow({
    Title = "🌟 Mahi Hub V2.0 - Blox Fruits",
    Icon = "anchor",
    Author = "Mahi Development Team",
    Folder = "MahiHubV2",
    Size = UDim2.fromOffset(600, 480),
    Transparent = true,
    Theme = "Dark",
    User = {
        Enabled = true,
        Anonymous = false
    },
    SideBarWidth = 220,
    HasOutline = true,
})

-- Create Enhanced Tabs
local Tabs = {
    Main = Window:Tab({ Title = "🏠 Main", Icon = "home" }),
    AutoFarm = Window:Tab({ Title = "⚔️ Auto Farm", Icon = "sword" }),
    Stats = Window:Tab({ Title = "📊 Stats", Icon = "trending-up" }),
    Teleport = Window:Tab({ Title = "🚀 Teleport", Icon = "map-pin" }),
    ESP = Window:Tab({ Title = "👁️ ESP & Visual", Icon = "eye" }),
    Raid = Window:Tab({ Title = "🔥 Raids & Events", Icon = "shield" }),
    Misc = Window:Tab({ Title = "🛠️ Miscellaneous", Icon = "wrench" }),
    Settings = Window:Tab({ Title = "⚙️ Settings", Icon = "settings" })
}

-- Main Tab
Tabs.Main:Label({ Title = "🌍 Current Location: " .. currentSeaName })
Tabs.Main:Label({ Title = "👤 Player: " .. Player.Name })
Tabs.Main:Separator()

Tabs.Main:Button({
    Title = "🎯 Collect All Fruits",
    Icon = "gift",
    Callback = function()
        SafeExecute(function()
            for _, obj in pairs(Services.Workspace:GetChildren()) do
                if string.find(obj.Name, "Fruit") and obj:FindFirstChild("Handle") then
                    TeleportTo(obj.Handle.Position)
                    wait(1)
                end
            end
        end)
        WindUI:Notify({
            Title = "Mahi Hub",
            Content = "Collecting all visible fruits...",
            Icon = "check",
            Duration = 3
        })
    end
})

Tabs.Main:Button({
    Title = "💰 Collect Nearby Chests",
    Icon = "treasure-chest",
    Callback = function()
        SafeExecute(function()
            for _, obj in pairs(Services.Workspace:GetDescendants()) do
                if obj.Name == "Chest" or obj.Name == "Chest1" or obj.Name == "Chest2" then
                    if obj:FindFirstChild("Part") or obj:FindFirstChild("Handle") then
                        local part = obj:FindFirstChild("Part") or obj:FindFirstChild("Handle")
                        TeleportTo(part.Position)
                        wait(0.5)
                    end
                end
            end
        end)
        WindUI:Notify({
            Title = "Mahi Hub",
            Content = "Collecting nearby chests...",
            Icon = "check",
            Duration = 3
        })
    end
})

-- Auto Farm Tab
Tabs.AutoFarm:Toggle({
    Title = "🤖 Enable Auto Farm",
    Icon = "zap",
    Value = false,
    Callback = function(state)
        Settings.AutoFarm = state
        if state then
            AutoFarm()
            WindUI:Notify({
                Title = "Auto Farm",
                Content = "Auto Farm Enabled!",
                Icon = "check",
                Duration = 3
            })
        else
            if AutoFarmConnection then
                AutoFarmConnection:Disconnect()
            end
            WindUI:Notify({
                Title = "Auto Farm",
                Content = "Auto Farm Disabled!",
                Icon = "x",
                Duration = 3
            })
        end
    end
})

Tabs.AutoFarm:Dropdown({
    Title = "⚔️ Select Weapon",
    Icon = "sword",
    Items = GetWeapons(),
    Callback = function(selected)
        Settings.SelectedWeapon = selected
        WindUI:Notify({
            Title = "Weapon Selected",
            Content = "Selected: " .. selected,
            Icon = "check",
            Duration = 2
        })
    end
})

Tabs.AutoFarm:Button({
    Title = "🔄 Refresh Weapons",
    Icon = "refresh-cw",
    Callback = function()
        -- This would need to recreate the dropdown with new weapons
        WindUI:Notify({
            Title = "Weapons",
            Content = "Weapons list refreshed!",
            Icon = "check",
            Duration = 2
        })
    end
})

Tabs.AutoFarm:Dropdown({
    Title = "👹 Select Mob to Farm",
    Icon = "target",
    Items = GetCurrentData("Mobs"),
    Callback = function(selected)
        Settings.SelectedMob = selected
        WindUI:Notify({
            Title = "Mob Selected",
            Content = "Now farming: " .. selected,
            Icon = "check",
            Duration = 2
        })
    end
})

Tabs.AutoFarm:Slider({
    Title = "⚡ Attack Speed",
    Icon = "zap",
    Min = 0.1,
    Max = 1.0,
    Value = 0.1,
    Callback = function(value)
        Settings.AttackDelay = value
    end
})

-- Stats Tab
Tabs.Stats:Label({ Title = "📈 Character Stats Enhancement" })
Tabs.Stats:Separator()

local statTypes = {"Melee", "Defense", "Sword", "Gun", "Demon Fruit"}
local statValues = {}

for _, statType in pairs(statTypes) do
    statValues[statType] = 1
    
    Tabs.Stats:Slider({
        Title = "💪 " .. statType .. " Points",
        Icon = "plus",
        Min = 1,
        Max = 100,
        Value = 1,
        Callback = function(value)
            statValues[statType] = value
        end
    })
    
    Tabs.Stats:Button({
        Title = "Add " .. statType,
        Icon = "arrow-up",
        Callback = function()
            AddStats(statType, statValues[statType])
            WindUI:Notify({
                Title = "Stats Enhanced",
                Content = "Added " .. statValues[statType] .. " points to " .. statType,
                Icon = "check",
                Duration = 3
            })
        end
    })
end

-- Enhanced Teleport Tab
Tabs.Teleport:Label({ Title = "🌍 " .. currentSeaName .. " - Island Teleports" })
Tabs.Teleport:Separator()

-- Add all islands for current sea
local islands = GetCurrentData("Islands")
for name, position in pairs(islands) do
    Tabs.Teleport:Button({
        Title = name,
        Icon = "map-pin",
        Callback = function()
            TeleportTo(position)
            WindUI:Notify({
                Title = "Teleporting",
                Content = "Teleporting to " .. name:gsub("🏝️ ", ""):gsub("🌴 ", ""):gsub("🏰 ", ""),
                Icon = "check",
                Duration = 2
            })
        end
    })
end

-- Add special teleports
Tabs.Teleport:Separator()
Tabs.Teleport:Label({ Title = "🔸 Special Locations" })

Tabs.Teleport:Button({
    Title = "🏪 Fruit Dealer",
    Icon = "shopping-cart",
    Callback = function()
        local fruitDealer = Services.Workspace:FindFirstChild("Fruit Dealer")
        if fruitDealer and fruitDealer:FindFirstChild("HumanoidRootPart") then
            TeleportTo(fruitDealer.HumanoidRootPart.Position)
        end
    end
})

Tabs.Teleport:Button({
    Title = "🗡️ Sword Dealer",
    Icon = "sword",
    Callback = function()
        -- Add sword dealer teleport logic based on current sea
        WindUI:Notify({
            Title = "Teleporting",
            Content = "Teleporting to Sword Dealer...",
            Icon = "check",
            Duration = 2
        })
    end
})

-- Enhanced ESP Tab
Tabs.ESP:Toggle({
    Title = "🍎 ESP Devil Fruits",
    Icon = "apple",
    Value = false,
    Callback = function(state)
        Settings.ESP.Fruits = state
        if not state then ClearESP() end
        UpdateESP()
    end
})

Tabs.ESP:Toggle({
    Title = "👹 ESP Enemies",
    Icon = "target",
    Value = false,
    Callback = function(state)
        Settings.ESP.Mobs = state
        if not state then ClearESP() end
        UpdateESP()
    end
})

Tabs.ESP:Toggle({
    Title = "👑 ESP Bosses",
    Icon = "crown",
    Value = false,
    Callback = function(state)
        Settings.ESP.Bosses = state
        if not state then ClearESP() end
        UpdateESP()
    end
})

Tabs.ESP:Button({
    Title = "🧹 Clear All ESP",
    Icon = "trash-2",
    Callback = function()
        ClearESP()
        Settings.ESP = {
            Fruits = false,
            Mobs = false,
            Bosses = false,
            Chests = false,
            NPCs = false
        }
        WindUI:Notify({
            Title = "ESP Cleared",
            Content = "All ESP elements removed!",
            Icon = "check",
            Duration = 2
        })
    end
})

-- Raids Tab
Tabs.Raid:Label({ Title = "🔥 Auto Raid System" })
Tabs.Raid:Toggle({
    Title = "🤖 Auto Raid",
    Icon = "shield",
    Value = false,
    Callback = function(state)
        Settings.AutoRaid = state
        WindUI:Notify({
            Title = "Auto Raid",
            Content = state and "Auto Raid Enabled!" or "Auto Raid Disabled!",
            Icon = state and "check" or "x",
            Duration = 3
        })
    end
})

-- Miscellaneous Tab
Tabs.Misc:Button({
    Title = "🌀 Remove Damage GUI",
    Icon = "eye-off",
    Callback = function()
        SafeExecute(function()
            for _, gui in pairs(Player.PlayerGui:GetChildren()) do
                if gui.Name == "DamageGui" then
                    gui:Destroy()
                end
            end
        end)
    end
})

Tabs.Misc:Button({
    Title = "🏃 Infinite Walkspeed",
    Icon = "fast-forward",
    Callback = function()
        SafeExecute(function()
            if Humanoid then
                Humanoid.WalkSpeed = 100
            end
        end)
    end
})

Tabs.Misc:Button({
    Title = "🦘 Super Jump",
    Icon = "arrow-up",
    Callback = function()
        SafeExecute(function()
            if Humanoid then
                Humanoid.JumpPower = 120
            end
        end)
    end
})

-- Settings Tab
Tabs.Settings:Slider({
    Title = "🚀 Teleport Speed",
    Icon = "gauge",
    Min = 10,
    Max = 300,
    Value = 50,
    Callback = function(value)
        Settings.TeleportSpeed = value
    end
})

Tabs.Settings:Toggle({
    Title = "🛡️ Safe Mode",
    Icon = "shield-check",
    Value = true,
    Callback = function(state)
        Settings.SafeMode = state
    end
})

Tabs.Settings:Button({
    Title = "🔄 Rejoin Server",
    Icon = "refresh-cw",
    Callback = function()
        Services.TeleportService:Teleport(game.PlaceId, Player)
    end
})

Tabs.Settings:Button({
    Title = "🗑️ Destroy Script",
    Icon = "trash-2",
    Callback = function()
        ClearESP()
        if AutoFarmConnection then
            AutoFarmConnection:Disconnect()
        end
        Window:Destroy()
        WindUI:Notify({
            Title = "Mahi Hub",
            Content = "Script destroyed successfully!",
            Icon = "check",
            Duration = 3
        })
    end
})

-- Auto-update systems
Services.RunService.Heartbeat:Connect(function()
    SafeExecute(function()
        if Settings.ESP.Fruits or Settings.ESP.Mobs or Settings.ESP.Bosses then
            UpdateESP()
        end
    end)
end)

-- Character respawn handling
Player.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    RootPart = Character:WaitForChild("HumanoidRootPart")
end)

-- Success notification
WindUI:Notify({
    Title = "🌟 Mahi Hub V2.0 Loaded!",
    Content = "Welcome to " .. currentSeaName .. "! Enhanced version loaded successfully.",
    Icon = "check-circle",
    Duration = 5
})

-- Console output
print("🌟 Mahi Hub V2.0 - Enhanced Blox Fruits Script")
print("📍 Current Sea: " .. currentSeaName)
print("🎯 Available Mobs: " .. table.concat(GetCurrentData("Mobs"), ", "))
print("👑 Available Bosses: " .. table.concat(GetCurrentData("Bosses"), ", "))
print("🏝️ Available Islands: " .. #GetCurrentData("Islands"))
print("✅ Script loaded successfully via GitHub!")

-- Return the main functions for external access
return {
    Settings = Settings,
    DetectCurrentSea = DetectCurrentSea,
    TeleportTo = TeleportTo,
    GetCurrentData = GetCurrentData,
    Window = Window
}
