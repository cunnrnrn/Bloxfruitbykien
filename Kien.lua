local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local CFG = {
	Brand = "√12kientomato",
	Title = "KIÊN PRO MAX",
	Range = 60,
	Delay = 0.13,
	Speed = 170,
	Height = 8,
	AutoMelee = true,
	AutoFarmBoss = false,
	Session = "20404cc8",
	-- Hiệu ứng mở đầu kiểu chuyển cảnh xe / con mắt / mở giao diện
	IntroCarImage = "rbxassetid://0",
	IntroEyeImage = "rbxassetid://0",
}

local MELEE_NAMES = {
	"combat", "dark step", "electric", "water kung fu", "dragon breath",
	"superhuman", "death step", "sharkman karate", "electric claw",
	"dragon talon", "godhuman", "sanguine art",
}

-- {Name = "Tên Boss", Island = "Đảo", Pos = Vector3, Image = "rbxassetid://..."}
local BOSS_LIST = {
	{Name = "The Gorilla King", Island = "Jungle", Pos = Vector3.new(-1142, 40, -515), Image = "rbxassetid://0"},
	{Name = "Bobby", Island = "Pirate Village", Pos = Vector3.new(-1147, 15, 3835), Image = "rbxassetid://0"},
	{Name = "Ancient Monk", Island = "Sky Area 1", Pos = Vector3.new(-4840, 718, -2620), Image = "rbxassetid://0"},
	{Name = "Warden", Island = "Prison", Pos = Vector3.new(4875, 6, 736), Image = "rbxassetid://0"},
	{Name = "Chief Warden", Island = "Prison", Pos = Vector3.new(5310, 2, 474), Image = "rbxassetid://0"},
	{Name = "Swan", Island = "Prison", Pos = Vector3.new(5230, 6, 740), Image = "rbxassetid://0"},
	{Name = "Magma Admiral", Island = "Magma Village", Pos = Vector3.new(-5690, 78, 8680), Image = "rbxassetid://0"},
	{Name = "Fishman Lord", Island = "Underwater City", Pos = Vector3.new(61120, 18, 1569), Image = "rbxassetid://0"},
	{Name = "Wysper", Island = "Upper Sky", Pos = Vector3.new(-7900, 5545, -380), Image = "rbxassetid://0"},
	{Name = "Thunder God", Island = "Upper Sky", Pos = Vector3.new(-7775, 5605, -2500), Image = "rbxassetid://0"},
	{Name = "Cyborg", Island = "Fountain City", Pos = Vector3.new(5660, 48, 4900), Image = "rbxassetid://0"},
	{Name = "Diamond", Island = "Colosseum", Pos = Vector3.new(-1575, 12, -2990), Image = "rbxassetid://0"},
	{Name = "Jeremy", Island = "Area 1", Pos = Vector3.new(2175, 448, 750), Image = "rbxassetid://0"},
	{Name = "Fajita", Island = "Green Zone", Pos = Vector3.new(-2145, 73, 120), Image = "rbxassetid://0"},
	{Name = "Smoke Admiral", Island = "Marine Base G1", Pos = Vector3.new(-2440, 73, -3215), Image = "rbxassetid://0"},
	{Name = "Don Swan", Island = "Mansion", Pos = Vector3.new(2285, 15, 905), Image = "rbxassetid://0"},
	{Name = "Cursed Captain", Island = "Cursed Ship", Pos = Vector3.new(915, 141, 33410), Image = "rbxassetid://0"},
	{Name = "Cake Queen", Island = "Cake Land", Pos = Vector3.new(-705, 381, -11150), Image = "rbxassetid://0"},
	{Name = "Dough King", Island = "Cake Land", Pos = Vector3.new(-2020, 38, -12025), Image = "rbxassetid://0"},
	{Name = "Rip_Indra", Island = "Castle on the Sea", Pos = Vector3.new(-5345, 424, -2730), Image = "rbxassetid://0"},
	{Name = "Tiki Boss", Island = "Tiki Outpost", Pos = Vector3.new(-16550, 55, 1050), Image = "rbxassetid://0"},
}

