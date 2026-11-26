repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local placeId = game.PlaceId
local World1, World2, World3 = false, false, false
if placeId == 2753915549 or placeId == 85211729168715 then
	World1 = true
elseif placeId == 4442272183 or placeId == 79091703265657 then
	World2 = true
elseif placeId == 7449423635 or placeId == 100117331123089 then
	World3 = true
end

local FolderName = "Night"
local SubFolder = FolderName .. "/Blox Fruits"
local FileName = SubFolder .. "/" .. LocalPlayer.Name .. ".json"

_G.Settings = {
	Main = {
		["Selected Weapon"] = "Melee",
		["Auto Farm"] = false,
		["Auto Farm Nearest"] = false,
		["Selected Monster"] = nil,
		["Farm Monster"] = false,
		["Selected Boss"] = nil,
		["Farm Boss"] = false,
		["Selected Mastery Mode"] = "Quest",
		["Selected Mastery Fruit"] = {},
		["Farm Mastery Fruit"] = false,
		["Selected Mastery Gun"] = {},
		["Farm Mastery Gun"] = false,
		["Selected Mastery Sword"] = {},
		["Farm Mastery Sword"] = false,
		["Kill Health Mastery"] = 25,
		["Auto Haki"] = true,
		["Auto Observation"] = false,
		["Auto Dodge"] = false,
		["Auto Turn On V3"] = false,
		["Auto Turn On V4"] = false,
		["Bring Mob"] = true,
		["Farm Distance"] = 25,
		["Spin Position"] = false,
		["Fast Attack"] = true,
		["Attack Delay"] = 0.12
	},
	Farming = {
		["Auto Elite Hunter"] = false,
		["Hop Server Elite"] = false,
		["Auto Farm Bone"] = false,
		["Auto Random Surprise"] = false,
		["Auto Pirate Raid"] = false,
		["Auto Observation V2"] = false,
		["Auto Musketeer Hat"] = false,
		["Auto Saber"] = false,
		["Auto Farm Chest"] = false,
		["Chest Mode"] = "Tween",
		["Auto Cake Prince"] = false,
		["Auto Dough King"] = false,
		["Auto Sea Beast"] = false,
		["Auto Terror Shark"] = false,
		["Auto Shark"] = false,
		["Auto Piranha"] = false,
		["Auto Fish Boat"] = false,
		["Auto Ghost Ship"] = false,
		["Auto Tushita"] = false,
		["Auto Yama"] = false,
		["Auto Soul Guitar"] = false,
		["Auto Cursed Dual Katana"] = false
	},
	Items = {
		["Auto Superhuman"] = false,
		["Auto Death Step"] = false,
		["Auto Sharkman Karate"] = false,
		["Auto Electric Claw"] = false,
		["Auto Dragon Talon"] = false,
		["Auto Godhuman"] = false,
		["Auto Rengoku"] = false,
		["Auto Midnight Blade"] = false,
		["Auto Buddy Sword"] = false,
		["Auto Canvander"] = false,
		["Auto Kabucha"] = false,
		["Auto Pole"] = false
	},
	Setting = {
		["White Screen"] = false,
		["Remove Effect"] = false,
		["Remove Monster"] = false,
		["Disable Notify"] = false,
		["Auto Rejoin"] = true,
		["Anti AFK"] = true,
		["Hop Delay"] = 3
	},
	ESP = {
		["ESP Island"] = false,
		["ESP Player"] = false,
		["ESP Chest"] = false,
		["ESP DevilFruit"] = false,
		["ESP RealFruit"] = false,
		["ESP Flower"] = false,
		["ESP Monster"] = false,
		["ESP Sea Beast"] = false,
		["ESP Npc"] = false,
		["ESP Mirage"] = false,
		["ESP Kitsune"] = false,
		["ESP Frozen"] = false,
		["ESP Prehistoric"] = false,
		["ESP Advanced Fruit Dealer"] = false,
		["ESP Aura"] = false,
		["ESP Gear"] = false
	},
	Teleport = {
		["Selected Sea"] = "Sea 1",
		["Selected Island"] = nil
	},
	Shop = {
		["Auto Buy Haki"] = false,
		["Auto Buy Soru"] = false,
		["Auto Buy Observation"] = false,
		["Auto Buy Buso"] = false
	},
	Misc = {
		["Auto Rip Indra"] = false,
		["Auto Law Raid"] = false,
		["Auto Factory"] = false,
		["Auto Temple of Time"] = false,
		["Auto Trial V4"] = false
	}
}

local function SaveSettings()
	if writefile and makefolder then
		if not isfolder(FolderName) then makefolder(FolderName) end
		if not isfolder(SubFolder) then makefolder(SubFolder) end
		writefile(FileName, HttpService:JSONEncode(_G.Settings))
	end
end

local function LoadSettings()
	if isfile and isfile(FileName) then
		local ok, decoded = pcall(function()
			return HttpService:JSONDecode(readfile(FileName))
		end)
		if ok and type(decoded) == "table" then
			for k, v in pairs(decoded) do
				if type(v) == "table" and type(_G.Settings[k]) == "table" then
					for sk, sv in pairs(v) do
						_G.Settings[k][sk] = sv
					end
				else
					_G.Settings[k] = v
				end
			end
		end
	end
end
LoadSettings()

local UILib
pcall(function()
	UILib = loadstring(game:HttpGet("https://raw.githubusercontent.com/NightHubDev/NightHub/main/Library.1.lua"))()
end)

local Window = UILib and UILib:CreateWindow({
	Title = "Night Hub | Blox Fruits",
	SubTitle = World3 and "Sea 3" or World2 and "Sea 2" or "Sea 1",
	SaveConfig = true
}) or {
	MakeTab = function(_, name)
		return {
			AddSection = function() end,
			AddToggle = function() end,
			AddDropdown = function() end,
			AddSlider = function() end,
			AddButton = function() end
		}
	end
}

