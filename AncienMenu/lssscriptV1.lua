-- LocalScript unique (StarterPlayerScripts ou StarterGui)

--== Services ==--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

--== Config ESP ==--
local ESP = {
    Enabled = true,
    Color = Color3.fromRGB(128, 0, 255),
    OutlineColor = Color3.fromRGB(255, 255, 255),
    MaxDistance = 250,
    ShowInfo = true,
    ShowTeams = true,
    ShowHealth = true,
    ShowDistance = true
}

local COLOR_CYCLE = {
    {name="🔮 Violet", color=Color3.fromRGB(128,0,255)},
    {name="🌿 Vert",   color=Color3.fromRGB(0,255,100)},
    {name="🔥 Rouge",  color=Color3.fromRGB(255,64,64)},
    {name="💎 Cyan",   color=Color3.fromRGB(64,200,255)},
    {name="⭐ Jaune",  color=Color3.fromRGB(255,220,64)},
    {name="❄️ Blanc",  color=Color3.fromRGB(255,255,255)},
    {name="🌸 Rose",   color=Color3.fromRGB(255,128,255)},
    {name="🍊 Orange", color=Color3.fromRGB(255,140,64)}
}
local colorIndex = 1

--== Utility Functions ==--
local function safeWait(instance, name, timeout)
    return instance:WaitForChild(name, timeout or 5)
end

local function getHumanoidRootPart(character)
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid(character)
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function distanceBetweenCharacters(a, b)
    local hrpA = getHumanoidRootPart(a)
    local hrpB = getHumanoidRootPart(b)
    if not hrpA or not hrpB then return math.huge end
    return (hrpA.Position - hrpB.Position).Magnitude
end

local function createTween(obj, duration, props, style, direction)
    return TweenService:Create(obj, TweenInfo.new(
        duration or 0.3, 
        style or Enum.EasingStyle.Quart, 
        direction or Enum.EasingDirection.Out
    ), props)
end

--== ESP Functions ==--
local function ensureHighlight(character)
    if not character then return end
    local hl = character:FindFirstChild("AuraHighlight")
    if not hl then
        hl = Instance.new("Highlight")
        hl.Name = "AuraHighlight"
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.FillTransparency = 0.4
        hl.OutlineTransparency = 0.1
        hl.Adornee = character
        hl.Parent = character
    end
    return hl
end

local function ensureInfoBillboard(character, player)
    if not character then return end
    local gui = character:FindFirstChild("ESPInfo")
    if not gui then
        gui = Instance.new("BillboardGui")
        gui.Name = "ESPInfo"
        gui.Size = UDim2.new(0, 280, 0, 90)
        gui.StudsOffset = Vector3.new(0, 4, 0)
        gui.AlwaysOnTop = true
        gui.MaxDistance = 1000
        gui.Parent = character

        -- Background frame with modern design
        local bg = Instance.new("Frame")
        bg.Name = "Background"
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
        bg.BackgroundTransparency = 0.2
        bg.BorderSizePixel = 0
        bg.Parent = gui

        local bgCorner = Instance.new("UICorner")
        bgCorner.CornerRadius = UDim.new(0, 12)
        bgCorner.Parent = bg

        local bgStroke = Instance.new("UIStroke")
        bgStroke.Color = Color3.fromRGB(100, 100, 150)
        bgStroke.Transparency = 0.5
        bgStroke.Thickness = 2
        bgStroke.Parent = bg

        -- Gradient overlay
        local gradient = Instance.new("UIGradient")
        gradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 255))
        }
        gradient.Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0.7),
            NumberSequenceKeypoint.new(1, 0.9)
        }
        gradient.Rotation = 45
        gradient.Parent = bg

        -- Player name
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Size = UDim2.new(1, -16, 0, 30)
        nameLabel.Position = UDim2.new(0, 8, 0, 8)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 16
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.TextScaled = true
        nameLabel.Text = player.DisplayName
        nameLabel.Parent = bg

        -- Info label
        local infoLabel = Instance.new("TextLabel")
        infoLabel.Name = "InfoLabel"
        infoLabel.Size = UDim2.new(1, -16, 0, 50)
        infoLabel.Position = UDim2.new(0, 8, 0, 32)
        infoLabel.BackgroundTransparency = 1
        infoLabel.Font = Enum.Font.Gotham
        infoLabel.TextSize = 12
        infoLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        infoLabel.TextXAlignment = Enum.TextXAlignment.Left
        infoLabel.TextYAlignment = Enum.TextYAlignment.Top
        infoLabel.TextWrapped = true
        infoLabel.Text = ""
        infoLabel.Parent = bg
    end
    return gui
