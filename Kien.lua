local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local CFG = {
	Delay = 0.13,
	Range = 60,
	TweenSpeed = 145,
	HoverHeight = 7.0,
	NpcStandOffset = Vector3.new(0, 1.5, 4.0),
	QuestRetryDelay = 1.8,
	RandomFruitCooldown = 3.0,
	StatChoice = "Melee",
	Session = nil,
}

local Core = _G.KienVip94Core or {
	AutoFarm = false,
	AutoQuest = true,
	AutoAttack = true,
	AutoHaki = true,
	AutoKen = false,
	AutoStats = false,
	AutoPickupFruit = true,
	AutoRandomFruit = false,
	AntiAfk = true,
	EspTargetMob = false,
	EspPlayers = false,
	LastAtk = 0,
	LastQuestTime = 0,
	LastStatTime = 0,
	LastRandomFruitTime = 0,
	CurrentSea = 1,
	CurrentLevel = 1,
	TargetMobName = "Bandit",
	TargetQuestName = "BanditQuest1",
	QuestGuiVisible = false,
	QuestProgressText = "NV Ẩn -> Nhận tiếp",
	QuestDone = true,
	Status = "Idle",
}
_G.KienVip94Core = Core

local function detectCurrentSea()
	local placeId = game.PlaceId
	if placeId == 2753915549 then return 1
	elseif placeId == 4442272183 then return 2
	elseif placeId == 7449423635 then return 3 end

	local map = workspace:FindFirstChild("Map")
	if map then
		if map:FindFirstChild("Dressrosa") or map:FindFirstChild("Cafe") or map:FindFirstChild("Kingdom of Rose") then
			return 2
		elseif map:FindFirstChild("Port Town") or map:FindFirstChild("Castle on the Sea") or map:FindFirstChild("Tiki Outpost") then
			return 3
		end
	end

	local data = player:FindFirstChild("Data")
	local lvObj = data and data:FindFirstChild("Level")
	local lv = (lvObj and lvObj:IsA("ValueBase")) and tonumber(lvObj.Value) or 1
	if lv >= 1500 then return 3 elseif lv >= 700 then return 2 end
	return 1
end

local function scanPlayerLevel()
	local data = player:FindFirstChild("Data")
	if data then
		local lv = data:FindFirstChild("Level")
		if lv and lv:IsA("ValueBase") then
			return tonumber(lv.Value) or 1
		end
	end

	local ls = player:FindFirstChild("leaderstats")
	if ls then
		local lv = ls:FindFirstChild("Level") or ls:FindFirstChild("Lv")
		if lv and lv:IsA("ValueBase") then
			return tonumber(lv.Value) or 1
		end
	end

	local pGui = player:FindFirstChild("PlayerGui")
	local mainGui = pGui and pGui:FindFirstChild("Main")
	local lvLabel = mainGui and mainGui:FindFirstChild("Level")
	if lvLabel and lvLabel:IsA("TextLabel") then
		local num = tonumber(string.match(lvLabel.Text, "%d+"))
		if num then return num end
	end

	return 1
end

