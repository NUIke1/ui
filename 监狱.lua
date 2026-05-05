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
    Title = "欢迎！弹窗示例",
    Icon = "info",
    Content = "这是为 " .. gradient("WindUI", Color3.fromHex("#00FF87"), Color3.fromHex("#60EFFF")) .. " 库准备的示例UI",
    Buttons = {
        {
            Title = "取消",
            Callback = function() end,
            Variant = "Secondary",
        },
        {
            Title = "继续",
            Icon = "arrow-right",
            Callback = function() Confirmed = true end,
            Variant = "Primary",
        }
    }
})

repeat wait() until Confirmed

local Window = WindUI:CreateWindow({
    Title = "监狱人生",
    Icon = "door-open",
    Author = "监狱人生",
    Folder = "CloudHub",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    User = {
        Enabled = true,
        Callback = function() print("已点击") end,
        Anonymous = true
    },
    SideBarWidth = 200,
    HasOutline = true,
    KeySystem = {
        Key = { "1234", "5678" },
        Note = "示例密钥系统。\n\n密钥是 '1234' 或 '5678'",
        URL = "https://github.com/Footagesus/WindUI",
        SaveKey = true,
    },
})

Window:EditOpenButton({
    Title = "打开监狱人生",
    Icon = "monitor",
    CornerRadius = UDim.new(0,16),
    StrokeThickness = 2,
    Color = ColorSequence.new(
        Color3.fromHex("FF0F7B"),
        Color3.fromHex("F89B29")
    ),
    Draggable = true,
})

local createdTabs = {}

local Tabs = {}

Tabs.MainTab = Window:Tab({ Title = "主页", Icon = "home" })

Tabs.SettingsTab = Window:Tab({ Title = "设置", Icon = "settings" })

local killAuraEnabled = false
local auraRange = 100
local killAuraCoroutine = nil
local currentKillAuraTab = nil
local teleportKillEnabled = false
local killTargetTeam = "Guards"

local mp5KillEnabled = false
local mp5AuraRange = 100
local mp5Coroutine = nil
local mp5TeleportEnabled = false
local mp5TargetTeam = "Guards"

local taserKillEnabled = false
local taserAuraRange = 100
local taserCoroutine = nil
local taserTeleportEnabled = false
local taserTargetTeam = "All"

local m9KillEnabled = false
local m9AuraRange = 100
local m9Coroutine = nil
local m9TeleportEnabled = false
local m9TargetTeam = "Guards"

local globalEspEnabled = false

local function setAmmo(gunName, amount)
    local player = game.Players.LocalPlayer
    local char = player.Character
    if not char then return false end
    local gun = char:FindFirstChild(gunName)
    if gun then
        local currentAmmo = gun:FindFirstChild("Local_CurrentAmmo")
        local maxAmmo = gun:FindFirstChild("MaxAmmo")
        if currentAmmo then
            currentAmmo.Value = amount
        end
        if maxAmmo then
            maxAmmo.Value = amount
        end
        return true
    end
    return false
end

local function startKillAuraLogic()
    local player = game.Players.LocalPlayer
    local rs = game:GetService("ReplicatedStorage")
    local event = rs:WaitForChild("GunRemotes"):WaitForChild("ShootEvent")
    local reloadEvent = rs:WaitForChild("GunRemotes"):WaitForChild("FuncReload")
    
    local lastReload = 0
    local reloading = false
    
    while killAuraEnabled and task.wait(0.05) do
        local char = player.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local gun = char:FindFirstChild("AK-47")
        if not hrp or not gun then continue end
        local muzzle = gun:FindFirstChild("Muzzle")
        if not muzzle then continue end
        local wz = muzzle.AssemblyCenterOfMass
        
        reloading = false
        if tick() - lastReload >= 5 then
            reloadEvent:InvokeServer()
            lastReload = tick()
            reloading = true
            WindUI:Notify({
                Title = "换弹",
                Content = "AK47正在换弹",
                Duration = 1,
            })
        end
        
        if reloading then continue end
        
        local closestTarget = nil
        local closestDist = math.huge
        local targetRoot = nil
        
        for _, target in ipairs(game.Players:GetPlayers()) do
            if target == player then continue end
            local tchar = target.Character
            if not tchar then continue end
            local humanoid = tchar:FindFirstChildOfClass("Humanoid")
            local head = tchar:FindFirstChild("Head")
            local thrp = tchar:FindFirstChild("HumanoidRootPart")
            if not humanoid or not head or not thrp then continue end
            if humanoid.Health <= 0 then continue end
            if killTargetTeam == "Guards" and target.Team and target.Team.Name == "Guards" then
                local dist = (hrp.Position - head.Position).Magnitude
                if dist <= auraRange and dist < closestDist then
                    closestDist = dist
                    closestTarget = head
                    targetRoot = thrp
                end
            elseif killTargetTeam == "Criminals" and target.Team and target.Team.Name == "Criminals" then
                local dist = (hrp.Position - head.Position).Magnitude
                if dist <= auraRange and dist < closestDist then
                    closestDist = dist
                    closestTarget = head
                    targetRoot = thrp
                end
            elseif killTargetTeam == "Inmates" and target.Team and target.Team.Name == "Inmates" then
                local dist = (hrp.Position - head.Position).Magnitude
                if dist <= auraRange and dist < closestDist then
                    closestDist = dist
                    closestTarget = head
                    targetRoot = thrp
                end
            elseif killTargetTeam == "All" then
                local dist = (hrp.Position - head.Position).Magnitude
                if dist <= auraRange and dist < closestDist then
                    closestDist = dist
                    closestTarget = head
                    targetRoot = thrp
                end
            end
        end
        
        if closestTarget and targetRoot then
            if teleportKillEnabled then
                hrp.CFrame = targetRoot.CFrame * CFrame.new(0,0,-3)
            end
            local args = {{ { wz, hrp.Position, closestTarget } }}
            event:FireServer(unpack(args))
        end
    end
end

