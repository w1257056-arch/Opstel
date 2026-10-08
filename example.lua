local Opstel = loadstring(game:HttpGet("https://raw.githubusercontent.com/w1257056-arch/Opstel/main/source.lua"))()
local Window = Opstel:CreateWindow("Моё меню", "OpstelDark")

-- Уведомление при запуске
Window:Notify("Добро пожаловать", "Opstel загружен успешно ✨", 4)

-- Вкладка "Главное"
local Main = Window:CreateTab("Главное", "★")
Main:CreateSection("Утилиты")

Main:CreateButton("Тест кнопки", function()
    Window:Notify("Кнопка", "Нажата!", 2)
end)

Main:CreateToggle("Автоклик", false, function(state)
    print("Автоклик:", state)
end)

Main:CreateSlider("Скорость", 0, 100, 16, function(v)
    print("Скорость:", v)
end)

Main:CreateTextBox("Ник", "Введи никнейм", function(text)
    print("Введено:", text)
end)

Main:CreateDropdown("Режим", {"Normal", "Fast", "Turbo"}, function(opt)
    Window:Notify("Режим", "Выбран: " .. opt, 2)
end)

-- Вкладка "Настройки"
local Settings = Window:CreateTab("Настройки", "⚙")
Settings:CreateButton("Выход", function()
    Window:Notify("Выход", "До встречи!", 2)
end)