end

local function updateTargetVisual(targetPlayer)
    local lpChar = LocalPlayer.Character
    local tpChar = targetPlayer and targetPlayer.Character
    if not lpChar or not tpChar then return end

    local d = distanceBetweenCharacters(lpChar, tpChar)
    local inRange = d <= ESP.MaxDistance

    -- Highlight
    local hl = ensureHighlight(tpChar)
    if hl then
        hl.Enabled = ESP.Enabled and inRange
        hl.FillColor = ESP.Color
        hl.OutlineColor = ESP.OutlineColor
    end

    -- Billboard Info
    if ESP.ShowInfo then
        local infoGui = ensureInfoBillboard(tpChar, targetPlayer)
        if infoGui then
            infoGui.Enabled = ESP.Enabled and inRange
            
            local bg = infoGui:FindFirstChild("Background")
            local infoLabel = bg and bg:FindFirstChild("InfoLabel")
            
            if infoLabel then
                local hum = getHumanoid(tpChar)
                local hp = hum and math.floor(hum.Health) or 0
                local maxHp = hum and math.floor(hum.MaxHealth) or 100
                local teamName = (targetPlayer.Team and targetPlayer.Team.Name) or "Sans équipe"
                
                local infoText = ""
                if ESP.ShowDistance then
                    infoText = infoText .. string.format("📍 Distance: %dm\n", math.floor(d + 0.5))
                end
                if ESP.ShowHealth then
                    infoText = infoText .. string.format("❤️ Santé: %d/%d HP\n", hp, maxHp)
                end
                if ESP.ShowTeams then
                    infoText = infoText .. string.format("👥 Équipe: %s", teamName)
                end
                
                infoLabel.Text = infoText
            end
            
            -- Update stroke color to match ESP color
            local bgStroke = bg and bg:FindFirstChild("UIStroke")
            if bgStroke then
                bgStroke.Color = ESP.Color
            end
        end
    end
end

--== Main ESP Loop ==--
RunService.RenderStepped:Connect(function()
    if not LocalPlayer.Character then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            pcall(updateTargetVisual, plr)
        end
    end
end)

--== Character Management ==--
local function onCharacterAdded(char, player)
    task.wait(1) -- Wait for character to fully load
    if char.Parent then
        ensureHighlight(char)
        if ESP.ShowInfo then
            ensureInfoBillboard(char, player)
        end
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    if p.Character then onCharacterAdded(p.Character, p) end
    p.CharacterAdded:Connect(function(char) onCharacterAdded(char, p) end)
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(char) onCharacterAdded(char, p) end)
end)

--== UI Creation ==--
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ESP_Admin_UI_Premium"
screenGui.ResetOnSpawn = false
screenGui.Parent = safeWait(LocalPlayer, "PlayerGui")

-- Simple toggle with Insert key (no complex animations to avoid bugs)
screenGui.Enabled = false

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        screenGui.Enabled = not screenGui.Enabled
        print("Menu toggled:", screenGui.Enabled) -- Debug line
    end
end)

-- Main window with modern glassmorphism design
local main = Instance.new("Frame")
main.Name = "MainWindow"
main.Size = UDim2.new(0, 450, 0, 400)
main.Position = UDim2.new(0.5, -225, 0.5, -200)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
main.BackgroundTransparency = 0.1
main.BorderSizePixel = 0
main.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 20)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(100, 100, 150)
mainStroke.Transparency = 0.3
mainStroke.Thickness = 2
mainStroke.Parent = main

-- Glow effect
local glow = Instance.new("Frame")
glow.Name = "Glow"
glow.Size = UDim2.new(1, 20, 1, 20)
glow.Position = UDim2.new(0, -10, 0, -10)
glow.BackgroundColor3 = ESP.Color
glow.BackgroundTransparency = 0.8
glow.BorderSizePixel = 0
glow.ZIndex = -1
glow.Parent = main

