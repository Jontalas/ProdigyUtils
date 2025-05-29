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

-- MEJORADO: Variables de control con límites y reset automático
local currentStrataIndex = 8  -- Empezar en TOOLTIP (el más alto)
local currentLevel = FRAME_LEVELS.BASE
local MAX_FRAME_LEVEL = 800  -- Límite antes de resetear

-- MEJORADO: Sistema de reset cuando se alcanzan niveles muy altos
local function resetFrameLevels()
    currentLevel = FRAME_LEVELS.BASE
    ProdigyUtils:Debug("FrameStrataManager: Niveles reseteados para optimizar memoria")
end

-- Función para obtener el próximo estrato superior
function FrameStrataManager:GetNextStrata()
    local strata = AVAILABLE_STRATAS[currentStrataIndex]
    currentLevel = currentLevel + 50
    
    -- MEJORADO: Reset automático para prevenir niveles excesivos
    if currentLevel > MAX_FRAME_LEVEL then
        if currentStrataIndex < #AVAILABLE_STRATAS then
            currentStrataIndex = currentStrataIndex + 1
            currentLevel = FRAME_LEVELS.BASE
            strata = AVAILABLE_STRATAS[currentStrataIndex]
        else
            -- Si llegamos al estrato más alto, resetear todo
            currentStrataIndex = 8  -- Volver a TOOLTIP
            resetFrameLevels()
            strata = AVAILABLE_STRATAS[currentStrataIndex]
        end
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

-- MEJORADO: Función optimizada para forzar una ventana al frente
function FrameStrataManager:BringToFront(frame)
    if not frame then return end
    
    local strata, level = self:GetNextStrata()
    frame:SetFrameStrata(strata)
    frame:SetFrameLevel(level)
    frame:Raise()
    
    ProdigyUtils:Debug("Ventana movida al frente: " .. strata .. " nivel " .. level)
end

-- NUEVO: Función para obtener estadísticas del manager
function FrameStrataManager:GetStats()
    return {
        currentStrata = AVAILABLE_STRATAS[currentStrataIndex],
        currentLevel = currentLevel,
        strataIndex = currentStrataIndex
    }
end

-- Hacer disponible globalmente
ProdigyUtils.FrameStrataManager = FrameStrataManager