-- ========================================
-- CHARGEMENT DES BIBLIOTHEQUES
-- ========================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Lib = loadstring(game:HttpGet('https://raw.githubusercontent.com/nictix02-sys/BlackJack-Tools/refs/heads/main/Fly.lua'))()
local Teleport = loadstring(game:HttpGet('https://raw.githubusercontent.com/nictix02-sys/BlackJack-Tools/refs/heads/main/TP.lua'))()

-- Bibliothèque AutoClicker intégrée
local AutoClicker = {}
AutoClicker.__index = AutoClicker

function AutoClicker.new(config)
    local self = setmetatable({}, AutoClicker)
    config = config or {}
    self.interval = config.interval or 100
    self.button = config.button or "left"
    self.clicks = config.clicks or 1
    self.running = false
    self.click_count = 0
    self.max_clicks = config.max_clicks or nil
    return self
end

function AutoClicker:performClick(button)
    button = button or self.button
    if button == "left" then
        mouse1click()
    elseif button == "right" then
        mouse2click()
    elseif button == "middle" then
        mouse1click()
    end
    self.click_count = self.click_count + 1
end

function AutoClicker:performMultipleClicks(count)
    count = count or self.clicks
    for i = 1, count do
        self:performClick()
        if i < count then
            task.wait(0.05)
        end
    end
end

function AutoClicker:start()
    if self.running then
        return
    end
    self.running = true
    self.click_count = 0
    task.spawn(function()
        while self.running do
            if self.max_clicks and self.click_count >= self.max_clicks then
                self:stop()
                break
            end
            self:performMultipleClicks()
            task.wait(self.interval / 1000)
        end
    end)
end

function AutoClicker:stop()
    if not self.running then
        return
    end
    self.running = false
end

function AutoClicker:setInterval(interval)
    if interval and interval > 0 then
        self.interval = interval
    end
end

function AutoClicker:setButton(button)
    if button == "left" or button == "right" or button == "middle" then
        self.button = button
    end
end

function AutoClicker:isRunning()
    return self.running
end

-- ========================================
-- CREATION DE LA FENETRE
-- ========================================
local Window = Rayfield:CreateWindow({
    Name = "Menu by Edaward_01",
    LoadingTitle = "Chargement...",
    LoadingSubtitle = "by Edaward_01",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "AncienMenu",
        FileName = "Settings"
    },
    Discord = {
        Enabled = false,
        Invite = "https://discord.gg/thcfr",
        RememberJoins = true
    },
    KeySystem = false
})

-- ========================================
-- ONGLET AUTOCLICKER
-- ========================================
local Auto = Window:CreateTab("AutoClicker", "mouse")

local clicker = AutoClicker.new({
    interval = 100,
    button = "left",
    clicks = 1,
    max_clicks = nil
})

local clickerEnabled = false

Auto:CreateToggle({
    Name = "Activer AutoClicker",
    CurrentValue = false,
    Flag = "AutoClickerToggle",
    Callback = function(Value)
        clickerEnabled = Value
        if Value then
            clicker:start()
            Rayfield:Notify({
                Title = "AutoClicker",
                Content = "AutoClicker activé",
                Duration = 2,
                Image = "check-circle",
            })
        else 
            clicker:stop()
            Rayfield:Notify({
                Title = "AutoClicker",
                Content = "AutoClicker désactivé",
                Duration = 2,
                Image = "x-circle",
            })
        end
    end,
})

Auto:CreateSlider({
    Name = "Clics par Seconde",
    Range = {1, 50},
    Increment = 1,
    Suffix = " CPS",
    CurrentValue = 10,
    Flag = "ClickSpeed",
    Callback = function(Value)
        local interval = math.floor(1000 / Value)
        clicker:setInterval(interval)
        if clickerEnabled then
            Rayfield:Notify({
                Title = "AutoClicker",
                Content = "Vitesse: " .. Value .. " CPS",
                Duration = 1.5,
                Image = "gauge",
            })
        end
    end,
})

Auto:CreateDropdown({
    Name = "Bouton de Souris",
    Options = {"left", "right", "middle"},
    CurrentOption = {"left"},
    MultipleOptions = false,
    Flag = "MouseButton",
    Callback = function(Option)
        local button = type(Option) == "table" and Option[1] or Option
        clicker:setButton(button)
        if clickerEnabled then
            Rayfield:Notify({
                Title = "AutoClicker",
                Content = "Bouton: " .. button,
                Duration = 1.5,
                Image = "mouse-pointer",
            })
        end
    end,
})

Auto:CreateButton({
    Name = "Statistiques",
    Callback = function()
        local stats = clicker.click_count
        Rayfield:Notify({
            Title = "Statistiques",
            Content = "Total de clics: " .. stats,
            Duration = 3,
            Image = "bar-chart",
        })
    end,
})

Auto:CreateButton({
    Name = "Réinitialiser le compteur",
    Callback = function()
        clicker.click_count = 0
        Rayfield:Notify({
            Title = "AutoClicker",
            Content = "Compteur réinitialisé",
            Duration = 2,
            Image = "rotate-ccw",
        })
    end,
})

