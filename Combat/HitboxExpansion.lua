--[[
    Orion Hub - Hitbox Expansion
    Aumenta o tamanho dos hitboxes dos jogadores (cabeça, tronco, membros).
    Utiliza BodyMover ou modifica diretamente o Size das partes.
]]

local HitboxExpansion = {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local enabled = false
local expansionAmount = 0 -- em studs (0 a 5)
local originalSizes = {} -- Salva tamanhos originais

-- Expande hitboxes de um personagem
local function expandHitboxes(character, amount)
    if not character or amount <= 0 then return end
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            if not originalSizes[part] then
                originalSizes[part] = part.Size
            end
            local newSize = originalSizes[part] + Vector3.new(amount, amount, amount)
            part.Size = newSize
        end
    end
end

-- Restaura hitboxes ao original
local function restoreHitboxes(character)
    if not character then return end
    for part, original in pairs(originalSizes) do
        if part and part.Parent then
            part.Size = original
        end
    end
    originalSizes = {}
end

-- Aplica a todos os jogadores (exceto local)
local function applyToAllPlayers()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if enabled and expansionAmount > 0 then
                expandHitboxes(player.Character, expansionAmount)
            else
                restoreHitboxes(player.Character)
            end
        end
    end
end

-- Observador de novos personagens
local function onCharacterAdded(player, character)
    character:WaitForChild("HumanoidRootPart")
    if enabled and expansionAmount > 0 then
        expandHitboxes(character, expansionAmount)
    end
end

-- Conecta eventos
local connections = {}
local function setupConnections()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local conn = player.CharacterAdded:Connect(function(char)
                onCharacterAdded(player, char)
            end)
            table.insert(connections, conn)
            if player.Character then
                onCharacterAdded(player, player.Character)
            end
        end
    end
    local playerAddedConn = Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then
            local conn = player.CharacterAdded:Connect(function(char)
                onCharacterAdded(player, char)
            end)
            table.insert(connections, conn)
        end
    end)
    table.insert(connections, playerAddedConn)
end

function HitboxExpansion:SetEnabled(state)
    enabled = state
    if not enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                restoreHitboxes(player.Character)
            end
        end
    else
        applyToAllPlayers()
    end
end

function HitboxExpansion:SetExpansion(amount)
    expansionAmount = amount
    if enabled then
        applyToAllPlayers()
    end
end

function HitboxExpansion:Start()
    setupConnections()
end

function HitboxExpansion:Stop()
    for _, conn in ipairs(connections) do
        conn:Disconnect()
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            restoreHitboxes(player.Character)
        end
    end
end

return HitboxExpansion
