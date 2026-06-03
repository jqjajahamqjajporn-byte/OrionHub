--[[
    Wind Hub UI Library - Versão simplificada e estável para Orion Hub
]]

local WindHub = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Criar ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OrionHub_GUI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

-- Janela principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainWindow"
MainFrame.Size = UDim2.new(0, 600, 0, 450)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Visible = false  -- começa invisível
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Background image (ID fornecido)
local BackgroundImage = Instance.new("ImageLabel")
BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
BackgroundImage.BackgroundTransparency = 1
BackgroundImage.Image = "rbxassetid://115818288059902"
BackgroundImage.ScaleType = Enum.ScaleType.Crop
BackgroundImage.Parent = MainFrame

-- Logo (ID fornecido)
local Logo = Instance.new("ImageLabel")
Logo.Size = UDim2.new(0, 50, 0, 50)
Logo.Position = UDim2.new(1, -60, 0, 10)
Logo.BackgroundTransparency = 1
Logo.Image = "rbxassetid://106935138382807"
Logo.Parent = MainFrame

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 150, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 10)
Title.BackgroundTransparency = 1
Title.Text = "Orion Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Container das abas (lateral)
local TabsContainer = Instance.new("ScrollingFrame")
TabsContainer.Size = UDim2.new(0, 150, 1, -40)
TabsContainer.Position = UDim2.new(0, 0, 0, 40)
TabsContainer.BackgroundTransparency = 1
TabsContainer.BorderSizePixel = 0
TabsContainer.ScrollBarThickness = 4
TabsContainer.Parent = MainFrame

local TabsLayout = Instance.new("UIListLayout")
TabsLayout.Padding = UDim.new(0, 5)
TabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabsLayout.Parent = TabsContainer

-- Container do conteúdo
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -160, 1, -50)
ContentContainer.Position = UDim2.new(0, 150, 0, 40)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

-- Dicionário de abas
local tabs = {}
local currentTab = nil

-- Funções públicas
function WindHub:AddTab(tabName)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    btn.Text = tabName
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamSemibold
    btn.BorderSizePixel = 0
    btn.Parent = TabsContainer
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 6
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.Visible = false
    content.Parent = ContentContainer
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = content
    
    tabs[tabName] = { button = btn, content = content, layout = contentLayout, elements = {} }
    
    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.content.Visible = false
            t.button.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        end
        content.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(85, 85, 105)
        currentTab = tabName
    end)
    
    -- Se for a primeira, ativar
    if next(tabs) == tabName then
        btn.MouseButton1Click:Fire()
    end
    
    -- Retornar objeto com métodos para adicionar componentes
    return {
        AddToggle = function(config) return WindHub:AddToggle(content, contentLayout, config) end,
        AddSlider = function(config) return WindHub:AddSlider(content, contentLayout, config) end,
        AddButton = function(config) return WindHub:AddButton(content, contentLayout, config) end,
        AddLabel = function(config) return WindHub:AddLabel(content, contentLayout, config) end,
        AddKeybind = function(config) return WindHub:AddKeybind(content, contentLayout, config) end,
    }
end

-- Componente Toggle
function WindHub:AddToggle(parent, layout, config)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 35)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    frame.BackgroundTransparency = 0.5
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.Parent = frame
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 40, 0, 25)
    toggleBtn.Position = UDim2.new(1, -50, 0.5, -12.5)
    toggleBtn.BackgroundColor3 = config.Default and Color3.fromRGB(85, 85, 255) or Color3.fromRGB(100, 100, 100)
    toggleBtn.Text = config.Default and "ON" or "OFF"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 12
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Parent = frame
    
    local corner2 = Instance.new("UICorner")
    corner2.CornerRadius = UDim.new(1, 0)
    corner2.Parent = toggleBtn
    
    local state = config.Default or false
    local callback = config.Callback or function() end
    
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(85, 85, 255) or Color3.fromRGB(100, 100, 100)
        toggleBtn.Text = state and "ON" or "OFF"
        callback(state)
    end)
    
    return { SetValue = function(v) if v ~= state then toggleBtn.MouseButton1Click:Fire() end end }
end