local function startMp5AuraLogic()
    local player = game.Players.LocalPlayer
    local rs = game:GetService("ReplicatedStorage")
    local event = rs:WaitForChild("GunRemotes"):WaitForChild("ShootEvent")
    local reloadEvent = rs:WaitForChild("GunRemotes"):WaitForChild("FuncReload")
    
    local lastReload = 0
    local reloading = false
    
    while mp5KillEnabled and task.wait(0.05) do
        local char = player.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local gun = char:FindFirstChild("MP5")
        if not hrp or not gun then continue end
        local muzzle = gun:FindFirstChild("Muzzle")
        if not muzzle then continue end
        local wz = muzzle.AssemblyCenterOfMass
        
        reloading = false
        if tick() - lastReload >= 5 then
            reloadEvent:InvokeServer()
            lastReload = tick()
            reloading = true
            WindUI:Notify({
                Title = "换弹",
                Content = "MP5正在换弹",
                Duration = 1,
            })
        end
        
        if reloading then continue end
        
        local closestTarget = nil
        local closestDist = math.huge
        local targetRoot = nil
        
        for _, target in ipairs(game.Players:GetPlayers()) do
            if target == player then continue end
            local tchar = target.Character
            if not tchar then continue end
            local humanoid = tchar:FindFirstChildOfClass("Humanoid")
            local head = tchar:FindFirstChild("Head")
            local thrp = tchar:FindFirstChild("HumanoidRootPart")
            if not humanoid or not head or not thrp then continue end
            if humanoid.Health <= 0 then continue end
            if mp5TargetTeam == "Guards" and target.Team and target.Team.Name == "Guards" then
                local dist = (hrp.Position - head.Position).Magnitude
                if dist <= mp5AuraRange and dist < closestDist then
                    closestDist = dist
                    closestTarget = head
                    targetRoot = thrp
                end
            elseif mp5TargetTeam == "Criminals" and target.Team and target.Team.Name == "Criminals" then
                local dist = (hrp.Position - head.Position).Magnitude
                if dist <= mp5AuraRange and dist < closestDist then
                    closestDist = dist
                    closestTarget = head
                    targetRoot = thrp
                end
            elseif mp5TargetTeam == "Inmates" and target.Team and target.Team.Name == "Inmates" then
                local dist = (hrp.Position - head.Position).Magnitude
                if dist <= mp5AuraRange and dist < closestDist then
                    closestDist = dist
                    closestTarget = head
                    targetRoot = thrp
                end
            elseif mp5TargetTeam == "All" then
                local dist = (hrp.Position - head.Position).Magnitude
                if dist <= mp5AuraRange and dist < closestDist then
                    closestDist = dist
                    closestTarget = head
                    targetRoot = thrp
                end
            end
        end
        
        if closestTarget and targetRoot then
            if mp5TeleportEnabled then
                hrp.CFrame = targetRoot.CFrame * CFrame.new(0,0,-3)
            end
            local args = {{ { wz, hrp.Position, closestTarget } }}
            event:FireServer(unpack(args))
        end
    end
end

local function startTaserAuraLogic()
    local player = game.Players.LocalPlayer
    local rs = game:GetService("ReplicatedStorage")
    local event = rs:WaitForChild("GunRemotes"):WaitForChild("ShootEvent")
    local reloadEvent = rs:WaitForChild("GunRemotes"):WaitForChild("FuncReload")
    
    local lastReload = 0
    local reloading = false
    
    while taserKillEnabled and task.wait(0.05) do
        local char = player.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local gun = char:FindFirstChild("Taser")
        if not hrp or not gun then continue end
        local muzzle = gun:FindFirstChild("Muzzle")
        if not muzzle then continue end
        local wz = muzzle.AssemblyCenterOfMass
        
        reloading = false
        if tick() - lastReload >= 5 then
            reloadEvent:InvokeServer()
            lastReload = tick()
            reloading = true
            WindUI:Notify({
                Title = "换弹",
                Content = "Taser正在换弹",
                Duration = 1,
            })
        end
        
        if reloading then continue end
        
        local closestTarget = nil
        local closestDist = math.huge
        local targetRoot = nil
        
        for _, target in ipairs(game.Players:GetPlayers()) do
            if target == player then continue end
            local tchar = target.Character
            if not tchar then continue end
            local humanoid = tchar:FindFirstChildOfClass("Humanoid")
            local head = tchar:FindFirstChild("Head")
            local thrp = tchar:FindFirstChild("HumanoidRootPart")
            if not humanoid or not head or not thrp then continue end
            if humanoid.Health <= 0 then continue end
            if taserTargetTeam == "Criminals" and target.Team and target.Team.Name == "Criminals" then
                local dist = (hrp.Position - head.Position).Magnitude
                if dist <= taserAuraRange and dist < closestDist then
                    closestDist = dist
                    closestTarget = head
                    targetRoot = thrp
                end
            elseif taserTargetTeam == "Inmates" and target.Team and target.Team.Name == "Inmates" then
                local dist = (hrp.Position - head.Position).Magnitude
                if dist <= taserAuraRange and dist < closestDist then
                    closestDist = dist
                    closestTarget = head
                    targetRoot = thrp
                end
            elseif taserTargetTeam == "All" then
                if target.Team and (target.Team.Name == "Criminals" or target.Team.Name == "Inmates") then
                    local dist = (hrp.Position - head.Position).Magnitude
                    if dist <= taserAuraRange and dist < closestDist then
                        closestDist = dist
                        closestTarget = head
                        targetRoot = thrp
                    end
                end
            end
        end
        
        if closestTarget and targetRoot then
            if taserTeleportEnabled then
                hrp.CFrame = targetRoot.CFrame * CFrame.new(0,0,-3)
            end
            local args = {{ { wz, hrp.Position, closestTarget } }}
            event:FireServer(unpack(args))
        end
    end
end