local glowCorner = Instance.new("UICorner")
glowCorner.CornerRadius = UDim.new(0, 25)
glowCorner.Parent = glow

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 60)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
titleBar.BackgroundTransparency = 0.3
titleBar.BorderSizePixel = 0
titleBar.Parent = main

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 20)
titleCorner.Parent = titleBar

-- Hide bottom corners of title bar
local titleMask = Instance.new("Frame")
titleMask.Size = UDim2.new(1, 0, 0, 20)
titleMask.Position = UDim2.new(0, 0, 1, -20)
titleMask.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
titleMask.BackgroundTransparency = 0.3
titleMask.BorderSizePixel = 0
titleMask.Parent = titleBar

-- Title with icon and gradient
local title = Instance.new("TextLabel")
title.Text = "🎯 ESP ADMIN PANEL"
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.TextColor3 = Color3.fromRGB(220, 200, 255)
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -120, 1, 0)
title.Position = UDim2.new(0, 20, 0, 0)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

-- Status indicator
local statusFrame = Instance.new("Frame")
statusFrame.Size = UDim2.new(0, 80, 0, 30)
statusFrame.Position = UDim2.new(1, -100, 0.5, -15)
statusFrame.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
statusFrame.BackgroundTransparency = 0.2
statusFrame.BorderSizePixel = 0
statusFrame.Parent = titleBar

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 15)
statusCorner.Parent = statusFrame

local statusText = Instance.new("TextLabel")
statusText.Text = "ACTIF"
statusText.Font = Enum.Font.GothamBold
statusText.TextSize = 12
statusText.TextColor3 = Color3.fromRGB(255, 255, 255)
statusText.BackgroundTransparency = 1
statusText.Size = UDim2.new(1, 0, 1, 0)
statusText.Parent = statusFrame

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Text = "✕"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.BackgroundTransparency = 0.3
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -45, 0, 15)
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, 15)
closeBtnCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    screenGui.Enabled = false
end)

-- Drag functionality
local dragging = false
local dragStart, startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then 
                dragging = false 
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        updateDrag(input)
    end
end)

-- Tab system
local tabContainer = Instance.new("Frame")
tabContainer.Name = "TabContainer"
tabContainer.Size = UDim2.new(1, -40, 0, 50)
tabContainer.Position = UDim2.new(0, 20, 0, 70)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = main

local function createTab(text, icon, position)
    local tab = Instance.new("TextButton")
    tab.Name = text .. "Tab"
    tab.Size = UDim2.new(0, 120, 1, -10)
    tab.Position = position
    tab.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    tab.BackgroundTransparency = 0.3
    tab.BorderSizePixel = 0
    tab.Text = icon .. " " .. text
    tab.Font = Enum.Font.GothamBold
    tab.TextSize = 14
    tab.TextColor3 = Color3.fromRGB(255, 255, 255)
    tab.AutoButtonColor = false
    tab.Parent = tabContainer

    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 12)
    tabCorner.Parent = tab

    return tab
end

local espTab = createTab("ESP", "👁️", UDim2.new(0, 0, 0, 5))
local playersTab = createTab("Joueurs", "👥", UDim2.new(0, 130, 0, 5))
local settingsTab = createTab("Paramètres", "⚙️", UDim2.new(0, 260, 0, 5))

-- Content area
local contentArea = Instance.new("Frame")
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1, -40, 1, -140)
contentArea.Position = UDim2.new(0, 20, 0, 130)
contentArea.BackgroundTransparency = 1
contentArea.Parent = main

-- Create pages
local espPage = Instance.new("ScrollingFrame")
espPage.Name = "ESPPage"
espPage.Size = UDim2.new(1, 0, 1, 0)
espPage.BackgroundTransparency = 1
espPage.ScrollBarThickness = 6
espPage.ScrollBarImageTransparency = 0.5
espPage.CanvasSize = UDim2.new(0, 0, 0, 600)
espPage.Parent = contentArea

local playersPage = Instance.new("Frame")
playersPage.Name = "PlayersPage"
playersPage.Size = UDim2.new(1, 0, 1, 0)
playersPage.BackgroundTransparency = 1
playersPage.Visible = false
playersPage.Parent = contentArea

