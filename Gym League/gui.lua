-- https://www.roblox.com/games/17450551531 | Co-op coded with @Leadmarker

local service = setmetatable({}, {
    __index = function(self, key)
        local service = cloneref(game:GetService(key))
        rawset(self, key, service)
        
        return rawget(self, key)
    end
})

local players = service.Players
local runservice = service.RunService
local pathfindservice =  service.PathfindingService
local replicatedstorage = service.ReplicatedStorage
local ReplicatedStorage = service.ReplicatedStorage
local EquipmentsModule = require(ReplicatedStorage.Shared.presets.equipments)
local BigNum = require(ReplicatedStorage.Packages.BigNum)

local Material = loadstring(game:HttpGet("https://gist.githubusercontent.com/afyzone/8874e6a5f489d7e548db2ed8f5b87004/raw/"))()
local UI = Material.Load({Title = "@cats - Gym League",Style = 1,SizeX = 500,SizeY = 400, ColorOverrides = { MainFrame = Color3.fromRGB(15,15,15), Minimise = Color3.fromRGB(68, 208, 255), MinimiseAccent = Color3.fromRGB(3, 188, 182), Maximise = Color3.fromRGB(25,255,0), MaximiseAccent = Color3.fromRGB(0,255,110), NavBar = Color3.fromRGB(15,15,15), NavBarAccent = Color3.fromRGB(255,255,255), NavBarInvert = Color3.fromRGB(15,15,15), TitleBar = Color3.fromRGB(30, 30, 30), TitleBarAccent = Color3.fromRGB(255,255,255), Overlay = Color3.fromRGB(30, 30, 30), Banner = Color3.fromRGB(30, 30, 30), BannerAccent = Color3.fromRGB(255,255,255), Content = Color3.fromRGB(85,85,85), Button = Color3.fromRGB(40, 40, 40), ButtonAccent = Color3.fromRGB(235, 235, 235), ChipSet = Color3.fromRGB(170, 170, 170), ChipSetAccent = Color3.fromRGB(100,100,100), DataTable = Color3.fromRGB(160,160,160), DataTableAccent = Color3.fromRGB(45,45,45), Slider = Color3.fromRGB(45,45,45), SliderAccent = Color3.fromRGB(235,235,235), Toggle = Color3.fromRGB(230, 230, 230), ToggleAccent = Color3.fromRGB(235, 235, 235), Dropdown = Color3.fromRGB(45, 45, 45), DropdownAccent = Color3.fromRGB(235,235,235), ColorPicker = Color3.fromRGB(10, 10, 10), ColorPickerAccent = Color3.fromRGB(235,235,235), TextField = Color3.fromRGB(55,55,55), TextFieldAccent = Color3.fromRGB(235,235,235), }})

local client = players.LocalPlayer
local playergui = client:WaitForChild('PlayerGui')
local label_timer = workspace.Podium.entrance.billboard.billboard.labelTimer

local powerups, fast_mode = {}, {
    ['Stamina'] = false,
    ['Chest'] = true,
    ['Triceps'] = not workspace.Equipments:FindFirstChild('triceppushdown'),
    ['Shoulder'] = true,
    ['Abs'] = true,
    ['Forearm'] = true,
    ['Legs'] = false,
    ['Back'] = true,
    ['Biceps'] = true,
    ['Calves'] = true,
}

-- local equipment_rewards = {
--     ['Stamina'] = 'treadmill',
--     ['Chest'] = 'benchpress',
--     ['Triceps'] = workspace.Equipments:FindFirstChild('triceppushdown') and 'triceppushdown' or 'tricepscurl',
--     ['Shoulder'] = 'pushpress',
--     ['Abs'] = 'crunch',
--     ['Forearm'] = 'wristcurl',
--     ['Legs'] = 'legpress',
--     ['Back'] = 'deadlift',
--     ['Biceps'] = 'hammercurl',
--     ['Calves'] = 'frontsquat',
-- }

local Equipments = {} -- {['hammercurl'] = {['Biceps'] = 0.7, ['Forearm'] = 0.3}, ...}
local EquipmentNaming = {}
for Index, EquipmentInfo in EquipmentsModule do
	if type(EquipmentInfo) == 'table' and (EquipmentInfo.type == 'machine' or EquipmentInfo.type == 'weight' or EquipmentInfo.type == 'treadmill') then
        Equipments[Index] = EquipmentInfo.earnings
        table.insert(EquipmentNaming, Index)
	end
