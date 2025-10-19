-- ========================================
-- CHARGEMENT DES BIBLIOTHEQUES
-- ========================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Lib = loadstring(game:HttpGet('https://raw.githubusercontent.com/nictix02-sys/BlackJack-Tools/refs/heads/main/Fly.lua'))()
local Teleport = loadstring(game:HttpGet('https://raw.githubusercontent.com/nictix02-sys/BlackJack-Tools/refs/heads/main/TP.lua'))()
local ESP = loadstring(game:HttpGet('https://raw.githubusercontent.com/nictix02-sys/BlackJack-Tools/refs/heads/main/ESP.lua'))()
local Aimbot = loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/Aimbot-V3/main/src/Aimbot.lua"))()
local ItemsManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/nictix02-sys/BlackJack-Tools/refs/heads/main/give.lua'))()
local manager = ItemsManager.new()

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
-- ONGLET AIMBOT
-- ========================================
local AimbotTab = Window:CreateTab("Aimbot", "target")

local aimbotEnabled = false

AimbotTab:CreateToggle({
    Name = "Activer Aimbot",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = function(Value)
        aimbotEnabled = Value
        if Value then
            Aimbot.Load()
            Rayfield:Notify({
                Title = "Aimbot",
                Content = "Aimbot activé",
                Duration = 2,
                Image = "target",
            })
        else
            Aimbot.Unload()
            Rayfield:Notify({
                Title = "Aimbot",
                Content = "Aimbot désactivé",
                Duration = 2,
                Image = "x-circle",
            })
        end
    end
})

-- ========================================
-- ONGLET ESP
-- ========================================
local ESPTab = Window:CreateTab("ESP", "eye")

ESPTab:CreateToggle({
    Name = "Activer ESP",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(Value)
        if ESP and ESP.Settings then
            ESP.Settings.Enabled = Value
            Rayfield:Notify({
                Title = "ESP",
                Content = Value and "ESP activé" or "ESP désactivé",
                Duration = 2,
                Image = "eye",
            })
        end
    end
})

ESPTab:CreateToggle({
    Name = "Tracer Lines",
    CurrentValue = false,
    Flag = "TracerToggle",
    Callback = function(Value)
        if ESP and ESP.Settings then
            ESP.Settings.TracerEnabled = Value
        end
    end
})

ESPTab:CreateToggle({
    Name = "Afficher les boîtes",
    CurrentValue = true,
    Flag = "BoxToggle",
    Callback = function(Value)
        if ESP and ESP.Settings then
            ESP.Settings.BoxEnabled = Value
        end
    end
})

ESPTab:CreateToggle({
    Name = "Afficher les noms",
    CurrentValue = true,
    Flag = "NameToggle",
    Callback = function(Value)
        if ESP and ESP.Settings then
            ESP.Settings.ShowName = Value
        end
    end
})

ESPTab:CreateToggle({
    Name = "Afficher la distance",
    CurrentValue = true,
    Flag = "DistanceToggle",
    Callback = function(Value)
        if ESP and ESP.Settings then
            ESP.Settings.ShowDistance = Value
        end
    end
})

ESPTab:CreateToggle({
    Name = "Afficher la santé",
    CurrentValue = true,
    Flag = "HealthToggle",
    Callback = function(Value)
        if ESP and ESP.Settings then
            ESP.Settings.ShowHealth = Value
        end
    end
})

ESPTab:CreateColorPicker({
    Name = "Couleur ESP",
    Color = Color3.fromRGB(255, 255, 255),
    Flag = "ESPColor",
    Callback = function(Value)
        if ESP and ESP.Settings then
            ESP.Settings.Color = Value
        end
    end
})

-- ========================================
-- ONGLET ITEMS / GIVE
-- ========================================
local ItemsTab = Window:CreateTab("Items", "package")

manager:scanAllItems()

local selectedItem = nil
local selectedPlayerForItem = nil

ItemsTab:CreateSection("Sélection d'Item")

local ItemDropdown = ItemsTab:CreateDropdown({
    Name = "Choisir un item",
    Options = manager:getItemNames(),
    CurrentOption = {"Aucun"},
    MultipleOptions = false,
    Flag = "ItemDropdown",
    Callback = function(Option)
        selectedItem = type(Option) == "table" and Option[1] or Option
        print("Item sélectionné:", selectedItem)
        
        Rayfield:Notify({
            Title = "Item sélectionné",
            Content = selectedItem,
            Duration = 2,
            Image = "package",
        })
    end,
})

