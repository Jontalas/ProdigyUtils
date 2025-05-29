-- Módulo para la pestaña "Personajes"
local CharactersTab = {}

-- Reutilizamos los colores de clase y facción

-- Colores de clase
local classColors = {
    ["Caballero de la Muerte"] = "|cffc41e3a",
    ["Cazador de Demonios"] = "|cffa330c9",
    ["Druida"] = "|cffff7c0a",
    ["Evocador"] = "|cff33937f",
    ["Cazador"] = "|cffaad372",
    ["Mago"] = "|cff3fc7eb",
    ["Monje"] = "|cff00ff98",
    ["Paladín"] = "|cfff48cba",
    ["Sacerdote"] = "|cffffffff",
    ["Pícaro"] = "|cfffff468",
    ["Chamán"] = "|cff0070dd",
    ["Brujo"] = "|cff8788ee",
    ["Guerrero"] = "|cffc69b6d"
}

local factionColors = {
    ["Alianza"] = "|cff0070dd",
    ["Horda"] = "|cffff2020",
}

-- Actualización de datos del personaje actual
local function UpdateCurrentCharacterIlvl()
    local name, realm = UnitName("player")
    realm = GetRealmName()
    local charKey = name .. "-" .. realm

    -- Obtener la facción en inglés y convertirla a español
    local factionEN = UnitFactionGroup("player") -- "Alliance" o "Horde"
    local faction = (factionEN == "Alliance" and "Alianza") or (factionEN == "Horde" and "Horda") or factionEN

    local classLoc = select(1, UnitClass("player"))
    local numSpecs = GetNumSpecializations()
    local specs = {}
    for i = 1, numSpecs do
        local specID, specName = GetSpecializationInfo(i)
        table.insert(specs, specName)
    end

    local specIndex = GetSpecialization()
    local ilvl = tonumber(string.format("%.1f", select(2, GetAverageItemLevel())))

    ProdigyUtils.db = ProdigyUtils.db or {}
    ProdigyUtils.db.characters = ProdigyUtils.db.characters or {}
    ProdigyUtils.db.characters[charKey] = ProdigyUtils.db.characters[charKey] or {
        faction = faction,
        class = classLoc,
        specs = specs,
        ilvls = {},
        lastSpecIndex = specIndex,
        lastUpdate = time(),
    }

    local charData = ProdigyUtils.db.characters[charKey]
    charData.faction = faction -- Aquí ya queda en español
    charData.class = classLoc
    charData.specs = specs
    charData.lastSpecIndex = specIndex
    charData.lastUpdate = time()
    charData.ilvls = charData.ilvls or {}
    charData.ilvls[specIndex] = ilvl
end

-- Registro de eventos SOLO los que has pedido
local function UpdateCurrentCharacterIlvlImmediateAndDelayed()
    UpdateCurrentCharacterIlvl()                 -- inmediato
    C_Timer.After(5, UpdateCurrentCharacterIlvl) -- 5 segundos después
end

local updaterFrame = CreateFrame("Frame")
updaterFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
updaterFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
updaterFrame:SetScript("OnEvent", function(self, event, ...)
    UpdateCurrentCharacterIlvlImmediateAndDelayed()
end)

-- Funciones auxiliares de UI
local function GetClassColor(className)
    return (classColors and classColors[className]) or "|cffffffff"
end

local function GetFactionColor(faction)
    return (factionColors and factionColors[faction]) or "|cffffffff"
end

local function GetSpecIlvl(charData, specIndex)
    if not charData or not charData.ilvls or not charData.specs then return "" end
    local ilvl = charData.ilvls[specIndex] or 0
    return ilvl > 0 and tostring(ilvl) or ""
end

local function GetSpecName(charData, specIndex)
    return (charData.specs and charData.specs[specIndex]) or ""
end

local function GetAllCharacters()
    local chars = {}
    if ProdigyUtils.db and ProdigyUtils.db.characters then
        for key, data in pairs(ProdigyUtils.db.characters) do
            local name = key:match("^([^-]+)")
            table.insert(chars, {
                name = name,
                faction = data.faction,
                class = data.class,
                specs = data.specs,
                ilvls = data.ilvls,
            })
        end
    end
    table.sort(chars, function(a, b) return a.name < b.name end)
    return chars
end

local function GetMaxIlvl(charData)
    if not charData or not charData.ilvls then return 0 end
    local max = 0
    for i = 1, 4 do
        local v = charData.ilvls[i] or 0
        if v > max then max = v end
    end
    return max
