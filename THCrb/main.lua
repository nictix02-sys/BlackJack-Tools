--[[ 
    Script ESP pour Roblox
    Auteur: Edaward_01
    Version: 1.0
    Description: Ce script ajoute une fonctionnalité ESP (Extra Sensory Perception) pour voir les joueurs à travers les murs, avec des options personnalisables.
]]--

-- Chargement de LinoriaLib
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ========== SYSTÈME ESP ==========
local ESPObjects = {}
local ESPSettings = {
    Enabled = false,
    TeamCheck = false,
    ShowName = true,
    ShowDistance = true,
    ShowHealth = true,
    BoxEnabled = true,
    TracerEnabled = false,
    Color = Color3.fromRGB(255, 0, 0),
    TeamColor = false
}

local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = ESPSettings.Color
    Box.Thickness = 2
    Box.Transparency = 1
    Box.Filled = false
    
    local Tracer = Drawing.new("Line")
    Tracer.Visible = false
    Tracer.Color = ESPSettings.Color
    Tracer.Thickness = 2
    Tracer.Transparency = 1
    
    local NameText = Drawing.new("Text")
    NameText.Visible = false
    NameText.Center = true
    NameText.Outline = true
    NameText.Color = ESPSettings.Color
    NameText.Size = 13
    
    local DistanceText = Drawing.new("Text")
    DistanceText.Visible = false
    DistanceText.Center = true
    DistanceText.Outline = true
    DistanceText.Color = Color3.fromRGB(255, 255, 255)
    DistanceText.Size = 12
    
    local HealthText = Drawing.new("Text")
    HealthText.Visible = false
    HealthText.Center = true
    HealthText.Outline = true
    HealthText.Size = 12
    
    ESPObjects[player] = {
        Box = Box,
        Tracer = Tracer,
        NameText = NameText,
        DistanceText = DistanceText,
        HealthText = HealthText
    }
end

local function RemoveESP(player)
    if ESPObjects[player] then
        ESPObjects[player].Box:Remove()
        ESPObjects[player].Tracer:Remove()
        ESPObjects[player].NameText:Remove()
        ESPObjects[player].DistanceText:Remove()
        ESPObjects[player].HealthText:Remove()
        ESPObjects[player] = nil
    end
end

