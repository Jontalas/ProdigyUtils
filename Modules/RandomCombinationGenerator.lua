-- Módulo Generador de Combinaciones Aleatorias
local RandomCombinationGenerator = {}

-- Base de datos de clases y especializaciones con iconos
local classSpecData = {
    ["Caballero de la Muerte"] = {
        specs = {
            { name = "Sangre",   role = "Tanque",              icon = 135770 },
            { name = "Escarcha", role = "DPS cuerpo a cuerpo", icon = 135773 },
            { name = "Profano",  role = "DPS cuerpo a cuerpo", icon = 135775 }
        }
    },
    ["Cazador de Demonios"] = {
        specs = {
            { name = "Devastación", role = "DPS cuerpo a cuerpo", icon = 1247264 },
            { name = "Venganza",    role = "Tanque",              icon = 1247265 }
        }
    },
    ["Druida"] = {
        specs = {
            { name = "Equilibrio",   role = "DPS a distancia",     icon = 136096 },
            { name = "Feral",        role = "DPS cuerpo a cuerpo", icon = 132115 },
            { name = "Guardián",     role = "Tanque",              icon = 132276 },
            { name = "Restauración", role = "Sanador",             icon = 136041 }
        }
    },
    ["Evocador"] = {
        specs = {
            { name = "Devastación",  role = "DPS a distancia", icon = 4574311 },
            { name = "Preservación", role = "Sanador",         icon = 4511812 },
            { name = "Aumento",      role = "DPS a distancia", icon = 5198700 }
        }
    },
    ["Cazador"] = {
        specs = {
            { name = "Bestias",       role = "DPS a distancia",     icon = 461112 },
            { name = "Puntería",      role = "DPS a distancia",     icon = 236179 },
            { name = "Supervivencia", role = "DPS cuerpo a cuerpo", icon = 461113 }
        }
    },
    ["Mago"] = {
        specs = {
            { name = "Arcano",   role = "DPS a distancia", icon = 135932 },
            { name = "Fuego",    role = "DPS a distancia", icon = 135810 },
            { name = "Escarcha", role = "DPS a distancia", icon = 135846 }
        }
    },
    ["Monje"] = {
        specs = {
            { name = "Maestro Cervecero",  role = "Tanque",              icon = 608951 },
            { name = "Tejedor de Niebla",  role = "Sanador",             icon = 608952 },
            { name = "Viajero del Viento", role = "DPS cuerpo a cuerpo", icon = 608953 }
        }
    },
    ["Paladín"] = {
        specs = {
            { name = "Sagrado",    role = "Sanador",             icon = 135920 },
            { name = "Protección", role = "Tanque",              icon = 236264 },
            { name = "Reprensión", role = "DPS cuerpo a cuerpo", icon = 135873 }
        }
    },
    ["Sacerdote"] = {
        specs = {
            { name = "Disciplina", role = "Sanador",         icon = 135940 },
            { name = "Sagrado",    role = "Sanador",         icon = 237542 },
            { name = "Sombras",    role = "DPS a distancia", icon = 136207 }
        }
    },
    ["Pícaro"] = {
        specs = {
            { name = "Asesinato", role = "DPS cuerpo a cuerpo", icon = 236270 },
            { name = "Forajido",  role = "DPS cuerpo a cuerpo", icon = 236286 },
            { name = "Sutileza",  role = "DPS cuerpo a cuerpo", icon = 132320 }
        }
    },
    ["Chamán"] = {
        specs = {
            { name = "Elemental",    role = "DPS a distancia",     icon = 136048 },
            { name = "Mejora",       role = "DPS cuerpo a cuerpo", icon = 237581 },
            { name = "Restauración", role = "Sanador",             icon = 136052 }
        }
    },
    ["Brujo"] = {
        specs = {
            { name = "Aflicción",   role = "DPS a distancia", icon = 136145 },
            { name = "Demonología", role = "DPS a distancia", icon = 136172 },
            { name = "Destrucción", role = "DPS a distancia", icon = 136186 }
        }
    },
    ["Guerrero"] = {
        specs = {
            { name = "Armas",      role = "DPS cuerpo a cuerpo", icon = 132355 },
            { name = "Furia",      role = "DPS cuerpo a cuerpo", icon = 132347 },
            { name = "Protección", role = "Tanque",              icon = 132341 }
        }
    }
}

local factions = { "Alianza", "Horda" }

-- Iconos de facciones
local factionIcons = {
    ["Alianza"] = 2173919,
    ["Horda"] = 2173920
}

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

-- Función para obtener el icono de una especialización
local function GetSpecIcon(className, specName)
    local classData = classSpecData[className]
    if classData then
        for _, spec in ipairs(classData.specs) do
            if spec.name == specName then
                return spec.icon
            end
        end
    end
    return 134400 -- Icono por defecto
end

