--[[
    Orion Hub - Custom Keybinds
    Gerencia teclas de atalho configuráveis pelo usuário.
]]

local Keybinds = {}
local UserInputService = game:GetService("UserInputService")

-- Dicionário de ações disponíveis
local actions = {
    toggleSilentAim = {
        callback = function()
            if _G.Orion.Settings then
                _G.Orion.Settings.silentAimEnabled = not _G.Orion.Settings.silentAimEnabled
                if _G.Orion.Modules and _G.Orion.Modules.SilentAim then
                    _G.Orion.Modules.SilentAim:SetEnabled(_G.Orion.Settings.silentAimEnabled)
                end
            end
        end,
        defaultKey = "Q"
    },
    toggleESP = {
        callback = function()
            if _G.Orion.Settings then
                _G.Orion.Settings.espEnabled = not _G.Orion.Settings.espEnabled
                if _G.Orion.Modules and _G.Orion.Modules.ESP then
                    _G.Orion.Modules.ESP:SetEnabled(_G.Orion.Settings.espEnabled)
                end
            end
        end,
        defaultKey = "E"
    },
    serverHop = {
        callback = function()
            if _G.Orion.Modules and _G.Orion.Modules.AutoJoin then
                _G.Orion.Modules.AutoJoin:Hop()
            end
        end,
        defaultKey = "H"
    }
}

-- Armazena binds atuais (key -> action)
local activeBinds = {}

-- Carrega binds salvos ou padrão
local function loadBinds()
    for actionName, data in pairs(actions) do
        local savedKey = _G.Orion.Settings and _G.Orion.Settings.keybinds and _G.Orion.Settings.keybinds[actionName]
        local key = savedKey or data.defaultKey
        activeBinds[key] = actionName
    end
end

-- Função chamada quando uma tecla é pressionada
local function onInputBegan(input, gameProcessed)
    if gameProcessed then return end
    local key = input.KeyCode.Name
    local action = activeBinds[key]
    if action and actions[action] then
        actions[action].callback()
    end
end

-- Conecta o evento
local inputConn = nil
function Keybinds:Start()
    loadBinds()
    inputConn = UserInputService.InputBegan:Connect(onInputBegan)
end

-- Permite alterar uma keybind dinamicamente (chamado pelo menu)
function Keybinds:SetKeybind(actionName, newKey)
    if not actions[actionName] then return end
    -- Remove bind antigo
    for k, act in pairs(activeBinds) do
        if act == actionName then
            activeBinds[k] = nil
            break
        end
    end
    activeBinds[newKey] = actionName
    -- Salva nas configurações
    if _G.Orion.Settings then
        _G.Orion.Settings.keybinds = _G.Orion.Settings.keybinds or {}
        _G.Orion.Settings.keybinds[actionName] = newKey
    end
end

-- Obtém a tecla atual de uma ação
function Keybinds:GetKeybind(actionName)
    for k, act in pairs(activeBinds) do
        if act == actionName then
            return k
        end
    end
    return actions[actionName] and actions[actionName].defaultKey or nil
end

function Keybinds:Stop()
    if inputConn then inputConn:Disconnect() end
end

return Keybinds
