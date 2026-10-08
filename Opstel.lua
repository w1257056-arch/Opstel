--[[
    Opstel UI Library
    Автор: (dev fucking opstenal)
    Версия: 1.0
    API совместим с Kavo UI Library
]]

local Opstel = {}
Opstel.__index = Opstel

--// СЕРВИСЫ
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

--// НАСТРОЙКИ ТЕМ
local Themes = {
    DarkTheme = {
        Main          = Color3.fromRGB(25, 25, 25),
        Secondary     = Color3.fromRGB(35, 35, 35),
        Tertiary      = Color3.fromRGB(45, 45, 45),
        Text          = Color3.fromRGB(240, 240, 240),
        SubText       = Color3.fromRGB(170, 170, 170),
        Accent        = Color3.fromRGB(0, 170, 255),
        Outline       = Color3.fromRGB(60, 60, 60),
        Shadow        = Color3.fromRGB(0, 0, 0),
    },
    LightTheme = {
        Main          = Color3.fromRGB(245, 245, 245),
        Secondary     = Color3.fromRGB(230, 230, 230),
        Tertiary      = Color3.fromRGB(215, 215, 215),
        Text          = Color3.fromRGB(30, 30, 30),
        SubText       = Color3.fromRGB(90, 90, 90),
        Accent        = Color3.fromRGB(0, 120, 215),
        Outline       = Color3.fromRGB(200, 200, 200),
        Shadow        = Color3.fromRGB(0, 0, 0),
    },
    OpstelTheme = { -- фирменная тема
        Main          = Color3.fromRGB(18, 18, 22),
        Secondary     = Color3.fromRGB(28, 28, 34),
        Tertiary      = Color3.fromRGB(40, 40, 48),
        Text          = Color3.fromRGB(245, 245, 250),
        SubText       = Color3.fromRGB(160, 160, 175),
        Accent        = Color3.fromRGB(140, 90, 255),
        Outline       = Color3.fromRGB(55, 55, 65),
        Shadow        = Color3.fromRGB(0, 0, 0),
    },
}

--// УТИЛИТЫ
local function Create(className, props, children)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    for _, child in ipairs(children or {}) do
        child.Parent = obj
    end
    return obj
end

local function Corner(radius, parent)
    return Create("UICorner", { CornerRadius = UDim.new(0, radius or 6), Parent = parent })
end

local function Stroke(color, thickness, parent)
    return Create("UIStroke", {
        Color = color,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent
    })
end

local function Padding(top, right, bottom, left, parent)
    return Create("UIPadding", {
        PaddingTop    = UDim.new(0, top or 0),
        PaddingRight  = UDim.new(0, right or top or 0),
        PaddingBottom = UDim.new(0, bottom or top or 0),
        PaddingLeft   = UDim.new(0, left or right or top or 0),
        Parent = parent
    })
end

local function Tween(obj, time, props, style)
    local t = TweenService:Create(obj, TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quad), props)
    t:Play()
    return t
end

