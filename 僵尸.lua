local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

function gradient(text, startColor, endColor)
    local result = ""
    local length = #text
    for i = 1, length do
        local t = (i - 1) / math.max(length - 1, 1)
        local r = math.floor((startColor.R + (endColor.R - startColor.R) * t) * 255)
        local g = math.floor((startColor.G + (endColor.G - startColor.G) * t) * 255)
        local b = math.floor((startColor.B + (endColor.B - startColor.B) * t) * 255)
        local char = text:sub(i, i)
        result = result .. "<font color=\"rgb(" .. r ..", " .. g .. ", " .. b .. ")\">" .. char .. "</font>"
    end
    return result
end

local Confirmed = false

WindUI:Popup({
    Title = "欢迎使用ASH-僵尸竞技场",
    Icon = "info",
    Content = "尊敬的" .. game.Players.LocalPlayer.Name .. "感谢使用ASH脚本，本脚本为公益，可以去qq1034603242前往交流和反馈脚本问题",
    Buttons = {
        { Title = "取消", Callback = function() end, Variant = "Secondary", },
        { Title = "继续", Icon = "arrow-right", Callback = function() Confirmed = true end, Variant = "Primary", }
    }
})

repeat wait() until Confirmed

local Window = WindUI:CreateWindow({
    Title = "僵尸竞技场",
    Icon = "door-open",
    Author = "僵尸竞技场",
    Folder = "CloudHub",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    Background = "https://raw.githubusercontent.com/NUIke1/ui/refs/heads/main/Image_1778420704678_515.jpg",
    User = { Enabled = true, Callback = function() print("已点击") end, Anonymous = true },
    SideBarWidth = 200,
    HasOutline = true,
    KeySystem = { Key = { "1234", "5678" }, Note = "示例密钥系统。\n\n密钥是 '1234' 或 '5678'", URL = "https://github.com/Footagesus/WindUI", SaveKey = true, },
})

Window:EditOpenButton({
    Title = "启动ASH脚本",
    Icon = "monitor",
    CornerRadius = UDim.new(0,16),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromHex("FF0F7B"), Color3.fromHex("F89B29")),
    Draggable = true,
})

local Tabs = {}
Tabs.MainTab = Window:Tab({ Title = "主页", Icon = "home" })
Tabs.SettingsTab = Window:Tab({ Title = "设置", Icon = "settings" })
Tabs.ESPTab = Window:Tab({ Title = "透视", Icon = "eye" })

local function setWalkSpeed(value)
    local player = game.Players.LocalPlayer
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = value
        WindUI:Notify({ Title = "速度已修改", Content = "当前速度: " .. value, Duration = 1 })
    end
end

Tabs.MainTab:Input({
    Title = "输入速度数值",
    Placeholder = "请输入速度数值",
    Callback = function(input)
        local speed = tonumber(input)
        if speed then
            setWalkSpeed(speed)
        else
            WindUI:Notify({ Title = "提示:错误", Content = "请输入有效的数字", Duration = 1 })
        end
    end
})

local GunsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Animations"):WaitForChild("Guns")
local GunNames = {}
for _, child in ipairs(GunsFolder:GetChildren()) do
    table.insert(GunNames, child.Name)
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GunRemotes = ReplicatedStorage:WaitForChild("GunRemotes")
local GunFire = GunRemotes:WaitForChild("GunFire")
local GunHit = GunRemotes:WaitForChild("GunHit")
local ZombiesFolder = workspace:WaitForChild("Zombies_Local")
local RANGE = 500

local killAuraRunning = false
local killAuraConnection = nil

local function getCurrentGun()
    local character = LocalPlayer.Character
    if not character then return nil end
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Tool") and child:FindFirstChild("BarrelPoint") then
            return child
        end
    end
    return nil
end

local function getCurrentGunName()
    local gun = getCurrentGun()
    if gun then
        return gun.Name
    end
    return nil
end

local function getGunPosition(gun)
    local barrelPoint = gun:FindFirstChild("BarrelPoint")
    if barrelPoint then
        if barrelPoint:IsA("Attachment") then
            return barrelPoint.WorldPosition
        elseif barrelPoint:IsA("BasePart") then
            return barrelPoint.Position
        end
    end
    return nil
end

local function getZombieNumber(zombie)
    local name = zombie.Name
    local number = tonumber(name:match("_(%d+)"))
    return number or 4
end

