getgenv().Flags = Flags or {
    Parry = false,
    ParryChance = 100,
    AlternateEvade = false,
    DisableParryWhileClientRunning = false,
    DebugParry = false,
    UseCustomDelay = false,
    CustomDelay = 500,
    PingAdjustmentPercentage = 100,

    StrikingTraining = false,
    StrikingGainType = 'Strength', -- 'Strength', 'StrikingSpeed', 'Durability'
    StrikingDistanceFromPlayer = 5,
    
    Withdraw = false,
    Deposit = false,
    Job = false,
    JobType = {['Floor'] = 'Floor', ['Delivery'] = 'Delivery'},

    Roadwork = false,
    RoadworkType = 'Stamina', -- Stamina, Speed

    Calisthenic = false,
    CalisthenicType = 'Push Up',

    KickOnStaff = false,

    Mask = false,
    Vest = false,
    VestType = '5KG Vest',

    Protein = false,
    ProteinDrain = false,
    Food = false,
    FoodType = 'Chicken',

    Mode = false,
    Skills = false,
    Ultimate = false,

    Minigame = false,
    Machine = false,
    MachineDistanceFromPlayer = 5,
    MachineType = 'Treadmill',
    TreadmillType = 'Stamina', -- 'Stamina', 'Speed', 'Fat'

    MerchantBuy = false,

    BodyCondition = false,
    BodyConditionType = 'Alternate', -- Alternate, Hitter, Receiver
    MyUnpopThreshold = 0.25,
    MyRepopThreshold = 0.95,
    PartnerStopThreshold = 0.25,

    RaidTypes = { ['Raid1'] = 'Raid1', ['Raid2'] = 'Raid2' },
    Raids = false,
    Trials = false,

    TweenSpeed = 20,
    BobbingSpeed = 9e9,

    Webhook = nil,
    RoleInfo = nil,
    WatchedPlayer = nil,
}

