local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local CONFIG = {
	HubTitle = "Kiên 94",
	HubSub = "VIP PRO • √12kientomato",
	AttackRange = 60,
	MeleeDelay = 0.11,
	SwordDelay = 0.14,
	FlySpeed = 185,
	AboveHeadHeight = 8,
	BringMobEnabled = true,
	BringRadius = 60,
	BringPullSpeed = 52,
	QuestCooldown = 1.6,
	KaitunMode = true,
	AutoEquipWeapon = true,
	HitSessionId = "20404cc8",
	SendTelemetry = true,
	TriggerToolActivate = true,
	AutoQuest = true,
	AutoAttack = true,
}

local QUEST_DATA = {
	{ MinLevel = 1, MaxLevel = 9, NpcName = "Bandit Quest Giver", QuestName = "BanditQuest1", QuestIndex = 1, EnemyName = "Bandit" },
	{ MinLevel = 10, MaxLevel = 14, NpcName = "Jungle Quest Giver", QuestName = "JungleQuest", QuestIndex = 1, EnemyName = "Monkey" },
	{ MinLevel = 15, MaxLevel = 29, NpcName = "Jungle Quest Giver", QuestName = "JungleQuest", QuestIndex = 2, EnemyName = "Gorilla" },
	{ MinLevel = 30, MaxLevel = 39, NpcName = "Pirate Quest Giver", QuestName = "BuggyQuest1", QuestIndex = 1, EnemyName = "Pirate" },
	{ MinLevel = 40, MaxLevel = 59, NpcName = "Pirate Quest Giver", QuestName = "BuggyQuest1", QuestIndex = 2, EnemyName = "Brute" },
	{ MinLevel = 60, MaxLevel = 74, NpcName = "Desert Quest Giver", QuestName = "DesertQuest", QuestIndex = 1, EnemyName = "Desert Bandit" },
	{ MinLevel = 75, MaxLevel = 89, NpcName = "Desert Quest Giver", QuestName = "DesertQuest", QuestIndex = 2, EnemyName = "Desert Officer" },
	{ MinLevel = 90, MaxLevel = 99, NpcName = "Snow Quest Giver", QuestName = "SnowQuest", QuestIndex = 1, EnemyName = "Snow Bandit" },
	{ MinLevel = 100, MaxLevel = 119, NpcName = "Snow Quest Giver", QuestName = "SnowQuest", QuestIndex = 2, EnemyName = "Snowman" },
	{ MinLevel = 120, MaxLevel = 149, NpcName = "Marine Quest Giver", QuestName = "MarineQuest2", QuestIndex = 1, EnemyName = "Chief Petty Officer" },
	{ MinLevel = 150, MaxLevel = 174, NpcName = "Sky Quest Giver", QuestName = "SkyQuest", QuestIndex = 1, EnemyName = "Sky Bandit" },
	{ MinLevel = 175, MaxLevel = 199, NpcName = "Sky Quest Giver", QuestName = "SkyQuest", QuestIndex = 2, EnemyName = "Dark Master" },
	{ MinLevel = 200, MaxLevel = 249, NpcName = "Prisoner Quest Giver", QuestName = "PrisonerQuest", QuestIndex = 1, EnemyName = "Prisoner" },
	{ MinLevel = 250, MaxLevel = 299, NpcName = "Prisoner Quest Giver", QuestName = "PrisonerQuest", QuestIndex = 2, EnemyName = "Dangerous Prisoner" },
	{ MinLevel = 300, MaxLevel = 324, NpcName = "Colosseum Quest Giver", QuestName = "ColosseumQuest", QuestIndex = 1, EnemyName = "Toga Warrior" },
	{ MinLevel = 325, MaxLevel = 374, NpcName = "Colosseum Quest Giver", QuestName = "ColosseumQuest", QuestIndex = 2, EnemyName = "Gladiator" },
	{ MinLevel = 375, MaxLevel = 399, NpcName = "Magma Quest Giver", QuestName = "MagmaQuest", QuestIndex = 1, EnemyName = "Military Soldier" },
	{ MinLevel = 400, MaxLevel = 449, NpcName = "Magma Quest Giver", QuestName = "MagmaQuest", QuestIndex = 2, EnemyName = "Military Spy" },
	{ MinLevel = 450, MaxLevel = 474, NpcName = "Fishman Quest Giver", QuestName = "FishmanQuest", QuestIndex = 1, EnemyName = "Fishman Warrior" },
	{ MinLevel = 475, MaxLevel = 524, NpcName = "Fishman Quest Giver", QuestName = "FishmanQuest", QuestIndex = 2, EnemyName = "Fishman Commando" },
	{ MinLevel = 525, MaxLevel = 549, NpcName = "Sky Exp Quest Giver", QuestName = "SkyExp1Quest", QuestIndex = 1, EnemyName = "God's Guard" },
	{ MinLevel = 550, MaxLevel = 624, NpcName = "Sky Exp Quest Giver", QuestName = "SkyExp1Quest", QuestIndex = 2, EnemyName = "Shanda" },
	{ MinLevel = 625, MaxLevel = 649, NpcName = "Upper Sky Quest Giver", QuestName = "SkyExp2Quest", QuestIndex = 1, EnemyName = "Royal Squad" },
	{ MinLevel = 650, MaxLevel = 699, NpcName = "Upper Sky Quest Giver", QuestName = "SkyExp2Quest", QuestIndex = 2, EnemyName = "Royal Soldier" },
	{ MinLevel = 700, MaxLevel = 724, NpcName = "Fountain Quest Giver", QuestName = "FountainQuest", QuestIndex = 1, EnemyName = "Galley Pirate" },
	{ MinLevel = 725, MaxLevel = 774, NpcName = "Fountain Quest Giver", QuestName = "FountainQuest", QuestIndex = 2, EnemyName = "Galley Captain" },
	{ MinLevel = 775, MaxLevel = 799, NpcName = "Area 1 Quest Giver", QuestName = "Area1Quest", QuestIndex = 1, EnemyName = "Raider" },
	{ MinLevel = 800, MaxLevel = 874, NpcName = "Area 1 Quest Giver", QuestName = "Area1Quest", QuestIndex = 2, EnemyName = "Mercenary" },
	{ MinLevel = 875, MaxLevel = 899, NpcName = "Area 2 Quest Giver", QuestName = "Area2Quest", QuestIndex = 1, EnemyName = "Swan Pirate" },
	{ MinLevel = 900, MaxLevel = 949, NpcName = "Area 2 Quest Giver", QuestName = "Area2Quest", QuestIndex = 2, EnemyName = "Factory Staff" },
	{ MinLevel = 950, MaxLevel = 974, NpcName = "Marine Quest Giver 2", QuestName = "MarineQuest3", QuestIndex = 1, EnemyName = "Marine Lieutenant" },
	{ MinLevel = 975, MaxLevel = 999, NpcName = "Marine Quest Giver 2", QuestName = "MarineQuest3", QuestIndex = 2, EnemyName = "Marine Captain" },
	{ MinLevel = 1000, MaxLevel = 1049, NpcName = "Zombie Quest Giver", QuestName = "ZombieQuest", QuestIndex = 1, EnemyName = "Zombie" },
	{ MinLevel = 1050, MaxLevel = 1099, NpcName = "Zombie Quest Giver", QuestName = "ZombieQuest", QuestIndex = 2, EnemyName = "Vampire" },
	{ MinLevel = 1100, MaxLevel = 1174, NpcName = "Snow Mountain Quest Giver", QuestName = "SnowMountainQuest", QuestIndex = 1, EnemyName = "Snow Trooper" },
	{ MinLevel = 1175, MaxLevel = 1199, NpcName = "Snow Mountain Quest Giver", QuestName = "SnowMountainQuest", QuestIndex = 2, EnemyName = "Winter Warrior" },
	{ MinLevel = 1200, MaxLevel = 1249, NpcName = "Ice Side Quest Giver", QuestName = "IceSideQuest", QuestIndex = 1, EnemyName = "Lab Subordinate" },
	{ MinLevel = 1250, MaxLevel = 1274, NpcName = "Ice Side Quest Giver", QuestName = "IceSideQuest", QuestIndex = 2, EnemyName = "Horned Warrior" },
	{ MinLevel = 1275, MaxLevel = 1299, NpcName = "Fire Side Quest Giver", QuestName = "FireSideQuest", QuestIndex = 1, EnemyName = "Magma Ninja" },
	{ MinLevel = 1300, MaxLevel = 1349, NpcName = "Fire Side Quest Giver", QuestName = "FireSideQuest", QuestIndex = 2, EnemyName = "Lava Pirate" },
	{ MinLevel = 1350, MaxLevel = 1399, NpcName = "Ship Deck Quest Giver", QuestName = "ShipQuest1", QuestIndex = 1, EnemyName = "Ship Deckhand" },
	{ MinLevel = 1400, MaxLevel = 1424, NpcName = "Ship Deck Quest Giver", QuestName = "ShipQuest1", QuestIndex = 2, EnemyName = "Ship Engineer" },
	{ MinLevel = 1425, MaxLevel = 1449, NpcName = "Ship Interior Quest Giver", QuestName = "ShipQuest2", QuestIndex = 1, EnemyName = "Ship Steward" },
	{ MinLevel = 1450, MaxLevel = 1474, NpcName = "Ship Interior Quest Giver", QuestName = "ShipQuest2", QuestIndex = 2, EnemyName = "Ship Officer" },
	{ MinLevel = 1475, MaxLevel = 1499, NpcName = "Arlong Quest Giver", QuestName = "ArlongQuest", QuestIndex = 1, EnemyName = "Arlong Crew" },
	{ MinLevel = 1500, MaxLevel = 1524, NpcName = "Port Quest Giver", QuestName = "PortQuest", QuestIndex = 1, EnemyName = "Pirate Millionaire" },
	{ MinLevel = 1525, MaxLevel = 1574, NpcName = "Port Quest Giver", QuestName = "PortQuest", QuestIndex = 2, EnemyName = "Pistol Billionaire" },
	{ MinLevel = 1575, MaxLevel = 1599, NpcName = "Hydra Quest Giver", QuestName = "HydraQuest", QuestIndex = 1, EnemyName = "Dragon Crew Warrior" },
	{ MinLevel = 1600, MaxLevel = 1624, NpcName = "Hydra Quest Giver", QuestName = "HydraQuest", QuestIndex = 2, EnemyName = "Dragon Crew Archer" },
	{ MinLevel = 1625, MaxLevel = 1649, NpcName = "Great Tree Quest Giver", QuestName = "TreeQuest", QuestIndex = 1, EnemyName = "Marine Commodore" },
	{ MinLevel = 1650, MaxLevel = 1699, NpcName = "Great Tree Quest Giver", QuestName = "TreeQuest", QuestIndex = 2, EnemyName = "Marine Rear Admiral" },
	{ MinLevel = 1700, MaxLevel = 1724, NpcName = "Turtle Quest Giver", QuestName = "TurtleQuest", QuestIndex = 1, EnemyName = "Fishman Raider" },
	{ MinLevel = 1725, MaxLevel = 1774, NpcName = "Turtle Quest Giver", QuestName = "TurtleQuest", QuestIndex = 2, EnemyName = "Fishman Captain" },
	{ MinLevel = 1775, MaxLevel = 1799, NpcName = "Mansion Quest Giver", QuestName = "MansionQuest", QuestIndex = 1, EnemyName = "Forest Pirate" },
	{ MinLevel = 1800, MaxLevel = 1824, NpcName = "Mansion Quest Giver", QuestName = "MansionQuest", QuestIndex = 2, EnemyName = "Mythological Pirate" },
	{ MinLevel = 1825, MaxLevel = 1849, NpcName = "Haunted Quest Giver", QuestName = "HauntedQuest1", QuestIndex = 1, EnemyName = "Jungle Pirate" },
	{ MinLevel = 1850, MaxLevel = 1899, NpcName = "Haunted Quest Giver", QuestName = "HauntedQuest1", QuestIndex = 2, EnemyName = "Musketeer Pirate" },
	{ MinLevel = 1900, MaxLevel = 1924, NpcName = "Haunted Quest Giver 2", QuestName = "HauntedQuest2", QuestIndex = 1, EnemyName = "Reborn Skeleton" },
	{ MinLevel = 1925, MaxLevel = 1974, NpcName = "Haunted Quest Giver 2", QuestName = "HauntedQuest2", QuestIndex = 2, EnemyName = "Living Zombie" },
	{ MinLevel = 1975, MaxLevel = 1999, NpcName = "Nuts Quest Giver", QuestName = "NutsQuest", QuestIndex = 1, EnemyName = "Demonic Soul" },
	{ MinLevel = 2000, MaxLevel = 2024, NpcName = "Nuts Quest Giver", QuestName = "NutsQuest", QuestIndex = 2, EnemyName = "Posessed Mummy" },
	{ MinLevel = 2025, MaxLevel = 2049, NpcName = "Cake Quest Giver", QuestName = "CakeQuest1", QuestIndex = 1, EnemyName = "Cookie Crafter" },
	{ MinLevel = 2050, MaxLevel = 2074, NpcName = "Cake Quest Giver", QuestName = "CakeQuest1", QuestIndex = 2, EnemyName = "Cake Guard" },
	{ MinLevel = 2075, MaxLevel = 2099, NpcName = "Cake Quest Giver 2", QuestName = "CakeQuest2", QuestIndex = 1, EnemyName = "Baking Staff" },
	{ MinLevel = 2100, MaxLevel = 2124, NpcName = "Cake Quest Giver 2", QuestName = "CakeQuest2", QuestIndex = 2, EnemyName = "Head Baker" },
	{ MinLevel = 2125, MaxLevel = 2149, NpcName = "Choc Quest Giver", QuestName = "ChocQuest1", QuestIndex = 1, EnemyName = "Cocoa Warrior" },
	{ MinLevel = 2150, MaxLevel = 2199, NpcName = "Choc Quest Giver", QuestName = "ChocQuest1", QuestIndex = 2, EnemyName = "Chocolate Bar Battler" },
	{ MinLevel = 2200, MaxLevel = 2224, NpcName = "Choc Quest Giver 2", QuestName = "ChocQuest2", QuestIndex = 1, EnemyName = "Sweet Thief" },
	{ MinLevel = 2225, MaxLevel = 2299, NpcName = "Choc Quest Giver 2", QuestName = "ChocQuest2", QuestIndex = 2, EnemyName = "Candy Rebel" },
	{ MinLevel = 2300, MaxLevel = 2349, NpcName = "Candy Quest Giver", QuestName = "CandyQuest1", QuestIndex = 1, EnemyName = "Candy Pirate" },
	{ MinLevel = 2350, MaxLevel = 2399, NpcName = "Candy Quest Giver", QuestName = "CandyQuest1", QuestIndex = 2, EnemyName = "Snow Demon" },
	{ MinLevel = 2400, MaxLevel = 2449, NpcName = "Tiki Quest Giver", QuestName = "TikiQuest1", QuestIndex = 1, EnemyName = "Isle Outlaw" },
	{ MinLevel = 2450, MaxLevel = 2474, NpcName = "Tiki Quest Giver", QuestName = "TikiQuest1", QuestIndex = 2, EnemyName = "Island Boy" },
	{ MinLevel = 2475, MaxLevel = 2524, NpcName = "Tiki Quest Giver 2", QuestName = "TikiQuest2", QuestIndex = 1, EnemyName = "Sun-kissed Warrior" },
	{ MinLevel = 2525, MaxLevel = 9999, NpcName = "Tiki Quest Giver 2", QuestName = "TikiQuest2", QuestIndex = 2, EnemyName = "Isle Champion" },
}