local settingsPage = Instance.new("ScrollingFrame")
settingsPage.Name = "SettingsPage"
settingsPage.Size = UDim2.new(1, 0, 1, 0)
settingsPage.BackgroundTransparency = 1
settingsPage.ScrollBarThickness = 6
settingsPage.ScrollBarImageTransparency = 0.5
settingsPage.CanvasSize = UDim2.new(0, 0, 0, 400)
settingsPage.Visible = false
settingsPage.Parent = contentArea

-- Tab switching
local currentTab = espTab
local function switchTab(newTab, newPage)
    -- Animate old tab out
    createTween(currentTab, 0.2, {BackgroundTransparency = 0.3}):Play()
    
    -- Animate new tab in
    createTween(newTab, 0.2, {BackgroundTransparency = 0.1}):Play()
    currentTab = newTab
    
    -- Hide all pages
    espPage.Visible = false
    playersPage.Visible = false
    settingsPage.Visible = false
    
    -- Show selected page
    newPage.Visible = true
end

espTab.MouseButton1Click:Connect(function() switchTab(espTab, espPage) end)
playersTab.MouseButton1Click:Connect(function() switchTab(playersTab, playersPage) end)
settingsTab.MouseButton1Click:Connect(function() switchTab(settingsTab, settingsPage) end)

-- Initialize first tab
switchTab(espTab, espPage)

-- Modern button creation function
local function createModernButton(parent, text, icon, size, position, callback)
    local button = Instance.new("TextButton")
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
    button.BackgroundTransparency = 0.2
    button.BorderSizePixel = 0
    button.Text = ""
    button.AutoButtonColor = false
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = button

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 80, 120)
    stroke.Transparency = 0.6
    stroke.Thickness = 1
    stroke.Parent = button

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = icon .. " " .. text
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = button

    -- Hover effects
    button.MouseEnter:Connect(function()
        createTween(button, 0.2, {BackgroundTransparency = 0.1}):Play()
        createTween(stroke, 0.2, {Transparency = 0.3}):Play()
    end)

    button.MouseLeave:Connect(function()
        createTween(button, 0.2, {BackgroundTransparency = 0.2}):Play()
        createTween(stroke, 0.2, {Transparency = 0.6}):Play()
    end)

    button.MouseButton1Click:Connect(function()
        -- Click animation
        createTween(button, 0.1, {Size = size * 0.95}):Play()
        task.wait(0.1)
        createTween(button, 0.1, {Size = size}):Play()
        
        if callback then callback(label) end
    end)

    return button, label
end

--== ESP PAGE CONTROLS ==--
local yPos = 20

-- ESP Toggle
local espToggle, espToggleLabel = createModernButton(
    espPage,
    "ESP: ACTIVÉ",
    "⚡",
    UDim2.new(1, -20, 0, 50),
    UDim2.new(0, 10, 0, yPos),
    function(label)
        ESP.Enabled = not ESP.Enabled
        label.Text = "⚡ ESP: " .. (ESP.Enabled and "ACTIVÉ" or "DÉSACTIVÉ")
        statusFrame.BackgroundColor3 = ESP.Enabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 100, 0)
        statusText.Text = ESP.Enabled and "ACTIF" or "INACTIF"
    end
)
yPos = yPos + 70

-- Distance Control
local distanceBtn, distanceLabel = createModernButton(
    espPage,
    "Distance: " .. ESP.MaxDistance .. "m",
    "📏",
    UDim2.new(1, -20, 0, 50),
    UDim2.new(0, 10, 0, yPos),
    function(label)
        ESP.MaxDistance = ESP.MaxDistance + 50
        if ESP.MaxDistance > 1000 then ESP.MaxDistance = 100 end
        label.Text = "📏 Distance: " .. ESP.MaxDistance .. "m"
    end
)
yPos = yPos + 70

-- Color Control
local colorBtn, colorLabel = createModernButton(
    espPage,
    "Couleur: " .. COLOR_CYCLE[colorIndex].name,
    "🎨",
    UDim2.new(1, -20, 0, 50),
    UDim2.new(0, 10, 0, yPos),
    function(label)
        colorIndex = colorIndex + 1
        if colorIndex > #COLOR_CYCLE then colorIndex = 1 end
        ESP.Color = COLOR_CYCLE[colorIndex].color
        label.Text = "🎨 " .. COLOR_CYCLE[colorIndex].name
        glow.BackgroundColor3 = ESP.Color
    end
)
yPos = yPos + 70

