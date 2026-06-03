--[[
    Orion Hub - ESP Module
    Exibe informações sobre jogadores e itens no mundo.
    Otimizado: apenas entidades visíveis, cache de cores, limpeza automática.
]]

local ESP = {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- Configurações (serão vinculadas ao menu)
local settings = {
    enabled = true,
    chams = true,
    name = true,
    distance = true,
    role = true,
    items = true,
    boxes = true,
    tracers = true
}

-- Armazenamento de objetos de desenho
local drawings = {
    boxes = {},   -- player -> { box, name, distance, role, tracer }
    items = {}    -- item -> { text, line }
}

-- Cores por papel
local roleColors = {
    Murderer = Color3.fromRGB(255, 0, 0),
    Sheriff = Color3.fromRGB(0, 0, 255),
    Innocent = Color3.fromRGB(0, 255, 0)
}

-- Função auxiliar para obter papel (usa Core/Utils se disponível)
local function getPlayerRole(player)
    if _G.Orion and _G.Orion.Modules and _G.Orion.Modules.Utils then
        return _G.Orion.Modules.Utils.GetPlayerRole(player)
    end
    -- Fallback simples
    if player.Character then
        for _, tool in ipairs(player.Character:GetChildren()) do
            if tool:IsA("Tool") then
                if tool.Name:lower():find("knife") then return "Murderer" end
                if tool.Name:lower():find("gun") then return "Sheriff" end
            end
        end
    end
    return "Innocent"
end

-- Cria uma caixa 2D ao redor do personagem
local function createBox(player)
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Color = Color3.fromRGB(255, 255, 255)
    box.Filled = false
    box.Visible = false
    box.ZIndex = 5
    return box
end

-- Cria um texto para nome/distância/papel
local function createText()
    local text = Drawing.new("Text")
    text.Size = 14
    text.Center = true
    text.Outline = true
    text.OutlineColor = Color3.fromRGB(0, 0, 0)
    text.Visible = false
    text.ZIndex = 6
    return text
end

-- Cria um tracer (linha do centro da tela até o alvo)
local function createTracer()
    local line = Drawing.new("Line")
    line.Thickness = 1
    line.Color = Color3.fromRGB(255, 255, 255)
    line.Visible = false
    line.ZIndex = 4
    return line
end

-- Calcula a bounding box do personagem na tela
local function getCharacterBounds(character)
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    if not hrp or not head then return nil end
    local rootPos, onScreen = Camera:WorldToScreenPoint(hrp.Position)
    if not onScreen then return nil end
    local headPos = Camera:WorldToScreenPoint(head.Position)
    local height = math.abs(rootPos.Y - headPos.Y) * 2.5
    local width = height * 0.6
    return {
        X = rootPos.X - width/2,
        Y = rootPos.Y - height,
        Width = width,
        Height = height
    }
end

-- Atualiza ESP para um jogador
local function updatePlayerESP(player)
    if not settings.enabled then return end
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        -- Limpar desenhos se personagem não existe
        if drawings.boxes[player] then
            for _, obj in pairs(drawings.boxes[player]) do
                obj.Visible = false
            end
        end
        return
    end

    -- Criar objetos se não existirem
    if not drawings.boxes[player] then
        drawings.boxes[player] = {
            box = settings.boxes and createBox() or nil,
            nameText = settings.name and createText() or nil,
            distText = settings.distance and createText() or nil,
            roleText = settings.role and createText() or nil,
            tracer = settings.tracers and createTracer() or nil
        }
    end

    local bounds = getCharacterBounds(character)
    if not bounds then
        for _, obj in pairs(drawings.boxes[player]) do
            if obj then obj.Visible = false end
        end
        return
    end

    local role = getPlayerRole(player)
    local color = roleColors[role] or roleColors.Innocent

    -- Box
    if settings.boxes and drawings.boxes[player].box then
        local box = drawings.boxes[player].box
        box.Position = Vector2.new(bounds.X, bounds.Y)
        box.Size = Vector2.new(bounds.Width, bounds.Height)
        box.Color = color
        box.Visible = true
    end

    -- Nome
    if settings.name and drawings.boxes[player].nameText then
        local nameText = drawings.boxes[player].nameText
        nameText.Text = player.Name
        nameText.Position = Vector2.new(bounds.X + bounds.Width/2, bounds.Y - 15)
        nameText.Color = Color3.fromRGB(255, 255, 255)
        nameText.Visible = true
    end

    -- Distância
    if settings.distance and drawings.boxes[player].distText then
        local hrp = character.HumanoidRootPart
        local dist = (hrp.Position - (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position or Vector3.zero)).Magnitude
        local distText = drawings.boxes[player].distText
        distText.Text = string.format("%.1fm", dist)
        distText.Position = Vector2.new(bounds.X + bounds.Width/2, bounds.Y + bounds.Height + 10)
        distText.Color = color
        distText.Visible = true
    end

    -- Papel (acima da cabeça)
    if settings.role and drawings.boxes[player].roleText then
        local roleText = drawings.boxes[player].roleText
        roleText.Text = role
        roleText.Position = Vector2.new(bounds.X + bounds.Width/2, bounds.Y - 30)
        roleText.Color = color
        roleText.Visible = true
    end

    -- Tracer (linha do centro da tela)
    if settings.tracers and drawings.boxes[player].tracer then
        local hrp = character.HumanoidRootPart
        local screenPos = Camera:WorldToScreenPoint(hrp.Position)
        local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        local tracer = drawings.boxes[player].tracer
        tracer.From = center
        tracer.To = Vector2.new(screenPos.X, screenPos.Y)
        tracer.Color = color
        tracer.Visible = true
    end
end

-- ESP para itens (armas, facas, moedas) no chão
local function updateItemESP()
    if not settings.enabled or not settings.items then
        -- Limpar desenhos de itens
        for _, draw in pairs(drawings.items) do
            if draw.text then draw.text:Remove() end
            if draw.line then draw.line:Remove() end
        end
        drawings.items = {}
        return
    end

    local itemsFound = {}
    -- Procurar por tools/objetos no workspace que estão no chão (não segurados)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") or (obj.Name:lower():find("coin") or obj.Name:lower():find("knife") or obj.Name:lower():find("gun")) then
            if obj.Parent ~= LocalPlayer.Character and not obj.Parent:IsA("Player") then
                local pos = obj:FindFirstChild("Handle") and obj.Handle.Position or obj.Position
                if pos then
                    local screenPos, onScreen = Camera:WorldToScreenPoint(pos)
                    if onScreen then
                        if not drawings.items[obj] then
                            local text = Drawing.new("Text")
                            text.Size = 12
                            text.Center = true
                            text.Outline = true
                            text.Color = Color3.fromRGB(255, 255, 100)
                            local line = Drawing.new("Line")
                            line.Thickness = 1
                            line.Color = Color3.fromRGB(255, 200, 0)
                            line.Visible = settings.tracers
                            drawings.items[obj] = { text = text, line = line }
                        end
                        local text = drawings.items[obj].text
                        text.Text = obj.Name
                        text.Position = Vector2.new(screenPos.X, screenPos.Y - 20)
                        text.Visible = true
                        if drawings.items[obj].line then
                            local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                            local line = drawings.items[obj].line
                            line.From = center
                            line.To = Vector2.new(screenPos.X, screenPos.Y)
                            line.Visible = settings.tracers
                        end
                        itemsFound[obj] = true
                    end
                end
            end
        end
    end
    -- Remover desenhos de itens que não existem mais
    for obj, draw in pairs(drawings.items) do
        if not itemsFound[obj] or not obj.Parent then
            if draw.text then draw.text:Remove() end
            if draw.line then draw.line:Remove() end
            drawings.items[obj] = nil
        end
    end
end

-- Loop principal de renderização
local renderConn = nil
function ESP:Start()
    renderConn = RunService.RenderStepped:Connect(function()
        if not settings.enabled then
            -- Ocultar todos os desenhos
            for _, data in pairs(drawings.boxes) do
                for _, obj in pairs(data) do
                    if obj then obj.Visible = false end
                end
            end
            for _, draw in pairs(drawings.items) do
                if draw.text then draw.text.Visible = false end
                if draw.line then draw.line.Visible = false end
            end
            return
        end
        -- Atualizar players
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                updatePlayerESP(player)
            end
        end
        updateItemESP()
    end)
end

-- Funções para controle do menu
function ESP:SetEnabled(state)
    settings.enabled = state
end

function ESP:SetChams(state) -- Chams é separado (Highlight ou material override)
    settings.chams = state
    -- Chams será gerenciado pelo módulo Highlights.lua
    if _G.Orion and _G.Orion.Modules and _G.Orion.Modules.Highlights then
        _G.Orion.Modules.Highlights:SetEnabled(state and settings.chams)
    end
end

function ESP:SetName(state)
    settings.name = state
end

function ESP:SetDistance(state)
    settings.distance = state
end

function ESP:SetRole(state)
    settings.role = state
end

function ESP:SetItems(state)
    settings.items = state
end

function ESP:SetBoxes(state)
    settings.boxes = state
end

function ESP:ToggleTracers(state)
    settings.tracers = state
end

function ESP:Stop()
    if renderConn then renderConn:Disconnect() end
    -- Limpar todos os desenhos
    for _, data in pairs(drawings.boxes) do
        for _, obj in pairs(data) do
            if obj then obj:Remove() end
        end
    end
    for _, draw in pairs(drawings.items) do
        if draw.text then draw.text:Remove() end
        if draw.line then draw.line:Remove() end
    end
    drawings = { boxes = {}, items = {} }
end

return ESP