local function startM9AuraLogic()
    local player = game.Players.LocalPlayer
    local rs = game:GetService("ReplicatedStorage")
    local event = rs:WaitForChild("GunRemotes"):WaitForChild("ShootEvent")
    local reloadEvent = rs:WaitForChild("GunRemotes"):WaitForChild("FuncReload")
    
    local lastReload = 0
    local reloading = false
    
    while m9KillEnabled and task.wait(0.05) do
        local char = player.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local gun = char:FindFirstChild("M9")
        if not hrp or not gun then continue end
        local muzzle = gun:FindFirstChild("Muzzle")
        if not muzzle then continue end
        local wz = muzzle.AssemblyCenterOfMass
        
        reloading = false
        if tick() - lastReload >= 5 then
            reloadEvent:InvokeServer()
            lastReload = tick()
            reloading = true
            WindUI:Notify({
                Title = "换弹",
                Content = "M9正在换弹",
                Duration = 1,
            })
        end
        
        if reloading then continue end
        
        local closestTarget = nil
        local closestDist = math.huge
        local targetRoot = nil
        
        for _, target in ipairs(game.Players:GetPlayers()) do
            if target == player then continue end
            local tchar = target.Character
            if not tchar then continue end
            local humanoid = tchar:FindFirstChildOfClass("Humanoid")
            local head = tchar:FindFirstChild("Head")
            local thrp = tchar:FindFirstChild("HumanoidRootPart")
            if not humanoid or not head or not thrp then continue end
            if humanoid.Health <= 0 then continue end
            if m9TargetTeam == "Guards" and target.Team and target.Team.Name == "Guards" then
                local dist = (hrp.Position - head.Position).Magnitude
                if dist <= m9AuraRange and dist < closestDist then
                    closestDist = dist
                    closestTarget = head
                    targetRoot = thrp
                end
            elseif m9TargetTeam == "Criminals" and target.Team and target.Team.Name == "Criminals" then
                local dist = (hrp.Position - head.Position).Magnitude
                if dist <= m9AuraRange and dist < closestDist then
                    closestDist = dist
                    closestTarget = head
                    targetRoot = thrp
                end
            elseif m9TargetTeam == "Inmates" and target.Team and target.Team.Name == "Inmates" then
                local dist = (hrp.Position - head.Position).Magnitude
                if dist <= m9AuraRange and dist < closestDist then
                    closestDist = dist
                    closestTarget = head
                    targetRoot = thrp
                end
            elseif m9TargetTeam == "All" then
                local dist = (hrp.Position - head.Position).Magnitude
                if dist <= m9AuraRange and dist < closestDist then
                    closestDist = dist
                    closestTarget = head
                    targetRoot = thrp
                end
            end
        end
        
        if closestTarget and targetRoot then
            if m9TeleportEnabled then
                hrp.CFrame = targetRoot.CFrame * CFrame.new(0,0,-3)
            end
            local args = {{ { wz, hrp.Position, closestTarget } }}
            event:FireServer(unpack(args))
        end
    end
end

local espEnabled = false
local espConnections = {}
local espObjects = {}

local function createESP(player)
    if not espEnabled then return end
    if player == game.Players.LocalPlayer then return end
    if espObjects[player] then return end
    
    local function addESPToChar(char)
        if not char or not char.Parent then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local teamName = player.Team and player.Team.Name or ""
        local outlineColor, textColor, suffix
        
        if teamName == "Guards" then
            outlineColor = Color3.fromRGB(0, 0, 255)
            textColor = Color3.fromRGB(0, 0, 255)
            suffix = "警察"
        elseif teamName == "Criminals" then
            outlineColor = Color3.fromRGB(255, 0, 0)
            textColor = Color3.fromRGB(255, 0, 0)
            suffix = "逃出监狱者"
        elseif teamName == "Inmates" then
            outlineColor = Color3.fromRGB(255, 173, 48)
            textColor = Color3.fromRGB(255, 173, 48)
            suffix = "犯罪者"
        else
            return
        end
        
        local highlight = Instance.new("Highlight")
        highlight.FillColor = player.TeamColor.Color
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = outlineColor
        highlight.OutlineTransparency = 0.2
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Adornee = char
        highlight.Parent = char
        
        local tag = Instance.new("BillboardGui")
        tag.Size = UDim2.new(0, 150, 0, 30)
        tag.StudsOffset = Vector3.new(0, 2.5, 0)
        tag.AlwaysOnTop = true
        tag.Parent = hrp
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = player.Name .. " [" .. suffix .. "]"
        label.TextColor3 = textColor
        label.TextStrokeTransparency = 0.3
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Parent = tag
        
        espObjects[player] = {highlight = highlight, tag = tag}
    end
    
    if player.Character then
        addESPToChar(player.Character)
    end
    
    local charAddedConn = player.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        addESPToChar(char)
    end)
    
    espConnections[player] = charAddedConn
end

local function removeESP(player)
    if espObjects[player] then
        if espObjects[player].highlight then espObjects[player].highlight:Destroy() end
        if espObjects[player].tag then espObjects[player].tag:Destroy() end
        espObjects[player] = nil
    end
    if espConnections[player] then
        espConnections[player]:Disconnect()
        espConnections[player] = nil
    end
end

local function toggleESP(state)
    espEnabled = state
    globalEspEnabled = state
    if state then
        for _, player in ipairs(game.Players:GetPlayers()) do
            createESP(player)
        end
        WindUI:Notify({
            Title = "透视已开启",
            Content = "玩家透视已启用",
            Duration = 2,
        })
    else
        for player, _ in pairs(espObjects) do
            removeESP(player)
        end
        WindUI:Notify({
            Title = "透视已关闭",
            Content = "玩家透视已禁用",
            Duration = 2,
        })
    end
end

game.Players.PlayerAdded:Connect(function(player)
    if espEnabled then
        createESP(player)
    end
end)

game.Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

local function setWalkSpeed(value)
    local player = game.Players.LocalPlayer
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = value
        WindUI:Notify({
            Title = "速度已修改",
            Content = "当前速度: " .. value,
            Duration = 1,
        })
    end
end

local function deleteDoors()
    local doors = workspace:FindFirstChild("Doors")
    if doors then
        doors:Destroy()
        WindUI:Notify({
            Title = "删除成功",
            Content = "门已删除",
            Duration = 2,
        })
    else
        WindUI:Notify({
            Title = "删除失败",
            Content = "未找到门",
            Duration = 2,
        })
    end
end

local function checkTeamAndDisable()
    local player = game.Players.LocalPlayer
    local team = player.Team
    if not team then return end
    local teamName = team.Name
    
    if teamName == "Guards" then
        if createdTabs["犯罪者"] and Tabs.CriminalTab then
            Tabs.CriminalTab:Destroy()
            Tabs.CriminalTab = nil
            createdTabs["犯罪者"] = nil
        end
        if createdTabs["逃出监狱者"] and Tabs.EscapeTab then
            stopKillAura()
            stopMp5Aura()
            stopM9Aura()
            Tabs.EscapeTab:Destroy()
            Tabs.EscapeTab = nil
            createdTabs["逃出监狱者"] = nil
            currentKillAuraTab = nil
        end
        WindUI:Notify({
            Title = "团队检测",
            Content = "当前团队: 警察",
            Duration = 2,
        })
    elseif teamName == "Criminals" then
        if createdTabs["警察"] and Tabs.PoliceTab then
            stopTaserAura()
            Tabs.PoliceTab:Destroy()
            Tabs.PoliceTab = nil
            createdTabs["警察"] = nil
        end
        WindUI:Notify({
            Title = "团队检测",
            Content = "当前团队: 逃出监狱者",
            Duration = 2,
        })
    elseif teamName == "Inmates" then
        if createdTabs["警察"] and Tabs.PoliceTab then
            stopTaserAura()
            Tabs.PoliceTab:Destroy()
            Tabs.PoliceTab = nil
            createdTabs["警察"] = nil
        end
        WindUI:Notify({
            Title = "团队检测",
            Content = "当前团队: 犯罪者",
            Duration = 2,
        })
    end
end

