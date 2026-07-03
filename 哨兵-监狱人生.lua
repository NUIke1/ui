local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/KingScriptAE/No-sirve-nada./refs/heads/main/main.lua"))()

WindUI.TransparencyValue = 0.2
WindUI:SetTheme("Dark")

local function gradient(text, startColor, endColor)
    local result = ""
    local chars = {}
    for uchar in text:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
        table.insert(chars, uchar)
    end
    local length = #chars
    for i = 1, length do
        local t = (i - 1) / math.max(length - 1, 1)
        local r = math.floor((startColor.R + (endColor.R - startColor.R) * t) * 255)
        local g = math.floor((startColor.G + (endColor.G - startColor.G) * t) * 255)
        local b = math.floor((startColor.B + (endColor.B - startColor.B) * t) * 255)
        result = result .. string.format('<font color="rgb(%d,%d,%d)">%s</font>', r, g, b, chars[i])
    end
    return result
end

WindUI:Popup({
    Title = gradient("哨兵 您当前版本为: Demo", Color3.fromRGB(255, 0, 0), Color3.fromRGB(200, 50, 50)),
    Icon = "sparkles",
    Content = "loc:LIB_DESC",
    Buttons = {
        {
            Title = "Get Started",
            Icon = "arrow-right",
            Variant = "Primary",
            Callback = function() end
        }
    }
})

local Window = WindUI:CreateWindow({
    Title = "哨兵-监狱人生",
    Icon = "geist:window",
    Author = "loc:WELCOME",
    Folder = "WindUI_Example",
    Size = UDim2.fromOffset(580, 490),
    Theme = "Dark",
    Background = "https://raw.githubusercontent.com/NUIke1/Sentinel/refs/heads/main/Image_1782813742703_356.jpg",
    BackgroundImageTransparency = 0.5, 
    User = {
        Enabled = true,
        Anonymous = true,
        Callback = function()
            WindUI:Notify({
                Title = "User Profile",
                Content = "User profile clicked!",
                Duration = 3
            })
        end
    },
    Acrylic = true,
    HideSearchBar = false,
    SideBarWidth = 200,
})

Window:Tag({
    Title = "V2",
    Color = Color3.fromHex("#FF0000")
})
Window:Tag({
    Title = "测试",
    Color = Color3.fromHex("#FF0000")
})
local TimeTag = Window:Tag({
    Title = "哨兵-监狱人生",
    Radius = 0,
    Color = WindUI:Gradient({
        ["0"]   = { Color = Color3.fromHex("#FF0F7B"), Transparency = 0.3 },
        ["100"] = { Color = Color3.fromHex("#F89B29"), Transparency = 0.3 },
    }, {
        Rotation = 45,
    }),
})

local hue = 0

task.spawn(function()
    while true do
        local now = os.date("*t")
        local hours = string.format("%02d", now.hour)
        local minutes = string.format("%02d", now.min)
        
        hue = (hue + 0.01) % 1
        local color = Color3.fromHSV(hue, 1, 1)
        
        TimeTag:SetTitle(hours .. ":" .. minutes)

        task.wait(0.06)
    end
end)

Window:CreateTopbarButton("theme-switcher", "moon", function()
    WindUI:SetTheme(WindUI:GetCurrentTheme() == "Dark" and "Light" or "Dark")
    WindUI:Notify({
        Title = "Theme Changed",
        Content = "Current theme: "..WindUI:GetCurrentTheme(),
        Duration = 2
    })
end, 990)

local Main = Window:Section({ 
    Title = "主要", 
    Opened = true 
})

local AimTab = Main:Tab({ 
    Title = "Aim", 
    Icon = "crosshair", 
    Desc = "自瞄功能" 
})

local toggleState = false
local aimConnection = nil
local oldnamecall = nil
local hookActive = false

local camera = workspace.CurrentCamera
local players = game:GetService("Players")
local runservice = game:GetService("RunService")
local userinputservice = game:GetService("UserInputService")
local localplayer = players.LocalPlayer
local closesthitpart = nil

local function getdirection(origin, position)
    return (position - origin).Unit
end

local function isvisible(targetpart)
    local character = localplayer.Character
    if not character then return false end
    
    local origin = camera.CFrame.Position
    local direction = (targetpart.Position - origin)
    
    local raycastparams = RaycastParams.new()
    raycastparams.FilterType = Enum.RaycastFilterType.Exclude
    raycastparams.FilterDescendantsInstances = {character, camera}
    raycastparams.IgnoreWater = true
    
    local result = workspace:Raycast(origin, direction, raycastparams)
    
    if result then
        return result.Instance:IsDescendantOf(targetpart.Parent)
    end
    
    return true
end

local function issameteam(player)
    if localplayer.Team == nil or player.Team == nil then
        return false
    end
    return localplayer.Team == player.Team
end

local function getclosestplayer()
    local closestpart = nil
    local closestdistance = math.huge
    
    for _, player in pairs(players:GetPlayers()) do
        if player ~= localplayer and player.Character then
            if issameteam(player) then
                continue
            end
            
            local humanoidrootpart = player.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = player.Character:FindFirstChild("Humanoid")
            
            if humanoidrootpart and humanoid and humanoid.Health > 0 then
                local screenpos, onscreen = camera:WorldToViewportPoint(humanoidrootpart.Position)
                
                if onscreen then
                    local mousepos = userinputservice:GetMouseLocation()
                    local distance = (Vector2.new(screenpos.X, screenpos.Y) - mousepos).Magnitude
                    
                    if distance < closestdistance then
                        closestdistance = distance
                        closestpart = humanoidrootpart
                    end
                end
            end
        end
    end
    
    return closestpart
end

local function startAim()
    if aimConnection then return end
    aimConnection = runservice.Heartbeat:Connect(function()
        if hookActive then
            closesthitpart = getclosestplayer()
        end
    end)
end

local function stopAim()
    if aimConnection then
        aimConnection:Disconnect()
        aimConnection = nil
    end
    closesthitpart = nil
end

