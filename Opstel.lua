--[[
    Opstel UI Library v2.0
    Modern redesign: glass-morphism, gradients, spring animations
]]

local Opstel = {}
Opstel.__index = Opstel

--// СЕРВИСЫ
local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local CoreGui           = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

--// ТЕМЫ
local Themes = {
    OpstelDark = {
        Background   = Color3.fromRGB(12, 12, 18),
        Surface      = Color3.fromRGB(22, 22, 30),
        Surface2     = Color3.fromRGB(30, 30, 40),
        Border       = Color3.fromRGB(45, 45, 60),
        Text         = Color3.fromRGB(240, 240, 250),
        SubText      = Color3.fromRGB(150, 150, 170),
        Accent1      = Color3.fromRGB(124, 92, 255),
        Accent2      = Color3.fromRGB(78, 156, 255),
        Success      = Color3.fromRGB(80, 220, 140),
        Danger       = Color3.fromRGB(255, 90, 100),
    },
    OpstelLight = {
        Background   = Color3.fromRGB(245, 245, 250),
        Surface      = Color3.fromRGB(255, 255, 255),
        Surface2     = Color3.fromRGB(238, 238, 245),
        Border       = Color3.fromRGB(215, 215, 225),
        Text         = Color3.fromRGB(20, 20, 30),
        SubText      = Color3.fromRGB(100, 100, 120),
        Accent1      = Color3.fromRGB(110, 80, 240),
        Accent2      = Color3.fromRGB(60, 140, 240),
        Success      = Color3.fromRGB(40, 190, 110),
        Danger       = Color3.fromRGB(230, 70, 80),
    },
}

--// УТИЛИТЫ
local function Create(className, props, children)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do obj[k] = v end
    for _, c in ipairs(children or {}) do c.Parent = obj end
    return obj
end

local function Corner(radius, parent)
    return Create("UICorner", { CornerRadius = UDim.new(0, radius or 8), Parent = parent })
end

local function Stroke(color, thickness, transparency, parent)
    return Create("UIStroke", {
        Color = color,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent
    })
end

local function Gradient(c1, c2, rotation, parent)
    return Create("UIGradient", {
        Color = ColorSequence.new(c1, c2),
        Rotation = rotation or 90,
        Parent = parent
    })
end

local function Padding(t, r, b, l, parent)
    return Create("UIPadding", {
        PaddingTop    = UDim.new(0, t or 0),
        PaddingRight  = UDim.new(0, r or t or 0),
        PaddingBottom = UDim.new(0, b or t or 0),
        PaddingLeft   = UDim.new(0, l or r or t or 0),
        Parent = parent
    })
end

-- Spring-анимация (bounce)
local function Spring(obj, time, goal, style)
    local info = TweenInfo.new(time or 0.35, style or Enum.EasingStyle.Back,
        Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, info, goal)
    t:Play()
    return t
end

local function Tween(obj, time, goal, style, dir)
    local info = TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quart,
        dir or Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, info, goal)
    t:Play()
    return t
end

-- Ripple эффект на кнопке
local function Ripple(parent, theme)
    local ripple = Create("Frame", {
        Parent = parent,
        BackgroundColor3 = theme.Text,
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 0, 0, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        ZIndex = 10,
    })
    Corner(100, ripple)
    Tween(ripple, 0.5, {
        Size = UDim2.new(0, 300, 0, 300),
        BackgroundTransparency = 1
    }, Enum.EasingStyle.Quad)
    task.delay(0.5, function() ripple:Destroy() end)
end

--// МЕНЕДЖЕР УВЕДОМЛЕНИЙ
local NotifyHolder
local function ensureNotifyHolder(screenGui)
    if NotifyHolder and NotifyHolder.Parent then return NotifyHolder end
    NotifyHolder = Create("Frame", {
        Parent = screenGui,
        Name = "Notifications",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -20, 0, 20),
        Size = UDim2.new(0, 300, 1, -40),
        BackgroundTransparency = 1,
    })
    Create("UIListLayout", {
        Parent = NotifyHolder,
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
    })
    return NotifyHolder
end