end

local function GetBestEquipmentName(Muscle)
    local Highest, Best = 0, nil

    for MachineName, Info in Equipments do
        local Machine = workspace.Equipments:FindFirstChild(MachineName)
        if not Machine then continue end

        local Stat = Info[Muscle]
        if not Stat then continue end

        if Stat > Highest then
            Highest = Stat
            Best = MachineName
        end
    end

    return Best
end

for i,v in (playergui.Frames.GymStore.PowerUps.CanvasGroup.List:GetChildren()) do
    if (not v:IsA('Frame')) then continue end

    powerups[v.Name] = false
end

local get_char, get_backpack, get_root, get_hum; do 
    get_char = function(player)
        return player.Character
    end

    get_root = function(char)
        return char and char:FindFirstChild('HumanoidRootPart')
    end

    get_hum = function(char)
        return char and char:FindFirstChildWhichIsA('Humanoid')
    end

    get_backpack = function(player)
        return player:FindFirstChildWhichIsA('Backpack')
    end
end

local script_handler = {}; do
    script_handler.__index = script_handler

    function script_handler.new() 
        local self = setmetatable({}, script_handler)
        self.debounces = {}
        self.fast_mode_delay = 0
        self.current_path = nil
        self.current_farming = nil
        self.current_farming_instance = nil

        self.manual_farm = nil
        self.farmmode = false
        self.autofarm = false

        self.enable_fast_mode = false
        self.fast_mode = false

        self.manual = false
        
        self.auto_click = false
        self.autocomp = false
        self.comp_yield = false

        self.next_alter = false
        
        self.auraautoroll = false
        self.buyaurarolls = false

        self.buy_powerup = false
        self.use_powerup = false
        self.use_all_powerups = false
        self.selected_powerup = {}
        
        -- self.ui_funcs = {}; do
        --     for i,v in (equipment_rewards) do
        --         self.ui_funcs[i] = function(self)
        --             self.SetText(v)
        --         end
        --     end
        -- end

        return self
    end 

    function script_handler:update_farm(text: string)
        if (not self.manual and self.current_farming ~= text) then 
            self:call('EquipmentService', 'RF', 'Leave')
            self.current_farming_instance = nil
        end

        self.current_farming = text
    end
 
    function script_handler:toggle_autofarm(state: boolean) 
        self.autofarm = state
        
        if (not self.autofarm) then 
            self:call('EquipmentService', 'RF', 'Leave')
            self.current_farming_instance = nil
        end
    end
    
    function script_handler:get_equipment(name: string)
        local dist, closest, prompt = math.huge
        local char = get_char(client)
        local root = get_root(char)

        if not (char and root) then return end

        for i,v in (workspace:FindFirstChild('Equipments'):GetChildren()) do
            if (v.Name ~= name) then continue end
            if (self.current_farming_instance) then
                if (self.current_farming_instance ~= v and v:GetAttribute('occupied')) then continue end
            else
                if (v:GetAttribute('occupied')) then continue end
            end

            local mag = vector.magnitude(v:GetPivot().Position - root.Position)

            if (mag < dist) then
                dist = mag
                closest = v
                prompt = v:FindFirstChildWhichIsA('Part'):FindFirstChildWhichIsA('ProximityPrompt')
            end
        end

        return closest, prompt
    end
    
    function script_handler:grab_stamina()
        local Stamina = BigNum.fromString64(client:GetAttribute('stamina') or BigNum.One)
        local MaxStamina = BigNum.fromString64(client:GetAttribute('maxStamina') or BigNum.One)

        return (Stamina:native() / MaxStamina:native()) * 100
    end

    function script_handler:move(pos: Vector3)
        local char = get_char(client)
        local humanoid = get_hum(char)
        local root = get_root(char)

        if not (humanoid and root) then return end

        -- humanoid:MoveTo(pos)
        if (vector.magnitude(pos - root.Position) > 0.2) then
            humanoid.WalkToPoint = pos
        end
    end

    function script_handler:pathmove(pos: Vector3)
        if (self.current_path) then return end
        self.current_path = true
        local char = get_char(client)
        local hum = get_hum(char)
        local root = get_root(char)
    
        if (char and hum and root) then
            if (hum.SeatPart) then
                hum.Sit = false
            end
    
            local path = pathfindservice:CreatePath({AgentRadius = 3, AgentHeight = 5, AgentCanJump = true, AgentCanClimb = true, WaypointSpacing = 4})

            local success = pcall(function()
                path:ComputeAsync(root.Position, pos)

                if path.Status ~= Enum.PathStatus.Success then
                    local SpawnLocation = workspace.Map:FindFirstChild('SpawnLocation')
                    root.CFrame = SpawnLocation.CFrame + vector.create(0, 4, 0)
                    return
                end

                local waypoints = path:GetWaypoints()
    
                for _, waypoint in (waypoints) do
                    local waypointPosition = waypoint.Position
                    self:move(waypointPosition)
    
                    local distance = vector.magnitude(waypointPosition - root.Position)

                    while (distance > 5) do
                        local char = get_char(client)
                        local hum = get_hum(char)

                        if (not self.current_path or not hum or hum.MoveToPoint == vector.zero) then break end

                        self:move(waypointPosition)
                        distance = vector.magnitude(waypointPosition - root.Position)

                        task.wait()
                    end
                    if (not self.current_path) then return end
                end
            end)
    
            -- if (not success) then
            --     self:move(pos)
            -- end
        end
        self.current_path = nil
    end

    function script_handler:can_collide(bool: boolean)
        local char = get_char(client)
        if (not char) then return end 

        for i, v in char:GetDescendants() do 
            if (not v:IsA('BasePart')) then continue end 
            v.CanCollide = bool 
        end
    end

    function script_handler:call(service, folder, remote, ...)
        local remote_service = replicatedstorage.Packages._Index["sleitnick_knit@1.5.1"].knit.Services[service]
        local remote_folder = remote_service and remote_service[folder]
        local remote = remote_folder and remote_folder[remote]
        local args = {...}

        if (not remote) then return end

        if (remote:IsA('RemoteEvent') or remote:IsA('UnreliableRemoteEvent')) then
            return remote:FireServer(unpack(args))
        end
        
        if (remote:IsA('RemoteFunction')) then
            return remote:InvokeServer(unpack(args))
        end
    end

    function script_handler:roll(service, buy)
        if (buy) then
            self:call(service, 'RF', 'Buy')
        end

        self:call(service, 'RF', 'Spin')
    end

    function script_handler:update()
        local char = get_char(client)
        local root = get_root(char)
        local hum = get_hum(char)

        if not (char and hum and root) then 
            self.current_path = nil
            return 
        end

        self:competition()
        if (not self.comp_yield) then
            self:can_collide(client:GetAttribute('ragdolled'))
        end

        if (self.buy_powerup or self.use_powerup) then
            for i,v in (self.selected_powerup) do
                if (not self.use_all_powerups and not v) then continue end
                if (self.use_all_powerups and i == 'Milk') then continue end

                self:powerup_handler(i)
            end
        end

        if (self.auraautoroll) then
            self:roll('AuraService', self.buyaurarolls)
        end

        if (self.auraposeroll) then
            self:roll('PoseService', self.buyposerolls)
        end

        if (self.autoquest) then
            for Index, Quest in playergui.Frames.Quests.MainQuestsList:GetChildren() do
                local Reward = Quest:FindFirstChild('Reward')
                if not Reward or not Quest:IsA('Frame') or #Quest:GetChildren() == 0 then continue end

                if Reward.BackgroundColor3 == Color3.fromRGB(94, 255, 19) then
                    local Name = Quest.Name

                    self:call('QuestService', 'RF', 'complete', Name)
                    self:call('QuestService', 'RF', 'giveStoryQuest', Name)
                end
            end
        end

        if (self.autofarm or self.manual) then
            if (self.comp_yield) then return end

            if (root.Anchored) then
                local stamina = self:grab_stamina()

                if (stamina > 90) then 
                    self.farmmode = true
                elseif (stamina < 20) then 
                    self.farmmode = false 
                end
                
                if (self.current_farming == 'treadmill') then 
                    if (self.farmmode) then
                        self:call('EquipmentService', 'RF', 'ChangeSpeed', true)
                        
                        if (self.auto_click) then
                            self:call('EquipmentService', 'RE', 'click')
                        end
                    else
                        self:call('EquipmentService', 'RF', 'ChangeSpeed', false)
                    end
                else
                    if (self.farmmode) then 
                        self:call('EquipmentService', 'RF', 'AutoLoad')

                        -- if (not self.enable_fast_mode) then
                        --     task.spawn(function()
                        --         task.wait(0.1)
                        --         self:call('EquipmentService', 'RE', 'autoTrain', false)
                        --     end)
                        -- end

                        if (self.auto_click) then
                            self:call('EquipmentService', 'RE', 'click')
                        end
                        
                        if (self.enable_fast_mode and self.fast_mode and os.clock() - self.fast_mode_delay > 0.015) then
                            self:call('EquipmentService', 'RF', 'Leave')

                            local target, target_prompt = self:get_equipment(self.current_farming)
                            if (target and target_prompt) then 
                                root.CFrame = target:FindFirstChildWhichIsA('Part').CFrame
                                fireproximityprompt(target_prompt, 1, true)
                            end
                            
                            self.fast_mode_delay = os.clock()
                        end
                    end
                end
            else
                local target, target_prompt = self:get_equipment(self.current_farming)
                if (target and target_prompt) then 
                    self:pathmove(target:GetPivot().Position)
                    
                    if vector.magnitude(root.Position - target:GetPivot().Position) < 10 then
                        self.current_farming_instance = target
                        fireproximityprompt(target_prompt, 1, true)
                    end
                end
            end
        end
    end

    function script_handler:grab_farm()
        local current_stats = {
            ['Stamina'] = tonumber(playergui.Frames.Stats.Main.MuscleList.Stamina.Frame.APercentage.Text:match('%d+'))
        }

        for i,v in (playergui.Frames.Stats.Main.MuscleList.Stats:GetChildren()) do
            if (not v:IsA('ImageButton')) then continue end
            current_stats[v.Name] = tonumber(v.Frame.APercentage.Text:match('%d+'))
        end

        local all_stats_maxed = true
        local selected_farm = (function()
            for i,v in (current_stats) do
                if (v == 100) then continue end
                all_stats_maxed = false

                local EquipmentName = GetBestEquipmentName(i)
                if not EquipmentName then continue end

                local equipment = self:get_equipment(EquipmentName)
                if (not equipment) then continue end

                self.fast_mode = fast_mode[i]

                return EquipmentName
            end
        end)()

        if (all_stats_maxed and self.next_alter) then
            self:call('CharacterService', 'RF', 'NextAlter')
        end
    
        if (self.manual and self.manual_farm) then
            return self.manual_farm
        end

        return selected_farm or GetBestEquipmentName('Stamina')
    end

    function script_handler:competition()
        if (not self.autocomp) then return end

        local podium = playergui.Podium
        local rewards = podium.RewardsFrame

        if (podium.Enabled) then
            -- replicatedstorage:WaitForChild("Shared"):WaitForChild("minigames"):WaitForChild("Competition"):WaitForChild("comm"):FireServer()

            for i,v in (getconnections(rewards.CanvasGroup.Continue.MouseButton1Up)) do
                v:Function()
            end
            
            for i,v in (getconnections(podium.winners.ok.MouseButton1Up)) do
                v:Function()
            end
        else
            if (label_timer.Text:lower():find('starting')) then 
                self.comp_yield = true

                if (os.clock() - (self.debounces['competition'] or 0) > 3) then
                    self.current_farming_instance = nil
                    -- self:can_collide(true)
                    self:call('EquipmentService', 'RF', 'Leave')
                    self:call('MiniPodiumService', 'RF', 'Teleport')

                    self.debounces['competition'] = os.clock()
                end
            else
                if (self.comp_yield) then
                    self.current_path = nil
                end
                self.comp_yield = false
            end
        end
    end

    function script_handler:powerup_handler(item)
        local char = get_char(client)
        local backpack = get_backpack(client)
        local boost = playergui.Main.BottomCenter.Boosts.Scrolling.Inside:FindFirstChild(item)

        if (char and backpack) then
            local character_item = char:FindFirstChild(item)
            local backpack_item = backpack:FindFirstChild(item)

            if (boost) then
                if (self.use_powerup) then
                    -- if (backpack_item) then
                    --     backpack_item.Parent = char
                    -- end

                    -- if (character_item) then
                    --     character_item:Activate()
                    --     character_item.Parent = backpack
                    -- end
                    
                    self:call('ToolService', 'RF', 'ActivateTool', { powerupName = item, player = client })
                end
            else
                if (not boost and self.buy_powerup and os.clock() - (self.debounces[item] or 0) >= 2) then
                    self.debounces[item] = os.clock()
                    self:call('PowerUpsService', 'RF', 'Buy', item, 1)
                end
            end
        end
    end