-- Función para inicializar configuración por defecto
local function InitializeDefaultSettings()
    if not ProdigyUtils.db.randomCombination then
        ProdigyUtils.db.randomCombination = {
            specs = {},
            classFactions = {},
            classEnabled = {}, -- NUEVO: Configuración de clases habilitadas
            lastResult = {
                class = "",
                spec = "",
                faction = "",
                role = "",
                specIcon = 134400,
                factionIcon = 2173919
            }
        }
    end

    -- Inicializar configuración de especializaciones
    if not ProdigyUtils.db.randomCombination.specs then
        ProdigyUtils.db.randomCombination.specs = {}
    end

    -- Inicializar configuración de facciones por clase
    if not ProdigyUtils.db.randomCombination.classFactions then
        ProdigyUtils.db.randomCombination.classFactions = {}
    end

    -- NUEVO: Inicializar configuración de clases habilitadas
    if not ProdigyUtils.db.randomCombination.classEnabled then
        ProdigyUtils.db.randomCombination.classEnabled = {}
    end

    -- Configurar todas las especializaciones
    for className, classData in pairs(classSpecData) do
        -- Configurar facción por clase (si no existe)
        if not ProdigyUtils.db.randomCombination.classFactions[className] then
            ProdigyUtils.db.randomCombination.classFactions[className] = "both"
        end

        -- NUEVO: Configurar clase habilitada por defecto
        if ProdigyUtils.db.randomCombination.classEnabled[className] == nil then
            ProdigyUtils.db.randomCombination.classEnabled[className] = true
        end

        for _, spec in ipairs(classData.specs) do
            local specKey = className .. "_" .. spec.name
            if not ProdigyUtils.db.randomCombination.specs[specKey] then
                ProdigyUtils.db.randomCombination.specs[specKey] = {
                    enabled = true,
                    weight = 5,
                    class = className,
                    specName = spec.name,
                    role = spec.role,
                    icon = spec.icon
                }
            else
                -- Actualizar icono si no existe
                if not ProdigyUtils.db.randomCombination.specs[specKey].icon then
                    ProdigyUtils.db.randomCombination.specs[specKey].icon = spec.icon
                end
                -- Limpiar faction de specs existentes si existe
                ProdigyUtils.db.randomCombination.specs[specKey].faction = nil
            end
        end
    end
end

-- Función para calcular probabilidades considerando clases habilitadas
local function CalculateWeightedProbabilities(mode)
    local enabledSpecs = {}
    local weights = {}

    for specKey, specConfig in pairs(ProdigyUtils.db.randomCombination.specs) do
        local classEnabled = ProdigyUtils.db.randomCombination.classEnabled[specConfig.class]
        local include = false

        if mode == "inverse" then
            include = (specConfig.enabled == false)
            -- Ignora el checkbox de la clase
        else
            include = (classEnabled and specConfig.enabled)
        end

        if include then
            local classFaction = ProdigyUtils.db.randomCombination.classFactions[specConfig.class] or "both"
            if classFaction ~= "none" then
                table.insert(enabledSpecs, specConfig)
                table.insert(weights, specConfig.weight)
            end
        end
    end

    if #enabledSpecs == 0 then
        return {}, {}
    end

    -- Pesos y cálculos igual que antes
    local invertedWeights = {}
    for _, weight in ipairs(weights) do
        table.insert(invertedWeights, 1 / weight)
    end

    local totalWeight = 0
    for _, weight in ipairs(invertedWeights) do
        totalWeight = totalWeight + weight
    end

    local probabilities = {}
    for _, weight in ipairs(invertedWeights) do
        table.insert(probabilities, weight / totalWeight)
    end

    return enabledSpecs, probabilities
end

