local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

local CFG = {
	Brand = "√12kientomato",
	Title = "KIÊN PRO MAX • LVL",
	MaxLevelCap = 3000,
	Range = 60,
	Delay = 0.13,
	Speed = 150,
	Height = 8,
	QuestCooldown = 4.0,
	LevelScanInterval = 0.25,
	BusoInterval = 3.5,
	StatInterval = 0.75,
	StatOrder = {"Melee", "Defense", "Sword", "Demon Fruit", "Gun"},
	StatIndex = 1,
	AutoFarm = false,
	AutoQuest = true,
	AutoMelee = true,
	AutoBuso = true,
	AutoStats = true,
	AutoFixLag = true,
	Session = "20404cc8",
}

local MELEE_NAMES = {
	"combat", "dark step", "electric", "water kung fu", "dragon breath",
	"superhuman", "death step", "sharkman karate", "electric claw",
	"dragon talon", "godhuman", "sanguine art",
}

-- {MinLv, MaxLv, IslandName, IslandPos, NpcName, QuestName, QuestIdx, MobName}
local LEVEL_TABLE = {
	{1, 9, "Starter Island", Vector3.new(1060, 17, 1547), "Bandit Quest Giver", "BanditQuest1", 1, "Bandit"},
	{10, 29, "Jungle", Vector3.new(-1598, 36, 153), "Jungle Quest Giver", "JungleQuest", 1, "Monkey"},
	{30, 59, "Pirate Village", Vector3.new(-1120, 15, 3830), "Pirate Quest Giver", "BuggyQuest1", 1, "Pirate"},
	{60, 89, "Desert", Vector3.new(897, 6, 4390), "Desert Quest Giver", "DesertQuest", 1, "Desert Bandit"},
	{90, 119, "Frozen Village", Vector3.new(1390, 87, -1298), "Snow Quest Giver", "SnowQuest", 1, "Snow Bandit"},
	{120, 149, "Marine Fortress", Vector3.new(-2781, 24, 2060), "Marine Quest Giver", "MarineQuest2", 1, "Chief Petty Officer"},
	{150, 199, "Skylands", Vector3.new(-4840, 718, -2620), "Sky Quest Giver", "SkyQuest", 1, "Sky Bandit"},
	{200, 299, "Prison", Vector3.new(4875, 6, 736), "Prisoner Quest Giver", "PrisonerQuest", 1, "Prisoner"},
	{300, 374, "Colosseum", Vector3.new(-1825, 45, -2740), "Colosseum Quest Giver", "ColosseumQuest", 1, "Toga Warrior"},
	{375, 449, "Magma Village", Vector3.new(-5315, 12, 8515), "Magma Quest Giver", "MagmaQuest", 1, "Military Soldier"},
	{450, 524, "Underwater City", Vector3.new(61120, 18, 1569), "Fishman Quest Giver", "FishmanQuest", 1, "Fishman Warrior"},
	{525, 624, "Upper Skylands", Vector3.new(-4720, 846, -1950), "Sky Exp Quest Giver", "SkyExp1Quest", 1, "God's Guard"},
	{625, 699, "Fountain / Upper Sky", Vector3.new(-7625, 5605, -1460), "Upper Sky Quest Giver", "SkyExp2Quest", 1, "Royal Squad"},

	-- Sea 2 (700 - 1500)
	{700, 774, "Kingdom of Rose", Vector3.new(-425, 73, 1835), "Area 1 Quest Giver", "Area1Quest", 1, "Raider"},
	{775, 874, "Green Zone", Vector3.new(-975, 73, 1420), "Area 1 Quest Giver", "Area1Quest", 2, "Mercenary"},
	{875, 949, "Factory / Rose", Vector3.new(978, 122, 1240), "Area 2 Quest Giver", "Area2Quest", 1, "Swan Pirate"},
	{950, 999, "Marine Base G1", Vector3.new(-2440, 73, -3215), "Marine Quest Giver 2", "MarineQuest3", 1, "Marine Lieutenant"},
	{1000, 1099, "Graveyard", Vector3.new(-5495, 48, -795), "Zombie Quest Giver", "ZombieQuest", 1, "Zombie"},
	{1100, 1199, "Snow Mountain", Vector3.new(535, 401, -5330), "Snow Mountain Quest Giver", "SnowMountainQuest", 1, "Snow Trooper"},
	{1200, 1274, "Hot & Cold (Ice)", Vector3.new(-5780, 42, -4485), "Ice Side Quest Giver", "IceSideQuest", 1, "Lab Subordinate"},
	{1275, 1349, "Hot & Cold (Fire)", Vector3.new(-5428, 42, -5960), "Fire Side Quest Giver", "FireSideQuest", 1, "Magma Ninja"},
	{1350, 1424, "Cursed Ship Deck", Vector3.new(1040, 125, 32910), "Ship Deck Quest Giver", "ShipQuest1", 1, "Ship Deckhand"},
	{1425, 1499, "Cursed Ship Inside", Vector3.new(915, 141, 33410), "Ship Interior Quest Giver", "ShipQuest2", 1, "Ship Steward"},

	-- Sea 3 (1500 - 3000)
	{1500, 1574, "Port Town", Vector3.new(-290, 44, 5580), "Port Quest Giver", "PortQuest", 1, "Pirate Millionaire"},
	{1575, 1624, "Hydra Island", Vector3.new(5295, 1005, 395), "Hydra Quest Giver", "HydraQuest", 1, "Dragon Crew Warrior"},
	{1625, 1699, "Great Tree", Vector3.new(2280, 26, -6400), "Great Tree Quest Giver", "TreeQuest", 1, "Marine Commodore"},
	{1700, 1774, "Floating Turtle", Vector3.new(-10560, 332, -8460), "Turtle Quest Giver", "TurtleQuest", 1, "Fishman Raider"},
	{1775, 1824, "Mansion", Vector3.new(-13225, 332, -7625), "Mansion Quest Giver", "MansionQuest", 1, "Forest Pirate"},
	{1825, 1899, "Haunted Castle", Vector3.new(-12120, 332, -10450), "Haunted Quest Giver", "HauntedQuest1", 1, "Jungle Pirate"},
	{1900, 1999, "Haunted Grave", Vector3.new(-8760, 142, 6060), "Haunted Quest Giver 2", "HauntedQuest2", 1, "Reborn Skeleton"},
	{2000, 2074, "Sea of Treats", Vector3.new(-2020, 38, -12025), "Cake Quest Giver", "CakeQuest1", 1, "Cookie Crafter"},
	{2075, 2149, "Cake Island", Vector3.new(-1925, 38, -12855), "Cake Quest Giver 2", "CakeQuest2", 1, "Baking Staff"},
	{2150, 2249, "Chocolate Island", Vector3.new(235, 25, -12195), "Choc Quest Giver", "ChocQuest1", 1, "Cocoa Warrior"},
	{2250, 2399, "Candy Island", Vector3.new(-1150, 14, -14930), "Candy Quest Giver", "CandyQuest1", 1, "Candy Pirate"},
	{2400, 2524, "Tiki Outpost", Vector3.new(-16160, 12, 1345), "Tiki Quest Giver", "TikiQuest1", 1, "Isle Outlaw"},
	{2525, 2674, "Tiki Upper / Sub-Zone", Vector3.new(-16350, 15, -1060), "Tiki Quest Giver 2", "TikiQuest2", 1, "Sun-kissed Warrior"},
	{2675, 2850, "Late Sea 3 Grind", Vector3.new(-16620, 110, -1040), "Tiki Quest Giver 2", "TikiQuest2", 2, "Isle Champion"},
	{2851, 9999, "Max Level Zone (3000)", Vector3.new(-16620, 110, -1040), "Tiki Quest Giver 2", "TikiQuest2", 2, "Isle Champion"},
}

