--[[
    Orion Hub - Triggerbot
    Dispara automaticamente quando a mira (mouse) estiver sobre um inimigo.
    Funciona apenas com arma de fogo (Sheriff).
]]

local Triggerbot = {}
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local enabled = false
local currentTool = nil
local shootCooldown = false

-- Verifica se o mouse está sobre um jogador válido
local function isMouseOverEnemy()
    local mouse = UserInputService:GetMouseLocation()
    local target = nil
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local screenPos, onScreen = workspace.CurrentCamera:WorldToScreenPoint(hrp.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mouse).Magnitude
                if dist < 30 then -- Threshold para considerar "sobre" o alvo
                    target = player
                    break
                end
            end
        end
    end
    return target ~= nil
end

-- Simula um clique do mouse (disparo)
local function shoot()
    if shootCooldown then return end
    -- Encontra a arma equipada
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if tool and (tool.Name:lower():find("gun") or tool.Name:lower():find("pistol")) then
        -- Tenta ativar o evento de disparo (depende da implementação do jogo)
        local fireRemote = tool:FindFirstChild("Fire") or tool:FindFirstChild("Shoot") or tool:FindFirstChild("RemoteEvent")
        if fireRemote and fireRemote:IsA("RemoteEvent") then
            fireRemote:FireServer()
        else
            -- Fallback: simular clique do mouse (menos confiável)
            local VirtualInput = game:GetService("VirtualInput")
            VirtualInput:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, true, false, nil)
            task.wait(0.05)
            VirtualInput:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, false, false, nil)
        end
        shootCooldown = true
        task.delay(0.2, function() shootCooldown = false end) -- cooldown de 200ms
    end
end

-- Loop de verificação
local renderConn = nil
function Triggerbot:Start()
    renderConn = game:GetService("RunService").RenderStepped:Connect(function()
        if enabled and isMouseOverEnemy() then
            shoot()
        end
    end)
end

function Triggerbot:SetEnabled(state)
    enabled = state
end

function Triggerbot:Stop()
    if renderConn then renderConn:Disconnect() end
end

return Triggerbot
