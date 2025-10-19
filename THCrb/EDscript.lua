-- 🧠 Load Rayfield Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Aimbot = loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/Aimbot-V3/main/src/Aimbot.lua"))()


-- ⚙️ Services Roblox
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 📦 Variables ESP
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

-- 🧩 Fonctions ESP
local function CreateESP(player)
    if player == LocalPlayer then return end

    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = ESPSettings.Color
    Box.Thickness = 2
    Box.Filled = false

    local Tracer = Drawing.new("Line")
    Tracer.Visible = false
    Tracer.Color = ESPSettings.Color
    Tracer.Thickness = 2

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
    DistanceText.Color = Color3.fromRGB(255,255,255)
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
        for _, obj in pairs(ESPObjects[player]) do
            obj:Remove()
        end
        ESPObjects[player] = nil
    end
end

local function UpdateESP()
    if not ESPSettings.Enabled then
        for _, esp in pairs(ESPObjects) do
            for _, obj in pairs(esp) do
                obj.Visible = false
            end
        end
        return
    end

    for player, esp in pairs(ESPObjects) do
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") then
            for _, obj in pairs(esp) do obj.Visible = false end
            continue
        end

        local rootPart = char.HumanoidRootPart
        local head = char:FindFirstChild("Head")
        local humanoid = char.Humanoid

        local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
        if onScreen then
            local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
            local legPos = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
            local height = math.abs(headPos.Y - legPos.Y)
            local width = height / 2
            local color = ESPSettings.TeamColor and player.Team and player.Team.TeamColor.Color or ESPSettings.Color

            -- Box
            if ESPSettings.BoxEnabled then
                esp.Box.Size = Vector2.new(width, height)
                esp.Box.Position = Vector2.new(vector.X - width / 2, vector.Y - height / 2)
                esp.Box.Color = color
                esp.Box.Visible = true
            else
                esp.Box.Visible = false
            end

            -- Tracer
            if ESPSettings.TracerEnabled then
                esp.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                esp.Tracer.To = Vector2.new(vector.X, vector.Y)
                esp.Tracer.Color = color
                esp.Tracer.Visible = true
            else
                esp.Tracer.Visible = false
            end

            -- Text
            local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
                and (LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude or 0

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
                local hpPercent = health / maxHealth
                esp.HealthText.Text = string.format("%d/%d HP", health, maxHealth)
                esp.HealthText.Color = Color3.fromRGB(255 - 255 * hpPercent, 255 * hpPercent, 0)
                esp.HealthText.Position = Vector2.new(vector.X, vector.Y + height / 2 + 20)
                esp.HealthText.Visible = true
            else
                esp.HealthText.Visible = false
            end
        else
            for _, obj in pairs(esp) do obj.Visible = false end
        end
    end
end


-- 🔁 Boucle d’update
RunService.RenderStepped:Connect(UpdateESP)

-- 🔄 Création/clean des ESP
for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

-- 🪟 Interface RAYFIELD
local Window = Rayfield:CreateWindow({
   Name = "THCrb Script Hub",
   LoadingTitle = "THCrb Script Hub",
   LoadingSubtitle = "by THCrb",
})


-- UI Aimbot
local AimbotTab = Window:CreateTab("Aimbot", "target")
AimbotTab:CreateToggle({
   Name = "Activer Aimbot",
   CurrentValue = false,
   Callback = function(Value)
      Aimbot.Load()
   end
})

local ESPTab = Window:CreateTab("ESP", "eye")

ESPTab:CreateToggle({
   Name = "Activer ESP",
   CurrentValue = false,
   Callback = function(Value)
      ESPSettings.Enabled = Value
   end
})

ESPTab:CreateToggle({
   Name = "Tracer Lines",
   CurrentValue = false,
   Callback = function(Value)
      ESPSettings.TracerEnabled = Value
   end
})

ESPTab:CreateToggle({
   Name = "Afficher les boîtes",
   CurrentValue = true,
   Callback = function(Value)
      ESPSettings.BoxEnabled = Value
   end
})

ESPTab:CreateToggle({
   Name = "Afficher les noms",
   CurrentValue = true,
   Callback = function(Value)
      ESPSettings.ShowName = Value
   end
})

ESPTab:CreateToggle({
   Name = "Afficher la distance",
   CurrentValue = true,
   Callback = function(Value)
      ESPSettings.ShowDistance = Value
   end
})

ESPTab:CreateToggle({
   Name = "Afficher la santé",
   CurrentValue = true,
   Callback = function(Value)
      ESPSettings.ShowHealth = Value
   end
})

ESPTab:CreateColorPicker({
   Name = "Couleur ESP",
   Color = ESPSettings.Color,
   Callback = function(Value)
      ESPSettings.Color = Value
   end
})

local MiscTab = Window:CreateTab("Misc", "moon")

local ColorPicker = MiscTab:CreateColorPicker({
    Name = "Couleur du Menu",
    Color = Color3.fromRGB(0, 170, 255),
    Flag = "MenuColor",

    Callback = function(Value)
        -- On change la couleur du menu en direct
        Rayfield:ChangeColor("Main", Value)
    end
})

MiscTab:CreateButton({
    Name = "JOIN DISCORD",
    Callback = function()
        setclipboard("https://discord.gg/thcfr")
    end
})

-- ✅ Notification
Rayfield:Notify({
   Title = "THCrb Script Hub",
   Content = "ESP Module chargé avec succès !",
   Duration = 4,
   Image = "eye"
})

-- 🎹 Touche pour cacher/montrer le menu
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input, gpe)
   if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
      Rayfield:Toggle()
   end
end)
