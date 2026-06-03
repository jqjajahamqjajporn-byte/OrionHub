--[[
    Orion Hub - Core Init
    Responsável por configurar o ambiente global, verificar o jogo e inicializar módulos.
]]

local Init = {}

-- Variáveis globais do hub (protegidas)
_G.Orion = _G.Orion or {
    Loaded = false,
    Game = nil,
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    CoreGui = game:GetService("CoreGui"),
    Drawing = Drawing, -- API de desenho
    LocalPlayer = nil,
    CurrentRole = nil,
    Settings = {}, -- Será preenchido pelo ConfigManager
    Modules = {} -- Referências para outros módulos
}

-- Verifica se está no Murder Mystery 2
local function checkGame()
    if game.PlaceId == 142823291 or game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).name:find("Murder Mystery") then
        _G.Orion.Game = "MM2"
        return true
    else
        warn("[Orion] Jogo não suportado. Apenas Murder Mystery 2.")
        return false
    end
end

-- Obtém o papel do jogador local (Murderer, Sheriff, Innocent)
local function getRole()
    local lp = _G.Orion.LocalPlayer
    if not lp then return "Unknown" end
    local character = lp.Character
    if not character then return "Unknown" end
    -- Verifica se tem a ferramenta de Murderer (Knife) ou Sheriff (Gun)
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            if tool.Name:lower():find("knife") then
                return "Murderer"
            elseif tool.Name:lower():find("gun") or tool.Name:lower():find("pistol") then
                return "Sheriff"
            end
        end
    end
    return "Innocent"
end

-- Atualiza o papel a cada segundo
local function updateRoleLoop()
    while _G.Orion.Loaded do
        _G.Orion.CurrentRole = getRole()
        task.wait(1)
    end
end

-- Inicialização principal
function Init:Start()
    if _G.Orion.Loaded then return end
    if not checkGame() then return end
    
    _G.Orion.LocalPlayer = _G.Orion.Players.LocalPlayer
    _G.Orion.CurrentRole = getRole()
    
    -- Carregar configurações (placeholders até o ConfigManager existir)
    _G.Orion.Settings = {
        silentAimEnabled = true,
        silentAimFOV = 120,
        hitboxExpansion = 0,
        wallbang = false,
        aimSmoothing = 0.3,
        triggerbot = false,
        autoShoot = false,
        knifeReach = 15,
        espEnabled = true,
        espChams = true,
        espName = true,
        espDistance = true,
        espRole = true,
        espItems = true,
        espBoxes = true,
        tracers = true,
        highlight = false,
        antiAFK = false,
        autoJoin = false,
        performanceMode = false,
        keybinds = {}
    }
    
    -- Iniciar loop de papel
    task.spawn(updateRoleLoop)
    
    _G.Orion.Loaded = true
    print("[Orion] Core inicializado com sucesso!")
end

function Init:GetRole()
    return _G.Orion.CurrentRole
end

return Init