-- ========================================
-- ONGLET FLY
-- ========================================
local FlyTab = Window:CreateTab("Fly", "plane")

local flyEnabled = false

FlyTab:CreateToggle({
    Name = "Activer le Fly",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(Value)
        flyEnabled = Value
        if Value then
            Lib.Fly.On()
            Rayfield:Notify({
                Title = "Fly",
                Content = "Mode vol activé",
                Duration = 2,
                Image = "plane",
            })
        else
            Lib.Fly.Off()
            Rayfield:Notify({
                Title = "Fly",
                Content = "Mode vol désactivé",
                Duration = 2,
                Image = "plane-landing",
            })
        end
    end
})

FlyTab:CreateSlider({
    Name = "Vitesse de Vol",
    Range = {10, 200},
    Increment = 5,
    Suffix = " Speed",
    CurrentValue = 50,
    Flag = "FlySpeed",
    Callback = function(Value)
        Lib.Fly.Speed(Value)
        if flyEnabled then
            Rayfield:Notify({
                Title = "Fly",
                Content = "Vitesse: " .. Value,
                Duration = 1.5,
                Image = "gauge",
            })
        end
    end,
})

-- ========================================
-- ONGLET NOCLIP
-- ========================================
local NoClipTab = Window:CreateTab("NoClip", "ghost")

NoClipTab:CreateToggle({
    Name = "Activer le NoClip",
    CurrentValue = false,
    Flag = "NoClipToggle",
    Callback = function(Value)
        if Value then
            Lib.NoClip.On()
            Rayfield:Notify({
                Title = "NoClip",
                Content = "NoClip activé",
                Duration = 2,
                Image = "ghost",
            })
        else
            Lib.NoClip.Off()
            Rayfield:Notify({
                Title = "NoClip",
                Content = "NoClip désactivé",
                Duration = 2,
                Image = "user",
            })
        end
    end
})

-- ========================================
-- ONGLET TELEPORTATION
-- ========================================
local TeleportTab = Window:CreateTab("Teleportation", "map-pin")

local selectedPlayerName = nil

local PlayerDropdown = TeleportTab:CreateDropdown({
    Name = "Selectionner un joueur",
    Options = Teleport.GetPlayers(),
    CurrentOption = {"Aucun"},
    MultipleOptions = false,
    Flag = "PlayerDropdown",
    Callback = function(Option)
        selectedPlayerName = type(Option) == "table" and Option[1] or Option
        print("Joueur selectionne:", selectedPlayerName)
    end,
})

TeleportTab:CreateButton({
    Name = "Teleporter au joueur",
    Callback = function()
        if selectedPlayerName and selectedPlayerName ~= "" and selectedPlayerName ~= "Aucun" then
            local success = Teleport.ToPlayer(selectedPlayerName)
            if success then
                Rayfield:Notify({
                    Title = "Teleportation",
                    Content = "Teleporte a " .. selectedPlayerName,
                    Duration = 3,
                    Image = "check-circle",
                })
            else
                Rayfield:Notify({
                    Title = "Erreur",
                    Content = "Impossible de se teleporter",
                    Duration = 3,
                    Image = "x-circle",
                })
            end
        else
            Rayfield:Notify({
                Title = "Erreur",
                Content = "Veuillez selectionner un joueur",
                Duration = 3,
                Image = "alert-triangle",
            })
        end
    end,
})

TeleportTab:CreateButton({
    Name = "Rafraichir la liste",
    Callback = function()
        local newPlayerList = Teleport.GetPlayers()
        PlayerDropdown:Refresh(newPlayerList, true)
        Rayfield:Notify({
            Title = "Liste mise a jour",
            Content = #newPlayerList .. " joueurs trouves",
            Duration = 2,
            Image = "refresh-cw",
        })
    end,
})

-- Rafraichir automatiquement la liste quand un joueur rejoint
Teleport.OnPlayerAdded(function(player)
    task.wait(1)
    local newPlayerList = Teleport.GetPlayers()
    PlayerDropdown:Refresh(newPlayerList, true)
end)

-- Rafraichir automatiquement la liste quand un joueur quitte
Teleport.OnPlayerRemoving(function(player)
    local newPlayerList = Teleport.GetPlayers()
    PlayerDropdown:Refresh(newPlayerList, true)
end)

-- ========================================
-- ONGLET INFORMATIONS
-- ========================================
local InfoTab = Window:CreateTab("Informations", "info")

InfoTab:CreateParagraph({
    Title = "Menu by Edaward_01",
    Content = "Version 1.0\n\nFonctionnalités:\n- AutoClicker personnalisable\n- Mode Fly avec vitesse réglable\n- NoClip\n- Téléportation aux joueurs"
})

InfoTab:CreateButton({
    Name = "Fermer le menu",
    Callback = function()
        Rayfield:Destroy()
    end,
})

print("[Menu] Chargé avec succès par Edaward_01")