-- Función para generar combinación aleatoria
local function GenerateRandomCombination(mode)
    local enabledSpecs, probabilities = CalculateWeightedProbabilities(mode)

    if #enabledSpecs == 0 then
        return nil, "No hay especializaciones habilitadas"
    end

    -- Seleccionar especialización basada en probabilidades
    local random = math.random()
    local cumulativeProbability = 0
    local selectedSpec = nil

    for i, spec in ipairs(enabledSpecs) do
        cumulativeProbability = cumulativeProbability + probabilities[i]
        if random <= cumulativeProbability then
            selectedSpec = spec
            break
        end
    end

    if not selectedSpec then
        selectedSpec = enabledSpecs[#enabledSpecs] -- Fallback al último
    end

    -- Lógica de facciones especial para modo inverso
    local classFaction = ProdigyUtils.db.randomCombination.classFactions[selectedSpec.class] or "both"
    local availableFactions = {}

    if mode == "inverse" then
        if classFaction == "both" then
            availableFactions = { "Alianza", "Horda" }
        elseif classFaction == "alliance" then
            availableFactions = { "Horda" }
        elseif classFaction == "horde" then
            availableFactions = { "Alianza" }
        end
    else
        if classFaction == "both" then
            availableFactions = { "Alianza", "Horda" }
        elseif classFaction == "alliance" then
            availableFactions = { "Alianza" }
        elseif classFaction == "horde" then
            availableFactions = { "Horda" }
        end
    end

    if #availableFactions == 0 then
        return nil, "No hay facciones disponibles para esta clase"
    end

    local selectedFaction = availableFactions[math.random(#availableFactions)]

    -- Obtener el rol directamente desde classSpecData
    local role = nil
    local classData = classSpecData[selectedSpec.class]
    if classData then
        for _, spec in ipairs(classData.specs) do
            if spec.name == selectedSpec.specName then
                role = spec.role
                break
            end
        end
    end

    if not role then
        role = "Desconocido" -- Rol por defecto si no se encuentra
    end

    -- Obtener icono de especialización directamente de la tabla
    local specIcon = GetSpecIcon(selectedSpec.class, selectedSpec.specName)

    return {
        class = selectedSpec.class,
        spec = selectedSpec.specName,
        faction = selectedFaction,
        role = role, -- Usar el rol desde classSpecData
        specIcon = specIcon,
        factionIcon = factionIcons[selectedFaction] or 2173919
    }
end

-- Función para crear el contenido de la pestaña
function RandomCombinationGenerator.createTabContent()
    local frame = CreateFrame("Frame")
    frame:SetSize(560, 400)

    -- CONTENEDOR CENTRAL
    local mainContainer = CreateFrame("Frame", nil, frame)
    mainContainer:SetSize(560, 400)
    mainContainer:SetPoint("CENTER", frame, "CENTER", 0, 0)

    -- Título principal
    local title = mainContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -20)
    title:SetText("Generador de Combinaciones Aleatorias")
    title:SetTextColor(1, 0.82, 0)

    -- MODO DE GENERACIÓN (Dropdown)
    local modeDropdown = CreateFrame("Frame", nil, mainContainer)
    modeDropdown:SetSize(170, 25)
    modeDropdown:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)

    local modeLabel = modeDropdown:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    modeLabel:SetPoint("LEFT", modeDropdown, "LEFT", 0, 0)
    modeLabel:SetText("Modo de generación:")

    local dropdown = CreateFrame("Frame", "ProdigyGenModeDropdown", modeDropdown, "UIDropDownMenuTemplate")
    dropdown:SetPoint("LEFT", modeLabel, "RIGHT", -10, -3)
    local generationMode = "normal" -- default

    local function OnSelectMode(self, arg1, arg2, checked)
        generationMode = arg1
        UIDropDownMenu_SetSelectedID(dropdown, self:GetID())
    end

    UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        info.func = OnSelectMode

        info.text = "Normal"
        info.arg1 = "normal"
        info.checked = (generationMode == "normal")
        UIDropDownMenu_AddButton(info)

        info = UIDropDownMenu_CreateInfo()
        info.func = OnSelectMode
        info.text = "Inverso"
        info.arg1 = "inverse"
        info.checked = (generationMode == "inverse")
        UIDropDownMenu_AddButton(info)
    end)

    UIDropDownMenu_SetWidth(dropdown, 120)
    UIDropDownMenu_SetSelectedID(dropdown, 1)

    -- Frame para el resultado (también dentro del contenedor)
    local resultFrame = CreateFrame("Frame", nil, mainContainer, "InsetFrameTemplate")
    resultFrame:SetPoint("TOP", title, "BOTTOM", 0, -60)
    resultFrame:SetSize(500, 180)

    -- NUEVO: Contenedor para iconos y textos, para centrar todo el conjunto
    local resultContainer = CreateFrame("Frame", nil, resultFrame)
    resultContainer:SetSize(400, 64)
    resultContainer:SetPoint("CENTER", resultFrame, "CENTER", 0, 0)

    -- Icono de facción (ahora a la IZQUIERDA)
    local factionIcon = resultContainer:CreateTexture(nil, "ARTWORK")
    factionIcon:SetSize(48, 48)
    factionIcon:SetPoint("LEFT", resultContainer, "LEFT", 80, 0)
    factionIcon:SetTexture(2173919) -- Icono Alianza por defecto

    -- Icono de especialización (ahora a la derecha del de facción)
    local specIcon = resultContainer:CreateTexture(nil, "ARTWORK")
    specIcon:SetSize(48, 48)
    specIcon:SetPoint("LEFT", factionIcon, "RIGHT", 10, 0)
    specIcon:SetTexture(134400) -- Icono por defecto

    -- Texto del resultado (ahora a la derecha del icono de especialización)
    local resultText = resultContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    resultText:SetPoint("LEFT", specIcon, "RIGHT", 20, 0)
    resultText:SetWidth(270)
    resultText:SetJustifyH("LEFT")
    resultText:SetText("Presiona 'Generar' para obtener una combinación")

    -- Centrar el conjunto visualmente en el frame de resultado
    -- (el propio resultContainer ya está centrado, solo ajustar tamaños si es necesario)

    -- Función para actualizar el resultado
    local function UpdateResult()
        local result, error = GenerateRandomCombination(generationMode)

        if error then
            resultText:SetText("|cffff0000Error: " .. error .. "|r")
            specIcon:SetTexture(134400)     -- Icono error
            factionIcon:SetTexture(2173919) -- Icono por defecto
            return
        end

        if result then
            -- Guardar último resultado
            ProdigyUtils.db.randomCombination.lastResult = result

            -- Obtener color de clase
            local classColor = classColors[result.class] or "|cffffffff"

            -- Formatear resultado SIN facción (ya se muestra el icono)
            local specKey = result.class .. "_" .. result.spec
            local specConfig = ProdigyUtils.db.randomCombination.specs[specKey]
            local weightText = specConfig and specConfig.weight and (" (" .. tostring(specConfig.weight) .. ")") or ""
            local resultString = string.format(
                "%s%s|r\n%s%s\n%s",
                classColor,
                result.class,
                result.spec,
                weightText,
                result.role
            )
            resultText:SetText(resultString)

            -- Actualizar iconos
            if result.specIcon and result.specIcon > 0 then
                specIcon:SetTexture(result.specIcon)
            else
                specIcon:SetTexture(134400) -- Fallback
            end

            if result.factionIcon and result.factionIcon > 0 then
                factionIcon:SetTexture(result.factionIcon)
            else
                factionIcon:SetTexture(2173919) -- Fallback
            end

            ProdigyUtils:Debug("Resultado generado: " .. result.class .. " " .. result.spec .. " " .. result.faction)
        end
    end

    -- Botón principal de generar (sin cambios)
    local generateButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    generateButton:SetSize(360, 60)
    generateButton:SetPoint("TOP", resultFrame, "BOTTOM", 0, -20)
    generateButton:SetText("Generar")
    generateButton:SetScript("OnClick", UpdateResult)
    local generateButtonText = generateButton:GetFontString()
    generateButtonText:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")

    -- Crear fila inferior de botones (bien alineados)
    local buttonWidth, buttonHeight = 150, 30

    -- Botón Configurar Pesos (izquierda)
    local configButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    configButton:SetSize(buttonWidth, buttonHeight)
    configButton:SetPoint("TOPLEFT", generateButton, "BOTTOMLEFT", -50, -15)
    configButton:SetText("Configurar Pesos")
    configButton:SetScript("OnClick", function()
        RandomCombinationGenerator.ShowConfigWindow()
    end)

    -- Botón Resumen de Pesos (centro)
    local summaryButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    summaryButton:SetSize(buttonWidth, buttonHeight)
    summaryButton:SetPoint("TOP", generateButton, "BOTTOM", 0, -15)
    summaryButton:SetText("Resumen de Pesos")
    summaryButton:SetScript("OnClick", function()
        RandomCombinationGenerator.ShowSummaryWindow()
    end)

    -- Botón Probar Probabilidades (derecha)
    local testButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    testButton:SetSize(buttonWidth, buttonHeight)
    testButton:SetPoint("TOPRIGHT", generateButton, "BOTTOMRIGHT", 50, -15)
    testButton:SetText("Probar Probabilidades")
    testButton:SetScript("OnClick", function()
        RandomCombinationGenerator.ShowTestWindow()
    end)


    -- Mostrar último resultado si existe
    local lastResult = ProdigyUtils.db.randomCombination.lastResult
    if lastResult and lastResult.class ~= "" then
        local classColor = classColors[lastResult.class] or "|cffffffff"
        local resultString = string.format(
            "%s%s|r\n%s\n%s",
            classColor,
            lastResult.class,
            lastResult.spec,
            lastResult.role
        )
        resultText:SetText(resultString)

        -- Mostrar iconos del último resultado
        if lastResult.specIcon then
            specIcon:SetTexture(lastResult.specIcon)
        end
        if lastResult.factionIcon then
            factionIcon:SetTexture(lastResult.factionIcon)
        end
    end

    return frame