end

local handler = script_handler.new()
local main_tab = UI.New({Title = 'Main'}); do 
    main_tab.Label({Text = 'Farming'})
    
    main_tab.Toggle({Text = 'Autofarm', Enabled = false, Callback = function(self)
        handler:toggle_autofarm(self)
    end, Menu = { Information = function(self) UI.Banner({Text = "Finds the best equipment to farm based on your stats." }) end}})

    main_tab.Label({Text = 'Manual Farming'})
    main_tab.Toggle({Text = 'Manual Farm', Enabled = false, Callback = function(self)
        handler.manual = self
    end, Menu = { Information = function(self) UI.Banner({Text = "Turning on manual mode wont auto complete your stats." }) end}})

    -- main_tab.TextField({
    --     Text = "Manual Farms",
    --     Editable = false,
    --     Callback = function(Value)
    --         handler.manual_farm = Value
    --     end,
    --     Menu = handler.ui_funcs
    -- })

    main_tab.Dropdown({Text = 'Choose manual farm', Default = 'Stamina', Options = EquipmentNaming, Callback = function(Value)
        handler.manual_farm = Value
    end})
    
    -- main_tab.Toggle({Text = 'Fast Mode (Blatant)', Enabled = false, Callback = function(self)
    --     handler.enable_fast_mode = self
    -- end, Menu = { Information = function(self) UI.Banner({Text = "Sometimes faster stat gain." }) end}})
    
    main_tab.Toggle({Text = 'Auto Clicker', Enabled = false, Callback = function(self)
        handler.auto_click = self
    end, Menu = { Information = function(self) UI.Banner({Text = "Auto clicks for you when needed." }) end}})

