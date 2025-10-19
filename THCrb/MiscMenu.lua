local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()

-- Création de la fenêtre principale
local Window = OrionLib:MakeWindow({
    Name = "THC Menu",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "OrionTest"
})

-- Création de l'onglet Utilities
local Tab = Window:MakeTab({
    Name = "Utilities",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Ajout d'une section Movement
local Section = Tab:AddSection({
    Name = "Movement"
})

-- ===================== VARIABLES GLOBALES =====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local FlyEnabled = false
local NoClipEnabled = false
local FlySpeed = 50

-- ===================== FONCTION FLY =====================
local FlyConnection
local function ToggleFly(state)
    FlyEnabled = state
    
    if FlyEnabled then
        local Character = LocalPlayer.Character
        local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
        
        if not HumanoidRootPart then return end
        
        local BodyVelocity = Instance.new("BodyVelocity")
        BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        BodyVelocity.Parent = HumanoidRootPart
        
        FlyConnection = RunService.Heartbeat:Connect(function()
            if not FlyEnabled then return end
            
            local Character = LocalPlayer.Character
            local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
            local Humanoid = Character and Character:FindFirstChild("Humanoid")
            
            if not HumanoidRootPart or not Humanoid then return end
            
            local MoveDirection = Vector3.new(0, 0, 0)
            
            -- Contrôles de déplacement
            if UIS:IsKeyDown(Enum.KeyCode.W) then
                MoveDirection = MoveDirection + (workspace.CurrentCamera.CFrame.LookVector)
            end
            if UIS:IsKeyDown(Enum.KeyCode.S) then
                MoveDirection = MoveDirection - (workspace.CurrentCamera.CFrame.LookVector)
            end
            if UIS:IsKeyDown(Enum.KeyCode.A) then
                MoveDirection = MoveDirection - (workspace.CurrentCamera.CFrame.RightVector)
            end
            if UIS:IsKeyDown(Enum.KeyCode.D) then
                MoveDirection = MoveDirection + (workspace.CurrentCamera.CFrame.RightVector)
            end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then
                MoveDirection = MoveDirection + Vector3.new(0, 1, 0)
            end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
                MoveDirection = MoveDirection - Vector3.new(0, 1, 0)
            end
            
            BodyVelocity.Velocity = MoveDirection * FlySpeed
        end)
    else
        if FlyConnection then
            FlyConnection:Disconnect()
        end
        
        local Character = LocalPlayer.Character
        local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
        
        if HumanoidRootPart then
            local BodyVelocity = HumanoidRootPart:FindFirstChildOfClass("BodyVelocity")
            if BodyVelocity then
                BodyVelocity:Destroy()
            end
        end
    end
end

-- ===================== FONCTION NOCLIP =====================
local NoClipConnection
local function ToggleNoClip(state)
    NoClipEnabled = state
    
    if NoClipEnabled then
        NoClipConnection = RunService.Stepped:Connect(function()
            if not NoClipEnabled then return end
            
            local Character = LocalPlayer.Character
            if Character then
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if NoClipConnection then
            NoClipConnection:Disconnect()
        end
        
        local Character = LocalPlayer.Character
        if Character then
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- ===================== INTERFACE ORION =====================

-- Toggle Fly
Tab:AddToggle({
    Name = "Fly",
    Default = false,
    Callback = function(Value)
        ToggleFly(Value)
    end    
})

-- Slider vitesse Fly
Tab:AddSlider({
    Name = "Fly Speed",
    Min = 10,
    Max = 200,
    Default = 50,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 5,
    ValueName = "Speed",
    Callback = function(Value)
        FlySpeed = Value
    end    
})

-- Toggle NoClip
Tab:AddToggle({
    Name = "NoClip",
    Default = false,
    Callback = function(Value)
        ToggleNoClip(Value)
    end    
})

-- ⚠️ IMPORTANT: Init() doit être appelé EN DERNIER
OrionLib:Init()

-- Notification
OrionLib:MakeNotification({
    Name = "THC Menu",
    Content = "Menu chargé avec succès!",
    Image = "rbxassetid://4483345998",
    Time = 5
})

-- ===================== Touche RightShift pour ouvrir/fermer le menu =====================
local MenuVisible = true
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        MenuVisible = not MenuVisible
        OrionLib:ToggleUI()
    end
end)