local function hookRaycast()
    if oldnamecall then return end
    hookActive = true
    oldnamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
        local method = getnamecallmethod()
        local args = {...}
        local self = args[1]

        if self == workspace and not checkcaller() and method == "Raycast" then
            local hitpart = closesthitpart
            
            if hitpart then
                local origin = args[2]
                local direction = getdirection(origin, hitpart.Position) * 1000
                args[2] = origin
                args[3] = direction
                return oldnamecall(unpack(args))
            end
        end

        return oldnamecall(...)
    end))
end

local function unhookRaycast()
    if oldnamecall then
        hookActive = false
        oldnamecall = nil
    end
end

AimTab:Toggle({
    Title = "美国子弹",
    Desc = "自瞄辅助",
    Value = false,
    Callback = function(state) 
        toggleState = state
        if state then
            startAim()
            hookRaycast()
        else
            hookActive = false
            stopAim()
            unhookRaycast()
        end
        WindUI:Notify({
            Title = "提示",
            Content = state and "你已开启美国子弹" or "你已关闭美国子弹",
            Icon = state and "check" or "x",
            Duration = 2
        })
    end
})

AimTab:Button({
    Title = "飞行",
    Desc = "你妈妈飞走喽",
    Value = false,
    Callback = function(state) 
        toggleState = state
        if state then
            loadstring(game:HttpGet("https://raw.githubusercontent.com/KingScriptAE/No-sirve-nada./refs/heads/main/main.lua"))()
        WindUI:Notify({
            Title = "提示",
            Content = state and "你已开启飞行" or "你无法关闭",
            Icon = state and "check" or "x",
            Duration = 2
        })
    end
})

local featureToggle = ElementsSection:Button({
    Title = "删除门",
    Desc = "删删😍",
    Value = false,
    Callback = function()
        local a = game.Workspace.Doors
        a:Destroy()
    end
})

local EspTab = Main:Tab({ 
    Title = "Esp", 
    Icon = "eye", 
    Desc = "透视功能" 
})

local espEnabled = false
local espRenderConnection = nil
local espObjects = {}
local espDrawings = {}
local localPlayer = game.Players.LocalPlayer
local espCamera = workspace.CurrentCamera

local espSettings = {
    Box = true,
    Name = true,
    Health = true,
    Skeleton = false,
    Tracer = false,
    BoxColor = Color3.fromRGB(255, 255, 255),
    NameColor = Color3.fromRGB(255, 255, 255),
    HealthColor = Color3.fromRGB(0, 255, 0),
    SkeletonColor = Color3.fromRGB(255, 255, 255),
    TracerColor = Color3.fromRGB(255, 255, 255)
}

local R15Bones = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"}
}

local R6Bones = {
    {"Head", "Torso"},
    {"Torso", "Left Arm"},
    {"Torso", "Right Arm"},
    {"Torso", "Left Leg"},
    {"Torso", "Right Leg"}
}

local function CreateESPDrawings(player)
    local drawings = {}
    
    drawings.Box = Drawing.new("Square")
    drawings.Box.Thickness = 1
    drawings.Box.Filled = false
    drawings.Box.Visible = false
    drawings.Box.ZIndex = 1
    
    drawings.Name = Drawing.new("Text")
    drawings.Name.Size = 14
    drawings.Name.Center = true
    drawings.Name.Outline = true
    drawings.Name.Visible = false
    drawings.Name.ZIndex = 2
    
    drawings.HealthBg = Drawing.new("Square")
    drawings.HealthBg.Thickness = 0
    drawings.HealthBg.Filled = true
    drawings.HealthBg.Transparency = 0.5
    drawings.HealthBg.Visible = false
    drawings.HealthBg.ZIndex = 1
    
    drawings.Health = Drawing.new("Square")
    drawings.Health.Thickness = 0
    drawings.Health.Filled = true
    drawings.Health.Visible = false
    drawings.Health.ZIndex = 2
    
    drawings.Tracer = Drawing.new("Line")
    drawings.Tracer.Thickness = 1
    drawings.Tracer.Visible = false
    drawings.Tracer.ZIndex = 1
    
    drawings.Skeleton = {}
    for i = 1, 15 do
        drawings.Skeleton[i] = Drawing.new("Line")
        drawings.Skeleton[i].Thickness = 1
        drawings.Skeleton[i].Visible = false
        drawings.Skeleton[i].ZIndex = 1
    end
    
    espDrawings[player] = drawings
    return drawings
end

local function RemoveESPDrawings(player)
    if espDrawings[player] then
        for _, obj in pairs(espDrawings[player]) do
            if type(obj) == "table" then
                for _, line in pairs(obj) do
                    line:Remove()
                end
            else
                obj:Remove()
            end
        end
        espDrawings[player] = nil
    end
end