local NetFolder = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Net")
local RegisterAttackRE = NetFolder and NetFolder:FindFirstChild("RE/RegisterAttack")
local RegisterHitRE = NetFolder and NetFolder:FindFirstChild("RE/RegisterHit")
local InputTelemetryRE = NetFolder and NetFolder:FindFirstChild("RE/InputTelemetry")
local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
local OnTalkToNpcRE = RemotesFolder and RemotesFolder:FindFirstChild("OnTalkToNPC")

local KienState = {
	AutoFarm = true,
	MenuOpen = true,
	ActiveTab = "Farm",
	LastAttack = 0,
	LastQuest = 0,
	LastEquip = 0,
	LastLevel = nil,
	LastEnemyName = nil,
	AnchorPos = nil,
	LockedEnemy = nil,
	BodyPos = nil,
	BodyVel = nil,
	NotifyLabel = nil,
	NotifyClearAt = 0,
	UI = {},
}

local MELEE_KEYWORDS = {
	"combat", "dark step", "electric", "water kung fu", "dragon breath",
	"superhuman", "death step", "sharkman karate", "electric claw",
	"dragon talon", "godhuman", "sanguine art", "melee", "fighting",
}

local EXCLUDED_KEYWORDS = {
	"fruit", "gun", "bow", "rifle", "pistol", "musket", "flintlock",
	"kabucha", "soul guitar",
}

