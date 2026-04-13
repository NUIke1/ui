local NoirUI = {}
NoirUI.Modules = {}
NoirUI.Version = "1.0.0"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")
local Debris = game:GetService("Debris")
local LP = Players.LocalPlayer

NoirUI.Config = {
    Theme = "Dark",
    Transparency = 0.92,
    AnimationSpeed = 0.2,
    CornerRadius = 12,
    Font = Enum.Font.GothamMedium,
    FontBold = Enum.Font.GothamBold,
    FontLight = Enum.Font.Gotham,
    AutoSave = true,
    Debug = false,
}

local Colors = {
    Dark = {
        Background = Color3.fromRGB(8, 8, 10),
        Surface = Color3.fromRGB(18, 18, 22),
        SurfaceHover = Color3.fromRGB(28, 28, 34),
        SurfaceActive = Color3.fromRGB(38, 38, 44),
        Primary = Color3.fromRGB(88, 101, 242),
        PrimaryHover = Color3.fromRGB(105, 118, 255),
        PrimaryActive = Color3.fromRGB(70, 80, 220),
        Text = Color3.fromRGB(235, 235, 240),
        TextSecondary = Color3.fromRGB(140, 140, 150),
        TextDisabled = Color3.fromRGB(80, 80, 90),
        Border = Color3.fromRGB(40, 40, 45),
        Success = Color3.fromRGB(35, 200, 120),
        Danger = Color3.fromRGB(235, 70, 85),
        Warning = Color3.fromRGB(250, 180, 50),
        Info = Color3.fromRGB(60, 150, 230),
    },
    Light = {
        Background = Color3.fromRGB(245, 245, 250),
        Surface = Color3.fromRGB(255, 255, 255),
        SurfaceHover = Color3.fromRGB(240, 240, 245),
        SurfaceActive = Color3.fromRGB(230, 230, 235),
        Primary = Color3.fromRGB(88, 101, 242),
        PrimaryHover = Color3.fromRGB(105, 118, 255),
        PrimaryActive = Color3.fromRGB(70, 80, 220),
        Text = Color3.fromRGB(30, 30, 35),
        TextSecondary = Color3.fromRGB(100, 100, 110),
        TextDisabled = Color3.fromRGB(170, 170, 180),
        Border = Color3.fromRGB(220, 220, 225),
        Success = Color3.fromRGB(35, 200, 120),
        Danger = Color3.fromRGB(235, 70, 85),
        Warning = Color3.fromRGB(250, 180, 50),
        Info = Color3.fromRGB(60, 150, 230),
    }
}

NoirUI.Colors = Colors

function NoirUI.GetColor(key)
    return Colors[NoirUI.Config.Theme][key]
end

function NoirUI.SetTheme(theme)
    if Colors[theme] then
        NoirUI.Config.Theme = theme
        if NoirUI.OnThemeChanged then
            NoirUI.OnThemeChanged(theme)
        end
    end
end

function NoirUI.Log(...)
    if NoirUI.Config.Debug then
        print("[NoirUI]", ...)
    end
end

local function CreateInstance(className, props, parent)
    local inst = Instance.new(className)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    if parent then
        inst.Parent = parent
    end
    return inst
end

NoirUI.Create = CreateInstance

function NoirUI.Tween(obj, tweenInfo, properties)
    return TweenService:Create(obj, tweenInfo, properties)
end

function NoirUI.Round(num, decimal)
    local mult = 10^(decimal or 0)
    return math.floor(num * mult + 0.5) / mult
end

function NoirUI.Clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

function NoirUI.Lerp(a, b, t)
    return a + (b - a) * NoirUI.Clamp(t, 0, 1)
end

function NoirUI.ShallowCopy(t)
    local new = {}
    for k, v in pairs(t) do
        new[k] = v
    end
    return new
end

function NoirUI.DeepCopy(t, seen)
    seen = seen or {}
    if seen[t] then return seen[t] end
    local new = {}
    seen[t] = new
    for k, v in pairs(t) do
        if type(v) == "table" then
            new[k] = NoirUI.DeepCopy(v, seen)
        else
            new[k] = v
        end
    end
    return new
end

function NoirUI.GenerateID()
    return HttpService:GenerateGUID(false)
end

NoirUI.Services = {
    Players = Players,
    RunService = RunService,
    TweenService = TweenService,
    UserInputService = UserInputService,
    TextService = TextService,
    Debris = Debris,
}

return NoirUI

local NoirUI = NoirUI or {}
local Colors = NoirUI.Colors or {}
local Create = NoirUI.Create or Instance.new

local function GetColor(key)
    return NoirUI.GetColor and NoirUI.GetColor(key) or Colors[NoirUI.Config and NoirUI.Config.Theme or "Dark"][key]
end

function NoirUI.CreateRoundedFrame(parent, size, position, color, transparency, corner)
    local frame = Create("Frame", {
        Size = size,
        Position = position or UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = color or GetColor("Surface"),
        BackgroundTransparency = transparency or 0,
        BorderSizePixel = 0,
    }, parent)
    
    local uiCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, corner or NoirUI.Config.CornerRadius)
    }, frame)
    
    return frame
end

function NoirUI.CreateGlassFrame(parent, size, position, transparency, corner)
    local frame = Create("Frame", {
        Size = size,
        Position = position or UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0.96,
        BorderSizePixel = 0,
    }, parent)
    
    local blur = Create("BlurEffect", {
        Size = 12,
        Enabled = true,
    }, frame)
    
    local cornerInst = Create("UICorner", {
        CornerRadius = UDim.new(0, corner or NoirUI.Config.CornerRadius)
    }, frame)
    
    local stroke = Create("UIStroke", {
        Color = GetColor("Border"),
        Thickness = 1,
        Transparency = 0.5,
    }, frame)
    
    return frame
end

function NoirUI.CreateShadow(parent, targetSize, offset)
    local shadow = Create("Frame", {
        Size = UDim2.new(1, (offset or 4) * 2, 1, (offset or 4) * 2),
        Position = UDim2.new(0.5, -(offset or 4), 0.5, -(offset or 4)),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        ZIndex = -1,
    }, parent)
    
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, NoirUI.Config.CornerRadius + (offset or 4))
    }, shadow)
    
    return shadow
end

function NoirUI.CreateStroke(parent, color, thickness, transparency)
    local stroke = Create("UIStroke", {
        Color = color or GetColor("Border"),
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, parent)
    return stroke
end

function NoirUI.CreateGradient(parent, direction, colors, transparencies)
    local gradient = Create("UIGradient", {}, parent)
    
    if direction == "horizontal" then
        gradient.Rotation = 0
    elseif direction == "vertical" then
        gradient.Rotation = 90
    elseif direction == "diagonal" then
        gradient.Rotation = 45
    else
        gradient.Rotation = direction or 0
    end
    
    local colorKeys = {}
    local transKeys = {}
    
    for i, col in ipairs(colors) do
        local t = (i - 1) / (#colors - 1)
        table.insert(colorKeys, ColorSequenceKeypoint.new(t, col))
    end
    
    for i, trans in ipairs(transparencies or {}) do
        local t = (i - 1) / (#transparencies - 1)
        table.insert(transKeys, NumberSequenceKeypoint.new(t, trans))
    end
    
    if #colorKeys > 0 then
        gradient.Color = ColorSequence.new(colorKeys)
    end
    
    if #transKeys > 0 then
        gradient.Transparency = NumberSequence.new(transKeys)
    end
    
    return gradient
end

function NoirUI.CreateText(parent, text, size, color, transparency, font, position, size2)
    local label = Create("TextLabel", {
        Text = text or "",
        TextSize = size or 14,
        TextColor3 = color or GetColor("Text"),
        TextTransparency = transparency or 0,
        Font = font or NoirUI.Config.Font,
        BackgroundTransparency = 1,
        Size = size2 or UDim2.new(0, 100, 0, 20),
        Position = position or UDim2.new(0, 0, 0, 0),
    }, parent)
    
    return label
end

function NoirUI.CreateButton(parent, text, callback, width, height, variant)
    local button = Create("TextButton", {
        Size = UDim2.new(0, width or 120, 0, height or 36),
        Text = text or "",
        BackgroundColor3 = variant == "secondary" and GetColor("Surface") or GetColor("Primary"),
        BackgroundTransparency = variant == "ghost" and 1 or 0,
        TextColor3 = variant == "secondary" and GetColor("Text") or Color3.new(1, 1, 1),
        TextSize = 14,
        Font = NoirUI.Config.Font,
        AutoButtonColor = false,
        BorderSizePixel = 0,
    }, parent)
    
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, 8)
    }, button)
    
    local hoverColor = variant == "secondary" and GetColor("SurfaceHover") or GetColor("PrimaryHover")
    local normalColor = variant == "secondary" and GetColor("Surface") or GetColor("Primary")
    
    button.MouseButton1Click:Connect(callback)
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = hoverColor}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = normalColor}):Play()
    end)
    
    return button
end

function NoirUI.CreateIcon(parent, iconId, size, color)
    local image = Create("ImageLabel", {
        Size = UDim2.new(0, size or 20, 0, size or 20),
        BackgroundTransparency = 1,
        Image = iconId,
        ImageColor3 = color or GetColor("Text"),
    }, parent)
    
    return image
end

function NoirUI.CreateDivider(parent, width, color, thickness)
    local divider = Create("Frame", {
        Size = UDim2.new(width or 1, 0, 0, thickness or 1),
        BackgroundColor3 = color or GetColor("Border"),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
    }, parent)
    
    return divider
end

function NoirUI.CreateSpacing(parent, height)
    local spacer = Create("Frame", {
        Size = UDim2.new(1, 0, 0, height or 8),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, parent)
    
    return spacer
end

function NoirUI.CreateListLayout(parent, direction, padding, horizontalAlignment, verticalAlignment)
    local layout = Create("UIListLayout", {
        FillDirection = direction == "horizontal" and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, padding or 8),
        HorizontalAlignment = horizontalAlignment == "center" and Enum.HorizontalAlignment.Center 
            or horizontalAlignment == "right" and Enum.HorizontalAlignment.Right 
            or Enum.HorizontalAlignment.Left,
        VerticalAlignment = verticalAlignment == "center" and Enum.VerticalAlignment.Center 
            or verticalAlignment == "bottom" and Enum.VerticalAlignment.Bottom 
            or Enum.VerticalAlignment.Top,
    }, parent)
    return layout
end

function NoirUI.CreateGridLayout(parent, cellSize, fillDirectionMaxCells, startDirection, horizontalAlignment, verticalAlignment)
    local layout = Create("UIGridLayout", {
        CellSize = UDim2.new(0, cellSize.X or 100, 0, cellSize.Y or 100),
        FillDirectionMaxCells = fillDirectionMaxCells or 3,
        SortOrder = Enum.SortOrder.LayoutOrder,
        StartDirection = startDirection == "horizontal" and Enum.StartDirection.Horizontal or Enum.StartDirection.Vertical,
        HorizontalAlignment = horizontalAlignment == "center" and Enum.HorizontalAlignment.Center 
            or horizontalAlignment == "right" and Enum.HorizontalAlignment.Right 
            or Enum.HorizontalAlignment.Left,
        VerticalAlignment = verticalAlignment == "center" and Enum.VerticalAlignment.Center 
            or verticalAlignment == "bottom" and Enum.VerticalAlignment.Bottom 
            or Enum.VerticalAlignment.Top,
    }, parent)
    return layout
end

function NoirUI.CreatePadding(parent, left, right, top, bottom)
    local padding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, left or 0),
        PaddingRight = UDim.new(0, right or 0),
        PaddingTop = UDim.new(0, top or 0),
        PaddingBottom = UDim.new(0, bottom or 0),
    }, parent)
    return padding
end

function NoirUI.CreateScrollFrame(parent, size, position, scrollingDirection)
    local scroll = Create("ScrollingFrame", {
        Size = size or UDim2.new(1, 0, 1, 0),
        Position = position or UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageTransparency = 0.8,
        ScrollingDirection = scrollingDirection == "horizontal" and Enum.ScrollingDirection.X 
            or scrollingDirection == "both" and Enum.ScrollingDirection.XY 
            or Enum.ScrollingDirection.Y,
        ElasticBehavior = Enum.ElasticBehavior.Never,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
    }, parent)
    
    local scrollBar = scroll:FindFirstChild("ScrollBar")
    if scrollBar then
        scrollBar.ScrollBarImageColor3 = GetColor("Primary")
    end
    
    return scroll
end

function NoirUI.CreateCanvasGroup(parent, size, position, groupTransparency)
    local canvas = Create("CanvasGroup", {
        Size = size or UDim2.new(1, 0, 1, 0),
        Position = position or UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = GetColor("Surface"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        GroupTransparency = groupTransparency or 0,
    }, parent)
    
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, NoirUI.Config.CornerRadius)
    }, canvas)
    
    return canvas
end

function NoirUI.CreateViewport(parent, size, position)
    local viewport = Create("ViewportFrame", {
        Size = size or UDim2.new(1, 0, 1, 0),
        Position = position or UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = GetColor("Surface"),
        BorderSizePixel = 0,
    }, parent)
    
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, NoirUI.Config.CornerRadius)
    }, viewport)
    
    return viewport
end

function NoirUI.CreateScrollingList(parent, itemHeight, onUpdate)
    local container = Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
    }, parent)
    
    local scroll = NoirUI.CreateScrollFrame(container, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), "vertical")
    
    local listContainer = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
    }, scroll)
    
    local layout = NoirUI.CreateListLayout(listContainer, "vertical", 0)
    
    local items = {}
    
    local function RefreshLayout()
        local totalHeight = 0
        for i, item in ipairs(items) do
            if item.Visible ~= false then
                totalHeight = totalHeight + itemHeight
            end
        end
        listContainer.Size = UDim2.new(1, 0, 0, totalHeight)
        if onUpdate then
            onUpdate(#items)
        end
    end
    
    local function AddItem(data)
        local item = {
            Data = data,
            Visible = true,
            Frame = nil,
        }
        
        item.Frame = Create("Frame", {
            Size = UDim2.new(1, 0, 0, itemHeight),
            BackgroundTransparency = 1,
            LayoutOrder = #items + 1,
        }, listContainer)
        
        table.insert(items, item)
        RefreshLayout()
        return item
    end
    
    local function RemoveItem(index)
        if items[index] and items[index].Frame then
            items[index].Frame:Destroy()
            table.remove(items, index)
            for i = index, #items do
                if items[i] and items[i].Frame then
                    items[i].Frame.LayoutOrder = i
                end
            end
            RefreshLayout()
        end
    end
    
    local function ClearItems()
        for _, item in ipairs(items) do
            if item.Frame then
                item.Frame:Destroy()
            end
        end
        items = {}
        RefreshLayout()
    end
    
    local function SetItemVisible(index, visible)
        if items[index] then
            items[index].Visible = visible
            if items[index].Frame then
                items[index].Frame.Visible = visible
            end
            RefreshLayout()
        end
    end
    
    return {
        Container = container,
        ScrollFrame = scroll,
        ListContainer = listContainer,
        Items = items,
        AddItem = AddItem,
        RemoveItem = RemoveItem,
        ClearItems = ClearItems,
        SetItemVisible = SetItemVisible,
        RefreshLayout = RefreshLayout,
    }
end

function NoirUI.CreatePagedContainer(parent, pageCount, onPageChange)
    local container = Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
    }, parent)
    
    local pages = {}
    local currentPage = 1
    
    for i = 1, pageCount do
        local page = Create("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            Visible = i == 1,
        }, container)
        pages[i] = page
    end
    
    local function GoToPage(pageNum)
        if pageNum < 1 or pageNum > pageCount then
            return false
        end
        if pages[currentPage] then
            pages[currentPage].Visible = false
        end
        currentPage = pageNum
        if pages[currentPage] then
            pages[currentPage].Visible = true
        end
        if onPageChange then
            onPageChange(currentPage)
        end
        return true
    end
    
    local function NextPage()
        return GoToPage(currentPage + 1)
    end
    
    local function PrevPage()
        return GoToPage(currentPage - 1)
    end
    
    return {
        Container = container,
        Pages = pages,
        CurrentPage = currentPage,
        GoToPage = GoToPage,
        NextPage = NextPage,
        PrevPage = PrevPage,
    }
end

function NoirUI.CreateTabContainer(parent, tabs, onTabChange)
    local container = Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
    }, parent)
    
    local tabBar = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundTransparency = 1,
    }, container)
    
    local contentArea = Create("Frame", {
        Size = UDim2.new(1, 0, 1, -44),
        Position = UDim2.new(0, 0, 0, 44),
        BackgroundTransparency = 1,
    }, container)
    
    local tabButtons = {}
    local tabContents = {}
    local selectedTab = 1
    
    local tabLayout = NoirUI.CreateListLayout(tabBar, "horizontal", 4)
    
    for i, tab in ipairs(tabs) do
        local tabButton = NoirUI.CreateButton(tabBar, tab.Name, nil, 100, 36, "ghost")
        tabButton.LayoutOrder = i
        tabButton.BackgroundTransparency = 1
        
        local indicator = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 2),
            Position = UDim2.new(0, 0, 1, -2),
            BackgroundColor3 = GetColor("Primary"),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
        }, tabButton)
        
        local content = Create("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = i == 1,
        }, contentArea)
        
        tabButtons[i] = {Button = tabButton, Indicator = indicator}
        tabContents[i] = content
        
        tabButton.MouseButton1Click:Connect(function()
            if selectedTab == i then return end
            tabContents[selectedTab].Visible = false
            TweenService:Create(tabButtons[selectedTab].Indicator, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            selectedTab = i
            tabContents[selectedTab].Visible = true
            TweenService:Create(tabButtons[selectedTab].Indicator, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
            if onTabChange then
                onTabChange(i, tab)
            end
        end)
        
        tabButton.MouseEnter:Connect(function()
            if selectedTab ~= i then
                TweenService:Create(indicator, TweenInfo.new(0.15), {BackgroundTransparency = 0.5}):Play()
            end
        end)
        
        tabButton.MouseLeave:Connect(function()
            if selectedTab ~= i then
                TweenService:Create(indicator, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
            end
        end)
    end
    
    TweenService:Create(tabButtons[1].Indicator, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    
    return {
        Container = container,
        TabBar = tabBar,
        ContentArea = contentArea,
        TabButtons = tabButtons,
        TabContents = tabContents,
        SelectedTab = selectedTab,
        SelectTab = function(index)
            if tabButtons[index] then
                tabButtons[index].Button.MouseButton1Click:Fire()
            end
        end,
    }
end

local NoirUI = NoirUI or {}
local GetColor = NoirUI.GetColor or function(key) return NoirUI.Colors[NoirUI.Config.Theme][key] end
local Create = NoirUI.Create or Instance.new

NoirUI.Windows = NoirUI.Windows or {}
NoirUI.ActiveWindows = {}

function NoirUI.CreateWindow(config)
    config = config or {}
    
    local screenGui = Create("ScreenGui", {
        Name = config.Name or "NoirUI_Window_" .. NoirUI.GenerateID(),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
    })
    
    local mainFrame = Create("Frame", {
        Size = config.Size or UDim2.new(0, 800, 0, 600),
        Position = config.Position or UDim2.new(0.5, -400, 0.5, -300),
        BackgroundColor3 = GetColor("Surface"),
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, screenGui)
    
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, config.CornerRadius or NoirUI.Config.CornerRadius)
    }, mainFrame)
    
    local shadow = NoirUI.CreateShadow(mainFrame, mainFrame.Size, 8)
    shadow.ZIndex = -1
    
    local glassOverlay = Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0.96,
        BorderSizePixel = 0,
    }, mainFrame)
    
    local glassCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, config.CornerRadius or NoirUI.Config.CornerRadius)
    }, glassOverlay)
    
    local titleBar = Create("Frame", {
        Size = UDim2.new(1, 0, 0, config.TitleBarHeight or 48),
        BackgroundTransparency = 1,
    }, mainFrame)
    
    local dragArea = Create("Frame", {
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
    }, titleBar)
    
    local titleText = NoirUI.CreateText(titleBar, config.Title or "NoirUI", 16, GetColor("Text"), 0, NoirUI.Config.FontBold, UDim2.new(0, 60, 0, 14), UDim2.new(0, 200, 0, 48))
    titleText.Position = UDim2.new(0, 16, 0.5, -8)
    
    local contentArea = Create("Frame", {
        Size = UDim2.new(1, -32, 1, -config.TitleBarHeight or -48),
        Position = UDim2.new(0, 16, 0, config.TitleBarHeight or 48),
        BackgroundTransparency = 1,
    }, mainFrame)
    
    local isDragging = false
    local dragStart
    local windowStart
    
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStart = input.Position
            windowStart = mainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            local newX = windowStart.X.Offset + delta.X
            local newY = windowStart.Y.Offset + delta.Y
            mainFrame.Position = UDim2.new(windowStart.X.Scale, newX, windowStart.Y.Scale, newY)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    local closeButton = NoirUI.CreateButton(titleBar, "", function()
        if config.OnClose then
            config.OnClose()
        end
        screenGui:Destroy()
        for i, w in ipairs(NoirUI.ActiveWindows) do
            if w == window then
                table.remove(NoirUI.ActiveWindows, i)
                break
            end
        end
    end, 32, 32, "ghost")
    closeButton.Position = UDim2.new(1, -48, 0.5, -16)
    closeButton.BackgroundTransparency = 1
    
    local closeIcon = NoirUI.CreateIcon(closeButton, "rbxassetid://10734867702", 16, GetColor("TextSecondary"))
    closeIcon.Position = UDim2.new(0.5, -8, 0.5, -8)
    
    local minimizeButton = NoirUI.CreateButton(titleBar, "", function()
        if config.OnMinimize then
            config.OnMinimize()
        end
        mainFrame.Size = UDim2.new(mainFrame.Size.X.Scale, mainFrame.Size.X.Offset, 0, 48)
        if contentArea then
            contentArea.Visible = false
        end
    end, 32, 32, "ghost")
    minimizeButton.Position = UDim2.new(1, -88, 0.5, -16)
    minimizeButton.BackgroundTransparency = 1
    
    local minimizeIcon = NoirUI.CreateIcon(minimizeButton, "rbxassetid://10734867672", 16, GetColor("TextSecondary"))
    minimizeIcon.Position = UDim2.new(0.5, -8, 0.5, -8)
    
    local maximizeButton = NoirUI.CreateButton(titleBar, "", function()
        if config.OnMaximize then
            config.OnMaximize()
        end
        if mainFrame.Size.Y.Offset > 100 then
            windowSaved = {Size = mainFrame.Size, Position = mainFrame.Position}
            mainFrame.Size = UDim2.new(1, 0, 1, 0)
            mainFrame.Position = UDim2.new(0, 0, 0, 0)
        else
            if windowSaved then
                mainFrame.Size = windowSaved.Size
                mainFrame.Position = windowSaved.Position
            end
        end
        if contentArea then
            contentArea.Visible = true
        end
    end, 32, 32, "ghost")
    maximizeButton.Position = UDim2.new(1, -128, 0.5, -16)
    maximizeButton.BackgroundTransparency = 1
    
    local maximizeIcon = NoirUI.CreateIcon(maximizeButton, "rbxassetid://10734867678", 16, GetColor("TextSecondary"))
    maximizeIcon.Position = UDim2.new(0.5, -8, 0.5, -8)
    
    local borderStroke = NoirUI.CreateStroke(mainFrame, GetColor("Border"), 1, 0.3)
    
    local window = {
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        ContentArea = contentArea,
        TitleBar = titleBar,
        TitleText = titleText,
        CloseButton = closeButton,
        MinimizeButton = minimizeButton,
        MaximizeButton = maximizeButton,
        
        SetTitle = function(self, newTitle)
            titleText.Text = newTitle
        end,
        
        SetSize = function(self, newSize)
            TweenService:Create(mainFrame, TweenInfo.new(0.2), {Size = newSize}):Play()
        end,
        
        SetPosition = function(self, newPosition)
            TweenService:Create(mainFrame, TweenInfo.new(0.2), {Position = newPosition}):Play()
        end,
        
        Center = function(self)
            local parentSize = screenGui.AbsoluteSize
            local frameSize = mainFrame.AbsoluteSize
            mainFrame.Position = UDim2.new(0.5, -frameSize.X / 2, 0.5, -frameSize.Y / 2)
        end,
        
        Close = function(self)
            if config.OnClose then
                config.OnClose()
            end
            screenGui:Destroy()
            for i, w in ipairs(NoirUI.ActiveWindows) do
                if w == window then
                    table.remove(NoirUI.ActiveWindows, i)
                    break
                end
            end
        end,
        
        Minimize = function(self)
            minimizeButton.MouseButton1Click:Fire()
        end,
        
        Maximize = function(self)
            maximizeButton.MouseButton1Click:Fire()
        end,
        
        AddElement = function(self, element, layoutOrder)
            element.Parent = contentArea
            if layoutOrder then
                element.LayoutOrder = layoutOrder
            end
        end,
        
        Clear = function(self)
            for _, child in ipairs(contentArea:GetChildren()) do
                if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
                    child:Destroy()
                end
            end
        end,
    }
    
    screenGui.Parent = LP.PlayerGui
    table.insert(NoirUI.ActiveWindows, window)
    
    if config.OnCreate then
        config.OnCreate(window)
    end
    
    return window
