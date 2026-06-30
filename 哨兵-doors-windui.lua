local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

function gradient(text, startColor, endColor)
    local result = ""
    local chars = {}
    for uchar in text:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
        table.insert(chars, uchar)
    end
    local length = #chars
    for i = 1, length do
        local t = (i - 1) / math.max(length - 1, 1)
        local r = startColor.R + (endColor.R - startColor.R) * t
        local g = startColor.G + (endColor.G - startColor.G) * t
        local b = startColor.B + (endColor.B - startColor.B) * t
        result = result .. string.format('<font color="rgb(%d,%d,%d)">%s</font>',
            math.floor(r * 255),
            math.floor(g * 255),
            math.floor(b * 255),
            chars[i])
    end
    return result
end

function redWhiteGradient(text)
    return gradient(text, Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 255, 255))
end

local gamename = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or "Unknown Game"

local _getgenv = getgenv or function() return _G end
local env = _getgenv()
if env.TransparencyEnabled == nil then
    env.TransparencyEnabled = false
end

local themes = {"Dark", "Light"}
local currentThemeIndex = 1
function createRainbowBorder() end
function startBorderAnimation() end

local Window = WindUI:CreateWindow({
    Title = redWhiteGradient("哨兵-Doors｜"..gamename),
    IconThemed = true,
    Folder = "SentinelDoors",
    Size = UDim2.fromOffset(150, 100),
    Transparent = env.TransparencyEnabled,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 150,
    BackgroundImageTransparency = 0.8,
    HideSearchBar = true,
    Background = "https://raw.githubusercontent.com/tnine-n9/n9/refs/heads/main/tnine.png",
    BackgroundImageTransparency = 0.5,
    ScrollBarEnabled = true,
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function()
            currentThemeIndex = currentThemeIndex + 1
            if currentThemeIndex > #themes then
                currentThemeIndex = 1
            end
            local newTheme = themes[currentThemeIndex]
            WindUI:SetTheme(newTheme)
            WindUI:Notify({
                Title = "Theme Changed",
                Content = "Switched to " .. newTheme .. " theme!",
                Duration = 2,
                Icon = "palette"
            })
        end,
    },
})

Window:EditOpenButton({
    Title = redWhiteGradient("哨兵-Doors｜"..gamename),
    CornerRadius = UDim.new(4,16),
    StrokeThickness = 1.25,
    Draggable = true,
})

task.spawn(function()
    local function enableRichTextForTitle()
        local main = Window.UIElements and Window.UIElements.Main
        if main then
            local openBtn = main:FindFirstChild("OpenButton")
            if openBtn then
                local textLabel = openBtn:FindFirstChildWhichIsA("TextLabel")
                if textLabel then
                    textLabel.RichText = true
                end
            end
        end
    end
    enableRichTextForTitle()
    local colorA = Color3.fromRGB(255, 0, 0)
    local colorB = Color3.fromRGB(255, 255, 255)
    local runService = game:GetService("RunService")
    runService.Heartbeat:Connect(function()
        local t = tick() * 0.8
        local keypoints = {}
        for i = 0, 10 do
            local x = i / 10
            local wave = (math.sin((x - t) * math.pi * 2) + 1) / 2
            local currentColor = colorA:Lerp(colorB, wave)
            table.insert(keypoints, ColorSequenceKeypoint.new(x, currentColor))
        end
        Window:EditOpenButton({
            CornerRadius = UDim.new(4, 16),
            StrokeThickness = 1.25,
            Color = ColorSequence.new(keypoints)
        })
    end)
end)

spawn(function()
    wait(0.5)
    createRainbowBorder(Window)
    startBorderAnimation(Window)
end)

local executionCount = 0
if isfile and writefile and readfile then
    local filename = "SentinelDoors_Count.txt"
    if isfile(filename) then
        executionCount = tonumber(readfile(filename)) or 0
        executionCount = executionCount + 1
        writefile(filename, tostring(executionCount))
    else
        executionCount = 1
        writefile(filename, "1")
    end
end

Window:Tag({
    Title = "哨兵-Doors 免费 | 执行次数: " .. executionCount,
    Radius = 5,
    Color = Color3.fromHex("#FFB347"),
})

Window:SetToggleKey(Enum.KeyCode.F, true)

local borderEnabled = true
local animationSpeed = 3
local currentColorScheme = "红色炫动"
local COLOR_SCHEMES = {
    ["红色炫动"] = {type = "duo", color1 = Color3.fromHex("8B0000"), color2 = Color3.fromHex("FF0000")}
}
local colorSchemeNames = {}
for name, _ in pairs(COLOR_SCHEMES) do
    table.insert(colorSchemeNames, name)
end
table.sort(colorSchemeNames)

local function ensureBlurElement()
    local mainFrame = Window.UIElements and Window.UIElements.Main
    if not mainFrame then return end
    local blur = mainFrame:FindFirstChild("Blur")
    if not blur then
        blur = Instance.new("ImageLabel")
        blur.Name = "Blur"
        blur.Size = UDim2.new(1, 0, 1, 0)
        blur.Position = UDim2.new(0, 0, 0, 0)
        blur.BackgroundTransparency = 1
        blur.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
        blur.ImageTransparency = 0.2
        blur.ZIndex = 0
        blur.Parent = mainFrame
    end
    return blur
end

local function getColorForScheme(scheme, time)
    local data = COLOR_SCHEMES[scheme]
    if data.type == "rainbow" then
        local hue = (time * 0.5) % 1
        return Color3.fromHSV(hue, 1, 1)
    elseif data.type == "duo" then
        local t = (math.sin(time * 2) + 1) / 2
        return data.color1:lerp(data.color2, t)
    end
    return Color3.new(1,1,1)
end

local function b(c, d, e)
    d = d or Color3.fromRGB(255,215,0)
    e = e or 0.1
    local f = c.UIElements and c.UIElements.Main or c.Frame or c.Gui or c
    if not f then return false end
    local g = f:FindFirstChild("Blur", true)
    if g and g:IsA("ImageLabel") then
        g.ImageColor3 = d
        g.ImageTransparency = e
        return true
    end
    local h = f:FindFirstChild("Shadow", true)
    if h and h:IsA("ImageLabel") then
        h.ImageColor3 = d
        h.ImageTransparency = e
        return true
    end
    return false
end

local borderConnection = nil
local function startBorderAnimation()
    if borderConnection then
        borderConnection:Disconnect()
        borderConnection = nil
    end
    if not borderEnabled then return end
    ensureBlurElement()
    borderConnection = game:GetService("RunService").Heartbeat:Connect(function()
        local mainFrame = Window.UIElements and Window.UIElements.Main
        if not mainFrame or not mainFrame.Visible then return end
        local time = tick() * animationSpeed
        local color = getColorForScheme(currentColorScheme, time)
        b(Window, color, 0.2)
    end)
end

local function stopBorderAnimation()
    if borderConnection then
        borderConnection:Disconnect()
        borderConnection = nil
    end
end

local function setupVisibilityListener()
    local mainFrame = Window.UIElements and Window.UIElements.Main
    if not mainFrame then
        task.spawn(function()
            repeat task.wait() until Window.UIElements and Window.UIElements.Main
            setupVisibilityListener()
        end)
        return
    end
    if mainFrame.Visible and borderEnabled then
        startBorderAnimation()
    elseif not mainFrame.Visible then
        stopBorderAnimation()
    end
    mainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
        if mainFrame.Visible and borderEnabled then
            startBorderAnimation()
        else
            stopBorderAnimation()
        end
    end)
end

setupVisibilityListener()

Window:OnClose(function()
    stopBorderAnimation()
end)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local ProximityPromptService = game:GetService("ProximityPromptService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")
local TextChatService = game:GetService("TextChatService")
local VirtualUser = game:GetService("VirtualUser")
local MarketplaceService = game:GetService("MarketplaceService")

repeat task.wait() until game:IsLoaded()

local function IsDoorsGame()
    return ReplicatedStorage:FindFirstChild("RemotesFolder") or ReplicatedStorage:FindFirstChild("EntityInfo") or ReplicatedStorage:FindFirstChild("Bricks")
end

if not IsDoorsGame() then
    WindUI:Notify({Title = "错误", Content = "请在DOORS游戏中运行此脚本", Duration = 5, Icon = "x"})
    return
end

local floor = ReplicatedStorage.GameData.Floor
local latestRoom = ReplicatedStorage.GameData.LatestRoom
local remotesFolder = ReplicatedStorage:FindFirstChild("RemotesFolder") or ReplicatedStorage:FindFirstChild("EntityInfo") or ReplicatedStorage:FindFirstChild("Bricks")
local MainGame = LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game
local RequiredMainGame
local RemoteListener = MainGame.RemoteListener
local ClientModules = ReplicatedStorage:FindFirstChild("ModulesClient") or ReplicatedStorage:FindFirstChild("ClientModules")
local liveModifiers = ReplicatedStorage:FindFirstChild("LiveModifiers")

local ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/TheHunterSolo1/Scripts/main/ESPLibrary"))()

local Toggles = {}
local Options = {}
local Connections = {}
local isChinese = false
local velocityLimiter = nil
local replicatesignal = nil

local function GetCharacter()
    return LocalPlayer.Character
end

local function GetRoot()
    local char = GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid()
    local char = GetCharacter()
    return char and char:FindFirstChild("Humanoid")
end

local function GetDistance(pos)
    local root = GetRoot()
    if not root then return math.huge end
    return (root.Position - pos).Magnitude
end

local function FirePrompt(prompt)
    if fireproximityprompt then
        fireproximityprompt(prompt)
    elseif prompt and prompt:IsA("ProximityPrompt") then
        prompt:InputHoldBegin()
        task.wait(prompt.HoldDuration or 0.1)
        prompt:InputHoldEnd(prompt.HoldDuration or 0.1)
    end
end

local function GetCurrentRoom()
    return LocalPlayer:GetAttribute("CurrentRoom") or 0
end

local function GetLatestRoom()
    return latestRoom and latestRoom.Value or 0
end

local function AddESP(part, txt, color)
    ESPLibrary:AddESP({Object = part, Text = txt, Color = color})
end

local function RemoveESP(part)
    ESPLibrary:RemoveESP(part)
end

local function IsAlive()
    return LocalPlayer:GetAttribute("Alive")
end

local function GetNearestCloset()
    local closest = nil
    local minDist = math.huge
    local room = GetCurrentRoom()
    if room and Workspace.CurrentRooms and Workspace.CurrentRooms[room] then
        local assets = Workspace.CurrentRooms[room]:FindFirstChild("Assets")
        if assets then
            for _, v in pairs(assets:GetChildren()) do
                if v.Name == "Wardrobe" or v.Name == "Rooms_Locker" or v.Name == "Rooms_Locker_Fridge" or v.Name == "Toolshed" or v.Name == "Locker_Large" or v.Name == "Backdoor_Wardrobe" or v.Name == "Bed" or v.Name == "Double_Bed" then
                    if v.PrimaryPart then
                        local dist = GetDistance(v.PrimaryPart.Position)
                        if dist < minDist then
                            minDist = dist
                            closest = v
                        end
                    end
                end
            end
        end
    end
    return closest
end

local function GetNearestLocker()
    local closest = nil
    local minDist = math.huge
    for _, v in pairs(Workspace.CurrentRooms:GetDescendants()) do
        if (v.Name == "Rooms_Locker" or v.Name == "Rooms_Locker_Fridge") and v:FindFirstChild("HiddenPlayer") then
            if v.HiddenPlayer.Value == nil then
                local dist = GetDistance(v.PrimaryPart and v.PrimaryPart.Position or v:GetPivot().Position)
                if dist < minDist then
                    minDist = dist
                    closest = v
                end
            end
        end
    end
    return closest
end

local function GetLibraryCode()
    local code = ""
    for _, plr in pairs(Players:GetPlayers()) do
        local char = plr.Character
        if char then
            local paper = char:FindFirstChild("LibraryHintPaper") or char:FindFirstChild("LibraryHintPaperHard")
            if paper then
                local hints = LocalPlayer.PlayerGui:FindFirstChild("PermUI") and LocalPlayer.PlayerGui.PermUI:FindFirstChild("Hints")
                if hints and paper:FindFirstChild("UI") then
                    local slot = {}
                    for _, img in pairs(paper.UI:GetChildren()) do
                        if img:IsA("ImageLabel") and tonumber(img.Name) then
                            slot[tonumber(img.Name)] = img
                        end
                    end
                    for i = 1, #slot do
                        local img = slot[i]
                        if img then
                            for _, hint in pairs(hints:GetChildren()) do
                                if hint.Name == "Icon" and hint.ImageRectOffset.X == img.ImageRectOffset.X then
                                    local label = hint:FindFirstChild("TextLabel")
                                    if label then
                                        code = code .. label.Text
                                    end
                                    break
                                end
                            end
                        else
                            code = code .. "_"
                        end
                    end
                end
                break
            end
        end
    end
    return code
end

local function Notify(txt, duration)
    WindUI:Notify({Title = "哨兵-Doors", Content = txt, Duration = duration or 3})
    local sound = Instance.new("Sound", SoundService)
    sound.SoundId = "rbxassetid://101511361468852"
    sound.Volume = 2
    sound:Play()
    Debris:AddItem(sound, 3)
end

local function SetupVelocityLimiter(root)
    if velocityLimiter then
        velocityLimiter:Destroy()
        velocityLimiter = nil
    end
    local att = root:FindFirstChild("RootAttachment")
    if att then
        velocityLimiter = Instance.new("LinearVelocity", root)
        velocityLimiter.Enabled = false
        velocityLimiter.MaxForce = math.huge
        velocityLimiter.VectorVelocity = Vector3.new(0, 0, 0)
        velocityLimiter.RelativeTo = Enum.ActuatorRelativeTo.World
        velocityLimiter.Attachment0 = att
    end
end

local function AutoClosetLogic()
    local char = GetCharacter()
    local humanoid = GetHumanoid()
    if not char or not humanoid then return end
    for _, entity in pairs(Workspace:GetChildren()) do
        local range = nil
        if entity.Name == "RushMoving" or entity.Name == "BackdoorRush" then
            range = 150
        elseif entity.Name == "AmbushMoving" then
            range = 155
        elseif entity.Name == "A60" then
            range = 200
        elseif entity.Name == "A120" then
            range = 200
        elseif entity.Name == "GlitchRush" then
            range = 150
        elseif entity.Name == "GlitchAmbush" then
            range = 155
        end
        if range and entity.PrimaryPart then
            local dist = GetDistance(entity.PrimaryPart.Position)
            if dist < range then
                local closet = GetNearestCloset()
                if closet and closet:FindFirstChild("HidePrompt") then
                    FirePrompt(closet.HidePrompt)
                end
                return
            end
        end
    end
    if char:GetAttribute("Hiding") then
        char:SetAttribute("Hiding", false)
    end