local MainTab = Window:MakeTab("Main")
local FarmingTab = Window:MakeTab("Farming")
local ItemsTab = Window:MakeTab("Items")
local SettingTab = Window:MakeTab("Setting")
local LocalPlayerTab = Window:MakeTab("Local Player")
local HoldSkillTab = Window:MakeTab("Hold Skill")
local SeaEventTab = Window:MakeTab("Sea Event")
local StackSeaTab = Window:MakeTab("Stack Sea")
local CraftsTab = Window:MakeTab("Crafts")
local DragonDojoTab = Window:MakeTab("Dragon Dojo")
local RaceV4Tab = Window:MakeTab("Race V4")
local CombatTab = Window:MakeTab("Combat")
local RaidTab = Window:MakeTab("Raid")
local EspTab = Window:MakeTab("Esp")
local TeleportTab = Window:MakeTab("Teleport")
local ShopTab = Window:MakeTab("Shop")
local DevilFruitTab = Window:MakeTab("Devil Fruit")
local MiscTab = Window:MakeTab("Misc")
local ServerTab = Window:MakeTab("Server")

local function EquipWeaponByType(wType)
	local char = LocalPlayer.Character
	local backpack = LocalPlayer:FindFirstChild("Backpack")
	if not char or not backpack then return end
	for _, tool in ipairs(backpack:GetChildren()) do
		if tool:IsA("Tool") and tool.ToolTip == wType then
			char.Humanoid:EquipTool(tool)
			return tool
		end
	end
	for _, tool in ipairs(char:GetChildren()) do
		if tool:IsA("Tool") and tool.ToolTip == wType then
			return tool
		end
	end
end

local function AttackTarget(targetPart)
	if not targetPart or not _G.Settings.Main["Fast Attack"] then return end
	pcall(function()
		local net = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Net")
		local regAtk = net and net:FindFirstChild("RE/RegisterAttack")
		local regHit = net and net:FindFirstChild("RE/RegisterHit")
		if regAtk then regAtk:FireServer(_G.Settings.Main["Attack Delay"] or 0.12) end
		if regHit and targetPart.Parent then
			regHit:FireServer(targetPart, {})
		end
	end)
end

local function MoveToCFrame(cf)
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp or not cf then return end
	local dist = (hrp.Position - cf.Position).Magnitude
	if dist <= 6 then
		hrp.CFrame = cf
		return
	end
	local tween = TweenService:Create(hrp, TweenInfo.new(math.clamp(dist / 300, 0.05, 4), Enum.EasingStyle.Linear), {CFrame = cf})
	tween:Play()
	tween.Completed:Wait()
end

local function GetNearestEnemy(maxDist)
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil end
	local enemies = workspace:FindFirstChild("Enemies")
	if not enemies then return nil end
	local closest, bestDist = nil, maxDist or 2500
	for _, mob in ipairs(enemies:GetChildren()) do
		local hum = mob:FindFirstChildOfClass("Humanoid")
		local root = mob:FindFirstChild("HumanoidRootPart")
		if hum and hum.Health > 0 and root then
			local d = (hrp.Position - root.Position).Magnitude
			if d < bestDist then
				bestDist = d
				closest = mob
			end
		end
	end
	return closest
end

local function GetMonsterNames()
	local names, seen = {}, {}
	local enemies = workspace:FindFirstChild("Enemies")
	if enemies then
		for _, mob in ipairs(enemies:GetChildren()) do
			if not seen[mob.Name] then
				seen[mob.Name] = true
				table.insert(names, mob.Name)
			end
		end
	end
	return names
end

local function GetToolNamesByTip(tip)
	local list = {}
	for _, container in ipairs({LocalPlayer:FindFirstChild("Backpack"), LocalPlayer.Character}) do
		if container then
			for _, item in ipairs(container:GetChildren()) do
				if item:IsA("Tool") and (not tip or item.ToolTip == tip) then
					table.insert(list, item.Name)
				end
			end
		end
	end
	return list
end

MainTab:AddSection("Farm")
MainTab:AddDropdown("Selected Weapon", {"Melee", "Sword", "Gun", "Fruit"}, _G.Settings.Main["Selected Weapon"], function(v)
	_G.Settings.Main["Selected Weapon"] = v
	SaveSettings()
end)
MainTab:AddToggle("Auto Farm", _G.Settings.Main["Auto Farm"], function(v)
	_G.Settings.Main["Auto Farm"] = v
	SaveSettings()
end)
MainTab:AddToggle("Auto Farm Nearest", _G.Settings.Main["Auto Farm Nearest"], function(v)
	_G.Settings.Main["Auto Farm Nearest"] = v
	SaveSettings()
end)
MainTab:AddDropdown("Select Monster", GetMonsterNames(), _G.Settings.Main["Selected Monster"], function(v)
	_G.Settings.Main["Selected Monster"] = v
	SaveSettings()
end)
MainTab:AddToggle("Farm Monster", _G.Settings.Main["Farm Monster"], function(v)
	_G.Settings.Main["Farm Monster"] = v
	SaveSettings()
end)
MainTab:AddDropdown("Select Boss", GetMonsterNames(), _G.Settings.Main["Selected Boss"], function(v)
	_G.Settings.Main["Selected Boss"] = v
	SaveSettings()
end)
MainTab:AddToggle("Farm Boss", _G.Settings.Main["Farm Boss"], function(v)
	_G.Settings.Main["Farm Boss"] = v
	SaveSettings()
end)

