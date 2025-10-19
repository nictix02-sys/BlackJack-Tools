-- ===================== VARIABLES GLOBALES =====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local FlyEnabled = false
local NoClipEnabled = false
local FlySpeed = 50
local FlyConnection
local NoClipConnection

-- ===================== MODULE FLY =====================
local Fly = {}

function Fly.On()
    if FlyEnabled then return end
    FlyEnabled = true
    
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
end

function Fly.Off()
    if not FlyEnabled then return end
    FlyEnabled = false
    
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

function Fly.Toggle()
    if FlyEnabled then
        Fly.Off()
    else
        Fly.On()
    end
end

function Fly.Speed(speed)
    FlySpeed = speed
end

-- ===================== MODULE NOCLIP =====================
local NoClip = {}

function NoClip.On()
    if NoClipEnabled then return end
    NoClipEnabled = true
    
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
end

function NoClip.Off()
    if not NoClipEnabled then return end
    NoClipEnabled = false
    
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

function NoClip.Toggle()
    if NoClipEnabled then
        NoClip.Off()
    else
        NoClip.On()
    end
end

-- ===================== RETOUR DES MODULES =====================
return {
    Fly = Fly,
    NoClip = NoClip
}