local function UpdateESP()
    if not espEnabled then return end
    
    for _, player in pairs(players:GetPlayers()) do
        if player == localPlayer then continue end
        
        local char = player.Character
        if not char then
            if espDrawings[player] then
                for _, obj in pairs(espDrawings[player]) do
                    if type(obj) == "table" then
                        for _, line in pairs(obj) do
                            line.Visible = false
                        end
                    else
                        obj.Visible = false
                    end
                end
            end
            continue
        end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not hum or not root or hum.Health <= 0 then
            if espDrawings[player] then
                for _, obj in pairs(espDrawings[player]) do
                    if type(obj) == "table" then
                        for _, line in pairs(obj) do
                            line.Visible = false
                        end
                    else
                        obj.Visible = false
                    end
                end
            end
            continue
        end
        
        if not espDrawings[player] then
            CreateESPDrawings(player)
        end
        
        local drawings = espDrawings[player]
        local pos, onScreen = espCamera:WorldToViewportPoint(root.Position)
        
        if not onScreen then
            for _, obj in pairs(drawings) do
                if type(obj) == "table" then
                    for _, line in pairs(obj) do
                        line.Visible = false
                    end
                else
                    obj.Visible = false
                end
            end
            continue
        end
        
        local head = char:FindFirstChild("Head")
        if not head then continue end
        
        local headPos, _ = espCamera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.7, 0))
        local footPos, _ = espCamera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
        
        local height = math.abs(headPos.Y - footPos.Y)
        local width = height / 1.6
        local centerX = pos.X
        local centerY = pos.Y
        
        if espSettings.Box then
            drawings.Box.Visible = true
            drawings.Box.Size = Vector2.new(width, height)
            drawings.Box.Position = Vector2.new(centerX - width/2, centerY - height/2)
            drawings.Box.Color = espSettings.BoxColor
        else
            drawings.Box.Visible = false
        end
        
        if espSettings.Name then
            drawings.Name.Visible = true
            drawings.Name.Text = player.Name
            drawings.Name.Position = Vector2.new(centerX, centerY - height/2 - 16)
            drawings.Name.Color = espSettings.NameColor
        else
            drawings.Name.Visible = false
        end
        
        if espSettings.Health then
            local healthPercent = hum.Health / hum.MaxHealth
            local healthColor = Color3.fromRGB(0, 255, 0)
            if healthPercent < 0.25 then healthColor = Color3.fromRGB(255, 0, 0)
            elseif healthPercent < 0.5 then healthColor = Color3.fromRGB(255, 170, 0)
            elseif healthPercent < 0.75 then healthColor = Color3.fromRGB(255, 255, 0) end
            
            drawings.HealthBg.Visible = true
            drawings.HealthBg.Size = Vector2.new(4, height)
            drawings.HealthBg.Position = Vector2.new(centerX - width/2 - 6, centerY - height/2)
            drawings.HealthBg.Color = Color3.fromRGB(0, 0, 0)
            
            drawings.Health.Visible = true
            drawings.Health.Size = Vector2.new(2, height * healthPercent)
            drawings.Health.Position = Vector2.new(centerX - width/2 - 5, centerY + height/2 - (height * healthPercent))
            drawings.Health.Color = healthColor
        else
            drawings.HealthBg.Visible = false
            drawings.Health.Visible = false
        end
        
        if espSettings.Tracer then
            local screenCenter = Vector2.new(espCamera.ViewportSize.X / 2, espCamera.ViewportSize.Y)
            drawings.Tracer.Visible = true
            drawings.Tracer.From = screenCenter
            drawings.Tracer.To = Vector2.new(centerX, centerY)
            drawings.Tracer.Color = espSettings.TracerColor
        else
            drawings.Tracer.Visible = false
        end
        
        if espSettings.Skeleton then
            local bones = hum.RigType == Enum.HumanoidRigType.R15 and R15Bones or R6Bones
            for i, bonePair in ipairs(bones) do
                local part1 = char:FindFirstChild(bonePair[1])
                local part2 = char:FindFirstChild(bonePair[2])
                if part1 and part2 then
                    local pos1, on1 = espCamera:WorldToViewportPoint(part1.Position)
                    local pos2, on2 = espCamera:WorldToViewportPoint(part2.Position)
                    if on1 and on2 then
                        drawings.Skeleton[i].Visible = true
                        drawings.Skeleton[i].From = Vector2.new(pos1.X, pos1.Y)
                        drawings.Skeleton[i].To = Vector2.new(pos2.X, pos2.Y)
                        drawings.Skeleton[i].Color = espSettings.SkeletonColor
                    else
                        drawings.Skeleton[i].Visible = false
                    end
                end
            end
        else
            for _, line in pairs(drawings.Skeleton) do
                line.Visible = false
            end
        end
    end
end

local function StartESP()
    if espEnabled then return end
    espEnabled = true
    espRenderConnection = runservice.RenderStepped:Connect(UpdateESP)
end

local function StopESP()
    espEnabled = false
    if espRenderConnection then
        espRenderConnection:Disconnect()
        espRenderConnection = nil
    end
    for player in pairs(espDrawings) do
        RemoveESPDrawings(player)
    end
end

EspTab:Toggle({
    Title = "透视总开关",
    Desc = "启用/禁用所有透视功能",
    Value = false,
    Callback = function(state)
        if state then
            StartESP()
        else
            StopESP()
        end
        WindUI:Notify({
            Title = "ESP",
            Content = state and "透视已开启" or "透视已关闭",
            Duration = 2
        })
    end
})

EspTab:Divider()

EspTab:Toggle({
    Title = "方框绘制",
    Desc = "显示玩家方框",
    Value = true,
    Callback = function(state)
        espSettings.Box = state
    end
})

EspTab:Toggle({
    Title = "名称绘制",
    Desc = "显示玩家名称",
    Value = true,
    Callback = function(state)
        espSettings.Name = state
    end
})

EspTab:Toggle({
    Title = "血量绘制",
    Desc = "显示血条",
    Value = true,
    Callback = function(state)
        espSettings.Health = state
    end
})

EspTab:Toggle({
    Title = "骨骼绘制",
    Desc = "显示玩家骨骼线条",
    Value = false,
    Callback = function(state)
        espSettings.Skeleton = state
    end
})

EspTab:Toggle({
    Title = "追踪线绘制",
    Desc = "从屏幕底部指向玩家",
    Value = false,
    Callback = function(state)
        espSettings.Tracer = state
    end
})

EspTab:Divider()

EspTab:Colorpicker({
    Title = "方框颜色",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(color)
        espSettings.BoxColor = color
    end
})

EspTab:Colorpicker({
    Title = "名称颜色",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(color)
        espSettings.NameColor = color
    end
})

EspTab:Colorpicker({
    Title = "骨骼颜色",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(color)
        espSettings.SkeletonColor = color
    end
})

EspTab:Colorpicker({
    Title = "追踪线颜色",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(color)
        espSettings.TracerColor = color
    end
})

local function ClearAllESP()
    StopESP()
    for player in pairs(espDrawings) do
        RemoveESPDrawings(player)
    end
    espDrawings = {}
end

players.PlayerRemoving:Connect(function(player)
    RemoveESPDrawings(player)
end)

local FovTab = Main:Tab({
    Title = "FOV",
    Icon = "target",
    Desc = "自瞄范围圈"
})

local fovEnabled = false
local fovObject = nil
local fovConnection = nil

