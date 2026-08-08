getgenv().Flags = Flags or {
	CombatCheck = false,
	BedDistanceFromPlayer = 10,

	AutoMachine = false,
	MachineDistanceFromPlayer = 10,
	Machines = {
		Selected = 'Weight Twists',
	},

	AutoTrainingTool = false,
	TrainingTools = {
		Selected = 'Handstand Pushup',

	},

	AutoTrainingEquipment = false,
	Equipments = {
		Selected = {},

	},

	ParryChance = 100,
	PingAdjustmentPercentage = 80,

	BobbingSpeed = 99999,
	TweenSpeed = 75,
	SpeedMultiplier = 0,
	ServerHopDelay = 0,
	WebHookDataSendDelay = 1800,
	KickOnStaff = false,

	AutomaticExecution = false,
	KickMessage = nil,
	WebHook = nil,
}

local HiddenFlags = {
	GameName = 'Ryujin',
	CurrentGameVersion = 0,
	Game = {
		Ignore = workspace.Ignore,
		JobsRelated = workspace.Ignore.Interactables.JobsRelated,
		JobBoards = workspace.Ignore.Interactables.JobsRelated["Job Borders"],
		VFXFolder = workspace.Ignore.VFX,
		NPCs = workspace.Ignore.NPCs,
		Roadworks = workspace.Ignore.Interactables.Roadworks,
		ATMs = workspace.Interactables.ATMs,
		Buyables = workspace.Ignore.Interactables.Buyables,
		Beds = workspace.Ignore.Interactables.Beds,
		BusStops = workspace.Map["Bus Stations"],
		Buildings = (function()
			local Folder = Instance.new('Folder')

			for i,v in workspace.Ignore.Zones:GetDescendants() do
				if not v:IsA('Part') then continue end
				if Folder:FindFirstChild(v.Name) then continue end

				local Cloned = v:Clone()
				Cloned.Parent = Folder
			end

			return Folder
		end)(),

		Trainings = workspace.Interactables.Trainings,

		TrainingsIndexed = (function()
			local Tbl = {}
			local Names = {'Weight Twists', 'Treadmills', 'Pullups', 'BenchPress', 'Barbell Squat'}

			for i,v in workspace.Interactables.Trainings:GetChildren() do
				if not v:IsA('Folder') then continue end
				
				local GangBase = workspace.Interactables.Trainings:FindFirstChild('Equipment')
				if GangBase and v == GangBase then continue end
				
				if not table.find(Names, v.Name) then continue end

				Tbl[v.Name] = v
			end

			return Names, Tbl
		end),
		
		Equipped = {
			['50KG Leg Weights'] = '50kg leg weights',
			['50KG Vest'] = '50kg vest',
			['25KG Leg Weights'] = '25kg leg weights',
			['25KG Vest'] = '25kg vest',
			['5KG Leg Weights'] = '5kg leg weights',
			['5KG Vest'] = '5kg vest',
			['Breathing Mask'] = 'breathing mask',
			['Blindfold'] = 'blindfold',
		},

		TrainingTools = {
			['Handstand Pushup'] = workspace.Ignore.Interactables.Buyables["Handstand Pushup"],
			['Jumping Jacks'] = workspace.Ignore.Interactables.Buyables["Jumping Jacks"],
			['Jumping Rope'] = workspace.Ignore.Interactables.Buyables["Jumping Rope"],
			['One Hand Pushups'] = workspace.Ignore.Interactables.Buyables["One Hand Pushups"],
			['Pushup'] = workspace.Ignore.Interactables.Buyables.Pushup,
			['Situp'] = workspace.Ignore.Interactables.Buyables.Situp,
			['Squat'] = workspace.Ignore.Interactables.Buyables.Squat,
		},
	},

	FloorLevel = 271,
	NormalLevel = 332,
	TargetGroup = 34758135,
	BlacklistedUIDs = {[4203884193] = 'gay femboy'},
	Connections = {},
	LastMachine = {},
	RemoteTimings = {}, -- Always check remotes
	Parts = {},
	UI = {},
	AttackAnims = {},
	RevertFunctions = {},
	DeInitFunctions = {},
	LastWebHookSentData = 0,
	Prompts = setmetatable({}, { __mode = 'kv' }), -- Always check prox prompts
	HighRank = {
		['Tester'] = true,
		['Content Creators Manager'] = true,
		['Moderator'] = true,
		['Assets Uploader'] = true,
		['Senior Moderator'] = true,
		['Admin'] = true,
		['Developer'] = true,
		['Birb'] = true,
		['Studio Developer'] = true,
		['Owner'] = true,
	},
	Thresholds = {
		FatigueMax = 90,
		HungerLow = 35,
		HungerHigh = 90,
		StaminaLow = 20,
		StaminaHigh = 90,

		MaxWallet = 1_000_000,
		MaxBank = 20_000_000,
		MinWallet = 10_000,
	},
	OriginalFunctions = {
		FireServer = Instance.new('RemoteEvent').FireServer,
		InvokeServer = Instance.new('RemoteFunction').InvokeServer
	},
}

local Services = setmetatable({}, {
	__index = function(self, key)
		if key == "Create" then
			local CreateTable = {}

			setmetatable(CreateTable, {
				__index = function(_, key)
					if not rawget(CreateTable, key) then
						local Object = Instance.new(key)
						rawset(CreateTable, key, Object)
					end

					return CreateTable[key]
				end
			})

			rawset(self, key, CreateTable)
			return CreateTable
		end

		local Service = cloneref(game:GetService(key))
		rawset(self, key, Service)
		return Service
	end
})

local UserInputService = Services.UserInputService
local TeleportService = Services.TeleportService
local Players = Services.Players
local Client = Players.LocalPlayer

local WaitingForClient = os.clock()
while not Client do -- Roblox is unstable
	Client = Players.LocalPlayer

	if os.clock() - WaitingForClient > 30 then
		TeleportService:Teleport(game.PlaceId)
		task.wait(5)
	end

	task.wait()
end

local GuiService = Services.GuiService
local CoreGui = Services.CoreGui
local HttpService = Services.HttpService
local RunService = Services.RunService
local ReplicatedStorage = Services.ReplicatedStorage
local VirtualInputManager = Services.Create.VirtualInputManager
local Stats = Services.Stats
local CollectionService = Services.CollectionService

if not LPH_OBFUSCATED then
	LPH_NO_VIRTUALIZE = function(...) return ... end
end

