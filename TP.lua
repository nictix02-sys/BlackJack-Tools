-- ===================== VARIABLES GLOBALES =====================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ===================== MODULE TELEPORT =====================
local Teleport = {}

function Teleport.GetPlayers()
    local playerList = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerList, player.Name)
        end
    end
    print("[TP] Joueurs trouvés:", table.concat(playerList, ", "))
    return playerList
end

function Teleport.ToPlayer(playerName)
    print("[TP] Tentative de téléportation vers:", playerName)
    
    if not playerName or playerName == "" then
        warn("[TP] Nom de joueur vide")
        return false
    end
    
    local targetPlayer = Players:FindFirstChild(playerName)
    
    if not targetPlayer then
        warn("[TP] Joueur introuvable:", playerName)
        return false
    end
    
    print("[TP] Joueur trouvé:", targetPlayer.Name)
    
    local targetCharacter = targetPlayer.Character
    local localCharacter = LocalPlayer.Character
    
    if not targetCharacter then
        warn("[TP] Personnage cible introuvable")
        return false
    end
    
    if not localCharacter then
        warn("[TP] Votre personnage est introuvable")
        return false
    end
    
    local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
    local localRoot = localCharacter:FindFirstChild("HumanoidRootPart")
    
    if not targetRoot then
        warn("[TP] HumanoidRootPart de la cible introuvable")
        return false
    end
    
    if not localRoot then
        warn("[TP] Votre HumanoidRootPart introuvable")
        return false
    end
    
    local success, err = pcall(function()
        localRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -3)
    end)
    
    if success then
        print("[TP] Téléportation réussie vers", targetPlayer.Name)
        return true
    else
        warn("[TP] Erreur lors de la téléportation:", err)
        return false
    end
end

function Teleport.ToPosition(x, y, z)
    local localCharacter = LocalPlayer.Character
    
    if not localCharacter then
        warn("[TP] Personnage introuvable")
        return false
    end
    
    local localRoot = localCharacter:FindFirstChild("HumanoidRootPart")
    
    if not localRoot then
        warn("[TP] HumanoidRootPart introuvable")
        return false
    end
    
    local success, err = pcall(function()
        localRoot.CFrame = CFrame.new(x, y, z)
    end)
    
    if success then
        print("[TP] Téléportation réussie aux coordonnées:", x, y, z)
        return true
    else
        warn("[TP] Erreur lors de la téléportation:", err)
        return false
    end
end

function Teleport.GetPlayerPosition(playerName)
    local targetPlayer = Players:FindFirstChild(playerName)
    
    if not targetPlayer then
        return nil
    end
    
    local targetCharacter = targetPlayer.Character
    if not targetCharacter then
        return nil
    end
    
    local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
    if not targetRoot then
        return nil
    end
    
    return targetRoot.Position
end

function Teleport.OnPlayerAdded(callback)
    Players.PlayerAdded:Connect(callback)
end

function Teleport.OnPlayerRemoving(callback)
    Players.PlayerRemoving:Connect(callback)
end

print("[TP] Module Teleport chargé avec succès")

return Teleport