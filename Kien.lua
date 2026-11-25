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
	Session = "20404cc8",
}

local MELEE_NAMES = {
	"combat", "dark step", "electric", "water kung fu", "dragon breath",
	"superhuman", "death step", "sharkman karate", "electric claw",
	"dragon talon", "godhuman", "sanguine art",
}

local BOSS_DB = {
	{Sea = 1, Name = "The Gorilla King", Island = "Jungle", Pos = Vector3.new(-1142, 40, -515), Color = Color3.fromRGB(115, 75, 45)},
	{Sea = 1, Name = "Bobby", Island = "Pirate Village", Pos = Vector3.new(-1147, 15, 3835), Color = Color3.fromRGB(220, 55, 65)},
	{Sea = 1, Name = "Ancient Monk", Island = "Sky Area 1", Pos = Vector3.new(-4840, 718, -2620), Color = Color3.fromRGB(190, 165, 95)},
	{Sea = 1, Name = "Warden", Island = "Prison", Pos = Vector3.new(4875, 6, 736), Color = Color3.fromRGB(235, 175, 45)},
	{Sea = 1, Name = "Chief Warden", Island = "Prison", Pos = Vector3.new(5310, 2, 474), Color = Color3.fromRGB(165, 55, 195)},
	{Sea = 1, Name = "Swan", Island = "Prison", Pos = Vector3.new(5230, 6, 740), Color = Color3.fromRGB(245, 120, 185)},
	{Sea = 1, Name = "Magma Admiral", Island = "Magma Village", Pos = Vector3.new(-5690, 78, 8680), Color = Color3.fromRGB(235, 85, 35)},
	{Sea = 1, Name = "Fishman Lord", Island = "Underwater City", Pos = Vector3.new(61120, 18, 1569), Color = Color3.fromRGB(45, 155, 225)},
	{Sea = 1, Name = "Wysper", Island = "Upper Sky", Pos = Vector3.new(-7900, 5545, -380), Color = Color3.fromRGB(240, 210, 90)},
	{Sea = 1, Name = "Thunder God", Island = "Upper Sky", Pos = Vector3.new(-7775, 5605, -2500), Color = Color3.fromRGB(95, 215, 255)},
	{Sea = 1, Name = "Cyborg", Island = "Fountain City", Pos = Vector3.new(5660, 48, 4900), Color = Color3.fromRGB(120, 145, 185)},

	{Sea = 2, Name = "Diamond", Island = "Colosseum", Pos = Vector3.new(-1575, 12, -2990), Color = Color3.fromRGB(90, 225, 255)},
	{Sea = 2, Name = "Jeremy", Island = "Area 1", Pos = Vector3.new(2175, 448, 750), Color = Color3.fromRGB(130, 215, 85)},
	{Sea = 2, Name = "Fajita", Island = "Green Zone", Pos = Vector3.new(-2145, 73, 120), Color = Color3.fromRGB(155, 95, 235)},
	{Sea = 2, Name = "Smoke Admiral", Island = "Marine Base G1", Pos = Vector3.new(-2440, 73, -3215), Color = Color3.fromRGB(185, 195, 210)},
	{Sea = 2, Name = "Don Swan", Island = "Mansion", Pos = Vector3.new(2285, 15, 905), Color = Color3.fromRGB(255, 115, 180)},
	{Sea = 2, Name = "Cursed Captain", Island = "Cursed Ship", Pos = Vector3.new(915, 141, 33410), Color = Color3.fromRGB(75, 235, 165)},
	{Sea = 2, Name = "Darkbeard", Island = "Dark Arena", Pos = Vector3.new(3780, 15, -3490), Color = Color3.fromRGB(65, 70, 95)},

	{Sea = 3, Name = "Stone", Island = "Port Town", Pos = Vector3.new(-1080, 40, 6780), Color = Color3.fromRGB(145, 130, 115)},
	{Sea = 3, Name = "Island Empress", Island = "Hydra Island", Pos = Vector3.new(5715, 602, 200), Color = Color3.fromRGB(225, 65, 125)},
	{Sea = 3, Name = "Kilo Admiral", Island = "Hydra Island", Pos = Vector3.new(6670, 370, 320), Color = Color3.fromRGB(245, 165, 55)},
	{Sea = 3, Name = "Captain Elephant", Island = "Floating Turtle", Pos = Vector3.new(-13375, 318, -8420), Color = Color3.fromRGB(115, 135, 175)},
	{Sea = 3, Name = "Beautiful Pirate", Island = "Floating Turtle", Pos = Vector3.new(5310, 22, 145), Color = Color3.fromRGB(240, 140, 205)},
	{Sea = 3, Name = "Cake Queen", Island = "Cake Land", Pos = Vector3.new(-705, 381, -11150), Color = Color3.fromRGB(255, 150, 185)},
	{Sea = 3, Name = "Dough King", Island = "Cake Land", Pos = Vector3.new(-2020, 38, -12025), Color = Color3.fromRGB(255, 195, 115)},
	{Sea = 3, Name = "Rip_indra True Form", Island = "Castle on the Sea", Pos = Vector3.new(-5345, 424, -2730), Color = Color3.fromRGB(235, 55, 95)},
	{Sea = 3, Name = "Tiki Boss", Island = "Tiki Outpost", Pos = Vector3.new(-16550, 55, 1050), Color = Color3.fromRGB(65, 225, 195)},
}

