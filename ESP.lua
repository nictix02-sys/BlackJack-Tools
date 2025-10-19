-- Bibliothèque ESP pour Roblox
-- ESP (Extra Sensory Perception) - Affichage d'informations sur les joueurs

local ESP = {}
ESP.__index = ESP

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Paramètres par défaut
ESP.Settings = {
    Enabled = false,
    BoxEnabled = true,
    TracerEnabled = false,
    ShowName = true,
    ShowDistance = true,
    ShowHealth = true,
    TeamColor = false,
    TeamCheck = false, -- Ne pas afficher l'ESP pour les coéquipiers
    Color = Color3.fromRGB(255, 255, 255),
    BoxThickness = 2,
    TracerThickness = 2,
    TextSize = 13,
    MaxDistance = 5000 -- Distance maximale pour afficher l'ESP
}

-- Stockage des objets ESP
local ESPObjects = {}
local UpdateConnection = nil

-- Créer les objets ESP pour un joueur
local function CreateESP(player)
    if player == LocalPlayer then return end
    if ESPObjects[player] then return end

    -- Box (rectangle)
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = ESP.Settings.Color
    Box.Thickness = ESP.Settings.BoxThickness
    Box.Filled = false
    Box.Transparency = 1

    -- Tracer (ligne depuis le bas de l'écran)
    local Tracer = Drawing.new("Line")
    Tracer.Visible = false
    Tracer.Color = ESP.Settings.Color
    Tracer.Thickness = ESP.Settings.TracerThickness
    Tracer.Transparency = 1

    -- Texte du nom
    local NameText = Drawing.new("Text")
    NameText.Visible = false
    NameText.Center = true
    NameText.Outline = true
    NameText.Color = ESP.Settings.Color
    NameText.Size = ESP.Settings.TextSize
    NameText.Font = 2

    -- Texte de la distance
    local DistanceText = Drawing.new("Text")
    DistanceText.Visible = false
    DistanceText.Center = true
    DistanceText.Outline = true
    DistanceText.Color = Color3.fromRGB(255, 255, 255)
    DistanceText.Size = ESP.Settings.TextSize - 1
    DistanceText.Font = 2

    -- Texte de la santé
    local HealthText = Drawing.new("Text")
    HealthText.Visible = false
    HealthText.Center = true
    HealthText.Outline = true
    HealthText.Size = ESP.Settings.TextSize - 1
    HealthText.Font = 2

    -- Barre de santé
    local HealthBar = Drawing.new("Square")
    HealthBar.Visible = false
    HealthBar.Filled = true
    HealthBar.Thickness = 1
    HealthBar.Transparency = 1

    local HealthBarOutline = Drawing.new("Square")
    HealthBarOutline.Visible = false
    HealthBar.Filled = false
    HealthBarOutline.Thickness = 1
    HealthBarOutline.Color = Color3.fromRGB(0, 0, 0)
    HealthBarOutline.Transparency = 1

    ESPObjects[player] = {
        Box = Box,
        Tracer = Tracer,
        NameText = NameText,
        DistanceText = DistanceText,
        HealthText = HealthText,
        HealthBar = HealthBar,
        HealthBarOutline = HealthBarOutline
    }
end

-- Supprimer les objets ESP d'un joueur
local function RemoveESP(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            pcall(function()
                obj:Remove()
            end)
        end
        ESPObjects[player] = nil
    end
end

-- Mettre à jour l'ESP
local function UpdateESP()
    if not ESP.Settings.Enabled then
        for _, esp in pairs(ESPObjects) do
            for _, obj in pairs(esp) do
                obj.Visible = false
            end
        end
        return
    end

    for player, esp in pairs(ESPObjects) do
        -- Vérifier si le joueur existe toujours
        if not player or not player.Parent then
            RemoveESP(player)
            continue
        end

        local char = player.Character
        local localChar = LocalPlayer.Character

        -- Vérifications de base
        if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") then
            for _, obj in pairs(esp) do 
                obj.Visible = false 
            end
            continue
        end

        if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then
            for _, obj in pairs(esp) do 
                obj.Visible = false 
            end
            continue
        end

        -- Team check
        if ESP.Settings.TeamCheck and player.Team == LocalPlayer.Team and player.Team ~= nil then
            for _, obj in pairs(esp) do 
                obj.Visible = false 
            end
            continue
        end

        local rootPart = char.HumanoidRootPart
        local head = char:FindFirstChild("Head")
        local humanoid = char.Humanoid

        -- Calculer la distance
        local distance = (localChar.HumanoidRootPart.Position - rootPart.Position).Magnitude
        
        -- Vérifier la distance maximale
        if distance > ESP.Settings.MaxDistance then
            for _, obj in pairs(esp) do 
                obj.Visible = false 
            end
            continue
        end

        -- Convertir la position du monde en position d'écran
        local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
        
        if onScreen then
            -- Calculer les dimensions de la box
            local headPos = Camera:WorldToViewportPoint((head and head.Position or rootPart.Position) + Vector3.new(0, 0.5, 0))
            local legPos = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
            local height = math.abs(headPos.Y - legPos.Y)
            local width = height / 2

            -- Déterminer la couleur
            local color = ESP.Settings.Color
            if ESP.Settings.TeamColor and player.Team and player.Team.TeamColor then
                color = player.Team.TeamColor.Color
            end

            -- === BOX ===
            if ESP.Settings.BoxEnabled then
                esp.Box.Size = Vector2.new(width, height)
                esp.Box.Position = Vector2.new(vector.X - width / 2, vector.Y - height / 2)
                esp.Box.Color = color
                esp.Box.Thickness = ESP.Settings.BoxThickness
                esp.Box.Visible = true
            else
                esp.Box.Visible = false
            end

            -- === TRACER ===
            if ESP.Settings.TracerEnabled then
                esp.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                esp.Tracer.To = Vector2.new(vector.X, vector.Y)
                esp.Tracer.Color = color
                esp.Tracer.Thickness = ESP.Settings.TracerThickness
                esp.Tracer.Visible = true
            else
                esp.Tracer.Visible = false
            end

            -- === NOM ===
            if ESP.Settings.ShowName then
                esp.NameText.Text = player.Name
                esp.NameText.Position = Vector2.new(vector.X, vector.Y - height / 2 - 15)
                esp.NameText.Color = color
                esp.NameText.Size = ESP.Settings.TextSize
                esp.NameText.Visible = true
            else
                esp.NameText.Visible = false
            end

            -- === DISTANCE ===
            if ESP.Settings.ShowDistance then
                esp.DistanceText.Text = string.format("[%d studs]", math.floor(distance))
                esp.DistanceText.Position = Vector2.new(vector.X, vector.Y + height / 2 + 5)
                esp.DistanceText.Visible = true
            else
                esp.DistanceText.Visible = false
            end

            -- === SANTÉ ===
            if ESP.Settings.ShowHealth then
                local health = math.floor(humanoid.Health)
                local maxHealth = math.floor(humanoid.MaxHealth)
                local hpPercent = math.clamp(health / maxHealth, 0, 1)
                
                esp.HealthText.Text = string.format("%d/%d HP", health, maxHealth)
                esp.HealthText.Color = Color3.fromRGB(
                    math.floor(255 - 255 * hpPercent), 
                    math.floor(255 * hpPercent), 
                    0
                )
                esp.HealthText.Position = Vector2.new(vector.X, vector.Y + height / 2 + 20)
                esp.HealthText.Visible = true

                -- Barre de santé
                local barWidth = 4
                local barHeight = height
                esp.HealthBarOutline.Size = Vector2.new(barWidth, barHeight)
                esp.HealthBarOutline.Position = Vector2.new(vector.X - width / 2 - barWidth - 2, vector.Y - height / 2)
                esp.HealthBarOutline.Visible = true

                esp.HealthBar.Size = Vector2.new(barWidth - 2, barHeight * hpPercent)
                esp.HealthBar.Position = Vector2.new(vector.X - width / 2 - barWidth - 1, vector.Y - height / 2 + barHeight * (1 - hpPercent))
                esp.HealthBar.Color = Color3.fromRGB(
                    math.floor(255 - 255 * hpPercent), 
                    math.floor(255 * hpPercent), 
                    0
                )
                esp.HealthBar.Visible = true
            else
                esp.HealthText.Visible = false
                esp.HealthBar.Visible = false
                esp.HealthBarOutline.Visible = false
            end
        else
            -- Joueur hors de l'écran
            for _, obj in pairs(esp) do 
                obj.Visible = false 
            end
        end
    end
end

-- Initialiser l'ESP
function ESP:Init()
    -- Créer l'ESP pour tous les joueurs existants
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreateESP(player)
        end
    end

    -- Écouter l'arrivée de nouveaux joueurs
    Players.PlayerAdded:Connect(function(player)
        task.wait(1)
        CreateESP(player)
    end)

    -- Écouter le départ de joueurs
    Players.PlayerRemoving:Connect(function(player)
        RemoveESP(player)
    end)

    -- Démarrer la boucle de mise à jour
    if not UpdateConnection then
        UpdateConnection = RunService.RenderStepped:Connect(UpdateESP)
    end

    print("[ESP] Initialisé avec succès")
end

-- Activer l'ESP
function ESP:Enable()
    self.Settings.Enabled = true
    print("[ESP] Activé")
end

-- Désactiver l'ESP
function ESP:Disable()
    self.Settings.Enabled = false
    print("[ESP] Désactivé")
end

-- Toggle l'ESP
function ESP:Toggle()
    self.Settings.Enabled = not self.Settings.Enabled
    print("[ESP] " .. (self.Settings.Enabled and "Activé" or "Désactivé"))
end

-- Détruire l'ESP complètement
function ESP:Destroy()
    if UpdateConnection then
        UpdateConnection:Disconnect()
        UpdateConnection = nil
    end

    for player, _ in pairs(ESPObjects) do
        RemoveESP(player)
    end

    print("[ESP] Détruit")
end

-- Changer la couleur
function ESP:SetColor(color)
    self.Settings.Color = color
end

-- Changer l'épaisseur des lignes
function ESP:SetThickness(thickness)
    self.Settings.BoxThickness = thickness
    self.Settings.TracerThickness = thickness
end

-- Obtenir les statistiques
function ESP:GetStats()
    local count = 0
    for _ in pairs(ESPObjects) do
        count = count + 1
    end
    return {
        playersTracked = count,
        enabled = self.Settings.Enabled
    }
end

-- Initialiser automatiquement
ESP:Init()

return ESP