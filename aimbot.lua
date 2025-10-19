--[[

	Universal Aimbot Module by Exunys © CC0 1.0 Universal (2023 - 2024)
	https://github.com/Exunys
	
	Améliorations:
	- Meilleure gestion des erreurs
	- Optimisation des performances
	- Code plus lisible et maintainable
	- Prédiction de mouvement améliorée
	- Système de priorité des cibles

]]

--// Cache

local game, workspace = game, workspace
local getrawmetatable, getmetatable, setmetatable, pcall, getgenv, next, tick = getrawmetatable, getmetatable, setmetatable, pcall, getgenv, next, tick
local Vector2new, Vector3zero, Vector3new, CFramenew, Color3fromRGB, Color3fromHSV, Drawingnew, TweenInfonew = Vector2.new, Vector3.zero, Vector3.new, CFrame.new, Color3.fromRGB, Color3.fromHSV, Drawing.new, TweenInfo.new
local getupvalue, mousemoverel, tablefind, tableremove, stringlower, stringsub, mathclamp, mathabs = debug.getupvalue, mousemoverel or (Input and Input.MouseMove), table.find, table.remove, string.lower, string.sub, math.clamp, math.abs

local GameMetatable = getrawmetatable and getrawmetatable(game) or {
	__index = function(self, Index)
		return self[Index]
	end,

	__newindex = function(self, Index, Value)
		self[Index] = Value
	end
}

local __index = GameMetatable.__index
local __newindex = GameMetatable.__newindex

local getrenderproperty, setrenderproperty = getrenderproperty or __index, setrenderproperty or __newindex

local GetService = __index(game, "GetService")

--// Services

local RunService = GetService(game, "RunService")
local UserInputService = GetService(game, "UserInputService")
local TweenService = GetService(game, "TweenService")
local Players = GetService(game, "Players")

--// Service Methods

local LocalPlayer = __index(Players, "LocalPlayer")
local Camera = __index(workspace, "CurrentCamera")

local FindFirstChild, FindFirstChildOfClass = __index(game, "FindFirstChild"), __index(game, "FindFirstChildOfClass")
local GetDescendants = __index(game, "GetDescendants")
local WorldToViewportPoint = __index(Camera, "WorldToViewportPoint")
local GetPartsObscuringTarget = __index(Camera, "GetPartsObscuringTarget")
local GetMouseLocation = __index(UserInputService, "GetMouseLocation")
local GetPlayers = __index(Players, "GetPlayers")

--// Variables

local RequiredDistance, Typing, Running, ServiceConnections, Animation, OriginalSensitivity = 2000, false, false, {}, nil, nil
local Connect = function(signal, func) 
	local success, connection = pcall(function() return signal:Connect(func) end)
	return success and connection or nil
end
local Disconnect = function(connection) 
	if connection then 
		pcall(function() connection:Disconnect() end)
	end
end

--// Checking for multiple processes

if getgenv().ExunysDeveloperAimbot and getgenv().ExunysDeveloperAimbot.Exit then
	pcall(function()
		getgenv().ExunysDeveloperAimbot:Exit()
	end)
end

--// Environment

getgenv().ExunysDeveloperAimbot = {
	DeveloperSettings = {
		UpdateMode = "RenderStepped",
		TeamCheckOption = "TeamColor",
		RainbowSpeed = 1, -- Bigger = Slower
		PredictionEnabled = true, -- Prédiction de mouvement
		PredictionMultiplier = 0.15, -- Force de la prédiction
		SmoothingEnabled = true, -- Lissage du mouvement
		DebugMode = false -- Afficher les infos de debug
	},

	Settings = {
		Enabled = true,

		TeamCheck = false,
		AliveCheck = true,
		WallCheck = false,

		OffsetToMoveDirection = false,
		OffsetIncrement = 15,

		Sensitivity = 0, -- Animation length (in seconds) before fully locking onto target
		Sensitivity2 = 3.5, -- mousemoverel Sensitivity

		LockMode = 1, -- 1 = CFrame; 2 = mousemoverel
		LockPart = "Head", -- Body part to lock on

		TriggerKey = Enum.UserInputType.MouseButton2,
		Toggle = false,
		
		-- Nouveaux paramètres
		MaxLockDistance = 2000, -- Distance maximale de lock
		MinHealthPercent = 0, -- Pourcentage de vie minimum (0-100)
		PrioritizeClosest = true -- Prioriser la cible la plus proche
	},

	FOVSettings = {
		Enabled = true,
		Visible = true,

		Radius = 90,
		NumSides = 60,

		Thickness = 1,
		Transparency = 1,
		Filled = false,

		RainbowColor = false,
		RainbowOutlineColor = false,
		Color = Color3fromRGB(255, 255, 255),
		OutlineColor = Color3fromRGB(0, 0, 0),
		LockedColor = Color3fromRGB(255, 150, 150)
	},

	Blacklisted = {},
	Whitelisted = {}, -- Liste blanche (si non vide, seuls ces joueurs seront ciblés)
	FOVCircleOutline = Drawingnew("Circle"),
	FOVCircle = Drawingnew("Circle"),
	
	-- Statistiques
	Stats = {
		TotalLocks = 0,
		CurrentTarget = nil,
		LastLockTime = 0
	}
}

