--[[ 
    WEBHOOOK LOGGER POUR ROBLOX
    Auteur: Edaward_01
    Version: 1.0
    Description: Script pour logger les connexions, déconnexions et stats des joueurs via un webhook Discord.
]]--
-- Chargement de LinoriaLib
 local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ======= WEBHOOK =======
local webhookUrl = "https://discord.com/api/webhooks/1421489001441001525/2_96vZNxpXu14HKhh-AoMFFKx_R2XKIH6UvkFeMiYEBq4he32xvgCak3xZJhmweJ6yUO"

-- Fonction pour envoyer un message au webhook
function WebhookLogger:Send(data)
    local success, response = pcall(function()
        return HttpService:PostAsync(
            WEBHOOK_URL,
            HttpService:JSONEncode(data),
            Enum.HttpContentType.ApplicationJson,
            false
        )
    end)
    return success
end

function WebhookLogger:SendEmbed(embedData)
    return self:Send({embeds = {embedData}})
end

-- ========== TRACKING DES JOUEURS ==========

-- Stats des joueurs (exemple)
local PlayerStats = {}

Players.PlayerAdded:Connect(function(player)
    -- Initialiser les stats
    PlayerStats[player] = {
        JoinTime = os.time(),
        Kills = 0,
        Deaths = 0,
        Coins = 0,
        Level = 1
    }
    
    -- Log la connexion
    local embed = {
        title = "🟢 Nouveau Joueur",
        description = string.format("**%s** a rejoint le serveur!", player.Name),
        color = 65280,
        fields = {
            {name = "Nom", value = player.Name, inline = true},
            {name = "UserID", value = tostring(player.UserId), inline = true},
            {name = "Age du compte", value = player.AccountAge .. " jours", inline = true},
            {name = "Premium", value = player.MembershipType == Enum.MembershipType.Premium and "✅" or "❌", inline = true}
        },
        thumbnail = {
            url = string.format("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=150&height=150&format=png", player.UserId)
        },
        timestamp = DateTime.now():ToIsoDate()
    }
    
    WebhookLogger:SendEmbed(embed)
end)

Players.PlayerRemoving:Connect(function(player)
    if not PlayerStats[player] then return end
    
    local stats = PlayerStats[player]
    local sessionTime = os.time() - stats.JoinTime
    
    -- Log la déconnexion avec stats
    local embed = {
        title = "🔴 Joueur Déconnecté",
        description = string.format("**%s** a quitté le serveur", player.Name),
        color = 16711680,
        fields = {
            {name = "Temps de jeu", value = string.format("%d min", math.floor(sessionTime / 60)), inline = true},
            {name = "Niveau", value = tostring(stats.Level), inline = true},
            {name = "Kills", value = tostring(stats.Kills), inline = true},
            {name = "Morts", value = tostring(stats.Deaths), inline = true},
            {name = "K/D Ratio", value = string.format("%.2f", stats.Deaths > 0 and stats.Kills / stats.Deaths or stats.Kills), inline = true},
            {name = "Coins gagnés", value = tostring(stats.Coins), inline = true}
        },
        timestamp = DateTime.now():ToIsoDate()
    }
    
    WebhookLogger:SendEmbed(embed)
    
    PlayerStats[player] = nil
end)