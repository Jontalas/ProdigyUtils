-- Namespace del addon
ProdigyUtils = {}
ProdigyUtils.modules = {}
ProdigyUtils.db = {}

-- Configuración por defecto
local defaultSettings = {
    mainWindow = {
        point = "CENTER",
        x = 0,
        y = 0,
        width = 600,
        height = 400,
        shown = false
    },
    modules = {},
    showDebug = false,
    alwaysOnTop = true
}

-- Frame principal para eventos
local eventFrame = CreateFrame("Frame")

-- MEJORADO: Función recursiva optimizada para merge de configuración
local function deepMergeConfig(target, source)
    for key, value in pairs(source) do
        if target[key] == nil then
            if type(value) == "table" then
                target[key] = {}
                deepMergeConfig(target[key], value)
            else
                target[key] = value
            end
        elseif type(value) == "table" and type(target[key]) == "table" then
            deepMergeConfig(target[key], value)
        end
    end
end

local function OnAddonLoaded(self, event, addonName)
    if addonName == "ProdigyUtils" then
        -- MEJORADO: Inicializar base de datos con merge optimizado
        ProdigyUtilsDB = ProdigyUtilsDB or {}
        
        -- Merge configuración por defecto con guardada (más eficiente)
        deepMergeConfig(ProdigyUtilsDB, defaultSettings)
        
        ProdigyUtils.db = ProdigyUtilsDB
        
        -- Inicializar UI
        ProdigyUtils:InitializeUI()
        
        -- Registrar comando slash
        SLASH_PRODIGYUTILS1 = "/prodigy"
        SLASH_PRODIGYUTILS2 = "/putils"
        SlashCmdList["PRODIGYUTILS"] = function(msg)
            local command = string.lower(string.trim(msg or ""))
            
            if command == "" or command == "show" then
                ProdigyUtils:ToggleMainWindow()
            elseif command == "config" then
                ProdigyUtils:ToggleMainWindow()
                ProdigyUtils.TabSystem:SwitchToTab("config")
            elseif command == "help" then
                ProdigyUtils:ShowHelp()
            else
                print("|cffff0000Comando no reconocido:|r " .. command)
                ProdigyUtils:ShowHelp()
            end
        end
        
        print("|cff00ff00Prodigy Utils v1.0.0|r cargado para WoW 11.1.5")
        print("Usa |cff00ffff/prodigy|r para abrir o |cff00ffff/prodigy help|r para ayuda")
    end
end

local function OnPlayerLogout()
    -- Guardar posición y estado de la ventana
    if ProdigyUtils.mainFrame then
        local point, _, _, x, y = ProdigyUtils.mainFrame:GetPoint()
        ProdigyUtils.db.mainWindow.point = point
        ProdigyUtils.db.mainWindow.x = x
        ProdigyUtils.db.mainWindow.y = y
        ProdigyUtils.db.mainWindow.shown = ProdigyUtils.mainFrame:IsShown()
        
        -- Guardar tamaño si es redimensionable
        ProdigyUtils.db.mainWindow.width = ProdigyUtils.mainFrame:GetWidth()
        ProdigyUtils.db.mainWindow.height = ProdigyUtils.mainFrame:GetHeight()
    end
end

-- Función para registrar módulos
function ProdigyUtils:RegisterModule(name, moduleData)
    if self.modules[name] then
        print("|cffff8000Advertencia:|r Módulo '" .. name .. "' ya existe, sobrescribiendo")
    end
    
    self.modules[name] = moduleData
    
    if self.db.showDebug then
        print("|cff00ff00Debug:|r Módulo registrado: " .. name)
    end
end

-- Toggle ventana principal
function ProdigyUtils:ToggleMainWindow()
    if self.mainFrame then
        if self.mainFrame:IsShown() then
            self.mainFrame:Hide()
        else
            self.mainFrame:Show()
        end
    end
end

-- Mostrar ayuda
function ProdigyUtils:ShowHelp()
    print("|cff00ff00=== Prodigy Utils - Comandos ===|r")
    print("|cff00ffff/prodigy|r o |cff00ffff/putils|r - Abrir/cerrar ventana principal")
    print("|cff00ffff/prodigy config|r - Abrir directamente en configuración")
    print("|cff00ffff/prodigy help|r - Mostrar esta ayuda")
end

-- Función de debug
function ProdigyUtils:Debug(message)
    if self.db.showDebug then
        print("|cff888888[Prodigy Debug]|r " .. tostring(message))
    end
end

-- Registrar eventos
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGOUT")
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        OnAddonLoaded(self, event, ...)
    elseif event == "PLAYER_LOGOUT" then
        OnPlayerLogout()
    end
end)