local App = {
	Open = true,
	TrackedLv = nil,
	LastLvScan = 0,
	LastLevelGainText = "Chưa tăng Lv",
	LastIsland = nil,
	LastAtk = 0,
	LastMelee = 0,
	LastBuso = 0,
	LastStat = 0,
	LastQuestCall = 0,
	QuestActive = false,
	QuestStartLv = nil,
	QuestStageKey = nil,
	LastProgressText = "Chưa có NV",
	BV = nil,
	BG = nil,
	NotifyLbl = nil,
	LvLbl = nil,
	TargetLbl = nil,
	StateLbl = nil,
	FarmBtn = nil,
	QuestBtn = nil,
	MeleeBtn = nil,
	BusoBtn = nil,
	StatBtn = nil,
	StatCycleBtn = nil,
}

local function notify(txt)
	if App.NotifyLbl then
		App.NotifyLbl.Text = "🔔 " .. tostring(txt)
	end
end

local function getStatName()
	return CFG.StatOrder[CFG.StatIndex] or "Melee"
end

local function applyFixLag()
	if not CFG.AutoFixLag then return end
	pcall(function()
		Lighting.GlobalShadows = false
		Lighting.FogEnd = 1e6
		for _, eff in ipairs(Lighting:GetChildren()) do
			if eff:IsA("PostEffect") then
				eff.Enabled = false
			end
		end
	end)
	pcall(function()
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Fire") or obj:IsA("Smoke") then
				obj.Enabled = false
			elseif obj:IsA("BasePart") then
				obj.Material = Enum.Material.SmoothPlastic
				obj.Reflectance = 0
			end
		end
	end)
end