local App = {
	SelectedBoss = BOSS_LIST[1],
	MenuOpen = true,
	LastAtk = 0,
	LastMelee = 0,
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

local function getUiContainer()
	if type(gethui) == "function" then
		local ok, hui = pcall(gethui)
		if ok and hui then return hui end
	end
	local okCore, core = pcall(function() return CoreGui end)
	if okCore and core then return core end
	return LocalPlayer:FindFirstChild("PlayerGui")
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
		gyro.P = 15000
		gyro.D = 400
		gyro.CFrame = hrp.CFrame
		gyro.Parent = hrp
		App.BG = gyro
	end

	local diff = targetPos - hrp.Position
	local dist = diff.Magnitude
	local stepDt = math.clamp(dt or 0.016, 0.008, 0.05)

	if dist > 2.5 then
		local dir = diff.Unit
		App.BV.Velocity = dir * CFG.Speed
		hrp.CFrame = CFrame.new(hrp.Position + dir * math.min(dist, CFG.Speed * stepDt))
	else
		App.BV.Velocity = Vector3.zero
		hrp.CFrame = CFrame.new(targetPos)
	end

	local lookPos = Vector3.new(targetPos.X, hrp.Position.Y - CFG.Height, targetPos.Z)
	if (lookPos - hrp.Position).Magnitude > 0.1 then
		App.BG.CFrame = CFrame.lookAt(hrp.Position, lookPos)
	end
end

local function findBoss(bossName, hrp)
	local folder = workspace:FindFirstChild("Enemies")
	if not folder or not bossName then return nil end
	local low = string.lower(bossName)
	local bestPart, bestDist = nil, math.huge
	for _, m in ipairs(folder:GetChildren()) do
		if m:IsA("Model") and string.find(string.lower(m.Name), low, 1, true) then
			local hum = m:FindFirstChildOfClass("Humanoid")
			local part = m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("Head")
			if hum and hum.Health > 0 and part and part:IsDescendantOf(workspace) then
				local d = hrp and (part.Position - hrp.Position).Magnitude or 0
				if d < bestDist then
					bestDist, bestPart = d, part
				end
			end
		end
	end
	return bestPart
end
local Net = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Net")
local RE_Atk = Net and Net:FindFirstChild("RE/RegisterAttack")
local RE_Hit = Net and Net:FindFirstChild("RE/RegisterHit")

local function refreshButtons()
	if App.ToggleFarmBtn then
		App.ToggleFarmBtn.Text = App.SelectedBoss
			and (CFG.AutoFarmBoss and ("Auto Farm Boss: ON") or ("Auto Farm Boss: OFF"))
			or "Auto Farm Boss: OFF"
		App.ToggleFarmBtn.BackgroundColor3 = CFG.AutoFarmBoss and Color3.fromRGB(16, 185, 129) or Color3.fromRGB(225, 65, 85)
	end
	if App.ToggleMeleeBtn then
		App.ToggleMeleeBtn.Text = CFG.AutoMelee and "Tự Cầm Melee: ON" or "Tự Cầm Melee: OFF"
		App.ToggleMeleeBtn.BackgroundColor3 = CFG.AutoMelee and Color3.fromRGB(124, 92, 255) or Color3.fromRGB(82, 88, 112)
	end
end

local function selectBoss(bossData)
	App.SelectedBoss = bossData
	if App.SelectedLbl then
		App.SelectedLbl.Text = "Boss: " .. bossData.Name .. " (" .. bossData.Island .. ")"
	end
	notify("Đã chọn Boss: " .. bossData.Name)
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
	App.NotifyLbl.Size = UDim2.new(0, 300, 0, 28)
	App.NotifyLbl.Position = UDim2.new(0.5, -150, 0.035, 0)
	App.NotifyLbl.BackgroundColor3 = Color3.fromRGB(14, 18, 30)
	App.NotifyLbl.BackgroundTransparency = 0.25
	App.NotifyLbl.TextColor3 = Color3.fromRGB(56, 248, 255)
	App.NotifyLbl.Font = Enum.Font.GothamBold
	App.NotifyLbl.TextSize = 11
	App.NotifyLbl.Text = "🔔 " .. CFG.Title .. " • " .. CFG.Brand
	App.NotifyLbl.Parent = sg
	Instance.new("UICorner", App.NotifyLbl).CornerRadius = UDim.new(0, 10)
	local nStroke = Instance.new("UIStroke", App.NotifyLbl)
	nStroke.Color = Color3.fromRGB(56, 248, 255)
	nStroke.Transparency = 0.55

	-- Nút nổi chữ K kéo thả để thu/mở giao diện
	local kFloat = Instance.new("TextButton")
	kFloat.Size = UDim2.new(0, 44, 0, 44)
	kFloat.Position = UDim2.new(0.87, 0, 0.16, 0)
	kFloat.Text = "K"
	kFloat.Font = Enum.Font.GothamBlack
	kFloat.TextSize = 20
	kFloat.TextColor3 = Color3.fromRGB(255, 255, 255)
	kFloat.BackgroundColor3 = Color3.fromRGB(18, 24, 42)
	kFloat.BackgroundTransparency = 0.18
	kFloat.Parent = sg
	Instance.new("UICorner", kFloat).CornerRadius = UDim.new(1, 0)
	local kStroke = Instance.new("UIStroke", kFloat)
	kStroke.Color = Color3.fromRGB(124, 92, 255)
	kStroke.Thickness = 1.6

	-- Khung chính Kiên Pro Max (mở từ từ bằng Tween)
	local mainFrame = Instance.new("Frame")
	mainFrame.Size = UDim2.new(0, 0, 0, 0)
	mainFrame.Position = UDim2.new(0.5, 0, 0.52, 0)
	mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	mainFrame.BackgroundColor3 = Color3.fromRGB(13, 17, 29)
	mainFrame.BackgroundTransparency = 0.22
	mainFrame.ClipsDescendants = true
	mainFrame.Visible = false
	mainFrame.Parent = sg
	Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 16)
	local mStroke = Instance.new("UIStroke", mainFrame)
	mStroke.Color = Color3.fromRGB(92, 225, 255)
	mStroke.Thickness = 1.4
	mStroke.Transparency = 0.3

	-- Lớp chuyển cảnh mở đầu (xe -> mắt -> hiện giao diện)
	local introOverlay = Instance.new("Frame")
	introOverlay.Size = UDim2.new(1, 0, 1, 0)
	introOverlay.BackgroundColor3 = Color3.fromRGB(9, 12, 22)
	introOverlay.BackgroundTransparency = 0.08
	introOverlay.ZIndex = 20
	introOverlay.Parent = mainFrame
	Instance.new("UICorner", introOverlay).CornerRadius = UDim.new(0, 16)

	local introIcon = Instance.new("ImageLabel")
	introIcon.Size = UDim2.new(0, 68, 0, 44)
	introIcon.Position = UDim2.new(0.5, -34, 0.32, 0)
	introIcon.BackgroundTransparency = 1
	introIcon.Image = CFG.IntroCarImage
	introIcon.ScaleType = Enum.ScaleType.Fit
	introIcon.ZIndex = 21
	introIcon.Parent = introOverlay

	local introLabel = Instance.new("TextLabel")
	introLabel.Size = UDim2.new(1, -24, 0, 28)
	introLabel.Position = UDim2.new(0, 12, 0.58, 0)
	introLabel.BackgroundTransparency = 1
	introLabel.Text = "🚗 " .. CFG.Title .. " • Đang khởi động..."
	introLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	introLabel.Font = Enum.Font.GothamBlack
	introLabel.TextSize = 13
	introLabel.ZIndex = 21
	introLabel.Parent = introOverlay

	-- Header
	local header = Instance.new("TextLabel")
	header.Size = UDim2.new(1, -20, 0, 24)
	header.Position = UDim2.new(0, 10, 0, 8)
	header.BackgroundTransparency = 1
	header.Text = "⚡ " .. CFG.Title .. "  |  " .. CFG.Brand
	header.TextColor3 = Color3.fromRGB(92, 225, 255)
	header.Font = Enum.Font.GothamBlack
	header.TextSize = 13
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.Parent = mainFrame

	App.SelectedLbl = Instance.new("TextLabel")
	App.SelectedLbl.Size = UDim2.new(1, -20, 0, 18)
	App.SelectedLbl.Position = UDim2.new(0, 10, 0, 32)
	App.SelectedLbl.BackgroundTransparency = 1
	App.SelectedLbl.Text = "Boss: " .. App.SelectedBoss.Name .. " (" .. App.SelectedBoss.Island .. ")"
	App.SelectedLbl.TextColor3 = Color3.fromRGB(235, 245, 255)
	App.SelectedLbl.Font = Enum.Font.GothamBold
	App.SelectedLbl.TextSize = 11
	App.SelectedLbl.TextXAlignment = Enum.TextXAlignment.Left
	App.SelectedLbl.Parent = mainFrame

	App.BossStatusLbl = Instance.new("TextLabel")
	App.BossStatusLbl.Size = UDim2.new(1, -20, 0, 18)
	App.BossStatusLbl.Position = UDim2.new(0, 10, 0, 50)
	App.BossStatusLbl.BackgroundTransparency = 1
	App.BossStatusLbl.Text = "Trạng thái: Đang kiểm tra... | Bay 170 | Tầm 60"
	App.BossStatusLbl.TextColor3 = Color3.fromRGB(255, 215, 110)
	App.BossStatusLbl.Font = Enum.Font.GothamMedium
	App.BossStatusLbl.TextSize = 10
	App.BossStatusLbl.TextXAlignment = Enum.TextXAlignment.Left
	App.BossStatusLbl.Parent = mainFrame

	-- Danh sách chọn Boss kéo lên/kéo xuống (có hình ảnh Boss)
	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -16, 0, 134)
	scroll.Position = UDim2.new(0, 8, 0, 72)
	scroll.BackgroundColor3 = Color3.fromRGB(19, 25, 42)
	scroll.BackgroundTransparency = 0.35
	scroll.ScrollBarThickness = 4
	scroll.CanvasSize = UDim2.new(0, 0, 0, #BOSS_LIST * 46 + 8)
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

	for _, bData in ipairs(BOSS_LIST) do
		local rowBtn = Instance.new("TextButton")
		rowBtn.Size = UDim2.new(1, 0, 0, 42)
		rowBtn.BackgroundColor3 = Color3.fromRGB(26, 34, 56)
		rowBtn.BackgroundTransparency = 0.2
		rowBtn.Text = ""
		rowBtn.Parent = scroll
		Instance.new("UICorner", rowBtn).CornerRadius = UDim.new(0, 8)

		local thumb = Instance.new("ImageLabel")
		thumb.Size = UDim2.new(0, 34, 0, 34)
		thumb.Position = UDim2.new(0, 4, 0, 4)
		thumb.BackgroundColor3 = Color3.fromRGB(15, 20, 34)
		thumb.Image = bData.Image
		thumb.ScaleType = Enum.ScaleType.Crop
		thumb.Parent = rowBtn
		Instance.new("UICorner", thumb).CornerRadius = UDim.new(0, 6)

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
		subTxt.Text = "Đảo: " .. bData.Island
		subTxt.TextColor3 = Color3.fromRGB(145, 215, 255)
		subTxt.Font = Enum.Font.Gotham
		subTxt.TextSize = 10
		subTxt.TextXAlignment = Enum.TextXAlignment.Left
		subTxt.Parent = rowBtn

		rowBtn.MouseButton1Click:Connect(function()
			selectBoss(bData)
		end)
	end

	-- Nút bật/tắt Auto Farm Boss & Tự cầm Melee
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
		notify(CFG.AutoFarmBoss and "Bật Farm Boss" or "Tắt Farm Boss")
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
			mainFrame.Size = UDim2.new(0, 276, 0, 256)
		end
	end)

	-- Kéo thả giao diện trên điện thoại
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

	-- Chạy hiệu ứng mở từ từ: xe -> mắt -> mở rộng giao diện
	mainFrame.Visible = true
	TweenService:Create(
		mainFrame,
		TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		{Size = UDim2.new(0, 276, 0, 256)}
	):Play()

	task.spawn(function()
		task.wait(0.45)
		introIcon.Image = CFG.IntroEyeImage
		introLabel.Text = "👁️ Quét đảo & Boss sẵn sàng..."
		task.wait(0.45)
		local fade = TweenService:Create(introOverlay, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
		local txtFade = TweenService:Create(introLabel, TweenInfo.new(0.35), {TextTransparency = 1})
		local imgFade = TweenService:Create(introIcon, TweenInfo.new(0.35), {ImageTransparency = 1})
		fade:Play()
		txtFade:Play()
		imgFade:Play()
		fade.Completed:Wait()
		introOverlay.Visible = false
	end)
end

pcall(buildKienProMaxUI)

RunService.Heartbeat:Connect(function(dt)
	local now = os.clock()
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local hrp = char and char:FindFirstChild("HumanoidRootPart")

	local bossPart = App.SelectedBoss and findBoss(App.SelectedBoss.Name, hrp) or nil
	local aliveText = bossPart and "CÒN SỐNG" or "ĐÃ CHẾT / CHƯA SPAWN"

	if App.BossStatusLbl then
		App.BossStatusLbl.Text = "Boss: " .. aliveText .. " | Bay 170 | Tầm 60"
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

	-- Luôn bay tới đảo của Boss trước để kích spawn quái/Boss khi đứng xa
	if bossPart then
		flyTo(char, hum, hrp, bossPart.Position + Vector3.new(0, CFG.Height, 0), dt)
	else
		local islandPos = App.SelectedBoss.Pos + Vector3.new(0, 24, 0)
		if (islandPos - hrp.Position).Magnitude > 4 then
			flyTo(char, hum, hrp, islandPos, dt)
			notify("Bay tới " .. App.SelectedBoss.Island .. " kích spawn...")
		else
			stopFlight()
		end
	end

	-- Tốc độ đánh giữ nguyên 0.13s, khoảng cách đánh 60
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
