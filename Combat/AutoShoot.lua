--[[
    Orion Hub - Auto Shoot (Sheriff)
    Quando ativado, atira automaticamente sempre que um jogador estiver na mira,
    com cooldown entre tiros e sem necessidade de pressionar o botão.
]]

local AutoShoot = {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local enabled = false
local shootCooldown = false
local fireRate = 0.3 -- segundos entre tiros

local function getClosestEnemy()
    local mousePos = game:GetService("UserInputService"):GetMouseLocation()
    local closest = nil
    local closestDist = 300 -- máximo de distância em pixels
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local screenPos, onScreen = workspace.CurrentCamera:WorldToScreenPoint(hrp.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = player
                end
            end
        end
    end
    return closest
end

local function shootAtTarget()
    if shootCooldown then return end
    local target = getClosestEnemy()
    if target then
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool and (tool.Name:lower():find("gun") or tool.Name:lower():find("pistol")) then
            local fireRemote = tool:FindFirstChild("Fire") or tool:FindFirstChild("Shoot")
            if fireRemote and fireRemote:IsA("RemoteEvent") then
                fireRemote:FireServer()
                shootCooldown = true
                task.delay(fireRate, function() shootCooldown = false end)
            end
        end
    end
end

local heartbeatConn = nil
function AutoShoot:Start()
    heartbeatConn = game:GetService("RunService").Heartbeat:Connect(function()
        if enabled then
            shootAtTarget()
        end
    end)
end

function AutoShoot:SetEnabled(state)
    enabled = state
end

function AutoShoot:SetFireRate(rate)
    fireRate = rate
end

function AutoShoot:Stop()
    if heartbeatConn then heartbeatConn:Disconnect() end
end

return AutoShoot