local function readLevelIn(root)
	if not root then return nil end
	for _, n in ipairs({"Level", "Lvl", "Lv", "level", "lvl"}) do
		local v = root:FindFirstChild(n)
		if v and v:IsA("ValueBase") and tonumber(v.Value) then
			return tonumber(v.Value)
		end
	end
	for _, d in ipairs(root:GetDescendants()) do
		if d:IsA("ValueBase") and tonumber(d.Value) then
			local low = string.lower(d.Name)
			if low == "level" or low == "lvl" or low == "lv" then
				return tonumber(d.Value)
			end
		end
	end
	return nil
end

local function getPlayerLevel()
	local lv = readLevelIn(LocalPlayer:FindFirstChild("leaderstats"))
		or readLevelIn(LocalPlayer:FindFirstChild("Data"))
		or readLevelIn(LocalPlayer)
		or 1
	return math.min(lv, CFG.MaxLevelCap)
end

local function getAvailableStatPoints()
	local containers = {
		LocalPlayer:FindFirstChild("Data"),
		LocalPlayer:FindFirstChild("leaderstats"),
		LocalPlayer,
	}
	for _, c in ipairs(containers) do
		if c then
			local pts = c:FindFirstChild("Points") or c:FindFirstChild("StatPoints") or c:FindFirstChild("AvailablePoints")
			if pts and pts:IsA("ValueBase") and tonumber(pts.Value) then
				return tonumber(pts.Value)
			end
		end
	end
	return 0
end

