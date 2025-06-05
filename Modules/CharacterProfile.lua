-- Módulo Perfil del Personaje
local CharacterProfile = {}

-- Helpers para DB global
local function GetProfileDB()
    ProdigyUtilsDB = ProdigyUtilsDB or {}
    ProdigyUtilsDB.consumibles = ProdigyUtilsDB.consumibles or {}
    ProdigyUtilsDB.bandas = ProdigyUtilsDB.bandas or {}
    ProdigyUtilsDB.profundidades = ProdigyUtilsDB.profundidades or {}
    -- Eliminamos el array de mazmorras clásico, solo usamos el de umbrales
    ProdigyUtilsDB.mazmorras_umbral = ProdigyUtilsDB.mazmorras_umbral or {}
    return ProdigyUtilsDB
end

-- === CLAVE PARA CONSUMIBLES ===
local function GetConsKey()
    local _, classKey = UnitClass("player")
    local specIndex = GetSpecialization and GetSpecialization() or 1
    local specName = select(2, GetSpecializationInfo(specIndex)) or "UNKNOWN"
    return string.upper(classKey .. "-" .. specName)
end

-- === DATOS DEL PERSONAJE ACTUAL ===
local function GetCharacterData()
    local playerName = UnitName("player") or "Desconocido"
    local playerLevel = UnitLevel("player") or 1
    local playerClass, englishClass = UnitClass("player")
    playerClass = playerClass or "Desconocida"
    local playerRace = UnitRace("player") or "Desconocida"
    local specIndex = GetSpecialization and GetSpecialization()
    local specName = "Sin especialización"
    local specIcon = 134400
    if specIndex ~= nil and specIndex > 0 then
        local id, name, _, icon = GetSpecializationInfo(specIndex)
        if name then
            specName = name
            specIcon = icon
        end
    end
    local ilvl = 0
    if GetAverageItemLevel then
        ilvl = tonumber(string.format("%.1f", select(2, GetAverageItemLevel())))
    end
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
        classColor = classColor,
        classKey = englishClass,
        specIndex = specIndex,
        specId = (specIndex ~= nil and specIndex > 0 and select(1, GetSpecializationInfo(specIndex))) or 0
    }
end

---------------------------
-- CONSUMIBLES
---------------------------
local CONSUMIBLES_KEYS = { "Runa", "Poción", "Comida", "Frasco", "Temporal" }

local function GetConsumiblesForCurrent()
    local db = GetProfileDB()
    local key = GetConsKey()
    db.consumibles[key] = db.consumibles[key] or {}
    local tbl = db.consumibles[key]
    for _, k in ipairs(CONSUMIBLES_KEYS) do
        if not tbl[k] then tbl[k] = "" end
    end
    return tbl
end

local function SetConsumible(key, value)
    local db = GetProfileDB()
    local consKey = GetConsKey()
    db.consumibles[consKey][key] = value
end

---------------------------
-- BANDAS / PROFUNDIDADES
---------------------------
local function GetPares(tablename)
    local db = GetProfileDB()
    db[tablename] = db[tablename] or {}
    table.sort(db[tablename], function(a, b) return (a.ilvl or 0) < (b.ilvl or 0) end)
    return db[tablename]
end

local function GetTextoPorIlvl(tablename, ilvl)
    local lista = GetPares(tablename)
    local bestTexto, bestIlvl
    for _, t in ipairs(lista) do
        if ilvl >= t.ilvl and (not bestIlvl or t.ilvl > bestIlvl) then
            bestTexto = t.texto
            bestIlvl = t.ilvl
        end
    end
    return bestTexto or "-"
end

