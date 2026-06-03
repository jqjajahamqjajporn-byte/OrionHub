--[[
    Orion Hub - Custom Animations Loader
    Permite carregar e aplicar animações personalizadas no jogador local.
    Suporta arquivos locais (se o executor tiver permissão) ou IDs de animação da biblioteca Roblox.
]]

local CustomAnimLoader = {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local AnimationsFolder = script.Parent -- pasta Assets/Animations

-- Armazena animações carregadas
local loadedAnims = {}
local currentAnimTrack = nil

-- Verifica suporte a arquivos
local function hasFileAccess()
    return type(readfile) == "function" and type(isfile) == "function"
end

-- Carrega animação de um arquivo .rbxm (modelo contendo Animation)
function CustomAnimLoader:LoadFromFile(fileName)
    if not hasFileAccess() then
        warn("[Orion] Executor sem suporte a arquivos.")
        return nil
    end
    local fullPath = AnimationsFolder.Name .. "/" .. fileName
    if not isfile(fullPath) then
        warn("[Orion] Arquivo não encontrado:", fullPath)
        return nil
    end
    local content = readfile(fullPath)
    -- O conteúdo é um XML (rbxm), precisamos instanciar
    local success, obj = pcall(function()
        return game:GetService("InsertService"):LoadAsset(content)
    end)
    if success and obj then
        local animation = obj:FindFirstChildWhichIsA("Animation")
        if animation then
            return animation
        else
            warn("[Orion] Arquivo não contém uma Animation válida.")
        end
    else
        warn("[Orion] Falha ao carregar arquivo de animação.")
    end
    return nil
end

-- Carrega animação por Asset ID (da biblioteca Roblox)
function CustomAnimLoader:LoadFromId(assetId)
    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://" .. tostring(assetId)
    return animation
end

-- Aplica uma animação ao personagem local (em um loop opcional)
function CustomAnimLoader:ApplyAnimation(animation, loop, fadeTime)
    if not LocalPlayer.Character then return end
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    if not humanoid then return end
    -- Limpa animação anterior
    if currentAnimTrack then
        currentAnimTrack:Stop()
        currentAnimTrack:Destroy()
    end
    local animator = humanoid:FindFirstChild("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end
    local track = animator:LoadAnimation(animation)
    track.Priority = Enum.AnimationPriority.Action
    if loop then
        track.Looped = true
    else
        track.Looped = false
    end
    track:Play()
    currentAnimTrack = track
    return track
end

-- Para a animação atual
function CustomAnimLoader:StopAnimation()
    if currentAnimTrack then
        currentAnimTrack:Stop()
        currentAnimTrack = nil
    end
end

-- Exemplo: carrega animação de dança padrão (ID fictício)
function CustomAnimLoader:LoadDanceAnimation()
    local danceId = 507771037 -- exemplo: dança default do Roblox
    local anim = self:LoadFromId(danceId)
    return anim
end

-- Interface para o menu: selecionar e aplicar
function CustomAnimLoader:ShowLoadDialog()
    -- Placeholder: normalmente seria um prompt na UI.
    -- Aqui apenas exemplifica.
    print("[Orion] Use CustomAnimLoader:LoadFromFile('myAnim.rbxm') ou LoadFromId(123456789)")
end

return CustomAnimLoader
