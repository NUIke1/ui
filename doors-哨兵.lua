local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/KingScriptAE/No-sirve-nada./refs/heads/main/main.lua"))()

WindUI:Localization({
    Enabled = true,
    Prefix = "loc:",
    DefaultLanguage = "en",
    Translations = {
        ["en"] = {
            ["WINDUI_EXAMPLE"] = "WindUI 示例",
            ["WELCOME"] = "Sentinel-Doors",
            ["LIB_DESC"] = "1034603242有任何问题请前往qq群反馈要艾特管理员",
            ["SETTINGS"] = "设置",
            ["APPEARANCE"] = "外观",
            ["FEATURES"] = "功能",
            ["UTILITIES"] = "工具",
            ["UI_ELEMENTS"] = "UI 元素",
            ["CONFIGURATION"] = "配置",
            ["SAVE_CONFIG"] = "保存配置",
            ["LOAD_CONFIG"] = "加载配置",
            ["THEME_SELECT"] = "选择主题",
            ["TRANSPARENCY"] = "窗口透明度"
        }
    }
})

WindUI.TransparencyValue = 0.15
WindUI:SetTheme("Dark")

local soundOptions = {
    { Name = "通知音1", ID = 4590662766 },
    { Name = "通知音2", ID = 4590657391 },
    { Name = "通知音3", ID = 9126209752 },
}
local currentSoundID = soundOptions[2].ID
local notifySoundID = soundOptions[2].ID

local function playClickSound()
    local success, char = pcall(function()
        return game:GetService("Players").LocalPlayer.Character
    end)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. currentSoundID
    sound.Volume = 0.4
    sound.Parent = (char and char ~= nil) and char or workspace
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 2)
end

local function playNotifySound()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. notifySoundID
    sound.Volume = 0.6
    sound.Parent = workspace
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 3)
end