local function getAllZombies()
    local zombies = {}
    for _, child in ipairs(ZombiesFolder:GetChildren()) do
        if child:IsA("Model") and child:FindFirstChild("Head") then
            table.insert(zombies, child)
        end
    end
    return zombies
end

local function isInRange(gunPos, headPos)
    local distance = (headPos - gunPos).Magnitude
    return distance <= RANGE
end

local function killAuraLoop()
    while killAuraRunning do
        local gun = getCurrentGun()
        if gun then
            local currentGunName = getCurrentGunName()
            if currentGunName and table.find(GunNames, currentGunName) then
                local gunPos = getGunPosition(gun)
                if gunPos then
                    local zombies = getAllZombies()
                    for _, targetZombie in ipairs(zombies) do
                        local head = targetZombie:FindFirstChild("Head")
                        if head then
                            if isInRange(gunPos, head.Position) then
                                local zombieNumber = getZombieNumber(targetZombie)
                                local direction = (head.Position - gunPos).Unit
                                
                                local fireArgs = {
                                    currentGunName,
                                    gunPos,
                                    direction
                                }
                                GunFire:FireServer(unpack(fireArgs))
                                
                                local hitArgs = {
                                    currentGunName,
                                    zombieNumber,
                                    head.Position
                                }
                                GunHit:FireServer(unpack(hitArgs))
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.05)
    end
end

local function startKillAura()
    if killAuraRunning then return end
    killAuraRunning = true
    killAuraConnection = coroutine.wrap(killAuraLoop)()
    killAuraConnection()
end

local function stopKillAura()
    killAuraRunning = false
end

local toggleState = false
local featureToggle = Tabs.MainTab:Toggle({
    Title = "杀戮光环",
    Value = false,
    Callback = function(state) 
        toggleState = state
        WindUI:Notify({
            Title = "功能",
            Content = state and "杀戮光环已启用" or "杀戮光环已禁用",
            Icon = state and "check" or "x",
            Duration = 2
        })
        if state then
            startKillAura()
        else
            stopKillAura()
        end
    end
})

local espLines = {}
local espEnabled = false

local function createBox(zombie)
    local head = zombie:FindFirstChild("Head")
    local hrp = zombie:FindFirstChild("HumanoidRootPart")
    if not head or not hrp then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Parent = zombie
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    
    local billboard = Instance.new("BillboardGui")
    billboard.Parent = head
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 100, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = billboard
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextStrokeTransparency = 0.3
    textLabel.Text = zombie.Name
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 14
    
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Parent = billboard
    distanceLabel.Size = UDim2.new(1, 0, 0, 20)
    distanceLabel.Position = UDim2.new(0, 0, 1, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    distanceLabel.Text = ""
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.TextSize = 12
    
    espLines[zombie] = {highlight = highlight, billboard = billboard, distanceLabel = distanceLabel}
end

local function updateDistance()
    if not espEnabled then return end
    local character = LocalPlayer.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    for zombie, objects in pairs(espLines) do
        if zombie and zombie.Parent then
            local head = zombie:FindFirstChild("Head")
            if head and objects.distanceLabel then
                local distance = (head.Position - root.Position).Magnitude
                objects.distanceLabel.Text = math.floor(distance) .. " 米"
            end
        else
            if objects.highlight then objects.highlight:Destroy() end
            if objects.billboard then objects.billboard:Destroy() end
            espLines[zombie] = nil
        end
    end
end

local function startESP()
    espEnabled = true
    for _, zombie in ipairs(getAllZombies()) do
        if not espLines[zombie] then
            createBox(zombie)
        end
    end
    
    if not espConnection then
        espConnection = game:GetService("RunService").RenderStepped:Connect(updateDistance)
    end
    
    ZombiesFolder.ChildAdded:Connect(function(child)
        if espEnabled and child:IsA("Model") and child:FindFirstChild("Head") then
            createBox(child)
        end
    end)
end

local function stopESP()
    espEnabled = false
    for zombie, objects in pairs(espLines) do
        if objects.highlight then objects.highlight:Destroy() end
        if objects.billboard then objects.billboard:Destroy() end
    end
    espLines = {}
    if espConnection then
        espConnection:Disconnect()
        espConnection = nil
    end
end

local espToggle = Tabs.ESPTab:Toggle({
    Title = "僵尸透视",
    Value = false,
    Callback = function(state)
        if state then
            startESP()
        else
            stopESP()
        end
    end
})