-- Componente Slider
function WindHub:AddSlider(parent, layout, config)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 65)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    frame.BackgroundTransparency = 0.5
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = config.Text .. ": " .. tostring(config.Default or config.Min)
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.Parent = frame
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0.9, 0, 0, 5)
    slider.Position = UDim2.new(0.05, 0, 0.7, 0)
    slider.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    slider.BorderSizePixel = 0
    slider.Parent = frame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(85, 85, 255)
    fill.BorderSizePixel = 0
    fill.Parent = slider
    
    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 15, 0, 15)
    knob.Position = UDim2.new(0, -7, 0.5, -7.5)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Text = ""
    knob.BorderSizePixel = 0
    knob.Parent = slider
    
    local cornerKnob = Instance.new("UICorner")
    cornerKnob.CornerRadius = UDim.new(1, 0)
    cornerKnob.Parent = knob
    
    local value = config.Default or config.Min
    local min = config.Min or 0
    local max = config.Max or 100
    local callback = config.Callback or function() end
    
    local function updateSlider(val)
        val = math.clamp(val, min, max)
        value = val
        local percent = (val - min) / (max - min)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, -7, 0.5, -7.5)
        label.Text = config.Text .. ": " .. string.format("%.1f", val)
        callback(val)
    end
    
    updateSlider(value)
    
    local dragging = false
    knob.MouseButton1Down:Connect(function()
        dragging = true
        local mouse = game:GetService("UserInputService")
        local update = function()
            local mousePos = mouse:GetMouseLocation().X
            local sliderPos = slider.AbsolutePosition.X
            local sliderWidth = slider.AbsoluteSize.X
            local percent = math.clamp((mousePos - sliderPos) / sliderWidth, 0, 1)
            updateSlider(min + (max - min) * percent)
        end
        local conn
        conn = mouse.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
                update()
            end
        end)
        local releaseConn
        releaseConn = mouse.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
                conn:Disconnect()
                releaseConn:Disconnect()
            end
        end)
    end)
    
    return { SetValue = updateSlider }
end

-- Componente Button
function WindHub:AddButton(parent, layout, config)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(85, 85, 255)
    btn.Text = config.Text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(config.Callback or function() end)
    return btn
end

-- Componente Label
function WindHub:AddLabel(parent, layout, config)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 25)
    lbl.BackgroundTransparency = 1
    lbl.Text = config.Text
    lbl.TextColor3 = config.Color or Color3.fromRGB(200, 200, 200)
    lbl.TextSize = config.Size or 14
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

-- Componente Keybind (simples)
function WindHub:AddKeybind(parent, layout, config)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 35)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    frame.BackgroundTransparency = 0.5
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local bindBtn = Instance.new("TextButton")
    bindBtn.Size = UDim2.new(0, 80, 0, 25)
    bindBtn.Position = UDim2.new(1, -90, 0.5, -12.5)
    bindBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    bindBtn.Text = config.Default and tostring(config.Default) or "None"
    bindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    bindBtn.TextSize = 12
    bindBtn.Font = Enum.Font.GothamBold
    bindBtn.BorderSizePixel = 0
    bindBtn.Parent = frame
    
    local listening = false
    bindBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        bindBtn.Text = "..."
        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                local key = input.KeyCode.Name
                bindBtn.Text = key
                if config.Callback then config.Callback(key) end
                listening = false
                conn:Disconnect()
            end
        end)
        task.wait(5)
        if listening then
            listening = false
            bindBtn.Text = config.Default or "None"
            conn:Disconnect()
        end
    end)
    
    return bindBtn
end

-- Funções de toggle do menu
function WindHub:Toggle()
    MainFrame.Visible = not MainFrame.Visible
end

function WindHub:Open()
    MainFrame.Visible = true
end

function WindHub:Close()
    MainFrame.Visible = false
end

return WindHubMainFrame.Visible = false
MainFrame.Parent = ScreenGui

-- Arredondamento (usando UICorner)
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, Theme.BorderRadius)
UICorner.Parent = MainFrame

-- Background com imagem
local BackgroundImage = Instance.new("ImageLabel")
BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
BackgroundImage.BackgroundTransparency = 1
BackgroundImage.Image = "rbxassetid://115818288059902" -- ID do background
BackgroundImage.ScaleType = Enum.ScaleType.Crop
BackgroundImage.Parent = MainFrame