local function detectSea()
	local pid = game.PlaceId
	if pid == 2753915549 then return 1 end
	if pid == 4442272183 then return 2 end
	if pid == 7449423635 then return 3 end
	local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if hrp then
		if hrp.Position.Z < -7000 or hrp.Position.X < -7000 then return 3 end
		if hrp.Position.X > 2000 and hrp.Position.Y < 500 then return 2 end
	end
	return 1
end

local function getCurrentServerBosses()
	local sea = detectSea()
	local out = {}
	for _, item in ipairs(BOSS_DB) do
		if item.Sea == sea then
			table.insert(out, item)
		end
	end
	return (#out > 0 and out or BOSS_DB), sea
end

local InitialBosses, InitialSea = getCurrentServerBosses()

local App = {
	Sea = InitialSea,
	Bosses = InitialBosses,
	Selected = InitialBosses[1],
	Open = true,
	LastAtk = 0,
	LastMelee = 0,
	SeenAlive = {},
	DiedFlag = {},
	SkyDodgeUntil = 0,
	PrevHealth = nil,
	BV = nil,
	BG = nil,
	NotifyLbl = nil,
	StatusLbl = nil,
	SelectedLbl = nil,
	FarmBtn = nil,
	MeleeBtn = nil,
	PreviewRefresh = nil,
}

local function notify(txt)
	if App.NotifyLbl then
		App.NotifyLbl.Text = "🔔 " .. tostring(txt)
	end
end

local function applyFixLag()
	if not CFG.AutoFixLag then return end
	pcall(function()
		Lighting.GlobalShadows = false
		Lighting.FogEnd = 1e6
		for _, v in ipairs(Lighting:GetChildren()) do
			if v:IsA("PostEffect") then
				v.Enabled = false
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

local function isMelee(tool)
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
	if cur and isMelee(cur) then return cur end
	local pack = LocalPlayer:FindFirstChild("Backpack")
	if pack then
		for _, item in ipairs(pack:GetChildren()) do
			if isMelee(item) then
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

local function stopMove()
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
		vel.Name = "KienMaxVel"
		vel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		vel.Velocity = Vector3.zero
		vel.Parent = hrp
		App.BV = vel
	end

	if not App.BG or App.BG.Parent ~= hrp then
		if App.BG then pcall(function() App.BG:Destroy() end) end
		local gyro = Instance.new("BodyGyro")
		gyro.Name = "KienMaxGyro"
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
		local spd = math.min(CFG.Speed, math.max(50, dist * 7))
		App.BV.Velocity = dir * spd
		hrp.CFrame = CFrame.new(hrp.Position + dir * math.min(dist, spd * stepDt))
	else
		App.BV.Velocity = Vector3.zero
		hrp.CFrame = CFrame.new(targetPos)
	end

	local lookAt = Vector3.new(targetPos.X, hrp.Position.Y - CFG.Height, targetPos.Z)
	if (lookAt - hrp.Position).Magnitude > 0.1 then
		App.BG.CFrame = CFrame.lookAt(hrp.Position, lookAt)
	end
end

-- Quét Boss trong server để trả về: (part, model, statusText, color, isAlive)
local function scanBoss(bossInfo, hrp)
	if not bossInfo then return nil, nil, "CHƯA CHỌN", Color3.fromRGB(200, 200, 210), false end
	local low = string.lower(bossInfo.Name)
	local folder = workspace:FindFirstChild("Enemies")

	if folder then
		for _, m in ipairs(folder:GetChildren()) do
			if m:IsA("Model") and string.find(string.lower(m.Name), low, 1, true) then
				local bHum = m:FindFirstChildOfClass("Humanoid")
				local bPart = m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("Head") or m:FindFirstChildWhichIsA("BasePart")
				if bHum and bHum.Health > 0 and bPart and bPart:IsDescendantOf(workspace) then
					App.SeenAlive[bossInfo.Name] = true
					App.DiedFlag[bossInfo.Name] = false
					return bPart, m, "TRẠNG THÁI: CÒN SỐNG", Color3.fromRGB(52, 235, 145), true
				elseif bHum and bHum.Health <= 0 then
					App.DiedFlag[bossInfo.Name] = true
				end
			end
		end
	end

	for _, obj in ipairs(workspace:GetChildren()) do
		if obj:IsA("Model") and string.find(string.lower(obj.Name), low, 1, true) then
			local bHum = obj:FindFirstChildOfClass("Humanoid")
			local p = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
			if p and (not bHum or bHum.Health > 0) then
				App.SeenAlive[bossInfo.Name] = true
				App.DiedFlag[bossInfo.Name] = false
				return p, obj, "TRẠNG THÁI: CÒN SỐNG", Color3.fromRGB(52, 235, 145), true
			end
		end
	end

	if App.DiedFlag[bossInfo.Name] then
		return nil, nil, "TRẠNG THÁI: ĐÃ CHẾT", Color3.fromRGB(255, 85, 105), false
	end

	if App.SeenAlive[bossInfo.Name] then
		App.DiedFlag[bossInfo.Name] = true
		return nil, nil, "TRẠNG THÁI: ĐÃ CHẾT", Color3.fromRGB(255, 85, 105), false
	end

	return nil, nil, "TRẠNG THÁI: CHƯA SPAWN (BẬT FARM SẼ BAY TỚI)", Color3.fromRGB(255, 205, 85), false
end

local function isBossCastingSkill(bossModel, bossPart, hum, hrp)
	if not bossModel or not bossPart or not hrp then return false end
	if hum and App.PrevHealth and hum.Health < App.PrevHealth then
		App.PrevHealth = hum.Health
		return true
	end
	if hum then App.PrevHealth = hum.Health end

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
	return false
end

-- Dựng mô hình 3D thật của Boss hoặc mô hình 3D đặc trưng vào ViewportFrame
local function renderBoss3D(viewport, bossInfo, realModel)
	if not viewport or not bossInfo then return end
	local wm = viewport:FindFirstChildOfClass("WorldModel")
	if not wm then
		wm = Instance.new("WorldModel")
		wm.Parent = viewport
	end
	wm:ClearAllChildren()

	local cam = viewport.CurrentCamera
	if not cam then
		cam = Instance.new("Camera")
		cam.Parent = viewport
		viewport.CurrentCamera = cam
	end

	if realModel and realModel:IsA("Model") then
		pcall(function()
			realModel.Archivable = true
			local clone = realModel:Clone()
			for _, d in ipairs(clone:GetDescendants()) do
				if d:IsA("Script") or d:IsA("LocalScript") or d:IsA("BillboardGui") or d:IsA("ParticleEmitter") then
					d:Destroy()
				end
			end
			clone.Parent = wm
			local cf, size = clone:GetBoundingBox()
			local center = cf.Position
			local maxDim = math.max(size.X, size.Y, size.Z, 4)
			cam.CFrame = CFrame.lookAt(center + Vector3.new(maxDim * 1.1, maxDim * 0.45, maxDim * 1.35), center)
		end)
		if #wm:GetChildren() > 0 then return end
	end

	-- Mô hình 3D khi chưa có model thật trong workspace: thân + đầu + vương miện/sừng Boss
	local dummy = Instance.new("Model")
	dummy.Name = bossInfo.Name
	dummy.Parent = wm

	local torso = Instance.new("Part")
	torso.Size = Vector3.new(2.2, 2.6, 1.3)
	torso.Position = Vector3.new(0, 1.3, 0)
	torso.Color = bossInfo.Color
	torso.Material = Enum.Material.SmoothPlastic
	torso.Anchored = true
	torso.Parent = dummy

	local head = Instance.new("Part")
	head.Size = Vector3.new(1.5, 1.5, 1.5)
	head.Position = Vector3.new(0, 3.45, 0)
	head.Color = bossInfo.Color:Lerp(Color3.fromRGB(255, 255, 255), 0.15)
	head.Material = Enum.Material.SmoothPlastic
	head.Anchored = true
	head.Parent = dummy

	local crown = Instance.new("Part")
	crown.Size = Vector3.new(1.7, 0.55, 1.7)
	crown.Position = Vector3.new(0, 4.45, 0)
	crown.Color = Color3.fromRGB(255, 210, 55)
	crown.Material = Enum.Material.Neon
	crown.Anchored = true
	crown.Parent = dummy

	cam.CFrame = CFrame.lookAt(Vector3.new(4.2, 3.2, 5.2), Vector3.new(0, 2.5, 0))
end
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Net = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Net")
local RE_Atk = Net and Net:FindFirstChild("RE/RegisterAttack")
local RE_Hit = Net and Net:FindFirstChild("RE/RegisterHit")

local function getUiRoot()
	if type(gethui) == "function" then
		local ok, hui = pcall(gethui)
		if ok and hui then return hui end
	end
	local okCore, core = pcall(function() return CoreGui end)
	if okCore and core then return core end
	return LocalPlayer:FindFirstChild("PlayerGui")
end

local function refreshToggleUI()
	if App.FarmBtn then
		App.FarmBtn.Text = CFG.AutoFarmBoss and "⚡ Auto Farm Boss: ON" or "⚡ Auto Farm Boss: OFF"
		App.FarmBtn.BackgroundColor3 = CFG.AutoFarmBoss and Color3.fromRGB(16, 185, 129) or Color3.fromRGB(215, 55, 78)
	end
	if App.MeleeBtn then
		App.MeleeBtn.Text = CFG.AutoMelee and "🥊 Auto Melee: ON" or "🥊 Auto Melee: OFF"
		App.MeleeBtn.BackgroundColor3 = CFG.AutoMelee and Color3.fromRGB(124, 92, 255) or Color3.fromRGB(62, 68, 92)
	end
end

local function buildUI()
	local root = getUiRoot()
	if not root then return end

	local prev = root:FindFirstChild("KienProMax3DGui")
	if prev then pcall(function() prev:Destroy() end) end

	local sg = Instance.new("ScreenGui")
	sg.Name = "KienProMax3DGui"
	sg.ResetOnSpawn = false
	sg.DisplayOrder = 10000
	pcall(function() sg.Parent = root end)
	if not sg.Parent then sg.Parent = LocalPlayer:WaitForChild("PlayerGui", 5) end

	-- Thông báo trên cùng
	App.NotifyLbl = Instance.new("TextLabel")
	App.NotifyLbl.Size = UDim2.new(0, 316, 0, 28)
	App.NotifyLbl.Position = UDim2.new(0.5, -158, 0.03, 0)
	App.NotifyLbl.BackgroundColor3 = Color3.fromRGB(11, 15, 27)
	App.NotifyLbl.BackgroundTransparency = 0.2
	App.NotifyLbl.TextColor3 = Color3.fromRGB(64, 245, 255)
	App.NotifyLbl.Font = Enum.Font.GothamBold
	App.NotifyLbl.TextSize = 11
	App.NotifyLbl.Text = "🔔 " .. CFG.Title .. " • Sea " .. App.Sea .. " | Bay 150 | Tầm 60"
	App.NotifyLbl.Parent = sg
	Instance.new("UICorner", App.NotifyLbl).CornerRadius = UDim.new(0, 10)
	local nStroke = Instance.new("UIStroke", App.NotifyLbl)
	nStroke.Color = Color3.fromRGB(64, 245, 255)
	nStroke.Transparency = 0.45

	-- Nút nổi chữ K thiết kế đẹp, kéo thả mượt
	local kBtn = Instance.new("TextButton")
	kBtn.Size = UDim2.new(0, 48, 0, 48)
	kBtn.Position = UDim2.new(0.86, 0, 0.15, 0)
	kBtn.BackgroundColor3 = Color3.fromRGB(16, 21, 38)
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
		ColorSequenceKeypoint.new(0, Color3.fromRGB(64, 245, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(168, 85, 247)),
	})

	-- Khung chính Kiên Pro Max (310 x 332: danh sách Boss phía trên + khung 3D Boss phía dưới)
	local win = Instance.new("Frame")
	win.Size = UDim2.new(0, 310, 0, 332)
	win.Position = UDim2.new(0.5, -155, 0.52, -166)
	win.BackgroundColor3 = Color3.fromRGB(11, 15, 27)
	win.BackgroundTransparency = 0.2
	win.Visible = App.Open
	win.Parent = sg
	Instance.new("UICorner", win).CornerRadius = UDim.new(0, 16)
	local wStroke = Instance.new("UIStroke", win)
	wStroke.Thickness = 1.8
	local wGrad = Instance.new("UIGradient", wStroke)
	wGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(64, 245, 255)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(168, 85, 247)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 185, 129)),
	})

	local titleBar = Instance.new("TextLabel")
	titleBar.Size = UDim2.new(1, -16, 0, 22)
	titleBar.Position = UDim2.new(0, 8, 0, 6)
	titleBar.BackgroundTransparency = 1
	titleBar.Text = "⚡ " .. CFG.Title .. " • SEA " .. App.Sea .. "  |  " .. CFG.Brand
	titleBar.TextColor3 = Color3.fromRGB(64, 245, 255)
	titleBar.Font = Enum.Font.GothamBlack
	titleBar.TextSize = 12
	titleBar.TextXAlignment = Enum.TextXAlignment.Left
	titleBar.Parent = win

	App.SelectedLbl = Instance.new("TextLabel")
	App.SelectedLbl.Size = UDim2.new(1, -16, 0, 18)
	App.SelectedLbl.Position = UDim2.new(0, 8, 0, 28)
	App.SelectedLbl.BackgroundTransparency = 1
	App.SelectedLbl.Text = "Boss: " .. App.Selected.Name .. " (" .. App.Selected.Island .. ")"
	App.SelectedLbl.TextColor3 = Color3.fromRGB(245, 250, 255)
	App.SelectedLbl.Font = Enum.Font.GothamBold
	App.SelectedLbl.TextSize = 11
	App.SelectedLbl.TextXAlignment = Enum.TextXAlignment.Left
	App.SelectedLbl.Parent = win

	App.StatusLbl = Instance.new("TextLabel")
	App.StatusLbl.Size = UDim2.new(1, -16, 0, 18)
	App.StatusLbl.Position = UDim2.new(0, 8, 0, 46)
	App.StatusLbl.BackgroundTransparency = 1
	App.StatusLbl.Text = "TRẠNG THÁI: ĐANG QUÉT..."
	App.StatusLbl.TextColor3 = Color3.fromRGB(255, 205, 85)
	App.StatusLbl.Font = Enum.Font.GothamBold
	App.StatusLbl.TextSize = 10
	App.StatusLbl.TextXAlignment = Enum.TextXAlignment.Left
	App.StatusLbl.Parent = win

	-- Khu cuộn chọn Boss của Server/Sea hiện tại
	local listScroll = Instance.new("ScrollingFrame")
	listScroll.Size = UDim2.new(1, -16, 0, 116)
	listScroll.Position = UDim2.new(0, 8, 0, 68)
	listScroll.BackgroundColor3 = Color3.fromRGB(17, 23, 40)
	listScroll.BackgroundTransparency = 0.35
	listScroll.ScrollBarThickness = 4
	listScroll.CanvasSize = UDim2.new(0, 0, 0, #App.Bosses * 36 + 6)
	listScroll.Parent = win
	Instance.new("UICorner", listScroll).CornerRadius = UDim.new(0, 10)

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 4)
	layout.Parent = listScroll

	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 4)
	pad.PaddingLeft = UDim.new(0, 4)
	pad.PaddingRight = UDim.new(0, 4)
	pad.Parent = listScroll

	-- Khu hiển thị mô hình 3D của Boss ở phía dưới danh sách chọn
	local view3DBox = Instance.new("ViewportFrame")
	view3DBox.Size = UDim2.new(1, -16, 0, 96)
	view3DBox.Position = UDim2.new(0, 8, 0, 190)
	view3DBox.BackgroundColor3 = Color3.fromRGB(16, 22, 38)
	view3DBox.BackgroundTransparency = 0.25
	view3DBox.Parent = win
	Instance.new("UICorner", view3DBox).CornerRadius = UDim.new(0, 12)
	local vStroke = Instance.new("UIStroke", view3DBox)
	vStroke.Color = Color3.fromRGB(124, 92, 255)
	vStroke.Transparency = 0.35

	local viewTag = Instance.new("TextLabel")
	viewTag.Size = UDim2.new(1, -10, 0, 16)
	viewTag.Position = UDim2.new(0, 6, 1, -18)
	viewTag.BackgroundTransparency = 1
	viewTag.Text = "3D PREVIEW • " .. App.Selected.Name
	viewTag.TextColor3 = Color3.fromRGB(175, 225, 255)
	viewTag.Font = Enum.Font.GothamBold
	viewTag.TextSize = 10
	viewTag.TextXAlignment = Enum.TextXAlignment.Left
	viewTag.Parent = view3DBox

	App.PreviewRefresh = function(realModel)
		viewTag.Text = "3D PREVIEW • " .. App.Selected.Name .. (realModel and " (Model Thật)" or " (3D)")
		renderBoss3D(view3DBox, App.Selected, realModel)
	end

	for _, bInfo in ipairs(App.Bosses) do
		local itemBtn = Instance.new("TextButton")
		itemBtn.Size = UDim2.new(1, 0, 0, 32)
		itemBtn.BackgroundColor3 = Color3.fromRGB(24, 32, 54)
		itemBtn.BackgroundTransparency = 0.2
		itemBtn.Text = "  " .. bInfo.Name .. "  •  " .. bInfo.Island
		itemBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		itemBtn.Font = Enum.Font.GothamBold
		itemBtn.TextSize = 11
		itemBtn.TextXAlignment = Enum.TextXAlignment.Left
		itemBtn.Parent = listScroll
		Instance.new("UICorner", itemBtn).CornerRadius = UDim.new(0, 8)

		itemBtn.MouseButton1Click:Connect(function()
			App.Selected = bInfo
			App.SelectedLbl.Text = "Boss: " .. bInfo.Name .. " (" .. bInfo.Island .. ")"
			local _, mModel = scanBoss(bInfo, nil)
			App.PreviewRefresh(mModel)
			notify("Chọn Boss: " .. bInfo.Name)
		end)
	end

	App.FarmBtn = Instance.new("TextButton")
	App.FarmBtn.Size = UDim2.new(0.5, -12, 0, 32)
	App.FarmBtn.Position = UDim2.new(0, 8, 1, -38)
	App.FarmBtn.Font = Enum.Font.GothamBold
	App.FarmBtn.TextSize = 11
	App.FarmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	App.FarmBtn.Parent = win
	Instance.new("UICorner", App.FarmBtn).CornerRadius = UDim.new(0, 9)

	App.MeleeBtn = Instance.new("TextButton")
	App.MeleeBtn.Size = UDim2.new(0.5, -12, 0, 32)
	App.MeleeBtn.Position = UDim2.new(0.5, 4, 1, -38)
	App.MeleeBtn.Font = Enum.Font.GothamBold
	App.MeleeBtn.TextSize = 11
	App.MeleeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	App.MeleeBtn.Parent = win
	Instance.new("UICorner", App.MeleeBtn).CornerRadius = UDim.new(0, 9)

	App.FarmBtn.MouseButton1Click:Connect(function()
		CFG.AutoFarmBoss = not CFG.AutoFarmBoss
		if not CFG.AutoFarmBoss then stopMove() end
		refreshToggleUI()
		notify(CFG.AutoFarmBoss and "Bật Auto Farm Boss (150)" or "Tắt Auto Farm Boss")
	end)

	App.MeleeBtn.MouseButton1Click:Connect(function()
		CFG.AutoMelee = not CFG.AutoMelee
		refreshToggleUI()
		notify(CFG.AutoMelee and "Bật Auto Melee" or "Tắt Auto Melee")
	end)

	kBtn.MouseButton1Click:Connect(function()
		App.Open = not App.Open
		win.Visible = App.Open
		if App.Open then
			win.Size = UDim2.new(0, 40, 0, 40)
			TweenService:Create(win, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, 310, 0, 332)
			}):Play()
		end
	end)

	local dragging, dInput, sInput, sPos = false
	win.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging, sInput, sPos = true, inp.Position, win.Position
			inp.Changed:Connect(function()
				if inp.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	win.InputChanged:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseMovement then
			dInput = inp
		end
	end)
	UserInputService.InputChanged:Connect(function(inp)
		if inp == dInput and dragging then
			local delta = inp.Position - sInput
			win.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + delta.X, sPos.Y.Scale, sPos.Y.Offset + delta.Y)
		end
	end)

	refreshToggleUI()
	App.PreviewRefresh(nil)

	-- Hiệu ứng mở mượt khi bật script
	win.Size = UDim2.new(0, 60, 0, 40)
	TweenService:Create(win, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 310, 0, 332)
	}):Play()

	task.spawn(function()
		while win.Parent do
			wGrad.Rotation = (wGrad.Rotation + 2) % 360
			kGrad.Rotation = (kGrad.Rotation - 2) % 360
			task.wait(0.03)
		end
	end)