end

function NoirUI.CloseAllWindows()
    for _, window in ipairs(NoirUI.ActiveWindows) do
        window:Close()
    end
    NoirUI.ActiveWindows = {}
end

function NoirUI.CreateModal(config)
    config = config or {}
    
    local overlay = Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.5,
        ZIndex = 1000,
    })
    
    local window = NoirUI.CreateWindow({
        Title = config.Title or "Modal",
        Size = config.Size or UDim2.new(0, 400, 0, 300),
        Position = UDim2.new(0.5, -200, 0.5, -150),
        OnClose = function()
            overlay:Destroy()
        end,
    })
    
    window.ScreenGui.Parent = overlay
    overlay.Parent = LP.PlayerGui
    
    return window
end

function NoirUI.CreateDialog(config)
    config = config or {}
    
    local overlay = Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.6,
        ZIndex = 1000,
    }, LP.PlayerGui)
    
    local dialogFrame = NoirUI.CreateRoundedFrame(overlay, UDim2.new(0, 360, 0, 220), UDim2.new(0.5, -180, 0.5, -110), GetColor("Surface"), 0, 16)
    dialogFrame.ZIndex = 1001
    
    local titleText = NoirUI.CreateText(dialogFrame, config.Title or "Dialog", 18, GetColor("Text"), 0, NoirUI.Config.FontBold, UDim2.new(0, 16, 0, 20), UDim2.new(1, -32, 0, 24))
    
    local contentText = NoirUI.CreateText(dialogFrame, config.Content or "", 14, GetColor("TextSecondary"), 0, NoirUI.Config.Font, UDim2.new(0, 16, 0, 60), UDim2.new(1, -32, 0, 80))
    contentText.TextWrapped = true
    contentText.TextXAlignment = Enum.TextXAlignment.Left
    contentText.TextYAlignment = Enum.TextYAlignment.Top
    
    local buttonArea = Create("Frame", {
        Size = UDim2.new(1, -32, 0, 40),
        Position = UDim2.new(0, 16, 1, -56),
        BackgroundTransparency = 1,
    }, dialogFrame)
    
    local buttonLayout = NoirUI.CreateListLayout(buttonArea, "horizontal", 12, "right")
    
    local dialog = {
        Frame = dialogFrame,
        Overlay = overlay,
        
        Close = function(self)
            overlay:Destroy()
        end,
        
        AddButton = function(self, text, callback, variant)
            local btn = NoirUI.CreateButton(buttonArea, text, function()
                if callback then callback(self) end
                self:Close()
            end, 80, 36, variant or "primary")
            return btn
        end,
    }
    
    if config.Buttons then
        for _, btn in ipairs(config.Buttons) do
            dialog:AddButton(btn.Text, btn.Callback, btn.Variant)
        end
    else
        dialog:AddButton("确定", nil, "primary")
    end
    
    return dialog
end

NoirUI.Loading = {}

function NoirUI.Loading.CreateSpinner(parent, size, color)
    local container = Create("Frame", {
        Size = UDim2.new(0, size or 40, 0, size or 40),
        Position = UDim2.new(0.5, -(size or 40)/2, 0.5, -(size or 40)/2),
        BackgroundTransparency = 1,
    }, parent)
    
    local spinner = Create("Frame", {
        Size = UDim2.new(0, (size or 40) * 0.7, 0, (size or 40) * 0.7),
        Position = UDim2.new(0.5, -(size or 40) * 0.35, 0.5, -(size or 40) * 0.35),
        BackgroundColor3 = color or GetColor("Primary"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
    }, container)
    
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(1, 0)
    }, spinner)
    
    local angle = 0
    local pulseUp = TweenService:Create(spinner, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.6})
    local pulseDown = TweenService:Create(spinner, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0})
    
    local connection
    connection = RunService.RenderStepped:Connect(function(dt)
        if container.Parent then
            angle = angle + dt * 10
            spinner.Rotation = angle * 180 / math.pi
        else
            connection:Disconnect()
        end
    end)
    
    pulseUp:Play()
    pulseUp.Completed:Connect(function()
        pulseDown:Play()
    end)
    pulseDown.Completed:Connect(function()
        pulseUp:Play()
    end)
    
    return container
end

function NoirUI.Loading.CreateCircularProgress(parent, size, thickness, color)
    local container = Create("Frame", {
        Size = UDim2.new(0, size or 60, 0, size or 60),
        BackgroundTransparency = 1,
    }, parent)
    
    local bgCircle = Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = GetColor("Surface"),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
    }, container)
    
    local bgCorner = Create("UICorner", {
        CornerRadius = UDim.new(1, 0)
    }, bgCircle)
    
    local progressCircle = Create("Frame", {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = color or GetColor("Primary"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
    }, container)
    
    local progressCorner = Create("UICorner", {
        CornerRadius = UDim.new(1, 0)
    }, progressCircle)
    
    local text = NoirUI.CreateText(container, "0%", 14, GetColor("Text"), 0, NoirUI.Config.FontBold, UDim2.new(0.5, -20, 0.5, -10), UDim2.new(0, 40, 0, 20))
    
    local currentProgress = 0
    
    local function SetProgress(value)
        currentProgress = NoirUI.Clamp(value, 0, 1)
        local angle = currentProgress * 360
        progressCircle.Size = UDim2.new(0, size or 60, 0, size or 60)
        progressCircle.Rotation = -90
        text.Text = math.floor(currentProgress * 100) .. "%"
        
        local clip = Create("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ClipsDescendants = true,
        }, container)
        
        local halfSize = (size or 60) / 2
        local radius = halfSize - (thickness or 4)
        
        for i = 1, 360 do
            if i / 360 <= currentProgress then
                local rad = math.rad(i)
                local x = halfSize + radius * math.cos(rad)
                local y = halfSize + radius * math.sin(rad)
                local dot = Create("Frame", {
                    Size = UDim2.new(0, thickness or 4, 0, thickness or 4),
                    Position = UDim2.new(0, x - (thickness or 4)/2, 0, y - (thickness or 4)/2),
                    BackgroundColor3 = color or GetColor("Primary"),
                    BackgroundTransparency = 0,
                    BorderSizePixel = 0,
                }, clip)
                local dotCorner = Create("UICorner", {
                    CornerRadius = UDim.new(1, 0)
                }, dot)
            end
        end
    end
    
    local function AnimateTo(target, duration)
        local start = currentProgress
        local elapsed = 0
        local connection
        connection = RunService.RenderStepped:Connect(function(dt)
            elapsed = elapsed + dt
            local t = NoirUI.Clamp(elapsed / duration, 0, 1)
            local newValue = start + (target - start) * t
            SetProgress(newValue)
            if t >= 1 then
                connection:Disconnect()
            end
        end)
    end
    
    SetProgress(0)
    
    return {
        Container = container,
        SetProgress = SetProgress,
        AnimateTo = AnimateTo,
        Text = text,
    }
end

function NoirUI.Loading.CreateProgressBar(parent, width, height, color)
    local container = Create("Frame", {
        Size = UDim2.new(0, width or 300, 0, height or 8),
        BackgroundColor3 = GetColor("SurfaceHover"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
    }, parent)
    
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(1, 0)
    }, container)
    
    local fill = Create("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = color or GetColor("Primary"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
    }, container)
    
    local fillCorner = Create("UICorner", {
        CornerRadius = UDim.new(1, 0)
    }, fill)
    
    local text = NoirUI.CreateText(container, "0%", 12, GetColor("TextSecondary"), 0, NoirUI.Config.Font, UDim2.new(0.5, -20, -1, -4), UDim2.new(0, 40, 0, 16))
    
    local currentValue = 0
    
    local function SetProgress(value)
        currentValue = NoirUI.Clamp(value, 0, 1)
        local targetWidth = (width or 300) * currentValue
        TweenService:Create(fill, TweenInfo.new(0.2), {Size = UDim2.new(0, targetWidth, 1, 0)}):Play()
        text.Text = math.floor(currentValue * 100) .. "%"
    end
    
    local function AnimateTo(target, duration)
        local start = currentValue
        local elapsed = 0
        local connection
        connection = RunService.RenderStepped:Connect(function(dt)
            elapsed = elapsed + dt
            local t = NoirUI.Clamp(elapsed / duration, 0, 1)
            local newValue = start + (target - start) * t
            SetProgress(newValue)
            if t >= 1 then
                connection:Disconnect()
            end
        end)
    end
    
    return {
        Container = container,
        Fill = fill,
        Text = text,
        SetProgress = SetProgress,
        AnimateTo = AnimateTo,
        GetValue = function() return currentValue end,
    }
end

function NoirUI.Loading.CreateSkeleton(parent, width, height, corner)
    local skeleton = Create("Frame", {
        Size = width or UDim2.new(1, 0, 0, 20),
        BackgroundColor3 = GetColor("SurfaceHover"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
    }, parent)
    
    local cornerInst = Create("UICorner", {
        CornerRadius = UDim.new(0, corner or 4)
    }, skeleton)
    
    local pulse = TweenService:Create(skeleton, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {BackgroundTransparency = 0.5})
    pulse:Play()
    
    return {
        Frame = skeleton,
        Destroy = function()
            pulse:Cancel()
            skeleton:Destroy()
        end,
    }
end

function NoirUI.Loading.CreateSkeletonText(parent, lineCount, lineHeight)
    local container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, (lineHeight or 16) * lineCount + (lineCount - 1) * 8),
        BackgroundTransparency = 1,
    }, parent)
    
    local skeletons = {}
    
    for i = 1, lineCount do
        local width = i == lineCount and 0.6 or 1
        local skeleton = NoirUI.Loading.CreateSkeleton(container, UDim2.new(width, 0, 0, lineHeight or 16), UDim2.new(0, 0, 0, (i-1) * ((lineHeight or 16) + 8)), 4)
        table.insert(skeletons, skeleton)
    end
    
    return {
        Container = container,
        Skeletons = skeletons,
        Destroy = function()
            for _, s in ipairs(skeletons) do
                s:Destroy()
            end
            container:Destroy()
        end,
    }
end

function NoirUI.Loading.CreateSkeletonAvatar(parent, size)
    local skeleton = NoirUI.Loading.CreateSkeleton(parent, UDim2.new(0, size or 40, 0, size or 40), UDim2.new(0, 0, 0, 0), size or 40)
    return skeleton
end

function NoirUI.Loading.CreateFullscreenLoader(message)
    local overlay = Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.7,
        ZIndex = 2000,
    }, LP.PlayerGui)
    
    local card = NoirUI.CreateRoundedFrame(overlay, UDim2.new(0, 240, 0, 160), UDim2.new(0.5, -120, 0.5, -80), GetColor("Surface"), 0, 16)
    card.ZIndex = 2001
    
    local spinner = NoirUI.Loading.CreateSpinner(card, 48)
    spinner.Position = UDim2.new(0.5, -24, 0, 20)
    
    local text = NoirUI.CreateText(card, message or "加载中...", 16, GetColor("Text"), 0, NoirUI.Config.Font, UDim2.new(0, 0, 0, 90), UDim2.new(1, 0, 0, 30))
    text.TextXAlignment = Enum.TextXAlignment.Center
    
    local function Close()
        overlay:Destroy()
    end
    
    return {
        Overlay = overlay,
        Card = card,
        Text = text,
        Close = Close,
    }
end

function NoirUI.Loading.CreateInlineLoader(parent, size)
    local container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, size or 60),
        BackgroundTransparency = 1,
    }, parent)
    
    local spinner = NoirUI.Loading.CreateSpinner(container, 32)
    spinner.Position = UDim2.new(0.5, -16, 0.5, -16)
    
    return {
        Container = container,
        Spinner = spinner,
        Destroy = function()
            container:Destroy()
        end,
    }
end

function NoirUI.Loading.CreateDotsLoader(parent, dotCount, dotSize, color)
    local container = Create("Frame", {
        Size = UDim2.new(0, (dotCount or 3) * ((dotSize or 10) + 8), 0, dotSize or 10),
        BackgroundTransparency = 1,
    }, parent)
    
    local dots = {}
    
    for i = 1, (dotCount or 3) do
        local dot = Create("Frame", {
            Size = UDim2.new(0, dotSize or 10, 0, dotSize or 10),
            Position = UDim2.new(0, (i-1) * ((dotSize or 10) + 8), 0.5, -(dotSize or 10)/2),
            BackgroundColor3 = color or GetColor("Primary"),
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
        }, container)
        
        local corner = Create("UICorner", {
            CornerRadius = UDim.new(1, 0)
        }, dot)
        
        table.insert(dots, dot)
        
        local delayTime = (i - 1) * 0.15
        task.delay(delayTime, function()
            local tween1 = TweenService:Create(dot, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {BackgroundTransparency = 0.7})
            local tween2 = TweenService:Create(dot, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {BackgroundTransparency = 0})
            tween1:Play()
            tween2:Play()
        end)
    end
    
    return {
        Container = container,
        Dots = dots,
        Destroy = function()
            container:Destroy()
        end,
    }
end

NoirUI.Button = {}

function NoirUI.Button.Create(parent, config)
    config = config or {}
    
    local button = Create("TextButton", {
        Size = config.Size or UDim2.new(0, 120, 0, 36),
        Position = config.Position or UDim2.new(0, 0, 0, 0),
        Text = config.Text or "",
        TextSize = config.TextSize or 14,
        TextColor3 = config.TextColor or GetColor("Text"),
        Font = config.Font or NoirUI.Config.Font,
        BackgroundColor3 = config.BackgroundColor or GetColor("Primary"),
        BackgroundTransparency = config.BackgroundTransparency or 0,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        LayoutOrder = config.LayoutOrder or 0,
    }, parent)
    
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, config.CornerRadius or 8)
    }, button)
    
    if config.Icon then
        local icon = NoirUI.CreateIcon(button, config.Icon, config.IconSize or 16, config.IconColor or Color3.new(1, 1, 1))
        icon.Position = UDim2.new(0, 12, 0.5, -8)
        button.Text = "  " .. config.Text
    end
    
    local hoverColor = config.HoverColor or GetColor("PrimaryHover")
    local normalColor = config.BackgroundColor or GetColor("Primary")
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = hoverColor}):Play()
        if config.OnHover then config.OnHover(true) end
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = normalColor}):Play()
        if config.OnHover then config.OnHover(false) end
    end)
    
    button.MouseButton1Click:Connect(function()
        if config.OnClick then config.OnClick(button) end
    end)
    
    return button
end

function NoirUI.Button.CreatePrimary(parent, text, onClick, width)
    return NoirUI.Button.Create(parent, {
        Text = text,
        Size = UDim2.new(0, width or 120, 0, 36),
        BackgroundColor = GetColor("Primary"),
        HoverColor = GetColor("PrimaryHover"),
        OnClick = onClick,
    })
end

function NoirUI.Button.CreateSecondary(parent, text, onClick, width)
    return NoirUI.Button.Create(parent, {
        Text = text,
        Size = UDim2.new(0, width or 120, 0, 36),
        BackgroundColor = GetColor("Surface"),
        TextColor = GetColor("Text"),
        HoverColor = GetColor("SurfaceHover"),
        OnClick = onClick,
    })
end

function NoirUI.Button.CreateGhost(parent, text, onClick, width)
    return NoirUI.Button.Create(parent, {
        Text = text,
        Size = UDim2.new(0, width or 100, 0, 36),
        BackgroundColor = Color3.new(1, 1, 1),
        BackgroundTransparency = 1,
        TextColor = GetColor("Primary"),
        HoverColor = Color3.new(1, 1, 1),
        OnClick = onClick,
    })
end

function NoirUI.Button.CreateDanger(parent, text, onClick, width)
    return NoirUI.Button.Create(parent, {
        Text = text,
        Size = UDim2.new(0, width or 120, 0, 36),
        BackgroundColor = GetColor("Danger"),
        HoverColor = GetColor("Danger"),
        OnClick = onClick,
    })
end

function NoirUI.Button.CreateSuccess(parent, text, onClick, width)
    return NoirUI.Button.Create(parent, {
        Text = text,
        Size = UDim2.new(0, width or 120, 0, 36),
        BackgroundColor = GetColor("Success"),
        HoverColor = GetColor("Success"),
        OnClick = onClick,
    })
end

function NoirUI.Button.CreateIconButton(parent, iconId, onClick, size)
    local button = Create("ImageButton", {
        Size = UDim2.new(0, size or 36, 0, size or 36),
        BackgroundColor3 = GetColor("Surface"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Image = iconId,
        ImageColor3 = GetColor("Text"),
        ImageTransparency = 0,
    }, parent)
    
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, 8)
    }, button)
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = GetColor("SurfaceHover")}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = GetColor("Surface")}):Play()
    end)
    
    button.MouseButton1Click:Connect(onClick)
    
    return button
end

function NoirUI.Button.CreateToggle(parent, config)
    local isActive = config.Default or false
    
    local button = Create("TextButton", {
        Size = config.Size or UDim2.new(0, 100, 0, 32),
        Text = isActive and (config.ActiveText or "ON") or (config.InactiveText or "OFF"),
        TextSize = 12,
        TextColor3 = GetColor("Text"),
        Font = NoirUI.Config.FontBold,
        BackgroundColor3 = isActive and GetColor("Primary") or GetColor("Surface"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        AutoButtonColor = false,
    }, parent)
    
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(1, 0)
    }, button)
    
    local function SetActive(active)
        isActive = active
        button.Text = isActive and (config.ActiveText or "ON") or (config.InactiveText or "OFF")
        TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = isActive and GetColor("Primary") or GetColor("Surface")}):Play()
        if config.OnToggle then config.OnToggle(isActive) end
    end
    
    button.MouseButton1Click:Connect(function()
        SetActive(not isActive)
    end)
    
    return {
        Button = button,
        IsActive = function() return isActive end,
        SetActive = SetActive,
        Toggle = function() SetActive(not isActive) end,
    }
end

