-- ========================================
-- CHARGEMENT DES BIBLIOTHEQUES
-- ========================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Lib = loadstring(game:HttpGet('https://raw.githubusercontent.com/nictix02-sys/BlackJack-Tools/refs/heads/main/Fly.lua'))()
local Teleport = loadstring(game:HttpGet('https://raw.githubusercontent.com/nictix02-sys/BlackJack-Tools/refs/heads/main/TP.lua'))()
local ESP = loadstring(game:HttpGet('https://raw.githubusercontent.com/nictix02-sys/BlackJack-Tools/refs/heads/main/ESP.lua'))()
local Aimbot = loadstring(game:HttpGet('https://raw.githubusercontent.com/nictix02-sys/BlackJack-Tools/refs/heads/main/aimbot.lua'))()
local AdminLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/nictix02-sys/BlackJack-Tools/refs/heads/main/moneyexploit.lua'))()
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
    Name = "Menu by Edaward_01 v2.0",
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

-- Variables globales pour stocker les inputs
local targetPlayerName = ""
local targetAmount = 0

-- Créer l'onglet dans Rayfield
local MoneyTab = Window:CreateTab("Gestion Argent", "dollar-sign")

-- Créer la section
MoneyTab:CreateSection("Gestion de l'Argent des Joueurs")

-- Input pour le nom du joueur
MoneyTab:CreateInput({
    Name = "Nom du Joueur",
    PlaceholderText = "Entrez le nom du joueur...",
    RemoveTextAfterFocusLost = false,
    Flag = "PlayerNameInput",
    Callback = function(Text)
        targetPlayerName = Text
    end,
})

-- Input pour le montant
MoneyTab:CreateInput({
    Name = "Montant d'Argent",
    PlaceholderText = "Entrez le montant...",
    RemoveTextAfterFocusLost = false,
    Flag = "AmountInput",
    Callback = function(Text)
        targetAmount = tonumber(Text) or 0
    end,
})

-- Bouton pour définir l'argent
MoneyTab:CreateButton({
    Name = "Définir l'Argent",
    Callback = function()
        if targetPlayerName ~= "" and targetAmount > 0 then
            local player = game.Players:FindFirstChild(targetPlayerName)
            if player then
                local success = AdminLib:SetMoney(player, targetAmount)
                if success then
                    Rayfield:Notify({
                        Title = "Succès",
                        Content = "Argent de " .. targetPlayerName .. " défini à " .. targetAmount .. "$",
                        Duration = 5,
                        Image = 4483362458,
                    })
                else
                    Rayfield:Notify({
                        Title = "Erreur",
                        Content = "Impossible de définir l'argent",
                        Duration = 5,
                        Image = 4483362458,
                    })
                end
            else
                Rayfield:Notify({
                    Title = "Erreur",
                    Content = "Joueur introuvable: " .. targetPlayerName,
                    Duration = 5,
                    Image = 4483362458,
                })
            end
        else
            Rayfield:Notify({
                Title = "Erreur",
                Content = "Nom ou montant invalide",
                Duration = 5,
                Image = 4483362458,
            })
        end
    end,
})

-- ========================================
-- ONGLET AIMBOT (AMELIORE)
-- ========================================
local AimbotTab = Window:CreateTab("Aimbot", "target")

local aimbotEnabled = false

AimbotTab:CreateSection("Activation")

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
            if Aimbot.Settings then
                Aimbot:Toggle(false)
            end
            Rayfield:Notify({
                Title = "Aimbot",
                Content = "Aimbot désactivé",
                Duration = 2,
                Image = "x-circle",
            })
        end
    end,
})

AimbotTab:CreateSection("Paramètres de Base")

AimbotTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = false,
    Flag = "AimbotTeamCheck",
    Callback = function(Value)
        if Aimbot and Aimbot.Settings then
            Aimbot.Settings.TeamCheck = Value
        end
    end,
})

AimbotTab:CreateToggle({
    Name = "Wall Check",
    CurrentValue = false,
    Flag = "AimbotWallCheck",
    Callback = function(Value)
        if Aimbot and Aimbot.Settings then
            Aimbot.Settings.WallCheck = Value
        end
    end,
})

AimbotTab:CreateToggle({
    Name = "Alive Check",
    CurrentValue = true,
    Flag = "AimbotAliveCheck",
    Callback = function(Value)
        if Aimbot and Aimbot.Settings then
            Aimbot.Settings.AliveCheck = Value
        end
    end,
})