ItemsTab:CreateInput({
    Name = "Rechercher un item",
    PlaceholderText = "Entrez un mot-clé...",
    RemoveTextAfterFocusLost = false,
    Flag = "ItemSearch",
    Callback = function(Text)
        if Text and Text ~= "" then
            local results = manager:searchItems(Text)
            if #results > 0 then
                ItemDropdown:Refresh(results, true)
                Rayfield:Notify({
                    Title = "Recherche",
                    Content = #results .. " item(s) trouvé(s)",
                    Duration = 2,
                    Image = "search",
                })
            else
                Rayfield:Notify({
                    Title = "Recherche",
                    Content = "Aucun item trouvé",
                    Duration = 2,
                    Image = "alert-circle",
                })
            end
        end
    end,
})

ItemsTab:CreateButton({
    Name = "Rafraîchir la liste des items",
    Callback = function()
        local count = manager:refresh()
        local itemNames = manager:getItemNames()
        ItemDropdown:Refresh(itemNames, true)
        
        Rayfield:Notify({
            Title = "Items rafraîchis",
            Content = count .. " items disponibles",
            Duration = 3,
            Image = "refresh-cw",
        })
    end,
})

ItemsTab:CreateSection("Se donner des items")

ItemsTab:CreateButton({
    Name = "Me donner l'item sélectionné",
    Callback = function()
        if not selectedItem or selectedItem == "Aucun" then
            Rayfield:Notify({
                Title = "Erreur",
                Content = "Veuillez sélectionner un item",
                Duration = 3,
                Image = "alert-triangle",
            })
            return
        end
        
        local success, message = manager:giveItemToSelf(selectedItem)
        
        if success then
            Rayfield:Notify({
                Title = "Item donné",
                Content = "Vous avez reçu: " .. selectedItem,
                Duration = 3,
                Image = "check-circle",
            })
        else
            Rayfield:Notify({
                Title = "Erreur",
                Content = message or "Impossible de donner l'item",
                Duration = 3,
                Image = "x-circle",
            })
        end
    end,
})

ItemsTab:CreateButton({
    Name = "Vider mon inventaire",
    Callback = function()
        local player = game.Players.LocalPlayer
        local success, message = manager:clearPlayerInventory(player.Name)
        
        if success then
            Rayfield:Notify({
                Title = "Inventaire vidé",
                Content = message,
                Duration = 3,
                Image = "trash-2",
            })
        else
            Rayfield:Notify({
                Title = "Erreur",
                Content = message or "Impossible de vider l'inventaire",
                Duration = 3,
                Image = "x-circle",
            })
        end
    end,
})

ItemsTab:CreateSection("Donner à un autre joueur")

local PlayerDropdownForItems = ItemsTab:CreateDropdown({
    Name = "Sélectionner un joueur",
    Options = (function()
        local players = {}
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer then
                table.insert(players, player.Name)
            end
        end
        return players
    end)(),
    CurrentOption = {"Aucun"},
    MultipleOptions = false,
    Flag = "ItemPlayerDropdown",
    Callback = function(Option)
        selectedPlayerForItem = type(Option) == "table" and Option[1] or Option
        print("Joueur sélectionné:", selectedPlayerForItem)
    end,
})

ItemsTab:CreateButton({
    Name = "Donner l'item au joueur",
    Callback = function()
        if not selectedItem or selectedItem == "Aucun" then
            Rayfield:Notify({
                Title = "Erreur",
                Content = "Veuillez sélectionner un item",
                Duration = 3,
                Image = "alert-triangle",
            })
            return
        end
        
        if not selectedPlayerForItem or selectedPlayerForItem == "Aucun" then
            Rayfield:Notify({
                Title = "Erreur",
                Content = "Veuillez sélectionner un joueur",
                Duration = 3,
                Image = "alert-triangle",
            })
            return
        end
        
        local success, message = manager:giveItemToPlayer(selectedPlayerForItem, selectedItem)
        
        if success then
            Rayfield:Notify({
                Title = "Item donné",
                Content = selectedItem .. " → " .. selectedPlayerForItem,
                Duration = 3,
                Image = "gift",
            })
        else
            Rayfield:Notify({
                Title = "Erreur",
                Content = message or "Impossible de donner l'item",
                Duration = 3,
                Image = "x-circle",
            })
        end
    end,
})