MainTab:AddSection("Mastery")
MainTab:AddDropdown("Select Mastery Mode", {"Quest", "No Quest", "Bones", "Cakeprince", "Nearest", "Boss"}, _G.Settings.Main["Selected Mastery Mode"], function(v)
	_G.Settings.Main["Selected Mastery Mode"] = v
	SaveSettings()
end)
MainTab:AddDropdown("Select Mastery Fruit", GetToolNamesByTip("Blox Fruit"), _G.Settings.Main["Selected Mastery Fruit"], function(v)
	_G.Settings.Main["Selected Mastery Fruit"] = v
	SaveSettings()
end)
MainTab:AddToggle("Farm Mastery Fruit", _G.Settings.Main["Farm Mastery Fruit"], function(v)
	_G.Settings.Main["Farm Mastery Fruit"] = v
	SaveSettings()
end)
MainTab:AddDropdown("Select Mastery Gun", GetToolNamesByTip("Gun"), _G.Settings.Main["Selected Mastery Gun"], function(v)
	_G.Settings.Main["Selected Mastery Gun"] = v
	SaveSettings()
end)
MainTab:AddToggle("Farm Mastery Gun", _G.Settings.Main["Farm Mastery Gun"], function(v)
	_G.Settings.Main["Farm Mastery Gun"] = v
	SaveSettings()
end)
MainTab:AddDropdown("Select Mastery Sword", GetToolNamesByTip("Sword"), _G.Settings.Main["Selected Mastery Sword"], function(v)
	_G.Settings.Main["Selected Mastery Sword"] = v
	SaveSettings()
end)
MainTab:AddToggle("Farm Mastery Sword", _G.Settings.Main["Farm Mastery Sword"], function(v)
	_G.Settings.Main["Farm Mastery Sword"] = v
	SaveSettings()
end)
MainTab:AddSlider("Kill Health Mastery", 5, 100, _G.Settings.Main["Kill Health Mastery"], function(v)
	_G.Settings.Main["Kill Health Mastery"] = v
	SaveSettings()
end)

MainTab:AddSection("Combat & Position")
MainTab:AddToggle("Auto Haki", _G.Settings.Main["Auto Haki"], function(v)
	_G.Settings.Main["Auto Haki"] = v
	SaveSettings()
end)
MainTab:AddToggle("Auto Observation", _G.Settings.Main["Auto Observation"], function(v)
	_G.Settings.Main["Auto Observation"] = v
	SaveSettings()
end)
MainTab:AddToggle("Auto Dodge", _G.Settings.Main["Auto Dodge"], function(v)
	_G.Settings.Main["Auto Dodge"] = v
	SaveSettings()
end)
MainTab:AddToggle("Auto Turn On V3", _G.Settings.Main["Auto Turn On V3"], function(v)
	_G.Settings.Main["Auto Turn On V3"] = v
	SaveSettings()
end)
MainTab:AddToggle("Auto Turn On V4", _G.Settings.Main["Auto Turn On V4"], function(v)
	_G.Settings.Main["Auto Turn On V4"] = v
	SaveSettings()
end)
MainTab:AddToggle("Bring Mob", _G.Settings.Main["Bring Mob"], function(v)
	_G.Settings.Main["Bring Mob"] = v
	SaveSettings()
end)
MainTab:AddSlider("Farm Distance", 5, 60, _G.Settings.Main["Farm Distance"], function(v)
	_G.Settings.Main["Farm Distance"] = v
	SaveSettings()
end)
MainTab:AddToggle("Spin Position", _G.Settings.Main["Spin Position"], function(v)
	_G.Settings.Main["Spin Position"] = v
	SaveSettings()
end)
MainTab:AddToggle("Fast Attack", _G.Settings.Main["Fast Attack"], function(v)
	_G.Settings.Main["Fast Attack"] = v
	SaveSettings()
end)

task.spawn(function()
	while task.wait(0.25) do
		pcall(function()
			local char = LocalPlayer.Character
			if _G.Settings.Main["Auto Haki"] and char and not char:FindFirstChild("HasBuso") then
				ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
			end
			if _G.Settings.Main["Auto Observation"] then
				ReplicatedStorage.Remotes.CommE:FireServer("Ken", true)
			end
			if _G.Settings.Main["Auto Turn On V3"] then
				ReplicatedStorage.Remotes.CommE:FireServer("ActivateAbility")
			end
			if _G.Settings.Main["Auto Turn On V4"] and char and char:FindFirstChild("RaceEnergy") and char.RaceEnergy.Value >= 1 then
				ReplicatedStorage.Remotes.CommE:FireServer("ActivateV4")
			end
		end)
	end
end)
local function GetMaterialCount(matName)
	local inv = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
	if not inv then return 0 end
	local ok, res = pcall(function()
		return inv:InvokeServer("getInventory")
	end)
	if ok and type(res) == "table" then
		for _, item in pairs(res) do
			if type(item) == "table" and (item.Name == matName or item.name == matName) then
				return item.Count or item.count or 1
			end
		end
	end
	return 0
end

local function HopServer()
	task.spawn(function()
		local ok, body = pcall(function()
			return game:HttpGet("https://games.roblox.com/v1/games/" .. tostring(placeId) .. "/servers/Public?sortOrder=Asc&limit=100")
		end)
		if ok and body then
			local data = HttpService:JSONDecode(body)
			for _, srv in ipairs(data.data or {}) do
				if srv.id ~= game.JobId and srv.playing < srv.maxPlayers then
					TeleportService:TeleportToPlaceInstance(placeId, srv.id, LocalPlayer)
					break
				end
			end
		end
	end)
end

