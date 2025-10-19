local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()

-- Création de la fenêtre
local Window = OrionLib:MakeWindow({
    Name = "Mon Menu",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "MonMenu"
})

-- Création d'un onglet
local Tab = Window:MakeTab({
    Name = "Principal",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Ajout d'une section
local Section = Tab:AddSection({
    Name = "Bienvenue"
})

-- Initialisation (toujours à la fin)
OrionLib:Init()