function NoirUI.Button.CreateRadioGroup(parent, options, defaultIndex, onSelect)
    local container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
    }, parent)
    
    local layout = NoirUI.CreateListLayout(container, "horizontal", 8)
    
    local buttons = {}
    local selectedIndex = defaultIndex or 1
    
    local function Select(index)
        if selectedIndex == index then return end
        for i, btn in ipairs(buttons) do
            if i == index then
                TweenService:Create(btn.Button, TweenInfo.new(0.15), {BackgroundColor3 = GetColor("Primary")}):Play()
                btn.Button.TextColor3 = Color3.new(1, 1, 1)
            else
                TweenService:Create(btn.Button, TweenInfo.new(0.15), {BackgroundColor3 = GetColor("Surface")}):Play()
                btn.Button.TextColor3 = GetColor("Text")
            end
        end
        selectedIndex = index
        if onSelect then onSelect(index, options[index]) end
    end
    
    for i, opt in ipairs(options) do
        local btn = NoirUI.Button.Create(container, {
            Text = opt,
            Size = UDim2.new(0, 80, 0, 32),
            BackgroundColor = i == selectedIndex and GetColor("Primary") or GetColor("Surface"),
            TextColor = i == selectedIndex and Color3.new(1, 1, 1) or GetColor("Text"),
            OnClick = function() Select(i) end,
        })
        table.insert(buttons, {Button = btn, Text = opt})
    end
    
    return {
        Container = container,
        Buttons = buttons,
        SelectedIndex = function() return selectedIndex end,
        Select = Select,
    }
end

function NoirUI.Button.CreateDropdownButton(parent, text, menuItems, onSelect)
    local button = NoirUI.Button.Create(parent, {
        Text = text,
        Size = UDim2.new(0, 150, 0, 36),
        BackgroundColor = GetColor("Surface"),
        TextColor = GetColor("Text"),
    })
    
    local arrow = NoirUI.CreateIcon(button, "rbxassetid://10734867672", 14, GetColor("TextSecondary"))
    arrow.Position = UDim2.new(1, -24, 0.5, -7)
    
    local menuFrame = Create("Frame", {
        Size = UDim2.new(0, 150, 0, 0),
        Position = UDim2.new(0, 0, 1, 4),
        BackgroundColor3 = GetColor("Surface"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = false,
        ZIndex = 100,
    }, button)
    
    local menuCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 8)
    }, menuFrame)
    
    local menuStroke = NoirUI.CreateStroke(menuFrame, GetColor("Border"), 1, 0.3)
    
    local menuLayout = NoirUI.CreateListLayout(menuFrame, "vertical", 0)
    
    local isOpen = false
    
    local function CloseMenu()
        isOpen = false
        TweenService:Create(menuFrame, TweenInfo.new(0.15), {Size = UDim2.new(0, 150, 0, 0)}):Play()
        task.delay(0.15, function()
            if not isOpen then menuFrame.Visible = false end
        end)
    end
    
    local function OpenMenu()
        isOpen = true
        menuFrame.Visible = true
        local totalHeight = #menuItems * 36
        TweenService:Create(menuFrame, TweenInfo.new(0.15), {Size = UDim2.new(0, 150, 0, totalHeight)}):Play()
    end
    
    for _, item in ipairs(menuItems) do
        local itemBtn = NoirUI.Button.Create(menuFrame, {
            Text = item,
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor = GetColor("Surface"),
            BackgroundTransparency = 0,
            TextColor = GetColor("Text"),
            HoverColor = GetColor("SurfaceHover"),
            OnClick = function()
                button.Text = item
                if onSelect then onSelect(item) end
                CloseMenu()
            end,
        })
        itemBtn.BackgroundTransparency = 0
    end
    
    button.MouseButton1Click:Connect(function()
        if isOpen then CloseMenu() else OpenMenu() end
    end)
    
    UserInputService.InputBegan:Connect(function(input)
        if isOpen and input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            local btnPos = button.AbsolutePosition
            local btnSize = button.AbsoluteSize
            local menuPos = menuFrame.AbsolutePosition
            local menuSize = menuFrame.AbsoluteSize
            
            if mousePos.X < btnPos.X or mousePos.X > btnPos.X + btnSize.X or
               mousePos.Y < btnPos.Y or mousePos.Y > btnPos.Y + btnSize.Y then
                if mousePos.X < menuPos.X or mousePos.X > menuPos.X + menuSize.X or
                   mousePos.Y < menuPos.Y or mousePos.Y > menuPos.Y + menuSize.Y then
                    CloseMenu()
                end
            end
        end
    end)
    
    return {
        Button = button,
        Menu = menuFrame,
        IsOpen = function() return isOpen end,
        Open = OpenMenu,
        Close = CloseMenu,
        SetText = function(newText) button.Text = newText end,
    }
end

NoirUI.Input = {}

function NoirUI.Input.Create(parent, config)
    config = config or {}
    
    local container = Create("Frame", {
        Size = config.Size or UDim2.new(0, 200, 0, 36),
        Position = config.Position or UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = GetColor("Surface"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        LayoutOrder = config.LayoutOrder or 0,
    }, parent)
    
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, 8)
    }, container)
    
    local stroke = NoirUI.CreateStroke(container, GetColor("Border"), 1, 0.3)
    
    local padding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
    }, container)
    
    local input = Create("TextBox", {
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Default or "",
        TextColor3 = GetColor("Text"),
        TextSize = config.TextSize or 14,
        Font = config.Font or NoirUI.Config.Font,
        PlaceholderText = config.Placeholder or "",
        PlaceholderColor3 = GetColor("TextDisabled"),
        ClearTextOnFocus = config.ClearOnFocus or false,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, container)
    
    local label = nil
    if config.Label then
        label = NoirUI.CreateText(parent, config.Label, 12, GetColor("TextSecondary"), 0, NoirUI.Config.Font, UDim2.new(0, 0, -1, -4), UDim2.new(0, 100, 0, 16))
        label.TextXAlignment = Enum.TextXAlignment.Left
    end
    
    local function GetText()
        return input.Text
    end
    
    local function SetText(newText)
        input.Text = newText
        if config.OnChange then
            config.OnChange(newText)
        end
    end
    
    input:GetPropertyChangedSignal("Text"):Connect(function()
        if config.OnChange then
            config.OnChange(input.Text)
        end
    end)
    
    input.Focused:Connect(function()
        if config.OnFocus then config.OnFocus() end
        TweenService:Create(container, TweenInfo.new(0.15), {BackgroundColor3 = GetColor("SurfaceHover")}):Play()
    end)
    
    input.FocusLost:Connect(function()
        if config.OnBlur then config.OnBlur(input.Text) end
        TweenService:Create(container, TweenInfo.new(0.15), {BackgroundColor3 = GetColor("Surface")}):Play()
    end)
    
    return {
        Container = container,
        Input = input,
        Label = label,
        GetText = GetText,
        SetText = SetText,
        Clear = function() SetText("") end,
        Focus = function() input:CaptureFocus() end,
    }
end

function NoirUI.Input.CreatePassword(parent, config)
    config = config or {}
    local inputObj = NoirUI.Input.Create(parent, config)
    inputObj.Input.Text = ""
    return inputObj
end

function NoirUI.Input.CreateNumber(parent, config)
    config = config or {}
    local min = config.Min or 0
    local max = config.Max or 100
    local step = config.Step or 1
    
    local container = Create("Frame", {
        Size = config.Size or UDim2.new(0, 150, 0, 36),
        Position = config.Position or UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = GetColor("Surface"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        LayoutOrder = config.LayoutOrder or 0,
    }, parent)
    
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, 8)
    }, container)
    
    local stroke = NoirUI.CreateStroke(container, GetColor("Border"), 1, 0.3)
    
    local input = Create("TextBox", {
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(config.Default or min),
        TextColor3 = GetColor("Text"),
        TextSize = 14,
        Font = NoirUI.Config.Font,
        PlaceholderText = tostring(min),
        PlaceholderColor3 = GetColor("TextDisabled"),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, container)
    
    local decBtn = Create("TextButton", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -60, 0.5, -14),
        Text = "-",
        TextSize = 18,
        TextColor3 = GetColor("Text"),
        BackgroundColor3 = GetColor("SurfaceHover"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        AutoButtonColor = false,
    }, container)
    
    local decCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 6)
    }, decBtn)
    
    local incBtn = Create("TextButton", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -28, 0.5, -14),
        Text = "+",
        TextSize = 18,
        TextColor3 = GetColor("Text"),
        BackgroundColor3 = GetColor("SurfaceHover"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        AutoButtonColor = false,
    }, container)
    
    local incCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 6)
    }, incBtn)
    
    local currentValue = tonumber(input.Text) or min
    
    local function UpdateValue(newValue)
        newValue = NoirUI.Clamp(newValue, min, max)
        newValue = math.floor(newValue / step + 0.5) * step
        if newValue ~= currentValue then
            currentValue = newValue
            input.Text = tostring(currentValue)
            if config.OnChange then
                config.OnChange(currentValue)
            end
        end
    end
    
    decBtn.MouseButton1Click:Connect(function()
        UpdateValue(currentValue - step)
    end)
    
    incBtn.MouseButton1Click:Connect(function()
        UpdateValue(currentValue + step)
    end)
    
    input.FocusLost:Connect(function()
        local val = tonumber(input.Text)
        if val then
            UpdateValue(val)
        else
            input.Text = tostring(currentValue)
        end
    end)
    
    return {
        Container = container,
        Input = input,
        GetValue = function() return currentValue end,
        SetValue = UpdateValue,
        Increment = function() UpdateValue(currentValue + step) end,
        Decrement = function() UpdateValue(currentValue - step) end,
    }
end

function NoirUI.Input.CreateTextArea(parent, config)
    config = config or {}
    
    local container = Create("Frame", {
        Size = config.Size or UDim2.new(0, 300, 0, 100),
        Position = config.Position or UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = GetColor("Surface"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        LayoutOrder = config.LayoutOrder or 0,
    }, parent)
    
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, 8)
    }, container)
    
    local stroke = NoirUI.CreateStroke(container, GetColor("Border"), 1, 0.3)
    
    local input = Create("TextBox", {
        Size = UDim2.new(1, -24, 1, -24),
        Position = UDim2.new(0, 12, 0, 12),
        BackgroundTransparency = 1,
        Text = config.Default or "",
        TextColor3 = GetColor("Text"),
        TextSize = 14,
        Font = NoirUI.Config.Font,
        PlaceholderText = config.Placeholder or "",
        PlaceholderColor3 = GetColor("TextDisabled"),
        ClearTextOnFocus = config.ClearOnFocus or false,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        MultiLine = true,
    }, container)
    
    local function GetText()
        return input.Text
    end
    
    local function SetText(newText)
        input.Text = newText
        if config.OnChange then
            config.OnChange(newText)
        end
    end
    
    input:GetPropertyChangedSignal("Text"):Connect(function()
        if config.OnChange then
            config.OnChange(input.Text)
        end
    end)
    
    return {
        Container = container,
        Input = input,
        GetText = GetText,
        SetText = SetText,
        Clear = function() SetText("") end,
    }
end

function NoirUI.Input.CreateSearch(parent, config)
    config = config or {}
    config.Placeholder = config.Placeholder or "搜索..."
    
    local container = Create("Frame", {
        Size = config.Size or UDim2.new(0, 250, 0, 36),
        Position = config.Position or UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = GetColor("Surface"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        LayoutOrder = config.LayoutOrder or 0,
    }, parent)
    
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, 8)
    }, container)
    
    local stroke = NoirUI.CreateStroke(container, GetColor("Border"), 1, 0.3)
    
    local searchIcon = NoirUI.CreateIcon(container, "rbxassetid://10734867710", 16, GetColor("TextSecondary"))
    searchIcon.Position = UDim2.new(0, 12, 0.5, -8)
    
    local input = Create("TextBox", {
        Size = UDim2.new(1, -44, 1, 0),
        Position = UDim2.new(0, 36, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Default or "",
        TextColor3 = GetColor("Text"),
        TextSize = 14,
        Font = NoirUI.Config.Font,
        PlaceholderText = config.Placeholder,
        PlaceholderColor3 = GetColor("TextDisabled"),
        ClearTextOnFocus = config.ClearOnFocus or false,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, container)
    
    local clearBtn = Create("TextButton", {
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -32, 0.5, -12),
        Text = "×",
        TextSize = 18,
        TextColor3 = GetColor("TextSecondary"),
        BackgroundTransparency = 1,
        Visible = false,
    }, container)
    
    clearBtn.MouseButton1Click:Connect(function()
        input.Text = ""
        clearBtn.Visible = false
        if config.OnChange then config.OnChange("") end
    end)
    
    input:GetPropertyChangedSignal("Text"):Connect(function()
        clearBtn.Visible = input.Text ~= ""
        if config.OnChange then config.OnChange(input.Text) end
    end)
    
    local function GetText()
        return input.Text
    end
    
    local function SetText(newText)
        input.Text = newText
    end
    
    return {
        Container = container,
        Input = input,
        GetText = GetText,
        SetText = SetText,
        Clear = function() SetText("") end,
    }
end

function NoirUI.Input.CreateSliderInput(parent, config)
    config = config or {}
    local min = config.Min or 0
    local max = config.Max or 100
    local defaultValue = config.Default or min
    
    local container = Create("Frame", {
        Size = config.Size or UDim2.new(0, 300, 0, 60),
        BackgroundTransparency = 1,
        LayoutOrder = config.LayoutOrder or 0,
    }, parent)
    
    local label = NoirUI.CreateText(container, config.Label or "数值", 14, GetColor("Text"), 0, NoirUI.Config.Font, UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 20))
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local inputFrame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        Position = UDim2.new(0, 0, 0, 24),
        BackgroundColor3 = GetColor("Surface"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
    }, container)
    
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, 8)
    }, inputFrame)
    
    local numberInput = NoirUI.Input.CreateNumber(inputFrame, {
        Size = UDim2.new(0, 80, 1, 0),
        Position = UDim2.new(1, -90, 0, 0),
        Min = min,
        Max = max,
        Step = config.Step or 1,
        Default = defaultValue,
        OnChange = function(val)
            sliderBar.SetProgress((val - min) / (max - min))
            if config.OnChange then config.OnChange(val) end
        end,
    })
    
    local sliderBar = NoirUI.Loading.CreateProgressBar(inputFrame, 180, 4, GetColor("Primary"))
    sliderBar.Container.Position = UDim2.new(0, 12, 0.5, -2)
    sliderBar.SetProgress((defaultValue - min) / (max - min))
    
    return {
        Container = container,
        NumberInput = numberInput,
        Slider = sliderBar,
        GetValue = numberInput.GetValue,
        SetValue = numberInput.SetValue,
    }
end

NoirUI.Toggle = {}

function NoirUI.Toggle.Create(parent, config)
    config = config or {}
    
    local container = Create("Frame", {
        Size = config.Size or UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        LayoutOrder = config.LayoutOrder or 0,
    }, parent)
    
    local label = nil
    if config.Label then
        label = NoirUI.CreateText(container, config.Label, 14, GetColor("Text"), 0, NoirUI.Config.Font, UDim2.new(0, 0, 0, 10), UDim2.new(0, 200, 0, 20))
        label.TextXAlignment = Enum.TextXAlignment.Left
    end
    
    local toggleBg = Create("Frame", {
        Size = UDim2.new(0, 44, 0, 24),
        Position = UDim2.new(1, -44, 0.5, -12),
        BackgroundColor3 = config.Default and GetColor("Primary") or GetColor("SurfaceHover"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
    }, container)
    
    local bgCorner = Create("UICorner", {
        CornerRadius = UDim.new(1, 0)
    }, toggleBg)
    
    local toggleKnob = Create("Frame", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = config.Default and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
    }, toggleBg)
    
    local knobCorner = Create("UICorner", {
        CornerRadius = UDim.new(1, 0)
    }, toggleKnob)
    
    local isOn = config.Default or false
    
    local function SetState(on, animate)
        isOn = on
        local targetBgColor = isOn and GetColor("Primary") or GetColor("SurfaceHover")
        local targetKnobPos = isOn and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        
        if animate then
            TweenService:Create(toggleBg, TweenInfo.new(0.2), {BackgroundColor3 = targetBgColor}):Play()
            TweenService:Create(toggleKnob, TweenInfo.new(0.2), {Position = targetKnobPos}):Play()
        else
            toggleBg.BackgroundColor3 = targetBgColor
            toggleKnob.Position = targetKnobPos
        end
        
        if config.OnChange then
            config.OnChange(isOn)
        end
    end
    
    local button = Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
    }, container)
    
    button.MouseButton1Click:Connect(function()
        SetState(not isOn, true)
    end)
    
    if config.Default then
        SetState(config.Default, false)
    end
    
    return {
        Container = container,
        ToggleBg = toggleBg,
        ToggleKnob = toggleKnob,
        IsOn = function() return isOn end,
        SetOn = function(state) SetState(state, true) end,
        Toggle = function() SetState(not isOn, true) end,
    }
end

NoirUI.Switch = NoirUI.Toggle

NoirUI.Checkbox = {}

function NoirUI.Checkbox.Create(parent, config)
    config = config or {}
    
    local container = Create("Frame", {
        Size = config.Size or UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        LayoutOrder = config.LayoutOrder or 0,
    }, parent)
    
    local box = Create("Frame", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 0, 0.5, -10),
        BackgroundColor3 = config.Checked and GetColor("Primary") or GetColor("Surface"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
    }, container)
    
    local boxCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 4)
    }, box)
    
    local checkIcon = Create("ImageLabel", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0.5, -7, 0.5, -7),
        BackgroundTransparency = 1,
        Image = "rbxassetid://10734867678",
        ImageColor3 = Color3.new(1, 1, 1),
        ImageTransparency = config.Checked and 0 or 1,
        Visible = config.Checked,
    }, box)
    
    local label = nil
    if config.Label then
        label = NoirUI.CreateText(container, config.Label, 14, GetColor("Text"), 0, NoirUI.Config.Font, UDim2.new(0, 28, 0, 6), UDim2.new(0, 200, 0, 20))
        label.TextXAlignment = Enum.TextXAlignment.Left
    end
    
    local isChecked = config.Checked or false
    
    local function SetState(checked, animate)
        isChecked = checked
        local targetColor = isChecked and GetColor("Primary") or GetColor("Surface")
        
        if animate then
            TweenService:Create(box, TweenInfo.new(0.15), {BackgroundColor3 = targetColor}):Play()
            TweenService:Create(checkIcon, TweenInfo.new(0.15), {ImageTransparency = isChecked and 0 or 1}):Play()
        else
            box.BackgroundColor3 = targetColor
            checkIcon.ImageTransparency = isChecked and 0 or 1
        end
        checkIcon.Visible = isChecked
        
        if config.OnChange then
            config.OnChange(isChecked)
        end
    end
    
    local button = Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
    }, container)
    
    button.MouseButton1Click:Connect(function()
        SetState(not isChecked, true)
    end)
    
    if config.Checked then
        SetState(config.Checked, false)
    end
    
    return {
        Container = container,
        Box = box,
        IsChecked = function() return isChecked end,
        SetChecked = function(state) SetState(state, true) end,
        Toggle = function() SetState(not isChecked, true) end,
    }
end

NoirUI.Radio = {}

function NoirUI.Radio.CreateGroup(parent, options, defaultIndex, onSelect)
    local container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, #options * 32),
        BackgroundTransparency = 1,
    }, parent)
    
    local radios = {}
    local selectedIndex = defaultIndex or 1
    
    for i, opt in ipairs(options) do
        local radioContainer = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundTransparency = 1,
            LayoutOrder = i,
        }, container)
        
        local outerCircle = Create("Frame", {
            Size = UDim2.new(0, 18, 0, 18),
            Position = UDim2.new(0, 0, 0.5, -9),
            BackgroundColor3 = GetColor("Surface"),
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
        }, radioContainer)
        
        local outerCorner = Create("UICorner", {
            CornerRadius = UDim.new(1, 0)
        }, outerCircle)
        
        local innerCircle = Create("Frame", {
            Size = UDim2.new(0, 10, 0, 10),
            Position = UDim2.new(0.5, -5, 0.5, -5),
            BackgroundColor3 = GetColor("Primary"),
            BackgroundTransparency = i == selectedIndex and 0 or 1,
            BorderSizePixel = 0,
        }, outerCircle)
        
        local innerCorner = Create("UICorner", {
            CornerRadius = UDim.new(1, 0)
        }, innerCircle)
        
        local label = NoirUI.CreateText(radioContainer, opt, 14, GetColor("Text"), 0, NoirUI.Config.Font, UDim2.new(0, 26, 0, 6), UDim2.new(0, 200, 0, 20))
        label.TextXAlignment = Enum.TextXAlignment.Left
        
        local button = Create("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "",
        }, radioContainer)
        
        button.MouseButton1Click:Connect(function()
            if selectedIndex == i then return end
            if radios[selectedIndex] then
                TweenService:Create(radios[selectedIndex].InnerCircle, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
            end
            selectedIndex = i
            TweenService:Create(innerCircle, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
            if onSelect then onSelect(i, opt) end
        end)
        
        radios[i] = {
            Container = radioContainer,
            OuterCircle = outerCircle,
            InnerCircle = innerCircle,
            Label = label,
            Value = opt,
        }
    end
    
    return {
        Container = container,
        Radios = radios,
        SelectedIndex = function() return selectedIndex end,
        SelectedValue = function() return options[selectedIndex] end,
        Select = function(index)
            if radios[index] then
                radios[index].Container.TextButton.MouseButton1Click:Fire()
            end
        end,
    }
end

NoirUI.Slider = {}

function NoirUI.Slider.Create(parent, config)
    config = config or {}
    local min = config.Min or 0
    local max = config.Max or 100
    local defaultValue = config.Default or min
    
    local container = Create("Frame", {
        Size = config.Size or UDim2.new(1, 0, 0, 60),
        BackgroundTransparency = 1,
        LayoutOrder = config.LayoutOrder or 0,
    }, parent)
    
    local label = nil
    if config.Label then
        label = NoirUI.CreateText(container, config.Label, 14, GetColor("Text"), 0, NoirUI.Config.Font, UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 20))
        label.TextXAlignment = Enum.TextXAlignment.Left
    end
    
    local valueLabel = NoirUI.CreateText(container, tostring(defaultValue), 14, GetColor("Primary"), 0, NoirUI.Config.FontBold, UDim2.new(1, -50, 0, 0), UDim2.new(0, 50, 0, 20))
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    local track = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 4),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundColor3 = GetColor("SurfaceHover"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
    }, container)
    
    local trackCorner = Create("UICorner", {
        CornerRadius = UDim.new(1, 0)
    }, track)
    
    local fill = Create("Frame", {
        Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = GetColor("Primary"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
    }, track)
    
    local fillCorner = Create("UICorner", {
        CornerRadius = UDim.new(1, 0)
    }, fill)
    
    local thumb = Create("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new((defaultValue - min) / (max - min), -8, 0.5, -8),
        BackgroundColor3 = GetColor("Primary"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
    }, track)
    
    local thumbCorner = Create("UICorner", {
        CornerRadius = UDim.new(1, 0)
    }, thumb)
    
    local isDragging = false
    local currentValue = defaultValue
    
    local function UpdateValue(value)
        currentValue = NoirUI.Clamp(value, min, max)
        local t = (currentValue - min) / (max - min)
        fill.Size = UDim2.new(t, 0, 1, 0)
        thumb.Position = UDim2.new(t, -8, 0.5, -8)
        valueLabel.Text = tostring(math.floor(currentValue))
        if config.OnChange then
            config.OnChange(currentValue)
        end
    end
    
    local function GetThumbPosition(inputPos)
        local trackPos = track.AbsolutePosition.X
        local trackWidth = track.AbsoluteSize.X
        local relativeX = NoirUI.Clamp(inputPos.X - trackPos, 0, trackWidth)
        local t = relativeX / trackWidth
        return min + t * (max - min)
    end
    
    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            TweenService:Create(thumb, TweenInfo.new(0.1), {Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(thumb.Position.X.Scale, -10, 0.5, -10)}):Play()
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local newValue = GetThumbPosition(input.Position)
            UpdateValue(newValue)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and isDragging then
            isDragging = false
            TweenService:Create(thumb, TweenInfo.new(0.1), {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(thumb.Position.X.Scale, -8, 0.5, -8)}):Play()
        end
    end)
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local newValue = GetThumbPosition(input.Position)
            UpdateValue(newValue)
        end
    end)
    
    UpdateValue(defaultValue)
    
    return {
        Container = container,
        Track = track,
        Fill = fill,
        Thumb = thumb,
        ValueLabel = valueLabel,
        GetValue = function() return currentValue end,
        SetValue = UpdateValue,
    }
