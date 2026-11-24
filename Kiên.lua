local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer

local CONFIG = {
	HubTitle = "Kiên 94",
	HubSub = "VIP PRO • √12kientomato",
	AttackRange = 60,
	MeleeDelay = 0.11,
	SwordDelay = 0.14,
	FlySpeed = 180,
	AboveHeadHeight = 8,
	BringMobEnabled = true,
	BringRadius = 60,
	BringPullSpeed = 50,
	QuestCooldown = 1.6,
	HitSessionId = "20404cc8",
	SendTelemetry = true,
	TriggerToolActivate = true,
	AutoQuest = true,
	AutoAttack = true,
	SoundEnabled = true,
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
	{ MinLevel = 150, MaxLevel = 9999, NpcName = "Bandit Quest Giver", QuestName = "BanditQuest1", QuestIndex = 1, EnemyName = "Bandit" },
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

local function playBeep(isPositive)
	if not CONFIG.SoundEnabled then
		return
	end
	pcall(function()
		local s = Instance.new("Sound")
		s.SoundId = isPositive and "rbxassetid://6026984224" or "rbxassetid://6026984115"
		s.Volume = 0.55
		s.Parent = SoundService
		s:Play()
		task.delay(1.5, function()
			if s then
				s:Destroy()
			end
		end)
	end)
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
		return p and p.Position or nil
	end
	if npcModel:IsA("BasePart") then
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
	if not char then
		return nil, nil, nil
	end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
	if not hum or hum.Health <= 0 or not hrp then
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

local function getEnemyRootAndHitPart(enemy)
	if not enemy or not enemy:IsA("Model") then
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
	if not hit then
		return nil, nil
	end
	return root or hit, hit
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
	if not hrp or not targetPos then
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

		if isEnemyMatch(enemy.Name, expectedName) and hum and hum.Health > 0 and root and root:IsA("BasePart") then
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
	if not tool then
		return nil, nil
	end
	local lowerName = string.lower(tool.Name)
	for _, blocked in ipairs(EXCLUDED_KEYWORDS) do
		if string.find(lowerName, blocked, 1, true) then
			return nil, nil
		end
	end

	local attr = tool:GetAttribute("WeaponType")
	if type(attr) == "string" then
		local t = string.lower(attr)
		if t == "melee" then
			return tool, CONFIG.MeleeDelay
		elseif t == "sword" then
			return tool, CONFIG.SwordDelay
		else
			return nil, nil
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
			pcall(function()
				RegisterHitRE:FireServer(t.Part, {}, [4] = CONFIG.HitSessionId)
			end)
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
	sg.Parent = playerGui

	local notifyBar = Instance.new("TextLabel")
	notifyBar.Name = "Kien94NotifyBar"
	notifyBar.Size = UDim2.new(0, 290, 0, 28)
	notifyBar.Position = UDim2.new(0.5, -145, 0.06, 0)
	notifyBar.BackgroundColor3 = Color3.fromRGB(12, 16, 28)
	notifyBar.BackgroundTransparency = 0.35
	notifyBar.Text = "🔔 Kiên 94 • √12kientomato đã sẵn sàng"
	notifyBar.Font = Enum.Font.GothamBold
	notifyBar.TextSize = 11
	notifyBar.TextColor3 = Color3.fromRGB(145, 245, 255)
	notifyBar.TextWrapped = true
	notifyBar.Parent = sg
	Instance.new("UICorner", notifyBar).CornerRadius = UDim.new(0, 10)
	local nStroke = Instance.new("UIStroke", notifyBar)
	nStroke.Thickness = 1.4
	nStroke.Color = Color3.fromRGB(0, 235, 255)
	KienState.NotifyLabel = notifyBar
	KienState.NotifyClearAt = os.clock() + 3.0

	local kBtn = Instance.new("TextButton")
	kBtn.Name = "KienFloatK"
	kBtn.Size = UDim2.new(0, 46, 0, 46)
	kBtn.Position = UDim2.new(0.87, 0, 0.2, 0)
	kBtn.Text = "K"
	kBtn.Font = Enum.Font.GothamBlack
	kBtn.TextSize = 20
	kBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	kBtn.BackgroundColor3 = Color3.fromRGB(14, 18, 32)
	kBtn.BackgroundTransparency = 0.35
	kBtn.BorderSizePixel = 0
	kBtn.Parent = sg
	Instance.new("UICorner", kBtn).CornerRadius = UDim.new(1, 0)
	local kStroke = Instance.new("UIStroke", kBtn)
	kStroke.Thickness = 2
	kStroke.Color = Color3.fromRGB(0, 240, 255)

	local panel = Instance.new("Frame")
	panel.Name = "Kien94GlassPanel"
	panel.Size = UDim2.new(0, 276, 0, 272)
	panel.Position = UDim2.new(0.5, -138, 0.18, 0)
	panel.BackgroundColor3 = Color3.fromRGB(10, 14, 26)
	panel.BackgroundTransparency = 0.54
	panel.BorderSizePixel = 0
	panel.Visible = KienState.MenuOpen
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
	title.Text = CONFIG.HubTitle .. " • VIP PRO"
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

	local autoFarmBtn = Instance.new("TextButton")
	autoFarmBtn.Size = UDim2.new(0.49, -2, 0, 30)
	autoFarmBtn.Position = UDim2.new(0, 0, 0, 38)
	autoFarmBtn.Text = "Auto Farm: ON"
	autoFarmBtn.Font = Enum.Font.GothamBold
	autoFarmBtn.TextSize = 11
	autoFarmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	autoFarmBtn.BackgroundTransparency = 0.25
	autoFarmBtn.BorderSizePixel = 0
	autoFarmBtn.Parent = farmPage
	Instance.new("UICorner", autoFarmBtn).CornerRadius = UDim.new(0, 8)

	local autoQuestBtn = Instance.new("TextButton")
	autoQuestBtn.Size = UDim2.new(0.49, -2, 0, 30)
	autoQuestBtn.Position = UDim2.new(0.51, 2, 0, 38)
	autoQuestBtn.Text = "Auto Quest: ON"
	autoQuestBtn.Font = Enum.Font.GothamBold
	autoQuestBtn.TextSize = 11
	autoQuestBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	autoQuestBtn.BackgroundTransparency = 0.25
	autoQuestBtn.BorderSizePixel = 0
	autoQuestBtn.Parent = farmPage
	Instance.new("UICorner", autoQuestBtn).CornerRadius = UDim.new(0, 8)

	local bringMobBtn = Instance.new("TextButton")
	bringMobBtn.Size = UDim2.new(1, 0, 0, 30)
	bringMobBtn.Position = UDim2.new(0, 0, 0, 74)
	bringMobBtn.Text = "Bring Mob: ON"
	bringMobBtn.Font = Enum.Font.GothamBold
	bringMobBtn.TextSize = 11
	bringMobBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	bringMobBtn.BackgroundTransparency = 0.25
	bringMobBtn.BorderSizePixel = 0
	bringMobBtn.Parent = farmPage
	Instance.new("UICorner", bringMobBtn).CornerRadius = UDim.new(0, 8)

	local heightLbl = Instance.new("TextLabel")
	heightLbl.Size = UDim2.new(1, 0, 0, 20)
	heightLbl.Position = UDim2.new(0, 0, 0, 110)
	heightLbl.BackgroundTransparency = 1
	heightLbl.Text = "Độ cao trên đầu quái: " .. CONFIG.AboveHeadHeight .. " studs"
	heightLbl.Font = Enum.Font.GothamMedium
	heightLbl.TextSize = 11
	heightLbl.TextXAlignment = Enum.TextXAlignment.Left
	heightLbl.TextColor3 = Color3.fromRGB(210, 235, 255)
	heightLbl.Parent = farmPage

	local hMinus = Instance.new("TextButton")
	hMinus.Size = UDim2.new(0.49, -2, 0, 28)
	hMinus.Position = UDim2.new(0, 0, 0, 134)
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
	hPlus.Size = UDim2.new(0.49, -2, 0, 28)
	hPlus.Position = UDim2.new(0.51, 2, 0, 134)
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
	mobInfoLbl.Position = UDim2.new(0, 0, 0, 166)
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
	infoBox.Text = "Hub: √12kientomato • Kiên 94\n• Tự nhận quest theo level\n• Bay cố định trên đầu quái & đổi quái khi lên level\n• Bring Mob mượt không mất máu\n• Auto Attack 60 studs khi cầm Võ/Kiếm"
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

	autoFarmBtn.MouseButton1Click:Connect(function()
		KienState.AutoFarm = not KienState.AutoFarm
		if not KienState.AutoFarm then
			stopHover()
			cleanupAllMobs()
			KienState.LockedEnemy = nil
			KienState.AnchorPos = nil
		end
		refreshAll()
		playBeep(KienState.AutoFarm)
		notify(KienState.AutoFarm and "Auto Farm: BẬT" or "Auto Farm: TẮT")
	end)

	autoQuestBtn.MouseButton1Click:Connect(function()
		CONFIG.AutoQuest = not CONFIG.AutoQuest
		refreshAll()
		playBeep(CONFIG.AutoQuest)
		notify(CONFIG.AutoQuest and "Auto Quest: BẬT" or "Auto Quest: TẮT")
	end)

	bringMobBtn.MouseButton1Click:Connect(function()
		CONFIG.BringMobEnabled = not CONFIG.BringMobEnabled
		if not CONFIG.BringMobEnabled then
			cleanupAllMobs()
		end
		refreshAll()
		playBeep(CONFIG.BringMobEnabled)
		notify(CONFIG.BringMobEnabled and "Bring Mob: BẬT" or "Bring Mob: TẮT")
	end)

	autoAtkBtn.MouseButton1Click:Connect(function()
		CONFIG.AutoAttack = not CONFIG.AutoAttack
		refreshAll()
		playBeep(CONFIG.AutoAttack)
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
	refreshAll()
end

createCleanUI()

RunService.Heartbeat:Connect(function(dt)
	local now = os.clock()

	if KienState.NotifyLabel and now > KienState.NotifyClearAt then
		KienState.NotifyLabel.Text = "🔔 " .. CONFIG.HubTitle .. " • Lv " .. tostring(getPlayerLevel())
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