local function notify(text, duration)
	KienState.NotifyClearAt = os.clock() + (duration or 2.4)
	if KienState.NotifyLabel then
		KienState.NotifyLabel.Text = "🔔 " .. tostring(text)
	end
end

local function getPlayerLevel()
	local ls = LocalPlayer:FindFirstChild("leaderstats")
	if ls then
		local lv = ls:FindFirstChild("Level") or ls:FindFirstChild("Lvl") or ls:FindFirstChild("Lv")
		if lv and lv:IsA("ValueBase") then
			return tonumber(lv.Value) or 1
		end
	end
	local data = LocalPlayer:FindFirstChild("Data")
	if data then
		local lv = data:FindFirstChild("Level")
		if lv and lv:IsA("ValueBase") then
			return tonumber(lv.Value) or 1
		end
	end
	return 1
end

local function getQuestEntryForLevel(level)
	for _, entry in ipairs(QUEST_DATA) do
		if level >= entry.MinLevel and level <= entry.MaxLevel then
			return entry
		end
	end
	return QUEST_DATA[1]
end

local function hasActiveQuest()
	local gui = LocalPlayer:FindFirstChild("PlayerGui")
	if not gui then
		return false
	end
	local main = gui:FindFirstChild("Main")
	if main then
		local q = main:FindFirstChild("Quest")
		if q and q:IsA("GuiObject") and q.Visible then
			return true
		end
	end
	return false
end

local function findQuestNpcModel(npcName)
	local npcsFolder = workspace:FindFirstChild("NPCs")
	if not npcsFolder then
		return nil
	end
	local direct = npcsFolder:FindFirstChild(npcName)
	if direct then
		return direct
	end
	local targetLower = string.lower(npcName)
	for _, item in ipairs(npcsFolder:GetChildren()) do
		if string.find(string.lower(item.Name), targetLower, 1, true) then
			return item
		end
	end
	return nil
end

local function getNpcPosition(npcModel)
	if not npcModel then
		return nil
	end
	if npcModel:IsA("Model") then
		local p = npcModel:FindFirstChild("HumanoidRootPart") or npcModel.PrimaryPart or npcModel:FindFirstChildWhichIsA("BasePart")
		return (p and p:IsDescendantOf(workspace)) and p.Position or nil
	end
	if npcModel:IsA("BasePart") and npcModel:IsDescendantOf(workspace) then
		return npcModel.Position
	end
	return nil
end

local function requestQuest(npcModel, questEntry)
	if npcModel and OnTalkToNpcRE then
		pcall(function()
			OnTalkToNpcRE:FireServer(npcModel)
		end)
	end
	local commF = (RemotesFolder and RemotesFolder:FindFirstChild("CommF_")) or ReplicatedStorage:FindFirstChild("CommF_")
	if commF and commF:IsA("RemoteFunction") then
		pcall(function()
			commF:InvokeServer("StartQuest", questEntry.QuestName, questEntry.QuestIndex)
		end)
	end
end
local function getCharacterParts()
	local char = LocalPlayer.Character
	if not char or not char:IsDescendantOf(workspace) then
		return nil, nil, nil
	end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
	if not hum or hum.Health <= 0 or not hrp or not hrp:IsDescendantOf(workspace) then
		return nil, nil, nil
	end
	return char, hum, hrp
end

local function applyNoClip(char)
	if not char then
		return
	end
	for _, p in ipairs(char:GetDescendants()) do
		if p:IsA("BasePart") and p.CanCollide then
			p.CanCollide = false
		end
	end
end

local function isToolAllowed(tool)
	if not tool or not tool:IsA("Tool") then
		return false
	end
	local lowerName = string.lower(tool.Name)
	for _, blocked in ipairs(EXCLUDED_KEYWORDS) do
		if string.find(lowerName, blocked, 1, true) then
			return false
		end
	end
	local attr = tool:GetAttribute("WeaponType")
	if type(attr) == "string" then
		local t = string.lower(attr)
		return (t == "melee" or t == "sword")
	end
	return true
end

local function ensureWeaponEquipped(char, hum)
	if not CONFIG.AutoEquipWeapon or not char or not hum then
		return
	end
	local currentTool = char:FindFirstChildOfClass("Tool")
	if currentTool and isToolAllowed(currentTool) then
		return
	end
	local backpack = LocalPlayer:FindFirstChild("Backpack")
	if not backpack then
		return
	end
	local bestMelee, bestSword = nil, nil
	for _, item in ipairs(backpack:GetChildren()) do
		if isToolAllowed(item) then
			local lowerName = string.lower(item.Name)
			local isMelee = false
			for _, kw in ipairs(MELEE_KEYWORDS) do
				if string.find(lowerName, kw, 1, true) then
					isMelee = true
					break
				end
			end
			if isMelee and not bestMelee then
				bestMelee = item
			elseif not bestSword then
				bestSword = item
			end
		end
	end
	local pick = bestMelee or bestSword
	if pick then
		pcall(function()
			hum:EquipTool(pick)
		end)
	end
end

local function getEnemyRootAndHitPart(enemy)
	if not enemy or not enemy:IsA("Model") or not enemy:IsDescendantOf(workspace) then
		return nil, nil
	end
	local hum = enemy:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then
		return nil, nil
	end
	local root = enemy:FindFirstChild("HumanoidRootPart") or enemy.PrimaryPart
	local hit = enemy:FindFirstChild("Head")
		or enemy:FindFirstChild("UpperTorso")
		or root
		or enemy:FindFirstChildWhichIsA("BasePart")
	if not hit or not hit:IsDescendantOf(workspace) then
		return nil, nil
	end
	return (root and root:IsDescendantOf(workspace) and root) or hit, hit
end

local function isEnemyMatch(enemyName, expectedName)
	local a = string.lower(enemyName)
	local b = string.lower(expectedName)
	return a == b or string.find(a, b, 1, true) ~= nil
end