local MobQuestTable = {
	-- SEA 1
	{ sea = 1, minLevel = 1,   questName = "BanditQuest1",     questId = 1, questPos = Vector3.new(1059.37, 16.51, 1544.53),    mobName = "Bandit",             spawnPos = Vector3.new(1145.0, 17.0, 1635.0) },
	{ sea = 1, minLevel = 10,  questName = "JungleQuest",      questId = 1, questPos = Vector3.new(-1598.09, 35.55, 153.38),   mobName = "Monkey",             spawnPos = Vector3.new(-1490.0, 38.0, 28.0) },
	{ sea = 1, minLevel = 15,  questName = "JungleQuest",      questId = 2, questPos = Vector3.new(-1598.09, 35.55, 153.38),   mobName = "Gorilla",            spawnPos = Vector3.new(-1220.0, 42.0, -560.0) },
	{ sea = 1, minLevel = 30,  questName = "BuggyQuest1",      questId = 1, questPos = Vector3.new(-1141.07, 4.10, 3827.62),   mobName = "Pirate",             spawnPos = Vector3.new(-1215.0, 14.0, 3915.0) },
	{ sea = 1, minLevel = 40,  questName = "BuggyQuest1",      questId = 2, questPos = Vector3.new(-1141.07, 4.10, 3827.62),   mobName = "Brute",              spawnPos = Vector3.new(-1145.0, 48.0, 4295.0) },
	{ sea = 1, minLevel = 60,  questName = "DesertQuest",      questId = 1, questPos = Vector3.new(896.51, 6.43, 4390.14),     mobName = "Desert Bandit",      spawnPos = Vector3.new(932.0, 12.0, 4484.0) },
	{ sea = 1, minLevel = 75,  questName = "DesertQuest",      questId = 2, questPos = Vector3.new(896.51, 6.43, 4390.14),     mobName = "Desert Officer",     spawnPos = Vector3.new(1572.0, 10.0, 4373.0) },
	{ sea = 1, minLevel = 90,  questName = "SnowQuest",        questId = 1, questPos = Vector3.new(1386.80, 87.27, -1298.90),  mobName = "Snow Bandit",        spawnPos = Vector3.new(1354.0, 120.0, -1462.0) },
	{ sea = 1, minLevel = 105, questName = "SnowQuest",        questId = 2, questPos = Vector3.new(1386.80, 87.27, -1298.90),  mobName = "Snowman",            spawnPos = Vector3.new(1201.0, 145.0, -1442.0) },
	{ sea = 1, minLevel = 120, questName = "MarineQuest2",     questId = 1, questPos = Vector3.new(-5035.42, 28.65, 4324.50),  mobName = "Chief Petty Officer",spawnPos = Vector3.new(-4855.0, 32.0, 4290.0) },
	{ sea = 1, minLevel = 150, questName = "SkyQuest",         questId = 1, questPos = Vector3.new(-4841.83, 717.67, -2623.96),mobName = "Sky Bandit",         spawnPos = Vector3.new(-4970.0, 720.0, -2485.0) },
	{ sea = 1, minLevel = 175, questName = "SkyQuest",         questId = 2, questPos = Vector3.new(-4841.83, 717.67, -2623.96),mobName = "Dark Master",        spawnPos = Vector3.new(-5240.0, 725.0, -2190.0) },
	{ sea = 1, minLevel = 190, questName = "PrisonerQuest",    questId = 1, questPos = Vector3.new(5308.93, 1.66, 475.12),     mobName = "Prisoner",           spawnPos = Vector3.new(5090.0, 10.0, 470.0) },
	{ sea = 1, minLevel = 210, questName = "PrisonerQuest",    questId = 2, questPos = Vector3.new(5308.93, 1.66, 475.12),     mobName = "Dangerous Prisoner", spawnPos = Vector3.new(5560.0, 10.0, 620.0) },
	{ sea = 1, minLevel = 250, questName = "ColosseumQuest",   questId = 1, questPos = Vector3.new(-1576.11, 7.39, -2983.30), mobName = "Toga Warrior",       spawnPos = Vector3.new(-1825.0, 20.0, -2760.0) },
	{ sea = 1, minLevel = 275, questName = "ColosseumQuest",   questId = 2, questPos = Vector3.new(-1576.11, 7.39, -2983.30), mobName = "Gladiator",          spawnPos = Vector3.new(-1290.0, 20.0, -3150.0) },
	{ sea = 1, minLevel = 300, questName = "MagmaQuest",       questId = 1, questPos = Vector3.new(-5314.62, 12.26, 8517.27),  mobName = "Military Soldier",   spawnPos = Vector3.new(-5415.0, 22.0, 8465.0) },
	{ sea = 1, minLevel = 325, questName = "MagmaQuest",       questId = 2, questPos = Vector3.new(-5314.62, 12.26, 8517.27),  mobName = "Military Spy",       spawnPos = Vector3.new(-5785.0, 85.0, 8820.0) },
	{ sea = 1, minLevel = 375, questName = "FishmanQuest",     questId = 1, questPos = Vector3.new(61122.65, 18.49, 1569.39), mobName = "Fishman Warrior",    spawnPos = Vector3.new(60890.0, 35.0, 1510.0) },
	{ sea = 1, minLevel = 400, questName = "FishmanQuest",     questId = 2, questPos = Vector3.new(61122.65, 18.49, 1569.39), mobName = "Fishman Commando",   spawnPos = Vector3.new(61890.0, 35.0, 1465.0) },
	{ sea = 1, minLevel = 450, questName = "SkyExp1Quest",     questId = 1, questPos = Vector3.new(-7859.09, 5545.51, -381.47),mobName = "God's Guard",        spawnPos = Vector3.new(-7690.0, 5555.0, -510.0) },
	{ sea = 1, minLevel = 475, questName = "SkyExp1Quest",     questId = 2, questPos = Vector3.new(-7859.09, 5545.51, -381.47),mobName = "Shanda",             spawnPos = Vector3.new(-7680.0, 5560.0, -490.0) },
	{ sea = 1, minLevel = 525, questName = "SkyExp2Quest",     questId = 1, questPos = Vector3.new(-7903.38, 5635.98, -1410.92),mobName = "Royal Squad",        spawnPos = Vector3.new(-7650.0, 5645.0, -1415.0) },
	{ sea = 1, minLevel = 550, questName = "SkyExp2Quest",     questId = 2, questPos = Vector3.new(-7903.38, 5635.98, -1410.92),mobName = "Royal Soldier",      spawnPos = Vector3.new(-7825.0, 5650.0, -1720.0) },
	{ sea = 1, minLevel = 625, questName = "FountainQuest",    questId = 1, questPos = Vector3.new(5258.27, 38.52, 4050.04),  mobName = "Galley Pirate",      spawnPos = Vector3.new(5560.0, 50.0, 3995.0) },
	{ sea = 1, minLevel = 650, questName = "FountainQuest",    questId = 2, questPos = Vector3.new(5258.27, 38.52, 4050.04),  mobName = "Galley Captain",     spawnPos = Vector3.new(5665.0, 55.0, 4920.0) },
	-- SEA 2
	{ sea = 2, minLevel = 700,  questName = "Area1Quest",       questId = 1, questPos = Vector3.new(-427.72, 73.04, 1836.94),   mobName = "Raider",             spawnPos = Vector3.new(-740.0, 39.0, 2340.0) },
	{ sea = 2, minLevel = 725,  questName = "Area1Quest",       questId = 2, questPos = Vector3.new(-427.72, 73.04, 1836.94),   mobName = "Mercenary",          spawnPos = Vector3.new(-975.0, 75.0, 1435.0) },
	{ sea = 2, minLevel = 775,  questName = "Area2Quest",       questId = 1, questPos = Vector3.new(635.61, 73.49, 919.36),     mobName = "Swan Pirate",        spawnPos = Vector3.new(1060.0, 120.0, 1280.0) },
	{ sea = 2, minLevel = 800,  questName = "Area2Quest",       questId = 2, questPos = Vector3.new(635.61, 73.49, 919.36),     mobName = "Factory Staff",      spawnPos = Vector3.new(1310.0, 190.0, 340.0) },
	{ sea = 2, minLevel = 875,  questName = "MarineQuest3",     questId = 1, questPos = Vector3.new(-2440.99, 73.04, -3217.70), mobName = "Marine Lieutenant",  spawnPos = Vector3.new(-2910.0, 75.0, -2975.0) },
	{ sea = 2, minLevel = 900,  questName = "MarineQuest3",     questId = 2, questPos = Vector3.new(-2440.99, 73.04, -3217.70), mobName = "Marine Captain",     spawnPos = Vector3.new(-1860.0, 75.0, -3330.0) },
	{ sea = 2, minLevel = 950,  questName = "ZombieQuest",      questId = 1, questPos = Vector3.new(-5497.06, 47.59, -795.23),  mobName = "Zombie",             spawnPos = Vector3.new(-5650.0, 50.0, -780.0) },
	{ sea = 2, minLevel = 975,  questName = "ZombieQuest",      questId = 2, questPos = Vector3.new(-5497.06, 47.59, -795.23),  mobName = "Vampire",            spawnPos = Vector3.new(-6030.0, 12.0, -1330.0) },
	{ sea = 2, minLevel = 1000, questName = "SnowMountainQuest",questId = 1, questPos = Vector3.new(609.85, 401.44, -5370.53),  mobName = "Snow Trooper",       spawnPos = Vector3.new(540.0, 402.0, -5370.0) },
	{ sea = 2, minLevel = 1050, questName = "SnowMountainQuest",questId = 2, questPos = Vector3.new(609.85, 401.44, -5370.53),  mobName = "Winter Warrior",     spawnPos = Vector3.new(1220.0, 430.0, -5170.0) },
	{ sea = 2, minLevel = 1100, questName = "IceSideQuest",     questId = 1, questPos = Vector3.new(-6061.76, 15.92, -4902.03), mobName = "Lab Subordinate",    spawnPos = Vector3.new(-5760.0, 20.0, -4960.0) },
	{ sea = 2, minLevel = 1125, questName = "IceSideQuest",     questId = 2, questPos = Vector3.new(-6061.76, 15.92, -4902.03), mobName = "Horned Warrior",     spawnPos = Vector3.new(-6400.0, 16.0, -5780.0) },
	{ sea = 2, minLevel = 1175, questName = "FireSideQuest",    questId = 1, questPos = Vector3.new(-5429.04, 15.97, -5297.96), mobName = "Magma Ninja",        spawnPos = Vector3.new(-5440.0, 75.0, -5955.0) },
	{ sea = 2, minLevel = 1200, questName = "FireSideQuest",    questId = 2, questPos = Vector3.new(-5429.04, 15.97, -5297.96), mobName = "Lava Pirate",        spawnPos = Vector3.new(-5210.0, 15.0, -4740.0) },
	{ sea = 2, minLevel = 1250, questName = "ShipQuest1",       questId = 1, questPos = Vector3.new(1033.46, 125.07, 32911.63), mobName = "Ship Deckhand",      spawnPos = Vector3.new(1210.0, 126.0, 33140.0) },
	{ sea = 2, minLevel = 1275, questName = "ShipQuest1",       questId = 2, questPos = Vector3.new(1033.46, 125.07, 32911.63), mobName = "Ship Engineer",      spawnPos = Vector3.new(915.0, 126.0, 33390.0) },
	{ sea = 2, minLevel = 1300, questName = "ShipQuest2",       questId = 1, questPos = Vector3.new(969.95, 125.07, 33242.38),  mobName = "Ship Steward",       spawnPos = Vector3.new(915.0, 142.0, 33425.0) },
	{ sea = 2, minLevel = 1325, questName = "ShipQuest2",       questId = 2, questPos = Vector3.new(969.95, 125.07, 33242.38),  mobName = "Ship Officer",       spawnPos = Vector3.new(1035.0, 180.0, 32855.0) },
	{ sea = 2, minLevel = 1350, questName = "FrostQuest",       questId = 1, questPos = Vector3.new(6529.08, 141.86, -1107.28), mobName = "Arctic Warrior",     spawnPos = Vector3.new(5965.0, 30.0, -1240.0) },
	{ sea = 2, minLevel = 1425, questName = "ForgottenQuest",   questId = 1, questPos = Vector3.new(-3053.98, 236.88, -10147.79),mobName = "Water Fighter",      spawnPos = Vector3.new(-3350.0, 290.0, -10525.0) },
	{ sea = 2, minLevel = 1450, questName = "ForgottenQuest",   questId = 2, questPos = Vector3.new(-3053.98, 236.88, -10147.79),mobName = "Tide Keeper",        spawnPos = Vector3.new(-2690.0, 238.0, -10280.0) },
	-- SEA 3
	{ sea = 3, minLevel = 1500, questName = "PiratePortQuest",  questId = 1, questPos = Vector3.new(-290.07, 42.90, 5581.59),   mobName = "Pirate Millionaire",  spawnPos = Vector3.new(-370.0, 45.0, 5450.0) },
	{ sea = 3, minLevel = 1525, questName = "PiratePortQuest",  questId = 2, questPos = Vector3.new(-290.07, 42.90, 5581.59),   mobName = "Pistol Billionaire",  spawnPos = Vector3.new(-185.0, 85.0, 6015.0) },
	{ sea = 3, minLevel = 1575, questName = "AmazonQuest",      questId = 1, questPos = Vector3.new(5832.83, 51.39, -1105.61),  mobName = "Dragon Crew Warrior", spawnPos = Vector3.new(6300.0, 55.0, -1230.0) },
	{ sea = 3, minLevel = 1600, questName = "AmazonQuest",      questId = 2, questPos = Vector3.new(5832.83, 51.39, -1105.61),  mobName = "Dragon Crew Archer",  spawnPos = Vector3.new(6710.0, 380.0, -520.0) },
	{ sea = 3, minLevel = 1625, questName = "AmazonQuest2",     questId = 1, questPos = Vector3.new(5446.87, 601.63, 747.46),   mobName = "Female Islander",     spawnPos = Vector3.new(4690.0, 605.0, 630.0) },
	{ sea = 3, minLevel = 1650, questName = "AmazonQuest2",     questId = 2, questPos = Vector3.new(5446.87, 601.63, 747.46),   mobName = "Giant Islander",      spawnPos = Vector3.new(4530.0, 650.0, 105.0) },
	{ sea = 3, minLevel = 1700, questName = "MarineTreeQuest",  questId = 1, questPos = Vector3.new(2179.98, 28.73, -6740.05),  mobName = "Marine Commodore",    spawnPos = Vector3.new(2290.0, 75.0, -7590.0) },
	{ sea = 3, minLevel = 1725, questName = "MarineTreeQuest",  questId = 2, questPos = Vector3.new(2179.98, 28.73, -6740.05),  mobName = "Marine Rear Admiral", spawnPos = Vector3.new(3650.0, 160.0, -6920.0) },
	{ sea = 3, minLevel = 1775, questName = "DeepForestQuest",  questId = 1, questPos = Vector3.new(-13234.69, 331.74, -7625.40),mobName = "Fishman Raider",      spawnPos = Vector3.new(-10560.0, 332.0, -8460.0) },
	{ sea = 3, minLevel = 1800, questName = "DeepForestQuest",  questId = 2, questPos = Vector3.new(-13234.69, 331.74, -7625.40),mobName = "Fishman Captain",     spawnPos = Vector3.new(-10995.0, 332.0, -8940.0) },
	{ sea = 3, minLevel = 1825, questName = "DeepForestQuest2", questId = 1, questPos = Vector3.new(-12680.80, 390.88, -9902.21),mobName = "Forest Pirate",       spawnPos = Vector3.new(-13225.0, 332.0, -10425.0) },
	{ sea = 3, minLevel = 1850, questName = "DeepForestQuest2", questId = 2, questPos = Vector3.new(-12680.80, 390.88, -9902.21),mobName = "Mythological Pirate", spawnPos = Vector3.new(-13580.0, 470.0, -11985.0) },
	{ sea = 3, minLevel = 1900, questName = "JungleQuest3",     questId = 1, questPos = Vector3.new(-11897.80, 1007.98,-14787.55),mobName = "Jungle Pirate",       spawnPos = Vector3.new(-12120.0, 1008.0,-14520.0) },
	{ sea = 3, minLevel = 1925, questName = "JungleQuest3",     questId = 2, questPos = Vector3.new(-11897.80, 1007.98,-14787.55),mobName = "Musketeer Pirate",    spawnPos = Vector3.new(-13280.0, 1008.0,-14415.0) },
	{ sea = 3, minLevel = 2000, questName = "HauntedQuest1",    questId = 1, questPos = Vector3.new(-9516.99, 142.13, 5786.00),   mobName = "Reborn Skeleton",     spawnPos = Vector3.new(-8760.0, 145.0, 6075.0) },
	{ sea = 3, minLevel = 2025, questName = "HauntedQuest1",    questId = 2, questPos = Vector3.new(-9516.99, 142.13, 5786.00),   mobName = "Living Zombie",       spawnPos = Vector3.new(-10150.0, 140.0, 5950.0) },
	{ sea = 3, minLevel = 2075, questName = "HauntedQuest2",    questId = 1, questPos = Vector3.new(-9516.99, 142.13, 5786.00),   mobName = "Demonic Soul",        spawnPos = Vector3.new(-9500.0, 175.0, 6190.0) },
	{ sea = 3, minLevel = 2100, questName = "HauntedQuest2",    questId = 2, questPos = Vector3.new(-9516.99, 142.13, 5786.00),   mobName = "Posessed Mummy",      spawnPos = Vector3.new(-9580.0, 145.0, 6365.0) },
	{ sea = 3, minLevel = 2200, questName = "NutsIslandQuest",  questId = 1, questPos = Vector3.new(-16540.66, 55.69, 1051.30),  mobName = "Peanut Scout",        spawnPos = Vector3.new(-15700.0, 60.0, 740.0) },
	{ sea = 3, minLevel = 2225, questName = "NutsIslandQuest",  questId = 2, questPos = Vector3.new(-16540.66, 55.69, 1051.30),  mobName = "Peanut President",     spawnPos = Vector3.new(-16550.0, 105.0, 430.0) },
	{ sea = 3, minLevel = 2300, questName = "CakeQuest1",       questId = 1, questPos = Vector3.new(-2021.32, 37.80, -12028.73), mobName = "Cookie Crafter",      spawnPos = Vector3.new(-2370.0, 90.0, -12110.0) },
	{ sea = 3, minLevel = 2325, questName = "CakeQuest1",       questId = 2, questPos = Vector3.new(-2021.32, 37.80, -12028.73), mobName = "Cake Guard",          spawnPos = Vector3.new(-1510.0, 90.0, -12420.0) },
	{ sea = 3, minLevel = 2400, questName = "CakeQuest2",       questId = 1, questPos = Vector3.new(-1928.00, 37.80, -12840.00), mobName = "Baking Staff",        spawnPos = Vector3.new(-1880.0, 125.0, -12990.0) },
	{ sea = 3, minLevel = 2425, questName = "CakeQuest2",       questId = 2, questPos = Vector3.new(-1928.00, 37.80, -12840.00), mobName = "Head Baker",          spawnPos = Vector3.new(-2210.0, 125.0, -12850.0) },
	{ sea = 3, minLevel = 2500, questName = "ChocQuest1",       questId = 1, questPos = Vector3.new(233.29, 29.88, -12201.23),   mobName = "Cocoa Warrior",       spawnPos = Vector3.new(125.0, 80.0, -12335.0) },
	{ sea = 3, minLevel = 2525, questName = "ChocQuest1",       questId = 2, questPos = Vector3.new(233.29, 29.88, -12201.23),   mobName = "Chocolate Bar Battler",spawnPos = Vector3.new(745.0, 80.0, -12650.0) },
	{ sea = 3, minLevel = 2550, questName = "ChocQuest2",       questId = 1, questPos = Vector3.new(150.00, 30.00, -12700.00),   mobName = "Sweet Thief",         spawnPos = Vector3.new(135.0, 80.0, -12550.0) },
	{ sea = 3, minLevel = 2575, questName = "ChocQuest2",       questId = 2, questPos = Vector3.new(150.00, 30.00, -12700.00),   mobName = "Candy Rebel",         spawnPos = Vector3.new(75.0, 80.0, -12970.0) },
}

