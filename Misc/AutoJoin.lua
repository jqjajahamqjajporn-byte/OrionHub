--[[
    Orion Hub - Auto Join & Server Hop
    Permite pular para um novo servidor aleatório ou conectar a um servidor específico.
]]

local AutoJoin = {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local autoJoinEnabled = false
vararg = ""

-- Lista de servidores públicos do MM2 (exemplo via API)
local function getRandomServer()
    -- Usa uma API pública para obter servidores do jogo (ex: games.roblox.com)
    local placeId = game.PlaceId
    local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?limit=100"
    local success, response = pcall(function()
        return game:GetService("HttpService"):GetAsync(url)
    end)
    if success then
        local data = HttpService:JSONDecode(response)
        if data and data.data then
            local servers = {}
            for _, server in ipairs(data.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    table.insert(servers, server.id)
                end
            end
            if #servers > 0 then
                return servers[math.random(1, #servers)]
            end
        end
    end
    return nil
end

-- Função principal de teleporte para outro servidor
local function hopToServer(jobId)
    if jobId then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, LocalPlayer)
    else
        -- Fallback: teleportar para o mesmo jogo (entrará em outro servidor aleatório)
        TeleportService:Teleport(game.PlaceId)
    end
end

-- Server Hop: troca imediatamente para um servidor aleatório
function AutoJoin:Hop()
    local targetJobId = getRandomServer()
    if targetJobId then
        hopToServer(targetJobId)
    else
        warn("[Orion] Nenhum servidor disponível, tentando fallback")
        hopToServer(nil)
    end
end

-- Auto Join New Server: monitora o número de jogadores e troca quando ficar baixo
local function checkPlayerCount()
    if not autoJoinEnabled then return end
    local playerCount = #Players:GetPlayers()
    if playerCount <= 2 then -- servidor vazio ou quase vazio
        task.wait(2) -- pequeno delay para evitar loop
        AutoJoin:Hop()
    end
end

local playerCountConn = nil
function AutoJoin:SetAutoJoinEnabled(state)
    autoJoinEnabled = state
    if state and not playerCountConn then
        playerCountConn = Players.PlayerRemoving:Connect(checkPlayerCount)
        Players.PlayerAdded:Connect(checkPlayerCount)
        checkPlayerCount() -- verificação inicial
    elseif not state and playerCountConn then
        playerCountConn:Disconnect()
        playerCountConn = nil
    end
end

function AutoJoin:Stop()
    if playerCountConn then playerCountConn:Disconnect() end
end

return AutoJoin