game.Players.LocalPlayer:GetPropertyChangedSignal("Team"):Connect(checkTeamAndDisable)
task.wait(1)
checkTeamAndDisable()

Tabs.SettingsTab:Slider({
    Title = "修改速度",
    Value = {
        Min = 24,
        Max = 200,
        Default = 24,
    },
    Callback = function(value)
        setWalkSpeed(value)
    end
})

Tabs.MainTab:Button({
    Title = "删除门",
    Desc = "删除门",
    Callback = function()
        deleteDoors()
    end,
})

Tabs.MainTab:Button({
    Title = "选择阵营",
    Callback = function()
        Window:Dialog({
            Title = "选择模式",
            Content = "选择你当前的阵营",
            Icon = "bird",
            Buttons = {
                {
                    Title = "犯罪者",
                    Icon = "bird",
                    Variant = "Tertiary",
                    Callback = function()
                        if not createdTabs["犯罪者"] then
                            Tabs.CriminalTab = Window:Tab({ Title = "犯罪者", Icon = "skull" })
                            Tabs.CriminalTab:Paragraph({
                                Title = "犯罪者阵营",
                                Desc = "你选择了犯罪者阵营",
                                Color = "Orange",
                            })
                            
                            local espToggle = Tabs.CriminalTab:Toggle({
                                Title = "玩家透视",
                                Value = globalEspEnabled,
                                Callback = function(state)
                                    toggleESP(state)
                                end,
                            })
                            
                            Tabs.CriminalTab:Input({
                                Title = "无限弹药数值",
                                Placeholder = "输入弹药数量",
                                Callback = function(input)
                                    local num = tonumber(input)
                                    if num then
                                        setAmmo("AK-47", num)
                                        setAmmo("MP5", num)
                                        setAmmo("M9", num)
                                        setAmmo("Taser", num)
                                        WindUI:Notify({
                                            Title = "弹药已修改",
                                            Content = "弹药已设置为: " .. num,
                                            Duration = 2,
                                        })
                                    end
                                end,
                            })
                            
                            local killToggle = Tabs.CriminalTab:Toggle({
                                Title = "AK47杀戮光环",
                                Value = false,
                                Callback = function(state)
                                    if killAuraCoroutine and killAuraEnabled then
                                        killAuraEnabled = false
                                        task.wait(0.1)
                                    end
                                    killAuraEnabled = state
                                    if killAuraEnabled then
                                        killAuraCoroutine = coroutine.wrap(startKillAuraLogic)
                                        killAuraCoroutine()
                                        WindUI:Notify({
                                            Title = "AK47杀戮光环已开启",
                                            Content = "范围: " .. auraRange,
                                            Duration = 2,
                                        })
                                    else
                                        WindUI:Notify({
                                            Title = "AK47杀戮光环已关闭",
                                            Duration = 2,
                                        })
                                    end
                                end,
                            })
                            
                            local teleportToggle = Tabs.CriminalTab:Toggle({
                                Title = "AK47传送杀戮光环",
                                Value = false,
                                Callback = function(state)
                                    teleportKillEnabled = state
                                    if state then
                                        WindUI:Notify({
                                            Title = "AK47传送已开启",
                                            Content = "攻击时会传送到敌人身边",
                                            Duration = 2,
                                        })
                                    else
                                        WindUI:Notify({
                                            Title = "AK47传送已关闭",
                                            Duration = 2,
                                        })
                                    end
                                end,
                            })
                            
                            local rangeSlider = Tabs.CriminalTab:Slider({
                                Title = "AK47攻击范围",
                                Value = {
                                    Min = 10,
                                    Max = 1000,
                                    Default = 100,
                                },
                                Callback = function(value)
                                    auraRange = value
                                end,
                            })
                            
                            local mp5Toggle = Tabs.CriminalTab:Toggle({
                                Title = "MP5杀戮光环",
                                Value = false,
                                Callback = function(state)
                                    if mp5Coroutine and mp5KillEnabled then
                                        mp5KillEnabled = false
                                        task.wait(0.1)
                                    end
                                    mp5KillEnabled = state
                                    if mp5KillEnabled then
                                        mp5Coroutine = coroutine.wrap(startMp5AuraLogic)
                                        mp5Coroutine()
                                        WindUI:Notify({
                                            Title = "MP5杀戮光环已开启",
                                            Content = "范围: " .. mp5AuraRange,
                                            Duration = 2,
                                        })
                                    else
                                        WindUI:Notify({
                                            Title = "MP5杀戮光环已关闭",
                                            Duration = 2,
                                        })
                                    end
                                end,
                            })
                            
                            local mp5TeleportToggle = Tabs.CriminalTab:Toggle({
                                Title = "MP5传送杀戮光环",
                                Value = false,
                                Callback = function(state)
                                    mp5TeleportEnabled = state
                                    if state then
                                        WindUI:Notify({
                                            Title = "MP5传送已开启",
                                            Content = "攻击时会传送到敌人身边",
                                            Duration = 2,
                                        })
                                    else
                                        WindUI:Notify({
                                            Title = "MP5传送已关闭",
                                            Duration = 2,
                                        })
                                    end
                                end,
                            })
                            
                            local mp5RangeSlider = Tabs.CriminalTab:Slider({
                                Title = "MP5攻击范围",
                                Value = {
                                    Min = 10,
                                    Max = 1000,
                                    Default = 100,
                                },
                                Callback = function(value)
                                    mp5AuraRange = value
                                end,
                            })
                            
                            local m9Toggle = Tabs.CriminalTab:Toggle({
                                Title = "M9杀戮光环",
                                Value = false,
                                Callback = function(state)
                                    if m9Coroutine and m9KillEnabled then
                                        m9KillEnabled = false
                                        task.wait(0.1)
                                    end
                                    m9KillEnabled = state
                                    if m9KillEnabled then
                                        m9Coroutine = coroutine.wrap(startM9AuraLogic)
                                        m9Coroutine()
                                        WindUI:Notify({
                                            Title = "M9杀戮光环已开启",
                                            Content = "范围: " .. m9AuraRange,
                                            Duration = 2,
                                        })
                                    else
                                        WindUI:Notify({
                                            Title = "M9杀戮光环已关闭",
                                            Duration = 2,
                                        })
                                    end
                                end,
                            })
                            
                            local m9TeleportToggle = Tabs.CriminalTab:Toggle({
                                Title = "M9传送杀戮光环",
                                Value = false,
                                Callback = function(state)
                                    m9TeleportEnabled = state
                                    if state then
                                        WindUI:Notify({
                                            Title = "M9传送已开启",
                                            Content = "攻击时会传送到敌人身边",
                                            Duration = 2,
                                        })
                                    else
                                        WindUI:Notify({
                                            Title = "M9传送已关闭",
                                            Duration = 2,
                                        })
                                    end
                                end,
                            })
                            
                            local m9RangeSlider = Tabs.CriminalTab:Slider({
                                Title = "M9攻击范围",
                                Value = {
                                    Min = 10,
                                    Max = 1000,
                                    Default = 100,
                                },
                                Callback = function(value)
                                    m9AuraRange = value
                                end,
                            })
                            
                            Tabs.CriminalTab:Button({
                                Title = "传送犯罪窝点",
                                Callback = function()
                                    local char = game.Players.LocalPlayer.Character
                                    if char and char:FindFirstChild("HumanoidRootPart") then
                                        char.HumanoidRootPart.CFrame = CFrame.new(-974.71, 108.32, 2055.38)
                                        WindUI:Notify({
                                            Title = "传送成功",
                                            Content = "已传送到犯罪窝点",
                                            Duration = 2,
                                        })
                                    end
                                end,
                            })
                            
                            Tabs.CriminalTab:Button({
                                Title = "传送警察室内",
                                Callback = function()
                                    local char = game.Players.LocalPlayer.Character
                                    if char and char:FindFirstChild("HumanoidRootPart") then
                                        char.HumanoidRootPart.CFrame = CFrame.new(819.14, 99.98, 2232.99)
                                        WindUI:Notify({
                                            Title = "传送成功",
                                            Content = "已传送到警察室内",
                                            Duration = 2,
                                        })
                                    end
                                end,
                            })
                            
                            Tabs.CriminalTab:Button({
                                Title = "传送监狱大门",
                                Callback = function()
                                    local char = game.Players.LocalPlayer.Character
                                    if char and char:FindFirstChild("HumanoidRootPart") then
                                        char.HumanoidRootPart.CFrame = CFrame.new(548.22, 98.19, 2241.38)
                                        WindUI:Notify({
                                            Title = "传送成功",
                                            Content = "已传送到监狱大门",
                                            Duration = 2,
                                        })
                                    end
                                end,
                            })
                            
                            Tabs.CriminalTab:Button({
                                Title = "重置所有光环",
                                Callback = function()
                                    killToggle:SetValue(false)
                                    teleportToggle:SetValue(false)
                                    rangeSlider:SetValue(100)
                                    mp5Toggle:SetValue(false)
                                    mp5TeleportToggle:SetValue(false)
                                    mp5RangeSlider:SetValue(100)
                                    m9Toggle:SetValue(false)
                                    m9TeleportToggle:SetValue(false)
                                    m9RangeSlider:SetValue(100)
                                    if killAuraEnabled then killAuraEnabled = false end
                                    teleportKillEnabled = false
                                    if mp5KillEnabled then mp5KillEnabled = false end
                                    mp5TeleportEnabled = false
                                    if m9KillEnabled then m9KillEnabled = false end
                                    m9TeleportEnabled = false
                                    WindUI:Notify({
                                        Title = "已重置",
                                        Content = "所有光环已关闭，范围已重置为100",
                                        Duration = 2,
                                    })
                                end,
                            })
                            
                            createdTabs["犯罪者"] = true
                            WindUI:Notify({
                                Title = "选项卡已创建",
                                Content = "犯罪者选项卡已添加",
                                Duration = 2,
                            })
                        else
                            WindUI:Notify({
                                Title = "提示",
                                Content = "犯罪者选项卡已存在",
                                Duration = 2,
                            })
                        end
                    end,
                },
                {
                    Title = "警察",
                    Icon = "bird",
                    Variant = "Tertiary",
                    Callback = function()
                        if not createdTabs["警察"] then
                            Tabs.PoliceTab = Window:Tab({ Title = "警察", Icon = "badge" })
                            Tabs.PoliceTab:Paragraph({
                                Title = "警察阵营",
                                Desc = "你选择了警察阵营",
                                Color = "Blue",
                            })
                            
                            local espToggle = Tabs.PoliceTab:Toggle({
                                Title = "玩家透视",
                                Value = globalEspEnabled,
                                Callback = function(state)
                                    toggleESP(state)
                                end,
                            })
                            
                            Tabs.PoliceTab:Input({
                                Title = "无限弹药数值",
                                Placeholder = "输入弹药数量",
                                Callback = function(input)
                                    local num = tonumber(input)
                                    if num then
                                        setAmmo("AK-47", num)
                                        setAmmo("MP5", num)
                                        setAmmo("M9", num)
                                        setAmmo("Taser", num)
                                        WindUI:Notify({
                                            Title = "弹药已修改",
                                            Content = "弹药已设置为: " .. num,
                                            Duration = 2,
                                        })
                                    end
                                end,
                            })
                            
                            local targetDropdown = Tabs.PoliceTab:Dropdown({
                                Title = "攻击目标",
                                Values = { "Criminals", "Inmates", "All" },
                                Value = "All",
                                Callback = function(value)
                                    killTargetTeam = value
                                    mp5TargetTeam = value
                                    m9TargetTeam = value
                                    if value == "Criminals" then
                                        taserTargetTeam = "Criminals"
                                    elseif value == "Inmates" then
                                        taserTargetTeam = "Inmates"
                                    else
                                        taserTargetTeam = "All"
                                    end
                                end,
                            })
                            
                            local akToggle = Tabs.PoliceTab:Toggle({
                                Title = "AK47杀戮光环",
                                Value = false,
                                Callback = function(state)
                                    if killAuraCoroutine and killAuraEnabled then
                                        killAuraEnabled = false
                                        task.wait(0.1)
                                    end
                                    killAuraEnabled = state
                                    if killAuraEnabled then
                                        killAuraCoroutine = coroutine.wrap(startKillAuraLogic)
                                        killAuraCoroutine()
                                        WindUI:Notify({
                                            Title = "AK47杀戮光环已开启",
                                            Content = "范围: " .. auraRange,
                                            Duration = 2,
                                        })
                                    else
                                        WindUI:Notify({
                                            Title = "AK47杀戮光环已关闭",
                                            Duration = 2,
                                        })
                                    end
                                end,
                            })
                            
                            local akTeleportToggle = Tabs.PoliceTab:Toggle({
                                Title = "AK47传送杀戮光环",
                                Value = false,
                                Callback = function(state)
                                    teleportKillEnabled = state
                                    if state then
                                        WindUI:Notify({
                                            Title = "AK47传送已开启",
                                            Content = "攻击时会传送到敌人身边",
                                            Duration = 2,
                                        })
                                    else
                                        WindUI:Notify({
                                            Title = "AK47传送已关闭",
                                            Duration = 2,
                                        })
                                    end
                                end,
                            })
                            
                            local akRangeSlider = Tabs.PoliceTab:Slider({
                                Title = "AK47攻击范围",
                                Value = {
                                    Min = 10,
                                    Max = 1000,
                                    Default = 100,
                                },
                                Callback = function(value)
                                    auraRange = value
                                end,
                            })
                            
                            local mp5Toggle = Tabs.PoliceTab:Toggle({
                                Title = "MP5杀戮光环",
                                Value = false,
                                Callback = function(state)
                                    if mp5Coroutine and mp5KillEnabled then
                                        mp5KillEnabled = false
                                        task.wait(0.1)
                                    end
                                    mp5KillEnabled = state
                                    if mp5KillEnabled then
                                        mp5Coroutine = coroutine.wrap(startMp5AuraLogic)
                                        mp5Coroutine()
                                        WindUI:Notify({
                                            Title = "MP5杀戮光环已开启",
                                            Content = "范围: " .. mp5AuraRange,
                                            Duration = 2,
                                        })
                                    else
                                        WindUI:Notify({
                                            Title = "MP5杀戮光环已关闭",
                                            Duration = 2,
                                        })
                                    end
                                end,
                            })
                            
                            local mp5TeleportToggle = Tabs.PoliceTab:Toggle({
                                Title = "MP5传送杀戮光环",
                                Value = false,
                                Callback = function(state)
                                    mp5TeleportEnabled = state
                                    if state then
                                        WindUI:Notify({
                                            Title = "MP5传送已开启",
                                            Content = "攻击时会传送到敌人身边",
                                            Duration = 2,
                                        })
                                    else
                                        WindUI:Notify({
                                            Title = "MP5传送已关闭",
                                            Duration = 2,
                                        })
                                    end
                                end,
                            })
                            
                            local mp5RangeSlider = Tabs.PoliceTab:Slider({
                                Title = "MP5攻击范围",
                                Value = {
                                    Min = 10,
                                    Max = 1000,
                                    Default = 100,
                                },
                                Callback = function(value)
                                    mp5AuraRange = value
                                end,
                            })
                            
                            local m9Toggle = Tabs.PoliceTab:Toggle({
                                Title = "M9杀戮光环",
                                Value = false,
                                Callback = function(state)
                                    if m9Coroutine and m9KillEnabled then
                                        m9KillEnabled = false
                                        task.wait(0.1)
                                    end
                                    m9KillEnabled = state
                                    if m9KillEnabled then
                                        m9Coroutine = coroutine.wrap(startM9AuraLogic)
                                        m9Coroutine()
                                        WindUI:Notify({
                                            Title = "M9杀戮光环已开启",
                                            Content = "范围: " .. m9AuraRange,
                                            Duration = 2,
                                        })
                                    else
                                        WindUI:Notify({
                                            Title = "M9杀戮光环已关闭",
                                            Duration = 2,
                                        })
                                    end
                                end,
                            })
                            
                            local m9TeleportToggle = Tabs.PoliceTab:Toggle({
                                Title = "M9传送杀戮光环",
                                Value = false,
                                Callback = function(state)
                                    m9TeleportEnabled = state
                                    if state then
                                        WindUI:Notify({
                                            Title = "M9传送已开启",
                                            Content = "攻击时会传送到敌人身边",
                                            Duration = 2,
                                        })
                                    else
                                        WindUI:Notify({
                                            Title = "M9传送已关闭",
                                            Duration = 2,
                                        })
                                    end
                                end,
                            })
                            
                            local m9RangeSlider = Tabs.PoliceTab:Slider({
                                Title = "M9攻击范围",
                                Value = {
                                    Min = 10,
                                    Max = 1000,
                                    Default = 100,
                                },
                                Callback = function(value)
                                    m9AuraRange = value
                                end,
                            })
                            
                            local taserToggle = Tabs.PoliceTab:Toggle({
                                Title = "Taser电击枪杀戮光环",
                                Value = false,
                                Callback = function(state)
                                    if taserCoroutine and taserKillEnabled then
                                        taserKillEnabled = false
                                        task.wait(0.1)
                                    end
                                    taserKillEnabled = state
                                    if taserKillEnabled then
                                        taserCoroutine = coroutine.wrap(startTaserAuraLogic)
                                        taserCoroutine()
                                        WindUI:Notify({
                                            Title = "Taser杀戮光环已开启",
                                            Content = "范围: " .. taserAuraRange,
                                            Duration = 2,
                                        })
                                    else
                                        WindUI:Notify({
                                            Title = "Taser杀戮光环已关闭",
                                            Duration = 2,
                                        })
                                    end
                                end,
                            })
                            
                            local taserTeleportToggle = Tabs.PoliceTab:Toggle({
                                Title = "Taser传送杀戮光环",
                                Value = false,
                                Callback = function(state)
                                    taserTeleportEnabled = state
                                    if state then
                                        WindUI:Notify({
                                            Title = "Taser传送已开启",
                                            Content = "攻击时会传送到敌人身边",
                                            Duration = 2,
                                        })
                                    else
                                        WindUI:Notify({
                                            Title = "Taser传送已关闭",
                                            Duration = 2,
                                        })
                                    end
                                end,
                            })
                            
                            local taserRangeSlider = Tabs.PoliceTab:Slider({
                                Title = "Taser攻击范围",
                                Value = {
                                    Min = 10,
                                    Max = 1000,
                                    Default = 100,
                                },
                                Callback = function(value)
                                    taserAuraRange = value
                                end,
                            })
                            
                            Tabs.PoliceTab:Button({
                                Title = "传送犯罪窝点",
                                Callback = function()
                                    local char = game.Players.LocalPlayer.Character
                                    if char and char:FindFirstChild("HumanoidRootPart") then
                                        char.HumanoidRootPart.CFrame = CFrame.new(-974.71, 108.32, 2055.38)
                                        WindUI:Notify({
                                            Title = "传送成功",
                                            Content = "已传送到犯罪窝点",
                                            Duration = 2,
                                        })
                                    end
                                end,
                            })
                            
                            Tabs.PoliceTab:Button({
                                Title = "传送警察室内",
                                Callback = function()
                                    local char = game.Players.LocalPlayer.Character
                                    if char and char:FindFirstChild("HumanoidRootPart") then
                                        char.HumanoidRootPart.CFrame = CFrame.new(819.14, 99.98, 2232.99)
                                        WindUI:Notify({
                                            Title = "传送成功",
                                            Content = "已传送到警察室内",
                                            Duration = 2,
                                        })
                                    end
                                end,
                            })
                            
                            Tabs.PoliceTab:Button({
                                Title = "传送监狱大门",
                                Callback = function()
                                    local char = game.Players.LocalPlayer.Character
                                    if char and char:FindFirstChild("HumanoidRootPart") then
                                        char.HumanoidRootPart.CFrame = CFrame.new(548.22, 98.19, 2241.38)
                                        WindUI:Notify({
                                            Title = "传送成功",
                                            Content = "已传送到监狱大门",
                                            Duration = 2,
                                        })
                                    end
                                end,
                            })
                            
                            Tabs.PoliceTab:Button({
                                Title = "重置所有光环",
                                Callback = function()
                                    akToggle:SetValue(false)
                                    akTeleportToggle:SetValue(false)
                                    akRangeSlider:SetValue(100)
                                    mp5Toggle:SetValue(false)
                                    mp5TeleportToggle:SetValue(false)
                                    mp5RangeSlider:SetValue(100)
                                    m9Toggle:SetValue(false)
                                    m9TeleportToggle:SetValue(false)
                                    m9RangeSlider:SetValue(100)
                                    taserToggle:SetValue(false)
                                    taserTeleportToggle:SetValue(false)
                                    taserRangeSlider:SetValue(100)
                                    if killAuraEnabled then killAuraEnabled = false end
                                    teleportKillEnabled = false
                                    if mp5KillEnabled then mp5KillEnabled = false end
                                    mp5TeleportEnabled = false
                                    if m9KillEnabled then m9KillEnabled = false end
                                    m9TeleportEnabled = false
                                    if taserKillEnabled then taserKillEnabled = false end
                                    taserTeleportEnabled = false
                                    WindUI:Notify({
                                        Title = "已重置",
                                        Content = "所有光环已关闭，范围已重置为100",
                                        Duration = 2,
                                    })
                                end,
                            })
                            
                            createdTabs["警察"] = true
                            WindUI:Notify({
                                Title = "选项卡已创建",
                                Content = "警察选项卡已添加",
                                Duration = 2,
                            })
                        else
                            WindUI:Notify({
                                Title = "提示",
                                Content = "警察选项卡已存在",
                                Duration = 2,
                            })
                        end
                    end,
                },
                {
                    Title = "逃出监狱者",
                    Icon = "bird",
                    Variant = "Secondary",
                    Callback = function()
                        if not createdTabs["逃出监狱者"] then
                            if currentKillAuraTab and Tabs[currentKillAuraTab] then
                                Tabs[currentKillAuraTab]:Destroy()
                            end
                            stopKillAura()
                            stopMp5Aura()
                            stopM9Aura()
                            
                            Tabs.EscapeTab = Window:Tab({ Title = "逃出监狱者", Icon = "door-open" })
                            currentKillAuraTab = "EscapeTab"
                            
                            Tabs.EscapeTab:Paragraph({
                                Title = "逃出监狱者阵营",
                                Desc = "你选择了逃出监狱者阵营",
                                Color = "Red",
                            })
                            
                            local espToggle = Tabs.EscapeTab:Toggle({
                                Title = "玩家透视",
                                Value = globalEspEnabled,
                                Callback = function(state)
                                    toggleESP(state)
                                end,
                            })
                            
                            Tabs.EscapeTab:Input({
                                Title = "无限弹药数值",
                                Placeholder = "输入弹药数量",
                                Callback = function(input)
                                    local num = tonumber(input)
                                    if num then
                                        setAmmo("AK-47", num)
                                        setAmmo("MP5", num)
                                        setAmmo("M9", num)
                                        setAmmo("Taser", num)
                                        WindUI:Notify({
                                            Title = "弹药已修改",
                                            Content = "弹药已设置为: " .. num,
                                            Duration = 2,
                                        })
                                    end
                                end,
                            })
                            
                            local killToggle = Tabs.EscapeTab:Toggle({
                                Title = "AK47杀戮光环",
                                Value = false,
                                Callback = function(state)
                                    if killAuraCoroutine and killAuraEnabled then
                                        killAuraEnabled = false
                                        task.wait(0.1)
                                    end
                                    killAuraEnabled = state
                                    if killAuraEnabled then
                                        killAuraCoroutine = coroutine.wrap(startKillAuraLogic)
                                        killAuraCoroutine()
                                        WindUI:Notify({
                                            Title = "AK47杀戮光环已开启",
                                            Content = "范围: " .. auraRange,
                                            Duration = 2,
                                        })
                                    else
                                        WindUI:Notify({
                                            Title = "AK47杀戮光环已关闭",
                                            Duration = 2,
                                        })
                                    end
                                end,
                            })
                            
                            local teleportToggle = Tabs.EscapeTab:Toggle({
                                Title = "AK47传送杀戮光环",
                                Value = false,
                                Callback = function(state)
                                    teleportKillEnabled = state
                                    if state then
                                        WindUI:Notify({
                                            Title = "AK47传送已开启",
                                            Content = "攻击时会传送到敌人身边",
                                            Duration = 2,
                                        })
                                    else
                                        WindUI:Notify({
                                            Title = "AK47传送已关闭",
                                            Duration = 2,
                                        })
                                    end
                                end,
                            })
                            
                            local rangeSlider = Tabs.EscapeTab:Slider({
                                Title = "AK47攻击范围",
                                Value = {
                                    Min = 10,
                                    Max = 1000,
                                    Default = 100,
                                },
                                Callback = function(value)
                                    auraRange = value
                                end,
                            })
                            
                            local mp5Toggle = Tabs.EscapeTab:Toggle({
                                Title = "MP5杀戮光环",
                                Value = false,
                                Callback = function(state)
                                    if mp5Coroutine and mp5KillEnabled then
                                        mp5KillEnabled = false
                                        task.wait(0.1)
                                    end
                                    mp5KillEnabled = state
                                    if mp5KillEnabled then
                                        mp5Coroutine = coroutine.wrap(startMp5AuraLogic)
                                        mp5Coroutine()
                                        WindUI:Notify({
                                            Title = "MP5杀戮光环已开启",
                                            Content = "范围: " .. mp5AuraRange,
                                            Duration = 2,
                                        })
                                    else
                                        WindUI:Notify({
                                            Title = "MP5杀戮光环已关闭",
                                            Duration = 2,
                                        })
                                    end
                                end,
                            })
                            
                            local mp5TeleportToggle = Tabs.EscapeTab:Toggle({
                                Title = "MP5传送杀戮光环",
                                Value = false,
                                Callback = function(state)
                                    mp5TeleportEnabled = state
                                    if state then
                                        WindUI:Notify({
                                            Title = "MP5传送已开启",
                                            Content = "攻击时会传送到敌人身边",
                                            Duration = 2,
                                        })
                                    else
                                        WindUI:Notify({
                                            Title = "MP5传送已关闭",
                                            Duration = 2,
                                        })
                                    end
                                end,
                            })
                            
                            local mp5RangeSlider = Tabs.EscapeTab:Slider({
                                Title = "MP5攻击范围",
                                Value = {
                                    Min = 10,
                                    Max = 1000,
                                    Default = 100,
                                },
                                Callback = function(value)
                                    mp5AuraRange = value
                                end,
                            })
                            
                            local m9Toggle = Tabs.EscapeTab:Toggle({
                                Title = "M9杀戮光环",
                                Value = false,
                                Callback = function(state)
                                    if m9Coroutine and m9KillEnabled then
                                        m9KillEnabled = false
                                        task.wait(0.1)
                                    end
                                    m9KillEnabled = state
                                    if m9KillEnabled then
                                        m9Coroutine = coroutine.wrap(startM9AuraLogic)
                                        m9Coroutine()
                                        WindUI:Notify({
                                            Title = "M9杀戮光环已开启",
                                            Content = "范围: " .. m9AuraRange,
                                            Duration = 2,
                                        })
                                    else
                                        WindUI:Notify({
                                            Title = "M9杀戮光环已关闭",
                                            Duration = 2,
                                        })
                                    end
                                end,
                            })
                            
                            local m9TeleportToggle = Tabs.EscapeTab:Toggle({
                                Title = "M9传送杀戮光环",
                                Value = false,
                                Callback = function(state)
                                    m9TeleportEnabled = state
                                    if state then
                                        WindUI:Notify({
                                            Title = "M9传送已开启",
                                            Content = "攻击时会传送到敌人身边",
                                            Duration = 2,
                                        })
                                    else
                                        WindUI:Notify({
                                            Title = "M9传送已关闭",
                                            Duration = 2,
                                        })
                                    end
                                end,
                            })
                            
                            local m9RangeSlider = Tabs.EscapeTab:Slider({
                                Title = "M9攻击范围",
                                Value = {
                                    Min = 10,
                                    Max = 1000,
                                    Default = 100,
                                },
                                Callback = function(value)
                                    m9AuraRange = value
                                end,
                            })
                            
                            Tabs.EscapeTab:Button({
                                Title = "传送犯罪窝点",
                                Callback = function()
                                    local char = game.Players.LocalPlayer.Character
                                    if char and char:FindFirstChild("HumanoidRootPart") then
                                        char.HumanoidRootPart.CFrame = CFrame.new(-974.71, 108.32, 2055.38)
                                        WindUI:Notify({
                                            Title = "传送成功",
                                            Content = "已传送到犯罪窝点",
                                            Duration = 2,
                                        })
                                    end
                                end,
                            })
                            
                            Tabs.EscapeTab:Button({
                                Title = "传送警察室内",
                                Callback = function()
                                    local char = game.Players.LocalPlayer.Character
                                    if char and char:FindFirstChild("HumanoidRootPart") then
                                        char.HumanoidRootPart.CFrame = CFrame.new(819.14, 99.98, 2232.99)
                                        WindUI:Notify({
                                            Title = "传送成功",
                                            Content = "已传送到警察室内",
                                            Duration = 2,
                                        })
                                    end
                                end,
                            })
                            
                            Tabs.EscapeTab:Button({
                                Title = "传送监狱大门",
                                Callback = function()
                                    local char = game.Players.LocalPlayer.Character
                                    if char and char:FindFirstChild("HumanoidRootPart") then
                                        char.HumanoidRootPart.CFrame = CFrame.new(548.22, 98.19, 2241.38)
                                        WindUI:Notify({
                                            Title = "传送成功",
                                            Content = "已传送到监狱大门",
                                            Duration = 2,
                                        })
                                    end
                                end,
                            })
                            
                            Tabs.EscapeTab:Button({
                                Title = "重置所有光环",
                                Callback = function()
                                    killToggle:SetValue(false)
                                    teleportToggle:SetValue(false)
                                    rangeSlider:SetValue(100)
                                    mp5Toggle:SetValue(false)
                                    mp5TeleportToggle:SetValue(false)
                                    mp5RangeSlider:SetValue(100)
                                    m9Toggle:SetValue(false)
                                    m9TeleportToggle:SetValue(false)
                                    m9RangeSlider:SetValue(100)
                                    if killAuraEnabled then killAuraEnabled = false end
                                    teleportKillEnabled = false
                                    if mp5KillEnabled then mp5KillEnabled = false end
                                    mp5TeleportEnabled = false
                                    if m9KillEnabled then m9KillEnabled = false end
                                    m9TeleportEnabled = false
                                    WindUI:Notify({
                                        Title = "已重置",
                                        Content = "所有光环已关闭，范围已重置为100",
                                        Duration = 2,
                                    })
                                end,
                            })
                            
                            createdTabs["逃出监狱者"] = true
                            WindUI:Notify({
                                Title = "选项卡已创建",
                                Content = "逃出监狱者选项卡已添加",
                                Duration = 2,
                            })
                        else
                            WindUI:Notify({
                                Title = "提示",
                                Content = "逃出监狱者选项卡已存在",
                                Duration = 2,
                            })
                        end
                    end,
                },
            }
        })
    end,
})

