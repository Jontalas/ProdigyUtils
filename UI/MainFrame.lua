function ProdigyUtils:InitializeUI()
    -- Crear ventana principal con template moderno
    local mainFrame = CreateFrame("Frame", "ProdigyUtilsMainFrame", UIParent, "BasicFrameTemplateWithInset")
    mainFrame:SetSize(self.db.mainWindow.width, self.db.mainWindow.height)
    mainFrame:SetMovable(true)
    mainFrame:EnableMouse(true)
    mainFrame:RegisterForDrag("LeftButton")
    mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
    mainFrame:SetScript("OnDragStop", mainFrame.StopMovingOrSizing)
    mainFrame:SetClampedToScreen(true)

    -- Usar el sistema de estratos
    local strata, level = ProdigyUtils.FrameStrataManager:GetMainWindowStrata()
    mainFrame:SetFrameStrata(strata)
    mainFrame:SetFrameLevel(level)

    -- Hacer redimensionable (método correcto)
    mainFrame:SetResizable(true)
    mainFrame:SetResizeBounds(700, 500, 1200, 800)

    -- Botón de redimensionar
    local resizeButton = CreateFrame("Button", nil, mainFrame)
    resizeButton:SetSize(16, 16)
    resizeButton:SetPoint("BOTTOMRIGHT", -6, 7)
    resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    resizeButton:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            mainFrame:StartSizing("BOTTOMRIGHT")
        end
    end)
    resizeButton:SetScript("OnMouseUp", function(self, button)
        mainFrame:StopMovingOrSizing()
    end)

    -- Título con versión
    mainFrame.TitleText:SetText("Prodigy Utils v1.0.0 (WoW 11.1.5)")

    -- Botón de cerrar personalizado
    mainFrame.CloseButton:SetScript("OnClick", function()
        mainFrame:Hide()
    end)

    -- Posicionar según configuración guardada
    local pos = self.db.mainWindow
    mainFrame:ClearAllPoints()
    mainFrame:SetPoint(pos.point, UIParent, pos.point, pos.x, pos.y)

    -- ELIMINADO: Ya no aplicamos opacidad guardada
    -- mainFrame:SetAlpha(self.db.windowOpacity)

    -- Mostrar si estaba abierta
    if pos.shown then
        mainFrame:Show()
    else
        mainFrame:Hide()
    end

    -- Tecla de escape para cerrar
    mainFrame:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then
            self:Hide()
        end
    end)
    mainFrame:SetPropagateKeyboardInput(true)

    -- Asegurar que siempre esté al frente cuando se muestre
    mainFrame:SetScript("OnShow", function(self)
        if ProdigyUtils.db.alwaysOnTop ~= false then
            ProdigyUtils.FrameStrataManager:BringToFront(self)
        else
            self:SetFrameStrata("HIGH")
            self:SetFrameLevel(100)
        end
        -- REFRESCAR TABLA DE LA PESTAÑA ACTIVA AL ABRIR VENTANA
        if ProdigyUtils.TabSystem and ProdigyUtils.TabSystem.activeTab then
            local tab = ProdigyUtils.TabSystem.activeTab
            if ProdigyUtils.modules[tab.name] and ProdigyUtils.modules[tab.name].refreshTabContent then
                ProdigyUtils.modules[tab.name].refreshTabContent(tab.container)
            end
        end
    end)


    self.mainFrame = mainFrame

    -- Inicializar sistema de pestañas
    self:InitializeTabs()

    ProdigyUtils:Debug("Ventana principal inicializada con estrato " .. strata)
end

function ProdigyUtils:InitializeTabs()
    -- PRIMERO: Cargar módulos registrados
    for name, moduleData in pairs(self.modules) do
        if moduleData.createTabContent then
            local contentFrame = moduleData.createTabContent()
            ProdigyUtils.TabSystem:CreateTab(name, moduleData.displayName or name, contentFrame)
        end
    end

    -- ÚLTIMO: Pestaña de configuración general (aparecerá al final)
    local configFrame = self:CreateConfigTab()
    ProdigyUtils.TabSystem:CreateTab("config", "Configuración", configFrame)

    ProdigyUtils:Debug("Sistema de pestañas inicializado con " .. #ProdigyUtils.TabSystem.tabs .. " pestañas")
end

-- MEJORADO: Tab de configuración SIN slider de opacidad
function ProdigyUtils:CreateConfigTab()
    local frame = CreateFrame("ScrollFrame", nil, nil, "UIPanelScrollFrameTemplate")
    frame.content = CreateFrame("Frame", nil, frame)
    frame:SetScrollChild(frame.content)
    frame.content:SetSize(550, 400) -- Reducido el tamaño ya que hay menos contenido

    -- Título de la sección
    local title = frame.content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 10, -10)
    title:SetText("Configuración General")
    title:SetTextColor(1, 0.82, 0)

    -- Checkbox para mostrar mensajes de debug
    local debugCheckbox = CreateFrame("CheckButton", nil, frame.content, "InterfaceOptionsCheckButtonTemplate")
    debugCheckbox:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -20)
    debugCheckbox.Text:SetText("Mostrar mensajes de debug")
    debugCheckbox:SetScript("OnClick", function(self)
        ProdigyUtils.db.showDebug = self:GetChecked()
        if ProdigyUtils.db.showDebug then
            print("|cff00ff00Prodigy Debug activado|r")
        else
            print("|cffff8000Prodigy Debug desactivado|r")
        end
    end)

    -- Checkbox para mantener siempre al frente
    local alwaysOnTopCheckbox = CreateFrame("CheckButton", nil, frame.content, "InterfaceOptionsCheckButtonTemplate")
    alwaysOnTopCheckbox:SetPoint("TOPLEFT", debugCheckbox, "BOTTOMLEFT", 0, -10)
    alwaysOnTopCheckbox.Text:SetText("Mantener ventanas siempre al frente")
    alwaysOnTopCheckbox:SetScript("OnClick", function(self)
        ProdigyUtils.db.alwaysOnTop = self:GetChecked()
        if ProdigyUtils.db.alwaysOnTop then
            ProdigyUtils.FrameStrataManager:BringToFront(ProdigyUtils.mainFrame)
            print("|cff00ff00Ventanas configuradas para estar siempre al frente|r")
        else
            ProdigyUtils.mainFrame:SetFrameStrata("HIGH")
            ProdigyUtils.mainFrame:SetFrameLevel(100)
            print("|cffff8000Ventanas en modo normal|r")
        end
    end)

    -- ELIMINADO COMPLETAMENTE: Slider de opacidad y toda su funcionalidad

    -- NUEVO: Información del sistema de estratos para debug
    local strataInfo = frame.content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    strataInfo:SetPoint("TOPLEFT", alwaysOnTopCheckbox, "BOTTOMLEFT", 0, -30)
    strataInfo:SetText("Sistema de Gestión de Ventanas: Activo")
    strataInfo:SetTextColor(0.7, 0.7, 0.7)

    -- Función llamada cuando se activa la pestaña
    function frame:OnTabActivated()
        debugCheckbox:SetChecked(ProdigyUtils.db.showDebug or false)
        alwaysOnTopCheckbox:SetChecked(ProdigyUtils.db.alwaysOnTop ~= false)

        -- Actualizar información del sistema de estratos
        if ProdigyUtils.db.showDebug then
            local stats = ProdigyUtils.FrameStrataManager:GetStats()
            strataInfo:SetText(string.format("Estrato actual: %s (Nivel: %d)",
                stats.currentStrata, stats.currentLevel))
        end
    end

    return frame
end