local function resolveFarmEnemy(hrp, expectedName, forceRefresh)
	local enemiesFolder = workspace:FindFirstChild("Enemies")
	if not enemiesFolder then
		KienState.LockedEnemy = nil
		KienState.AnchorPos = nil
		return nil
	end

	if forceRefresh then
		KienState.LockedEnemy = nil
		KienState.AnchorPos = nil
	end

	if KienState.LockedEnemy and KienState.LockedEnemy.Parent == enemiesFolder then
		if isEnemyMatch(KienState.LockedEnemy.Name, expectedName) then
			local root, hitPart = getEnemyRootAndHitPart(KienState.LockedEnemy)
			if root and hitPart then
				local targetAbove = hitPart.Position + Vector3.new(0, CONFIG.AboveHeadHeight, 0)
				if not KienState.AnchorPos or (targetAbove - KienState.AnchorPos).Magnitude > 12 then
					KienState.AnchorPos = targetAbove
				end
				return hitPart
			end
		end
	end

	local bestPart, bestModel, bestDist = nil, nil, math.huge
	for _, enemy in ipairs(enemiesFolder:GetChildren()) do
		if isEnemyMatch(enemy.Name, expectedName) then
			local _, hitPart = getEnemyRootAndHitPart(enemy)
			if hitPart then
				local d = (hitPart.Position - hrp.Position).Magnitude
				if d < bestDist then
					bestDist = d
					bestPart = hitPart
					bestModel = enemy
				end
			end
		end
	end

	KienState.LockedEnemy = bestModel
	KienState.AnchorPos = bestPart and (bestPart.Position + Vector3.new(0, CONFIG.AboveHeadHeight, 0)) or nil
	return bestPart
end

local function stopHover()
	if KienState.BodyPos then
		pcall(function()
			KienState.BodyPos:Destroy()
		end)
		KienState.BodyPos = nil
	end
	if KienState.BodyVel then
		pcall(function()
			KienState.BodyVel:Destroy()
		end)
		KienState.BodyVel = nil
	end
end

local function flyAndLockAt(hrp, targetPos, dt)
	if not hrp or not hrp:IsDescendantOf(workspace) or not targetPos then
		return
	end
	if not KienState.BodyPos or KienState.BodyPos.Parent ~= hrp then
		stopHover()
		local bp = Instance.new("BodyPosition")
		bp.Name = "Kien94Bp"
		bp.MaxForce = Vector3.new(1e6, 1e6, 1e6)
		bp.P = 18000
		bp.D = 1200
		bp.Position = hrp.Position
		bp.Parent = hrp
		KienState.BodyPos = bp

		local bv = Instance.new("BodyVelocity")
		bv.Name = "Kien94Bv"
		bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
		bv.Velocity = Vector3.zero
		bv.Parent = hrp
		KienState.BodyVel = bv
	end

	local diff = targetPos - hrp.Position
	local dist = diff.Magnitude
	local safeDt = math.clamp(dt or 0.016, 0.008, 0.05)

	if dist > 2.0 then
		local step = math.min(dist, CONFIG.FlySpeed * safeDt)
		KienState.BodyPos.Position = hrp.Position + diff.Unit * math.max(step, 1.5)
		KienState.BodyVel.Velocity = diff.Unit * math.min(CONFIG.FlySpeed, math.max(45, dist * 6))
	else
		KienState.BodyPos.Position = targetPos
		KienState.BodyVel.Velocity = Vector3.zero
	end

	local lookTarget = Vector3.new(targetPos.X, hrp.Position.Y - CONFIG.AboveHeadHeight, targetPos.Z)
	hrp.CFrame = CFrame.lookAt(hrp.Position, lookTarget)
end

local function releaseMob(enemy)
	if not enemy then
		return
	end
	local root = enemy:FindFirstChild("HumanoidRootPart") or enemy.PrimaryPart
	if root then
		local bv = root:FindFirstChild("Kien94MobBv")
		if bv then
			pcall(function()
				bv:Destroy()
			end)
		end
		local bp = root:FindFirstChild("Kien94MobBp")
		if bp then
			pcall(function()
				bp:Destroy()
			end)
		end
	end
	local hum = enemy:FindFirstChildOfClass("Humanoid")
	if hum and hum.Health > 0 and hum.WalkSpeed == 0 then
		hum.WalkSpeed = 16
	end
end

local function cleanupAllMobs()
	local enemiesFolder = workspace:FindFirstChild("Enemies")
	if not enemiesFolder then
		return
	end
	for _, enemy in ipairs(enemiesFolder:GetChildren()) do
		releaseMob(enemy)
	end
end

local function bringMobsToSpot(anchorPos, expectedName)
	local enemiesFolder = workspace:FindFirstChild("Enemies")
	if not enemiesFolder or not anchorPos then
		return 0
	end

	local gatherSpot = anchorPos - Vector3.new(0, math.max(4, CONFIG.AboveHeadHeight - 1), 0)
	local count = 0

	for _, enemy in ipairs(enemiesFolder:GetChildren()) do
		local hum = enemy:FindFirstChildOfClass("Humanoid")
		local root = getEnemyRootAndHitPart(enemy)

		if isEnemyMatch(enemy.Name, expectedName) and hum and hum.Health > 0 and root and root:IsA("BasePart") and root:IsDescendantOf(workspace) then
			if (root.Position - anchorPos).Magnitude <= CONFIG.BringRadius then
				count += 1
				hum.WalkSpeed = 0
				for _, p in ipairs(enemy:GetDescendants()) do
					if p:IsA("BasePart") then
						p.CanCollide = false
					end
				end

				local toSpot = gatherSpot - root.Position
				if toSpot.Magnitude > 1.8 then
					local oldBp = root:FindFirstChild("Kien94MobBp")
					if oldBp then
						pcall(function()
							oldBp:Destroy()
						end)
					end
					local bv = root:FindFirstChild("Kien94MobBv")
					if not bv then
						bv = Instance.new("BodyVelocity")
						bv.Name = "Kien94MobBv"
						bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
						bv.Parent = root
					end
					bv.Velocity = toSpot.Unit * math.min(CONFIG.BringPullSpeed, toSpot.Magnitude * 6)
				else
					local oldBv = root:FindFirstChild("Kien94MobBv")
					if oldBv then
						pcall(function()
							oldBv:Destroy()
						end)
					end
					local bp = root:FindFirstChild("Kien94MobBp")
					if not bp then
						bp = Instance.new("BodyPosition")
						bp.Name = "Kien94MobBp"
						bp.MaxForce = Vector3.new(1e5, 1e5, 1e5)
						bp.P = 12000
						bp.D = 900
						bp.Parent = root
					end
					bp.Position = gatherSpot
				end
			else
				releaseMob(enemy)
			end
		else
			releaseMob(enemy)
		end
	end
	return count
end

local function getTargetsInRange(originPos, range)
	local enemiesFolder = workspace:FindFirstChild("Enemies")
	if not enemiesFolder then
		return {}
	end
	local list = {}
	for _, enemy in ipairs(enemiesFolder:GetChildren()) do
		local _, hitPart = getEnemyRootAndHitPart(enemy)
		if hitPart then
			local d = (hitPart.Position - originPos).Magnitude
			if d <= range then
				table.insert(list, { Part = hitPart, Distance = d })
			end
		end
	end
	table.sort(list, function(a, b)
		return a.Distance < b.Distance
	end)
	return list
end

local function getEquippedMeleeOrSword(char)
	if not char then
		return nil, nil
	end
	local tool = char:FindFirstChildOfClass("Tool")
	if not isToolAllowed(tool) then
		return nil, nil
	end

	local lowerName = string.lower(tool.Name)
	local attr = tool:GetAttribute("WeaponType")
	if type(attr) == "string" then
		local t = string.lower(attr)
		if t == "melee" then
			return tool, CONFIG.MeleeDelay
		elseif t == "sword" then
			return tool, CONFIG.SwordDelay
		end
	end

	for _, kw in ipairs(MELEE_KEYWORDS) do
		if string.find(lowerName, kw, 1, true) then
			return tool, CONFIG.MeleeDelay
		end
	end

	return tool, CONFIG.SwordDelay
end

