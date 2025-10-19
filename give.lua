-- Bibliothèque Items Manager pour Roblox
-- Gestion des objets et items du jeu

local ItemsManager = {}
ItemsManager.__index = ItemsManager

-- Services Roblox
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

-- Créer une nouvelle instance
function ItemsManager.new()
    local self = setmetatable({}, ItemsManager)
    self.cachedItems = {}
    self.lastScan = 0
    return self
end

-- Scanner tous les outils/items disponibles dans le jeu
function ItemsManager:scanAllItems()
    local items = {}
    local locations = {
        ReplicatedStorage,
        ServerStorage,
        Workspace
    }
    
    for _, location in ipairs(locations) do
        for _, item in pairs(location:GetDescendants()) do
            if item:IsA("Tool") or item:IsA("Accessory") or item:IsA("Model") then
                if not items[item.Name] then
                    items[item.Name] = {
                        name = item.Name,
                        class = item.ClassName,
                        location = location.Name,
                        object = item
                    }
                end
            end
        end
    end
    
    self.cachedItems = items
    self.lastScan = tick()
    return items
end

-- Obtenir la liste des noms d'items
function ItemsManager:getItemNames()
    if tick() - self.lastScan > 30 then
        self:scanAllItems()
    end
    
    local names = {}
    for name, _ in pairs(self.cachedItems) do
        table.insert(names, name)
    end
    
    table.sort(names)
    return names
end

-- Obtenir un item par son nom
function ItemsManager:getItemByName(itemName)
    if not self.cachedItems[itemName] then
        self:scanAllItems()
    end
    return self.cachedItems[itemName]
end

-- Donner un item à un joueur (par nom d'item)
function ItemsManager:giveItemToPlayer(playerName, itemName)
    local player = Players:FindFirstChild(playerName)
    if not player then
        warn("[ItemsManager] Joueur introuvable: " .. tostring(playerName))
        return false, "Joueur introuvable"
    end
    
    local character = player.Character
    if not character then
        warn("[ItemsManager] Personnage introuvable pour: " .. tostring(playerName))
        return false, "Personnage introuvable"
    end
    
    local itemData = self:getItemByName(itemName)
    if not itemData then
        warn("[ItemsManager] Item introuvable: " .. tostring(itemName))
        return false, "Item introuvable"
    end
    
    local success, err = pcall(function()
        local item = itemData.object:Clone()
        
        if item:IsA("Tool") then
            -- Donner un outil
            local backpack = player:FindFirstChild("Backpack")
            if backpack then
                item.Parent = backpack
            else
                item.Parent = character
            end
        elseif item:IsA("Accessory") then
            -- Donner un accessoire
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:AddAccessory(item)
            end
        elseif item:IsA("Model") then
            -- Donner un modèle (placer près du joueur)
            item:MoveTo(character:GetPivot().Position + Vector3.new(3, 0, 0))
            item.Parent = Workspace
        end
    end)
    
    if success then
        print("[ItemsManager] Item donné: " .. itemName .. " à " .. playerName)
        return true, "Item donné avec succès"
    else
        warn("[ItemsManager] Erreur: " .. tostring(err))
        return false, "Erreur lors du don de l'item"
    end
end

-- Donner un item à soi-même (joueur local)
function ItemsManager:giveItemToSelf(itemName)
    local player = Players.LocalPlayer
    return self:giveItemToPlayer(player.Name, itemName)
end

-- Donner un item par chemin direct (ex: game.ReplicatedStorage.Sword)
function ItemsManager:giveItemByPath(playerName, itemPath)
    local player = Players:FindFirstChild(playerName)
    if not player then
        return false, "Joueur introuvable"
    end
    
    local character = player.Character
    if not character then
        return false, "Personnage introuvable"
    end
    
    local success, err = pcall(function()
        local item = itemPath:Clone()
        
        if item:IsA("Tool") then
            local backpack = player:FindFirstChild("Backpack")
            if backpack then
                item.Parent = backpack
            else
                item.Parent = character
            end
        elseif item:IsA("Accessory") then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:AddAccessory(item)
            end
        end
    end)
    
    return success, err
end

-- Supprimer tous les outils d'un joueur
function ItemsManager:clearPlayerInventory(playerName)
    local player = Players:FindFirstChild(playerName)
    if not player then
        return false, "Joueur introuvable"
    end
    
    local backpack = player:FindFirstChild("Backpack")
    local character = player.Character
    
    local count = 0
    
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                tool:Destroy()
                count = count + 1
            end
        end
    end
    
    if character then
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") then
                tool:Destroy()
                count = count + 1
            end
        end
    end
    
    print("[ItemsManager] Inventaire vidé: " .. count .. " items supprimés")
    return true, count .. " items supprimés"
end

-- Obtenir l'inventaire d'un joueur
function ItemsManager:getPlayerInventory(playerName)
    local player = Players:FindFirstChild(playerName)
    if not player then
        return {}
    end
    
    local inventory = {}
    local backpack = player:FindFirstChild("Backpack")
    local character = player.Character
    
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                table.insert(inventory, tool.Name)
            end
        end
    end
    
    if character then
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") then
                table.insert(inventory, tool.Name)
            end
        end
    end
    
    return inventory
end

-- Dupliquer un item que le joueur possède déjà
function ItemsManager:duplicatePlayerItem(playerName, itemName)
    local player = Players:FindFirstChild(playerName)
    if not player then
        return false, "Joueur introuvable"
    end
    
    local backpack = player:FindFirstChild("Backpack")
    local character = player.Character
    
    local foundItem = nil
    
    if backpack then
        foundItem = backpack:FindFirstChild(itemName)
    end
    
    if not foundItem and character then
        foundItem = character:FindFirstChild(itemName)
    end
    
    if not foundItem then
        return false, "Item introuvable dans l'inventaire"
    end
    
    local success, err = pcall(function()
        local clone = foundItem:Clone()
        if backpack then
            clone.Parent = backpack
        end
    end)
    
    if success then
        return true, "Item dupliqué"
    else
        return false, "Erreur lors de la duplication"
    end
end

-- Rechercher des items par mot-clé
function ItemsManager:searchItems(keyword)
    local results = {}
    keyword = string.lower(keyword)
    
    for name, data in pairs(self.cachedItems) do
        if string.find(string.lower(name), keyword) then
            table.insert(results, name)
        end
    end
    
    return results
end

-- Obtenir les statistiques
function ItemsManager:getStats()
    return {
        totalItems = self:countItems(),
        lastScan = self.lastScan,
        cacheSize = #self.cachedItems
    }
end

-- Compter le nombre total d'items
function ItemsManager:countItems()
    local count = 0
    for _ in pairs(self.cachedItems) do
        count = count + 1
    end
    return count
end

-- Rafraîchir le cache
function ItemsManager:refresh()
    self:scanAllItems()
    return self:countItems()
end

return ItemsManager