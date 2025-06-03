local Rotations = {}

local function GetPlayerKey()
    return UnitName("player") .. "-" .. GetRealmName()
end

local function SafeGetCurrentSpecID()
    if not GetSpecialization then return nil end
    local specIndex = GetSpecialization()
    if not specIndex or specIndex == 0 then return nil end
    if not GetSpecializationInfo then return nil end
    local specID = GetSpecializationInfo(specIndex)
    return specID
end

local function EnsureDB()
    if not ProdigyUtilsDB then ProdigyUtilsDB = {} end
    if not ProdigyUtilsDB.rotations then ProdigyUtilsDB.rotations = {} end
end

function Rotations.UpdateLoadouts()
    EnsureDB()
    local db = ProdigyUtilsDB.rotations
    local playerKey = GetPlayerKey()
    db[playerKey] = db[playerKey] or {}
    local specID = SafeGetCurrentSpecID()
    if not specID then return end

    db[playerKey][specID] = db[playerKey][specID] or {}

    local configIDs = (C_ClassTalents and C_ClassTalents.GetConfigIDsBySpecID and C_ClassTalents.GetConfigIDsBySpecID(specID)) or
        nil
    if not configIDs then return end

    local currentLoadouts = {}
    for _, value in pairs(configIDs) do
        currentLoadouts[value] = true
        if not db[playerKey][specID][value] then
            local info = (C_Traits and C_Traits.GetConfigInfo and C_Traits.GetConfigInfo(value)) or nil
            db[playerKey][specID][value] = {
                name = (info and info.name) or ("Loadout " .. tostring(value)),
                abilities = {}
            }
        end
    end
    for loadoutID in pairs(db[playerKey][specID]) do
        if not currentLoadouts[loadoutID] then
            db[playerKey][specID][loadoutID] = nil
        end
    end
end