local fovSettings = {
    Type = "圆形",
    Radius = 150,
    Color = Color3.fromRGB(255, 255, 255),
    Transparency = 0.55,
    OutlineColor = Color3.fromRGB(255, 255, 255),
    OutlineTransparency = 0,
    OutlineThickness = 1,
    Mode = "center"
}

local function CreateFOV()
    if fovObject then
        fovObject:Destroy()
        fovObject = nil
    end

    local parent = Instance.new("ScreenGui")
    parent.Name = "FOVGui"
    parent.Parent = core_gui or game:GetService("CoreGui")
    parent.ResetOnSpawn = false

    local frame = Instance.new("Frame")
    frame.Name = "FOVFrame"
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BackgroundTransparency = fovSettings.Transparency
    frame.BackgroundColor3 = fovSettings.Color
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(0, fovSettings.Radius * 2, 0, fovSettings.Radius * 2)
    frame.Visible = true
    frame.Parent = parent

    local outline = Instance.new("UIStroke")
    outline.Thickness = fovSettings.OutlineThickness
    outline.Color = fovSettings.OutlineColor
    outline.Transparency = fovSettings.OutlineTransparency
    outline.Parent = frame

    if fovSettings.Type == "圆形" then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = frame
    elseif fovSettings.Type == "方形" then
    elseif fovSettings.Type == "点状" then
        frame.BackgroundTransparency = 1
        for i = 1, 36 do
            local dot = Instance.new("Frame")
            dot.Size = UDim2.new(0, 3, 0, 3)
            dot.BackgroundColor3 = fovSettings.Color
            dot.BackgroundTransparency = fovSettings.Transparency
            dot.AnchorPoint = Vector2.new(0.5, 0.5)
            local angle = math.rad((i - 1) * 10)
            local x = math.cos(angle) * fovSettings.Radius
            local y = math.sin(angle) * fovSettings.Radius
            dot.Position = UDim2.new(0.5, x, 0.5, y)
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(1, 0)
            corner.Parent = dot
            dot.Parent = frame
        end
    elseif fovSettings.Type == "线状" then
        frame.BackgroundTransparency = 1
        for i = 1, 36 do
            local line = Instance.new("Frame")
            line.Size = UDim2.new(0, 10, 0, 1)
            line.BackgroundColor3 = fovSettings.Color
            line.BackgroundTransparency = fovSettings.Transparency
            line.AnchorPoint = Vector2.new(0.5, 0.5)
            local angle = math.rad((i - 1) * 10)
            local x = math.cos(angle) * fovSettings.Radius
            local y = math.sin(angle) * fovSettings.Radius
            line.Position = UDim2.new(0.5, x, 0.5, y)
            line.Rotation = math.deg(angle)
            line.Parent = frame
        end
    end

    fovObject = parent

    local function UpdatePosition()
        if not fovEnabled then return end
        if fovSettings.Mode == "mouse" then
            local mouse = userinputservice:GetMouseLocation()
            local guiInset = game:GetService("GuiService"):GetGuiInset()
            frame.Position = UDim2.new(0, mouse.X - guiInset.X, 0, mouse.Y - guiInset.Y)
        else
            frame.Position = UDim2.new(0.5, 0, 0.5, 0)
        end
    end

    fovConnection = runservice.RenderStepped:Connect(UpdatePosition)
    UpdatePosition()

    return parent
end

local function StartFOV()
    if fovEnabled then return end
    fovEnabled = true
    CreateFOV()
end

local function StopFOV()
    fovEnabled = false
    if fovConnection then
        fovConnection:Disconnect()
        fovConnection = nil
    end
    if fovObject then
        fovObject:Destroy()
        fovObject = nil
    end
end

FovTab:Toggle({
    Title = "FOV 总开关",
    Desc = "启用/禁用自瞄范围圈",
    Value = false,
    Callback = function(state)
        if state then
            StartFOV()
        else
            StopFOV()
        end
        WindUI:Notify({
            Title = "FOV",
            Content = state and "FOV已开启" or "FOV已关闭",
            Duration = 2
        })
    end
})

FovTab:Divider()

FovTab:Dropdown({
    Title = "FOV 类型",
    Desc = "选择自瞄圈样式",
    Values = {"圆形", "方形", "点状", "线状"},
    Value = "圆形",
    Callback = function(value)
        fovSettings.Type = value
        if fovEnabled then
            StopFOV()
            StartFOV()
        end
    end
})

FovTab:Dropdown({
    Title = "FOV 模式",
    Desc = "跟随鼠标或固定在屏幕中心",
    Values = {"center", "mouse"},
    Value = "center",
    Callback = function(value)
        fovSettings.Mode = value
    end
})

FovTab:Slider({
    Title = "FOV 半径",
    Desc = "调整自瞄圈大小",
    Value = { Min = 50, Max = 400, Default = 150 },
    Callback = function(value)
        fovSettings.Radius = value
        if fovEnabled then
            StopFOV()
            StartFOV()
        end
    end
})

FovTab:Slider({
    Title = "FOV 透明度",
    Desc = "调整自瞄圈透明度",
    Value = { Min = 0, Max = 100, Default = 55 },
    Callback = function(value)
        fovSettings.Transparency = value / 100
        if fovEnabled then
            StopFOV()
            StartFOV()
        end
    end
})

FovTab:Colorpicker({
    Title = "FOV 颜色",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(color)
        fovSettings.Color = color
        if fovEnabled then
            StopFOV()
            StartFOV()
        end
    end
})

FovTab:Colorpicker({
    Title = "描边颜色",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(color)
        fovSettings.OutlineColor = color
        if fovEnabled then
            StopFOV()
            StartFOV()
        end
    end
})

local VisualTab = Main:Tab({
    Title = "特效",
    Icon = "sparkles",
    Desc = "视觉特效功能"
})

local chamsEnabled = false
local chamsObjects = {}
local chamsConnection = nil
local trailEnabled = false
local trailObjects = {}
local auraEnabled = false
local auraObjects = {}
local auraConnection = nil
local ring3DEnabled = false
local ring3DObjects = {}