local function getQuestForSeaAndLevel(sea, lv)
	if sea == 1 and lv >= 10 and lv < 15 then
		return MobQuestTable[2]
	end

	local picked = nil
	for _, entry in ipairs(MobQuestTable) do
		if entry.sea == sea and lv >= entry.minLevel then
			picked = entry
		elseif entry.sea > sea then
			break
		end
	end
	if not picked then
		for _, entry in ipairs(MobQuestTable) do
			if entry.sea == sea then
				picked = entry
				break
			end
		end
	end
	return picked or MobQuestTable[1]
end
local function getCommF()
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	return remotes and remotes:FindFirstChild("CommF_")
end

local function getCharParts()
	local char = player.Character
	if not char then return nil, nil, nil end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum or hum.Health <= 0 then return nil, nil, nil end
	return char, hrp, hum
end

local function clearMotionHelpers(hrp)
	if not hrp then return end
	for _, child in ipairs(hrp:GetChildren()) do
		if child.Name == "KienVip94_BV" or child.Name == "KienVip94_BG" then
			child:Destroy()
		end
	end
end

local function zeroVelocity(hrp)
	if not hrp then return end
	pcall(function()
		hrp.AssemblyLinearVelocity = Vector3.zero
		hrp.AssemblyAngularVelocity = Vector3.zero
	end)
