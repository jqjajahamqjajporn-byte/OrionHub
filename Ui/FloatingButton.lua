--[[
    Orion Hub - Floating Button
    Botão arrastável na tela para toggle do Silent Aim
]]

local FloatingButton = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local button = Instance.new("ImageButton")
button.Size = UDim2.new(0, 50, 0, 50)
button.Position = UDim2.new(0.8, 0, 0.8, 0)
button.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
button.BackgroundTransparency = 0.2
button.Image = "rbxassetid://106935138382807" -- mesmo logo
button.ImageColor3 = Color3.fromRGB(255, 255, 255)
button.Parent = game:GetService("CoreGui"):FindFirstChild("OrionHub_GUI") or game:GetService("CoreGui")

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = button

local function updateButtonAppearance(state)
    if state then
        button.ImageColor3 = Color3.fromRGB(100, 255, 100)
    else
        button.ImageColor3 = Color3.fromRGB(255, 100, 100)
    end
end

-- Toggle Silent Aim
local function toggleSilentAim()
    _G.Orion.Settings.silentAimEnabled = not _G.Orion.Settings.silentAimEnabled
    updateButtonAppearance(_G.Orion.Settings.silentAimEnabled)
    -- Notificar se quiser
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Silent Aim",
        Text = _G.Orion.Settings.silentAimEnabled and "Enabled" or "Disabled",
        Duration = 1
    })
end

button.MouseButton1Click:Connect(toggleSilentAim)

-- Arrastar o botão
local dragging = false
local dragStart
local buttonStartPos

button.MouseButton1Down:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        buttonStartPos = button.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        local newX = buttonStartPos.X.Scale + (delta.X / game:GetService("CoreGui").AbsoluteSize.X)
        local newY = buttonStartPos.Y.Scale + (delta.Y / game:GetService("CoreGui").AbsoluteSize.Y)
        button.Position = UDim2.new(newX, 0, newY, 0)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Inicializar com estado atual
updateButtonAppearance(_G.Orion.Settings.silentAimEnabled)

return FloatingButton