local chamsSettings = {
    Color = Color3.fromRGB(204, 46, 107),
    OutlineColor = Color3.fromRGB(204, 46, 107),
    Transparency = 0.6,
    OutlineTransparency = 0.4,
    Breath = true
}

local trailSettings = {
    Color = Color3.fromRGB(255, 58, 134),
    Transparency = 0.5,
    Lifetime = 0.5,
    Width = 0.5
}

local auraSettings = {
    Type = "Lightning",
    Color1 = Color3.fromRGB(255, 58, 134),
    Color2 = Color3.fromRGB(0, 0, 0),
    Transparency1 = 0,
    Transparency2 = 0,
    Visible = true
}

local ring3DSettings = {
    Radius = 5,
    Height = 0.1,
    Color = Color3.fromRGB(255, 255, 255),
    AlwaysOnTop = false
}

local tracerModeSettings = {
    Mode = "From Screen"
}

local function CreateChams(player)
    if chamsObjects[player] then return end
    
    local char = player.Character
    if not char then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Adornee = char
    highlight.Enabled = true
    highlight.FillColor = chamsSettings.Color
    highlight.OutlineColor = chamsSettings.OutlineColor
    highlight.FillTransparency = chamsSettings.Transparency
    highlight.OutlineTransparency = chamsSettings.OutlineTransparency
    highlight.DepthMode = "AlwaysOnTop"
    
    local parent = Instance.new("ScreenGui")
    parent.Name = "ChamsGui"
    parent.Parent = core_gui or game:GetService("CoreGui")
    parent.ResetOnSpawn = false
    highlight.Parent = parent
    
    chamsObjects[player] = {
        highlight = highlight,
        parent = parent
    }
end

local function RemoveChams(player)
    if chamsObjects[player] then
        if chamsObjects[player].highlight then
            chamsObjects[player].highlight:Destroy()
        end
        if chamsObjects[player].parent then
            chamsObjects[player].parent:Destroy()
        end
        chamsObjects[player] = nil
    end
end

local function StartChams()
    if chamsEnabled then return end
    chamsEnabled = true
    
    for _, player in pairs(players:GetPlayers()) do
        if player ~= localPlayer then
            CreateChams(player)
        end
    end
    
    players.PlayerAdded:Connect(function(player)
        if chamsEnabled and player ~= localPlayer then
            player.CharacterAdded:Connect(function()
                task.wait(0.5)
                CreateChams(player)
            end)
        end
    end)
    
    players.PlayerRemoving:Connect(function(player)
        RemoveChams(player)
    end)
end

local function StopChams()
    chamsEnabled = false
    for player in pairs(chamsObjects) do
        RemoveChams(player)
    end
end

local function CreateTrail(player)
    if trailObjects[player] then return end
    
    local char = player.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local trail = Instance.new("Trail")
    trail.Parent = root
    trail.Color = ColorSequence.new(trailSettings.Color)
    trail.Transparency = NumberSequence.new(trailSettings.Transparency)
    trail.Lifetime = trailSettings.Lifetime
    trail.WidthScale = NumberSequence.new(trailSettings.Width)
    trail.Enabled = true
    trail.FaceCamera = true
    trail.MinLength = 0.1
    trail.MaxLength = 15
    
    local att0 = Instance.new("Attachment")
    att0.Parent = root
    att0.Position = Vector3.new(0.5, 0, 0)
    local att1 = Instance.new("Attachment")
    att1.Parent = root
    att1.Position = Vector3.new(-0.5, 0, 0)
    
    trail.Attachment0 = att0
    trail.Attachment1 = att1
    
    trailObjects[player] = {
        trail = trail,
        att0 = att0,
        att1 = att1
    }
end

local function RemoveTrail(player)
    if trailObjects[player] then
        if trailObjects[player].trail then
            trailObjects[player].trail:Destroy()
        end
        if trailObjects[player].att0 then
            trailObjects[player].att0:Destroy()
        end
        if trailObjects[player].att1 then
            trailObjects[player].att1:Destroy()
        end
        trailObjects[player] = nil
    end
end

local function StartTrail()
    if trailEnabled then return end
    trailEnabled = true
    
    for _, player in pairs(players:GetPlayers()) do
        if player ~= localPlayer then
            CreateTrail(player)
        end
    end
    
    players.PlayerAdded:Connect(function(player)
        if trailEnabled and player ~= localPlayer then
            player.CharacterAdded:Connect(function()
                task.wait(0.5)
                CreateTrail(player)
            end)
        end
    end)
    
    players.PlayerRemoving:Connect(function(player)
        RemoveTrail(player)
    end)
end

local function StopTrail()
    trailEnabled = false
    for player in pairs(trailObjects) do
        RemoveTrail(player)
    end
end

local function CreateAura(player)
    if auraObjects[player] then return end
    
    local char = player.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local attachment = Instance.new("Attachment")
    attachment.Parent = root
    
    local emitter = Instance.new("ParticleEmitter")
    emitter.Parent = attachment
    emitter.Enabled = auraSettings.Visible
    
    if auraSettings.Type == "Lightning" then
        emitter.Texture = "rbxassetid://16664675233"
        emitter.Lifetime = NumberRange.new(0.5, 1)
        emitter.Rate = 50
        emitter.SpreadAngle = Vector2.new(360, 360)
        emitter.Size = NumberSequence.new(0, 6, 0, 3, 2, 0)
        emitter.Transparency = NumberSequence.new(0, 0.5, 0.1, 1)
        emitter.Color = ColorSequence.new(auraSettings.Color1, auraSettings.Color2)
        emitter.LightEmission = 10
        emitter.RotSpeed = NumberRange.new(0, 0)
        emitter.Orientation = Enum.ParticleOrientation.FacingCamera
    elseif auraSettings.Type == "Swirl" then
        emitter.Texture = "rbxassetid://14477910720"
        emitter.Lifetime = NumberRange.new(0.1, 1)
        emitter.Rate = 5
        emitter.SpreadAngle = Vector2.new(360, -360)
        emitter.Size = NumberSequence.new(0, 7, 0, 1, 7, 0)
        emitter.Transparency = NumberSequence.new(0, 0, 0, 1, 0, 0)
        emitter.Color = ColorSequence.new(auraSettings.Color1, auraSettings.Color2)
        emitter.RotSpeed = NumberRange.new(360, 360)
        emitter.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
    else
        emitter.Texture = "rbxassetid://11189077263"
        emitter.Lifetime = NumberRange.new(0.25, 0.25)
        emitter.Rate = 25
        emitter.SpreadAngle = Vector2.new(-360, 360)
        emitter.Size = NumberSequence.new(0, 6, 1, 1, 6, 1)
        emitter.Transparency = NumberSequence.new(0, 1, 0, 0.25, 0, 0, 1, 1, 0)
        emitter.Color = ColorSequence.new(auraSettings.Color1, auraSettings.Color2)
        emitter.RotSpeed = NumberRange.new(500, 1000)
        emitter.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
    end
    
    auraObjects[player] = {
        emitter = emitter,
        attachment = attachment
    }