local function EditarParesFrame(tablename, displayTitle, parentFrame)
    local db = GetProfileDB()
    local lista = db[tablename]
    local f = CreateFrame("Frame", "Editar" .. tablename .. "Frame", parentFrame or UIParent,
        "BasicFrameTemplateWithInset")
    f:SetSize(400, 420)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.title:SetPoint("TOP", 0, -10)
    f.title:SetText("Editar " .. displayTitle)

    local headerY = -50
    local ilvlHeader = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    ilvlHeader:SetPoint("TOPLEFT", 16, headerY)
    ilvlHeader:SetText("|cffFFD700Ilvl|r")
    local textoHeader = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    textoHeader:SetPoint("TOPLEFT", 70, headerY)
    textoHeader:SetText("|cffFFD700Texto Recomendación|r")

    local y = headerY - 25
    for i, par in ipairs(lista) do
        local ilvlBox = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
        ilvlBox:SetSize(40, 20)
        ilvlBox:SetPoint("TOPLEFT", 16, y)
        ilvlBox:SetNumber(par.ilvl)
        local textoBox = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
        textoBox:SetSize(220, 20)
        textoBox:SetPoint("LEFT", ilvlBox, "RIGHT", 8, 0)
        textoBox:SetText(par.texto)
        ilvlBox:SetScript("OnEnterPressed", function(self)
            local num = tonumber(self:GetText()) or 0
            for j, p in ipairs(lista) do
                if j ~= i and p.ilvl == num then
                    self:SetNumber(par.ilvl); return;
                end
            end
            par.ilvl = num
        end)
        textoBox:SetScript("OnEnterPressed", function(self) par.texto = self:GetText() end)
        local delBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        delBtn:SetSize(24, 20)
        delBtn:SetText("X")
        delBtn:SetPoint("LEFT", textoBox, "RIGHT", 6, 0)
        delBtn:SetScript("OnClick", function()
            table.remove(lista, i)
            f:Hide()
            EditarParesFrame(tablename, displayTitle, parentFrame)
        end)
        y = y - 28
    end

    local addSeparator = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    addSeparator:SetPoint("TOPLEFT", 16, y - 10)
    addSeparator:SetText("|cffFFD700Añadir nuevo elemento:|r")
    y = y - 30

    local addIlvl = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
    addIlvl:SetSize(40, 20)
    addIlvl:SetPoint("TOPLEFT", 16, y)
    addIlvl:SetNumber(0)
    local addTexto = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
    addTexto:SetSize(220, 20)
    addTexto:SetPoint("LEFT", addIlvl, "RIGHT", 8, 0)
    addTexto:SetText("")
    local addBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    addBtn:SetSize(60, 20)
    addBtn:SetText("Añadir")
    addBtn:SetPoint("LEFT", addTexto, "RIGHT", 8, 0)
    addBtn:SetScript("OnClick", function()
        local num = tonumber(addIlvl:GetText()) or 0
        for _, p in ipairs(lista) do if p.ilvl == num then return end end
        table.insert(lista, { ilvl = num, texto = addTexto:GetText() })
        f:Hide()
        EditarParesFrame(tablename, displayTitle, parentFrame)
    end)
    local closeBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    closeBtn:SetSize(80, 22)
    closeBtn:SetText("Cerrar")
    closeBtn:SetPoint("BOTTOM", 0, 12)
    closeBtn:SetScript("OnClick", function()
        f:Hide()
        if parentFrame and CharacterProfile.refreshTabContent then
            CharacterProfile.refreshTabContent(parentFrame)
        end
    end)
    local saveBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    saveBtn:SetSize(80, 22)
    saveBtn:SetText("Guardar")
    saveBtn:SetPoint("BOTTOMRIGHT", -10, 12)
    saveBtn:SetScript("OnClick", function()
        f:Hide()
        if parentFrame and CharacterProfile.refreshTabContent then
            CharacterProfile.refreshTabContent(parentFrame)
        end
    end)
    f:Show()
end

---------------------------
-- MAZMORRAS (CATEGORÍAS FIJAS, UMBRAL GLOBAL)
---------------------------
local MAZMORRAS_CATEGORIAS = {
    { nombre = "Miticas", clave = "miticas" },
    { nombre = "M+ 6",    clave = "mplus6" },
    { nombre = "M+ 7",    clave = "mplus7" },
    { nombre = "M+ 10",   clave = "mplus10" },
}
local MAZMORRAS_DB_KEY = "mazmorras_umbral"

local function GetMazmorrasUmbrales()
    local db = GetProfileDB()
    db[MAZMORRAS_DB_KEY] = db[MAZMORRAS_DB_KEY] or {
        miticas = 441,
        mplus6 = 454,
        mplus7 = 463,
        mplus10 = 470,
    }
    return db[MAZMORRAS_DB_KEY]
end

local function SetMazmorraUmbral(clave, valor)
    local db = GetProfileDB()
    db[MAZMORRAS_DB_KEY] = db[MAZMORRAS_DB_KEY] or {}
    db[MAZMORRAS_DB_KEY][clave] = valor
end

