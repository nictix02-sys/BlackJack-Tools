-- AdminMenu_Insert.lua (LocalScript)
-- Place : StarterPlayer > StarterPlayerScripts (ou StarterGui)
-- 100% client-side. Ouvre avec la touche Insert (Ins).

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInput = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- === CONFIG ===
local openKey = Enum.KeyCode.Insert   -- touche Ins pour ouvrir/fermer
local allowNonAdmins = true           -- true = menu accessible à tous (debug/test)
-- =============

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdminMenu_ClientOnly_Insert"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "Main"
mainFrame.Size = UDim2.new(0, 420, 0, 330)
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -165)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(28,28,30)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1,0,0,34)
titleBar.Position = UDim2.new(0,0,0,0)
titleBar.BackgroundColor3 = Color3.fromRGB(15,15,17)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.new(0,8,0,0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Menu Admin (Client-side) — Ins pour ouvrir"
titleLabel.TextColor3 = Color3.fromRGB(255,255,255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0,28,0,22)
closeBtn.Position = UDim2.new(1,-34,0,6)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.Font = Enum.Font.Gotham
closeBtn.TextSize = 18
closeBtn.TextColor3 = Color3.fromRGB(200,200,200)
closeBtn.Parent = titleBar

-- Left / Right columns
local leftColumn = Instance.new("Frame")
leftColumn.Size = UDim2.new(0,200,1,-50)
leftColumn.Position = UDim2.new(0,10,0,44)
leftColumn.BackgroundTransparency = 1
leftColumn.Parent = mainFrame

local rightColumn = Instance.new("Frame")
rightColumn.Size = UDim2.new(0,200,1,-50)
rightColumn.Position = UDim2.new(0,210,0,44)
rightColumn.BackgroundTransparency = 1
rightColumn.Parent = mainFrame

local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1,-16,0,26)
footer.Position = UDim2.new(0,8,1,-34)
footer.BackgroundTransparency = 1
footer.Text = "Client-side • Ins pour ouvrir/fermer"
footer.TextColor3 = Color3.fromRGB(170,170,170)
footer.Font = Enum.Font.Gotham
footer.TextSize = 12
footer.TextXAlignment = Enum.TextXAlignment.Left
footer.Parent = mainFrame

-- Helpers to create UI
local function makeButton(parent, y, text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,180,0,32)
    btn.Position = UDim2.new(0,10,0,10 + (y-1)*38)
    btn.BackgroundColor3 = Color3.fromRGB(45,45,48)
    btn.TextColor3 = Color3.fromRGB(235,235,235)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Text = text
    btn.Parent = parent
    return btn
end

local function makeTextBox(parent, y, placeholder)
    local tb = Instance.new("TextBox")
    tb.Size = UDim2.new(0,180,0,28)
    tb.Position = UDim2.new(0,10,0,10 + (y-1)*36)
    tb.BackgroundColor3 = Color3.fromRGB(40,40,42)
    tb.PlaceholderText = placeholder or ""
    tb.Text = ""
    tb.TextColor3 = Color3.fromRGB(240,240,240)
    tb.Font = Enum.Font.Gotham
    tb.TextSize = 14
    tb.Parent = parent
    return tb
end

-- Buttons / Inputs
local btnFly      = makeButton(leftColumn, 1, "Toggle Fly")
local btnNoclip   = makeButton(leftColumn, 2, "Toggle Noclip")
local btnSpeed    = makeButton(leftColumn, 3, "Set WalkSpeed")
local btnJump     = makeButton(leftColumn, 4, "Set JumpPower")
local btnTP       = makeButton(leftColumn, 5, "Teleport to Player")
local btnTool     = makeButton(leftColumn, 6, "Give Local Tool")
local btnFakeKick = makeButton(leftColumn, 7, "Fake Kick (client)")

local inputPlayer = makeTextBox(rightColumn, 1, "Nom du joueur (exact)")
local inputSpeed  = makeTextBox(rightColumn, 2, "WalkSpeed (ex: 16)")
local inputJump   = makeTextBox(rightColumn, 3, "JumpPower (ex: 50)")
local inputTool   = makeTextBox(rightColumn, 4, "Nom de l'outil (local)")

-- Notification helper
local function notify(title, text)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = 3;
        })
    end)
end

-- Character cache
local char, humanoid, hrp
local function cacheCharacter()
    char = LocalPlayer.Character
    if char then
        humanoid = char:FindFirstChildOfClass("Humanoid")
        hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    else
        humanoid = nil
        hrp = nil
    end
end
cacheCharacter()
LocalPlayer.CharacterAdded:Connect(cacheCharacter)

-- Fly
local flyEnabled = false
local flyBV, flyBG
local flySpeed = 100
local function enableFly()
    if not hrp then notify("Fly","Pas de personnage") return end
    flyBV = Instance.new("BodyVelocity"); flyBV.MaxForce = Vector3.new(1e5,1e5,1e5); flyBV.Velocity = Vector3.new(0,0,0); flyBV.Parent = hrp
    flyBG = Instance.new("BodyGyro"); flyBG.MaxTorque = Vector3.new(1e5,1e5,1e5); flyBG.CFrame = hrp.CFrame; flyBG.Parent = hrp
    flyEnabled = true; notify("Fly","Activé (client)")
