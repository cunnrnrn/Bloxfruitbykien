local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

local CFG = {
	Brand = "√12kientomato",
	Title = "KIÊN PRO MAX",
	Range = 60,
	Delay = 0.13,
	Speed = 150,
	Height = 8,
	SkyDodgeHeight = 48,
	SkyDodgeDuration = 0.9,
	AutoMelee = true,
	AutoFarmBoss = false,
	AutoFixLag = true,
	RespawnWindow = 25,
	Session = "20404cc8",
	DefaultIcon = "",
}

local MELEE_NAMES = {
	"combat", "dark step", "electric", "water kung fu", "dragon breath",
	"superhuman", "death step", "sharkman karate", "electric claw",
	"dragon talon", "godhuman", "sanguine art",
}

-- Tự nhận diện Sea hiện tại dựa theo PlaceId để chỉ hiển thị Boss đúng Server/Sea đó
local function detectCurrentSea()
	local pid = game.PlaceId
	if pid == 2753915549 then
		return 1, "Sea 1"
	elseif pid == 4442272183 then
		return 2, "Sea 2"
	elseif pid == 7449423635 then
		return 3, "Sea 3"
	end
	-- Fallback theo vị trí nếu PlaceId lạ
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if hrp then
		if hrp.Position.Z < -7000 or hrp.Position.X < -7000 then
			return 3, "Sea 3"
		elseif hrp.Position.X > 2000 and hrp.Position.Y < 500 then
			return 2, "Sea 2"
		end
	end
	return 1, "Sea 1"
end

-- Danh sách Boss đầy đủ theo từng Sea: {Sea, Name, Island, Pos, Image}
local ALL_BOSSES = {
	-- SEA 1
	{Sea = 1, Name = "The Gorilla King", Island = "Jungle", Pos = Vector3.new(-1142, 40, -515), Image = ""},
	{Sea = 1, Name = "Bobby", Island = "Pirate Village", Pos = Vector3.new(-1147, 15, 3835), Image = ""},
	{Sea = 1, Name = "Ancient Monk", Island = "Sky Area 1", Pos = Vector3.new(-4840, 718, -2620), Image = ""},
	{Sea = 1, Name = "Warden", Island = "Prison", Pos = Vector3.new(4875, 6, 736), Image = ""},
	{Sea = 1, Name = "Chief Warden", Island = "Prison", Pos = Vector3.new(5310, 2, 474), Image = ""},
	{Sea = 1, Name = "Swan", Island = "Prison", Pos = Vector3.new(5230, 6, 740), Image = ""},
	{Sea = 1, Name = "Magma Admiral", Island = "Magma Village", Pos = Vector3.new(-5690, 78, 8680), Image = ""},
	{Sea = 1, Name = "Fishman Lord", Island = "Underwater City", Pos = Vector3.new(61120, 18, 1569), Image = ""},
	{Sea = 1, Name = "Wysper", Island = "Upper Sky", Pos = Vector3.new(-7900, 5545, -380), Image = ""},
	{Sea = 1, Name = "Thunder God", Island = "Upper Sky", Pos = Vector3.new(-7775, 5605, -2500), Image = ""},
	{Sea = 1, Name = "Cyborg", Island = "Fountain City", Pos = Vector3.new(5660, 48, 4900), Image = ""},

	-- SEA 2
	{Sea = 2, Name = "Diamond", Island = "Colosseum", Pos = Vector3.new(-1575, 12, -2990), Image = ""},
	{Sea = 2, Name = "Jeremy", Island = "Area 1", Pos = Vector3.new(2175, 448, 750), Image = ""},
	{Sea = 2, Name = "Fajita", Island = "Green Zone", Pos = Vector3.new(-2145, 73, 120), Image = ""},
	{Sea = 2, Name = "Smoke Admiral", Island = "Marine Base G1", Pos = Vector3.new(-2440, 73, -3215), Image = ""},
	{Sea = 2, Name = "Don Swan", Island = "Mansion", Pos = Vector3.new(2285, 15, 905), Image = ""},
	{Sea = 2, Name = "Cursed Captain", Island = "Cursed Ship", Pos = Vector3.new(915, 141, 33410), Image = ""},
	{Sea = 2, Name = "Darkbeard", Island = "Dark Arena", Pos = Vector3.new(3780, 15, -3490), Image = ""},

	-- SEA 3
	{Sea = 3, Name = "Stone", Island = "Port Town", Pos = Vector3.new(-1080, 40, 6780), Image = ""},
	{Sea = 3, Name = "Island Empress", Island = "Hydra Island", Pos = Vector3.new(5715, 602, 200), Image = ""},
	{Sea = 3, Name = "Kilo Admiral", Island = "Hydra Island", Pos = Vector3.new(6670, 370, 320), Image = ""},
	{Sea = 3, Name = "Captain Elephant", Island = "Floating Turtle", Pos = Vector3.new(-13375, 318, -8420), Image = ""},
	{Sea = 3, Name = "Beautiful Pirate", Island = "Floating Turtle", Pos = Vector3.new(5310, 22, 145), Image = ""},
	{Sea = 3, Name = "Cake Queen", Island = "Cake Land", Pos = Vector3.new(-705, 381, -11150), Image = ""},
	{Sea = 3, Name = "Dough King", Island = "Cake Land", Pos = Vector3.new(-2020, 38, -12025), Image = ""},
	{Sea = 3, Name = "Rip_indra True Form", Island = "Castle on the Sea", Pos = Vector3.new(-5345, 424, -2730), Image = ""},
	{Sea = 3, Name = "Tiki Boss", Island = "Tiki Outpost", Pos = Vector3.new(-16550, 55, 1050), Image = ""},
}