AimbotTab:CreateToggle({
    Name = "Mode Toggle",
    CurrentValue = false,
    Flag = "AimbotToggleMode",
    Callback = function(Value)
        if Aimbot and Aimbot.Settings then
            Aimbot.Settings.Toggle = Value
            Rayfield:Notify({
                Title = "Mode Toggle",
                Content = Value and "Mode toggle activé" or "Mode maintenu activé",
                Duration = 2,
                Image = "toggle-left",
            })
        end
    end,
})

AimbotTab:CreateSection("Paramètres Avancés")

AimbotTab:CreateDropdown({
    Name = "Lock Mode",
    Options = {"CFrame (Smooth)", "MouseMoveRel (Direct)"},
    CurrentOption = {"CFrame (Smooth)"},
    MultipleOptions = false,
    Flag = "AimbotLockMode",
    Callback = function(Option)
        if Aimbot and Aimbot.Settings then
            local mode = Option[1] or Option
            Aimbot.Settings.LockMode = mode:find("CFrame") and 1 or 2
        end
    end,
})

AimbotTab:CreateDropdown({
    Name = "Lock Part (Partie visée)",
    Options = {"Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso"},
    CurrentOption = {"Head"},
    MultipleOptions = false,
    Flag = "AimbotLockPart",
    Callback = function(Option)
        if Aimbot and Aimbot.Settings then
            Aimbot.Settings.LockPart = Option[1] or Option
            Rayfield:Notify({
                Title = "Lock Part",
                Content = "Visée: " .. (Option[1] or Option),
                Duration = 2,
                Image = "crosshair",
            })
        end
    end,
})

AimbotTab:CreateSlider({
    Name = "Sensibilité (Smoothness)",
    Range = {0, 5},
    Increment = 0.1,
    Suffix = "s",
    CurrentValue = 0,
    Flag = "AimbotSensitivity",
    Callback = function(Value)
        if Aimbot and Aimbot.Settings then
            Aimbot.Settings.Sensitivity = Value
        end
    end,
})

AimbotTab:CreateSlider({
    Name = "MouseMoveRel Sensitivity",
    Range = {1, 10},
    Increment = 0.5,
    Suffix = "",
    CurrentValue = 3.5,
    Flag = "AimbotSensitivity2",
    Callback = function(Value)
        if Aimbot and Aimbot.Settings then
            Aimbot.Settings.Sensitivity2 = Value
        end
    end,
})

AimbotTab:CreateSection("Prédiction de Mouvement")

AimbotTab:CreateToggle({
    Name = "Prédiction Activée",
    CurrentValue = true,
    Flag = "AimbotPrediction",
    Callback = function(Value)
        if Aimbot and Aimbot.DeveloperSettings then
            Aimbot.DeveloperSettings.PredictionEnabled = Value
        end
    end,
})

AimbotTab:CreateSlider({
    Name = "Force de Prédiction",
    Range = {0, 1},
    Increment = 0.05,
    Suffix = "",
    CurrentValue = 0.15,
    Flag = "AimbotPredictionMultiplier",
    Callback = function(Value)
        if Aimbot and Aimbot.DeveloperSettings then
            Aimbot.DeveloperSettings.PredictionMultiplier = Value
        end
    end,
})

AimbotTab:CreateToggle({
    Name = "Offset vers Direction",
    CurrentValue = false,
    Flag = "AimbotOffset",
    Callback = function(Value)
        if Aimbot and Aimbot.Settings then
            Aimbot.Settings.OffsetToMoveDirection = Value
        end
    end,
})

AimbotTab:CreateSlider({
    Name = "Offset Increment",
    Range = {1, 30},
    Increment = 1,
    Suffix = "",
    CurrentValue = 15,
    Flag = "AimbotOffsetIncrement",
    Callback = function(Value)
        if Aimbot and Aimbot.Settings then
            Aimbot.Settings.OffsetIncrement = Value
        end
    end,
})

AimbotTab:CreateSection("FOV (Champ de Vision)")

AimbotTab:CreateToggle({
    Name = "Afficher FOV Circle",
    CurrentValue = true,
    Flag = "AimbotFOVVisible",
    Callback = function(Value)
        if Aimbot and Aimbot.FOVSettings then
            Aimbot.FOVSettings.Visible = Value
        end
    end,
})

AimbotTab:CreateToggle({
    Name = "FOV Enabled",
    CurrentValue = true,
    Flag = "AimbotFOVEnabled",
    Callback = function(Value)
        if Aimbot and Aimbot.FOVSettings then
            Aimbot.FOVSettings.Enabled = Value
        end
    end,
})

