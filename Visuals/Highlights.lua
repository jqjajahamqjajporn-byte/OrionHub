--[[
    Orion Hub - Highlights / Chams Module
    Adiciona um efeito de brilho ou outline nos personagens baseado no papel.
    Usa instância 'Highlight' para performance e compatibilidade.
]]

local Highlights = {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local enabled = false
local highlights = {} -- player -> Highlight

local roleColors = {
    Murderer = Color3.fromRGB(255, 50, 50),
    Sheriff = Color3.fromRGB(50, 50, 255),
    Innocent = Color3.fromRGB(50, 255, 50)
}

-- Obtém papel do jogador (reutiliza função do ESP ou Core/Utils)
local function getPlayerRole(player)
    if _G.Orion and _G.Orion.Modules and _G.Orion.Modules.Utils then
        return _G.Orion.Modules.Utils.GetPlayerRole(player)
    end
    if player.Character then
        for _, tool in ipairs(player.Character:GetChildren()) do
            if tool:IsA("Tool") then
                if tool.Name:lower():find("knife") then return "Murderer" end
                if tool.Name:lower():find("gun") then return "Sheriff" end
            end
        end
    end
    return "Innocent"
end

-- Cria ou atualiza o highlight de um jogador
local function updateHighlight(player)
    if not enabled then
        if highlights[player] then
            highlights[player]:Destroy()
            highlights[player] = nil
        end
        return
    end
    local character = player.Character
    if not character then
        if highlights[player] then
            highlights[player]:Destroy()
            highlights[player] = nil
        end
        return
    end
    if not highlights[player] then
        local highlight = Instance.new("Highlight")
        highlight.FillTransparency = 0.7
        highlight.OutlineTransparency = 0.4
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = character
        highlights[player] = highlight
    end
    local role = getPlayerRole(player)
    local color = roleColors[role] or roleColors.Innocent
    highlights[player].FillColor = color
    highlights[player].OutlineColor = color
end

-- Conecta eventos de personagem adicionado/removido
local connections = {}
local function setupPlayer(player)
    if player == LocalPlayer then return end
    updateHighlight(player)
    local charAddedConn = player.CharacterAdded:Connect(function()
        updateHighlight(player)
    end)
    local charRemovingConn = player.CharacterRemoving:Connect(function()
        if highlights[player] then
            highlights[player]:Destroy()
            highlights[player] = nil
        end
    end)
    table.insert(connections, charAddedConn)
    table.insert(connections, charRemovingConn)
end

function Highlights:Start()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            setupPlayer(player)
        end
    end
    local playerAddedConn = Players.PlayerAdded:Connect(setupPlayer)
    local playerRemovingConn = Players.PlayerRemoving:Connect(function(player)
        if highlights[player] then
            highlights[player]:Destroy()
            highlights[player] = nil
        end
    end)
    table.insert(connections, playerAddedConn)
    table.insert(connections, playerRemovingConn)
end

function Highlights:SetEnabled(state)
    enabled = state
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            updateHighlight(player)
        end
    end
end

function Highlights:Stop()
    for _, conn in ipairs(connections) do
        conn:Disconnect()
    end
    for _, hl in pairs(highlights) do
        hl:Destroy()
    end
    highlights = {}
end

return Highlights
