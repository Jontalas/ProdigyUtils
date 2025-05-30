-- Módulo para la pestaña "Personajes"
local CharactersTab = {}

-- Reutilizamos los colores de clase y facción

-- Colores de clase
local classColors = {
    ["Caballero de la Muerte"] = "|cffc41e3a",
    ["Cazador de demonios"] = "|cffa330c9",
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
    frame:SetSize(900, 420) -- tamaño total de la pestaña principal

    -- Frame contenedor centrado
    local containerFrame = CreateFrame("Frame", nil, frame)
    containerFrame:SetSize(800, 380)
    containerFrame:SetPoint("TOPLEFT", 30, -30)
    containerFrame:SetPoint("BOTTOMRIGHT", -30, 30)

    -- ScrollFrame para la tabla
    local scrollFrame = CreateFrame("ScrollFrame", nil, containerFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 0, -60)
    scrollFrame:SetPoint("BOTTOMRIGHT", 0, 0)

    -- Contenido del scroll (child)
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(850, 1) -- el height se actualizará según el contenido
    scrollFrame:SetScrollChild(scrollChild)

    -- Título alineado al contenedor
    local title = containerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -20)
    title:SetText("Personajes de la cuenta")
    title:SetTextColor(1, 0.82, 0)

    local headers = { "Nombre", "Clase", "Max ilvl", "Especializaciones" }
    local COLUMN_X = { 30, 130, 280, 370 }

    for i, header in ipairs(headers) do
        local headerFS = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        headerFS:SetPoint("TOPLEFT", COLUMN_X[i], -5)
        headerFS:SetWidth((i == 4) and 500 or 100)
        headerFS:SetJustifyH("LEFT")
        headerFS:SetText(header)
    end

    local yOffset = -30
    local rowHeight = 18

    local chars = GetAllCharacters()
    for _, charData in ipairs(chars) do
        charData.maxIlvl = GetMaxIlvl(charData)
    end
    table.sort(chars, function(a, b) return (a.maxIlvl or 0) > (b.maxIlvl or 0) end)

    for _, charData in ipairs(chars) do
        local nameFS = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        nameFS:SetPoint("TOPLEFT", COLUMN_X[1], yOffset)
        nameFS:SetWidth(90)
        nameFS:SetJustifyH("LEFT")
        nameFS:SetText(GetFactionColor(charData.faction) .. charData.name .. "|r")

        local classFS = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        classFS:SetPoint("TOPLEFT", COLUMN_X[2], yOffset)
        classFS:SetWidth(150)
        classFS:SetJustifyH("LEFT")
        classFS:SetText(GetClassColor(charData.class) .. charData.class .. "|r")

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

        local maxIlvlFS = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        maxIlvlFS:SetPoint("TOPLEFT", COLUMN_X[3], yOffset)
        maxIlvlFS:SetWidth(60)
        maxIlvlFS:SetJustifyH("LEFT")
        maxIlvlFS:SetText("|cff00ff00" .. (maxIlvl > 0 and string.format("%.1f", maxIlvl) or "") .. "|r")

        for i = 1, 4 do
            local specName = GetSpecName(charData, i)
            local ilvl = tonumber(GetSpecIlvl(charData, i)) or 0
            if ilvl > 0 and specName and specName ~= "" then
                local color = (i == maxIndex) and "|cff00ff00" or "|cffffffff"
                if especStr ~= "" then especStr = especStr .. ", " end
                especStr = especStr .. string.format("%s%s (%.1f)|r", color, specName, ilvl)
            end
        end

        local especFS = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        especFS:SetPoint("TOPLEFT", COLUMN_X[4], yOffset)
        especFS:SetWidth(500)
        especFS:SetJustifyH("LEFT")
        especFS:SetText(especStr)

        yOffset = yOffset - rowHeight
    end

    -- Ajustar el alto del scrollChild según filas
    scrollChild:SetHeight(-yOffset + 10)

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