end

NoirUI.Dropdown = {}

function NoirUI.Dropdown.Create(parent, config)
    config = config or {}
    
    local container = Create("Frame", {
        Size = config.Size or UDim2.new(0, 200, 0, 36),
        BackgroundTransparency = 1,
        LayoutOrder = config.LayoutOrder or 0,
    }, parent)
    
    local label = nil
    if config.Label then
        label = NoirUI.CreateText(container, config.Label, 12, GetColor("TextSecondary"), 0, NoirUI.Config.Font, UDim2.new(0, 0, -1, -4), UDim2.new(0, 200, 0, 16))
        label.TextXAlignment = Enum.TextXAlignment.Left
    end
    
    local button = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 36),
        Position = UDim2.new(0, 0, 1, -36),
        BackgroundColor3 = GetColor("Surface"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Text = config.Default or config.Options[1] or "",
        TextColor3 = GetColor("Text"),
        TextSize = 14,
        Font = NoirUI.Config.Font,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, container)
    
    local buttonCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 8)
    }, button)
    
    local buttonStroke = NoirUI.CreateStroke(button, GetColor("Border"), 1, 0.3)
    
    local arrow = NoirUI.CreateIcon(button, "rbxassetid://10734867672", 14, GetColor("TextSecondary"))
    arrow.Position = UDim2.new(1, -24, 0.5, -7)
    
    local padding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
    }, button)
    
    local dropdownFrame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 1, 4),
        BackgroundColor3 = GetColor("Surface"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = false,
        ZIndex = 100,
    }, container)
    
    local dropdownCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 8)
    }, dropdownFrame)
    
    local dropdownStroke = NoirUI.CreateStroke(dropdownFrame, GetColor("Border"), 1, 0.3)
    
    local dropdownLayout = NoirUI.CreateListLayout(dropdownFrame, "vertical", 0)
    
    local isOpen = false
    local selectedIndex = config.DefaultIndex or 1
    local selectedValue = config.Default or config.Options[1]
    
    local function CloseDropdown()
        isOpen = false
        TweenService:Create(dropdownFrame, TweenInfo.new(0.15), {Size = UDim2.new(1, 0, 0, 0)}):Play()
        task.delay(0.15, function()
            if not isOpen then dropdownFrame.Visible = false end
        end)
    end
    
    local function OpenDropdown()
        isOpen = true
        dropdownFrame.Visible = true
        local totalHeight = #config.Options * 36
        TweenService:Create(dropdownFrame, TweenInfo.new(0.15), {Size = UDim2.new(1, 0, 0, totalHeight)}):Play()
    end
    
    local function SelectItem(index, value)
        selectedIndex = index
        selectedValue = value
        button.Text = value
        if config.OnChange then
            config.OnChange(value, index)
        end
        CloseDropdown()
    end
    
    for i, opt in ipairs(config.Options) do
        local itemBtn = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = i == selectedIndex and GetColor("SurfaceHover") or GetColor("Surface"),
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Text = opt,
            TextColor3 = GetColor("Text"),
            TextSize = 14,
            Font = NoirUI.Config.Font,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, dropdownFrame)
        
        local itemPadding = Create("UIPadding", {
            PaddingLeft = UDim.new(0, 12),
        }, itemBtn)
        
        itemBtn.MouseEnter:Connect(function()
            TweenService:Create(itemBtn, TweenInfo.new(0.1), {BackgroundColor3 = GetColor("SurfaceHover")}):Play()
        end)
        
        itemBtn.MouseLeave:Connect(function()
            if i ~= selectedIndex then
                TweenService:Create(itemBtn, TweenInfo.new(0.1), {BackgroundColor3 = GetColor("Surface")}):Play()
            end
        end)
        
        itemBtn.MouseButton1Click:Connect(function()
            SelectItem(i, opt)
        end)
        
        if i == selectedIndex then
            itemBtn.BackgroundColor3 = GetColor("SurfaceHover")
            local checkIcon = NoirUI.CreateIcon(itemBtn, "rbxassetid://10734867678", 14, GetColor("Primary"))
            checkIcon.Position = UDim2.new(1, -24, 0.5, -7)
        end
    end
    
    button.MouseButton1Click:Connect(function()
        if isOpen then CloseDropdown() else OpenDropdown() end
    end)
    
    UserInputService.InputBegan:Connect(function(input)
        if isOpen and input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            local btnPos = button.AbsolutePosition
            local btnSize = button.AbsoluteSize
            local dropPos = dropdownFrame.AbsolutePosition
            local dropSize = dropdownFrame.AbsoluteSize
            
            if mousePos.X < btnPos.X or mousePos.X > btnPos.X + btnSize.X or
               mousePos.Y < btnPos.Y or mousePos.Y > btnPos.Y + btnSize.Y then
                if mousePos.X < dropPos.X or mousePos.X > dropPos.X + dropSize.X or
                   mousePos.Y < dropPos.Y or mousePos.Y > dropPos.Y + dropSize.Y then
                    CloseDropdown()
                end
            end
        end
    end)
    
    return {
        Container = container,
        Button = button,
        DropdownFrame = dropdownFrame,
        SelectedIndex = function() return selectedIndex end,
        SelectedValue = function() return selectedValue end,
        Select = SelectItem,
        Open = OpenDropdown,
        Close = CloseDropdown,
        IsOpen = function() return isOpen end,
    }
end

NoirUI.Select = NoirUI.Dropdown

NoirUI.Tabs = {}

function NoirUI.Tabs.Create(parent, config)
    config = config or {}
    
    local container = Create("Frame", {
        Size = config.Size or UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
    }, parent)
    
    local tabBar = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundTransparency = 1,
    }, container)
    
    local tabLayout = NoirUI.CreateListLayout(tabBar, "horizontal", 4)
    
    local contentArea = Create("Frame", {
        Size = UDim2.new(1, 0, 1, -44),
        Position = UDim2.new(0, 0, 0, 44),
        BackgroundTransparency = 1,
    }, container)
    
    local tabs = {}
    local contents = {}
    local selectedTab = config.DefaultIndex or 1
    
    local function SelectTab(index)
        if selectedTab == index then return end
        if contents[selectedTab] then
            contents[selectedTab].Visible = false
        end
        if tabs[selectedTab] and tabs[selectedTab].Indicator then
            TweenService:Create(tabs[selectedTab].Indicator, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        end
        selectedTab = index
        if contents[selectedTab] then
            contents[selectedTab].Visible = true
        end
        if tabs[selectedTab] and tabs[selectedTab].Indicator then
            TweenService:Create(tabs[selectedTab].Indicator, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
        end
        if config.OnChange then
            config.OnChange(selectedTab, config.Tabs[selectedTab])
        end
    end
    
    for i, tabData in ipairs(config.Tabs) do
        local tabButton = Create("TextButton", {
            Size = UDim2.new(0, tabData.Width or 100, 0, 36),
            BackgroundColor3 = GetColor("Surface"),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = tabData.Title or "",
            TextColor3 = GetColor("Text"),
            TextSize = 14,
            Font = NoirUI.Config.Font,
            AutoButtonColor = false,
        }, tabBar)
        
        local indicator = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 2),
            Position = UDim2.new(0, 0, 1, -2),
            BackgroundColor3 = GetColor("Primary"),
            BackgroundTransparency = i == selectedTab and 0 or 1,
            BorderSizePixel = 0,
        }, tabButton)
        
        if tabData.Icon then
            local icon = NoirUI.CreateIcon(tabButton, tabData.Icon, 16, GetColor("TextSecondary"))
            icon.Position = UDim2.new(0, 12, 0.5, -8)
            tabButton.Text = "  " .. tabData.Title
        end
        
        tabButton.MouseButton1Click:Connect(function()
            SelectTab(i)
        end)
        
        tabButton.MouseEnter:Connect(function()
            if selectedTab ~= i then
                TweenService:Create(indicator, TweenInfo.new(0.15), {BackgroundTransparency = 0.5}):Play()
                TweenService:Create(tabButton, TweenInfo.new(0.15), {BackgroundColor3 = GetColor("SurfaceHover")}):Play()
            end
        end)
        
        tabButton.MouseLeave:Connect(function()
            if selectedTab ~= i then
                TweenService:Create(indicator, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
                TweenService:Create(tabButton, TweenInfo.new(0.15), {BackgroundColor3 = GetColor("Surface")}):Play()
            end
        end)
        
        local content = Create("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = i == selectedTab,
        }, contentArea)
        
        tabs[i] = {Button = tabButton, Indicator = indicator, Data = tabData}
        contents[i] = content
    end
    
    return {
        Container = container,
        TabBar = tabBar,
        ContentArea = contentArea,
        Tabs = tabs,
        Contents = contents,
        SelectedTab = selectedTab,
        SelectTab = SelectTab,
        GetCurrentContent = function() return contents[selectedTab] end,
    }
end

NoirUI.Menu = {}

function NoirUI.Menu.Create(parent, config)
    config = config or {}
    
    local container = Create("Frame", {
        Size = config.Size or UDim2.new(0, 200, 0, 0),
        Position = config.Position or UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = GetColor("Surface"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = false,
        ZIndex = 200,
    }, parent)
    
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, 8)
    }, container)
    
    local stroke = NoirUI.CreateStroke(container, GetColor("Border"), 1, 0.3)
    
    local layout = NoirUI.CreateListLayout(container, "vertical", 0)
    
    local items = {}
    local isOpen = false
    
    local function AddItem(itemConfig)
        local itemBtn = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = GetColor("Surface"),
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Text = itemConfig.Text or "",
            TextColor3 = itemConfig.Danger and GetColor("Danger") or GetColor("Text"),
            TextSize = 14,
            Font = NoirUI.Config.Font,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, container)
        
        local itemPadding = Create("UIPadding", {
            PaddingLeft = UDim.new(0, 12),
        }, itemBtn)
        
        if itemConfig.Icon then
            local icon = NoirUI.CreateIcon(itemBtn, itemConfig.Icon, 14, itemConfig.Danger and GetColor("Danger") or GetColor("TextSecondary"))
            icon.Position = UDim2.new(1, -28, 0.5, -7)
        end
        
        if itemConfig.Divider then
            local divider = NoirUI.CreateDivider(container, 1, GetColor("Border"), 1)
            divider.Size = UDim2.new(0.9, 0, 0, 1)
            divider.Position = UDim2.new(0.05, 0, 0, 0)
        end
        
        itemBtn.MouseEnter:Connect(function()
            TweenService:Create(itemBtn, TweenInfo.new(0.1), {BackgroundColor3 = GetColor("SurfaceHover")}):Play()
        end)
        
        itemBtn.MouseLeave:Connect(function()
            TweenService:Create(itemBtn, TweenInfo.new(0.1), {BackgroundColor3 = GetColor("Surface")}):Play()
        end)
        
        itemBtn.MouseButton1Click:Connect(function()
            if itemConfig.OnClick then
                itemConfig.OnClick()
            end
            CloseMenu()
        end)
        
        table.insert(items, itemBtn)
        return itemBtn
    end
    
    local function OpenMenu(x, y)
        isOpen = true
        container.Visible = true
        local totalHeight = #items * 36
        container.Position = UDim2.new(0, x or 0, 0, y or 0)
        TweenService:Create(container, TweenInfo.new(0.12), {Size = UDim2.new(0, 200, 0, totalHeight)}):Play()
    end
    
    local function CloseMenu()
        isOpen = false
        TweenService:Create(container, TweenInfo.new(0.12), {Size = UDim2.new(0, 200, 0, 0)}):Play()
        task.delay(0.12, function()
            if not isOpen then container.Visible = false end
        end)
    end
    
    for _, item in ipairs(config.Items or {}) do
        AddItem(item)
    end
    
    return {
        Container = container,
        Items = items,
        AddItem = AddItem,
        Open = OpenMenu,
        Close = CloseMenu,
        IsOpen = function() return isOpen end,
    }
end

NoirUI.Notification = {}
NoirUI.Notifications = {}
NoirUI.NotificationQueue = {}

function NoirUI.Notification.Create(config)
    config = config or {}
    
    if not NoirUI.NotificationContainer then
        NoirUI.NotificationContainer = Create("Frame", {
            Size = UDim2.new(0, 320, 1, 0),
            Position = UDim2.new(1, -340, 0, 0),
            BackgroundTransparency = 1,
            ZIndex = 1000,
        }, LP.PlayerGui)
        
        local padding = Create("UIPadding", {
            PaddingTop = UDim.new(0, 16),
            PaddingBottom = UDim.new(0, 16),
        }, NoirUI.NotificationContainer)
        
        local layout = NoirUI.CreateListLayout(NoirUI.NotificationContainer, "vertical", 12, "center", "bottom")
    end
    
    local notification = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = GetColor("Surface"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 1001,
    }, NoirUI.NotificationContainer)
    
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, 12)
    }, notification)
    
    local stroke = NoirUI.CreateStroke(notification, GetColor("Border"), 1, 0.3)
    
    local content = Create("Frame", {
        Size = UDim2.new(1, -32, 0, 0),
        Position = UDim2.new(0, 16, 0, 12),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
    }, notification)
    
    local iconType = config.Type or "info"
    local iconColor = iconType == "success" and GetColor("Success") 
        or iconType == "error" and GetColor("Danger") 
        or iconType == "warning" and GetColor("Warning") 
        or GetColor("Primary")
    
    local iconId = iconType == "success" and "rbxassetid://10734867678" 
        or iconType == "error" and "rbxassetid://10734867702" 
        or iconType == "warning" and "rbxassetid://10734867710" 
        or "rbxassetid://10734867714"
    
    local icon = NoirUI.CreateIcon(content, iconId, 20, iconColor)
    icon.Position = UDim2.new(0, 0, 0, 0)
    icon.Size = UDim2.new(0, 20, 0, 20)
    
    local textContainer = Create("Frame", {
        Size = UDim2.new(1, -32, 0, 0),
        Position = UDim2.new(0, 28, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
    }, content)
    
    local title = NoirUI.CreateText(textContainer, config.Title or "通知", 14, GetColor("Text"), 0, NoirUI.Config.FontBold, UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 18))
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local message = NoirUI.CreateText(textContainer, config.Message or "", 13, GetColor("TextSecondary"), 0, NoirUI.Config.Font, UDim2.new(0, 0, 0, 18), UDim2.new(1, 0, 0, 0))
    message.TextXAlignment = Enum.TextXAlignment.Left
    message.TextWrapped = true
    message.AutomaticSize = Enum.AutomaticSize.Y
    
    local closeBtn = Create("TextButton", {
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -28, 0, 4),
        BackgroundTransparency = 1,
        Text = "×",
        TextColor3 = GetColor("TextSecondary"),
        TextSize = 18,
    }, notification)
    
    closeBtn.MouseButton1Click:Connect(function()
        CloseNotification(notification)
    end)
    
    local duration = config.Duration or 5
    
    local function CloseNotification(notif)
        TweenService:Create(notif, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
        TweenService:Create(notif, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(1, 0, 0, 0)}):Play()
        task.delay(0.25, function()
            notif:Destroy()
        end)
    end
    
    notification.Size = UDim2.new(1, 0, 0, content.AbsoluteSize.Y + 24)
    notification.BackgroundTransparency = 0
    
    local startY = notification.Position.Y.Offset
    TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, startY)}):Play()
    
    if duration > 0 then
        task.delay(duration, function()
            if notification.Parent then
                CloseNotification(notification)
            end
        end)
    end
    
    return notification
end

function NoirUI.Notification.Show(config)
    return NoirUI.Notification.Create(config)
end

function NoirUI.Notification.Success(title, message, duration)
    return NoirUI.Notification.Create({Type = "success", Title = title, Message = message, Duration = duration or 3})
end

function NoirUI.Notification.Error(title, message, duration)
    return NoirUI.Notification.Create({Type = "error", Title = title, Message = message, Duration = duration or 4})
end

function NoirUI.Notification.Warning(title, message, duration)
    return NoirUI.Notification.Create({Type = "warning", Title = title, Message = message, Duration = duration or 4})
end

function NoirUI.Notification.Info(title, message, duration)
    return NoirUI.Notification.Create({Type = "info", Title = title, Message = message, Duration = duration or 3})
end

NoirUI.Dialog = {}

function NoirUI.Dialog.Create(config)
    config = config or {}
    
    local overlay = Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.6,
        ZIndex = 2000,
    }, LP.PlayerGui)
    
    local dialog = Create("Frame", {
        Size = config.Size or UDim2.new(0, 400, 0, 220),
        Position = UDim2.new(0.5, -200, 0.5, -110),
        BackgroundColor3 = GetColor("Surface"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 2001,
    }, overlay)
    
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, 16)
    }, dialog)
    
    local stroke = NoirUI.CreateStroke(dialog, GetColor("Border"), 1, 0.3)
    
    local titleBar = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = GetColor("Primary"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
    }, dialog)
    
    local titleCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 16)
    }, titleBar)
    
    local titleClip = Create("UICorner", {
        CornerRadius = UDim.new(0, 16)
    }, titleBar)
    
    local titleText = NoirUI.CreateText(titleBar, config.Title or "对话框", 16, Color3.new(1, 1, 1), 0, NoirUI.Config.FontBold, UDim2.new(0, 16, 0, 14), UDim2.new(0, 300, 0, 20))
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    
    local closeBtn = Create("TextButton", {
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -36, 0.5, -16),
        BackgroundTransparency = 1,
        Text = "×",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 20,
    }, titleBar)
    
    closeBtn.MouseButton1Click:Connect(function()
        overlay:Destroy()
        if config.OnClose then config.OnClose() end
    end)
    
    local content = Create("Frame", {
        Size = UDim2.new(1, -32, 0, 0),
        Position = UDim2.new(0, 16, 0, 64),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
    }, dialog)
    
    local message = NoirUI.CreateText(content, config.Message or "", 14, GetColor("Text"), 0, NoirUI.Config.Font, UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 0))
    message.TextXAlignment = Enum.TextXAlignment.Left
    message.TextWrapped = true
    message.AutomaticSize = Enum.AutomaticSize.Y
    
    local buttonArea = Create("Frame", {
        Size = UDim2.new(1, -32, 0, 40),
        Position = UDim2.new(0, 16, 1, -56),
        BackgroundTransparency = 1,
    }, dialog)
    
    local buttonLayout = NoirUI.CreateListLayout(buttonArea, "horizontal", 12, "right")
    
    local dialogObj = {
        Overlay = overlay,
        Dialog = dialog,
        Content = content,
        ButtonArea = buttonArea,
        
        Close = function()
            overlay:Destroy()
            if config.OnClose then config.OnClose() end
        end,
        
        AddButton = function(text, callback, variant)
            local btn = NoirUI.Button.Create(buttonArea, {
                Text = text,
                Size = UDim2.new(0, 80, 0, 36),
                BackgroundColor = variant == "primary" and GetColor("Primary") or GetColor("Surface"),
                TextColor = variant == "primary" and Color3.new(1, 1, 1) or GetColor("Text"),
                HoverColor = variant == "primary" and GetColor("PrimaryHover") or GetColor("SurfaceHover"),
                OnClick = function()
                    if callback then callback(dialogObj) end
                    dialogObj:Close()
                end,
            })
            return btn
        end,
    }
    
    if config.Buttons then
        for _, btn in ipairs(config.Buttons) do
            dialogObj:AddButton(btn.Text, btn.Callback, btn.Variant)
        end
    else
        dialogObj:AddButton("确定", nil, "primary")
    end
    
    local totalHeight = 64 + message.AbsoluteSize.Y + 56
    dialog.Size = UDim2.new(0, config.Size and config.Size.X.Offset or 400, 0, totalHeight)
    dialog.Position = UDim2.new(0.5, -200, 0.5, -totalHeight / 2)
    
    return dialogObj