-- Info Toggle
local infoToggle, infoToggleLabel = createModernButton(
    espPage,
    "Informations: ACTIVÉES",
    "📊",
    UDim2.new(1, -20, 0, 50),
    UDim2.new(0, 10, 0, yPos),
    function(label)
        ESP.ShowInfo = not ESP.ShowInfo
        label.Text = "📊 Informations: " .. (ESP.ShowInfo and "ACTIVÉES" or "DÉSACTIVÉES")
    end
)
yPos = yPos + 70

-- Team Toggle
local teamToggle, teamToggleLabel = createModernButton(
    espPage,
    "Afficher équipes: ACTIVÉ",
    "👥",
    UDim2.new(1, -20, 0, 50),
    UDim2.new(0, 10, 0, yPos),
    function(label)
        ESP.ShowTeams = not ESP.ShowTeams
        label.Text = "👥 Afficher équipes: " .. (ESP.ShowTeams and "ACTIVÉ" or "DÉSACTIVÉ")
    end
)
yPos = yPos + 70

-- Health Toggle
local healthToggle, healthToggleLabel = createModernButton(
    espPage,
    "Afficher santé: ACTIVÉ",
    "❤️",
    UDim2.new(1, -20, 0, 50),
    UDim2.new(0, 10, 0, yPos),
    function(label)
        ESP.ShowHealth = not ESP.ShowHealth
        label.Text = "❤️ Afficher santé: " .. (ESP.ShowHealth and "ACTIVÉ" or "DÉSACTIVÉ")
    end
)

--== PLAYERS PAGE ==--
-- Player list setup
local playerListFrame = Instance.new("Frame")
playerListFrame.Size = UDim2.new(0.48, 0, 1, 0)
playerListFrame.Position = UDim2.new(0, 0, 0, 0)
playerListFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
playerListFrame.BackgroundTransparency = 0.3
playerListFrame.BorderSizePixel = 0
playerListFrame.Parent = playersPage

local playerListCorner = Instance.new("UICorner")
playerListCorner.CornerRadius = UDim.new(0, 12)
playerListCorner.Parent = playerListFrame

local playerScroll = Instance.new("ScrollingFrame")
playerScroll.Size = UDim2.new(1, -20, 1, -50)
playerScroll.Position = UDim2.new(0, 10, 0, 40)
playerScroll.BackgroundTransparency = 1
playerScroll.ScrollBarThickness = 4
playerScroll.ScrollBarImageTransparency = 0.5
playerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
playerScroll.Parent = playerListFrame

local playerListTitle = Instance.new("TextLabel")
playerListTitle.Size = UDim2.new(1, 0, 0, 30)
playerListTitle.Position = UDim2.new(0, 0, 0, 5)
playerListTitle.BackgroundTransparency = 1
playerListTitle.Text = "👥 Liste des Joueurs"
playerListTitle.Font = Enum.Font.GothamBold
playerListTitle.TextSize = 16
playerListTitle.TextColor3 = Color3.fromRGB(220, 200, 255)
playerListTitle.Parent = playerListFrame

local playerListLayout = Instance.new("UIListLayout")
playerListLayout.FillDirection = Enum.FillDirection.Vertical
playerListLayout.SortOrder = Enum.SortOrder.Name
playerListLayout.Padding = UDim.new(0, 5)
playerListLayout.Parent = playerScroll

-- Player detail panel
local playerDetailFrame = Instance.new("Frame")
playerDetailFrame.Size = UDim2.new(0.48, 0, 1, 0)
playerDetailFrame.Position = UDim2.new(0.52, 0, 0, 0)
playerDetailFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
playerDetailFrame.BackgroundTransparency = 0.3
playerDetailFrame.BorderSizePixel = 0
playerDetailFrame.Parent = playersPage

local playerDetailCorner = Instance.new("UICorner")
playerDetailCorner.CornerRadius = UDim.new(0, 12)
playerDetailCorner.Parent = playerDetailFrame

local detailTitle = Instance.new("TextLabel")
detailTitle.Size = UDim2.new(1, -20, 0, 30)
detailTitle.Position = UDim2.new(0, 10, 0, 5)
detailTitle.BackgroundTransparency = 1
detailTitle.Text = "🎯 Sélectionnez un joueur"
detailTitle.Font = Enum.Font.GothamBold
detailTitle.TextSize = 16
detailTitle.TextColor3 = Color3.fromRGB(220, 200, 255)
detailTitle.TextXAlignment = Enum.TextXAlignment.Left
detailTitle.Parent = playerDetailFrame