-- Logo
local Logo = Instance.new("ImageLabel")
Logo.Size = UDim2.new(0, 50, 0, 50)
Logo.Position = UDim2.new(1, -60, 0, 10)
Logo.BackgroundTransparency = 1
Logo.Image = "rbxassetid://106935138382807"
Logo.Parent = MainFrame

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 150, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 10)
Title.BackgroundTransparency = 1
Title.Text = "Orion Hub"
Title.TextColor3 = Theme.TextColor
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Abas container
local TabsContainer = Instance.new("Frame")
TabsContainer.Size = UDim2.new(0, 150, 1, -40)
TabsContainer.Position = UDim2.new(0, 0, 0, 40)
TabsContainer.BackgroundTransparency = 1
TabsContainer.Parent = MainFrame

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -160, 1, -50)
ContentContainer.Position = UDim2.new(0, 150, 0, 40)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

-- Dicionário de abas e elementos
local Tabs = {}
local CurrentTab = nil

-- Função para criar um botão de aba
function WindHub:AddTab(tabName)
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(1, -20, 0, 35)
    tabButton.Position = UDim2.new(0, 10, 0, (#Tabs) * 40 + 10)
    tabButton.BackgroundColor3 = Theme.AccentColor
    tabButton.BackgroundTransparency = 0.8
    tabButton.Text = tabName
    tabButton.TextColor3 = Theme.TextColor
    tabButton.TextSize = 16
    tabButton.Font = Enum.Font.GothamSemibold
    tabButton.BorderSizePixel = 0
    tabButton.Parent = TabsContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = tabButton
    
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Size = UDim2.new(1, 0, 1, 0)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.ScrollBarThickness = 6
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentFrame.Visible = false
    contentFrame.Parent = ContentContainer
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = contentFrame
    
    Tabs[tabName] = {
        Button = tabButton,
        Content = contentFrame,
        Layout = contentLayout,
        Elements = {}
    }
    
    tabButton.MouseButton1Click:Connect(function()
        for _, tab in pairs(Tabs) do
            tab.Content.Visible = false
            tab.Button.BackgroundTransparency = 0.8
        end
        contentFrame.Visible = true
        tabButton.BackgroundTransparency = 0.3
        CurrentTab = tabName
    end)
    
    -- Se for a primeira aba, ativa
    if #Tabs == 1 then
        tabButton.MouseButton1Click:Fire()
    end
    
    return {
        AddToggle = function(config)
            return WindHub:AddToggle(contentFrame, contentLayout, config)
        end,
        AddSlider = function(config)
            return WindHub:AddSlider(contentFrame, contentLayout, config)
        end,
        AddButton = function(config)
            return WindHub:AddButton(contentFrame, contentLayout, config)
        end,
        AddLabel = function(config)
            return WindHub:AddLabel(contentFrame, contentLayout, config)
        end,
        AddKeybind = function(config)
            return WindHub:AddKeybind(contentFrame, contentLayout, config)
        end
    }
end

-- Componente Toggle
function WindHub:AddToggle(parent, layout, config)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 35)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    frame.BackgroundTransparency = 0.5
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Text
    label.TextColor3 = Theme.TextColor
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.Parent = frame
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 40, 0, 25)
    toggleBtn.Position = UDim2.new(1, -50, 0.5, -12.5)
    toggleBtn.BackgroundColor3 = config.Default and Theme.AccentColor or Color3.fromRGB(100, 100, 100)
    toggleBtn.Text = config.Default and "ON" or "OFF"
    toggleBtn.TextColor3 = Theme.TextColor
    toggleBtn.TextSize = 12
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Parent = frame
    
    local corner2 = Instance.new("UICorner")
    corner2.CornerRadius = UDim.new(1, 0)
    corner2.Parent = toggleBtn
    
    local state = config.Default or false
    local callback = config.Callback or function() end
    
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.BackgroundColor3 = state and Theme.AccentColor or Color3.fromRGB(100, 100, 100)
        toggleBtn.Text = state and "ON" or "OFF"
        callback(state)
    end)
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        frame.Size = UDim2.new(1, -20, 0, 35)
    end)
    
    return { SetValue = function(v) if v ~= state then toggleBtn.MouseButton1Click:Fire() end end }
end

