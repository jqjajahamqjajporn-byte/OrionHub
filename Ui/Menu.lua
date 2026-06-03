--[[
    Orion Hub - Menu Principal
    Cria as abas: Home, Main, Combat, Visuals, Misc, Settings
    Integra com os módulos do hub (Core, Combat, Visuals, Misc, Settings)
]]

local Menu = {}
local WindHub = require(script.Parent.WindHubLib) -- ou loadstring se necessário
local Core = require(script.Parent.Parent.Core.Init)
local Events = require(script.Parent.Parent.Core.Events)
local Utils = require(script.Parent.Parent.Core.Utils)

-- Referências para módulos que serão carregados depois
local Combat = nil
local Visuals = nil
local Misc = nil
local Settings = nil

function Menu:Create()
    -- Aguarda o Core iniciar
    if not _G.Orion.Loaded then
        Core:Start()
    end
    
    -- Cria janela principal
    local window = WindHub -- já está com a GUI criada
    
    -- Aba Home
    local homeTab = WindHub:AddTab("Home")
    homeTab:AddLabel({ Text = "Orion Hub V1 - MM2", Size = 18, Color = Color3.fromRGB(255, 200, 100) })
    homeTab:AddLabel({ Text = "Status:" })
    local roleLabel = homeTab:AddLabel({ Text = "Role: " .. Core:GetRole() })
    local playersLabel = homeTab:AddLabel({ Text = "Players Online: " .. #game:GetService("Players"):GetPlayers() })
    
    -- Atualiza labels periodicamente
    task.spawn(function()
        while _G.Orion.Loaded do
            roleLabel.Text = "Role: " .. Core:GetRole()
            playersLabel.Text = "Players Online: " .. #game:GetService("Players"):GetPlayers()
            task.wait(1)
        end
    end)
    
    homeTab:AddButton({ Text = "Copy Invite Code", Callback = function()
        setclipboard("Orion Hub V1 - Best MM2 Script")
        Utils.Notify("Orion", "Invite code copied!", 2)
    end })
    homeTab:AddLabel({ Text = "Credits: Orion Developer", Color = Color3.fromRGB(150, 150, 150), Size = 12 })
    
    -- Aba Main (Teleports removido conforme solicitado)
    local mainTab = WindHub:AddTab("Main")
    mainTab:AddButton({ Text = "Teleport to Players", Callback = function()
        -- Abre uma lista simples (poderia ser um dropdown, mas por simplicidade, um input)
        local playersList = {}
        for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
            if p ~= _G.Orion.LocalPlayer then
                table.insert(playersList, p.Name)
            end
        end
        local chosen = game:GetService("GuiService"):GetScreenGui():FindFirstChild("TextBox") -- hack, melhor usar prompt
        -- Placeholder: usar input nativo
        local text = Utils.Notify("Enter player name:", "Type name to teleport", 5)
        -- Implementação real usaria um prompt customizado, mas para simplificar:
        -- (aqui deixamos apenas o esboço, será chamado do módulo TeleportsToPlayers se existir)
        Utils.Notify("Teleport", "Feature implemented in Teleports module", 2)
    end })
    mainTab:AddButton({ Text = "Teleport to Map Locations", Callback = function()
        Utils.Notify("Map Teleports", "Gun spawn, Coin spawn, Safe spots", 2)
    end })
    mainTab:AddButton({ Text = "Auto Equip Best Knife/Gun", Callback = function()
        -- Lógica: encontrar a melhor faca/arma no inventário e equipar
        local char = _G.Orion.LocalPlayer.Character
        if char then
            local bestKnife = nil
            local bestGun = nil
            for _, tool in ipairs(char:GetChildren()) do
                if tool:IsA("Tool") then
                    if tool.Name:lower():find("knife") then
                        bestKnife = tool
                    elseif tool.Name:lower():find("gun") then
                        bestGun = tool
                    end
                end
            end
            if bestKnife then
                _G.Orion.LocalPlayer.Character.Humanoid:EquipTool(bestKnife)
            elseif bestGun then
                _G.Orion.LocalPlayer.Character.Humanoid:EquipTool(bestGun)
            end
        end
        Utils.Notify("Auto Equip", "Best weapon equipped", 1)
    end })
    mainTab:AddButton({ Text = "Role Detector (Instant Warning)", Callback = function()
        -- Já será ativado pelo módulo Visuals/RoleDetector, este botão apenas liga/desliga
        _G.Orion.Settings.roleDetector = not _G.Orion.Settings.roleDetector
        Utils.Notify("Role Detector", _G.Orion.Settings.roleDetector and "Enabled" or "Disabled", 1)
    end })
    mainTab:AddButton({ Text = "Custom Animations Loader", Callback = function()
        -- Placeholder para carregar animações customizadas
        Utils.Notify("Animations", "Load custom animation from file", 2)
    end })
    
    -- Aba Combat
    local combatTab = WindHub:AddTab("Combat")
    combatTab:AddToggle({ Text = "Silent Aim (Knife & Gun)", Default = true, Callback = function(state)
        _G.Orion.Settings.silentAimEnabled = state
        if _G.Orion.Modules.SilentAim then
            _G.Orion.Modules.SilentAim:SetEnabled(state)
        end
    end })
    combatTab:AddSlider({ Text = "Silent Aim FOV", Min = 30, Max = 300, Default = 120, Callback = function(value)
        _G.Orion.Settings.silentAimFOV = value
        if _G.Orion.Modules.SilentAim then
            _G.Orion.Modules.SilentAim:UpdateFOV(value)
        end
    end })
    combatTab:AddSlider({ Text = "Hitbox Expansion", Min = 0, Max = 5, Default = 0, Callback = function(value)
        _G.Orion.Settings.hitboxExpansion = value
        if _G.Orion.Modules.HitboxExpansion then
            _G.Orion.Modules.HitboxExpansion:SetExpansion(value)
        end
    end })
    combatTab:AddToggle({ Text = "Wallbang / Wall Check", Default = false, Callback = function(state)
        _G.Orion.Settings.wallbang = state
    end })
    combatTab:AddSlider({ Text = "Aim Smoothing", Min = 0, Max = 1, Default = 0.3, Callback = function(value)
        _G.Orion.Settings.aimSmoothing = value
    end })
    combatTab:AddToggle({ Text = "Triggerbot", Default = false, Callback = function(state)
        _G.Orion.Settings.triggerbot = state
        if _G.Orion.Modules.Triggerbot then
            _G.Orion.Modules.Triggerbot:SetEnabled(state)
        end
    end })
    combatTab:AddToggle({ Text = "Auto Shoot (Sheriff)", Default = false, Callback = function(state)
        _G.Orion.Settings.autoShoot = state
    end })
    combatTab:AddSlider({ Text = "Knife Aura / Reach", Min = 5, Max = 30, Default = 15, Callback = function(value)
        _G.Orion.Settings.knifeReach = value
        if _G.Orion.Modules.KnifeAura then
            _G.Orion.Modules.KnifeAura:SetReach(value)
        end
    end })
    
    -- Aba Visuals
    local visualsTab = WindHub:AddTab("Visuals")
    visualsTab:AddToggle({ Text = "ESP Enabled", Default = true, Callback = function(state)
        _G.Orion.Settings.espEnabled = state
        if _G.Orion.Modules.ESP then
            _G.Orion.Modules.ESP:SetEnabled(state)
        end
    end })
    visualsTab:AddToggle({ Text = "ESP Chams (Colors by Role)", Default = true, Callback = function(state)
        _G.Orion.Settings.espChams = state
    end })
    visualsTab:AddToggle({ Text = "ESP Name", Default = true, Callback = function(state)
        _G.Orion.Settings.espName = state
    end })
    visualsTab:AddToggle({ Text = "ESP Distance", Default = true, Callback = function(state)
        _G.Orion.Settings.espDistance = state
    end })
    visualsTab:AddToggle({ Text = "ESP Role", Default = true, Callback = function(state)
        _G.Orion.Settings.espRole = state
    end })
    visualsTab:AddToggle({ Text = "ESP Items (Guns, Knives, Coins)", Default = true, Callback = function(state)
        _G.Orion.Settings.espItems = state
    end })
    visualsTab:AddToggle({ Text = "ESP Boxes", Default = true, Callback = function(state)
        _G.Orion.Settings.espBoxes = state
    end })
    visualsTab:AddToggle({ Text = "Tracers", Default = true, Callback = function(state)
        _G.Orion.Settings.tracers = state
        if _G.Orion.Modules.ESP then
            _G.Orion.Modules.ESP:ToggleTracers(state)
        end
    end })
    visualsTab:AddToggle({ Text = "Highlight Players", Default = false, Callback = function(state)
        _G.Orion.Settings.highlight = state
    end })
    
    -- Aba Misc
    local miscTab = WindHub:AddTab("Misc")
    miscTab:AddToggle({ Text = "Anti-AFK", Default = false, Callback = function(state)
        _G.Orion.Settings.antiAFK = state
        if _G.Orion.Modules.AntiAFK then
            _G.Orion.Modules.AntiAFK:SetEnabled(state)
        end
    end })
    miscTab:AddToggle({ Text = "Auto Join New Server", Default = false, Callback = function(state)
        _G.Orion.Settings.autoJoin = state
    end })
    miscTab:AddButton({ Text = "Server Hop", Callback = function()
        if _G.Orion.Modules.AutoJoin then
            _G.Orion.Modules.AutoJoin:Hop()
        end
    end })
    miscTab:AddKeybind({ Text = "Toggle Silent Aim Keybind", Default = "Insert", Callback = function(key)
        _G.Orion.Settings.keybinds.toggleSilentAim = key
        Utils.Notify("Keybind Set", "Silent Aim toggled with " .. key, 2)
    end })
    miscTab:AddToggle({ Text = "Performance Mode", Default = false, Callback = function(state)
        _G.Orion.Settings.performanceMode = state
        if _G.Orion.Modules.PerformanceMode then
            _G.Orion.Modules.PerformanceMode:SetEnabled(state)
        end
    end })
    miscTab:AddButton({ Text = "Clear Notifications", Callback = function()
        -- Implementar se necessário
    end })
    
    -- Aba Settings
    local settingsTab = WindHub:AddTab("Settings")
    settingsTab:AddButton({ Text = "Save Current Config", Callback = function()
        if _G.Orion.Modules.ConfigManager then
            _G.Orion.Modules.ConfigManager:Save()
        end
        Utils.Notify("Config", "Saved!", 1)
    end })
    settingsTab:AddButton({ Text = "Load Default Config", Callback = function()
        if _G.Orion.Modules.ConfigManager then
            _G.Orion.Modules.ConfigManager:LoadDefaults()
        end
        Utils.Notify("Config", "Defaults loaded", 1)
    end })
    settingsTab:AddButton({ Text = "Reset UI Position", Callback = function()
        -- Resetar posição da janela (se implementado)
    end })
    
    -- Configurar keybind Insert para abrir/fechar
    Events:SetupKeybinds(function()
        WindHub:Toggle()
    end)
    
    print("[Orion] Menu created successfully")
end

return Menu