local function gradient(text, startColor, endColor)
    local result = ""
    for i = 1, #text do
        local t = (i - 1) / (#text - 1)
        local r = math.floor((startColor.R + (endColor.R - startColor.R) * t) * 255)
        local g = math.floor((startColor.G + (endColor.G - startColor.G) * t) * 255)
        local b = math.floor((startColor.B + (endColor.B - startColor.B) * t) * 255)
        result = result .. string.format('<font color="rgb(%d,%d,%d)">%s</font>', r, g, b, text:sub(i, i))
    end
    return result
end

WindUI:Popup({
    Title = gradient("Sentinel-测试", Color3.fromHex("#8B4513"), Color3.fromHex("#D2691E")),
    Icon = "sparkles",
    Content = "loc:LIB_DESC",
    Buttons = {
        {
            Title = "使用Sentinel",
            Icon = "arrow-right",
            Variant = "Primary",
            Callback = function() end
        }
    }
})

local Window = WindUI:CreateWindow({
    Title = "哨兵-Doors",
    Icon = "geist:window",
    Author = "loc:WELCOME",
    Folder = "WindUI_Example",
    Size = UDim2.fromOffset(600, 510),
    Theme = "Dark",
    Background = "https://raw.githubusercontent.com/NUIke1/Sentinel/refs/heads/main/Image_1780211396491_940.jpg",
    BackgroundImageTransparency = 0.65,
    User = {
        Enabled = true,
        Anonymous = true,
        Callback = function()
            WindUI:Notify({
                Title = "用户资料",
                Content = "欢迎 " .. game.Players.LocalPlayer.Name .. " 使用哨兵脚本",
                Duration = 3
            })
        end
    },
    Acrylic = true,
    HideSearchBar = false,
    SideBarWidth = 200,
})

Window:Tag({
    Title = "v1.3",
    Color = Color3.fromHex("#8B4513")
})
Window:Tag({
    Title = "优化版",
    Color = Color3.fromHex("#D2691E")
})

local TimeTag = Window:Tag({
    Title = "--:--",
    Radius = 0,
    Color = WindUI:Gradient({
        ["0"]   = { Color = Color3.fromHex("#8B4513"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#D2691E"), Transparency = 0 },
    }, { Rotation = 45 }),
})

task.spawn(function()
    while true do
        local now = os.date("*t")
        TimeTag:SetTitle(string.format("%02d:%02d", now.hour, now.min))
        task.wait(0.5)
    end
end)

Window:CreateTopbarButton("theme-switcher", "moon", function()
    WindUI:SetTheme(WindUI:GetCurrentTheme() == "Dark" and "Light" or "Dark")
    WindUI:Notify({ Title = "主题已更改", Content = "当前主题: "..WindUI:GetCurrentTheme(), Duration = 2 })
end, 990)

local VisualSection = Window:Section({ Title = "透视&视觉", Opened = true })
local ConfigSection = VisualSection:Tab({ Title = "颜色配置", Icon = "palette" })
local PlayerTab = VisualSection:Tab({ Title = "玩家透视", Icon = "user" })
local MonsterTab = VisualSection:Tab({ Title = "怪物透视", Icon = "ghost" })
local ItemTab = VisualSection:Tab({ Title = "物品透视", Icon = "package" })
local WorldTab = VisualSection:Tab({ Title = "世界透视", Icon = "globe" })
local VisualTab = VisualSection:Tab({ Title = "视觉设置", Icon = "eye" })

local NotifySection = Window:Section({ Title = "提示", Opened = true })
local NotifyMainTab = NotifySection:Tab({ Title = "怪物提示", Icon = "bell" })
local NotifyItemTab = NotifySection:Tab({ Title = "物品提示", Icon = "bell-dot" })
local NotifySubTab = NotifySection:Tab({ Title = "提示设置", Icon = "settings" })

local EvasionSection = Window:Section({ Title = "规避", Opened = true })
local EvasionTab = EvasionSection:Tab({ Title = "规避", Icon = "shield" })

local MovementSection = Window:Section({ Title = "娱乐", Opened = true })
local Y = MovementSection:Tab({ Title = "娱乐", Icon = "user" })

local M = Window:Section({ Title = "主要", Opened = true })
local m = M:Tab({ Title = "主要", Icon = "user" })

local SettingsSection = Window:Section({ Title = "设置", Opened = true })
local SettingsTab = SettingsSection:Tab({ Title = "设置", Icon = "settings" })

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local ESPObjects = {}
local espConnection = nil
local isThirdPerson = false
local thirdPersonOffset = Vector3.new(0, 0, 5)
local showDistance = true
local espTextSize = 14
local espFillTransparency = 0.5
local espOutlineTransparency = 0.3
local scanFrame = 0
local scanInterval = 5
local maxDistance = 250
local lowQualityActive = false
local lowQualityConn = nil
local fpsUnlocked = false

local espActive = { Player = false, GoldPile = false }
local categoryMap = {}

local monsters = {
    "RushMoving", "AmbushMoving", "A60", "A120", "Eyes", "Screech", 
    "FigureRig", "FigureRagdoll", "SeekMovingNewClone", "BackdoorRush", 
    "BackdoorLookman", "Halt", "JeffTheKiller", "GiggleCeiling", 
    "GrumbleRig", "Snare", "GlitchRush", "GlitchAmbush"
}

local monsterNames = {
    RushMoving = "Rush", AmbushMoving = "Ambush", 
    A60 = "A-60", A120 = "A-120", Eyes = "眼睛", Screech = "小黑子",
    FigureRig = "无眼怪", FigureRagdoll = "无眼怪",
    SeekMovingNewClone = "Seek", BackdoorRush = "Blitz", 
    BackdoorLookman = "Lookman", Halt = "Halt", JeffTheKiller = "Jeff",
    GiggleCeiling = "Giggle", GrumbleRig = "Grumble", Snare = "地刺",
    GlitchRush = "GlitchRush", GlitchAmbush = "GlitchAmbush"
}

for _, name in ipairs(monsters) do
    espActive[name] = false
    categoryMap[name] = "monster"
end

local worldItems = {
    Door = "门", KeyObtain = "钥匙", LeverForGate = "大门拉杆", LiveBreakerPolePickup = "电闸",
    Gate = "大门", ElevatorBreaker = "断路器", FuseObtain = "保险丝", MinesGenerator = "发电机",
    MinesGateButton = "闸门按钮", WaterPump = "水泵", MinesAnchor = "锚点", Lever = "拉杆",
    TimerLever = "计时器拉杆", Padlock = "挂锁"
}

for objName, _ in pairs(worldItems) do
    espActive[objName] = false
    categoryMap[objName] = "world"
end

local items = {
    "ChestBoxLocked", "ChestBox", "Crucifix", "Candle", "Battery", "Vitamins", "Lockpick", 
    "Flashlight", "Smoothie", "Key", "Fuse", "Book", "Sheet", "FlashBeacon", 
    "Barrel", "Rift", "Skull", "Herb", "GloomPile", "SkeletonKey", "Shears",
    "Bandage", "StarVial", "StarBottle", "Shakelight", "Straplight", "Bulklight"
}

local itemNames = {
    ChestBoxLocked = "上锁箱子", ChestBox = "箱子", Crucifix = "十字架", Candle = "蜡烛",
    Battery = "电池", Vitamins = "维生素", Lockpick = "开锁器", Flashlight = "手电筒",
    Smoothie = "啤酒桶", Key = "钥匙", Fuse = "保险丝", Book = "书",
    Sheet = "纸", FlashBeacon = "闪光信标", Barrel = "桶", Rift = "裂缝", 
    Skull = "骷髅", Herb = "草药", GloomPile = "Gloom堆", SkeletonKey = "骷髅钥匙",
    Shears = "剪刀", Bandage = "绷带", StarVial = "星光小瓶", StarBottle = "星光瓶",
    Shakelight = "摇动手电", Straplight = "头灯", Bulklight = "大型手电"
}

for _, name in ipairs(items) do
    espActive[name] = false
    categoryMap[name] = "item"
end

espActive.GoldPile = false
categoryMap.GoldPile = "gold"

local colors = {
    monster = Color3.fromRGB(255, 0, 0),
    item = Color3.fromRGB(255, 0, 255),
    world = Color3.fromRGB(0, 255, 0),
    gold = Color3.fromRGB(255, 215, 0),
    player = Color3.fromRGB(255, 255, 255),
    monsterText = Color3.fromRGB(255, 255, 255),
    otherText = Color3.fromRGB(255, 255, 255)
}

local function GetDistance(part)
    if not part then return math.huge end
    if not LocalPlayer.Character then return math.huge end
    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return math.huge end
    local pos = part.Position
    if not pos then return math.huge end
    return (hrp.Position - pos).Magnitude
end

local function RemoveESP(instance)
    if not instance then return end
    local data = ESPObjects[instance]
    if data then
        if data.billboard then pcall(function() data.billboard:Destroy() end) end
        if data.highlight then pcall(function() data.highlight:Destroy() end) end
        ESPObjects[instance] = nil
    end
end

local function GetAttachPart(instance)
    if not instance then return nil end
    if instance:IsA("Model") then
        if instance.PrimaryPart then return instance.PrimaryPart end
        local hrp = instance:FindFirstChild("HumanoidRootPart")
        if hrp then return hrp end
        local torso = instance:FindFirstChild("UpperTorso") or instance:FindFirstChild("Torso")
        if torso then return torso end
        local anyPart = instance:FindFirstChildWhichIsA("BasePart")
        if anyPart then return anyPart end
    end
    if instance:IsA("BasePart") then return instance end
    return nil
end

local function CreateESP(instance, text, color, textColor)
    if not instance or not instance:IsDescendantOf(workspace) then return end
    
    local attachPart = GetAttachPart(instance)
    if not attachPart then return end
    
    local distance = GetDistance(attachPart)
    if distance > maxDistance then
        RemoveESP(instance)
        return
    end
    
    if ESPObjects[instance] then
        local data = ESPObjects[instance]
        if data.highlight then
            pcall(function() data.highlight.FillColor = color end)
            pcall(function() data.highlight.FillTransparency = espFillTransparency end)
        end
        if data.billboard then
            local label = data.billboard:FindFirstChildOfClass("TextLabel")
            if label then
                pcall(function() label.TextColor3 = textColor end)
                pcall(function() label.TextSize = espTextSize end)
                local displayText = text
                if showDistance then
                    displayText = text .. " | " .. math.floor(distance) .. "m"
                end
                if label.Text ~= displayText then
                    label.Text = displayText
                end
            end
        end
        return
    end
    
    local highlight = Instance.new("Highlight")
    highlight.FillColor = color
    highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
    highlight.FillTransparency = espFillTransparency
    highlight.OutlineTransparency = espOutlineTransparency
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    pcall(function() highlight.Parent = instance end)
    
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 150, 0, 25)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = maxDistance
    pcall(function() billboard.Parent = attachPart end)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = textColor
    label.TextSize = espTextSize
    local displayText = text
    if showDistance then
        displayText = text .. " | " .. math.floor(distance) .. "m"
    end
    label.Text = displayText
    label.Font = Enum.Font.GothamBold
    label.TextStrokeTransparency = 0.25
    label.Parent = billboard
    
    ESPObjects[instance] = { billboard = billboard, highlight = highlight, attachPart = attachPart }
end

local espScanInterval = 3
local espScanCounter = 0

local function CleanupInvalidESP()
    local toRemove = {}
    for obj, _ in pairs(ESPObjects) do
        if not obj or not obj:IsDescendantOf(workspace) then
            table.insert(toRemove, obj)
        end
    end
    for _, obj in ipairs(toRemove) do RemoveESP(obj) end
end

local espCache = {
    monsters = {},
    worldItems = {},
    items = {},
    gold = {},
    players = {}
}

local function UpdateESPCache()
    espCache.monsters = {}
    for _, name in ipairs(monsters) do
        if espActive[name] then
            for _, entity in ipairs(workspace:GetDescendants()) do
                if entity.Name == name and entity:IsA("Model") then
                    table.insert(espCache.monsters, entity)
                end
            end
        end
    end
    
    espCache.worldItems = {}
    for objName, displayName in pairs(worldItems) do
        if espActive[objName] then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name == objName and obj:IsA("Model") then
                    table.insert(espCache.worldItems, obj)
                end
                if objName == "Door" and obj.Name == "Door" and obj:FindFirstChild("Door") then
                    table.insert(espCache.worldItems, obj.Door)
                end
                if objName == "Padlock" and obj.Name == "Padlock" then
                    table.insert(espCache.worldItems, obj)
                end
            end
        end
    end
    
    espCache.items = {}
    for _, name in ipairs(items) do
        if espActive[name] then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and obj.Name == name then
                    table.insert(espCache.items, obj)
                end
            end
        end
    end
    
    espCache.gold = {}
    if espActive.GoldPile then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name == "GoldPile" then
                table.insert(espCache.gold, obj)
            end
        end
    end
    
    espCache.players = {}
    if espActive.Player then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    table.insert(espCache.players, player.Character)
                end
            end
        end
    end
end

local function UpdateAllESP()
    espScanCounter = espScanCounter + 1
    if espScanCounter < espScanInterval then return end
    espScanCounter = 0
    
    CleanupInvalidESP()
    UpdateESPCache()
    
    for _, entity in ipairs(espCache.monsters) do
        if entity and entity:IsDescendantOf(workspace) then
            CreateESP(entity, monsterNames[entity.Name] or entity.Name, colors.monster, colors.monsterText)
        end
    end
    
    for _, obj in ipairs(espCache.worldItems) do
        if obj and obj:IsDescendantOf(workspace) then
            local displayName = worldItems[obj.Name] or worldItems[obj.Parent and obj.Parent.Name] or "物品"
            if obj.Name == "Door" and obj.Parent and obj.Parent.Parent then
                displayName = "门"
            end
            CreateESP(obj, displayName, colors.world, colors.otherText)
        end
    end
    
    for _, obj in ipairs(espCache.items) do
        if obj and obj:IsDescendantOf(workspace) then
            CreateESP(obj, itemNames[obj.Name] or obj.Name, colors.item, colors.otherText)
        end
    end
    
    for _, gold in ipairs(espCache.gold) do
        if gold and gold:IsDescendantOf(workspace) then
            local val = gold:GetAttribute("GoldValue") or ""
            CreateESP(gold, "💰金币 " .. tostring(val), colors.gold, colors.otherText)
        end
    end
    
    for _, char in ipairs(espCache.players) do
        if char and char:IsDescendantOf(workspace) then
            CreateESP(char, char.Name or "玩家", colors.player, colors.otherText)
        end
    end
    
    for obj, data in pairs(ESPObjects) do
        if data.billboard and data.attachPart then
            local label = data.billboard:FindFirstChildOfClass("TextLabel")
            if label and data.attachPart then
                local dist = GetDistance(data.attachPart)
                local rawText = label.Text:gsub(" | %d+m", ""):gsub(" | %d+m", "")
                if showDistance then
                    label.Text = rawText .. " | " .. math.floor(dist) .. "m"
                else
                    label.Text = rawText
                end
                label.TextSize = espTextSize
            end
        end
        if data.highlight then
            data.highlight.FillTransparency = espFillTransparency
            data.highlight.OutlineTransparency = espOutlineTransparency
        end
    end
end

local function StartESP()
    if espConnection then espConnection:Disconnect() espConnection = nil end
    espConnection = RunService.Heartbeat:Connect(UpdateAllESP)
end

local function StopESP()
    if espConnection then espConnection:Disconnect() espConnection = nil end
    for obj, _ in pairs(ESPObjects) do RemoveESP(obj) end
end

local function checkAndStartESP()
    local any = false
    for _, v in pairs(espActive) do
        if v then any = true break end
    end
    if any then
        if not espConnection then StartESP() end
    else
        if espConnection then StopESP() end
    end
end

local function GetMonsterDisplayName(name)
    local display = monsterNames[name]
    if display then return display end
    return name:gsub("Moving", ""):gsub("Rig", ""):gsub("NewClone", "")
end

local monsterNotifyEnabled = {}
for _, name in ipairs(monsters) do
    monsterNotifyEnabled[name] = false
end

local itemNotifyEnabled = {}
for _, name in ipairs(items) do
    itemNotifyEnabled[name] = false
end

local notifiedMonsters = {}
local notifiedItems = {}

workspace.ChildAdded:Connect(function(child)
    task.wait(0.3)
    for _, monsterName in ipairs(monsters) do
        if monsterNotifyEnabled[monsterName] and child.Name == monsterName then
            local displayName = GetMonsterDisplayName(monsterName)
            if not notifiedMonsters[child] then
                notifiedMonsters[child] = true
                playNotifySound()
                WindUI:Notify({
                    Title = "⚠️ 怪物出现",
                    Content = displayName .. " 已生成，快找地方躲起来！",
                    Duration = 4
                })
                child.AncestryChanged:Connect(function()
                    if not child.Parent then
                        notifiedMonsters[child] = nil
                    end
                end)
            end
            break
        end
    end
    for _, itemName in ipairs(items) do
        if itemNotifyEnabled[itemName] and child.Name == itemName and child:IsA("Model") then
            local displayName = itemNames[itemName] or itemName
            if not notifiedItems[child] then
                notifiedItems[child] = true
                playNotifySound()
                WindUI:Notify({
                    Title = "📦 物品出现",
                    Content = displayName .. " 已生成！",
                    Duration = 3
                })
                child.AncestryChanged:Connect(function()
                    if not child.Parent then
                        notifiedItems[child] = nil
                    end
                end)
            end
            break
        end
    end
end)

NotifyMainTab:Paragraph({
    Title = "怪物提示",
    Content = "开启后当怪物生成时会收到通知"
})

for _, name in ipairs(monsters) do
    local displayName = GetMonsterDisplayName(name)
    NotifyMainTab:Toggle({
        Title = displayName .. " 提醒",
        Default = false,
        Callback = function(state)
            playClickSound()
            monsterNotifyEnabled[name] = state
        end
    })
end

NotifyItemTab:Paragraph({
    Title = "物品提示",
    Content = "开启后当物品生成时会收到通知"
})

for _, name in ipairs(items) do
    if name ~= "GoldPile" then
        local displayName = itemNames[name] or name
        NotifyItemTab:Toggle({
            Title = displayName .. " 提醒",
            Default = false,
            Callback = function(state)
                playClickSound()
                itemNotifyEnabled[name] = state
            end
        })
    end
end

NotifyItemTab:Toggle({
    Title = "金币 提醒",
    Default = false,
    Callback = function(state)
        playClickSound()
        itemNotifyEnabled.GoldPile = state
    end
})

NotifySubTab:Dropdown({
    Title = "提示音选择",
    Values = { soundOptions[1].Name, soundOptions[2].Name, soundOptions[3].Name },
    Value = soundOptions[2].Name,
    Callback = function(selected)
        for _, opt in ipairs(soundOptions) do
            if opt.Name == selected then
                notifySoundID = opt.ID
                break
            end
        end
        playClickSound()
        WindUI:Notify({ Title = "提示音已更改", Content = "当前: " .. selected, Duration = 1 })
    end
})

EvasionTab:Toggle({
    Title = "防香蕉皮",
    Default = false,
    Callback = function(Value)
        local currentRooms = workspace:WaitForChild("CurrentRooms")
        
        if getgenv().antiBananaConn then
            getgenv().antiBananaConn:Disconnect()
            getgenv().antiBananaConn = nil
        end

        for _, v in pairs(currentRooms:GetDescendants()) do
            if v.Name == "BananaPeel" and v:IsA("BasePart") then
                v.CanTouch = not Value
            end
        end

        if Value then
            getgenv().antiBananaConn = currentRooms.DescendantAdded:Connect(function(v)
                if v.Name == "BananaPeel" and v:IsA("BasePart") then
                    v.CanTouch = false
                end
            end)
        end
        WindUI:Notify("防香蕉皮", Value and "已启用" or "已禁用", 2)
    end
})

EvasionTab:Toggle({
    Title = "防Jeff杀手",
    Default = false,
    Callback = function(Value)
        local currentRooms = workspace:WaitForChild("CurrentRooms")
        
        if getgenv().antiJeffConn then
            getgenv().antiJeffConn:Disconnect()
            getgenv().antiJeffConn = nil
        end

        for _, model in pairs(currentRooms:GetDescendants()) do
            if model.Name == "JeffTheKiller" and model:IsA("Model") then
                for _, part in ipairs(model:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanTouch = not Value
                    end
                end
            end
        end

        if Value then
            getgenv().antiJeffConn = currentRooms.DescendantAdded:Connect(function(v)
                if v.Name == "JeffTheKiller" and v:IsA("Model") then
                    for _, part in ipairs(v:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanTouch = false
                        end
                    end
                end
            end)
        end
        WindUI:Notify("防Jeff杀手", Value and "已启用" or "已禁用", 2)
    end
})

EvasionTab:Toggle({
    Title = "反 Halt",
    Default = false,
    Callback = function(Value)
        local entityModules = game:GetService("ReplicatedStorage"):FindFirstChild("ClientModules")
        if entityModules then
            local module = entityModules.EntityModules:FindFirstChild("Shade") or entityModules.EntityModules:FindFirstChild("_Shade")
            if module then
                module.Name = Value and "_Shade" or "Shade"
            end
        end
        WindUI:Notify("反 Halt", Value and "已启用" or "已禁用", 2)
    end
})

EvasionTab:Toggle({
    Title = "反 Screech",
    Default = false,
    Callback = function(Value)
        local mainGame = LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game
        if mainGame then
            local module = mainGame:FindFirstChild("Screech", true) or mainGame:FindFirstChild("_Screech", true)
            if module then
                module.Name = Value and "_Screech" or "Screech"
            end
        end
        WindUI:Notify("反 Screech", Value and "已启用" or "已禁用", 2)
    end
})

EvasionTab:Toggle({
    Title = "反 Dupe 假门",
    Default = false,
    Callback = function(Value)
        for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
            for _, dupeRoom in pairs(room:GetChildren()) do
                if dupeRoom:GetAttribute("LoadModule") == "DupeRoom" then
                    local doorFake = dupeRoom:FindFirstChild("DoorFake")
                    if doorFake then
                        local hidden = doorFake:FindFirstChild("Hidden")
                        if hidden then hidden.CanTouch = not Value end
                        local lock = doorFake:FindFirstChild("Lock")
                        if lock then
                            local prompt = lock:FindFirstChildOfClass("ProximityPrompt")
                            if prompt then prompt.Enabled = not Value end
                        end
                    end
                end
            end
        end
        WindUI:Notify("反 Dupe", Value and "已启用" or "已禁用", 2)
    end
})

EvasionTab:Toggle({
    Title = "反 Eyes / Lookman",
    Default = false,
    Callback = function(Value)
        if Value then
            local remoteFolder = game:GetService("ReplicatedStorage"):FindFirstChild("RemotesFolder") or game:GetService("ReplicatedStorage"):FindFirstChild("EntityInfo")
            if remoteFolder then
                remoteFolder.MotorReplication:FireServer(-650)
            end
        end
        WindUI:Notify("反 Eyes", Value and "已启用，看向眼睛不会受伤" or "已禁用", 2)
    end
})

EvasionTab:Toggle({
    Title = "反 Snare 地刺",
    Default = false,
    Callback = function(Value)
        for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
            if room:FindFirstChild("Assets") then
                for _, snare in pairs(room.Assets:GetChildren()) do
                    if snare.Name == "Snare" then
                        local hitbox = snare:FindFirstChild("Hitbox")
                        if hitbox then hitbox.CanTouch = not Value end
                    end
                end
            end
        end
        WindUI:Notify("反 Snare", Value and "已启用" or "已禁用", 2)
    end
})

EvasionTab:Toggle({
    Title = "反 Seek 障碍物",
    Default = false,
    Callback = function(Value)
        for _, v in pairs(workspace.CurrentRooms:GetDescendants()) do
            if v.Name == "ChandelierObstruction" or v.Name == "Seek_Arm" then
                for _, part in pairs(v:GetChildren()) do
                    if part:IsA("BasePart") then part.CanTouch = not Value end
                end
            end
        end
        WindUI:Notify("反 Seek 障碍物", Value and "已启用" or "已禁用", 2)
    end
})

EvasionTab:Toggle({
    Title = "反 A90",
    Default = false,
    Callback = function(Value)
        local mainGame = LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game
        if mainGame then
            local module = mainGame:FindFirstChild("A90", true) or mainGame:FindFirstChild("_A90", true)
            if module then
                module.Name = Value and "_A90" or "A90"
            end
        end
        WindUI:Notify("反 A90", Value and "已启用" or "已禁用", 2)
    end
})

EvasionTab:Toggle({
    Title = "反 Dread",
    Default = false,
    Callback = function(Value)
        local modules = LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener.Modules
        if modules then
            local dread = modules:FindFirstChild("Dread") or modules:FindFirstChild("_Dread")
            if dread then
                dread.Name = Value and "_Dread" or "Dread"
            end
        end
        WindUI:Notify("反 Dread", Value and "已启用" or "已禁用", 2)
    end
})

EvasionTab:Toggle({
    Title = "反 Figure 听觉",
    Default = false,
    Callback = function(Value)
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local RunService = game:GetService("RunService")
        local RemoteFolder = ReplicatedStorage:FindFirstChild("RemotesFolder") or ReplicatedStorage:FindFirstChild("EntityInfo")

        if _G.AntiHearingConn then
            _G.AntiHearingConn:Disconnect()
            _G.AntiHearingConn = nil
        end

        if Value then
            _G.AntiHearingConn = RunService.Heartbeat:Connect(function()
                RemoteFolder.Crouch:FireServer(true)
            end)
            WindUI:Notify("反 Figure 听觉", "已启用，Figure将听不见你", 2)
        else
            RemoteFolder.Crouch:FireServer(false)
            WindUI:Notify("反 Figure 听觉", "已禁用", 2)
        end
    end
})

EvasionTab:Toggle({
    Title = "反 Lookman",
    Default = false,
    Callback = function(Value)
        if Value and workspace:FindFirstChild("BackdoorLookman") then
            local remoteFolder = game:GetService("ReplicatedStorage"):FindFirstChild("RemotesFolder") or game:GetService("ReplicatedStorage"):FindFirstChild("EntityInfo")
            if remoteFolder then
                remoteFolder.MotorReplication:FireServer(-890)
            end
        end
        WindUI:Notify("反 Lookman", Value and "已启用" or "已禁用", 2)
    end
})

EvasionTab:Toggle({
    Title = "反 Giggle",
    Default = false,
    Callback = function(Value)
        for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
            for _, giggle in pairs(room:GetChildren()) do
                if giggle.Name == "GiggleCeiling" then
                    local hitbox = giggle:FindFirstChild("Hitbox")
                    if hitbox then hitbox.CanTouch = not Value end
                end
            end
        end
        WindUI:Notify("反 Giggle", Value and "已启用" or "已禁用", 2)
    end
})

EvasionTab:Toggle({
    Title = "反 Gloom Egg",
    Default = false,
    Callback = function(Value)
        for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
            for _, gloomPile in pairs(room:GetChildren()) do
                if gloomPile.Name == "GloomPile" then
                    for _, gloomEgg in pairs(gloomPile:GetDescendants()) do
                        if gloomEgg.Name == "Egg" then
                            gloomEgg.CanTouch = not Value
                        end
                    end
                end
            end
        end
        WindUI:Notify("反 Gloom Egg", Value and "已启用" or "已禁用", 2)
    end
})

EvasionTab:Toggle({
    Title = "反桥梁坠落",
    Default = false,
    Callback = function(Value)
        if Value then
            for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
                if room:FindFirstChild("Parts") then
                    for _, bridge in pairs(room.Parts:GetChildren()) do
                        if bridge.Name == "Bridge" then
                            for _, barrier in pairs(bridge:GetChildren()) do
                                if barrier.Name == "PlayerBarrier" and barrier.Size.Y == 2.75 then
                                    local clone = barrier:Clone()
                                    clone.Name = "AntiBridge"
                                    clone.Size = Vector3.new(barrier.Size.X, barrier.Size.Y, 30)
                                    clone.CFrame = barrier.CFrame * CFrame.new(0, 0, -5)
                                    clone.Transparency = 0
                                    clone.Anchored = true
                                    clone.CanCollide = true
                                    clone.Parent = bridge
                                end
                            end
                        end
                    end
                end
            end
        else
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name == "AntiBridge" then v:Destroy() end
            end
        end
        WindUI:Notify("反桥梁坠落", Value and "已启用" or "已禁用", 2)
    end
})

EvasionTab:Toggle({
    Title = "反真空",
    Default = false,
    Callback = function(Value)
        for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
            for _, obj in pairs(room:GetChildren()) do
                if obj.Name == "SideroomSpace" then
                    local collision = obj:FindFirstChild("Collision")
                    if collision then
                        collision.CanTouch = not Value
                        collision.CanCollide = Value
                    end
                end
            end
        end
        WindUI:Notify("反真空", Value and "已启用" or "已禁用", 2)
    end
})

EvasionTab:Toggle({
    Title = "反干扰",
    Default = false,
    Callback = function(Value)
        local mainTrack = game:GetService("SoundService"):FindFirstChild("Main")
        if mainTrack then
            local jamming = mainTrack:FindFirstChild("Jamming")
            if jamming then
                jamming.Enabled = not Value
            end
        end
        local mainUI = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("MainUI")
        if mainUI then
            local healthGui = mainUI:FindFirstChild("Initiator") and mainUI.Initiator:FindFirstChild("Main_Game") and mainUI.Initiator.Main_Game:FindFirstChild("Health")
            if healthGui then
                local jamSound = healthGui:FindFirstChild("Jam")
                if jamSound then
                    jamSound.Playing = not Value
                end
            end
        end
        WindUI:Notify("反干扰", Value and "已启用" or "已禁用", 2)
    end
})

Y:Toggle({
    Title = "始终可跳跃",
    Default = false,
    Tooltip = "让你随时可以跳跃",
    Callback = function(Value)
        local LocalPlayer = game.Players.LocalPlayer
        LocalPlayer.Character:SetAttribute("CanJump", Value)
        
        if Value then
            WindUI:Notify("跳跃", "始终跳跃已启用", 3)
        else
            WindUI:Notify("跳跃", "始终跳跃已禁用", 3)
        end
        LocalPlayer.CharacterAdded:Connect(function(newCharacter)
            task.wait(1.5)
            newCharacter:SetAttribute("CanJump", Value)
        end)
    end
})

Y:Toggle({
    Title = "第三人称",
    Default = false,
    Callback = function(state)
        playClickSound()
        isThirdPerson = state
    end
})

Y:Slider({
    Title = "第三人称偏移X",
    Value = { Min = -10, Max = 10, Default = 0 },
    Callback = function(v)
        playClickSound()
        thirdPersonOffset = Vector3.new(v, thirdPersonOffset.Y, thirdPersonOffset.Z)
    end
})

Y:Slider({
    Title = "第三人称偏移Y",
    Value = { Min = -10, Max = 10, Default = 0 },
    Callback = function(v)
        playClickSound()
        thirdPersonOffset = Vector3.new(thirdPersonOffset.X, v, thirdPersonOffset.Z)
    end
})

Y:Slider({
    Title = "第三人称偏移Z",
    Value = { Min = -10, Max = 10, Default = 5 },
    Callback = function(v)
        playClickSound()
        thirdPersonOffset = Vector3.new(thirdPersonOffset.X, thirdPersonOffset.Y, v)
    end
})

Y:Toggle({
    Title = "防卡顿",
    Default = false,
    Callback = function(Value)
        local Modifiers = workspace:FindFirstChild("Modifiers")
        if Modifiers and not Modifiers:FindFirstChild("Jammin") then
            return
        end

        local mainTrack = game["SoundService"]:FindFirstChild("Main")
        if mainTrack then
            local jamming = mainTrack:FindFirstChild("Jamming")
            if jamming then
                jamming.Enabled = not Value
            end
        end

        local mainUI = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("MainUI")
        if mainUI then
            local healthGui = mainUI:FindFirstChild("Initiator") and 
                             mainUI.Initiator:FindFirstChild("Main_Game") and 
                             mainUI.Initiator.Main_Game:FindFirstChild("Health")
            if healthGui then
                local jamSound = healthGui:FindFirstChild("Jam")
                if jamSound then
                    jamSound.Playing = not Value
                end
            end
        end
        WindUI:Notify("防卡顿", Value and "已启用" or "已禁用", 2)
    end
})

PlayerTab:Toggle({
    Title = "玩家透视",
    Default = false,
    Callback = function(state)
        playClickSound()
        espActive.Player = state
        checkAndStartESP()
    end
})

VisualTab:Toggle({
    Title = "显示距离",
    Default = true,
    Callback = function(state)
        playClickSound()
        showDistance = state
        UpdateAllESP()
    end
})

VisualTab:Slider({
    Title = "透视文字大小",
    Value = { Min = 10, Max = 22, Default = 14 },
    Callback = function(v)
        playClickSound()
        espTextSize = v
        UpdateAllESP()
    end
})

VisualTab:Slider({
    Title = "透视填充透明度",
    Value = { Min = 0, Max = 1, Default = 0.5, Decimal = true },
    Callback = function(v)
        playClickSound()
        espFillTransparency = v
        UpdateAllESP()
    end
})

VisualTab:Slider({
    Title = "透视轮廓透明度",
    Value = { Min = 0, Max = 1, Default = 0.3, Decimal = true },
    Callback = function(v)
        playClickSound()
        espOutlineTransparency = v
        UpdateAllESP()
    end
})

VisualTab:Slider({
    Title = "扫描间隔(帧)",
    Value = { Min = 1, Max = 10, Default = 3 },
    Callback = function(v)
        playClickSound()
        espScanInterval = v
    end
})

VisualTab:Toggle({
    Title = "FPS解锁",
    Default = false,
    Callback = function(state)
        playClickSound()
        fpsUnlocked = state
        if state then
            setfpscap(999)
        else
            setfpscap(60)
        end
    end
})

VisualTab:Toggle({
    Title = "低画质优化",
    Default = false,
    Callback = function(state)
        playClickSound()
        if lowQualityConn then lowQualityConn:Disconnect() lowQualityConn = nil end
        lowQualityActive = state
        if state then
            local function apply()
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") then
                        pcall(function() v.Material = Enum.Material.Plastic end)
                    end
                    if v.Name == "LightFixture" or v.Name == "Carpet" or v.Name == "CarpetLight" then
                        pcall(function() v:Destroy() end)
                    end
                end
            end
            apply()
            lowQualityConn = RunService.Heartbeat:Connect(apply)
        end
    end
})

for _, name in ipairs(monsters) do
    MonsterTab:Toggle({
        Title = monsterNames[name] or name,
        Default = false,
        Callback = function(state)
            playClickSound()
            espActive[name] = state
            checkAndStartESP()
        end
    })
end

for _, name in ipairs(items) do
    if name ~= "GoldPile" then
        ItemTab:Toggle({
            Title = itemNames[name] or name,
            Default = false,
            Callback = function(state)
                playClickSound()
                espActive[name] = state
                checkAndStartESP()
            end
        })
    end
end

ItemTab:Toggle({
    Title = "金币透视",
    Default = false,
    Callback = function(state)
        playClickSound()
        espActive.GoldPile = state
        checkAndStartESP()
    end
})

for objName, displayName in pairs(worldItems) do
    WorldTab:Toggle({
        Title = displayName .. "透视",
        Default = false,
        Callback = function(state)
            playClickSound()
            espActive[objName] = state
            checkAndStartESP()
        end
    })
end

ConfigSection:Colorpicker({
    Title = "玩家颜色",
    Default = colors.player,
    Callback = function(color)
        playClickSound()
        colors.player = color
        for obj, data in pairs(ESPObjects) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= LocalPlayer.Character then
                if data.highlight then pcall(function() data.highlight.FillColor = color end) end
            end
        end
    end
})

ConfigSection:Colorpicker({
    Title = "怪物颜色",
    Default = colors.monster,
    Callback = function(color)
        playClickSound()
        colors.monster = color
        for obj, data in pairs(ESPObjects) do
            if categoryMap[obj.Name] == "monster" and data.highlight then
                pcall(function() data.highlight.FillColor = color end)
            end
        end
    end
})

ConfigSection:Colorpicker({
    Title = "物品颜色",
    Default = colors.item,
    Callback = function(color)
        playClickSound()
        colors.item = color
        for obj, data in pairs(ESPObjects) do
            if categoryMap[obj.Name] == "item" and data.highlight then
                pcall(function() data.highlight.FillColor = color end)
            end
        end
    end
})

ConfigSection:Colorpicker({
    Title = "世界物品颜色",
    Default = colors.world,
    Callback = function(color)
        playClickSound()
        colors.world = color
        for obj, data in pairs(ESPObjects) do
            if categoryMap[obj.Name] == "world" and data.highlight then
                pcall(function() data.highlight.FillColor = color end)
            end
        end
    end
})

ConfigSection:Colorpicker({
    Title = "金币颜色",
    Default = colors.gold,
    Callback = function(color)
        playClickSound()
        colors.gold = color
        for obj, data in pairs(ESPObjects) do
            if categoryMap[obj.Name] == "gold" and data.highlight then
                pcall(function() data.highlight.FillColor = color end)
            end
        end
    end
})

ConfigSection:Colorpicker({
    Title = "怪物文字颜色",
    Default = colors.monsterText,
    Callback = function(color)
        playClickSound()
        colors.monsterText = color
        for obj, data in pairs(ESPObjects) do
            if categoryMap[obj.Name] == "monster" and data.billboard then
                local label = data.billboard:FindFirstChildOfClass("TextLabel")
                if label then pcall(function() label.TextColor3 = color end) end
            end
        end
    end
})

ConfigSection:Colorpicker({
    Title = "其他文字颜色",
    Default = colors.otherText,
    Callback = function(color)
        playClickSound()
        colors.otherText = color
        for obj, data in pairs(ESPObjects) do
            if categoryMap[obj.Name] ~= "monster" and data.billboard then
                local label = data.billboard:FindFirstChildOfClass("TextLabel")
                if label then pcall(function() label.TextColor3 = color end) end
            end
        end
    end
})

ConfigSection:Dropdown({
    Title = "按钮提示音",
    Values = { soundOptions[1].Name, soundOptions[2].Name, soundOptions[3].Name },
    Value = soundOptions[2].Name,
    Callback = function(selected)
        for _, opt in ipairs(soundOptions) do
            if opt.Name == selected then
                currentSoundID = opt.ID
                break
            end
        end
        playClickSound()
        WindUI:Notify({ Title = "提示音已更改", Content = "当前: " .. selected, Duration = 1 })
    end
})

VisualTab:Toggle({
    Title = "高亮",
    Default = false,
    Callback = function(state)
        playClickSound()
        Lighting.Ambient = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0)
    end
})

VisualTab:Slider({
    Title = "FOV调整",
    Value = { Min = 70, Max = 120, Default = 70 },
    Callback = function(v)
        playClickSound()
        pcall(function() Camera.FieldOfView = v end)
    end
})

RunService.RenderStepped:Connect(function()
    if isThirdPerson and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local char = LocalPlayer.Character
        local hrp = char.HumanoidRootPart
        local camCF = Camera.CFrame
        local targetPos = hrp.Position + camCF.LookVector * -thirdPersonOffset.Z + camCF.RightVector * thirdPersonOffset.X + camCF.UpVector * thirdPersonOffset.Y
        Camera.CFrame = CFrame.new(targetPos, hrp.Position)
    end
end)

task.spawn(function()
    while true do
        task.wait(60)
        CleanupInvalidESP()
        if lowQualityActive and not lowQualityConn then lowQualityActive = false end
        collectgarbage("collect")
    end
end)

local TS = Window:Section({ Title = "自动类", Opened = true })
local B = TS:Tab({ Title = "自动", Icon = "puzzle" })

local antiAfk = false
local function startAntiAfk()
    if antiAfk then return end
    antiAfk = true
    LocalPlayer.Idled:Connect(function()
        if antiAfk then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end)
end

B:Toggle({
    Title = "防挂机",
    Default = false,
    Callback = function(state)
        playClickSound()
        antiAfk = state
        if state then
            startAntiAfk()
        end
    end
})

B:Toggle({
    Title = "自动锚点代码求解",
    Default = false,
    Callback = function(enabled)
        local running = false
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local Workspace = game:GetService("Workspace")
        
        if enabled then
            if running then return end
            running = true
            
            task.spawn(function()
                local playerGui = LocalPlayer:WaitForChild("PlayerGui")
                
                local function findFrame()
                    local mainUI = playerGui:FindFirstChild("MainUI")
                    if mainUI and mainUI:FindFirstChild("MainFrame") then
                        local frame = mainUI.MainFrame:FindFirstChild("AnchorHintFrame")
                        if frame then return frame end
                    end

                    local anchorUI = playerGui:FindFirstChild("AnchorHintUI")
                    if anchorUI then
                        local frame = anchorUI:FindFirstChild("AnchorHintFrame")
                        if frame then return frame end
                    end
                    return nil
                end

                while running do
                    task.wait(0.9)
                    local frame = findFrame()
                    
                    if frame then
                        local anchorName = (frame:FindFirstChild("AnchorCode") and frame.AnchorCode.Text) or ''
                        local codeText = (frame:FindFirstChild("Code") and frame.Code.Text) or ''
                        
                        if anchorName ~= '' and codeText ~= '' then
                            local anchorObject
                            for _, obj in ipairs(Workspace.CurrentRooms:GetDescendants()) do
                                if obj.Name == "MinesAnchor" then
                                    local sign = obj:FindFirstChild("Sign")
                                    if sign then
                                        local label = sign:FindFirstChild("TextLabel") or sign:FindFirstChildWhichIsA("TextLabel")
                                        if label and label.Text == anchorName then
                                            anchorObject = obj
                                            break
                                        end
                                    end
                                end
                            end

                            if anchorObject then
                                local note = anchorObject:FindFirstChild("Note")
                                if not note then
                                    WindUI:Notify("锚点代码", "锚点 " .. anchorName .. " 代码是 " .. codeText, 3)
                                else
                                    local surfaceGui = note:FindFirstChildOfClass("SurfaceGui") or note:FindFirstChild("SurfaceGui")
                                    local noteText = (surfaceGui and surfaceGui:FindFirstChild("TextLabel") and surfaceGui.TextLabel.Text) or '0'
                                    local noteValue = tonumber(noteText) or 0
                                    local solved = ''
                                    
                                    for i = 1, #codeText do
                                        local digit = tonumber(codeText:sub(i, i)) or 0
                                        digit = (digit + noteValue) % 10
                                        solved = solved .. tostring(digit)
                                    end
                                    
                                    WindUI:Notify("锚点代码", "锚点 " .. anchorName .. " 代码是 " .. solved, 5)
                                end
                            end
                        end
                    else
                        task.wait(0.25)
                    end
                end
            end)
        else
            running = false
        end
    end
})

B:Toggle({
    Title = "自动断路器游戏",
    Default = false,
    Callback = function(Value)
        local Players = game:GetService("Players")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local LocalPlayer = Players.LocalPlayer
        local RemoteFolder = ReplicatedStorage:FindFirstChild("RemotesFolder") or ReplicatedStorage:FindFirstChild("EntityInfo") or ReplicatedStorage:FindFirstChild("Bricks")
        
        while task.wait() and Value do
            if not Value then break end
            
            local currentRoom = LocalPlayer:GetAttribute("CurrentRoom")
            if currentRoom ~= 100 then
                WindUI:Notify("提示", "你需要在100号房间使用此功能", 5)
                break
            end

            local Breaker = nil
            for _, v in ipairs(workspace.CurrentRooms:GetDescendants()) do
                if v.Name == "ElevatorBreaker" then
                    Breaker = v
                    break
                end
            end

            if Breaker then
                local solved = true
                for _, v in ipairs(Breaker:GetChildren()) do
                    if v.Name == "BreakerSwitch" then
                        local codeText = Breaker:WaitForChild("SurfaceGui").Frame.Code.Text
                        if v:GetAttribute("ID") == tonumber(codeText) then
                            if Breaker.SurfaceGui.Frame.Code.Frame.BackgroundTransparency == 0 then
                                v:SetAttribute("Enabled", true)
                                if not v.Sound.Playing then
                                    v.Sound.Playing = true
                                end
                                v.Material = Enum.Material.Neon
                                v.Light.Attachment.Spark:Emit(1)
                                v.PrismaticConstraint.TargetPosition = -0.2
                            else
                                v:SetAttribute("Enabled", false)
                                if not v.Sound.Playing then
                                    v.Sound.Playing = true
                                end
                                v.PrismaticConstraint.TargetPosition = 0.2
                                v.Material = Enum.Material.Glass
                                solved = false
                            end
                        end
                    end
                end

                if solved and RemoteFolder then
                    local breakerRemote = RemoteFolder:FindFirstChild("BreakerMinigame")
                    if breakerRemote then
                        breakerRemote:FireServer("Solved")
                    end
                end
            end
        end
    end
})

B:Toggle({
    Title = "自动隐藏[防怪物]",
    Default = false,
    Risky = true,
    Tooltip = "自动为你隐藏",
    Callback = function(Value)
        local EntityDistances = {
            RushMoving = 80,
            BackdoorRush = 80,
            AmbushMoving = 130,
            A60 = 130,
            A120 = 65,
        }
        local Rooms = workspace.CurrentRooms
        local LocalPlayer = game.Players.LocalPlayer
        local Connections = {}

        local function GetHiding()
            local Closest, Prompt
            local currRoom = Rooms and Rooms[LocalPlayer:GetAttribute("CurrentRoom")]
            if not currRoom then return nil end

            local char = LocalPlayer.Character
            if not char then return nil end

            local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Collision") or char.PrimaryPart
            if not hrp then return nil end

            local function distFromPlayer(model)
                if not model then return math.huge end
                local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
                if not part then return math.huge end
                return (part.Position - hrp.Position).Magnitude
            end

            local assets = currRoom:FindFirstChild("Assets")
            if assets then
                for _, v in pairs(assets:GetChildren()) do
                    if v:IsA("Model") then
                        if ((v.Name == "Locker_Large") or (v.Name == "Wardrobe") or (v.Name == "Toolshed") or (v.Name == "Bed") or (v.Name == "Rooms_Locker") or (v.Name == "Rooms_Locker_Fridge") or (v.Name == "Backdoor_Wardrobe")) and v:FindFirstChild("HidePrompt") and v:FindFirstChild("HiddenPlayer") then
                            if not v.HiddenPlayer.Value and not v:FindFirstChild("HideEntityOnSpot", true) then
                                if Closest then
                                    if distFromPlayer(v) < distFromPlayer(Closest) then
                                        Closest = v
                                        Prompt = v.HidePrompt
                                    end
                                else
                                    Closest = v
                                    Prompt = v.HidePrompt
                                end
                            end
                        elseif v.Name == "Double_Bed" then
                            for _, x in pairs(v:GetChildren()) do
                                if x.Name == "DoubleBed" and x:FindFirstChild("HidePrompt") and x:FindFirstChild("HiddenPlayer") then
                                    if not x.HiddenPlayer.Value and not x:FindFirstChild("HideEntityOnSpot", true) then
                                        if Closest then
                                            if distFromPlayer(x) < distFromPlayer(Closest) then
                                                Closest = x
                                                Prompt = x.HidePrompt
                                            end
                                        else
                                            Closest = x
                                            Prompt = x.HidePrompt
                                        end
                                    end
                                end
                            end
                        elseif v.Name == "Dumpster" then
                            for _, x in pairs(v:GetChildren()) do
                                if x:FindFirstChild("HidePrompt") and x:FindFirstChild("HiddenPlayer") then
                                    local dumpsterBaseHasSpot = v:FindFirstChild("DumpsterBase") and v.DumpsterBase:FindFirstChild("HideEntityOnSpot")
                                    if not x.HiddenPlayer.Value and not dumpsterBaseHasSpot then
                                        if Closest then
                                            if distFromPlayer(x) < distFromPlayer(Closest) then
                                                Closest = x
                                                Prompt = x.HidePrompt
                                            end
                                        else
                                            Closest = x
                                            Prompt = x.HidePrompt
                                        end
                                    end
                                end
                            end
                        end
                    elseif v:IsA("Folder") then
                        if v.Name == "Blockage" then
                            for _, x in pairs(v:GetChildren()) do
                                if x:IsA("Model") and x.Name == "Wardrobe" and x:FindFirstChild("HiddenPlayer") and x:FindFirstChild("HidePrompt") then
                                    if not x.HiddenPlayer.Value then
                                        if Closest then
                                            if distFromPlayer(x) < distFromPlayer(Closest) then
                                                Closest = x
                                                Prompt = x.HidePrompt
                                            end
                                        else
                                            Closest = x
                                            Prompt = x.HidePrompt
                                        end
                                    end
                                end
                            end
                        elseif v.Name == "Vents" then
                            for _, x in pairs(v:GetChildren()) do
                                if x.Name == "CircularVent" and x:FindFirstChild("Grate") and x.Grate:FindFirstChild("HidePrompt") and x:FindFirstChild("HiddenPlayer") then
                                    if not x.HiddenPlayer.Value and not v:FindFirstChild("HideEntityOnSpot", true) then
                                        if Closest then
                                            if distFromPlayer(x) < distFromPlayer(Closest) then
                                                Closest = x
                                                Prompt = x.Grate.HidePrompt
                                            end
                                        else
                                            Closest = x
                                            Prompt = x.Grate.HidePrompt
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end

            for _, v in pairs(currRoom:GetChildren()) do
                if v:IsA("Model") then
                    if v.Name == "CircularVent" and v:FindFirstChild("Grate") and v.Grate:FindFirstChild("HidePrompt") and v:FindFirstChild("HiddenPlayer") then
                        if not v.HiddenPlayer.Value and not v:FindFirstChild("HideEntityOnSpot", true) then
                            if Closest then
                                if distFromPlayer(v) < distFromPlayer(Closest) then
                                    Closest = v
                                    Prompt = v.Grate.HidePrompt
                                end
                            else
                                Closest = v
                                Prompt = v.Grate.HidePrompt
                            end
                        end
                    end
                end
            end

            return Prompt
        end

        if Value then
            table.insert(Connections, workspace.ChildAdded:Connect(function(v)
                if v:IsA("Model") and EntityDistances[v.Name] then
                    task.wait(1)
                    local Part = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart", true)
                    if not Part then return end

                    v:SetAttribute("_Prediction", Part.Position)

                    while task.wait() and v.Parent do
                        task.spawn(function()
                            local LastPosition = Part.Position
                            task.wait(0.3333333333333333)
                            if Part and Part.Parent then
                                v:SetAttribute("_Prediction", Part.Position - LastPosition)
                            end
                        end)

                        if Value then
                            local IncludeList = {}
                            for _, Room in pairs(Rooms:GetChildren()) do
                                if Room:FindFirstChild("Assets") then
                                    table.insert(IncludeList, Room.Assets)
                                end
                                if Room:FindFirstChild("Parts") then
                                    table.insert(IncludeList, Room.Parts)
                                end
                            end

                            local RaycastParams = RaycastParams.new()
                            RaycastParams.FilterDescendantsInstances = IncludeList
                            RaycastParams.FilterType = Enum.RaycastFilterType.Include

                            local Count = {0.2, 0.4, 0.6, 0.8, 1}
                            local entityInRange = false

                            for i = 1, #Count do
                                local Number = 1.5 * Count[i]
                                local predAttr = v:GetAttribute("_Prediction")
                                local Prediction = (predAttr and (predAttr * 3)) or Vector3.new(0, 0, 0)
                                Prediction = Prediction * Number

                                local char = LocalPlayer.Character
                                if not char then break end

                                local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Collision") or char.PrimaryPart
                                if not hrp then break end

                                if Vector3.new(Prediction.X, 0, Prediction.Z).Magnitude > 1 then
                                    local PredictionPosition = Part.Position + Prediction
                                    local Raycast
                                    if true then
                                        Raycast = workspace:Raycast(hrp.Position, PredictionPosition - hrp.Position, RaycastParams)
                                    end

                                    local distMultiplier = 1
                                    local mode = "Safety"
                                    local adjust = 0

                                    if mode == "Safety" then
                                        adjust = 20
                                    elseif mode == "Close Call" then
                                        adjust = -20
                                    end

                                    local adjustedDistance = EntityDistances[v.Name] + adjust
                                    local distanceToEntity = (PredictionPosition - hrp.Position).Magnitude

                                    if not Raycast and distanceToEntity <= (adjustedDistance * distMultiplier) then
                                        entityInRange = true
                                        local Prompt = GetHiding()
                                        if Prompt then
                                            pcall(function()
                                                fireproximityprompt(Prompt)
                                            end)
                                            task.wait(3)
                                        end
                                        break
                                    end
                                end
                            end

                            local char = LocalPlayer.Character
                            if char and not entityInRange and char:GetAttribute("Hiding") then
                                char:SetAttribute("Hiding", false)
                            end
                        end
                    end
                end
            end))
        else
            for _, conn in ipairs(Connections) do
                conn:Disconnect()
            end
            Connections = {}
        end
    end
})

B:Dropdown({
    Title = "自动隐藏模式",
    Values = {"Safety", "Close Call"},
    Default = "Safety",
    Callback = function(Value) end
})

B:Slider({
    Title = "预测时间",
    Value = {Min = 0.1, Max = 1.5, Default = 1.5},
    Suffix = "s",
    Callback = function(Value) end
})

B:Slider({
    Title = "距离倍数",
    Value = {Min = 1, Max = 1.5, Default = 1},
    Suffix = "x",
    Callback = function(Value) end
})

local AutoInteractDistance = 10
B:Toggle({
    Title = "自动互动",
    Default = false,
    Callback = function(Value)
        if Value then
            local RunService = game:GetService("RunService")
            local LocalPlayer = game.Players.LocalPlayer

            local AutoInteractConnection
            local CachedInteractables = {}
            local PromptSeen = {}
            local InteractableModels = {
                AlarmClock = true, GlitchCub = true, Aloe = true, BandagePack = true, Battery = true,
                TimerLever = true, OuterPart = true, BatteryPack = true, Candle = true, LiveBreakerPolePickup = true,
                Compass = true, Crucifix = true, ElectricalRoomKey = true, Flashlight = true, Glowstick = true,
                HolyHandGrenade = true, Lantern = true, LaserPointer = true, Lighter = true, Lockpick = true,
                LotusFlower = true, LotusPetalPickup = true, Multitool = true, NVCS3000 = true, OutdoorsKey = true,
                Shears = true, SkeletonKey = true, Smoothie = true, SolutionPaper = true, Spotlight = true,
                StarlightVial = true, StarlightJug = true, StarlightBottle = true, Vitamins = true,
            }

            local function PickRootPart(obj, prompt)
                if prompt and prompt.Parent and prompt.Parent:IsA("BasePart") then
                    return prompt.Parent
                end
                if obj:IsA("Model") then
                    if obj.PrimaryPart and obj.PrimaryPart:IsA("BasePart") then
                        return obj.PrimaryPart
                    end
                    local common = obj:FindFirstChild("Main", true) or obj:FindFirstChild("Handle", true) or obj:FindFirstChild("Door", true)
                    if common and common:IsA("BasePart") then
                        return common
                    end
                end
                return obj:FindFirstChildWhichIsA("BasePart", true)
            end

            local function AddPromptsFromObject(obj)
                for _, desc in ipairs(obj:GetDescendants()) do
                    if desc:IsA("ProximityPrompt") and not PromptSeen[desc] then
                        local root = PickRootPart(obj, desc)
                        if root then
                            PromptSeen[desc] = true
                            table.insert(CachedInteractables, {
                                prompt = desc,
                                part = root,
                                last = 0,
                            })
                        end
                    end
                end
            end

            local function CollectTargets(folder)
                for _, v in ipairs(folder:GetChildren()) do
                    if v:IsA("Model") or v:IsA("Folder") then
                        if v.Name == "DrawerContainer" or InteractableModels[v.Name] or v.Name == "RoomsLootItem" or v.Name == "Locker_Small" or v.Name == "Toolbox" or v.Name == "ChestBox" or v.Name == "Toolshed_Small" or v.Name == "CrucifixOnTheWall" then
                            AddPromptsFromObject(v)
                        end
                        CollectTargets(v)
                    end
                end
            end

            local function RefreshTargets()
                CachedInteractables = {}
                PromptSeen = {}
                local CurrentRoom = workspace.CurrentRooms[LocalPlayer:GetAttribute("CurrentRoom")]
                if not CurrentRoom then return end
                CollectTargets(CurrentRoom)
            end

            local lastCheck = 0
            local interval = 0.2

            local function AutoInteractStep(dt)
                lastCheck = lastCheck + dt
                if lastCheck < interval then return end
                lastCheck = 0

                if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Collision") then
                    return
                end                local charPos = LocalPlayer.Character.Collision.Position
                local now = tick()

                for i = #CachedInteractables, 1, -1 do
                    local entry = CachedInteractables[i]
                    local prompt, part = entry.prompt, entry.part

                    if not prompt or not prompt.Parent or not part or not part:IsDescendantOf(workspace) then
                        table.remove(CachedInteractables, i)
                    else
                        local dist = (part.Position - charPos).Magnitude
                        if dist <= AutoInteractDistance and (now - (entry.last or 0)) >= 0.35 then
                            entry.last = now
                            task.spawn(function()
                                pcall(function()
                                    fireproximityprompt(prompt)
                                end)
                            end)
                        end
                    end
                end
            end

            RefreshTargets()
            AutoInteractConnection = RunService.Heartbeat:Connect(AutoInteractStep)

            local attributeConn
            local roomDescConn

            attributeConn = LocalPlayer:GetAttributeChangedSignal("CurrentRoom"):Connect(function()
                RefreshTargets()
                if roomDescConn then
                    roomDescConn:Disconnect()
                    roomDescConn = nil
                end
                local cr = workspace.CurrentRooms[LocalPlayer:GetAttribute("CurrentRoom")]
                if cr then
                    roomDescConn = cr.DescendantAdded:Connect(function()
                        task.defer(RefreshTargets)
                    end)
                end
            end)

            local cr = workspace.CurrentRooms[LocalPlayer:GetAttribute("CurrentRoom")]
            if cr then
                roomDescConn = cr.DescendantAdded:Connect(function()
                    task.defer(RefreshTargets)
                end)
            end

            _G.StopAutoInteract = function()
                if AutoInteractConnection then
                    AutoInteractConnection:Disconnect()
                    AutoInteractConnection = nil
                end
                if attributeConn then
                    attributeConn:Disconnect()
                    attributeConn = nil
                end
                if roomDescConn then
                    roomDescConn:Disconnect()
                    roomDescConn = nil
                end
                CachedInteractables, PromptSeen = {}, {}
            end
        elseif _G.StopAutoInteract then
            _G.StopAutoInteract()
            _G.StopAutoInteract = nil
        end
    end
})

B:Slider({
    Title = "自动互动距离",
    Value = {Min = 1, Max = 20, Default = 10},
    Suffix = " studs",
    Callback = function(Value)
        AutoInteractDistance = Value
    end
})

B:Toggle({
    Title = "自动矿车推动",
    Default = false,
    Callback = function(Value)
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local LocalPlayer = Players.LocalPlayer
        local Workspace = game:GetService("Workspace")
        local Rooms = Workspace:WaitForChild("CurrentRooms")

        if _G.AutoMinecartConn then
            _G.AutoMinecartConn:Disconnect()
            _G.AutoMinecartConn = nil
        end
        if _G.AutoMinecartLoop then
            _G.AutoMinecartLoop:Disconnect()
            _G.AutoMinecartLoop = nil
        end

        if Value then
            local function tryPush(cartModel)
                local cart = cartModel:FindFirstChild("Cart")
                if not cart then return end
                local prompt = cart:FindFirstChild("PushPrompt")
                if not prompt then return end

                local character = LocalPlayer.Character
                local root = character and character:FindFirstChild("HumanoidRootPart")
                if not root then return end

                if (root.Position - prompt.Parent.Position).Magnitude <= (prompt.MaxActivationDistance or 10) then
                    fireproximityprompt(prompt)
                end
            end

            _G.AutoMinecartConn = Rooms.DescendantAdded:Connect(function(obj)
                if obj.Name == "MinecartMoving" then
                    task.defer(function()
                        tryPush(obj)
                    end)
                end
            end)

            _G.AutoMinecartLoop = RunService.Heartbeat:Connect(function()
                local character = LocalPlayer.Character
                local root = character and character:FindFirstChild("HumanoidRootPart")
                if not root then return end

                for _, obj in ipairs(Rooms:GetDescendants()) do
                    if obj.Name == "MinecartMoving" then
                        tryPush(obj)
                    end
                end
            end)
        else
            if _G.AutoMinecartConn then
                _G.AutoMinecartConn:Disconnect()
            end
            if _G.AutoMinecartLoop then
                _G.AutoMinecartLoop:Disconnect()
            end
            _G.AutoMinecartConn = nil
            _G.AutoMinecartLoop = nil
        end
    end
})

B:Toggle({
    Title = "自动破门",
    Default = false,
    Callback = function(Value)
        local connections = {}
        local running = false
        local targetNames = {"DoorPieceBottom", "DoorPieceTop"}

        local function safeDisconnect()
            for _, c in ipairs(connections) do
                if c and c.Disconnect then
                    pcall(function() c:Disconnect() end)
                elseif c and c.disconnect then
                    pcall(function() c:disconnect() end)
                end
            end
            connections = {}
        end

        local function handlePrompt(p)
            pcall(function() p.MaxActivationDistance = 40 end)
            if p.Enabled then
                pcall(fireproximityprompt, p)
            end
        end

        local function processModel(m)
            for _, n in ipairs(targetNames) do
                local part = m:FindFirstChild(n, true)
                if part then
                    for _, d in ipairs(part:GetDescendants()) do
                        if d:IsA("ProximityPrompt") then
                            pcall(handlePrompt, d)
                        end
                    end

                    local con = part.DescendantAdded:Connect(function(desc)
                        if desc:IsA("ProximityPrompt") then
                            pcall(function() task.defer(handlePrompt, desc) end)
                        end
                    end)
                    table.insert(connections, con)
                end
            end
        end

        local function scanAll()
            local cr = workspace:FindFirstChild("CurrentRooms")
            if not cr then return end

            for _, room in ipairs(cr:GetDescendants()) do
                if room:IsA("Model") or room:IsA("Folder") then
                    processModel(room)
                end
            end
        end

        if Value then
            running = true
            safeDisconnect()
            
            task.spawn(function()
                scanAll()
                local cr = workspace:FindFirstChild("CurrentRooms")
                if cr then
                    local con = cr.DescendantAdded:Connect(function(d)
                        if not running then return end
                        local model = d
                        while model and not (model:IsA("Model") or model:IsA("Folder")) do
                            model = model.Parent
                        end
                        if model then
                            task.defer(processModel, model)
                        end
                    end)
                    table.insert(connections, con)
                end

                while running and Value do
                    scanAll()
                    task.wait(0.8)
                end
            end)
        else
            running = false
            safeDisconnect()
        end
    end
})

B:Toggle({
    Title = "自动拾取",
    Default = false,
    Callback = function(Value)
        local connections = {}
        local running = false

        local function safeDisconnect()
            for _, c in ipairs(connections) do
                if c and c.Disconnect then
                    pcall(function() c:Disconnect() end)
                elseif c and c.disconnect then
                    pcall(function() c:disconnect() end)
                end
            end
            connections = {}
        end

        local function handlePrompt(p)
            pcall(function() p.MaxActivationDistance = 40 end)
            if p.Enabled then
                pcall(fireproximityprompt, p)
            end
        end

        local function processDrop(d)
            for _, desc in ipairs(d:GetDescendants()) do
                if desc:IsA("ProximityPrompt") then
                    pcall(handlePrompt, desc)
                end
            end

            local con = d.DescendantAdded:Connect(function(desc)
                if desc:IsA("ProximityPrompt") then
                    pcall(function() task.defer(handlePrompt, desc) end)
                end
            end)
            table.insert(connections, con)
        end

        local function scanDrops()
            local drops = workspace:FindFirstChild("Drops")
            if not drops then return end

            for _, child in ipairs(drops:GetChildren()) do
                if child:IsA("Model") or child:IsA("Folder") then
                    processDrop(child)
                end
            end
        end

        if Value then
            running = true
            safeDisconnect()
            
            task.spawn(function()
                scanDrops()
                local drops = workspace:FindFirstChild("Drops")
                if drops then
                    local con = drops.ChildAdded:Connect(function(c)
                        if not running then return end
                        if c:IsA("Model") or c:IsA("Folder") then
                            task.defer(processDrop, c)
                        end
                    end)
                    table.insert(connections, con)
                end

                while running and Value do
                    scanDrops()
                    task.wait(0.8)
                end
            end)
        else
            running = false
            safeDisconnect()
        end
    end
})

B:Toggle({
    Title = "自动房间",
    Default = false,
    Callback = function(enabled)
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local PathfindingService = game:GetService("PathfindingService")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local Workspace = game:GetService("Workspace")
        local player = Players.LocalPlayer
        local rooms = Workspace:WaitForChild("CurrentRooms")
        local gameData = ReplicatedStorage:WaitForChild("GameData")
        local floor = gameData:WaitForChild("Floor")
        local active = false
        local runner
        local clone

        local function stop()
            active = false
            if runner then
                runner:Disconnect()
                runner = nil
            end
            if clone and clone.Parent then
                clone:Destroy()
            end
            player:SetAttribute("AutoRoomsActive", false)
        end

        if not enabled then
            stop()
            return
        end

        player:SetAttribute("AutoRoomsActive", true)
        active = true

        if player.Character and player.Character:FindFirstChild("CollisionPart") then
            clone = player.Character.CollisionPart:Clone()
            clone.Name = "_AutoRoomsCollision"
            clone.Massless = true
            clone.Anchored = false
            clone.CanCollide = false
            clone.CanQuery = false
            clone.CustomPhysicalProperties = PhysicalProperties.new(0.01, 0.7, 0, 1, 1)
            clone.Parent = player.Character
        end

        local function findClosestLocker()
            local best, bestDist = nil, math.huge
            for _, obj in ipairs(rooms:GetDescendants()) do
                if obj.Name == "Rooms_Locker" or obj.Name == "Rooms_Locker_Fridge" then
                    if obj.PrimaryPart then
                        local dist = (player.Character.HumanoidRootPart.Position - obj.PrimaryPart.Position).Magnitude
                        if dist < bestDist then
                            best = obj
                            bestDist = dist
                        end
                    end
                end
            end
            return best
        end

        local function walkTo(target)
            local char = player.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end

            local path = PathfindingService:CreatePath({
                AgentRadius = 2,
                AgentHeight = 1,
                AgentCanJump = false,
                WaypointSpacing = 5,
            })

            path:ComputeAsync(char.HumanoidRootPart.Position, target.Position)

            if path.Status == Enum.PathStatus.Success then
                for _, waypoint in ipairs(path:GetWaypoints()) do
                    if not active then return end
                    char:FindFirstChildOfClass("Humanoid"):MoveTo(waypoint.Position)
                    char.Humanoid.MoveToFinished:Wait()
                end
            end
        end

        runner = RunService.Heartbeat:Connect(function()
            if not active then return end
            if floor.Value ~= "Rooms" then return stop() end
            if gameData.LatestRoom.Value >= 1000 then return stop() end

            local entity = Workspace:FindFirstChild("A60") or Workspace:FindFirstChild("A120") or Workspace:FindFirstChild("GlitchRush") or Workspace:FindFirstChild("GlitchAmbush")

            if entity and entity.PrimaryPart and entity.PrimaryPart.Position.Y > -6 then
                local locker = findClosestLocker()
                if locker and locker.PrimaryPart then
                    local hide = locker:FindFirstChild("HidePoint")
                    if not hide then
                        hide = Instance.new("Part")
                        hide.Name = "HidePoint"
                        hide.Anchored = true
                        hide.Transparency = 1
                        hide.CanCollide = false
                        hide.Position = locker.PrimaryPart.Position + (locker.PrimaryPart.CFrame.LookVector * 7)
                        hide.Parent = locker
                    end

                    walkTo(hide)
                    task.wait(0.1)

                    local prompt = locker:FindFirstChildOfClass("ProximityPrompt")
                    if prompt then
                        if fireproximityprompt then
                            fireproximityprompt(prompt)
                        else
                            prompt:InputHoldBegin()
                            prompt:InputHoldEnd()
                        end
                    end
                end
            else
                local currentRoom = gameData.LatestRoom.Value
                local door = rooms[currentRoom] and rooms[currentRoom]:FindFirstChild("Door", true)
                if door and door:FindFirstChild("Door") then
                    walkTo(door.Door)
                end
            end
        end)
    end
})

B:Toggle({
    Title = "自动门范围",
    Default = false,
    Callback = function(Value)
        local doorReachLoop

        if Value then
            local Rooms = workspace:FindFirstChild("CurrentRooms")
            if not Rooms then return end

            doorReachLoop = task.spawn(function()
                while Value do
                    for _, room in pairs(Rooms:GetChildren()) do
                        local door = room:FindFirstChild("Door")
                        if door and door:FindFirstChild("ClientOpen") then
                            door.ClientOpen:FireServer()
                        end
                    end
                    task.wait(0.5)
                end
            end)
            WindUI:Notify("自动门", "自动门范围已启用", 3)
        else
            doorReachLoop = nil
            WindUI:Notify("自动门", "自动门范围已禁用", 3)
        end
    end
})

B:Toggle({
    Title = "即时互动",
    Default = false,
    Callback = function(Value)
        if getgenv().ProximityConnection then
            getgenv().ProximityConnection:Disconnect()
            getgenv().ProximityConnection = nil
        end

        local function modifyPrompt(prompt, instant)
            if not prompt:IsA("ProximityPrompt") then return end
            if instant then
                if not prompt:GetAttribute("OriginalHoldDuration") then
                    prompt:SetAttribute("OriginalHoldDuration", prompt.HoldDuration)
                    prompt:SetAttribute("OriginalLineOfSight", prompt.RequiresLineOfSight)
                end
                prompt.HoldDuration = 0
                prompt.RequiresLineOfSight = false
            else
                prompt.HoldDuration = prompt:GetAttribute("OriginalHoldDuration") or 1
                prompt.RequiresLineOfSight = prompt:GetAttribute("OriginalLineOfSight") or true
            end
        end

        local currentRooms = workspace:FindFirstChild("CurrentRooms")
        if currentRooms then
            for _, prompt in ipairs(currentRooms:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    modifyPrompt(prompt, Value)
                end
            end
        end

        if Value and currentRooms then
            getgenv().ProximityConnection = currentRooms.DescendantAdded:Connect(function(descendant)
                if descendant:IsA("ProximityPrompt") then
                    modifyPrompt(descendant, true)
                end
            end)
        end

        WindUI:Notify("即时互动", Value and "已启用" or "已禁用", 3)
    end
})

B:Slider({
    Title = "既时互动范围提升",
    Value = {Min = 1, Max = 5, Default = 1},
    Suffix = "x",
    Callback = function(multiplier)
        local originalRanges = {}
        local rangeConnections = {}

        local function updateProximityPromptRanges(multiplier)
            local function modifyPrompt(prompt)
                if not originalRanges[prompt] then
                    originalRanges[prompt] = prompt.MaxActivationDistance
                end
                prompt.MaxActivationDistance = originalRanges[prompt] * multiplier
            end

            for _, descendant in pairs(workspace:GetDescendants()) do
                if descendant:IsA("ProximityPrompt") then
                    modifyPrompt(descendant)
                end
            end
            for _, player in pairs(game.Players:GetPlayers()) do
                if player.PlayerGui then
                    for _, descendant in pairs(player.PlayerGui:GetDescendants()) do
                        if descendant:IsA("ProximityPrompt") then
                            modifyPrompt(descendant)
                        end
                    end
                end
            end
        end

        local function setupRangeConnections(multiplier)
            for _, connection in pairs(rangeConnections) do
                connection:Disconnect()
            end
            rangeConnections = {}

            table.insert(rangeConnections, workspace.DescendantAdded:Connect(function(descendant)
                if descendant:IsA("ProximityPrompt") then
                    task.wait(0.1)
                    originalRanges[descendant] = descendant.MaxActivationDistance
                    descendant.MaxActivationDistance = originalRanges[descendant] * multiplier
                end
            end))

            for _, player in pairs(game.Players:GetPlayers()) do
                if player.PlayerGui then
                    table.insert(rangeConnections, player.PlayerGui.DescendantAdded:Connect(function(descendant)
                        if descendant:IsA("ProximityPrompt") then
                            task.wait(0.1)
                            originalRanges[descendant] = descendant.MaxActivationDistance
                            descendant.MaxActivationDistance = originalRanges[descendant] * multiplier
                        end
                    end))
                end
            end
        end

        if multiplier == 1 then
            for prompt, originalRange in pairs(originalRanges) do
                if prompt and prompt.Parent then
                    prompt.MaxActivationDistance = originalRange
                end
            end
            for _, connection in pairs(rangeConnections) do
                connection:Disconnect()
            end
            rangeConnections = {}
        else
            updateProximityPromptRanges(multiplier)
            setupRangeConnections(multiplier)
        end

        WindUI:Notify("互动范围", "已设置为 " .. multiplier .. "x", 3)
    end
})

B:Button({
    Title = "过一道门",
    Callback = function()
        pcall(function()
            local HasKey = false
            local LatestRoom = game:GetService("ReplicatedStorage").GameData.LatestRoom.Value
            local CurrentDoor = workspace.CurrentRooms[tostring(LatestRoom)]:WaitForChild("Door")
            for i,v in ipairs(CurrentDoor.Parent:GetDescendants()) do
                if v.Name == "KeyObtain" then
                    HasKey = v
                end
            end
            if HasKey then
                game.Players.LocalPlayer.Character:PivotTo(CFrame.new(HasKey.Hitbox.Position))
                task.wait(0.3)
                fireproximityprompt(HasKey.ModulePrompt,0)
                game.Players.LocalPlayer.Character:PivotTo(CFrame.new(CurrentDoor.Door.Position))
                task.wait(0.3)
                fireproximityprompt(CurrentDoor.Lock.UnlockPrompt,0)
            end
            if LatestRoom == 50 then
                CurrentDoor = workspace.CurrentRooms[tostring(LatestRoom+1)]:WaitForChild("Door")
            end
            game.Players.LocalPlayer.Character:PivotTo(CFrame.new(CurrentDoor.Door.Position))
            task.wait(0.3)
            CurrentDoor.ClientOpen:FireServer()
            WindUI:Notify("过门", "已通过当前门", 2)
        end)
    end
})

local autoSkipActive = false
local autoSkipTask = nil

local function startAutoSkip()
    if autoSkipTask then return end
    autoSkipTask = task.spawn(function()
        while autoSkipActive do
            task.wait()
            pcall(function()
                if autoSkipActive and game:GetService("ReplicatedStorage").GameData.LatestRoom.Value < 100 then
                    local HasKey = false
                    local LatestRoom = game:GetService("ReplicatedStorage").GameData.LatestRoom.Value
                    local CurrentDoor = workspace.CurrentRooms[tostring(LatestRoom)]:WaitForChild("Door")
                    for i,v in ipairs(CurrentDoor.Parent:GetDescendants()) do
                        if v.Name == "KeyObtain" then
                            HasKey = v
                        end
                    end
                    if HasKey then
                        game.Players.LocalPlayer.Character:PivotTo(CFrame.new(HasKey.Hitbox.Position))
                        task.wait(0.3)
                        fireproximityprompt(HasKey.ModulePrompt,0)
                        game.Players.LocalPlayer.Character:PivotTo(CFrame.new(CurrentDoor.Door.Position))
                        task.wait(0.3)
                        fireproximityprompt(CurrentDoor.Lock.UnlockPrompt,0)
                    end
                    if LatestRoom == 50 then
                        CurrentDoor = workspace.CurrentRooms[tostring(LatestRoom+1)]:WaitForChild("Door")
                    end
                    game.Players.LocalPlayer.Character:PivotTo(CFrame.new(CurrentDoor.Door.Position))
                    task.wait(0.3)
                    CurrentDoor.ClientOpen:FireServer()
                end
            end)
        end
    end)
end

local function stopAutoSkip()
    if autoSkipTask then
        coroutine.close(autoSkipTask)
        autoSkipTask = nil
    end
end

B:Toggle({
    Title = "连续过门",
    Default = false,
    Callback = function(state)
        playClickSound()
        autoSkipActive = state
        if state then
            startAutoSkip()
            WindUI:Notify("连续过门", "已启用，将自动通过门", 2)
        else
            stopAutoSkip()
            WindUI:Notify("连续过门", "已禁用", 2)
        end
    end
})

B:Toggle({
    Title = "自动治疗",
    Default = false,
    Callback = function(Value)
        local healingItems = {"Bandage", "BandagePack", "Aloe", "Herb"}
        local running = false
        local conn = nil
        
        local function getHealth()
            local char = game.Players.LocalPlayer.Character
            if not char then return 100 end
            local hum = char:FindFirstChild("Humanoid")
            return hum and hum.Health or 100
        end
        
        local function getMaxHealth()
            local char = game.Players.LocalPlayer.Character
            if not char then return 100 end
            local hum = char:FindFirstChild("Humanoid")
            return hum and hum.MaxHealth or 100
        end
        
        local function useItem(item)
            local tool = item.Parent
            if tool and tool:IsA("Tool") then
                local activateRemote = tool:FindFirstChild("ActivateRemote") or tool:FindFirstChild("Remote")
                if activateRemote then
                    pcall(function() activateRemote:FireServer() end)
                end
                local remoteEvent = tool:FindFirstChildOfClass("RemoteEvent")
                if remoteEvent then
                    pcall(function() remoteEvent:FireServer() end)
                end
            end
        end
        
        local function findHealingItem()
            local char = game.Players.LocalPlayer.Character
            local backpack = game.Players.LocalPlayer.Backpack
            
            for _, name in ipairs(healingItems) do
                if char then
                    local tool = char:FindFirstChild(name)
                    if tool and tool:IsA("Tool") then
                        return tool, name
                    end
                end
                if backpack then
                    local tool = backpack:FindFirstChild(name)
                    if tool and tool:IsA("Tool") then
                        return tool, name
                    end
                end
            end
            return nil, nil
        end
        
        if Value then
            running = true
            conn = game:GetService("RunService").Heartbeat:Connect(function()
                if not running then return end
                local health = getHealth()
                local maxHealth = getMaxHealth()
                
                if health < maxHealth and health < 60 then
                    local item, name = findHealingItem()
                    if item then
                        pcall(function() useItem(item) end)
                        WindUI:Notify("自动治疗", "使用了 " .. name, 1)
                        task.wait(0.5)
                    end
                end
            end)
        else
            running = false
            if conn then conn:Disconnect() end
        end
    end
})

B:Toggle({
    Title = "自动图书馆密码",
    Default = false,
    Callback = function(Value)
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local RemoteFolder = ReplicatedStorage:FindFirstChild("RemotesFolder") or ReplicatedStorage:FindFirstChild("EntityInfo")
        
        if not RemoteFolder then
            WindUI:Notify("错误", "未找到远程文件夹", 3)
            return
        end
        
        local PL = RemoteFolder:FindFirstChild("PL")
        if not PL then
            WindUI:Notify("错误", "未找到PL远程事件", 3)
            return
        end
        
        local padlockSolved = false
        local paperScanned = {}
        local conn = nil
        local codePrinted = false
        
        local function parsePaperCode(paper)
            local codeTable = {}
            local ui = paper:FindFirstChild("UI")
            if not ui then return nil end
            
            for _, img in ipairs(ui:GetChildren()) do
                if img:IsA("ImageLabel") and tonumber(img.Name) then
                    local key = img.ImageRectOffset.X .. "_" .. img.ImageRectOffset.Y
                    codeTable[key] = {tonumber(img.Name), "_"}
                end
            end
            
            local hints = LocalPlayer.PlayerGui:FindFirstChild("PermUI")
            if hints then
                local hintsContainer = hints:FindFirstChild("Hints")
                if hintsContainer then
                    for _, icon in ipairs(hintsContainer:GetChildren()) do
                        if icon.Name == "Icon" then
                            local key = icon.ImageRectOffset.X .. "_" .. icon.ImageRectOffset.Y
                            if codeTable[key] then
                                local label = icon:FindFirstChildWhichIsA("TextLabel")
                                if label then
                                    codeTable[key][2] = label.Text
                                end
                            end
                        end
                    end
                end
            end
            
            local result = {}
            for i = 1, 5 do
                for _, v in pairs(codeTable) do
                    if v[1] == i then
                        result[i] = v[2]
                        break
                    end
                end
            end
            
            return table.concat(result)
        end
        
        local function solvePadlock()
            if padlockSolved then return end
            
            local char = LocalPlayer.Character
            local backpack = LocalPlayer.Backpack
            
            local function checkContainer(container)
                if not container then return nil end
                for _, tool in ipairs(container:GetChildren()) do
                    if tool:IsA("Tool") and (tool.Name == "LibraryHintPaper" or tool.Name == "LibraryHintPaperHard") then
                        if not paperScanned[tool] then
                            paperScanned[tool] = true
                            local code = parsePaperCode(tool)
                            if code and #code == 5 and code:match("%d%d%d%d%d") then
                                local padlock = workspace:FindFirstChild("Padlock", true)
                                if padlock then
                                    local dist = (char and char:FindFirstChild("HumanoidRootPart") and (char.HumanoidRootPart.Position - padlock:GetPivot().Position).Magnitude) or 999
                                    if dist <= 30 then
                                        pcall(function() PL:FireServer(code) end)
                                        padlockSolved = true
                                        if not codePrinted then
                                            WindUI:Notify("图书馆", "密码已输入: " .. code, 3)
                                            codePrinted = true
                                        end
                                        return true
                                    end
                                end
                            end
                        end
                    end
                end
                return nil
            end
            
            checkContainer(char)
            checkContainer(backpack)
        end
        
        local function onRoomChange()
            padlockSolved = false
            paperScanned = {}
            codePrinted = false
            
            local currentRoom = LocalPlayer:GetAttribute("CurrentRoom")
            if currentRoom == 49 or currentRoom == 50 then
                solvePadlock()
            end
        end
        
        if Value then
            onRoomChange()
            
            if conn then conn:Disconnect() end
            conn = LocalPlayer:GetAttributeChangedSignal("CurrentRoom"):Connect(function()
                onRoomChange()
            end)
            
            local charConn
            charConn = LocalPlayer.CharacterAdded:Connect(function()
                task.wait(2)
                if LocalPlayer:GetAttribute("CurrentRoom") == 49 or LocalPlayer:GetAttribute("CurrentRoom") == 50 then
                    solvePadlock()
                end
            end)
            
            local function onChildAdded(child)
                if child:IsA("Tool") and (child.Name == "LibraryHintPaper" or child.Name == "LibraryHintPaperHard") then
                    task.wait(0.5)
                    solvePadlock()
                end
            end
            
            if LocalPlayer.Character then
                LocalPlayer.Character.ChildAdded:Connect(onChildAdded)
            end
            LocalPlayer.Backpack.ChildAdded:Connect(onChildAdded)
            
            task.spawn(function()
                while Value do
                    task.wait(1)
                    if LocalPlayer:GetAttribute("CurrentRoom") == 49 or LocalPlayer:GetAttribute("CurrentRoom") == 50 then
                        solvePadlock()
                    end
                end
            end)
        else
            if conn then conn:Disconnect() end
        end
    end
})

Y:Toggle({
    Title = "处于眩晕状态",
    Default = false,
    Callback = function(state)
        local character = LocalPlayer.Character
        if character then
            character:SetAttribute("Stunned", state)
        end
        WindUI:Notify("眩晕", state and "已启用" or "已禁用", 2)
    end
})

local Oxygenslider = Y:Slider({
    Title = "氧气值",
    Value = { Min = 0, Max = 100, Default = 100 },
    Callback = function(value)
        local character = LocalPlayer.Character
        if character then
            character:SetAttribute("Oxygen", value)
        end
        WindUI:Notify("氧气", "当前氧气值: " .. value, 1)
    end
})

local SpeedBoostSlider = m:Slider({
    Title = "速度增益(修改为5最合适)",
    Value = { Min = 0, Max = 10, Default = 0 },
    Callback = function(value)
        local character = LocalPlayer.Character
        if character then
            character:SetAttribute("SpeedBoost", value)
        end
        WindUI:Notify("速度增益", "当前增益: " .. value, 1)
    end
})

m:Toggle({
    Title = "Figure无敌模式",
    Default = false,
    Callback = function(value)
        if value then
            local function makeFigureInvincible()
                for _, figure in pairs(workspace.CurrentRooms:GetDescendants()) do
                    if figure:IsA("Model") and (figure.Name == "FigureRagdoll" or figure.Name == "FigureRig") then
                        for _, part in pairs(figure:GetDescendants()) do
                            if part:IsA("BasePart") then
                                if not part:GetAttribute("OriginalCanTouch") then
                                    part:SetAttribute("OriginalCanTouch", part.CanTouch)
                                end
                                if not part:GetAttribute("OriginalCanCollide") then
                                    part:SetAttribute("OriginalCanCollide", part.CanCollide)
                                end
                                part.CanTouch = false
                                part.CanCollide = false
                            end
                        end
                    end
                end
            end
            
            makeFigureInvincible()
            
            if not _G.FigureGodmodeConn then
                _G.FigureGodmodeConn = workspace.CurrentRooms.DescendantAdded:Connect(function(child)
                    if value and (child.Name == "FigureRagdoll" or child.Name == "FigureRig") then
                        task.wait(0.5)
                        for _, part in pairs(child:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanTouch = false
                                part.CanCollide = false
                            end
                        end
                    end
                end)
            end
            
            WindUI:Notify("Figure无敌模式", "Figure将无法攻击你", 2)
        else
            if _G.FigureGodmodeConn then
                _G.FigureGodmodeConn:Disconnect()
                _G.FigureGodmodeConn = nil
            end
            
            for _, figure in pairs(workspace.CurrentRooms:GetDescendants()) do
                if figure:IsA("Model") and (figure.Name == "FigureRagdoll" or figure.Name == "FigureRig") then
                    for _, part in pairs(figure:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanTouch = part:GetAttribute("OriginalCanTouch") or true
                            part.CanCollide = part:GetAttribute("OriginalCanCollide") or true
                        end
                    end
                end
            end
            
            WindUI:Notify("Figure无敌模式", "已禁用", 2)
        end
    end
})

Y:Toggle({
    Title = "上帝模式",
    Default = false,
    Callback = function(value)
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        local collision = character and character:FindFirstChild("Collision")
        
        local function enableGodmode()
            if humanoid and collision then
                humanoid.HipHeight = 3.01
                task.wait()
                collision.Position = collision.Position - Vector3.new(0, 8, 0)
                task.wait()
                humanoid.HipHeight = 3
            end
        end
        
        local function disableGodmode()
            if humanoid and collision then
                humanoid.HipHeight = 3.01
                task.wait()
                collision.Position = collision.Position + Vector3.new(0, 8, 0)
                task.wait()
                humanoid.HipHeight = 3
            end
        end
        
        if value then
            enableGodmode()
            if not _G.GodmodeConn then
                _G.GodmodeConn = LocalPlayer.CharacterAdded:Connect(function(newChar)
                    task.wait(0.5)
                    local newHumanoid = newChar:FindFirstChild("Humanoid")
                    local newCollision = newChar:FindFirstChild("Collision")
                    if newHumanoid and newCollision then
                        newHumanoid.HipHeight = 3.01
                        task.wait()
                        newCollision.Position = newCollision.Position - Vector3.new(0, 8, 0)
                        task.wait()
                        newHumanoid.HipHeight = 3
                    end
                end)
            end
            local remoteFolder = game:GetService("ReplicatedStorage"):FindFirstChild("RemotesFolder") or game:GetService("ReplicatedStorage"):FindFirstChild("EntityInfo")
            if remoteFolder and remoteFolder:FindFirstChild("Crouch") then
                remoteFolder.Crouch:FireServer(true)
            end
            WindUI:Notify("上帝模式", "已启用，你将免疫所有伤害", 3)
        else
            disableGodmode()
            if _G.GodmodeConn then
                _G.GodmodeConn:Disconnect()
                _G.GodmodeConn = nil
            end
            local remoteFolder = game:GetService("ReplicatedStorage"):FindFirstChild("RemotesFolder") or game:GetService("ReplicatedStorage"):FindFirstChild("EntityInfo")
            if remoteFolder and remoteFolder:FindFirstChild("Crouch") then
                remoteFolder.Crouch:FireServer(false)
            end
            WindUI:Notify("上帝模式", "已禁用", 2)
        end
    end
})

Y:Toggle({
    Title = "无限复活",
    Default = false,
    Callback = function(value)
        local remotesFolder = game:GetService("ReplicatedStorage"):FindFirstChild("RemotesFolder") or game:GetService("ReplicatedStorage"):FindFirstChild("EntityInfo")
        
        local function revive()
            if remotesFolder and remotesFolder:FindFirstChild("Revive") then
                remotesFolder.Revive:FireServer()
            end
        end
        
        if value then
            if not LocalPlayer:GetAttribute("Alive") then
                task.wait(1.25)
                revive()
            end
            
            if not _G.InfReviveConn then
                _G.InfReviveConn = LocalPlayer:GetAttributeChangedSignal("Alive"):Connect(function()
                    if Y:GetValue("无限复活") and not LocalPlayer:GetAttribute("Alive") then
                        task.wait(1.25)
                        revive()
                        WindUI:Notify("无限复活", "检测到死亡，正在复活...", 2)
                    end
                end)
            end
            
            WindUI:Notify("无限复活", "已启用，死亡后将自动复活", 3)
        else
            if _G.InfReviveConn then
                _G.InfReviveConn:Disconnect()
                _G.InfReviveConn = nil
            end
            WindUI:Notify("无限复活", "已禁用", 2)
        end
    end
})

WindUI:Notify("脚本已加载", "哨兵脚本", 3)