local function Notify(screenGui, theme, title, text, duration)
    local holder = ensureNotifyHolder(screenGui)
    local notif = Create("Frame", {
        Parent = holder,
        Size = UDim2.new(1, 0, 0, 68),
        BackgroundColor3 = theme.Surface,
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    })
    Corner(12, notif)
    Stroke(theme.Border, 1, 0.3, notif)
    Gradient(theme.Accent1, theme.Accent2, 0, notif)

    local accentBar = Create("Frame", {
        Parent = notif,
        Size = UDim2.new(0, 4, 1, -16),
        Position = UDim2.new(0, 8, 0, 8),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
    })
    Corner(2, accentBar)

    Create("TextLabel", {
        Parent = notif,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 10),
        Size = UDim2.new(1, -30, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = title or "Opstel",
        TextSize = 14,
        TextColor3 = Color3.new(1, 1, 1),
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    Create("TextLabel", {
        Parent = notif,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 30),
        Size = UDim2.new(1, -30, 0, 30),
        Font = Enum.Font.Gotham,
        Text = text or "",
        TextSize = 12,
        TextColor3 = Color3.new(0.9, 0.9, 0.95),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
    })

    -- Анимация появления
    notif.Position = UDim2.new(1, 40, 0, 0)
    Spring(notif, 0.4, { Position = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Back)

    -- Прогресс-бар
    local progress = Create("Frame", {
        Parent = notif,
        Position = UDim2.new(0, 0, 1, -3),
        Size = UDim2.new(1, 0, 0, 3),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
    })
    Tween(progress, duration or 3, { Size = UDim2.new(0, 0, 0, 3) }, Enum.EasingStyle.Linear)

    task.delay(duration or 3, function()
        local tw = Tween(notif, 0.3, { Position = UDim2.new(1, 60, 0, 0), BackgroundTransparency = 1 })
        tw.Completed:Connect(function() notif:Destroy() end)
    end)
end

--// СОЗДАНИЕ ОКНА
function Opstel:CreateWindow(title, themeName)
    local theme = Themes[themeName] or Themes.OpstelDark
    local W, H = 640, 420

    -- ЭКРАН
    local ScreenGui = Create("ScreenGui", {
        Name = "OpstelUI_" .. tostring(math.random(10000, 99999)),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    -- MAIN
    local Main = Create("Frame", {
        Name = "Main",
        Parent = ScreenGui,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, W, 0, H),
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        Active = true,
    })
    Corner(14, Main)
    Stroke(theme.Border, 1, 0.4, Main)

    -- ТОНКАЯ ГРАДИЕНТНАЯ РАМКА СВЕРХУ
    local topGlow = Create("Frame", {
        Parent = Main,
        Size = UDim2.new(1, -24, 0, 2),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
    })
    Corner(1, topGlow)
    Gradient(theme.Accent1, theme.Accent2, 0, topGlow)

    -- ТЕНЬ (мягкая, через ImageLabel)
    local Shadow = Create("ImageLabel", {
        Parent = Main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -30, 0, -30),
        Size = UDim2.new(1, 60, 1, 60),
        Image = "rbxassetid://5554236805",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.5,
        ZIndex = -1,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
    })

    -- ХЕДЕР
    local Header = Create("Frame", {
        Name = "Header",
        Parent = Main,
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundTransparency = 1,
    })

    -- ТОЧКА-ИНДИКАТОР + НАЗВАНИЕ
    local brandDot = Create("Frame", {
        Parent = Header,
        Position = UDim2.new(0, 18, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = theme.Accent1,
        BorderSizePixel = 0,
    })
    Corner(5, brandDot)
    Gradient(theme.Accent1, theme.Accent2, 45, brandDot)

    Create("TextLabel", {
        Parent = Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 36, 0, 0),
        Size = UDim2.new(0, 260, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = title or "Opstel",
        TextSize = 16,
        TextColor3 = theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    -- КНОПКИ УПРАВЛЕНИЯ
    local function makeControl(symbol, offsetX, hoverColor)
        local btn = Create("TextButton", {
            Parent = Header,
            BackgroundColor3 = theme.Surface2,
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, offsetX, 0.5, 0),
            Size = UDim2.new(0, 28, 0, 28),
            Text = symbol,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextColor3 = theme.SubText,
            AutoButtonColor = false,
            BorderSizePixel = 0,
        })
        Corner(8, btn)
        btn.MouseEnter:Connect(function()
            Tween(btn, 0.15, { BackgroundTransparency = 0, TextColor3 = hoverColor or theme.Text })
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, 0.15, { BackgroundTransparency = 1, TextColor3 = theme.SubText })
        end)
        return btn
    end

    local closeBtn  = makeControl("✕", -12, theme.Danger)
    local minBtn    = makeControl("—", -46, theme.Text)

    -- SIDEBAR
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Parent = Main,
        Position = UDim2.new(0, 12, 0, 56),
        Size = UDim2.new(0, 168, 1, -68),
        BackgroundColor3 = theme.Surface,
        BorderSizePixel = 0,
        BackgroundTransparency = 0.2,
    })
    Corner(12, Sidebar)
    Stroke(theme.Border, 1, 0.5, Sidebar)

    local TabList = Create("ScrollingFrame", {
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 8),
        Size = UDim2.new(1, -16, 1, -16),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = theme.Accent1,
        BorderSizePixel = 0,
    })
    Create("UIListLayout", {
        Parent = TabList,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    -- CONTENT
    local Content = Create("Frame", {
        Name = "Content",
        Parent = Main,
        Position = UDim2.new(0, 192, 0, 56),
        Size = UDim2.new(1, -204, 1, -68),
        BackgroundColor3 = theme.Surface,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    })
    Corner(12, Content)
    Stroke(theme.Border, 1, 0.5, Content)

    -- ОБЪЕКТ ОКНА
    local Window = { __tabs = {}, Theme = theme, ScreenGui = ScreenGui }

    --// УВЕДОМЛЕНИЯ
    function Window:Notify(nTitle, nText, dur)
        Notify(ScreenGui, theme, nTitle or title, nText or "", dur or 3)
    end

    --// СОЗДАНИЕ ВКЛАДКИ
    function Window:CreateTab(name, icon)
        local TabButton = Create("TextButton", {
            Parent = TabList,
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = theme.Surface2,
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            BorderSizePixel = 0,
        })
        Corner(8, TabButton)

        local indicator = Create("Frame", {
            Parent = TabButton,
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.new(0, 3, 0.5, 0),
            BackgroundColor3 = theme.Accent1,
            BorderSizePixel = 0,
        })
        Corner(2, indicator)
        Gradient(theme.Accent1, theme.Accent2, 90, indicator)
        indicator.Visible = false

        local iconLabel = Create("TextLabel", {
            Parent = TabButton,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0, 0),
            Size = UDim2.new(0, 20, 1, 0),
            Text = icon or "◆",
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextColor3 = theme.SubText,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        local nameLabel = Create("TextLabel", {
            Parent = TabButton,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 36, 0, 0),
            Size = UDim2.new(1, -44, 1, 0),
            Text = name or "Tab",
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            TextColor3 = theme.SubText,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        local TabContent = Create("ScrollingFrame", {
            Parent = Content,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -20, 1, -20),
            Position = UDim2.new(0, 10, 0, 10),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = theme.Accent1,
            Visible = false,
            BorderSizePixel = 0,
        })
        Create("UIListLayout", {
            Parent = TabContent,
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })
        Padding(0, 4, 0, 0, TabContent)

        local Tab = { __elements = {}, __button = TabButton, __content = TabContent }

        local function activate()
            for _, t in ipairs(Window.__tabs) do
                t.__content.Visible = false
                Tween(t.__button, 0.15, { BackgroundTransparency = 1 })
                Tween(t.__button.NameLabel, 0.15, { TextColor3 = theme.SubText })
                Tween(t.__button.IconLabel, 0.15, { TextColor3 = theme.SubText })
                t.__button.Indicator.Visible = false
                Tween(t.__button.Indicator, 0.2, { Size = UDim2.new(0, 3, 0.5, 0) })
            end
            TabContent.Visible = true
            Tween(TabButton, 0.2, { BackgroundTransparency = 0.35 })
            Tween(nameLabel, 0.2, { TextColor3 = theme.Text })
            Tween(iconLabel, 0.2, { TextColor3 = theme.Accent1 })
            indicator.Visible = true
            indicator.Size = UDim2.new(0, 3, 0, 0)
            Spring(indicator, 0.35, { Size = UDim2.new(0, 3, 0.5, 0) })
        end

        TabButton.NameLabel = nameLabel
        TabButton.IconLabel = iconLabel
        TabButton.Indicator = indicator

        TabButton.MouseEnter:Connect(function()
            if not TabContent.Visible then
                Tween(TabButton, 0.15, { BackgroundTransparency = 0.7 })
            end
        end)
        TabButton.MouseLeave:Connect(function()
            if not TabContent.Visible then
                Tween(TabButton, 0.15, { BackgroundTransparency = 1 })
            end
        end)
        TabButton.MouseButton1Click:Connect(activate)

        if #Window.__tabs == 0 then
            task.defer(activate)
        end

        table.insert(Window.__tabs, Tab)
        Tab.__window = Window
        Tab.__theme = theme
        return Tab
    end

    --// УПРАВЛЕНИЕ ОКНОМ
    closeBtn.MouseButton1Click:Connect(function()
        Tween(Main, 0.25, { Size = UDim2.new(0, W, 0, 0), BackgroundTransparency = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.25)
        ScreenGui:Destroy()
    end)

    local minimized = false
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(Main, 0.3, { Size = UDim2.new(0, W, 0, 52) }, Enum.EasingStyle.Quart)
        else
            Tween(Main, 0.3, { Size = UDim2.new(0, W, 0, H) }, Enum.EasingStyle.Quart)
        end
    end)

    --// ПЕРЕТАСКИВАНИЕ
    do
        local dragging, dragStart, startPos
        Header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = Main.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
                local d = input.Position - dragStart
                Main.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + d.X,
                    startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end

    return Window
end

--// ХЕЛПЕР ЭЛЕМЕНТА (карточка)
local function makeCard(tab, height)
    local el = Create("Frame", {
        Parent = tab.__content,
        Size = UDim2.new(1, 0, 0, height or 40),
        BackgroundColor3 = tab.__theme.Surface2,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
    })
    Corner(10, el)
    Stroke(tab.__theme.Border, 1, 0.4, el)
    return el
end

--// МЕТОДЫ ВКЛАДКИ
local TabMethods = {}

function TabMethods:CreateSection(name)
    local holder = Create("Frame", {
        Parent = self.__content,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
    })
    Create("TextLabel", {
        Parent = holder,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 4, 0, 0),
        Size = UDim2.new(1, -8, 1, 0),
        Text = string.upper(name or "SECTION"),
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = self.__theme.SubText,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local line = Create("Frame", {
        Parent = holder,
        Position = UDim2.new(0, 4, 1, -4),
        Size = UDim2.new(0, 30, 0, 1),
        BackgroundColor3 = self.__theme.Accent1,
        BorderSizePixel = 0,
    })
    Gradient(self.__theme.Accent1, self.__theme.Accent2, 0, line)
    return holder
end

-- КНОПКА
function TabMethods:CreateButton(text, callback)
    local btn = makeCard(self, 38)
    local label = Create("TextLabel", {
        Parent = btn,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(1, -28, 1, 0),
        Text = text or "Button",
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = self.__theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local clickable = Create("TextButton", {
        Parent = btn, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0), Text = "",
    })
    clickable.MouseEnter:Connect(function()
        Tween(btn, 0.2, { BackgroundColor3 = self.__theme.Surface, BackgroundTransparency = 0 })
        Tween(label, 0.2, { TextColor3 = self.__theme.Accent1 })
    end)
    clickable.MouseLeave:Connect(function()
        Tween(btn, 0.2, { BackgroundColor3 = self.__theme.Surface2, BackgroundTransparency = 0.4 })
        Tween(label, 0.2, { TextColor3 = self.__theme.Text })
    end)
    clickable.MouseButton1Down:Connect(function()
        Tween(btn, 0.1, { Size = UDim2.new(0.98, 0, 0, 38) })
    end)
    clickable.MouseButton1Up:Connect(function()
        Spring(btn, 0.3, { Size = UDim2.new(1, 0, 0, 38) })
    end)
    clickable.MouseButton1Click:Connect(function()
        Ripple(btn, self.__theme)
        if callback then
            local ok, err = pcall(callback)
            if not ok then warn("[Opstel] Button: " .. tostring(err)) end
        end
    end)
    return { Button = clickable, Frame = btn }
end

-- ПЕРЕКЛЮЧАТЕЛЬ
function TabMethods:CreateToggle(text, default, callback)
    local state = default and true or false
    local toggle = makeCard(self, 40)

    Create("TextLabel", {
        Parent = toggle,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(1, -80, 1, 0),
        Text = text or "Toggle",
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = self.__theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local switchBg = Create("Frame", {
        Parent = toggle,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.new(0, 42, 0, 22),
        BackgroundColor3 = state and self.__theme.Accent1 or self.__theme.Surface,
        BorderSizePixel = 0,
    })
    Corner(11, switchBg)
    Stroke(self.__theme.Border, 1, 0.5, switchBg)

    local grad = Gradient(self.__theme.Accent1, self.__theme.Accent2, 0, switchBg)
    grad.Enabled = state

    local knob = Create("Frame", {
        Parent = switchBg,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = state and UDim2.new(1, -4, 0.5, 0) or UDim2.new(0, 4, 0.5, 0),
        Size = UDim2.new(0, 16, 0, 16),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 2,
    })
    Corner(8, knob)

    local clickable = Create("TextButton", {
        Parent = toggle, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0), Text = "", ZIndex = 3,
    })

    local function render(animate)
        if animate == false then
            switchBg.BackgroundColor3 = state and self.__theme.Accent1 or self.__theme.Surface
            grad.Enabled = state
            knob.Position = state and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 4, 0.5, 0)
            return
        end
        Tween(switchBg, 0.2, {
            BackgroundColor3 = state and self.__theme.Accent1 or self.__theme.Surface
        })
        grad.Enabled = state
        Spring(knob, 0.3, {
            Position = state and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 4, 0.5, 0)
        })
    end

    clickable.MouseButton1Click:Connect(function()
        state = not state
        render()
        if callback then
            local ok, err = pcall(callback, state)
            if not ok then warn("[Opstel] Toggle: " .. tostring(err)) end
        end
    end)

    return {
        Set = function(v) state = v and true or false; render(false) end,
        Get = function() return state end,
    }
end

-- СЛАЙДЕР
function TabMethods:CreateSlider(text, min, max, default, callback)
    min, max = min or 0, max or 100
    local value = math.clamp(default or min, min, max)
    local slider = makeCard(self, 56)

    local label = Create("TextLabel", {
        Parent = slider,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 6),
        Size = UDim2.new(1, -90, 0, 18),
        Text = text or "Slider",
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = self.__theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local valueLabel = Create("TextLabel", {
        Parent = slider,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -80, 0, 6),
        Size = UDim2.new(0, 66, 0, 18),
        Text = tostring(value),
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = self.__theme.Accent1,
        TextXAlignment = Enum.TextXAlignment.Right,
    })

    local barBg = Create("Frame", {
        Parent = slider,
        Position = UDim2.new(0, 14, 0, 34),
        Size = UDim2.new(1, -28, 0, 6),
        BackgroundColor3 = self.__theme.Surface,
        BorderSizePixel = 0,
    })
    Corner(3, barBg)

    local barFill = Create("Frame", {
        Parent = barBg,
        Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = self.__theme.Accent1,
        BorderSizePixel = 0,
    })
    Corner(3, barFill)
    Gradient(self.__theme.Accent1, self.__theme.Accent2, 0, barFill)

    local knob = Create("Frame", {
        Parent = barFill,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 14, 0, 14),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 2,
    })
    Corner(7, knob)
    Stroke(self.__theme.Accent1, 2, 0, knob)

    local dragging = false
    local function update(input)
        local rel = math.clamp((input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
        value = math.floor(min + (max - min) * rel + 0.5)
        barFill.Size = UDim2.new(rel, 0, 1, 0)
        valueLabel.Text = tostring(value)
        if callback then
            local ok, err = pcall(callback, value)
            if not ok then warn("[Opstel] Slider: " .. tostring(err)) end
        end
    end

    barBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            Spring(knob, 0.2, { Size = UDim2.new(0, 18, 0, 18) })
            update(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            Tween(knob, 0.2, { Size = UDim2.new(0, 14, 0, 14) })
        end
    end)

    return {
        Set = function(v)
            value = math.clamp(v, min, max)
            local rel = (value - min) / (max - min)
            barFill.Size = UDim2.new(rel, 0, 1, 0)
            valueLabel.Text = tostring(value)
        end,
        Get = function() return value end,
    }
end

-- ТЕКСТОВОЕ ПОЛЕ
function TabMethods:CreateTextBox(text, placeholder, callback)
    local box = makeCard(self, 42)
    Create("TextLabel", {
        Parent = box,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(0.4, -14, 1, 0),
        Text = text or "Input",
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = self.__theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local inputFrame = Create("Frame", {
        Parent = box,
        Position = UDim2.new(0.4, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(0.6, -14, 0, 26),
        BackgroundColor3 = self.__theme.Surface,
        BorderSizePixel = 0,
    })
    Corner(6, inputFrame)
    local stroke = Stroke(self.__theme.Border, 1, 0.4, inputFrame)

    local input = Create("TextBox", {
        Parent = inputFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 0),
        Size = UDim2.new(1, -16, 1, 0),
        PlaceholderText = placeholder or "...",
        PlaceholderColor3 = self.__theme.SubText,
        Text = "",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = self.__theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
    })

    input.Focused:Connect(function()
        Tween(stroke, 0.15, { Color = self.__theme.Accent1, Transparency = 0 })
    end)
    input.FocusLost:Connect(function(enter)
        Tween(stroke, 0.15, { Color = self.__theme.Border, Transparency = 0.4 })
        if callback then
            local ok, err = pcall(callback, input.Text, enter)
            if not ok then warn("[Opstel] TextBox: " .. tostring(err)) end
        end
    end)

    return {
        Set = function(t) input.Text = t end,
        Get = function() return input.Text end,
    }
end

-- ВЫПАДАЮЩИЙ СПИСОК
function TabMethods:CreateDropdown(text, options, callback)
    options = options or {}
    local selected = nil
    local opened = false
    local dd = makeCard(self, 42)

    local label = Create("TextLabel", {
        Parent = dd,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(1, -50, 1, 0),
        Text = text or "Dropdown",
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = self.__theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Name = "Label",
    })
    local arrow = Create("TextLabel", {
        Parent = dd,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.new(0, 20, 0, 20),
        Text = "▾",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = self.__theme.SubText,
    })
    local clickable = Create("TextButton", {
        Parent = dd, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0), Text = "",
    })

    local listHolder = Create("Frame", {
        Parent = dd,
        Position = UDim2.new(0, 0, 1, 6),
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = self.__theme.Surface2,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = false,
        ZIndex = 20,
    })
    Corner(10, listHolder)
    Stroke(self.__theme.Border, 1, 0.3, listHolder)

    local list = Create("ScrollingFrame", {
        Parent = listHolder,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -8, 1, -8),
        Position = UDim2.new(0, 4, 0, 4),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = self.__theme.Accent1,
        BorderSizePixel = 0,
    })
    Create("UIListLayout", {
        Parent = list, Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder
    })

    for _, opt in ipairs(options) do
        local item = Create("TextButton", {
            Parent = list,
            Size = UDim2.new(1, 0, 0, 26),
            BackgroundColor3 = self.__theme.Surface,
            BackgroundTransparency = 1,
            Text = "  " .. tostring(opt),
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = self.__theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
            BorderSizePixel = 0,
        })
        Corner(6, item)
        item.MouseEnter:Connect(function()
            Tween(item, 0.1, { BackgroundTransparency = 0, TextColor3 = self.__theme.Accent1 })
        end)
        item.MouseLeave:Connect(function()
            Tween(item, 0.1, { BackgroundTransparency = 1, TextColor3 = self.__theme.Text })
        end)
        item.MouseButton1Click:Connect(function()
            selected = opt
            label.Text = (text or "Dropdown") .. ":  " .. tostring(opt)
            label.TextColor3 = self.__theme.Accent1
            if callback then
                local ok, err = pcall(callback, opt)
                if not ok then warn("[Opstel] Dropdown: " .. tostring(err)) end
            end
        end)
    end

    clickable.MouseButton1Click:Connect(function()
        opened = not opened
        listHolder.Visible = true
        local target = opened
            and UDim2.new(1, 0, 0, math.min(#options * 29 + 8, 150))
            or UDim2.new(1, 0, 0, 0)
        Tween(listHolder, 0.25, { Size = target }, Enum.EasingStyle.Quart)
        Tween(arrow, 0.2, { Rotation = opened and 180 or 0 })
        if not opened then
            task.delay(0.25, function() listHolder.Visible = false end)
        end
    end)

    return {
        Set = function(v)
            selected = v
            label.Text = (text or "Dropdown") .. ":  " .. tostring(v)
        end,
        Get = function() return selected end,
    }
end

-- ПРИМЕНЯЕМ МЕТОДЫ К ВКЛАДКАМ
local TabMT = { __index = TabMethods }

local _origCreateWindow = Opstel.CreateWindow
function Opstel:CreateWindow(title, themeName)
    local win = _origCreateWindow(self, title, themeName)
    local _origCreateTab = win.CreateTab
    win.CreateTab = function(_, name, icon)
        local tab = _origCreateTab(win, name, icon)
        return setmetatable(tab, TabMT)
    end
    return win
end

return Opstel
