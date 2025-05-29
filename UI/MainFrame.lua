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
    
    -- MODIFICADO: Usar el sistema de estratos
    local strata, level = ProdigyUtils.FrameStrataManager:GetMainWindowStrata()
    mainFrame:SetFrameStrata(strata)
    mainFrame:SetFrameLevel(level)
    
    -- Hacer redimensionable (método correcto)
    mainFrame:SetResizable(true)
    mainFrame:SetResizeBounds(400, 300, 1200, 800)
    
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
    
    -- Aplicar opacidad guardada
    mainFrame:SetAlpha(self.db.windowOpacity)
    
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
    
    -- MODIFICADO: Asegurar que siempre esté al frente cuando se muestre
    mainFrame:SetScript("OnShow", function(self)
        if ProdigyUtils.db.alwaysOnTop ~= false then
            ProdigyUtils.FrameStrataManager:BringToFront(self)
        else
            self:Raise()
        end
    end)
    
    self.mainFrame = mainFrame
    
    -- Inicializar sistema de pestañas
    self:InitializeTabs()
    
    ProdigyUtils:Debug("Ventana principal inicializada con estrato " .. strata)
end

-- Resto de las funciones sin cambios...
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

function ProdigyUtils:CreateConfigTab()
    local frame = CreateFrame("ScrollFrame", nil, nil, "UIPanelScrollFrameTemplate")
    frame.content = CreateFrame("Frame", nil, frame)
    frame:SetScrollChild(frame.content)
    frame.content:SetSize(550, 600)
    
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
    
    -- MODIFICADO: Checkbox para mantener siempre al frente
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
    
    -- Slider para opacidad de la ventana
    local opacitySlider = CreateFrame("Slider", nil, frame.content, "OptionsSliderTemplate")
    opacitySlider:SetPoint("TOPLEFT", alwaysOnTopCheckbox, "BOTTOMLEFT", 0, -30)
    opacitySlider:SetMinMaxValues(0.3, 1.0)
    opacitySlider:SetValue(ProdigyUtils.db.windowOpacity or 1.0)
    opacitySlider:SetValueStep(0.1)
    opacitySlider:SetObeyStepOnDrag(true)
    opacitySlider.textLow = opacitySlider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    opacitySlider.textHigh = opacitySlider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    opacitySlider.textLow:SetPoint("TOPLEFT", opacitySlider, "BOTTOMLEFT", 2, 3)
    opacitySlider.textHigh:SetPoint("TOPRIGHT", opacitySlider, "BOTTOMRIGHT", -2, 3)
    opacitySlider.textLow:SetText("30%")
    opacitySlider.textHigh:SetText("100%")
    
    local opacityTitle = frame.content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    opacityTitle:SetPoint("BOTTOMLEFT", opacitySlider, "TOPLEFT", 0, 0)
    opacityTitle:SetText("Opacidad de la ventana: " .. math.floor((ProdigyUtils.db.windowOpacity or 1.0) * 100) .. "%")
    
    opacitySlider:SetScript("OnValueChanged", function(self, value)
        ProdigyUtils.db.windowOpacity = value
        ProdigyUtils.mainFrame:SetAlpha(value)
        opacityTitle:SetText("Opacidad de la ventana: " .. math.floor(value * 100) .. "%")
    end)
    
    -- Función llamada cuando se activa la pestaña
    function frame:OnTabActivated()
        debugCheckbox:SetChecked(ProdigyUtils.db.showDebug or false)
        alwaysOnTopCheckbox:SetChecked(ProdigyUtils.db.alwaysOnTop ~= false)
        local opacity = ProdigyUtils.db.windowOpacity or 1.0
        opacitySlider:SetValue(opacity)
        ProdigyUtils.mainFrame:SetAlpha(opacity)
    end
    
    return frame
end