end

function NoirUI.Dialog.Confirm(title, message, onConfirm, onCancel)
    return NoirUI.Dialog.Create({
        Title = title or "确认",
        Message = message or "确定要继续吗？",
        Buttons = {
            {Text = "取消", Callback = onCancel, Variant = "secondary"},
            {Text = "确定", Callback = onConfirm, Variant = "primary"},
        },
    })
end

function NoirUI.Dialog.Alert(title, message, onClose)
    return NoirUI.Dialog.Create({
        Title = title or "提示",
        Message = message or "",
        Buttons = {
            {Text = "知道了", Callback = onClose, Variant = "primary"},
        },
    })
end

function NoirUI.Dialog.Prompt(title, message, defaultValue, onConfirm, onCancel)
    local dialog = NoirUI.Dialog.Create({
        Title = title or "输入",
        Message = message or "",
        Size = UDim2.new(0, 400, 0, 280),
        Buttons = {
            {Text = "取消", Variant = "secondary"},
            {Text = "确定", Variant = "primary"},
        },
    })
    
    local inputContainer = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        Position = UDim2.new(0, 0, 0, 80),
        BackgroundTransparency = 1,
    }, dialog.Dialog)
    
    local input = NoirUI.Input.Create(inputContainer, {
        Size = UDim2.new(1, 0, 0, 36),
        Default = defaultValue or "",
        Placeholder = "请输入...",
    })
    
    local oldButtons = dialog.ButtonArea:GetChildren()
    for _, btn in ipairs(oldButtons) do
        btn:Destroy()
    end
    
    dialog:AddButton("取消", function()
        if onCancel then onCancel(nil) end
        dialog:Close()
    end, "secondary")
    
    dialog:AddButton("确定", function()
        if onConfirm then onConfirm(input.GetText()) end
        dialog:Close()
    end, "primary")
    
    return dialog
end

NoirUI.Table = {}

function NoirUI.Table.Create(parent, config)
    config = config or {}
    
    local container = Create("Frame", {
        Size = config.Size or UDim2.new(1, 0, 0, 400),
        BackgroundColor3 = GetColor("Surface"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        LayoutOrder = config.LayoutOrder or 0,
    }, parent)
    
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, 8)
    }, container)
    
    local stroke = NoirUI.CreateStroke(container, GetColor("Border"), 1, 0.3)
    
    local header = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = GetColor("SurfaceHover"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
    }, container)
    
    local headerCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 8)
    }, header)
    
    local headerLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 0),
    }, header)
    
    local columns = {}
    local rows = {}
    local columnWidths = {}
    
    for i, col in ipairs(config.Columns or {}) do
        local width = col.Width or (1 / #config.Columns)
        columnWidths[i] = width
        
        local headerCell = Create("Frame", {
            Size = UDim2.new(width, 0, 1, 0),
            BackgroundTransparency = 1,
            LayoutOrder = i,
        }, header)
        
        local headerText = NoirUI.CreateText(headerCell, col.Title, 14, GetColor("Text"), 0, NoirUI.Config.FontBold, UDim2.new(0, 12, 0.5, -10), UDim2.new(1, -24, 0, 20))
        headerText.TextXAlignment = Enum.TextXAlignment.Left
        
        if col.Sortable then
            local sortIcon = NoirUI.CreateIcon(headerCell, "rbxassetid://10734867672", 12, GetColor("TextSecondary"))
            sortIcon.Position = UDim2.new(1, -20, 0.5, -6)
            
            local sortState = "none"
            headerCell.MouseButton1Click:Connect(function()
                if sortState == "none" or sortState == "desc" then
                    sortState = "asc"
                    sortIcon.Rotation = 0
                    if config.OnSort then config.OnSort(i, "asc") end
                else
                    sortState = "desc"
                    sortIcon.Rotation = 180
                    if config.OnSort then config.OnSort(i, "desc") end
                end
            end)
        end
        
        table.insert(columns, {Cell = headerCell, Text = headerText, Width = width})
    end
    
    local scrollFrame = Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageTransparency = 0.8,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
    }, container)
    
    local body = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
    }, scrollFrame)
    
    local bodyLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 0),
    }, body)
    
    local function AddRow(rowData)
        local rowIndex = #rows + 1
        local row = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = rowIndex % 2 == 0 and GetColor("Surface") or GetColor("SurfaceHover"),
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            LayoutOrder = rowIndex,
        }, body)
        
        local rowLayout = Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 0),
        }, row)
        
        local cells = {}
        
        for i, col in ipairs(config.Columns or {}) do
            local value = rowData[col.Key] or ""
            local width = columnWidths[i]
            
            local cell = Create("Frame", {
                Size = UDim2.new(width, 0, 1, 0),
                BackgroundTransparency = 1,
                LayoutOrder = i,
            }, row)
            
            local cellText = NoirUI.CreateText(cell, tostring(value), 13, GetColor("Text"), 0, NoirUI.Config.Font, UDim2.new(0, 12, 0.5, -10), UDim2.new(1, -24, 0, 20))
            cellText.TextXAlignment = Enum.TextXAlignment.Left
            cellText.TextTruncate = Enum.TextTruncate.AtEnd
            
            table.insert(cells, {Cell = cell, Text = cellText, Value = value})
        end
        
        local rowObj = {
            Frame = row,
            Cells = cells,
            Data = rowData,
            Index = rowIndex,
            
            Update = function(newData)
                for i, col in ipairs(config.Columns or {}) do
                    local newValue = newData[col.Key] or ""
                    cells[i].Text.Text = tostring(newValue)
                    cells[i].Value = newValue
                end
                rowData = newData
            end,
            
            SetColor = function(color)
                TweenService:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = color}):Play()
            end,
            
            Select = function()
                for _, r in ipairs(rows) do
                    TweenService:Create(r.Frame, TweenInfo.new(0.15), {BackgroundColor3 = r.Index % 2 == 0 and GetColor("Surface") or GetColor("SurfaceHover")}):Play()
                end
                TweenService:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = GetColor("Primary")}):Play()
                if config.OnRowSelect then config.OnRowSelect(rowObj) end
            end,
        }
        
        row.MouseButton1Click:Connect(function()
            rowObj:Select()
        end)
        
        table.insert(rows, rowObj)
        
        body.Size = UDim2.new(1, 0, 0, #rows * 36)
        
        return rowObj
    end
    
    local function ClearRows()
        for _, row in ipairs(rows) do
            row.Frame:Destroy()
        end
        rows = {}
        body.Size = UDim2.new(1, 0, 0, 0)
    end
    
    local function SetData(data)
        ClearRows()
        for _, rowData in ipairs(data) do
            AddRow(rowData)
        end
    end
    
    if config.Data then
        SetData(config.Data)
    end
    
    return {
        Container = container,
        Header = header,
        Body = body,
        Columns = columns,
        Rows = rows,
        AddRow = AddRow,
        ClearRows = ClearRows,
        SetData = SetData,
        GetSelectedRow = function()
            for _, row in ipairs(rows) do
                if row.Frame.BackgroundColor3 == GetColor("Primary") then
                    return row
                end
            end
            return nil
        end,
    }
end

NoirUI.List = {}

function NoirUI.List.Create(parent, config)
    config = config or {}
    
    local container = Create("Frame", {
        Size = config.Size or UDim2.new(1, 0, 0, 300),
        BackgroundColor3 = GetColor("Surface"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        LayoutOrder = config.LayoutOrder or 0,
    }, parent)
    
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, 8)
    }, container)
    
    local stroke = NoirUI.CreateStroke(container, GetColor("Border"), 1, 0.3)
    
    local scrollFrame = Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageTransparency = 0.8,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
    }, container)
    
    local listBody = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
    }, scrollFrame)
    
    local listLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 0),
    }, listBody)
    
    local items = {}
    
    local function AddItem(itemData)
        local itemIndex = #items + 1
        
        local item = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 44),
            BackgroundColor3 = GetColor("Surface"),
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Text = "",
            LayoutOrder = itemIndex,
            AutoButtonColor = false,
        }, listBody)
        
        local icon = nil
        if itemData.Icon then
            icon = NoirUI.CreateIcon(item, itemData.Icon, 20, GetColor("TextSecondary"))
            icon.Position = UDim2.new(0, 12, 0.5, -10)
        end
        
        local title = NoirUI.CreateText(item, itemData.Title or "", 14, GetColor("Text"), 0, NoirUI.Config.Font, UDim2.new(icon and 0 or 12, 0, 0.5, -10), UDim2.new(1, icon and -48 or -24, 0, 20))
        title.TextXAlignment = Enum.TextXAlignment.Left
        
        local subtitle = nil
        if itemData.Subtitle then
            title.Position = UDim2.new(icon and 0 or 12, 0, 0, 8)
            subtitle = NoirUI.CreateText(item, itemData.Subtitle, 12, GetColor("TextSecondary"), 0, NoirUI.Config.Font, UDim2.new(icon and 0 or 12, 0, 0, 26), UDim2.new(1, icon and -48 or -24, 0, 16))
            subtitle.TextXAlignment = Enum.TextXAlignment.Left
        end
        
        local badge = nil
        if itemData.Badge then
            badge = NoirUI.CreateRoundedFrame(item, UDim2.new(0, 40, 0, 20), UDim2.new(1, -52, 0.5, -10), GetColor("Primary"), 0, 10)
            local badgeText = NoirUI.CreateText(badge, itemData.Badge, 11, Color3.new(1, 1, 1), 0, NoirUI.Config.Font, UDim2.new(0.5, -20, 0.5, -8), UDim2.new(1, 0, 0, 16))
            badgeText.TextXAlignment = Enum.TextXAlignment.Center
        end
        
        local divider = Create("Frame", {
            Size = UDim2.new(0.9, 0, 0, 1),
            Position = UDim2.new(0.05, 0, 1, -1),
            BackgroundColor3 = GetColor("Border"),
            BackgroundTransparency = 0.5,
            BorderSizePixel = 0,
        }, item)
        
        item.MouseEnter:Connect(function()
            TweenService:Create(item, TweenInfo.new(0.1), {BackgroundColor3 = GetColor("SurfaceHover")}):Play()
        end)
        
        item.MouseLeave:Connect(function()
            TweenService:Create(item, TweenInfo.new(0.1), {BackgroundColor3 = GetColor("Surface")}):Play()
        end)
        
        item.MouseButton1Click:Connect(function()
            if config.OnSelect then config.OnSelect(itemData, itemIndex) end
        end)
        
        local itemObj = {
            Frame = item,
            Title = title,
            Subtitle = subtitle,
            Icon = icon,
            Badge = badge,
            Data = itemData,
            Index = itemIndex,
            
            Update = function(newData)
                title.Text = newData.Title or ""
                if subtitle then subtitle.Text = newData.Subtitle or "" end
                if badge and newData.Badge then badgeText.Text = newData.Badge end
                itemData = newData
            end,
            
            Remove = function()
                item:Destroy()
                table.remove(items, itemIndex)
                for i, it in ipairs(items) do
                    it.Frame.LayoutOrder = i
                end
            end,
        }
        
        table.insert(items, itemObj)
        listBody.Size = UDim2.new(1, 0, 0, #items * 44)
        
        return itemObj
    end
    
    local function ClearItems()
        for _, item in ipairs(items) do
            item.Frame:Destroy()
        end
        items = {}
        listBody.Size = UDim2.new(1, 0, 0, 0)
    end
    
    if config.Items then
        for _, itemData in ipairs(config.Items) do
            AddItem(itemData)
        end
    end
    
    return {
        Container = container,
        Items = items,
        AddItem = AddItem,
        ClearItems = ClearItems,
        GetItem = function(index) return items[index] end,
    }
end

NoirUI.Card = {}

function NoirUI.Card.Create(parent, config)
    config = config or {}
    
    local card = Create("Frame", {
        Size = config.Size or UDim2.new(1, 0, 0, 120),
        BackgroundColor3 = GetColor("Surface"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        LayoutOrder = config.LayoutOrder or 0,
    }, parent)
    
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, config.CornerRadius or 12)
    }, card)
    
    local stroke = NoirUI.CreateStroke(card, GetColor("Border"), 1, 0.3)
    
    local content = Create("Frame", {
        Size = UDim2.new(1, -24, 1, -16),
        Position = UDim2.new(0, 12, 0, 8),
        BackgroundTransparency = 1,
    }, card)
    
    if config.Image then
        local image = Create("ImageLabel", {
            Size = UDim2.new(0, config.ImageSize or 80, 1, 0),
            BackgroundColor3 = GetColor("SurfaceHover"),
            BackgroundTransparency = 0,
            Image = config.Image,
            ImageColor3 = GetColor("Text"),
            ScaleType = Enum.ScaleType.Crop,
        }, content)
        
        local imageCorner = Create("UICorner", {
            CornerRadius = UDim.new(0, 8)
        }, image)
        
        local textArea = Create("Frame", {
            Size = UDim2.new(1, -(config.ImageSize or 80) - 12, 1, 0),
            Position = UDim2.new(0, (config.ImageSize or 80) + 12, 0, 0),
            BackgroundTransparency = 1,
        }, content)
        
        local title = NoirUI.CreateText(textArea, config.Title or "", 16, GetColor("Text"), 0, NoirUI.Config.FontBold, UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 24))
        title.TextXAlignment = Enum.TextXAlignment.Left
        
        local description = NoirUI.CreateText(textArea, config.Description or "", 13, GetColor("TextSecondary"), 0, NoirUI.Config.Font, UDim2.new(0, 0, 0, 28), UDim2.new(1, 0, 1, -28))
        description.TextXAlignment = Enum.TextXAlignment.Left
        description.TextWrapped = true
        description.TextYAlignment = Enum.TextYAlignment.Top
    else
        local title = NoirUI.CreateText(content, config.Title or "", 16, GetColor("Text"), 0, NoirUI.Config.FontBold, UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 24))
        title.TextXAlignment = Enum.TextXAlignment.Left
        
        local description = NoirUI.CreateText(content, config.Description or "", 13, GetColor("TextSecondary"), 0, NoirUI.Config.Font, UDim2.new(0, 0, 0, 28), UDim2.new(1, 0, 1, -28))
        description.TextXAlignment = Enum.TextXAlignment.Left
        description.TextWrapped = true
        description.TextYAlignment = Enum.TextYAlignment.Top
    end
    
    if config.Footer then
        local footer = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 32),
            Position = UDim2.new(0, 0, 1, -32),
            BackgroundTransparency = 1,
        }, content)
        
        local footerText = NoirUI.CreateText(footer, config.Footer, 12, GetColor("TextSecondary"), 0, NoirUI.Config.Font, UDim2.new(0, 0, 0.5, -8), UDim2.new(1, 0, 0, 16))
        footerText.TextXAlignment = Enum.TextXAlignment.Left
    end
    
    return card
end

NoirUI.ColorPicker = {}

function NoirUI.ColorPicker.Create(parent, config)
    config = config or {}
    
    local container = Create("Frame", {
        Size = config.Size or UDim2.new(0, 280, 0, 320),
        BackgroundColor3 = GetColor("Surface"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        LayoutOrder = config.LayoutOrder or 0,
    }, parent)
    
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, 12)
    }, container)
    
    local stroke = NoirUI.CreateStroke(container, GetColor("Border"), 1, 0.3)
    
    local previewBar = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = config.Default or GetColor("Primary"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
    }, container)
    
    local previewCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 12)
    }, previewBar)
    
    local previewClip = Create("UICorner", {
        CornerRadius = UDim.new(0, 12)
    }, previewBar)
    
    local hexText = NoirUI.CreateText(previewBar, "#FFFFFF", 14, Color3.new(1, 1, 1), 0, NoirUI.Config.Font, UDim2.new(0, 12, 0.5, -8), UDim2.new(0, 120, 0, 16))
    hexText.TextXAlignment = Enum.TextXAlignment.Left
    
    local content = Create("Frame", {
        Size = UDim2.new(1, -16, 1, -56),
        Position = UDim2.new(0, 8, 0, 56),
        BackgroundTransparency = 1,
    }, container)
    
    local hueSatMap = Create("ImageLabel", {
        Size = UDim2.new(1, 0, 0, 180),
        BackgroundColor3 = Color3.fromHSV(0, 1, 1),
        BackgroundTransparency = 0,
        Image = "rbxassetid://4155801252",
        ScaleType = Enum.ScaleType.Crop,
    }, content)
    
    local mapCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 8)
    }, hueSatMap)
    
    local cursor = Create("Frame", {
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
    }, hueSatMap)
    
    local cursorCorner = Create("UICorner", {
        CornerRadius = UDim.new(1, 0)
    }, cursor)
    
    local cursorStroke = NoirUI.CreateStroke(cursor, GetColor("Border"), 2, 0)
    
    local hueSlider = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.new(0, 0, 0, 192),
        BackgroundColor3 = GetColor("Surface"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
    }, content)
    
    local hueCorner = Create("UICorner", {
        CornerRadius = UDim.new(1, 0)
    }, hueSlider)
    
    local hueGradient = Create("UIGradient", {
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
            ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
            ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
            ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
            ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
            ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
        }),
    }, hueSlider)
    
    local hueCursor = Create("Frame", {
        Size = UDim2.new(0, 4, 1, -4),
        Position = UDim2.new(0, 0, 0.5, -2),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
    }, hueSlider)
    
    local alphaSlider = nil
    if config.Alpha then
        alphaSlider = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 16),
            Position = UDim2.new(0, 0, 0, 216),
            BackgroundColor3 = GetColor("Surface"),
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
        }, content)
        
        local alphaCorner = Create("UICorner", {
            CornerRadius = UDim.new(1, 0)
        }, alphaSlider)
        
        local alphaBg = Create("ImageLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Image = "rbxassetid://14204231522",
            ScaleType = Enum.ScaleType.Tile,
            TileSize = UDim2.fromOffset(10, 10),
        }, alphaSlider)
        
        local alphaFill = Create("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
        }, alphaSlider)
        
        local alphaCorner2 = Create("UICorner", {
            CornerRadius = UDim.new(1, 0)
        }, alphaFill)
        
        local alphaCursor = Create("Frame", {
            Size = UDim2.new(0, 4, 1, -4),
            Position = UDim2.new(1, -2, 0.5, -2),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
        }, alphaSlider)
    end
    
    local rgbContainer = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        Position = UDim2.new(0, 0, 0, config.Alpha and 248 or 232),
        BackgroundTransparency = 1,
    }, content)
    
    local rgbLayout = NoirUI.CreateListLayout(rgbContainer, "horizontal", 8)
    
    local rInput = NoirUI.Input.CreateNumber(rgbContainer, {Size = UDim2.new(0, 80, 0, 32), Min = 0, Max = 255, Step = 1, Default = 255})
    rInput.Container.Size = UDim2.new(0, 80, 0, 32)
    rInput.Container:FindFirstChild("Input").Text = "255"
    
    local gInput = NoirUI.Input.CreateNumber(rgbContainer, {Size = UDim2.new(0, 80, 0, 32), Min = 0, Max = 255, Step = 1, Default = 255})
    gInput.Container.Size = UDim2.new(0, 80, 0, 32)
    gInput.Container:FindFirstChild("Input").Text = "255"
    
    local bInput = NoirUI.Input.CreateNumber(rgbContainer, {Size = UDim2.new(0, 80, 0, 32), Min = 0, Max = 255, Step = 1, Default = 255})
    bInput.Container.Size = UDim2.new(0, 80, 0, 32)
    bInput.Container:FindFirstChild("Input").Text = "255"
    
    local currentHue = 0
    local currentSat = 1
    local currentVal = 1
    local currentAlpha = 1
    local isDraggingMap = false
    local isDraggingHue = false
    local isDraggingAlpha = false
    
    local function UpdateColor()
        local color = Color3.fromHSV(currentHue, currentSat, currentVal)
        previewBar.BackgroundColor3 = color
        hexText.Text = "#" .. color:ToHex()
        rInput.SetValue(math.floor(color.R * 255))
        gInput.SetValue(math.floor(color.G * 255))
        bInput.SetValue(math.floor(color.B * 255))
        hueSatMap.BackgroundColor3 = Color3.fromHSV(currentHue, 1, 1)
        cursor.Position = UDim2.new(currentSat, -6, 1 - currentVal, -6)
        if alphaFill then
            alphaFill.BackgroundColor3 = color
            alphaFill.BackgroundTransparency = 1 - currentAlpha
        end
        if config.OnChange then config.OnChange(color, currentAlpha) end
    end
    
    local function UpdateHue()
        hueCursor.Position = UDim2.new(currentHue, -2, 0.5, -2)
        UpdateColor()
    end
    
    local function UpdateAlpha()
        if alphaCursor then
            alphaCursor.Position = UDim2.new(currentAlpha, -2, 0.5, -2)
            UpdateColor()
        end
    end
    
    local function GetMapPosition(inputPos)
        local mapPos = hueSatMap.AbsolutePosition
        local mapSize = hueSatMap.AbsoluteSize
        local x = NoirUI.Clamp((inputPos.X - mapPos.X) / mapSize.X, 0, 1)
        local y = NoirUI.Clamp((inputPos.Y - mapPos.Y) / mapSize.Y, 0, 1)
        return x, 1 - y
    end
    
    local function GetHuePosition(inputPos)
        local sliderPos = hueSlider.AbsolutePosition
        local sliderSize = hueSlider.AbsoluteSize
        return NoirUI.Clamp((inputPos.X - sliderPos.X) / sliderSize.X, 0, 1)
    end
    
    local function GetAlphaPosition(inputPos)
        if not alphaSlider then return 1 end
        local sliderPos = alphaSlider.AbsolutePosition
        local sliderSize = alphaSlider.AbsoluteSize
        return NoirUI.Clamp((inputPos.X - sliderPos.X) / sliderSize.X, 0, 1)
    end
    
    hueSatMap.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDraggingMap = true
            local x, y = GetMapPosition(input.Position)
            currentSat = x
            currentVal = y
            UpdateColor()
        end
    end)
    
    hueSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDraggingHue = true
            currentHue = GetHuePosition(input.Position)
            UpdateHue()
        end
    end)
    
    if alphaSlider then
        alphaSlider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDraggingAlpha = true
                currentAlpha = GetAlphaPosition(input.Position)
                UpdateAlpha()
            end
        end)
    end
    
    UserInputService.InputChanged:Connect(function(input)
        if isDraggingMap and input.UserInputType == Enum.UserInputType.MouseMovement then
            local x, y = GetMapPosition(input.Position)
            currentSat = x
            currentVal = y
            UpdateColor()
        elseif isDraggingHue and input.UserInputType == Enum.UserInputType.MouseMovement then
            currentHue = GetHuePosition(input.Position)
            UpdateHue()
        elseif isDraggingAlpha and input.UserInputType == Enum.UserInputType.MouseMovement then
            currentAlpha = GetAlphaPosition(input.Position)
            UpdateAlpha()
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDraggingMap = false
            isDraggingHue = false
            isDraggingAlpha = false
        end
    end)
    
    rInput.OnChange = function(val) 
        currentSat = val / 255
        UpdateColor() 
    end
    gInput.OnChange = function(val) 
        currentVal = val / 255
        UpdateColor() 
    end
    bInput.OnChange = function(val) 
        currentHue = val / 255
        UpdateHue() 
    end
    
    if config.Default then
        local h, s, v = Color3.toHSV(config.Default)
        currentHue = h
        currentSat = s
        currentVal = v
        UpdateHue()
    end
    
    UpdateHue()
    
    return {
        Container = container,
        Preview = previewBar,
        GetColor = function() return Color3.fromHSV(currentHue, currentSat, currentVal) end,
        GetAlpha = function() return currentAlpha end,
        SetColor = function(color)
            local h, s, v = Color3.toHSV(color)
            currentHue = h
            currentSat = s
            currentVal = v
            UpdateHue()
        end,
        SetAlpha = function(alpha)
            currentAlpha = NoirUI.Clamp(alpha, 0, 1)
            UpdateAlpha()
        end,
    }
