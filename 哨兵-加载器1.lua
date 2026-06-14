local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/KingScriptAE/No-sirve-nada./refs/heads/main/main.lua"))()

WindUI:Localization({
    Enabled = true,
    Prefix = "loc:",
    DefaultLanguage = "en",
    Translations = {
        ["en"] = {
            ["WINDUI_EXAMPLE"] = "WindUI 示例",
            ["WELCOME"] = "Sentinel-加载器",
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

WindUI.TransparencyValue = 0.2
WindUI:SetTheme("Dark")

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
    Title = gradient("Sentinel Demo", Color3.fromHex("#6A11CB"), Color3.fromHex("#2575FC")),
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
    Title = "哨兵-加载器",
    Icon = "geist:window",
    Author = "loc:WELCOME",
    Folder = "WindUI_Example",
    Size = UDim2.fromOffset(580, 490),
    Theme = "Dark",
    Background = "https://raw.githubusercontent.com/NUIke1/Sentinel/refs/heads/main/Image_1780211396491_940.jpg",
    BackgroundImageTransparency = 0.7,
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
    Title = "v1.0",
    Color = Color3.fromHex("#30ff6a")
})

Window:Tag({
    Title = "加载器",
    Color = Color3.fromHex("#315dff")
})

local TimeTag = Window:Tag({
    Title = "--:--",
    Radius = 0,
    Color = WindUI:Gradient({
        ["0"]   = { Color = Color3.fromHex("#FF0F7B"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#F89B29"), Transparency = 0 },
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
        Title = "主题已更改",
        Content = "当前主题: "..WindUI:GetCurrentTheme(),
        Duration = 2
    })
end, 990)

local MainSection = Window:Section({ Title = "脚本加载器", Opened = true })
local LoaderTab = MainSection:Tab({ Title = "脚本列表", Icon = "download", Desc = "选择要加载的脚本" })

LoaderTab:Paragraph({
    Title = "Sentinel 脚本合集",
    Desc = "点击下方按钮加载对应的脚本",
    Image = "package",
    ImageSize = 20,
    Color = Color3.fromHex("#30ff6a"),
})

LoaderTab:Divider()

local doorsScriptLoaded = false
local demonologyLoaded = false
local aimbotLoaded = false

LoaderTab:Button({
    Title = "加载 Doors 脚本",
    Icon = "door",
    Callback = function()
        if not doorsScriptLoaded then
            local success, err = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/ckckck123456/ck.lua1/refs/heads/main/Sentinel-Doors"))()
            end)
            if success then
                doorsScriptLoaded = true
                WindUI:Notify({
                    Title = "加载成功",
                    Content = "Doors 脚本已加载",
                    Icon = "check",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "加载失败",
                    Content = "错误: " .. tostring(err),
                    Icon = "x",
                    Duration = 3
                })
            end
        else
            WindUI:Notify({
                Title = "提示",
                Content = "Doors 脚本已加载过",
                Duration = 2
            })
        end
    end
})

LoaderTab:Button({
    Title = "加载 恶魔学 脚本",
    Icon = "ghost",
    Callback = function()
        if not demonologyLoaded then
            local success, err = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/NUIke1/Sentinel/refs/heads/main/%E5%93%A8%E5%85%B5-%E6%81%B6%E9%AD%94%E5%AD%A6.lua"))()
            end)
            if success then
                demonologyLoaded = true
                WindUI:Notify({
                    Title = "加载成功",
                    Content = "恶魔学 脚本已加载",
                    Icon = "check",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "加载失败",
                    Content = "错误: " .. tostring(err),
                    Icon = "x",
                    Duration = 3
                })
            end
        else
            WindUI:Notify({
                Title = "提示",
                Content = "恶魔学 脚本已加载过",
                Duration = 2
            })
        end
    end
})

LoaderTab:Button({
    Title = "加载 木筏101生存 脚本",
    Icon = "ghost",
    Callback = function()
        if not demonologyLoaded then
            local success, err = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/NUIke1/Sentinel/refs/heads/main/%E6%9C%A8%E7%AD%8F101%E7%94%9F%E5%AD%98.lua"))()
            end)
            if success then
                demonologyLoaded = true
                WindUI:Notify({
                    Title = "加载成功",
                    Content = "木筏101 脚本已加载",
                    Icon = "check",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "加载失败",
                    Content = "错误: " .. tostring(err),
                    Icon = "x",
                    Duration = 3
                })
            end
        else
            WindUI:Notify({
                Title = "提示",
                Content = "木筏101生存 脚本已加载过",
                Duration = 2
            })
        end
    end
})

LoaderTab:Button({
    Title = "加载 木筏101生存 脚本",
    Icon = "ghost",
    Callback = function()
        if not demonologyLoaded then
            local success, err = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/NUIke1/Sentinel/refs/heads/main/%E7%9B%91%E7%8B%B1%E4%BA%BA%E7%94%9F.lua"))()
            end)
            if success then
                demonologyLoaded = true
                WindUI:Notify({
                    Title = "加载成功",
                    Content = "监狱人生 脚本已加载",
                    Icon = "check",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "加载失败",
                    Content = "错误: " .. tostring(err),
                    Icon = "x",
                    Duration = 3
                })
            end
        else
            WindUI:Notify({
                Title = "提示",
                Content = "监狱人生 脚本已加载过",
                Duration = 2
            })
        end
    end
})

LoaderTab:Button({
    Title = "加载 通用自瞄 脚本",
    Icon = "target",
    Callback = function()
        if not aimbotLoaded then
            local success, err = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/NUIke1/Sentinel/refs/heads/main/Sentinel-%E9%80%9A%E7%94%A8%E8%87%AA%E7%9E%84.lua"))()
            end)
            if success then
                aimbotLoaded = true
                WindUI:Notify({
                    Title = "加载成功",
                    Content = "通用自瞄 脚本已加载",
                    Icon = "check",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "加载失败",
                    Content = "错误: " .. tostring(err),
                    Icon = "x",
                    Duration = 3
                })
            end
        else
            WindUI:Notify({
                Title = "提示",
                Content = "通用自瞄 脚本已加载过",
                Duration = 2
            })
        end
    end
})

LoaderTab:Divider()

LoaderTab:Paragraph({
    Title = "使用说明",
    Desc = "一定要去对应的服务器使用脚本",
    Image = "info",
    ImageSize = 20,
    Color = Color3.fromHex("#30ff6a"),
})

LoaderTab:Divider()

LoaderTab:Paragraph({
    Title = "感谢语",
    Desc = "很感谢你能够使用我的脚本，如果有任何问题前往企鹅1034603242",
    Image = "alert-triangle",
    ImageSize = 20,
    Color = Color3.fromHex("#ff6a30"),
})

local ConfigSection = MainSection:Tab({ Title = "设置", Icon = "settings" })

ConfigSection:Paragraph({
    Title = "关于",
    Desc = "Sentinel 脚本加载器 v1.0\n作者: 1",
    Image = "info",
    ImageSize = 20,
    Color = Color3.fromHex("#30ff6a"),
})