end

-- Tư thế bay hợp lý: giữ nhân vật đứng thẳng/hơi nghiêng tự nhiên theo phương ngang, không lộn ngược hay bẻ gãy pose
local function makeHorizontalCFrame(pos, lookPos)
	if not lookPos then
		return CFrame.new(pos)
	end
	local flatLook = Vector3.new(lookPos.X, pos.Y, lookPos.Z)
	if (flatLook - pos).Magnitude < 0.05 then
		return CFrame.new(pos)
	end
	return CFrame.lookAt(pos, flatLook)
end

local function flySmoothNatural(hrp, hum, targetPos, lookTargetPos)
	if not hrp or not hum then return end
	local char = hrp.Parent

	local function setNoClip(enabled)
		if not char then return end
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = not enabled
			end
		end
	end

	clearMotionHelpers(hrp)
	setNoClip(true)
	if hum:GetState() == Enum.HumanoidStateType.Seated then
		hum.Sit = false
	end

	local bv = Instance.new("BodyVelocity")
	bv.Name = "KienVip94_BV"
	bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
	bv.Velocity = Vector3.zero
	bv.Parent = hrp

	while char and char.Parent and hum.Health > 0 do
		local pos = hrp.Position
		local delta = targetPos - pos
		local dist = delta.Magnitude
		if dist <= 3.0 then
			break
		end

		local dt = RunService.Heartbeat:Wait()
		local speed = math.min(CFG.TweenSpeed, dist / math.max(dt, 0.016))
		local dir = delta.Unit
		bv.Velocity = dir * speed
		hrp.AssemblyAngularVelocity = Vector3.zero
		hrp.CFrame = makeHorizontalCFrame(pos + dir * math.min(dist, CFG.TweenSpeed * dt), lookTargetPos or targetPos)
	end

	clearMotionHelpers(hrp)
	hrp.CFrame = makeHorizontalCFrame(targetPos, lookTargetPos or targetPos)
	zeroVelocity(hrp)
	setNoClip(false)
end

local function findNpcNear(q)
	if not q or not q.questPos then return nil end
	local searchRoots = { workspace:FindFirstChild("NPCs"), workspace }
	for _, root in ipairs(searchRoots) do
		if root then
			for _, obj in ipairs(root:GetDescendants()) do
				if obj:IsA("Model") then
					local p = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head") or obj:FindFirstChildWhichIsA("BasePart")
					if p and (p.Position - q.questPos).Magnitude <= 45 then
						local lower = string.lower(obj.Name)
						if string.find(lower, "quest") or string.find(lower, "monkey") or string.find(lower, "bandit") or string.find(lower, "adventurer") then
							return obj, p.Position
						end
					end
				end
			end
		end
	end
	return nil, q.questPos
end

