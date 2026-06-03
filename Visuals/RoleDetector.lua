--[[
    Orion Hub - Role Detector
    Monitora ferramentas dos jogadores e notifica quando alguém é Murderer ou Sheriff.
]]

local RoleDetector = {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Utils = _G.Orion and _G.Orion.Modules and _G.Orion.Modules.Utils
local Notify = (Utils and Utils.Notify) or function(t, m) warn(t, m) end

local enabled = true
local detectedRoles = {} -- player -> role

-- Verifica o papel de um jogador baseado nas ferramentas
local function checkRole(player)
    if not enabled then return end
    local character = player.Character
    if not character then return end
    local role = "Innocent"
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            if tool.Name:lower():find("knife") then
                role = "Murderer"
                break
            elseif tool.Name:lower():find("gun") then
                role = "Sheriff"
                break
            end
        end
    end
    if detectedRoles[player] ~= role then
        detectedRoles[player] = role
        if role ~= "Innocent" then
            Notify("Role Detector", player.Name .. " is the " .. role .. "!", 3)
        end
    end
end

-- Observa mudanças nas ferramentas (através de DescendantAdded/Removed)
local function watchPlayer(player)
    if player == LocalPlayer then return end
    local character = player.Character
    if not character then
        player.CharacterAdded:Connect(function(char)
            watchCharacter(player, char)
        end)
        return
    end
    watchCharacter(player, character)
end

local function watchCharacter(player, character)
    checkRole(player)
    local addedConn = character.DescendantAdded:Connect(function(desc)
        if desc:IsA("Tool") then
            checkRole(player)
        end
    end)
    local removedConn = character.DescendantRemoving:Connect(function(desc)
        if desc:IsA("Tool") then
            checkRole(player)
        end
    end)
    -- Armazenar conexões para limpeza
    if not _G.Orion._roleDetectorConns then _G.Orion._roleDetectorConns = {} end
    _G.Orion._roleDetectorConns[player] = { addedConn, removedConn }
end

function RoleDetector:Start()
    for _, player in ipairs(Players:GetPlayers()) do
        watchPlayer(player)
    end
    Players.PlayerAdded:Connect(watchPlayer)
    Players.PlayerRemoving:Connect(function(player)
        if _G.Orion._roleDetectorConns and _G.Orion._roleDetectorConns[player] then
            for _, conn in ipairs(_G.Orion._roleDetectorConns[player]) do
                conn:Disconnect()
            end
            _G.Orion._roleDetectorConns[player] = nil
        end
        detectedRoles[player] = nil
    end)
end

function RoleDetector:SetEnabled(state)
    enabled = state
end

function RoleDetector:Stop()
    enabled = false
    if _G.Orion._roleDetectorConns then
        for player, conns in pairs(_G.Orion._roleDetectorConns) do
            for _, conn in ipairs(conns) do
                conn:Disconnect()
            end
        end
        _G.Orion._roleDetectorConns = nil
    end
end

return RoleDetector