FarmingTab:AddSection("Sea 2 & Sea 3 Farming")
FarmingTab:AddToggle("Auto Elite Hunter", _G.Settings.Farming["Auto Elite Hunter"], function(v)
	_G.Settings.Farming["Auto Elite Hunter"] = v
	SaveSettings()
end)
FarmingTab:AddToggle("Hop Server Elite", _G.Settings.Farming["Hop Server Elite"], function(v)
	_G.Settings.Farming["Hop Server Elite"] = v
	SaveSettings()
end)
FarmingTab:AddToggle("Auto Farm Bone", _G.Settings.Farming["Auto Farm Bone"], function(v)
	_G.Settings.Farming["Auto Farm Bone"] = v
	SaveSettings()
end)
FarmingTab:AddToggle("Auto Random Surprise", _G.Settings.Farming["Auto Random Surprise"], function(v)
	_G.Settings.Farming["Auto Random Surprise"] = v
	SaveSettings()
end)
FarmingTab:AddToggle("Auto Pirate Raid", _G.Settings.Farming["Auto Pirate Raid"], function(v)
	_G.Settings.Farming["Auto Pirate Raid"] = v
	SaveSettings()
end)
FarmingTab:AddToggle("Auto Observation V2", _G.Settings.Farming["Auto Observation V2"], function(v)
	_G.Settings.Farming["Auto Observation V2"] = v
	SaveSettings()
end)
FarmingTab:AddToggle("Auto Musketeer Hat", _G.Settings.Farming["Auto Musketeer Hat"], function(v)
	_G.Settings.Farming["Auto Musketeer Hat"] = v
	SaveSettings()
end)
FarmingTab:AddToggle("Auto Saber", _G.Settings.Farming["Auto Saber"], function(v)
	_G.Settings.Farming["Auto Saber"] = v
	SaveSettings()
end)

FarmingTab:AddSection("Chest & Cake Prince")
FarmingTab:AddDropdown("Chest Mode", {"Tween", "Instant", "Hop", "Mirage Island"}, _G.Settings.Farming["Chest Mode"], function(v)
	_G.Settings.Farming["Chest Mode"] = v
	SaveSettings()
end)
FarmingTab:AddToggle("Auto Farm Chest", _G.Settings.Farming["Auto Farm Chest"], function(v)
	_G.Settings.Farming["Auto Farm Chest"] = v
	SaveSettings()
end)
FarmingTab:AddToggle("Auto Cake Prince", _G.Settings.Farming["Auto Cake Prince"], function(v)
	_G.Settings.Farming["Auto Cake Prince"] = v
	SaveSettings()
end)
FarmingTab:AddToggle("Auto Dough King", _G.Settings.Farming["Auto Dough King"], function(v)
	_G.Settings.Farming["Auto Dough King"] = v
	SaveSettings()
end)

FarmingTab:AddSection("Sea Events & Mythical Weapons")
FarmingTab:AddToggle("Auto Sea Beast", _G.Settings.Farming["Auto Sea Beast"], function(v)
	_G.Settings.Farming["Auto Sea Beast"] = v
	SaveSettings()
end)
FarmingTab:AddToggle("Auto Terror Shark", _G.Settings.Farming["Auto Terror Shark"], function(v)
	_G.Settings.Farming["Auto Terror Shark"] = v
	SaveSettings()
end)
FarmingTab:AddToggle("Auto Shark", _G.Settings.Farming["Auto Shark"], function(v)
	_G.Settings.Farming["Auto Shark"] = v
	SaveSettings()
end)
FarmingTab:AddToggle("Auto Piranha", _G.Settings.Farming["Auto Piranha"], function(v)
	_G.Settings.Farming["Auto Piranha"] = v
	SaveSettings()
end)
FarmingTab:AddToggle("Auto Fish Boat", _G.Settings.Farming["Auto Fish Boat"], function(v)
	_G.Settings.Farming["Auto Fish Boat"] = v
	SaveSettings()
end)
FarmingTab:AddToggle("Auto Ghost Ship", _G.Settings.Farming["Auto Ghost Ship"], function(v)
	_G.Settings.Farming["Auto Ghost Ship"] = v
	SaveSettings()
end)
FarmingTab:AddToggle("Auto Tushita", _G.Settings.Farming["Auto Tushita"], function(v)
	_G.Settings.Farming["Auto Tushita"] = v
	SaveSettings()
end)
FarmingTab:AddToggle("Auto Yama", _G.Settings.Farming["Auto Yama"], function(v)
	_G.Settings.Farming["Auto Yama"] = v
	SaveSettings()
end)
FarmingTab:AddToggle("Auto Soul Guitar", _G.Settings.Farming["Auto Soul Guitar"], function(v)
	_G.Settings.Farming["Auto Soul Guitar"] = v
	SaveSettings()
end)
FarmingTab:AddToggle("Auto Cursed Dual Katana", _G.Settings.Farming["Auto Cursed Dual Katana"], function(v)
	_G.Settings.Farming["Auto Cursed Dual Katana"] = v
	SaveSettings()
end)