local function triggerNpcInteractions(npcModel, pos)
	if npcModel then
		for _, desc in ipairs(npcModel:GetDescendants()) do
			if desc:IsA("ProximityPrompt") then
				pcall(function() fireproximityprompt(desc) end)
			elseif desc:IsA("ClickDetector") then
				pcall(function() fireclickdetector(desc) end)
			end
		end
	end

	for _, desc in ipairs(workspace:GetDescendants()) do
		if desc:IsA("ProximityPrompt") and desc.Parent and desc.Parent:IsA("BasePart") then
			if (desc.Parent.Position - pos).Magnitude <= 14 then
				pcall(function() fireproximityprompt(desc) end)
			end
		end
	end
end

local function flyToNpcAndAcceptQuest(hrp, hum, q)
	if not Core.AutoQuest or not q then return end
	if os.clock() - Core.LastQuestTime < CFG.QuestRetryDelay then return end

	local npcModel, npcPos = findNpcNear(q)
	local standPos = npcPos + CFG.NpcStandOffset

	if (hrp.Position - standPos).Magnitude > 3.5 then
		Core.Status = "Bay tới NPC (" .. q.questName .. ")"
		flySmoothNatural(hrp, hum, standPos, npcPos)
	end

	hrp.CFrame = makeHorizontalCFrame(standPos, npcPos)
	zeroVelocity(hrp)
	Core.Status = "Đang nhận NV (" .. q.questName .. ")"

	local commF = getCommF()
	if commF then
		Core.LastQuestTime = os.clock()
		pcall(function() commF:InvokeServer("StartQuest", q.questName, q.questId) end)
		pcall(function() commF:InvokeServer("StartQuest", q.questName, 1) end)
		pcall(function() commF:FireServer("StartQuest", q.questName, q.questId) end)
	end

	triggerNpcInteractions(npcModel, npcPos)
	task.wait(0.25)
end

local function findNaturalMob(mobName, hrp)
	local folder = workspace:FindFirstChild("Enemies")
	if not folder or not hrp then return nil end

	local bestPart, bestDist = nil, math.huge
	for _, m in ipairs(folder:GetChildren()) do
		if m.Name == mobName then
			local h = m:FindFirstChildOfClass("Humanoid")
			local p = m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("Head")
			if h and h.Health > 0 and p then
				local d = (p.Position - hrp.Position).Magnitude
				if d < bestDist then
					bestDist = d
					bestPart = p
				end
			end
		end
	end
	return bestPart
end
local function resolveAttackRemotes()
	local reAtk, reHit
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	if remotes then
		reAtk = remotes:FindFirstChild("RE_Atk") or remotes:FindFirstChild("RegisterAttack")
		reHit = remotes:FindFirstChild("RE_Hit") or remotes:FindFirstChild("RegisterHit")
	end
	local net = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Net")
	if net then
		reAtk = reAtk or net:FindFirstChild("RE/RegisterAttack")
		reHit = reHit or net:FindFirstChild("RE/RegisterHit")
	end
	return reAtk, reHit
end

local RE_Atk, RE_Hit = resolveAttackRemotes()

local function equipBestTool(char, hum)
	if not char or not hum then return nil end
	local equipped = char:FindFirstChildOfClass("Tool")
	if equipped then return equipped end

	local backpack = player:FindFirstChild("Backpack")
	if not backpack then return nil end

	for _, tool in ipairs(backpack:GetChildren()) do
		if tool:IsA("Tool") and tool:GetAttribute("ToolTip") == "Melee" then
			pcall(function() hum:EquipTool(tool) end)
			return tool
		end
	end

	local anyTool = backpack:FindFirstChildOfClass("Tool")
	if anyTool then
		pcall(function() hum:EquipTool(anyTool) end)
		return anyTool
	end
	return nil
end

local function updateHakiAndKen()
	local commF = getCommF()
	if not commF then return end

	if Core.AutoHaki then
		local char = player.Character
		if char and not char:FindFirstChild("HasBuso") then
			pcall(function() commF:InvokeServer("Buso") end)
		end
	end

	if Core.AutoKen then
		local char = player.Character
		if char and not char:FindFirstChild("KenActive") then
			pcall(function() commF:InvokeServer("Ken", true) end)
		end
	end
end

local function updateAutoStats()
	if not Core.AutoStats then return end
	if os.clock() - Core.LastStatTime < 0.5 then return end
	Core.LastStatTime = os.clock()

	local commF = getCommF()
	if commF then
		pcall(function()
			commF:InvokeServer("AddPoint", CFG.StatChoice, 1)
		end)
	end
end

local function performFastAttack(char, hrp, hum)
	if not Core.AutoAttack or not char or not hrp or not hum then return end
	local now = os.clock()
	if now - Core.LastAtk >= CFG.Delay then
		local tool = equipBestTool(char, hum) or char:FindFirstChildOfClass("Tool")
		local folder = workspace:FindFirstChild("Enemies")
		if tool and folder then
			local targets = {}
			for _, m in ipairs(folder:GetChildren()) do
				local h = m:FindFirstChildOfClass("Humanoid")
				local p = m:FindFirstChild("Head") or m:FindFirstChild("HumanoidRootPart")
				if h and h.Health > 0 and p and (p.Position - hrp.Position).Magnitude <= CFG.Range then
					table.insert(targets, p)
				end
			end
			if #targets > 0 then
				Core.LastAtk = now
				pcall(function() tool:Activate() end)
				if RE_Atk then pcall(function() RE_Atk:FireServer(0.5, 2) end) end
				if RE_Hit then
					for _, p in ipairs(targets) do
						pcall(function() RE_Hit:FireServer(p, {}, nil, CFG.Session) end)
					end
				end
			end
		end
	end
end
local function isFruitObject(obj)
	if not obj then return false end
	local nameLower = string.lower(obj.Name)
	local hasFruitKeyword = string.find(nameLower, "fruit", 1, true) ~= nil
	local hasHandle = obj:FindFirstChild("Handle") ~= nil

	if obj:IsA("Tool") then
		-- Bỏ qua trái đã ăn hoặc tool không phải trái ác quỷ
		if hasFruitKeyword or obj:GetAttribute("OriginalName") ~= nil or hasHandle then
			if string.find(nameLower, "fruit") or obj:FindFirstChild("EatRemote") or obj:FindFirstChild("Fruit") then
				return true
			end
		end
	end

	if (obj:IsA("Model") or obj:IsA("BasePart")) and hasFruitKeyword then
		if not obj:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(obj) then
			return true
		end
	end

	return false
end

local function getFruitPosition(obj)
	if not obj then return nil end
	if obj:IsA("BasePart") then
		return obj.Position
	end
	local handle = obj:FindFirstChild("Handle")
	if handle and handle:IsA("BasePart") then
		return handle.Position
	end
	if obj:IsA("Model") then
		local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
		if part then return part.Position end
	end
	return nil
end

local function findNearestFruit(hrp)
	if not hrp then return nil, nil end
	local bestObj, bestPos, bestDist = nil, nil, math.huge

	-- Quét cả trái mọc tự nhiên lẫn trái người chơi khác giục xuống đất trong workspace
	for _, child in ipairs(workspace:GetChildren()) do
		if isFruitObject(child) then
			local pos = getFruitPosition(child)
			if pos then
				local d = (pos - hrp.Position).Magnitude
				if d < bestDist then
					bestDist = d
					bestObj = child
					bestPos = pos
				end
			end
		end
	end

	return bestObj, bestPos