AimbotTab:CreateSlider({
    Name = "FOV Radius",
    Range = {10, 500},
    Increment = 5,
    Suffix = " px",
    CurrentValue = 90,
    Flag = "AimbotFOVRadius",
    Callback = function(Value)
        if Aimbot and Aimbot.FOVSettings then
            Aimbot.FOVSettings.Radius = Value
        end
    end,
})

AimbotTab:CreateSlider({
    Name = "FOV Transparence",
    Range = {0, 1},
    Increment = 0.1,
    Suffix = "",
    CurrentValue = 1,
    Flag = "AimbotFOVTransparency",
    Callback = function(Value)
        if Aimbot and Aimbot.FOVSettings then
            Aimbot.FOVSettings.Transparency = Value
        end
    end,
})

AimbotTab:CreateToggle({
    Name = "Rainbow FOV Color",
    CurrentValue = false,
    Flag = "AimbotRainbowFOV",
    Callback = function(Value)
        if Aimbot and Aimbot.FOVSettings then
            Aimbot.FOVSettings.RainbowColor = Value
        end
    end,
})

AimbotTab:CreateColorPicker({
    Name = "FOV Color",
    Color = Color3.fromRGB(255, 255, 255),
    Flag = "AimbotFOVColor",
    Callback = function(Value)
        if Aimbot and Aimbot.FOVSettings then
            Aimbot.FOVSettings.Color = Value
        end
    end
})

AimbotTab:CreateColorPicker({
    Name = "Locked Color",
    Color = Color3.fromRGB(255, 150, 150),
    Flag = "AimbotLockedColor",
    Callback = function(Value)
        if Aimbot and Aimbot.FOVSettings then
            Aimbot.FOVSettings.LockedColor = Value
        end
    end
})

AimbotTab:CreateSection("Gestion des Joueurs")

local blacklistInput = ""
AimbotTab:CreateInput({
    Name = "Blacklist un joueur",
    PlaceholderText = "Nom du joueur...",
    RemoveTextAfterFocusLost = false,
    Flag = "AimbotBlacklistInput",
    Callback = function(Text)
        blacklistInput = Text
    end,
})

AimbotTab:CreateButton({
    Name = "Ajouter à la Blacklist",
    Callback = function()
        if blacklistInput and blacklistInput ~= "" then
            if Aimbot and Aimbot.Blacklist then
                local success = pcall(function()
                    Aimbot:Blacklist(blacklistInput)
                end)
                if success then
                    Rayfield:Notify({
                        Title = "Blacklist",
                        Content = blacklistInput .. " ajouté",
                        Duration = 2,
                        Image = "user-x",
                    })
                else
                    Rayfield:Notify({
                        Title = "Erreur",
                        Content = "Joueur introuvable",
                        Duration = 2,
                        Image = "alert-triangle",
                    })
                end
            end
        end
    end,
})

local whitelistInput = ""
AimbotTab:CreateInput({
    Name = "Whitelist un joueur",
    PlaceholderText = "Nom du joueur...",
    RemoveTextAfterFocusLost = false,
    Flag = "AimbotWhitelistInput",
    Callback = function(Text)
        whitelistInput = Text
    end,
})

AimbotTab:CreateButton({
    Name = "Retirer de la Blacklist",
    Callback = function()
        if whitelistInput and whitelistInput ~= "" then
            if Aimbot and Aimbot.Whitelist then
                local success = pcall(function()
                    Aimbot:Whitelist(whitelistInput)
                end)
                if success then
                    Rayfield:Notify({
                        Title = "Whitelist",
                        Content = whitelistInput .. " retiré",
                        Duration = 2,
                        Image = "user-check",
                    })
                else
                    Rayfield:Notify({
                        Title = "Erreur",
                        Content = "Joueur non blacklisté",
                        Duration = 2,
                        Image = "alert-triangle",
                    })
                end
            end
        end
    end,
})

AimbotTab:CreateSection("Actions")

AimbotTab:CreateButton({
    Name = "Redémarrer Aimbot",
    Callback = function()
        if Aimbot and Aimbot.Restart then
            Aimbot.Restart()
            Rayfield:Notify({
                Title = "Aimbot",
                Content = "Aimbot redémarré",
                Duration = 2,
                Image = "refresh-cw",
            })
        end
    end,
})