local function UpdateESP()
    if not ESPSettings.Enabled then return end
    
    local Camera = workspace.CurrentCamera
    
    for player, esp in pairs(ESPObjects) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            local character = player.Character
            local rootPart = character.HumanoidRootPart
            local humanoid = character.Humanoid
            local head = character:FindFirstChild("Head")
            
            if ESPSettings.TeamCheck and player.Team == LocalPlayer.Team then
                esp.Box.Visible = false
                esp.Tracer.Visible = false
                esp.NameText.Visible = false
                esp.DistanceText.Visible = false
                esp.HealthText.Visible = false
                continue
            end
            
            local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            
            if onScreen then
                local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                local legPos = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
                
                local height = math.abs(headPos.Y - legPos.Y)
                local width = height / 2
                
                local color = ESPSettings.Color
                if ESPSettings.TeamColor and player.Team then
                    color = player.Team.TeamColor.Color
                end
                
                if ESPSettings.BoxEnabled then
                    esp.Box.Size = Vector2.new(width, height)
                    esp.Box.Position = Vector2.new(vector.X - width / 2, vector.Y - height / 2)
                    esp.Box.Color = color
                    esp.Box.Visible = true
                else
                    esp.Box.Visible = false
                end
                
                if ESPSettings.TracerEnabled then
                    esp.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    esp.Tracer.To = Vector2.new(vector.X, vector.Y)
                    esp.Tracer.Color = color
                    esp.Tracer.Visible = true
                else
                    esp.Tracer.Visible = false
                end
                
                local distance = (LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
                
                if ESPSettings.ShowName then
                    esp.NameText.Text = player.Name
                    esp.NameText.Position = Vector2.new(vector.X, vector.Y - height / 2 - 15)
                    esp.NameText.Color = color
                    esp.NameText.Visible = true
                else
                    esp.NameText.Visible = false
                end
                
                if ESPSettings.ShowDistance then
                    esp.DistanceText.Text = string.format("[%d studs]", math.floor(distance))
                    esp.DistanceText.Position = Vector2.new(vector.X, vector.Y + height / 2 + 5)
                    esp.DistanceText.Visible = true
                else
                    esp.DistanceText.Visible = false
                end
                
                if ESPSettings.ShowHealth then
                    local health = math.floor(humanoid.Health)
                    local maxHealth = math.floor(humanoid.MaxHealth)
                    local healthPercent = health / maxHealth
                    
                    local healthColor = Color3.fromRGB(
                        math.floor(255 * (1 - healthPercent)),
                        math.floor(255 * healthPercent),
                        0
                    )
                    
                    esp.HealthText.Text = string.format("%d/%d HP", health, maxHealth)
                    esp.HealthText.Position = Vector2.new(vector.X, vector.Y + height / 2 + 20)
                    esp.HealthText.Color = healthColor
                    esp.HealthText.Visible = true
                else
                    esp.HealthText.Visible = false
                end
                
            else
                esp.Box.Visible = false
                esp.Tracer.Visible = false
                esp.NameText.Visible = false
                esp.DistanceText.Visible = false
                esp.HealthText.Visible = false
            end
        else
            esp.Box.Visible = false
            esp.Tracer.Visible = false
            esp.NameText.Visible = false
            esp.DistanceText.Visible = false
            esp.HealthText.Visible = false
        end
    end
end

RunService.RenderStepped:Connect(UpdateESP)

Players.PlayerAdded:Connect(function(player)
    if ESPSettings.Enabled then
        CreateESP(player)
    end
end)

Players.PlayerRemoving:Connect(RemoveESP)

-- ========== CRÉATION DU MENU ==========
local Window = Library:CreateWindow({
    Title = 'Mon Script avec ESP',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Visuel = Window:AddTab('Visuel'),
    Player = Window:AddTab('Joueur'),
    ['UI Settings'] = Window:AddTab('Paramètres UI'),
}

-- ========== ONGLET VISUEL ==========
local ESPGroup = Tabs.Visuel:AddLeftGroupbox('ESP')

ESPGroup:AddToggle('PlayerESP', {
    Text = 'Activer ESP',
    Default = false,
    Tooltip = 'Voir les joueurs à travers les murs',
    
    Callback = function(Value)
        ESPSettings.Enabled = Value
        
        if Value then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and not ESPObjects[player] then
                    CreateESP(player)
                end
            end
        else
            for _, esp in pairs(ESPObjects) do
                esp.Box.Visible = false
                esp.Tracer.Visible = false
                esp.NameText.Visible = false
                esp.DistanceText.Visible = false
                esp.HealthText.Visible = false
            end
        end
    end
})

ESPGroup:AddToggle('ESPBox', {
    Text = 'Afficher Box',
    Default = true,
    Tooltip = 'Affiche un carré autour des joueurs',
    
    Callback = function(Value)
        ESPSettings.BoxEnabled = Value
    end
})

ESPGroup:AddToggle('ESPTracer', {
    Text = 'Afficher Tracers',
    Default = false,
    Tooltip = 'Ligne depuis le bas de l\'écran',
    
    Callback = function(Value)
        ESPSettings.TracerEnabled = Value
    end
})

ESPGroup:AddToggle('ESPName', {
    Text = 'Afficher Nom',
    Default = true,
    
    Callback = function(Value)
        ESPSettings.ShowName = Value
    end
})

ESPGroup:AddToggle('ESPDistance', {
    Text = 'Afficher Distance',
    Default = true,
    
    Callback = function(Value)
        ESPSettings.ShowDistance = Value
    end
})

ESPGroup:AddToggle('ESPHealth', {
    Text = 'Afficher Vie',
    Default = true,
    
    Callback = function(Value)
        ESPSettings.ShowHealth = Value
    end
})

ESPGroup:AddToggle('TeamCheck', {
    Text = 'Team Check',
    Default = false,
    Tooltip = 'Ne pas afficher les coéquipiers',
    
    Callback = function(Value)
        ESPSettings.TeamCheck = Value
    end
})

ESPGroup:AddToggle('TeamColor', {
    Text = 'Couleur de Team',
    Default = false,
    Tooltip = 'Utilise la couleur de l\'équipe',
    
    Callback = function(Value)
        ESPSettings.TeamColor = Value
    end
})

ESPGroup:AddLabel('Couleur ESP'):AddColorPicker('ESPColor', {
    Default = Color3.fromRGB(255, 0, 0),
    Title = 'Couleur ESP',
    
    Callback = function(Value)
        ESPSettings.Color = Value
    end
})

-- ========== ONGLET JOUEUR ==========
local PlayerGroup = Tabs.Player:AddLeftGroupbox('Paramètres du joueur')

PlayerGroup:AddSlider('WalkSpeed', {
    Text = 'Vitesse de marche',
    Default = 16,
    Min = 16,
    Max = 100,
    Rounding = 1,
    Compact = false,
    
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end
})

PlayerGroup:AddSlider('JumpPower', {
    Text = 'Puissance de saut',
    Default = 50,
    Min = 50,
    Max = 200,
    Rounding = 1,
    Compact = false,
    
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = Value
        end
    end
})

-- ========== CONFIGURATION UI ==========
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({'MenuKeybind'})

ThemeManager:SetLibrary(Library)
SaveManager:SetFolder('MonScript/configs')

SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])

local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

MenuGroup:AddButton({
    Text = 'Décharger le script',
    Func = function()
        for _, esp in pairs(ESPObjects) do
            esp.Box:Remove()
            esp.Tracer:Remove()
            esp.NameText:Remove()
            esp.DistanceText:Remove()
            esp.HealthText:Remove()
        end
        Library:Unload()
    end,
    DoubleClick = true
})

MenuGroup:AddLabel('Raccourci menu'):AddKeyPicker('MenuKeybind', {
    Default = 'RightShift',
    NoUI = true,
    Text = 'Ouvrir/Fermer'
})

Library.ToggleKeybind = Options.MenuKeybind
Library:SetWatermarkVisibility(true)
Library:SetWatermark('ESP Script v1.0')

SaveManager:LoadAutoloadConfig()
Library:Notify('Script chargé avec succès!', 5)

-- Créer ESP pour joueurs existants
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end