local playerInfoLabel = Instance.new("TextLabel")
playerInfoLabel.Size = UDim2.new(1, -20, 0, 120)
playerInfoLabel.Position = UDim2.new(0, 10, 0, 45)
playerInfoLabel.BackgroundTransparency = 1
playerInfoLabel.Text = "Aucun joueur sélectionné"
playerInfoLabel.Font = Enum.Font.Gotham
playerInfoLabel.TextSize = 14
playerInfoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
playerInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
playerInfoLabel.TextYAlignment = Enum.TextYAlignment.Top
playerInfoLabel.TextWrapped = true
playerInfoLabel.Parent = playerDetailFrame

-- Player action buttons
local actionY = 180
local spectateBtn, spectateLabel = createModernButton(
    playerDetailFrame,
    "Spectater",
    "👁️",
    UDim2.new(1, -20, 0, 40),
    UDim2.new(0, 10, 0, actionY),
    function(label)
        if currentSelectedPlayer and currentSelectedPlayer.Character then
            local hum = getHumanoid(currentSelectedPlayer.Character)
            if hum then
                Workspace.CurrentCamera.CameraSubject = hum
            end
        end
    end
)

actionY = actionY + 50
local teleportBtn, teleportLabel = createModernButton(
    playerDetailFrame,
    "Se téléporter",
    "⚡",
    UDim2.new(1, -20, 0, 40),
    UDim2.new(0, 10, 0, actionY),
    function(label)
        if currentSelectedPlayer and LocalPlayer.Character and currentSelectedPlayer.Character then
            local targetHRP = getHumanoidRootPart(currentSelectedPlayer.Character)
            local myHRP = getHumanoidRootPart(LocalPlayer.Character)
            if targetHRP and myHRP then
                myHRP.CFrame = targetHRP.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end
)

actionY = actionY + 50
local highlightBtn, highlightLabel = createModernButton(
    playerDetailFrame,
    "Toggle Highlight",
    "✨",
    UDim2.new(1, -20, 0, 40),
    UDim2.new(0, 10, 0, actionY),
    function(label)
        if currentSelectedPlayer and currentSelectedPlayer.Character then
            local hl = ensureHighlight(currentSelectedPlayer.Character)
            if hl then
                hl.Enabled = not hl.Enabled
            end
        end
    end
)

-- Player management functions
local currentSelectedPlayer = nil