task.spawn(function()
	while task.wait(0.35) do
		pcall(function()
			local char = LocalPlayer.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if not hrp then return end

			if _G.Settings.Farming["Auto Farm Chest"] then
				local chest
				for _, obj in ipairs(workspace:GetDescendants()) do
					if obj:IsA("BasePart") and (obj.Name:find("Chest") or obj.Name:find("chest")) then
						chest = obj
						break
					end
				end
				if chest then
					if _G.Settings.Farming["Chest Mode"] == "Instant" then
						hrp.CFrame = chest.CFrame
					else
						MoveToCFrame(chest.CFrame * CFrame.new(0, 2, 0))
					end
				elseif _G.Settings.Farming["Chest Mode"] == "Hop" then
					HopServer()
				end
			end

			if _G.Settings.Farming["Auto Farm Bone"] or _G.Settings.Farming["Auto Random Surprise"] then
				if _G.Settings.Farming["Auto Random Surprise"] then
					ReplicatedStorage.Remotes.CommF_:InvokeServer("Bones", "Buy", 1, 1)
				end
				if _G.Settings.Farming["Auto Farm Bone"] then
					local enemies = workspace:FindFirstChild("Enemies")
					if enemies then
						for _, mob in ipairs(enemies:GetChildren()) do
							if mob.Name:find("Reborn Skeleton") or mob.Name:find("Living Zombie") or mob.Name:find("Demonic Soul") or mob.Name:find("Posessed Mummy") then
								local hum = mob:FindFirstChildOfClass("Humanoid")
								local root = mob:FindFirstChild("HumanoidRootPart")
								if hum and hum.Health > 0 and root then
									EquipWeaponByType(_G.Settings.Main["Selected Weapon"])
									MoveToCFrame(root.CFrame * CFrame.new(0, _G.Settings.Main["Farm Distance"], 0))
									AttackTarget(root)
									break
								end
							end
						end
					end
				end
			end

			if _G.Settings.Farming["Auto Elite Hunter"] then
				local eliteNames = {"Diablo", "Deandre", "Urban"}
				local foundElite
				local enemies = workspace:FindFirstChild("Enemies")
				if enemies then
					for _, mob in ipairs(enemies:GetChildren()) do
						for _, en in ipairs(eliteNames) do
							if mob.Name:find(en) then
								local hum = mob:FindFirstChildOfClass("Humanoid")
								local root = mob:FindFirstChild("HumanoidRootPart")
								if hum and hum.Health > 0 and root then
									foundElite = {mob = mob, root = root}
									break
								end
							end
						end
						if foundElite then break end
					end
				end
				if foundElite then
					ReplicatedStorage.Remotes.CommF_:InvokeServer("EliteHunter")
					EquipWeaponByType(_G.Settings.Main["Selected Weapon"])
					MoveToCFrame(foundElite.root.CFrame * CFrame.new(0, _G.Settings.Main["Farm Distance"], 0))
					AttackTarget(foundElite.root)
				elseif _G.Settings.Farming["Hop Server Elite"] then
					HopServer()
				end
			end

			if _G.Settings.Farming["Auto Pirate Raid"] then
				local enemies = workspace:FindFirstChild("Enemies")
				if enemies then
					for _, mob in ipairs(enemies:GetChildren()) do
						if mob.Name:find("Pirate") or mob.Name:find("Brigade") then
							local hum = mob:FindFirstChildOfClass("Humanoid")
							local root = mob:FindFirstChild("HumanoidRootPart")
							if hum and hum.Health > 0 and root then
								EquipWeaponByType(_G.Settings.Main["Selected Weapon"])
								MoveToCFrame(root.CFrame * CFrame.new(0, _G.Settings.Main["Farm Distance"], 0))
								AttackTarget(root)
								break
							end
						end
					end
				end
			end

			if _G.Settings.Farming["Auto Observation V2"] then
				ReplicatedStorage.Remotes.CommF_:InvokeServer("KenTalk", "Start")
			end
			if _G.Settings.Farming["Auto Musketeer Hat"] then
				ReplicatedStorage.Remotes.CommF_:InvokeServer("BartiloQuestProgress", "Bartilo")
			end
			if _G.Settings.Farming["Auto Saber"] then
				ReplicatedStorage.Remotes.CommF_:InvokeServer("ProHGQuestProgress", "Begin")
			end

			if _G.Settings.Farming["Auto Cake Prince"] or _G.Settings.Farming["Auto Dough King"] then
				local targetBoss = _G.Settings.Farming["Auto Dough King"] and "Dough King" or "Cake Prince"
				local enemies = workspace:FindFirstChild("Enemies")
				local bossObj
				if enemies then
					for _, mob in ipairs(enemies:GetChildren()) do
						if mob.Name:find(targetBoss) then
							local hum = mob:FindFirstChildOfClass("Humanoid")
							local root = mob:FindFirstChild("HumanoidRootPart")
							if hum and hum.Health > 0 and root then
								bossObj = root
								break
							end
						end
					end
				end
				if bossObj then
					EquipWeaponByType(_G.Settings.Main["Selected Weapon"])
					MoveToCFrame(bossObj.CFrame * CFrame.new(0, _G.Settings.Main["Farm Distance"], 0))
					AttackTarget(bossObj)
				else
					ReplicatedStorage.Remotes.CommF_:InvokeServer("CakePrinceSpawner")
				end
			end

			local seaTargets = {}
			if _G.Settings.Farming["Auto Sea Beast"] then table.insert(seaTargets, "SeaBeast") end
			if _G.Settings.Farming["Auto Terror Shark"] then table.insert(seaTargets, "Terrorshark") end
			if _G.Settings.Farming["Auto Shark"] then table.insert(seaTargets, "Shark") end
			if _G.Settings.Farming["Auto Piranha"] then table.insert(seaTargets, "Piranha") end
			if _G.Settings.Farming["Auto Fish Boat"] then table.insert(seaTargets, "FishBoat") end
			if _G.Settings.Farming["Auto Ghost Ship"] then table.insert(seaTargets, "GhostShip") end

			if #seaTargets > 0 then
				local seaFolder = workspace:FindFirstChild("SeaBeasts") or workspace:FindFirstChild("Enemies")
				if seaFolder then
					for _, obj in ipairs(seaFolder:GetChildren()) do
						for _, key in ipairs(seaTargets) do
							if obj.Name:find(key) then
								local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
								if root then
									EquipWeaponByType(_G.Settings.Main["Selected Weapon"])
									MoveToCFrame(root.CFrame * CFrame.new(0, 35, 0))
									AttackTarget(root)
									break
								end
							end
						end
					end
				end
			end

			if _G.Settings.Farming["Auto Tushita"] then
				ReplicatedStorage.Remotes.CommF_:InvokeServer("TushitaProgress", "Check")
			end
			if _G.Settings.Farming["Auto Yama"] then
				ReplicatedStorage.Remotes.CommF_:InvokeServer("YamaQuest", "Check")
			end
			if _G.Settings.Farming["Auto Soul Guitar"] then
				ReplicatedStorage.Remotes.CommF_:InvokeServer("GuitarPuzzleProgress", "Check")
			end

			if _G.Settings.Farming["Auto Cursed Dual Katana"] then
				local fragCount = GetMaterialCount("Alucard Fragment")
				if fragCount < 6 then
					ReplicatedStorage.Remotes.CommF_:InvokeServer("CDKQuest", "StartTrial", "Tushita")
					ReplicatedStorage.Remotes.CommF_:InvokeServer("CDKQuest", "StartTrial", "Yama")
				else
					ReplicatedStorage.Remotes.CommF_:InvokeServer("CDKQuest", "OpenDoor")
				end
			end
		end)
	end
end)
ItemsTab:AddSection("Fighting Styles")
ItemsTab:AddToggle("Auto Superhuman", _G.Settings.Items["Auto Superhuman"], function(v)
	_G.Settings.Items["Auto Superhuman"] = v
	SaveSettings()
end)
ItemsTab:AddToggle("Auto Death Step", _G.Settings.Items["Auto Death Step"], function(v)
	_G.Settings.Items["Auto Death Step"] = v
	SaveSettings()
end)
ItemsTab:AddToggle("Auto Sharkman Karate", _G.Settings.Items["Auto Sharkman Karate"], function(v)
	_G.Settings.Items["Auto Sharkman Karate"] = v
	SaveSettings()
end)
ItemsTab:AddToggle("Auto Electric Claw", _G.Settings.Items["Auto Electric Claw"], function(v)
	_G.Settings.Items["Auto Electric Claw"] = v
	SaveSettings()
end)
ItemsTab:AddToggle("Auto Dragon Talon", _G.Settings.Items["Auto Dragon Talon"], function(v)
	_G.Settings.Items["Auto Dragon Talon"] = v
	SaveSettings()
end)
ItemsTab:AddToggle("Auto Godhuman", _G.Settings.Items["Auto Godhuman"], function(v)
	_G.Settings.Items["Auto Godhuman"] = v
	SaveSettings()
end)

