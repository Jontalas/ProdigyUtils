-- Sistema de gestión de estratos para ventanas de ProdigyUtils
local FrameStrataManager = {}

-- Estratos disponibles en orden ascendente
local AVAILABLE_STRATAS = {
    "BACKGROUND",
    "LOW", 
    "MEDIUM",
    "HIGH",
    "DIALOG",
    "FULLSCREEN",
    "FULLSCREEN_DIALOG",
    "TOOLTIP"
}

-- Niveles dentro de cada estrato
local FRAME_LEVELS = {
    BASE = 100,
    DIALOG = 200,
    POPUP = 300,
    TOOLTIP = 400
}

-- Variables de control
local currentStrataIndex = 8  -- Empezar en TOOLTIP (el más alto)
local currentLevel = FRAME_LEVELS.BASE

-- Función para obtener el próximo estrato superior
function FrameStrataManager:GetNextStrata()
    local strata = AVAILABLE_STRATAS[currentStrataIndex]
    currentLevel = currentLevel + 50
    
    -- Si el nivel se vuelve muy alto, subir al siguiente estrato si es posible
    if currentLevel > 900 and currentStrataIndex < #AVAILABLE_STRATAS then
        currentStrataIndex = currentStrataIndex + 1
        currentLevel = FRAME_LEVELS.BASE
        strata = AVAILABLE_STRATAS[currentStrataIndex]
    end
    
    return strata, currentLevel
end

-- Función para obtener estrato base para ventana principal
function FrameStrataManager:GetMainWindowStrata()
    return "TOOLTIP", FRAME_LEVELS.BASE
end

-- Función para obtener estrato para ventanas de diálogo
function FrameStrataManager:GetDialogStrata()
    return self:GetNextStrata()
end

-- Función para obtener estrato para popups/tooltips
function FrameStrataManager:GetPopupStrata()
    return self:GetNextStrata()
end

-- Función para forzar una ventana al frente
function FrameStrataManager:BringToFront(frame)
    local strata, level = self:GetNextStrata()
    frame:SetFrameStrata(strata)
    frame:SetFrameLevel(level)
    frame:Raise()
    
    ProdigyUtils:Debug("Ventana movida al frente: " .. strata .. " nivel " .. level)
end

-- Hacer disponible globalmente
ProdigyUtils.FrameStrataManager = FrameStrataManager