end

NoirUI.DatePicker = {}

function NoirUI.DatePicker.Create(parent, config)
    config = config or {}
    
    local container = Create("Frame", {
        Size = config.Size or UDim2.new(0, 280, 0, 320),
        BackgroundColor3 = GetColor("Surface"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        LayoutOrder = config.LayoutOrder or 0,
    }, parent)
    
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, 12)
    }, container)
    
    local stroke = NoirUI.CreateStroke(container, GetColor("Border"), 1, 0.3)
    
    local header = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = GetColor("Primary"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
    }, container)
    
    local headerCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 12)
    }, header)
    
    local monthYear = NoirUI.CreateText(header, "2024年1月", 16, Color3.new(1, 1, 1), 0, NoirUI.Config.FontBold, UDim2.new(0.5, -60, 0.5, -8), UDim2.new(0, 120, 0, 16))
    monthYear.TextXAlignment = Enum.TextXAlignment.Center
    
    local prevBtn = NoirUI.Button.Create(header, {Text = "<", Size = UDim2.new(0, 32, 0, 32), BackgroundColor = Color3.new(1, 1, 1), BackgroundTransparency = 0.2, TextColor = Color3.new(1, 1, 1)})
    prevBtn.Position = UDim2.new(0, 12, 0.5, -16)
    
    local nextBtn = NoirUI.Button.Create(header, {Text = ">", Size = UDim2.new(0, 32, 0, 32), BackgroundColor = Color3.new(1, 1, 1), BackgroundTransparency = 0.2, TextColor = Color3.new(1, 1, 1)})
    nextBtn.Position = UDim2.new(1, -44, 0.5, -16)
    
    local weekdayNames = {"日", "一", "二", "三", "四", "五", "六"}
    local weekdayRow = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        Position = UDim2.new(0, 0, 0, 56),
        BackgroundTransparency = 1,
    }, container)
    
    local weekdayLayout = Create("UIGridLayout", {
        CellSize = UDim2.new(0, 38, 0, 32),
        FillDirectionMaxCells = 7,
        StartDirection = Enum.StartDirection.Horizontal,
    }, weekdayRow)
    
    for _, name in ipairs(weekdayNames) do
        local wdText = NoirUI.CreateText(weekdayRow, name, 12, GetColor("TextSecondary"), 0, NoirUI.Config.Font, UDim2.new(0, 0, 0, 0), UDim2.new(0, 38, 0, 32))
        wdText.TextXAlignment = Enum.TextXAlignment.Center
    end
    
    local daysGrid = Create("Frame", {
        Size = UDim2.new(1, 0, 1, -96),
        Position = UDim2.new(0, 0, 0, 96),
        BackgroundTransparency = 1,
    }, container)
    
    local gridLayout = Create("UIGridLayout", {
        CellSize = UDim2.new(0, 38, 0, 38),
        FillDirectionMaxCells = 7,
        StartDirection = Enum.StartDirection.Horizontal,
    }, daysGrid)
    
    local currentYear = config.Year or os.date("*t").year
    local currentMonth = config.Month or os.date("*t").month
    local selectedDay = config.Day or os.date("*t").day
    local dayButtons = {}
    
    local function UpdateCalendar()
        for _, btn in ipairs(dayButtons) do
            btn:Destroy()
        end
        dayButtons = {}
        
        local firstDayOfMonth = os.time({year = currentYear, month = currentMonth, day = 1})
        local firstWeekday = os.date("*t", firstDayOfMonth).wday
        local daysInMonth = os.date("*t", os.time({year = currentYear, month = currentMonth + 1, day = 0})).day
        
        monthYear.Text = string.format("%d年%d月", currentYear, currentMonth)
        
        local dayOffset = firstWeekday - 1
        
        for i = 1, dayOffset do
            local emptyBtn = Create("Frame", {
                Size = UDim2.new(0, 38, 0, 38),
                BackgroundTransparency = 1,
            }, daysGrid)
            table.insert(dayButtons, emptyBtn)
        end
        
        for day = 1, daysInMonth do
            local isSelected = (day == selectedDay)
            local dayBtn = Create("TextButton", {
                Size = UDim2.new(0, 38, 0, 38),
                BackgroundColor3 = isSelected and GetColor("Primary") or GetColor("Surface"),
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Text = tostring(day),
                TextColor3 = isSelected and Color3.new(1, 1, 1) or GetColor("Text"),
                TextSize = 14,
                Font = NoirUI.Config.Font,
            }, daysGrid)
            
            local btnCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 8)
            }, dayBtn)
            
            dayBtn.MouseButton1Click:Connect(function()
                selectedDay = day
                UpdateCalendar()
                if config.OnSelect then
                    config.OnSelect(currentYear, currentMonth, selectedDay)
                end
            end)
            
            dayBtn.MouseEnter:Connect(function()
                if not isSelected then
                    TweenService:Create(dayBtn, TweenInfo.new(0.1), {BackgroundColor3 = GetColor("SurfaceHover")}):Play()
                end
            end)
            
            dayBtn.MouseLeave:Connect(function()
                if not isSelected then
                    TweenService:Create(dayBtn, TweenInfo.new(0.1), {BackgroundColor3 = GetColor("Surface")}):Play()
                end
            end)
            
            table.insert(dayButtons, dayBtn)
        end
    end
    
    prevBtn.MouseButton1Click:Connect(function()
        if currentMonth == 1 then
            currentMonth = 12
            currentYear = currentYear - 1
        else
            currentMonth = currentMonth - 1
        end
        UpdateCalendar()
    end)
    
    nextBtn.MouseButton1Click:Connect(function()
        if currentMonth == 12 then
            currentMonth = 1
            currentYear = currentYear + 1
        else
            currentMonth = currentMonth + 1
        end
        UpdateCalendar()
    end)
    
    UpdateCalendar()
    
    return {
        Container = container,
        GetDate = function() return {year = currentYear, month = currentMonth, day = selectedDay} end,
        SetDate = function(year, month, day)
            currentYear = year
            currentMonth = month
            selectedDay = day
            UpdateCalendar()
        end,
    }
end

NoirUI.Chart = {}

function NoirUI.Chart.CreateBarChart(parent, config)
    config = config or {}
    
    local container = Create("Frame", {
        Size = config.Size or UDim2.new(1, 0, 0, 300),
        BackgroundColor3 = GetColor("Surface"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        LayoutOrder = config.LayoutOrder or 0,
    }, parent)
    
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, 12)
    }, container)
    
    local stroke = NoirUI.CreateStroke(container, GetColor("Border"), 1, 0.3)
    
    local title = nil
    if config.Title then
        title = NoirUI.CreateText(container, config.Title, 16, GetColor("Text"), 0, NoirUI.Config.FontBold, UDim2.new(0, 16, 0, 12), UDim2.new(1, -32, 0, 24))
        title.TextXAlignment = Enum.TextXAlignment.Left
    end
    
    local chartArea = Create("Frame", {
        Size = UDim2.new(1, -32, 1, title and -80 or -60),
        Position = UDim2.new(0, 16, 0, title and 48 or 36),
        BackgroundTransparency = 1,
    }, container)
    
    local yAxis = Create("Frame", {
        Size = UDim2.new(0, 32, 1, 0),
        BackgroundTransparency = 1,
    }, chartArea)
    
    local yAxisLine = Create("Frame", {
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = GetColor("Border"),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
    }, yAxis)
    
    local xAxis = Create("Frame", {
        Size = UDim2.new(1, -32, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = GetColor("Border"),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
    }, chartArea)
    
    local barsContainer = Create("Frame", {
        Size = UDim2.new(1, -32, 1, -32),
        Position = UDim2.new(0, 32, 0, 0),
        BackgroundTransparency = 1,
    }, chartArea)
    
    local bars = {}
    local maxValue = config.MaxValue or 100
    
    if config.Data then
        local barWidth = (1 / #config.Data) * 0.7
        local barSpacing = (1 / #config.Data) * 0.3
        
        for i, item in ipairs(config.Data) do
            local barHeight = (item.Value / maxValue) * 0.85
            local barX = (i - 1) * (barWidth + barSpacing) + barSpacing / 2
            
            local barContainer = Create("Frame", {
                Size = UDim2.new(barWidth, 0, 1, 0),
                Position = UDim2.new(barX, 0, 0, 0),
                BackgroundTransparency = 1,
            }, barsContainer)
            
            local bar = Create("Frame", {
                Size = UDim2.new(1, 0, barHeight, 0),
                Position = UDim2.new(0, 0, 1 - barHeight, 0),
                BackgroundColor3 = item.Color or GetColor("Primary"),
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
            }, barContainer)
            
            local barCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 4)
            }, bar)
            
            local valueLabel = NoirUI.CreateText(barContainer, tostring(item.Value), 11, GetColor("TextSecondary"), 0, NoirUI.Config.Font, UDim2.new(0.5, -20, 1, -barHeight - 4), UDim2.new(0, 40, 0, 16))
            valueLabel.TextXAlignment = Enum.TextXAlignment.Center
            
            local label = NoirUI.CreateText(barContainer, item.Label or "", 11, GetColor("TextSecondary"), 0, NoirUI.Config.Font, UDim2.new(0.5, -30, 0, -20), UDim2.new(0, 60, 0, 16))
            label.TextXAlignment = Enum.TextXAlignment.Center
            label.TextTruncate = Enum.TextTruncate.AtEnd
            
            bar.MouseEnter:Connect(function()
                TweenService:Create(bar, TweenInfo.new(0.15), {BackgroundColor3 = GetColor("PrimaryHover")}):Play()
                valueLabel.TextTransparency = 0
            end)
            
            bar.MouseLeave:Connect(function()
                TweenService:Create(bar, TweenInfo.new(0.15), {BackgroundColor3 = item.Color or GetColor("Primary")}):Play()
                valueLabel.TextTransparency = 1
            end)
            
            table.insert(bars, {Bar = bar, Container = barContainer, Value = item.Value, Label = label})
        end
    end
    
    return {
        Container = container,
        Bars = bars,
        UpdateData = function(newData)
            for i, bar in ipairs(bars) do
                bar.Container:Destroy()
            end
            bars = {}
            local barWidth = (1 / #newData) * 0.7
            local barSpacing = (1 / #newData) * 0.3
            
            for i, item in ipairs(newData) do
                local barHeight = (item.Value / maxValue) * 0.85
                local barX = (i - 1) * (barWidth + barSpacing) + barSpacing / 2
                
                local barContainer = Create("Frame", {
                    Size = UDim2.new(barWidth, 0, 1, 0),
                    Position = UDim2.new(barX, 0, 0, 0),
                    BackgroundTransparency = 1,
                }, barsContainer)
                
                local bar = Create("Frame", {
                    Size = UDim2.new(1, 0, barHeight, 0),
                    Position = UDim2.new(0, 0, 1 - barHeight, 0),
                    BackgroundColor3 = item.Color or GetColor("Primary"),
                    BackgroundTransparency = 0,
                    BorderSizePixel = 0,
                }, barContainer)
                
                local barCorner = Create("UICorner", {
                    CornerRadius = UDim.new(0, 4)
                }, bar)
                
                local valueLabel = NoirUI.CreateText(barContainer, tostring(item.Value), 11, GetColor("TextSecondary"), 0, NoirUI.Config.Font, UDim2.new(0.5, -20, 1, -barHeight - 4), UDim2.new(0, 40, 0, 16))
                valueLabel.TextXAlignment = Enum.TextXAlignment.Center
                valueLabel.TextTransparency = 1
                
                local label = NoirUI.CreateText(barContainer, item.Label or "", 11, GetColor("TextSecondary"), 0, NoirUI.Config.Font, UDim2.new(0.5, -30, 0, -20), UDim2.new(0, 60, 0, 16))
                label.TextXAlignment = Enum.TextXAlignment.Center
                
                bar.MouseEnter:Connect(function()
                    TweenService:Create(bar, TweenInfo.new(0.15), {BackgroundColor3 = GetColor("PrimaryHover")}):Play()
                    valueLabel.TextTransparency = 0
                end)
                
                bar.MouseLeave:Connect(function()
                    TweenService:Create(bar, TweenInfo.new(0.15), {BackgroundColor3 = item.Color or GetColor("Primary")}):Play()
                    valueLabel.TextTransparency = 1
                end)
                
                table.insert(bars, {Bar = bar, Container = barContainer, Value = item.Value, Label = label})
            end
        end,
    }
end

NoirUI.ProgressRing = {}

function NoirUI.ProgressRing.Create(parent, config)
    config = config or {}
    
    local size = config.Size or 100
    local thickness = config.Thickness or 8
    
    local container = Create("Frame", {
        Size = UDim2.new(0, size, 0, size),
        BackgroundTransparency = 1,
        LayoutOrder = config.LayoutOrder or 0,
    }, parent)
    
    local bgCircle = Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = GetColor("SurfaceHover"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
    }, container)
    
    local bgCorner = Create("UICorner", {
        CornerRadius = UDim.new(1, 0)
    }, bgCircle)
    
    local progressCircle = Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = config.Color or GetColor("Primary"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
    }, container)
    
    local progressCorner = Create("UICorner", {
        CornerRadius = UDim.new(1, 0)
    }, progressCircle)
    
    local centerLabel = NoirUI.CreateText(container, "0%", config.TextSize or 16, GetColor("Text"), 0, NoirUI.Config.FontBold, UDim2.new(0.5, -30, 0.5, -10), UDim2.new(0, 60, 0, 20))
    centerLabel.TextXAlignment = Enum.TextXAlignment.Center
    
    local currentProgress = 0
    
    local function UpdateProgress(value)
        currentProgress = NoirUI.Clamp(value, 0, 1)
        local angle = currentProgress * 360
        centerLabel.Text = math.floor(currentProgress * 100) .. "%"
        
        progressCircle.Rotation = -90
        progressCircle.Size = UDim2.new(1, 0, 1, 0)
        
        local clip = Create("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ClipsDescendants = true,
        }, container)
        
        local radius = size / 2 - thickness
        for i = 1, 360 do
            if i / 360 <= currentProgress then
                local rad = math.rad(i)
                local x = size / 2 + radius * math.cos(rad)
                local y = size / 2 + radius * math.sin(rad)
                local dot = Create("Frame", {
                    Size = UDim2.new(0, thickness, 0, thickness),
                    Position = UDim2.new(0, x - thickness / 2, 0, y - thickness / 2),
                    BackgroundColor3 = config.Color or GetColor("Primary"),
                    BackgroundTransparency = 0,
                    BorderSizePixel = 0,
                }, clip)
                local dotCorner = Create("UICorner", {
                    CornerRadius = UDim.new(1, 0)
                }, dot)
            end
        end
        
        if config.OnChange then config.OnChange(currentProgress) end
    end
    
    local function AnimateTo(target, duration)
        local start = currentProgress
        local elapsed = 0
        local connection
        connection = RunService.RenderStepped:Connect(function(dt)
            elapsed = elapsed + dt
            local t = NoirUI.Clamp(elapsed / duration, 0, 1)
            local newValue = start + (target - start) * t
            UpdateProgress(newValue)
            if t >= 1 then
                connection:Disconnect()
            end
        end)
    end
    
    UpdateProgress(config.Progress or 0)
    
    return {
        Container = container,
        ProgressCircle = progressCircle,
        CenterLabel = centerLabel,
        GetProgress = function() return currentProgress end,
        SetProgress = UpdateProgress,
        AnimateTo = AnimateTo,
    }
end

NoirUI.Rating = {}

function NoirUI.Rating.Create(parent, config)
    config = config or {}
    
    local maxRating = config.Max or 5
    local defaultValue = config.Default or 0
    
    local container = Create("Frame", {
        Size = config.Size or UDim2.new(0, maxRating * 32, 0, 32),
        BackgroundTransparency = 1,
        LayoutOrder = config.LayoutOrder or 0,
    }, parent)
    
    local stars = {}
    local currentRating = defaultValue
    local isHovering = false
    
    local function UpdateStars(rating)
        for i = 1, maxRating do
            if i <= rating then
                stars[i].ImageColor3 = GetColor("Warning")
                stars[i].ImageTransparency = 0
            elseif i <= math.floor(rating) then
                stars[i].ImageColor3 = GetColor("Warning")
                stars[i].ImageTransparency = 0
            else
                stars[i].ImageColor3 = GetColor("TextSecondary")
                stars[i].ImageTransparency = 0.5
            end
        end
    end
    
    local function SetRating(rating)
        currentRating = NoirUI.Clamp(rating, 0, maxRating)
        UpdateStars(currentRating)
        if config.OnChange then config.OnChange(currentRating) end
    end
    
    for i = 1, maxRating do
        local star = Create("ImageButton", {
            Size = UDim2.new(0, 28, 0, 28),
            Position = UDim2.new(0, (i - 1) * 32, 0.5, -14),
            BackgroundTransparency = 1,
            Image = "rbxassetid://10734867678",
            ImageColor3 = i <= defaultValue and GetColor("Warning") or GetColor("TextSecondary"),
            ImageTransparency = i <= defaultValue and 0 or 0.5,
        }, container)
        
        star.MouseButton1Click:Connect(function()
            SetRating(i)
        end)
        
        star.MouseEnter:Connect(function()
            isHovering = true
            for j = 1, i do
                stars[j].ImageColor3 = GetColor("Warning")
                stars[j].ImageTransparency = 0
            end
            for j = i + 1, maxRating do
                stars[j].ImageColor3 = GetColor("TextSecondary")
                stars[j].ImageTransparency = 0.5
            end
        end)
        
        table.insert(stars, star)
    end
    
    container.MouseLeave:Connect(function()
        if isHovering then
            isHovering = false
            UpdateStars(currentRating)
        end
    end)
    
    return {
        Container = container,
        Stars = stars,
        GetRating = function() return currentRating end,
        SetRating = SetRating,
    }
end

NoirUI.Stepper = {}

function NoirUI.Stepper.Create(parent, config)
    config = config or {}
    
    local min = config.Min or 0
    local max = config.Max or 10
    local defaultValue = config.Default or 0
    local step = config.Step or 1
    
    local container = Create("Frame", {
        Size = config.Size or UDim2.new(0, 120, 0, 36),
        BackgroundColor3 = GetColor("Surface"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        LayoutOrder = config.LayoutOrder or 0,
    }, parent)
    
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, 8)
    }, container)
    
    local stroke = NoirUI.CreateStroke(container, GetColor("Border"), 1, 0.3)
    
    local decBtn = Create("TextButton", {
        Size = UDim2.new(0, 32, 1, 0),
        BackgroundColor3 = GetColor("SurfaceHover"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Text = "-",
        TextSize = 18,
        TextColor3 = GetColor("Text"),
    }, container)
    
    local decCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 8)
    }, decBtn)
    
    local valueLabel = NoirUI.CreateText(container, tostring(defaultValue), 14, GetColor("Text"), 0, NoirUI.Config.FontBold, UDim2.new(0.5, -20, 0.5, -10), UDim2.new(0, 40, 0, 20))
    valueLabel.TextXAlignment = Enum.TextXAlignment.Center
    
    local incBtn = Create("TextButton", {
        Size = UDim2.new(0, 32, 1, 0),
        Position = UDim2.new(1, -32, 0, 0),
        BackgroundColor3 = GetColor("SurfaceHover"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Text = "+",
        TextSize = 18,
        TextColor3 = GetColor("Text"),
    }, container)
    
    local incCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 8)
    }, incBtn)
    
    local currentValue = defaultValue
    
    local function UpdateValue(newValue)
        currentValue = NoirUI.Clamp(newValue, min, max)
        currentValue = math.floor(currentValue / step) * step
        valueLabel.Text = tostring(currentValue)
        if config.OnChange then config.OnChange(currentValue) end
    end
    
    decBtn.MouseButton1Click:Connect(function()
        UpdateValue(currentValue - step)
    end)
    
    incBtn.MouseButton1Click:Connect(function()
        UpdateValue(currentValue + step)
    end)
    
    UpdateValue(defaultValue)
    
    return {
        Container = container,
        GetValue = function() return currentValue end,
        SetValue = UpdateValue,
        Increment = function() UpdateValue(currentValue + step) end,
        Decrement = function() UpdateValue(currentValue - step) end,
    }
