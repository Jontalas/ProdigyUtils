ProdigyUtils.TabSystem = {}

local TabSystem = ProdigyUtils.TabSystem
TabSystem.tabs = {}
TabSystem.activeTab = nil

-- Crear una nueva pestaña
function TabSystem:CreateTab(name, displayName, contentFrame)
    local tabButton = CreateFrame("Button", nil, ProdigyUtils.mainFrame, "UIPanelButtonTemplate")
    tabButton:SetSize(120, 25)
    tabButton:SetText(displayName)
    
    -- Posicionar pestaña
    local numTabs = #self.tabs
    if numTabs == 0 then
        tabButton:SetPoint("TOPLEFT", ProdigyUtils.mainFrame, "TOPLEFT", 10, -30)
    else
        tabButton:SetPoint("LEFT", self.tabs[numTabs].button, "RIGHT", 5, 0)
    end
    
    -- Crear el contenedor del contenido
    local container = CreateFrame("Frame", nil, ProdigyUtils.mainFrame)
    container:SetPoint("TOPLEFT", ProdigyUtils.mainFrame, "TOPLEFT", 10, -60)
    container:SetPoint("BOTTOMRIGHT", ProdigyUtils.mainFrame, "BOTTOMRIGHT", -10, 10)
    container:Hide()
    
    -- Si se proporciona un frame de contenido, lo añadimos al contenedor
    if contentFrame then
        contentFrame:SetParent(container)
        contentFrame:SetAllPoints(container)
    end
    
    local tab = {
        name = name,
        displayName = displayName,
        button = tabButton,
        container = container,
        contentFrame = contentFrame
    }
    
    -- Script del botón
    tabButton:SetScript("OnClick", function()
        self:SwitchToTab(name)
    end)
    
    table.insert(self.tabs, tab)
    
    -- Si es la primera pestaña, activarla
    if #self.tabs == 1 then
        self:SwitchToTab(name)
    end
    
    return tab
end

-- Cambiar a una pestaña específica
function TabSystem:SwitchToTab(tabName)
    for _, tab in ipairs(self.tabs) do
        if tab.name == tabName then
            -- Activar pestaña
            tab.container:Show()
            tab.button:SetEnabled(false) -- Deshabilitar botón activo
            self.activeTab = tab
            
            -- Ejecutar callback de activación si existe
            if tab.contentFrame and tab.contentFrame.OnTabActivated then
                tab.contentFrame:OnTabActivated()
            end
        else
            -- Desactivar otras pestañas
            tab.container:Hide()
            tab.button:SetEnabled(true)
        end
    end
end

-- Obtener pestaña activa
function TabSystem:GetActiveTab()
    return self.activeTab
end

-- Obtener pestaña por nombre
function TabSystem:GetTab(tabName)
    for _, tab in ipairs(self.tabs) do
        if tab.name == tabName then
            return tab
        end
    end
    return nil
end