-- Componente Slider
function WindHub:AddSlider(parent, layout, config)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 65)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    frame.BackgroundTransparency = 0.5
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = config.Text .. ": " .. tostring(config.Default or config.Min)
    label.TextColor3 = Theme.TextColor
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.Parent = frame
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0.9, 0, 0, 5)
    slider.Position = UDim2.new(0.05, 0, 0.7, 0)
    slider.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    slider.BorderSizePixel = 0
    slider.Parent = frame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Theme.AccentColor
    fill.BorderSizePixel = 0
    fill.Parent = slider
    
    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 15, 0, 15)
    knob.Position = UDim2.new(0, -7, 0.5, -7.5)
    knob.BackgroundColor3 = Theme.TextColor
    knob.Text = ""
    knob.BorderSizePixel = 0
    knob.Parent = slider
    
    local cornerKnob = Instance.new("UICorner")
    cornerKnob.CornerRadius = UDim.new(1, 0)
    cornerKnob.Parent = knob
    
    local value = config.Default or config.Min
    local min = config.Min or 0
    local max = config.Max or 100
    local callback = config.Callback or function() end
    
    local function updateSlider(val)
        val = math.clamp(val, min, max)
        value = val
        local percent = (val - min) / (max - min)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, -7, 0.5, -7.5)
        label.Text = config.Text .. ": " .. string.format("%.1f", val)
        callback(val)
    end
    
    updateSlider(value)
    
    local dragging = false
    knob.MouseButton1Down:Connect(function()
        dragging = true
        local mouse = game:GetService("UserInputService")
        local function update()
            local mousePos = mouse:GetMouseLocation().X
            local sliderPos = slider.AbsolutePosition.X
            local sliderWidth = slider.AbsoluteSize.X
            local percent = math.clamp((mousePos - sliderPos) / sliderWidth, 0, 1)
            updateSlider(min + (max - min) * percent)
        end
        local conn
        conn = mouse.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
                update()
            end
        end)
        local releaseConn
        releaseConn = mouse.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
                conn:Disconnect()
                releaseConn:Disconnect()
            end
        end)
    end)
    
    return { SetValue = updateSlider }
end

-- Componente Button
function WindHub:AddButton(parent, layout, config)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 35)
    button.BackgroundColor3 = Theme.AccentColor
    button.Text = config.Text
    button.TextColor3 = Theme.TextColor
    button.TextSize = 14
    button.Font = Enum.Font.GothamBold
    button.BorderSizePixel = 0
    button.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    button.MouseButton1Click:Connect(config.Callback or function() end)
    
    return button
end

-- Componente Label
function WindHub:AddLabel(parent, layout, config)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 25)
    label.BackgroundTransparency = 1
    label.Text = config.Text
    label.TextColor3 = config.Color or Theme.SecondaryText
    label.TextSize = config.Size or 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    
    return label
end

-- Componente Keybind (simplificado)
function WindHub:AddKeybind(parent, layout, config)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 35)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    frame.BackgroundTransparency = 0.5
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Text
    label.TextColor3 = Theme.TextColor
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.Parent = frame
    
    local bindBtn = Instance.new("TextButton")
    bindBtn.Size = UDim2.new(0, 80, 0, 25)
    bindBtn.Position = UDim2.new(1, -90, 0.5, -12.5)
    bindBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    bindBtn.Text = config.Default and tostring(config.Default) or "None"
    bindBtn.TextColor3 = Theme.TextColor
    bindBtn.TextSize = 12
    bindBtn.Font = Enum.Font.GothamBold
    bindBtn.BorderSizePixel = 0
    bindBtn.Parent = frame
    
    local listening = false
    bindBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        bindBtn.Text = "..."
        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                local key = input.KeyCode.Name
                bindBtn.Text = key
                config.Callback(key)
                listening = false
                conn:Disconnect()
            end
        end)
        task.wait(5)
        if listening then
            listening = false
            bindBtn.Text = config.Default or "None"
            conn:Disconnect()
        end
    end)
    
    return bindBtn
end

-- Abrir/fechar menu
function WindHub:Toggle()
    MainFrame.Visible = not MainFrame.Visible
end

function WindHub:Open()
    MainFrame.Visible = true
end

function WindHub:Close()
    MainFrame.Visible = false
end

-- Retorna a GUI para uso externo
return WindHub