local Environment = getgenv().ExunysDeveloperAimbot

setrenderproperty(Environment.FOVCircle, "Visible", false)
setrenderproperty(Environment.FOVCircleOutline, "Visible", false)

--// Core Functions

local FixUsername = function(String)
	if not String or type(String) ~= "string" then return nil end
	
	local Result

	for _, Value in next, GetPlayers(Players) do
		local Name = __index(Value, "Name")

		if Name and stringsub(stringlower(Name), 1, #String) == stringlower(String) then
			Result = Name
			break
		end
	end

	return Result
end

local GetRainbowColor = function()
	local RainbowSpeed = Environment.DeveloperSettings.RainbowSpeed

	return Color3fromHSV(tick() % RainbowSpeed / RainbowSpeed, 1, 1)
end

local ConvertVector = function(Vector)
	return Vector2new(Vector.X, Vector.Y)
end

local GetVelocity = function(Character)
	local HumanoidRootPart = FindFirstChild(Character, "HumanoidRootPart")
	if HumanoidRootPart then
		local success, velocity = pcall(function()
			return __index(HumanoidRootPart, "AssemblyLinearVelocity") or __index(HumanoidRootPart, "Velocity")
		end)
		return success and velocity or Vector3zero
	end
	return Vector3zero
end

local PredictPosition = function(Position, Character)
	if not Environment.DeveloperSettings.PredictionEnabled then
		return Position
	end
	
	local Velocity = GetVelocity(Character)
	local Prediction = Velocity * Environment.DeveloperSettings.PredictionMultiplier
	
	return Position + Prediction
end

local CancelLock = function()
	Environment.Locked = nil
	Environment.Stats.CurrentTarget = nil

	local FOVCircle = Environment.FOVCircle

	setrenderproperty(FOVCircle, "Color", Environment.FOVSettings.Color)
	
	if OriginalSensitivity then
		pcall(function()
			__newindex(UserInputService, "MouseDeltaSensitivity", OriginalSensitivity)
		end)
	end

	if Animation then
		pcall(function()
			Animation:Cancel()
		end)
		Animation = nil
	end
end

local IsValidTarget = function(Player, Character, Humanoid, LockPart)
	-- Vérifications de base
	if not Player or not Character or not Humanoid or Player == LocalPlayer then
		return false
	end
	
	-- Vérifier si le LockPart existe
	if not FindFirstChild(Character, LockPart) then
		return false
	end
	
	-- Vérifier la blacklist
	local PlayerName = __index(Player, "Name")
	if tablefind(Environment.Blacklisted, PlayerName) then
		return false
	end
	
	-- Vérifier la whitelist (si elle n'est pas vide)
	if #Environment.Whitelisted > 0 and not tablefind(Environment.Whitelisted, PlayerName) then
		return false
	end
	
	-- Team check
	if Environment.Settings.TeamCheck then
		local TeamCheckOption = Environment.DeveloperSettings.TeamCheckOption
		if __index(Player, TeamCheckOption) == __index(LocalPlayer, TeamCheckOption) then
			return false
		end
	end
	
	-- Alive check
	if Environment.Settings.AliveCheck then
		local Health = __index(Humanoid, "Health")
		local MaxHealth = __index(Humanoid, "MaxHealth")
		if Health <= 0 or (MaxHealth > 0 and (Health / MaxHealth * 100) < Environment.Settings.MinHealthPercent) then
			return false
		end
	end
	
	return true
end

local GetClosestPlayer = function()
	local Settings = Environment.Settings
	local LockPart = Settings.LockPart

	if not Environment.Locked then
		RequiredDistance = Environment.FOVSettings.Enabled and Environment.FOVSettings.Radius or Settings.MaxLockDistance
		local BestTarget = nil

		for _, Player in next, GetPlayers(Players) do
			local Character = __index(Player, "Character")
			local Humanoid = Character and FindFirstChildOfClass(Character, "Humanoid")

			if IsValidTarget(Player, Character, Humanoid, LockPart) then
				local LockPartInstance = FindFirstChild(Character, LockPart)
				if not LockPartInstance then continue end
				
				local PartPosition = __index(LockPartInstance, "Position")

				-- Wall check
				if Settings.WallCheck then
					local LocalCharacter = __index(LocalPlayer, "Character")
					if LocalCharacter then
						local BlacklistTable = GetDescendants(LocalCharacter)

						for _, DescendantValue in next, GetDescendants(Character) do
							BlacklistTable[#BlacklistTable + 1] = DescendantValue
						end

						local ObscuringParts = GetPartsObscuringTarget(Camera, {PartPosition}, BlacklistTable)
						if #ObscuringParts > 0 then
							continue
						end
					end
				end

				local Vector, OnScreen = WorldToViewportPoint(Camera, PartPosition)
				if OnScreen then
					Vector = ConvertVector(Vector)
					local Distance = (GetMouseLocation(UserInputService) - Vector).Magnitude

					if Distance < RequiredDistance then
						RequiredDistance = Distance
						BestTarget = Player
					end
				end
			end
		end
		
		if BestTarget then
			Environment.Locked = BestTarget
			Environment.Stats.TotalLocks = Environment.Stats.TotalLocks + 1
			Environment.Stats.LastLockTime = tick()
			Environment.Stats.CurrentTarget = __index(BestTarget, "Name")
		end
		
	elseif Environment.Locked then
		-- Vérifier si la cible est toujours valide
		local LockedCharacter = __index(Environment.Locked, "Character")
		local LockedHumanoid = LockedCharacter and FindFirstChildOfClass(LockedCharacter, "Humanoid")
		
		if not IsValidTarget(Environment.Locked, LockedCharacter, LockedHumanoid, LockPart) then
			CancelLock()
			return
		end
		
		if LockedCharacter and FindFirstChild(LockedCharacter, LockPart) then
			local MousePos = GetMouseLocation(UserInputService)
			local TargetPos = __index(FindFirstChild(LockedCharacter, LockPart), "Position")
			local ScreenPos = ConvertVector(WorldToViewportPoint(Camera, TargetPos))
			local CurrentDistance = (MousePos - ScreenPos).Magnitude
			
			-- Déverrouiller si la cible sort du FOV
			local MaxDistance = Environment.FOVSettings.Enabled and Environment.FOVSettings.Radius or Settings.MaxLockDistance
			if CurrentDistance > MaxDistance then
				CancelLock()
			end
		else
			CancelLock()
		end
	end
end

local Load = function()
	OriginalSensitivity = __index(UserInputService, "MouseDeltaSensitivity")

	local Settings = Environment.Settings
	local FOVCircle = Environment.FOVCircle
	local FOVCircleOutline = Environment.FOVCircleOutline
	local FOVSettings = Environment.FOVSettings

	ServiceConnections.RenderSteppedConnection = Connect(__index(RunService, Environment.DeveloperSettings.UpdateMode), function()
		local LockPart = Settings.LockPart

		-- FOV Circle Update
		if FOVSettings.Enabled and Settings.Enabled then
			for Index, Value in next, FOVSettings do
				if Index == "Color" or Index == "OutlineColor" or Index == "LockedColor" then
					continue
				end

				local success = pcall(function()
					setrenderproperty(FOVCircle, Index, Value)
					setrenderproperty(FOVCircleOutline, Index, Value)
				end)
			end

			local circleColor = (Environment.Locked and FOVSettings.LockedColor) 
				or (FOVSettings.RainbowColor and GetRainbowColor()) 
				or FOVSettings.Color
			
			setrenderproperty(FOVCircle, "Color", circleColor)
			setrenderproperty(FOVCircleOutline, "Color", FOVSettings.RainbowOutlineColor and GetRainbowColor() or FOVSettings.OutlineColor)
			setrenderproperty(FOVCircleOutline, "Thickness", FOVSettings.Thickness + 1)
			
			local MouseLocation = GetMouseLocation(UserInputService)
			setrenderproperty(FOVCircle, "Position", MouseLocation)
			setrenderproperty(FOVCircleOutline, "Position", MouseLocation)
		else
			setrenderproperty(FOVCircle, "Visible", false)
			setrenderproperty(FOVCircleOutline, "Visible", false)
		end

		-- Aimbot Logic
		if Running and Settings.Enabled then
			GetClosestPlayer()

			if Environment.Locked then
				local LockedCharacter = __index(Environment.Locked, "Character")
				if not LockedCharacter or not FindFirstChild(LockedCharacter, LockPart) then
					CancelLock()
					return
				end

				local LockedHumanoid = FindFirstChildOfClass(LockedCharacter, "Humanoid")
				local LockPartInstance = FindFirstChild(LockedCharacter, LockPart)
				
				-- Calcul de l'offset
				local Offset = Vector3zero
				if Settings.OffsetToMoveDirection and LockedHumanoid then
					local MoveDir = __index(LockedHumanoid, "MoveDirection")
					Offset = MoveDir * (mathclamp(Settings.OffsetIncrement, 1, 30) / 10)
				end

				local PartPosition = __index(LockPartInstance, "Position")
				local PredictedPosition = PredictPosition(PartPosition, LockedCharacter)
				local FinalPosition = PredictedPosition + Offset
				
				local LockedPosition = WorldToViewportPoint(Camera, FinalPosition)

				-- Lock Mode
				if Settings.LockMode == 2 and mousemoverel then
					-- mousemoverel mode
					local MousePos = GetMouseLocation(UserInputService)
					local DeltaX = (LockedPosition.X - MousePos.X) / Settings.Sensitivity2
					local DeltaY = (LockedPosition.Y - MousePos.Y) / Settings.Sensitivity2
					
					pcall(function()
						mousemoverel(DeltaX, DeltaY)
					end)
				else
					-- CFrame mode
					local CameraPos = Camera.CFrame.Position
					local LookVector = FinalPosition
					
					if Settings.Sensitivity > 0 then
						-- Animation avec lissage
						if Animation then
							Animation:Cancel()
						end
						
						Animation = TweenService:Create(
							Camera, 
							TweenInfonew(Settings.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), 
							{CFrame = CFramenew(CameraPos, LookVector)}
						)
						Animation:Play()
					else
						-- Lock instantané
						pcall(function()
							__newindex(Camera, "CFrame", CFramenew(CameraPos, LookVector))
						end)
					end

					pcall(function()
						__newindex(UserInputService, "MouseDeltaSensitivity", 0)
					end)
				end

				setrenderproperty(FOVCircle, "Color", FOVSettings.LockedColor)
			end
		end
	end)

	ServiceConnections.InputBeganConnection = Connect(__index(UserInputService, "InputBegan"), function(Input)
		if Typing then return end

		local TriggerKey = Settings.TriggerKey
		local Toggle = Settings.Toggle

		if (Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == TriggerKey) 
			or Input.UserInputType == TriggerKey then
			
			if Toggle then
				Running = not Running
				if not Running then
					CancelLock()
				end
			else
				Running = true
			end
		end
	end)

	ServiceConnections.InputEndedConnection = Connect(__index(UserInputService, "InputEnded"), function(Input)
		if Toggle or Typing then return end

		local TriggerKey = Settings.TriggerKey

		if (Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == TriggerKey) 
			or Input.UserInputType == TriggerKey then
			
			Running = false
			CancelLock()
		end
	end)
end

--// Typing Check

ServiceConnections.TypingStartedConnection = Connect(__index(UserInputService, "TextBoxFocused"), function()
	Typing = true
end)

ServiceConnections.TypingEndedConnection = Connect(__index(UserInputService, "TextBoxFocusReleased"), function()
	Typing = false
end)

--// Functions

function Environment.Exit(self)
	assert(self, "EXUNYS_AIMBOT-V3.Exit: Missing parameter #1 \"self\" <table>.")

	Running = false
	CancelLock()

	for Index, Connection in next, ServiceConnections do
		Disconnect(Connection)
		ServiceConnections[Index] = nil
	end

	Load = nil
	ConvertVector = nil
	CancelLock = nil
	GetClosestPlayer = nil
	GetRainbowColor = nil
	FixUsername = nil
	IsValidTarget = nil
	GetVelocity = nil
	PredictPosition = nil

	pcall(function()
		if self.FOVCircle then self.FOVCircle:Remove() end
		if self.FOVCircleOutline then self.FOVCircleOutline:Remove() end
	end)
	
	getgenv().ExunysDeveloperAimbot = nil
end

function Environment.Restart()
	for Index, Connection in next, ServiceConnections do
		Disconnect(Connection)
	end

	Load()
end

function Environment.Toggle(self, State)
	assert(self, "EXUNYS_AIMBOT-V3.Toggle: Missing parameter #1 \"self\" <table>.")
	
	if State ~= nil then
		self.Settings.Enabled = State
	else
		self.Settings.Enabled = not self.Settings.Enabled
	end
	
	if not self.Settings.Enabled then
		Running = false
		CancelLock()
	end
	
	return self.Settings.Enabled
end

function Environment.Blacklist(self, Username)
	assert(self, "EXUNYS_AIMBOT-V3.Blacklist: Missing parameter #1 \"self\" <table>.")
	assert(Username, "EXUNYS_AIMBOT-V3.Blacklist: Missing parameter #2 \"Username\" <string>.")

	Username = FixUsername(Username)
	assert(Username, "EXUNYS_AIMBOT-V3.Blacklist: User couldn't be found.")

	if not tablefind(self.Blacklisted, Username) then
		self.Blacklisted[#self.Blacklisted + 1] = Username
	end
	
	-- Si la cible actuelle est blacklistée, annuler le lock
	if self.Locked and __index(self.Locked, "Name") == Username then
		CancelLock()
	end
end

function Environment.Whitelist(self, Username)
	assert(self, "EXUNYS_AIMBOT-V3.Whitelist: Missing parameter #1 \"self\" <table>.")
	assert(Username, "EXUNYS_AIMBOT-V3.Whitelist: Missing parameter #2 \"Username\" <string>.")

	Username = FixUsername(Username)
	assert(Username, "EXUNYS_AIMBOT-V3.Whitelist: User couldn't be found.")

	local Index = tablefind(self.Blacklisted, Username)
	if Index then
		tableremove(self.Blacklisted, Index)
	end
end

function Environment.AddToWhitelist(self, Username)
	assert(self, "EXUNYS_AIMBOT-V3.AddToWhitelist: Missing parameter #1 \"self\" <table>.")
	assert(Username, "EXUNYS_AIMBOT-V3.AddToWhitelist: Missing parameter #2 \"Username\" <string>.")

	Username = FixUsername(Username)
	assert(Username, "EXUNYS_AIMBOT-V3.AddToWhitelist: User couldn't be found.")

	if not tablefind(self.Whitelisted, Username) then
		self.Whitelisted[#self.Whitelisted + 1] = Username
	end
end

function Environment.RemoveFromWhitelist(self, Username)
	assert(self, "EXUNYS_AIMBOT-V3.RemoveFromWhitelist: Missing parameter #1 \"self\" <table>.")
	assert(Username, "EXUNYS_AIMBOT-V3.RemoveFromWhitelist: Missing parameter #2 \"Username\" <string>.")

	Username = FixUsername(Username)
	assert(Username, "EXUNYS_AIMBOT-V3.RemoveFromWhitelist: User couldn't be found.")

	local Index = tablefind(self.Whitelisted, Username)
	if Index then
		tableremove(self.Whitelisted, Index)
	end
end

function Environment.GetClosestPlayer()
	GetClosestPlayer()
	local Value = Environment.Locked
	CancelLock()
	return Value
end

function Environment.GetStats(self)
	assert(self, "EXUNYS_AIMBOT-V3.GetStats: Missing parameter #1 \"self\" <table>.")
	return self.Stats
end

Environment.Load = Load

setmetatable(Environment, {__call = Load})

return Environment