end

local function stepAutoPickupFruit(hrp, hum)
	if not Core.AutoPickupFruit or not hrp or not hum then return false end
	local fruitObj, fruitPos = findNearestFruit(hrp)
	if not fruitObj or not fruitPos then return false end

	Core.Status = "Bay nhặt trái: " .. fruitObj.Name
	flySmoothNatural(hrp, hum, fruitPos, fruitPos)

	if fruitObj:IsA("Tool") and fruitObj.Parent == workspace then
		pcall(function() hum:EquipTool(fruitObj) end)
	end

	for _, desc in ipairs(fruitObj:GetDescendants()) do
		if desc:IsA("ProximityPrompt") then
			pcall(function() fireproximityprompt(desc) end)
		elseif desc:IsA("ClickDetector") then
			pcall(function() fireclickdetector(desc) end)
		end
	end

	return true
end

local function stepAutoRandomFruit()
	if not Core.AutoRandomFruit then return end
	if os.clock() - Core.LastRandomFruitTime < CFG.RandomFruitCooldown then return end
	Core.LastRandomFruitTime = os.clock()

	local commF = getCommF()
	if commF then
		pcall(function() commF:InvokeServer("CrollFruit") end)
		pcall(function() commF:InvokeServer("BuyFruit") end)
		pcall(function() commF:InvokeServer("GetRandomFruit") end)
	end
end
local function isQuestGuiOpen()
	local pGui = player:FindFirstChild("PlayerGui")
	local mainGui = pGui and pGui:FindFirstChild("Main")
	local qFrame = mainGui and mainGui:FindFirstChild("Quest")
	if not qFrame or not qFrame.Parent then
		return false
	end

	if qFrame:IsA("GuiObject") and qFrame.Visible then
		return true
	end

	for _, child in ipairs(qFrame:GetChildren()) do
		if child:IsA("GuiObject") and child.Visible then
			for _, desc in ipairs(child:GetDescendants()) do
				if desc:IsA("TextLabel") and desc.Visible and desc.Text ~= "" then
					return true
				end
			end
		end
	end

	return false
end

local function scanQuestState()
	local open = isQuestGuiOpen()
	if open then
		local labelInfo = "NV đang hiện"
		local pGui = player:FindFirstChild("PlayerGui")
		local mainGui = pGui and pGui:FindFirstChild("Main")
		local qFrame = mainGui and mainGui:FindFirstChild("Quest")
		if qFrame then
			for _, obj in ipairs(qFrame:GetDescendants()) do
				if obj:IsA("TextLabel") and obj.Visible then
					local c, r = string.match(obj.Text, "(%d+)%s*/%s*(%d+)")
					if c and r then
						labelInfo = c .. "/" .. r
						break
					end
				end
			end
		end
		return true, labelInfo, false
	end
	return false, "NV biến mất -> Nhận tiếp", true
end

local ESP_MOB_TAG = "KienVip94_TargetMobESP"
local ESP_PLR_TAG = "KienVip94_PlayerESP"

local function clearMobEsp()
	local folder = workspace:FindFirstChild("Enemies")
	if not folder then return end
	for _, mob in ipairs(folder:GetChildren()) do
		local g = mob:FindFirstChild(ESP_MOB_TAG)
		if g then g:Destroy() end
	end
end

local function clearPlayerEsp()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			local g = plr.Character:FindFirstChild(ESP_PLR_TAG)
			if g then g:Destroy() end
		end
	end
end

local function ensureBillboard(parent, name, color, text)
	local adornee = parent:FindFirstChild("Head") or parent:FindFirstChild("HumanoidRootPart")
	if not adornee then return end

	local bb = parent:FindFirstChild(name)
	if not bb then
		bb = Instance.new("BillboardGui")
		bb.Name = name
		bb.Adornee = adornee
		bb.Size = UDim2.fromOffset(175, 26)
		bb.StudsOffset = Vector3.new(0, 2.7, 0)
		bb.AlwaysOnTop = true
		bb.Parent = parent

		local lbl = Instance.new("TextLabel")
		lbl.Name = "Text"
		lbl.Size = UDim2.fromScale(1, 1)
		lbl.BackgroundColor3 = Color3.fromRGB(20, 14, 24)
		lbl.BackgroundTransparency = 0.25
		lbl.TextColor3 = color
		lbl.Font = Enum.Font.GothamBold
		lbl.TextSize = 11
		lbl.Parent = bb

		Instance.new("UICorner", lbl).CornerRadius = UDim.new(0, 6)
		local stroke = Instance.new("UIStroke", lbl)
		stroke.Color = color
		stroke.Thickness = 1
	end

	local lbl = bb:FindFirstChild("Text")
	if lbl and lbl:IsA("TextLabel") then
		lbl.Text = text
	end
end

player.Idled:Connect(function()
	if Core.AntiAfk then
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new())
	end
end)

task.spawn(function()
	while true do
		Core.CurrentSea = detectCurrentSea()
		Core.CurrentLevel = scanPlayerLevel()
		local q = getQuestForSeaAndLevel(Core.CurrentSea, Core.CurrentLevel)
		Core.TargetMobName = q.mobName
		Core.TargetQuestName = q.questName

		local open, infoText, canAccept = scanQuestState()
		Core.QuestGuiVisible = open
		Core.QuestProgressText = infoText
		Core.QuestDone = canAccept
		task.wait(0.2)
	end
end)

task.spawn(function()
	while true do
		task.wait(0.08)
		local char, hrp, hum = getCharParts()
		if not char or not hrp or not hum then
			if Core.AutoFarm then Core.Status = "Respawning..." end
			continue
		end

		updateHakiAndKen()
		updateAutoStats()
		stepAutoRandomFruit()

		if stepAutoPickupFruit(hrp, hum) then
			continue
		end

		if Core.AutoFarm then
			local sea = Core.CurrentSea
			local lv = Core.CurrentLevel
			local q = getQuestForSeaAndLevel(sea, lv)
			Core.TargetMobName = q.mobName
			Core.TargetQuestName = q.questName

			local open, infoText, canAccept = scanQuestState()
			Core.QuestGuiVisible = open
			Core.QuestProgressText = infoText
			Core.QuestDone = canAccept

			if Core.AutoQuest and canAccept then
				flyToNpcAndAcceptQuest(hrp, hum, q)
			end

			local mobPart = findNaturalMob(q.mobName, hrp)
			if mobPart then
				local farmSpot = mobPart.Position + Vector3.new(0, CFG.HoverHeight, 2.5)
				if (hrp.Position - farmSpot).Magnitude > 3.5 then
					Core.Status = "Bay tới " .. q.mobName
					flySmoothNatural(hrp, hum, farmSpot, mobPart.Position)
				else
					hrp.CFrame = makeHorizontalCFrame(hrp.Position, mobPart.Position)
					zeroVelocity(hrp)
					Core.Status = "Đánh " .. q.mobName .. " [" .. infoText .. "]"
				end
				performFastAttack(char, hrp, hum)
			else
				local waitSpot = q.spawnPos + Vector3.new(0, CFG.HoverHeight, 0)
				if (hrp.Position - waitSpot).Magnitude > 4 then
					Core.Status = "Bay tới bãi " .. q.mobName .. " (Sea " .. tostring(sea) .. ")"
					flySmoothNatural(hrp, hum, waitSpot, q.spawnPos)
				else
					zeroVelocity(hrp)
					Core.Status = "Đợi " .. q.mobName .. " [" .. infoText .. "]"
				end
				performFastAttack(char, hrp, hum)
			end
		elseif Core.AutoAttack then
			performFastAttack(char, hrp, hum)
		else
			Core.Status = "Idle"
		end
	end
end)