ItemsTab:CreateButton({
    Name = "Rafraîchir la liste des joueurs",
    Callback = function()
        local players = {}
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer then
                table.insert(players, player.Name)
            end
        end
        
        PlayerDropdownForItems:Refresh(players, true)
        
        Rayfield:Notify({
            Title = "Joueurs rafraîchis",
            Content = #players .. " joueur(s) trouvé(s)",
            Duration = 2,
            Image = "users",
        })
    end,
})

ItemsTab:CreateSection("Gestion d'inventaire")

ItemsTab:CreateButton({
    Name = "Voir mon inventaire",
    Callback = function()
        local player = game.Players.LocalPlayer
        local inventory = manager:getPlayerInventory(player.Name)
        
        if #inventory > 0 then
            local itemList = table.concat(inventory, ", ")
            Rayfield:Notify({
                Title = "Mon inventaire (" .. #inventory .. " items)",
                Content = itemList,
                Duration = 5,
                Image = "backpack",
            })
        else
            Rayfield:Notify({
                Title = "Inventaire vide",
                Content = "Vous n'avez aucun item",
                Duration = 3,
                Image = "inbox",
            })
        end
    end,
})

ItemsTab:CreateButton({
    Name = "Dupliquer un item équipé",
    Callback = function()
        if not selectedItem or selectedItem == "Aucun" then
            Rayfield:Notify({
                Title = "Erreur",
                Content = "Veuillez sélectionner un item",
                Duration = 3,
                Image = "alert-triangle",
            })
            return
        end
        
        local player = game.Players.LocalPlayer
        local success, message = manager:duplicatePlayerItem(player.Name, selectedItem)
        
        if success then
            Rayfield:Notify({
                Title = "Item dupliqué",
                Content = selectedItem .. " x2",
                Duration = 3,
                Image = "copy",
            })
        else
            Rayfield:Notify({
                Title = "Erreur",
                Content = message or "Item non trouvé dans l'inventaire",
                Duration = 3,
                Image = "x-circle",
            })
        end
    end,
})

ItemsTab:CreateSection("Statistiques")

ItemsTab:CreateButton({
    Name = "Afficher les statistiques",
    Callback = function()
        local stats = manager:getStats()
        
        Rayfield:Notify({
            Title = "Statistiques Items",
            Content = string.format(
                "Total: %d items\nCache: %d items",
                stats.totalItems,
                stats.cacheSize
            ),
            Duration = 4,
            Image = "bar-chart",
        })
    end,
})

-- Rafraîchir automatiquement la liste des joueurs pour items
game.Players.PlayerAdded:Connect(function(player)
    task.wait(1)
    local players = {}
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer then
            table.insert(players, p.Name)
        end
    end
    PlayerDropdownForItems:Refresh(players, true)
end)

game.Players.PlayerRemoving:Connect(function(player)
    local players = {}
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer then
            table.insert(players, p.Name)
        end
    end
    PlayerDropdownForItems:Refresh(players, true)
end)

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

local TeleportPlayerDropdown = TeleportTab:CreateDropdown({
    Name = "Selectionner un joueur",
    Options = Teleport.GetPlayers(),
    CurrentOption = {"Aucun"},
    MultipleOptions = false,
    Flag = "TeleportPlayerDropdown",
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
        TeleportPlayerDropdown:Refresh(newPlayerList, true)
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
    TeleportPlayerDropdown:Refresh(newPlayerList, true)
end)

-- Rafraichir automatiquement la liste quand un joueur quitte
Teleport.OnPlayerRemoving(function(player)
    local newPlayerList = Teleport.GetPlayers()
    TeleportPlayerDropdown:Refresh(newPlayerList, true)
end)

-- ========================================
-- ONGLET INFORMATIONS
-- ========================================
local InfoTab = Window:CreateTab("Informations", "info")

InfoTab:CreateParagraph({
    Title = "Menu by Edaward_01",
    Content = "Version 1.5\n\nFonctionnalités:\n- Aimbot\n- ESP complet\n- Give Items\n- AutoClicker personnalisable\n- Mode Fly avec vitesse réglable\n- NoClip\n- Téléportation aux joueurs"
})

InfoTab:CreateButton({
    Name = "Fermer le menu",
    Callback = function()
        Rayfield:Destroy()
    end,
})

print("[Menu] Chargé avec succès par Edaward_01 - Version 1.5")