end

-- SISTEMA DE DROPDOWN PERSONALIZADO
local function CreateCustomDropdown(parent, width, x, y)
    local dropdown = CreateFrame("Frame", nil, parent)
    dropdown:SetSize(width, 25)
    dropdown:SetPoint("TOPLEFT", x, y)

    -- Fondo del dropdown
    local bg = dropdown:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)

    -- Borde del dropdown
    local border = dropdown:CreateTexture(nil, "BORDER")
    border:SetPoint("TOPLEFT", -1, 1)
    border:SetPoint("BOTTOMRIGHT", 1, -1)
    border:SetColorTexture(0.6, 0.6, 0.6, 1)

    -- Texto del dropdown
    local text = dropdown:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("LEFT", 8, 0)
    text:SetJustifyH("LEFT")
    text:SetText("Seleccionar...")

    -- Flecha
    local arrow = dropdown:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    arrow:SetPoint("RIGHT", -8, 0)
    arrow:SetText("▼")

    -- Variables del dropdown
    local options = {}
    local selectedValue = nil
    local onSelectCallback = nil
    local isOpen = false
    local menuFrame = nil

    -- Función para cerrar el menú
    local function CloseMenu()
        if menuFrame then
            menuFrame:Hide()
            menuFrame = nil
            isOpen = false
            arrow:SetText("▼")
        end
    end

    -- Función para abrir el menú
    local function OpenMenu()
        if isOpen then
            CloseMenu()
            return
        end

        if #options == 0 then return end

        -- Crear frame del menú
        menuFrame = CreateFrame("Frame", nil, dropdown)
        menuFrame:SetSize(width, #options * 25)
        menuFrame:SetPoint("TOPLEFT", dropdown, "BOTTOMLEFT", 0, -2)
        menuFrame:SetFrameStrata("TOOLTIP")
        menuFrame:SetFrameLevel(dropdown:GetFrameLevel() + 10)

        -- Fondo del menú
        local menuBg = menuFrame:CreateTexture(nil, "BACKGROUND")
        menuBg:SetAllPoints()
        menuBg:SetColorTexture(0.1, 0.1, 0.1, 0.95)

        -- Borde del menú
        local menuBorder = menuFrame:CreateTexture(nil, "BORDER")
        menuBorder:SetPoint("TOPLEFT", -1, 1)
        menuBorder:SetPoint("BOTTOMRIGHT", 1, -1)
        menuBorder:SetColorTexture(0.6, 0.6, 0.6, 1)

        -- Crear opciones
        for i, option in ipairs(options) do
            local optionButton = CreateFrame("Button", nil, menuFrame)
            optionButton:SetSize(width - 4, 23)
            optionButton:SetPoint("TOPLEFT", 2, -(i - 1) * 25 - 1)

            -- Texto de la opción
            local optionText = optionButton:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            optionText:SetPoint("LEFT", 6, 0)
            optionText:SetText(option.text)

            -- Highlight de la opción
            local highlight = optionButton:CreateTexture(nil, "ARTWORK")
            highlight:SetAllPoints()
            highlight:SetColorTexture(0.3, 0.3, 0.8, 0.5)
            highlight:Hide()

            -- Marcar si está seleccionada
            if option.value == selectedValue then
                optionText:SetTextColor(1, 1, 0)
            else
                optionText:SetTextColor(1, 1, 1)
            end

            -- Scripts de la opción
            optionButton:SetScript("OnEnter", function()
                highlight:Show()
            end)

            optionButton:SetScript("OnLeave", function()
                highlight:Hide()
            end)

            optionButton:SetScript("OnClick", function()
                selectedValue = option.value
                text:SetText(option.text)
                if onSelectCallback then
                    onSelectCallback(option.value, option.text)
                end
                CloseMenu()
            end)
        end

        isOpen = true
        arrow:SetText("▲")

        -- Cerrar menú al hacer clic fuera
        local closeHandler = CreateFrame("Frame", nil, UIParent)
        closeHandler:SetAllPoints(UIParent)
        closeHandler:SetFrameStrata("TOOLTIP")
        closeHandler:SetFrameLevel(1)
        closeHandler:EnableMouse(true)
        closeHandler:SetScript("OnMouseDown", function()
            CloseMenu()
            closeHandler:Hide()
        end)

        menuFrame:SetScript("OnHide", function()
            closeHandler:Hide()
        end)
    end

    -- Hacer el dropdown clickeable
    dropdown:EnableMouse(true)
    dropdown:SetScript("OnMouseDown", OpenMenu)

    -- Funciones públicas del dropdown
    function dropdown:SetOptions(newOptions)
        options = newOptions
        CloseMenu()
    end

    function dropdown:SetValue(value)
        selectedValue = value
        for _, option in ipairs(options) do
            if option.value == value then
                text:SetText(option.text)
                break
            end
        end
    end

    function dropdown:GetValue()
        return selectedValue
    end

    function dropdown:SetCallback(callback)
        onSelectCallback = callback
    end

    function dropdown:SetText(newText)
        text:SetText(newText)
    end

    return dropdown
end

-- Función para ajustar la opacidad de una clase
local function SetClassOpacity(className, enabled, controls)
    local alpha = enabled and 1.0 or 0.5 -- 100% opacidad si está habilitada, 50% si está deshabilitada

    -- Ajustar opacidad de todos los elementos relacionados con la clase
    for _, control in pairs(controls) do
        if control.class == className then
            if control.enabledCheckbox then
                control.enabledCheckbox:SetAlpha(alpha)
            end
            if control.weightEditBox then
                control.weightEditBox:SetAlpha(alpha)
            end
            if control.specIcon then
                control.specIcon:SetAlpha(alpha)
            end
            if control.specText then
                control.specText:SetAlpha(alpha)
            end
            if control.weightLabel then
                control.weightLabel:SetAlpha(alpha)
            end
            if control.helpText then
                control.helpText:SetAlpha(alpha)
            end
        end
    end
end

-- Ventana de configuración con efecto visual para clases deshabilitadas
function RandomCombinationGenerator.ShowConfigWindow()
    if RandomCombinationGenerator.configFrame and RandomCombinationGenerator.configFrame:IsShown() then
        RandomCombinationGenerator.configFrame:Hide()
        return
    end

    -- Variables para controlar cambios
    local pendingChanges = {}
    local hasUnsavedChanges = false

    -- Crear ventana de configuración
    local configFrame = CreateFrame("Frame", "ProdigyRandomConfigFrame", UIParent, "BasicFrameTemplateWithInset")
    configFrame:SetSize(900, 700)
    configFrame:SetPoint("CENTER")

    -- Usar sistema de estratos para ventana de diálogo
    local strata, level = ProdigyUtils.FrameStrataManager:GetDialogStrata()
    configFrame:SetFrameStrata(strata)
    configFrame:SetFrameLevel(level)

    configFrame:SetMovable(true)
    configFrame:EnableMouse(true)
    configFrame:RegisterForDrag("LeftButton")
    configFrame:SetScript("OnDragStart", configFrame.StartMoving)
    configFrame:SetScript("OnDragStop", configFrame.StopMovingOrSizing)
    configFrame.TitleText:SetText("Configuración de Pesos de Especializaciones")

    -- Script para mantenerse al frente al mostrarse
    configFrame:SetScript("OnShow", function(self)
        if ProdigyUtils.db.alwaysOnTop ~= false then
            ProdigyUtils.FrameStrataManager:BringToFront(self)
        end
    end)

    RandomCombinationGenerator.configFrame = configFrame

    -- Crear área de scroll
    local scrollFrame = CreateFrame("ScrollFrame", nil, configFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 15, -30)
    scrollFrame:SetPoint("BOTTOMRIGHT", configFrame, "BOTTOMRIGHT", -35, 50)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(850, 2000)
    scrollFrame:SetScrollChild(content)

    -- Título principal
    local mainTitle = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    mainTitle:SetPoint("TOPLEFT", 10, -10)
    mainTitle:SetText("Configuración de Pesos por Especialización")
    mainTitle:SetTextColor(1, 0.82, 0)

    -- Descripción
    local description = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    description:SetPoint("TOPLEFT", mainTitle, "BOTTOMLEFT", 0, -10)
    description:SetText(
        "Habilitar o deshabilitar clases afecta la generación, no el estado de sus especializaciones. Peso menor = mayor probabilidad. Puedes usar decimales (ej: 1.5, 2.3). Peso 1 = máxima probabilidad.")
    description:SetTextColor(0.8, 0.8, 0.8)

    local yOffset = -60
    local controls = {}

    -- Crear tabla ordenada alfabéticamente por clase
    local sortedClasses = {}
    for className, classData in pairs(classSpecData) do
        table.insert(sortedClasses, { name = className, data = classData })
    end
    table.sort(sortedClasses, function(a, b) return a.name < b.name end)

    -- Crear controles agrupados por clase (ordenadas alfabéticamente)
    for _, classInfo in ipairs(sortedClasses) do
        local className = classInfo.name
        local classData = classInfo.data

        -- Checkbox para habilitar/deshabilitar clase completa
        local classCheckbox = CreateFrame("CheckButton", nil, content, "InterfaceOptionsCheckButtonTemplate")
        classCheckbox:SetPoint("TOPLEFT", 10, yOffset + 2)

        local classEnabled = ProdigyUtils.db.randomCombination.classEnabled[className]
        classCheckbox:SetChecked(classEnabled)

        -- Título de clase con color (reposicionado)
        local classTitle = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        classTitle:SetPoint("LEFT", classCheckbox, "RIGHT", 5, 0)
        local classColor = classColors[className] or "|cffffffff"
        classTitle:SetText(classColor .. className .. "|r")
        classTitle:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")

        -- Dropdown personalizado de facción (reposicionado)
        local classFactionDropdown = CreateCustomDropdown(content, 150, 520, yOffset)

        -- Configurar opciones del dropdown
        local factionOptions = {
            { value = "both",     text = "Ambas facciones" },
            { value = "alliance", text = "Solo Alianza" },
            { value = "horde",    text = "Solo Horda" }
        }
        classFactionDropdown:SetOptions(factionOptions)

        -- Establecer valor actual
        local currentClassFaction = ProdigyUtils.db.randomCombination.classFactions[className] or "both"
        classFactionDropdown:SetValue(currentClassFaction)

        -- Callback para cambios de facción
        classFactionDropdown:SetCallback(function(value, text)
            ProdigyUtils:Debug("Cambiando facción de " .. className .. " a " .. value)
            pendingChanges["class_" .. className] = pendingChanges["class_" .. className] or {}
            pendingChanges["class_" .. className].faction = value
            hasUnsavedChanges = true
        end)

        -- Callback para checkbox de clase (solo afecta generación y opacidad visual)
        classCheckbox:SetScript("OnClick", function(self)
            local enabled = self:GetChecked()

            -- Guardar cambio pendiente
            pendingChanges["class_" .. className] = pendingChanges["class_" .. className] or {}
            pendingChanges["class_" .. className].enabled = enabled
            hasUnsavedChanges = true

            -- Ajustar opacidad de la clase
            SetClassOpacity(className, enabled, controls)
        end)

        -- Guardar referencias
        controls["classEnabled_" .. className] = {
            checkbox = classCheckbox,
            originalEnabled = classEnabled
        }

        controls["classFaction_" .. className] = {
            dropdown = classFactionDropdown,
            originalFaction = currentClassFaction
        }

        yOffset = yOffset - 25

        -- Línea separadora visual
        local separator = content:CreateTexture(nil, "ARTWORK")
        separator:SetPoint("TOPLEFT", 10, yOffset + 5)
        separator:SetSize(820, 1)
        separator:SetColorTexture(0.3, 0.3, 0.3, 0.8)

        yOffset = yOffset - 10

        -- Crear controles para cada especialización de esta clase
        for _, spec in ipairs(classData.specs) do
            local specKey = className .. "_" .. spec.name
            local specConfig = ProdigyUtils.db.randomCombination.specs[specKey]

            -- Guardar valores originales
            controls[specKey] = {
                class = className, -- NUEVO: Asociar los controles a la clase
                originalEnabled = specConfig.enabled,
                originalWeight = specConfig.weight
            }

            -- Icono de especialización
            local specIcon = content:CreateTexture(nil, "ARTWORK")
            specIcon:SetSize(24, 24)
            specIcon:SetPoint("TOPLEFT", 30, yOffset + 12)
            specIcon:SetTexture(spec.icon)
            controls[specKey].specIcon = specIcon

            -- Checkbox de habilitado (reposicionado)
            local enabledCheckbox = CreateFrame("CheckButton", nil, content, "InterfaceOptionsCheckButtonTemplate")
            enabledCheckbox:SetPoint("LEFT", specIcon, "RIGHT", 5, 0)
            enabledCheckbox:SetChecked(specConfig.enabled)
            enabledCheckbox:SetScript("OnClick", function(self)
                pendingChanges[specKey] = pendingChanges[specKey] or {}
                pendingChanges[specKey].enabled = self:GetChecked()
                hasUnsavedChanges = true
            end)
            controls[specKey].enabledCheckbox = enabledCheckbox

            -- Nombre de especialización (reposicionado)
            local specText = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            specText:SetPoint("LEFT", enabledCheckbox, "RIGHT", 5, 0)
            specText:SetText(spec.name)
            specText:SetWidth(180)
            specText:SetJustifyH("LEFT")
            controls[specKey].specText = specText

            -- Campo de entrada para peso
            local weightEditBox = CreateFrame("EditBox", nil, content, "InputBoxTemplate")
            weightEditBox:SetPoint("LEFT", specText, "RIGHT", 20, 0)
            weightEditBox:SetSize(80, 25)
            weightEditBox:SetText(tostring(specConfig.weight))
            weightEditBox:SetAutoFocus(false)
            weightEditBox:SetNumeric(false)
            weightEditBox:SetMaxLetters(6)
            controls[specKey].weightEditBox = weightEditBox

            -- Etiqueta "Peso:"
            local weightLabel = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            weightLabel:SetPoint("RIGHT", weightEditBox, "LEFT", -5, 0)
            weightLabel:SetText("Peso:")
            controls[specKey].weightLabel = weightLabel

            -- Texto de ayuda
            local helpText = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            helpText:SetPoint("LEFT", weightEditBox, "RIGHT", 10, 0)
            helpText:SetText("(menor = más probable)")
            helpText:SetTextColor(0.7, 0.7, 0.7)
            controls[specKey].helpText = helpText

            yOffset = yOffset - 35
        end

        -- Ajustar opacidad inicial de la clase
        SetClassOpacity(className, classEnabled, controls)

        -- Espacio extra entre clases
        yOffset = yOffset - 15
    end

    -- Función para guardar cambios
    local function SaveChanges()
        for key, changes in pairs(pendingChanges) do
            if key:match("^class_") then
                -- Guardar configuración de clase
                local className = key:gsub("^class_", "")
                if changes.faction then
                    ProdigyUtils.db.randomCombination.classFactions[className] = changes.faction
                    ProdigyUtils:Debug("Guardando facción para " .. className .. ": " .. changes.faction)
                end
                if changes.enabled ~= nil then
                    ProdigyUtils.db.randomCombination.classEnabled[className] = changes.enabled
                    ProdigyUtils:Debug("Guardando estado de clase " .. className .. ": " .. tostring(changes.enabled))
                end
            else
                -- Guardar configuración de especialización
                local specConfig = ProdigyUtils.db.randomCombination.specs[key]
                if specConfig then
                    if changes.enabled ~= nil then
                        specConfig.enabled = changes.enabled
                        controls[key].originalEnabled = changes.enabled
                    end
                    if changes.weight ~= nil then
                        specConfig.weight = changes.weight
                        controls[key].originalWeight = changes.weight
                    end
                end
            end
        end
        pendingChanges = {}
        hasUnsavedChanges = false
        print("|cff00ff00[Prodigy]|r Configuración de pesos guardada correctamente")

        configFrame:Hide()
    end

    -- Función para restablecer a peso 1
    local function ResetWeights()
        for specKey, control in pairs(controls) do
            if control.weightEditBox then
                control.weightEditBox:SetText("1")
                pendingChanges[specKey] = pendingChanges[specKey] or {}
                pendingChanges[specKey].weight = 1
                hasUnsavedChanges = true
            end
        end
        print("|cffff8000[Prodigy]|r Todos los pesos restablecidos a 1 (pendiente de guardar)")
    end

    -- Función para cerrar con confirmación
    local function CloseWithConfirmation()
        if hasUnsavedChanges then
            StaticPopup_Show("PRODIGY_CONFIRM_CLOSE")
        else
            configFrame:Hide()
        end
    end

    -- Crear popup de confirmación
    StaticPopupDialogs["PRODIGY_CONFIRM_CLOSE"] = {
        text = "Tienes cambios sin guardar. ¿Quieres salir sin guardar?",
        button1 = "Salir sin guardar",
        button2 = "Cancelar",
        OnAccept = function()
            -- Restaurar valores originales
            for key, control in pairs(controls) do
                if key:match("^classFaction_") and control.dropdown and control.originalFaction then
                    control.dropdown:SetValue(control.originalFaction)
                elseif key:match("^classEnabled_") and control.checkbox then
                    control.checkbox:SetChecked(control.originalEnabled)
                end
            end
            pendingChanges = {}
            hasUnsavedChanges = false
            configFrame:Hide()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }

    -- Botones de acción
    local buttonY = 15

    -- Botón Guardar
    local saveButton = CreateFrame("Button", nil, configFrame, "UIPanelButtonTemplate")
    saveButton:SetSize(100, 25)
    saveButton:SetPoint("BOTTOMLEFT", configFrame, "BOTTOMLEFT", 20, buttonY)
    saveButton:SetText("Guardar")
    saveButton:SetScript("OnClick", function()
        SaveChanges()
    end)

    -- Botón Restablecer
    local resetButton = CreateFrame("Button", nil, configFrame, "UIPanelButtonTemplate")
    resetButton:SetSize(100, 25)
    resetButton:SetPoint("LEFT", saveButton, "RIGHT", 10, 0)
    resetButton:SetText("Restablecer")
    resetButton:SetScript("OnClick", function()
        ResetWeights()
    end)

    -- Botón Cerrar
    local closeButton = CreateFrame("Button", nil, configFrame, "UIPanelButtonTemplate")
    closeButton:SetSize(100, 25)
    closeButton:SetPoint("BOTTOMRIGHT", configFrame, "BOTTOMRIGHT", -20, buttonY)
    closeButton:SetText("Cerrar")
    closeButton:SetScript("OnClick", function()
        CloseWithConfirmation()
    end)

    -- Sobrescribir el botón X de la ventana
    configFrame.CloseButton:SetScript("OnClick", function()
        CloseWithConfirmation()
    end)

    -- Indicador de cambios pendientes
    local statusText = configFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    statusText:SetPoint("BOTTOM", configFrame, "BOTTOM", 0, 25)
    statusText:SetText("")

    -- Actualizar indicador cada frame
    local function UpdateStatus()
        if hasUnsavedChanges then
            statusText:SetText("|cffff8000Hay cambios sin guardar|r")
        else
            statusText:SetText("|cff00ff00Todos los cambios guardados|r")
        end
    end

    local ticker = C_Timer.NewTicker(0.5, UpdateStatus)
    configFrame:SetScript("OnHide", function()
        if ticker then
            ticker:Cancel()
        end
    end)

    UpdateStatus()
    configFrame:Show()
end

-- Función para mostrar ventana de prueba
function RandomCombinationGenerator.ShowTestWindow()
    if RandomCombinationGenerator.testFrame and RandomCombinationGenerator.testFrame:IsShown() then
        RandomCombinationGenerator.testFrame:Hide()
        return
    end

    local testFrame = CreateFrame("Frame", "ProdigyTestFrame", UIParent, "BasicFrameTemplateWithInset")
    testFrame:SetSize(400, 300)
    testFrame:SetPoint("CENTER")

    -- Usar sistema de estratos para ventana de prueba
    local strata, level = ProdigyUtils.FrameStrataManager:GetPopupStrata()
    testFrame:SetFrameStrata(strata)
    testFrame:SetFrameLevel(level)

    testFrame:SetMovable(true)
    testFrame:EnableMouse(true)
    testFrame:RegisterForDrag("LeftButton")
    testFrame:SetScript("OnDragStart", testFrame.StartMoving)
    testFrame:SetScript("OnDragStop", testFrame.StopMovingOrSizing)
    testFrame.TitleText:SetText("Prueba de Probabilidades")

    -- Script para mantenerse al frente al mostrarse
    testFrame:SetScript("OnShow", function(self)
        if ProdigyUtils.db.alwaysOnTop ~= false then
            ProdigyUtils.FrameStrataManager:BringToFront(self)
        end
    end)

    RandomCombinationGenerator.testFrame = testFrame

    -- Área de scroll para resultados
    local scrollFrame = CreateFrame("ScrollFrame", nil, testFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", testFrame, "TOPLEFT", 15, -30)
    scrollFrame:SetPoint("BOTTOMRIGHT", testFrame, "BOTTOMRIGHT", -35, 50)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(350, 1000)
    scrollFrame:SetScrollChild(content)

    -- Título
    local title = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", 0, -10)
    title:SetText("Prueba de Probabilidades (1000 generaciones)")

    -- Texto de resultados
    local resultsText = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    resultsText:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -20)
    resultsText:SetWidth(330)
    resultsText:SetJustifyH("LEFT")
    resultsText:SetText("Presiona 'Ejecutar Prueba' para comenzar...")

    -- Botón de prueba
    local testButton = CreateFrame("Button", nil, testFrame, "UIPanelButtonTemplate")
    testButton:SetSize(120, 25)
    testButton:SetPoint("BOTTOM", testFrame, "BOTTOM", 0, 15)
    testButton:SetText("Ejecutar Prueba")
    testButton:SetScript("OnClick", function()
        testButton:SetText("Ejecutando...")
        testButton:Disable()

        -- Ejecutar prueba después de un pequeño delay para que se vea el cambio
        C_Timer.After(0.1, function()
            local results = {}
            local totalTests = 1000

            for i = 1, totalTests do
                local result = GenerateRandomCombination()
                if result then
                    local key = result.class .. " - " .. result.spec
                    results[key] = (results[key] or 0) + 1
                end
            end

            -- Ordenar resultados por frecuencia
            local sortedResults = {}
            for key, count in pairs(results) do
                table.insert(sortedResults, { key = key, count = count })
            end
            table.sort(sortedResults, function(a, b) return a.count > b.count end)

            -- Formatear texto de resultados
            local resultText = "Resultados de " .. totalTests .. " generaciones:\n\n"
            for _, data in ipairs(sortedResults) do
                local percentage = (data.count / totalTests) * 100
                resultText = resultText .. string.format("%s: %d (%.1f%%)\n", data.key, data.count, percentage)
            end

            resultsText:SetText(resultText)
            testButton:SetText("Ejecutar Prueba")
            testButton:Enable()
        end)
    end)

    testFrame:Show()
end

-- Función para mostrar la ventana de resumen (ventana modal, siempre en primer plano)
function RandomCombinationGenerator.ShowSummaryWindow()
    if RandomCombinationGenerator.summaryFrame and RandomCombinationGenerator.summaryFrame:IsShown() then
        RandomCombinationGenerator.summaryFrame:Hide()
        return
    end

    -- Crear la ventana como hija de UIParent y llevarla al frente con FrameStrataManager
    local summaryFrame = CreateFrame("Frame", "ProdigySummaryFrame", UIParent, "BasicFrameTemplateWithInset")
    summaryFrame:SetSize(520, 400)
    summaryFrame:SetPoint("CENTER")

    -- USAR EL SISTEMA DE ESTRATOS DEL ADDON PARA QUE SIEMPRE QUEDE ENCIMA
    if ProdigyUtils.FrameStrataManager and ProdigyUtils.FrameStrataManager.BringToFront then
        ProdigyUtils.FrameStrataManager:BringToFront(summaryFrame)
    else
        summaryFrame:SetFrameStrata("TOOLTIP")
        summaryFrame:SetFrameLevel(99)
    end

    summaryFrame:SetMovable(true)
    summaryFrame:EnableMouse(true)
    summaryFrame:RegisterForDrag("LeftButton")
    summaryFrame:SetScript("OnDragStart", summaryFrame.StartMoving)
    summaryFrame:SetScript("OnDragStop", summaryFrame.StopMovingOrSizing)

    summaryFrame.title = summaryFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    summaryFrame.title:SetPoint("TOP", 0, -8)
    summaryFrame.title:SetText("Resumen de Pesos por Especialización")

    -- Botón de cerrar
    local closeButton = CreateFrame("Button", nil, summaryFrame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", summaryFrame, "TOPRIGHT", -2, -2)

    -- Scroll para el contenido
    local scrollFrame = CreateFrame("ScrollFrame", nil, summaryFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 15, -35)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 15)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(480, 800)
    scrollFrame:SetScrollChild(content)

    -- Mostrar TODAS las especializaciones, agrupadas por peso
    local groupedByWeight = {}
    for class, classData in pairs(classSpecData) do
        for _, spec in ipairs(classData.specs) do
            local key = class .. "_" .. spec.name
            local config = ProdigyUtils.db.randomCombination.specs and ProdigyUtils.db.randomCombination.specs[key]
            local weight = (config and tonumber(config.weight)) or 1
            if not groupedByWeight[weight] then groupedByWeight[weight] = {} end
            table.insert(groupedByWeight[weight], {
                class = class,
                classColor = classColors and classColors[class] or "|cffffffff",
                specName = spec.name,
                icon = spec.icon
            })
        end
    end

    -- Ordenar pesos de menor a mayor
    local weights = {}
    for w in pairs(groupedByWeight) do table.insert(weights, w) end
    table.sort(weights, function(a, b) return a < b end)

    -- Mostrar en el frame
    local yOffset = -10
    for _, weight in ipairs(weights) do
        local specs = groupedByWeight[weight]
        -- Título de grupo de peso
        local groupTitle = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        groupTitle:SetPoint("TOPLEFT", 10, yOffset)
        groupTitle:SetText(string.format("Peso %s:", tostring(weight)))
        yOffset = yOffset - 22

        for _, entry in ipairs(specs) do
            -- Icono (usando el campo correcto)
            local icon = content:CreateTexture(nil, "ARTWORK")
            icon:SetSize(24, 24)
            icon:SetPoint("TOPLEFT", 25, yOffset)
            icon:SetTexture(entry.icon or 134400)

            -- Clase (con color)
            local classNameText = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            classNameText:SetPoint("LEFT", icon, "RIGHT", 8, 0)
            classNameText:SetText(entry.classColor .. entry.class .. "|r")

            -- Especialización
            local specText = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            specText:SetPoint("LEFT", classNameText, "RIGHT", 12, 0)
            specText:SetText("- " .. entry.specName)

            yOffset = yOffset - 28
        end
        yOffset = yOffset - 10
    end

    RandomCombinationGenerator.summaryFrame = summaryFrame
    summaryFrame:Show()
end

-- Inicializar configuración por defecto al cargar el módulo
InitializeDefaultSettings()

-- Registrar el módulo
ProdigyUtils:RegisterModule("randomCombination", {
    displayName = "Combinaciones",
    createTabContent = RandomCombinationGenerator.createTabContent
})
