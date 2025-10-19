-- Menu d'Administration Client-Side - Style RageUI
-- À placer dans StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

-- Variables pour les fonctionnalités
local flying = false
local noclipping = false
local flySpeed = 50
local flyConnection

-- Fonction de notification
local function notify(title, text)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 2
        })
    end)
end

-- Création du ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdminMenu"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Frame principal
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 500, 0, 450)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui

-- UICorner pour le frame principal
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

-- Barre de titre
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = Color3.fromRGB(138, 43, 226) -- Violet RageUI
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

-- Fix pour les coins de la barre de titre
local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0, 12)
titleFix.Position = UDim2.new(0, 0, 1, -12)
titleFix.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar

-- Titre
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, -20, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⚡ ADMIN MENU"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 24
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Bouton de fermeture
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 40, 0, 40)
closeButton.Position = UDim2.new(1, -45, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeButton.Text = "✕"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 20
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.BorderSizePixel = 0
closeButton.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

-- Container pour les boutons
local buttonContainer = Instance.new("ScrollingFrame")
buttonContainer.Name = "ButtonContainer"
buttonContainer.Size = UDim2.new(1, -30, 1, -80)
buttonContainer.Position = UDim2.new(0, 15, 0, 65)
buttonContainer.BackgroundTransparency = 1
buttonContainer.BorderSizePixel = 0
buttonContainer.ScrollBarThickness = 6
buttonContainer.ScrollBarImageColor3 = Color3.fromRGB(138, 43, 226)
buttonContainer.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 12)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = buttonContainer

-- Fonction pour créer un bouton
local function createButton(parent, index, text, description, color)
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Name = "Button_" .. index
    buttonFrame.Size = UDim2.new(1, 0, 0, 70)
    buttonFrame.BackgroundColor3 = color
    buttonFrame.BorderSizePixel = 0
    buttonFrame.LayoutOrder = index
    buttonFrame.Parent = parent
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 10)
    buttonCorner.Parent = buttonFrame
    
    local button = Instance.new("TextButton")
    button.Name = "Button"
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.Parent = buttonFrame
    
    local buttonText = Instance.new("TextLabel")
    buttonText.Name = "ButtonText"
    buttonText.Size = UDim2.new(1, -20, 0, 25)
    buttonText.Position = UDim2.new(0, 10, 0, 8)
    buttonText.BackgroundTransparency = 1
    buttonText.Text = text
    buttonText.Font = Enum.Font.GothamBold
    buttonText.TextSize = 18
    buttonText.TextColor3 = Color3.fromRGB(255, 255, 255)
    buttonText.TextXAlignment = Enum.TextXAlignment.Left
    buttonText.Parent = buttonFrame
    
    local descText = Instance.new("TextLabel")
    descText.Name = "Description"
    descText.Size = UDim2.new(1, -20, 0, 20)
    descText.Position = UDim2.new(0, 10, 0, 38)
    descText.BackgroundTransparency = 1
    descText.Text = description
    descText.Font = Enum.Font.Gotham
    descText.TextSize = 14
    descText.TextColor3 = Color3.fromRGB(200, 200, 200)
    descText.TextXAlignment = Enum.TextXAlignment.Left
    descText.Parent = buttonFrame
    
    -- Hover effect
    button.MouseEnter:Connect(function()
        local tween = TweenService:Create(buttonFrame, TweenInfo.new(0.2), {
            Size = UDim2.new(1, 10, 0, 75),
            BackgroundColor3 = Color3.new(color.R * 1.2, color.G * 1.2, color.B * 1.2)
        })
        tween:Play()
    end)
    
    button.MouseLeave:Connect(function()
        local tween = TweenService:Create(buttonFrame, TweenInfo.new(0.2), {
            Size = UDim2.new(1, 0, 0, 70),
            BackgroundColor3 = color
        })
        tween:Play()
    end)
    
    return button
end

