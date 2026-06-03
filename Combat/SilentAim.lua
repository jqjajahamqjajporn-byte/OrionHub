--[[
    Orion Hub - Silent Aim Module
    Suporte para faca (corpo a corpo) e arma (projétil).
    Inclui FOV circle, predição, wallbang toggle, aim smoothing.
]]

local SilentAim = {}
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Variáveis internas
local enabled = true
local fovRadius = 120
local wallbang = false
local aimSmoothing = 0.3
local fovCircle = nil
local lastTarget = nil
local currentWeapon = nil -- "Knife" ou "Gun"

-- Função para criar o círculo FOV
local function createFOVCircle()
    if fovCircle then fovCircle:Remove() end
    fovCircle = Drawing.new("Circle")
    fovCircle.Radius = fovRadius
    fovCircle.Thickness = 2
    fovCircle.Color = Color3.fromRGB(255, 85, 85)
    fovCircle.Transparency = 0.7
    fovCircle.NumSides = 64
    fovCircle.Visible = enabled
    fovCircle.ZIndex = 10
end

-- Atualiza posição do círculo a cada frame
local function updateFOVCirclePosition()
    if not fovCircle then return end
    local mousePos = UserInputService:GetMouseLocation()
    fovCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
end

-- Predição de posição para armas de projétil
local function predictPosition(target, projectileSpeed)
    if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    local hrp = target.Character.HumanoidRootPart
    local velocity = hrp.Velocity
    local origin = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not origin then return hrp.Position end
    local distance = (hrp.Position - origin.Position).Magnitude
    local timeToHit = distance / (projectileSpeed or 800)
    local predicted = hrp.Position + (velocity * timeToHit)
    return predicted
end

-- Verifica se o alvo está visível (Wallbang check)
local function isVisible(targetPart)
    if wallbang then return true end
    local origin = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
    if not origin then return false end
    local ray = Ray.new(origin.Position, (targetPart.Position - origin.Position).Unit * 1000)
    local hit, position = workspace:FindPartOnRay(ray, LocalPlayer.Character)
    local distToTarget = (targetPart.Position - origin.Position).Magnitude
    local distToHit = (position - origin.Position).Magnitude
    return math.abs(distToHit - distToTarget) < 1.5
end

-- Encontra o melhor alvo dentro do FOV
local function getBestTarget()
    if not LocalPlayer.Character then return nil end
    local mousePos = UserInputService:GetMouseLocation()
    local bestTarget = nil
    local bestScore = fovRadius + 1
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local screenPos, onScreen = workspace.CurrentCamera:WorldToScreenPoint(hrp.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if dist <= fovRadius and dist < bestScore then
                    -- Checagem de visibilidade
                    if isVisible(hrp) then
                        bestScore = dist
                        bestTarget = player
                    end
                end
            end
        end
    end
    return bestTarget
end

-- Aplica smoothing no aiming (para armas de tiro)
local function smoothAim(current, target, smoothing)
    return current:Lerp(target, smoothing)
end

-- Função principal de Silent Aim (chamada no Heartbeat para faca ou no InputBegan para tiro)
local function handleKnifeAim()
    if not enabled or currentWeapon ~= "Knife" then return end
    local target = getBestTarget()
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local targetPos = target.Character.HumanoidRootPart.Position
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local direction = (targetPos - hrp.Position).Unit
        -- Altera o CFrame da faca (silent aim para corpo a corpo)
        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool and (tool.Name:lower():find("knife") or tool.Name:lower():find("dagger")) then
            -- Modifica a direção do ataque (simula mira)
            tool.Handle.CFrame = CFrame.new(tool.Handle.Position, targetPos)
        end
    end
end

-- Para armas de tiro, interceptamos o evento de disparo (simulação)
local function hookShoot()
    -- Encontra a ferramenta arma
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not tool or not (tool.Name:lower():find("gun") or tool.Name:lower():find("pistol")) then
        return
    end
    -- Obtém a função de disparo (exemplo genérico, no MM2 geralmente é um RemoteEvent)
    local fireRemote = tool:FindFirstChild("Fire") or tool:FindFirstChild("Shoot")
    if fireRemote and fireRemote:IsA("RemoteEvent") then
        local oldFire = fireRemote.FireServer
        fireRemote.FireServer = function(self, ...)
            if not enabled then return oldFire(self, ...) end
            local target = getBestTarget()
            if target and target.Character then
                local predicted = predictPosition(target, 800)
                if predicted then
                    -- Substitui os argumentos para mirar no predito
                    return oldFire(self, predicted, ...)
                end
            end
            return oldFire(self, ...)
        end
    end
end

-- Atualiza o tipo de arma atual
local function updateWeapon()
    if not LocalPlayer.Character then return end
    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if tool then
        if tool.Name:lower():find("knife") then
            currentWeapon = "Knife"
        elseif tool.Name:lower():find("gun") or tool.Name:lower():find("pistol") then
            currentWeapon = "Gun"
        else
            currentWeapon = nil
        end
    else
        currentWeapon = nil
    end
end

-- Eventos de loop
local heartbeatConn = nil
local renderConn = nil

function SilentAim:Start()
    createFOVCircle()
    renderConn = RunService.RenderStepped:Connect(function()
        updateFOVCirclePosition()
        updateWeapon()
        handleKnifeAim()
        if currentWeapon == "Gun" then
            hookShoot() -- Recria o hook periodicamente (pois a tool pode mudar)
        end
    end)
    heartbeatConn = RunService.Heartbeat:Connect(function()
        if enabled and currentWeapon == "Gun" then
            -- Opcional: pré-calcular alvo para smoothing
        end
    end)
end

function SilentAim:SetEnabled(state)
    enabled = state
    if fovCircle then fovCircle.Visible = state end
end

function SilentAim:UpdateFOV(radius)
    fovRadius = radius
    if fovCircle then fovCircle.Radius = radius end
end

function SilentAim:SetWallbang(state)
    wallbang = state
end

function SilentAim:SetSmoothing(value)
    aimSmoothing = value
end

function SilentAim:Stop()
    if renderConn then renderConn:Disconnect() end
    if heartbeatConn then heartbeatConn:Disconnect() end
    if fovCircle then fovCircle:Remove() end
end

return SilentAim
