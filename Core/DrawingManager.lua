 --[[
    Orion Hub - Drawing Manager
    Gerencia objetos de desenho (círculo FOV, tracers, etc.) e garante limpeza.
]]

local DrawingManager = {}
local drawings = {}

-- Cria um círculo para o Silent Aim FOV (borda suave)
function DrawingManager:CreateFOVCircle(radius, color, thickness, transparency)
    local circle = _G.Orion.Drawing.new("Circle")
    circle.Radius = radius
    circle.Thickness = thickness
    circle.Color = color
    circle.Transparency = transparency
    circle.NumSides = 64 -- Suavidade
    circle.Visible = _G.Orion.Settings.silentAimEnabled
    circle.Position = Vector2.new(_G.Orion.UserInputService:GetMouseLocation().X, _G.Orion.UserInputService:GetMouseLocation().Y)
    
    table.insert(drawings, circle)
    return circle
end

-- Atualiza a posição do círculo (chamar a cada frame)
function DrawingManager:UpdateFOVCircle(circle)
    if circle and circle.Visible then
        local mouse = _G.Orion.UserInputService:GetMouseLocation()
        circle.Position = Vector2.new(mouse.X, mouse.Y)
    end
end

-- Cria um tracer (linha do centro da tela até o alvo)
function DrawingManager:CreateTracer(color, thickness)
    local line = _G.Orion.Drawing.new("Line")
    line.Color = color
    line.Thickness = thickness
    line.Transparency = 1
    line.Visible = _G.Orion.Settings.tracers
    table.insert(drawings, line)
    return line
end

-- Atualiza tracer: ponto origem (centro tela) e ponto destino (posição do alvo na tela)
function DrawingManager:UpdateTracer(line, targetScreenPos)
    if not line or not line.Visible then return end
    local screenCenter = Vector2.new(_G.Orion.CoreGui.AbsoluteSize.X / 2, _G.Orion.CoreGui.AbsoluteSize.Y / 2)
    line.From = screenCenter
    line.To = targetScreenPos
end

-- Remove todos os desenhos
function DrawingManager:ClearDrawings()
    for _, drawing in ipairs(drawings) do
        drawing:Remove()
    end
    drawings = {}
end

-- Remove um desenho específico
function DrawingManager:RemoveDrawing(drawing)
    if drawing then
        drawing:Remove()
        for i, d in ipairs(drawings) do
            if d == drawing then
                table.remove(drawings, i)
                break
            end
        end
    end
end

-- Alternar visibilidade de todos os desenhos de um tipo (ex: tracers)
function DrawingManager:ToggleTracers(visible)
    for _, drawing in ipairs(drawings) do
        if drawing:IsA("Line") then
            drawing.Visible = visible
        end
    end
end

return DrawingManager