local function sendTelemetry()
	if not CONFIG.SendTelemetry or not InputTelemetryRE then
		return
	end
	local tickBase = math.floor(os.clock() * 1000) % 100000
	local args = {
		{
			{ 1, -8, tickBase, 3, 1 },
			{ 1, -8, tickBase + 258, 3, 0 },
			{ 1, -8, tickBase + 1374, 3, 0 },
			{ 1, -8, tickBase + 1398, 3, 1 },
			{ 1, -8, tickBase + 1487, 3, 1 },
			{ 1, -8, tickBase + 1740, 3, 0 },
		},
	}
	pcall(function()
		InputTelemetryRE:FireServer(unpack(args))
	end)
end

local function fireAttack(tool, targets)
	if not tool or #targets == 0 then
		return
	end
	if CONFIG.TriggerToolActivate then
		pcall(function()
			tool:Activate()
		end)
	end
	sendTelemetry()
	if RegisterAttackRE then
		pcall(function()
			RegisterAttackRE:FireServer(0.5, 2)
		end)
	end
	if RegisterHitRE then
		for _, t in ipairs(targets) do
			if t.Part and t.Part:IsDescendantOf(workspace) then
				pcall(function()
					RegisterHitRE:FireServer(t.Part, {}, [4] = CONFIG.HitSessionId)
				end)
			end
		end
	end