local function createPlayerCard(player)
    local card = Instance.new("TextButton")
    card.Name = player.Name
    card.Size = UDim2.new(1, -10, 0, 45)
    card.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
    card.BackgroundTransparency = 0.3
    card.BorderSizePixel = 0
    card.Text = ""
    card.AutoButtonColor = false
    card.Parent = playerScroll

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 8)
    cardCorner.Parent = card

    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = Color3.fromRGB(80, 80, 120)
    cardStroke.Transparency = 0.7
    cardStroke.Thickness = 1
    cardStroke.Parent = card

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -40, 1, 0)
    nameLabel.Position = UDim2.new(0, 10, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.DisplayName .. " (@" .. player.Name .. ")"
    nameLabel.Font = Enum.Font.GothamMedium
    nameLabel.TextSize = 13
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = card

    local statusIcon = Instance.new("TextLabel")
    statusIcon.Size = UDim2.new(0, 20, 0, 20)
    statusIcon.Position = UDim2.new(1, -30, 0.5, -10)
    statusIcon.BackgroundTransparency = 1
    statusIcon.Text = "🟢"
    statusIcon.Font = Enum.Font.Gotham
    statusIcon.TextSize = 16
    statusIcon.Parent = card

    -- Hover effects
    card.MouseEnter:Connect(function()
        createTween(card, 0.2, {BackgroundTransparency = 0.2}):Play()
        createTween(cardStroke, 0.2, {Transparency = 0.4}):Play()
    end)

    card.MouseLeave:Connect(function()
        if currentSelectedPlayer ~= player then
            createTween(card, 0.2, {BackgroundTransparency = 0.3}):Play()
            createTween(cardStroke, 0.2, {Transparency = 0.7}):Play()
        end
    end)

    card.MouseButton1Click:Connect(function()
        -- Deselect previous
        if currentSelectedPlayer then
            local oldCard = playerScroll:FindFirstChild(currentSelectedPlayer.Name)
            if oldCard then
                createTween(oldCard, 0.2, {BackgroundTransparency = 0.3}):Play()
                local oldStroke = oldCard:FindFirstChild("UIStroke")
                if oldStroke then
                    createTween(oldStroke, 0.2, {Transparency = 0.7}):Play()
                end
            end
        end

        -- Select new
        currentSelectedPlayer = player
        createTween(card, 0.2, {BackgroundTransparency = 0.1}):Play()
        createTween(cardStroke, 0.2, {Transparency = 0.3}):Play()

        -- Update detail panel
        updatePlayerDetail(player)
    end)

    return card
end

local function updatePlayerDetail(player)
    if not player then
        detailTitle.Text = "🎯 Sélectionnez un joueur"
        playerInfoLabel.Text = "Aucun joueur sélectionné"
        return
    end

    detailTitle.Text = "🎯 " .. player.DisplayName
    
    local char = player.Character
    local teamName = (player.Team and player.Team.Name) or "Aucune équipe"
    local distance = "N/A"
    local health = "N/A"
    
    if LocalPlayer.Character and char then
        local d = distanceBetweenCharacters(LocalPlayer.Character, char)
        if d ~= math.huge then
            distance = math.floor(d + 0.5) .. "m"
        end
        
        local hum = getHumanoid(char)
        if hum then
            health = math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth) .. " HP"
        end
    end
    
    playerInfoLabel.Text = string.format(
        "📋 Nom: %s\n🆔 UserID: %d\n👥 Équipe: %s\n📍 Distance: %s\n❤️ Santé: %s\n⏰ Temps de jeu: %ds",
        player.Name,
        player.UserId,
        teamName,
        distance,
        health,
        math.floor((tick() - (player.PlayerScripts and player.PlayerScripts:GetAttribute("JoinTime") or tick())))
    )
end