local function getStageByLevel(lv)
	for _, row in ipairs(LEVEL_TABLE) do
		if lv >= row[1] and lv <= row[2] then
			return {
				minLv = row[1], maxLv = row[2], island = row[3], islandPos = row[4],
				npc = row[5], quest = row[6], questIdx = row[7], mob = row[8],
			}
		end
	end
	local last = LEVEL_TABLE[#LEVEL_TABLE]
	return {
		minLv = last[1], maxLv = last[2], island = last[3], islandPos = last[4],
		npc = last[5], quest = last[6], questIdx = last[7], mob = last[8],
	}
end

local function scanDirectLevelUp(lv, now)
	if App.TrackedLv == nil then
		App.TrackedLv = lv
		return false, 0
	end
	if (now - App.LastLvScan) < CFG.LevelScanInterval then
		return false, 0
	end
	App.LastLvScan = now
	if lv > App.TrackedLv then
		local gained = lv - App.TrackedLv
		App.TrackedLv = lv
		App.LastLevelGainText = "+" .. tostring(gained) .. " Lv (Đánh quái)"
		return true, gained
	elseif lv < App.TrackedLv then
		App.TrackedLv = lv
	end
	return false, 0
end

local function isBusoActive(char)
	if not char then return false end
	if char:GetAttribute("BusoActive") == true or char:GetAttribute("HasBuso") == true then
		return true
	end
	if char:FindFirstChild("HasBuso") then
		return true
	end
	for _, p in ipairs(char:GetChildren()) do
		if p:IsA("BasePart") and string.find(string.lower(p.Name), "arm", 1, true) then
			if p.Material == Enum.Material.Neon or p.Color == Color3.fromRGB(25, 25, 25) then
				return true
			end
		end
	end
	return false
end

local function activateBuso(char)
	if not CFG.AutoBuso or isBusoActive(char) then return end
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	local commF = (remotes and remotes:FindFirstChild("CommF_")) or ReplicatedStorage:FindFirstChild("CommF_")
	if commF and commF:IsA("RemoteFunction") then
		pcall(function() commF:InvokeServer("Buso") end)
	end
	for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
		if d:IsA("RemoteEvent") and string.find(string.lower(d.Name), "buso", 1, true) then
			pcall(function() d:FireServer() end)
		end
	end
end

local function addStatPoint(statName, amount)
	local pts = getAvailableStatPoints()
	if pts <= 0 then return false end
	local addCount = math.clamp(amount or 1, 1, math.min(pts, 10))
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	local commF = (remotes and remotes:FindFirstChild("CommF_")) or ReplicatedStorage:FindFirstChild("CommF_")
	if commF and commF:IsA("RemoteFunction") then
		local ok = pcall(function()
			commF:InvokeServer("AddPoint", statName, addCount)
		end)
		return ok
	end
	return false
end

local function scanQuestBanner()
	local pg = LocalPlayer:FindFirstChild("PlayerGui")
	if not pg then return false, "Không thấy NV", 0, 0 end

	local foundVisibleQuest = false
	local bestText = nil
	local curN, totN = 0, 0

	for _, gui in ipairs(pg:GetChildren()) do
		if gui:IsA("ScreenGui") and gui.Name ~= "KienProMaxLvlGui" and gui.Enabled then
			for _, obj in ipairs(gui:GetDescendants()) do
				if obj:IsA("GuiObject") and obj.Visible then
					local lowName = string.lower(obj.Name)
					local pos = obj.AbsolutePosition
					if pos.Y >= 0 and pos.Y <= 260 and string.find(lowName, "quest", 1, true) then
						foundVisibleQuest = true
					end
					if obj:IsA("TextLabel") and obj.Text and obj.Text ~= "" and pos.Y <= 260 then
						local a, b = string.match(obj.Text, "(%d+)%s*/%s*(%d+)")
						if a and b then
							foundVisibleQuest = true
							curN = tonumber(a) or 0
							totN = tonumber(b) or 0
							bestText = "NV: " .. a .. "/" .. b
						end
					end
				end
			end
		end
	end

	if bestText then
		return true, bestText, curN, totN
	end
	if foundVisibleQuest then
		return true, "NV đang chạy", 0, 0
	end
	return false, "Chưa nhận NV", 0, 0
end

local function isMeleeTool(tool)
	if not tool or not tool:IsA("Tool") then return false end
	local attr = tool:GetAttribute("WeaponType")
	if type(attr) == "string" and string.lower(attr) == "melee" then return true end
	local low = string.lower(tool.Name)
	for _, n in ipairs(MELEE_NAMES) do
		if string.find(low, n, 1, true) then return true end
	end
	return string.find(low, "melee", 1, true) ~= nil
end

local function equipMelee(char, hum)
	if not CFG.AutoMelee or not char or not hum then return nil end
	local cur = char:FindFirstChildOfClass("Tool")
	if cur and isMeleeTool(cur) then return cur end
	local pack = LocalPlayer:FindFirstChild("Backpack")
	if pack then
		for _, item in ipairs(pack:GetChildren()) do
			if isMeleeTool(item) then
				pcall(function() hum:EquipTool(item) end)
				return item
			end
		end
	end
	return cur
end

local function setNoClip(char, on)
	if not char then return end
	for _, p in ipairs(char:GetDescendants()) do
		if p:IsA("BasePart") then p.CanCollide = not on end
	end
end

local function stopFlight()
	if App.BV then pcall(function() App.BV:Destroy() end) App.BV = nil end
	if App.BG then pcall(function() App.BG:Destroy() end) App.BG = nil end
	setNoClip(LocalPlayer.Character, false)
end

local function flyTo(char, hum, hrp, goalPos, dt)
	if not char or not hum or not hrp or not goalPos then return end
	setNoClip(char, true)
	pcall(function() hum:ChangeState(Enum.HumanoidStateType.Physics) end)

	if not App.BV or App.BV.Parent ~= hrp then
		if App.BV then pcall(function() App.BV:Destroy() end) end
		local vel = Instance.new("BodyVelocity")
		vel.Name = "KienLvlVel"
		vel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		vel.Velocity = Vector3.zero
		vel.Parent = hrp
		App.BV = vel
	end

	if not App.BG or App.BG.Parent ~= hrp then
		if App.BG then pcall(function() App.BG:Destroy() end) end
		local gyro = Instance.new("BodyGyro")
		gyro.Name = "KienLvlGyro"
		gyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
		gyro.P = 12000
		gyro.D = 450
		gyro.CFrame = hrp.CFrame
		gyro.Parent = hrp
		App.BG = gyro
	end

	local diff = goalPos - hrp.Position
	local dist = diff.Magnitude
	local stepDt = math.clamp(dt or 0.016, 0.008, 0.04)

	if dist > 2.5 then
		local dir = diff.Unit
		local spd = math.min(CFG.Speed, math.max(55, dist * 7))
		App.BV.Velocity = dir * spd
		hrp.CFrame = CFrame.new(hrp.Position + dir * math.min(dist, spd * stepDt))
	else
		App.BV.Velocity = Vector3.zero
		hrp.CFrame = CFrame.new(goalPos)
	end

	local lookTarget = Vector3.new(goalPos.X, hrp.Position.Y - CFG.Height, goalPos.Z)
	if (lookTarget - hrp.Position).Magnitude > 0.1 then
		App.BG.CFrame = CFrame.lookAt(hrp.Position, lookTarget)
	end
end

local function findNearestMob(hrp, mobName)
	local folder = workspace:FindFirstChild("Enemies")
	if not folder or not hrp then return nil end
	local low = string.lower(mobName)
	local best, bestDist = nil, math.huge
	for _, m in ipairs(folder:GetChildren()) do
		if m:IsA("Model") and string.find(string.lower(m.Name), low, 1, true) then
			local h = m:FindFirstChildOfClass("Humanoid")
			local p = m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("Head")
			if h and h.Health > 0 and p and p:IsDescendantOf(workspace) then
				local d = (p.Position - hrp.Position).Magnitude
				if d < bestDist then
					bestDist, best = d, p
				end
			end
		end
	end
	return best
end

local function takeQuestOnce(stage)
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	local commF = (remotes and remotes:FindFirstChild("CommF_")) or ReplicatedStorage:FindFirstChild("CommF_")
	if commF and commF:IsA("RemoteFunction") then
		pcall(function() commF:InvokeServer("StartQuest", stage.quest, stage.questIdx) end)
	end
	local npcFolder = workspace:FindFirstChild("NPCs")
	local npcModel = npcFolder and npcFolder:FindFirstChild(stage.npc)
	local reTalk = remotes and remotes:FindFirstChild("OnTalkToNPC")
	if npcModel and reTalk then
		pcall(function() reTalk:FireServer(npcModel) end)
	end
end
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Net = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Net")
local RE_Atk = Net and Net:FindFirstChild("RE/RegisterAttack")
local RE_Hit = Net and Net:FindFirstChild("RE/RegisterHit")

local function getUiContainer()
	if type(gethui) == "function" then
		local ok, hui = pcall(gethui)
		if ok and hui then return hui end
	end
	local okCore, core = pcall(function() return CoreGui end)
	if okCore and core then return core end
	return LocalPlayer:FindFirstChild("PlayerGui")
end

local function syncToggleButtons()
	if App.FarmBtn then
		App.FarmBtn.Text = CFG.AutoFarm and "⚡ Auto Farm Level: ON" or "⚡ Auto Farm Level: OFF"
		App.FarmBtn.BackgroundColor3 = CFG.AutoFarm and Color3.fromRGB(16, 185, 129) or Color3.fromRGB(220, 55, 78)
	end
	if App.QuestBtn then
		App.QuestBtn.Text = CFG.AutoQuest and "📜 Auto Quest: ON" or "📜 Auto Quest: OFF"
		App.QuestBtn.BackgroundColor3 = CFG.AutoQuest and Color3.fromRGB(59, 130, 246) or Color3.fromRGB(62, 68, 92)
	end
	if App.MeleeBtn then
		App.MeleeBtn.Text = CFG.AutoMelee and "🥊 Auto Melee: ON" or "🥊 Auto Melee: OFF"
		App.MeleeBtn.BackgroundColor3 = CFG.AutoMelee and Color3.fromRGB(139, 92, 246) or Color3.fromRGB(62, 68, 92)
	end
	if App.BusoBtn then
		App.BusoBtn.Text = CFG.AutoBuso and "🛡️ Buso Haki: ON" or "🛡️ Buso Haki: OFF"
		App.BusoBtn.BackgroundColor3 = CFG.AutoBuso and Color3.fromRGB(14, 165, 233) or Color3.fromRGB(62, 68, 92)
	end
	if App.StatBtn then
		App.StatBtn.Text = CFG.AutoStats and "📈 Auto Stat: ON" or "📈 Auto Stat: OFF"
		App.StatBtn.BackgroundColor3 = CFG.AutoStats and Color3.fromRGB(234, 179, 8) or Color3.fromRGB(62, 68, 92)
		App.StatBtn.TextColor3 = CFG.AutoStats and Color3.fromRGB(15, 20, 34) or Color3.fromRGB(255, 255, 255)
	end
	if App.StatCycleBtn then
		App.StatCycleBtn.Text = "Stat: " .. getStatName()
	end
end

local function buildLvlUI()
	local parent = getUiContainer()
	if not parent then return end

	local old = parent:FindFirstChild("KienProMaxLvlGui")
	if old then pcall(function() old:Destroy() end) end

	local sg = Instance.new("ScreenGui")
	sg.Name = "KienProMaxLvlGui"
	sg.ResetOnSpawn = false
	sg.DisplayOrder = 10000
	pcall(function() sg.Parent = parent end)
	if not sg.Parent then sg.Parent = LocalPlayer:WaitForChild("PlayerGui", 5) end

	App.NotifyLbl = Instance.new("TextLabel")
	App.NotifyLbl.Size = UDim2.new(0, 320, 0, 28)
	App.NotifyLbl.Position = UDim2.new(0.5, -160, 0.03, 0)
	App.NotifyLbl.BackgroundColor3 = Color3.fromRGB(10, 14, 26)
	App.NotifyLbl.BackgroundTransparency = 0.2
	App.NotifyLbl.TextColor3 = Color3.fromRGB(56, 248, 255)
	App.NotifyLbl.Font = Enum.Font.GothamBold
	App.NotifyLbl.TextSize = 11
	App.NotifyLbl.Text = "🔔 " .. CFG.Title .. " • " .. CFG.Brand .. " (Buso + Stat)"
	App.NotifyLbl.Parent = sg
	Instance.new("UICorner", App.NotifyLbl).CornerRadius = UDim.new(0, 10)
	local nStroke = Instance.new("UIStroke", App.NotifyLbl)
	nStroke.Color = Color3.fromRGB(56, 248, 255)
	nStroke.Transparency = 0.45

	local kBtn = Instance.new("TextButton")
	kBtn.Size = UDim2.new(0, 48, 0, 48)
	kBtn.Position = UDim2.new(0.86, 0, 0.15, 0)
	kBtn.BackgroundColor3 = Color3.fromRGB(15, 20, 36)
	kBtn.BackgroundTransparency = 0.12
	kBtn.Text = "K"
	kBtn.Font = Enum.Font.GothamBlack
	kBtn.TextSize = 22
	kBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	kBtn.Parent = sg
	Instance.new("UICorner", kBtn).CornerRadius = UDim.new(1, 0)
	local kStroke = Instance.new("UIStroke", kBtn)
	kStroke.Thickness = 2
	local kGrad = Instance.new("UIGradient", kStroke)
	kGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(56, 248, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(168, 85, 247)),
	})

	local card = Instance.new("Frame")
	card.Size = UDim2.new(0, 298, 0, 292)
	card.Position = UDim2.new(0.5, -149, 0.52, -146)
	card.BackgroundColor3 = Color3.fromRGB(10, 14, 26)
	card.BackgroundTransparency = 0.2
	card.Visible = App.Open
	card.Parent = sg
	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 16)
	local cStroke = Instance.new("UIStroke", card)
	cStroke.Thickness = 1.8
	local cGrad = Instance.new("UIGradient", cStroke)
	cGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(56, 248, 255)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(168, 85, 247)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 185, 129)),
	})

	local head = Instance.new("TextLabel")
	head.Size = UDim2.new(1, -16, 0, 24)
	head.Position = UDim2.new(0, 8, 0, 6)
	head.BackgroundTransparency = 1
	head.Text = "⚡ " .. CFG.Title .. " • " .. CFG.Brand
	head.TextColor3 = Color3.fromRGB(56, 248, 255)
	head.Font = Enum.Font.GothamBlack
	head.TextSize = 12
	head.TextXAlignment = Enum.TextXAlignment.Left
	head.Parent = card

	App.LvLbl = Instance.new("TextLabel")
	App.LvLbl.Size = UDim2.new(1, -16, 0, 18)
	App.LvLbl.Position = UDim2.new(0, 8, 0, 30)
	App.LvLbl.BackgroundTransparency = 1
	App.LvLbl.Text = "Lv: 1 / " .. CFG.MaxLevelCap .. " • " .. App.LastLevelGainText
	App.LvLbl.TextColor3 = Color3.fromRGB(245, 250, 255)
	App.LvLbl.Font = Enum.Font.GothamBold
	App.LvLbl.TextSize = 11
	App.LvLbl.TextXAlignment = Enum.TextXAlignment.Left
	App.LvLbl.Parent = card

	App.TargetLbl = Instance.new("TextLabel")
	App.TargetLbl.Size = UDim2.new(1, -16, 0, 18)
	App.TargetLbl.Position = UDim2.new(0, 8, 0, 48)
	App.TargetLbl.BackgroundTransparency = 1
	App.TargetLbl.Text = "Bandit • Starter Island"
	App.TargetLbl.TextColor3 = Color3.fromRGB(145, 225, 255)
	App.TargetLbl.Font = Enum.Font.GothamMedium
	App.TargetLbl.TextSize = 10
	App.TargetLbl.TextXAlignment = Enum.TextXAlignment.Left
	App.TargetLbl.Parent = card

	App.StateLbl = Instance.new("TextLabel")
	App.StateLbl.Size = UDim2.new(1, -16, 0, 18)
	App.StateLbl.Position = UDim2.new(0, 8, 0, 66)
	App.StateLbl.BackgroundTransparency = 1
	App.StateLbl.Text = "Trạng thái: Sẵn sàng"
	App.StateLbl.TextColor3 = Color3.fromRGB(255, 210, 95)
	App.StateLbl.Font = Enum.Font.GothamBold
	App.StateLbl.TextSize = 10
	App.StateLbl.TextXAlignment = Enum.TextXAlignment.Left
	App.StateLbl.Parent = card

	local function makeFullBtn(y, h)
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1, -16, 0, h)
		b.Position = UDim2.new(0, 8, 0, y)
		b.Font = Enum.Font.GothamBold
		b.TextSize = 11
		b.TextColor3 = Color3.fromRGB(255, 255, 255)
		b.Parent = card
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 9)
		return b
	end

	local function makeHalfBtn(xScale, xOffset, y, h, wOffset)
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(0.5, wOffset, 0, h)
		b.Position = UDim2.new(xScale, xOffset, 0, y)
		b.Font = Enum.Font.GothamBold
		b.TextSize = 11
		b.TextColor3 = Color3.fromRGB(255, 255, 255)
		b.Parent = card
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 9)
		return b
	end

	App.FarmBtn = makeFullBtn(90, 36)
	App.QuestBtn = makeHalfBtn(0, 8, 132, 34, -12)
	App.MeleeBtn = makeHalfBtn(0.5, 4, 132, 34, -12)
	App.BusoBtn = makeHalfBtn(0, 8, 172, 34, -12)
	App.StatBtn = makeHalfBtn(0.5, 4, 172, 34, -12)
	App.StatCycleBtn = makeFullBtn(212, 32)
	App.StatCycleBtn.BackgroundColor3 = Color3.fromRGB(30, 41, 68)

	App.FarmBtn.MouseButton1Click:Connect(function()
		CFG.AutoFarm = not CFG.AutoFarm
		if not CFG.AutoFarm then stopFlight() end
		syncToggleButtons()
		notify(CFG.AutoFarm and "Bật Auto Farm Level (Bay 150)" or "Tắt Auto Farm Level")
	end)

	App.QuestBtn.MouseButton1Click:Connect(function()
		CFG.AutoQuest = not CFG.AutoQuest
		if not CFG.AutoQuest then
			App.QuestActive = false
			App.QuestStartLv = nil
		end
		syncToggleButtons()
		notify(CFG.AutoQuest and "Bật Auto Quest" or "Tắt Auto Quest")
	end)

	App.MeleeBtn.MouseButton1Click:Connect(function()
		CFG.AutoMelee = not CFG.AutoMelee
		syncToggleButtons()
		notify(CFG.AutoMelee and "Bật Auto Melee" or "Tắt Auto Melee")
	end)

	App.BusoBtn.MouseButton1Click:Connect(function()
		CFG.AutoBuso = not CFG.AutoBuso
		if CFG.AutoBuso and LocalPlayer.Character then
			activateBuso(LocalPlayer.Character)
		end
		syncToggleButtons()
		notify(CFG.AutoBuso and "Bật Auto Buso Haki" or "Tắt Auto Buso Haki")
	end)

	App.StatBtn.MouseButton1Click:Connect(function()
		CFG.AutoStats = not CFG.AutoStats
		syncToggleButtons()
		notify(CFG.AutoStats and ("Bật Auto Stat -> " .. getStatName()) or "Tắt Auto Stat")
	end)

	App.StatCycleBtn.MouseButton1Click:Connect(function()
		CFG.StatIndex = (CFG.StatIndex % #CFG.StatOrder) + 1
		syncToggleButtons()
		notify("Đổi cộng điểm: " .. getStatName())
	end)

	kBtn.MouseButton1Click:Connect(function()
		App.Open = not App.Open
		card.Visible = App.Open
		if App.Open then
			card.Size = UDim2.new(0, 45, 0, 40)
			TweenService:Create(card, TweenInfo.new(0.26, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, 298, 0, 292)
			}):Play()
		end
	end)

	local dragging, dInp, sInp, sPos = false
	card.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging, sInp, sPos = true, inp.Position, card.Position
			inp.Changed:Connect(function()
				if inp.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	card.InputChanged:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseMovement then
			dInp = inp
		end
	end)
	UserInputService.InputChanged:Connect(function(inp)
		if inp == dInp and dragging then
			local delta = inp.Position - sInp
			card.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + delta.X, sPos.Y.Scale, sPos.Y.Offset + delta.Y)
		end
	end)

	syncToggleButtons()

	card.Size = UDim2.new(0, 50, 0, 36)
	TweenService:Create(card, TweenInfo.new(0.42, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 298, 0, 292)
	}):Play()

	task.spawn(function()
		while card.Parent do
			cGrad.Rotation = (cGrad.Rotation + 2) % 360
			kGrad.Rotation = (kGrad.Rotation - 2) % 360
			task.wait(0.03)
		end
	end)
