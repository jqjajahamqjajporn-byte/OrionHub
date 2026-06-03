--[[
    Orion Hub - Core Utils
    Funções auxiliares: obtenção de papel, predição, nearest player, notificações, etc.
]]

local Utils = {}

-- Obtém o papel de um jogador (baseado em ferramentas ou atributos)
function Utils.GetPlayerRole(player)
    if not player or not player.Character then return "Unknown" end
    local character = player.Character
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            if tool.Name:lower():find("knife") then
                return "Murderer"
            elseif tool.Name:lower():find("gun") or tool.Name:lower():find("pistol") then
                return "Sheriff"
            end
        end
    end
    -- Fallback: verificar se o jogador é o Murderer (pelo nome da ferramenta na mão)
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid and humanoid:FindFirstChild("Tool") then
        local toolName = humanoid.Tool.Name:lower()
        if toolName:find("knife") then return "Murderer" end
        if toolName:find("gun") or toolName:find("pistol") then return "Sheriff" end
    end
    return "Innocent"
end

-- Predição simples para Silent Aim (baseada na velocidade do alvo)
function Utils.PredictPosition(target, projectileSpeed)
    projectileSpeed = projectileSpeed or 800 -- Velocidade padrão da bala
    if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    local hrp = target.Character.HumanoidRootPart
    local velocity = hrp.Velocity
    local distance = (hrp.Position - _G.Orion.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
    local timeToHit = distance / projectileSpeed
    local predictedPos = hrp.Position + (velocity * timeToHit)
    return predictedPos
end

-- Encontra o jogador mais próximo do mouse dentro do FOV (para Silent Aim)
function Utils.GetNearestPlayerInFOV(fovRadius)
    local localPlayer = _G.Orion.LocalPlayer
    if not localPlayer or not localPlayer.Character then return nil end
    local mousePos = _G.Orion.UserInputService:GetMouseLocation()
    local nearest = nil
    local smallestDist = fovRadius + 1
    
    for _, player in ipairs(_G.Orion.Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local screenPos, onScreen = _G.Orion.CoreGui.Camera:WorldToScreenPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if dist < smallestDist and dist <= fovRadius then
                    smallestDist = dist
                    nearest = player
                end
            end
        end
    end
    return nearest
end

-- Verifica se o jogador está visível (wallbang check)
function Utils.IsVisible(targetPart)
    local origin = _G.Orion.LocalPlayer.Character.Head.Position
    local ray = Ray.new(origin, (targetPart.Position - origin).Unit * 1000)
    local hit, position = workspace:FindPartOnRay(ray, _G.Orion.LocalPlayer.Character)
    local distanceToTarget = (targetPart.Position - origin).Magnitude
    local distanceToHit = (position - origin).Magnitude
    return math.abs(distanceToHit - distanceToTarget) < 1
end

-- Notificação simples (pode ser expandida para usar UI)
function Utils.Notify(title, text, duration)
    duration = duration or 3
    -- Placeholder: usar o sistema de notificação do jogo ou criar um GUI local
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration
    })
end

-- Obtém a cor baseada no papel (para ESP)
function Utils.GetRoleColor(role)
    if role == "Murderer" then
        return Color3.fromRGB(255, 0, 0) -- Vermelho
    elseif role == "Sheriff" then
        return Color3.fromRGB(0, 0, 255) -- Azul
    else
        return Color3.fromRGB(0, 255, 0) -- Verde
    end
end

return Utils
