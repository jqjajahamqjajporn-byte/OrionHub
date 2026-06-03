--[[
    Orion Hub - Notification System
    Exibe notificações temporárias na tela
]]

local Notifications = {}
local queue = {}
local active = false

local ScreenGui = game:GetService("CoreGui"):FindFirstChild("OrionHub_GUI")
if not ScreenGui then
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "OrionHub_GUI"
    ScreenGui.Parent = game:GetService("CoreGui")
end

local NotificationContainer = Instance.new("Frame")
NotificationContainer.Size = UDim2.new(0, 300, 0, 0)
NotificationContainer.Position = UDim2.new(1, -310, 0, 10)
NotificationContainer.BackgroundTransparency = 1
NotificationContainer.Parent = ScreenGui

local function showNext()
    if active or #queue == 0 then return end
    active = true
    local notif = table.remove(queue, 1)
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = NotificationContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -10, 0, 20)
    title.Position = UDim2.new(0, 5, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = notif.Title
    title.TextColor3 = Color3.fromRGB(255, 200, 100)
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -10, 0, 20)
    text.Position = UDim2.new(0, 5, 0, 25)
    text.BackgroundTransparency = 1
    text.Text = notif.Text
    text.TextColor3 = Color3.fromRGB(220, 220, 220)
    text.TextSize = 12
    text.Font = Enum.Font.Gotham
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.Parent = frame
    
    -- Ajustar altura do container
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = NotificationContainer
    
    task.delay(notif.Duration or 3, function()
        frame:Destroy()
        active = false
        showNext()
    end)
end

function Notifications:Show(title, text, duration)
    table.insert(queue, { Title = title, Text = text, Duration = duration or 3 })
    showNext()
end

-- Sobrescreve a função Utils.Notify se disponível
if _G.Orion and _G.Orion.Modules and _G.Orion.Modules.Utils then
    _G.Orion.Modules.Utils.Notify = function(title, text, duration)
        Notifications:Show(title, text, duration)
    end
else
    -- Fallback
    _G.Notify = Notifications.Show
end

return Notifications
