-- // LocalScript
-- // Menu Discord avec Rayfield UI

local discordLink = "https://discord.gg/TONCODE" -- 🔗 ton lien Discord ici

-- Chargement de la lib Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Uranium - Menu Discord",
    LoadingTitle = "Uranium",
    LoadingSubtitle = "by YourName",
    ConfigurationSaving = {
        Enabled = false
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false,
})

local MainTab = Window:CreateTab("Communauté", 4483362458) -- icône "community"
Rayfield:Notify({
    Title = "Bienvenue !",
    Content = "Merci de jouer sur Uranium ⚛️",
    Duration = 6,
    Image = 4483362458,
})

-- 🔘 Bouton pour rejoindre Discord
MainTab:CreateButton({
    Name = "🔗 Rejoindre le Discord",
    Callback = function()
        local success, err = pcall(function()
            if game:GetService("GuiService").OpenBrowserWindow then
                game:GetService("GuiService"):OpenBrowserWindow(discordLink)
            else
                setclipboard(discordLink)
                Rayfield:Notify({
                    Title = "Lien copié !",
                    Content = "Le lien Discord a été copié dans ton presse-papier.",
                    Duration = 5
                })
            end
        end)

        if not success then
            Rayfield:Notify({
                Title = "Impossible d'ouvrir le lien",
                Content = "Ton client Roblox bloque l’ouverture automatique. Voici le lien : " .. discordLink,
                Duration = 8
            })
        end
    end,
})

-- 🧩 Option bonus : bouton copier uniquement
MainTab:CreateButton({
    Name = "📋 Copier le lien Discord",
    Callback = function()
        pcall(function() setclipboard(discordLink) end)
        Rayfield:Notify({
            Title = "Copié !",
            Content = "Le lien Discord est dans ton presse-papier.",
            Duration = 4
        })
    end,
})