-- Fonction Fly
local function toggleFly()
    flying = not flying
    
    if flying then
        local character = player.Character
        if not character then return end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        
        if not humanoid or not rootPart then return end
        
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bodyVelocity.Parent = rootPart
        
        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bodyGyro.CFrame = rootPart.CFrame
        bodyGyro.Parent = rootPart
        
        flyConnection = RunService.Heartbeat:Connect(function()
            if not flying then return end
            
            local moveDirection = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDirection = moveDirection + camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDirection = moveDirection - camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDirection = moveDirection - camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDirection = moveDirection + camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDirection = moveDirection + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                moveDirection = moveDirection - Vector3.new(0, 1, 0)
            end
            
            bodyVelocity.Velocity = moveDirection * flySpeed
            bodyGyro.CFrame = camera.CFrame
        end)
        
        notify("Fly Activé", "Utilisez WASD + Space/Shift pour voler")
    else
        if flyConnection then
            flyConnection:Disconnect()
        end
        
        local character = player.Character
        if character then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                for _, v in pairs(rootPart:GetChildren()) do
                    if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then
                        v:Destroy()
                    end
                end
            end
        end
        
        notify("Fly Désactivé", "Mode vol désactivé")
    end
end

-- Fonction Noclip
local function toggleNoclip()
    noclipping = not noclipping
    
    if noclipping then
        RunService.Stepped:Connect(function()
            if not noclipping then return end
            
            local character = player.Character
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
        
        notify("Noclip Activé", "Vous pouvez traverser les murs")
    else
        notify("Noclip Désactivé", "Collisions normales restaurées")
    end
end

-- Fonction TP vers joueur
local function teleportToPlayer()
    local players = Players:GetPlayers()
    local otherPlayers = {}
    
    for _, p in ipairs(players) do
        if p ~= player then
            table.insert(otherPlayers, p)
        end
    end
    
    if #otherPlayers > 0 then
        local randomPlayer = otherPlayers[math.random(1, #otherPlayers)]
        local character = player.Character
        local targetChar = randomPlayer.Character
        
        if character and targetChar then
            local hrp = character:FindFirstChild("HumanoidRootPart")
            local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
            
            if hrp and targetHrp then
                hrp.CFrame = targetHrp.CFrame + Vector3.new(0, 3, 0)
                notify("Téléportation", "Téléporté vers " .. randomPlayer.Name)
                return
            end
        end
    end
    
    notify("Erreur", "Aucun joueur disponible")
end

-- Fonction Give Tool
local function giveTool()
    local tool = Instance.new("Tool")
    tool.Name = "Admin Tool"
    tool.RequiresHandle = false
    tool.Parent = player.Backpack
    
    notify("Tool Donné", "Admin Tool ajouté à votre inventaire")
end

-- Création des boutons
local flyBtn = createButton(buttonContainer, 1, "🚀 Fly Mode", "Permet de voler en client-side", Color3.fromRGB(52, 152, 219))
local noclipBtn = createButton(buttonContainer, 2, "👻 Noclip", "Passe à travers les murs", Color3.fromRGB(46, 204, 113))
local tpBtn = createButton(buttonContainer, 3, "📍 TP Player", "Téléporte vers un joueur aléatoire", Color3.fromRGB(231, 76, 60))
local toolBtn = createButton(buttonContainer, 4, "🔧 Give Tool", "Donne un outil local", Color3.fromRGB(241, 196, 15))

-- Connexions des boutons
flyBtn.MouseButton1Click:Connect(toggleFly)
noclipBtn.MouseButton1Click:Connect(toggleNoclip)
tpBtn.MouseButton1Click:Connect(teleportToPlayer)
toolBtn.MouseButton1Click:Connect(giveTool)

-- Bouton fermeture
closeButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

-- Drag system
local dragging = false
local dragInput, mousePos, framePos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        mousePos = input.Position
        framePos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        mainFrame.Position = UDim2.new(
            framePos.X.Scale,
            framePos.X.Offset + delta.X,
            framePos.Y.Scale,
            framePos.Y.Offset + delta.Y
        )
    end
end)

-- Toggle menu avec Insert
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

-- Notification de démarrage
wait(1)
notify("Admin Menu", "Appuyez sur Insert pour ouvrir le menu")

print("Admin Menu chargé avec succès!")