end

local function RemoveAura(player)
    if auraObjects[player] then
        if auraObjects[player].emitter then
            auraObjects[player].emitter:Destroy()
        end
        if auraObjects[player].attachment then
            auraObjects[player].attachment:Destroy()
        end
        auraObjects[player] = nil
    end
end

local function StartAura()
    if auraEnabled then return end
    auraEnabled = true
    
    for _, player in pairs(players:GetPlayers()) do
        if player ~= localPlayer then
            CreateAura(player)
        end
    end
    
    players.PlayerAdded:Connect(function(player)
        if auraEnabled and player ~= localPlayer then
            player.CharacterAdded:Connect(function()
                task.wait(0.5)
                CreateAura(player)
            end)
        end
    end)
    
    players.PlayerRemoving:Connect(function(player)
        RemoveAura(player)
    end)
end

local function StopAura()
    auraEnabled = false
    for player in pairs(auraObjects) do
        RemoveAura(player)
    end
end

local function CreateRing3D(player)
    if ring3DObjects[player] then return end
    
    local char = player.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local adornment = Instance.new("CylinderHandleAdornment")
    adornment.Radius = ring3DSettings.Radius
    adornment.InnerRadius = ring3DSettings.Radius - 0.1
    adornment.Height = ring3DSettings.Height
    adornment.Color3 = ring3DSettings.Color
    adornment.AlwaysOnTop = ring3DSettings.AlwaysOnTop
    adornment.AdornCullingMode = Enum.AdornCullingMode.Never
    adornment.Adornee = root
    adornment.ZIndex = 5
    adornment.Parent = char
    
    ring3DObjects[player] = adornment
end

local function RemoveRing3D(player)
    if ring3DObjects[player] then
        ring3DObjects[player]:Destroy()
        ring3DObjects[player] = nil
    end
end

local function StartRing3D()
    if ring3DEnabled then return end
    ring3DEnabled = true
    
    for _, player in pairs(players:GetPlayers()) do
        if player ~= localPlayer then
            CreateRing3D(player)
        end
    end
    
    players.PlayerAdded:Connect(function(player)
        if ring3DEnabled and player ~= localPlayer then
            player.CharacterAdded:Connect(function()
                task.wait(0.5)
                CreateRing3D(player)
            end)
        end
    end)
    
    players.PlayerRemoving:Connect(function(player)
        RemoveRing3D(player)
    end)
end

local function StopRing3D()
    ring3DEnabled = false
    for player in pairs(ring3DObjects) do
        RemoveRing3D(player)
    end
end

VisualTab:Toggle({
    Title = "Chams 高亮",
    Desc = "玩家模型高亮染色（呼吸效果）",
    Value = false,
    Callback = function(state)
        if state then
            StartChams()
        else
            StopChams()
        end
        WindUI:Notify({
            Title = "Chams",
            Content = state and "高亮已开启" or "高亮已关闭",
            Duration = 2
        })
    end
})

VisualTab:Toggle({
    Title = "拖尾特效",
    Desc = "玩家移动留下彩色拖尾",
    Value = false,
    Callback = function(state)
        if state then
            StartTrail()
        else
            StopTrail()
        end
        WindUI:Notify({
            Title = "Trail",
            Content = state and "拖尾已开启" or "拖尾已关闭",
            Duration = 2
        })
    end
})

VisualTab:Toggle({
    Title = "Aura 光环",
    Desc = "玩家周围粒子光环",
    Value = false,
    Callback = function(state)
        if state then
            StartAura()
        else
            StopAura()
        end
        WindUI:Notify({
            Title = "Aura",
            Content = state and "光环已开启" or "光环已关闭",
            Duration = 2
        })
    end
})

VisualTab:Toggle({
    Title = "3D 光环",
    Desc = "玩家头顶/脚下彩色圆环",
    Value = false,
    Callback = function(state)
        if state then
            StartRing3D()
        else
            StopRing3D()
        end
        WindUI:Notify({
            Title = "3D Ring",
            Content = state and "3D光环已开启" or "3D光环已关闭",
            Duration = 2
        })
    end
})

VisualTab:Divider()

VisualTab:Dropdown({
    Title = "Aura 类型",
    Desc = "选择光环样式",
    Values = {"Lightning", "Swirl", "Juju"},
    Value = "Lightning",
    Callback = function(value)
        auraSettings.Type = value
        if auraEnabled then
            StopAura()
            StartAura()
        end
    end
})

VisualTab:Colorpicker({
    Title = "Aura 颜色 1",
    Default = Color3.fromRGB(255, 58, 134),
    Callback = function(color)
        auraSettings.Color1 = color
        if auraEnabled then
            StopAura()
            StartAura()
        end
    end
})

VisualTab:Colorpicker({
    Title = "Aura 颜色 2",
    Default = Color3.fromRGB(0, 0, 0),
    Callback = function(color)
        auraSettings.Color2 = color
        if auraEnabled then
            StopAura()
            StartAura()
        end
    end
})

VisualTab:Colorpicker({
    Title = "Chams 颜色",
    Default = Color3.fromRGB(204, 46, 107),
    Callback = function(color)
        chamsSettings.Color = color
        if chamsEnabled then
            StopChams()
            StartChams()
        end
    end
})