local function rebuildPlayerList()
    -- Clear existing cards
    for _, child in ipairs(playerScroll:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    -- Add all players except local player
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            createPlayerCard(player)
        end
    end
    
    -- Update canvas size
    task.wait()
    playerScroll.CanvasSize = UDim2.new(0, 0, 0, playerListLayout.AbsoluteContentSize.Y + 10)
end

-- Player list events
Players.PlayerAdded:Connect(rebuildPlayerList)
Players.PlayerRemoving:Connect(function(player)
    if currentSelectedPlayer == player then
        currentSelectedPlayer = nil
        updatePlayerDetail(nil)
    end
    rebuildPlayerList()
end)

-- Update player detail in real time
RunService.Heartbeat:Connect(function()
    if currentSelectedPlayer then
        updatePlayerDetail(currentSelectedPlayer)
    end
end)

--== SETTINGS PAGE ==--
local settingsY = 20

-- Info section
local infoSection = Instance.new("TextLabel")
infoSection.Size = UDim2.new(1, -20, 0, 40)
infoSection.Position = UDim2.new(0, 10, 0, settingsY)
infoSection.BackgroundTransparency = 1
infoSection.Text = "⚙️ Paramètres Avancés"
infoSection.Font = Enum.Font.GothamBold
infoSection.TextSize = 18
infoSection.TextColor3 = Color3.fromRGB(220, 200, 255)
infoSection.TextXAlignment = Enum.TextXAlignment.Left
infoSection.Parent = settingsPage
settingsY = settingsY + 60

-- Distance toggle
local distanceToggle, distanceToggleLabel = createModernButton(
    settingsPage,
    "Afficher distance: ACTIVÉ",
    "📏",
    UDim2.new(1, -20, 0, 50),
    UDim2.new(0, 10, 0, settingsY),
    function(label)
        ESP.ShowDistance = not ESP.ShowDistance
        label.Text = "📏 Afficher distance: " .. (ESP.ShowDistance and "ACTIVÉ" or "DÉSACTIVÉ")
    end
)
settingsY = settingsY + 70

-- Performance mode
local performanceMode = false
local perfToggle, perfToggleLabel = createModernButton(
    settingsPage,
    "Mode Performance: DÉSACTIVÉ",
    "⚡",
    UDim2.new(1, -20, 0, 50),
    UDim2.new(0, 10, 0, settingsY),
    function(label)
        performanceMode = not performanceMode
        label.Text = "⚡ Mode Performance: " .. (performanceMode and "ACTIVÉ" or "DÉSACTIVÉ")
        -- Adjust update frequency based on performance mode
    end
)
settingsY = settingsY + 70

-- Reset all settings
local resetBtn, resetLabel = createModernButton(
    settingsPage,
    "Réinitialiser les paramètres",
    "🔄",
    UDim2.new(1, -20, 0, 50),
    UDim2.new(0, 10, 0, settingsY),
    function(label)
        ESP.Enabled = true
        ESP.MaxDistance = 250
        ESP.ShowInfo = true
        ESP.ShowTeams = true
        ESP.ShowHealth = true
        ESP.ShowDistance = true
        colorIndex = 1
        ESP.Color = COLOR_CYCLE[colorIndex].color
        
        -- Update all UI elements
        espToggleLabel.Text = "⚡ ESP: ACTIVÉ"
        distanceLabel.Text = "📏 Distance: " .. ESP.MaxDistance .. "m"
        colorLabel.Text = "🎨 " .. COLOR_CYCLE[colorIndex].name
        infoToggleLabel.Text = "📊 Informations: ACTIVÉES"
        teamToggleLabel.Text = "👥 Afficher équipes: ACTIVÉ"
        healthToggleLabel.Text = "❤️ Afficher santé: ACTIVÉ"
        distanceToggleLabel.Text = "📏 Afficher distance: ACTIVÉ"
        
        statusFrame.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        statusText.Text = "ACTIF"
        glow.BackgroundColor3 = ESP.Color
    end
)

-- Initialize player list
rebuildPlayerList()

-- Instruction text at bottom
local instructionText = Instance.new("TextLabel")
instructionText.Size = UDim2.new(1, 0, 0, 30)
instructionText.Position = UDim2.new(0, 0, 1, -35)
instructionText.BackgroundTransparency = 1
instructionText.Text = "💡 Appuyez sur [Insert] pour ouvrir/fermer le menu"
instructionText.Font = Enum.Font.Gotham
instructionText.TextSize = 12
instructionText.TextColor3 = Color3.fromRGB(150, 150, 170)
instructionText.Parent = main

-- Version info
local versionText = Instance.new("TextLabel")
versionText.Size = UDim2.new(0, 100, 0, 20)
versionText.Position = UDim2.new(1, -110, 1, -25)
versionText.BackgroundTransparency = 1
versionText.Text = "v2.0 Premium"
versionText.Font = Enum.Font.GothamBold
versionText.TextSize = 10
versionText.TextColor3 = Color3.fromRGB(100, 100, 120)
versionText.Parent = main

-- Startup message
task.spawn(function()
    task.wait(1)
    local startupMsg = Instance.new("TextLabel")
    startupMsg.Size = UDim2.new(0, 300, 0, 50)
    startupMsg.Position = UDim2.new(0.5, -150, 0, 50)
    startupMsg.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    startupMsg.BackgroundTransparency = 0.2
    startupMsg.BorderSizePixel = 0
    startupMsg.Text = "🎯 ESP Admin chargé avec succès!\nAppuyez sur [Insert] pour ouvrir"
    startupMsg.Font = Enum.Font.GothamBold
    startupMsg.TextSize = 14
    startupMsg.TextColor3 = Color3.fromRGB(0, 255, 100)
    startupMsg.Parent = screenGui
    
    local startupCorner = Instance.new("UICorner")
    startupCorner.CornerRadius = UDim.new(0, 10)
    startupCorner.Parent = startupMsg
    
    -- Fade in
    startupMsg.BackgroundTransparency = 1
    startupMsg.TextTransparency = 1
    
    createTween(startupMsg, 0.5, {
        BackgroundTransparency = 0.2,
        TextTransparency = 0
    }):Play()
    
    -- Fade out after 3 seconds
    task.wait(3)
    createTween(startupMsg, 0.5, {
        BackgroundTransparency = 1,
        TextTransparency = 1
    }):Play()
    
    task.wait(0.5)
    startupMsg:Destroy()
end)