local function getServerBosses()
	local seaId = detectCurrentSea()
	local list = {}
	for _, b in ipairs(ALL_BOSSES) do
		if b.Sea == seaId then
			table.insert(list, b)
		end
	end
	return #list > 0 and list or ALL_BOSSES, seaId
end

local ServerBosses, CurrentSeaId = getServerBosses()

local App = {
	SeaId = CurrentSeaId,
	Bosses = ServerBosses,
	SelectedBoss = ServerBosses[1],
	MenuOpen = true,
	LastAtk = 0,
	LastMelee = 0,
	LastSeenAlive = {},
	LastDiedAt = {},
	SkyDodgeUntil = 0,
	LastHumHealth = nil,
	BV = nil,
	BG = nil,
	NotifyLbl = nil,
	BossStatusLbl = nil,
	SelectedLbl = nil,
	ToggleFarmBtn = nil,
	ToggleMeleeBtn = nil,
}

local function notify(text)
	if App.NotifyLbl then
		App.NotifyLbl.Text = "🔔 " .. tostring(text)
	end
end

local function applyFixLag()
	if not CFG.AutoFixLag then return end
	pcall(function()
		Lighting.GlobalShadows = false
		Lighting.FogEnd = 1e6
		for _, eff in ipairs(Lighting:GetChildren()) do
			if eff:IsA("BlurEffect") or eff:IsA("SunRaysEffect") or eff:IsA("BloomEffect") or eff:IsA("DepthOfFieldEffect") then
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

local function flyTo(char, hum, hrp, targetPos, dt)
	if not char or not hum or not hrp or not targetPos then return end
	setNoClip(char, true)
	pcall(function() hum:ChangeState(Enum.HumanoidStateType.Physics) end)

	if not App.BV or App.BV.Parent ~= hrp then
		if App.BV then pcall(function() App.BV:Destroy() end) end
		local vel = Instance.new("BodyVelocity")
		vel.Name = "KienProVel"
		vel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		vel.Velocity = Vector3.zero
		vel.Parent = hrp
		App.BV = vel
	end

	if not App.BG or App.BG.Parent ~= hrp then
		if App.BG then pcall(function() App.BG:Destroy() end) end
		local gyro = Instance.new("BodyGyro")
		gyro.Name = "KienProGyro"
		gyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
		gyro.P = 12000
		gyro.D = 450
		gyro.CFrame = hrp.CFrame
		gyro.Parent = hrp
		App.BG = gyro
	end

	local diff = targetPos - hrp.Position
	local dist = diff.Magnitude
	local stepDt = math.clamp(dt or 0.016, 0.008, 0.04)

	if dist > 2.5 then
		local dir = diff.Unit
		local spd = math.min(CFG.Speed, math.max(45, dist * 6))
		App.BV.Velocity = dir * spd
		hrp.CFrame = CFrame.new(hrp.Position + dir * math.min(dist, spd * stepDt))
	else
		App.BV.Velocity = Vector3.zero
		hrp.CFrame = CFrame.new(targetPos)
	end

	local lookPos = Vector3.new(targetPos.X, hrp.Position.Y - CFG.Height, targetPos.Z)
	if (lookPos - hrp.Position).Magnitude > 0.1 then
		App.BG.CFrame = CFrame.lookAt(hrp.Position, lookPos)
	end
end

local function checkBossState(bossData, hrp, now)
	if not bossData then return nil, nil, "CHƯA CHỌN", false end
	local low = string.lower(bossData.Name)
	local folder = workspace:FindFirstChild("Enemies")

	if folder then
		for _, m in ipairs(folder:GetChildren()) do
			if m:IsA("Model") and string.find(string.lower(m.Name), low, 1, true) then
				local bHum = m:FindFirstChildOfClass("Humanoid")
				local bPart = m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("Head")
				if bHum and bHum.Health > 0 and bPart and bPart:IsDescendantOf(workspace) then
					App.LastSeenAlive[bossData.Name] = now
					return bPart, m, "ĐÃ SPAWN (CÒN SỐNG)", true
				elseif bHum and bHum.Health <= 0 then
					App.LastDiedAt[bossData.Name] = now
				end
			end
		end
	end

	for _, obj in ipairs(workspace:GetChildren()) do
		if obj:IsA("Model") and string.find(string.lower(obj.Name), low, 1, true) then
			local p = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
			if p then
				return p, obj, "ĐÃ SPAWN (TỪ XA)", true
			end
		end
	end

	local diedAt = App.LastDiedAt[bossData.Name]
	if diedAt and (now - diedAt) < CFG.RespawnWindow then
		local rem = math.ceil(CFG.RespawnWindow - (now - diedAt))
		return nil, nil, "ĐÃ CHẾT (HỒI ~" .. rem .. "s)", false
	end

	local distToIsland = hrp and (bossData.Pos - hrp.Position).Magnitude or 9999
	if distToIsland > 450 then
		return nil, nil, "CHƯA LOAD (XA ĐẢO)", false
	end
	return nil, nil, "CHƯA SPAWN", false
end

local function bossPreparingSkill(bossModel, bossPart, hum, hrp, now)
	if not bossModel or not bossPart or not hrp then return false end
	if hum and App.LastHumHealth and hum.Health < App.LastHumHealth then
		App.LastHumHealth = hum.Health
		return true
	end
	if hum then App.LastHumHealth = hum.Health end

	local bHum = bossModel:FindFirstChildOfClass("Humanoid")
	if bHum then
		local st = bHum:GetState()
		if st == Enum.HumanoidStateType.Jumping or st == Enum.HumanoidStateType.Attacking then
			return true
		end
		local animator = bHum:FindFirstChildOfClass("Animator")
		if animator then
			for _, tr in ipairs(animator:GetPlayingAnimationTracks()) do
				if tr.Speed > 0.2 and tr.TimePosition > 0.05 then
					return true
				end
			end
		end
	end

	if bossModel:FindFirstChildOfClass("Tool") and (bossPart.Position - hrp.Position).Magnitude < 45 then
		return true
	end
	return false
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

local function refreshButtons()
	if App.ToggleFarmBtn then
		App.ToggleFarmBtn.Text = CFG.AutoFarmBoss and "Auto Farm Boss: ON" or "Auto Farm Boss: OFF"
		App.ToggleFarmBtn.BackgroundColor3 = CFG.AutoFarmBoss and Color3.fromRGB(16, 185, 129) or Color3.fromRGB(220, 60, 80)
	end
	if App.ToggleMeleeBtn then
		App.ToggleMeleeBtn.Text = CFG.AutoMelee and "Tự Cầm Melee: ON" or "Tự Cầm Melee: OFF"
		App.ToggleMeleeBtn.BackgroundColor3 = CFG.AutoMelee and Color3.fromRGB(124, 92, 255) or Color3.fromRGB(78, 84, 108)
	end
end

local function selectBoss(bossData)
	App.SelectedBoss = bossData
	if App.SelectedLbl then
		App.SelectedLbl.Text = "Sea " .. bossData.Sea .. " • " .. bossData.Name .. " (" .. bossData.Island .. ")"
	end
	notify("Đã chọn: " .. bossData.Name)
end

local function buildKienProMaxUI()
	local parent = getUiContainer()
	if not parent then return end

	local old = parent:FindFirstChild("KienProMaxUI")
	if old then pcall(function() old:Destroy() end) end

	local sg = Instance.new("ScreenGui")
	sg.Name = "KienProMaxUI"
	sg.ResetOnSpawn = false
	sg.DisplayOrder = 10000
	pcall(function() sg.Parent = parent end)
	if not sg.Parent then sg.Parent = LocalPlayer:WaitForChild("PlayerGui", 5) end

	-- Thanh thông báo trên cùng
	App.NotifyLbl = Instance.new("TextLabel")
	App.NotifyLbl.Size = UDim2.new(0, 310, 0, 28)
	App.NotifyLbl.Position = UDim2.new(0.5, -155, 0.032, 0)
	App.NotifyLbl.BackgroundColor3 = Color3.fromRGB(12, 16, 28)
	App.NotifyLbl.BackgroundTransparency = 0.22
	App.NotifyLbl.TextColor3 = Color3.fromRGB(92, 245, 255)
	App.NotifyLbl.Font = Enum.Font.GothamBold
	App.NotifyLbl.TextSize = 11
	App.NotifyLbl.Text = "🔔 " .. CFG.Title .. " • Sea " .. App.SeaId .. " | Fix Lag + Né Skill"
	App.NotifyLbl.Parent = sg
	Instance.new("UICorner", App.NotifyLbl).CornerRadius = UDim.new(0, 10)
	local nStroke = Instance.new("UIStroke", App.NotifyLbl)
	nStroke.Color = Color3.fromRGB(92, 245, 255)
	nStroke.Transparency = 0.45

	-- Nút nổi chữ K kéo thả
	local kFloat = Instance.new("TextButton")
	kFloat.Size = UDim2.new(0, 44, 0, 44)
	kFloat.Position = UDim2.new(0.87, 0, 0.16, 0)
	kFloat.Text = "K"
	kFloat.Font = Enum.Font.GothamBlack
	kFloat.TextSize = 20
	kFloat.TextColor3 = Color3.fromRGB(255, 255, 255)
	kFloat.BackgroundColor3 = Color3.fromRGB(18, 24, 42)
	kFloat.BackgroundTransparency = 0.15
	kFloat.Parent = sg
	Instance.new("UICorner", kFloat).CornerRadius = UDim.new(1, 0)
	local kStroke = Instance.new("UIStroke", kFloat)
	kStroke.Color = Color3.fromRGB(168, 85, 247)
	kStroke.Thickness = 1.8

	-- Khung chính Kiên Pro Max (có viền gradient chuyển màu mượt)
	local mainFrame = Instance.new("Frame")
	mainFrame.Size = UDim2.new(0, 0, 0, 0)
	mainFrame.Position = UDim2.new(0.5, 0, 0.52, 0)
	mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	mainFrame.BackgroundColor3 = Color3.fromRGB(12, 16, 28)
	mainFrame.BackgroundTransparency = 0.22
	mainFrame.ClipsDescendants = true
	mainFrame.Visible = false
	mainFrame.Parent = sg
	Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 16)

	local mStroke = Instance.new("UIStroke", mainFrame)
	mStroke.Thickness = 1.8
	mStroke.Transparency = 0.15
	local grad = Instance.new("UIGradient", mStroke)
	grad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(56, 248, 255)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(168, 85, 247)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 185, 129)),
	})

	-- Lớp chuyển cảnh mở đầu mượt (hiệu ứng quét & mở rộng)
	local introOverlay = Instance.new("Frame")
	introOverlay.Size = UDim2.new(1, 0, 1, 0)
	introOverlay.BackgroundColor3 = Color3.fromRGB(8, 11, 20)
	introOverlay.BackgroundTransparency = 0.05
	introOverlay.ZIndex = 20
	introOverlay.Parent = mainFrame
	Instance.new("UICorner", introOverlay).CornerRadius = UDim.new(0, 16)

	local introBadge = Instance.new("TextLabel")
	introBadge.Size = UDim2.new(0, 74, 0, 44)
	introBadge.Position = UDim2.new(0.5, -37, 0.28, 0)
	introBadge.BackgroundColor3 = Color3.fromRGB(24, 32, 56)
	introBadge.BackgroundTransparency = 0.2
	introBadge.Text = "⚡ K"
	introBadge.TextColor3 = Color3.fromRGB(92, 245, 255)
	introBadge.Font = Enum.Font.GothamBlack
	introBadge.TextSize = 20
	introBadge.ZIndex = 21
	introBadge.Parent = introOverlay
	Instance.new("UICorner", introBadge).CornerRadius = UDim.new(0, 12)

	local introLabel = Instance.new("TextLabel")
	introLabel.Size = UDim2.new(1, -24, 0, 28)
	introLabel.Position = UDim2.new(0, 12, 0.56, 0)
	introLabel.BackgroundTransparency = 1
	introLabel.Text = CFG.Title .. " • Đang tải Boss Sea " .. App.SeaId .. "..."
	introLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	introLabel.Font = Enum.Font.GothamBold
	introLabel.TextSize = 12
	introLabel.ZIndex = 21
	introLabel.Parent = introOverlay

	local header = Instance.new("TextLabel")
	header.Size = UDim2.new(1, -20, 0, 24)
	header.Position = UDim2.new(0, 10, 0, 8)
	header.BackgroundTransparency = 1
	header.Text = "⚡ " .. CFG.Title .. " • Sea " .. App.SeaId .. " | " .. CFG.Brand
	header.TextColor3 = Color3.fromRGB(92, 245, 255)
	header.Font = Enum.Font.GothamBlack
	header.TextSize = 12
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.Parent = mainFrame

	App.SelectedLbl = Instance.new("TextLabel")
	App.SelectedLbl.Size = UDim2.new(1, -20, 0, 18)
	App.SelectedLbl.Position = UDim2.new(0, 10, 0, 32)
	App.SelectedLbl.BackgroundTransparency = 1
	App.SelectedLbl.Text = "Sea " .. App.SelectedBoss.Sea .. " • " .. App.SelectedBoss.Name .. " (" .. App.SelectedBoss.Island .. ")"
	App.SelectedLbl.TextColor3 = Color3.fromRGB(240, 248, 255)
	App.SelectedLbl.Font = Enum.Font.GothamBold
	App.SelectedLbl.TextSize = 11
	App.SelectedLbl.TextXAlignment = Enum.TextXAlignment.Left
	App.SelectedLbl.Parent = mainFrame

	App.BossStatusLbl = Instance.new("TextLabel")
	App.BossStatusLbl.Size = UDim2.new(1, -20, 0, 18)
	App.BossStatusLbl.Position = UDim2.new(0, 10, 0, 50)
	App.BossStatusLbl.BackgroundTransparency = 1
	App.BossStatusLbl.Text = "Trạng thái: Đang kiểm tra..."
	App.BossStatusLbl.TextColor3 = Color3.fromRGB(255, 218, 115)
	App.BossStatusLbl.Font = Enum.Font.GothamMedium
	App.BossStatusLbl.TextSize = 10
	App.BossStatusLbl.TextXAlignment = Enum.TextXAlignment.Left
	App.BossStatusLbl.Parent = mainFrame

	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -16, 0, 134)
	scroll.Position = UDim2.new(0, 8, 0, 72)
	scroll.BackgroundColor3 = Color3.fromRGB(18, 24, 40)
	scroll.BackgroundTransparency = 0.35
	scroll.ScrollBarThickness = 4
	scroll.CanvasSize = UDim2.new(0, 0, 0, #App.Bosses * 46 + 8)
	scroll.Parent = mainFrame
	Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 10)

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 4)
	listLayout.Parent = scroll

	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 4)
	pad.PaddingLeft = UDim.new(0, 4)
	pad.PaddingRight = UDim.new(0, 4)
	pad.Parent = scroll

	for _, bData in ipairs(App.Bosses) do
		local rowBtn = Instance.new("TextButton")
		rowBtn.Size = UDim2.new(1, 0, 0, 42)
		rowBtn.BackgroundColor3 = Color3.fromRGB(25, 34, 56)
		rowBtn.BackgroundTransparency = 0.22
		rowBtn.Text = ""
		rowBtn.Parent = scroll
		Instance.new("UICorner", rowBtn).CornerRadius = UDim.new(0, 8)

		local thumb = Instance.new("ImageLabel")
		thumb.Size = UDim2.new(0, 34, 0, 34)
		thumb.Position = UDim2.new(0, 4, 0, 4)
		thumb.BackgroundColor3 = Color3.fromRGB(36, 48, 76)
		thumb.Image = (bData.Image ~= "" and bData.Image) or CFG.DefaultIcon
		thumb.ScaleType = Enum.ScaleType.Crop
		thumb.Parent = rowBtn
		Instance.new("UICorner", thumb).CornerRadius = UDim.new(0, 6)

		local badge = Instance.new("TextLabel")
		badge.Size = UDim2.new(1, 0, 1, 0)
		badge.BackgroundTransparency = 1
		badge.Text = (thumb.Image == "") and "👑" or ""
		badge.TextSize = 15
		badge.Parent = thumb

		local nameTxt = Instance.new("TextLabel")
		nameTxt.Size = UDim2.new(1, -46, 0, 18)
		nameTxt.Position = UDim2.new(0, 43, 0, 4)
		nameTxt.BackgroundTransparency = 1
		nameTxt.Text = bData.Name
		nameTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameTxt.Font = Enum.Font.GothamBold
		nameTxt.TextSize = 11
		nameTxt.TextXAlignment = Enum.TextXAlignment.Left
		nameTxt.Parent = rowBtn

		local subTxt = Instance.new("TextLabel")
		subTxt.Size = UDim2.new(1, -46, 0, 16)
		subTxt.Position = UDim2.new(0, 43, 0, 21)
		subTxt.BackgroundTransparency = 1
		subTxt.Text = "Đảo: " .. bData.Island .. " • Sea " .. bData.Sea
		subTxt.TextColor3 = Color3.fromRGB(150, 220, 255)
		subTxt.Font = Enum.Font.Gotham
		subTxt.TextSize = 10
		subTxt.TextXAlignment = Enum.TextXAlignment.Left
		subTxt.Parent = rowBtn

		rowBtn.MouseButton1Click:Connect(function()
			selectBoss(bData)
		end)
	end

	App.ToggleFarmBtn = Instance.new("TextButton")
	App.ToggleFarmBtn.Size = UDim2.new(0.5, -12, 0, 32)
	App.ToggleFarmBtn.Position = UDim2.new(0, 8, 1, -42)
	App.ToggleFarmBtn.Font = Enum.Font.GothamBold
	App.ToggleFarmBtn.TextSize = 11
	App.ToggleFarmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	App.ToggleFarmBtn.Parent = mainFrame
	Instance.new("UICorner", App.ToggleFarmBtn).CornerRadius = UDim.new(0, 9)

	App.ToggleMeleeBtn = Instance.new("TextButton")
	App.ToggleMeleeBtn.Size = UDim2.new(0.5, -12, 0, 32)
	App.ToggleMeleeBtn.Position = UDim2.new(0.5, 4, 1, -42)
	App.ToggleMeleeBtn.Font = Enum.Font.GothamBold
	App.ToggleMeleeBtn.TextSize = 11
	App.ToggleMeleeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	App.ToggleMeleeBtn.Parent = mainFrame
	Instance.new("UICorner", App.ToggleMeleeBtn).CornerRadius = UDim.new(0, 9)

	App.ToggleFarmBtn.MouseButton1Click:Connect(function()
		CFG.AutoFarmBoss = not CFG.AutoFarmBoss
		if not CFG.AutoFarmBoss then stopFlight() end
		refreshButtons()
		notify(CFG.AutoFarmBoss and "Bật Farm Boss (150)" or "Tắt Farm Boss")
	end)

	App.ToggleMeleeBtn.MouseButton1Click:Connect(function()
		CFG.AutoMelee = not CFG.AutoMelee
		refreshButtons()
		notify(CFG.AutoMelee and "Bật Tự Cầm Melee" or "Tắt Tự Cầm Melee")
	end)

	kFloat.MouseButton1Click:Connect(function()
		App.MenuOpen = not App.MenuOpen
		mainFrame.Visible = App.MenuOpen
		if App.MenuOpen then
			mainFrame.Size = UDim2.new(0, 280, 0, 258)
		end
	end)

	local dragging, dragInput, startInput, startPos = false
	mainFrame.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging, startInput, startPos = true, inp.Position, mainFrame.Position
			inp.Changed:Connect(function()
				if inp.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	mainFrame.InputChanged:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = inp
		end
	end)
	UserInputService.InputChanged:Connect(function(inp)
		if inp == dragInput and dragging then
			local d = inp.Position - startInput
			mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)

	refreshButtons()

	-- Xoay viền gradient nhẹ nhàng liên tục
	task.spawn(function()
		while mainFrame.Parent do
			grad.Rotation = (grad.Rotation + 2) % 360
			task.wait(0.03)
		end
	end)

	-- Hiệu ứng mở dần từ từ
	mainFrame.Visible = true
	TweenService:Create(
		mainFrame,
		TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		{Size = UDim2.new(0, 280, 0, 258)}
	):Play()

	task.spawn(function()
		task.wait(0.4)
		introBadge.Text = "👁️"
		introLabel.Text = "Sẵn sàng • Lọc Boss Sea " .. App.SeaId
		task.wait(0.4)
		local t1 = TweenService:Create(introOverlay, TweenInfo.new(0.32), {BackgroundTransparency = 1})
		local t2 = TweenService:Create(introBadge, TweenInfo.new(0.32), {TextTransparency = 1, BackgroundTransparency = 1})
		local t3 = TweenService:Create(introLabel, TweenInfo.new(0.32), {TextTransparency = 1})
		t1:Play() t2:Play() t3:Play()
		t1.Completed:Wait()
		introOverlay.Visible = false
	end)
