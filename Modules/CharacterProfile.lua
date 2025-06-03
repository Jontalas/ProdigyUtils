-- Módulo Perfil del Personaje
local CharacterProfile = {}

-- Función para obtener información del personaje
local function GetCharacterData()
    local playerName = UnitName("player") or "Desconocido"
    local playerLevel = UnitLevel("player") or 1
    local playerClass, englishClass = UnitClass("player")
    playerClass = playerClass or "Desconocida"
    local playerRace = UnitRace("player") or "Desconocida"
    
    -- Especialización actual
    local specName = "Sin especialización"
    local specIcon = 134400 -- Icono por defecto
    local specIndex = GetSpecialization and GetSpecialization()
    if specIndex and specIndex > 0 then
        local id, name, description, icon = GetSpecializationInfo(specIndex)
        if name then
            specName = name
            specIcon = icon
        end
    end
    
    -- Item Level promedio (equipado, un decimal)
    local ilvl = 0
    if GetAverageItemLevel then
        ilvl = tonumber(string.format("%.1f", select(2, GetAverageItemLevel())))
    end
    
    -- Colores de clase
    local classColors = {
        ["DEATHKNIGHT"] = "|cffc41e3a",
        ["DEMONHUNTER"] = "|cffa330c9", 
        ["DRUID"] = "|cffff7c0a",
        ["EVOKER"] = "|cff33937f",
        ["HUNTER"] = "|cffaad372",
        ["MAGE"] = "|cff3fc7eb",
        ["MONK"] = "|cff00ff98",
        ["PALADIN"] = "|cfff48cba",
        ["PRIEST"] = "|cffffffff",
        ["ROGUE"] = "|cfffff468",
        ["SHAMAN"] = "|cff0070dd",
        ["WARLOCK"] = "|cff8788ee",
        ["WARRIOR"] = "|cffc69b6d"
    }
    
    local classColor = classColors[englishClass] or "|cffffffff"
    
    return {
        name = playerName,
        level = playerLevel,
        class = playerClass,
        race = playerRace,
        specName = specName,
        specIcon = specIcon,
        itemLevel = ilvl,
        classColor = classColor
    }
end

