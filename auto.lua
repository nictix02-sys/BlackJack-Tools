-- Bibliothèque Auto-Clicker en Lua
-- Nécessite FFI pour l'interaction avec l'OS (Windows)

local ffi = require("ffi")
local AutoClicker = {}
AutoClicker.__index = AutoClicker

-- Définitions FFI pour Windows
ffi.cdef[[
    typedef unsigned long DWORD;
    typedef void* HANDLE;
    typedef struct tagPOINT { long x; long y; } POINT;
    
    void Sleep(DWORD dwMilliseconds);
    bool GetCursorPos(POINT* lpPoint);
    bool SetCursorPos(int X, int Y);
    void mouse_event(DWORD dwFlags, DWORD dx, DWORD dy, DWORD dwData, uintptr_t dwExtraInfo);
]]

-- Constantes pour mouse_event
local MOUSEEVENTF_LEFTDOWN = 0x0002
local MOUSEEVENTF_LEFTUP = 0x0004
local MOUSEEVENTF_RIGHTDOWN = 0x0008
local MOUSEEVENTF_RIGHTUP = 0x0010
local MOUSEEVENTF_MIDDLEDOWN = 0x0020
local MOUSEEVENTF_MIDDLEUP = 0x0040

-- Créer une nouvelle instance d'AutoClicker
function AutoClicker.new(config)
    local self = setmetatable({}, AutoClicker)
    
    config = config or {}
    self.interval = config.interval or 100 -- Intervalle en millisecondes
    self.button = config.button or "left" -- "left", "right", "middle"
    self.clicks = config.clicks or 1 -- Nombre de clics par action
    self.running = false
    self.click_count = 0
    self.max_clicks = config.max_clicks or nil -- nil = infini
    
    return self
end

-- Obtenir la position actuelle du curseur
function AutoClicker:getCursorPosition()
    local point = ffi.new("POINT")
    ffi.C.GetCursorPos(point)
    return {x = point.x, y = point.y}
end

-- Définir la position du curseur
function AutoClicker:setCursorPosition(x, y)
    ffi.C.SetCursorPos(x, y)
end

-- Effectuer un clic simple
function AutoClicker:performClick(button)
    button = button or self.button
    
    local down_flag, up_flag
    
    if button == "left" then
        down_flag = MOUSEEVENTF_LEFTDOWN
        up_flag = MOUSEEVENTF_LEFTUP
    elseif button == "right" then
        down_flag = MOUSEEVENTF_RIGHTDOWN
        up_flag = MOUSEEVENTF_RIGHTUP
    elseif button == "middle" then
        down_flag = MOUSEEVENTF_MIDDLEDOWN
        up_flag = MOUSEEVENTF_MIDDLEUP
    else
        error("Bouton invalide: " .. button)
    end
    
    ffi.C.mouse_event(down_flag, 0, 0, 0, 0)
    ffi.C.Sleep(10)
    ffi.C.mouse_event(up_flag, 0, 0, 0, 0)
    
    self.click_count = self.click_count + 1
end

-- Effectuer plusieurs clics
function AutoClicker:performMultipleClicks(count)
    count = count or self.clicks
    for i = 1, count do
        self:performClick()
        if i < count then
            ffi.C.Sleep(50)
        end
    end
end

-- Cliquer à une position spécifique
function AutoClicker:clickAt(x, y, button)
    local original_pos = self:getCursorPosition()
    self:setCursorPosition(x, y)
    ffi.C.Sleep(10)
    self:performClick(button)
    ffi.C.Sleep(10)
    self:setCursorPosition(original_pos.x, original_pos.y)
end

-- Démarrer l'auto-clicker
function AutoClicker:start()
    if self.running then
        print("Auto-clicker déjà en cours d'exécution")
        return
    end
    
    self.running = true
    self.click_count = 0
    
    print(string.format("Auto-clicker démarré - Intervalle: %dms, Bouton: %s", 
          self.interval, self.button))
    
    while self.running do
        if self.max_clicks and self.click_count >= self.max_clicks then
            self:stop()
            break
        end
        
        self:performMultipleClicks()
        ffi.C.Sleep(self.interval)
    end
end

-- Arrêter l'auto-clicker
function AutoClicker:stop()
    if not self.running then
        return
    end
    
    self.running = false
    print(string.format("Auto-clicker arrêté - Total de clics: %d", self.click_count))
end

-- Modifier l'intervalle
function AutoClicker:setInterval(interval)
    self.interval = interval
end

-- Modifier le bouton
function AutoClicker:setButton(button)
    if button ~= "left" and button ~= "right" and button ~= "middle" then
        error("Bouton invalide: " .. button)
    end
    self.button = button
end

-- Obtenir les statistiques
function AutoClicker:getStats()
    return {
        running = self.running,
        click_count = self.click_count,
        interval = self.interval,
        button = self.button,
        max_clicks = self.max_clicks
    }
end

-- Exemple d'utilisation
function AutoClicker.example()
    print("=== Exemple d'utilisation de la bibliothèque Auto-Clicker ===\n")
    
    -- Créer un auto-clicker
    local clicker = AutoClicker.new({
        interval = 200,
        button = "left",
        clicks = 1,
        max_clicks = 10
    })
    
    -- Obtenir la position du curseur
    local pos = clicker:getCursorPosition()
    print(string.format("Position actuelle: x=%d, y=%d", pos.x, pos.y))
    
    -- Effectuer un clic simple
    print("\nClic simple...")
    clicker:performClick()
    
    -- Cliquer à une position spécifique
    print("\nClic à la position (100, 100)...")
    clicker:clickAt(100, 100)
    
    -- Démarrer l'auto-clicker (limité à 10 clics)
    print("\nDémarrage de l'auto-clicker (10 clics max)...")
    clicker:start()
    
    -- Afficher les statistiques
    local stats = clicker:getStats()
    print(string.format("\nStatistiques finales: %d clics effectués", stats.click_count))
end

return AutoClicker