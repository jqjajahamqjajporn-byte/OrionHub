--[[
    Orion Hub - Main Entry Point
    Murder Mystery 2 Premium Script
    Version: V1
    Author: Orion Developer
]]

-- Desativa o modo de performance da biblioteca padrão (opcional)
local RunService = game:GetService("RunService")

-- Função segura para carregar módulos com fallback
local function loadModule(path)
    local success, module = pcall(require, path)
    if not success then
        warn("[Orion] Failed to load module: " .. tostring(path) .. " - " .. tostring(module))
        return nil
    end
    return module
end

-- Configurar ambiente global
_G.Orion = _G.Orion or {
    Loaded = false,
    Game = nil,
    Players = game:GetService("Players"),
    RunService = RunService,
    UserInputService = game:GetService("UserInputService"),
    CoreGui = game:GetService("CoreGui"),
    LocalPlayer = game:GetService("Players").LocalPlayer,
    Modules = {},
    Settings = {},
    PerformanceModeActive = false
}

-- Aguardar o jogo carregar completamente
local function waitForGame()
    repeat task.wait() until game:IsLoaded() and game.PlaceId == 142823291
end

-- Carregar módulos Core
local Core = loadModule(script.Core.Init)
local Events = loadModule(script.Core.Events)
local DrawingManager = loadModule(script.Core.DrawingManager)
local Utils = loadModule(script.Core.Utils)

-- Carregar módulos UI
local WindHub = loadModule(script.UI.WindHubLib)
local Menu = loadModule(script.UI.Menu)
local FloatingButton = loadModule(script.UI.FloatingButton)
local Notifications = loadModule(script.UI.Notifications)

-- Carregar módulos Combat
local SilentAim = loadModule(script.Combat.SilentAim)
local HitboxExpansion = loadModule(script.Combat.HitboxExpansion)
local Triggerbot = loadModule(script.Combat.Triggerbot)
local AutoShoot = loadModule(script.Combat.AutoShoot)
local KnifeAura = loadModule(script.Combat.KnifeAura)

-- Carregar módulos Visuals
local ESP = loadModule(script.Visuals.ESP)
local Highlights = loadModule(script.Visuals.Highlights)
local RoleDetector = loadModule(script.Visuals.RoleDetector)

-- Carregar módulos Misc
local AntiAFK = loadModule(script.Misc.AntiAFK)
local AutoJoin = loadModule(script.Misc.AutoJoin)
local Keybinds = loadModule(script.Misc.Keybinds)
local PerformanceMode = loadModule(script.Misc.PerformanceMode)

-- Carregar módulos Settings
local ConfigManager = loadModule(script.Settings.ConfigManager)
local ProfileLoader = loadModule(script.Settings.ProfileLoader)

-- Carregar Assets
local CustomAnimLoader = loadModule(script.Assets.Animations.CustomAnimLoader)

-- Inicializar Core primeiro
local function initCore()
    if not Core then
        error("[Orion] Core module is required!")
    end
    Core:Start()
    _G.Orion.LocalPlayer = _G.Orion.Players.LocalPlayer
    print("[Orion] Core initialized.")
end

-- Registrar todos os módulos no _G.Orion.Modules
local function registerModules()
    _G.Orion.Modules = {
        -- Core
        Utils = Utils,
        Events = Events,
        DrawingManager = DrawingManager,
        -- Combat
        SilentAim = SilentAim,
        HitboxExpansion = HitboxExpansion,
        Triggerbot = Triggerbot,
        AutoShoot = AutoShoot,
        KnifeAura = KnifeAura,
        -- Visuals
        ESP = ESP,
        Highlights = Highlights,
        RoleDetector = RoleDetector,
        -- Misc
        AntiAFK = AntiAFK,
        AutoJoin = AutoJoin,
        Keybinds = Keybinds,
        PerformanceMode = PerformanceMode,
        -- Settings
        ConfigManager = ConfigManager,
        ProfileLoader = ProfileLoader,
        -- Assets
        CustomAnimLoader = CustomAnimLoader
    }
    print("[Orion] All modules registered.")
end

-- Iniciar módulos (apenas aqueles que têm método Start)
local function startModules()
    if SilentAim then SilentAim:Start() end
    if HitboxExpansion then HitboxExpansion:Start() end
    if Triggerbot then Triggerbot:Start() end
    if AutoShoot then AutoShoot:Start() end
    if KnifeAura then KnifeAura:Start() end
    if ESP then ESP:Start() end
    if Highlights then Highlights:Start() end
    if RoleDetector then RoleDetector:Start() end
    if AntiAFK then AntiAFK:Start() end
    if AutoJoin then AutoJoin:Start() end
    if Keybinds then Keybinds:Start() end
    if PerformanceMode then PerformanceMode:Start() end
    print("[Orion] Modules started.")
end

-- Carregar configurações salvas e aplicar
local function loadSettings()
    if ConfigManager then
        ConfigManager:Load()
        -- Aplica as configurações aos módulos via ConfigManager
        ConfigManager:ApplyToModules()
    else
        warn("[Orion] ConfigManager not available, using defaults.")
    end
end

-- Criar UI (Menu e FloatingButton)
local function createUI()
    if Menu then
        Menu:Create()
        print("[Orion] Menu created.")
    else
        warn("[Orion] Menu module missing.")
    end
    -- Floating button já se cria sozinho, mas garantir que exista
    if not FloatingButton then
        warn("[Orion] FloatingButton not loaded.")
    end
end

-- Setup de keybind global Insert (já está no Events, mas garantimos)
local function setupGlobalKeybind()
    if Events then
        Events:SetupKeybinds(function()
            if WindHub then
                WindHub:Toggle()
            end
        end)
    end
end

-- Inicialização principal
local function main()
    waitForGame()
    initCore()
    registerModules()
    loadSettings()
    startModules()
    createUI()
    setupGlobalKeybind()
    
    -- Notificação de boas-vindas
    if Utils and Utils.Notify then
        Utils.Notify("Orion Hub", "Loaded successfully! Press Insert to open menu.", 3)
    else
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Orion Hub",
            Text = "Loaded! Press Insert.",
            Duration = 3
        })
    end
    
    _G.Orion.Loaded = true
    print("[Orion] Hub fully loaded. Version V1")
end

-- Executar com proteção contra erros
local success, err = pcall(main)
if not success then
    warn("[Orion] Critical error: " .. tostring(err))
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Orion Hub Error",
        Text = "Check console for details.",
        Duration = 5
    })
end

-- Opcional: manter o script rodando (não é necessário em executors)
if _G.Orion and _G.Orion.Loaded then
    -- Loop de manutenção vazio para evitar que o executor feche
    while _G.Orion.Loaded do
        task.wait(1)
    end
end