function Rotations.createTabContent()
    EnsureDB()
    Rotations.UpdateLoadouts()

    local frame = CreateFrame("Frame")
    frame:SetSize(560, 400)

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -20)
    title:SetText("Rotaciones: habilidades usadas por loadout")
    title:SetTextColor(1, 0.82, 0)

    local playerKey = GetPlayerKey()
    local specID = SafeGetCurrentSpecID()
    if not specID then
        local info = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        info:SetPoint("TOPLEFT", 20, -60)
        return frame
    end

    local db = (ProdigyUtilsDB.rotations and ProdigyUtilsDB.rotations[playerKey] and ProdigyUtilsDB.rotations[playerKey][specID]) or
        {}

    local loadoutScroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    loadoutScroll:SetPoint("TOPLEFT", 20, -80)
    loadoutScroll:SetSize(200, 280) -- Reducido para dar espacio al botón Reset
    local loadoutContent = CreateFrame("Frame", nil, loadoutScroll)
    loadoutContent:SetSize(200, 600)
    loadoutScroll:SetScrollChild(loadoutContent)

    -- Título para la sección de habilidades con el nombre del loadout
    local abilityTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    abilityTitle:SetPoint("TOP", 0, -40)
    abilityTitle:SetText("Selecciona un loadout")
    abilityTitle:SetTextColor(1, 1, 1)

    -- ScrollFrame de habilidades con anclaje dinámico
    local abilityScroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    abilityScroll:SetPoint("TOPLEFT", 240, -80)
    abilityScroll:SetPoint("BOTTOMRIGHT", -30, 30)
    local abilityContent = CreateFrame("Frame", nil, abilityScroll)
    abilityContent:SetSize(300, 600)
    abilityScroll:SetScrollChild(abilityContent)

    -- Variables para rastrear el loadout y botón actualmente seleccionado
    local selectedButton = nil
    local selectedLoadoutID = nil -- NUEVO: Para saber qué loadout está seleccionado

    local function ShowAbilities(loadoutData, loadoutID, clickedButton)
        -- Limpiar todos los FontStrings previos del abilityContent
        for _, child in ipairs({ abilityContent:GetRegions() }) do
            if child:GetObjectType() == "FontString" then
                child:Hide()
                child:SetParent(nil)
            end
        end

        -- Limpiar todos los frames hijos del abilityContent
        for _, child in ipairs({ abilityContent:GetChildren() }) do
            child:Hide()
            child:SetParent(nil)
        end

        -- Actualizar el título con el nombre del loadout seleccionado
        abilityTitle:SetText(loadoutData.name or "Loadout " .. tostring(loadoutID))
        abilityTitle:SetTextColor(1, 0.82, 0) -- Color dorado para indicar selección

        -- Gestión de botón seleccionado (highlighting)
        if selectedButton then
            selectedButton:SetNormalFontObject("GameFontNormal")
            selectedButton:SetHighlightFontObject("GameFontHighlight")
        end
        selectedButton = clickedButton
        selectedLoadoutID = loadoutID -- NUEVO: Guardar el ID del loadout seleccionado
        if selectedButton then
            selectedButton:SetNormalFontObject("GameFontHighlight")
            selectedButton:SetHighlightFontObject("GameFontNormal")
        end

        -- Código para mostrar habilidades SIN spellID y con contador en verde
        local abilities = {}
        for spellID, v in pairs(loadoutData.abilities) do
            table.insert(abilities, { name = v.name, count = v.count })
        end
        table.sort(abilities, function(a, b) return a.count > b.count end)
        local yy = 0
        for i, ab in ipairs(abilities) do
            local line = abilityContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            line:SetPoint("TOPLEFT", 10, -yy)
            line:SetText(string.format("%s: |cff00ff00%d|r", ab.name, ab.count))
            yy = yy + 22
        end
        if #abilities == 0 then
            local line = abilityContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            line:SetPoint("TOPLEFT", 10, 0)
            line:SetText("No se ha registrado ninguna habilidad para este loadout.")
        end
    end

    -- MODIFICADO: Botón Reset que solo borra el loadout seleccionado
    local resetButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    resetButton:SetSize(80, 25)
    resetButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 20, 10)
    resetButton:SetText("Reset")
    resetButton:SetScript("OnClick", function()
        -- NUEVO: Verificar que hay un loadout seleccionado
        if not selectedLoadoutID then
            print("|cffff0000[Prodigy]|r Primero selecciona un loadout para poder resetearlo.")
            return
        end

        -- Obtener el nombre del loadout para el mensaje de confirmación
        local loadoutName = "Loadout " .. tostring(selectedLoadoutID)
        if db[selectedLoadoutID] and db[selectedLoadoutID].name then
            loadoutName = db[selectedLoadoutID].name
        end

        -- Crear popup de confirmación para el reset del loadout específico
        StaticPopupDialogs["PRODIGY_CONFIRM_RESET_ROTATION"] = {
            text = string.format(
                "¿Estás seguro de que quieres borrar todos los datos de rotación del loadout '%s'?\n\nEsta acción no se puede deshacer.",
                loadoutName),
            button1 = "Sí, borrar",
            button2 = "Cancelar",
            OnAccept = function()
                -- MODIFICADO: Borrar solo los datos del loadout seleccionado
                if ProdigyUtilsDB.rotations and ProdigyUtilsDB.rotations[playerKey] and ProdigyUtilsDB.rotations[playerKey][specID] and ProdigyUtilsDB.rotations[playerKey][specID][selectedLoadoutID] then
                    -- Limpiar solo las habilidades del loadout seleccionado
                    ProdigyUtilsDB.rotations[playerKey][specID][selectedLoadoutID].abilities = {}

                    -- Actualizar la vista actual
                    for _, child in ipairs({ abilityContent:GetRegions() }) do
                        if child:GetObjectType() == "FontString" then
                            child:Hide()
                            child:SetParent(nil)
                        end
                    end

                    for _, child in ipairs({ abilityContent:GetChildren() }) do
                        child:Hide()
                        child:SetParent(nil)
                    end

                    -- Mostrar mensaje de que no hay datos
                    local line = abilityContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                    line:SetPoint("TOPLEFT", 10, 0)
                    line:SetText("No se ha registrado ninguna habilidad para este loadout.")

                    print("|cff00ff00[Prodigy]|r Datos de rotación borrados para el loadout '" .. loadoutName .. "'.")
                end
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
        StaticPopup_Show("PRODIGY_CONFIRM_RESET_ROTATION")
    end)

    -- Obtener loadout activo actual para auto-selección
    local activeLoadoutID = nil
    if C_ClassTalents and C_ClassTalents.GetLastSelectedSavedConfigID then
        activeLoadoutID = C_ClassTalents.GetLastSelectedSavedConfigID(specID)
    end

    local n = 0
    local activeButton = nil -- Para guardar referencia al botón activo

    for loadoutID, loadoutData in pairs(db) do
        n = n + 1
        local btn = CreateFrame("Button", nil, loadoutContent, "UIPanelButtonTemplate")
        btn:SetSize(180, 28)
        btn:SetPoint("TOPLEFT", 10, -((n - 1) * 35))
        btn:SetText((loadoutData.name or "Loadout " .. tostring(loadoutID)))
        btn:SetScript("OnClick", function() ShowAbilities(loadoutData, loadoutID, btn) end)

        -- Si este es el loadout activo, guardamos la referencia
        if activeLoadoutID and tonumber(loadoutID) == activeLoadoutID then
            activeButton = btn
        end
    end

    if n == 0 then
        local info = loadoutContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        info:SetPoint("TOPLEFT", 10, 0)
        info:SetText("No hay loadouts disponibles para la especialización actual.")
    else
        -- Auto-seleccionar el loadout activo si existe
        if activeButton and activeLoadoutID and db[activeLoadoutID] then
            ShowAbilities(db[activeLoadoutID], activeLoadoutID, activeButton)
        end
    end

    return frame
end

-- Variable para guardar el frame actual
local lastFrame = nil

-- Función para refrescar el contenido de la pestaña
function Rotations.refreshTabContent(container)
    -- Elimina el frame anterior
    if lastFrame then
        lastFrame:Hide()
        lastFrame:SetParent(nil)
        lastFrame = nil
    end

    -- Crear nuevo contenido actualizado
    local newFrame = Rotations.createTabContent()
    newFrame:SetParent(container)
    newFrame:SetAllPoints(container)
    newFrame:Show()

    -- Guardar referencia al nuevo frame
    lastFrame = newFrame
end

function Rotations.OnLoad()
    EnsureDB()
    Rotations.UpdateLoadouts()

    if not Rotations.eventFrame then
        local f = CreateFrame("Frame")
        f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        f:SetScript("OnEvent", function()
            if not UnitAffectingCombat("player") then return end
            local _, event, _, sourceGUID, _, _, _, _, _, _, _, spellID, spellName = CombatLogGetCurrentEventInfo()
            if event == "SPELL_CAST_SUCCESS" and sourceGUID == UnitGUID("player") then
                EnsureDB()
                local playerKey = GetPlayerKey()
                local specID = SafeGetCurrentSpecID()
                if not specID then return end
                local loadoutID = (C_ClassTalents and C_ClassTalents.GetLastSelectedSavedConfigID and C_ClassTalents.GetLastSelectedSavedConfigID(specID)) or
                    nil
                if not loadoutID then return end
                if not (ProdigyUtilsDB.rotations and ProdigyUtilsDB.rotations[playerKey] and ProdigyUtilsDB.rotations[playerKey][specID] and ProdigyUtilsDB.rotations[playerKey][specID][loadoutID]) then
                    Rotations.UpdateLoadouts()
                end
                local abilities = ProdigyUtilsDB.rotations[playerKey][specID][loadoutID].abilities
                abilities[spellID] = abilities[spellID] or { name = spellName, count = 0 }
                abilities[spellID].count = abilities[spellID].count + 1
            end
        end)
        Rotations.eventFrame = f
    end
end

-- Registrar el módulo CON la función de refresh
ProdigyUtils:RegisterModule("rotations", {
    displayName = "Rotaciones",
    createTabContent = Rotations.createTabContent,
    refreshTabContent = Rotations.refreshTabContent
})

Rotations.OnLoad()