ItemsTab:AddSection("Swords & Guns")
ItemsTab:AddToggle("Auto Rengoku", _G.Settings.Items["Auto Rengoku"], function(v)
	_G.Settings.Items["Auto Rengoku"] = v
	SaveSettings()
end)
ItemsTab:AddToggle("Auto Midnight Blade", _G.Settings.Items["Auto Midnight Blade"], function(v)
	_G.Settings.Items["Auto Midnight Blade"] = v
	SaveSettings()
end)
ItemsTab:AddToggle("Auto Buddy Sword", _G.Settings.Items["Auto Buddy Sword"], function(v)
	_G.Settings.Items["Auto Buddy Sword"] = v
	SaveSettings()
end)
ItemsTab:AddToggle("Auto Canvander", _G.Settings.Items["Auto Canvander"], function(v)
	_G.Settings.Items["Auto Canvander"] = v
	SaveSettings()
end)
ItemsTab:AddToggle("Auto Kabucha", _G.Settings.Items["Auto Kabucha"], function(v)
	_G.Settings.Items["Auto Kabucha"] = v
	SaveSettings()
end)
ItemsTab:AddToggle("Auto Pole", _G.Settings.Items["Auto Pole"], function(v)
	_G.Settings.Items["Auto Pole"] = v
	SaveSettings()
end)

task.spawn(function()
	while task.wait(0.5) do
		pcall(function()
			local commF = ReplicatedStorage.Remotes.CommF_
			if _G.Settings.Items["Auto Superhuman"] then commF:InvokeServer("BuySuperhuman") end
			if _G.Settings.Items["Auto Death Step"] then commF:InvokeServer("BuyDeathStep") end
			if _G.Settings.Items["Auto Sharkman Karate"] then commF:InvokeServer("BuySharkmanKarate") end
			if _G.Settings.Items["Auto Electric Claw"] then commF:InvokeServer("BuyElectricClaw") end
			if _G.Settings.Items["Auto Dragon Talon"] then commF:InvokeServer("BuyDragonTalon") end
			if _G.Settings.Items["Auto Godhuman"] then commF:InvokeServer("BuyGodhuman") end
			if _G.Settings.Items["Auto Rengoku"] then commF:InvokeServer("RengokuQuest", "Progress") end
			if _G.Settings.Items["Auto Midnight Blade"] then commF:InvokeServer("Ectoplasm", "Buy", 1) end
			if _G.Settings.Items["Auto Buddy Sword"] then commF:InvokeServer("CakePrinceSpawner") end
			if _G.Settings.Items["Auto Canvander"] then commF:InvokeServer("CanvanderQuest") end
			if _G.Settings.Items["Auto Kabucha"] then commF:InvokeServer("BlackbeardReward", "Item", "2") end
			if _G.Settings.Items["Auto Pole"] then commF:InvokeServer("ThunderGodQuest") end
		end)
	end
end)

