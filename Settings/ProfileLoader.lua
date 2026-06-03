--[[
    Orion Hub - Profile Loader
    Gerencia múltiplos perfis de configuração.
]]

local ProfileLoader = {}
local HttpService = game:GetService("HttpService")
local profilesFolder = "OrionHub_Profiles/"
local currentProfile = "default"

-- Verifica suporte a arquivos
local function hasFileAccess()
    return type(writefile) == "function" and type(readfile) == "function" and type(makefolder) == "function"
end

-- Cria a pasta de perfis se não existir
local function ensureFolder()
    if hasFileAccess() and not isfolder(profilesFolder) then
        makefolder(profilesFolder)
    end
end

-- Salva o perfil atual com um nome
function ProfileLoader:SaveProfile(profileName)
    if not hasFileAccess() then
        warn("[Orion] Perfis requerem suporte a arquivos (writefile).")
        return false
    end
    ensureFolder()
    local config = _G.Orion.Settings
    local jsonData = HttpService:JSONEncode(config)
    local filename = profilesFolder .. profileName .. ".json"
    writefile(filename, jsonData)
    print("[Orion] Perfil salvo:", profileName)
    return true
end

-- Carrega um perfil pelo nome
function ProfileLoader:LoadProfile(profileName)
    if not hasFileAccess() then
        warn("[Orion] Perfis requerem suporte a arquivos.")
        return false
    end
    local filename = profilesFolder .. profileName .. ".json"
    if isfile(filename) then
        local content = readfile(filename)
        local success, decoded = pcall(HttpService.JSONDecode, HttpService, content)
        if success then
            _G.Orion.Settings = decoded
            currentProfile = profileName
            -- Aplicar configurações aos módulos
            if _G.Orion.Modules and _G.Orion.Modules.ConfigManager then
                _G.Orion.Modules.ConfigManager:ApplyToModules()
            end
            print("[Orion] Perfil carregado:", profileName)
            return true
        else
            warn("[Orion] Falha ao decodificar perfil:", profileName)
        end
    else
        warn("[Orion] Perfil não encontrado:", profileName)
    end
    return false
end

-- Lista todos os perfis disponíveis
function ProfileLoader:ListProfiles()
    if not hasFileAccess() then
        return {}
    end
    ensureFolder()
    local profiles = {}
    local files = listfiles(profilesFolder)
    for _, file in ipairs(files) do
        local name = file:match("([^/]+)%.json$")
        if name then
            table.insert(profiles, name)
        end
    end
    return profiles
end

-- Deleta um perfil
function ProfileLoader:DeleteProfile(profileName)
    if not hasFileAccess() then
        return false
    end
    local filename = profilesFolder .. profileName .. ".json"
    if isfile(filename) then
        delfile(filename)
        print("[Orion] Perfil deletado:", profileName)
        return true
    end
    return false
end

-- Carrega o último perfil usado (salva o nome em um arquivo separado)
function ProfileLoader:LoadLastProfile()
    if hasFileAccess() and isfile("OrionHub_LastProfile.txt") then
        local last = readfile("OrionHub_LastProfile.txt")
        if last and last ~= "" then
            self:LoadProfile(last)
        end
    end
end

-- Salva o nome do perfil atual para próximo load
function ProfileLoader:SaveCurrentProfileName()
    if hasFileAccess() then
        writefile("OrionHub_LastProfile.txt", currentProfile)
    end
end

return ProfileLoader
