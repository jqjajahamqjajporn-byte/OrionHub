--[[
    Orion Hub - Anti-AFK Module
    Simula movimento da câmera ou pequenos inputs para evitar o kick por idle.
]]

local AntiAFK = {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local enabled = false
vararg = 0

-- Método 1: Simular movimento da câmera (mais seguro)
local function simulateCameraMovement()
    local currentPos = UserInputService:GetMouseDelta()
    -- Movimento sutil e aleatório
    local deltaX = math.random(-3, 3)
    local deltaY = math.random(-2, 2)
    UserInputService:GetMouseDelta(Vector2.new(deltaX, deltaY))
end

-- Método 2: Usar VirtualUser para enviar inputs (funciona em alguns executors)
local function virtualUserBounce()
    if VirtualUser then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end

-- Loop de anti-AFK
local heartbeatConn = nil
function AntiAFK:Start()
    heartbeatConn = game:GetService("RunService").Heartbeat:Connect(function()
        if enabled then
            -- A cada 30 segundos (aprox. 1800 heartbeats a 60hz)
            if tick() - lastAction > 30 then
                simulateCameraMovement()
                virtualUserBounce()
                lastAction = tick()
            end
        end
    end)
end

local lastAction = tick()

function AntiAFK:SetEnabled(state)
    enabled = state
    if state then
        lastAction = tick() -- reset timer
    end
end

function AntiAFK:Stop()
    if heartbeatConn then heartbeatConn:Disconnect() end
end

return AntiAFK
