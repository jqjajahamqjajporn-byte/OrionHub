--[[
    Orion Hub - Config Manager
    Salva e carrega as configurações do usuário persistentemente.
]]

local ConfigManager = {}
local HttpService = game:GetService("HttpService")
local configFileName = "OrionHub_Config.json"

-- Configuração padrão (será mesclada com Defaults.lua)
local defaultConfig = {
    -- Combat
    silentAimEnabled = true,
    silentAimFOV = 120,
    hitboxExpansion = 0,
    wallbang = false,
    aimSmoothing = 0.3,
    triggerbot = false,
    autoShoot = false,
    knifeReach = 15,
    -- Visuals
    espEnabled = true,
    espChams = true,
    espName = true,
    espDistance = true,
    espRole = true,
    espItems = true,
    espBoxes = true,
    tracers = true,
    highlight = false,
    -- Misc
    antiAFK = false,
    autoJoin = false,
    performanceMode = false,
    -- Keybinds
    keybinds = {
        toggleSilentAim = "Q",
        toggleESP = "E",
        serverHop = "H"
    }
}

-- Verifica se o executor permite acesso a arquivos
local function hasFileAccess()
    return type(writefile) == "function" and type(readfile) == "function"
end

-- Salva a configuração atual em arquivo (se possível) ou na área de transferência
function ConfigManager:Save()
    local config = _G.Orion.Settings or defaultConfig
    local jsonData = HttpService:JSONEncode(config)
    if hasFileAccess() then
        writefile(configFileName, jsonData)
        print("[Orion] Configuração salva em:", configFileName)
    else
        -- Fallback: salvar na área de transferência (útil para backup manual)
        setclipboard(jsonData)
        warn("[Orion] Executor sem suporte a writefile. Configuração copiada para clipboard.")
    end
    return true
end

-- Carrega a configuração do arquivo ou usa padrão
function ConfigManager:Load()
    local loadedConfig = nil
    if hasFileAccess() and isfile(configFileName) then
        local content = readfile(configFileName)
        if content and content ~= "" then
            local success, decoded = pcall(HttpService.JSONDecode, HttpService, content)
            if success then
                loadedConfig = decoded
                print("[Orion] Configuração carregada do arquivo.")
            else
                warn("[Orion] Falha ao decodificar configuração. Usando padrão.")
            end
        end
    end
    -- Mesclar com padrão (garantir que todas as chaves existam)
    local finalConfig = defaultConfig
    if loadedConfig then
        for k, v in pairs(loadedConfig) do
            if type(v) == "table" and type(finalConfig[k]) == "table" then
                for subk, subv in pairs(v) do
                    finalConfig[k][subk] = subv
                end
            else
                finalConfig[k] = v
            end
        end
    end
    _G.Orion.Settings = finalConfig
    -- Aplicar configurações aos módulos (callbacks)
    self:ApplyToModules()
    return finalConfig
end

-- Aplica as configurações atuais aos módulos carregados (garantir sync)
function ConfigManager:ApplyToModules()
    local modules = _G.Orion.Modules
    if not modules then return end
    -- Silent Aim
    if modules.SilentAim then
        modules.SilentAim:SetEnabled(_G.Orion.Settings.silentAimEnabled)
        modules.SilentAim:UpdateFOV(_G.Orion.Settings.silentAimFOV)
        modules.SilentAim:SetWallbang(_G.Orion.Settings.wallbang)
        modules.SilentAim:SetSmoothing(_G.Orion.Settings.aimSmoothing)
    end
    -- Hitbox
    if modules.HitboxExpansion then
        modules.HitboxExpansion:SetEnabled(_G.Orion.Settings.hitboxExpansion > 0)
        modules.HitboxExpansion:SetExpansion(_G.Orion.Settings.hitboxExpansion)
    end
    -- Triggerbot
    if modules.Triggerbot then
        modules.Triggerbot:SetEnabled(_G.Orion.Settings.triggerbot)
    end
    -- AutoShoot
    if modules.AutoShoot then
        modules.AutoShoot:SetEnabled(_G.Orion.Settings.autoShoot)
    end
    -- Knife Aura
    if modules.KnifeAura then
        modules.KnifeAura:SetEnabled(_G.Orion.Settings.knifeReach > 5)
        modules.KnifeAura:SetReach(_G.Orion.Settings.knifeReach)
    end
    -- ESP
    if modules.ESP then
        modules.ESP:SetEnabled(_G.Orion.Settings.espEnabled)
        modules.ESP:SetChams(_G.Orion.Settings.espChams)
        modules.ESP:SetName(_G.Orion.Settings.espName)
        modules.ESP:SetDistance(_G.Orion.Settings.espDistance)
        modules.ESP:SetRole(_G.Orion.Settings.espRole)
        modules.ESP:SetItems(_G.Orion.Settings.espItems)
        modules.ESP:SetBoxes(_G.Orion.Settings.espBoxes)
        modules.ESP:ToggleTracers(_G.Orion.Settings.tracers)
    end
    -- Highlights (Chams)
    if modules.Highlights then
        modules.Highlights:SetEnabled(_G.Orion.Settings.espChams and _G.Orion.Settings.espEnabled)
    end
    -- Role Detector
    if modules.RoleDetector then
        modules.RoleDetector:SetEnabled(_G.Orion.Settings.roleDetector or true)
    end
    -- AntiAFK
    if modules.AntiAFK then
        modules.AntiAFK:SetEnabled(_G.Orion.Settings.antiAFK)
    end
    -- AutoJoin
    if modules.AutoJoin then
        modules.AutoJoin:SetAutoJoinEnabled(_G.Orion.Settings.autoJoin)
    end
    -- Performance Mode
    if modules.PerformanceMode then
        modules.PerformanceMode:SetEnabled(_G.Orion.Settings.performanceMode)
    end
    -- Keybinds (aplicar binds salvos)
    if modules.Keybinds and _G.Orion.Settings.keybinds then
        for action, key in pairs(_G.Orion.Settings.keybinds) do
            modules.Keybinds:SetKeybind(action, key)
        end
    end
end

-- Restaura a configuração padrão
function ConfigManager:LoadDefaults()
    _G.Orion.Settings = defaultConfig
    self:ApplyToModules()
    self:Save() -- salva imediatamente
    print("[Orion] Configuração padrão restaurada.")
end

return ConfigManager