end
local function createCleanUI()
	local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
	if not playerGui then
		return
	end
	local old = playerGui:FindFirstChild("Kien94CleanGlassUI")
	if old then
		pcall(function()
			old:Destroy()
		end)
	end

	local sg = Instance.new("ScreenGui")
	sg.Name = "Kien94CleanGlassUI"
	sg.ResetOnSpawn = false
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	sg.DisplayOrder = 999
	sg.Parent = playerGui

	local notifyBar = Instance.new("TextLabel")
	notifyBar.Name = "Kien94NotifyBar"
	notifyBar.Size = UDim2.new(0, 310, 0, 30)
	notifyBar.Position = UDim2.new(0.5, -155, 0.05, 0)
	notifyBar.BackgroundColor3 = Color3.fromRGB(12, 16, 28)
	notifyBar.BackgroundTransparency = 0.25
	notifyBar.Text = "🔔 Kiên 94 • Kaitun Full Map đã bật!"
	notifyBar.Font = Enum.Font.GothamBold
	notifyBar.TextSize = 11
	notifyBar.TextColor3 = Color3.fromRGB(145, 245, 255)
	notifyBar.TextWrapped = true
	notifyBar.Parent = sg
	Instance.new("UICorner", notifyBar).CornerRadius = UDim.new(0, 10)
	local nStroke = Instance.new("UIStroke", notifyBar)
	nStroke.Thickness = 1.5
	nStroke.Color = Color3.fromRGB(0, 235, 255)
	KienState.NotifyLabel = notifyBar
	KienState.NotifyClearAt = os.clock() + 3.5

	local kBtn = Instance.new("TextButton")
	kBtn.Name = "KienFloatK"
	kBtn.Size = UDim2.new(0, 48, 0, 48)
	kBtn.Position = UDim2.new(0.86, 0, 0.2, 0)
	kBtn.Text = "K"
	kBtn.Font = Enum.Font.GothamBlack
	kBtn.TextSize = 20
	kBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	kBtn.BackgroundColor3 = Color3.fromRGB(14, 18, 32)
	kBtn.BackgroundTransparency = 0.28
	kBtn.BorderSizePixel = 0
	kBtn.Parent = sg
	Instance.new("UICorner", kBtn).CornerRadius = UDim.new(1, 0)
	local kStroke = Instance.new("UIStroke", kBtn)
	kStroke.Thickness = 2
	kStroke.Color = Color3.fromRGB(0, 240, 255)

	local panel = Instance.new("Frame")
	panel.Name = "Kien94GlassPanel"
	panel.Size = UDim2.new(0, 282, 0, 294)
	panel.Position = UDim2.new(0.5, -141, 0.16, 0)
	panel.BackgroundColor3 = Color3.fromRGB(10, 14, 26)
	panel.BackgroundTransparency = 0.52
	panel.BorderSizePixel = 0
	panel.Visible = true
	panel.Parent = sg
	Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 16)

	local pStroke = Instance.new("UIStroke", panel)
	pStroke.Thickness = 1.6
	pStroke.Transparency = 0.15
	local grad = Instance.new("UIGradient", pStroke)
	grad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 240, 255)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(175, 95, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 165)),
	})

	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, -12, 0, 38)
	header.Position = UDim2.new(0, 6, 0, 6)
	header.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	header.BackgroundTransparency = 0.92
	header.BorderSizePixel = 0
	header.Parent = panel
	Instance.new("UICorner", header).CornerRadius = UDim.new(0, 11)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -38, 0, 18)
	title.Position = UDim2.new(0, 10, 0, 3)
	title.BackgroundTransparency = 1
	title.Text = CONFIG.HubTitle .. " • Kaitun Full Map"
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 13
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Parent = header

	local sub = Instance.new("TextLabel")
	sub.Size = UDim2.new(1, -38, 0, 14)
	sub.Position = UDim2.new(0, 10, 0, 20)
	sub.BackgroundTransparency = 1
	sub.Text = "√12kientomato • 3 Tabs • Range 60"
	sub.Font = Enum.Font.GothamMedium
	sub.TextSize = 10
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.TextColor3 = Color3.fromRGB(130, 240, 255)
	sub.Parent = header

	local hideBtn = Instance.new("TextButton")
	hideBtn.Size = UDim2.new(0, 24, 0, 24)
	hideBtn.Position = UDim2.new(1, -31, 0, 7)
	hideBtn.Text = "×"
	hideBtn.Font = Enum.Font.GothamBold
	hideBtn.TextSize = 15
	hideBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	hideBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	hideBtn.BackgroundTransparency = 0.86
	hideBtn.BorderSizePixel = 0
	hideBtn.Parent = header
	Instance.new("UICorner", hideBtn).CornerRadius = UDim.new(1, 0)

	local tabBar = Instance.new("Frame")
	tabBar.Size = UDim2.new(1, -12, 0, 28)
	tabBar.Position = UDim2.new(0, 6, 0, 48)
	tabBar.BackgroundTransparency = 1
	tabBar.Parent = panel

	local function makeTabBtn(text, xScale, wScale, xOff, wOff)
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(wScale, wOff, 1, 0)
		b.Position = UDim2.new(xScale, xOff, 0, 0)
		b.Text = text
		b.Font = Enum.Font.GothamBold
		b.TextSize = 11
		b.TextColor3 = Color3.fromRGB(255, 255, 255)
		b.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		b.BackgroundTransparency = 0.86
		b.BorderSizePixel = 0
		b.Parent = tabBar
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
		return b
	end

	local tabFarmBtn = makeTabBtn("Farm", 0, 0.333, 0, -3)
	local tabAttackBtn = makeTabBtn("Attack", 0.333, 0.333, 2, -3)
	local tabInfoBtn = makeTabBtn("Info", 0.666, 0.334, 3, -3)

	local farmPage = Instance.new("Frame")
	farmPage.Size = UDim2.new(1, -12, 1, -84)
	farmPage.Position = UDim2.new(0, 6, 0, 80)
	farmPage.BackgroundTransparency = 1
	farmPage.Visible = true
	farmPage.Parent = panel

	local farmStatus = Instance.new("TextLabel")
	farmStatus.Size = UDim2.new(1, 0, 0, 32)
	farmStatus.Position = UDim2.new(0, 0, 0, 0)
	farmStatus.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	farmStatus.BackgroundTransparency = 0.92
	farmStatus.Text = "Lv: ... | Mob: ..."
	farmStatus.Font = Enum.Font.GothamSemibold
	farmStatus.TextSize = 11
	farmStatus.TextColor3 = Color3.fromRGB(230, 252, 255)
	farmStatus.TextWrapped = true
	farmStatus.Parent = farmPage
	Instance.new("UICorner", farmStatus).CornerRadius = UDim.new(0, 8)
	KienState.UI.FarmStatus = farmStatus

	local kaitunBtn = Instance.new("TextButton")
	kaitunBtn.Size = UDim2.new(1, 0, 0, 30)
	kaitunBtn.Position = UDim2.new(0, 0, 0, 36)
	kaitunBtn.Text = "Kaitun Mode: ON"
	kaitunBtn.Font = Enum.Font.GothamBlack
	kaitunBtn.TextSize = 11
	kaitunBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	kaitunBtn.BackgroundTransparency = 0.22
	kaitunBtn.BorderSizePixel = 0
	kaitunBtn.Parent = farmPage
	Instance.new("UICorner", kaitunBtn).CornerRadius = UDim.new(0, 8)

	local autoFarmBtn = Instance.new("TextButton")
	autoFarmBtn.Size = UDim2.new(0.49, -2, 0, 28)
	autoFarmBtn.Position = UDim2.new(0, 0, 0, 70)
	autoFarmBtn.Text = "Auto Farm: ON"
	autoFarmBtn.Font = Enum.Font.GothamBold
	autoFarmBtn.TextSize = 11
	autoFarmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	autoFarmBtn.BackgroundTransparency = 0.25
	autoFarmBtn.BorderSizePixel = 0
	autoFarmBtn.Parent = farmPage
	Instance.new("UICorner", autoFarmBtn).CornerRadius = UDim.new(0, 8)

	local autoQuestBtn = Instance.new("TextButton")
	autoQuestBtn.Size = UDim2.new(0.49, -2, 0, 28)
	autoQuestBtn.Position = UDim2.new(0.51, 2, 0, 70)
	autoQuestBtn.Text = "Auto Quest: ON"
	autoQuestBtn.Font = Enum.Font.GothamBold
	autoQuestBtn.TextSize = 11
	autoQuestBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	autoQuestBtn.BackgroundTransparency = 0.25
	autoQuestBtn.BorderSizePixel = 0
	autoQuestBtn.Parent = farmPage
	Instance.new("UICorner", autoQuestBtn).CornerRadius = UDim.new(0, 8)

	local bringMobBtn = Instance.new("TextButton")
	bringMobBtn.Size = UDim2.new(1, 0, 0, 28)
	bringMobBtn.Position = UDim2.new(0, 0, 0, 102)
	bringMobBtn.Text = "Bring Mob: ON"
	bringMobBtn.Font = Enum.Font.GothamBold
	bringMobBtn.TextSize = 11
	bringMobBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	bringMobBtn.BackgroundTransparency = 0.25
	bringMobBtn.BorderSizePixel = 0
	bringMobBtn.Parent = farmPage
	Instance.new("UICorner", bringMobBtn).CornerRadius = UDim.new(0, 8)

	local heightLbl = Instance.new("TextLabel")
	heightLbl.Size = UDim2.new(1, 0, 0, 18)
	heightLbl.Position = UDim2.new(0, 0, 0, 134)
	heightLbl.BackgroundTransparency = 1
	heightLbl.Text = "Độ cao trên đầu quái: " .. CONFIG.AboveHeadHeight .. " studs"
	heightLbl.Font = Enum.Font.GothamMedium
	heightLbl.TextSize = 11
	heightLbl.TextXAlignment = Enum.TextXAlignment.Left
	heightLbl.TextColor3 = Color3.fromRGB(210, 235, 255)
	heightLbl.Parent = farmPage

	local hMinus = Instance.new("TextButton")
	hMinus.Size = UDim2.new(0.49, -2, 0, 26)
	hMinus.Position = UDim2.new(0, 0, 0, 154)
	hMinus.Text = "- Hạ xuống"
	hMinus.Font = Enum.Font.GothamBold
	hMinus.TextSize = 11
	hMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
	hMinus.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	hMinus.BackgroundTransparency = 0.86
	hMinus.BorderSizePixel = 0
	hMinus.Parent = farmPage
	Instance.new("UICorner", hMinus).CornerRadius = UDim.new(0, 8)

	local hPlus = Instance.new("TextButton")
	hPlus.Size = UDim2.new(0.49, -2, 0, 26)
	hPlus.Position = UDim2.new(0.51, 2, 0, 154)
	hPlus.Text = "+ Nâng lên"
	hPlus.Font = Enum.Font.GothamBold
	hPlus.TextSize = 11
	hPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
	hPlus.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	hPlus.BackgroundTransparency = 0.86
	hPlus.BorderSizePixel = 0
	hPlus.Parent = farmPage
	Instance.new("UICorner", hPlus).CornerRadius = UDim.new(0, 8)

	local mobInfoLbl = Instance.new("TextLabel")
	mobInfoLbl.Size = UDim2.new(1, 0, 0, 18)
	mobInfoLbl.Position = UDim2.new(0, 0, 0, 183)
	mobInfoLbl.BackgroundTransparency = 1
	mobInfoLbl.Text = "Quái đã gom: 0"
	mobInfoLbl.Font = Enum.Font.GothamMedium
	mobInfoLbl.TextSize = 10
	mobInfoLbl.TextColor3 = Color3.fromRGB(150, 250, 210)
	mobInfoLbl.Parent = farmPage
	KienState.UI.MobInfo = mobInfoLbl
	local attackPage = Instance.new("Frame")
	attackPage.Size = UDim2.new(1, -12, 1, -84)
	attackPage.Position = UDim2.new(0, 6, 0, 80)
	attackPage.BackgroundTransparency = 1
	attackPage.Visible = false
	attackPage.Parent = panel

	local autoAtkBtn = Instance.new("TextButton")
	autoAtkBtn.Size = UDim2.new(1, 0, 0, 32)
	autoAtkBtn.Position = UDim2.new(0, 0, 0, 4)
	autoAtkBtn.Text = "Auto Attack (60): ON"
	autoAtkBtn.Font = Enum.Font.GothamBold
	autoAtkBtn.TextSize = 11
	autoAtkBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	autoAtkBtn.BackgroundTransparency = 0.25
	autoAtkBtn.BorderSizePixel = 0
	autoAtkBtn.Parent = attackPage
	Instance.new("UICorner", autoAtkBtn).CornerRadius = UDim.new(0, 8)

	local meleeLbl = Instance.new("TextLabel")
	meleeLbl.Size = UDim2.new(1, 0, 0, 20)
	meleeLbl.Position = UDim2.new(0, 0, 0, 44)
	meleeLbl.BackgroundTransparency = 1
	meleeLbl.Text = "Võ Delay: " .. string.format("%.2f", CONFIG.MeleeDelay) .. "s"
	meleeLbl.Font = Enum.Font.GothamMedium
	meleeLbl.TextSize = 11
	meleeLbl.TextXAlignment = Enum.TextXAlignment.Left
	meleeLbl.TextColor3 = Color3.fromRGB(220, 240, 255)
	meleeLbl.Parent = attackPage

	local mSub = Instance.new("TextButton")
	mSub.Size = UDim2.new(0.49, -2, 0, 28)
	mSub.Position = UDim2.new(0, 0, 0, 66)
	mSub.Text = "- Nhanh hơn"
	mSub.Font = Enum.Font.GothamBold
	mSub.TextSize = 11
	mSub.TextColor3 = Color3.fromRGB(255, 255, 255)
	mSub.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	mSub.BackgroundTransparency = 0.86
	mSub.BorderSizePixel = 0
	mSub.Parent = attackPage
	Instance.new("UICorner", mSub).CornerRadius = UDim.new(0, 8)

	local mAdd = Instance.new("TextButton")
	mAdd.Size = UDim2.new(0.49, -2, 0, 28)
	mAdd.Position = UDim2.new(0.51, 2, 0, 66)
	mAdd.Text = "+ Chậm hơn"
	mAdd.Font = Enum.Font.GothamBold
	mAdd.TextSize = 11
	mAdd.TextColor3 = Color3.fromRGB(255, 255, 255)
	mAdd.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	mAdd.BackgroundTransparency = 0.86
	mAdd.BorderSizePixel = 0
	mAdd.Parent = attackPage
	Instance.new("UICorner", mAdd).CornerRadius = UDim.new(0, 8)

	local swordLbl = Instance.new("TextLabel")
	swordLbl.Size = UDim2.new(1, 0, 0, 20)
	swordLbl.Position = UDim2.new(0, 0, 0, 102)
	swordLbl.BackgroundTransparency = 1
	swordLbl.Text = "Kiếm Delay: " .. string.format("%.2f", CONFIG.SwordDelay) .. "s"
	swordLbl.Font = Enum.Font.GothamMedium
	swordLbl.TextSize = 11
	swordLbl.TextXAlignment = Enum.TextXAlignment.Left
	swordLbl.TextColor3 = Color3.fromRGB(220, 240, 255)
	swordLbl.Parent = attackPage

	local sSub = Instance.new("TextButton")
	sSub.Size = UDim2.new(0.49, -2, 0, 28)
	sSub.Position = UDim2.new(0, 0, 0, 124)
	sSub.Text = "- Nhanh hơn"
	sSub.Font = Enum.Font.GothamBold
	sSub.TextSize = 11
	sSub.TextColor3 = Color3.fromRGB(255, 255, 255)
	sSub.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	sSub.BackgroundTransparency = 0.86
	sSub.BorderSizePixel = 0
	sSub.Parent = attackPage
	Instance.new("UICorner", sSub).CornerRadius = UDim.new(0, 8)

	local sAdd = Instance.new("TextButton")
	sAdd.Size = UDim2.new(0.49, -2, 0, 28)
	sAdd.Position = UDim2.new(0.51, 2, 0, 124)
	sAdd.Text = "+ Chậm hơn"
	sAdd.Font = Enum.Font.GothamBold
	sAdd.TextSize = 11
	sAdd.TextColor3 = Color3.fromRGB(255, 255, 255)
	sAdd.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	sAdd.BackgroundTransparency = 0.86
	sAdd.BorderSizePixel = 0
	sAdd.Parent = attackPage
	Instance.new("UICorner", sAdd).CornerRadius = UDim.new(0, 8)

	local infoPage = Instance.new("Frame")
	infoPage.Size = UDim2.new(1, -12, 1, -84)
	infoPage.Position = UDim2.new(0, 6, 0, 80)
	infoPage.BackgroundTransparency = 1
	infoPage.Visible = false
	infoPage.Parent = panel

	local infoBox = Instance.new("TextLabel")
	infoBox.Size = UDim2.new(1, 0, 1, -6)
	infoBox.Position = UDim2.new(0, 0, 0, 2)
	infoBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	infoBox.BackgroundTransparency = 0.92
	infoBox.Text = "Hub: √12kientomato • Kiên 94\n• Kaitun tự Farm, tự nhận Quest, tự cầm Võ/Kiếm\n• Đầy đủ mốc quái Full Map (Lv 1 -> 2525+)\n• Bay cố định trên đầu quái & đổi mục tiêu khi lên level\n• Bring Mob mượt & Auto Attack tầm 60"
	infoBox.Font = Enum.Font.GothamMedium
	infoBox.TextSize = 11
	infoBox.TextColor3 = Color3.fromRGB(225, 248, 255)
	infoBox.TextWrapped = true
	infoBox.Parent = infoPage
	Instance.new("UICorner", infoBox).CornerRadius = UDim.new(0, 10)

	local function refreshAll()
		farmPage.Visible = (KienState.ActiveTab == "Farm")
		attackPage.Visible = (KienState.ActiveTab == "Attack")
		infoPage.Visible = (KienState.ActiveTab == "Info")

		tabFarmBtn.BackgroundTransparency = (KienState.ActiveTab == "Farm") and 0.45 or 0.88
		tabAttackBtn.BackgroundTransparency = (KienState.ActiveTab == "Attack") and 0.45 or 0.88
		tabInfoBtn.BackgroundTransparency = (KienState.ActiveTab == "Info") and 0.45 or 0.88

		kaitunBtn.Text = CONFIG.KaitunMode and "Kaitun Mode: ON" or "Kaitun Mode: OFF"
		kaitunBtn.BackgroundColor3 = CONFIG.KaitunMode and Color3.fromRGB(145, 75, 255) or Color3.fromRGB(85, 90, 110)

		autoFarmBtn.Text = KienState.AutoFarm and "Auto Farm: ON" or "Auto Farm: OFF"
		autoFarmBtn.BackgroundColor3 = KienState.AutoFarm and Color3.fromRGB(0, 190, 135) or Color3.fromRGB(215, 60, 75)

		autoQuestBtn.Text = CONFIG.AutoQuest and "Auto Quest: ON" or "Auto Quest: OFF"
		autoQuestBtn.BackgroundColor3 = CONFIG.AutoQuest and Color3.fromRGB(95, 115, 255) or Color3.fromRGB(90, 95, 115)

		bringMobBtn.Text = CONFIG.BringMobEnabled and "Bring Mob: ON" or "Bring Mob: OFF"
		bringMobBtn.BackgroundColor3 = CONFIG.BringMobEnabled and Color3.fromRGB(0, 175, 220) or Color3.fromRGB(90, 95, 115)

		autoAtkBtn.Text = CONFIG.AutoAttack and "Auto Attack (60): ON" or "Auto Attack (60): OFF"
		autoAtkBtn.BackgroundColor3 = CONFIG.AutoAttack and Color3.fromRGB(0, 190, 135) or Color3.fromRGB(215, 60, 75)

		heightLbl.Text = "Độ cao trên đầu quái: " .. CONFIG.AboveHeadHeight .. " studs"
		meleeLbl.Text = "Võ Delay: " .. string.format("%.2f", CONFIG.MeleeDelay) .. "s"
		swordLbl.Text = "Kiếm Delay: " .. string.format("%.2f", CONFIG.SwordDelay) .. "s"
	end

	tabFarmBtn.MouseButton1Click:Connect(function()
		KienState.ActiveTab = "Farm"
		refreshAll()
		notify("Đã mở tab Farm", 1.5)
	end)
	tabAttackBtn.MouseButton1Click:Connect(function()
		KienState.ActiveTab = "Attack"
		refreshAll()
		notify("Đã mở tab Attack", 1.5)
	end)
	tabInfoBtn.MouseButton1Click:Connect(function()
		KienState.ActiveTab = "Info"
		refreshAll()
		notify("Đã mở tab Info", 1.5)
	end)

	kaitunBtn.MouseButton1Click:Connect(function()
		CONFIG.KaitunMode = not CONFIG.KaitunMode
		if CONFIG.KaitunMode then
			KienState.AutoFarm = true
			CONFIG.AutoQuest = true
			CONFIG.BringMobEnabled = true
			CONFIG.AutoAttack = true
			CONFIG.AutoEquipWeapon = true
		end
		refreshAll()
		notify(CONFIG.KaitunMode and "Kaitun Mode: BẬT (Tự động toàn bộ)" or "Kaitun Mode: TẮT")
	end)

	autoFarmBtn.MouseButton1Click:Connect(function()
		KienState.AutoFarm = not KienState.AutoFarm
		if not KienState.AutoFarm then
			CONFIG.KaitunMode = false
			stopHover()
			cleanupAllMobs()
			KienState.LockedEnemy = nil
			KienState.AnchorPos = nil
		end
		refreshAll()
		notify(KienState.AutoFarm and "Auto Farm: BẬT" or "Auto Farm: TẮT")
	end)

	autoQuestBtn.MouseButton1Click:Connect(function()
		CONFIG.AutoQuest = not CONFIG.AutoQuest
		refreshAll()
		notify(CONFIG.AutoQuest and "Auto Quest: BẬT" or "Auto Quest: TẮT")
	end)

	bringMobBtn.MouseButton1Click:Connect(function()
		CONFIG.BringMobEnabled = not CONFIG.BringMobEnabled
		if not CONFIG.BringMobEnabled then
			cleanupAllMobs()
		end
		refreshAll()
		notify(CONFIG.BringMobEnabled and "Bring Mob: BẬT" or "Bring Mob: TẮT")
	end)

	autoAtkBtn.MouseButton1Click:Connect(function()
		CONFIG.AutoAttack = not CONFIG.AutoAttack
		refreshAll()
		notify(CONFIG.AutoAttack and "Auto Attack (60): BẬT" or "Auto Attack (60): TẮT")
	end)

	hMinus.MouseButton1Click:Connect(function()
		CONFIG.AboveHeadHeight = math.max(3, CONFIG.AboveHeadHeight - 1)
		KienState.AnchorPos = nil
		refreshAll()
		notify("Độ cao trên đầu quái: " .. CONFIG.AboveHeadHeight .. " studs", 1.5)
	end)
	hPlus.MouseButton1Click:Connect(function()
		CONFIG.AboveHeadHeight = math.min(35, CONFIG.AboveHeadHeight + 1)
		KienState.AnchorPos = nil
		refreshAll()
		notify("Độ cao trên đầu quái: " .. CONFIG.AboveHeadHeight .. " studs", 1.5)
	end)

	mSub.MouseButton1Click:Connect(function()
		CONFIG.MeleeDelay = math.max(0.05, CONFIG.MeleeDelay - 0.02)
		refreshAll()
		notify("Võ Delay: " .. string.format("%.2f", CONFIG.MeleeDelay) .. "s", 1.5)
	end)
	mAdd.MouseButton1Click:Connect(function()
		CONFIG.MeleeDelay = math.min(0.60, CONFIG.MeleeDelay + 0.02)
		refreshAll()
		notify("Võ Delay: " .. string.format("%.2f", CONFIG.MeleeDelay) .. "s", 1.5)
	end)
	sSub.MouseButton1Click:Connect(function()
		CONFIG.SwordDelay = math.max(0.05, CONFIG.SwordDelay - 0.02)
		refreshAll()
		notify("Kiếm Delay: " .. string.format("%.2f", CONFIG.SwordDelay) .. "s", 1.5)
	end)
	sAdd.MouseButton1Click:Connect(function()
		CONFIG.SwordDelay = math.min(0.60, CONFIG.SwordDelay + 0.02)
		refreshAll()
		notify("Kiếm Delay: " .. string.format("%.2f", CONFIG.SwordDelay) .. "s", 1.5)
	end)

	hideBtn.MouseButton1Click:Connect(function()
		KienState.MenuOpen = false
		panel.Visible = false
		notify("Đã ẩn menu (bấm nút K để mở)", 1.8)
	end)
	kBtn.MouseButton1Click:Connect(function()
		KienState.MenuOpen = not KienState.MenuOpen
		panel.Visible = KienState.MenuOpen
		notify(KienState.MenuOpen and "Đã mở menu Kiên 94" or "Đã thu gọn menu Kiên 94", 1.5)
	end)

	local function enableDrag(obj)
		local dragging, inputRef, startInput, startObj = false, nil, nil, nil
		obj.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				startInput = inp.Position
				startObj = obj.Position
				inp.Changed:Connect(function()
					if inp.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)
		obj.InputChanged:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseMovement then
				inputRef = inp
			end
		end)
		UserInputService.InputChanged:Connect(function(inp)
			if inp == inputRef and dragging then
				local d = inp.Position - startInput
				obj.Position = UDim2.new(startObj.X.Scale, startObj.X.Offset + d.X, startObj.Y.Scale, startObj.Y.Offset + d.Y)
			end
		end)
	end

	enableDrag(kBtn)
	enableDrag(panel)
	panel.Visible = true
	refreshAll()