local function GetFifthLowestEquippedIlvl()
    local ilvls = {}
    for slot = 1, 17 do
        local itemLink = GetInventoryItemLink("player", slot)
        if itemLink then
            local ilvl = C_Item.GetDetailedItemLevelInfo(itemLink)
            if ilvl then
                table.insert(ilvls, ilvl)
            end
        end
    end
    table.sort(ilvls)
    if #ilvls >= 5 then
        return ilvls[5]
    elseif #ilvls > 0 then
        return ilvls[#ilvls]
    else
        return 0
    end
end

local function GetCategoriaMazmorraParaIlvl(ilvl)
    local umbrales = GetMazmorrasUmbrales()
    local mejorCategoria = nil
    local mejorValor = -1
    for _, cat in ipairs(MAZMORRAS_CATEGORIAS) do
        local val = tonumber(umbrales[cat.clave] or 0)
        if ilvl >= val and val > mejorValor then
            mejorCategoria = cat.nombre
            mejorValor = val
        end
    end
    return mejorCategoria or "Heroicas"
end

local function EditarMazmorrasFrame(parentFrame)
    local umbrales = GetMazmorrasUmbrales()
    local f = CreateFrame("Frame", "EditarMazmorrasFrame", parentFrame or UIParent, "BasicFrameTemplateWithInset")
    f:SetSize(400, 300)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.title:SetPoint("TOP", 0, -10)
    f.title:SetText("Configurar Mazmorras")

    -- Cabeceras
    local headerY = -50
    local nombreHeader = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    nombreHeader:SetPoint("TOPLEFT", 16, headerY)
    nombreHeader:SetText("|cffFFD700Categoría|r")
    local umbralHeader = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    umbralHeader:SetPoint("TOPLEFT", 180, headerY)
    umbralHeader:SetText("|cffFFD700Ilvl mínimo|r")

    -- Edit boxes por categoría
    local y = headerY - 25
    local edits = {}
    for _, cat in ipairs(MAZMORRAS_CATEGORIAS) do
        local label = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("TOPLEFT", 16, y)
        label:SetText(cat.nombre .. ":")
        local edit = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
        edit:SetSize(80, 20)
        edit:SetPoint("LEFT", label, "LEFT", 170, 0)
        edit:SetNumber(tonumber(umbrales[cat.clave]) or 0)
        edits[cat.clave] = edit
        y = y - 34
    end

    local saveBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    saveBtn:SetSize(90, 22)
    saveBtn:SetText("Guardar")
    saveBtn:SetPoint("BOTTOMRIGHT", -16, 12)
    saveBtn:SetScript("OnClick", function()
        for _, cat in ipairs(MAZMORRAS_CATEGORIAS) do
            local val = tonumber(edits[cat.clave]:GetText()) or 0
            SetMazmorraUmbral(cat.clave, val)
        end
        f:Hide()
        if parentFrame and CharacterProfile.refreshTabContent then
            CharacterProfile.refreshTabContent(parentFrame)
        end
    end)

    local closeBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    closeBtn:SetSize(90, 22)
    closeBtn:SetText("Cerrar")
    closeBtn:SetPoint("BOTTOMLEFT", 16, 12)
    closeBtn:SetScript("OnClick", function()
        f:Hide()
        if parentFrame and CharacterProfile.refreshTabContent then
            CharacterProfile.refreshTabContent(parentFrame)
        end
    end)

    f:Show()
end

---------------------------
-- EDICIÓN DE CONSUMIBLES
---------------------------
local EditBoxEnFoco = nil
hooksecurefunc("ChatEdit_InsertLink", function(link)
    if EditBoxEnFoco and EditBoxEnFoco:HasFocus() then
        EditBoxEnFoco:Insert(link)
        return true
    end
end)

local function EditarConsumiblesFrame(parentFrame)
    local tbl = GetConsumiblesForCurrent()
    local f = CreateFrame("Frame", "EditarConsFrame", parentFrame or UIParent, "BasicFrameTemplateWithInset")
    f:SetSize(400, 340)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.title:SetPoint("TOP", 0, -10)
    f.title:SetText("Editar consumibles")
    local y = -40
    local boxes = {}
    for _, key in ipairs(CONSUMIBLES_KEYS) do
        local label = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("TOPLEFT", 16, y)
        label:SetText(key .. ":")
        local edit = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
        edit:SetSize(270, 20)
        edit:SetPoint("LEFT", label, "RIGHT", 10, 0)
        edit:SetText(tbl[key])
        edit:SetAutoFocus(false)
        edit:SetScript("OnEditFocusGained", function(self) EditBoxEnFoco = self end)
        edit:SetScript("OnEditFocusLost", function(self) if EditBoxEnFoco == self then EditBoxEnFoco = nil end end)
        boxes[key] = edit
        y = y - 34
    end
    local saveBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    saveBtn:SetSize(90, 22)
    saveBtn:SetText("Guardar")
    saveBtn:SetPoint("BOTTOMRIGHT", -16, 12)
    saveBtn:SetScript("OnClick", function()
        for _, key in ipairs(CONSUMIBLES_KEYS) do
            SetConsumible(key, boxes[key]:GetText())
        end
        f:Hide()
        if parentFrame and CharacterProfile.refreshTabContent then
            CharacterProfile.refreshTabContent(parentFrame)
        end
    end)
    local closeBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    closeBtn:SetSize(90, 22)
    closeBtn:SetText("Cerrar")
    closeBtn:SetPoint("BOTTOMLEFT", 16, 12)
    closeBtn:SetScript("OnClick", function()
        f:Hide()
        if parentFrame and CharacterProfile.refreshTabContent then
            CharacterProfile.refreshTabContent(parentFrame)
        end
    end)
    f:Show()
end

---------------------------
-- VISUALIZACIÓN PESTAÑA
---------------------------
function CharacterProfile.createTabContent()
    local frame = CreateFrame("Frame")
    frame:SetSize(560, 500)
    local charData = GetCharacterData()
    local mainContainer = CreateFrame("Frame", nil, frame)
    mainContainer:SetSize(560, 500)
    mainContainer:SetPoint("CENTER", frame, "CENTER", 0, 0)
    local title = mainContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -40)
    title:SetText("Perfil del Personaje")
    title:SetTextColor(1, 0.82, 0)
    local infoFrame = CreateFrame("Frame", nil, mainContainer, "InsetFrameTemplate")
    infoFrame:SetPoint("TOP", title, "BOTTOM", 0, -20)
    infoFrame:SetSize(520, 380)
    local portrait = infoFrame:CreateTexture(nil, "BACKGROUND")
    portrait:SetSize(64, 64)
    portrait:SetPoint("TOPRIGHT", infoFrame, "TOPRIGHT", -12, -12)
    SetPortraitTexture(portrait, "player")
    local infoContainer = CreateFrame("Frame", nil, infoFrame)
    infoContainer:SetSize(480, 380)
    infoContainer:SetPoint("TOPLEFT", infoFrame, "TOPLEFT", 10, -10)
    local y = -10
    local nameText = infoContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    nameText:SetPoint("TOPLEFT", 10, y)
    nameText:SetText(charData.classColor .. charData.name .. "|r")
    y = y - 28
    local levelText = infoContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    levelText:SetPoint("TOPLEFT", 10, y)
    levelText:SetText("Nivel " .. charData.level ..
        " " .. charData.race .. " - " .. charData.class .. " (" .. charData.specName .. ")")
    y = y - 28
    local ilvlText = infoContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    ilvlText:SetPoint("TOPLEFT", 10, y)
    ilvlText:SetText("Ilvl: |cffffff00" .. charData.itemLevel .. "|r")
    y = y - 20

    -- === SECCIÓN CONSUMIBLES ===
    local consTitle = infoContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    consTitle:SetPoint("TOPLEFT", 10, y)
    consTitle:SetText("|cffffcc00Consumibles recomendados|r")
    local editConsBtn = CreateFrame("Button", nil, infoContainer, "UIPanelButtonTemplate")
    editConsBtn:SetSize(130, 20)
    editConsBtn:SetText("Editar consumibles")
    editConsBtn:SetPoint("TOPLEFT", 200, y + 4)
    editConsBtn:SetScript("OnClick", function() EditarConsumiblesFrame(frame) end)
    y = y - 22
    local consumibles = GetConsumiblesForCurrent()
    for _, key in ipairs(CONSUMIBLES_KEYS) do
        local label = infoContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        label:SetPoint("TOPLEFT", 24, y)
        label:SetText(key .. ":")
        local msgFrame = CreateFrame("ScrollingMessageFrame", nil, infoContainer)
        msgFrame:SetSize(360, 18)
        msgFrame:SetPoint("LEFT", label, "RIGHT", 8, 0)
        msgFrame:SetFontObject(GameFontHighlightSmall)
        msgFrame:SetJustifyH("LEFT")
        msgFrame:SetFading(false)
        msgFrame:SetMaxLines(1)
        msgFrame:SetHyperlinksEnabled(true)
        msgFrame:Clear()
        msgFrame:AddMessage(consumibles[key] or "")
        msgFrame:SetScript("OnHyperlinkEnter", function(self, linkData, link, button)
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
            GameTooltip:SetHyperlink(link)
            GameTooltip:Show()
        end)
        msgFrame:SetScript("OnHyperlinkLeave", function() GameTooltip:Hide() end)
        msgFrame:SetScript("OnHyperlinkClick", function(self, linkData, link, button)
            if IsShiftKeyDown() then
                ChatEdit_InsertLink(link)
            end
        end)
        y = y - 20
    end
    y = y - 14

    -- === SECCIÓN CONTENIDO RECOMENDADO ===
    local contTitle = infoContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    contTitle:SetPoint("TOPLEFT", 10, y)
    contTitle:SetText("|cffffcc00Contenido recomendado|r")
    y = y - 22

    -- MAZMORRAS
    local minIlvl = GetFifthLowestEquippedIlvl()
    local mazLabel = infoContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    mazLabel:SetPoint("TOPLEFT", 24, y)
    mazLabel:SetText("Mazmorras:")
    local mazValue = infoContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    mazValue:SetPoint("LEFT", mazLabel, "RIGHT", 8, 0)
    mazValue:SetText(GetCategoriaMazmorraParaIlvl(minIlvl))
    mazValue:SetJustifyH("LEFT")
    mazValue:SetWidth(320)
    mazValue:SetWordWrap(true)
    local btnMaz = CreateFrame("Button", nil, infoContainer, "UIPanelButtonTemplate")
    btnMaz:SetSize(80, 18)
    btnMaz:SetText("Editar")
    btnMaz:SetPoint("LEFT", mazLabel, "LEFT", 390, 0)
    btnMaz:SetScript("OnClick", function() EditarMazmorrasFrame(frame) end)
    y = y - 22

    -- PROFUNDIDADES
    local profLabel = infoContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    profLabel:SetPoint("TOPLEFT", 24, y)
    profLabel:SetText("Profundidades:")
    local profValue = infoContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    profValue:SetPoint("LEFT", profLabel, "RIGHT", 8, 0)
    profValue:SetText(GetTextoPorIlvl("profundidades", charData.itemLevel))
    profValue:SetJustifyH("LEFT")
    profValue:SetWidth(320)
    profValue:SetWordWrap(true)
    local btnProf = CreateFrame("Button", nil, infoContainer, "UIPanelButtonTemplate")
    btnProf:SetSize(80, 18)
    btnProf:SetText("Editar")
    btnProf:SetPoint("LEFT", profLabel, "LEFT", 390, 0)
    btnProf:SetScript("OnClick", function() EditarParesFrame("profundidades", "Profundidades", frame) end)
    y = y - 22

    -- BANDAS
    local bandLabel = infoContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    bandLabel:SetPoint("TOPLEFT", 24, y)
    bandLabel:SetText("Bandas:")
    local bandValue = infoContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    bandValue:SetPoint("LEFT", bandLabel, "RIGHT", 8, 0)
    bandValue:SetText(GetTextoPorIlvl("bandas", charData.itemLevel))
    bandValue:SetJustifyH("LEFT")
    bandValue:SetWidth(320)
    bandValue:SetWordWrap(true)
    local btnBand = CreateFrame("Button", nil, infoContainer, "UIPanelButtonTemplate")
    btnBand:SetSize(80, 18)
    btnBand:SetText("Editar")
    btnBand:SetPoint("LEFT", bandLabel, "LEFT", 390, 0)
    btnBand:SetScript("OnClick", function() EditarParesFrame("bandas", "Bandas", frame) end)

    local refreshButton = CreateFrame("Button", nil, infoFrame, "UIPanelButtonTemplate")
    refreshButton:SetSize(120, 25)
    refreshButton:SetPoint("BOTTOMRIGHT", infoFrame, "BOTTOMRIGHT", -10, 10)
    refreshButton:SetText("Actualizar")
    refreshButton:SetScript("OnClick", function()
        CharacterProfile.refreshTabContent(frame:GetParent())
    end)
    return frame
end

function CharacterProfile.refreshTabContent(container)
    for _, child in pairs({ container:GetChildren() }) do
        if child ~= container then
            child:Hide()
            child:SetParent(nil)
        end
    end
    local newFrame = CharacterProfile.createTabContent()
    newFrame:SetParent(container)
    newFrame:SetAllPoints(container)
    newFrame:Show()
end

ProdigyUtils:RegisterModule("characterProfile", {
    displayName = function() return UnitName("player") or "Personaje" end,
    createTabContent = CharacterProfile.createTabContent,
    refreshTabContent = CharacterProfile.refreshTabContent
})

return CharacterProfile