end

NoirUI.Tree = {}

function NoirUI.Tree.Create(parent, config)
    config = config or {}
    
    local container = Create("Frame", {
        Size = config.Size or UDim2.new(1, 0, 0, 400),
        BackgroundColor3 = GetColor("Surface"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        LayoutOrder = config.LayoutOrder or 0,
    }, parent)
    
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, 8)
    }, container)
    
    local stroke = NoirUI.CreateStroke(container, GetColor("Border"), 1, 0.3)
    
    local scrollFrame = Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
    }, container)
    
    local treeBody = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
    }, scrollFrame)
    
    local treeLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 0),
    }, treeBody)
    
    local nodes = {}
    local expandedNodes = {}
    
    local function CreateNode(nodeData, depth, parentNode)
        depth = depth or 0
        local nodeContainer = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundTransparency = 1,
            LayoutOrder = #nodes + 1,
        }, treeBody)
        
        local indent = Create("Frame", {
            Size = UDim2.new(0, depth * 20, 1, 0),
            BackgroundTransparency = 1,
        }, nodeContainer)
        
        local content = Create("Frame", {
            Size = UDim2.new(1, -depth * 20, 1, 0),
            Position = UDim2.new(0, depth * 20, 0, 0),
            BackgroundTransparency = 1,
        }, nodeContainer)
        
        local expandBtn = nil
        if nodeData.Children and #nodeData.Children > 0 then
            expandBtn = Create("TextButton", {
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(0, 4, 0.5, -10),
                BackgroundTransparency = 1,
                Text = expandedNodes[nodeData.Id] and "▼" or "▶",
                TextColor3 = GetColor("TextSecondary"),
                TextSize = 10,
            }, content)
        end
        
        local icon = nil
        if nodeData.Icon then
            icon = NoirUI.CreateIcon(content, nodeData.Icon, 16, GetColor("TextSecondary"))
            icon.Position = UDim2.new(0, expandBtn and 28 or 8, 0.5, -8)
        end
        
        local text = NoirUI.CreateText(content, nodeData.Title or "", 14, GetColor("Text"), 0, NoirUI.Config.Font, UDim2.new(0, expandBtn and 48 or (icon and 32 or 12), 0.5, -10), UDim2.new(1, -60, 0, 20))
        text.TextXAlignment = Enum.TextXAlignment.Left
        
        local line = Create("Frame", {
            Size = UDim2.new(1, -12, 0, 1),
            Position = UDim2.new(0, 12, 1, -1),
            BackgroundColor3 = GetColor("Border"),
            BackgroundTransparency = 0.5,
            BorderSizePixel = 0,
        }, nodeContainer)
        
        local nodeObj = {
            Container = nodeContainer,
            Content = content,
            ExpandBtn = expandBtn,
            Icon = icon,
            Text = text,
            Data = nodeData,
            Depth = depth,
            Children = {},
            Expanded = expandedNodes[nodeData.Id] or false,
            
            Toggle = function()
                nodeObj.Expanded = not nodeObj.Expanded
                expandedNodes[nodeData.Id] = nodeObj.Expanded
                if expandBtn then
                    expandBtn.Text = nodeObj.Expanded and "▼" or "▶"
                end
                for _, child in ipairs(nodeObj.Children) do
                    child.Container.Visible = nodeObj.Expanded
                end
                if config.OnToggle then config.OnToggle(nodeData, nodeObj.Expanded) end
            end,
            
            AddChild = function(childData)
                local childNode = CreateNode(childData, depth + 1, nodeObj)
                childNode.Container.Visible = nodeObj.Expanded
                table.insert(nodeObj.Children, childNode)
                return childNode
            end,
        }
        
        if expandBtn then
            expandBtn.MouseButton1Click:Connect(function()
                nodeObj.Toggle()
            end)
        end
        
        content.MouseButton1Click:Connect(function()
            if config.OnSelect then config.OnSelect(nodeData, nodeObj) end
        end)
        
        content.MouseEnter:Connect(function()
            TweenService:Create(content, TweenInfo.new(0.1), {BackgroundColor3 = GetColor("SurfaceHover")}):Play()
        end)
        
        content.MouseLeave:Connect(function()
            TweenService:Create(content, TweenInfo.new(0.1), {BackgroundColor3 = GetColor("Surface")}):Play()
        end)
        
        table.insert(nodes, nodeObj)
        
        if nodeData.Children then
            for _, childData in ipairs(nodeData.Children) do
                local childNode = nodeObj:AddChild(childData)
                if childNode.Expanded then
                    childNode.Toggle()
                end
            end
        end
        
        return nodeObj
    end
    
    local function ClearNodes()
        for _, node in ipairs(nodes) do
            node.Container:Destroy()
        end
        nodes = {}
    end
    
    local function SetData(data)
        ClearNodes()
        for _, nodeData in ipairs(data) do
            CreateNode(nodeData, 0, nil)
        end
        treeBody.Size = UDim2.new(1, 0, 0, #nodes * 32)
    end
    
    if config.Data then
        SetData(config.Data)
    end
    
    return {
        Container = container,
        Nodes = nodes,
        SetData = SetData,
        ClearNodes = ClearNodes,
        ExpandAll = function()
            for _, node in ipairs(nodes) do
                if not node.Expanded then
                    node.Toggle()
                end
            end
        end,
        CollapseAll = function()
            for _, node in ipairs(nodes) do
                if node.Expanded then
                    node.Toggle()
                end
            end
        end,
    }
end

NoirUI.Tooltip = {}

local TooltipInstance = nil

function NoirUI.Tooltip.Show(text, position, duration)
    if TooltipInstance then
        TooltipInstance:Destroy()
    end
    
    local tooltip = Create("Frame", {
        Size = UDim2.new(0, 0, 0, 0),
        Position = position or UDim2.new(0, UserInputService:GetMouseLocation().X + 10, 0, UserInputService:GetMouseLocation().Y + 10),
        BackgroundColor3 = GetColor("Surface"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 3000,
    }, LP.PlayerGui)
    
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, 6)
    }, tooltip)
    
    local stroke = NoirUI.CreateStroke(tooltip, GetColor("Border"), 1, 0.3)
    
    local textLabel = NoirUI.CreateText(tooltip, text, 13, GetColor("Text"), 0, NoirUI.Config.Font, UDim2.new(0, 8, 0, 6), UDim2.new(0, 0, 0, 0))
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.AutomaticSize = Enum.AutomaticSize.XY
    
    tooltip.Size = UDim2.new(0, textLabel.TextBounds.X + 16, 0, textLabel.TextBounds.Y + 12)
    
    TweenService:Create(tooltip, TweenInfo.new(0.1), {BackgroundTransparency = 0}):Play()
    
    TooltipInstance = tooltip
    
    if duration then
        task.delay(duration, function()
            if tooltip then
                TweenService:Create(tooltip, TweenInfo.new(0.1), {BackgroundTransparency = 1}):Play()
                task.delay(0.1, function()
                    if tooltip then tooltip:Destroy() end
                end)
            end
        end)
    end
    
    return tooltip
end

function NoirUI.Tooltip.Hide()
    if TooltipInstance then
        TooltipInstance:Destroy()
        TooltipInstance = nil
    end
end

function NoirUI.Tooltip.Bind(element, text, delay)
    local hoverConnection = nil
    local leaveConnection = nil
    local delayTask = nil
    
    element.MouseEnter:Connect(function()
        delayTask = task.delay(delay or 0.5, function()
            local pos = UDim2.new(0, UserInputService:GetMouseLocation().X + 10, 0, UserInputService:GetMouseLocation().Y + 10)
            NoirUI.Tooltip.Show(text, pos)
        end)
    end)
    
    element.MouseLeave:Connect(function()
        if delayTask then
            task.cancel(delayTask)
            delayTask = nil
        end
        NoirUI.Tooltip.Hide()
    end)
end

NoirUI.ContextMenu = {}

local ContextMenuInstance = nil

function NoirUI.ContextMenu.Show(items, x, y)
    if ContextMenuInstance then
        ContextMenuInstance:Destroy()
    end
    
    local menu = Create("Frame", {
        Size = UDim2.new(0, 180, 0, 0),
        Position = UDim2.new(0, x or UserInputService:GetMouseLocation().X, 0, y or UserInputService:GetMouseLocation().Y),
        BackgroundColor3 = GetColor("Surface"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 3000,
    }, LP.PlayerGui)
    
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, 8)
    }, menu)
    
    local stroke = NoirUI.CreateStroke(menu, GetColor("Border"), 1, 0.3)
    
    local menuLayout = NoirUI.CreateListLayout(menu, "vertical", 0)
    
    local function CloseMenu()
        if menu then
            TweenService:Create(menu, TweenInfo.new(0.1), {BackgroundTransparency = 1}):Play()
            task.delay(0.1, function()
                if menu then menu:Destroy() end
            end)
        end
        ContextMenuInstance = nil
    end
    
    for _, item in ipairs(items) do
        local itemBtn = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = GetColor("Surface"),
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Text = item.Text or "",
            TextColor3 = item.Danger and GetColor("Danger") or GetColor("Text"),
            TextSize = 14,
            Font = NoirUI.Config.Font,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, menu)
        
        local itemPadding = Create("UIPadding", {
            PaddingLeft = UDim.new(0, 12),
        }, itemBtn)
        
        if item.Icon then
            local icon = NoirUI.CreateIcon(itemBtn, item.Icon, 14, item.Danger and GetColor("Danger") or GetColor("TextSecondary"))
            icon.Position = UDim2.new(1, -28, 0.5, -7)
        end
        
        if item.Divider then
            local divider = NoirUI.CreateDivider(menu, 0.9, GetColor("Border"), 1)
            divider.Position = UDim2.new(0.05, 0, 0, 0)
        end
        
        itemBtn.MouseEnter:Connect(function()
            TweenService:Create(itemBtn, TweenInfo.new(0.1), {BackgroundColor3 = GetColor("SurfaceHover")}):Play()
        end)
        
        itemBtn.MouseLeave:Connect(function()
            TweenService:Create(itemBtn, TweenInfo.new(0.1), {BackgroundColor3 = GetColor("Surface")}):Play()
        end)
        
        itemBtn.MouseButton1Click:Connect(function()
            if item.OnClick then item.OnClick() end
            CloseMenu()
        end)
    end
    
    local totalHeight = #items * 32
    menu.Size = UDim2.new(0, 180, 0, totalHeight)
    
    ContextMenuInstance = menu
    
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            local menuPos = menu.AbsolutePosition
            local menuSize = menu.AbsoluteSize
            if mousePos.X < menuPos.X or mousePos.X > menuPos.X + menuSize.X or
               mousePos.Y < menuPos.Y or mousePos.Y > menuPos.Y + menuSize.Y then
                CloseMenu()
            end
        end
    end)
    
    return menu
end

NoirUI.DragSort = {}

function NoirUI.DragSort.Create(parent, config)
    config = config or {}
    
    local container = Create("Frame", {
        Size = config.Size or UDim2.new(1, 0, 0, 400),
        BackgroundColor3 = GetColor("Surface"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        LayoutOrder = config.LayoutOrder or 0,
    }, parent)
    
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, 8)
    }, container)
    
    local stroke = NoirUI.CreateStroke(container, GetColor("Border"), 1, 0.3)
    
    local scrollFrame = Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
    }, container)
    
    local listBody = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
    }, scrollFrame)
    
    local listLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
    }, listBody)
    
    local items = {}
    local dragItem = nil
    local dragIndex = nil
    local dragOffset = nil
    
    local function AddItem(itemData)
        local itemIndex = #items + 1
        
        local item = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 48),
            BackgroundColor3 = GetColor("SurfaceHover"),
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            LayoutOrder = itemIndex,
        }, listBody)
        
        local itemCorner = Create("UICorner", {
            CornerRadius = UDim.new(0, 8)
        }, item)
        
        local dragHandle = Create("Frame", {
            Size = UDim2.new(0, 24, 1, 0),
            BackgroundColor3 = GetColor("Primary"),
            BackgroundTransparency = 0.5,
            BorderSizePixel = 0,
        }, item)
        
        local handleCorner = Create("UICorner", {
            CornerRadius = UDim.new(0, 8)
        }, dragHandle)
        
        local dragIcon = NoirUI.CreateIcon(dragHandle, "rbxassetid://10734867672", 14, Color3.new(1, 1, 1))
        dragIcon.Position = UDim2.new(0.5, -7, 0.5, -7)
        
        local content = Create("Frame", {
            Size = UDim2.new(1, -32, 1, 0),
            Position = UDim2.new(0, 32, 0, 0),
            BackgroundTransparency = 1,
        }, item)
        
        local title = NoirUI.CreateText(content, itemData.Title or "", 14, GetColor("Text"), 0, NoirUI.Config.Font, UDim2.new(0, 12, 0.5, -10), UDim2.new(1, -24, 0, 20))
        title.TextXAlignment = Enum.TextXAlignment.Left
        
        local subtitle = nil
        if itemData.Subtitle then
            title.Position = UDim2.new(0, 12, 0, 8)
            subtitle = NoirUI.CreateText(content, itemData.Subtitle, 12, GetColor("TextSecondary"), 0, NoirUI.Config.Font, UDim2.new(0, 12, 0, 26), UDim2.new(1, -24, 0, 16))
            subtitle.TextXAlignment = Enum.TextXAlignment.Left
        end
        
        local itemObj = {
            Frame = item,
            DragHandle = dragHandle,
            Title = title,
            Subtitle = subtitle,
            Data = itemData,
            Index = itemIndex,
            
            Update = function(newData)
                title.Text = newData.Title or ""
                if subtitle then subtitle.Text = newData.Subtitle or "" end
                itemData = newData
            end,
        }
        
        dragHandle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragItem = itemObj
                dragIndex = itemIndex
                dragOffset = input.Position.Y - item.AbsolutePosition.Y
                
                local dragClone = item:Clone()
                dragClone.Parent = container
                dragClone.Position = UDim2.new(0, item.AbsolutePosition.X, 0, item.AbsolutePosition.Y)
                dragClone.ZIndex = 1000
                
                TweenService:Create(item, TweenInfo.new(0.15), {BackgroundTransparency = 0.5}):Play()
            end
        end)
        
        dragHandle.InputChanged:Connect(function(input)
            if dragItem == itemObj and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mouseY = input.Position.Y
                local newIndex = math.floor((mouseY - listBody.AbsolutePosition.Y) / 48) + 1
                newIndex = NoirUI.Clamp(newIndex, 1, #items)
                
                if newIndex ~= dragIndex then
                    for i = newIndex, dragIndex - 1 do
                        items[i].Frame.LayoutOrder = i + 1
                    end
                    for i = dragIndex + 1, newIndex do
                        items[i].Frame.LayoutOrder = i - 1
                    end
                    dragIndex = newIndex
                end
            end
        end)
        
        dragHandle.InputEnded:Connect(function()
            if dragItem == itemObj then
                TweenService:Create(item, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
                dragItem = nil
                
                local newItems = {}
                for i = 1, #items do
                    newItems[i] = items[items[i].Frame.LayoutOrder]
                end
                for i, newItem in ipairs(newItems) do
                    newItem.Frame.LayoutOrder = i
                    newItem.Index = i
                end
                
                if config.OnChange then
                    config.OnChange(newItems)
                end
            end
        end)
        
        table.insert(items, itemObj)
        listBody.Size = UDim2.new(1, 0, 0, #items * 52)
        
        return itemObj
    end
    
    local function ClearItems()
        for _, item in ipairs(items) do
            item.Frame:Destroy()
        end
        items = {}
        listBody.Size = UDim2.new(1, 0, 0, 0)
    end
    
    if config.Items then
        for _, itemData in ipairs(config.Items) do
            AddItem(itemData)
        end
    end
    
    return {
        Container = container,
        Items = items,
        AddItem = AddItem,
        ClearItems = ClearItems,
        GetOrder = function()
            local order = {}
            for i, item in ipairs(items) do
                order[i] = item.Data
            end
            return order
        end,
    }
end

NoirUI.Resizable = {}

function NoirUI.Resizable.Create(element, config)
    config = config or {}
    
    local handles = {}
    local isResizing = false
    local startSize = nil
    local startPos = nil
    local startMouse = nil
    local direction = nil
    
    local handleSize = config.HandleSize or 6
    
    local edges = {"top", "bottom", "left", "right", "topLeft", "topRight", "bottomLeft", "bottomRight"}
    
    local function CreateHandle(edge)
        local handle = Create("Frame", {
            Name = edge .. "Handle",
            BackgroundColor3 = GetColor("Primary"),
            BackgroundTransparency = 0.8,
            BorderSizePixel = 0,
            ZIndex = 100,
        }, element)
        
        if edge == "top" then
            handle.Size = UDim2.new(1, 0, 0, handleSize)
            handle.Position = UDim2.new(0, 0, 0, -handleSize / 2)
            handle.Cursor = "SizeNS"
        elseif edge == "bottom" then
            handle.Size = UDim2.new(1, 0, 0, handleSize)
            handle.Position = UDim2.new(0, 0, 1, -handleSize / 2)
            handle.Cursor = "SizeNS"
        elseif edge == "left" then
            handle.Size = UDim2.new(0, handleSize, 1, 0)
            handle.Position = UDim2.new(0, -handleSize / 2, 0, 0)
            handle.Cursor = "SizeWE"
        elseif edge == "right" then
            handle.Size = UDim2.new(0, handleSize, 1, 0)
            handle.Position = UDim2.new(1, -handleSize / 2, 0, 0)
            handle.Cursor = "SizeWE"
        elseif edge == "topLeft" then
            handle.Size = UDim2.new(0, handleSize, 0, handleSize)
            handle.Position = UDim2.new(0, -handleSize / 2, 0, -handleSize / 2)
            handle.Cursor = "SizeNWSE"
        elseif edge == "topRight" then
            handle.Size = UDim2.new(0, handleSize, 0, handleSize)
            handle.Position = UDim2.new(1, -handleSize / 2, 0, -handleSize / 2)
            handle.Cursor = "SizeNESW"
        elseif edge == "bottomLeft" then
            handle.Size = UDim2.new(0, handleSize, 0, handleSize)
            handle.Position = UDim2.new(0, -handleSize / 2, 1, -handleSize / 2)
            handle.Cursor = "SizeNESW"
        elseif edge == "bottomRight" then
            handle.Size = UDim2.new(0, handleSize, 0, handleSize)
            handle.Position = UDim2.new(1, -handleSize / 2, 1, -handleSize / 2)
            handle.Cursor = "SizeNWSE"
        end
        
        local handleCorner = Create("UICorner", {
            CornerRadius = UDim.new(1, 0)
        }, handle)
        
        handle.MouseEnter:Connect(function()
            TweenService:Create(handle, TweenInfo.new(0.1), {BackgroundTransparency = 0.3}):Play()
        end)
        
        handle.MouseLeave:Connect(function()
            if not isResizing then
                TweenService:Create(handle, TweenInfo.new(0.1), {BackgroundTransparency = 0.8}):Play()
            end
        end)
        
        handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isResizing = true
                direction = edge
                startSize = element.Size
                startPos = element.Position
                startMouse = input.Position
            end
        end)
        
        handles[edge] = handle
    end
    
    for _, edge in ipairs(edges) do
        CreateHandle(edge)
    end
    
    UserInputService.InputChanged:Connect(function(input)
        if isResizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - startMouse
            local newSize = startSize
            local newPos = startPos
            
            if direction == "right" or direction == "topRight" or direction == "bottomRight" then
                newSize = UDim2.new(startSize.X.Scale, startSize.X.Offset + delta.X, startSize.Y.Scale, startSize.Y.Offset)
            end
            if direction == "left" or direction == "topLeft" or direction == "bottomLeft" then
                newSize = UDim2.new(startSize.X.Scale, startSize.X.Offset - delta.X, startSize.Y.Scale, startSize.Y.Offset)
                newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset)
            end
            if direction == "bottom" or direction == "bottomLeft" or direction == "bottomRight" then
                newSize = UDim2.new(startSize.X.Scale, startSize.X.Offset, startSize.Y.Scale, startSize.Y.Offset + delta.Y)
            end
            if direction == "top" or direction == "topLeft" or direction == "topRight" then
                newSize = UDim2.new(startSize.X.Scale, startSize.X.Offset, startSize.Y.Scale, startSize.Y.Offset - delta.Y)
                newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
            
            if config.MinSize then
                newSize = UDim2.new(newSize.X.Scale, math.max(newSize.X.Offset, config.MinSize.X), newSize.Y.Scale, math.max(newSize.Y.Offset, config.MinSize.Y))
            end
            if config.MaxSize then
                newSize = UDim2.new(newSize.X.Scale, math.min(newSize.X.Offset, config.MaxSize.X), newSize.Y.Scale, math.min(newSize.Y.Offset, config.MaxSize.Y))
            end
            
            element.Size = newSize
            element.Position = newPos
            if config.OnResize then config.OnResize(element.Size) end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and isResizing then
            isResizing = false
            for _, handle in pairs(handles) do
                TweenService:Create(handle, TweenInfo.new(0.1), {BackgroundTransparency = 0.8}):Play()
            end
        end
    end)
    
    return {
        Handles = handles,
        SetEnabled = function(enabled)
            for _, handle in pairs(handles) do
                handle.Visible = enabled
            end
        end,
    }
end

NoirUI.Keybind = {}

function NoirUI.Keybind.Create(parent, config)
    config = config or {}
    
    local container = Create("Frame", {
        Size = config.Size or UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        LayoutOrder = config.LayoutOrder or 0,
    }, parent)
    
    local label = nil
    if config.Label then
        label = NoirUI.CreateText(container, config.Label, 14, GetColor("Text"), 0, NoirUI.Config.Font, UDim2.new(0, 0, 0, 10), UDim2.new(0, 150, 0, 20))
        label.TextXAlignment = Enum.TextXAlignment.Left
    end
    
    local keyButton = Create("TextButton", {
        Size = UDim2.new(0, 100, 0, 32),
        Position = UDim2.new(1, -100, 0.5, -16),
        BackgroundColor3 = GetColor("Surface"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Text = config.Default or "None",
        TextColor3 = GetColor("Text"),
        TextSize = 13,
        Font = NoirUI.Config.Font,
    }, container)
    
    local buttonCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 6)
    }, keyButton)
    
    local buttonStroke = NoirUI.CreateStroke(keyButton, GetColor("Border"), 1, 0.3)
    
    local isListening = false
    local currentKey = config.Default or "None"
    
    local function GetKeyName(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            return input.KeyCode.Name
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            return "Mouse1"
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            return "Mouse2"
        elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
            return "Mouse3"
        end
        return nil
    end
    
    local function StartListening()
        isListening = true
        keyButton.Text = "..."
        TweenService:Create(keyButton, TweenInfo.new(0.15), {BackgroundColor3 = GetColor("SurfaceHover")}):Play()
    end
    
    local function StopListening()
        isListening = false
        TweenService:Create(keyButton, TweenInfo.new(0.15), {BackgroundColor3 = GetColor("Surface")}):Play()
    end
    
    local function SetKey(key)
        currentKey = key
        keyButton.Text = key
        if config.OnChange then config.OnChange(key) end
    end
    
    keyButton.MouseButton1Click:Connect(function()
        if isListening then
            StopListening()
        else
            StartListening()
        end
    end)
    
    local inputConnection = nil
    local function StartInputListener()
        if inputConnection then inputConnection:Disconnect() end
        inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if isListening then
                local key = GetKeyName(input)
                if key then
                    SetKey(key)
                    StopListening()
                end
            end
        end)
    end
    
    StartInputListener()
    
    local function Clear()
        SetKey("None")
    end
    
    if config.Default then
        SetKey(config.Default)
    end
    
    return {
        Container = container,
        KeyButton = keyButton,
        GetKey = function() return currentKey end,
        SetKey = SetKey,
        Clear = Clear,
        StartListening = StartListening,
        StopListening = StopListening,
    }