VisualTab:Colorpicker({
    Title = "拖尾颜色",
    Default = Color3.fromRGB(255, 58, 134),
    Callback = function(color)
        trailSettings.Color = color
        if trailEnabled then
            StopTrail()
            StartTrail()
        end
    end
})

VisualTab:Colorpicker({
    Title = "3D光环颜色",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(color)
        ring3DSettings.Color = color
        if ring3DEnabled then
            StopRing3D()
            StartRing3D()
        end
    end
})

VisualTab:Slider({
    Title = "Chams 透明度",
    Desc = "调整高亮透明度",
    Value = { Min = 0, Max = 100, Default = 60 },
    Callback = function(value)
        chamsSettings.Transparency = value / 100
        if chamsEnabled then
            StopChams()
            StartChams()
        end
    end
})

local TracerTab = Main:Tab({
    Title = "Tracer",
    Icon = "line-chart",
    Desc = "追踪线模式"
})

local tracerEnabled = false
local tracerLines = {}
local tracerConnection = nil

local tracerSettings = {
    Mode = "From Screen",
    Color = Color3.fromRGB(255, 255, 255),
    Thickness = 1,
    Transparency = 0.1
}

local function GetTracerOrigin()
    local mode = tracerSettings.Mode
    local cam = workspace.CurrentCamera
    
    if mode == "From Screen" then
        return Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
    elseif mode == "From Mouse" then
        local mouse = userinputservice:GetMouseLocation()
        return Vector2.new(mouse.X, mouse.Y)
    elseif mode == "From Client" then
        local char = localPlayer.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local pos, onScreen = cam:WorldToScreenPoint(root.Position)
                if onScreen then
                    return Vector2.new(pos.X, pos.Y)
                end
            end
        end
        return Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
    elseif mode == "Over Head" then
        return Vector2.new(cam.ViewportSize.X / 2, 0)
    end
    return Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
end

local function CreateTracerLine(player)
    if tracerLines[player] then return end
    
    local line = Drawing.new("Line")
    line.Thickness = tracerSettings.Thickness
    line.Color = tracerSettings.Color
    line.Transparency = tracerSettings.Transparency
    line.Visible = false
    line.ZIndex = 1
    
    tracerLines[player] = line
end

local function RemoveTracerLine(player)
    if tracerLines[player] then
        tracerLines[player]:Remove()
        tracerLines[player] = nil
    end
end

local function UpdateTracers()
    if not tracerEnabled then return end
    
    local cam = workspace.CurrentCamera
    local origin = GetTracerOrigin()
    
    for _, player in pairs(players:GetPlayers()) do
        if player == localPlayer then continue end
        
        local char = player.Character
        if not char then
            if tracerLines[player] then
                tracerLines[player].Visible = false
            end
            continue
        end
        
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then
            if tracerLines[player] then
                tracerLines[player].Visible = false
            end
            continue
        end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then
            if tracerLines[player] then
                tracerLines[player].Visible = false
            end
            continue
        end
        
        if not tracerLines[player] then
            CreateTracerLine(player)
        end
        
        local targetPos, onScreen = cam:WorldToScreenPoint(root.Position)
        if onScreen then
            local target = Vector2.new(targetPos.X, targetPos.Y)
            if tracerSettings.Mode == "Over Head" then
                target = Vector2.new(targetPos.X, targetPos.Y - 50)
            end
            
            tracerLines[player].Visible = true
            tracerLines[player].From = origin
            tracerLines[player].To = target
            tracerLines[player].Color = tracerSettings.Color
            tracerLines[player].Thickness = tracerSettings.Thickness
            tracerLines[player].Transparency = tracerSettings.Transparency
        else
            tracerLines[player].Visible = false
        end
    end
end

local function StartTracer()
    if tracerEnabled then return end
    tracerEnabled = true
    tracerConnection = runservice.RenderStepped:Connect(UpdateTracers)
end

local function StopTracer()
    tracerEnabled = false
    if tracerConnection then
        tracerConnection:Disconnect()
        tracerConnection = nil
    end
    for player in pairs(tracerLines) do
        RemoveTracerLine(player)
    end
end

TracerTab:Toggle({
    Title = "Tracer 总开关",
    Desc = "启用/禁用追踪线",
    Value = false,
    Callback = function(state)
        if state then
            StartTracer()
        else
            StopTracer()
        end
        WindUI:Notify({
            Title = "Tracer",
            Content = state and "追踪线已开启" or "追踪线已关闭",
            Duration = 2
        })
    end
})

TracerTab:Divider()

TracerTab:Dropdown({
    Title = "Tracer 模式",
    Desc = "选择追踪线起点位置",
    Values = {"From Screen", "From Mouse", "From Client", "Over Head"},
    Value = "From Screen",
    Callback = function(value)
        tracerSettings.Mode = value
    end
})

TracerTab:Colorpicker({
    Title = "Tracer 颜色",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(color)
        tracerSettings.Color = color
    end
})

TracerTab:Slider({
    Title = "Tracer 透明度",
    Desc = "调整追踪线透明度",
    Value = { Min = 0, Max = 100, Default = 10 },
    Callback = function(value)
        tracerSettings.Transparency = value / 100
    end
})

TracerTab:Slider({
    Title = "Tracer 粗细",
    Desc = "调整追踪线粗细",
    Value = { Min = 1, Max = 5, Default = 1 },
    Callback = function(value)
        tracerSettings.Thickness = value
    end
})

players.PlayerRemoving:Connect(function(player)
    RemoveTracerLine(player)
end)

local MiscTab = Main:Tab({
    Title = "杂项",
    Icon = "settings",
    Desc = "其他功能"
})

MiscTab:Button({
    Title = "删除所有门",
    Desc = "删除监狱所有门（慎用）",
    Callback = function()
        local doors = workspace:FindFirstChild("Doors")
        if doors then
            doors:Destroy()
            WindUI:Notify({
                Title = "删除门",
                Content = "所有门已删除！",
                Duration = 2
            })
        else
            WindUI:Notify({
                Title = "删除门",
                Content = "未找到门",
                Duration = 2
            })
        end
    end
})

