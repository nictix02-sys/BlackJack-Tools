local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Lib = loadstring(game:HttpGet('https://raw.githubusercontent.com/nictix02-sys/BlackJack-Tools/refs/heads/main/Fly.lua'))()
local Teleport = loadstring(game:HttpGet('https://raw.githubusercontent.com/nictix02-sys/BlackJack-Tools/refs/heads/main/TP.lua'))()

local Window = Rayfield:CreateWindow({
    Name = "Menu by Edaward_01",
    LoadingTitle = "Chargement...",
    LoadingSubtitle = "by Edaward_01",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "AncienMenu",
        FileName = "Settings"
    },
    Discord = {
        Enabled = false,
        Invite = "https://discord.gg/thcfr",
        RememberJoins = true
    },
    KeySystem = false
})

-- ONGLET FLY
local FlyTab = Window:CreateTab("Fly", "plane")

FlyTab:CreateToggle({
    Name = "Activer le Fly",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(Value)
        if Value then
            Lib.Fly.On()
        else
            Lib.Fly.Off()
        end
    end
})

FlyTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 200},
    Increment = 5,
    Suffix = "Speed",
    CurrentValue = 50,
    Flag = "FlySpeed",
    Callback = function(Value)
        Lib.Fly.Speed(Value)
    end,
})

-- ONGLET NOCLIP
local NoClipTab = Window:CreateTab("NoClip", "menu")

NoClipTab:CreateToggle({
    Name = "Activer le NoClip",
    CurrentValue = false,
    Flag = "NoClipToggle",
    Callback = function(Value)
        if Value then
            Lib.NoClip.On()
        else
            Lib.NoClip.Off()
        end
    end
})

-- ONGLET TELEPORTATION
local TeleportTab = Window:CreateTab("Teleportation", "moon-star")

local selectedPlayerName = nil

local PlayerDropdown = TeleportTab:CreateDropdown({
    Name = "Selectionner un joueur",
    Options = Teleport.GetPlayers(),
    CurrentOption = {"Aucun"},
    MultipleOptions = false,
    Flag = "PlayerDropdown",
    Callback = function(Option)
        selectedPlayerName = Option
        print("Joueur selectionne:", selectedPlayerName)
    end,
})

TeleportTab:CreateButton({
    Name = "Teleporter au joueur",
    Callback = function()
        if selectedPlayerName and selectedPlayerName ~= "" and selectedPlayerName ~= "Aucun" then
            local success = Teleport.ToPlayer(selectedPlayerName)
            if success then
                Rayfield:Notify({
                    Title = "Teleportation",
                    Content = "Teleporte a " .. selectedPlayerName,
                    Duration = 3,
                    Image = 4483345998,
                })
            else
                Rayfield:Notify({
                    Title = "Erreur",
                    Content = "Impossible de se teleporter",
                    Duration = 3,
                    Image = 4483345998,
                })
            end
        else
            Rayfield:Notify({
                Title = "Erreur",
                Content = "Veuillez selectionner un joueur",
                Duration = 3,
                Image = 4483345998,
            })
        end
    end,
})

TeleportTab:CreateButton({
    Name = "Rafraichir la liste",
    Callback = function()
        local newPlayerList = Teleport.GetPlayers()
        PlayerDropdown:Refresh(newPlayerList, true)
        Rayfield:Notify({
            Title = "Liste mise a jour",
            Content = #newPlayerList .. " joueurs trouves",
            Duration = 2,
            Image = 4483345998,
        })
    end,
})

Teleport.OnPlayerAdded(function(player)
    task.wait(1)
    PlayerDropdown:Refresh(Teleport.GetPlayers(), true)
end)

Teleport.OnPlayerRemoving(function(player)
    PlayerDropdown:Refresh(Teleport.GetPlayers(), true)
end)