end

local function AutoInteractLogic()
    if not Toggles.AutoInteract then return end
    local char = GetCharacter()
    local root = GetRoot()
    if not char or not root then return end
    for _, prompt in pairs(Workspace.CurrentRooms:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and prompt.Enabled then
            if prompt.Parent and prompt.Parent:IsA("BasePart") then
                local dist = GetDistance(prompt.Parent.Position)
                if dist < (prompt.MaxActivationDistance or 7) then
                    FirePrompt(prompt)
                end
            elseif prompt.Parent and prompt.Parent.PrimaryPart then
                local dist = GetDistance(prompt.Parent.PrimaryPart.Position)
                if dist < (prompt.MaxActivationDistance or 7) then
                    FirePrompt(prompt)
                end
            end
        end
    end
end

local function AutoLibraryLogic()
    if not Toggles.AutoLibrary then return end
    if GetLatestRoom() ~= 50 then return end
    for _, plr in pairs(Players:GetPlayers()) do
        local char = plr.Character
        if char then
            local paper = char:FindFirstChild("LibraryHintPaper") or char:FindFirstChild("LibraryHintPaperHard")
            if paper then
                local code = GetLibraryCode()
                if code and #code > 0 and remotesFolder and remotesFolder:FindFirstChild("PL") then
                    local padlock = Workspace:FindFirstChild("Padlock", true)
                    if padlock then
                        local dist = GetDistance(padlock:GetPivot().Position)
                        if dist < (Options.AutoLibraryDist or 20) then
                            remotesFolder.PL:FireServer(code)
                        end
                    end
                end
                break
            end
        end
    end
end

local function UpdateESP()
    if Toggles.DoorESP then
        local room = GetLatestRoom()
        local doorModel = Workspace.CurrentRooms and Workspace.CurrentRooms[room]
        if doorModel and doorModel:FindFirstChild("Door") and doorModel.Door:FindFirstChild("Door") then
            local door = doorModel.Door.Door
            local opened = doorModel.Door:GetAttribute("Opened")
            local locked = doorModel:GetAttribute("RequiresKey")
            local state = ""
            if opened then state = "[已打开]"
            elseif locked then state = "[有锁]"
            end
            AddESP(door, (isChinese and "门 " or "Door ") .. state, Color3.new(0, 1, 1))
        end
    end
    if Toggles.KeyESP then
        for _, v in pairs(Workspace.CurrentRooms:GetDescendants()) do
            if v.Name == "KeyObtain" then
                AddESP(v, isChinese and "钥匙" or "Key", Color3.new(0, 1, 1))
            end
            if v.Name == "ElectricalKeyObtain" then
                AddESP(v, isChinese and "电气钥匙" or "Electrical Key", Color3.new(0, 1, 1))
            end
        end
    end
    if Toggles.HidingSpotESP then
        for _, v in pairs(Workspace.CurrentRooms:GetDescendants()) do
            if v:FindFirstChild("HiddenPlayer") and v:FindFirstChild("HidePrompt") then
                local name = isChinese and "躲藏点" or "Hiding Spot"
                if v.Name == "Bed" or v.Name == "Double_Bed" then name = isChinese and "床" or "Bed"
                elseif v.Name == "Rooms_Locker" or v.Name == "Rooms_Locker_Fridge" then name = isChinese and "储物柜" or "Locker"
                elseif v.Name == "Wardrobe" or v.Name == "Backdoor_Wardrobe" then name = isChinese and "衣柜" or "Wardrobe"
                end
                AddESP(v, name, Color3.new(0, 0.5, 0))
            end
        end
    end
    if Toggles.GateLeverESP then
        for _, v in pairs(Workspace.CurrentRooms:GetDescendants()) do
            if v.Name == "LeverForGate" then
                AddESP(v, isChinese and "闸门拉杆" or "Gate Lever", Color3.new(0.5, 0.5, 0.5))
            end
        end
    end
    if Toggles.BooksESP then
        for _, v in pairs(Workspace.CurrentRooms:GetDescendants()) do
            if v.Name == "LiveHintBook" then
                AddESP(v, isChinese and "书" or "Book", Color3.new(0, 0, 0.5))
            end
        end
    end
    if Toggles.BreakerESP then
        for _, v in pairs(Workspace.CurrentRooms:GetDescendants()) do
            if v.Name == "LiveBreakerPolePickup" then
                AddESP(v, isChinese and "断路器" or "Breaker", Color3.new(0.5, 1, 0.5))
            end
        end
    end
    if Toggles.GoldESP then
        for _, v in pairs(Workspace.CurrentRooms:GetDescendants()) do
            if v.Name == "GoldPile" then
                AddESP(v, (isChinese and "金币 " or "Gold ") .. (v:GetAttribute("GoldValue") or ""), Color3.new(1, 1, 0))
            end
        end
    end
    if Toggles.EntityESP then
        for _, v in pairs(Workspace:GetChildren()) do
            if v.Name == "RushMoving" or v.Name == "AmbushMoving" or v.Name == "A60" or v.Name == "A120" or v.Name == "Eyes" or v.Name == "BackdoorRush" or v.Name == "BackdoorLookman" or v.Name == "JeffTheKiller" then
                if v.PrimaryPart and v.PrimaryPart.Transparency == 1 then
                    v.PrimaryPart.Transparency = 0.99
                end
                if not v:FindFirstChildOfClass("Humanoid") then
                    Instance.new("Humanoid", v)
                end
                AddESP(v, v.Name, Color3.new(1, 0, 0))
            end
        end
        for _, v in pairs(Workspace.CurrentRooms:GetDescendants()) do
            if v.Name == "FigureRig" or v.Name == "FigureRagdoll" then
                if v.PrimaryPart and v.PrimaryPart.Transparency == 1 then
                    v.PrimaryPart.Transparency = 0.99
                end
                if not v:FindFirstChildOfClass("Humanoid") then
                    Instance.new("Humanoid", v)
                end
                AddESP(v, "Figure", Color3.new(1, 0, 0))
            elseif v.Name == "Snare" then
                if v:FindFirstChild("Hitbox") then
                    AddESP(v, isChinese and "藤蔓" or "Snare", Color3.new(1, 0, 0))
                end
            elseif v.Name == "GiggleCeiling" then
                if v:FindFirstChild("Hitbox") then
                    AddESP(v, "Giggle", Color3.new(1, 0, 0))
                end
            end
        end
    end
    if Toggles.LadderESP then
        for _, v in pairs(Workspace.CurrentRooms:GetDescendants()) do
            if v.Name == "Ladder" then
                AddESP(v, isChinese and "梯子" or "Ladder", Color3.new(0, 0, 1))
            end
        end
    end
    if Toggles.FuseESP then
        for _, v in pairs(Workspace.CurrentRooms:GetDescendants()) do
            if v.Name == "FuseObtain" then
                AddESP(v, isChinese and "保险丝" or "Fuse", Color3.new(0.2, 0.5, 0.3))
            end
        end
    end
    if Toggles.PlayerESP then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local hum = plr.Character:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    AddESP(plr.Character, plr.Name .. " [" .. math.floor(hum.Health) .. "%]", Color3.new(1, 1, 1))
                end
            end
        end
    end
    if Toggles.ChestESP then
        for _, v in pairs(Workspace.CurrentRooms:GetDescendants()) do
            if v:GetAttribute("Storage") == "ChestBox" or v.Name == "Toolshed_Small" then
                local locked = v:GetAttribute("Locked")
                local opened = v:GetAttribute("LocalOpened")
                local state = ""
                if opened then state = "[已开启]"
                elseif locked then state = "[上锁]"
                end
                AddESP(v, (isChinese and "箱子 " or "Chest ") .. state, Color3.new(1, 1, 0))
            end
        end
    end
    if Toggles.ShowDistance then ESPLibrary:SetShowDistance(true) end
    if Toggles.ShowTracers then ESPLibrary:SetTracers(true) end
    if Toggles.RainbowESP then ESPLibrary:SetRainbow(true) end
end

local function CleanupAll()
    for _, conn in pairs(Connections) do
        pcall(function() conn:Disconnect() end)
    end
    ESPLibrary:Unload()
    LocalPlayer:SetAttribute("SupremeLoaded", nil)
    if remotesFolder and remotesFolder:FindFirstChild("Crouch") then
        remotesFolder.Crouch:FireServer(false)
    end
    local char = GetCharacter()
    if char then
        char:SetAttribute("CanJump", false)
        local humanoid = GetHumanoid()
        if humanoid then humanoid.WalkSpeed = 16 end
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and not part.CanCollide then
                part.CanCollide = true
            end
        end
    end
    Lighting.Ambient = Color3.new(0, 0, 0)
    Lighting.FogEnd = 100000
    if velocityLimiter then
        velocityLimiter:Destroy()
        velocityLimiter = nil
    end
end

local function GetText(en, zh)
    return isChinese and zh or en
end

local MainTab = Window:Tab({Title = GetText("主要", "Main"), Icon = "crown"})
local PlayerTab = Window:Tab({Title = GetText("玩家", "Player"), Icon = "user"})
local AutoTab = Window:Tab({Title = GetText("自动", "Auto"), Icon = "repeat"})
local ReachTab = Window:Tab({Title = GetText("远程", "Reach"), Icon = "maximize"})
local VisualTab = Window:Tab({Title = GetText("视觉", "Visuals"), Icon = "eye"})
local ESPTab = Window:Tab({Title = "ESP", Icon = "target"})
local BypassTab = Window:Tab({Title = GetText("绕过", "Bypass"), Icon = "shield"})
local FloorTab = Window:Tab({Title = GetText("楼层", "Floor"), Icon = "layers"})
local SettingsTab = Window:Tab({Title = GetText("设置", "Settings"), Icon = "settings"})

local MainSection = MainTab:Section({Title = GetText("主要功能", "Main"), Icon = "crown"})
MainSection:Paragraph({
    Title = GetText("状态", "Status"),
    Desc = GetText("就绪", "Ready"),
    Image = "check-circle",
    ImageSize = 20,
    Color = "Green"
})

MainSection:Button({
    Title = GetText("重置角色", "Reset Character"),
    Icon = "refresh-cw",
    Callback = function()
        if replicatesignal then
            replicatesignal(LocalPlayer.Kill)
        else
            local char = GetCharacter()
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.Health = 0
            end
        end
        Notify(GetText("角色已重置", "Character Reset"), 2)
    end
})

MainSection:Button({
    Title = GetText("再来一次", "Play Again"),
    Icon = "play",
    Callback = function()
        if remotesFolder and remotesFolder:FindFirstChild("PlayAgain") then
            remotesFolder.PlayAgain:FireServer()
        end
        Notify(GetText("再来一次", "Play Again"), 2)
    end
})

MainSection:Button({
    Title = GetText("大厅", "Lobby"),
    Icon = "home",
    Callback = function()
        if remotesFolder and remotesFolder:FindFirstChild("Lobby") then
            remotesFolder.Lobby:FireServer()
        end
        Notify(GetText("正在前往大厅", "Going to Lobby"), 2)
    end
})

MainSection:Button({
    Title = GetText("复活", "Revive"),
    Icon = "heart",
    Callback = function()
        if remotesFolder and remotesFolder:FindFirstChild("Revive") then
            remotesFolder.Revive:FireServer()
        end
        Notify(GetText("正在复活...", "Reviving..."), 2)
    end
})

local PlayerSection = PlayerTab:Section({Title = GetText("移动", "Movement"), Icon = "user"})

Toggles.MovementSpeed = false
local movementSpeedVal = 16
PlayerSection:Slider({
    Title = GetText("移动速度", "Walk Speed"),
    Value = {Min = 15, Max = 21, Default = 16},
    Callback = function(value) movementSpeedVal = value end
})

PlayerSection:Toggle({
    Title = GetText("启用移速", "Enable Walk Speed"),
    Value = false,
    Callback = function(state)
        Toggles.MovementSpeed = state
        local hum = GetHumanoid()
        if hum then
            hum.WalkSpeed = state and movementSpeedVal or 16
        end
    end
})

local climbingSpeedVal = 16
PlayerSection:Slider({
    Title = GetText("攀爬速度", "Climb Speed"),
    Value = {Min = 15, Max = 30, Default = 16},
    Callback = function(value) climbingSpeedVal = value end
})

PlayerSection:Toggle({
    Title = GetText("启用攀爬速度", "Enable Climb Speed"),
    Value = false,
    Callback = function(state)
        Toggles.ClimbSpeed = state
        local hum = GetHumanoid()
        if hum then
            hum.WalkSpeed = state and climbingSpeedVal or 16
        end
    end
})

PlayerSection:Toggle({
    Title = GetText("防滑", "No Acceleration"),
    Value = false,
    Callback = function(state)
        Toggles.NoAccel = state
        local root = GetRoot()
        if root then
            if state then
                root.CustomPhysicalProperties = PhysicalProperties.new(100, 0.1, 0.1, 0.1, 0.1)
            else
                root.CustomPhysicalProperties = PhysicalProperties.new(0.4, 0.2, 0.2)
            end
        end
    end
})

Options.VelocityLimiter = 25
PlayerSection:Slider({
    Title = "速度限制器",
    Value = {Min = 0, Max = 25, Default = 25},
    Callback = function(value) Options.VelocityLimiter = value end
})

Options.SpeedBypassDelay = 0.21
PlayerSection:Slider({
    Title = "速度绕过延迟",
    Value = {Min = 0.2, Max = 0.22, Default = 0.21},
    Callback = function(value) Options.SpeedBypassDelay = value end
})

Toggles.LagbackDetection = false
PlayerSection:Toggle({
    Title = "防Lagback检测",
    Value = false,
    Callback = function(state) Toggles.LagbackDetection = state end
})

Toggles.NoClip = false
PlayerSection:Toggle({
    Title = GetText("穿墙模式", "Noclip") .. " (N)",
    Value = false,
    Callback = function(state)
        Toggles.NoClip = state
        local char = GetCharacter()
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = not state
                end
            end
            if char:FindFirstChild("Collision") then
                char.Collision.CanCollide = not state
                if char.Collision:FindFirstChild("CollisionCrouch") then
                    char.Collision.CollisionCrouch.CanCollide = not state
                end
            end
        end
    end
})

Toggles.Fly = false
local flySpeedVal = 15
local flyBody = nil
PlayerSection:Slider({
    Title = GetText("飞行速度", "Fly Speed"),
    Value = {Min = 15, Max = 21, Default = 15},
    Callback = function(value) flySpeedVal = value end
})

PlayerSection:Toggle({
    Title = GetText("飞行模式", "Fly") .. " (F)",
    Value = false,
    Callback = function(state)
        Toggles.Fly = state
        local root = GetRoot()
        local hum = GetHumanoid()
        if root then
            if state then
                if not flyBody then
                    flyBody = Instance.new("BodyVelocity", root)
                    flyBody.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                end
                flyBody.Parent = root
                if hum then hum.PlatformStand = true end
            else
                if flyBody then flyBody:Destroy() end
                flyBody = nil
                if hum then hum.PlatformStand = false end
            end
        end
    end
})

Toggles.EnableJump = false
PlayerSection:Toggle({
    Title = GetText("启用跳跃", "Enable Jump"),
    Value = false,
    Callback = function(state)
        Toggles.EnableJump = state
        local char = GetCharacter()
        if char then
            char:SetAttribute("CanJump", state)
        end
    end
})

Toggles.EnableSlide = false
PlayerSection:Toggle({
    Title = GetText("启用滑铲", "Enable Slide"),
    Value = false,
    Callback = function(state)
        Toggles.EnableSlide = state
        local char = GetCharacter()
        if char then
            char:SetAttribute("Sliding", state)
        end
    end
})

Toggles.InfiniteJump = false
PlayerSection:Toggle({
    Title = GetText("无限跳跃", "Infinite Jump"),
    Value = false,
    Callback = function(state) Toggles.InfiniteJump = state end
})

Toggles.InstantInteract = false
PlayerSection:Toggle({
    Title = GetText("瞬间交互", "Instant Interact"),
    Value = false,
    Callback = function(state)
        Toggles.InstantInteract = state
        for _, prompt in pairs(Workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                if state then
                    if not prompt:GetAttribute("Hold") then
                        prompt:SetAttribute("Hold", prompt.HoldDuration)
                    end
                    prompt.HoldDuration = 0
                else
                    prompt.HoldDuration = prompt:GetAttribute("Hold") or 0.5
                end
            end
        end
    end
})

Toggles.FastClosetExit = false
PlayerSection:Toggle({
    Title = GetText("快速柜子进出", "Fast Closet Exit"),
    Value = false,
    Callback = function(state)
        Toggles.FastClosetExit = state
    end
})

Toggles.GodMode = false
PlayerSection:Toggle({
    Title = GetText("无敌模式", "God Mode") .. " (G)",
    Value = false,
    Callback = function(state)
        Toggles.GodMode = state
        local char = GetCharacter()
        local root = GetRoot()
        if char and root then
            if state then
                if remotesFolder and remotesFolder.Name == "RemotesFolder" then
                    char:PivotTo(char.CollisionPart.CFrame * CFrame.new(0, -2, 0))
                else
                    char.Collision.Position = char.Collision.Position - Vector3.new(0, 4, 0)
                end
                if not Toggles.AntiFigure then
                    Toggles.AntiFigure = true
                end
            else
                if remotesFolder and remotesFolder.Name == "RemotesFolder" then
                    char.Humanoid.HipHeight = 2.4
                    char.Collision.Size = Vector3.new(5.5, 3, 3)
                    char:PivotTo(char.CollisionPart.CFrame * CFrame.new(0, 2, 0))
                else
                    char.Collision.Position = root.Position
                end
            end
        end
    end
})

local flyUpdateConnection = nil
RunService.Heartbeat:Connect(function()
    if Toggles.Fly and flyBody then
        local root = GetRoot()
        local cam = Camera
        if root and cam then
            local moveDir = Vector3.zero
            if UserInputService.KeyboardEnabled then
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + cam.CFrame.UpVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - cam.CFrame.UpVector end
            end
            if moveDir.Magnitude > 0 then
                flyBody.Velocity = moveDir.Unit * flySpeedVal
            else
                flyBody.Velocity = Vector3.zero
            end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Toggles.InfiniteJump then
        local hum = GetHumanoid()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if Toggles.FastClosetExit then
        local char = GetCharacter()
        local hum = GetHumanoid()
        if char and hum and char:GetAttribute("Hiding") and hum.MoveDirection.Magnitude > 0.5 then
            if remotesFolder and remotesFolder:FindFirstChild("CamLock") then
                remotesFolder.CamLock:FireServer()
            end
        end
    end
end)

local ReachSection = ReachTab:Section({Title = "远程", Icon = "maximize"})

Toggles.DoorReach = false
ReachSection:Toggle({
    Title = "远程开门",
    Value = false,
    Callback = function(state)
        Toggles.DoorReach = state
        if state then
            local room = GetLatestRoom()
            local door = Workspace.CurrentRooms and Workspace.CurrentRooms[room] and Workspace.CurrentRooms[room]:FindFirstChild("Door")
            if door then
                local clientOpen = door:FindFirstChild("ClientOpen")
                if clientOpen then
                    clientOpen:FireServer()
                end
            end
        end
    end
})

ReachSection:Toggle({
    Title = "穿墙交互",
    Value = false,
    Callback = function(state)
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                v.RequiresLineOfSight = not state
            end
        end
    end
})

ReachSection:Slider({
    Title = "物品互动距离",
    Value = {Min = 1, Max = 2, Default = 1},
    Callback = function(value)
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                local old = v:GetAttribute("OldRange") or v.MaxActivationDistance
                v:SetAttribute("OldRange", old)
                v.MaxActivationDistance = old * value
            end
        end
    end
})

local AutoSection = AutoTab:Section({Title = "自动化", Icon = "repeat"})

Toggles.AutoInteract = false
local autoInteractDelay = 0.05
local autoInteractRange = 7
AutoSection:Toggle({
    Title = "自动交互 (R)",
    Value = false,
    Callback = function(state)
        Toggles.AutoInteract = state
        task.spawn(function()
            local timer = 0
            while Toggles.AutoInteract do
                task.wait(0.05)
                timer = timer + 0.05
                if timer >= autoInteractDelay then
                    timer = 0
                    for _, prompt in pairs(Workspace.CurrentRooms:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                            local ignoreList = Options.IgnoreList or {}
                            local shouldIgnore = false
                            for _, ignore in pairs(ignoreList) do
                                if ignore == "Jeff物品" and prompt.Parent and prompt.Parent:GetAttribute("JeffShop") then
                                    shouldIgnore = true
                                    break
                                end
                                if ignore == "金币" and prompt.Parent and prompt.Parent.Name == "GoldPile" then
                                    shouldIgnore = true
                                    break
                                end
                                if ignore == "掉落物" and prompt.Parent.Parent and prompt.Parent.Parent.Name == "Drops" then
                                    shouldIgnore = true
                                    break
                                end
                            end
                            if shouldIgnore then continue end
                            local target = prompt.Parent
                            if target and target:IsA("BasePart") and GetDistance(target.Position) < autoInteractRange then
                                FirePrompt(prompt)
                            elseif target and target.PrimaryPart and GetDistance(target.PrimaryPart.Position) < autoInteractRange then
                                FirePrompt(prompt)
                            end
                        end
                    end
                end
            end
        end)
    end
})

Options.IgnoreList = {}
AutoSection:Dropdown({
    Title = "自动交互忽略列表",
    Values = {"Jeff物品", "金币", "掉落物"},
    Value = {},
    Multi = true,
    Callback = function(value) Options.IgnoreList = value end
})
AutoSection:Slider({
    Title = "自动交互延迟",
    Value = {Min = 0, Max = 0.2, Default = 0.05},
    Callback = function(value) autoInteractDelay = value end
})

AutoSection:Slider({
    Title = "自动交互距离",
    Value = {Min = 7, Max = 12, Default = 7},
    Callback = function(value) autoInteractRange = value end
})

Toggles.AutoCloset = false
AutoSection:Toggle({
    Title = "自动柜子 (Q)",
    Value = false,
    Callback = function(state)
        Toggles.AutoCloset = state
        task.spawn(function()
            while Toggles.AutoCloset do
                task.wait(0.3)
                for _, entity in pairs(Workspace:GetChildren()) do
                    local range = nil
                    if entity.Name == "RushMoving" or entity.Name == "BackdoorRush" then range = 150
                    elseif entity.Name == "AmbushMoving" then range = 155
                    elseif entity.Name == "A60" then range = 200
                    elseif entity.Name == "A120" then range = 200
                    end
                    if range and entity.PrimaryPart and GetDistance(entity.PrimaryPart.Position) < range then
                        local closet = GetNearestCloset()
                        if closet and closet:FindFirstChild("HidePrompt") then
                            FirePrompt(closet.HidePrompt)
                        end
                        break
                    end
                end
            end
        end)
    end
})

Toggles.AutoHeartbeat = false
AutoSection:Toggle({
    Title = "自动心跳小游戏",
    Value = false,
    Callback = function(state)
        Toggles.AutoHeartbeat = state
        if state and remotesFolder and remotesFolder:FindFirstChild("ClutchHeartbeat") then
            task.spawn(function()
                while Toggles.AutoHeartbeat do
                    task.wait(0.1)
                    remotesFolder.ClutchHeartbeat:FireServer(true)
                end
            end)
        end
    end
})

Toggles.AutoLibrary = false
Toggles.BruteForceLibCode = false
AutoSection:Toggle({
    Title = "自动图书馆密码",
    Value = false,
    Callback = function(state)
        Toggles.AutoLibrary = state
        task.spawn(function()
            while Toggles.AutoLibrary do
                task.wait(2)
                if GetLatestRoom() == 50 then
                    local code = GetLibraryCode()
                    if Toggles.BruteForceLibCode and string.find(code, "_") then
                        local bruted = ""
                        for i = 1, #code do
                            local c = string.sub(code, i, i)
                            bruted = bruted .. (c == "_" and math.random(0, 9) or c)
                        end
                        code = bruted
                    end
                    if code and #code > 0 and remotesFolder and remotesFolder:FindFirstChild("PL") then
                        local padlock = Workspace:FindFirstChild("Padlock", true)
                        if padlock then
                            local dist = GetDistance(padlock:GetPivot().Position)
                            if dist < Options.AutoLibraryDist then
                                remotesFolder.PL:FireServer(code)
                            end
                        end
                    end
                end
            end
        end)
    end
})

AutoSection:Toggle({
    Title = "暴力破解图书馆密码",
    Value = false,
    Callback = function(state)
        Toggles.BruteForceLibCode = state
    end
})

Options.AutoLibraryDist = 20
AutoSection:Slider({
    Title = "距离解锁",
    Value = {Min = 1, Max = 100, Default = 20},
    Callback = function(value) Options.AutoLibraryDist = value end
})

Toggles.AutoBreaker = false
AutoSection:Toggle({
    Title = "自动电闸",
    Value = false,
    Callback = function(state)
        Toggles.AutoBreaker = state
        task.spawn(function()
            while Toggles.AutoBreaker do
                task.wait(0.5)
                for _, v in pairs(Workspace.CurrentRooms:GetDescendants()) do
                    if v.Name == "ElevatorBreaker" and v:FindFirstChild("SurfaceGui") then
                        local code = v.SurfaceGui:FindFirstChild("Frame") and v.SurfaceGui.Frame:FindFirstChild("Code")
                        if code then
                            local target = tonumber(code.Text)
                            if target then
                                for _, breaker in pairs(v:GetChildren()) do
                                    if breaker.Name == "BreakerSwitch" and breaker:GetAttribute("ID") == target then
                                        if Options.AutoBreakerMethod == "Exploit" and remotesFolder and remotesFolder:FindFirstChild("EBF") then
                                            remotesFolder.EBF:FireServer()
                                        else
                                            if not breaker:GetAttribute("Enabled") then
                                                breaker:SetAttribute("Enabled", true)
                                                local constraint = breaker:FindFirstChild("PrismaticConstraint")
                                                if constraint then constraint.TargetPosition = -0.2 end
                                                local light = breaker:FindFirstChild("Light")
                                                if light then
                                                    light.Material = Enum.Material.Neon
                                                    local spark = light:FindFirstChild("Spark", true)
                                                    if spark then spark:Emit(1) end
                                                end
                                                local sound = breaker:FindFirstChild("Sound")
                                                if sound then sound:Play() end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
})

Options.AutoBreakerMethod = "Legit"
AutoSection:Dropdown({
    Title = "自动电闸方式",
    Values = {"Legit", "Exploit"},
    Value = "Legit",
    Callback = function(value) Options.AutoBreakerMethod = value end
})

Toggles.AutoBreakerBox = false
AutoSection:Toggle({
    Title = "自动断路器盒",
    Value = false,
    Callback = function(state)
        Toggles.AutoBreakerBox = state
        task.spawn(function()
            while Toggles.AutoBreakerBox do
                task.wait(1)
                for _, v in pairs(Workspace.CurrentRooms:GetDescendants()) do
                    if v.Name == "ElevatorBreaker" and v:FindFirstChild("SurfaceGui") then
                        local code = v.SurfaceGui:FindFirstChild("Frame") and v.SurfaceGui.Frame:FindFirstChild("Code")
                        if code then
                            local target = tonumber(code.Text)
                            if target then
                                for _, breaker in pairs(v:GetChildren()) do
                                    if breaker.Name == "BreakerSwitch" and breaker:GetAttribute("ID") == target then
                                        if not breaker:GetAttribute("Enabled") then
                                            breaker:SetAttribute("Enabled", true)
                                            local constraint = breaker:FindFirstChild("PrismaticConstraint")
                                            if constraint then constraint.TargetPosition = -0.2 end
                                            local light = breaker:FindFirstChild("Light")
                                            if light then
                                                light.Material = Enum.Material.Neon
                                                local spark = light:FindFirstChild("Spark", true)
                                                if spark then spark:Emit(1) end
                                            end
                                            local sound = breaker:FindFirstChild("Sound")
                                            if sound then sound:Play() end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
})

Toggles.AutoClosetNotif = false
AutoSection:Toggle({
    Title = "自动柜子通知",
    Value = false,
    Callback = function(state)
        Toggles.AutoClosetNotif = state
    end
})

local VisualSection = VisualTab:Section({Title = "视觉", Icon = "eye"})

Toggles.ThirdPerson = false
local thirdX = 0
local thirdY = 0
local thirdZ = 4
VisualSection:Toggle({
    Title = "第三人称 (V)",
    Value = false,
    Callback = function(state)
        Toggles.ThirdPerson = state
    end
})

VisualSection:Slider({
    Title = "X轴",
    Value = {Min = -10, Max = 10, Default = 0},
    Callback = function(value) thirdX = value end
})

VisualSection:Slider({
    Title = "Y轴",
    Value = {Min = -10, Max = 10, Default = 0},
    Callback = function(value) thirdY = value end
})

VisualSection:Slider({
    Title = "Z轴",
    Value = {Min = -10, Max = 10, Default = 4},
    Callback = function(value) thirdZ = value end
})

Toggles.FOV = false
local fovVal = 70
VisualSection:Slider({
    Title = "视野范围",
    Value = {Min = 70, Max = 120, Default = 70},
    Callback = function(value) fovVal = value end
})

VisualSection:Toggle({
    Title = "启用视野",
    Value = false,
    Callback = function(state) Toggles.FOV = state end
})

Toggles.NoCamShake = false
VisualSection:Toggle({
    Title = "无抖动",
    Value = false,
    Callback = function(state)
        Toggles.NoCamShake = state
        if state and RequiredMainGame then
            RequiredMainGame.csgo = CFrame.new()
        end
    end
})

Toggles.NoCutscenes = false
VisualSection:Toggle({
    Title = "无过场动画",
    Value = false,
    Callback = function(state)
        Toggles.NoCutscenes = state
        local cutscene = RemoteListener:FindFirstChild("Cutscenes") or RemoteListener:FindFirstChild("Cutscenes_")
        if cutscene then
            cutscene.Name = state and "Cutscenes_" or "Cutscenes"
        end
    end
})

Toggles.NoFog = false
VisualSection:Toggle({
    Title = "去雾",
    Value = false,
    Callback = function(state)
        Toggles.NoFog = state
        if state then
            Lighting.FogEnd = 500000
            local atmo = Lighting:FindFirstChildOfClass("Atmosphere")
            if atmo then atmo.Density = 0 end
        else
            Lighting.FogEnd = 100000
            local atmo = Lighting:FindFirstChildOfClass("Atmosphere")
            if atmo then atmo.Density = 0.94 end
        end
    end
})

Toggles.Fullbright = false
VisualSection:Toggle({
    Title = "全亮",
    Value = false,
    Callback = function(state)
        Toggles.Fullbright = state
        if state then
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.GlobalShadows = false
        else
            Lighting.Ambient = Color3.new(0, 0, 0)
            Lighting.GlobalShadows = true
        end
    end
})

Toggles.AntiLag = false
VisualSection:Toggle({
    Title = "低画质",
    Value = false,
    Callback = function(state)
        Toggles.AntiLag = state
        for _, v in pairs(Workspace.CurrentRooms:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = state and Enum.Material.Plastic or Enum.Material.SmoothPlastic
            end
        end
    end
})

Toggles.TranslucentCloset = false
local transVal = 0.5
VisualSection:Slider({
    Title = "躲藏透明度",
    Value = {Min = 0, Max = 1, Default = 0.5},
    Callback = function(value) transVal = value end
})

VisualSection:Toggle({
    Title = "半透明柜子",
    Value = false,
    Callback = function(state)
        Toggles.TranslucentCloset = state
        task.spawn(function()
            while Toggles.TranslucentCloset do
                task.wait(0.1)
                local char = GetCharacter()
                if char and char:GetAttribute("Hiding") then
                    for _, v in pairs(Workspace.CurrentRooms:GetDescendants()) do
                        if v:FindFirstChild("HiddenPlayer") and v.HiddenPlayer.Value == char then
                            for _, part in pairs(v:GetDescendants()) do
                                if part:IsA("BasePart") and part.Name ~= "Collision" then
                                    part.Transparency = transVal
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
})

RunService.Heartbeat:Connect(function()
    local char = GetCharacter()
    if not char then return end
    if Toggles.ThirdPerson then
        Camera.CFrame = Camera.CFrame * CFrame.new(thirdX, thirdY, thirdZ)
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name == "Head" then
                part.LocalTransparencyModifier = 0
            elseif part:IsA("Accessory") and part:FindFirstChild("Handle") then
                part.Handle.LocalTransparencyModifier = 0
            end
        end
    else
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name == "Head" then
                part.LocalTransparencyModifier = 1
            elseif part:IsA("Accessory") and part:FindFirstChild("Handle") then
                part.Handle.LocalTransparencyModifier = 1
            end
        end
    end
    if Toggles.FOV then
        Camera.FieldOfView = fovVal
    end
end)

local NotifySection = VisualTab:Section({Title = "通知", Icon = "bell"})

Toggles.EntityNotify = false
local entityList = {}
NotifySection:Dropdown({
    Title = "选择提示实体",
    Values = {"Rush", "Ambush", "A-60", "A-120", "Eyes", "Blitz", "Lookman", "Jeff"},
    Value = {},
    Multi = true,
    Callback = function(value) entityList = value end
})

NotifySection:Toggle({
    Title = "实体提示",
    Value = false,
    Callback = function(state)
        Toggles.EntityNotify = state
    end
})

Toggles.NotifyLibrary = false
NotifySection:Toggle({
    Title = "通知图书馆密码",
    Value = false,
    Callback = function(state)
        Toggles.NotifyLibrary = state
        task.spawn(function()
            while Toggles.NotifyLibrary do
                task.wait(5)
                if GetLatestRoom() == 50 then
                    local code = GetLibraryCode()
                    if code and #code > 0 then
                        Notify("图书馆密码: " .. code, 5)
                    end
                end
            end
        end)
    end
})

Toggles.NotifyOxygen = false
NotifySection:Toggle({
    Title = "氧气通知",
    Value = false,
    Callback = function(state)
        Toggles.NotifyOxygen = state
        task.spawn(function()
            while Toggles.NotifyOxygen do
                task.wait(1)
                local char = GetCharacter()
                if char then
                    local oxygen = char:GetAttribute("Oxygen")
                    if oxygen and oxygen < 100 then
                        Notify("氧气: " .. oxygen .. "%", 2)
                    end
                end
            end
        end)
    end
})

Toggles.NotifyChat = false
NotifySection:Toggle({
    Title = "聊天通知",
    Value = false,
    Callback = function(state) Toggles.NotifyChat = state end
})

Toggles.NotifySound = true
NotifySection:Toggle({
    Title = "播放提示音效",
    Value = true,
    Callback = function(state) Toggles.NotifySound = state end
})

Options.NotifySide = "Right"
NotifySection:Dropdown({
    Title = "提示位置",
    Values = {"Right", "Left"},
    Value = "Right",
    Callback = function(value) Options.NotifySide = value end
})

Options.NotifyStyle = "Linoria"
NotifySection:Dropdown({
    Title = "通知样式",
    Values = {"Linoria", "Doors"},
    Value = "Linoria",
    Callback = function(value) Options.NotifyStyle = value end
})

local entityChildAddedConn = Workspace.ChildAdded:Connect(function(child)
    if Toggles.EntityNotify then
        local names = {
            RushMoving = "Rush",
            AmbushMoving = "Ambush",
            A60 = "A-60",
            A120 = "A-120",
            Eyes = "Eyes",
            BackdoorRush = "Blitz",
            BackdoorLookman = "Lookman",
            JeffTheKiller = "Jeff"
        }
        local name = names[child.Name]
        if name then
            local found = false
            for _, v in pairs(entityList) do
                if v == name then found = true break end
            end
            if found then
                local msg = isChinese and (name .. " 已生成！") or (name .. " has spawned!")
                Notify(msg, 5)
                if Toggles.NotifyChat then
                    TextChatService.TextChannels.RBXGeneral:SendAsync(name .. " has spawned!")
                end
            end
        end
    end
end)
table.insert(Connections, entityChildAddedConn)

local ESPSection = ESPTab:Section({Title = "ESP", Icon = "target"})

local ESPColors = {
    Door = Color3.new(0, 1, 1),
    Key = Color3.new(0, 1, 0),
    Hiding = Color3.new(0, 0.5, 0),
    Gate = Color3.new(0.5, 0.5, 0.5),
    Book = Color3.new(0, 0, 0.5),
    Breaker = Color3.new(0.5, 1, 0.5),
    Gold = Color3.new(1, 1, 0),
    Entity = Color3.new(1, 0, 0),
    Ladder = Color3.new(0, 0, 1),
    Fuse = Color3.new(0.2, 0.5, 0.3),
    Player = Color3.new(1, 1, 1)
}

local espToggleState = {}

Toggles.DoorESP = false
ESPSection:Toggle({
    Title = "门ESP",
    Value = false,
    Callback = function(state)
        Toggles.DoorESP = state
        UpdateESP()
    end
})
ESPSection:Colorpicker({
    Title = "门颜色",
    Default = ESPColors.Door,
    Callback = function(value)
        ESPColors.Door = value
        Toggles.DoorESP = false
        UpdateESP()
        Toggles.DoorESP = true
        UpdateESP()
    end
})

Toggles.KeyESP = false
ESPSection:Toggle({
    Title = "钥匙/物品ESP",
    Value = false,
    Callback = function(state)
        Toggles.KeyESP = state
        UpdateESP()
    end
})
ESPSection:Colorpicker({
    Title = "钥匙颜色",
    Default = ESPColors.Key,
    Callback = function(value)
        ESPColors.Key = value
        Toggles.KeyESP = false
        UpdateESP()
        Toggles.KeyESP = true
        UpdateESP()
    end
})

Toggles.HidingSpotESP = false
ESPSection:Toggle({
    Title = "躲藏点ESP",
    Value = false,
    Callback = function(state)
        Toggles.HidingSpotESP = state
        UpdateESP()
    end
})
ESPSection:Colorpicker({
    Title = "躲藏点颜色",
    Default = ESPColors.Hiding,
    Callback = function(value)
        ESPColors.Hiding = value
        Toggles.HidingSpotESP = false
        UpdateESP()
        Toggles.HidingSpotESP = true
        UpdateESP()
    end
})

Toggles.GateLeverESP = false
ESPSection:Toggle({
    Title = "闸门拉杆ESP",
    Value = false,
    Callback = function(state)
        Toggles.GateLeverESP = state
        UpdateESP()
    end
})
ESPSection:Colorpicker({
    Title = "拉杆颜色",
    Default = ESPColors.Gate,
    Callback = function(value)
        ESPColors.Gate = value
        Toggles.GateLeverESP = false
        UpdateESP()
        Toggles.GateLeverESP = true
        UpdateESP()
    end
})

Toggles.BooksESP = false
ESPSection:Toggle({
    Title = "书ESP",
    Value = false,
    Callback = function(state)
        Toggles.BooksESP = state
        UpdateESP()
    end
})
ESPSection:Colorpicker({
    Title = "书颜色",
    Default = ESPColors.Book,
    Callback = function(value)
        ESPColors.Book = value
        Toggles.BooksESP = false
        UpdateESP()
        Toggles.BooksESP = true
        UpdateESP()
    end
})

Toggles.BreakerESP = false
ESPSection:Toggle({
    Title = "断路器ESP",
    Value = false,
    Callback = function(state)
        Toggles.BreakerESP = state
        UpdateESP()
    end
})
ESPSection:Colorpicker({
    Title = "断路器颜色",
    Default = ESPColors.Breaker,
    Callback = function(value)
        ESPColors.Breaker = value
        Toggles.BreakerESP = false
        UpdateESP()
        Toggles.BreakerESP = true
        UpdateESP()
    end
})

Toggles.GoldESP = false
ESPSection:Toggle({
    Title = "金币ESP",
    Value = false,
    Callback = function(state)
        Toggles.GoldESP = state
        UpdateESP()
    end
})
ESPSection:Colorpicker({
    Title = "金币颜色",
    Default = ESPColors.Gold,
    Callback = function(value)
        ESPColors.Gold = value
        Toggles.GoldESP = false
        UpdateESP()
        Toggles.GoldESP = true
        UpdateESP()
    end
})

Toggles.EntityESP = false
ESPSection:Toggle({
    Title = "实体ESP",
    Value = false,
    Callback = function(state)
        Toggles.EntityESP = state
        UpdateESP()
    end
})
ESPSection:Colorpicker({
    Title = "实体颜色",
    Default = ESPColors.Entity,
    Callback = function(value)
        ESPColors.Entity = value
        Toggles.EntityESP = false
        UpdateESP()
        Toggles.EntityESP = true
        UpdateESP()
    end
})

Toggles.LadderESP = false
ESPSection:Toggle({
    Title = "梯子ESP",
    Value = false,
    Callback = function(state)
        Toggles.LadderESP = state
        UpdateESP()
    end
})
ESPSection:Colorpicker({
    Title = "梯子颜色",
    Default = ESPColors.Ladder,
    Callback = function(value)
        ESPColors.Ladder = value
        Toggles.LadderESP = false
        UpdateESP()
        Toggles.LadderESP = true
        UpdateESP()
    end
})

Toggles.FuseESP = false
ESPSection:Toggle({
    Title = "保险丝ESP",
    Value = false,
    Callback = function(state)
        Toggles.FuseESP = state
        UpdateESP()
    end
})
ESPSection:Colorpicker({
    Title = "保险丝颜色",
    Default = ESPColors.Fuse,
    Callback = function(value)
        ESPColors.Fuse = value
        Toggles.FuseESP = false
        UpdateESP()
        Toggles.FuseESP = true
        UpdateESP()
    end
})

Toggles.PlayerESP = false
ESPSection:Toggle({
    Title = "玩家ESP",
    Value = false,
    Callback = function(state)
        Toggles.PlayerESP = state
        UpdateESP()
    end
})

Toggles.ChestESP = false
ESPSection:Toggle({
    Title = "箱子ESP",
    Value = false,
    Callback = function(state)
        Toggles.ChestESP = state
        UpdateESP()
    end
})

Toggles.GuidingLightESP = false
ESPSection:Toggle({
    Title = "引导之光ESP",
    Value = false,
    Callback = function(state)
        Toggles.GuidingLightESP = state
        UpdateESP()
    end
})

Toggles.TimerLeverESP = false
ESPSection:Toggle({
    Title = "计时拉杆ESP",
    Value = false,
    Callback = function(state)
        Toggles.TimerLeverESP = state
        UpdateESP()
    end
})

Toggles.GeneratorESP = false
ESPSection:Toggle({
    Title = "发电机ESP",
    Value = false,
    Callback = function(state)
        Toggles.GeneratorESP = state
        UpdateESP()
    end
})

Toggles.AnchorESP = false
ESPSection:Toggle({
    Title = "锚点ESP",
    Value = false,
    Callback = function(state)
        Toggles.AnchorESP = state
        UpdateESP()
    end
})

Toggles.WaterPumpESP = false
ESPSection:Toggle({
    Title = "水泵ESP",
    Value = false,
    Callback = function(state)
        Toggles.WaterPumpESP = state
        UpdateESP()
    end
})

ESPSection:Colorpicker({
    Title = "玩家颜色",
    Default = ESPColors.Player,
    Callback = function(value)
        ESPColors.Player = value
        Toggles.PlayerESP = false
        UpdateESP()
        Toggles.PlayerESP = true
        UpdateESP()
    end
})

Toggles.ShowDistance = false
ESPSection:Toggle({
    Title = "显示距离",
    Value = false,
    Callback = function(state)
        Toggles.ShowDistance = state
        ESPLibrary:SetShowDistance(state)
    end
})

Toggles.ShowTracers = false
ESPSection:Toggle({
    Title = "显示射线",
    Value = false,
    Callback = function(state)
        Toggles.ShowTracers = state
        ESPLibrary:SetTracers(state)
    end
})

Toggles.RainbowESP = false
ESPSection:Toggle({
    Title = "彩虹渐变",
    Value = false,
    Callback = function(state)
        Toggles.RainbowESP = state
        ESPLibrary:SetRainbow(state)
    end
})

ESPSection:Divider()

ESPSection:Dropdown({
    Title = "ESP显示模式",
    Values = {"高亮/文字", "文字", "高亮"},
    Value = "高亮/文字",
    Callback = function(value)
        ESPLibrary:SetESPMode(value)
    end
})

ESPSection:Dropdown({
    Title = "ESP文字字体",
    Values = {"Legacy", "Arial", "ArialBold", "SourceSans", "SourceSansBold", "SourceSansLight", "SourceSansItalic", "Bodoni", "Garamond", "Cartoon", "Code", "Highway", "SciFi", "Arcade", "Fantasy", "Antique", "Gotham", "GothamMedium", "GothamBold", "GothamBlack", "AmaticSC", "Bangers", "Creepster", "DenkOne", "FredokaOne", "IndieFlower", "LuckiestGuy", "Michroma", "Nunito", "Oswald", "PatrickHand", "PermanentMarker", "Roboto", "RobotoCondensed", "RobotoMono", "Sarpanch", "SpecialElite", "TitilliumWeb", "Ubuntu"},
    Value = "Roboto",
    Callback = function(value)
        ESPLibrary:SetFont(value)
    end
})

ESPSection:Slider({
    Title = "ESP文字大小",
    Value = {Min = 12, Max = 30, Default = 16},
    Callback = function(value)
        ESPLibrary:SetTextSize(value)
    end
})

local BypassSection = BypassTab:Section({Title = "实体绕过", Icon = "shield"})

Toggles.AvoidRushAmbush = false
BypassSection:Toggle({
    Title = "反Rush/Ambush伤害",
    Value = false,
    Callback = function(state)
        Toggles.AvoidRushAmbush = state
        task.spawn(function()
            while Toggles.AvoidRushAmbush do
                task.wait(0.1)
                for _, v in pairs(Workspace:GetChildren()) do
                    if (v.Name == "RushMoving" or v.Name == "AmbushMoving") and v.PrimaryPart then
                        local dist = GetDistance(v.PrimaryPart.Position)
                        if dist < 150 then
                            local char = GetCharacter()
                            local collision = char and char:FindFirstChild("Collision")
                            if collision then
                                local oldNoclip = Toggles.NoClip
                                if not Toggles.NoClip then Toggles.NoClip = true end
                                collision.Position = collision.Position + Vector3.new(0, 24, 0)
                                task.wait(0.1)
                                collision.Position = collision.Position - Vector3.new(0, 24, 0)
                                if not oldNoclip then Toggles.NoClip = false end
                            end
                        end
                    end
                end
            end
        end)
    end
})

Toggles.NoJammin = false
BypassSection:Toggle({
    Title = "无Jammin",
    Value = false,
    Callback = function(state)
        Toggles.NoJammin = state
        if liveModifiers and liveModifiers:FindFirstChild("Jammin") then
            local jam = MainGame:FindFirstChild("Jam", true)
            if jam then jam.Playing = not state end
            local jamming = SoundService:FindFirstChild("Jamming", true)
            if jamming then jamming.Enabled = not state end
        end
    end
})

Toggles.AntiScreech = false
BypassSection:Toggle({
    Title = "防 Screech",
    Value = false,
    Callback = function(state)
        Toggles.AntiScreech = state
        local module = MainGame:FindFirstChild("Screech", true) or MainGame:FindFirstChild("_Screech", true)
        if module then
            module.Name = state and "_Screech" or "Screech"
        end
    end
})

Toggles.AntiA90 = false
BypassSection:Toggle({
    Title = "防 A90",
    Value = false,
    Callback = function(state)
        Toggles.AntiA90 = state
        local module = MainGame:FindFirstChild("A90", true) or MainGame:FindFirstChild("_A90", true)
        if module then
            module.Name = state and "_A90" or "A90"
        end
    end
})

Toggles.AntiDread = false
BypassSection:Toggle({
    Title = "防 Dread",
    Value = false,
    Callback = function(state)
        Toggles.AntiDread = state
        local module = RemoteListener:FindFirstChild("Dread", true) or RemoteListener:FindFirstChild("_Dread", true)
        if module then
            module.Name = state and "_Dread" or "Dread"
        end
    end
})

Toggles.AntiHalt = false
BypassSection:Toggle({
    Title = "防 Halt",
    Value = false,
    Callback = function(state)
        Toggles.AntiHalt = state
        local module = ClientModules.EntityModules:FindFirstChild("Shade", true) or ClientModules.EntityModules:FindFirstChild("_Shade", true)
        if module then
            module.Name = state and "_Shade" or "Shade"
        end
    end
})

Toggles.AntiJammin = false
BypassSection:Toggle({
    Title = "防 Jammin",
    Value = false,
    Callback = function(state)
        Toggles.AntiJammin = state
        if liveModifiers and liveModifiers:FindFirstChild("Jammin") then
            local jam = MainGame:FindFirstChild("Jam", true)
            if jam then jam.Playing = not state end
            local jamming = SoundService:FindFirstChild("Jamming", true)
            if jamming then jamming.Enabled = not state end
        end
    end
})

Toggles.AntiSurge = false
BypassSection:Toggle({
    Title = "防 Surge",
    Value = false,
    Callback = function(state)
        Toggles.AntiSurge = state
        if remotesFolder and remotesFolder:FindFirstChild("SurgeRemote") then
            if state then
                remotesFolder.SurgeRemote.Parent = ReplicatedStorage
            else
                ReplicatedStorage:FindFirstChild("SurgeRemote").Parent = remotesFolder
            end
        end
    end
})

Toggles.AntiSnare = false
BypassSection:Toggle({
    Title = "防 藤蔓",
    Value = false,
    Callback = function(state)
        Toggles.AntiSnare = state
        for _, v in pairs(Workspace.CurrentRooms:GetDescendants()) do
            if v.Name == "Snare" and v:FindFirstChild("Hitbox") then
                v.Hitbox.CanTouch = not state
            end
        end
    end
})

Toggles.AntiGiggle = false
BypassSection:Toggle({
    Title = "防 Giggle",
    Value = false,
    Callback = function(state)
        Toggles.AntiGiggle = state
        for _, v in pairs(Workspace.CurrentRooms:GetDescendants()) do
            if v.Name == "GiggleCeiling" and v:FindFirstChild("Hitbox") then
                v.Hitbox.CanTouch = not state
            end
        end
    end
})

Toggles.AntiDupe = false
BypassSection:Toggle({
    Title = "防 假门",
    Value = false,
    Callback = function(state)
        Toggles.AntiDupe = state
        for _, v in pairs(Workspace.CurrentRooms:GetDescendants()) do
            if v.Name == "DoorFake" and v:FindFirstChild("Hidden") then
                v.Hidden.CanTouch = not state
            end
        end
    end
})

Toggles.AntiEyes = false
BypassSection:Toggle({
    Title = "防 Eyes",
    Value = false,
    Callback = function(state)
        Toggles.AntiEyes = state
        task.spawn(function()
            while Toggles.AntiEyes do
                task.wait(0.1)
                if Workspace:FindFirstChild("Eyes") then
                    if remotesFolder and remotesFolder:FindFirstChild("MotorReplication") then
                        if remotesFolder.Name == "Bricks" or remotesFolder.Name == "EntityInfo" then
                            remotesFolder.MotorReplication:FireServer(0, -100, 0, false)
                        else
                            remotesFolder.MotorReplication:FireServer(-890)
                        end
                    end
                end
            end
        end)
    end
})

Toggles.AntiLookman = false
BypassSection:Toggle({
    Title = "防 Lookman",
    Value = false,
    Callback = function(state)
        Toggles.AntiLookman = state
        task.spawn(function()
            while Toggles.AntiLookman do
                task.wait(0.1)
                if Workspace:FindFirstChild("BackdoorLookman") then
                    if remotesFolder and remotesFolder:FindFirstChild("MotorReplication") then
                        remotesFolder.MotorReplication:FireServer(-890)
                    end
                end
            end
        end)
    end
})

Toggles.AntiGloom = false
BypassSection:Toggle({
    Title = "防 Gloom",
    Value = false,
    Callback = function(state)
        Toggles.AntiGloom = state
        for _, v in pairs(Workspace.CurrentRooms:GetDescendants()) do
            if v.Name == "Egg" then
                v.CanTouch = not state
            end
        end
    end
})

Toggles.AntiFigure = false
BypassSection:Toggle({
    Title = "防 Figure",
    Value = false,
    Callback = function(state)
        Toggles.AntiFigure = state
        if remotesFolder and remotesFolder:FindFirstChild("Crouch") then
            remotesFolder.Crouch:FireServer(state)
        end
    end
})

local Bypass2Section = BypassTab:Section({Title = "绕过", Icon = "zap"})

Toggles.SpeedBypass = false
Bypass2Section:Toggle({
    Title = "速度绕过",
    Value = false,
    Callback = function(state)
        Toggles.SpeedBypass = state
    end
})

Options.SpeedBypassMethod = "模式1"
Bypass2Section:Dropdown({
    Title = "速度绕过模式",
    Values = {"模式1", "模式2"},
    Value = "模式1",
    Callback = function(value) Options.SpeedBypassMethod = value end
})

local SpeedBypassConnection = RunService.Heartbeat:Connect(function()
    if Toggles.SpeedBypass then
        local char = GetCharacter()
        if char then
            local clone = char:FindFirstChild("Collision")
            if clone then
                if Options.SpeedBypassMethod == "模式1" then
                    clone.Massless = true
                    task.wait(Options.SpeedBypassDelay or 0.216)
                    clone.Massless = false
                elseif Options.SpeedBypassMethod == "模式2" then
                    local root = GetRoot()
                    if root then
                        local params = RaycastParams.new()
                        params.FilterDescendantsInstances = {char}
                        local result = workspace:Raycast(root.Position, Vector3.new(0, -100, 0), params)
                        if result then
                            clone.Massless = true
                            task.wait(Options.SpeedBypassDelay or 0.216)
                            clone.Massless = false
                        end
                    end
                end
            end
        end
    end
end)
table.insert(Connections, SpeedBypassConnection)

Toggles.AntiCheatMani = false
Options.AntiCheatManiMethod = "平移"
Bypass2Section:Toggle({
    Title = "无视反作弊穿墙 (V)",
    Value = false,
    Callback = function(state)
        Toggles.AntiCheatMani = state
    end
})

Bypass2Section:Dropdown({
    Title = "穿墙方式",
    Values = {"平移", "坐标"},
    Value = "平移",
    Callback = function(value) Options.AntiCheatManiMethod = value end
})

local AntiCheatManiConnection = RunService.Heartbeat:Connect(function()
    if Toggles.AntiCheatMani then
        local root = GetRoot()
        if root then
            if Options.AntiCheatManiMethod == "平移" then
                local bv = root:FindFirstChild("VelocityMani")
                if not bv then
                    bv = Instance.new("BodyVelocity", root)
                    bv.Name = "VelocityMani"
                    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                end
                local look = root.CFrame.LookVector * 2
                bv.Velocity = Vector3.new(look.X, look.Y, look.Z)
            else
                root.CFrame = root.CFrame * CFrame.new(0, 0, 10000)
            end
        end
    end
end)
table.insert(Connections, AntiCheatManiConnection)

local Stored = {}

local Names = {
    Lock = true,
    ChestBoxLocked = true,
    Cellar = true,
    Chest_Vine = true,
    CuttableVines = true,
    SkullLock = true,
    Toolbox_Locked = true,
    Lock1 = true,
    Lock2 = true,
}

local function InfPrompt(Prompt)
    local Char = GetCharacter()
    if not Char then return end

    local RootPart = GetRoot()
    if not RootPart then return end

    local Tool = Char:FindFirstChild("Lockpick") or Char:FindFirstChild("SkeletonKey") or Char:FindFirstChild("Shears")
    local Name = Tool and Tool.Name

    if Tool then
        if Prompt:GetAttribute("InfItems") and Prompt:GetAttribute("Tool") ~= Name then
            if Prompt.Parent then
                local ExistingPrompt = Prompt.Parent:FindFirstChild("InfPrompt")
                if ExistingPrompt then
                    ExistingPrompt:Destroy()
                end
                Prompt:SetAttribute("InfItems", nil)
                Prompt.Enabled = true
            end
        end

        if not Prompt:GetAttribute("InfItems") then
            Prompt.Enabled = false
            Prompt:SetAttribute("InfItems", true)
            Prompt:SetAttribute("Tool", Name)
            Prompt.ClickablePrompt = false

            local Clone = Prompt:Clone()
            Clone.Name = "InfPrompt"
            Clone.MaxActivationDistance = Prompt.MaxActivationDistance * 0.5
            Clone.Parent = Prompt.Parent
            Clone.Enabled = true
            Clone.ClickablePrompt = true

            local Con
            Con = Clone.Triggered:Connect(function()
                Con:Disconnect()
                Clone:Destroy()

                if Char:FindFirstChild(Name) then
                    task.spawn(function()
                        local Drop = nil
                        local StartTime = tick()

                        repeat
                            if remotesFolder and remotesFolder:FindFirstChild("DropItem") then
                                remotesFolder.DropItem:FireServer(Tool)
                            end
                            task.wait(0.01)

                            local ClosestDist = 15
                            for _, v in pairs(Workspace.Drops:GetChildren()) do
                                if v.Name == Name then
                                    local Dist = GetDistance(v:GetPivot().Position)
                                    if Dist < ClosestDist then
                                        ClosestDist = Dist
                                        Drop = v
                                    end
                                end
                            end
                        until Drop or not Char:FindFirstChild(Name) or (tick() - StartTime) > 3

                        if Name == "Shears" then
                            FirePrompt(Prompt)
                            if Drop then
                                local DropPrompt = Drop:FindFirstChildOfClass("ProximityPrompt")
                                if DropPrompt then FirePrompt(DropPrompt) end
                            end
                        else
                            if Drop then
                                local DropPrompt = Drop:FindFirstChildOfClass("ProximityPrompt")
                                if DropPrompt then FirePrompt(DropPrompt) end
                            end
                            FirePrompt(Prompt)
                        end

                        Prompt:SetAttribute("InfItems", nil)
                        Prompt:SetAttribute("Tool", nil)
                        Prompt.Enabled = true
                        Prompt.ClickablePrompt = true
                    end)
                else
                    Prompt:SetAttribute("InfItems", nil)
                    Prompt:SetAttribute("Tool", nil)
                    Prompt.Enabled = true
                    Prompt.ClickablePrompt = true
                end
            end)
        end
    elseif (Char:FindFirstChild("Key") or Char:FindFirstChild("Fuse")) and Prompt:GetAttribute("InfItems") then
        if Prompt.Parent then
            local ExistingPrompt = Prompt.Parent:FindFirstChild("InfPrompt")
            if ExistingPrompt then
                ExistingPrompt:Destroy()
            end
        end
        Prompt:SetAttribute("InfItems", nil)
        Prompt:SetAttribute("Tool", nil)
        Prompt.Enabled = true
        Prompt.ClickablePrompt = true
    end
end

Toggles.InfItems = false
Bypass2Section:Toggle({
    Title = "无限使用道具",
    Value = false,
    Callback = function(state)
        Toggles.InfItems = state
        if state then
            for _, v in pairs(Workspace.CurrentRooms:GetDescendants()) do
                if v:IsA("ProximityPrompt") then
                    if Names[v.Parent.Name] or v.Name == "FusesPrompt" or (v.Parent.Parent and v.Parent.Parent.Name == "Locker_Small_Locked") then
                        table.insert(Stored, v)
                    end
                end
            end
        else
            for _, Prompt in pairs(Workspace.CurrentRooms:GetDescendants()) do
                if Prompt:IsA("ProximityPrompt") then
                    if Names[Prompt.Parent.Name] then
                        if Prompt:GetAttribute("InfItems") then
                            local Fake = Prompt.Parent:FindFirstChild("InfPrompt")
                            if Fake then
                                Fake:Destroy()
                            end
                            Prompt:SetAttribute("InfItems", nil)
                            Prompt.Enabled = true
                            Prompt.ClickablePrompt = true
                        end
                    end
                end
            end
            table.clear(Stored)
        end
    end
})

local InfCrucfixTable = {
    RushMoving = 90,
    AmbushMoving = 160,
    A60 = 140,
    A120 = 99,
    GlitchRush = 150,
    GlitchAmbush = 110,
}

Toggles.InfCrucifix = false
Bypass2Section:Toggle({
    Title = "无限十字架",
    Value = false,
    Callback = function(state)
        Toggles.InfCrucifix = state
    end
})

Toggles.LadderBypass = false
Bypass2Section:Toggle({
    Title = "梯子绕过",
    Value = false,
    Callback = function(state)
        Toggles.LadderBypass = state
    end
})

local LadderBypassConnection = RunService.Heartbeat:Connect(function()
    if Toggles.LadderBypass then
        local char = GetCharacter()
        if char and char:GetAttribute("Climbing") then
            char:SetAttribute("Climbing", false)
        end
    end
end)
table.insert(Connections, LadderBypassConnection)

local FakeReviveActive = false
local FakeReviveConnections = {}

Toggles.FakeRevive = false
Bypass2Section:Toggle({
    Title = "假复活",
    Value = false,
    Callback = function(state)
        Toggles.FakeRevive = state
        if state then
            local char = GetCharacter()
            if char and char:FindFirstChild("Humanoid") then
                local latest = latestRoom and latestRoom.Value or 0
                if latest == 0 then
                    Notify("请先打开一扇门再开启假复活", 5)
                    Toggles.FakeRevive = false
                    return
                end

                local oxygenModule = MainGame:FindFirstChild("Oxygen")
                local healthModule = MainGame:FindFirstChild("Health")
                local cameraModule = MainGame:FindFirstChild("Camera")
                local inventoryModule = MainGame:FindFirstChild("Inventory")

                if oxygenModule and healthModule then
                    task.delay(0.5, function()
                        if not Toggles.FakeRevive then return end
                        oxygenModule.Enabled = false
                        healthModule.Enabled = false
                        inventoryModule.Enabled = false
                    end)
                end

                task.spawn(function()
                    while Toggles.FakeRevive and char and char:GetAttribute("Alive") do
                        if remotesFolder and remotesFolder:FindFirstChild("Underwater") then
                            remotesFolder.Underwater:FireServer(true)
                        end
                        task.wait(0.25)
                    end

                    if char and char:GetAttribute("Alive") and not Toggles.FakeRevive then
                        if remotesFolder and remotesFolder:FindFirstChild("Underwater") then
                            remotesFolder.Underwater:FireServer(false)
                        end
                        if oxygenModule then oxygenModule.Enabled = true end
                        if healthModule then healthModule.Enabled = true end
                        Notify("假复活已禁用，无法杀死玩家", 5)
                        return
                    end

                    if char and not char:GetAttribute("Alive") then
                        FakeReviveActive = true
                        workspace.Gravity = 0

                        if cameraModule then cameraModule.Enabled = false end

                        local mainUI = LocalPlayer.PlayerGui:FindFirstChild("MainUI")
                        if mainUI then
                            for _, hotbarItem in pairs(mainUI.MainFrame.Hotbar:GetChildren()) do
                                if hotbarItem:IsA("TextButton") then
                                    hotbarItem.Visible = false
                                end
                            end
                        end

                        local humanoid = char:FindFirstChild("Humanoid")
                        if humanoid then
                            humanoid.Name = "old_Humanoid"
                            local newHumanoid = humanoid:Clone()
                            newHumanoid.Parent = char
                            newHumanoid.Name = "Humanoid"
                            task.wait()
                            humanoid:Destroy()
                            workspace.CurrentCamera.CameraSubject = char
                            newHumanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
                        end

                        local root = GetRoot()
                        if root then
                            local determined_cframe = root.CFrame * CFrame.new(math.random(-100, 100)/200, math.random(-100, 100)/200, math.random(-100, 100)/200)
                            root.CFrame = determined_cframe
                            local atempts = 0
                            repeat task.wait()
                                atempts = atempts + 1
                                root.CFrame = determined_cframe
                            until atempts > 250 and atempts > 2
                        end

                        for _, part in pairs(char:GetDescendants()) do
                            if part:IsA("BasePart") and part.Name ~= "UpperTorso" and part.Name ~= "Collision" and part.Parent.Name ~= "Collision" then
                                part.Massless = true
                                part.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5, 1, 1)
                            end
                        end

                        for _, weld in pairs(char:GetChildren()) do
                            if weld:IsA("Weld") then weld:Destroy() end
                        end

                        workspace.CurrentCamera.CameraSubject = char:FindFirstChildOfClass("Humanoid")
                        workspace.CurrentCamera.CameraType = "Custom"
                        LocalPlayer.CameraMinZoomDistance = 0.5
                        LocalPlayer.CameraMaxZoomDistance = 400
                        LocalPlayer.CameraMode = "Classic"

                        local head = char:FindFirstChild("Head")
                        if head then head.Anchored = false end

                        local humanoidDescription = Players:GetHumanoidDescriptionFromUserId(LocalPlayer.UserId)
                        humanoidDescription.HeightScale = 1.2

                        local previewCharacter = Players:CreateHumanoidModelFromDescription(humanoidDescription, Enum.HumanoidRigType.R15)
                        previewCharacter.Parent = Workspace
                        previewCharacter.Name = "PreviewCharacter"
                        previewCharacter.HumanoidRootPart.Anchored = true

                        local upperTorso = char:FindFirstChild("UpperTorso")
                        if upperTorso then upperTorso.CanCollide = false end

                        local leftFoot = char:FindFirstChild("LeftFoot")
                        if leftFoot then leftFoot.CanCollide = true end
                        local rightFoot = char:FindFirstChild("RightFoot")
                        if rightFoot then rightFoot.CanCollide = true end

                        local function generateCharacterCFrame(obj)
                            local obj_pos = obj.Position
                            return CFrame.new(obj_pos, obj_pos - (Vector3.new(workspace.CurrentCamera.CFrame.Position.X, obj_pos.Y, workspace.CurrentCamera.CFrame.Position.Z) - obj_pos).unit)
                        end

                        local FakeReviveRenderConn = RunService.RenderStepped:Connect(function()
                            if char:FindFirstChild("Humanoid") then
                                char.Humanoid.WalkSpeed = 15
                            end

                            if root and root.Position.Y < -150 then
                                root.Position = workspace.SpawnLocation.Position
                            end

                            if char:FindFirstChild("UpperTorso") then
                                char.UpperTorso.CanCollide = false
                            end

                            if previewCharacter then
                                previewCharacter:PivotTo(generateCharacterCFrame(root.CFrame * CFrame.new(0, 1000, 0)))
                            end

                            if root then
                                root.Transparency = 1
                                root.CanCollide = false
                            end
                        end)
                        table.insert(FakeReviveConnections, FakeReviveRenderConn)

                        for _, room in pairs(Workspace.CurrentRooms:GetChildren()) do
                            task.spawn(function()
                                local roomDetectPart = room:WaitForChild(room.Name, math.huge)
                                if roomDetectPart then
                                    roomDetectPart.Size = Vector3.new(roomDetectPart.Size.X, roomDetectPart.Size.Y * 250, roomDetectPart.Size.Z)
                                    local touchEvent = roomDetectPart.Touched:Connect(function(hit)
                                        if hit.Parent == LocalPlayer.Character then
                                            LocalPlayer:SetAttribute("CurrentRoom", tonumber(room.Name))
                                        end
                                    end)
                                    table.insert(FakeReviveConnections, touchEvent)
                                end
                            end)
                        end

                        local CurrentRoomFixConn = workspace.CurrentRooms.ChildAdded:Connect(function(room)
                            task.spawn(function()
                                local roomDetectPart = room:WaitForChild(room.Name, math.huge)
                                if roomDetectPart then
                                    roomDetectPart.Size = Vector3.new(roomDetectPart.Size.X, roomDetectPart.Size.Y * 100, roomDetectPart.Size.Z)
                                    local touchEvent = roomDetectPart.Touched:Connect(function(hit)
                                        if hit.Parent == LocalPlayer.Character then
                                            LocalPlayer:SetAttribute("CurrentRoom", tonumber(room.Name))
                                        end
                                    end)
                                    table.insert(FakeReviveConnections, touchEvent)
                                end
                            end)
                        end)
                        table.insert(FakeReviveConnections, CurrentRoomFixConn)

                        Notify("假复活已启动！", 3)
                    end
                end)
            end
        else
            FakeReviveActive = false
            for _, conn in pairs(FakeReviveConnections) do
                pcall(function() conn:Disconnect() end)
            end
            table.clear(FakeReviveConnections)
            workspace.Gravity = 90

            local char = GetCharacter()
            if char then
                local humanoid = char:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.BreakJointsOnDeath = true
                    humanoid.RequiresNeck = true
                    humanoid.PlatformStand = false
                    humanoid.AutomaticScalingEnabled = true
                end
                local root = GetRoot()
                if root then
                    root.Transparency = 0
                    root.CanCollide = true
                end
                local upperTorso = char:FindFirstChild("UpperTorso")
                if upperTorso then upperTorso.CanCollide = true end
            end

            if MainGame then
                local oxygenModule = MainGame:FindFirstChild("Oxygen")
                local healthModule = MainGame:FindFirstChild("Health")
                if oxygenModule then oxygenModule.Enabled = true end
                if healthModule then healthModule.Enabled = true end
            end
        end
    end
})

local InfItemsConnection = RunService.Heartbeat:Connect(function()
    if Toggles.InfItems then
        for _, Prompt in pairs(Stored) do
            InfPrompt(Prompt)
        end
    end
end)
table.insert(Connections, InfItemsConnection)

local InfCrucifixConnection = RunService.Heartbeat:Connect(function()
    if Toggles.InfCrucifix then
        local char = GetCharacter()
        if not char then return end
        local root = GetRoot()
        if not root then return end
        local Origin = root.Position
        local InfParams = RaycastParams.new()
        InfParams.FilterType = Enum.RaycastFilterType.Exclude

        for _, Entity in pairs(Workspace:GetChildren()) do
            local Range = InfCrucfixTable[Entity.Name]
            if Range and Entity.PrimaryPart then
                local Target = Entity.PrimaryPart.Position
                if (Origin - Target).Magnitude < Range then
                    InfParams.FilterDescendantsInstances = {char, Entity}
                    if not workspace:Raycast(Origin, Target - Origin, InfParams) then
                        local crucifix = char:FindFirstChild("Crucifix")
                        if crucifix and remotesFolder and remotesFolder:FindFirstChild("DropItem") then
                            remotesFolder.DropItem:FireServer(crucifix)
                            repeat task.wait()
                                local Drop = Workspace.Drops:FindFirstChild("Crucifix")
                                if Drop and Drop:FindFirstChildOfClass("ProximityPrompt") then
                                    FirePrompt(Drop:FindFirstChildOfClass("ProximityPrompt"))
                                end
                            until char:FindFirstChild("Crucifix")
                        end
                    end
                end
            end
        end
    end
end)
table.insert(Connections, InfCrucifixConnection)

local FloorSection = FloorTab:Section({Title = "酒店", Icon = "building"})

Toggles.LibraryHint = false
FloorSection:Toggle({
    Title = "图书馆密码提示",
    Value = false,
    Callback = function(state)
        Toggles.LibraryHint = state
        task.spawn(function()
            while Toggles.LibraryHint do
                task.wait(3)
                if GetLatestRoom() == 50 then
                    local code = GetLibraryCode()
                    if code and #code > 0 then
                        Notify("图书馆密码: " .. code, 5)
                    end
                end
            end
        end)
    end
})

Toggles.AntiSeekObstacle = false
FloorSection:Toggle({
    Title = "防Seek障碍",
    Value = false,
    Callback = function(state)
        Toggles.AntiSeekObstacle = state
        for _, v in pairs(Workspace.CurrentRooms:GetDescendants()) do
            if v.Name == "ChandelierObstruction" or v.Name == "Seek_Arm" then
                for _, part in pairs(v:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanTouch = not state
                    end
                end
            end
        end
    end
})

Toggles.AutoDoors = false
FloorSection:Toggle({
    Title = "自动门 (99门)",
    Value = false,
    Callback = function(state)
        Toggles.AutoDoors = state
        if state then
            if not Toggles.AntiFigure then Toggles.AntiFigure = true end
            if not Toggles.NoCutscenes then Toggles.NoCutscenes = true end
        end
        task.spawn(function()
            while Toggles.AutoDoors and GetLatestRoom() < 99 do
                task.wait(0.5)
                local room = GetLatestRoom()
                if room and Workspace.CurrentRooms and Workspace.CurrentRooms[room] then
                    local door = Workspace.CurrentRooms[room]:FindFirstChild("Door")
                    if door and door:FindFirstChild("Door") then
                        door.Door.CanCollide = false
                        local clientOpen = door:FindFirstChild("ClientOpen")
                        if clientOpen then clientOpen:FireServer() end
                    end
                    local key = Workspace.CurrentRooms[room]:FindFirstChild("KeyObtain", true)
                    if key and not LocalPlayer.Character:FindFirstChild("Key") then
                        GetHumanoid():MoveTo(key.PrimaryPart.Position)
                    end
                end
            end
        end)
    end
})

local MinesSection = FloorTab:Section({Title = "矿山", Icon = "pickaxe"})

Toggles.FastLadder = false
MinesSection:Toggle({
    Title = "快速爬梯",
    Value = false,
    Callback = function(state)
        Toggles.FastLadder = state
        task.spawn(function()
            while Toggles.FastLadder do
                task.wait(0.1)
                local char = GetCharacter()
                if char and char:GetAttribute("Climbing") then
                    char:SetAttribute("SpeedBoostBehind", 50)
                end
            end
        end)
    end
})

Options.MaxSlopeAngle = 45
MinesSection:Slider({
    Title = "最大地板角度",
    Value = {Min = 0, Max = 90, Default = 45},
    Callback = function(value)
        Options.MaxSlopeAngle = value
        local hum = GetHumanoid()
        if hum then hum.MaxSlopeAngle = value end
    end
})

Toggles.TheMinesAnticheatBypass = false
MinesSection:Toggle({
    Title = "抗高温绕过",
    Value = false,
    Callback = function(state)
        Toggles.TheMinesAnticheatBypass = state
        task.spawn(function()
            while Toggles.TheMinesAnticheatBypass do
                task.wait(0.5)
                local char = GetCharacter()
                if char and char:GetAttribute("Climbing") then
                    char:SetAttribute("Climbing", false)
                    if remotesFolder and remotesFolder:FindFirstChild("ClimbLadder") then
                        remotesFolder.ClimbLadder:FireServer()
                    end
                    Notify("已绕过反作弊", 3)
                    break
                end
            end
        end)
    end
})

MinesSection:Button({
    Title = "自动200门水泵",
    Icon = "play",
    Callback = function()
        if GetLatestRoom() < 99 then
            Notify("未到达200号门", 3)
            return
        end
        local char = GetCharacter()
        local root = GetRoot()
        if not char or not root then return end
        local bypassing = Toggles.SpeedBypass
        if bypassing then Toggles.SpeedBypass = false end
        local startPos = root.CFrame
        local damHandler = Workspace.CurrentRooms[GetLatestRoom()]:FindFirstChild("_DamHandler")
        if damHandler then
            if damHandler:FindFirstChild("PlayerBarriers1") then
                for _, pump in pairs(damHandler.Flood1.Pumps:GetChildren()) do
                    char:PivotTo(pump.Wheel.CFrame)
                    task.wait(0.25)
                    if pump.Wheel:FindFirstChild("ValvePrompt") then
                        FirePrompt(pump.Wheel.ValvePrompt)
                    end
                    task.wait(0.25)
                end
                task.wait(8)
            end
            if damHandler:FindFirstChild("PlayerBarriers2") then
                for _, pump in pairs(damHandler.Flood2.Pumps:GetChildren()) do
                    char:PivotTo(pump.Wheel.CFrame)
                    task.wait(0.25)
                    if pump.Wheel:FindFirstChild("ValvePrompt") then
                        FirePrompt(pump.Wheel.ValvePrompt)
                    end
                    task.wait(0.25)
                end
                task.wait(8)
            end
            if damHandler:FindFirstChild("PlayerBarriers3") then
                for _, pump in pairs(damHandler.Flood3.Pumps:GetChildren()) do
                    char:PivotTo(pump.Wheel.CFrame)
                    task.wait(0.25)
                    if pump.Wheel:FindFirstChild("ValvePrompt") then
                        FirePrompt(pump.Wheel.ValvePrompt)
                    end
                    task.wait(0.25)
                end
                task.wait(10)
            end
        end
        local generator = Workspace.CurrentRooms[GetLatestRoom()]:FindFirstChild("MinesGenerator", true)
        if generator then
            char:PivotTo(generator.PrimaryPart.CFrame)
            task.wait(0.25)
            if generator.Lever:FindFirstChild("LeverPrompt") then
                FirePrompt(generator.Lever.LeverPrompt)
            end
            task.wait(0.25)
        end
        if bypassing then Toggles.SpeedBypass = true end
        char:PivotTo(startPos)
        Notify("水泵任务完成", 3)
    end
})

Toggles.MinecartTeleport = false
MinesSection:Toggle({
    Title = "矿车传送",
    Value = false,
    Callback = function(state)
        Toggles.MinecartTeleport = state
        task.spawn(function()
            while Toggles.MinecartTeleport do
                task.wait(0.5)
                local minecartRig = Camera:FindFirstChild("MinecartRig")
                if minecartRig then
                    local minecartRoot = minecartRig:FindFirstChild("Root")
                    if minecartRoot then
                        local room = GetLatestRoom()
                        if room >= 45 and room <= 49 then
                            for _, v in pairs(Workspace.CurrentRooms:GetDescendants()) do
                                if v.Name == "MinecartNode" .. room + 1 then
                                    minecartRoot.CFrame = v.CFrame
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
})

Toggles.MinecartPathVisualiser = false
local pathNodes = Instance.new("Folder", Workspace)
pathNodes.Name = "MinecartPathNodes"
MinesSection:Toggle({
    Title = "矿车路径可视化",
    Value = false,
    Callback = function(state)
        Toggles.MinecartPathVisualiser = state
        if state then
            pathNodes:ClearAllChildren()
            for _, v in pairs(Workspace.CurrentRooms:GetDescendants()) do
                if string.find(v.Name, "MinecartNode") then
                    local part = Instance.new("Part", pathNodes)
                    part.Size = Vector3.new(0.7, 0.7, 0.7)
                    part.Shape = Enum.PartType.Ball
                    part.Position = v.Position
                    part.Anchored = true
                    part.CanCollide = false
                    part.CanTouch = false
                    part.Color = Color3.new(0, 1, 0)
                    part.Material = Enum.Material.Neon
                    part.Transparency = 0
                end
            end
        else
            pathNodes:ClearAllChildren()
        end
    end
})

local PathVisualiserConnection = RunService.Heartbeat:Connect(function()
    if Toggles.MinecartPathVisualiser then
        local existingNodes = {}
        for _, part in pairs(pathNodes:GetChildren()) do
            existingNodes[part.Position] = true
        end

        for _, v in pairs(Workspace.CurrentRooms:GetDescendants()) do
            if string.find(v.Name, "MinecartNode") then
                if not existingNodes[v.Position] then
                    local part = Instance.new("Part", pathNodes)
                    part.Size = Vector3.new(0.7, 0.7, 0.7)
                    part.Shape = Enum.PartType.Ball
                    part.Position = v.Position
                    part.Anchored = true
                    part.CanCollide = false
                    part.CanTouch = false
                    part.Color = Color3.new(0, 1, 0)
                    part.Material = Enum.Material.Neon
                    part.Transparency = 0
                end
            end
        end
    end
end)
table.insert(Connections, PathVisualiserConnection)

local PathVisualiserCleanup = workspace.CurrentRooms.ChildAdded:Connect(function()
    if Toggles.MinecartPathVisualiser then
        task.wait(0.5)
        pathNodes:ClearAllChildren()
        for _, v in pairs(Workspace.CurrentRooms:GetDescendants()) do
            if string.find(v.Name, "MinecartNode") then
                local part = Instance.new("Part", pathNodes)
                part.Size = Vector3.new(0.7, 0.7, 0.7)
                part.Shape = Enum.PartType.Ball
                part.Position = v.Position
                part.Anchored = true
                part.CanCollide = false
                part.CanTouch = false
                part.Color = Color3.new(0, 1, 0)
                part.Material = Enum.Material.Neon
                part.Transparency = 0
            end
        end
    end
end)
table.insert(Connections, PathVisualiserCleanup)

Toggles.DeleteFigure = false
MinesSection:Toggle({
    Title = "删除 Figure (FE)",
    Value = false,
    Callback = function(state)
        Toggles.DeleteFigure = state
        task.spawn(function()
            while Toggles.DeleteFigure do
                task.wait(0.5)
                local figure = Workspace.CurrentRooms:FindFirstChild("FigureRig", true) or Workspace.CurrentRooms:FindFirstChild("FigureRagdoll", true)
                if figure and figure:FindFirstChild("Root") then
                    local root = figure.Root
                    if root then
                        root.Size = Vector3.new(0.4, 2000, 0.4)
                        root.CanCollide = false
                        root.Anchored = false
                        figure.PrimaryPart = root
                        if root.Position.Y > -1000 then
                            root.CFrame = CFrame.new(root.Position.X, -50000, root.Position.Z)
                        end
                    end
                end
            end
        end)
    end
})

Toggles.ShowSeekPath = false
local seekPathFolder = Instance.new("Folder", Workspace)
seekPathFolder.Name = "SeekPath"
MinesSection:Toggle({
    Title = "显示Seek路径",
    Value = false,
    Callback = function(state)
        Toggles.ShowSeekPath = state
        if state then
            for _, v in pairs(Workspace.CurrentRooms:GetDescendants()) do
                if v.Name == "SeekGuidingLight" then
                    local part = Instance.new("Part", seekPathFolder)
                    part.Size = Vector3.new(1.5, 1.5, 1.5)
                    part.Anchored = true
                    part.Shape = "Ball"
                    part.Position = v.Position
                    part.CanCollide = false
                    part.Color = Color3.new(0, 1, 0)
                    Debris:AddItem(part, 60)
                end
            end
        else
            seekPathFolder:ClearAllChildren()
        end
    end
})

Toggles.FixBridge = false
MinesSection:Toggle({
    Title = "修补断桥",
    Value = false,
    Callback = function(state)
        Toggles.FixBridge = state
        for _, v in pairs(Workspace.CurrentRooms:GetDescendants()) do
            if v.Name == "Bridge" then
                for _, i in pairs(v:GetChildren()) do
                    if i.Name == "PlayerBarrier" and i.Rotation.X == 180 then
                        if state then
                            local barrier = i:Clone()
                            barrier.CFrame = CFrame.new(i.Position.X, i.Position.Y - 7, i.Position.Z)
                            barrier.Size = Vector3.new(40, 0.1, 40)
                            barrier.Transparency = 0.5
                            barrier.Color = Color3.new(0.5, 0, 0.5)
                            barrier.Material = Enum.Material.ForceField
                            barrier.Parent = v
                            barrier.Name = "BridgeBarrier"
                            barrier.Anchored = true
                            barrier.CanCollide = true
                        else
                            local barrier = v:FindFirstChild("BridgeBarrier")
                            if barrier then barrier:Destroy() end
                        end
                    end
                end
            end
        end
    end
})

Toggles.AutoMinecart = false
MinesSection:Toggle({
    Title = "自动矿车",
    Value = false,
    Callback = function(state)
        Toggles.AutoMinecart = state
    end
})

Toggles.AutoAnchor = false
MinesSection:Toggle({
    Title = "自动锚点",
    Value = false,
    Callback = function(state)
        Toggles.AutoAnchor = state
        task.spawn(function()
            while Toggles.AutoAnchor and GetLatestRoom() == 50 do
                task.wait(1)
                local anchorFrame = LocalPlayer.PlayerGui.MainUI:FindFirstChild("AnchorHintFrame")
                if anchorFrame and anchorFrame.Visible then
                    local anchorCode = anchorFrame.AnchorCode.Text
                    local code = anchorFrame.Code.Text
                    for _, v in pairs(Workspace.CurrentRooms:GetDescendants()) do
                        if v.Name == "MinesAnchor" and v:FindFirstChild("Sign") then
                            local sign = v.Sign:FindFirstChild("TextLabel")
                            if sign and sign.Text == anchorCode then
                                local remote = v:FindFirstChildOfClass("RemoteFunction")
                                if remote then
                                    remote:InvokeServer(code)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
})

Toggles.AntiSeekFlood = false
MinesSection:Toggle({
    Title = "防Seek洪水",
    Value = false,
    Callback = function(state)
        Toggles.AntiSeekFlood = state
        for _, v in pairs(Workspace.CurrentRooms:GetDescendants()) do
            if v.Name == "SeekFloodline" then
                v.CanCollide = state
            end
        end
    end
})

local FoolsSection = FloorTab:Section({Title = "愚人节", Icon = "smile"})

local holdingItem = nil
local holdTrack = nil
local throwTrack = nil

Toggles.GrabBananaJeff = false
FoolsSection:Toggle({
    Title = "抓香蕉/Jeff",
    Value = false,
    Callback = function(state)
        Toggles.GrabBananaJeff = state
        if not state then
            if holdingItem then
                local target = holdingItem
                if target:IsA("BasePart") then
                    target.CanTouch = true
                    target.CanCollide = target:GetAttribute("Clip") or true
                    local gyro = target:FindFirstChildOfClass("BodyGyro")
                    if gyro then gyro:Destroy() end
                end
                holdingItem = nil
            end
            if holdTrack then
                holdTrack:Stop()
                holdTrack = nil
            end
        end
    end
})

Toggles.ThrowBananaJeff = false
FoolsSection:Toggle({
    Title = "投掷香蕉/Jeff",
    Value = false,
    Callback = function(state) Toggles.ThrowBananaJeff = state end
})

Options.ThrowStrength = 1
FoolsSection:Slider({
    Title = "投掷力量",
    Value = {Min = 1, Max = 10, Default = 1},
    Callback = function(value) Options.ThrowStrength = value end
})

local GrabBananaJeffConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if UserInputService:GetFocusedTextBox() then return end

    if Toggles.GrabBananaJeff and input.UserInputType == Enum.UserInputType.MouseButton1 then
        local char = GetCharacter()
        if not char then return end

        local mouse = LocalPlayer:GetMouse()
        if not mouse then return end

        local target = mouse.Target
        if not target then return end

        local targetModel = target:FindFirstAncestorOfClass("Model")
        local isBanana = target.Name == "BananaPeel"
        local isJeff = targetModel and targetModel.Name == "JeffTheKiller"

        if (isBanana or isJeff) and not holdingItem then
            local grabTarget = isBanana and target or targetModel.PrimaryPart

            if grabTarget and (isnetworkowner and isnetworkowner(grabTarget) or true) then
                local hum = GetHumanoid()
                if hum then
                    local anims = char:FindFirstChild("Animations")
                    if anims then
                        local holdAnim = anims:FindFirstChild("Hold")
                        if holdAnim then
                            holdTrack = hum:LoadAnimation(holdAnim)
                            if holdTrack then holdTrack:Play() end
                        end
                    end
                end

                if not grabTarget:FindFirstChildOfClass("BodyGyro") then
                    local gyro = Instance.new("BodyGyro", grabTarget)
                    gyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                    gyro.P = 3000
                end

                if not grabTarget:GetAttribute("Clip") then
                    grabTarget:SetAttribute("Clip", grabTarget.CanCollide)
                end

                grabTarget.CanTouch = false
                grabTarget.CanCollide = false
                grabTarget.AssemblyAngularVelocity = Vector3.zero
                grabTarget.AssemblyLinearVelocity = Vector3.zero

                holdingItem = grabTarget
            end
        elseif holdingItem and isBanana and target == holdingItem then
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local gyro = holdingItem:FindFirstChildOfClass("BodyGyro")
                if gyro then gyro:Destroy() end
                holdingItem.CanTouch = true
                holdingItem.CanCollide = holdingItem:GetAttribute("Clip") or true
                holdingItem.AssemblyLinearVelocity = Vector3.zero
                holdingItem = nil
                if holdTrack then
                    holdTrack:Stop()
                    holdTrack = nil
                end
            end
        end
    end

    if Toggles.ThrowBananaJeff and holdingItem and input.KeyCode == Enum.KeyCode.G then
        local char = GetCharacter()
        if not char then return end

        local hum = GetHumanoid()
        if hum then
            local anims = char:FindFirstChild("Animations")
            if anims then
                local throwAnim = anims:FindFirstChild("Throw")
                if throwAnim then
                    throwTrack = hum:LoadAnimation(throwAnim)
                    if throwTrack then throwTrack:Play() end
                end
            end
        end

        task.wait(0.35)

        local gyro = holdingItem:FindFirstChildOfClass("BodyGyro")
        if gyro then gyro:Destroy() end

        local cam = workspace.CurrentCamera
        if cam then
            local velocity = cam.CFrame.LookVector * 50 * Options.ThrowStrength
            holdingItem.CFrame = cam.CFrame:ToWorldSpace(CFrame.new(0, 0, -3))
            holdingItem.Velocity = velocity
            holdingItem.AssemblyAngularVelocity = Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10))
        end

        holdingItem.CanTouch = true
        holdingItem.CanCollide = holdingItem:GetAttribute("Clip") or true

        if holdingItem:FindFirstAncestorOfClass("Model") and holdingItem:FindFirstAncestorOfClass("Model").Name == "JeffTheKiller" then
            local jeff = holdingItem:FindFirstAncestorOfClass("Model")
            for _, part in pairs(jeff:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanTouch = not Toggles.AntiJeffClient or true
                    part.CanCollide = part:GetAttribute("Clip") or true
                end
            end
        end

        if holdTrack then
            holdTrack:Stop()
            holdTrack = nil
        end
        if throwTrack then
            task.wait(0.5)
            throwTrack:Stop()
            throwTrack = nil
        end

        holdingItem = nil
    end
end)
table.insert(Connections, GrabBananaJeffConnection)

local HoldingItemUpdate = RunService.Heartbeat:Connect(function()
    if Toggles.GrabBananaJeff and holdingItem then
        local char = GetCharacter()
        if not char then
            if holdingItem then
                holdingItem.CanTouch = true
                holdingItem.CanCollide = holdingItem:GetAttribute("Clip") or true
                local gyro = holdingItem:FindFirstChildOfClass("BodyGyro")
                if gyro then gyro:Destroy() end
                holdingItem = nil
                if holdTrack then
                    holdTrack:Stop()
                    holdTrack = nil
                end
            end
            return
        end

        if not isnetworkowner or (isnetworkowner and not isnetworkowner(holdingItem)) then
            if holdingItem then
                holdingItem.CanTouch = true
                holdingItem.CanCollide = holdingItem:GetAttribute("Clip") or true
                local gyro = holdingItem:FindFirstChildOfClass("BodyGyro")
                if gyro then gyro:Destroy() end
                holdingItem = nil
                if holdTrack then
                    holdTrack:Stop()
                    holdTrack = nil
                end
            end
            return
        end

        local rightHand = char:FindFirstChild("RightHand")
        if rightHand then
            holdingItem.CFrame = rightHand.CFrame
            holdingItem.AssemblyAngularVelocity = Vector3.zero
            holdingItem.AssemblyLinearVelocity = Vector3.zero
        end
    end
end)
table.insert(Connections, HoldingItemUpdate)

Toggles.GodmodeFools = false
FoolsSection:Toggle({
    Title = "上帝模式",
    Value = false,
    Callback = function(state)
        Toggles.GodmodeFools = state
        local char = GetCharacter()
        if char then
            if state then
                char.Collision.Position = char.Collision.Position - Vector3.new(0, 11, 0)
            else
                char.Collision.Position = char.Collision.Position + Vector3.new(0, 11, 0)
            end
        end
    end
})

Toggles.FigureGodmodeFools = false
FoolsSection:Toggle({
    Title = "Figure上帝模式",
    Value = false,
    Callback = function(state)
        Toggles.FigureGodmodeFools = state
        for _, v in pairs(Workspace.CurrentRooms:GetDescendants()) do
            if v.Name == "FigureRagdoll" then
                for _, part in pairs(v:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanTouch = not state
                    end
                end
            end
        end
    end
})

Toggles.AntiJeffServer = false
FoolsSection:Toggle({
    Title = "反Jeff服务器",
    Value = false,
    Callback = function(state)
        Toggles.AntiJeffServer = state
        task.spawn(function()
            while Toggles.AntiJeffServer do
                task.wait(0.5)
                local jeff = Workspace:FindFirstChild("JeffTheKiller")
                if jeff and jeff:FindFirstChildOfClass("Humanoid") then
                    jeff:FindFirstChildOfClass("Humanoid").Health = 0
                end
            end
        end)
    end
})

local holdingItem = nil
RunService.Heartbeat:Connect(function()
    if Toggles.GrabBananaJeff then
        local char = GetCharacter()
        if not char then return end
        local mouse = UserInputService.KeyboardEnabled and LocalPlayer:GetMouse() or nil
        if mouse and mouse.Target then
            local target = mouse.Target
            local targetModel = target:FindFirstAncestorOfClass("Model")
            if target.Name == "BananaPeel" or (targetModel and targetModel.Name == "JeffTheKiller") then
                if not holdingItem then
                    holdingItem = target
                    if target:IsA("BasePart") then
                        target.CanTouch = false
                        target.CanCollide = false
                    end
                end
            end
        end
        if holdingItem then
            local rightHand = char:FindFirstChild("RightHand")
            if rightHand then
                holdingItem.CFrame = rightHand.CFrame
            end
        end
    else
        holdingItem = nil
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if Toggles.ThrowBananaJeff and holdingItem and input.KeyCode == Enum.KeyCode.G then
        local velocity = Camera.CFrame.LookVector * 50 * Options.ThrowStrength
        if holdingItem:IsA("BasePart") then
            holdingItem.Velocity = velocity
            holdingItem.CanTouch = true
            holdingItem.CanCollide = true
        end
        holdingItem = nil
    end
end)

Toggles.AntiBanana = false
FoolsSection:Toggle({
    Title = "无视香蕉皮",
    Value = false,
    Callback = function(state)
        Toggles.AntiBanana = state
        for _, v in pairs(Workspace:GetChildren()) do
            if v.Name == "BananaPeel" then
                v.CanTouch = not state
            end
        end
    end
})

Toggles.AntiJeff = false
FoolsSection:Toggle({
    Title = "防 Jeff",
    Value = false,
    Callback = function(state)
        Toggles.AntiJeff = state
        local jeff = Workspace:FindFirstChild("JeffTheKiller")
        if jeff then
            for _, part in pairs(jeff:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanTouch = not state
                end
            end
            if state then
                local hum = jeff:FindFirstChildOfClass("Humanoid")
                if hum then hum.Health = 0 end
            end
        end
    end
})

Toggles.InfRevive = false
FoolsSection:Toggle({
    Title = "无限复活",
    Value = false,
    Callback = function(state)
        Toggles.InfRevive = state
        task.spawn(function()
            while Toggles.InfRevive do
                task.wait(0.5)
                if not IsAlive() and remotesFolder and remotesFolder:FindFirstChild("Revive") then
                    remotesFolder.Revive:FireServer()
                end
            end
        end)
    end
})

Toggles.DeleteSeekFE = false
FoolsSection:Toggle({
    Title = "删除Seek (FE)",
    Value = false,
    Callback = function(state)
        Toggles.DeleteSeekFE = state
        task.spawn(function()
            while Toggles.DeleteSeekFE do
                task.wait(0.1)
                local seekCollision = Workspace:FindFirstChild("TriggerEventCollision", true)
                if seekCollision then
                    seekCollision:ClearAllChildren()
                end
                local trigger = Workspace:FindFirstChild("TriggerSeek", true)
                if trigger then trigger:Destroy() end
            end
        end)
    end
})

local RoomsSection = FloorTab:Section({Title = "Rooms", Icon = "door"})

Toggles.AutoRooms = false
RoomsSection:Toggle({
    Title = "自动 A-1000",
    Value = false,
    Callback = function(state)
        Toggles.AutoRooms = state
        if state then Toggles.IgnoreA60 = true end
        task.spawn(function()
            while Toggles.AutoRooms and GetLatestRoom() < 1000 do
                task.wait(0.1)
                local entity = Workspace:FindFirstChild("A60") or Workspace:FindFirstChild("A120")
                local door = Workspace.CurrentRooms and Workspace.CurrentRooms[GetLatestRoom()]
                if door and door:FindFirstChild("Door") and door.Door:FindFirstChild("Door") then
                    local target = door.Door.Door
                    if entity and entity.PrimaryPart and entity.PrimaryPart.Position.Y > -10 then
                        local locker = GetNearestLocker()
                        if locker and locker:FindFirstChild("HidePrompt") then
                            FirePrompt(locker.HidePrompt)
                        end
                    else
                        local hum = GetHumanoid()
                        if hum then hum:MoveTo(target.Position) end
                    end
                end
            end
            if GetLatestRoom() >= 1000 then
                Notify("已到达 A-1000", 5)
            end
        end)
    end
})

Toggles.IgnoreA60 = false
RoomsSection:Toggle({
    Title = "防 A-60",
    Value = false,
    Callback = function(state)
        Toggles.IgnoreA60 = state
    end
})

local RetroSection = FloorTab:Section({Title = "复古", Icon = "clock"})

Toggles.AntiWall = false
RetroSection:Toggle({
    Title = "防Seek障碍",
    Value = false,
    Callback = function(state)
        Toggles.AntiWall = state
        for _, v in pairs(Workspace.CurrentRooms:GetDescendants()) do
            if v.Name == "ScaryWall" then
                for _, part in pairs(v:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanTouch = not state
                    end
                end
            end
        end
    end
})

Toggles.AntiLava = false
RetroSection:Toggle({
    Title = "无视岩浆",
    Value = false,
    Callback = function(state)
        Toggles.AntiLava = state
        for _, v in pairs(Workspace.CurrentRooms:GetDescendants()) do
            if v.Name == "Lava" then
                v.CanTouch = not state
            end
        end
    end
})

Toggles.ShowBridge = false
RetroSection:Toggle({
    Title = "显示桥梁",
    Value = false,
    Callback = function(state)
        Toggles.ShowBridge = state
        for _, v in pairs(Workspace.CurrentRooms:GetDescendants()) do
            if v.Name == "Bridge" and not v.CanCollide then
                v.Transparency = state and 1 or 0
            end
        end
    end
})

local SettingsSection = SettingsTab:Section({Title = "设置", Icon = "settings"})

isChinese = false
SettingsSection:Toggle({
    Title = "中文语言",
    Value = false,
    Callback = function(state)
        isChinese = state
        Notify(isChinese and "已切换为中文" or "Switched to English", 2)
    end
})

Toggles.FpsUnlocker = false
SettingsSection:Toggle({
    Title = "FPS解锁器",
    Value = false,
    Callback = function(state)
        Toggles.FpsUnlocker = state
        setfpscap(state and 9999999 or 60)
    end
})

Toggles.AntiAfk = false
SettingsSection:Toggle({
    Title = "禁用AFK",
    Value = false,
    Callback = function(state)
        Toggles.AntiAfk = state
        if state then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end
})

SettingsSection:Toggle({
    Title = "提示音效",
    Value = true,
    Callback = function(state) Toggles.NotifySound = state end
})

SettingsSection:Dropdown({
    Title = "通知样式",
    Values = {"Linoria", "Doors", "WindUI"},
    Value = "WindUI",
    Callback = function(value) Options.NotifyStyle = value end
})

SettingsSection:Dropdown({
    Title = "提示位置",
    Values = {"Right", "Left"},
    Value = "Right",
    Callback = function(value) Options.NotifySide = value end
})

SettingsSection:Slider({
    Title = "ESP渲染帧率",
    Value = {Min = 10, Max = 240, Default = 60},
    Callback = function(value)
        ESPLibrary:SetRenderingSpeed(value)
    end
})

SettingsSection:Slider({
    Title = "界面缩放",
    Value = {Min = 50, Max = 200, Default = 100},
    Callback = function(value)
        Window:SetDPIScale(value / 100)
    end
})

SettingsSection:Button({
    Title = "卸载脚本",
    Icon = "x",
    Callback = function()
        CleanupAll()
        Window:Destroy()
        Notify("脚本已卸载", 2)
    end
})

local updateConn = RunService.Heartbeat:Connect(function()
    UpdateESP()
    if Toggles.AutoCloset then AutoClosetLogic() end
    if Toggles.AutoInteract then AutoInteractLogic() end
    if Toggles.AutoLibrary then AutoLibraryLogic() end

    local root = GetRoot()
    if root and Options.VelocityLimiter then
        if root.AssemblyLinearVelocity.Magnitude > (Options.VelocityLimiter * 10) then
            if not velocityLimiter then SetupVelocityLimiter(root) end
            if velocityLimiter then
                velocityLimiter.Enabled = true
                velocityLimiter.VectorVelocity = Vector3.new(0, 0, 0)
            end
        else
            if velocityLimiter then
                velocityLimiter.Enabled = false
            end
        end
    end
end)
table.insert(Connections, updateConn)

local characterAddedConn = LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    local root = GetRoot()
    if root then
        SetupVelocityLimiter(root)
    end
end)
table.insert(Connections, characterAddedConn)