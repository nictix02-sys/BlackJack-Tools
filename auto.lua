-- Bibliothèque Auto-Clicker pour Roblox
-- Compatible avec tous les executeurs Roblox

local AutoClicker = {}
AutoClicker.__index = AutoClicker

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
    self.connection = nil
    
    return self
end

-- Effectuer un clic selon le bouton
function AutoClicker:performClick(button)
    button = button or self.button
    
    if button == "left" then
        mouse1click()
    elseif button == "right" then
        mouse2click()
    elseif button == "middle" then
        -- Le clic du milieu n'est pas directement supporté sur Roblox
        -- On utilise mouse1click par défaut
        mouse1click()
    else
        warn("Bouton invalide: " .. tostring(button))
        return
    end
    
    self.click_count = self.click_count + 1
end

-- Effectuer plusieurs clics
function AutoClicker:performMultipleClicks(count)
    count = count or self.clicks
    for i = 1, count do
        self:performClick()
        if i < count then
            task.wait(0.05) -- 50ms entre chaque clic multiple
        end
    end
end

-- Démarrer l'auto-clicker
function AutoClicker:start()
    if self.running then
        warn("Auto-clicker déjà en cours d'exécution")
        return
    end
    
    self.running = true
    self.click_count = 0
    
    print(string.format("[AutoClicker] Démarré - Intervalle: %dms, Bouton: %s", 
          self.interval, self.button))
    
    -- Créer une coroutine pour les clics
    task.spawn(function()
        while self.running do
            if self.max_clicks and self.click_count >= self.max_clicks then
                self:stop()
                break
            end
            
            self:performMultipleClicks()
            task.wait(self.interval / 1000) -- Convertir ms en secondes
        end
    end)
end

-- Arrêter l'auto-clicker
function AutoClicker:stop()
    if not self.running then
        return
    end
    
    self.running = false
    print(string.format("[AutoClicker] Arrêté - Total de clics: %d", self.click_count))
end

-- Basculer l'état (toggle)
function AutoClicker:toggle()
    if self.running then
        self:stop()
    else
        self:start()
    end
end

-- Modifier l'intervalle (en millisecondes)
function AutoClicker:setInterval(interval)
    if interval and interval > 0 then
        self.interval = interval
        print(string.format("[AutoClicker] Intervalle changé: %dms", interval))
    else
        warn("Intervalle invalide: " .. tostring(interval))
    end
end

-- Modifier le bouton
function AutoClicker:setButton(button)
    if button == "left" or button == "right" or button == "middle" then
        self.button = button
        print(string.format("[AutoClicker] Bouton changé: %s", button))
    else
        warn("Bouton invalide: " .. tostring(button))
    end
end

-- Modifier le nombre de clics par action
function AutoClicker:setClicks(clicks)
    if clicks and clicks > 0 then
        self.clicks = clicks
        print(string.format("[AutoClicker] Clics par action: %d", clicks))
    else
        warn("Nombre de clics invalide: " .. tostring(clicks))
    end
end

-- Définir une limite de clics
function AutoClicker:setMaxClicks(max)
    self.max_clicks = max
    if max then
        print(string.format("[AutoClicker] Limite de clics: %d", max))
    else
        print("[AutoClicker] Limite de clics: Infini")
    end
end

-- Réinitialiser le compteur
function AutoClicker:resetCount()
    self.click_count = 0
    print("[AutoClicker] Compteur réinitialisé")
end

-- Obtenir les statistiques
function AutoClicker:getStats()
    return {
        running = self.running,
        click_count = self.click_count,
        interval = self.interval,
        button = self.button,
        clicks = self.clicks,
        max_clicks = self.max_clicks
    }
end

-- Afficher les statistiques
function AutoClicker:printStats()
    local stats = self:getStats()
    print("=== AutoClicker Stats ===")
    print("Status: " .. (stats.running and "Running" or "Stopped"))
    print("Clics effectués: " .. stats.click_count)
    print("Intervalle: " .. stats.interval .. "ms")
    print("Bouton: " .. stats.button)
    print("Clics par action: " .. stats.clicks)
    print("Limite: " .. (stats.max_clicks or "Infini"))
    print("========================")
end

-- Vérifier si l'auto-clicker est en cours
function AutoClicker:isRunning()
    return self.running
end

-- Nettoyer l'auto-clicker
function AutoClicker:destroy()
    self:stop()
    self = nil
    print("[AutoClicker] Détruit")
end

return AutoClicker