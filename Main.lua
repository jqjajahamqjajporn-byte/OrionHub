-- Carregar biblioteca WindHub (caminho relativo)
local WindHub = require(script.UI.WindHubLib)

-- Criar menu e abas
local function SetupMenu()
    local homeTab = WindHub:AddTab("Home")
    homeTab:AddLabel({ Text = "Orion Hub V1 - MM2", Size = 18, Color = Color3.fromRGB(255, 200, 100) })
    homeTab:AddLabel({ Text = "Status: Carregado com sucesso!" })
    homeTab:AddButton({ Text = "Copy Invite Code", Callback = function()
        setclipboard("Orion Hub V1 - Best MM2 Script")
        print("Código copiado")
    end })
    
    local combatTab = WindHub:AddTab("Combat")
    combatTab:AddToggle({ Text = "Silent Aim", Default = true, Callback = function(state) print("Silent Aim:", state) end })
    combatTab:AddSlider({ Text = "FOV", Min = 30, Max = 300, Default = 120, Callback = function(v) print("FOV:", v) end })
    
    local visualsTab = WindHub:AddTab("Visuals")
    visualsTab:AddToggle({ Text = "ESP Enabled", Default = true, Callback = function(state) print("ESP:", state) end })
    
    local miscTab = WindHub:AddTab("Misc")
    miscTab:AddToggle({ Text = "Anti-AFK", Default = false, Callback = function(state) print("Anti-AFK:", state) end })
    miscTab:AddButton({ Text = "Server Hop", Callback = function() print("Server Hop") end })
    
    local settingsTab = WindHub:AddTab("Settings")
    settingsTab:AddButton({ Text = "Save Config", Callback = function() print("Config saved") end })
    settingsTab:AddButton({ Text = "Load Defaults", Callback = function() print("Defaults loaded") end })
    
    print("Menu UI criada com sucesso. Pressione Insert para abrir.")
end

-- Keybind Insert
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        WindHub:Toggle()
    end
end)

-- Executar
local success, err = pcall(SetupMenu)
if success then
    print("Orion Hub iniciado corretamente.")
else
    warn("Erro ao criar UI: " .. tostring(err))
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Orion Hub Error",
        Text = "Erro ao carregar UI: " .. tostring(err),
        Duration = 10
    })
end