end

pcall(buildKienProMaxUI)
task.spawn(applyFixLag)

RunService.Heartbeat:Connect(function(dt)
	local now = os.clock()
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local hrp = char and char:FindFirstChild("HumanoidRootPart")

	local bossPart, bossModel, statusText, isSpawned = checkBossState(App.SelectedBoss, hrp, now)
	if App.BossStatusLbl then
		App.BossStatusLbl.Text = statusText .. " | Bay 150 | Tầm 60"
	end

	if not CFG.AutoFarmBoss or not App.SelectedBoss then
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

	if bossPart and bossModel then
		if bossPreparingSkill(bossModel, bossPart, hum, hrp, now) then
			App.SkyDodgeUntil = now + CFG.SkyDodgeDuration
		end

		local targetPos = bossPart.Position + Vector3.new(0, CFG.Height, 0)
		if now < App.SkyDodgeUntil then
			targetPos = bossPart.Position + Vector3.new(0, CFG.SkyDodgeHeight, 0)
			notify("Né skill Boss -> Bay lên cao!")
		end
		flyTo(char, hum, hrp, targetPos, dt)
	elseif isSpawned then
		local islandPos = App.SelectedBoss.Pos + Vector3.new(0, 24, 0)
		if (islandPos - hrp.Position).Magnitude > 4 then
			flyTo(char, hum, hrp, islandPos, dt)
			notify("Bay tới " .. App.SelectedBoss.Island .. " (150)")
		end
	else
		stopFlight()
	end

	if now - App.LastAtk >= CFG.Delay then
		local tool = equipMelee(char, hum) or char:FindFirstChildOfClass("Tool")
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
				App.LastAtk = now
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
end)
