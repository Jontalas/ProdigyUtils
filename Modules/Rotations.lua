local Rotations = {}

local function GetPlayerKey()
    return UnitName("player") .. "-" .. GetRealmName()
end

local function SafeGetCurrentSpecID()
    return (PlayerUtil and PlayerUtil.GetCurrentSpecID and PlayerUtil.GetCurrentSpecID()) or nil
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

    local configIDs = (C_ClassTalents and C_ClassTalents.GetConfigIDsBySpecID and C_ClassTalents.GetConfigIDsBySpecID(specID)) or nil
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
        info:SetText("No se ha detectado una especialización de talentos disponible para el personaje.\n"
            .. "Si acabas de iniciar sesión o cambiar de personaje, vuelve a esta pestaña en unos segundos.")
        return frame
    end

    local db = (ProdigyUtilsDB.rotations and ProdigyUtilsDB.rotations[playerKey] and ProdigyUtilsDB.rotations[playerKey][specID]) or {}

    local loadoutScroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    loadoutScroll:SetPoint("TOPLEFT", 20, -60)
    loadoutScroll:SetSize(200, 320)
    local loadoutContent = CreateFrame("Frame", nil, loadoutScroll)
    loadoutContent:SetSize(200, 600)
    loadoutScroll:SetScrollChild(loadoutContent)

    local abilityScroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    abilityScroll:SetPoint("TOPLEFT", 240, -60)
    abilityScroll:SetSize(300, 320)
    local abilityContent = CreateFrame("Frame", nil, abilityScroll)
    abilityContent:SetSize(300, 600)
    abilityScroll:SetScrollChild(abilityContent)

    local function ShowAbilities(loadoutData)
        -- Borra todos los hijos previos del abilityContent
        for _, child in ipairs({abilityContent:GetChildren()}) do
            child:Hide()
            child:SetParent(nil)
        end
        local abilities = {}
        for spellID, v in pairs(loadoutData.abilities) do
            table.insert(abilities, { spellID = spellID, name = v.name, count = v.count })
        end
        table.sort(abilities, function(a, b) return a.count > b.count end)
        local yy = 0
        for i, ab in ipairs(abilities) do
            local line = abilityContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            line:SetPoint("TOPLEFT", 10, -yy)
            line:SetText(string.format("%s (ID: %d): %d", ab.name, ab.spellID, ab.count))
            yy = yy + 22
        end
        if #abilities == 0 then
            local line = abilityContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            line:SetPoint("TOPLEFT", 10, 0)
            line:SetText("No se ha registrado ninguna habilidad para este loadout.")
        end
    end

    local n = 0
    for loadoutID, loadoutData in pairs(db) do
        n = n + 1
        local btn = CreateFrame("Button", nil, loadoutContent, "UIPanelButtonTemplate")
        btn:SetSize(180, 28)
        btn:SetPoint("TOPLEFT", 10, -((n-1)*35))
        btn:SetText((loadoutData.name or "Loadout " .. tostring(loadoutID)))
        btn:SetScript("OnClick", function() ShowAbilities(loadoutData) end)
    end
    if n == 0 then
        local info = loadoutContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        info:SetPoint("TOPLEFT", 10, 0)
        info:SetText("No hay loadouts disponibles para la especialización actual.")
    end

    return frame
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
                local loadoutID = (C_ClassTalents and C_ClassTalents.GetLastSelectedSavedConfigID and C_ClassTalents.GetLastSelectedSavedConfigID(specID)) or nil
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

ProdigyUtils:RegisterModule("rotations", {
    displayName = "Rotaciones",
    createTabContent = Rotations.createTabContent
})

Rotations.OnLoad()