MiscTab:Button({
    Title = "恢复所有门",
    Desc = "恢复被删除的门",
    Callback = function()
        local lighting = game:GetService("Lighting")
        local doors = lighting:FindFirstChild("Doors")
        if doors then
            doors.Parent = workspace
            WindUI:Notify({
                Title = "恢复门",
                Content = "所有门已恢复！",
                Duration = 2
            })
        else
            WindUI:Notify({
                Title = "恢复门",
                Content = "未找到备份的门",
                Duration = 2
            })
        end
    end
})

MiscTab:Button({
    Title = "删除所有墙",
    Desc = "删除监狱所有墙壁",
    Callback = function()
        local walls = {
            workspace:FindFirstChild("Prison_Halls"),
            workspace:FindFirstChild("Prison_Cellblock"),
            workspace:FindFirstChild("Prison_OuterWall"),
            workspace:FindFirstChild("Prison_Fences"),
            workspace:FindFirstChild("Prison_Guard_Outpost"),
            workspace:FindFirstChild("Prison_Cafeteria"),
            workspace:FindFirstChild("City_buildings")
        }
        local count = 0
        for _, wall in pairs(walls) do
            if wall then
                wall.Parent = game:GetService("Lighting")
                count = count + 1
            end
        end
        WindUI:Notify({
            Title = "删除墙",
            Content = "已删除 " .. count .. " 组墙壁",
            Duration = 2
        })
    end
})

MiscTab:Button({
    Title = "恢复所有墙",
    Desc = "恢复被删除的墙壁",
    Callback = function()
        local lighting = game:GetService("Lighting")
        local restored = 0
        for _, child in pairs(lighting:GetChildren()) do
            if child:IsA("Model") and child.Name ~= "Doors" then
                child.Parent = workspace
                restored = restored + 1
            end
        end
        WindUI:Notify({
            Title = "恢复墙",
            Content = "已恢复 " .. restored .. " 组墙壁",
            Duration = 2
        })
    end
})

MiscTab:Divider()

MiscTab:Button({
    Title = "切换队伍 - 囚犯",
    Desc = "变成囚犯队伍",
    Callback = function()
        pcall(function()
            workspace.Remote.TeamEvent:FireServer("Bright orange")
            WindUI:Notify({
                Title = "切换队伍",
                Content = "已切换为囚犯",
                Duration = 2
            })
        end)
    end
})

MiscTab:Button({
    Title = "切换队伍 - 警卫",
    Desc = "变成警卫队伍",
    Callback = function()
        pcall(function()
            workspace.Remote.TeamEvent:FireServer("Bright blue")
            WindUI:Notify({
                Title = "切换队伍",
                Content = "已切换为警卫",
                Duration = 2
            })
        end)
    end
})

MiscTab:Button({
    Title = "切换队伍 - 罪犯",
    Desc = "变成罪犯队伍",
    Callback = function()
        pcall(function()
            workspace.Remote.TeamEvent:FireServer("Really red")
            WindUI:Notify({
                Title = "切换队伍",
                Content = "已切换为罪犯",
                Duration = 2
            })
        end)
    end
})

MiscTab:Button({
    Title = "切换队伍 - 中立",
    Desc = "变成中立队伍",
    Callback = function()
        pcall(function()
            workspace.Remote.TeamEvent:FireServer("Medium stone grey")
            WindUI:Notify({
                Title = "切换队伍",
                Content = "已切换为中立",
                Duration = 2
            })
        end)
    end
})

MiscTab:Divider()

MiscTab:Button({
    Title = "获取所有武器",
    Desc = "获取游戏内所有枪械",
    Callback = function()
        pcall(function()
            local items = workspace:FindFirstChild("Prison_ITEMS")
            if items and items:FindFirstChild("giver") then
                local giver = items.giver
                for _, item in pairs(giver:GetChildren()) do
                    if item:FindFirstChild("ITEMPICKUP") then
                        workspace.Remote.ItemHandler:InvokeServer(item.ITEMPICKUP)
                    end
                end
                WindUI:Notify({
                    Title = "获取武器",
                    Content = "已获取所有武器！",
                    Duration = 2
                })
            else
                WindUI:Notify({
                    Title = "获取武器",
                    Content = "未找到武器源",
                    Duration = 2
                })
            end
        end)
    end
})

MiscTab:Button({
    Title = "打开大门",
    Desc = "打开监狱大门",
    Callback = function()
        pcall(function()
            local buttons = workspace:FindFirstChild("Prison_ITEMS")
            if buttons and buttons:FindFirstChild("buttons") then
                local gate = buttons.buttons:FindFirstChild("Prison Gate")
                if gate and gate:FindFirstChild("Prison Gate") then
                    workspace.Remote.ItemHandler:InvokeServer(gate["Prison Gate"])
                    WindUI:Notify({
                        Title = "打开大门",
                        Content = "大门已打开！",
                        Duration = 2
                    })
                end
            end
        end)
    end
})

MiscTab:Divider()

MiscTab:Slider({
    Title = "移动速度",
    Desc = "修改玩家移速（默认16）",
    Value = { Min = 0, Max = 100, Default = 16 },
    Callback = function(value)
        pcall(function()
            local char = localPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.WalkSpeed = value
                end
            end
        end)
    end
})

MiscTab:Slider({
    Title = "跳跃高度",
    Desc = "修改玩家跳跃高度（默认50）",
    Value = { Min = 0, Max = 200, Default = 50 },
    Callback = function(value)
        pcall(function()
            local char = localPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.JumpPower = value
                end
            end
        end)
    end
})

MiscTab:Button({
    Title = "重置移速/跳跃",
    Desc = "恢复默认移速16和跳跃50",
    Callback = function()
        pcall(function()
            local char = localPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.WalkSpeed = 16
                    hum.JumpPower = 50
                    WindUI:Notify({
                        Title = "重置属性",
                        Content = "移速和跳跃已重置",
                        Duration = 2
                    })
                end
            end
        end)
    end
})

print("Sentinel Hub 全部功能加载完成！")