end
local function disableFly()
    if flyBV then flyBV:Destroy(); flyBV = nil end
    if flyBG then flyBG:Destroy(); flyBG = nil end
    flyEnabled = false; notify("Fly","Désactivé")
end

-- Noclip
local noclipEnabled = false
local function setNoclip(v)
    if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            p.CanCollide = not v
        end
    end
    noclipEnabled = v
    notify("Noclip", v and "Activé (client)" or "Désactivé")
end

-- Teleport
local function teleportTo(name)
    if not hrp then notify("TP","Pas de personnage") return end
    local t = Players:FindFirstChild(name)
    if not t or not t.Character or not t.Character:FindFirstChild("HumanoidRootPart") then notify("TP","Joueur introuvable") return end
    hrp.CFrame = t.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
    notify("TP","Téléporté vers "..name)
end

-- Give local tool
local function giveLocalTool(name)
    local backpack = LocalPlayer:FindFirstChild("Backpack") or LocalPlayer:WaitForChild("Backpack")
    local tool = Instance.new("Tool")
    tool.Name = (name ~= "" and name) or ("LocalTool_"..math.random(1000,9999))
    tool.RequiresHandle = false
    tool.Parent = backpack
    notify("Tool","Outil local ajouté : "..tool.Name)
end

-- Fake kick
local function fakeKick()
    notify("Kick","Simulation de kick (client-side)")
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1,0,1,0); overlay.Position = UDim2.new(0,0,0,0)
    overlay.BackgroundColor3 = Color3.new(0,0,0); overlay.BackgroundTransparency = 1
    overlay.Parent = screenGui
    for i = 1, 12 do overlay.BackgroundTransparency = 1 - i*0.08; wait(0.035) end
    overlay:Destroy()
end

-- Set walk/jump
local function setWalkSpeed(v)
    if humanoid and tonumber(v) then humanoid.WalkSpeed = tonumber(v); notify("WalkSpeed","Réglé à "..v) else notify("WalkSpeed","Valeur invalide") end
end
local function setJumpPower(v)
    if humanoid and tonumber(v) then humanoid.JumpPower = tonumber(v); notify("JumpPower","Réglé à "..v) else notify("JumpPower","Valeur invalide") end
end

-- Button connections
btnFly.MouseButton1Click:Connect(function() cacheCharacter(); if flyEnabled then disableFly() else enableFly() end end)
btnNoclip.MouseButton1Click:Connect(function() cacheCharacter(); setNoclip(not noclipEnabled) end)
btnSpeed.MouseButton1Click:Connect(function() setWalkSpeed(inputSpeed.Text) end)
btnJump.MouseButton1Click:Connect(function() setJumpPower(inputJump.Text) end)
btnTP.MouseButton1Click:Connect(function() teleportTo(inputPlayer.Text) end)
btnTool.MouseButton1Click:Connect(function() giveLocalTool(inputTool.Text) end)
btnFakeKick.MouseButton1Click:Connect(fakeKick)
closeBtn.MouseButton1Click:Connect(function() mainFrame.Visible = false end)

-- Drag window
local dragging, dragStart, startPos = false, nil, nil
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = mainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging and dragStart and startPos then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Stepped loop: noclip upkeep + fly movement
RunService.Stepped:Connect(function()
    if noclipEnabled and char then
        for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
    end
    if flyEnabled and hrp then
        local cam = workspace.CurrentCamera
        local dir = Vector3.new(0,0,0)
        local keys = {
            forward = UserInput:IsKeyDown(Enum.KeyCode.W),
            back = UserInput:IsKeyDown(Enum.KeyCode.S),
            left = UserInput:IsKeyDown(Enum.KeyCode.A),
            right = UserInput:IsKeyDown(Enum.KeyCode.D),
            up = UserInput:IsKeyDown(Enum.KeyCode.Space),
            down = UserInput:IsKeyDown(Enum.KeyCode.LeftControl) or UserInput:IsKeyDown(Enum.KeyCode.RightControl),
        }
        if keys.forward then dir = dir + cam.CFrame.LookVector end
        if keys.back then dir = dir - cam.CFrame.LookVector end
        if keys.left then dir = dir - cam.CFrame.RightVector end
        if keys.right then dir = dir + cam.CFrame.RightVector end
        if keys.up then dir = dir + Vector3.new(0,1,0) end
        if keys.down then dir = dir - Vector3.new(0,1,0) end

        if flyBV then
            flyBV.Velocity = (dir.Magnitude > 0) and (dir.Unit * flySpeed) or Vector3.new(0,0,0)
        end
        if flyBG then flyBG.CFrame = cam.CFrame end
    end
end)

-- Keybind to open/close
UserInput.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == openKey then
        if not allowNonAdmins then
            -- ici tu pourrais vérifier une whitelist si nécessaire
            notify("AdminMenu", "Accès restreint")
            return
        end
        mainFrame.Visible = not mainFrame.Visible
    end
end)

-- Info on start
notify("AdminMenu", "Appuie sur Ins pour ouvrir le menu (client-side)")