task.spawn(function()
	while true do
		task.wait(0.22)

		if Core.EspTargetMob then
			local folder = workspace:FindFirstChild("Enemies")
			if folder then
				for _, mob in ipairs(folder:GetChildren()) do
					local h = mob:FindFirstChildOfClass("Humanoid")
					if mob.Name == Core.TargetMobName and h and h.Health > 0 then
						local hpPct = math.clamp(math.floor((h.Health / math.max(1, h.MaxHealth)) * 100), 0, 100)
						ensureBillboard(mob, ESP_MOB_TAG, Color3.fromRGB(255, 130, 205), "[FARM] " .. mob.Name .. " (" .. hpPct .. "%)")
					else
						local old = mob:FindFirstChild(ESP_MOB_TAG)
						if old then old:Destroy() end
					end
				end
			end
		else
			clearMobEsp()
		end

		if Core.EspPlayers then
			local myChar, myHrp = getCharParts()
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr ~= player and plr.Character then
					local h = plr.Character:FindFirstChildOfClass("Humanoid")
					local r = plr.Character:FindFirstChild("HumanoidRootPart")
					if h and h.Health > 0 and r and myChar and myHrp then
						local dist = math.floor((r.Position - myHrp.Position).Magnitude)
						ensureBillboard(plr.Character, ESP_PLR_TAG, Color3.fromRGB(115, 225, 255), plr.Name .. " [" .. dist .. "m]")
					else
						local old = plr.Character:FindFirstChild(ESP_PLR_TAG)
						if old then old:Destroy() end
					end
				end
			end
		else
			clearPlayerEsp()
		end
	end
end)
local playerGui = player:WaitForChild("PlayerGui")
local oldUi = playerGui:FindFirstChild("KienVip94_UI_Full6")
if oldUi then oldUi:Destroy() end

local UI = {
	Bg = Color3.fromRGB(16, 17, 23),
	Panel = Color3.fromRGB(24, 26, 35),
	Row = Color3.fromRGB(32, 35, 47),
	Accent = Color3.fromRGB(95, 135, 255),
	Active = Color3.fromRGB(52, 199, 125),
	Inactive = Color3.fromRGB(55, 60, 76),
	Text = Color3.fromRGB(245, 247, 255),
	Sub = Color3.fromRGB(165, 172, 195),
}

local sg = Instance.new("ScreenGui")
sg.Name = "KienVip94_UI_Full6"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.IgnoreGuiInset = true
sg.Parent = playerGui

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleBtn"
toggleBtn.Size = UDim2.fromOffset(94, 36)
toggleBtn.Position = UDim2.fromOffset(14, 62)
toggleBtn.BackgroundColor3 = UI.Panel
toggleBtn.Text = "kienvip94"
toggleBtn.TextColor3 = UI.Text
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 12
toggleBtn.Active = true
toggleBtn.Draggable = true
toggleBtn.Parent = sg
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 10)
local tStroke = Instance.new("UIStroke", toggleBtn)
tStroke.Color = UI.Accent
tStroke.Thickness = 1.5

local win = Instance.new("Frame")
win.Name = "MainWindow"
win.Size = UDim2.fromOffset(480, 290)
win.Position = UDim2.fromScale(0.5, 0.5)
win.AnchorPoint = Vector2.new(0.5, 0.5)
win.BackgroundColor3 = UI.Bg
win.BorderSizePixel = 0
win.Visible = true
win.Active = true
win.Draggable = true
win.Parent = sg
Instance.new("UICorner", win).CornerRadius = UDim.new(0, 14)
local wStroke = Instance.new("UIStroke", win)
wStroke.Color = UI.Accent
wStroke.Thickness = 1.5

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 34)
header.BackgroundColor3 = UI.Panel
header.BorderSizePixel = 0
header.Parent = win
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 14)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -24, 1, 0)
title.Position = UDim2.fromOffset(14, 0)
title.BackgroundTransparency = 1
title.Text = "kienvip94"
title.TextColor3 = UI.Text
title.Font = Enum.Font.GothamBlack
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Thanh tab ngang ở trên
local topTabs = Instance.new("Frame")
topTabs.Size = UDim2.new(1, -16, 0, 34)
topTabs.Position = UDim2.fromOffset(8, 40)
topTabs.BackgroundColor3 = UI.Panel
topTabs.BorderSizePixel = 0
topTabs.Parent = win
Instance.new("UICorner", topTabs).CornerRadius = UDim.new(0, 10)

local hList = Instance.new("UIListLayout", topTabs)
hList.FillDirection = Enum.FillDirection.Horizontal
hList.Padding = UDim.new(0, 5)
hList.VerticalAlignment = Enum.VerticalAlignment.Center

local hPad = Instance.new("UIPadding", topTabs)
hPad.PaddingLeft = UDim.new(0, 6)
hPad.PaddingRight = UDim.new(0, 6)

local body = Instance.new("Frame")
body.Size = UDim2.new(1, -16, 1, -84)
body.Position = UDim2.fromOffset(8, 80)
body.BackgroundColor3 = UI.Panel
body.BorderSizePixel = 0
body.Parent = win
Instance.new("UICorner", body).CornerRadius = UDim.new(0, 10)

local tabBtns, tabPages = {}, {}

local function makeTopTab(name)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1 / 6, -5, 0, 24)
	b.BackgroundColor3 = UI.Inactive
	b.Text = name
	b.TextColor3 = UI.Sub
	b.Font = Enum.Font.GothamBold
	b.TextSize = 10
	b.Parent = topTabs
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)

	local page = Instance.new("ScrollingFrame")
	page.Size = UDim2.new(1, -12, 1, -12)
	page.Position = UDim2.fromOffset(6, 6)
	page.BackgroundTransparency = 1
	page.ScrollBarThickness = 3
	page.ScrollBarImageColor3 = UI.Accent
	page.Visible = false
	page.Parent = body

	local lay = Instance.new("UIListLayout", page)
	lay.Padding = UDim.new(0, 6)
	lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		page.CanvasSize = UDim2.new(0, 0, 0, lay.AbsoluteContentSize.Y + 8)
	end)

	tabBtns[name] = b
	tabPages[name] = page

	b.MouseButton1Click:Connect(function()
		for k, p in pairs(tabPages) do
			p.Visible = (k == name)
			tabBtns[k].BackgroundColor3 = (k == name) and UI.Accent or UI.Inactive
			tabBtns[k].TextColor3 = (k == name) and UI.Text or UI.Sub
		end
	end)

	return page
