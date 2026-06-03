--[[
    Orion Hub - Default Settings
    Valores iniciais para todas as funcionalidades.
]]

local Defaults = {
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
    roleDetector = true,  -- notificação de papel
    
    -- Misc
    antiAFK = false,
    autoJoin = false,
    performanceMode = false,
    
    -- Keybinds
    keybinds = {
        toggleSilentAim = "Q",
        toggleESP = "E",
        serverHop = "H",
        toggleMenu = "Insert"
    },
    
    -- UI
    menuPosition = UDim2.new(0.5, -300, 0.5, -225), -- posição da janela
    floatingButtonPosition = UDim2.new(0.8, 0, 0.8, 0)
}

-- Função para resetar as configurações do _G.Orion.Settings
function Defaults:Reset()
    if _G.Orion then
        _G.Orion.Settings = self
    end
    return self
end

return Defaults
