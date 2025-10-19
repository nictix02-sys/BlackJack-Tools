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