SettingTab:AddSection("Performance & Client")
SettingTab:AddToggle("White Screen", _G.Settings.Setting["White Screen"], function(v)
	_G.Settings.Setting["White Screen"] = v
	SaveSettings()
	RunService:Set3dRenderingEnabled(not v)
end)
SettingTab:AddToggle("Remove Effect", _G.Settings.Setting["Remove Effect"], function(v)
	_G.Settings.Setting["Remove Effect"] = v
	SaveSettings()
	if v then
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
				obj.Enabled = false
			end
		end
	end
end)
SettingTab:AddToggle("Remove Monster", _G.Settings.Setting["Remove Monster"], function(v)
	_G.Settings.Setting["Remove Monster"] = v
	SaveSettings()
end)
SettingTab:AddToggle("Auto Rejoin", _G.Settings.Setting["Auto Rejoin"], function(v)
	_G.Settings.Setting["Auto Rejoin"] = v
	SaveSettings()
end)
SettingTab:AddToggle("Anti AFK", _G.Settings.Setting["Anti AFK"], function(v)
	_G.Settings.Setting["Anti AFK"] = v
	SaveSettings()
end)
SettingTab:AddButton("Save Settings", function()
	SaveSettings()
end)

LocalPlayer.Idled:Connect(function()
	if _G.Settings.Setting["Anti AFK"] then
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new())
	end
end)

game:GetService("GuiService").ErrorMessageChanged:Connect(function()
	if _G.Settings.Setting["Auto Rejoin"] then
		TeleportService:Teleport(placeId, LocalPlayer)
	end
end)

LocalPlayerTab:AddSection("Movement & Physics")
LocalPlayerTab:AddSlider("WalkSpeed", 16, 200, 16, function(v)
	local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum.WalkSpeed = v end
end)
LocalPlayerTab:AddSlider("JumpPower", 50, 250, 50, function(v)
	local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum.JumpPower = v end
end)
local noclipEnabled = false
LocalPlayerTab:AddToggle("No Clip", false, function(v)
	noclipEnabled = v
end)
RunService.Stepped:Connect(function()
	if noclipEnabled and LocalPlayer.Character then
		for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = false end
		end
	end
end)
local holdSkillEnabled = false
HoldSkillTab:AddSection("Auto Hold Skills")
HoldSkillTab:AddToggle("Hold Z / X / C / V", false, function(v)
	holdSkillEnabled = v
end)
task.spawn(function()
	local vim = game:GetService("VirtualInputManager")
	local keys = {Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.V}
	while task.wait(0.4) do
		if holdSkillEnabled then
			for _, k in ipairs(keys) do
				pcall(function()
					vim:SendKeyEvent(true, k, false, game)
					task.wait(0.15)
					vim:SendKeyEvent(false, k, false, game)
				end)
			end
		end
	end
end)

SeaEventTab:AddSection("Sea Event Controls")
SeaEventTab:AddButton("TP To Sea Event Zone", function()
	local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if hrp then
		MoveToCFrame(CFrame.new(-35000, 35, -35000))
	end
end)

StackSeaTab:AddSection("Stack Sea Farm")
StackSeaTab:AddToggle("Auto Stack Sea", false, function(v)
	_G.Settings.Farming["Auto Sea Beast"] = v
	_G.Settings.Farming["Auto Terror Shark"] = v
	_G.Settings.Farming["Auto Shark"] = v
	_G.Settings.Farming["Auto Piranha"] = v
	SaveSettings()
end)

CraftsTab:AddSection("Material & Scroll Crafting")
CraftsTab:AddButton("Craft Mythical Scroll", function()
	pcall(function()
		ReplicatedStorage.Remotes.CommF_:InvokeServer("CraftScroll", "Mythical")
	end)
end)
CraftsTab:AddButton("Craft Leviathan Shield", function()
	pcall(function()
		ReplicatedStorage.Remotes.CommF_:InvokeServer("CraftItem", "LeviathanShield")
	end)
end)

DragonDojoTab:AddSection("Dragon Dojo")
DragonDojoTab:AddButton("Talk Dragon Hunter / Dojo", function()
	pcall(function()
		ReplicatedStorage.Remotes.CommF_:InvokeServer("DragonDojo", "Check")
	end)
end)

RaceV4Tab:AddSection("Race V4")
RaceV4Tab:AddButton("Train Race V4", function()
	pcall(function()
		ReplicatedStorage.Remotes.CommF_:InvokeServer("RaceV4Progress", "Check")
	end)
end)

CombatTab:AddSection("PvP / Combat")
CombatTab:AddToggle("Auto Aura / Ken Spam", false, function(v)
	_G.Settings.Main["Auto Haki"] = v
	_G.Settings.Main["Auto Observation"] = v
	SaveSettings()
end)

RaidTab:AddSection("Law & Factory / Chip Raid")
RaidTab:AddButton("Buy MicroChip (Law / Raid)", function()
	pcall(function()
		ReplicatedStorage.Remotes.CommF_:InvokeServer("RaidsNpc", "Select", "Flame")
	end)
end)
local espFolder = Instance.new("Folder")
espFolder.Name = "NightHubESP"
espFolder.Parent = game:GetService("CoreGui")

local function ClearESP()
	for _, v in ipairs(espFolder:GetChildren()) do
		v:Destroy()
	end
end

local function CreateESPTag(adornee, text, color)
	if not adornee or not adornee:IsA("BasePart") then return end
	local tag = espFolder:FindFirstChild(adornee:GetDebugId()) or Instance.new("BillboardGui")
	tag.Name = adornee:GetDebugId()
	tag.Adornee = adornee
	tag.Size = UDim2.new(0, 140, 0, 26)
	tag.AlwaysOnTop = true
	tag.Parent = espFolder

	local lbl = tag:FindFirstChildOfClass("TextLabel") or Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.TextStrokeTransparency = 0
	lbl.TextColor3 = color or Color3.fromRGB(255, 255, 255)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 12
	local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	local dist = hrp and math.floor((hrp.Position - adornee.Position).Magnitude) or 0
	lbl.Text = string.format("%s [%dm]", text, dist)
	lbl.Parent = tag