AimbotTab:CreateButton({
    Name = "Voir les Statistiques",
    Callback = function()
        if Aimbot and Aimbot.GetStats then
            local stats = Aimbot:GetStats()
            Rayfield:Notify({
                Title = "Statistiques Aimbot",
                Content = string.format(
                    "Locks: %d\nCible: %s",
                    stats.TotalLocks or 0,
                    stats.CurrentTarget or "Aucune"
                ),
                Duration = 4,
                Image = "bar-chart",
            })
        end
    end,
})

AimbotTab:CreateButton({
    Name = "Désactiver Complètement",
    Callback = function()
        if Aimbot and Aimbot.Exit then
            Aimbot:Exit()
            Rayfield:Notify({
                Title = "Aimbot",
                Content = "Aimbot complètement désactivé",
                Duration = 2,
                Image = "power",
            })
        end
    end,
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
    end,
})

Auto:CreateButton({
    Name = "Statistiques",
    Callback = function()
        Rayfield:Notify({
            Title = "Statistiques",
            Content = "Total de clics: " .. clicker.click_count,
            Duration = 3,
            Image = "bar-chart",
        })
    end,
})

-- ========================================
-- ONGLET FLY
-- ========================================
local FlyTab = Window:CreateTab("Fly", "plane")

FlyTab:CreateToggle({
    Name = "Activer le Fly",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(Value)
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

-- Rafraichir automatiquement
Teleport.OnPlayerAdded(function(player)
    task.wait(1)
    local newPlayerList = Teleport.GetPlayers()
    TeleportPlayerDropdown:Refresh(newPlayerList, true)
end)

Teleport.OnPlayerRemoving(function(player)
    local newPlayerList = Teleport.GetPlayers()
    TeleportPlayerDropdown:Refresh(newPlayerList, true)
end)

-- ========================================
-- ONGLET INFORMATIONS
-- ========================================
local InfoTab = Window:CreateTab("Informations", "info")

InfoTab:CreateParagraph({
    Title = "Menu by Edaward_01 v2.0",
    Content = "Version 2.0 avec Aimbot Amélioré\n\nFonctionnalités:\n✓ Aimbot avancé avec prédiction\n✓ ESP complet\n✓ Give Items\n✓ AutoClicker personnalisable\n✓ Mode Fly avec vitesse réglable\n✓ NoClip\n✓ Téléportation aux joueurs"
})

InfoTab:CreateSection("Guide Aimbot")

InfoTab:CreateParagraph({
    Title = "Comment utiliser l'Aimbot",
    Content = "1. Activez l'aimbot dans l'onglet Aimbot\n2. Maintenez le bouton droit de la souris\n3. L'aimbot se verrouillera sur la cible\n\nConseils:\n- Mode Toggle pour lock/unlock\n- Augmentez la Sensibilité pour plus de smoothness\n- Wall Check évite de viser à travers les murs\n- La prédiction aide à toucher les cibles en mouvement"
})

InfoTab:CreateSection("Actions")

InfoTab:CreateButton({
    Name = "Copier le lien du script",
    Callback = function()
        setclipboard("https://raw.githubusercontent.com/nictix02-sys/BlackJack-Tools/refs/heads/main/menu.lua")
        Rayfield:Notify({
            Title = "Lien copié",
            Content = "Lien du script copié",
            Duration = 3,
            Image = "clipboard",
        })
    end,
})

InfoTab:CreateButton({
    Name = "Fermer le menu",
    Callback = function()
        Rayfield:Destroy()
    end,
})

InfoTab:CreateSection("Crédits")

InfoTab:CreateParagraph({
    Title = "Développement",
    Content = "Menu: Edaward_01\nAimbot: Exunys\nInterface: Rayfield\n\nVersion: 2.0\nDate: 2025"
})

-- ========================================
-- INITIALISATION
-- ========================================

Rayfield:Notify({
    Title = "Menu by Edaward_01",
    Content = "Menu chargé avec succès ! Version 2.0",
    Duration = 5,
    Image = "check-circle",
})

print("========================================")
print("[Menu] Chargé avec succès")
print("[Menu] Version 2.0 - By Edaward_01")
print("========================================")

-- Nettoyage à la fermeture
game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child.Name == "Rayfield" then
        if getgenv().ExunysDeveloperAimbot and getgenv().ExunysDeveloperAimbot.Exit then
            pcall(function()
                getgenv().ExunysDeveloperAimbot:Exit()
            end)
        end
        print("[Menu] Fermé proprement")
    end
end)