local PreGameConnections, OnTeleportHandler, Teleporter, GetNewServer, Serialize, EscapeString, TeleportInitFailedHandler, KickHandler, SendData = {}; do
	TeleportInitFailedHandler = function(Player)
		if (Player ~= Client or HiddenFlags.TeleportRetrying) then return end

		HiddenFlags.TeleportRetrying = true

		task.delay(5, function()
			TeleportService:Teleport(game.PlaceId)
			HiddenFlags.TeleportRetrying = false
		end)
	end

	EscapeString = function(s)
		return s:gsub("\\", "\\\\")
				:gsub("\n", "\\n")
				:gsub("\t", "\\t")
				:gsub("'", "\\'")
	end

	Serialize = function(Tbl, Indent)
		local Indent = Indent or 0
		local Pad = string.rep("    ", Indent)
		local Str = "{\n"

		for k, v in Tbl do
			local Key
			if type(k) == "string" and k:match("^[%a_][%w_]*$") then
				Key = k
			else
				Key = "[" .. tostring(k) .. "]"
			end

			if type(v) == "table" then
				Str ..= Pad .. "    " .. Key .. " = " .. Serialize(v, Indent + 1) .. ",\n"
			elseif type(v) == "string" then
				Str ..= Pad .. "    " .. Key .. " = '" .. EscapeString(v) .. "',\n"
			else
				Str ..= Pad .. "    " .. Key .. " = " .. tostring(v) .. ",\n"
			end
		end

		return Str .. Pad .. "}"
	end

	GetNewServer = function()
		local Request = httprequest or request

		if Request then
			local Servers = {}
			local Req = Request({Url = `https://games.roblox.com/v1/games/{game.PlaceId}/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true`})
			if not Req then return end
			local Body = HttpService:JSONDecode(Req.Body)

			if (Body and Body.data) then
				for i, v in (Body.data) do
					if (type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.id ~= game.JobId) then
						table.insert(Servers, 1, v.id)
					end
				end
			end

			if #Servers > 0 then
				return Servers[math.random(1, #Servers)]
			end
		end
	end

	Teleporter = function(SameServer)
		if (not HiddenFlags.Teleporting) then
			Client:Kick('etocats: rejoining...')
			HiddenFlags.Teleporting = true
			task.wait(Flags.ServerHopDelay)

			local Data = HiddenFlags.StatsData and HiddenFlags.StatsData.Value or ''
			SendData('🟡 Reconnecting...'..(Data ~= '' and '\n' or '')..Data)

			if SameServer then
				TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Client)
				return
			end

			local NewServer = GetNewServer()

			if (NewServer) then
				TeleportService:TeleportToPlaceInstance(game.PlaceId, NewServer, Client)
			else
				TeleportService:Teleport(game.PlaceId)
			end
		end
	end

	OnTeleportHandler = function()
		if (HiddenFlags.OnTeleportSet) then return end;

		HiddenFlags.OnTeleportSet = true;
		Flags.AutomaticExecution = true
		local FinalString = "if Flags then return end getgenv().Flags = " .. Serialize(Flags) .. "\n"

		if (queue_on_teleport) then
			if LPH_OBFUSCATED then
				queue_on_teleport(FinalString .. "\nloadstring(game:HttpGet('https://r2.cathost.org/v2.cacheLayer.lua'))('" .. shared.key .. "')")
			else
				queue_on_teleport(FinalString .. "\nloadstring(game:HttpGet('https://gist.githubusercontent.com/broreallyplayingthisgame/d01c45572657bea4a0daf277f6ba4438/raw/b.lua'))()")
			end
		end
	end

	KickHandler = function()
		local ErrorCode = GuiService:GetErrorCode();
		if ErrorCode == Enum.ConnectionError.OK then return end;
		HiddenFlags.Kicked = true

		local Message = GuiService:GetErrorMessage()

		if not Message:find('etocats: rejoining...') then
			Flags.KickMessage = Message
		end

		Teleporter()
	end

	SendData = function(data)
		if not Flags.WebHook then return end

		local data = {
			["username"] = "Fistborn | etocats",
			["content"] = "Alert!",
			["embeds"] = {
				{
					["title"] = "**etocats**",
					["description"] = `{data}`,
					["type"] = "rich",
					["color"] = tonumber(0x7269da),
				}
			}
		}

		local newdata = HttpService:JSONEncode(data)

		local headers = {["content-type"] = "application/json"}
		local webhook = {Url = Flags.WebHook, Body = newdata, Method = "POST", Headers = headers}
		request = http_request or request or HttpPost or syn.request

		request(webhook)
	end

	local emoji = (function()
		local Year = tonumber(os.date("%Y"))
		local MonthDay = os.date("%m %d")

		-- leap year check
		local IsLeap = (Year % 4 == 0 and (Year % 100 ~= 0 or Year % 400 == 0))

		local Dates = {
			["01 01"] = "🎆",
			["10 31"] = "🎃",
			["12 25"] = "🎄",
		}

		-- Easter calculation
		do
			local A = math.floor(Year / 100)
			local B = math.floor((13 + 8 * A) / 25)
			local C = (15 - B + A - math.floor(A / 4)) % 30
			local D = (4 + A - math.floor(A / 4)) % 7
			local E = (19 * (Year % 19) + C) % 30
			local F = (2 * (Year % 4) + 4 * (Year % 7) + 6 * E + D) % 7
			local G = (22 + E + F)
			local Easter
			if E == 29 and F == 6 then
				Easter = "04 19"
			elseif E == 28 and F == 6 then
				Easter = "04 18"
			elseif G > 31 then
				Easter = ("04 %02d"):format(G - 31)
			else
				Easter = ("03 %02d"):format(G)
			end
			Dates[Easter] = "🥚"
		end

		-- Leap year addition
		if IsLeap then
			Dates["02 29"] = "🐸"
		end

		return Dates[MonthDay]
	end)()
	HiddenFlags.ScriptTitle = string.format(`%s etocats %s`, emoji or '', emoji or '')

	PreGameConnections.TeleportInitFailed = TeleportService.TeleportInitFailed:Connect(TeleportInitFailedHandler)
	PreGameConnections.OnTeleport = Client.OnTeleport:Connect(OnTeleportHandler)
	PreGameConnections.KickChecker = GuiService.ErrorMessageChanged:Connect(KickHandler);
	if GuiService:GetErrorCode() ~= Enum.ConnectionError.OK then
		KickHandler()
	end
end

shared.etocats_reload_id = (shared.etocats_reload_id or 0) + 1
local this_id = shared.etocats_reload_id

if shared.etocats then
	shared.etocats = false

	while shared.etocats_active do
		if this_id ~= shared.etocats_reload_id then return end

		task.wait()
	end
end

if this_id ~= shared.etocats_reload_id then return end
shared.etocats = true
shared.etocats_active = true

while not game:IsLoaded() do task.wait() end

game:HttpGet('https://gist.githubusercontent.com/afyzone/4fbea06d5894653c7bb9a3551433a33a/raw/fistcheck.lua')
local Library = loadstring(game:HttpGet("https://github.com/afyzone/scriptsold/releases/download/fistborn-1/Fluent.luau"))()
local SaveManager = loadstring(game:HttpGet("https://github.com/afyzone/scriptsold/releases/download/fistborn-1/SaveManager.luau"))()
local InterfaceManager = loadstring(game:HttpGet("https://github.com/afyzone/scriptsold/releases/download/fistborn-1/InterfaceManager.luau"))()

local PlayerGui = Client:WaitForChild('PlayerGui')
local Camera = workspace:FindFirstChild('Camera')
local Utility = require(ReplicatedStorage.Modules.Shared.Utility)
local ClientProcess = require(ReplicatedStorage.Packages._Index["imezx_warp@1.0.9"].warp.Index.Client.ClientProcess)

local GetRoot, GetHum, ClickButton, SmartWait, IncrementalMove, MoveTo, InCombat, CombatCheck,
	IsPlayerNearModel, Withdraw, Deposit, CheckEnoughMoney, GetBed, FormatNumber, FormatElapsed,
	IsFarmingActive, GetCollectiveMoney, CalculateTotalPower, EnsureSession, EndSession, GetPlusDelta, StatViewHandler,
	HandleSession, HandleNoClip, HandleResetPosition, StateHandler, GetOffBed, SteppedLoop,
	MainMenuHandler, WalletHandler, PlayerAddedHandler, SetupAutoParry, ListenToChildRemoving,
	ListenToChildAdded, Maid, Signal, MultiBuy, TrainingEquipmentHandler, HungerHandler,
	GetDistance, GetDistanceXZ, Init, DeInit, GUIDestroying, HandleItem, CheckInventory,
	UserInterface, GetClosestInTable, OnNewCharacter, Block, CalculatePingWait, SpawnProtection,
	AutoCompleteKeyPressMinigame, GetClosestATM, GetOffMachine, MachineHandler,
	JobHandler, GetClosestJobPart, GetClosestJobBoard, GetBestJob, TrainingToolHandler, FatigueHandler,
	RoadworkHandler, AnswerDialogue, SafeProximityPrompt, GetWorkoutDrinkPart, PunchingBagHandler; do

	GetRoot = function(Char)
		return Char and Char:FindFirstChild('HumanoidRootPart')
	end

	GetHum = function(Char)
		return Char and Char:FindFirstChildWhichIsA('Humanoid')
	end

	Init = function()
		-- if game.PlaceVersion > HiddenFlags.CurrentGameVersion then
		-- 	Library:Notify{
		-- 		Title = 'Warning',
		-- 		Content = `Looks like the game updated, you should be cautious of what you use.`,
		-- 		SubContent = `Current Game Version {game.PlaceVersion}, Script Version {HiddenFlags.CurrentGameVersion}`,
		-- 		Duration = 15,
		-- 	}
		-- end

		UserInterface()
		HiddenFlags.Maid = Maid().new()
		HiddenFlags.ParryMaid = Maid().new()
		SaveManager:SetLibrary(Library)
		InterfaceManager:SetLibrary(Library)
		SaveManager:IgnoreThemeSettings()
		SaveManager:SetIgnoreIndexes{}
		InterfaceManager:SetFolder("etocats")
		SaveManager:SetFolder(`etocats/{HiddenFlags.GameName}`)
		InterfaceManager:BuildInterfaceSection(HiddenFlags.UI.Tabs.Settings)
		SaveManager:BuildConfigSection(HiddenFlags.UI.Tabs.Settings)
		HiddenFlags.UI.Window:SelectTab(1)
		SaveManager:LoadAutoloadConfig()

		for i,v in getgc and getgc(true) or {} do
			if typeof(v) == 'table' then
				local Camera = rawget(v, 'Camera')
				if not Camera then continue end
				if typeof(Camera) ~= 'RBXScriptConnection' then continue end

				Camera:Disconnect()
			end
		end

		HiddenFlags.Parts.FakeVisual = Instance.new('Part')
		HiddenFlags.Parts.FakeVisual.CanCollide = false
		HiddenFlags.Parts.FakeVisual.Parent = HiddenFlags.Game.Ignore
		HiddenFlags.Parts.FakeVisual.Size = vector.zero
		HiddenFlags.Parts.FakeVisual.Anchored = true
		HiddenFlags.Parts.FakeVisual.Transparency = 1

		task.delay(45, function()
			if (PlayerGui:FindFirstChild('LoadingScreen')) then
				Client:Kick('took too long to load')
			end
		end)

		-- Client.DevCameraOcclusionMode = "Invisicam"
		-- Client.CameraMaxZoomDistance = math.huge

		for i,v in getconnections and getconnections(Client.Idled) or {} do
			if v.Disable then
				HiddenFlags.AntiAFK = true
				v:Disable()
			elseif v.Disconnect then
				HiddenFlags.AntiAFK = true
				v:Disconnect()
			end
		end

		if not HiddenFlags.AntiAFK then
			HiddenFlags.AntiAFK = true
			HiddenFlags.Connections.AntiAFK = Client.Idled:Connect(function()
				VirtualInputManager:SendKeyEvent(false, 'Unknown', false, game)
			end)
		end

		local function NewAnimData(Name, Type, Anim, Additional)
			HiddenFlags.AttackAnims[Anim.AnimationId:match('%d+')] = {Name = Name, Type = Type, Additional = Additional or 0}
		end

		local IgnoreAnims = {'Block', 'Road', 'Mode', 'Weave', 'Victim', 'Camera', 'User', 'Pull', 'Grab'}
		local FolderIgnore = {'Dodges', 'Carrying', 'GettingHit', 'Gripping'}

		for i, Folder in ReplicatedStorage.Assets.Animations.Combats:GetChildren() do
			if not Folder:IsA('Folder') then continue end
			if table.find(FolderIgnore, Folder.Name) then continue end

			for i, Animation in Folder:GetChildren() do
				local Folder = Animation:IsA('Folder') and Animation

				for i, Skill in Folder and Folder:GetChildren() or {} do
					local Folder = Skill:IsA('Folder') and Skill

					for i, Animation in Folder and Folder:GetChildren() or {} do
						if not Animation:IsA('Animation') then continue end
						if table.find(IgnoreAnims, Animation.Name) then continue end

						NewAnimData(Animation.Name, 'Default', Animation)
					end

					if not Skill:IsA('Animation') then continue end
					if table.find(IgnoreAnims, Skill.Name) then continue end

					NewAnimData(Skill.Name, 'Default', Skill)
				end

				if not Animation:IsA('Animation') then continue end
				if table.find(IgnoreAnims, Animation.Name) then continue end

				if Animation.Name:find('Swing') then
					NewAnimData(Animation.Parent.Name .. ' ' .. Animation.Name, 'Normal', Animation)
				elseif Animation.Name:find('M2') then
					NewAnimData(Animation.Parent.Name .. ' ' .. Animation.Name, 'Default', Animation)
				elseif Animation.Name:find('Weave') then
					NewAnimData(Animation.Parent.Name .. ' ' .. Animation.Name, 'Default', Animation)
				else
					NewAnimData(Animation.Parent.Name .. ' ' .. Animation.Name, 'Default', Animation)
				end
			end
		end

		for i, Animation in ReplicatedStorage.Assets.Animations.Skills.Clans:GetDescendants() do
			if not Animation:IsA('Animation') then continue end
			if table.find(IgnoreAnims, Animation.Name) then continue end

			NewAnimData(Animation.Name, 'Default', Animation)
		end

		if not LPH_OBFUSCATED then
			local CombatAnims = {
				['95217543358297'] = { Name = "Activate"; Type = "Default"; Additional = 0; DashAway = false };
				['97060850970277'] = { Name = "Aikido M2"; Type = "Default"; Additional = 0; DashAway = false };
				['136415844058390'] = { Name = "Aikido Swing1"; Type = "Normal"; Additional = 0; DashAway = false };
				['70406457824238'] = { Name = "Aikido Swing2"; Type = "Normal"; Additional = 0; DashAway = false };
				['106876234087895'] = { Name = "Aikido Swing3"; Type = "Normal"; Additional = 0; DashAway = false };
				['73456532383949'] = { Name = "Aikido Swing4"; Type = "Normal"; Additional = 0; DashAway = false };
				['84295073320108'] = { Name = "Animal Instinct Roar"; Type = "Default"; Additional = 0; DashAway = false };
				['113578946511686'] = { Name = "Animal Instinct Swing1"; Type = "Normal"; Additional = 0; DashAway = false };
				['112589846589429'] = { Name = "Animal Instinct Swing2"; Type = "Normal"; Additional = 0; DashAway = false };
				['108411093151472'] = { Name = "Animal Instinct Swing3"; Type = "Normal"; Additional = 0; DashAway = false };
				['73776738048707'] = { Name = "Animal Instinct Swing4"; Type = "Normal"; Additional = 0; DashAway = false };
				['80033102878085'] = { Name = "Attempt"; Type = "Default"; Additional = 0; DashAway = false };
				['75982771132817'] = { Name = "Attempt"; Type = "Default"; Additional = 0; DashAway = false };
				['126264607876260'] = { Name = "Attempt"; Type = "Default"; Additional = 0; DashAway = false };
				['110466557767663'] = { Name = "Attempt"; Type = "Default"; Additional = 0; DashAway = false };
				['86785063758991'] = { Name = "AvidyÄ"; Type = "Default"; Additional = 0; DashAway = false };
				['87672206881031'] = { Name = "Balance Breaker Attempt"; Type = "Default"; Additional = 0; DashAway = false };
				['105130489677179'] = { Name = "Balance Breaker User"; Type = "Default"; Additional = 0; DashAway = false };
				['113025261718757'] = { Name = "Balance Breaker Victim"; Type = "Default"; Additional = 0; DashAway = false };
				['115390639381308'] = { Name = "Biting Dragon"; Type = "Default"; Additional = 0; DashAway = false };
				['105708111152012'] = { Name = "Biting Dragon1"; Type = "Default"; Additional = 0; DashAway = false };
				['81938263856245'] = { Name = "Biting Dragon2"; Type = "Default"; Additional = 0; DashAway = false };
				['125114637688214'] = { Name = "Blastcore"; Type = "Default"; Additional = 0; DashAway = false };
				['118074592030544'] = { Name = "Body Slam"; Type = "Default"; Additional = 0; DashAway = false };
				['132579207317110'] = { Name = "Boxing Corkscrew"; Type = "Default"; Additional = 0; DashAway = false };
				['105222862680633'] = { Name = "Boxing GazellePunch"; Type = "Default"; Additional = 0; DashAway = false };
				['124813745539275'] = { Name = "Boxing Jab"; Type = "Default"; Additional = 0; DashAway = false };
				['74979351299342'] = { Name = "Boxing M2"; Type = "Default"; Additional = 0; DashAway = false };
				['76760060885179'] = { Name = "Boxing Swing1"; Type = "Normal"; Additional = 0; DashAway = false };
				['85694744022045'] = { Name = "Boxing Swing2"; Type = "Normal"; Additional = 0; DashAway = false };
				['72686347262162'] = { Name = "Boxing Swing3"; Type = "Normal"; Additional = 0; DashAway = false };
				['109699141797719'] = { Name = "Boxing Swing4"; Type = "Normal"; Additional = 0; DashAway = false };
				['125301184610555'] = { Name = "Boxing TripleJab"; Type = "Default"; Additional = 0; DashAway = false };
				['116642918801150'] = { Name = "Boxing WeaveStart"; Type = "Default"; Additional = 0; DashAway = false };
				['132510364037786'] = { Name = "Boxing White Fang"; Type = "Default"; Additional = 0; DashAway = false };
				['90575367194550'] = { Name = "Breakpoint"; Type = "Default"; Additional = 0; DashAway = false };
				['85198317094528'] = { Name = "Buddha Killer"; Type = "Default"; Additional = 0; DashAway = false };
				['100892656742869'] = { Name = "Calf Kick"; Type = "Default"; Additional = 0; DashAway = false };
				['78289905030730'] = { Name = "Cast"; Type = "Default"; Additional = 0; DashAway = false };
				['93923292902009'] = { Name = "Circular Redirect"; Type = "Default"; Additional = 0; DashAway = false };
				['119727758198872'] = { Name = "Colossal Titan Stomp"; Type = "Default"; Additional = 0; DashAway = false };
				['125926465105122'] = { Name = "Colossal Titan Transform"; Type = "Default"; Additional = 0; DashAway = false };
				['18897918819'] = { Name = "Combat Swing1"; Type = "Normal"; Additional = 0; DashAway = false };
				['18897921992'] = { Name = "Combat Swing2"; Type = "Normal"; Additional = 0; DashAway = false };
				['18897924931'] = { Name = "Combat Swing3"; Type = "Normal"; Additional = 0; DashAway = false };
				['18897927306'] = { Name = "Combat Swing4"; Type = "Normal"; Additional = 0; DashAway = false };
				['113999940248559'] = { Name = "Cyclone Fang"; Type = "Default"; Additional = 0; DashAway = false };
				['94446910604376'] = { Name = "Cyclone Fang1"; Type = "Default"; Additional = 0; DashAway = false };
				['83185670349292'] = { Name = "Cyclone Fang2"; Type = "Default"; Additional = 0; DashAway = false };
				['72564209978608'] = { Name = "Cyclone Fang3"; Type = "Default"; Additional = 0; DashAway = false };
				['120702987855445'] = { Name = "Devil Lance"; Type = "Default"; Additional = 0; DashAway = false };
				['132989842687837'] = { Name = "Dream Walking Attempt"; Type = "Default"; Additional = 0; DashAway = false };
				['109836567779631'] = { Name = "Dream Walking User"; Type = "Default"; Additional = 0; DashAway = false };
				['135868689766808'] = { Name = "Dream Walking Victim"; Type = "Default"; Additional = 0; DashAway = false };
				['98617709831500'] = { Name = "Dropkick"; Type = "Default"; Additional = 0; DashAway = false };
				['101252141066492'] = { Name = "Fa Jin Attempt"; Type = "Default"; Additional = 0; DashAway = false };
				['74093991444418'] = { Name = "Fa Jin User"; Type = "Default"; Additional = 0; DashAway = false };
				['82349080885376'] = { Name = "Fa Jin Victim"; Type = "Default"; Additional = 0; DashAway = false };
				['122733525249924'] = { Name = "Flicker Jabs"; Type = "Default"; Additional = 0; DashAway = false };
				['122551145167008'] = { Name = "God Glow"; Type = "Default"; Additional = 0; DashAway = false };
				['134489438694743'] = { Name = "Heaven Fang"; Type = "Default"; Additional = 0; DashAway = false };
				['72391495649471'] = { Name = "Hug Attempt"; Type = "Default"; Additional = 0; DashAway = false };
				['97658112921664'] = { Name = "Hug User"; Type = "Default"; Additional = 0; DashAway = false };
				['136462128518221'] = { Name = "Hug Victim"; Type = "Default"; Additional = 0; DashAway = false };
				['98029988164085'] = { Name = "Inner Circle Attempt"; Type = "Default"; Additional = 0; DashAway = false };
				['95608948120416'] = { Name = "Inner Circle User"; Type = "Default"; Additional = 0; DashAway = false };
				['77251185555432'] = { Name = "Inner Circle Victim"; Type = "Default"; Additional = 0; DashAway = false };
				['122260796660865'] = { Name = "Jaw Breaker"; Type = "Default"; Additional = 0; DashAway = false };
				['135452049435473'] = { Name = "Karate M2"; Type = "Default"; Additional = 0; DashAway = false };
				['134869190500075'] = { Name = "Karate Swing1"; Type = "Normal"; Additional = 0; DashAway = false };
				['87702685166096'] = { Name = "Karate Swing2"; Type = "Normal"; Additional = 0; DashAway = false };
				['94308724434211'] = { Name = "Karate Swing3"; Type = "Normal"; Additional = 0; DashAway = false };
				['73173291297187'] = { Name = "Karate Swing4"; Type = "Normal"; Additional = 0; DashAway = false };
				['78297143422578'] = { Name = "Kick Boxing M2"; Type = "Default"; Additional = 0; DashAway = false };
				['112420930627378'] = { Name = "Kick Boxing Swing1"; Type = "Normal"; Additional = 0; DashAway = false };
				['121006234118988'] = { Name = "Kick Boxing Swing1_"; Type = "Normal"; Additional = 0; DashAway = false };
				['125709887999900'] = { Name = "Kick Boxing Swing2"; Type = "Normal"; Additional = 0; DashAway = false };
				['99401611395357'] = { Name = "Kick Boxing Swing3"; Type = "Normal"; Additional = 0; DashAway = false };
				['81368787750609'] = { Name = "Kick Boxing Swing4"; Type = "Normal"; Additional = 0; DashAway = false };
				['112678708736607'] = { Name = "Kick1"; Type = "Default"; Additional = 0; DashAway = false };
				['128987555984139'] = { Name = "Kick2"; Type = "Default"; Additional = 0; DashAway = false };
				['101202395190609'] = { Name = "Kungfu M2"; Type = "Default"; Additional = 0; DashAway = false };
				['91351721987178'] = { Name = "Kungfu Swing1"; Type = "Normal"; Additional = 0; DashAway = false };
				['105172785048226'] = { Name = "Kungfu Swing2"; Type = "Normal"; Additional = 0; DashAway = false };
				['79598993382442'] = { Name = "Kungfu Swing3"; Type = "Normal"; Additional = 0; DashAway = false };
				['135877149669593'] = { Name = "Kungfu Swing4"; Type = "Normal"; Additional = 0; DashAway = false };
				['76478997729092'] = { Name = "Kure Traditions M2"; Type = "Default"; Additional = 0; DashAway = false };
				['120305746250709'] = { Name = "Kure Traditions Swing1"; Type = "Normal"; Additional = 0; DashAway = false };
				['124112160893513'] = { Name = "Kure Traditions Swing2"; Type = "Normal"; Additional = 0; DashAway = false };
				['126408295132417'] = { Name = "Kure Traditions Swing3"; Type = "Normal"; Additional = 0; DashAway = false };
				['84411205304643'] = { Name = "Kure Traditions Swing4"; Type = "Normal"; Additional = 0; DashAway = false };
				['91751059302250'] = { Name = "Leg Crusher"; Type = "Default"; Additional = 0; DashAway = false };
				['106050546233587'] = { Name = "Lian-Jin Start"; Type = "Default"; Additional = 0; DashAway = false };
				['82386814771930'] = { Name = "Lian-Jin User"; Type = "Default"; Additional = 0; DashAway = false };
				['77769816875990'] = { Name = "Lian-Jin Victim"; Type = "Default"; Additional = 0; DashAway = false };
				['131702769242137'] = { Name = "Lightning Flash"; Type = "Default"; Additional = 0; DashAway = false };
				['98288918063152'] = { Name = "Lightning FlashOld"; Type = "Default"; Additional = 0; DashAway = false };
				['106995889656421'] = { Name = "Lion Bite"; Type = "Default"; Additional = 0; DashAway = false };
				['109759202517910'] = { Name = "M2"; Type = "Default"; Additional = 0; DashAway = false };
				['112357749147873'] = { Name = "M2"; Type = "Default"; Additional = 0; DashAway = false };
				['126544442020713'] = { Name = "M2"; Type = "Default"; Additional = 0; DashAway = false };
				['108709923613549'] = { Name = "Miss"; Type = "Default"; Additional = 0; DashAway = false };
				['134746013128283'] = { Name = "Miss"; Type = "Default"; Additional = 0; DashAway = false };
				['72091499009641'] = { Name = "Mountain Breaker Attempt"; Type = "Default"; Additional = 0; DashAway = false };
				['91870684639348'] = { Name = "Mountain Breaker User"; Type = "Default"; Additional = 0; DashAway = false };
				['83850510775877'] = { Name = "Mountain Breaker Victim"; Type = "Default"; Additional = 0; DashAway = false };
				['73292538890697'] = { Name = "Muay Thai Flying Knee"; Type = "Default"; Additional = 0; DashAway = false };
				['138763915343598'] = { Name = "Muay Thai KneeKick Attempt"; Type = "Default"; Additional = 0; DashAway = false };
				['99855371808713'] = { Name = "Muay Thai KneeKick User"; Type = "Default"; Additional = 0; DashAway = false };
				['88386821390334'] = { Name = "Muay Thai KneeKick Victim"; Type = "Default"; Additional = 0; DashAway = false };
				['130894111641021'] = { Name = "Muay Thai M2"; Type = "Default"; Additional = 0; DashAway = false };
				['100085428335685'] = { Name = "Muay Thai Roundhouse Kick"; Type = "Default"; Additional = 0; DashAway = false };
				['124854957597392'] = { Name = "Muay Thai Skull Splitter"; Type = "Default"; Additional = 0; DashAway = false };
				['132785869207840'] = { Name = "Muay Thai Skull Splitter Victim"; Type = "Default"; Additional = 0; DashAway = false };
				['82265576274862'] = { Name = "Muay Thai Spinning Elbow"; Type = "Default"; Additional = 0; DashAway = false };
				['94781947226413'] = { Name = "Muay Thai Swing1"; Type = "Normal"; Additional = 0; DashAway = false };
				['76500728815383'] = { Name = "Muay Thai Swing2"; Type = "Normal"; Additional = 0; DashAway = false };
				['124722421668967'] = { Name = "Muay Thai Swing3"; Type = "Normal"; Additional = 0; DashAway = false };
				['72543817187500'] = { Name = "Muay Thai Swing4"; Type = "Normal"; Additional = 0; DashAway = false };
				['100028174044489'] = { Name = "Muay Thai TigerJaws Attempt"; Type = "Default"; Additional = 0; DashAway = false };
				['80294326679315'] = { Name = "Muay Thai TigerJaws User"; Type = "Default"; Additional = 0; DashAway = false };
				['85565523285617'] = { Name = "Muay Thai TigerJaws Victim"; Type = "Default"; Additional = 0; DashAway = false };
				['115026307993524'] = { Name = "Nuclear Kick"; Type = "Default"; Additional = 0; DashAway = false };
				['104024293242952'] = { Name = "Old Chop"; Type = "Default"; Additional = 0; DashAway = false };
				['107898094470819'] = { Name = "Old Fashioned Hook Kick"; Type = "Default"; Additional = 0; DashAway = false };
				['102618399999395'] = { Name = "One Inch Punch"; Type = "Default"; Additional = 0; DashAway = false };
				['118038489594088'] = { Name = "One Inch PunchNotUsed"; Type = "Default"; Additional = 0; DashAway = false };
				['104198772990299'] = { Name = "Pickle HadakaJime Attempt"; Type = "Default"; Additional = 0; DashAway = false };
				['119687519972726'] = { Name = "Pickle HadakaJime Attempt Shorter"; Type = "Default"; Additional = 0; DashAway = false };
				['80645333665297'] = { Name = "Pickle HadakaJime User"; Type = "Default"; Additional = 0; DashAway = false };
				['80317860108999'] = { Name = "Pickle HadakaJime Victim"; Type = "Default"; Additional = 0; DashAway = false };
				['93117896158349'] = { Name = "Pickle Leap"; Type = "Default"; Additional = 0; DashAway = false };
				['133845371784450'] = { Name = "Pickle LeapOld"; Type = "Default"; Additional = 0; DashAway = false };
				['139456332541134'] = { Name = "Pickle Smash"; Type = "Default"; Additional = 0; DashAway = false };
				['75684555914377'] = { Name = "Pickle Uppercut"; Type = "Default"; Additional = 0; DashAway = false };
				['89182446180392'] = { Name = "PickupUser"; Type = "Default"; Additional = 0; DashAway = false };
				['104218657807685'] = { Name = "PickupVictim"; Type = "Default"; Additional = 0; DashAway = false };
				['74449944586056'] = { Name = "Pummel"; Type = "Default"; Additional = 0; DashAway = false };
				['93859850373115'] = { Name = "Punch1"; Type = "Default"; Additional = 0; DashAway = false };
				['88032248145906'] = { Name = "Punch2"; Type = "Default"; Additional = 0; DashAway = false };
				['75087678181633'] = { Name = "Pure User"; Type = "Default"; Additional = 0; DashAway = false };
				['86043540683667'] = { Name = "Pure Victim"; Type = "Default"; Additional = 0; DashAway = false };
				['102173484889614'] = { Name = "Raishin M2"; Type = "Default"; Additional = 0; DashAway = false };
				['110449806780176'] = { Name = "Raishin Swing1"; Type = "Normal"; Additional = 0; DashAway = false };
				['136838135297991'] = { Name = "Raishin Swing2"; Type = "Normal"; Additional = 0; DashAway = false };
				['100381859629835'] = { Name = "Raishin Swing3"; Type = "Normal"; Additional = 0; DashAway = false };
				['115257758939159'] = { Name = "Raishin Swing4"; Type = "Normal"; Additional = 0; DashAway = false };
				['105682253611592'] = { Name = "Rapture"; Type = "Default"; Additional = 0; DashAway = false };
				['115906651463281'] = { Name = "RaptureOld"; Type = "Default"; Additional = 0; DashAway = false };
				['99850629170524'] = { Name = "Reaper Pistols Swing1"; Type = "Normal"; Additional = 0; DashAway = false };
				['108163266092263'] = { Name = "Reaper Pistols Swing2"; Type = "Normal"; Additional = 0; DashAway = false };
				['138855027747311'] = { Name = "RemovaStage1"; Type = "Default"; Additional = 0; DashAway = false };
				['110363431725903'] = { Name = "RemovaStage3 Camera"; Type = "Default"; Additional = 0; DashAway = false };
				['76966067549872'] = { Name = "RemovaStage3 User"; Type = "Default"; Additional = 0; DashAway = false };
				['78851961706730'] = { Name = "RenshÅ"; Type = "Default"; Additional = 0; DashAway = false };
				['118352169928756'] = { Name = "RotaryShift Attempt"; Type = "Default"; Additional = 0; DashAway = false };
				['124330190461317'] = { Name = "RotaryShift User"; Type = "Default"; Additional = 0; DashAway = false };
				['100438386945643'] = { Name = "RotaryShift Victim"; Type = "Default"; Additional = 0; DashAway = false };
				['135062533768824'] = { Name = "RunLoop"; Type = "Default"; Additional = 0; DashAway = false };
				['73127597552463'] = { Name = "RunUser"; Type = "Default"; Additional = 0; DashAway = false };
				['91262991777209'] = { Name = "RunVictim"; Type = "Default"; Additional = 0; DashAway = false };
				['108087779776327'] = { Name = "RyÅ«sui-ken"; Type = "Default"; Additional = 0; DashAway = false };
				['127179462215664'] = { Name = "Shoulder Bash"; Type = "Default"; Additional = 0; DashAway = false };
				['78599916594071'] = { Name = "ShoulderThrowAttempt"; Type = "Default"; Additional = 0; DashAway = false };
				['85743202426075'] = { Name = "ShoulderThrowAttemptOld"; Type = "Default"; Additional = 0; DashAway = false };
				['129101971020209'] = { Name = "ShoulderThrowUser"; Type = "Default"; Additional = 0; DashAway = false };
				['110450987165902'] = { Name = "ShoulderThrowUserOld"; Type = "Default"; Additional = 0; DashAway = false };
				['130396994026868'] = { Name = "ShoulderThrowVictim"; Type = "Default"; Additional = 0; DashAway = false };
				['86701508894530'] = { Name = "ShoulderThrowVictimOld"; Type = "Default"; Additional = 0; DashAway = false };
				['74548743209916'] = { Name = "Side Kick"; Type = "Default"; Additional = 0; DashAway = false };
				['96321292906767'] = { Name = "Side KickOld"; Type = "Default"; Additional = 0; DashAway = false };
				['104364358076241'] = { Name = "SkullStomp"; Type = "Default"; Additional = 0; DashAway = false };
				['85825072662360'] = { Name = "SkullStompUser"; Type = "Default"; Additional = 0; DashAway = false };
				['113557096684763'] = { Name = "SkullStomVictim"; Type = "Default"; Additional = 0; DashAway = false };
				['131753315436647'] = { Name = "Skyward Throw Attempt"; Type = "Default"; Additional = 0; DashAway = false };
				['104710984461828'] = { Name = "Skyward Throw User"; Type = "Default"; Additional = 0; DashAway = false };
				['88011295918524'] = { Name = "Skyward Throw Victim"; Type = "Default"; Additional = 0; DashAway = false };
				['95679804881081'] = { Name = "Slam Attempt"; Type = "Default"; Additional = 0; DashAway = false };
				['95423936827832'] = { Name = "Slam User"; Type = "Default"; Additional = 0; DashAway = false };
				['91532613168262'] = { Name = "Slam Victim"; Type = "Default"; Additional = 0; DashAway = false };
				['127403148867921'] = { Name = "SlamUser"; Type = "Default"; Additional = 0; DashAway = false };
				['107634129695862'] = { Name = "SlamVictim"; Type = "Default"; Additional = 0; DashAway = false };
				['79214494771806'] = { Name = "Stardrop Cast"; Type = "Default"; Additional = 0; DashAway = false };
				['95334698235438'] = { Name = "Stardrop User"; Type = "Default"; Additional = 0; DashAway = false };
				['135411918503914'] = { Name = "Stardrop Victim"; Type = "Default"; Additional = 0; DashAway = false };
				['126711383925396'] = { Name = "Start"; Type = "Default"; Additional = 0; DashAway = false };
				['75758060233545'] = { Name = "Stomp"; Type = "Default"; Additional = 0; DashAway = false };
				['73292626669403'] = { Name = "Street Fighting Cheap Shot"; Type = "Default"; Additional = 0; DashAway = false };
				['120561916659841'] = { Name = "Street Fighting Discombobulate"; Type = "Default"; Additional = 0; DashAway = false };
				['86834599087821'] = { Name = "Street Fighting Headbutt"; Type = "Default"; Additional = 0; DashAway = false };
				['88827751290366'] = { Name = "Street Fighting LowBlow"; Type = "Default"; Additional = 0; DashAway = false };
				['18920452028'] = { Name = "Street Fighting M2"; Type = "Default"; Additional = 0; DashAway = false };
				['140399901982658'] = { Name = "Street Fighting Swing1"; Type = "Normal"; Additional = 0; DashAway = false };
				['73979102410446'] = { Name = "Street Fighting Swing2"; Type = "Normal"; Additional = 0; DashAway = false };
				['109329372652434'] = { Name = "Street Fighting Swing3"; Type = "Normal"; Additional = 0; DashAway = false };
				['124706446009234'] = { Name = "Street Fighting Swing4"; Type = "Normal"; Additional = 0; DashAway = false };
				['128017865351434'] = { Name = "Sumo M2"; Type = "Default"; Additional = 0; DashAway = false };
				['79453890950807'] = { Name = "Sumo Swing1"; Type = "Normal"; Additional = 0; DashAway = false };
				['124366845919287'] = { Name = "Sumo Swing2"; Type = "Normal"; Additional = 0; DashAway = false };
				['88089073213770'] = { Name = "Sumo Swing3"; Type = "Normal"; Additional = 0; DashAway = false };
				['91740097683371'] = { Name = "Sumo Swing4"; Type = "Normal"; Additional = 0; DashAway = false };
				['130810164101947'] = { Name = "Sunfire"; Type = "Default"; Additional = 0; DashAway = false };
				['91722507582338'] = { Name = "SuplexAttempt"; Type = "Default"; Additional = 0; DashAway = false };
				['104917283051637'] = { Name = "SuplexUser"; Type = "Default"; Additional = 0; DashAway = false };
				['107714259462470'] = { Name = "SuplexVictim"; Type = "Default"; Additional = 0; DashAway = false };
				['139710178251470'] = { Name = "Swing1"; Type = "Default"; Additional = 0; DashAway = false };
				['71245965273121'] = { Name = "Swing1"; Type = "Default"; Additional = 0; DashAway = false };
				['94044591641820'] = { Name = "Swing1"; Type = "Default"; Additional = 0; DashAway = false };
				['71758990885395'] = { Name = "Swing1"; Type = "Default"; Additional = 0; DashAway = false };
				['127550580214734'] = { Name = "Swing2"; Type = "Default"; Additional = 0; DashAway = false };
				['104158603173410'] = { Name = "Swing2"; Type = "Default"; Additional = 0; DashAway = false };
				['118725745278483'] = { Name = "Swing2"; Type = "Default"; Additional = 0; DashAway = false };
				['136010750994028'] = { Name = "Swing2"; Type = "Default"; Additional = 0; DashAway = false };
				['127325890369718'] = { Name = "Swing3"; Type = "Default"; Additional = 0; DashAway = false };
				['126878830397379'] = { Name = "Swing3"; Type = "Default"; Additional = 0; DashAway = false };
				['111059419072011'] = { Name = "Swing3"; Type = "Default"; Additional = 0; DashAway = false };
				['140052859450325'] = { Name = "Swing3"; Type = "Default"; Additional = 0; DashAway = false };
				['102335824423554'] = { Name = "Swing4"; Type = "Default"; Additional = 0; DashAway = false };
				['122303098984989'] = { Name = "Swing4"; Type = "Default"; Additional = 0; DashAway = false };
				['112430308288328'] = { Name = "Swing4"; Type = "Default"; Additional = 0; DashAway = false };
				['118216222400878'] = { Name = "Swing4"; Type = "Default"; Additional = 0; DashAway = false };
				['75334123202448'] = { Name = "Tackle"; Type = "Default"; Additional = 0; DashAway = false };
				['120590664734250'] = { Name = "Taekkyeon M2"; Type = "Default"; Additional = 0; DashAway = false };
				['77145194449527'] = { Name = "Taekkyeon Swing1"; Type = "Normal"; Additional = 0; DashAway = false };
				['140533815282292'] = { Name = "Taekkyeon Swing2"; Type = "Normal"; Additional = 0; DashAway = false };
				['125600639325389'] = { Name = "Taekkyeon Swing3"; Type = "Normal"; Additional = 0; DashAway = false };
				['77809935733449'] = { Name = "Taekkyeon Swing4"; Type = "Normal"; Additional = 0; DashAway = false };
				['113789071745517'] = { Name = "Taekwondo 360Â° Kick"; Type = "Default"; Additional = 0; DashAway = false };
				['116193587001340'] = { Name = "Taekwondo 540Â° Kick"; Type = "Default"; Additional = 0; DashAway = false };
				['93532636172505'] = { Name = "Taekwondo Axe Kick"; Type = "Default"; Additional = 0; DashAway = false };
				['95952937482946'] = { Name = "Taekwondo BackKick"; Type = "Default"; Additional = 0; DashAway = false };
				['95575681084486'] = { Name = "Taekwondo Flurry Kick"; Type = "Default"; Additional = 0; DashAway = false };
				['77614941918366'] = { Name = "Taekwondo M2"; Type = "Default"; Additional = 0; DashAway = false };
				['139473912820305'] = { Name = "Taekwondo M2Old"; Type = "Default"; Additional = 0; DashAway = false };
				['74855215360759'] = { Name = "Taekwondo Swing1"; Type = "Normal"; Additional = 0; DashAway = false };
				['106482731997874'] = { Name = "Taekwondo Swing2"; Type = "Normal"; Additional = 0; DashAway = false };
				['90083045396351'] = { Name = "Taekwondo Swing3"; Type = "Normal"; Additional = 0; DashAway = false };
				['127604905255876'] = { Name = "Taekwondo Swing4"; Type = "Normal"; Additional = 0; DashAway = false };
				['82044818311177'] = { Name = "Taekwondo Temple Hook Kick"; Type = "Default"; Additional = 0; DashAway = false };
				['137995832866044'] = { Name = "Tenkuu-Otoshi Attempt"; Type = "Default"; Additional = 0; DashAway = false };
				['94946653562251'] = { Name = "Tenkuu-Otoshi User"; Type = "Default"; Additional = 0; DashAway = false };
				['82398868270156'] = { Name = "Tenkuu-Otoshi Victim"; Type = "Default"; Additional = 0; DashAway = false };
				['74775874433100'] = { Name = "Terminal Stab"; Type = "Default"; Additional = 0; DashAway = false };
				['78344418434013'] = { Name = "ThunderClap Attempt"; Type = "Default"; Additional = 0; DashAway = false };
				['105920120969869'] = { Name = "ThunderClap User"; Type = "Default"; Additional = 0; DashAway = false };
				['102271949326021'] = { Name = "ThunderClap Victim"; Type = "Default"; Additional = 0; DashAway = false };
				['99624629857040'] = { Name = "Tori-Uchi Start"; Type = "Default"; Additional = 0; DashAway = false };
				['103783927219305'] = { Name = "Tori-Uchi User"; Type = "Default"; Additional = 0; DashAway = false };
				['112788989864653'] = { Name = "Tori-Uchi Victim"; Type = "Default"; Additional = 0; DashAway = false };
				['116835884074995'] = { Name = "Trance State"; Type = "Default"; Additional = 0; DashAway = false };
				['108215333994599'] = { Name = "Triple Strike"; Type = "Default"; Additional = 0; DashAway = false };
				['77029179069609'] = { Name = "WallSlamUser"; Type = "Default"; Additional = 0; DashAway = false };
				['112907369802775'] = { Name = "WallSlamVictim"; Type = "Default"; Additional = 0; DashAway = false };
				['120472923490735'] = { Name = "Waterfall Beatdown Attempt"; Type = "Default"; Additional = 0; DashAway = false };
				['126581779214759'] = { Name = "Waterfall Beatdown User"; Type = "Default"; Additional = 0; DashAway = false };
				['81103374097424'] = { Name = "Waterfall Beatdown Victim"; Type = "Default"; Additional = 0; DashAway = false };
				['78202189556533'] = { Name = "Whirlwind"; Type = "Default"; Additional = 0; DashAway = false };
				['133391443087595'] = { Name = "Whirlwind Old"; Type = "Default"; Additional = 0; DashAway = false };
				['131547065147224'] = { Name = "Wrestling M2"; Type = "Default"; Additional = 0; DashAway = false };
				['82399852523711'] = { Name = "Wrestling Swing1"; Type = "Normal"; Additional = 0; DashAway = false };
				['89746824888567'] = { Name = "Wrestling Swing2"; Type = "Normal"; Additional = 0; DashAway = false };
				['139180913978655'] = { Name = "Wrestling Swing3"; Type = "Normal"; Additional = 0; DashAway = false };
				['82052060990065'] = { Name = "Wrestling Swing4"; Type = "Normal"; Additional = 0; DashAway = false }
			}
			local Serialized = {}

			for AnimationId, Data in HiddenFlags.AttackAnims do
				table.insert(Serialized, {
					Id = AnimationId,
					Name = Data.Name,
					Type = Data.Type,
					Additional = Data.Additional or 0,
					DashAway = Data.DashAway or false,
				})
			end

			table.sort(Serialized, function(a, b)
				return a.Name:lower() < b.Name:lower()
			end)

			local function IsDifferent(CombatAnims, Serialized)
				for _, Anim in ipairs(Serialized) do
					local Data = CombatAnims[Anim.Id]
					if not Data then
						-- new animation not in CombatAnims
						-- print("New animation found:", Anim.Name, Anim.Id)
						return true
					end

					if Data.Name ~= Anim.Name
						or Data.Type ~= Anim.Type
						or Data.Additional ~= Anim.Additional
						or Data.DashAway ~= Anim.DashAway then
						-- print("Changed animation:", Anim.Id, Anim.Name)
						return true
					end
				end

				-- check for deleted animations
				for Id in pairs(CombatAnims) do
					local found = false
					for _, Anim in ipairs(Serialized) do
						if Anim.Id == Id then
							found = true
							break
						end
					end
					if not found then
						-- print("Animation missing from current set:", Id, CombatAnims[Id].Name)
						return true
					end
				end

				return false
			end

			if IsDifferent(CombatAnims, Serialized) then
				HiddenFlags.UI.Window:Dialog{
					Title = "Animations Changed",
					Content = "There is a difference between the saved animations and current getter.",
					Buttons = {
						{
							Title = "Save New Animations",
							Callback = function()
								local Output = {}

								for _, Data in ipairs(Serialized) do
									local str = string.format(
										"{ Name = %q; Type = %q; Additional = %s; DashAway = %s }",
										Data.Name,
										Data.Type,
										tostring(Data.Additional or 0),
										tostring(Data.DashAway or false)
									)
									table.insert(Output, string.format("['%s'] = %s", Data.Id, str))
								end

								local Result = table.concat(Output, ";\n")
								setclipboard(Result)
							end
						},
						{
							Title = "Cancel",
							Callback = function() end
						}
					}
				}
			end
		end

		SetupAutoParry()

		local function HookGameFunc(Object, MethodName, HookFunction)
			assert(Object and MethodName and HookFunction, "Missing arguments")
			assert(type(MethodName) == "string", "MethodName must be a string")
			assert(type(HookFunction) == "function", "HookFunction must be a function")

			local Original = Object[MethodName]
			if not Original then
				error("Method '" .. MethodName .. "' not found on object")
			end

			Object[MethodName] = function(self, ...)
				return HookFunction(self, Original, ...)
			end

			-- revert function
			local Key = tostring(Object) .. "." .. MethodName

			HiddenFlags.RevertFunctions[Key] = function()
				Object[MethodName] = Original
				HiddenFlags.RevertFunctions[Key] = nil
			end

			return HiddenFlags.RevertFunctions[Key]
		end

		local function DeepSerialize(value, depth, seen)
			depth = depth or 0
			seen = seen or {}

			local t = typeof(value)
			local indent = string.rep("    ", depth)
			local output = ""

			if t == "table" then
				if seen[value] then
					return "\"<recursive>\""
				end
				seen[value] = true

				output ..= "{\n"
				for k, v in pairs(value) do
					local keyStr
					if typeof(k) == "string" then
						keyStr = string.format("[%q]", k)
					else
						keyStr = string.format("[%s]", tostring(k))
					end

					output ..= string.format("%s    %s = %s,\n", indent, keyStr, DeepSerialize(v, depth + 1, seen))
				end
				output ..= indent .. "}"
			elseif t == "string" then
				output = string.format("%q", value)
			elseif t == "Instance" then
				output = string.format("\"Instance<%s>\"", value:GetFullName())
			elseif t == "Vector3" or t == "CFrame" or t == "Color3" or t == "UDim2" then
				output = string.format("\"%s\"", tostring(value))
			elseif t == "function" then
				output = "\"<function>\""
			elseif t == "userdata" then
				output = "\"<userdata>\""
			elseif t == "nil" then
				output = "nil"
			else
				output = tostring(value)
			end

			output ..= ' -- ' ..typeof(value)

			return output
		end

		table.insert(HiddenFlags.DeInitFunctions, HookGameFunc(ClientProcess, 'insertQueue', function(self, Original, ...)
			-- local Tbl = {...}
			-- local Action = Tbl and Tbl[2]

			-- if not (type(Action) == 'table' and Action['CF']) and not (Action['Value'] and Action['Type']) then
			-- 	print(DeepSerialize({self, ...}))
			-- 	-- setclipboard(DeepSerialize({self, ...}))
			-- end

			if Flags.InfStamina then
				local Tbl = {...}
				local Action = Tbl and Tbl[2]

				if Action == 'Run' or Action == 'Dash' then return end
			end

			return Original(self, ...)
		end))

		if Flags.AutomaticExecution then
			pcall(HiddenFlags.UI.Window.Minimize)

			SendData('🟢 Connected')
		end

		if Flags.KickMessage then
			HiddenFlags.LastKickMessage = Flags.KickMessage
			Flags.KickMessage = nil

			Library:Notify{
				Title = "Information",
				Content = `Last Kick Message`,
				SubContent = HiddenFlags.LastKickMessage,
				Duration = 5
			}
		end

		local GetPlayersData = function()
			if HiddenFlags.PlayersData then return HiddenFlags.PlayersData end

			for i,v in getnilinstances() do
				if not v:IsA('Folder') then continue end
				if not v.Name == 'PlayersData' then continue end

				local ClientData = v:FindFirstChild(Client.Name)
				if not ClientData then continue end

				HiddenFlags.ClientData = ClientData
				HiddenFlags.PlayersData = v
				return v
			end
		end

		HiddenFlags.PlayersData = GetPlayersData()

		HiddenFlags.GUI = true
		Library.GUI.Destroying:Once(GUIDestroying)
		HiddenFlags.Connections.Stepped = RunService.Stepped:Connect(SteppedLoop)

		HiddenFlags.Connections.ClientCharacterAdded = Client.CharacterAdded:Connect(OnNewCharacter)
		OnNewCharacter(Client.Character)

		ListenToChildAdded(Players, PlayerAddedHandler)
	end

	DeInit = function()
		for i,v in HiddenFlags.DeInitFunctions do
			v()
		end

		for i,v in PreGameConnections do
			v:Disconnect()
		end

		for i,v in HiddenFlags.Parts do
			v:Destroy()
		end

		for i,v in Flags do
			if type(v) ~= 'boolean' then continue end

			v = false
		end

		if Library then
			Library:Destroy()
		end

		Camera.CameraSubject = Client.Character
		for i,v in HiddenFlags.Connections do
			v:Disconnect()
		end

		HiddenFlags.Maid.autoParryOnNewCharacter = nil
		HiddenFlags.Maid.autoParryMobsOnNewCharacter = nil
		HiddenFlags.ParryMaid:DoCleaning()

		shared.etocats_active = false
	end

	UserInterface = function()
		HiddenFlags.UI.Window = Library:CreateWindow{
			Title = HiddenFlags.ScriptTitle,
			SubTitle = "by afy (discord.gg/G37T6JvDtR)" .. (IS_FREE_USER and " (Free Version: This version is extremely limited)" or ""),
			TabWidth = 110,
			Size = UDim2.fromOffset(830, 525),
			Resize = true,
			MinSize = Vector2.new(470, 380),
			Theme = "Vynixu",
			MinimizeKey = Enum.KeyCode.RightShift
		}

		HiddenFlags.UI.Tabs = {
			Main = HiddenFlags.UI.Window:CreateTab{
				Title = "Main",
				Icon = "phosphor-users-bold"
			},
			Stats = HiddenFlags.UI.Window:CreateTab{
				Title = "Stats",
				Icon = "phosphor-air-traffic-control"
			},
			Farming = HiddenFlags.UI.Window:CreateTab{
				Title = "Farm",
				Icon = "phosphor-align-bottom"
			},
			Combat = HiddenFlags.UI.Window:CreateTab{
				Title = "Combat",
				Icon = "phosphor-boxing-glove"
			},
			Misc = HiddenFlags.UI.Window:CreateTab{
				Title = "Misc",
				Icon = "phosphor-angle"
			},
			Consumables = HiddenFlags.UI.Window:CreateTab{
				Title = "Consumables",
				Icon = "phosphor-anchor"
			},
			Teleports = HiddenFlags.UI.Window:CreateTab{
				Title = "Teleports",
				Icon = "phosphor-arrow-fat-lines-right"
			},
			Settings = HiddenFlags.UI.Window:CreateTab{
				Title = "Settings",
				Icon = "settings"
			}
		}

		HiddenFlags.UI.Tabs.Settings:CreateSlider("ServerHopDelay", {
			Title = "Server Hop Delay",
			Description = 'Increase the delay between server changes. Helpful for trash executors/devices.',
			Default = Flags.ServerHopDelay,
			Min = 0,
			Max = 60,
			Rounding = 0,
		}):OnChanged(function(Value)
			Flags.ServerHopDelay = Value
		end)

		HiddenFlags.UI.Tabs.Settings:CreateSlider("TweenSpeed", {
			Title = "Tween Speed",
			Description = "Moving speed whilst tweening (Dont go above 75 for stability)" .. (IS_FREE_USER and " (Much slower for free users)" or ""),
			Default = Flags.TweenSpeed,
			Min = 0,
			Max = IS_FREE_USER and 10 or 100,
			Rounding = 1,
		}):OnChanged(function(Value)
			Flags.TweenSpeed = IS_FREE_USER and math.max(Value, 10) or Value
		end)

		HiddenFlags.UI.Tabs.Farming:CreateToggle("CombatCheck", { Title = "Combat Check While Farming", Description = 'Leaves On Combat Check.', Default = Flags.CombatCheck }):OnChanged(function(Value)
			Flags.CombatCheck = Value
		end)

		HiddenFlags.UI.Tabs.Farming:CreateToggle("AutoCompleteKeyPressMinigame", { Title = "Auto Complete Key Press Minigame", Description = 'Auto presses the minigame where you have to press buttons.', Default = Flags.AutoCompleteKeyPressMinigame }):OnChanged(function(Value)
			Flags.AutoCompleteKeyPressMinigame = Value
		end)

		HiddenFlags.UI.Tabs.Farming:AddSection("Money")
		HiddenFlags.UI.Tabs.Farming:CreateToggle("AutoWithdraw", { Title = "Auto Withdraw", Default = Flags.AutoWithdraw }):OnChanged(function(Value)
			Flags.AutoWithdraw = Value
		end)
		HiddenFlags.UI.Tabs.Farming:CreateToggle("AutoDeposit", { Title = "Auto Deposit", Default = Flags.AutoDeposit }):OnChanged(function(Value)
			Flags.AutoDeposit = Value
		end)

		HiddenFlags.UI.Tabs.Farming:AddSection("Fatigue")
		HiddenFlags.UI.Tabs.Farming:CreateToggle("AutoFatigue", { Title = "Auto Fatigue", Default = Flags.AutoFatigue }):OnChanged(function(Value)
			Flags.AutoFatigue = Value

			if IS_FREE_USER and Value then
				Library:Notify{Content = `Free User`, SubContent = 'Cannot use Auto Fatigue', Duration = 5}
				Flags.AutoFatigue = false
				Library.Options.AutoFatigue:SetValue(false)
			end
		end)

		HiddenFlags.UI.Tabs.Farming:AddSection("Stats")
		HiddenFlags.UI.Tabs.Farming:CreateToggle("AutoRoadwork", { Title = "Auto Roadwork", Default = Flags.AutoRoadwork }):OnChanged(function(Value)
			Flags.AutoRoadwork = Value
		end)

		HiddenFlags.UI.Tabs.Farming:CreateSlider("RoadworkHeightAdjustment", {
			Title = "Roadwork Height Adjustment",
			Description = 'If your roadwork isnt registering, increase or decrease slightly to fix.',
			Default = Flags.RoadworkHeightAdjustment,
			Min = -10,
			Max = 10,
			Rounding = 1,
		}):OnChanged(function(Value)
			Flags.RoadworkHeightAdjustment = Value
		end)

		HiddenFlags.UI.Tabs.Farming:CreateDropdown("AutoRoadworkType", {
			Title = "Selected Roadwork Type",
			Values = {'Long', 'Short'},
			Multi = false,
			Default = Flags.AutoRoadworkType or 1,
		}):OnChanged(function(Value)
			Flags.AutoRoadworkType = Value
		end)

		HiddenFlags.UI.Tabs.Farming:AddSection("Punching Bag")
		HiddenFlags.UI.Tabs.Farming:CreateToggle("PunchingBag", { Title = "Auto Punching Bag", Default = Flags.PunchingBag }):OnChanged(function(Value)
			Flags.PunchingBag = Value
		end)
		HiddenFlags.UI.Tabs.Farming:CreateSlider("PunchingBagDistanceFromPlayer", {
			Title = "Punching Bag Distance From Player",
			Description = "How far the closest person can be to the Punching Bag.",
			Default = Flags.PunchingBagDistanceFromPlayer,
			Min = 0,
			Max = 100,
			Rounding = 1,
		}):OnChanged(function(Value)
			Flags.PunchingBagDistanceFromPlayer = Value
		end)
		HiddenFlags.UI.Tabs.Farming:CreateSlider("PunchingBagHeightAdjustment", {
			Title = "Punching Bag Height Adjustment",
			Description = 'If your roadwork isnt registering, increase or decrease slightly to fix.',
			Default = Flags.PunchingBagHeightAdjustment or 0,
			Min = -10,
			Max = 10,
			Rounding = 1,
		}):OnChanged(function(Value)
			Flags.PunchingBagHeightAdjustment = Value
		end)

		HiddenFlags.UI.Tabs.Farming:AddSection("Jobs")
		HiddenFlags.UI.Tabs.Farming:CreateToggle("JobFarm", { Title = "Auto Job Farm", Default = Flags.JobFarm }):OnChanged(function(Value)
			Flags.JobFarm = Value
		end)

		HiddenFlags.UI.Tabs.Farming:CreateDropdown("JobType", {
			Title = "Selected Job Type",
			Values = {'Job Board', 'Makima (Must be Employee Level 10)'},
			Multi = false,
			Default = Flags.JobType or 1,
		}):OnChanged(function(Value)
			Flags.JobType = Value

			if Library.Options.RejoinNoPatients then
				Library.Options.RejoinNoPatients.Instance.Frame.Visible = Flags.JobType == 'Makima (Must be Employee Level 10)'
			end
		end)

		HiddenFlags.UI.Tabs.Farming:CreateToggle("RejoinNoPatients", { Title = "Rejoin If There Are No Patients", Default = Flags.RejoinNoPatients }):OnChanged(function(Value)
			Flags.RejoinNoPatients = Value
			Library.Options.RejoinNoPatients.Instance.Frame.Visible = Flags.JobType == 'Makima (Must be Employee Level 10)'
		end)

		task.spawn(function()
			while not HiddenFlags.UI_Loaded do task.wait() end
			Library.Options.RejoinNoPatients.Instance.Frame.Visible = Flags.JobType == 'Makima (Must be Employee Level 10)'
		end)
		
		HiddenFlags.UI.Tabs.Farming:AddSection("Machines")
		HiddenFlags.UI.Tabs.Farming:CreateDropdown("Machines", {
			Title = "Selected Machine",
			Values = HiddenFlags.Game.TrainingsIndexed(),
			Multi = false,
			Default = Flags.Machines.Selected,
		}):OnChanged(function(Value)
			Flags.Machines.Selected = Value
			local TrainingNames, Trainings = HiddenFlags.Game.TrainingsIndexed()

			for i,v in Trainings do
				Flags.Machines[i] = Value == i
			end
		end)

		HiddenFlags.UI.Tabs.Farming:CreateToggle("AutoMachine", { Title = "Auto Machine", Default = Flags.AutoMachine }):OnChanged(function(Value)
			Flags.AutoMachine = Value

			if IS_FREE_USER and Flags.AutoMachine then
				Library:Notify{Content = `Free User`, SubContent = 'Cannot use Auto Machine', Duration = 5}
				Flags.AutoMachine = false
				Library.Options.AutoMachine:SetValue(false)
			end
		end)

		HiddenFlags.UI.Tabs.Farming:CreateSlider("MachineDistanceFromPlayer", {
			Title = "Machine Distance From Player",
			Description = "How far the closest person can be to the machine.",
			Default = Flags.MachineDistanceFromPlayer,
			Min = 0,
			Max = 100,
			Rounding = 1,
		}):OnChanged(function(Value)
			Flags.MachineDistanceFromPlayer = Value
		end)

		HiddenFlags.UI.Tabs.Farming:AddSection("Training Tools")
		HiddenFlags.UI.Tabs.Farming:CreateDropdown("TrainingTools", {
			Title = "Selected Training Tool",
			Values = {'Handstand Pushup', 'Jumping Jacks', 'Jumping Rope', 'One Hand Pushups', 'Pushup', 'Situp', 'Squat'},
			Multi = false,
			Default = Flags.TrainingTools.Selected,
		}):OnChanged(function(Value)
			Flags.TrainingTools.Selected = Value
			Flags.TrainingTools['Handstand Pushup'] = Value == 'Handstand Pushup'
			Flags.TrainingTools['Jumping Jacks'] = Value == 'Jumping Jacks'
			Flags.TrainingTools['Jumping Rope'] = Value == 'Jumping Rope'
			Flags.TrainingTools['One Hand Pushups'] = Value == 'One Hand Pushups'
			Flags.TrainingTools.Pushup = Value == 'Pushup'
			Flags.TrainingTools.Situp = Value == 'Situp'
			Flags.TrainingTools.Squat = Value == 'Squat'
		end)

		HiddenFlags.UI.Tabs.Farming:CreateToggle("AutoTrainingTool", { Title = "Auto Training Tool", Default = Flags.AutoTrainingTool }):OnChanged(function(Value)
			Flags.AutoTrainingTool = Value

			if IS_FREE_USER and Flags.AutoTrainingTool then
				Library:Notify{Content = `Free User`, SubContent = 'Cannot use Auto Training Tool', Duration = 5}
				Flags.AutoTrainingTool = false
				Library.Options.AutoTrainingTool:SetValue(false)
			end
		end)

		HiddenFlags.UI.Tabs.Consumables:CreateToggle("AutoWorkoutDrink", { Title = "Auto Workout Drink", Default = Flags.AutoWorkoutDrink }):OnChanged(function(Value)
			Flags.AutoWorkoutDrink = Value

			if IS_FREE_USER and Flags.AutoWorkoutDrink then
				Library:Notify{Content = `Free User`, SubContent = 'Cannot use Auto Workout Drink', Duration = 5}
				Flags.AutoWorkoutDrink = false
				Library.Options.AutoWorkoutDrink:SetValue(false)
			end
		end)

		HiddenFlags.UI.Tabs.Consumables:CreateToggle("AutoEat", { Title = "Auto Eat", Default = Flags.AutoEat }):OnChanged(function(Value)
			Flags.AutoEat = Value
		end)

		HiddenFlags.UI.Tabs.Consumables:AddSection("Training Equipments")
		HiddenFlags.UI.Tabs.Consumables:CreateToggle("AutoTrainingEquipment", { Title = "Auto Training Equipment", Default = Flags.AutoTrainingEquipment }):OnChanged(function(Value)
			Flags.AutoTrainingEquipment = Library.Options.AutoTrainingEquipment.Value
		end)

		HiddenFlags.UI.Tabs.Consumables:CreateDropdown("TrainingEquipments", {
			Title = "Select Equipment",
			Values = {"50KG Leg Weights", "50KG Vest", "25KG Leg Weights", "25KG Vest", "5KG Leg Weights", "5KG Vest", "Breathing Mask", 'Blindfold'},
			Multi = true,
			Default = Flags.Equipments.Selected
		}):OnChanged(function(selected)
			Flags.Equipments.Selected = {}

			for name in Flags.Equipments do
				if type(Flags.Equipments[name]) == 'table' then continue end
				Flags.Equipments[name] = false
			end

			for name, enabled in selected do
				if not enabled then continue end

				Flags.Equipments[name] = true
				table.insert(Flags.Equipments.Selected, name)
			end
		end)

		HiddenFlags.UI.Tabs.Misc:CreateInput("WebHookInput", {
			Title = "Discord Webhook",
			Placeholder = "None",
			Numeric = false, -- Only allows numbers
			Finished = false, -- Only calls callback when you press enter
			Callback = function(Value)
				Flags.WebHook = Value ~= '' and Value
				Library:Notify{
					Title = 'Set Webhook',
					Content = Value == '' and 'None' or Value,
					Duration = 5,
				}
			end
		})

		HiddenFlags.UI.Tabs.Misc:CreateSlider("WebHookDataSendDelay", {
			Title = "WebHook Data Send Delay",
			Description = 'Delay between sending data to webhook.',
			Default = Flags.WebHookDataSendDelay,
			Min = 5,
			Max = 1800,
			Rounding = 0,
		}):OnChanged(function(Value)
			Flags.WebHookDataSendDelay = Value
		end)

		HiddenFlags.UI.Tabs.Misc:CreateToggle("KickOnStaff", { Title = "Kick On Staff", Default = Flags.KickOnStaff }):OnChanged(function(Value)
			Flags.KickOnStaff = Value

			if Value then
				for _, v in Players:GetPlayers() do
					task.spawn(PlayerAddedHandler, v)
				end
			end
		end)

		HiddenFlags.StatsData = HiddenFlags.UI.Tabs.Stats:CreateParagraph("StatsData", {
			Title = "Stats",
			Content = "error..."
		})

		HiddenFlags.UI.Tabs.Misc:CreateButton{
			Title = "Rejoin",
			Description = "Rejoins the game",
			Callback = function()
				-- TeleportService:Teleport(game.PlaceId)
				CombatCheck()
				Client:Kick('Client requested rejoin')
			end
		}

		HiddenFlags.UI.Tabs.Misc:CreateKeybind("PanicKeybind", {
			Title = "Panic",
			Mode = "Toggle", -- Always, Toggle, Hold
			Default = 'RightControl',

			Callback = function(Value)
				if Value then
					DeInit()
				end
			end,
		})

		HiddenFlags.UI.Tabs.Misc:CreateSlider("SpeedMultiplier", {
			Title = "Speed Multiplier",
			Description = "Movement Speed Multiplier",
			Default = Flags.SpeedMultiplier,
			Min = 0,
			Max = 1,
			Rounding = 2,
		}):OnChanged(function(Value)
			Flags.SpeedMultiplier = Value
		end)

		HiddenFlags.UI.Tabs.Combat:CreateToggle("InfStamina", { Title = "Infinite Stamina", Default = Flags.InfStamina, Callback = function(Value)
			Flags.InfStamina = Value
		end})

		HiddenFlags.UI.Tabs.Combat:CreateToggle("AutoSprint", { Title = "Auto Sprint", Default = Flags.AutoSprint, Callback = function(Value)
			local LastRan = 0
			local ID = {}
			local Moving = false
			Flags.AutoSprint = Value

			HiddenFlags.Connections.InputBeganAutoSprint = HiddenFlags.Connections.InputBeganAutoSprint or UserInputService.InputBegan:Connect(function(Input, InChat)
				if InChat or not Flags.AutoSprint then return end

				if UserInputService:IsKeyDown('W') or UserInputService:IsKeyDown('A') or UserInputService:IsKeyDown('D') then
					Moving = true
				end

				if Input.KeyCode == Enum.KeyCode.W and os.clock() - LastRan > 0.1 then
					LastRan = os.clock()
					VirtualInputManager:SendKeyEvent(false, 'W', false, game)
					VirtualInputManager:SendKeyEvent(true, 'W', false, game)
				end
			end)

			HiddenFlags.Connections.InputEndedAutoSprint = HiddenFlags.Connections.InputEndedAutoSprint or UserInputService.InputEnded:Connect(function(Input, InChat)
				if InChat or not Flags.AutoSprint then return end

				if not (UserInputService:IsKeyDown('W') or UserInputService:IsKeyDown('A') or UserInputService:IsKeyDown('D')) then
					Moving = false
				end
			end)

			if HiddenFlags.Connections.SprintCheckCharacterAdded then
				HiddenFlags.Connections.SprintCheckCharacterAdded:Disconnect()
			end

			local function ReSprintCheck(Char)
				if not Char then return end
				local Humanoid = Char:WaitForChild('Humanoid')

				if Humanoid then
					if HiddenFlags.Connections.AutoSprintWalkSpeed then
						HiddenFlags.Connections.AutoSprintWalkSpeed:Disconnect()
					end

					HiddenFlags.Connections.AutoSprintWalkSpeed = Humanoid:GetPropertyChangedSignal('WalkSpeed'):Connect(function()
						if Moving and Humanoid.WalkSpeed <= 16 then
							local CurrentID = {}
							ID = CurrentID

							task.wait(0.1)
							if not (ID == CurrentID) then return end

							VirtualInputManager:SendKeyEvent(false, 'W', false, game)
							VirtualInputManager:SendKeyEvent(true, 'W', false, game)
						end
					end)
				end
			end

			ReSprintCheck(Client.Character)
			HiddenFlags.Connections.SprintCheckCharacterAdded = HiddenFlags.Connections.SprintCheckCharacterAdded or Client.CharacterAdded:Connect(ReSprintCheck)
		end})

		HiddenFlags.UI.Tabs.Combat:AddSection("Parry")
		HiddenFlags.UI.Tabs.Combat:CreateToggle("AutoParry", { Title = "Auto Parry", Default = Flags.AutoParry }):OnChanged(function(Value)
			Flags.AutoParry = Value
		end)

		HiddenFlags.UI.Tabs.Combat:CreateKeybind("AutoParryKeybind", {
			Title = "Auto Parry Toggle Keybind",
			Mode = "Toggle",
			Default = Flags.AutoParryKeybind or 'Semicolon',

			Callback = function()
				local Button = not Flags.AutoParry
				Library.Options.AutoParry:SetValue(Button)
				Flags.AutoParry = Button

				Library:Notify{
					Title = 'Toggled Auto Parry',
					Content = 'Status:',
					SubContent = tostring(Button),
					Duration = 5,
				}
			end,
		})

		HiddenFlags.UI.Tabs.Combat:CreateToggle("AutoCounter", { Title = "Auto Counter", Description = 'You should have a counter move in your hotbar', Default = Flags.AutoCounter }):OnChanged(function(Value)
			Flags.AutoCounter = Value
		end)
		HiddenFlags.UI.Tabs.Combat:CreateToggle("DisableDodgeWhileClientRunning", { Title = "Disable Dodge While Client Running", Description = 'If you are running, it will either counter or dash.', Default = Flags.DisableDodgeWhileClientRunning }):OnChanged(function(Value)
			Flags.DisableDodgeWhileClientRunning = Value
		end)
		HiddenFlags.UI.Tabs.Combat:CreateSlider("ParryChance", {
			Title = "Parry Chance",
			Description = "Chance for parrying",
			Default = Flags.ParryChance,
			Min = 0,
			Max = 100,
			Rounding = 1,
		}):OnChanged(function(Value)
			Flags.ParryChance = Value
		end)

		HiddenFlags.UI.Tabs.Combat:CreateToggle("AlternateEvade", { Title = "Alternative If On Cooldown", Description = 'If one evasion is on cooldown, it will use the other', Default = Flags.AlternateEvade }):OnChanged(function(Value)
			Flags.AlternateEvade = Value
		end)
		HiddenFlags.UI.Tabs.Combat:CreateToggle("DashFirst", { Title = "Dash First", Description = 'Rotates the order of which evasion comes first', Default = Flags.DashFirst }):OnChanged(function(Value)
			Flags.DashFirst = Value
		end)
		HiddenFlags.UI.Tabs.Combat:CreateToggle("UseCustomDelay", { Title = "Use Custom Delay", Default = Flags.UseCustomDelay }):OnChanged(function(Value)
			Flags.UseCustomDelay = Value
		end)
		HiddenFlags.UI.Tabs.Combat:CreateSlider("CustomDelay", {
			Title = "Custom Delay",
			Description = "Custom delay for parrying",
			Default = Flags.CustomDelay,
			Min = 0,
			Max = 1000,
			Rounding = 1,
		}):OnChanged(function(Value)
			Flags.CustomDelay = Value
		end)

		HiddenFlags.UI.Tabs.Combat:CreateSlider("PingAdjustmentPercentage", {
			Title = "Ping Adjustment Percentage",
			Description = "Parry Timing Ping Adjustment Percentage (This is used if Use Custom Delay is off)",
			Default = Flags.PingAdjustmentPercentage,
			Min = 0,
			Max = 100,
			Rounding = 1,
		}):OnChanged(function(Value)
			Flags.PingAdjustmentPercentage = Value
		end)

		HiddenFlags.UI.Tabs.Teleports:AddSection("Bus Stop Teleports")
		HiddenFlags.UI.Tabs.Teleports:CreateDropdown("BusStopTeleports", {
			Title = "Selected Bus Stop Teleport",
			Values = HiddenFlags.Game.BusStops:GetChildren(),
			Multi = false,
			Default = 1,
		})

		HiddenFlags.UI.Tabs.Teleports:CreateButton{
			Title = "Teleport",
			Description = "Teleport to chosen Bus Stop",
			Callback = function()
				local Char = Client.Character
				local Root = GetRoot(Char)
				if not (Char and Root) then return end

				local TeleportOptions = Library.Options["BusStopTeleports"]
				local TeleportModel = TeleportOptions and TeleportOptions.Value

				if TeleportModel then
					local TeleportPart = TeleportModel.Part
					MoveTo(TeleportPart.Position + vector.create(0, -6, 0))
					Root.CFrame = TeleportPart.CFrame
				end
			end
		}

		HiddenFlags.UI.Tabs.Teleports:AddSection("Building Teleports")
		HiddenFlags.UI.Tabs.Teleports:CreateDropdown("BuildingTeleports", {
			Title = "Selected Building Teleport",
			Values = HiddenFlags.Game.Buildings:GetChildren(),
			Multi = false,
			Default = 1,
		})

		HiddenFlags.UI.Tabs.Teleports:CreateButton{
			Title = "Teleport",
			Description = "Teleport to chosen Bus Stop",
			Callback = function()
				local Char = Client.Character
				local Root = GetRoot(Char)
				if not (Char and Root) then return end

				local TeleportOptions = Library.Options["BuildingTeleports"]
				local TeleportModel = TeleportOptions and TeleportOptions.Value

				if TeleportModel then
					MoveTo(TeleportModel:GetPivot().Position + vector.create(0, -6, 0))
					Root.CFrame = TeleportModel:GetPivot()
				end
			end
		}

		HiddenFlags.UI.Tabs.Teleports:AddSection("NPC Teleports")
		for i, NPCType in HiddenFlags.Game.NPCs:GetChildren() do
			HiddenFlags.UI.Tabs.Teleports:CreateDropdown("NPCTeleports"..NPCType.Name, {
				Title = "Selected " .. NPCType.Name .." Teleport",
				Values = NPCType:GetChildren(),
				Multi = false,
				Default = 1,
			})

			HiddenFlags.UI.Tabs.Teleports:CreateButton{
				Title = "Teleport",
				Description = "Teleport to chosen " .. NPCType.Name,
				Callback = function()
					local Char = Client.Character
					local Root = GetRoot(Char)
					if not (Char and Root) then return end

					local TeleportOptions = Library.Options["NPCTeleports"..NPCType.Name]
					local TeleportModel = TeleportOptions and TeleportOptions.Value

					if TeleportModel then
						MoveTo(TeleportModel:GetPivot().Position + vector.create(0, -6, 0))
						Root.CFrame = TeleportModel:GetPivot() + vector.create(0, 4, 0)
					end
				end
			}
		end

		HiddenFlags.UI.Tabs.Main:CreateParagraph("WelcomeMessage", {
			Title = "Welcome",
			Content = IS_FREE_USER and "You're using the free version of etocats. Some features are restricted and run slower here — consider supporting development to unlock full performance and all premium tools."
				or "You're running the full version of etocats with all premium automation, UI, and performance features unlocked. Enjoy faster movement, advanced farming.",
		})

		HiddenFlags.UI.Tabs.Main:CreateButton{
			Title = "Copy Discord Link",
			Description = "Grabs the discord link",
			Callback = function()
				setclipboard('discord.gg/G37T6JvDtR')

				Library:Notify{
					Title = "Information",
					Content = `Copied:`,
					SubContent = 'discord.gg/G37T6JvDtR',
					Duration = 5
				}
			end
		}
	end

	ClickButton = function(Button)
		if HiddenFlags.Kicked then return end
		if os.clock() - (HiddenFlags.LastClicked or 0) < 0.2 then return end
		HiddenFlags.LastClicked = os.clock()

		if Button == 'TopLeft' then
			VirtualInputManager:SendMouseButtonEvent(5, 5, 0, true, game, 0)
			VirtualInputManager:SendMouseButtonEvent(5, 5, 0, false, game, 0)
			return
		end

		local GuiInset = GuiService:GetGuiInset()
		local Center = {
			X = Button.AbsolutePosition.X + GuiInset.X + (Button.AbsoluteSize.X / 2), Button.AbsolutePosition.X + GuiInset.X + (Button.AbsoluteSize.X / 2),
			Y = Button.AbsolutePosition.Y + GuiInset.Y + (Button.AbsoluteSize.Y / 2), Button.AbsolutePosition.Y + GuiInset.Y + (Button.AbsoluteSize.Y / 2)
		}

		VirtualInputManager:SendMouseButtonEvent(Center.X, Center.Y, 0, true, game, 1)
		VirtualInputManager:SendMouseButtonEvent(Center.X, Center.Y, 0, false, game, 1)
	end

	local function MoveUpside()
		local Char = Client.Character
		local Root = GetRoot(Char)
		if not Root then return end

		if Root.Rotation.X < 10 and Root.Rotation.X > -10 then
			local UpVector = vector.create(0, -1, 1)
			local RightVector = -Root.CFrame.RightVector

			Root.CFrame = CFrame.fromMatrix(Root.Position, RightVector, UpVector)
		end
	end

	SmartWait = function(wait_time, flag_string, init_cframe)
		local Char = Client.Character
		local Root = GetRoot(Char)
		local start_time = os.clock()

		HiddenFlags.CurrentlyWaiting = true

		if (Char and Root) then
			local init_cframe = init_cframe or Root.CFrame
			local IsHeld = true

			task.spawn(function()
				while IsHeld do
					Root.CFrame = init_cframe
					-- Root.CFrame *= CFrame.Angles(math.pi + math.rad(15), 0, 0)
					MoveUpside()
					task.wait()
				end
			end)

			while (Char and Root and (not flag_string or Flags[flag_string]) and os.clock() - start_time <= (wait_time or 1/60)) do
				task.wait(1/60)
			end

			IsHeld = false
		end

		HiddenFlags.CurrentlyWaiting = false
		return os.clock() - start_time
	end

	IncrementalMove = function(Root, start_pos, end_pos, speed)
		local offset = end_pos - start_pos
		local distance = vector.magnitude(offset)
		if distance < 0.001 then return end

		local direction = vector.normalize(offset)
		local current_pos = start_pos
		local moved = 0

		while moved < distance do
			local delta = RunService.Heartbeat:Wait()
			local step = math.min(speed * delta, distance - moved) -- speed * delta

			current_pos += direction * step

			local ExposedAreas, IsExposed = {
				{ Position = vector.create(931, 192, 15), Size = 100 },
				{ Position = vector.create(444, 204, -600), Size = 30 },
				{ Position = vector.create(406, 204, -708), Size = 30 },
			}

			for _, Area in ExposedAreas do
				local Center = Area.Position
				local Size = Area.Size or 100

				if GetDistanceXZ(Root.Position, Center) < Size then
					IsExposed = true
					break
				end
			end

			if IsExposed then
				Root.CFrame = CFrame.new(current_pos.X, 186, current_pos.Z)
			else
				Root.CFrame = CFrame.new(current_pos)
			end

			MoveUpside()
			moved += step
		end

		end_pos = CFrame.new(end_pos)
		Root.CFrame = end_pos
		MoveUpside()
	end

	MoveTo = function(pos, specified_y)
		if GetOffBed() then return end
		if GetOffMachine() then return end

		if HiddenFlags.CurrentlyMoving then return end
		HiddenFlags.CurrentlyMoving = true

		local Char = Client.Character
		local Root = GetRoot(Char)

		HiddenFlags.DestinationLevel = HiddenFlags.NormalLevel

		if Char and Root then
			local normal_y = HiddenFlags.FloorLevel
			local current_pos = Root.Position
			local down_pos = vector.create(current_pos.X, specified_y or normal_y, current_pos.Z)
			local across_pos = vector.create(pos.X, specified_y or normal_y, pos.Z)
			local final_pos = pos
			-- local dist = vector.magnitude(current_pos - final_pos)
			local dist = GetDistanceXZ(current_pos, final_pos)

			if dist > 1 then
				IncrementalMove(Root, current_pos, down_pos, Flags.BobbingSpeed)
				IncrementalMove(Root, down_pos, across_pos, Flags.TweenSpeed)
			end

			IncrementalMove(Root, across_pos, final_pos, Flags.BobbingSpeed)
		end

		HiddenFlags.DestinationLevel = nil
		HiddenFlags.CurrentlyMoving = false
	end

	AutoCompleteKeyPressMinigame = function()
		if not Flags.AutoCompleteKeyPressMinigame then return end

		for i,v in PlayerGui.HUD.Secondary.Trainings:GetChildren() do
			if not v:IsA('ImageButton') then continue end

			if v.Name == 'Circle' then
				local Ring = v:FindFirstChild('Ring')
			
				if Ring and Ring.Size.Y.Scale > 0.5 then continue end
			end

			local Keybind = v:FindFirstChildWhichIsA('TextLabel')

			if not HiddenFlags.Dialogue and not HiddenFlags.StaminaWait and os.clock() - (HiddenFlags.LastKeyPressed or 0) > 0.5 and Keybind and Keybind.Text then
				HiddenFlags.LastKeyPressed = os.clock()
				VirtualInputManager:SendKeyEvent(true, Keybind.Text, false, game)
				VirtualInputManager:SendKeyEvent(false, Keybind.Text, false, game)
			end
		end
	end

	CheckInventory = function(Name)
		local Char = Client.Character
		if not Char then return end

		local Backpack = Client:FindFirstChildWhichIsA('Backpack')

		for _, Children in Backpack and Backpack:GetChildren() or {} do
			if Children.Name == Name then
				return Children
			end
		end

		for i, Children in Char:GetChildren() do
			if Children.Name == Name then
				return Children, true
			end
		end
	end

	InCombat = function()
		return Client:GetAttribute('InCombat')
	end

	CombatCheck = function(FlagString)
		local Char = Client.Character
		local Root = GetRoot(Char)
		local IsInCombat = InCombat()

		if IsInCombat and Flags.CombatCheck then
			if Char and Root and InCombat() and (not FlagString or Flags[FlagString]) then
				Library:Notify{
					Title = "Combat Tagged",
					Content = 'Waiting before leaving',
				}
			end

			while Char and Root and InCombat() and (not FlagString or Flags[FlagString]) do
				Root.CFrame = CFrame.new(Root.Position.X, HiddenFlags.FloorLevel, Root.Position.Z)
				SmartWait()
			end

			if not FlagString or Flags[FlagString] then
				SmartWait(10)
				Client:Kick('etocats: Combat Triggered, Rejoining...')
				task.wait(5)
			end
		end
	end

	IsPlayerNearModel = function(Model, DistanceFromPlayer)
		local ModelPivot = Model:GetPivot()

		for _, v in Players:GetPlayers() do
			if v == Client then continue end

			local PlayerChar = v.Character
			local PlayerRoot = GetRoot(PlayerChar)
			if not (PlayerChar and PlayerRoot) then continue end

			local ModelPos = ModelPivot.Position
			local PlayerPos = PlayerRoot.Position

			local HeightDiff = math.abs(ModelPos.Y - PlayerPos.Y)
			if HeightDiff > 10 then continue end

			local HorizontalDist = GetDistanceXZ(ModelPos, PlayerPos)

			if HorizontalDist < (DistanceFromPlayer or 10) then
				return true
			end
		end
	end

	MachineHandler = function()
		local Char = Client.Character
		local Root = GetRoot(Char)

		if Char and Root then
			if not CollectionService:HasTag(Char, 'Training') then
				local function GetBestMachine()
					local _, Trainings = HiddenFlags.Game.TrainingsIndexed()
					local Machines = Trainings[Flags.Machines.Selected]

					local LastMachine = HiddenFlags.LastMachine[Machines.Name]
					if LastMachine and not (LastMachine['ProximityPrompt'].MaxActivationDistance > 0) then -- and not IsPlayerNearModel(LastMachine, Flags.MachineDistanceFromPlayer)
						return LastMachine['Instance']
					end

					for i,v in Machines and Machines:GetChildren() or {} do
						local ProximityPrompt = v:FindFirstChild('TriggerProximity', true)
						if not ProximityPrompt then continue end

						if ProximityPrompt.MaxActivationDistance == 0 then continue end

						if IsPlayerNearModel(v, Flags.MachineDistanceFromPlayer) then continue end

						HiddenFlags.LastMachine[Machines.Name] = {Instance = v, ProximityPrompt = ProximityPrompt}
						return v, ProximityPrompt
					end
				end

				local Machine, ProximityPrompt = GetBestMachine()

				if Machine then
					local TeleportPart = Machine.PrimaryPart or Machine:FindFirstChildWhichIsA('Part') or Machine

					if Machine.Name == 'Treadmill' then
						TeleportPart = Machine
					end

					if TeleportPart then
						local MachinePivot = TeleportPart:GetPivot()
						local Dist = GetDistanceXZ(Root.Position, MachinePivot.Position)

						if Dist > 6 then
							MoveTo(MachinePivot.Position + vector.create(0, -6, 0))
						end

						Root.CFrame = MachinePivot

						if ProximityPrompt and os.clock() - (HiddenFlags.Prompts[ProximityPrompt] or 0) > 1 then
							HiddenFlags.Prompts[ProximityPrompt] = os.clock()
							fireproximityprompt(ProximityPrompt)

							local function GetBestWeight()
								local Indexed = {}

								for Name, Obj in PlayerGui.HUD.Miscs.Weights.Options:GetChildren() do
									if tonumber(Obj.Name) then
										table.insert(Indexed, tonumber(Obj.Name))
									end
								end

								table.sort(Indexed, function(A, B)
									return A > B
								end)

								for _, Index in ipairs(Indexed) do
									local Option = PlayerGui.HUD.Miscs.Weights.Options[tostring(Index)]
									local Title = Option and Option:FindFirstChild("Frame") and Option.Frame:FindFirstChild("Title")

									if Title then
										local Color = Title.TextColor3
										local IsRed = Color.R == 1 and Color.G == 0 and Color.B == 0 -- 255,0,0 normalized

										if not IsRed then
											return Option
										end
									end
								end
							end

							local WeightButton = GetBestWeight()

							if WeightButton then
								for i,v in getconnections(WeightButton.MouseButton1Click) do
									v:Fire()
								end
							end

							HiddenFlags.DestinationLevel = Root.Position.Y

							if HiddenFlags.SessionStats and os.clock() - HiddenFlags.SessionStats.LastMachineFinished > 2 then
								HiddenFlags.SessionStats.MachinesFinished += 1
								HiddenFlags.SessionStats.LastMachineFinished = os.clock()
							end
						end
					else
						local MachinePivot = Machine:GetPivot()
						MoveTo(vector.create(MachinePivot.Position.X, HiddenFlags.FloorLevel, MachinePivot.Position.Z))
					end
				else
					Client:Kick('etocats: No available machine')
					task.wait(5)
				end
			end
		end
	end

	GetOffMachine = function()
		local Char = Client.Character
		local Root = GetRoot(Char)

		if Char and Root and Root.Anchored then
			VirtualInputManager:SendKeyEvent(true, 'Space', false, game)
			VirtualInputManager:SendKeyEvent(false, 'Space', false, game)

			return Root.Anchored
		end
	end

	GetClosestATM = function()
		local Dist, Closest = math.huge

		local Char = Client.Character
		local Root = GetRoot(Char)

		if (Root) then
			for i,v in HiddenFlags.Game.ATMs:GetChildren() do
				local mag = vector.magnitude(v:GetPivot().Position - Root.Position)

				if (mag < Dist) then
					Dist = mag
					Closest = v
				end
			end
		end

		return Closest
	end

	Withdraw = function(Amount)
		local Char = Client.Character
		local Root = GetRoot(Char)
		local ATMFrame = PlayerGui.HUD.Tabs:FindFirstChild('ATM')
		local Withdraw = ATMFrame:FindFirstChild('Withdraw')

		if Char and Root and Withdraw then
			if GetOffMachine() then return true end
			local ATM = GetClosestATM()
			if not ATM then return true end

			MoveTo(ATM:GetPivot().Position + vector.create(0, -6, 0))

			local ClickDetector = ATM.Hitbox:FindFirstChildWhichIsA('ClickDetector')
			fireclickdetector(ClickDetector)

			ATMFrame.AmountBox.Text = tostring(Amount)

			if ATMFrame.Visible then
				local Signal = getconnections(Withdraw.MouseButton1Click)[2]

				if Signal then
					Signal:Fire()
				end
			end

			return true
		end
	end

	Deposit = function(Amount)
		local Char = Client.Character
		local Root = GetRoot(Char)
		local ATMFrame = PlayerGui.HUD.Tabs:FindFirstChild('ATM')
		local Deposit = ATMFrame:FindFirstChild('Deposit')

		if Char and Root and Deposit then
			if GetOffMachine() then return true end
			local ATM = GetClosestATM()
			if not ATM then return true end

			MoveTo(ATM:GetPivot().Position + vector.create(0, -6, 0))

			local ClickDetector = ATM.Hitbox:FindFirstChildWhichIsA('ClickDetector')
			fireclickdetector(ClickDetector)

			ATMFrame.AmountBox.Text = tostring(Amount)

			if ATMFrame.Visible then
				local Signal = getconnections(Deposit.MouseButton1Click)[2]

				if Signal then
					Signal:Fire()
				end
			end

			return true
		end
	end

	SpawnProtection = function()
		local Char = Client.Character

		if Char then
			local SpawnIFrames = Char:FindFirstChildWhichIsA('Highlight')

			if SpawnIFrames then
				local ActiveFarms, ActiveHelpers = IsFarmingActive()

				if ActiveFarms or ActiveHelpers then
					HiddenFlags.SpawnProtectRun = true
					VirtualInputManager:SendKeyEvent(true, 'W', false, game)

					return true
				end
			elseif HiddenFlags.SpawnProtectRun then
				VirtualInputManager:SendKeyEvent(false, 'W', false, game)
				HiddenFlags.SpawnProtectRun = false
			end
		end
	end

	CheckEnoughMoney = function()
		local Wallet = HiddenFlags.ClientData.Cash.Value

		if Wallet and Wallet < HiddenFlags.Thresholds.MinWallet then
			if GetOffMachine() then return true end

			Withdraw(HiddenFlags.Thresholds.MinWallet)
			return true
		end
	end

	SafeProximityPrompt = function(Prompt)
		if not Prompt then return end

		if Prompt.Enabled and Prompt.MaxActivationDistance > 0 and os.clock() - (HiddenFlags.Prompts[Prompt] or 0) > 1 then
			HiddenFlags.Prompts[Prompt] = os.clock()
			fireproximityprompt(Prompt)
			return true
		end
	end

	AnswerDialogue = function(Choice)
		local Cancel = 'End Dialogue'
		local NumToEnum = {
			['1'] = 'One',
			['2'] = 'Two',
			['3'] = 'Three',
			['4'] = 'Four',
			['5'] = 'Five',
			['6'] = 'Six',
			['7'] = 'Seven',
			['8'] = 'Eight',
			['9'] = 'Nine',
			['0'] = 'Zero',
		}

		for i,v in PlayerGui.HUD.Main.Dialogue.Options:GetChildren() do
			if not v:IsA('ImageButton') then continue end

			local TextLabel = v:FindFirstChildWhichIsA('TextLabel')

			if TextLabel.Text:find(Choice) or TextLabel.Text:find(Cancel) then
				local Key = NumToEnum[v.Name]
				local KeyCode = Key and Enum.KeyCode[Key]

				if KeyCode then
					VirtualInputManager:SendKeyEvent(true, KeyCode, false, game)
					VirtualInputManager:SendKeyEvent(false, KeyCode, false, game)
					return true
				end
			end
		end
	end

	RoadworkHandler = function()
		local Char = Client.Character
		local Root = GetRoot(Char)

		if Char and Root then
			local IsRoadworking = PlayerGui.HUD.Miscs.Roadwork.Visible and PlayerGui.HUD.Miscs.Roadwork.Position.X.Scale >= 0

			if IsRoadworking then
				local function GetRoadwork()
					for i,v in HiddenFlags.Game.Roadworks:GetDescendants() do
						if not v:IsA('BillboardGui') then continue end

						return v.Parent
					end
				end

				local Roadwork = GetRoadwork()

				if Roadwork then
					local RoadworkPosition = Roadwork:GetPivot().Position
					MoveTo(RoadworkPosition + vector.create(0, -9 + Flags.RoadworkHeightAdjustment, 0))
					SmartWait(0.05, 'AutoRoadwork')
				end
			else
				local Saitama = HiddenFlags.Game.NPCs["Important NPCs"].Saitama
				MoveTo(Saitama:GetPivot().Position + vector.create(0, -6, 0))

				local ProximityPrompt = Saitama.HumanoidRootPart:FindFirstChildWhichIsA('ProximityPrompt')
				SafeProximityPrompt(ProximityPrompt)

				AnswerDialogue('Hey, can you show me some training routes?')

				if AnswerDialogue(Flags.AutoRoadworkType == 'Long' and 'Long run' or 'Short run') then
					if HiddenFlags.SessionStats and os.clock() - HiddenFlags.SessionStats.LastRoadworkFinished > 2 then
						HiddenFlags.SessionStats.RoadworksFinished += 1
						HiddenFlags.SessionStats.LastRoadworkFinished = os.clock()
					end
				end
			end
		end
	end

	GetBed = function()
		for i, v in HiddenFlags.Game.Beds:GetChildren() do
			if not (v.Name == 'mesa massagem' and not v:GetAttribute('Used') and not v:GetAttribute('BeingUsed')) then continue end
			return true, true
		end

		for i, v in HiddenFlags.Game.Beds:GetChildren() do
			if (v.Name == 'mesa massagem') then continue end

			local ProximityPrompt = v.CharLoc:FindFirstChild('ProximityPrompt')
			if not ProximityPrompt or ProximityPrompt.MaxActivationDistance == 0 then continue end

			return ProximityPrompt
		end
	end

	FatigueHandler = function()
		local Char = Client.Character
		local Root = GetRoot(Char)

		if Char and Root then
			if HiddenFlags.IsSleeping then
				if not HiddenFlags.ShouldSleep then
					GetOffBed()
				end
			elseif HiddenFlags.ShouldSleep then
				local Bed, IsPremium = GetBed()
				if Root.Anchored then return true end
				if not Bed then Client:Kick('No Beds') end

				if IsPremium then
					if CheckEnoughMoney() then return end
					local Lofi = HiddenFlags.Game.NPCs["Important NPCs"].Lofi
					MoveTo(Lofi:GetPivot().Position + vector.create(0, -6, 0))

					local ProximityPrompt = Lofi.HumanoidRootPart:FindFirstChildWhichIsA('ProximityPrompt')
					SafeProximityPrompt(ProximityPrompt)

					AnswerDialogue('What can you do for me')

					if AnswerDialogue('take a massage') then
						if Root.Anchored then
							HiddenFlags.IsSleeping = true
						end
					end
				else
					SafeProximityPrompt(Bed)

					if Root.Anchored then
						HiddenFlags.IsSleeping = true
					end
				end
			end
		end
	end

	TrainingToolHandler = function()
		local Char = Client.Character
		if not Char then return end

		local Hum = GetHum(Char)
		if not Hum then return end

		if Flags.AutoTrainingTool then
			local Item, Inventory = CheckInventory(Flags.TrainingTools.Selected)

			if Item then
				if Inventory then
					if not CollectionService:HasTag(Char, 'Training') then
						ClickButton('TopLeft')
						SmartWait(0.1)
					end
				else
					Hum:EquipTool(Item)
				end
			else
				HandleItem(HiddenFlags.Game.Buyables[Flags.TrainingTools.Selected], 'AutoTrainingTool')
			end
		end
	end

	GetBestJob = function(Board)
		local Highest, Best = 0

		local Char = Client.Character
		local Root = GetRoot(Char)

		if (Root) then
			for i,v in Board.Posters:GetChildren() do
				if (v.SurfaceGui.Info.Text:lower():find('graffiti') or
					v.SurfaceGui.Info.Text:lower():find('deliver') or
					v.SurfaceGui.Info.Text:lower():find('posters') or
					v.SurfaceGui.Info.Text:lower():find('trashbags') or
					v.SurfaceGui.Info.Text:lower():find('dirt')) then continue end -- These will be disabled from auto job

				local Price = v.SurfaceGui:FindFirstChild('Reward') and
								v.SurfaceGui.Reward.Text and
								tonumber(v.SurfaceGui.Reward.Text:gsub("[^%d,]", ""):gsub(",", ""):gmatch("%d+")())

				if Price and Price > Highest then
					Highest = Price
					Best = v
				end
			end
		end

		return Best
	end


	GetClosestJobBoard = function()
		local Dist, Closest = math.huge

		local Char = Client.Character
		local Root = GetRoot(Char)

		if (Root) then
			for i,v in (HiddenFlags.Game.JobBoards:GetChildren()) do
				if (not GetBestJob(v)) then continue end
				if (v:GetPivot().Position.Y > 500) then continue end

				local Mag = vector.magnitude(v:GetPivot().Position - Root.Position)

				if (Mag < Dist) then
					Dist = Mag
					Closest = v
				end
			end
		end

		return Closest
	end

	GetClosestJobPart = function()
		local Dist, Closest = math.huge

		local Char = Client.Character
		local Root = GetRoot(Char)

		if (Root) then
			for i,v in (HiddenFlags.Game.JobsRelated:GetDescendants()) do
				if not v:IsA('BillboardGui') or not v.Adornee or not v.Enabled then continue end
				local Mag = vector.magnitude(v.Adornee.Position - Root.Position)

				if (Mag < Dist) then
					Dist = Mag
					Closest = v.Adornee
				end
			end

			for i,v in (HiddenFlags.Game.VFXFolder:GetChildren()) do
				local BillboardGui = v:FindFirstChildWhichIsA('BillboardGui')
				if not BillboardGui or not BillboardGui.Adornee or not BillboardGui.Enabled then continue end

				local Mag = vector.magnitude(BillboardGui.Adornee.Position - Root.Position)

				if (Mag < Dist) then
					Dist = Mag
					Closest = BillboardGui.Adornee
				end
			end
		end

		return Closest
	end

	JobHandler = function()
		local Char = Client.Character
		local Root = GetRoot(Char)
		if not Root then return end

		if Flags.JobType == 'Job Board' then
			local Job = GetClosestJobPart()

			if Job then
				MoveTo(Job:GetPivot().Position + vector.create(0, -20, 0))

				local ClickDetector = Job:FindFirstChildWhichIsA('ClickDetector')

				if ClickDetector then
					MoveTo(Job:GetPivot().Position + vector.create(0, -6, 0))
					SmartWait(0.2, 'JobFarm')
					fireclickdetector(ClickDetector)
					return
				end

				local TouchTransmitter = Job:FindFirstChildWhichIsA('TouchTransmitter')

				if TouchTransmitter then
					MoveTo(Job:GetPivot().Position + vector.create(0, -20, 0))
					SmartWait(0.05, 'JobFarm')
					firetouchinterest(Root, Job, 1)
				end
			else
				local Root = GetRoot(Client.Character)
				local JobPart = GetClosestJobBoard()

				if JobPart and Root then
					MoveTo(JobPart:GetPivot().Position + vector.create(0, -9, 0))
					SmartWait(0.2, 'JobFarm')

					local BestJob = GetBestJob(JobPart)

					if BestJob then
						local ClickDetector = BestJob:FindFirstChildWhichIsA('ClickDetector', true)

						if ClickDetector then
							fireclickdetector(ClickDetector)
							SmartWait(0.6, 'JobFarm')
						end
					end
				end
			end
		else
			local IsNurse = Char:GetAttribute('Nurse')

			local function GetPatient()
				for i,v in HiddenFlags.Game.NPCs.Miscs:GetChildren() do
					if not v:IsA('Model') then continue end

					local ProximityPrompt = v:FindFirstChildWhichIsA('ProximityPrompt')
					if not ProximityPrompt then continue end

					if ProximityPrompt.MaxActivationDistance == 0 then continue end

					return v, ProximityPrompt
				end
			end

			local Patient, ProximityPrompt = GetPatient()
			if Flags.RejoinNoPatients and not Patient then Client:Kick('etocats: No more patients') task.wait(5) end

			for i,v in Players:GetPlayers() do
				if v == Client then continue end
				
				local TChar = v.Character
				if not TChar then continue end

				if TChar:GetAttribute('Nurse') then
					Client:Kick('etocats: other nurses in game.')
					task.wait(5)
				end
			end

			if IsNurse then
				if Patient and ProximityPrompt then
					local PatientPivot = Patient:GetPivot()
					MoveTo(PatientPivot.Position + vector.create(0, -6, 0))
					-- local Type = math.floor(PatientPivot.Position.Z) == 113

					-- MoveTo(PatientPivot.Position + vector.create(0, 0, (Type and 7 or -7)), 415)

					fireproximityprompt(ProximityPrompt)
				end
			else
				local Makima = HiddenFlags.Game.NPCs["Important NPCs"].Makima
				MoveTo(Makima:GetPivot().Position + vector.create(0, -6, 0))

				local ProximityPrompt = Makima:FindFirstChildWhichIsA('ProximityPrompt', true)
				SafeProximityPrompt(ProximityPrompt)

				if AnswerDialogue('I was wondering if I could help around the hospital?') then
					SmartWait(0.2)
				end
			end
		end
	end

	FormatNumber = function(N)
		if type(N) ~= "number" or N ~= N or N == math.huge or N == -math.huge then
			return "0"
		end

		local sign = N < 0 and "-" or ""
		N = math.abs(N)

		local str = string.format("%.2f", N)
		local int, frac = str:match("^(%d+)%.(%d+)$")

		int = int:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")

		return sign .. int .. "." .. frac
	end

	FormatElapsed = function(seconds)
		local h = math.floor(seconds / 3600)
		local m = math.floor((seconds % 3600) / 60)
		local s = seconds % 60
		return string.format("%d:%02d:%02d", h, m, s)
	end

	IsFarmingActive = function()
		local Farms = HiddenFlags.CurrentlyMoving
			or Flags.AutoTrainingTool
			or Flags.AutoMachine
			or Flags.JobFarm
			or Flags.AutoRoadwork
			or Flags.ShadowFarm
			or Flags.PunchingBag

		local Helpers = (Flags.AutoEat and HiddenFlags.ShouldEat)
			or (Flags.AutoFatigue and HiddenFlags.ShouldSleep)
			or (Flags.AutoWorkoutDrink and HiddenFlags.ShouldWorkoutDrink)
			or HiddenFlags.BossWaiting

		return Farms, Helpers
	end

	GetCollectiveMoney = function()
		local Wallet = HiddenFlags.ClientData.Cash.Value
		local Bank = HiddenFlags.ClientData.Bank.Balance.Value

		if Wallet and Bank then return Wallet + Bank end
	end

	CalculateTotalPower = function(Player)
		local PlayerData = HiddenFlags.PlayersData:FindFirstChild(Player.Name)
		local Statistics = PlayerData and PlayerData:FindFirstChild('Statistics')
		local TotalPower = 0
		local BasePower = Player.Character and Utility.GetTP(Player.Character) or 0

		TotalPower += BasePower

		for i,v in Statistics and Statistics:GetChildren() or {} do
			if table.find({'UM', 'LM'}, v.Name) then continue end

			TotalPower += v.Value
		end	

		return TotalPower
	end

	EnsureSession = function()
		if HiddenFlags.SessionStats then return end

		local Char = Client.Character
		if not Char then return end

		HiddenFlags.SessionStats = {
			StartTime = os.clock(),
			RoadworksFinished = -1,
			MachinesFinished = -1,
			ShadowsFinished = -1,
			PunchingBagFinished = -1,
			BossesFought = 0,
			LastBossFinished = 0,
			LastShadowFinished = 0,
			LastMachineFinished = 0,
			LastRoadworkFinished = 0,
			LastPunchingBagFinished = 0,
			MoneyBaseline = GetCollectiveMoney() or 0,

			Base = {
				TotalPower = CalculateTotalPower(Client),
				Stamina = HiddenFlags.ClientData.Statistics.ST.Value or 0,
				Agility = HiddenFlags.ClientData.Statistics.AG.Value or 0,
				BattleSense = HiddenFlags.ClientData.Statistics.BS.Value or 0,
				Durability = HiddenFlags.ClientData.Statistics.DUR.Value or 0,
				Strength = HiddenFlags.ClientData.Statistics.STR.Value or 0,
				UpperMuscle = HiddenFlags.ClientData.Statistics.UM.Value or 0,
				UpperMuscleMemory = HiddenFlags.ClientData.MuscleMemory.UM.Value or 0,
				LowerMuscle = HiddenFlags.ClientData.Statistics.LM.Value or 0,
				LowerMuscleMemory = HiddenFlags.ClientData.MuscleMemory.LM.Value or 0,
				Fat = HiddenFlags.ClientData.Fat.Value or 0,
			}
		}
	end

	EndSession = function()
		HiddenFlags.SessionStats = nil
	end

	GetPlusDelta = function(Label, Current, BaseTable)
		if not HiddenFlags.SessionStats then return "" end

		local Base = BaseTable[Label]
		if Base == nil then return "" end

		local Delta = (Current or 0) - Base
		if Delta > -1 and Delta < 1 then return "" end

		local Sign = Delta > 0 and "+" or ""
		return (" (%s%d Since Farming)"):format(Sign, Delta)
	end

	StatViewHandler = function()
		local Char = Client.Character
		local Root = GetRoot(Char)
		if not (Char and Root) then return end

		local Data = ''

		if HiddenFlags.LastKickMessage then
			Data ..= 'Last Kick Message: ' .. HiddenFlags.LastKickMessage .. '\n'
		end

		if HiddenFlags.SessionStats then
			local Elapsed = math.max(0, math.floor(os.clock() - (HiddenFlags.SessionStats.StartTime or os.clock())))
			local MoneyNow = GetCollectiveMoney() or HiddenFlags.SessionStats.MoneyBaseline
			local MoneyEarned = (MoneyNow or 0) - (HiddenFlags.SessionStats.MoneyBaseline or 0)

			if Flags.AutoRoadwork then
				Data ..= ("Roadworks Finished: %d\n"):format(HiddenFlags.SessionStats.RoadworksFinished)
			end

			if Flags.AutoMachine then
				Data ..= ("Machines Finished: %d\n"):format(HiddenFlags.SessionStats.MachinesFinished)
			end

			Data ..= ("Money Earned: %s\n"):format(FormatNumber(MoneyEarned))
			Data ..= ("Time Elapsed: %s\n"):format(FormatElapsed(Elapsed))

			if os.clock() - HiddenFlags.LastWebHookSentData > Flags.WebHookDataSendDelay then
				HiddenFlags.LastWebHookSentData = os.clock()
				local Data = HiddenFlags.StatsData and HiddenFlags.StatsData.Value or ''
				SendData('✔ Data Received.'..(Data ~= '' and '\n' or '')..Data)

				if Data == 'error...' then
					HiddenFlags.LastWebHookSentData = os.clock() - (Flags.WebHookDataSendDelay + 10)
				end
			end
		end

		local tp = math.floor(CalculateTotalPower(Client))
		local stam = math.floor(HiddenFlags.ClientData.Statistics.ST.Value or 0)
		local agi  = math.floor(HiddenFlags.ClientData.Statistics.AG.Value or 0)
		local dex  = math.floor(HiddenFlags.ClientData.Statistics.BS.Value or 0)
		local dur  = math.floor(HiddenFlags.ClientData.Statistics.DUR.Value or 0)
		local str  = math.floor(HiddenFlags.ClientData.Statistics.STR.Value or 0)
		local upmus  = (HiddenFlags.ClientData.Statistics.UM.Value or 0)
		local upmusmem  = (HiddenFlags.ClientData.MuscleMemory.UM.Value or 0)
		local lomus  = (HiddenFlags.ClientData.Statistics.LM.Value or 0)
		local lomusmem  = (HiddenFlags.ClientData.MuscleMemory.LM.Value or 0)
		local fat  = (HiddenFlags.ClientData.Fat.Value or 0)

		local baseRef = HiddenFlags.SessionStats and HiddenFlags.SessionStats.Base or {}

		Data ..= ('Bank: %s\n'):format(FormatNumber(HiddenFlags.ClientData.Bank.Balance.Value or 0))
		Data ..= ('Wallet: %s\n'):format(FormatNumber(HiddenFlags.ClientData.Cash.Value or 0))
		Data ..= ('Employee Level: %d\n'):format(HiddenFlags.ClientData.EmployeeLevel.Value or 0)
		Data ..= ('Total Power: %d%s\n'):format(tp, GetPlusDelta('TotalPower', tp, baseRef))
		Data ..= ('Stamina: %d%s\n'):format(stam, GetPlusDelta('Stamina', stam, baseRef))
		Data ..= ('Agility: %d%s\n'):format(agi, GetPlusDelta('Agility', agi, baseRef))
		Data ..= ('Battle Sense: %d%s\n'):format(dex, GetPlusDelta('BattleSense', dex, baseRef))
		Data ..= ('Durability: %d%s\n'):format(dur, GetPlusDelta('Durability', dur, baseRef))
		Data ..= ('Upper Muscle: %d%s\n'):format(upmus, GetPlusDelta('UpperMuscle', upmus, baseRef))
		Data ..= ('Upper Muscle Memory: %d%s\n'):format(upmusmem, GetPlusDelta('UpperMuscleMemory', upmusmem, baseRef))
		Data ..= ('Lower Muscle: %d%s\n'):format(lomus, GetPlusDelta('LowerMuscle', lomus, baseRef))
		Data ..= ('Lower Muscle Memory: %d%s\n'):format(lomusmem, GetPlusDelta('LowerMuscleMemory', lomusmem, baseRef))
		Data ..= ('Fat: %d%s\n'):format(fat, GetPlusDelta('Fat', fat, baseRef))
		Data ..= ('Strength: %d%s\n'):format(str, GetPlusDelta('Strength', str, baseRef))
		Data ..= ('Fatigue: %d\n'):format(math.floor(HiddenFlags.ClientData.Fatigue.Value or 0))
		Data ..= ('Height: %d\n'):format(math.floor(HiddenFlags.ClientData.Height.Value or 0))
		Data ..= ('Weight: %d'):format(math.floor(Utility.GetWeight(Char) or 0))

		HiddenFlags.StatsData:SetValue(Data)
	end

	HandleSession = function()
		local ActiveFarms, ActiveHelpers = IsFarmingActive()

		if ActiveFarms or ActiveHelpers then
			EnsureSession()
		elseif HiddenFlags.SessionStats then
			EndSession()
		end
	end

	HandleNoClip = function()
		local Char = Client.Character
		local Root = GetRoot(Char)

		if Char and Root then
			local ActiveFarms, ActiveHelpers = IsFarmingActive()
			HiddenFlags.NoClipEnabled = ActiveFarms or ActiveHelpers

			if ActiveFarms or ActiveHelpers then
				for i,v in Char:GetDescendants() do
					if v:IsA('BasePart') then
						v.CanCollide = false
					end
				end
			end
		end
	end

	HandleResetPosition = function()
		local Char = Client.Character
		local Root = GetRoot(Char)
		local Hum = Char:FindFirstChildWhichIsA('Humanoid')

		if Char and Root then
			if HiddenFlags.NoClipEnabled then
				HiddenFlags.Parts.FakeVisual.CFrame = CFrame.new(Root.Position.X, HiddenFlags.DestinationLevel or HiddenFlags.NormalLevel, Root.Position.Z)
				Camera.CameraSubject = Root.Anchored and Char or HiddenFlags.Parts.FakeVisual

				if not Char:FindFirstChildWhichIsA('ForceField') then
					for i,v in not Root.Anchored and Hum and Hum:GetPlayingAnimationTracks() or {} do
						v:Stop()
					end
				end

				Root.AssemblyLinearVelocity = vector.zero
			else
				if Camera.CameraSubject == HiddenFlags.Parts.FakeVisual then
					Root.CFrame = CFrame.new(Root.Position.X, HiddenFlags.NormalLevel, Root.Position.Z)
					Camera.CameraSubject = Char
				end
			end
		end
	end

	StateHandler = function()
		local Char = Client.Character
		local Hum = GetHum(Char)

		if Char and Hum then
			local Fatigue = HiddenFlags.ClientData.Fatigue.Value
			local Hunger = HiddenFlags.ClientData.Hunger.Value

			local Stamina = Client:GetAttribute('Stamina') or 100
			local MaxStamina = Client:GetAttribute('MaxStamina') or 100
			local StamPercent = (Stamina / MaxStamina) * 100

			HiddenFlags.ShouldWorkoutDrink = not Char:GetAttribute('XPBoost')
			HiddenFlags.Dialogue = PlayerGui.HUD.Main.Dialogue.Visible and PlayerGui.HUD.Main.Dialogue.Position.Y.Scale < 1

			if HiddenFlags.Dialogue then
				Hum:UnequipTools()
			end

			if StamPercent then
				if StamPercent < HiddenFlags.Thresholds.StaminaLow then
					HiddenFlags.StaminaWait = true
				elseif StamPercent > HiddenFlags.Thresholds.StaminaHigh then
					HiddenFlags.StaminaWait = false
				end
			end

			if Hunger then
				if Hunger < HiddenFlags.Thresholds.HungerLow then
					HiddenFlags.ShouldEat = true
				elseif Hunger > HiddenFlags.Thresholds.HungerHigh then
					HiddenFlags.ShouldEat = false
				end
			end

			if Fatigue then
				if Fatigue > HiddenFlags.Thresholds.FatigueMax then
					HiddenFlags.ShouldSleep = true
				elseif Fatigue <= 0 then
					HiddenFlags.ShouldSleep = false
				end
			end
		end
	end

	GetOffBed = function()
		local Char = Client.Character
		local Root = GetRoot(Char)

		if Char and Root then
			local Humanoid = Char:FindFirstChildWhichIsA('Humanoid')

			if Humanoid and HiddenFlags.IsSleeping then
				-- Char.Humanoid.Jump = true
				VirtualInputManager:SendKeyEvent(true, 'Space', false, game)
				VirtualInputManager:SendKeyEvent(false, 'Space', false, game)

				if not Root.Anchored then
					HiddenFlags.IsSleeping = false
				end

				return Root.Anchored
			end
		end
	end

	SteppedLoop = function()
		AutoCompleteKeyPressMinigame()
		HandleSession()
		HandleNoClip()
		HandleResetPosition()
		StateHandler()
		StatViewHandler()
	end

	MainMenuHandler = function()
		if not (Client:GetAttribute('Loaded') and Client:GetAttribute('LoadedTools')) then
			return true
		end
	end

	WalletHandler = function()
		local Wallet = HiddenFlags.ClientData.Cash.Value
		local Bank = HiddenFlags.ClientData.Bank.Balance.Value

		if Wallet then
			if Flags.AutoWithdraw and HiddenFlags.ClientData.Cash.Value <= HiddenFlags.Thresholds.MinWallet and Bank > 0  then
				if GetOffMachine() then return true end
				local NeededAmount = HiddenFlags.Thresholds.MaxWallet - HiddenFlags.Thresholds.MinWallet

				Withdraw(Bank >= NeededAmount and NeededAmount or Bank)
				return true
			end

			if Flags.AutoDeposit and Wallet >= HiddenFlags.Thresholds.MaxWallet and Bank <= HiddenFlags.Thresholds.MaxBank then
				if GetOffMachine() then return true end

				Deposit(HiddenFlags.Thresholds.MaxWallet - (HiddenFlags.Thresholds.MinWallet * 2))
				return true
			end
		end
	end

	CalculatePingWait = function(n)
		if Flags.UseCustomDelay then
			n += Flags.CustomDelay / 1000
		else
			local Ping = Stats.PerformanceStats.Ping:GetValue() / 1000
			n -= Ping * (Flags.PingAdjustmentPercentage / 100)
		end

		return n
	end

	Signal = function()
		--- Lua-side duplication of the API of events on Roblox objects.
		-- Signals are needed for to ensure that for local events objects are passed by
		-- reference rather than by value where possible, as the BindableEvent objects
		-- always pass signal arguments by value, meaning tables will be deep copied.
		-- Roblox's deep copy method parses to a non-lua table compatable format.
		-- @classmod Signal

		local Signal = {}
		Signal.__index = Signal
		Signal.ClassName = "Signal"

		--- Constructs a new signal.
		-- @constructor Signal.new()
		-- @treturn Signal
		function Signal.new()
			local self = setmetatable({}, Signal)

			self._bindableEvent = Instance.new("BindableEvent")
			self._argData = nil
			self._argCount = nil -- Prevent edge case of :Fire("A", nil) --> "A" instead of "A", nil

			return self
		end

		function Signal.isSignal(object)
			return typeof(object) == 'table' and getmetatable(object) == Signal;
		end;

		--- Fire the event with the given arguments. All handlers will be invoked. Handlers follow
		-- Roblox signal conventions.
		-- @param ... Variable arguments to pass to handler
		-- @treturn nil
		function Signal:Fire(...)
			self._argData = {...}
			self._argCount = select("#", ...)
			self._bindableEvent:Fire()
			self._argData = nil
			self._argCount = nil
		end

		--- Connect a new handler to the event. Returns a connection object that can be disconnected.
		-- @tparam function handler Function handler called with arguments passed when `:Fire(...)` is called
		-- @treturn Connection Connection object that can be disconnected
		function Signal:Connect(handler)
			if not self._bindableEvent then return error("Signal has been destroyed"); end --Fixes an error while respawning with the UI injected

			if not (type(handler) == "function") then
				error(("connect(%s)"):format(typeof(handler)), 2)
			end

			return self._bindableEvent.Event:Connect(function()
				handler(unpack(self._argData, 1, self._argCount))
			end)
		end

		--- Wait for fire to be called, and return the arguments it was given.
		-- @treturn ... Variable arguments from connection
		function Signal:Wait()
			self._bindableEvent.Event:Wait()
			assert(self._argData, "Missing arg data, likely due to :TweenSize/Position corrupting threadrefs.")
			return unpack(self._argData, 1, self._argCount)
		end

		--- Disconnects all connected events to the signal. Voids the signal as unusable.
		-- @treturn nil
		function Signal:Destroy()
			if self._bindableEvent then
				self._bindableEvent:Destroy()
				self._bindableEvent = nil
			end

			self._argData = nil
			self._argCount = nil
		end

		return Signal
	end

	Maid = function()
		---	Manages the cleaning of events and other things.
		-- Useful for encapsulating state and make deconstructors easy
		-- @classmod Maid
		-- @see Signal

		local Signal = Signal();
		local tableStr = 'table';
		local classNameStr = 'Maid';
		local funcStr = 'function';
		local threadStr = 'thread';

		local Maid = {}
		Maid.ClassName = "Maid"

		--- Returns a new Maid object
		-- @constructor Maid.new()
		-- @treturn Maid
		function Maid.new()
			return setmetatable({
				_tasks = {}
			}, Maid)
		end

		function Maid.isMaid(value)
			return type(value) == tableStr and value.ClassName == classNameStr
		end

		--- Returns Maid[key] if not part of Maid metatable
		-- @return Maid[key] value
		function Maid.__index(self, index)
			if Maid[index] then
				return Maid[index]
			else
				return self._tasks[index]
			end
		end

		--- Add a task to clean up. Tasks given to a maid will be cleaned when
		--  maid[index] is set to a different value.
		-- @usage
		-- Maid[key] = (function)         Adds a task to perform
		-- Maid[key] = (event connection) Manages an event connection
		-- Maid[key] = (Maid)             Maids can act as an event connection, allowing a Maid to have other maids to clean up.
		-- Maid[key] = (Object)           Maids can cleanup objects with a `Destroy` method
		-- Maid[key] = nil                Removes a named task. If the task is an event, it is disconnected. If it is an object,
		--                                it is destroyed.
		function Maid:__newindex(index, newTask)
			if Maid[index] ~= nil then
				error(("'%s' is reserved"):format(tostring(index)), 2)
			end

			local tasks = self._tasks
			local oldTask = tasks[index]

			if oldTask == newTask then
				return
			end

			tasks[index] = newTask

			if oldTask then
				if type(oldTask) == "function" then
					oldTask()
				elseif typeof(oldTask) == "RBXScriptConnection" then
					oldTask:Disconnect();
				elseif typeof(oldTask) == 'table' then
					oldTask:Remove();
				elseif (Signal.isSignal(oldTask)) then
					oldTask:Destroy();
				elseif (typeof(oldTask) == 'thread') then
					task.cancel(oldTask);
				elseif oldTask.Destroy then
					oldTask:Destroy();
				end
			end
		end

		--- Same as indexing, but uses an incremented number as a key.
		-- @param task An item to clean
		-- @treturn number taskId
		function Maid:GiveTask(task)
			if not task then
				error("Task cannot be false or nil", 2)
			end

			local taskId = #self._tasks+1
			self[taskId] = task

			return taskId
		end

		--- Cleans up all tasks.
		-- @alias Destroy
		function Maid:DoCleaning()
			local tasks = self._tasks

			-- Disconnect all events first as we know this is safe
			for index, task in pairs(tasks) do
				if typeof(task) == "RBXScriptConnection" then
					tasks[index] = nil
					task:Disconnect()
				end
			end

			-- Clear out tasks table completely, even if clean up tasks add more tasks to the maid
			local index, taskData = next(tasks)
			while taskData ~= nil do
				tasks[index] = nil
				if type(taskData) == funcStr then
					taskData()
				elseif typeof(taskData) == "RBXScriptConnection" then
					taskData:Disconnect()
				elseif (Signal.isSignal(taskData)) then
					taskData:Destroy();
				elseif typeof(taskData) == tableStr then
					taskData:Remove();
				elseif (typeof(taskData) == threadStr) then
					task.cancel(taskData);
				elseif taskData.Destroy then
					taskData:Destroy()
				end
				index, taskData = next(tasks)
			end
		end

		--- Alias for DoCleaning()
		-- @function Destroy
		Maid.Destroy = Maid.DoCleaning

		return Maid;
	end

	ListenToChildAdded = function(folder, listener, options)
		options = options or {listenToDestroying = false};

		local createListener = typeof(listener) == 'table' and listener.new or listener;

		assert(typeof(folder) == 'Instance', 'listenToChildAdded folder #1 listener has to be an instance');
		assert(typeof(createListener) == 'function', 'listenToChildAdded #2 listener has to be a function');

		local function onChildAdded(child)
			local listenerObject = createListener(child);

			if (options.listenToDestroying) then
				child.Destroying:Connect(function()
					local removeListener = typeof(listener) == 'table' and (function() local a = (listener.Destroy or listener.Remove); a(listenerObject) end) or listenerObject;

					if (typeof(removeListener) ~= 'function') then
						warn('[Utility] removeListener is not definded possible memory leak for', folder);
					else
						removeListener(child);
					end;
				end);
			end;
		end

		-- debug.profilebegin(string.format('ListenToChildAdded(%s)', folder:GetFullName()));

		for _, child in next, folder:GetChildren() do
			task.spawn(onChildAdded, child);
		end;

		-- debug.profileend();

		return folder.ChildAdded:Connect(createListener);
	end

	ListenToChildRemoving = function(folder, listener)
		local createListener = typeof(listener) == 'table' and listener.new or listener;

		assert(typeof(folder) == 'Instance', 'ListenToChildRemoving folder #1 listener has to be an instance');
		assert(typeof(createListener) == 'function', 'ListenToChildRemoving #2 listener has to be a function');

		return folder.ChildRemoved:Connect(createListener);
	end

	SetupAutoParry = function()
		local AutoParryEntity = {};
		AutoParryEntity.__index = AutoParryEntity;

		function AutoParryEntity.new(character)
			if (character == Client.Character) then return end;

			local self = setmetatable({
				_character = character,
				_name = character.Name,
				_maid = Maid().new(),
				_isPlayer = Players:FindFirstChild(character.Name)
			}, AutoParryEntity)

			self._maid:GiveTask(character:GetPropertyChangedSignal('Parent'):Connect(function()
				local newParent = character.Parent
				if (newParent == nil) then return self:Destroy() end
			end))

			self._maid:GiveTask(ListenToChildAdded(character, function(obj)
				if (obj.Name == 'HumanoidRootPart') then
					self._rootPart = obj
					self:_onHumanoidAdded()
				elseif obj:IsA('Humanoid') then
					self._humanoid = obj
					self:_onHumanoidAdded()
				end
			end))

			self._maid:GiveTask(ListenToChildRemoving(character, function(obj)
				if obj.Name == 'HumanoidRootPart' then
					self._rootPart = nil
					self:_onHumanoidRemoved()
				elseif obj:IsA('Humanoid') then
					self:_onHumanoidRemoved()
					self._humanoid = nil
				end;
			end));

			HiddenFlags.ParryMaid:GiveTask(function()
				self._maid:Destroy();
			end);

			return self;
		end;

		function AutoParryEntity:_onHumanoidAdded()
			if (not self._rootPart or not self._humanoid) then return end;
			local Humanoid = self._humanoid;

			self._maid[Humanoid] = Humanoid.AnimationPlayed:Connect(function(animationTrack)
				if not Flags.AutoParry then return end
				local EntityPos = self._rootPart and self._rootPart.Position;
				local Char = Client.Character
				local Root = GetRoot(Client.Character)
				if (not EntityPos or not Root) then return end;
				if (vector.magnitude(EntityPos - Root.Position) >= 30) then return end;

				if self._isPlayer and (animationTrack.WeightTarget == 0 or animationTrack.Priority == Enum.AnimationPriority.Core) then
					return -- print('dont do', animationTrack.Animation.AnimationId, animationTrack.Priority, animationTrack.WeightTarget, animationTrack.Speed);
				end

				local AnimId = animationTrack.Animation.AnimationId:match('%d+');
				local DataAnim = HiddenFlags.AttackAnims[AnimId]
				local Hum = GetHum(Char)

				if Humanoid and Char and Root and Hum and AnimId and DataAnim then
					if Char:FindFirstChildWhichIsA('ForceField') then return end
					local InStance = Char:FindFirstChild('Combat')

					if InStance then
						if Flags.ParryChance < Random.new():NextInteger(0, 100) then return end

						local PrimaryDodge = Flags.DashFirst and 'Q' or 'F'
						local BlockKey = nil -- PrimaryDodge

						local Type = DataAnim.Type
						local Delay = (Type == 'Normal' or Type == 'Fast' or Type == 'Ranged') and 10 or
							Type == 'MidRanged' and 25 or
							Type == 'Slow' and 40
							or 20

						Delay += DataAnim.Additional

						local WaitedDelay = CalculatePingWait(Delay)

						while (animationTrack.TimePosition / animationTrack.Length) * 100 < WaitedDelay do
							task.wait()
						end

						-- print('Name', Type, 'Length', anim.Length, 'Speed', anim.Speed, 'TimePosition', anim.TimePosition, 'Calculated Ping Wait', WaitedDelay)

						if (not animationTrack.IsPlaying) then return end

						local IsClientRunning = Hum.WalkSpeed > 8
						local TargetVelocity = self._rootPart.AssemblyLinearVelocity
						-- local TargetVelocityMagnitude = vector.magnitude(TargetVelocity)
						-- local IsRunning = TargetVelocityMagnitude > 5
						local IsRunning = Hum.WalkSpeed > 8
						local Distance = vector.magnitude(Root.Position - self._rootPart.Position)
						local ToPlayer = vector.normalize(Root.Position - self._rootPart.Position)

						-- local TargetLook = self._rootPart.CFrame.LookVector
						local TargetCFrame = self._character:GetPivot()
						local TargetLook = TargetCFrame.LookVector
						local FacingDot = vector.dot(TargetLook, ToPlayer)

						-- if library.flags.checkIfFacingTarget then
						-- 	local dotProduct = vector.dot(TargetCFrame.Position - Root.Position, Root.CFrame.LookVector)
						-- 	if (dotProduct <= 0) then return print('Not parrying player is not facing target') end
						-- end

						if Distance > 3 and FacingDot <= 0.3 then -- Checking if Target is Facing Client (0.3 = 72degree, 0.5 = 60 degree)
							return
						end

						if Distance > (Type == 'Ranged' and 20 or Type == 'MidRanged' and 18 or IsRunning and 14 or 10) then -- IsRunning and Flags.DistanceWhileRunning or Flags.DistanceWhileStanding
							return
						end

						if Distance > 3 and IsRunning then -- Checking if Target is going towards Client
							local TargetVelocityUnit = vector.normalize(TargetVelocity)
							local DirectionDot = vector.dot(ToPlayer, TargetVelocityUnit)

							if DirectionDot < -0.3 then
								return
							end
						end

						local Cooldowns = Library.GetLibrary(Char, "Cooldowns")
						local DashCooldown = Cooldowns:Check('dash')
						local Dashing = Char:GetAttribute('dashing')
						local BlockCooldown = Cooldowns:Check('Blocking')
						local Blocking = Char:GetAttribute('Blocking')

						local DashCD = not (DashCooldown and Dashing)
						local DodgeCD = not (BlockCooldown and Blocking)

						if Flags.AlternateEvade then
							if PrimaryDodge == "Q" then
								-- Q = Dash, F = Dodge
								if DashCD then
									BlockKey = "Q" -- prioritize Dash
								elseif DodgeCD then
									BlockKey = "F" -- fallback to Dodge
								end
							else
								-- F = Dash, Q = Dodge
								if DodgeCD then
									BlockKey = "F"
								elseif DashCD then
									BlockKey = "Q"
								end
							end
						else
							if PrimaryDodge == "Q" then
								if DashCD then
									BlockKey = "Q"
								end
							else
								if DodgeCD then
									BlockKey = "F"
								end
							end
						end

						if Flags.AutoCounter then
							local Counter = CheckHotbar('Counter') or CheckHotbar('Lightning Counter')

							if Counter then
								if BlockKey then
									BlockKey = Random.new():NextInteger(0, 100) > 50 and Counter or BlockKey
								else
									BlockKey = Counter
								end
							end
						end

						if Flags.DisableDodgeWhileClientRunning and IsClientRunning and BlockKey == 'F' then
							BlockKey = DashCD <= 0 and 'Q'
						end

						local Pressed = Block(true, BlockKey)

						task.delay(0.65, function()
							Block(false, BlockKey)
						end)

						if Flags.AlternateEvade and DataAnim.DashAway then
							local DashCD = Char:GetAttribute("DashCooldown") or 0

							if DashCD <= 0 then
								Block(true, 'Q')
								Block(false, 'Q')
							end
						end

						if Flags.DebugParry then
							local DebugFlags = {}

							if type(Flags.DebugParry) == 'string' then
								DebugFlags = string.split(Flags.DebugParry, ' ')
							end

							local Skip = false

							if type(Flags.DebugParry) == 'string' then
								for _, Flag in DebugFlags do
									if Flag == 'NOM1' and DataAnim.Name:find(' M1: ') then
										Skip = true
										break
									elseif Flag == 'NOHEAVY' and DataAnim.Name:find(' Heavy') then
										Skip = true
										break
									end
								end
							end

							if not Skip then
								Library:Notify{
									Title = 'Attempting to Parry',
									Content = 'Pressing ' .. Pressed,
									SubContent = DataAnim.Name .. ' | ' .. DataAnim.Type .. ' | Delay ' .. math.round(WaitedDelay * 100) / 100,
									Duration = 5
								}
							end
						end
					end
				end
			end);
		end;

		function AutoParryEntity:_onHumanoidRemoved()
			local Humanoid = self._humanoid;
			if (not Humanoid) then return end;
			self._maid[Humanoid] = nil;
		end;

		function AutoParryEntity:Destroy()
			self._maid:Destroy();
		end;

		HiddenFlags.Maid.autoParryOnNewCharacter = ListenToChildAdded(workspace.LivingBeings, AutoParryEntity);
		HiddenFlags.Maid.autoParryMobsOnNewCharacter = ListenToChildAdded(workspace.LivingBeings.Mobs, AutoParryEntity);
	end

	PlayerAddedHandler = function(Player)
		if (not Player or not Player:IsA('Player')) then return end

		if (not HiddenFlags.BlacklistedUIDs[Player.UserId]) then
			if (not Player:IsInGroup(HiddenFlags.TargetGroup)) then return end
			if (not Player:GetRoleInGroup(HiddenFlags.TargetGroup)) then return end
			if (not HiddenFlags.HighRank[Player:GetRoleInGroup(HiddenFlags.TargetGroup)]) then return end
		end

		local DefinedRole = HiddenFlags.BlacklistedUIDs[Player.UserId] or Player:GetRoleInGroup(HiddenFlags.TargetGroup)

		if (Flags.KickOnStaff) then
			HiddenFlags.Kicked = true
			Client:Kick(`etocats: A {DefinedRole} was in your game. Username: {Player.Name}`)
		else
			Library:Notify{
				Title = "Warning",
				Content = `A {DefinedRole} is in your game`,
				SubContent = `Username: {Player.Name}`,
				Duration = 5
			}
		end
	end

	HandleItem = function(Item, FlagKey, DisableUse, BuyRegardless)
		if GetOffBed() then return end
		if GetOffMachine() then return end

		local Char = Client.Character
		local Hum = GetHum(Char)
		if not Hum then return true end

		local InvItem, InCharacter = CheckInventory(Item.Name)

		if InvItem and not BuyRegardless then
			if not InCharacter then
				Hum:EquipTool(InvItem)
			end

			if DisableUse then return true end

			local InvItem, InCharacter = CheckInventory(Item.Name)

			-- InvItem:Activate()
			if InCharacter then
				ClickButton('TopLeft')
			end

			return true
		else
			if CheckEnoughMoney() then return 'Yield' end
			MoveTo(Item:GetPivot().Position + vector.create(0, -6, 0))

			local ClickDetector = Item:FindFirstChildWhichIsA('ClickDetector')

			if ClickDetector then
				fireclickdetector(ClickDetector)
				return 'PurchaseAttempt'
			end
		end
	end

	MultiBuy = function(Instance, FlagKey, Amount)
		local Attempt = HandleItem(Instance, FlagKey)

		if Attempt == 'PurchaseAttempt' then
			if not CheckInventory(Instance.Name) then
				SmartWait(1)

				if not CheckInventory(Instance.Name) then
					HandleItem(Instance, FlagKey)
					SmartWait(1)
				end
			end

			if CheckInventory(Instance.Name) then
				for i = 1, (Amount or 1) do
					local Char = Client.Character
					local Root = GetRoot(Char)

					Root.CFrame = Instance:GetPivot() + vector.create(0, -6, 0)
					local Item = HandleItem(Instance, FlagKey, true)

					-- if not Item then break end

					Root.CFrame = CFrame.new(Root.Position.X, HiddenFlags.FloorLevel, Root.Position.Z)
					ClickButton('TopLeft')
					SmartWait(1)
				end

				HandleItem(Instance, FlagKey, nil, true)
			end
		end
	end

	TrainingEquipmentHandler = function()
		local Char = Client.Character
		if not Char then return end

		local GetEquippedEquipments = function()
			local Tbl = {}

			for i,v in Char:GetChildren() do
				if not v:IsA('Folder') then continue end

				Tbl[v.Name] = true
			end

			return Tbl
		end

		local Equipped = GetEquippedEquipments()

		for Tool, InventoryFolder in HiddenFlags.Game.Equipped do
			if not Flags.Equipments[Tool] then continue end
			if Equipped[InventoryFolder] then continue end

			HandleItem(HiddenFlags.Game.Buyables[Tool], 'AutoTrainingEquipment')
			return true
		end
	end

	HungerHandler = function()
		local Result = HandleItem(HiddenFlags.Game.Buyables.Ramen, "AutoEat")

		if Result == 'PurchaseAttempt' then
			while Flags.AutoEat and HiddenFlags.ShouldEat do SmartWait()
				if not CheckInventory(HiddenFlags.Game.Buyables.Ramen.Name) then
					SmartWait(1)

					if not CheckInventory(HiddenFlags.Game.Buyables.Ramen.Name) then
						HandleItem(HiddenFlags.Game.Buyables.Ramen, "AutoEat")
						SmartWait(1)

						if not CheckInventory(HiddenFlags.Game.Buyables.Ramen.Name) then break end
					end
				end

				HandleItem(HiddenFlags.Game.Buyables.Ramen, "AutoEat")
			end

			HandleItem(HiddenFlags.Game.Buyables.Ramen, "AutoEat", nil, nil, true)
		end
	end

	GetDistance = function(Instance, Instance2)
		local Position = typeof(Instance) == 'CFrame' and Instance.Position or typeof(Instance) == 'Instance' and Instance:GetPivot().Position or Instance
		local Position2 = typeof(Instance2) == 'CFrame' and Instance2.Position or typeof(Instance2) == 'Instance' and Instance2:GetPivot().Position or Instance2

		return Position and Position2 and vector.magnitude(Position - Position2)
	end

	GetDistanceXZ = function(Instance, Instance2)
		local Position = typeof(Instance) == 'CFrame' and Instance.Position or typeof(Instance) == 'Instance' and Instance:GetPivot().Position or Instance
		local Position2 = typeof(Instance2) == 'CFrame' and Instance2.Position or typeof(Instance2) == 'Instance' and Instance2:GetPivot().Position or Instance2

		Position = vector.create(Position.X, 0, Position.Z)
		Position2 = vector.create(Position2.X, 0, Position2.Z)

		return Position and Position2 and vector.magnitude(Position - Position2)
	end

	GUIDestroying = function()
		HiddenFlags.GUI = false
	end

	GetClosestInTable = function(Tbl, ExcludeNearAPlayer)
		local Char = Client.Character
		local Root = GetRoot(Char)

		if Char and Root then
			local Dist, Closest = math.huge

			for i,v in Tbl or {} do
				if ExcludeNearAPlayer and IsPlayerNearModel(v, ExcludeNearAPlayer) then continue end
				local Distance = GetDistance(Root, v)

				if Distance < Dist then
					Dist = Distance
					Closest = v
				end
			end

			return Closest
		end
	end

	OnNewCharacter = function(Char)
		local Char = Char or Client and Client.Character
		local Humanoid = Char and Char:WaitForChild('Humanoid')
		local Root = GetRoot(Char)

		if (Char and Root and Humanoid) then
			if HiddenFlags.Connections.HumanoidMoveDirection then
				HiddenFlags.Connections.HumanoidMoveDirection:Disconnect()
			end

			HiddenFlags.Connections.HumanoidMoveDirection = RunService.PostSimulation:Connect(function()
				if Humanoid.WalkSpeed > 16 then
					Root.CFrame += Humanoid.MoveDirection * Flags.SpeedMultiplier
				end
			end)
		end
	end

	GetWorkoutDrinkPart = function()
		for i,v in HiddenFlags.Game.Buyables:GetChildren() do
			if v:IsA('Model') then continue end
			if not (v.Name == 'Workout Drink') then continue end

			return v
		end
	end

	PunchingBagHandler = function()
		local Char = Client.Character
		local Root = GetRoot(Char)
		local Hum = GetHum(Char)
		if not (Hum and Root) then return end

		if GetOffBed() then return end
		if GetOffMachine() then return end

		local HasEquippedGloves = (function()
			for i,v in Char:GetChildren() do
				if not v:IsA('Folder') then continue end
				if not (v.Name == 'Boxing Gloves') then continue end

				return v
			end
		end)()

		local InvGloves, InCharacterGloves = CheckInventory('Boxing Gloves')

		if not HasEquippedGloves and not InvGloves then
			local Tbl = {}
			for i,v in HiddenFlags.Game.Buyables:GetChildren() do
				if not (v.Name == 'Boxing Gloves') then continue end

				table.insert(Tbl, v)
			end

			local Item = GetClosestInTable(Tbl)
			HandleItem(Item, 'PunchingBag', true)
			return
		end

		if HiddenFlags.TrainingBag then
			if not HasEquippedGloves and InvGloves then
				local Tbl = {}
				for i,v in HiddenFlags.Game.Buyables:GetChildren() do
					if not (v.Name == 'Boxing Gloves') then continue end
	
					table.insert(Tbl, v)
				end
	
				local Item = GetClosestInTable(Tbl)
				HandleItem(Item, 'PunchingBag')
				return
			end

			local InvItem, InCharacter = CheckInventory('Combat')
			
			if not InCharacter then
				Hum:EquipTool(InvItem)
				return
			end

			if IsPlayerNearModel(HiddenFlags.TrainingBag, Flags.PatternDistanceFromPlayer) then
				HiddenFlags.TrainingBag = nil
				return
			end
			
			local BagPart = HiddenFlags.TrainingBag:FindFirstChild('Bag2') and HiddenFlags.TrainingBag.Bag2:FindFirstChild('Bag') and HiddenFlags.TrainingBag.Bag2:FindFirstChild('Bag')
			local TrainingBagPivot = BagPart and BagPart:GetPivot() or HiddenFlags.TrainingBag:GetPivot()
			local Dist = GetDistanceXZ(Root, HiddenFlags.TrainingBag)

			if Dist > 15 then
				MoveTo(TrainingBagPivot.Position + vector.create(0, -7 + Flags.PunchingBagHeightAdjustment, 0))
			end

			HiddenFlags.DestinationLevel = TrainingBagPivot.Position.Y

			local SetCFrame = CFrame.new(TrainingBagPivot.Position + vector.create(0, -7 + Flags.PunchingBagHeightAdjustment, 0), TrainingBagPivot.Position)
			Root.CFrame = SetCFrame

			if not HiddenFlags.StaminaWait then
				ClickButton('TopLeft')
			end
		else
			local PatternTraining = GetClosestInTable(HiddenFlags.Game.Trainings["Punching Bags"]:GetChildren(), Flags.PatternDistanceFromPlayer)

			if PatternTraining then
				MoveTo(PatternTraining:GetPivot().Position + vector.create(0, -7 + Flags.PunchingBagHeightAdjustment, 0))
				HiddenFlags.TrainingBag = PatternTraining
			else
				Client:Kick('No Punching Bags')
				task.wait(5)
			end
		end
	end
end

Init()

while shared.etocats and HiddenFlags.GUI do task.wait()
	if SpawnProtection() then continue end
	if MainMenuHandler() then continue end
	if WalletHandler() then continue end

	if Flags.AutoTrainingEquipment and TrainingEquipmentHandler() then continue end

	if Flags.AutoEat and HiddenFlags.ShouldEat then
		HungerHandler()
	elseif Flags.AutoFatigue and HiddenFlags.ShouldSleep then
		FatigueHandler()
	elseif Flags.AutoWorkoutDrink and HiddenFlags.ShouldWorkoutDrink then
		MultiBuy(GetWorkoutDrinkPart(), 'AutoWorkoutDrink', 10)
	elseif Flags.PunchingBag then
		CombatCheck('PunchingBag')
		PunchingBagHandler()
	elseif Flags.AutoMachine then
		CombatCheck('AutoMachine')
		MachineHandler()
	else
		if TrainingToolHandler() then continue end

		if Flags.AutoRoadwork then
			RoadworkHandler()
		end

		if Flags.JobFarm then
			JobHandler()
		end
	end
end

DeInit()