--// СОЗДАНИЕ ОКНА
function Opstel:CreateWindow(title, themeName)
    local theme = Themes[themeName] or Themes.DarkTheme

    -- Экран
    local ScreenGui = Create("ScreenGui", {
        Name = "OpstelUI_" .. tostring(math.random(1000, 9999)),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })

    -- Поддержка защищённых мест
    pcall(function()
        ScreenGui.Parent = CoreGui
    end)
    if not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    -- Главный фрейм
    local Main = Create("Frame", {
        Name = "Main",
        Parent = ScreenGui,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 500, 0, 330),
        BackgroundColor3 = theme.Main,
        BorderSizePixel = 0,
        Active = true,
    })
    Corner(10, Main)
    Stroke(theme.Outline, 1, Main)

    -- Тень
    local Shadow = Create("ImageLabel", {
        Parent = Main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -20, 0, -20),
        Size = UDim2.new(1, 40, 1, 40),
        Image = "rbxassetid://5554236805",
        ImageColor3 = theme.Shadow,
        ImageTransparency = 0.4,
        ZIndex = -1,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
    })

    -- Заголовок
    local TitleBar = Create("Frame", {
        Name = "TitleBar",
        Parent = Main,
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = theme.Secondary,
        BorderSizePixel = 0,
    })
    Corner(10, TitleBar)
    Create("Frame", { -- прямые углы снизу
        Parent = TitleBar,
        Position = UDim2.new(0, 0, 1, -8),
        Size = UDim2.new(1, 0, 0, 8),
        BackgroundColor3 = theme.Secondary,
        BorderSizePixel = 0,
    })

    Create("TextLabel", {
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(1, -100, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = title or "Opstel",
        TextColor3 = theme.Text,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    -- Кнопки управления
    local CloseBtn = Create("TextButton", {
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -34, 0, 8),
        Size = UDim2.new(0, 20, 0, 20),
        Text = "×",
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextColor3 = theme.SubText,
        BackgroundColor3 = theme.Tertiary,
        AutoButtonColor = false,
    })
    Corner(4, CloseBtn)

    local MinimizeBtn = Create("TextButton", {
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -60, 0, 8),
        Size = UDim2.new(0, 20, 0, 20),
        Text = "—",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = theme.SubText,
        BackgroundColor3 = theme.Tertiary,
        AutoButtonColor = false,
    })
    Corner(4, MinimizeBtn)

    CloseBtn.MouseEnter:Connect(function() Tween(CloseBtn, 0.15, {TextColor3 = Color3.fromRGB(255, 80, 80)}) end)
    CloseBtn.MouseLeave:Connect(function() Tween(CloseBtn, 0.15, {TextColor3 = theme.SubText}) end)
    MinimizeBtn.MouseEnter:Connect(function() Tween(MinimizeBtn, 0.15, {TextColor3 = theme.Accent}) end)
    MinimizeBtn.MouseLeave:Connect(function() Tween(MinimizeBtn, 0.15, {TextColor3 = theme.SubText}) end)

    CloseBtn.MouseButton1Click:Connect(function()
        Tween(Main, 0.2, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1})
        task.wait(0.2)
        ScreenGui:Destroy()
    end)

    local minimized = false
    MinimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(Main, 0.25, {Size = UDim2.new(0, 500, 0, 36)})
        else
            Tween(Main, 0.25, {Size = UDim2.new(0, 500, 0, 330)})
        end
    end)

    --// Перетаскивание
    do
        local dragging, dragStart, startPos
        TitleBar.InputBegan:Connect(function(input)
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
                local delta = input.Position - dragStart
                Main.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end

    --// Контейнеры
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Parent = Main,
        Position = UDim2.new(0, 6, 0, 42),
        Size = UDim2.new(0, 130, 1, -48),
        BackgroundColor3 = theme.Secondary,
        BorderSizePixel = 0,
    })
    Corner(8, Sidebar)

    local TabList = Create("ScrollingFrame", {
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 6, 0, 6),
        Size = UDim2.new(1, -12, 1, -12),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = theme.Accent,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        BorderSizePixel = 0,
    })
    Create("UIListLayout", {
        Parent = TabList,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    local Content = Create("Frame", {
        Name = "Content",
        Parent = Main,
        Position = UDim2.new(0, 142, 0, 42),
        Size = UDim2.new(1, -148, 1, -48),
        BackgroundColor3 = theme.Secondary,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    })
    Corner(8, Content)

    --// Объект окна
    local Window = {}
    Window.__tabs = {}
    Window.Theme = theme

    --// Создание вкладки
    function Window:CreateTab(name, icon)
        local TabButton = Create("TextButton", {
            Parent = TabList,
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = theme.Main,
            BackgroundTransparency = 0.4,
            Text = "  " .. (name or "Tab"),
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextColor3 = theme.SubText,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
            BorderSizePixel = 0,
        })
        Corner(6, TabButton)

        local TabContent = Create("ScrollingFrame", {
            Parent = Content,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -12, 1, -12),
            Position = UDim2.new(0, 6, 0, 6),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = theme.Accent,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            BorderSizePixel = 0,
        })
        Create("UIListLayout", {
            Parent = TabContent,
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })
        Padding(4, 4, 4, 4, TabContent)

        local Tab = { __elements = {}, __button = TabButton, __content = TabContent }
        Tab.__layout = TabContent:FindFirstChildOfClass("UIListLayout")

        -- Активация
        local function activate()
            for _, t in ipairs(Window.__tabs) do
                t.__content.Visible = false
                Tween(t.__button, 0.15, {BackgroundTransparency = 0.4, TextColor3 = theme.SubText})
            end
            TabContent.Visible = true
            Tween(TabButton, 0.15, {BackgroundTransparency = 0, TextColor3 = theme.Accent})
        end
        TabButton.MouseButton1Click:Connect(activate)

        -- Автоактивация первой вкладки
        if #Window.__tabs == 0 then
            task.defer(activate)
        end

        table.insert(Window.__tabs, Tab)
        Tab.__window = Window
        Tab.__theme = theme
        return Tab
    end

    Main.Visible = true
    Window.__gui = ScreenGui
    Window.__main = Main
    return Window
end

--// ХЕЛПЕР ДЛЯ ЭЛЕМЕНТОВ
local function makeElement(tab, height)
    local el = Create("Frame", {
        Parent = tab.__content,
        Size = UDim2.new(1, 0, 0, height or 32),
        BackgroundColor3 = tab.__theme.Main,
        BorderSizePixel = 0,
        BackgroundTransparency = 0.15,
    })
    Corner(6, el)
    Stroke(tab.__theme.Outline, 1, el)
    return el
end

--// СЕКЦИЯ
function OpstelTabSection(tab, name)
    local sec = Create("TextLabel", {
        Parent = tab.__content,
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = "  " .. (name or "Section"),
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = tab.__theme.SubText,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    return sec
end

--// ПАТЧ: добавляем методы вкладке через метатаблицу
local TabMethods = {}
TabMethods.__index = function(t, k)
    local raw = rawget(TabMethods, k)
    if raw then return raw end
    return nil
end

function TabMethods:CreateSection(name)
    return OpstelTabSection(self, name)
end

--// КНОПКА
function TabMethods:CreateButton(text, callback)
    local btn = makeElement(self, 30)
    local label = Create("TextLabel", {
        Parent = btn,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -12, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        Text = text or "Button",
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = self.__theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local clickable = Create("TextButton", {
        Parent = btn,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
    })
    clickable.MouseEnter:Connect(function()
        Tween(btn, 0.15, {BackgroundColor3 = self.__theme.Tertiary})
    end)
    clickable.MouseLeave:Connect(function()
        Tween(btn, 0.15, {BackgroundColor3 = self.__theme.Main})
    end)
    clickable.MouseButton1Click:Connect(function()
        if callback then
            local ok, err = pcall(callback)
            if not ok then warn("[Opstel] Button error: " .. tostring(err)) end
        end
    end)
    return { Button = clickable, Frame = btn }
end

--// ПЕРЕКЛЮЧАТЕЛЬ
function TabMethods:CreateToggle(text, default, callback)
    local state = default and true or false
    local toggle = makeElement(self, 30)
    Create("TextLabel", {
        Parent = toggle,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 0),
        Size = UDim2.new(1, -70, 1, 0),
        Text = text or "Toggle",
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = self.__theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local switchBg = Create("Frame", {
        Parent = toggle,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.new(0, 36, 0, 18),
        BackgroundColor3 = state and self.__theme.Accent or self.__theme.Tertiary,
        BorderSizePixel = 0,
    })
    Corner(9, switchBg)
    local knob = Create("Frame", {
        Parent = switchBg,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = state and UDim2.new(1, -3, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
        Size = UDim2.new(0, 12, 0, 12),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
    })
    Corner(6, knob)

    local clickable = Create("TextButton", {
        Parent = toggle, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0), Text = "",
    })

    local function render()
        Tween(switchBg, 0.15, {
            BackgroundColor3 = state and self.__theme.Accent or self.__theme.Tertiary
        })
        Tween(knob, 0.15, {
            Position = state and UDim2.new(1, -15, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
        })
    end

    clickable.MouseButton1Click:Connect(function()
        state = not state
        render()
        if callback then
            local ok, err = pcall(callback, state)
            if not ok then warn("[Opstel] Toggle error: " .. tostring(err)) end
        end
    end)

    return {
        Set = function(v)
            state = v and true or false
            render()
        end,
        Get = function() return state end,
    }
end

--// СЛАЙДЕР
function TabMethods:CreateSlider(text, min, max, default, callback)
    min, max = min or 0, max or 100
    local value = math.clamp(default or min, min, max)
    local slider = makeElement(self, 46)

    local label = Create("TextLabel", {
        Parent = slider,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 2),
        Size = UDim2.new(1, -60, 0, 18),
        Text = text or "Slider",
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = self.__theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local valueLabel = Create("TextLabel", {
        Parent = slider,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -55, 0, 2),
        Size = UDim2.new(0, 50, 0, 18),
        Text = tostring(value),
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = self.__theme.Accent,
        TextXAlignment = Enum.TextXAlignment.Right,
    })

    local barBg = Create("Frame", {
        Parent = slider,
        Position = UDim2.new(0, 8, 0, 30),
        Size = UDim2.new(1, -16, 0, 6),
        BackgroundColor3 = self.__theme.Tertiary,
        BorderSizePixel = 0,
    })
    Corner(3, barBg)
    local barFill = Create("Frame", {
        Parent = barBg,
        Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = self.__theme.Accent,
        BorderSizePixel = 0,
    })
    Corner(3, barFill)
    local knob = Create("Frame", {
        Parent = barFill,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 12, 0, 12),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
    })
    Corner(6, knob)

    local dragging = false
    local function update(input)
        local rel = math.clamp((input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
        value = math.floor(min + (max - min) * rel + 0.5)
        barFill.Size = UDim2.new(rel, 0, 1, 0)
        valueLabel.Text = tostring(value)
        if callback then
            local ok, err = pcall(callback, value)
            if not ok then warn("[Opstel] Slider error: " .. tostring(err)) end
        end
    end

    barBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
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

--// ТЕКСТОВОЕ ПОЛЕ
function TabMethods:CreateTextBox(text, placeholder, callback)
    local box = makeElement(self, 30)
    Create("TextLabel", {
        Parent = box,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 0),
        Size = UDim2.new(0.4, -8, 1, 0),
        Text = text or "Input",
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = self.__theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local inputFrame = Create("Frame", {
        Parent = box,
        Position = UDim2.new(0.4, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(0.6, -10, 0, 22),
        BackgroundColor3 = self.__theme.Tertiary,
        BorderSizePixel = 0,
    })
    Corner(4, inputFrame)
    local input = Create("TextBox", {
        Parent = inputFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 6, 0, 0),
        Size = UDim2.new(1, -12, 1, 0),
        PlaceholderText = placeholder or "...",
        PlaceholderColor3 = self.__theme.SubText,
        Text = "",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = self.__theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
    })
    input.FocusLost:Connect(function(enter)
        if callback then
            local ok, err = pcall(callback, input.Text, enter)
            if not ok then warn("[Opstel] TextBox error: " .. tostring(err)) end
        end
    end)
    return {
        Set = function(t) input.Text = t end,
        Get = function() return input.Text end,
    }
end

--// ВЫПАДАЮЩИЙ СПИСОК
function TabMethods:CreateDropdown(text, options, callback)
    options = options or {}
    local selected = nil
    local opened = false
    local dd = makeElement(self, 30)

    Create("TextLabel", {
        Parent = dd,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 0),
        Size = UDim2.new(1, -30, 1, 0),
        Text = text or "Dropdown",
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = self.__theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Name = "Label",
    })
    local arrow = Create("TextLabel", {
        Parent = dd,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -24, 0, 0),
        Size = UDim2.new(0, 20, 1, 0),
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
        Position = UDim2.new(0, 0, 1, 4),
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = self.__theme.Tertiary,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = false,
        ZIndex = 5,
    })
    Corner(6, listHolder)
    local list = Create("ScrollingFrame", {
        Parent = listHolder,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -8, 1, -8),
        Position = UDim2.new(0, 4, 0, 4),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = self.__theme.Accent,
        BorderSizePixel = 0,
    })
    Create("UIListLayout", {
        Parent = list, Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder
    })

    for _, opt in ipairs(options) do
        local item = Create("TextButton", {
            Parent = list,
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundColor3 = self.__theme.Main,
            BackgroundTransparency = 0.5,
            Text = "  " .. tostring(opt),
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = self.__theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
            BorderSizePixel = 0,
        })
        Corner(4, item)
        item.MouseEnter:Connect(function() Tween(item, 0.1, {BackgroundTransparency = 0}) end)
        item.MouseLeave:Connect(function() Tween(item, 0.1, {BackgroundTransparency = 0.5}) end)
        item.MouseButton1Click:Connect(function()
            selected = opt
            dd.Label.Text = (text or "Dropdown") .. ": " .. tostring(opt)
            if callback then
                local ok, err = pcall(callback, opt)
                if not ok then warn("[Opstel] Dropdown error: " .. tostring(err)) end
            end
        end)
    end

    clickable.MouseButton1Click:Connect(function()
        opened = not opened
        listHolder.Visible = true
        local target = opened and UDim2.new(1, 0, 0, math.min(#options * 27 + 8, 130)) or UDim2.new(1, 0, 0, 0)
        Tween(listHolder, 0.2, {Size = target})
        arrow.Text = opened and "▴" or "▾"
        if not opened then
            task.delay(0.2, function() listHolder.Visible = false end)
        end
    end)

    return {
        Set = function(v)
            selected = v
            dd.Label.Text = (text or "Dropdown") .. ": " .. tostring(v)
        end,
        Get = function() return selected end,
    }
end

--// ПРИМЕНЯЕМ МЕТОДЫ К КАЖДОЙ ВКЛАДКЕ
local originalCreateTab = nil
-- Перехватываем создание вкладки, чтобы навесить методы
local mt = { __index = TabMethods }
local windowMeta = {}

-- Заменяем возвращаемую вкладку обёрткой
local function wrapTab(tab)
    return setmetatable(tab, mt)
end

--// ФИНАЛЬНЫЙ ВОЗВРАТ
local _origCreateWindow = Opstel.CreateWindow
function Opstel:CreateWindow(title, themeName)
    local win = _origCreateWindow(self, title, themeName)
    local _origCreateTab = win.CreateTab
    win.CreateTab = function(_, name, icon)
        local tab = _origCreateTab(win, name, icon)
        return wrapTab(tab)
    end
    return win
end

return Opstel