end

pcall(buildLvlUI)
task.spawn(applyFixLag)

RunService.Heartbeat:Connect(function(dt)
	local now = os.clock()
	local lv = getPlayerLevel()
	local leveledDirect, gainedLv = scanDirectLevelUp(lv, now)
	local stage = getStageByLevel(lv)
	local stageKey = stage.quest .. "_" .. tostring(stage.questIdx)
	local hasGui, progText, curCount, totalCount = scanQuestBanner()

	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local hrp = char and char:FindFirstChild("HumanoidRootPart")

	if CFG.AutoBuso and char and (now - App.LastBuso >= CFG.BusoInterval) then
		App.LastBuso = now
		activateBuso(char)
	end

	if CFG.AutoStats and (leveledDirect or (now - App.LastStat >= CFG.StatInterval)) then
		App.LastStat = now
		addStatPoint(getStatName(), gainedLv > 0 and gainedLv or 1)
	end

	if leveledDirect then
		notify("Lên +" .. tostring(gainedLv) .. " Lv (Lv " .. lv .. ") -> " .. stage.island)
	end

	if App.LastIsland ~= nil and App.LastIsland ~= stage.island and CFG.AutoFarm then
		notify("Đủ level! Bay qua đảo " .. stage.island)
	end
	App.LastIsland = stage.island

	if App.QuestActive then
		local leveledUpSinceTake = (App.QuestStartLv ~= nil) and (lv > App.QuestStartLv)
		local stageChanged = (App.QuestStageKey ~= nil) and (App.QuestStageKey ~= stageKey)
		local completedByCount = (totalCount > 0 and curCount >= totalCount)
		local finishedAfterProgress = (not hasGui) and (string.find(App.LastProgressText or "", "/", 1, true) ~= nil)

		if leveledUpSinceTake or stageChanged or completedByCount or finishedAfterProgress then
			App.QuestActive = false
			App.QuestStartLv = nil
			App.QuestStageKey = nil
			App.LastProgressText = "Hoàn tất NV"
		elseif hasGui then
			App.LastProgressText = progText
		end
	elseif hasGui then
		App.QuestActive = true
		App.QuestStartLv = App.QuestStartLv or lv
		App.QuestStageKey = stageKey
		App.LastProgressText = progText
	end

	local displayProg = hasGui and progText or (App.QuestActive and "Đang làm NV" or "Chưa nhận NV")
	if App.LvLbl then
		App.LvLbl.Text = "Lv: " .. lv .. "/" .. CFG.MaxLevelCap .. " • " .. App.LastLevelGainText
	end
	if App.TargetLbl then
		App.TargetLbl.Text = stage.mob .. " • " .. stage.island .. " (" .. displayProg .. ")"
	end

	if not CFG.AutoFarm then
		if App.StateLbl then App.StateLbl.Text = "Trạng thái: Đang chờ bật Auto Farm" end
		stopFlight()
		return
	end

	if not char or not hum or hum.Health <= 0 or not hrp or not hrp:IsDescendantOf(workspace) then
		stopFlight()
		return
	end

	if CFG.AutoMelee and (now - App.LastMelee >= 0.45) then
		App.LastMelee = now
		equipMelee(char, hum)
	end

	if CFG.AutoQuest and (not App.QuestActive) and (not hasGui) and (now - App.LastQuestCall >= CFG.QuestCooldown) then
		local npcFolder = workspace:FindFirstChild("NPCs")
		local npcModel = npcFolder and npcFolder:FindFirstChild(stage.npc)
		local npcPart = npcModel and (npcModel:FindFirstChild("HumanoidRootPart") or npcModel.PrimaryPart or npcModel:FindFirstChildWhichIsA("BasePart"))
		if npcPart and (npcPart.Position - hrp.Position).Magnitude > 14 then
			if App.StateLbl then App.StateLbl.Text = "Trạng thái: Bay tới NPC nhận NV 1 lần" end
			flyTo(char, hum, hrp, npcPart.Position + Vector3.new(0, 5, 0), dt)
		else
			App.LastQuestCall = now
			App.QuestActive = true
			App.QuestStartLv = lv
			App.QuestStageKey = stageKey
			App.LastProgressText = "NV: 0/?"
			takeQuestOnce(stage)
			if App.StateLbl then App.StateLbl.Text = "Trạng thái: Đã nhận NV " .. stage.mob .. " (Lv " .. lv .. ")" end
			notify("Đã nhận NV " .. stage.mob .. " • Theo dõi tiến độ")
		end
	end

	local mobPart = findNearestMob(hrp, stage.mob)
	if mobPart then
		if App.StateLbl then App.StateLbl.Text = "Trạng thái: Đang farm " .. stage.mob .. " (" .. displayProg .. ")" end
		flyTo(char, hum, hrp, mobPart.Position + Vector3.new(0, CFG.Height, 0), dt)
	else
		local islandGoal = stage.islandPos + Vector3.new(0, 24, 0)
		if (islandGoal - hrp.Position).Magnitude > 4 then
			if App.StateLbl then App.StateLbl.Text = "Trạng thái: Bay qua đảo " .. stage.island end
			flyTo(char, hum, hrp, islandGoal, dt)
		else
			if App.StateLbl then App.StateLbl.Text = "Trạng thái: Đợi quái spawn tại " .. stage.island end
		end
	end

	if now - App.LastAtk >= CFG.Delay then
		local tool = equipMelee(char, hum) or char:FindFirstChildOfClass("Tool")
		local folder = workspace:FindFirstChild("Enemies")
		if tool and folder then
			local hits = {}
			for _, m in ipairs(folder:GetChildren()) do
				local h = m:FindFirstChildOfClass("Humanoid")
				local p = m:FindFirstChild("Head") or m:FindFirstChild("HumanoidRootPart")
				if h and h.Health > 0 and p and (p.Position - hrp.Position).Magnitude <= CFG.Range then
					table.insert(hits, p)
				end
			end
			if #hits > 0 then
				App.LastAtk = now
				pcall(function() tool:Activate() end)
				if RE_Atk then pcall(function() RE_Atk:FireServer(0.5, 2) end) end
				if RE_Hit then
					for _, p in ipairs(hits) do
						pcall(function() RE_Hit:FireServer(p, {}, nil, CFG.Session) end)
					end
				end
			end
		end
	end
end)