end

pcall(buildUI)
task.spawn(applyFixLag)

local lastPreviewKey = ""

RunService.Heartbeat:Connect(function(dt)
	local now = os.clock()
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local hrp = char and char:FindFirstChild("HumanoidRootPart")

	local bossPart, bossModel, stText, stColor, isAlive = scanBoss(App.Selected, hrp)
	if App.StatusLbl then
		App.StatusLbl.Text = stText .. " | Bay 150 | Tầm 60"
		App.StatusLbl.TextColor3 = stColor
	end

	local pKey = tostring(App.Selected and App.Selected.Name) .. "_" .. tostring(bossModel ~= nil)
	if pKey ~= lastPreviewKey and App.PreviewRefresh then
		lastPreviewKey = pKey
		App.PreviewRefresh(bossModel)
	end

	if not CFG.AutoFarmBoss or not App.Selected then
		stopMove()
		return
	end

	if not char or not hum or hum.Health <= 0 or not hrp or not hrp:IsDescendantOf(workspace) then
		stopMove()
		return
	end

	if CFG.AutoMelee and (now - App.LastMelee >= 0.45) then
		App.LastMelee = now
		equipMelee(char, hum)
	end

	if bossPart and bossModel then
		if isBossCastingSkill(bossModel, bossPart, hum, hrp) then
			App.SkyDodgeUntil = now + CFG.SkyDodgeDuration
		end
		local goal = bossPart.Position + Vector3.new(0, CFG.Height, 0)
		if now < App.SkyDodgeUntil then
			goal = bossPart.Position + Vector3.new(0, CFG.SkyDodgeHeight, 0)
			notify("Né skill Boss -> Bay lên cao!")
		end
		flyTo(char, hum, hrp, goal, dt)
	else
		-- Chưa thấy Boss hoặc đang đứng xa đảo: vẫn bay tới tọa độ đảo của Boss ở tốc độ 150 để kích spawn/kiểm tra
		local dest = App.Selected.Pos + Vector3.new(0, 22, 0)
		if (dest - hrp.Position).Magnitude > 4 then
			flyTo(char, hum, hrp, dest, dt)
			notify("Bay tới " .. App.Selected.Island .. " (tốc độ 150)")
		else
			stopMove()
		end
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