end

pcall(createCleanUI)

RunService.Heartbeat:Connect(function(dt)
	local now = os.clock()

	if CONFIG.KaitunMode then
		KienState.AutoFarm = true
		CONFIG.AutoQuest = true
		CONFIG.BringMobEnabled = true
		CONFIG.AutoAttack = true
	end

	if KienState.NotifyLabel and now > KienState.NotifyClearAt then
		local modeTag = CONFIG.KaitunMode and "KAITUN" or "FARM"
		KienState.NotifyLabel.Text = "🔔 " .. CONFIG.HubTitle .. " • " .. modeTag .. " • Lv " .. tostring(getPlayerLevel())
	end

	local level = getPlayerLevel()
	local questEntry = getQuestEntryForLevel(level)
	local levelChanged = (KienState.LastLevel ~= nil and KienState.LastLevel ~= level)
	local enemyChanged = (KienState.LastEnemyName ~= nil and KienState.LastEnemyName ~= questEntry.EnemyName)
	KienState.LastLevel = level
	KienState.LastEnemyName = questEntry.EnemyName

	if levelChanged or enemyChanged then
		KienState.LockedEnemy = nil
		KienState.AnchorPos = nil
		notify("Đổi mục tiêu theo Lv " .. level .. ": " .. questEntry.EnemyName, 2.5)
	end

	if KienState.UI.FarmStatus then
		KienState.UI.FarmStatus.Text = "Lv: " .. level .. " | Mob: " .. questEntry.EnemyName .. " (+" .. CONFIG.AboveHeadHeight .. "y)"
	end

	if not KienState.AutoFarm then
		stopHover()
		cleanupAllMobs()
		if KienState.UI.MobInfo then
			KienState.UI.MobInfo.Text = "Quái đã gom: 0"
		end
		return
	end

	local char, hum, hrp = getCharacterParts()
	if not char or not hum or not hrp then
		stopHover()
		cleanupAllMobs()
		return
	end

	applyNoClip(char)

	if CONFIG.KaitunMode and (now - KienState.LastEquip >= 0.8) then
		KienState.LastEquip = now
		ensureWeaponEquipped(char, hum)
	end

	if CONFIG.AutoQuest and not hasActiveQuest() and (now - KienState.LastQuest >= CONFIG.QuestCooldown) then
		local npcModel = findQuestNpcModel(questEntry.NpcName)
		local npcPos = getNpcPosition(npcModel)
		if npcPos and (npcPos - hrp.Position).Magnitude > 12 then
			flyAndLockAt(hrp, npcPos + Vector3.new(0, 4, 0), dt)
		else
			KienState.LastQuest = now
			requestQuest(npcModel, questEntry)
			notify("Đang nhận quest: " .. questEntry.EnemyName, 2.0)
		end
	end

	local farmPart = resolveFarmEnemy(hrp, questEntry.EnemyName, levelChanged or enemyChanged)
	local brought = 0

	if farmPart and KienState.AnchorPos then
		flyAndLockAt(hrp, KienState.AnchorPos, dt)
		if CONFIG.BringMobEnabled then
			brought = bringMobsToSpot(KienState.AnchorPos, questEntry.EnemyName)
		end
	else
		stopHover()
	end

	if KienState.UI.MobInfo then
		KienState.UI.MobInfo.Text = "Quái đã gom: " .. brought
	end

	if not CONFIG.AutoAttack then
		return
	end
	local weapon, delaySec = getEquippedMeleeOrSword(char)
	if not weapon or not delaySec then
		return
	end
	if now - KienState.LastAttack < delaySec then
		return
	end

	local targets = getTargetsInRange(hrp.Position, CONFIG.AttackRange)
	if #targets > 0 then
		KienState.LastAttack = now
		fireAttack(weapon, targets)
	end
end)