local Players = game:GetService('Players')
local Stats = game:GetService('Stats')
local ReplicatedFirst = game:GetService('ReplicatedFirst')
local RunService = game:GetService('RunService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local GroupService = game:GetService("GroupService")
local TeleportService = game:GetService('TeleportService')
local GuiService = game:GetService('GuiService')
local HttpService = game:GetService('HttpService')
local VirtualInputManager = Instance.new('VirtualInputManager')

while not getrenv()._G.Replica or not getrenv()._G.Replica.Data do task.wait() end

local Client = Players.LocalPlayer
local ClientData = getrenv()._G.Replica.Data
local PlayerGui = Client:WaitForChild('PlayerGui')
local Backpack = Client:FindFirstChildWhichIsA('Backpack')
local GetGroupInfoAsync = GroupService.GetGroupInfoAsync
local SendKeyEvent = VirtualInputManager.SendKeyEvent

local function LoadWithRetry(URL, Attempts)
    for _ = 1, (Attempts or 5) do
        local Success, Result = pcall(function()
            return loadstring(game:HttpGet(URL))()
        end)

        if Success and Result then return Result end
        task.wait(2)
    end

    error('Failed to load: ' .. URL)
end

local Serialize = LoadWithRetry('https://github.com/chadhyatt/LuaEncode/releases/download/1.4.5/LuaEncode.lua')
local Library = LoadWithRetry("https://github.com/afyzone/scriptsold/releases/download/fistborn-1/Fluent.luau")
local SaveManager = LoadWithRetry("https://github.com/afyzone/scriptsold/releases/download/fistborn-1/SaveManager.luau")
local InterfaceManager = LoadWithRetry("https://github.com/afyzone/scriptsold/releases/download/fistborn-1/InterfaceManager.luau")

shared.etocats_reload_id = (shared.etocats_reload_id or 0) + 1; local this_id = shared.etocats_reload_id; if shared.etocats then shared.etocats = false while shared.etocats_active do if this_id ~= shared.etocats_reload_id then return end task.wait() end end if this_id == shared.etocats_reload_id then shared.etocats = true shared.etocats_active = true end

local IsMainMap = not not workspace.MapMisc:FindFirstChild('Purchases')
local HiddenFlags = {
    GameName = 'Asura',
    TargetGroup = 32353519,
    Running = false,
    Stats = 'Loading...',
    StandardSafeY = -25.7,
    SenkaimonSafeY = -450,
    SafeY = -25.7,
    GoodHunger = true,
    GoodProtein = true,
    
    CurrentRaidIndex = 1,
    CurrentlyTryingRaid = false,
    LastRaidAttempt = 0,

    Constants = {
        WalletMax = 500_000,
        BankMax = 20_000_000,
        BankIncrement = 10_000,
        WithdrawLimit = ClientData.WithdrawLimit,
        RoadworkTypes = {['Stamina'] = 'Stamina', ['Speed'] = 'Speed'},
        StrikingGainTypes = {['Strength'] = 'Strength', ['StrikingSpeed'] = 'StrikingSpeed', ['Durability'] = 'Durability'},
        TreadmillTypes = {['Stamina'] = 'Stamina', ['Speed'] = 'Speed', ['Fat'] = 'Fat'},
        Trainings = {['Benchpress'] = true, ['Pull-up'] = true, ['SquatRack'] = true, ['Treadmill'] = true, ['PunchingBag'] = true},
        UIRoadworkTypes = {'Stamina', 'Speed'},
        UIStrikingGainTypes = {'Strength', 'StrikingSpeed', 'Durability'},
        UITreadmillTypes = {'Stamina', 'Speed', 'Fat'},
        UITrainings = {'Benchpress', 'Pull-up', 'SquatRack', 'Treadmill'},
        RaidTypes = {'Raid1', 'Raid2', 'Raid3'}, -- Raid3 is Rift
        FoodTypes = ClientData.FoodOrder[1], -- {'Cheeseburger', 'Chicken', 'Milkshake', 'Ramen', 'Sushi'},
        Calisthenics = {'Push Up', 'Sit Up', 'Squat'},
        VestTypes = {'5KG Vest', '10KG Vest', '20KG Vest', '40KG Vest', '80KG Vest'},
        JobTypes = {'Floor', 'Delivery'},
        BodyConditionTypes = {'Alternate', 'Hitter', 'Receiver'},
        RoadworkRemoteFunction = ReplicatedStorage.Events.RoadworkGain,
        StrikingGain = ReplicatedStorage.Events.StrikingGain,
        BenchPressGain = ReplicatedStorage.Events.BenchPressGain,
        PullUpGain = ReplicatedStorage.Events.PullUpGain,
        SquatRackGain = ReplicatedStorage.Events.SquatRackGain,
        TreadmillGain = ReplicatedStorage.Events.TreadmillGain,
        PingChecker = ReplicatedStorage.Events.PingChecker,
        Party = ReplicatedStorage.Events.Party,
        Delivery = workspace.Delivery,
        RoadworkSteps = workspace.Roadworks,
        CleaningParts = IsMainMap and workspace.MapMisc.Jobs.CleaningParts,
        Purchases = IsMainMap and workspace.MapMisc.Purchases,
        StandardServer = not workspace:GetAttribute('BossServer'),
        IsInTrials = workspace:GetAttribute('BossServer') == 'Trial',
        IsInRaids = (workspace:GetAttribute('BossServer') or ''):find('Raid'),
        IsRecoveringAnimation = 'rbxassetid://135241995337805',
        BankPart = nil,
    },

    Parts = {}, Connections = {}, HookedFunctions = {}, ClientInvokes = {}, UI = {}, Blacklisted = {}, AttackAnims = {}, GroupRoles = {}, BlacklistedUIDs = {}, Cooldowns = {},
}

local function CreateInstance(Name, Properties)
    local Instance = Instance.new(Name)
    table.insert(HiddenFlags.Parts, Instance)

    for Property, Value in Properties or {} do
        Instance[Property] = Value
    end

    return Instance
end

local function CreateConnection(Signal, Callback)
    local Connection = Signal:Connect(Callback)
    table.insert(HiddenFlags.Connections, Connection)
    return Connection
end

local function CreateHookFunction(Function, NewFunction)
    table.insert(HiddenFlags.HookedFunctions, Function)
    local OriginalFunction = hookfunction(Function, NewFunction)
    return OriginalFunction
end

local function CreateHookInvoke(RemoteFunction, NewFunction)
    if not HiddenFlags.ClientInvokes[RemoteFunction] then
        HiddenFlags.ClientInvokes[RemoteFunction] = getcallbackvalue(RemoteFunction, 'OnClientInvoke')
    end

    RemoteFunction.OnClientInvoke = NewFunction
end

local function GetSortedPlayers()
    local PlayersTable = {}
    for _, Player in Players:GetPlayers() do
        if Player == Client then continue end
        table.insert(PlayersTable, Player)
    end

    table.sort(PlayersTable, function(a, b) return a.Name < b.Name end)
    return PlayersTable
end

local function GetSortedPlayersNames()
    local PlayersTable = {}
    for _, Player in Players:GetPlayers() do
        if Player == Client then continue end
        table.insert(PlayersTable, Player.Name)
    end

    table.sort(PlayersTable, function(a, b) return a < b end)
    return PlayersTable
end

local function PlayAudio(Name, URL)
    assert(getcustomasset, 'Missing executor function: getcustomasset')

    local MP3Name = Name..'.mp3'
    local FilePath = 'etocats/'..HiddenFlags.GameName..'/'..MP3Name

    if not isfile(FilePath) then
        local Status, Result = pcall(request, {Url = URL, Method = "GET"})
        assert(Status, 'Error Downloading Audio ' .. tostring(Result))
        writefile(FilePath, Result.Body)
    end

    local Sound = Instance.new("Sound")
    Sound.SoundId = getcustomasset(FilePath)
    Sound.Parent = gethui and gethui() or CoreGui
    Sound:Play()

    Sound.Ended:Connect(function()
        Sound:Destroy()
    end)
end

local function SafeWaitUntilNotCombat()
    local Root = GetRoot(Client.Character)
    if not Root then return end

    HiddenFlags.YieldSafe = math.huge

    while HiddenFlags.Running and HiddenFlags.InCombat and task.wait() do
        MoveTo(vector.create(Root.Position.X, HiddenFlags.SafeY, Root.Position.Z))
    end

    HiddenFlags.YieldSafe = nil
end

local function SendWebhook(Content)
    if not Flags.Webhook or Flags.Webhook == '' then return end
    
    local Tagged = '👤 **' .. Client.Name .. '** | ' .. Content
    task.spawn(request, {
        Url = Flags.Webhook,
        Method = 'POST',
        Headers = { ['Content-Type'] = 'application/json' },
        Body = HttpService:JSONEncode({ content = Tagged }),
    })
end

local function PlayerRoleSanity(Player)
    if not Player or not Player.Parent or not Player:IsA('Player') or Player == Client then return end

    if not HiddenFlags.BlacklistedUIDs[Player.UserId] then
        if not Player:IsInGroup(HiddenFlags.TargetGroup) then return end
        if not Player:GetRoleInGroup(HiddenFlags.TargetGroup) then return end
        if not Flags.RoleInfo[Player:GetRoleInGroup(HiddenFlags.TargetGroup)] then return end
    end

    local DefinedRole = HiddenFlags.BlacklistedUIDs[Player.UserId] or Player:GetRoleInGroup(HiddenFlags.TargetGroup)

    if Flags.KickOnStaff then
        SafeWaitUntilNotCombat()
        SendWebhook(string.format('🚨 **Staff Detected** | Role: %s | User: %s | Hopping from: `%s`', DefinedRole, Player.Name, game.JobId))
        Client:Kick(`etocats: A {DefinedRole} was in your game. Username: {Player.Name}`)
    else
        Library:Notify{
            Title = "Warning",
            Content = `A {DefinedRole} is in your game`,
            SubContent = `Username: {Player.Name}`,
            Duration = 5
        }
    end

    PlayAudio('AdminJoined', 'https://github.com/afyzone/Audios/raw/refs/heads/main/AdminJoined.mp3')
end

local function SafeRejoin(Delay)
    Client:Kick(' ')
    if Delay then task.wait(Delay) end
    TeleportService:Teleport(game.PlaceId)
end

local function SetupUI()
    HiddenFlags.UI.Window = Library:CreateWindow{
        Title = HiddenFlags.GameName,
        SubTitle = "by afy (discord.gg/G37T6JvDtR): ver: 0.165",
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
        Misc = HiddenFlags.UI.Window:CreateTab{
            Title = "Misc",
            Icon = "phosphor-angle"
        },
        Consumables = HiddenFlags.UI.Window:CreateTab{
            Title = "Consumables",
            Icon = "phosphor-anchor"
        },
        Settings = HiddenFlags.UI.Window:CreateTab{
            Title = "Settings",
            Icon = "settings"
        }
    }

    -- Stats
    HiddenFlags.UI.Tabs.Stats:CreateParagraph("StatsData", {
        Title = "Stats",
        Content = HiddenFlags.Stats,
    })
    
    HiddenFlags.UI.Tabs.Stats:CreateDropdown("WatchedPlayer", {
        Title = "Watch Player HP",
        Values = GetSortedPlayersNames(),
        Multi = false,
        Default = nil,
    }):OnChanged(function(Value) Flags.WatchedPlayer = Value end)

    HiddenFlags.UI.Tabs.Stats:CreateParagraph("WatchedPlayerHP", {
        Title = "Player HP",
        Content = "No player selected",
    })

    -- Settings
    HiddenFlags.UI.Tabs.Settings:CreateSlider("TweenSpeed", {
        Title = "Tween Speed",
        Description = "Moving speed whilst tweening",
        Default = Flags.TweenSpeed,
        Min = 0,
        Max = 100,
        Rounding = 1,
    }):OnChanged(function(Value) Flags.TweenSpeed = Value end)

    -- Main
    HiddenFlags.UI.Tabs.Main:CreateButton({ Title = 'Dex', Callback = loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua")) })
    HiddenFlags.UI.Tabs.Main:CreateButton({ Title = 'Rejoin', Callback = SafeRejoin })
    HiddenFlags.UI.Tabs.Main:CreateToggle("Parry", { Title = "Auto Parry", Default = Flags.Parry }):OnChanged(function(Value) Flags.Parry = Value end)
    HiddenFlags.UI.Tabs.Main:CreateToggle("AlternateEvade", { Title = "Alternate Evade", Default = Flags.AlternateEvade }):OnChanged(function(Value) Flags.AlternateEvade = Value end)
    HiddenFlags.UI.Tabs.Main:CreateToggle("DisableParryWhileClientRunning", { Title = "Disable Parry While Client Running", Default = Flags.DisableParryWhileClientRunning }):OnChanged(function(Value) Flags.DisableParryWhileClientRunning = Value end)
    HiddenFlags.UI.Tabs.Main:CreateToggle("DebugParry", { Title = "Debug Parry", Default = Flags.DebugParry }):OnChanged(function(Value) Flags.DebugParry = Value end)
    HiddenFlags.UI.Tabs.Main:CreateSlider("ParryChance", {
        Title = "Parry Chance",
        Description = "The chance success rate.",
        Default = Flags.ParryChance,
        Min = 0,
        Max = 100,
        Rounding = 1,
    }):OnChanged(function(Value) Flags.ParryChance = Value end)
    HiddenFlags.UI.Tabs.Main:CreateToggle("UseCustomDelay", { Title = "Use Custom Delay", Default = Flags.UseCustomDelay }):OnChanged(function(Value) Flags.UseCustomDelay = Value end)
    HiddenFlags.UI.Tabs.Main:CreateSlider("CustomDelay", {
        Title = "Custom Delay",
        Description = "The delay used for the custom delay.",
        Default = Flags.CustomDelay,
        Min = 0,
        Max = 1000,
        Rounding = 1,
    }):OnChanged(function(Value) Flags.CustomDelay = Value end)
    HiddenFlags.UI.Tabs.Main:CreateSlider("PingAdjustmentPercentage", {
        Title = "Ping Adjustment Percentage",
        Description = "The delay used for the ping-based delay.",
        Default = Flags.PingAdjustmentPercentage,
        Min = 0,
        Max = 100,
        Rounding = 1,
    }):OnChanged(function(Value) Flags.PingAdjustmentPercentage = Value end)

    -- Farming
    HiddenFlags.UI.Tabs.Farming:AddSection("Money")
    HiddenFlags.UI.Tabs.Farming:CreateToggle("Withdraw", { Title = "Auto Withdraw", Default = Flags.Withdraw }):OnChanged(function(Value) Flags.Withdraw = Value end)
    HiddenFlags.UI.Tabs.Farming:CreateToggle("Deposit", { Title = "Auto Deposit", Default = Flags.Deposit }):OnChanged(function(Value) Flags.Deposit = Value end)
    HiddenFlags.UI.Tabs.Farming:CreateToggle("Job", { Title = "Auto Job Farm", Default = Flags.Job }):OnChanged(function(Value) Flags.Job = Value end)
    HiddenFlags.UI.Tabs.Farming:CreateDropdown("JobType", {
        Title = "Job Type",
        Values = HiddenFlags.Constants.JobTypes,
        Multi = true,
        Default = Flags.JobType,
    }):OnChanged(function(Value) Flags.JobType = Value end)

    HiddenFlags.UI.Tabs.Farming:AddSection("Roadwork")
    HiddenFlags.UI.Tabs.Farming:CreateToggle("Roadwork", { Title = "Auto Roadwork", Default = Flags.Roadwork }):OnChanged(function(Value) Flags.Roadwork = Value end)
    HiddenFlags.UI.Tabs.Farming:CreateDropdown("RoadworkType", {
        Title = "Roadwork Type",
        Values = HiddenFlags.Constants.UIRoadworkTypes,
        Multi = false,
        Default = Flags.RoadworkType,
    }):OnChanged(function(Value) Flags.RoadworkType = Value end)
 
    HiddenFlags.UI.Tabs.Farming:AddSection("Machines")
    HiddenFlags.UI.Tabs.Farming:CreateToggle("Machine", { Title = "Auto Machine Farm", Default = Flags.Machine }):OnChanged(function(Value) Flags.Machine = Value end)
    HiddenFlags.UI.Tabs.Farming:CreateDropdown("Machines", {
        Title = "Machine Type",
        Values = HiddenFlags.Constants.UITrainings,
        Multi = false,
        Default = Flags.MachineType,
    }):OnChanged(function(Value) Flags.MachineType = Value end)
    HiddenFlags.UI.Tabs.Farming:CreateSlider("MachineDistanceFromPlayer", {
        Title = "Machine Distance",
        Description = "How far the closest other player can be to the Punching Bag.",
        Default = Flags.MachineDistanceFromPlayer,
        Min = 0,
        Max = 100,
        Rounding = 1,
    }):OnChanged(function(Value) Flags.MachineDistanceFromPlayer = Value end)
    
    HiddenFlags.UI.Tabs.Farming:CreateToggle("Minigame", { Title = "Auto Minigame", Default = Flags.Minigame }):OnChanged(function(Value) Flags.Minigame = Value end)
    HiddenFlags.UI.Tabs.Farming:CreateDropdown("TreadmillType", {
        Title = "Treadmill Farm",
        Values = HiddenFlags.Constants.UITreadmillTypes,
        Multi = false,
        Default = Flags.TreadmillType,
    }):OnChanged(function(Value) Flags.TreadmillType = Value end)
    
    HiddenFlags.UI.Tabs.Farming:AddSection("Striking Bag")
    HiddenFlags.UI.Tabs.Farming:CreateToggle("StrikingTraining", { Title = "Auto Pattern Training", Default = Flags.StrikingTraining }):OnChanged(function(Value) Flags.StrikingTraining = Value end)
    HiddenFlags.UI.Tabs.Farming:CreateDropdown("StrikingType", {
        Title = "Striking Type",
        Values = HiddenFlags.Constants.UIStrikingGainTypes,
        Multi = false,
        Default = Flags.StrikingGainType,
    }):OnChanged(function(Value) Flags.StrikingGainType = Value end)
    HiddenFlags.UI.Tabs.Farming:CreateSlider("StrikingDistanceFromPlayer", {
        Title = "Bag Distance",
        Description = "How far the closest other player can be to the Punching Bag.",
        Default = Flags.StrikingDistanceFromPlayer,
        Min = 0,
        Max = 100,
        Rounding = 1,
    }):OnChanged(function(Value) Flags.StrikingDistanceFromPlayer = Value end)

    HiddenFlags.UI.Tabs.Farming:AddSection("Body Condition")
    HiddenFlags.UI.Tabs.Farming:CreateToggle("BodyCondition", { Title = "Auto Body Condition", Default = Flags.BodyCondition }):OnChanged(function(Value) Flags.BodyCondition = Value end)
    HiddenFlags.UI.Tabs.Farming:CreateDropdown("BodyConditionType", {
        Title = "Body Condition Type",
        Values = HiddenFlags.Constants.BodyConditionTypes,
        Multi = false,
        Default = Flags.BodyConditionType,
    }):OnChanged(function(Value) Flags.BodyConditionType = Value end)
    HiddenFlags.UI.Tabs.Farming:CreateDropdown("BodyConditionPartner", {
        Title = "Body Condition Partner",
        Values = GetSortedPlayersNames(),
        Multi = false,
        Default = Flags.BodyConditionPartner,
    }):OnChanged(function(Value) Flags.BodyConditionPartner = Value end)
    HiddenFlags.UI.Tabs.Farming:CreateSlider("MyUnpopThreshold", {
        Title = "My Unpop Health %",
        Description = "Unpop body conditioning when your health drops below this",
        Default = Flags.MyUnpopThreshold * 100,
        Min = 5,
        Max = 90,
        Rounding = 1,
    }):OnChanged(function(Value) Flags.MyUnpopThreshold = Value / 100 end)
    HiddenFlags.UI.Tabs.Farming:CreateSlider("MyRepopThreshold", {
        Title = "My Repop Health %",
        Description = "Repop body conditioning when your health recovers above this",
        Default = Flags.MyRepopThreshold * 100,
        Min = 50,
        Max = 100,
        Rounding = 1,
    }):OnChanged(function(Value) Flags.MyRepopThreshold = Value / 100 end)
    HiddenFlags.UI.Tabs.Farming:CreateSlider("PartnerStopThreshold", {
        Title = "Partner Stop Health %",
        Description = "Stop hitting partner when their health drops below this",
        Default = Flags.PartnerStopThreshold,
        Min = 5,
        Max = 90,
        Rounding = 1,
    }):OnChanged(function(Value) Flags.PartnerStopThreshold = Value / 100 end)

    -- Misc

    HiddenFlags.UI.Tabs.Misc:CreateToggle("Calisthenic", { Title = "Auto Calisthenic", Default = Flags.Calisthenic }):OnChanged(function(Value) Flags.Calisthenic = Value end)
    HiddenFlags.UI.Tabs.Misc:CreateDropdown("CalisthenicType", {
        Title = "Calisthenic Type",
        Values = HiddenFlags.Constants.Calisthenics,
        Multi = false,
        Default = Flags.CalisthenicType,
    }):OnChanged(function(Value) Flags.CalisthenicType = Value end)

    HiddenFlags.UI.Tabs.Misc:AddSection('Combat')
    HiddenFlags.UI.Tabs.Misc:CreateToggle("Mode", { Title = "Auto Mode", Default = Flags.Mode }):OnChanged(function(Value) Flags.Mode = Value end)
    HiddenFlags.UI.Tabs.Misc:CreateToggle("Skills", { Title = "Auto Skills", Default = Flags.Skills }):OnChanged(function(Value) Flags.Skills = Value end)
    HiddenFlags.UI.Tabs.Misc:CreateToggle("Ultimate", { Title = "Auto Ultimate", Default = Flags.Ultimate }):OnChanged(function(Value) Flags.Ultimate = Value end)

    HiddenFlags.UI.Tabs.Misc:AddSection('Anti Staff')
    HiddenFlags.UI.Tabs.Misc:CreateDropdown("RoleInfo", {
        Title = "Kick Selection",
        Values = HiddenFlags.GroupRoles,
        Multi = true,
        Default = Flags.RoleInfo,
    }):OnChanged(function(Value) Flags.RoleInfo = Value end)

    HiddenFlags.UI.Tabs.Misc:CreateToggle("KickOnStaff", { Title = "Kick On Join", Default = Flags.KickOnStaff }):OnChanged(function(Value)
        Flags.KickOnStaff = Value

        if Value then
            for _, Player in Players:GetPlayers() do
                task.spawn(PlayerRoleSanity, Player)
            end
        end
    end)

    HiddenFlags.UI.Tabs.Misc:AddSection('Webhook')
    HiddenFlags.UI.Tabs.Misc:CreateInput("WebhookURL", {
        Title = "Webhook URL",
        Description = "Paste your Discord webhook URL here",
        Default = Flags.Webhook,
        Placeholder = "https://discord.com/api/webhooks/...",
        Numeric = false,
        Finished = true,
    }):OnChanged(function(Value) Flags.Webhook = Value end)
    
    HiddenFlags.UI.Tabs.Misc:CreateButton({ Title = 'Test Webhook', Callback = function()
        if not Flags.Webhook or Flags.Webhook == '' then
            Library:Notify{ Title = 'Webhook', Content = 'No URL set', Duration = 3 }
            return
        end

        local Success, Result = pcall(request, {
            Url = Flags.Webhook,
            Method = 'POST',
            Headers = { ['Content-Type'] = 'application/json' },
            Body = HttpService:JSONEncode({ content = '✅ **Webhook test** from ' .. Client.Name .. ' | ' .. game.JobId }),
        })

        if Success then
            Library:Notify{ Title = 'Webhook', Content = 'Test sent successfully', Duration = 3 }
        else
            Library:Notify{ Title = 'Webhook', Content = 'Failed: ' .. tostring(Result), Duration = 5 }
        end
    end })

    HiddenFlags.UI.Tabs.Misc:CreateButton({ Title = 'Get Wares Now', Callback = function()
        local Merchants = workspace:FindFirstChild('Merchants')
        local Traveler = Merchants and Merchants:FindFirstChild('Traveler')
        local OpenWares = Traveler and Traveler:FindFirstChild('OpenWares')
        local Prompt = OpenWares and OpenWares:FindFirstChildWhichIsA('ProximityPrompt')
        if Prompt then
            pcall(fireproximityprompt, Prompt)
            Library:Notify{ Title = 'Merchant', Content = 'Fired prompt, waiting for wares...', Duration = 3 }
        elseif HiddenFlags.LastMerchantWares then
            task.spawn(BuyAllCashItems, HiddenFlags.LastMerchantWares)
            Library:Notify{ Title = 'Merchant', Content = 'Using cached wares', Duration = 3 }
        else
            Library:Notify{ Title = 'Merchant', Content = 'No merchant found and no cached wares', Duration = 3 }
        end
    end })

    HiddenFlags.UI.Tabs.Misc:AddSection('Misc')
    HiddenFlags.UI.Tabs.Misc:CreateToggle("Trials", { Title = "Auto Trials", Default = Flags.Trials }):OnChanged(function(Value) Flags.Trials = Value end)
    HiddenFlags.UI.Tabs.Misc:CreateToggle("Raids", { Title = "Auto Raids", Default = Flags.Raids }):OnChanged(function(Value) Flags.Raids = Value end)
    HiddenFlags.UI.Tabs.Misc:CreateDropdown("RaidTypes", {
        Title = "Raid Types",
        Values = HiddenFlags.Constants.RaidTypes,
        Multi = true,
        Default = Flags.RaidTypes,
    }):OnChanged(function(Value) Flags.RaidTypes = Value end)

    -- Consumables
    HiddenFlags.UI.Tabs.Consumables:CreateToggle("Protein", { Title = "Auto Protein Shake", Default = Flags.Protein }):OnChanged(function(Value) Flags.Protein = Value end)
    HiddenFlags.UI.Tabs.Consumables:CreateToggle("ProteinDrain", { Title = "Auto Protein Drain", Default = Flags.ProteinDrain }):OnChanged(function(Value) Flags.ProteinDrain = Value end)
    HiddenFlags.UI.Tabs.Consumables:CreateToggle("Food", { Title = "Auto Food", Default = Flags.Food }):OnChanged(function(Value) Flags.Food = Value end)
    HiddenFlags.UI.Tabs.Consumables:CreateDropdown("FoodType", {
        Title = "Food Type",
        Values = HiddenFlags.Constants.FoodTypes,
        Multi = false,
        Default = Flags.FoodType,
    }):OnChanged(function(Value) Flags.FoodType = Value end)
    HiddenFlags.UI.Tabs.Consumables:CreateToggle("Mask", { Title = "Auto Mask", Default = Flags.Mask }):OnChanged(function(Value) Flags.Mask = Value end)
    HiddenFlags.UI.Tabs.Consumables:CreateToggle("Vest", { Title = "Auto Vest", Default = Flags.Vest }):OnChanged(function(Value) Flags.Vest = Value end)
    HiddenFlags.UI.Tabs.Consumables:CreateDropdown("VestType", {
        Title = "Vest Type",
        Values = HiddenFlags.Constants.VestTypes,
        Multi = false,
        Default = Flags.VestType,
    }):OnChanged(function(Value) Flags.VestType = Value end)

    HiddenFlags.UI.Tabs.Misc:CreateToggle("MerchantBuy", { Title = "Auto Merchant Buy", Default = Flags.MerchantBuy }):OnChanged(function(Value) Flags.MerchantBuy = Value end)

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
end

local function SetCooldown(SkillName, Duration)
    if not SkillName or not Duration then return end

    local EndTime = os.clock() + Duration
    HiddenFlags.Cooldowns[SkillName] = EndTime

    task.delay(Duration, function()
        if HiddenFlags.Cooldowns[SkillName] == EndTime then
            HiddenFlags.Cooldowns[SkillName] = nil
        end
    end)
end

local function IsOnCooldown(SkillName)
    local EndTime = HiddenFlags.Cooldowns[SkillName]
    if not EndTime then return false end

    if os.clock() >= EndTime then
        HiddenFlags.Cooldowns[SkillName] = nil
        return false
    end

    return EndTime - os.clock()
end

local function GetRoot(Character) 
    return Character and Character:FindFirstChild('HumanoidRootPart') 
end

local function GetHum(Character) 
    return Character and Character:FindFirstChildWhichIsA('Humanoid') 
end

local function GetAnimator(Humanoid) 
    return Humanoid and (Humanoid:FindFirstChildWhichIsA('Animator') or Humanoid)
end

local function SmartWait(WaitTime, FlagString, InitCFrame)
    local Char = Client.Character
    local Root = GetRoot(Char)
    local StartTime = os.clock()

    HiddenFlags.CurrentlyWaiting = true

    if (Char and Root) then
        Root.AssemblyLinearVelocity = vector.zero
        local InitCFrame = InitCFrame or Root.CFrame
        local Yield = true

        task.spawn(function()
            while (Char and Root and (not FlagString or Flags[FlagString]) and os.clock() - StartTime <= (WaitTime or 1/60)) do
                Root.CFrame = InitCFrame
                Root.AssemblyLinearVelocity = vector.zero
                task.wait()
            end

            Yield = false
        end)

        while Yield do task.wait() end
    end

    HiddenFlags.CurrentlyWaiting = false
    return os.clock() - StartTime
end

local function IncrementalMove(Root, StartPos, EndPos, Speed)
    local Offset = EndPos - StartPos
    local Distance = vector.magnitude(Offset)
    local Direction = vector.normalize(Offset)
    local CurrentPos = StartPos
    local Moved = 0

    while Distance > 1 and Moved < Distance do
        local Delta = RunService.Heartbeat:Wait()
        local Step = Speed * Delta

        if Moved + Step > Distance then
            Step = Distance - Moved
        end

        CurrentPos += Direction * Step
        Root.CFrame = CFrame.new(CurrentPos)
        Root.AssemblyLinearVelocity = vector.zero
        Moved += Step
    end

    Root.CFrame = CFrame.new(EndPos)
end

local function GetDistance(Instance, Instance2)
    local Position = typeof(Instance) == 'CFrame' and Instance.Position or typeof(Instance) == 'Instance' and Instance:GetPivot().Position or Instance
    local Position2 = typeof(Instance2) == 'CFrame' and Instance2.Position or typeof(Instance2) == 'Instance' and Instance2:GetPivot().Position or Instance2

    return Position and Position2 and vector.magnitude(Position - Position2)
end

local function GetDistanceXZ(Instance, Instance2)
    local Position = typeof(Instance) == 'CFrame' and Instance.Position or typeof(Instance) == 'Instance' and Instance:GetPivot().Position or Instance
    local Position2 = typeof(Instance2) == 'CFrame' and Instance2.Position or typeof(Instance2) == 'Instance' and Instance2:GetPivot().Position or Instance2

    Position = vector.create(Position.X, 0, Position.Z)
    Position2 = vector.create(Position2.X, 0, Position2.Z)

    return Position and Position2 and vector.magnitude(Position - Position2)
end

local function MoveTo(Pos, Options)
    local Options = Options or {}
    local SpecifiedY = Options.SpecifiedY
    local HorizontalMovementSpeed = Options.HorizontalMovementSpeed or Flags.TweenSpeed
    local VerticalMovementSpeed = Options.VerticalMovementSpeed or Flags.BobbingSpeed

    if HiddenFlags.CurrentlyMoving then return end
    HiddenFlags.CurrentlyMoving = true

    local Char = Client.Character
    local Root = GetRoot(Char)

    HiddenFlags.DestinationLevel = HiddenFlags.NormalLevel

    if Char and Root then
        local NormalY = HiddenFlags.SafeY
        local CurrentPos = Root.Position
        local DownPos = vector.create(CurrentPos.X, SpecifiedY or NormalY, CurrentPos.Z)
        local AcrossPos = vector.create(Pos.X, SpecifiedY or NormalY, Pos.Z)
        local FinalPos = Pos
        local Dist = GetDistanceXZ(CurrentPos, FinalPos)

        if Dist > 5 then
            IncrementalMove(Root, CurrentPos, DownPos, VerticalMovementSpeed)
            IncrementalMove(Root, DownPos, AcrossPos, HorizontalMovementSpeed)
        end

        IncrementalMove(Root, AcrossPos, FinalPos, VerticalMovementSpeed)
    end

    HiddenFlags.DestinationLevel = nil
    HiddenFlags.CurrentlyMoving = false
    return true
end

local function GetJobPart()
    local BillboardGui = PlayerGui:FindFirstChild('BillboardGui')
    local JobPart = BillboardGui and BillboardGui.Adornee
    return JobPart
end

local function GetClosestCleanFloorParts()
    local Character = Client.Character
    local Root = GetRoot(Character)
    if not Root then return end

    local ClosestDistance, ClosestPart = math.huge

    local CleaningParts = HiddenFlags.Constants.CleaningParts
    if not CleaningParts then return end

    local ClientCleaning = CleaningParts:FindFirstChild(Client.Name)
    if not ClientCleaning then return end

    for _, Part in ClientCleaning:GetChildren() do
        if not Part:IsA('Part') then continue end

        local Distance = GetDistance(Part, Root)
        if Distance >= ClosestDistance then continue end

        ClosestDistance = Distance
        ClosestPart = Part
    end

    return ClosestPart
end

local function JobCompleteFloors()
    local Character = Client.Character
    local Root = GetRoot(Character)
    local Hum = GetHum(Character)
    if not Root then return end

    local JobPart = GetJobPart()

    local Floor = GetClosestCleanFloorParts()
    if not Floor then 
        if JobPart then
            MoveTo(JobPart.Position)
        else
            Root.CFrame = CFrame.new(Root.Position.X, HiddenFlags.SafeY, Root.Position.Z)
        end
        
        return 
    end

    local Broom = Character:FindFirstChild('Broom')
    if Broom then
        Root.CFrame = CFrame.new(Root.Position.X, HiddenFlags.SafeY, Root.Position.Z)
    else
        MoveTo(Floor.Position + vector.create(0, -5, 0))

        local ClickDetector = Floor:FindFirstChildWhichIsA('ClickDetector')
        if ClickDetector then
            Hum:UnequipTools()
            
            if ClickDetector then 
                fireclickdetector(ClickDetector)
            end
        end
    end
end

local function FireTransmittersFromParent(Parent)
    local Character = Client.Character
    local Root = GetRoot(Character)
    if not Root then return end

    for _, Transmitter in Parent:GetDescendants() do 
        if not Transmitter:IsA('TouchTransmitter') then continue end

        local Part = Transmitter.Parent
        local Dist = GetDistance(Part, Root)

        if Dist > 12 then continue end

        firetouchinterest(Root, Part, 0)
        firetouchinterest(Root, Part, 1)
    end
end

local function JobCompleteDelivery()
    local Character = Client.Character
    local Root = GetRoot(Character)
    if not Root then return end

    local JobPart = GetJobPart()
    if not JobPart then 
        Root.CFrame = CFrame.new(Root.Position.X, HiddenFlags.SafeY, Root.Position.Z)
        return 
    end

    MoveTo(JobPart.Position + vector.create(0, -5, 0))
    FireTransmittersFromParent(HiddenFlags.Constants.Delivery)
end

local function GetCurrentJob()
    local Main = PlayerGui:FindFirstChild('Main')
    local JobStatus = Main and Main:FindFirstChild('LabelJob')
    local JobText = JobStatus and JobStatus.Text
    return JobText and JobText ~= '' and JobText:lower()
end

local function GetJob()
    ReplicatedStorage.Events.EventCore:FireServer('Job')
end

local function CancelJob()
    local CurrentJob = GetCurrentJob()
    ReplicatedStorage.Events.EventCore:FireServer('CancelJob')
    while HiddenFlags.Running and CurrentJob and CurrentJob == GetCurrentJob() do SmartWait() end
end

local function GetWalletBalance()
    return ClientData.Cash
end

local function GetBankBalance()
    return ClientData.Bank
end

local function UnequipTools()
    local Character = Client.Character
    local Hum = GetHum(Character)
    if not Hum then return end

    Hum:UnequipTools()
end

local function Withdraw(TransferAmount)
    if not HiddenFlags.Constants.BankPart then return end

    local WalletMax = HiddenFlags.Constants.WalletMax
    local Wallet = GetWalletBalance()
    if TransferAmount <= 1_000 or TransferAmount > WalletMax then return end

    UnequipTools()
    MoveTo(HiddenFlags.Constants.BankPart.Position + vector.create(0, -5.5, 0))
    fireclickdetector(HiddenFlags.Constants.BankPart.ClickDetector)
    SmartWait(0.5)
    local BankEvent = ReplicatedStorage.Events.Bank
    BankEvent:FireServer("Withdraw", tostring(TransferAmount))
end

local function Deposit(TransferAmount)
    if not HiddenFlags.Constants.BankPart then return end
    
    local BankMax = HiddenFlags.Constants.BankMax
    local TargetBankAmount = TransferAmount + GetBankBalance()
    if TransferAmount <= 0 or TargetBankAmount > BankMax then return end

    UnequipTools()
    MoveTo(HiddenFlags.Constants.BankPart.Position + vector.create(0, -5.5, 0))
    fireclickdetector(HiddenFlags.Constants.BankPart.ClickDetector)
    SmartWait(0.5)
    local BankEvent = ReplicatedStorage.Events.Bank
    BankEvent:FireServer("Deposit", tostring(TransferAmount))
end

local function JobHandler()
    local Character = Client.Character
    local Root = GetRoot(Character)
    if not Root then return end

    local Job = GetCurrentJob()

    if not Job then 
        Root.CFrame = CFrame.new(Root.Position.X, HiddenFlags.SafeY, Root.Position.Z)
        GetJob()
        return
    end

    local IsFloor = Job:find('floor')
    local IsDelivery = Job:find('deliver')
    local ShouldCancel = (IsFloor and not Flags.JobType['Floor']) or (IsDelivery and not Flags.JobType['Delivery'])

    if ShouldCancel then 
        CancelJob() 
        Root.CFrame = CFrame.new(Root.Position.X, HiddenFlags.SafeY, Root.Position.Z)
        SmartWait(0.2)
        return
    end

    if IsFloor then
        JobCompleteFloors()
    elseif IsDelivery then
        JobCompleteDelivery()
    else
        Root.CFrame = CFrame.new(Root.Position.X, HiddenFlags.SafeY, Root.Position.Z)
    end
end

local function GetTargetAdornee()
    local BillboardGui = PlayerGui:FindFirstChild('BillboardGui')
    local Adornee = BillboardGui and BillboardGui.Adornee
    return Adornee
end

local function SetRoadworkType()
    local RoadworkType = HiddenFlags.Constants.RoadworkTypes[Flags.RoadworkType]

    if RoadworkType then
        CreateHookInvoke(HiddenFlags.Constants.RoadworkRemoteFunction, function() return RoadworkType end)
    end
end

local function RevertRoadworkType()
    local RemoteFunction = HiddenFlags.Constants.RoadworkRemoteFunction
    local OriginalFunction = HiddenFlags.ClientInvokes[RemoteFunction]

    if OriginalFunction then
        RemoteFunction.OnClientInvoke = OriginalFunction
    end
end

local function HasTool(ToolName)
    if not ToolName then return end

    local Character = Client.Character
    if not Character then return end

    local Tool = Backpack:FindFirstChild(ToolName)
    if Tool then
        return Tool
    end

    local Tool = Character:FindFirstChild(ToolName)
    return Tool
end

local function UseTool(ToolName)
    if not ToolName then return end

    local Character = Client.Character
    local Hum = GetHum(Character)
    if not Hum then return end

    local Tool = Backpack:FindFirstChild(ToolName)
    if Tool then
        Hum:EquipTool(Tool)
    end

    local Tool = Character:FindFirstChild(ToolName)
    if Tool then
        Tool:Activate()
        Tool:Deactivate()
    end
end

local function IsPlayerNearModel(Model, DistanceFromPlayer)
    local ModelPivot = Model:GetPivot()

    for _, v in Players:GetPlayers() do
        if v == Client then continue end

        local PlayerChar = v.Character
        local PlayerRoot = GetRoot(PlayerChar)
        if not (PlayerChar and PlayerRoot) then continue end

        local ModelPos = ModelPivot.Position
        local PlayerPos = PlayerRoot.Position

        -- local HeightDiff = math.abs(ModelPos.Y - PlayerPos.Y)
        -- if HeightDiff > 10 then continue end

        local HorizontalDist = GetDistanceXZ(ModelPos, PlayerPos)
        
        if HorizontalDist < (DistanceFromPlayer or 10) then
            return true
        end
    end
end

local function GetClosestInTable(Tbl, Options)
    Options = Options or {}
    Options.MaxRange = Options.MaxRange or math.huge
    Options.ExcludeNearAPlayer = Options.ExcludeNearAPlayer or false

    local Char = Client.Character
    local Root = GetRoot(Char)

    if Char and Root then
        local Dist, Closest = Options.MaxRange

        for _, Iter in Tbl or {} do
            if Options.ExcludeNearAPlayer and IsPlayerNearModel(Iter, Options.ExcludeNearAPlayer) then continue end
            local Distance = GetDistance(Root, Iter)

            if Distance and Distance < Dist then
                Dist = Distance
                Closest = Iter
            end
        end

        return Closest, Dist
    end
end

local function PurchaseItem(ItemName)
    if not ItemName then return end
    local Tbl = {}
    
    for Index, Model in HiddenFlags.Constants.Purchases:GetDescendants() do
        if not Model:IsA('Model') then continue end
        if table.find(HiddenFlags.Blacklisted, Model) then continue end
        if Model:GetPivot().Position.Y > 25 then continue end
        if GetDistance(workspace.GangBase.GYM, Model) < 150 then continue end
        if Model.Name ~= ItemName then continue end
        local ClickDetector = Model:FindFirstChildWhichIsA('ClickDetector')
        if not ClickDetector then continue end
        table.insert(Tbl, Model)
    end

    local ClosestItem = GetClosestInTable(Tbl)
    
    if ClosestItem then
        local ClickDetector = ClosestItem:FindFirstChildWhichIsA('ClickDetector')

        if ClickDetector then
            local ClosestPart = ClosestItem:FindFirstChildWhichIsA('BasePart') or ClosestItem
            MoveTo(ClosestPart:GetPivot().Position + vector.create(0, -7, 0))
            SmartWait(0.2)
            fireclickdetector(ClickDetector)
            MoveTo(ClosestPart:GetPivot().Position + vector.create(0, -20, 0))
        end
    end
end

local function RoadworkHandler()
    local RoadworkStep = GetTargetAdornee()
    local Root = GetRoot(Client.Character)
    if not Root then return end

    if RoadworkStep then
        MoveTo(RoadworkStep.Position + vector.create(0, -5.5, 0))
        FireTransmittersFromParent(HiddenFlags.Constants.RoadworkSteps)
    else
        local RoadworkTool = HasTool('Roadwork Training')
        SetRoadworkType()

        task.defer(function()
            if not Flags.Roadwork then
                RevertRoadworkType()
            end
        end)

        if RoadworkTool then
            UseTool(RoadworkTool.Name)
            MoveTo(vector.create(Root.Position.X, HiddenFlags.SafeY, Root.Position.Z))
        else
            PurchaseItem('Roadwork Training')
        end
    end
end

local function IsProtected()
    local Protection = PlayerGui.Main:FindFirstChild('Protection')
    return Protection and Protection.Visible
end

local function ProtectionHandler()
    local Character = Client.Character
    local Hum = GetHum(Character)
    if not Hum then return end

    local Protection = IsProtected()

    if Protection then
        local Directions = {'W', 'A', 'S', 'D'}
        local Key = Directions[math.random(1, #Directions)]
        pcall(SendKeyEvent, VirtualInputManager, true, Key, false, nil)
        task.wait(0.20)
        pcall(SendKeyEvent, VirtualInputManager, false, Key, false, nil)
        task.wait(0.10)
    end
end

local function SafeCrash()
    game:Shutdown()
    task.wait(9e9)
end

local function GetCurrentMachine()
    for Attribute, Value in Client:GetAttributes() do
        if Attribute:find('Training') then
            local MachineName = Attribute:gsub('Training', '')

            if table.find(HiddenFlags.Constants.UITrainings, MachineName) then
                return MachineName
            end
        end
    end
end

local function GetOffMachine()
    local Character = Client.Character
    local Root = GetRoot(Character)
    if not Root then return end

    local MachineName = GetCurrentMachine()

    if MachineName and Root.Anchored then
        ReplicatedStorage.Events.EventCore:FireServer('Leave' .. MachineName)
    end
end

local function MinigameSolver()
    local Minigames = {
        ['BenchPressGain'] = 'UpperMuscle',
        ['PullUpGain'] = 'Durability',
        ['SquatRackGain'] = 'LowerMuscle',
        ['TreadmillGain'] = 'Treadmill',
    }

    for Remote, Return in Minigames do
        CreateHookInvoke(HiddenFlags.Constants[Remote], function(Type, KeyString)
            if Type == 'Key' then return HiddenFlags.GoodStamina end

            if Return == 'Treadmill' then
                local TreadmillType = HiddenFlags.Constants.TreadmillTypes[Flags.TreadmillType]
                if not TreadmillType then SafeCrash() return end

                return TreadmillType
            end

            return Return
        end)
    end
end

local function MinigameRevert()
    local Minigames = {
        HiddenFlags.Constants.StrikingGain, 
        HiddenFlags.Constants.TreadmillGain, 
        HiddenFlags.Constants.SquatRackGain, 
        HiddenFlags.Constants.PullUpGain, 
        HiddenFlags.Constants.BenchPressGain
    }

    for Index, RemoteFunction in Minigames do
        local OriginalFunction = HiddenFlags.ClientInvokes[RemoteFunction]

        if OriginalFunction then
            RemoteFunction.OnClientInvoke = OriginalFunction
        end
    end
end

local function MinigameHandler()
    if Flags.Minigame then
        MinigameSolver()
    else
        MinigameRevert()
    end
end

local function GetStamina()
    local Character = Client.Character
    if not Character then return end

    return (Character:GetAttribute('Stamina') or 1 / 1) * 100
end

local function GetHunger()
    return ClientData.Hunger
end

local function GetProtein()
    return ClientData.Protein
end

local function FoodHandler(Override)
    local Character = Client.Character
    local Root = GetRoot(Character)
    if not Root then return end

    local FoodTool = HasTool(Override or Flags.FoodType)

    if FoodTool then
        UseTool(FoodTool.Name)
        Root.CFrame = CFrame.new(Root.Position.X, HiddenFlags.SafeY, Root.Position.Z)
    else
        PurchaseItem(Override or Flags.FoodType)
    end
end

local function CalisthenicHandler()
    if not Flags.Calisthenic then return end
    local Calisthenic = HasTool(Flags.CalisthenicType)
    
    if Calisthenic and HiddenFlags.GoodStamina then
        if not table.find(HiddenFlags.Constants.Calisthenics, Calisthenic.Name) then return end

        UseTool(Calisthenic.Name)
    end
end

local function SetCharacterData()
    local Character = Client.Character
    local Hum = GetHum(Character)
    if not Hum then return end

    local SeatedState = Enum.HumanoidStateType.Seated

    if Hum:GetStateEnabled(SeatedState) then
        Hum:SetStateEnabled(SeatedState, false)
    end

    local Stamina = GetStamina()
    local Hunger = GetHunger()
    local Protein = GetProtein()
    local Health = Hum.Health / Hum.MaxHealth

    if Stamina > 80 then
        HiddenFlags.GoodStamina = true
    end

    if Stamina < 20 then
        HiddenFlags.GoodStamina = false
    end

    if Hunger > 80 then
        HiddenFlags.GoodHunger = true
    end

    if Hunger < 20 then
        HiddenFlags.GoodHunger = false
    end

    if Protein > 80 then
        HiddenFlags.GoodProtein = true
    end

    if Protein < 20 then
        HiddenFlags.GoodProtein = false
    end

    if Health > 0.8 then
        HiddenFlags.GoodHealth = true
    end

    if Health < 0.2 then
        HiddenFlags.GoodHealth = false
    end

    HiddenFlags.VestEquipped = not not Character:FindFirstChild('Vest')
    HiddenFlags.MaskEquipped = not not Character:FindFirstChild('Mask')
end

local function AntiCheatBypass()
    local RemoteEvent = Instance.new('RemoteEvent')
    local OriginalFireServer; OriginalFireServer = hookfunction(RemoteEvent.FireServer, function(...)
        local Self, Action, Args = ...
        if Action == "Run" and type(Args) == "table" and Args[1] == true then
            -- warn("[afy] prevented ban")
            return
        end
        
        return OriginalFireServer(...)
    end)

    local Found = false
    local Descendants = HiddenFlags.Constants.Purchases and HiddenFlags.Constants.Purchases:GetDescendants() or {}
    for Index, Value in Descendants do
        if not Value:IsA('Model') then continue end

        if Value.Name == 'Chicken' then
            if not Found then Found = true continue end
            table.insert(HiddenFlags.Blacklisted, Value)
        end
    end
end

local function Deinit()
    local Character = Client.Character
    local Hum = GetHum(Character)

    local SeatedState = Enum.HumanoidStateType.Seated
    if Hum and Hum:GetStateEnabled(SeatedState) then
        Hum:SetStateEnabled(SeatedState, true)
    end

    for _, Part in HiddenFlags.Parts do
        Part:Destroy()
    end

    for _, Connection in HiddenFlags.Connections do
        Connection:Disconnect()
    end

    for _, Function in HiddenFlags.HookedFunctions do
        restorefunction(Function)
    end

    for RemoteFunction, Function in HiddenFlags.ClientInvokes do
        RemoteFunction.OnClientInvoke = Function
    end
end

local function SetStats()
    local Stats = ''

    local CalculatedStats = {'LowerMuscle', 'StyleEXP', 'TotalPower2', 'UpperMuscle', ClientData.Style..'EXP'}
    local Viewed = {'Calorie', 'EmployeeLevel', 'BodyLimit', 'Bank', 'HighestStage', 'Fat'}

    for Index, Value in ClientData do
        if table.find(CalculatedStats, Index) then
            Stats..= `{Index}: {Value}\n`
        end

        if table.find(Viewed, Index) then
            Stats..= `{Index}: {Value}\n`
        end

        if Index == 'Playtime' then
            Stats..= `{math.round((Value or 0) / (60^2))} Hours\n`
        end
    end

    for _, Raid in HiddenFlags.Constants.RaidTypes do
        local Cooldown = IsOnCooldown(Raid..'Cooldown')

        if Cooldown then
            local Remaining = math.max(0, Cooldown)
            local Parts = {}

            local h = math.floor(Remaining / 3600)
            local m = math.floor((Remaining % 3600) / 60)
            local s = Remaining % 60

            if h > 0 then
                table.insert(Parts, string.format("%d Hour%s", h, h == 1 and "" or "s"))
            end

            if m > 0 or h > 0 then
                table.insert(Parts, string.format("%d Minute%s", m, m == 1 and "" or "s"))
            end

            if s > 0 or #Parts == 0 then
                table.insert(Parts, string.format("%d Second%s", s, s == 1 and "" or "s"))
            end

            Stats..= Raid.." Cooldown: " .. table.concat(Parts, " ") .. '\n'
        end
    end

    if Flags.BodyCondition then
        Stats..=`Recovering: {HiddenFlags.Recovering}\n`
    end

    if Flags.WatchedPlayer then
        local WatchedPlayer = Players:FindFirstChild(Flags.WatchedPlayer)
        local WCharacter = WatchedPlayer and WatchedPlayer.Character
        local WHum = GetHum(WCharacter)
        
        if WHum then
            local HPPercent = math.floor((WHum.Health / WHum.MaxHealth) * 100)
            Library.Options.WatchedPlayerHP:SetValue(
                string.format('%s: %d/%d (%d%%)', Flags.WatchedPlayer, math.floor(WHum.Health), math.floor(WHum.MaxHealth), HPPercent)
            )
        else
            Library.Options.WatchedPlayerHP:SetValue(Flags.WatchedPlayer .. ': No character found')
        end
    end

    HiddenFlags.Stats = Stats
    Library.Options.StatsData:SetValue(HiddenFlags.Stats)
end

local function SafeHeightUpdater()
    local Character = Client.Character
    local Root = GetRoot(Character)
    local Senkaimon = workspace.Regions:FindFirstChild("This Place Looks Familiar...")

    HiddenFlags.SafeY = HiddenFlags.StandardSafeY

    if Root and Senkaimon then
        if GetDistanceXZ(Senkaimon, Root) < 500 then
            HiddenFlags.SafeY = HiddenFlags.SenkaimonSafeY
        end
    end
end

local function PostSimulation()
    SafeHeightUpdater()
    SetStats()
    SetCharacterData()

    if HiddenFlags.AttemptCalisthenic then
        CalisthenicHandler()
    end
end

local function SetUnnamedConsants()
    for Index, Part in workspace:GetChildren() do
        if not Part:IsA('Part') then continue end
        
        local ClickDetector = Part:FindFirstChildWhichIsA('ClickDetector')
        if not ClickDetector then continue end

        local BillboardGui = Part:FindFirstChild('BillboardGui')
        local Label = BillboardGui and BillboardGui:FindFirstChild('Label')
        if not Label then continue end
        
        if Label.Text == 'Open Bank Account' then
            HiddenFlags.Constants.BankPart = Part
            break
        end
    end
end

local function NewAnimData(Name, Type, Anim, Additional)
    HiddenFlags.AttackAnims[Anim.AnimationId:match('%d+')] = {Name = Name, Type = Type, Additional = Additional or 0}
end

local function GatherParryData()
    local Ignore = {'Block', 'BlockHit', 'BodyConditioning', 'Cleaning', 'ClashKnockback', 'TheHunt_Leap', 'Block_Broken', 'Perfect_Block', 'Back', 'Front', 'Left', 'OldBack', 'OldFront', 'OldLeft', 'OldRight', 'Right'}
    local M1Anims = {'1', '2', '3', '4', '5'}
    
    for _, Style in ReplicatedFirst.Anims:GetChildren() do
        for _, Animation in Style:GetChildren() do
            if table.find(Ignore, Animation.Name) then continue end
            if Animation.Parent.Name == 'Stuns' then continue end
            if Animation.Parent.Name == 'Runs' then continue end
            if Animation.Parent.Name == 'Misc' then continue end
            if Animation.Parent.Name == 'Dashes' then continue end
            if Animation.Parent.Name == 'Skills' then continue end

            local Type = 'Normal'
            local Additional = 0

            if not table.find(M1Anims, Animation.Name) then
                Type = 'Slow'
            end

            if Animation.Name == 'M2' then
                Type = 'Heavy'
                Additional += 10
            end

            NewAnimData(Style.Name .. ' : ' .. Animation.Name, Type, Animation, Additional)
        end
    end

    for _, Animation in ReplicatedFirst.Anims.Skills:GetDescendants() do
        if not Animation:IsA('Animation') then continue end
        if Animation.Name ~= 'Grab' then continue end
        NewAnimData(Animation.Parent.Name .. ' : ' .. Animation.Name, 'Slow', Animation)
    end

    -- for _, Animation in ReplicatedFirst.ClientAnims.Skills:GetChildren() do
    --     NewAnimData(Animation.Name, 'Slow', Animation)
    -- end
end

local function EquipmentHandler(Type)
    local Character = Client.Character
    local Root = GetRoot(Character)
    if not Root then return end
    
    local EquipmentType = Type == 'Vest' and Flags.VestType or Type == 'Mask' and 'Breathing Mask'
    if not EquipmentType then return end

    local Equipment = HasTool(EquipmentType)

    if Equipment then
        UseTool(Equipment.Name)
        MoveTo(vector.create(Root.Position.X, HiddenFlags.SafeY, Root.Position.Z))
    else
        PurchaseItem(EquipmentType)
    end
end

local function MachineHandler()
    local Machines = {}

    for Index, Machine in workspace.Trainings:GetDescendants() do
        if not Machine:IsA('Model') then continue end
        if Machine.Name ~= Flags.MachineType then continue end
        local ClickDetector = Machine:FindFirstChildWhichIsA('ClickDetector')
        if not ClickDetector then continue end
        table.insert(Machines, Machine)
    end

    local ClosestMachine = GetClosestInTable(Machines, { ExcludeNearAPlayer = Flags.MachineDistanceFromPlayer })

    if ClosestMachine then
        local ClickDetector = ClosestMachine:FindFirstChildWhichIsA('ClickDetector')
        
        MoveTo(ClosestMachine:GetPivot().Position)
        fireclickdetector(ClickDetector)
    end
end

local function SetStrikingType()
    local Character = Client.Character
    local Humanoid = GetHum(Character)
    if not Humanoid then return end

    local StrikingGainType = HiddenFlags.Constants.StrikingGainTypes[Flags.StrikingGainType]
    if not StrikingGainType then return end

    CreateHookInvoke(HiddenFlags.Constants.StrikingGain, function()
        if StrikingGainType == 'Durability' then
            if Humanoid.Health < Humanoid.MaxHealth then return 'Strength' end
        end
        
        return StrikingGainType
    end)
end

local function RevertStrikingType()
    local RemoteFunction = HiddenFlags.Constants.StrikingGain
    local OriginalFunction = HiddenFlags.ClientInvokes[RemoteFunction]

    if OriginalFunction then
        RemoteFunction.OnClientInvoke = OriginalFunction
    end
end

local function GetClosestBag()
    local Bags = {}
    
    for Index, Model in workspace.Trainings:GetDescendants() do
        if not Model:IsA('Model') then continue end
        if table.find(HiddenFlags.Blacklisted, Model) then continue end
        if Model.Name ~= 'PunchingBag' then continue end
        if Model:GetPivot().Position.Y > 25 then continue end
        if GetDistance(workspace.GangBase.GYM, Model) < 150 then continue end
        table.insert(Bags, Model)
    end

    local ClosestBag = GetClosestInTable(Bags, { ExcludeNearAPlayer = Flags.StrikingDistanceFromPlayer })

    return ClosestBag
end

local function GetAvailableSkill()
    for _, Tool in Backpack:GetChildren() do
        if Tool.Name == 'Combat' then continue end
        if not Tool:GetAttribute('CombatTool') then continue end
        if Tool:GetAttribute('Ultimate') then continue end
        if IsOnCooldown(Tool.Name) then continue end
        return Tool
    end
end

local function GetAvailableUltimate()
    local Ultimate = Client:GetAttribute('Ultimate')
    if not Ultimate then return end
    if Ultimate < 100 then return end

    for _, Tool in Backpack:GetChildren() do
        if Tool.Name == 'Combat' then continue end
        if not Tool:GetAttribute('CombatTool') then continue end
        if not Tool:GetAttribute('Ultimate') then continue end
        if IsOnCooldown(Tool.Name) then continue end
        return Tool
    end
end

local function GetMode()
    for _, Tool in Backpack:GetChildren() do
        if not Tool:GetAttribute('CombatTool') then continue end
        if not Tool:GetAttribute('Clan') then continue end
        if IsOnCooldown(Tool.Name) then continue end
        return Tool
    end
end

local function Combat(Options)
    Options = Options or { UseM1 = true, UseM2 = true }
    if IsOnCooldown('ToolYield') then return end

    if HiddenFlags.GoodStamina then
        if Options.StopBlock and HiddenFlags.Blocking then
            ReplicatedStorage:WaitForChild("Events"):WaitForChild("EventCore"):FireServer("Block", false)
            return
        end

        if not IsOnCooldown('MoveCooldown') then
            if Options.UseSkills then
                local Skill = GetAvailableSkill()

                if Skill then
                    UseTool(Skill.Name)
                    SetCooldown('MoveCooldown', 1)
                    SetCooldown('ToolYield', 0.5)
                    return
                end
            end

            if Options.UseUltimate then
                local Ultimate = GetAvailableUltimate()

                if Ultimate then
                    UseTool(Ultimate.Name)
                    SetCooldown('MoveCooldown', 1)
                    SetCooldown('ToolYield', 0.5)
                    return
                end
            end

            if Options.UseMode then
                local Mode = GetMode()

                if Mode then 
                    UseTool(Mode.Name)
                    SetCooldown('MoveCooldown', 1)
                    SetCooldown('ToolYield', 0.5)
                    return
                end
            end
        end

        if Options.Block and not HiddenFlags.Blocking and not IsOnCooldown('StartBlock') and not IsOnCooldown('FakeoutDelay') then
            ReplicatedStorage:WaitForChild("Events"):WaitForChild("EventCore"):FireServer("Block", true)
            SetCooldown('FakeoutDelay', 3)
            SetCooldown('ToolYield', 0.2)
        end

        if Options.UseM2 and not IsOnCooldown('M2') then
            ReplicatedStorage:WaitForChild("Events"):WaitForChild("EventCore"):FireServer("M2")
            SetCooldown('M2', 3.5)
            return
        end

        if Options.UseM1 then
            UseTool('Combat')
        end
    end
end

local function StrikingHandler()
    local Character = Client.Character
    local Root = GetRoot(Character)
    if not Root then return end

    SetStrikingType()

    task.defer(function()
        if not Flags.StrikingTraining then
            RevertStrikingType()
        end
    end)

    local IsGloved = Character:FindFirstChild('Gloves')

    if IsGloved then
        local Adornee = GetTargetAdornee()

        if Adornee then
            local SafeBag = not IsPlayerNearModel(Adornee, Flags.StrikingDistanceFromPlayer - 1)

            if SafeBag then
                local BagPosition = Adornee:GetPivot().Position
                local PreferredPosition = BagPosition + vector.create(0, -8, 0)

                MoveTo(PreferredPosition)
                Root.CFrame = CFrame.new(PreferredPosition, BagPosition)

                if HiddenFlags.GoodStamina then
                    if not IsOnCooldown('HitDelay') then
                        HiddenFlags.StrikingM1Count = (HiddenFlags.StrikingM1Count or 0) + 1
                        if HiddenFlags.StrikingM1Count >= 5 then
                            HiddenFlags.StrikingM1Count = 0
                            Combat({ UseM1 = true, UseM2 = false })
                            SetCooldown('HitDelay', 9e9)
                            task.delay(1.05, function()
                                ReplicatedStorage.Events.EventCore:FireServer("M2")
                                SetCooldown('HitDelay', 0.425)
                            end)
                        else
                            SetCooldown('HitDelay', 0.425)
                            Combat({ UseM1 = true, UseM2 = false })
                        end
                    end
                end
            else
                Root.CFrame = CFrame.new(Root.Position.X, HiddenFlags.SafeY, Root.Position.Z)
            end
        else
            Root.CFrame = CFrame.new(Root.Position.X, HiddenFlags.SafeY, Root.Position.Z)
        end
    else
        local Tool = HasTool('Striking Training')

        if Tool then
            local Bag = GetClosestBag()
            
            if Bag then
                MoveTo(Bag:GetPivot().Position + vector.create(0, -8, 0))

                if Flags.StrikingType == 'Durability' then
                    if HiddenFlags.GoodHealth then
                        UseTool(Tool.Name)
                    else
                        Root.CFrame = CFrame.new(Root.Position.X, HiddenFlags.SafeY, Root.Position.Z)
                    end
                else
                    UseTool(Tool.Name)
                end
            else
                Root.CFrame = CFrame.new(Root.Position.X, HiddenFlags.SafeY, Root.Position.Z)
            end
        else
            PurchaseItem('Striking Training')
        end
    end
end

local function TransferHandler()
    if Flags.Withdraw then
        local CurrentWallet = GetWalletBalance()

        if CurrentWallet < 5_000 then
            Withdraw(HiddenFlags.Constants.WalletMax - 5_000)
        end
    end

    if Flags.Deposit then
        local CurrentWallet = GetWalletBalance()

        if CurrentWallet == HiddenFlags.Constants.WalletMax then
            Deposit(CurrentWallet - 10_000)
        end
    end
end

local function Block(State, Button)
    if not Button then return end

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

    if NumToEnum[Button] then
        Button = NumToEnum[Button]
    end

    VirtualInputManager:SendKeyEvent(State, Button, false, game)
    return Button
end

local function CalculatePingWait(n)
    if Flags.UseCustomDelay then
        n += Flags.CustomDelay / 1000
    else
        local Ping = Stats.PerformanceStats.Ping:GetValue() / 1000
        n -= Ping * (Flags.PingAdjustmentPercentage / 100)
    end

    return n
end

local function AutoParryCharacterAdded(PCharacter)
    if not PCharacter then return end

    local IsPlayer = Players:GetPlayerFromCharacter(PCharacter)
    local PRoot = GetRoot(PCharacter)
    local PHum = GetHum(PCharacter)
    if not PRoot or not PHum then return end

    if PRoot == GetRoot(Client.Character) then return end

    local PAnimator = PHum:FindFirstChildWhichIsA('Animator') or PHum

    local AnimConnection = CreateConnection(PAnimator.AnimationPlayed, function(AnimationTrack)
        if not Flags.Parry then return end
        
        local EntityPosition = PRoot and PRoot.Position
        local Char = Client.Character
        local Root = GetRoot(Client.Character)

        if (not EntityPosition or not Root) then return end
        if GetDistance(EntityPosition, Root.Position) >= 30 then return end

        if IsPlayer and (AnimationTrack.WeightTarget == 0 or AnimationTrack.Priority == Enum.AnimationPriority.Core) then return end

        local AnimId = AnimationTrack.Animation.AnimationId:match('%d+')
        local DataAnim = HiddenFlags.AttackAnims[AnimId]
        local Hum = GetHum(Char)

        if PHum and Char and Root and Hum and AnimId and DataAnim then
            if Char:FindFirstChildWhichIsA('ForceField') then return end
            
            local InStance = Char:FindFirstChild('Combat')

            if InStance then
                if Flags.ParryChance < Random.new():NextInteger(0, 100) then return end

                local PrimaryDodge = Flags.DashFirst and 'Q' or 'F'
                local BlockKey = PrimaryDodge

                local Type = DataAnim.Type
                local Delay = (Type == 'Normal' or Type == 'Fast' or Type == 'Ranged') and 10 or
                    Type == 'MidRanged' and 25 or
                    Type == 'Slow' and 40
                    or 20

                Delay += DataAnim.Additional

                local WaitedDelay = CalculatePingWait(Delay)

                while (AnimationTrack.TimePosition / AnimationTrack.Length) * 100 < WaitedDelay do
                    task.wait()
                end

                -- print('Name', Type, 'Length', anim.Length, 'Speed', anim.Speed, 'TimePosition', anim.TimePosition, 'Calculated Ping Wait', WaitedDelay)

                if (not AnimationTrack.IsPlaying) then return end

                -- local TargetVelocityMagnitude = vector.magnitude(TargetVelocity)
                -- local IsRunning = TargetVelocityMagnitude > 5
                local IsClientRunning = Hum.WalkSpeed > 8
                local TargetVelocity = PRoot.AssemblyLinearVelocity
                local IsRunning = Hum.WalkSpeed > 8
                local Distance = vector.magnitude(Root.Position - PRoot.Position)
                local ToPlayer = vector.normalize(Root.Position - PRoot.Position)

                -- local TargetLook = PRoot.CFrame.LookVector
                local TargetCFrame = PCharacter:GetPivot()
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

                -- local CanDash = ReplicatedStorage:WaitForChild("Events"):WaitForChild("FunctionCore") -- Probably not worth using this

                if Flags.AlternateEvade then
                    if not IsOnCooldown('StartBlock') then
                        BlockKey = "F"
                    else
                        BlockKey = "Q"
                    end
                else
                    if PrimaryDodge == "Q" then
                        BlockKey = "Q"
                    else
                        BlockKey = "F"
                    end
                end

                if Flags.DisableParryWhileClientRunning and IsClientRunning and BlockKey == 'F' then
                    BlockKey = 'Q'
                end

                if BlockKey == 'Q' then
                    Block(true, 'S')
                end

                local Pressed = Block(true, BlockKey)

                task.delay(0.3, function()
                    Block(false, BlockKey)

                    if BlockKey == 'Q' then
                        Block(false, 'S')
                    end
                end)

                if Flags.AlternateEvade and DataAnim.DashAway then
                    Block(true, 'S')
                    Block(true, 'Q')
                    Block(false, 'Q')
                    Block(false, 'S')
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
    end)

    local OriginalParent = PCharacter.Parent
    CreateConnection(PCharacter:GetPropertyChangedSignal('Parent'), function(NewParent)
        if NewParent ~= OriginalParent then AnimConnection:Disconnect() end
    end)    
end

local function IsBodyConditionPopped(Character)
    local PHum = GetHum(Character)
    return Character and PHum and PHum.WalkSpeed == 0 and Character:FindFirstChild('Body Conditioning')
end

local function IsAnimationPlaying(Animator, AnimationId)
    for _, AnimationTrack in Animator:GetPlayingAnimationTracks() do
        if AnimationTrack.Animation.AnimationId == AnimationId then return AnimationTrack end
    end
end

local function BodyConditionHitter()
    local Character = Client.Character
    local Root = GetRoot(Character)
    if not Root then return end

    local Partner = Flags.BodyConditionPartner and Players:FindFirstChild(Flags.BodyConditionPartner)
    if not Partner then HiddenFlags.Recovering = true return end

    local PCharacter = Partner.Character
    local PHum = GetHum(PCharacter)
    local PRoot = GetRoot(PCharacter)
    local PAnimator = GetAnimator(PHum)
    if not PRoot or not PHum then return end

    local PartnerIsPopped = IsBodyConditionPopped(PCharacter)
    local PartnerHealthRatio = PHum.Health / PHum.MaxHealth
    local IsPartnerRecovering = IsAnimationPlaying(PAnimator, HiddenFlags.Constants.IsRecoveringAnimation)

    HiddenFlags.Recovering = IsPartnerRecovering and IsPartnerRecovering.IsPlaying

    if PartnerIsPopped and PartnerHealthRatio > Flags.PartnerStopThreshold then
        local PRootPosition = PRoot.Position + vector.create(0, 0, -5)

        MoveTo(PRootPosition)
        Root.CFrame = CFrame.new(PRootPosition, PRoot.Position)

        Combat()
    end
end

local function BodyConditionReceiver()
    local Character = Client.Character
    local Hum = GetHum(Character)
    local Root = GetRoot(Character)
    local Animator = GetAnimator(Hum)
    if not Hum then return end

    local Partner = Flags.BodyConditionPartner and Players:FindFirstChild(Flags.BodyConditionPartner)
    if not Partner then HiddenFlags.Recovering = true return end
    
    local PCharacter = Partner.Character
    local PRoot = GetRoot(PCharacter)
    local PHum = GetHum(PCharacter)
    local PAnimator = GetAnimator(PHum)
    if not PRoot then return end

    local BodyCondition = HasTool('Body Conditioning')
    if not BodyCondition then
        if GetTargetAdornee() then
            return 'Training'
        end
        
        PurchaseItem('Body Conditioning')
        return
    end

    local IsPopped = IsBodyConditionPopped(Character)
    local MyHealthRatio = Hum.Health / Hum.MaxHealth
    local IsPartnerRecovering = IsAnimationPlaying(PAnimator, HiddenFlags.Constants.IsRecoveringAnimation)
    local TimeSinceUnpopped = tick() - (HiddenFlags.LastUnpopped or 0)
    local AnimationTrack = IsAnimationPlaying(Animator, HiddenFlags.Constants.IsRecoveringAnimation)

    Root.AssemblyLinearVelocity = vector.zero

    if not AnimationTrack then
        AnimationTrack = Animator:LoadAnimation(HiddenFlags.RecoveringAnimation)
    end

    if MyHealthRatio < Flags.MyUnpopThreshold then
        if AnimationTrack then
            AnimationTrack:Play()
        end

        HiddenFlags.ClientRecovering = true
    end

    if MyHealthRatio >= Flags.MyRepopThreshold then
        if AnimationTrack then
            AnimationTrack:Stop()
        end

        HiddenFlags.ClientRecovering = false
    end

    HiddenFlags.Recovering = HiddenFlags.ClientRecovering and IsPartnerRecovering and IsPartnerRecovering.IsPlaying

    if IsPopped then
        if MyHealthRatio < Flags.MyUnpopThreshold then
            UseTool(BodyCondition.Name)
            SmartWait(0.5)
            HiddenFlags.LastUnpopped = tick()
        else
            MoveTo(vector.create(Root.Position.X, HiddenFlags.SafeY, Root.Position.Z))
        end
    else
        if MyHealthRatio >= Flags.MyRepopThreshold and TimeSinceUnpopped > 5 then
            if GetTargetAdornee() then
                return 'Training'
            end

            MoveTo(vector.create(Root.Position.X, HiddenFlags.SafeY, Root.Position.Z))
            UseTool(BodyCondition.Name)
            SmartWait(0.5)
        end

        return 'Floating'
    end
end

local function BodyConditionAlternate()
    local Character = Client.Character
    local Hum = GetHum(Character)
    local Root = GetRoot(Character)
    local Animator = GetAnimator(Hum)
    if not Hum or not Root then return end

    local Partner = Flags.BodyConditionPartner and Players:FindFirstChild(Flags.BodyConditionPartner)
    if not Partner then HiddenFlags.Recovering = true return end

    local PCharacter = Partner.Character
    local PHum = GetHum(PCharacter)
    local PRoot = GetRoot(PCharacter)
    local PAnimator = GetAnimator(PHum)
    if not PRoot or not PHum then return end

    local BodyCondition = HasTool('Body Conditioning')
    if not BodyCondition then
        if GetTargetAdornee() then
            return 'Training'
        end
        
        PurchaseItem('Body Conditioning')
        return
    end

    local IAmPopped = IsBodyConditionPopped(Character)
    local PartnerIsPopped = IsBodyConditionPopped(PCharacter)
    local MyHealthRatio = Hum.Health / Hum.MaxHealth
    local PartnerHealthRatio = PHum.Health / PHum.MaxHealth
    local TimeSinceUnpopped = tick() - (HiddenFlags.LastUnpopped or 0)
    local IsPartnerRecovering = IsAnimationPlaying(PAnimator, HiddenFlags.Constants.IsRecoveringAnimation)
    local AnimationTrack = IsAnimationPlaying(Animator, HiddenFlags.Constants.IsRecoveringAnimation)

    Root.AssemblyLinearVelocity = vector.zero

    if not AnimationTrack then
        AnimationTrack = Animator:LoadAnimation(HiddenFlags.RecoveringAnimation)
    end

    if MyHealthRatio < Flags.MyUnpopThreshold then
        if AnimationTrack then
            AnimationTrack:Play()
        end

        HiddenFlags.ClientRecovering = true
    end

    if MyHealthRatio >= Flags.MyRepopThreshold then
        if AnimationTrack then
            AnimationTrack:Stop()
        end

        HiddenFlags.ClientRecovering = false
    end

    HiddenFlags.Recovering = HiddenFlags.ClientRecovering and IsPartnerRecovering and IsPartnerRecovering.IsPlaying

    if PartnerIsPopped and PartnerHealthRatio > Flags.PartnerStopThreshold then
        local PRootPosition = PRoot.Position + vector.create(0, 0, -5)
        
        MoveTo(PRootPosition)
        Root.CFrame = CFrame.new(PRootPosition, PRoot.Position)

        Combat()
    elseif IAmPopped then
        if MyHealthRatio < Flags.MyUnpopThreshold then
            UseTool(BodyCondition.Name)
            SmartWait(0.5)
            HiddenFlags.LastUnpopped = tick()
        else
            MoveTo(vector.create(Root.Position.X, HiddenFlags.SafeY, Root.Position.Z))
        end
    else
        if MyHealthRatio >= Flags.MyRepopThreshold and TimeSinceUnpopped > 5 then
            if GetTargetAdornee() then
                return 'Training'
            end

            MoveTo(vector.create(PRoot.Position.X, HiddenFlags.SafeY, PRoot.Position.Z))
            UseTool(BodyCondition.Name)
            SmartWait(0.5)
        else
            return 'Floating'
        end
    end
end

local function BodyConditionHandler()
    if Flags.BodyConditionType == 'Hitter' then
        return BodyConditionHitter()
    elseif Flags.BodyConditionType == 'Receiver' then
        return BodyConditionReceiver()
    elseif Flags.BodyConditionType == 'Alternate' then
        return BodyConditionAlternate()
    end
end

local function PlayerAdded(Player)
    local PlayerNames = GetSortedPlayersNames()

    if PlayerNames and #PlayerNames > 0 then
        Library.Options.BodyConditionPartner:SetValues(PlayerNames)
        Library.Options.WatchedPlayer:SetValues(PlayerNames)
    end

    PlayerRoleSanity(Player)
end

local function PlayerRemoving(Player)
    local PlayerNames = GetSortedPlayersNames()

    if PlayerNames and #PlayerNames > 0 then
        Library.Options.BodyConditionPartner:SetValues(PlayerNames)
        Library.Options.WatchedPlayer:SetValues(PlayerNames)
    end
end

local function RestartTrial()
    local Mob = workspace.Mobs:GetChildren()[1]
    if Mob then Mob:Destroy() end

    local Character = Client.Character
    ReplicatedStorage:WaitForChild("Events"):WaitForChild("TrialEvent"):FireServer()
    while HiddenFlags.Running and Character == Client.Character do task.wait() end

    ReplicatedStorage:WaitForChild("Events"):WaitForChild("TrialEvent"):FireServer()
    while HiddenFlags.Running and workspace.Mobs:GetChildren() == 0 do task.wait() end
end

local function GetEntity(Range)
    local Mob = GetClosestInTable(workspace.Mobs:GetChildren(), { MaxRange = Range or 200 })
    local TRoot = GetRoot(Mob)
    local THum = GetHum(Mob)

    if not (TRoot and THum) then return end
    if THum.Health <= 0 then return end

    return Mob, TRoot
end

local function GetTrialEntity()
    local Mob = GetClosestInTable(workspace.Mobs:GetChildren(), { MaxRange = 500 })
    local TRoot = GetRoot(Mob)
    local THum = GetHum(Mob)

    if not (TRoot and THum) then return end
    if THum.Health <= 0 then return 'Finished Trial' end

    return Mob, TRoot
end

local function TrialsHandler()
    local Character = Client.Character
    local Root = GetRoot(Character)
    local Hum = GetHum(Character)
    if not Root then return end

    local Mob, MobRoot = GetTrialEntity()

    if Mob then
        if Mob == 'Finished Trial' then
            RestartTrial()
        else
            local MobPivot = MobRoot:GetPivot()
            local CustomPosition = vector.create(MobPivot.Position.X, MobPivot.Position.Y - 8, MobPivot.Position.Z)

            MoveTo(MobPivot.Position, { SpecifiedY = CustomPosition.Y })
            Root.CFrame = CFrame.new(CustomPosition, MobPivot.Position)
            
            Combat({ UseM1 = true, UseM2 = true, UseSkills = Flags.Skills, UseUltimate = Flags.Ultimate, Block = true, StopBlock = true })
        end
    end
end

local function GetNextRaid()
    for Raid, _ in Flags.RaidTypes do
        if IsOnCooldown(Raid..'Cooldown') then continue end
        if Raid == 'Raid3' and not workspace:FindFirstChild(Raid) then continue end
        return Raid
    end
end

local function AttemptRaidServer()
    if not HiddenFlags.Constants.StandardServer then return end
    if HiddenFlags.CurrentlyTryingRaid then return end
    if IsOnCooldown('RaidAttemptCooldown') then return end

    HiddenFlags.CurrentlyTryingRaid = true
    SetCooldown('RaidAttemptCooldown', 3)

    local CurrentRaid = GetNextRaid()
    if not CurrentRaid then HiddenFlags.CurrentlyTryingRaid = false return end

    warn(`[Raid] Attempting to create {CurrentRaid}`)
    HiddenFlags.SelectedRaid = CurrentRaid
    HiddenFlags.Constants.Party:FireServer("Create", CurrentRaid)

    -- task.delay(2, function()
    --     if not HiddenFlags.CurrentlyTryingRaid then return end
    --     warn(`[Raid] Timeout: No response for {CurrentRaid} within 5 seconds. Blacklisting.`)
    --     SetCooldown(CurrentRaid .. 'Cooldown', 9e9)
    --     HiddenFlags.CurrentlyTryingRaid = false
    --     HiddenFlags.SelectedRaid = nil
    -- end)
end

local function GetDoors()
    local Doors = {}
    local Hitable = workspace:FindFirstChild('Hitable')

    for _, Door in Hitable and Hitable:GetChildren() or {} do
        local DoorHealth = Door:GetAttribute('Health')
        
        if DoorHealth and DoorHealth > 0 then
            table.insert(Doors, Door)
        end
    end

    return Doors
end

local function RaidsHandler()
    local Character = Client.Character
    local Root = GetRoot(Character)
    local Hum = GetHum(Character)
    if not Root then return end

    if HiddenFlags.Constants.IsInRaids then
        local Door = GetClosestInTable(GetDoors(), { MaxRange = 500 })
        local Mob, MobRoot = GetEntity()
        local MobHum = GetHum(Mob)

        if Door then
            Mob = Door
            MobRoot = Door
        else
            local Hitable = workspace:FindFirstChild('Hitable')
            local BankVault = Hitable and Hitable:FindFirstChild('BankVault')

            if BankVault then
                local VaultDist = GetDistance(Root, BankVault)

                if VaultDist < 100 then
                    firetouchinterest(Root, BankVault.Cylinder, 0)
                end
            end
        end

        if Mob then
            local Height = -8

            if MobHum and workspace:GetAttribute('BossServer') == 'Raid3' then
                if MobHum.Health / MobHum.MaxHealth < 0.95 then
                    Height = -15
                else
                    Height = 7
                end
            end

            local MobPivot = MobRoot:GetPivot()
            local CustomPosition = vector.create(MobPivot.Position.X, MobPivot.Position.Y + Height, MobPivot.Position.Z)

            MoveTo(MobPivot.Position, { SpecifiedY = CustomPosition.Y })
            Root.CFrame = CFrame.new(CustomPosition, MobPivot.Position)
            
            Combat({ UseM1 = true, UseM2 = true, UseSkills = Flags.Skills, UseUltimate = Flags.Ultimate })
        else
            MoveTo(Root.Position)
        end
    else
        AttemptRaidServer()
    end
end

local function MainMenuHandler()
    local LoadingScreen = PlayerGui:WaitForChild('LoadingScreen')

    if LoadingScreen then
        local Play = LoadingScreen:WaitForChild('LoadingFrame'):WaitForChild('Play')

        if Play and LoadingScreen.Enabled then
            for _, Connection in getconnections(Play.MouseButton1Click) do
                Connection:Function()
            end
        end

        return LoadingScreen.Enabled
    end
end

local function ModeHandler()
    if not HiddenFlags.StandardServer then
        Combat({ UseMode = Flags.Mode })
    end
end

-- local function BuyAllCashItems(Wares)
--     task.wait(2.5)
    
--     if not Flags.MerchantBuy then 
--         HiddenFlags.IsMerchantBuying = false
--         return 
--     end

--     if not Wares then 
--         HiddenFlags.IsMerchantBuying = false
--         return 
--     end

--     local Traveler = workspace.Merchants:WaitForChild("Traveler")
--     local TravelerRoot = Traveler and Traveler:WaitForChild('HumanoidRootPart')
--     if not Traveler or not TravelerRoot then
--         warn("[Merchant] Traveler not found!")
--         HiddenFlags.IsMerchantBuying = false
--         return
--     end

--     HiddenFlags.IsMerchantBuying = true
--     Library:Notify({
--         Title = "Merchant Detected",
--         Content = "Moving to Traveler to buy items...",
--         Duration = 4
--     })

--     local Char = Client.Character
--     local Root = GetRoot(Char)
--     if not Root then 
--         HiddenFlags.IsMerchantBuying = false
--         return 
--     end

--     local TargetPosition = TravelerRoot.Position + vector.create(0, -6, 0)
--     while HiddenFlags.Running and not MoveTo(TargetPosition) do if GetDistance(Root, TargetPosition) <= 5 then break end task.wait() end
--     SmartWait(1.2)

--     for Name, Data in Wares do
--         local Price = Data.Price
--         if not Price or Price.Currency ~= "Cash" then continue end

--         for i = 1, (Data.Amount or 1) do
--             if not HiddenFlags.Running or not HiddenFlags.IsMerchantBuying then 
--                 break 
--             end

--             ReplicatedStorage.Events.PurchaseEvent:FireServer(Name)
--             warn('[Merchant] Attempting to buy', Name)
--             SmartWait(0.85)
--         end
--     end

--     warn("[Merchant] Finished buying from Traveler")
--     HiddenFlags.IsMerchantBuying = false
-- end

local function BuyAllCashItems(Wares)
    if HiddenFlags.IsMerchantBuying then return end

    if Wares then
        HiddenFlags.LastMerchantWares = Wares
        local WaresReport = '**Merchant Spawned** | Server: ' .. game.JobId .. '\n' .. '```\n' .. Serialize(Data, {Prettify=true}) .. '```\n'

        HiddenFlags.LastWaresReport = WaresReport
        if not IsOnCooldown('WaresReportCooldown') then
            SetCooldown('WaresReportCooldown', 300) -- 5 min cooldown
            SendWebhook(WaresReport)
        end
    end

    if not Flags.MerchantBuy then
        HiddenFlags.IsMerchantBuying = false
        return
    end

    if not Wares then
        warn('[Merchant] Wares is nil')
        HiddenFlags.IsMerchantBuying = false
        return
    end

    local WaresPurchase = ReplicatedStorage.Events:FindFirstChild('WaresPurchase')
    local BuyProduct = ReplicatedStorage.Events:FindFirstChild('BuyProduct')
    warn('[Merchant] WaresPurchase:', WaresPurchase, '| BuyProduct:', BuyProduct)

    if not WaresPurchase and not BuyProduct then
        warn('[Merchant] No purchase remote found, cannot buy')
        HiddenFlags.IsMerchantBuying = false
        return
    end

    task.wait(2.5)

    local IgnoredItems = {
        ['Hair Color Reroll'] = true,
        ['Marking Reroll'] = true,
        ['Renew Shop'] = true,
        ['Zone Color Reroll'] = true,
        ['Eye Color Reroll'] = true,
        ['Face Reroll'] = true,
        ['Spawn Boss'] = true,
        ['Clan Reroll'] = true,
        ['Skill Reset'] = true,
        ['Style Reset'] = true,
    }

    HiddenFlags.IsMerchantBuying = true

    local BoughtReport = '**Merchant Purchase Summary** | Server: ' .. game.JobId .. '\n'
    local BoughtAnything = false

    for Name, Data in Wares do
        local Price = Data.Price
        local Currency = Price and Price.Currency or 'Unknown'

        if Currency ~= 'Cash' then continue end
        if IgnoredItems[Name] then
            warn('[Merchant] Ignoring', Name)
            BoughtReport ..= '❌ Ignored: **' .. Name .. '**\n'
            continue
        end

        local Amount = Data.Amount or 1
        warn('[Merchant] Buying', Name, 'x', Amount)

        for _ = 1, Amount do
            if not HiddenFlags.Running or not HiddenFlags.IsMerchantBuying then break end
            if WaresPurchase then WaresPurchase:FireServer(Name) end
            if BuyProduct then BuyProduct:FireServer(Name) end
            task.wait(0.1)
        end

        BoughtReport ..= '✅ Bought: **' .. Name .. '** x' .. Amount .. '\n'
        BoughtAnything = true
    end

    warn('[Merchant] Done buying all items')
    HiddenFlags.IsMerchantBuying = false

    if BoughtAnything then
        task.delay(3, function()
            if IsOnCooldown('PurchaseSummaryCooldown') then return end
            SetCooldown('PurchaseSummaryCooldown', 300)
            SendWebhook(BoughtReport)
        end)
    end
end

local function Init()
    SendWebhook(Client.Name .. ' Connected ✅')
    AntiCheatBypass()
    HiddenFlags.RecoveringAnimation = CreateInstance('Animation', {AnimationId=HiddenFlags.Constants.IsRecoveringAnimation})

    HiddenFlags.Running = true
    Library.GUI.Destroying:Once(function()
        HiddenFlags.Running = false
        shared.etocats = false
        shared.etocats_active = false
    end)

    local Success, GroupInfo = pcall(GetGroupInfoAsync, GroupService, HiddenFlags.TargetGroup)
    if not Success then return Library:Destroy() end
        
    for _, Role in GroupInfo.Roles do
        table.insert(HiddenFlags.GroupRoles, Role.Name)
    end

    if Flags.RoleInfo then
        for Index, _ in Flags.RoleInfo or {} do
            Flags.RoleInfo[Index] = Index
        end

        for Index, _ in Flags.JobType or {} do
            Flags.JobType[Index] = Index
        end

        for Index, _ in Flags.RaidTypes or {} do
            Flags.RaidTypes[Index] = Index
        end
    else
        Flags.RoleInfo = {}
        
        for _, Role in GroupInfo.Roles do
            Flags.RoleInfo[Role.Name] = Role.Rank > 1 and Role.Name or nil
        end
    end

    table.sort(HiddenFlags.GroupRoles, function(a, b) return a < b end)
    SetupUI()
    SetUnnamedConsants()
    GatherParryData()

    Client.DevCameraOcclusionMode = "Invisicam"
    Client.CameraMaxZoomDistance = math.huge
    
    for _, Connection in getconnections(Client.Idled) do
        Connection:Disconnect()
    end
    
    for _, Player in Players:GetPlayers() do
        task.spawn(PlayerRoleSanity, Player)
    end
    
    CreateConnection(ReplicatedStorage.Events.SkillCooldown.OnClientEvent, SetCooldown)
    CreateConnection(Players.PlayerAdded, PlayerAdded)
    CreateConnection(Players.PlayerRemoving, PlayerRemoving)
    CreateConnection(RunService.PostSimulation, PostSimulation)
    CreateConnection(ReplicatedStorage.Events.MerchantEvent.OnClientEvent, BuyAllCashItems)
    CreateConnection(ReplicatedStorage.Events.EventCore.OnClientEvent, function(...)
        local Type, Data, Num = ...

        if Type == 'pInfo' then
            local StatsData = Data.Stats

            if StatsData then
                HiddenFlags.Stamina = StatsData.Stamina
                HiddenFlags.MaxStamina = StatsData.MaxStamina
                HiddenFlags.BodyConditioning = StatsData.BodyConditioning
                HiddenFlags.Ragdoll = StatsData.StaminaKnocked or StatsData.Ragdolled or StatsData.Knocked
            end

            local BlockingData = Data.Blocking

            if BlockingData then
                if HiddenFlags.Blocking and not BlockingData.Block then
                    SetCooldown('StartBlock', 1)
                end

                HiddenFlags.Blocking = BlockingData.Block
            end

            HiddenFlags.InCombat = (Data.InCombat or 0) > 0
        end
    end)

    for _, Character in workspace.Living:GetChildren() do
        AutoParryCharacterAdded(Character)
    end
    for _, Character in workspace.Mobs:GetChildren() do
        AutoParryCharacterAdded(Character)
    end
    CreateConnection(workspace.Living.ChildAdded, AutoParryCharacterAdded)
    CreateConnection(workspace.Mobs.ChildAdded, AutoParryCharacterAdded)

    local OriginalNotify; OriginalNotify = CreateHookFunction(getrenv()._G.Notify, function(...)
        local Self, Message = ...

        if Message and HiddenFlags.SelectedRaid then
            if Message:find(`You can't create this raid for`) then
                local Hours = Message:match("(%d+)%s*hour")
                local Minutes = Message:match("(%d+)%s*minute")
                local Seconds = Message:match("(%d+)%s*second")

                Hours = tonumber(Hours) or 0
                Minutes = tonumber(Minutes) or 0
                Seconds = tonumber(Seconds) or 0

                SetCooldown(HiddenFlags.SelectedRaid..'Cooldown', (Hours * 3600) + (Minutes * 60) + Seconds)
            end

            if Message:find(`You can't create a lobby right now`) or Message:find('SS') then
                SetCooldown(HiddenFlags.SelectedRaid..'Cooldown', 9e9)
            end

            HiddenFlags.SelectedRaid = nil
            HiddenFlags.CurrentlyTryingRaid = false
        end

        return OriginalNotify(...)
    end)

    CreateConnection(HiddenFlags.Constants.Party.OnClientEvent, function()
        if not Flags.Raids then return end
        if not Flags.RaidTypes[HiddenFlags.SelectedRaid] then return end

        HiddenFlags.YieldSafe = math.huge
        warn('[afy] Starting', HiddenFlags.SelectedRaid)
        HiddenFlags.Constants.Party:FireServer("Start", HiddenFlags.SelectedRaid)
    end)

    CreateConnection(Client.OnTeleport, function()
        if HiddenFlags.SetQueue then return end
        HiddenFlags.SetQueue = true
        SendWebhook(Client.Name .. ' Reconnecting 🟡')
        queue_on_teleport(([[getgenv().Flags = %s loadstring(game:HttpGet('https://gist.githubusercontent.com/afyzone/d8ced8f52b2d4f6efdf0329aff23225c/raw/as.lua'))()]]):format(Serialize(Flags)))
    end)

    CreateConnection(TeleportService.TeleportInitFailed, function()
        SafeRejoin(2)
    end)

    if GuiService:GetErrorMessage() ~= '' then
        SafeRejoin(2)
    end
    
    CreateConnection(GuiService.ErrorMessageChanged, function()
        if HiddenFlags.ErrorMessageRejoining then return end
        HiddenFlags.ErrorMessageRejoining = true
        SafeRejoin(2)
    end)
    
    if HiddenFlags.Constants.IsInRaids then
        task.delay(300, function()
            if not HiddenFlags.Running then return end
            if not HiddenFlags.Constants.IsInRaids then return end

            warn('[Raid] 5 minute failsafe triggered, rejoining')
            SendWebhook(string.format('⏱️ **Raid Timeout** | 5min in raid without completing | Rejoining from: `%s`', game.JobId))
            SafeRejoin()
        end)
    end
end

Init()

while HiddenFlags.Running and task.wait() do
    local Character = Client.Character
    local Root = GetRoot(Character)
    local Hum = GetHum(Character)
    Backpack = Client:FindFirstChildWhichIsA('Backpack')

    if MainMenuHandler() then continue end
    if HiddenFlags.IsMerchantBuying then continue end

    if not Root then continue end
    ProtectionHandler()

    if HiddenFlags.YieldSafe and tick() - HiddenFlags.YieldSafe > 0 then
        Root.CFrame = CFrame.new(Root.Position.X, HiddenFlags.SafeY, Root.Position.Z)
        continue
    end

    if Flags.Trials and HiddenFlags.Constants.IsInTrials then
        TrialsHandler()
    elseif Flags.Raids then
        RaidsHandler()
    end

    if not HiddenFlags.Constants.StandardServer then continue end

    MinigameHandler()
    ModeHandler()

    HiddenFlags.AttemptCalisthenic = false

    local OnMachine = Root.Anchored
    if OnMachine then continue end

    TransferHandler()
    
    local IsGlovedNow = Character:FindFirstChild('Gloves')
    local StrikingActive = Flags.StrikingTraining and IsGlovedNow

    if Flags.Food and not HiddenFlags.GoodHunger and not StrikingActive then
        FoodHandler()
    elseif Flags.Protein and not HiddenFlags.GoodProtein and not StrikingActive then
        FoodHandler('Protein Shake')
    elseif Flags.ProteinDrain and not StrikingActive then
        FoodHandler('Protein Drain')
    elseif Flags.Vest and not HiddenFlags.VestEquipped and not StrikingActive then
        EquipmentHandler('Vest')
    elseif Flags.Mask and not HiddenFlags.MaskEquipped and not StrikingActive then
        EquipmentHandler('Mask')
    elseif Flags.BodyCondition then
        local Partner = Flags.BodyConditionPartner and Players:FindFirstChild(Flags.BodyConditionPartner)
        local Handler = Partner and BodyConditionHandler()

        if Handler == 'Training' or Handler == 'Floating' or Handler == 'StrikingOnly' or not Partner then
            if Flags.StrikingTraining then
                StrikingHandler()
            elseif Handler ~= 'StrikingOnly' then
                if Flags.Machine then
                    MachineHandler()
                else
                    HiddenFlags.AttemptCalisthenic = true
                    if Flags.Roadwork then
                        RoadworkHandler()
                    elseif Flags.Job then
                        JobHandler()
                    else
                        MoveTo(vector.create(Root.Position.X, HiddenFlags.SafeY, Root.Position.Z))
                    end
                end
            end
        end
    elseif Flags.Machine then
        MachineHandler()
    elseif Flags.StrikingTraining then
        StrikingHandler()
    else
        HiddenFlags.AttemptCalisthenic = true

        if Flags.Roadwork then
            RoadworkHandler()
        elseif Flags.Job then
            JobHandler()
        end
    end
end

Deinit()
