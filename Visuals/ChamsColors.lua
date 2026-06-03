--[[
    Orion Hub - Chams Colors Config
    Apenas um repositório de cores, para fácil manutenção.
    Pode ser expandido para permitir customização pelo usuário.
]]

local ChamsColors = {
    Murderer = Color3.fromRGB(255, 0, 0),
    Sheriff = Color3.fromRGB(0, 0, 255),
    Innocent = Color3.fromRGB(0, 255, 0),
    -- Opção para outline ou fill
    OutlineTransparency = 0.3,
    FillTransparency = 0.6
}

function ChamsColors:GetRoleColor(role)
    return self[role] or self.Innocent
end

function ChamsColors:SetCustomColor(role, color)
    if self[role] then
        self[role] = color
    end
end

return ChamsColors