end

NoirUI.ThemeEditor = {}

function NoirUI.ThemeEditor.Create(parent, config)
    config = config or {}
    
    local container = Create("Frame", {
        Size = config.Size or UDim2.new(1, 0, 0, 500),
        BackgroundColor3 = GetColor("Surface"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        LayoutOrder = config.LayoutOrder or 0,
    }, parent)
    
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, 12)
    }, container)
    
    local stroke = NoirUI.CreateStroke(container, GetColor("Border"), 1, 0.3)
    
    local themeSelector = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = GetColor("SurfaceHover"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
    }, container)
    
    local themeCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 12)
    }, themeSelector)
    
    local themeLabel = NoirUI.CreateText(themeSelector, "当前主题: " .. NoirUI.Config.Theme, 14, GetColor("Text"), 0, NoirUI.Config.Font, UDim2.new(0, 16, 0.5, -8), UDim2.new(0, 150, 0, 16))
    themeLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local themeBtn = NoirUI.Button.Create(themeSelector, "切换主题", function()
        local newTheme = NoirUI.Config.Theme == "Dark" and "Light" or "Dark"
        NoirUI.SetTheme(newTheme)
        themeLabel.Text = "当前主题: " .. NoirUI.Config.Theme
        if config.OnThemeChange then config.OnThemeChange(newTheme) end
    end, 100, 32)
    themeBtn.Position = UDim2.new(1, -116, 0.5, -16)
    
    local scrollFrame = Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, -56),
        Position = UDim2.new(0, 0, 0, 56),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
    }, container)
    
    local editorBody = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
    }, scrollFrame)
    
    local editorLayout = NoirUI.CreateListLayout(editorBody, "vertical", 12)
    
    local colorItems = {}
    
    local colorKeys = {
        {Key = "Background", Name = "背景色"},
        {Key = "Surface", Name = "表面色"},
        {Key = "SurfaceHover", Name = "悬停表面色"},
        {Key = "Primary", Name = "主色调"},
        {Key = "PrimaryHover", Name = "主色悬停"},
        {Key = "Text", Name = "文字色"},
        {Key = "TextSecondary", Name = "次要文字色"},
        {Key = "Border", Name = "边框色"},
        {Key = "Success", Name = "成功色"},
        {Key = "Danger", Name = "危险色"},
        {Key = "Warning", Name = "警告色"},
        {Key = "Info", Name = "信息色"},
    }
    
    for _, colorInfo in ipairs(colorKeys) do
        local itemFrame = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 48),
            BackgroundTransparency = 1,
        }, editorBody)
        
        local itemLabel = NoirUI.CreateText(itemFrame, colorInfo.Name, 14, GetColor("Text"), 0, NoirUI.Config.Font, UDim2.new(0, 16, 0.5, -8), UDim2.new(0, 120, 0, 16))
        itemLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local colorPreview = Create("Frame", {
            Size = UDim2.new(0, 32, 0, 32),
            Position = UDim2.new(1, -148, 0.5, -16),
            BackgroundColor3 = Colors[NoirUI.Config.Theme][colorInfo.Key],
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
        }, itemFrame)
        
        local previewCorner = Create("UICorner", {
            CornerRadius = UDim.new(0, 6)
        }, colorPreview)
        
        local colorPickerBtn = NoirUI.Button.Create(itemFrame, "选择", function()
            local picker = NoirUI.ColorPicker.Create(itemFrame, {
                Default = Colors[NoirUI.Config.Theme][colorInfo.Key],
                OnChange = function(color)
                    Colors[NoirUI.Config.Theme][colorInfo.Key] = color
                    colorPreview.BackgroundColor3 = color
                    NoirUI.OnThemeChanged(NoirUI.Config.Theme)
                    if config.OnColorChange then config.OnColorChange(colorInfo.Key, color) end
                end,
            })
            picker.Container.Size = UDim2.new(0, 280, 0, 320)
            picker.Container.Position = UDim2.new(0.5, -140, 0, 0)
        end, 60, 32)
        colorPickerBtn.Position = UDim2.new(1, -76, 0.5, -16)
        
        local resetBtn = NoirUI.Button.Create(itemFrame, "重置", function()
            Colors[NoirUI.Config.Theme][colorInfo.Key] = Colors[NoirUI.Config.Theme == "Dark" and "Dark" or "Light"][colorInfo.Key]
            colorPreview.BackgroundColor3 = Colors[NoirUI.Config.Theme][colorInfo.Key]
            NoirUI.OnThemeChanged(NoirUI.Config.Theme)
        end, 60, 32)
        resetBtn.Position = UDim2.new(1, -8, 0.5, -16)
        
        table.insert(colorItems, {
            Frame = itemFrame,
            Label = itemLabel,
            Preview = colorPreview,
            Key = colorInfo.Key,
        })
    end
    
    local function UpdateTheme()
        for _, item in ipairs(colorItems) do
            item.Preview.BackgroundColor3 = Colors[NoirUI.Config.Theme][item.Key]
        end
        themeLabel.Text = "当前主题: " .. NoirUI.Config.Theme
    end
    
    NoirUI.OnThemeChanged = function(theme)
        UpdateTheme()
        if config.OnThemeChange then config.OnThemeChange(theme) end
    end
    
    editorBody.Size = UDim2.new(1, 0, 0, #colorItems * 60)
    
    return {
        Container = container,
        ColorItems = colorItems,
        UpdateTheme = UpdateTheme,
    }
end

NoirUI.ConfigManager = {}

function NoirUI.ConfigManager.Create(config)
    config = config or {}
    
    local configs = {}
    local currentConfig = nil
    local savePath = config.SavePath or "NoirUI_Config"
    
    local function SaveConfig(name, data)
        local configData = {
            Name = name,
            Data = data,
            Timestamp = os.time(),
            Version = NoirUI.Version,
        }
        
        if writefile then
            writefile(savePath .. "_" .. name .. ".json", HttpService:JSONEncode(configData))
        end
        
        configs[name] = configData
        return configData
    end
    
    local function LoadConfig(name)
        if writefile and isfile(savePath .. "_" .. name .. ".json") then
            local success, result = pcall(function()
                return HttpService:JSONDecode(readfile(savePath .. "_" .. name .. ".json"))
            end)
            if success then
                configs[name] = result
                return result
            end
        end
        return nil
    end
    
    local function DeleteConfig(name)
        if writefile and isfile(savePath .. "_" .. name .. ".json") then
            delfile(savePath .. "_" .. name .. ".json")
        end
        configs[name] = nil
    end
    
    local function ListConfigs()
        local list = {}
        if writefile and listfiles then
            local files = listfiles(savePath:match("(.+)/[^/]+$") or "")
            for _, file in ipairs(files) do
                local match = file:match(savePath .. "_(.+)%.json")
                if match then
                    table.insert(list, match)
                end
            end
        else
            for name in pairs(configs) do
                table.insert(list, name)
            end
        end
        return list
    end
    
    local function AutoSave(element, key, configName)
        local timer = nil
        local function DebouncedSave()
            if timer then task.cancel(timer) end
            timer = task.delay(0.5, function()
                if currentConfig and currentConfig.Name == configName then
                    currentConfig.Data[key] = element.GetValue()
                    SaveConfig(configName, currentConfig.Data)
                end
            end)
        end
        
        if element.OnChange then
            element.OnChange = function(val)
                if config.OnChange then config.OnChange(val) end
                DebouncedSave()
            end
        end
    end
    
    local function LoadToElement(element, value)
        if element.SetValue then
            element:SetValue(value)
        elseif element.SetText then
            element:SetText(value)
        elseif element.SetChecked then
            element:SetChecked(value)
        end
    end
    
    local function RegisterElement(element, key, configName)
        if not currentConfig or currentConfig.Name ~= configName then
            return
        end
        if currentConfig.Data[key] then
            LoadToElement(element, currentConfig.Data[key])
        end
        AutoSave(element, key, configName)
    end
    
    local function CreateConfig(name, defaultData)
        local existing = LoadConfig(name)
        if existing then
            currentConfig = existing
        else
            currentConfig = {Name = name, Data = defaultData or {}}
            SaveConfig(name, currentConfig.Data)
        end
        if config.OnLoad then config.OnLoad(currentConfig) end
        return currentConfig
    end
    
    local function SwitchConfig(name)
        local loaded = LoadConfig(name)
        if loaded then
            currentConfig = loaded
            if config.OnSwitch then config.OnSwitch(currentConfig) end
            return true
        end
        return false
    end
    
    local function ExportConfig(name)
        local cfg = configs[name] or LoadConfig(name)
        if cfg then
            return HttpService:JSONEncode(cfg)
        end
        return nil
    end
    
    local function ImportConfig(jsonString)
        local success, data = pcall(function()
            return HttpService:JSONDecode(jsonString)
        end)
        if success and data then
            SaveConfig(data.Name, data.Data)
            return true
        end
        return false
    end
    
    return {
        SaveConfig = SaveConfig,
        LoadConfig = LoadConfig,
        DeleteConfig = DeleteConfig,
        ListConfigs = ListConfigs,
        CreateConfig = CreateConfig,
        SwitchConfig = SwitchConfig,
        ExportConfig = ExportConfig,
        ImportConfig = ImportConfig,
        RegisterElement = RegisterElement,
        CurrentConfig = function() return currentConfig end,
    }
end

NoirUI.Responsive = {}

function NoirUI.Responsive.Create(element, config)
    config = config or {}
    
    local breakpoints = config.Breakpoints or {
        {Max = 480, Handler = function() element.Size = UDim2.new(1, -32, 0, 400) end},
        {Max = 768, Handler = function() element.Size = UDim2.new(1, -64, 0, 500) end},
        {Max = 1024, Handler = function() element.Size = UDim2.new(0.9, 0, 0, 600) end},
        {Max = math.huge, Handler = function() element.Size = UDim2.new(0.8, 0, 0, 700) end},
    }
    
    local currentBreakpoint = nil
    
    local function CheckBreakpoint()
        local screenWidth = LP.PlayerGui.AbsoluteSize.X
        for _, bp in ipairs(breakpoints) do
            if screenWidth <= bp.Max then
                if currentBreakpoint ~= bp then
                    currentBreakpoint = bp
                    bp.Handler()
                    if config.OnBreak then config.OnBreak(bp) end
                end
                break
            end
        end
    end
    
    local connection = nil
    local function Start()
        CheckBreakpoint()
        connection = RunService.RenderStepped:Connect(CheckBreakpoint)
    end
    
    local function Stop()
        if connection then connection:Disconnect() end
    end
    
    Start()
    
    return {
        Start = Start,
        Stop = Stop,
        Check = CheckBreakpoint,
        CurrentBreakpoint = function() return currentBreakpoint end,
    }
end

NoirUI.Transition = {}

function NoirUI.Transition.Create(element, config)
    config = config or {}
    
    local transitions = {}
    
    local function FadeIn(duration)
        duration = duration or 0.3
        element.BackgroundTransparency = 1
        element.Visible = true
        TweenService:Create(element, TweenInfo.new(duration), {BackgroundTransparency = 0}):Play()
    end
    
    local function FadeOut(duration, onComplete)
        duration = duration or 0.3
        TweenService:Create(element, TweenInfo.new(duration), {BackgroundTransparency = 1}):Play()
        task.delay(duration, function()
            element.Visible = false
            if onComplete then onComplete() end
        end)
    end
    
    local function SlideIn(direction, duration, distance)
        duration = duration or 0.3
        distance = distance or 100
        local startPos = element.Position
        local endPos = startPos
        
        if direction == "left" then
            element.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset - distance, startPos.Y.Scale, startPos.Y.Offset)
            endPos = UDim2.new(startPos.X.Scale, startPos.X.Offset, startPos.Y.Scale, startPos.Y.Offset)
        elseif direction == "right" then
            element.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + distance, startPos.Y.Scale, startPos.Y.Offset)
            endPos = UDim2.new(startPos.X.Scale, startPos.X.Offset, startPos.Y.Scale, startPos.Y.Offset)
        elseif direction == "up" then
            element.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset, startPos.Y.Scale, startPos.Y.Offset - distance)
            endPos = UDim2.new(startPos.X.Scale, startPos.X.Offset, startPos.Y.Scale, startPos.Y.Offset)
        elseif direction == "down" then
            element.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset, startPos.Y.Scale, startPos.Y.Offset + distance)
            endPos = UDim2.new(startPos.X.Scale, startPos.X.Offset, startPos.Y.Scale, startPos.Y.Offset)
        end
        
        element.Visible = true
        TweenService:Create(element, TweenInfo.new(duration), {Position = endPos}):Play()
    end
    
    local function ScaleIn(duration, fromScale, toScale)
        duration = duration or 0.3
        fromScale = fromScale or 0.8
        toScale = toScale or 1
        
        local scaleObj = Instance.new("UIScale")
        scaleObj.Scale = fromScale
        scaleObj.Parent = element
        
        element.Visible = true
        TweenService:Create(scaleObj, TweenInfo.new(duration), {Scale = toScale}):Play()
        task.delay(duration, function()
            scaleObj:Destroy()
        end)
    end
    
    local function Pulse(color, duration)
        duration = duration or 0.3
        local originalColor = element.BackgroundColor3
        TweenService:Create(element, TweenInfo.new(duration / 2), {BackgroundColor3 = color or GetColor("Primary")}):Play()
        task.delay(duration / 2, function()
            TweenService:Create(element, TweenInfo.new(duration / 2), {BackgroundColor3 = originalColor}):Play()
        end)
    end
    
    local function Shake(intensity, duration)
        intensity = intensity or 5
        duration = duration or 0.3
        local originalPos = element.Position
        local startTime = tick()
        
        local connection
        connection = RunService.RenderStepped:Connect(function()
            local elapsed = tick() - startTime
            if elapsed >= duration then
                element.Position = originalPos
                connection:Disconnect()
                return
            end
            local offsetX = math.sin(elapsed * 50) * intensity * (1 - elapsed / duration)
            element.Position = UDim2.new(originalPos.X.Scale, originalPos.X.Offset + offsetX, originalPos.Y.Scale, originalPos.Y.Offset)
        end)
    end
    
    return {
        FadeIn = FadeIn,
        FadeOut = FadeOut,
        SlideIn = SlideIn,
        ScaleIn = ScaleIn,
        Pulse = Pulse,
        Shake = Shake,
    }
end

NoirUI.Demo = {}

function NoirUI.Demo.CreateWindow()
    local window = NoirUI.CreateWindow({
        Title = "NoirUI 演示窗口",
        Size = UDim2.new(0, 800, 0, 600),
        Position = UDim2.new(0.5, -400, 0.5, -300),
        OnCreate = function(w)
            print("窗口已创建")
        end,
        OnClose = function()
            print("窗口已关闭")
        end,
    })
    
    local tabContainer = NoirUI.Tabs.Create(window.ContentArea, {
        Tabs = {
            {Title = "组件", Width = 80},
            {Title = "表单", Width = 80},
            {Title = "数据", Width = 80},
            {Title = "关于", Width = 80},
        },
        OnChange = function(index, tab)
            print("切换到:", tab.Title)
        end,
    })
    
    local tab1 = tabContainer.Contents[1]
    local tab2 = tabContainer.Contents[2]
    local tab3 = tabContainer.Contents[3]
    local tab4 = tabContainer.Contents[4]
    
    local layout1 = NoirUI.CreateListLayout(tab1, "vertical", 12)
    local padding1 = NoirUI.CreatePadding(tab1, 16, 16, 16, 16)
    
    NoirUI.Button.CreatePrimary(tab1, "主要按钮", function() print("点击了主要按钮") end, 150)
    NoirUI.Button.CreateSecondary(tab1, "次要按钮", function() print("点击了次要按钮") end, 150)
    NoirUI.Button.CreateDanger(tab1, "危险按钮", function() print("点击了危险按钮") end, 150)
    
    NoirUI.CreateDivider(tab1, 1, nil, 1)
    NoirUI.CreateSpacing(tab1, 8)
    
    local toggle = NoirUI.Toggle.Create(tab1, {Label = "开关组件", Default = true, OnChange = function(v) print("开关状态:", v) end})
    local checkbox = NoirUI.Checkbox.Create(tab1, {Label = "复选框组件", Default = false, OnChange = function(v) print("复选框状态:", v) end})
    
    NoirUI.CreateDivider(tab1, 1, nil, 1)
    NoirUI.CreateSpacing(tab1, 8)
    
    local slider = NoirUI.Slider.Create(tab1, {Label = "滑块组件", Min = 0, Max = 100, Default = 50, OnChange = function(v) print("滑块数值:", v) end})
    
    local layout2 = NoirUI.CreateListLayout(tab2, "vertical", 12)
    local padding2 = NoirUI.CreatePadding(tab2, 16, 16, 16, 16)
    
    local input = NoirUI.Input.Create(tab2, {Label = "文本输入", Placeholder = "请输入内容", Default = "", OnChange = function(v) print("输入内容:", v) end})
    local numberInput = NoirUI.Input.CreateNumber(tab2, {Label = "数字输入", Min = 0, Max = 100, Default = 50, OnChange = function(v) print("数字:", v) end})
    local dropdown = NoirUI.Dropdown.Create(tab2, {Label = "下拉选择", Options = {"选项1", "选项2", "选项3"}, Default = "选项1", OnChange = function(v) print("选择:", v) end})
    
    local layout3 = NoirUI.CreateListLayout(tab3, "vertical", 12)
    local padding3 = NoirUI.CreatePadding(tab3, 16, 16, 16, 16)
    
    local progressBar = NoirUI.Loading.CreateProgressBar(tab3, 300, 8, GetColor("Primary"))
    progressBar.Container.Position = UDim2.new(0, 0, 0, 0)
    progressBar.AnimateTo(0.75, 1)
    
    local rating = NoirUI.Rating.Create(tab3, {Max = 5, Default = 3, OnChange = function(v) print("评分:", v) end})
    rating.Container.Position = UDim2.new(0, 0, 0, 60)
    
    local layout4 = NoirUI.CreateListLayout(tab4, "vertical", 12)
    local padding4 = NoirUI.CreatePadding(tab4, 16, 16, 16, 16)
    
    local aboutText = NoirUI.CreateText(tab4, "NoirUI v" .. NoirUI.Version .. "\n现代黑色主题UI框架\n\n作者: AI Assistant\n\n包含组件:\n- 按钮 / 开关 / 复选框 / 滑块\n- 输入框 / 下拉菜单 / 标签页\n- 表格 / 列表 / 树形控件\n- 颜色选择器 / 日期选择器\n- 通知 / 弹窗 / 工具提示\n- 图表 / 进度环 / 评分\n- 拖拽排序 / 可调整大小面板\n- 快捷键绑定 / 主题编辑器\n- 配置保存 / 响应式布局\n- 动画过渡效果", 14, GetColor("Text"), 0, NoirUI.Config.Font, UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 400))
    aboutText.TextXAlignment = Enum.TextXAlignment.Left
    aboutText.TextYAlignment = Enum.TextYAlignment.Top
    aboutText.TextWrapped = true
    
    return window
end

return NoirUI