end

local powerup_tab = UI.New({Title = 'PowerUps'}); do
    powerup_tab.Label({Text = 'Auto PowerUp'})

    powerup_tab.Toggle({Text = 'Auto Buy Power-Up', Callback = function(self)
        handler.buy_powerup = self
    end})

    powerup_tab.Toggle({Text = 'Auto Use Power-Up', Callback = function(self)
        handler.use_powerup = self
    end})

    powerup_tab.Toggle({Text = 'Choose All Power-Ups (Except Milk)', Callback = function(self)
        handler.use_all_powerups = self
    end})

    powerup_tab.ChipSet({
        Text = "Choose Power-Ups",
        Callback = function(selected_powerup)
            handler.selected_powerup = selected_powerup
        end,
        Options = powerups
    })
end

local misc_tab = UI.New({Title = 'Misc'}); do
    misc_tab.Label({Text = 'Misc'})
    misc_tab.Toggle({Text = 'Auto Competition', Callback = function(self)
        handler.autocomp = self 

        if (not handler.autocomp) then
            handler.comp_yield = false
            handler.current_path = nil
        end
    end})

    misc_tab.Toggle({Text = 'Next Alter (Upgrades body)', Callback = function(self)
        handler.next_alter = self
    end})

    misc_tab.Label({Text = 'Quests'})
    misc_tab.Toggle({Text = 'Auto Quest', Callback = function(self)
        handler.autoquest = self
    end})

    misc_tab.Label({Text = 'Aura'})
    misc_tab.Toggle({Text = 'Aura Roll', Callback = function(self)
        handler.auraautoroll = self
    end})

    misc_tab.Toggle({Text = 'Buy Aura Roll', Callback = function(self)
        handler.buyaurarolls = self
    end})

    misc_tab.Label({Text = 'Pose'})
    misc_tab.Toggle({Text = 'Pose Roll', Callback = function(self)
        handler.auraposeroll = self
    end})

    misc_tab.Toggle({Text = 'Buy Pose Roll', Callback = function(self)
        handler.buyposerolls = self
    end})
end

if shared.afy then
    shared.afy:Disconnect()
end

shared.afy = runservice.Heartbeat:Connect(function()
    handler:update_farm(handler:grab_farm())
    handler:update()
end)