end

local function makeToggle(parent, text, defaultVal, callback)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -6, 0, 34)
	row.BackgroundColor3 = UI.Row
	row.BorderSizePixel = 0
	row.Parent = parent
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -74, 1, 0)
	lbl.Position = UDim2.fromOffset(10, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = UI.Text
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextSize = 11
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = row

	local sw = Instance.new("TextButton")
	sw.Size = UDim2.fromOffset(54, 22)
	sw.Position = UDim2.new(1, -62, 0.5, -11)
	sw.BackgroundColor3 = defaultVal and UI.Active or UI.Inactive
	sw.Text = defaultVal and "ON" or "OFF"
	sw.TextColor3 = UI.Text
	sw.Font = Enum.Font.GothamBold
	sw.TextSize = 11
	sw.Parent = row
	Instance.new("UICorner", sw).CornerRadius = UDim.new(0, 6)

	local state = defaultVal
	sw.MouseButton1Click:Connect(function()
		state = not state
		sw.BackgroundColor3 = state and UI.Active or UI.Inactive
		sw.Text = state and "ON" or "OFF"
		if callback then callback(state) end
	end)
end

local function makeActionBtn(parent, text, callback)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -6, 0, 32)
	b.BackgroundColor3 = UI.Row
	b.Text = text
	b.TextColor3 = UI.Text
	b.Font = Enum.Font.GothamBold
	b.TextSize = 11
	b.Parent = parent
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
	b.MouseButton1Click:Connect(function()
		if callback then callback() end
	end)
end

local function makeInfo(parent, text)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -6, 0, 32)
	row.BackgroundColor3 = UI.Row
	row.BorderSizePixel = 0
	row.Parent = parent
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -16, 1, 0)
	lbl.Position = UDim2.fromOffset(10, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = UI.Text
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextSize = 11
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = row
	return lbl
end

local pFarm = makeTopTab("Farm Lv")
local pCombat = makeTopTab("Combat")
local pFruit = makeTopTab("Trái ÁQ")
local pStats = makeTopTab("Stats")
local pEsp = makeTopTab("ESP")
local pMisc = makeTopTab("Khác")

-- Tab Farm Lv
makeToggle(pFarm, "Auto Farm Level (Bay 145 + Đợi NV Mất)", Core.AutoFarm, function(v) Core.AutoFarm = v end)
makeToggle(pFarm, "Nhận NV Khi Giao Diện NV Biến Mất", Core.AutoQuest, function(v) Core.AutoQuest = v end)
local infoLbl = makeInfo(pFarm, "Sea 1 | Lv.1 | Bandit | NV: NV biến mất -> Nhận tiếp")
local statusLbl = makeInfo(pFarm, "Trạng thái: Idle")

-- Tab Combat
makeToggle(pCombat, "Fast Attack (0.13s / Range 60)", Core.AutoAttack, function(v) Core.AutoAttack = v end)
makeToggle(pCombat, "Auto Buso Haki", Core.AutoHaki, function(v) Core.AutoHaki = v end)
makeToggle(pCombat, "Auto Ken (Observation)", Core.AutoKen, function(v) Core.AutoKen = v end)

-- Tab Trái ÁQ
makeToggle(pFruit, "Auto Nhặt Trái Ác Quỷ (Spawn + Người Vứt)", Core.AutoPickupFruit, function(v) Core.AutoPickupFruit = v end)
makeToggle(pFruit, "Auto Quay Trái Ác Quỷ (Random)", Core.AutoRandomFruit, function(v) Core.AutoRandomFruit = v end)
makeActionBtn(pFruit, "Quay Trái Ngay 1 Lần", function()
	local commF = getCommF()
	if commF then
		pcall(function() commF:InvokeServer("CrollFruit") end)
		pcall(function() commF:InvokeServer("BuyFruit") end)
		pcall(function() commF:InvokeServer("GetRandomFruit") end)
	end
end)

-- Tab Stats
makeToggle(pStats, "Auto Cộng Điểm Stats", Core.AutoStats, function(v) Core.AutoStats = v end)
local statModeLbl = makeInfo(pStats, "Đang cộng vào: " .. CFG.StatChoice)
makeActionBtn(pStats, "Đổi Stat: Melee", function() CFG.StatChoice = "Melee"; statModeLbl.Text = "Đang cộng vào: Melee" end)
makeActionBtn(pStats, "Đổi Stat: Defense", function() CFG.StatChoice = "Defense"; statModeLbl.Text = "Đang cộng vào: Defense" end)
makeActionBtn(pStats, "Đổi Stat: Sword", function() CFG.StatChoice = "Sword"; statModeLbl.Text = "Đang cộng vào: Sword" end)
makeActionBtn(pStats, "Đổi Stat: Demon Fruit", function() CFG.StatChoice = "Demon Fruit"; statModeLbl.Text = "Đang cộng vào: Demon Fruit" end)

-- Tab ESP
makeToggle(pEsp, "ESP Tên Con Quái Chuẩn Bị Farm Level", Core.EspTargetMob, function(v) Core.EspTargetMob = v; if not v then clearMobEsp() end end)
makeToggle(pEsp, "ESP Người Chơi", Core.EspPlayers, function(v) Core.EspPlayers = v; if not v then clearPlayerEsp() end end)
local espMobLbl = makeInfo(pEsp, "Mục tiêu ESP: Bandit")

-- Tab Khác
makeToggle(pMisc, "Anti AFK", Core.AntiAfk, function(v) Core.AntiAfk = v end)
makeActionBtn(pMisc, "Bay Tới NPC NV Hiện Tại (Tốc Độ 145)", function()
	local char, hrp, hum = getCharParts()
	if char and hrp and hum then
		local q = getQuestForSeaAndLevel(Core.CurrentSea, Core.CurrentLevel)
		flyToNpcAndAcceptQuest(hrp, hum, q)
	end
end)

task.spawn(function()
	while true do
		task.wait(0.25)
		infoLbl.Text = string.format("Sea %d | Lv.%d | %s | NV: %s", Core.CurrentSea, Core.CurrentLevel, Core.TargetMobName, Core.QuestProgressText)
		statusLbl.Text = "Trạng thái: " .. tostring(Core.Status)
		espMobLbl.Text = "Mục tiêu ESP: " .. tostring(Core.TargetMobName)
	end
end)

tabBtns["Farm Lv"].BackgroundColor3 = UI.Accent
tabBtns["Farm Lv"].TextColor3 = UI.Text
tabPages["Farm Lv"].Visible = true

toggleBtn.MouseButton1Click:Connect(function()
	win.Visible = not win.Visible
end)
