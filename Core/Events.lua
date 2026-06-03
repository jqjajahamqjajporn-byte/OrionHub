 --[[
    Orion Hub - Core Events
    Gerencia eventos de renderização, Stepped e conexões importantes.
]]

local Events = {}
local connections = {}

-- Evento de renderização para desenhos (FOV circle, tracers, etc.)
function Events:OnRenderStep(callback)
    local conn
    conn = _G.Orion.RunService.RenderStepped:Connect(function(deltaTime)
        if _G.Orion.Loaded then
            callback(deltaTime)
        end
    end)
    table.insert(connections, conn)
    return conn
end

-- Evento Heartbeat para cálculos de física/predição
function Events:OnHeartbeat(callback)
    local conn
    conn = _G.Orion.RunService.Heartbeat:Connect(function(deltaTime)
        if _G.Orion.Loaded then
            callback(deltaTime)
        end
    end)
    table.insert(connections, conn)
    return conn
end

-- Evento de input para keybinds (Insert abre/fecha menu)
function Events:SetupKeybinds(toggleMenuCallback)
    local conn = _G.Orion.UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.Insert then
            toggleMenuCallback()
        end
        -- Keybinds customizáveis (a serem carregados do Settings)
        if _G.Orion.Settings.keybinds then
            for action, key in pairs(_G.Orion.Settings.keybinds) do
                if input.KeyCode == Enum.KeyCode[key] then
                    if action == "toggleSilentAim" then
                        _G.Orion.Settings.silentAimEnabled = not _G.Orion.Settings.silentAimEnabled
                        -- Notificação opcional
                    end
                end
            end
        end
    end)
    table.insert(connections, conn)
end

-- Limpa todas as conexões (útil ao recarregar o script)
function Events:Cleanup()
    for _, conn in ipairs(connections) do
        conn:Disconnect()
    end
    connections = {}
end

return Events