end

EspTab:AddSection("Visual ESP")
for key, val in pairs(_G.Settings.ESP) do
	EspTab:AddToggle(key, val, function(v)
		_G.Settings.ESP[key] = v
		SaveSettings()
		if not v then ClearESP() end
	end)
end

task.spawn(function()
	while task.wait(0.75) do
		local anyEsp = false
		for _, v in pairs(_G.Settings.ESP) do
			if v then anyEsp = true break end
		end
		if anyEsp then
			pcall(function()
				if _G.Settings.ESP["ESP Player"] then
					for _, plr in ipairs(Players:GetPlayers()) do
						if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
							CreateESPTag(plr.Character.HumanoidRootPart, plr.Name, Color3.fromRGB(255, 80, 120))
						end
					end
				end
				if _G.Settings.ESP["ESP Monster"] then
					local enemies = workspace:FindFirstChild("Enemies")
					if enemies then
						for _, mob in ipairs(enemies:GetChildren()) do
							local root = mob:FindFirstChild("HumanoidRootPart")
							local hum = mob:FindFirstChildOfClass("Humanoid")
							if root and hum and hum.Health > 0 then
								CreateESPTag(root, mob.Name, Color3.fromRGB(255, 200, 70))
							end
						end
					end
				end
				if _G.Settings.ESP["ESP Chest"] then
					for _, obj in ipairs(workspace:GetDescendants()) do
						if obj:IsA("BasePart") and obj.Name:find("Chest") then
							CreateESPTag(obj, obj.Name, Color3.fromRGB(255, 235, 100))
						end
					end
				end
				if _G.Settings.ESP["ESP DevilFruit"] or _G.Settings.ESP["ESP RealFruit"] then
					for _, obj in ipairs(workspace:GetChildren()) do
						if obj:IsA("Tool") and obj:FindFirstChild("Handle") then
							CreateESPTag(obj.Handle, obj.Name, Color3.fromRGB(140, 255, 160))
						end
					end
				end
			end)
		end
	end
end)

local IslandCoords = {
	["Starter Island"] = CFrame.new(1071, 16, 1426),
	["Marine Fortress"] = CFrame.new(-2694, 24, 2055),
	["Kingdom of Rose"] = CFrame.new(-390, 73, 297),
	["Cafe"] = CFrame.new(-382, 73, 298),
	["Port Town"] = CFrame.new(-290, 44, 5580),
	["Hydra Island"] = CFrame.new(5228, 604, 345),
	["Mansion"] = CFrame.new(-12463, 375, -7551)
}
local islandList = {}
for name in pairs(IslandCoords) do table.insert(islandList, name) end

TeleportTab:AddSection("Island & Sea Travel")
TeleportTab:AddDropdown("Select Island", islandList, _G.Settings.Teleport["Selected Island"], function(v)
	_G.Settings.Teleport["Selected Island"] = v
	SaveSettings()
end)
TeleportTab:AddButton("Teleport To Island", function()
	local cf = IslandCoords[_G.Settings.Teleport["Selected Island"]]
	if cf then MoveToCFrame(cf) end
end)
TeleportTab:AddButton("Travel To Sea 1", function()
	ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelMain")
end)
TeleportTab:AddButton("Travel To Sea 2", function()
	ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelDressrosa")
end)
TeleportTab:AddButton("Travel To Sea 3", function()
	ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelZou")
end)

ShopTab:AddSection("Abilities & Haki")
ShopTab:AddButton("Buy Geppo (Sky Jump)", function()
	ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyHaki", "Geppo")
end)
ShopTab:AddButton("Buy Buso (Aura)", function()
	ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyHaki", "Buso")
end)
ShopTab:AddButton("Buy Soru (Flash Step)", function()
	ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyHaki", "Soru")
end)
ShopTab:AddButton("Buy Ken (Observation)", function()
	ReplicatedStorage.Remotes.CommF_:InvokeServer("KenTalk", "Buy")
end)

DevilFruitTab:AddSection("Random & Store Fruit")
DevilFruitTab:AddButton("Random Devil Fruit", function()
	ReplicatedStorage.Remotes.CommF_:InvokeServer("Cousin", "Buy")
end)
DevilFruitTab:AddButton("Store Fruit In Inventory", function()
	for _, container in ipairs({LocalPlayer.Character, LocalPlayer:FindFirstChild("Backpack")}) do
		if container then
			for _, tool in ipairs(container:GetChildren()) do
				if tool:IsA("Tool") and tool.Name:find("Fruit") then
					ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", tool.Name:gsub(" Fruit", "") .. "-" .. tool.Name:gsub(" Fruit", ""), tool)
				end
			end
		end
	end
end)

MiscTab:AddSection("World Events")
MiscTab:AddToggle("Auto Rip Indra", _G.Settings.Misc["Auto Rip Indra"], function(v)
	_G.Settings.Misc["Auto Rip Indra"] = v
	SaveSettings()
end)
MiscTab:AddToggle("Auto Law Raid", _G.Settings.Misc["Auto Law Raid"], function(v)
	_G.Settings.Misc["Auto Law Raid"] = v
	SaveSettings()
end)
MiscTab:AddToggle("Auto Factory", _G.Settings.Misc["Auto Factory"], function(v)
	_G.Settings.Misc["Auto Factory"] = v
	SaveSettings()
end)

ServerTab:AddSection("Server Actions")
ServerTab:AddButton("Hop Server", function()
	HopServer()
end)
ServerTab:AddButton("Rejoin Server", function()
	TeleportService:TeleportToPlaceInstance(placeId, game.JobId, LocalPlayer)
end)