end

function CharactersTab.createTabContent()
    local frame = CreateFrame("Frame")
    frame:SetSize(900, 420) -- Más ancho por la nueva columna

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -20)
    title:SetText("Personajes de la cuenta")
    title:SetTextColor(1, 0.82, 0)

    local headers = { "Nombre", "Clase", "Max ilvl", "Especializaciones" }
    local COLUMN_X = { 20, 120, 230, 320 } -- ajusta el ancho según lo necesites

    for i, header in ipairs(headers) do
        local headerFS = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        headerFS:SetPoint("TOPLEFT", COLUMN_X[i], -60)
        headerFS:SetWidth((i == 3) and 550 or 100) -- Especializaciones más ancho
        headerFS:SetJustifyH("LEFT")
        headerFS:SetText(header)
    end

    local yOffset = -90
    local rowHeight = 18

    -- Obtener y ordenar personajes por ilvl máximo
    local chars = GetAllCharacters()
    for _, charData in ipairs(chars) do
        charData.maxIlvl = GetMaxIlvl(charData)
    end
    table.sort(chars, function(a, b) return (a.maxIlvl or 0) > (b.maxIlvl or 0) end)


    for _, charData in ipairs(chars) do
        -- Nombre
        local nameFS = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        nameFS:SetPoint("TOPLEFT", COLUMN_X[1], yOffset)
        nameFS:SetWidth(90)
        nameFS:SetJustifyH("LEFT")
        nameFS:SetText(GetFactionColor(charData.faction) .. charData.name .. "|r")

        -- Clase
        local classFS = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        classFS:SetPoint("TOPLEFT", COLUMN_X[2], yOffset)
        classFS:SetWidth(90)
        classFS:SetJustifyH("LEFT")
        classFS:SetText(GetClassColor(charData.class) .. charData.class .. "|r")

        -- Calculo de max ilvl y especializaciones
        local especStr = ""
        local maxIlvl = 0
        local maxIndex = 1
        for i = 1, 4 do
            local ilvl = tonumber(GetSpecIlvl(charData, i)) or 0
            if ilvl > maxIlvl then
                maxIlvl = ilvl
                maxIndex = i
            end
        end

        -- Max ilvl (en verde) - ahora columna 3
        local maxIlvlFS = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        maxIlvlFS:SetPoint("TOPLEFT", COLUMN_X[3], yOffset)
        maxIlvlFS:SetWidth(60)
        maxIlvlFS:SetJustifyH("LEFT")
        maxIlvlFS:SetText("|cff00ff00" .. (maxIlvl > 0 and string.format("%.1f", maxIlvl) or "") .. "|r")

        -- Especializaciones - ahora columna 4
        for i = 1, 4 do
            local specName = GetSpecName(charData, i)
            local ilvl = tonumber(GetSpecIlvl(charData, i)) or 0
            if ilvl > 0 and specName and specName ~= "" then
                local color = (i == maxIndex) and "|cff00ff00" or "|cffffffff"
                if especStr ~= "" then especStr = especStr .. ", " end
                especStr = especStr .. string.format("%s%s (%.1f)|r", color, specName, ilvl)
            end
        end

        local especFS = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        especFS:SetPoint("TOPLEFT", COLUMN_X[4], yOffset)
        especFS:SetWidth(500)
        especFS:SetJustifyH("LEFT")
        especFS:SetText(especStr)

        yOffset = yOffset - rowHeight
    end

    return frame
end

-- Guarda el frame actual de la pestaña para poder eliminarlo al refrescar
local lastFrame = nil

function CharactersTab.refreshTabContent(container)
    -- Elimina el frame anterior
    if lastFrame then
        lastFrame:Hide()
        lastFrame:SetParent(nil)
        lastFrame = nil
    end
    -- Crea el nuevo contenido y lo ancla al contenedor
    local frame = CharactersTab.createTabContent()
    frame:SetParent(container)
    frame:SetAllPoints(container)
    frame:Show()
    lastFrame = frame
end

ProdigyUtils:RegisterModule("charactersTab", {
    displayName = "Personajes",
    createTabContent = function()
        -- Devuelve un frame vacío que será llenado dinámicamente
        local container = CreateFrame("Frame")
        container:SetSize(820, 420)
        return container
    end,
    refreshTabContent = CharactersTab.refreshTabContent -- <<--- ESTA LÍNEA ES NUEVA
})