Tabs.SettingsTab:Colorpicker({
    Title = "选择颜色",
    Default = Color3.fromRGB(0, 0, 255),
    Transparency = 0,
    Callback = function(color) 
        print("选择的颜色: " .. tostring(color)) 
    end
})

Tabs.SettingsTab:Button({
    Title = "重置所有选项卡",
    Desc = "删除所有通过选择阵营创建的选项卡",
    Callback = function()
        stopKillAura()
        stopMp5Aura()
        stopTaserAura()
        stopM9Aura()
        toggleESP(false)
        if createdTabs["犯罪者"] and Tabs.CriminalTab then
            Tabs.CriminalTab:Destroy()
            Tabs.CriminalTab = nil
            createdTabs["犯罪者"] = nil
        end
        if createdTabs["警察"] and Tabs.PoliceTab then
            Tabs.PoliceTab:Destroy()
            Tabs.PoliceTab = nil
            createdTabs["警察"] = nil
        end
        if createdTabs["逃出监狱者"] and Tabs.EscapeTab then
            Tabs.EscapeTab:Destroy()
            Tabs.EscapeTab = nil
            createdTabs["逃出监狱者"] = nil
            currentKillAuraTab = nil
        end
        WindUI:Notify({
            Title = "重置完成",
            Content = "所有阵营选项卡已删除",
            Duration = 2,
        })
    end,
})