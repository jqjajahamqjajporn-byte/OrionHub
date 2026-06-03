--[[
    Orion Hub - Performance Mode
    Reduz a taxa de atualização de ESP e outros elementos gráficos para aumentar FPS.
]]

local PerformanceMode = {}
local RunService = game:GetService("RunService")

local enabled = false
local originalRenderStep = nil
local throttleFrames = 0

-- Será chamado pelo módulo ESP para ajustar a frequência de atualização
local function setLowQualityMode()
    if _G.Orion.Modules and _G.Orion.Modules.ESP then
        -- Exemplo: diminuir a atualização do ESP para 15 FPS (a cada 4 frames)
        -- Isso seria implementado dentro do ESP, mas aqui apenas sinalizamos.
        _G.Orion.PerformanceModeActive = enabled
    end
end

-- Alterna o modo de performance
function PerformanceMode:SetEnabled(state)
    enabled = state
    setLowQualityMode()
    if enabled then
        -- Reduzir qualidade de desenhos (menos lados no círculo, etc.)
        if _G.Orion.Modules and _G.Orion.Modules.SilentAim and _G.Orion.Modules.SilentAim.fovCircle then
            _G.Orion.Modules.SilentAim.fovCircle.NumSides = 32 -- reduz suavidade
        end
        -- Desativar alguns efeitos visuais não essenciais
        if _G.Orion.Settings then
            _G.Orion.Settings.tracers = false
            if _G.Orion.Modules and _G.Orion.Modules.ESP then
                _G.Orion.Modules.ESP:ToggleTracers(false)
            end
        end
    else
        if _G.Orion.Modules and _G.Orion.Modules.SilentAim and _G.Orion.Modules.SilentAim.fovCircle then
            _G.Orion.Modules.SilentAim.fovCircle.NumSides = 64
        end
        -- Restaurar configurações do usuário (se salvas)
        -- (implementar conforme necessário)
    end
end

function PerformanceMode:IsEnabled()
    return enabled
end

return PerformanceMode
