--[[
    Orion Hub - Knife Aura / Reach
    Aumenta o alcance da faca, permitindo acertar inimigos à distância.
    Funciona modificando o tamanho do Hitbox da faca ou usando um Raycast customizado.
]]

local KnifeAura = {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local enabled = false
local reach = 15 -- alcance em studs
local currentKnife = nil

-- Aumenta o alcance da faca: altera o tamanho da parte "Handle" ou adiciona um novo Hitbox
local function extendKnifeReach(knife)
    if not knife then return end
    local handle = knife:FindFirstChild("Handle")
    if handle and handle:IsA("BasePart") then
        -- Salva tamanho original se não existir
        if not handle:GetAttribute("OriginalSize") then
            handle:SetAttribute("OriginalSize", handle.Size)
        end
        local newSize = Vector3.new(reach, reach, reach)
        handle.Size = newSize
        -- Opcional: alterar o weld ou a posição
    end
end

local function restoreKnifeReach(knife)
    if not knife then return end
    local handle = knife:FindFirstChild("Handle")
    if handle and handle:IsA("BasePart") then
        local original = handle:GetAttribute("OriginalSize")
        if original then
            handle.Size = original
        end
    end
end

-- Detecta quando o jogador equipa uma faca
local function onToolEquipped(tool)
    if tool and (tool.Name:lower():find("knife") or tool.Name:lower():find("dagger")) then
        currentKnife = tool
        if enabled then
            extendKnifeReach(tool)
        end
    else
        if currentKnife then
            restoreKnifeReach(currentKnife)
            currentKnife = nil
        end
    end
end

-- Conecta eventos de equipamento
local function setupCharacterEvents(character)
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.EquippedTool:Connect(onToolEquipped)
    if humanoid.ActiveTool then
        onToolEquipped(humanoid.ActiveTool)
    end
end

local connections = {}
function KnifeAura:Start()
    if LocalPlayer.Character then
        setupCharacterEvents(LocalPlayer.Character)
    end
    local charAddedConn = LocalPlayer.CharacterAdded:Connect(function(character)
        setupCharacterEvents(character)
    end)
    table.insert(connections, charAddedConn)
end

function KnifeAura:SetEnabled(state)
    enabled = state
    if state and currentKnife then
        extendKnifeReach(currentKnife)
    elseif not state and currentKnife then
        restoreKnifeReach(currentKnife)
    end
end

function KnifeAura:SetReach(newReach)
    reach = newReach
    if enabled and currentKnife then
        extendKnifeReach(currentKnife)
    end
end

function KnifeAura:Stop()
    for _, conn in ipairs(connections) do
        conn:Disconnect()
    end
    if currentKnife then
        restoreKnifeReach(currentKnife)
    end
end

return KnifeAura