-- Función para crear el contenido de la pestaña
function CharacterProfile.createTabContent()
    local frame = CreateFrame("Frame")
    frame:SetSize(560, 400)
    
    -- Obtener datos del personaje
    local charData = GetCharacterData()
    
    -- CONTENEDOR PRINCIPAL
    local mainContainer = CreateFrame("Frame", nil, frame)
    mainContainer:SetSize(560, 400)
    mainContainer:SetPoint("CENTER", frame, "CENTER", 0, 0)
    
    -- Título principal
    local title = mainContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -20)
    title:SetText("Perfil del Personaje")
    title:SetTextColor(1, 0.82, 0)
    
    -- FRAME PRINCIPAL DE INFORMACIÓN
    local infoFrame = CreateFrame("Frame", nil, mainContainer, "InsetFrameTemplate")
    infoFrame:SetPoint("TOP", title, "BOTTOM", 0, -20)
    infoFrame:SetSize(520, 320)

    -- Retrato 2D del personaje en la esquina superior derecha
    local portrait = infoFrame:CreateTexture(nil, "BACKGROUND")
    portrait:SetSize(64, 64)
    portrait:SetPoint("TOPRIGHT", infoFrame, "TOPRIGHT", -12, -12)
    SetPortraitTexture(portrait, "player")
    
    -- CONTENEDOR DE INFORMACIÓN CENTRADO
    local infoContainer = CreateFrame("Frame", nil, infoFrame)
    infoContainer:SetSize(480, 280)
    infoContainer:SetPoint("CENTER", infoFrame, "CENTER", 0, 0)
    
    -- === SECCIÓN SUPERIOR: NOMBRE Y NIVEL ===
    local nameText = infoContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    nameText:SetPoint("TOP", infoContainer, "TOP", 0, -20)
    nameText:SetText(charData.classColor .. charData.name .. "|r")
    
    local levelText = infoContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    levelText:SetPoint("TOP", nameText, "BOTTOM", 0, -10)
    levelText:SetText("Nivel " .. charData.level)
    levelText:SetTextColor(1, 1, 1)
    
    -- === SECCIÓN CENTRAL: INFORMACIÓN BÁSICA ===
    local yOffset = -80
    
    -- Clase
    local classLabel = infoContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    classLabel:SetPoint("TOPLEFT", infoContainer, "TOPLEFT", 40, yOffset)
    classLabel:SetText("|cffffcc00Clase:|r")
    
    local classValue = infoContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    classValue:SetPoint("LEFT", classLabel, "RIGHT", 10, 0)
    classValue:SetText(charData.classColor .. charData.class .. "|r")
    
    yOffset = yOffset - 25
    
    -- Raza
    local raceLabel = infoContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    raceLabel:SetPoint("TOPLEFT", infoContainer, "TOPLEFT", 40, yOffset)
    raceLabel:SetText("|cffffcc00Raza:|r")
    
    local raceValue = infoContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    raceValue:SetPoint("LEFT", raceLabel, "RIGHT", 10, 0)
    raceValue:SetText(charData.race)
    
    yOffset = yOffset - 35
    
    -- === ESPECIALIZACIÓN CON ICONO ===
    local specLabel = infoContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    specLabel:SetPoint("TOPLEFT", infoContainer, "TOPLEFT", 40, yOffset)
    specLabel:SetText("|cffffcc00Especialización:|r")
    
    -- Icono de especialización
    local specIcon = infoContainer:CreateTexture(nil, "ARTWORK")
    specIcon:SetSize(24, 24)
    specIcon:SetPoint("LEFT", specLabel, "RIGHT", 10, 0)
    specIcon:SetTexture(charData.specIcon)
    
    -- Nombre de especialización
    local specValue = infoContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    specValue:SetPoint("LEFT", specIcon, "RIGHT", 8, 0)
    specValue:SetText(charData.specName)
    
    yOffset = yOffset - 35
    
    -- === ITEM LEVEL ===
    local ilvlLabel = infoContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    ilvlLabel:SetPoint("TOPLEFT", infoContainer, "TOPLEFT", 40, yOffset)
    ilvlLabel:SetText("|cffffcc00Item Level:|r")
    
    local ilvlValue = infoContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    ilvlValue:SetPoint("LEFT", ilvlLabel, "RIGHT", 10, 0)
    
    -- Color del item level según valor
    local ilvlColor = "|cffa335ee"
    
    ilvlValue:SetText(ilvlColor .. charData.itemLevel .. "|r")
    
    -- === SECCIÓN INFERIOR: ESPACIO PARA FUTURAS EXPANSIONES ===
    yOffset = yOffset - 50
    
    local futureLabel = infoContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    futureLabel:SetPoint("TOP", infoContainer, "BOTTOM", 0, yOffset)
    futureLabel:SetText("|cff888888--- Más información será añadida aquí ------|r")
    
    -- === BOTÓN DE ACTUALIZAR (OPCIONAL) ===
    local refreshButton = CreateFrame("Button", nil, infoFrame, "UIPanelButtonTemplate")
    refreshButton:SetSize(120, 25)
    refreshButton:SetPoint("BOTTOMRIGHT", infoFrame, "BOTTOMRIGHT", -10, 10)
    refreshButton:SetText("Actualizar")
    refreshButton:SetScript("OnClick", function()
        -- Recrear el contenido para refrescar datos
        CharacterProfile.refreshTabContent(frame:GetParent())
    end)
    
    return frame
end

-- Función para refrescar el contenido de la pestaña
function CharacterProfile.refreshTabContent(container)
    -- Limpiar contenido anterior
    for _, child in pairs({container:GetChildren()}) do
        if child ~= container then
            child:Hide()
            child:SetParent(nil)
        end
    end
    
    -- Crear nuevo contenido actualizado
    local newFrame = CharacterProfile.createTabContent()
    newFrame:SetParent(container)
    newFrame:SetAllPoints(container)
    newFrame:Show()
end

-- Registrar el módulo
ProdigyUtils:RegisterModule("characterProfile", {
    displayName = function() 
        return UnitName("player") or "Personaje"
    end,
    createTabContent = CharacterProfile.createTabContent,
    refreshTabContent = CharacterProfile.refreshTabContent
})

return CharacterProfile