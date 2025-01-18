-- https://www.roblox.com/games/17450551531 | Co-op coded with @Leadmarker

local service = setmetatable({}, {
    __index = function(self, key)
        self[key] = cloneref(game.FindService(game, key) or game.GetService(game, key))

        return self[key]
    end
})

local players = service.Players
local runservice = service.RunService
local pathfindservice =  service.PathfindingService
local replicatedstorage = service.ReplicatedStorage

local Material = loadstring(game:HttpGet("https://gist.githubusercontent.com/afyzone/8874e6a5f489d7e548db2ed8f5b87004/raw/"))()
local UI = Material.Load({Title = "@cats - Gym League",Style = 1,SizeX = 500,SizeY = 400, ColorOverrides = { MainFrame = Color3.fromRGB(15,15,15), Minimise = Color3.fromRGB(68, 208, 255), MinimiseAccent = Color3.fromRGB(3, 188, 182), Maximise = Color3.fromRGB(25,255,0), MaximiseAccent = Color3.fromRGB(0,255,110), NavBar = Color3.fromRGB(15,15,15), NavBarAccent = Color3.fromRGB(255,255,255), NavBarInvert = Color3.fromRGB(15,15,15), TitleBar = Color3.fromRGB(30, 30, 30), TitleBarAccent = Color3.fromRGB(255,255,255), Overlay = Color3.fromRGB(30, 30, 30), Banner = Color3.fromRGB(30, 30, 30), BannerAccent = Color3.fromRGB(255,255,255), Content = Color3.fromRGB(85,85,85), Button = Color3.fromRGB(40, 40, 40), ButtonAccent = Color3.fromRGB(235, 235, 235), ChipSet = Color3.fromRGB(170, 170, 170), ChipSetAccent = Color3.fromRGB(100,100,100), DataTable = Color3.fromRGB(160,160,160), DataTableAccent = Color3.fromRGB(45,45,45), Slider = Color3.fromRGB(45,45,45), SliderAccent = Color3.fromRGB(235,235,235), Toggle = Color3.fromRGB(230, 230, 230), ToggleAccent = Color3.fromRGB(235, 235, 235), Dropdown = Color3.fromRGB(45, 45, 45), DropdownAccent = Color3.fromRGB(235,235,235), ColorPicker = Color3.fromRGB(10, 10, 10), ColorPickerAccent = Color3.fromRGB(235,235,235), TextField = Color3.fromRGB(55,55,55), TextFieldAccent = Color3.fromRGB(235,235,235), }})

local client = players.LocalPlayer
local playergui = client:WaitForChild('PlayerGui')
local label_timer = workspace.Podium.entrance.billboard.billboard.labelTimer

client.DevCameraOcclusionMode = "Invisicam"
for i,v in getconnections(client.Idled) do
    v:Disable()
end

local powerups, equipment_rewards, fast_mode = {}, {
    ['Stamina'] = 'treadmill',
    ['Chest'] = 'benchpress',
    ['Triceps'] = workspace.Equipments:FindFirstChild('triceppushdown') and 'triceppushdown' or 'tricepscurl',
    ['Shoulder'] = 'pushpress',
    ['Abs'] = 'crunch',
    ['Forearm'] = 'wristcurl',
    ['Legs'] = 'legpress',
    ['Back'] = 'deadlift',
    ['Biceps'] = 'hammercurl',
    ['Calves'] = 'frontsquat',
}, {
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

    get_backpack = function(player: Player)
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
        self.fast_mode = false

        self.manual = false
        
        self.autocomp = false
        self.comp_yield = false

        self.next_alter = false
        
        self.auraautoroll = false
        self.buyaurarolls = false

        self.buy_powerup = false
        self.use_powerup = false
        self.selected_powerup = {}
        
        self.ui_funcs = {}; do
            for i,v in (equipment_rewards) do
                self.ui_funcs[i] = function(self)
                    self.SetText(v)
                end
            end
        end

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
            local mag = (v:GetPivot().Position - root.Position).magnitude

            if (mag < dist) then
                dist = mag
                closest = v
                prompt = v:FindFirstChildWhichIsA('Part'):FindFirstChildWhichIsA('ProximityPrompt')
            end
        end

        return closest, prompt
    end
    
    function script_handler:grab_stamina()
        local stamina = client:GetAttribute('stamina')
        local max_stamina = client:GetAttribute('maxStamina')
        return (stamina / max_stamina) * 100
    end

    function script_handler:move(pos: Vector3)
        local char = get_char(client)
        local humanoid = get_hum(char)
        local root = get_root(char)

        if not (humanoid and root) then return end
        humanoid:MoveTo(pos)
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
    
            local path = pathfindservice:CreatePath({AgentRadius = 3,AgentHeight = 5,WaypointSpacing = math.huge})
            local success = pcall(function()
                path:ComputeAsync(root.Position, pos)
                local waypoints = path:GetWaypoints()
    
                for _, waypoint in (waypoints) do
                    local waypointPosition = waypoint.Position
                    self:move(waypointPosition)
    
                    local distance = (waypointPosition - root.Position).Magnitude
                    while (distance > 5) do
                        local char = get_char(client)
                        local hum = get_hum(char)
                        if (not self.current_path or not hum or hum.MoveToPoint == Vector3.zero) then break end
                        self:move(waypointPosition)
                        distance = (waypointPosition - root.Position).Magnitude
                        task.wait()
                    end
                    if (not self.current_path) then return end
                end
            end)
    
            if (not success) then
                self:move(pos)
            end
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
        local remote_service = replicatedstorage.common.packages._Index["sleitnick_knit@1.5.1"].knit.Services[service]
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
                if (not v) then continue end
                self:powerup_handler(i)
            end
        end

        if (self.auraautoroll) then
            self:roll('AuraService', self.buyaurarolls)
        end

        if (self.auraposeroll) then
            self:roll('PoseService', self.buyposerolls)
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
                        self:call('EquipmentService', 'RE', 'click')
                    else
                        self:call('EquipmentService', 'RF', 'ChangeSpeed', false)
                    end
                else
                    if (self.farmmode) then 
                        self:call('EquipmentService', 'RF', 'AutoLoad')
                        self:call('EquipmentService', 'RE', 'click')
                        
                        if (self.fast_mode and os.clock() - self.fast_mode_delay > 0.015) then
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
                    if (root.Position - target:GetPivot().Position).magnitude < 10 then
                        fireproximityprompt(target_prompt, 1, true)
                        self.current_farming_instance = target
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

                local equipment = self:get_equipment(equipment_rewards[i])
                if (not equipment) then continue end

                self.fast_mode = fast_mode[i]

                return equipment_rewards[i]
            end
        end)()

        if (all_stats_maxed and self.next_alter) then
            self:call('CharacterService', 'RF', 'NextAlter')
        end
    
        if (self.manual and self.manual_farm) then
            return self.manual_farm
        end

        return selected_farm or equipment_rewards['Stamina']
    end

    function script_handler:competition()
        if (not self.autocomp) then return end

        local podium = playergui.Podium
        local rewards = podium.RewardsFrame

        if (podium.Enabled) then
            replicatedstorage.common.minigames.Competition.comm:FireServer()

            for i,v in (getconnections(playergui.Podium.RewardsFrame.CanvasGroup.Continue.MouseButton1Up)) do
                v:Function()
            end
            
            for i,v in (getconnections(playergui.Podium.winners.ok.MouseButton1Up)) do
                v:Function()
            end
        else
            if (label_timer.Text:lower():find('starting')) then 
                self.comp_yield = true

                if (os.clock() - (self.debounces['competition'] or 0) > 3) then
                    self.current_farming_instance = nil
                    self:can_collide(true)
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

            if (backpack_item or character_item) then
                if (self.use_powerup) then
                    if (backpack_item) then
                        backpack_item.Parent = char
                    end

                    if (character_item) then
                        character_item:Activate()
                        character_item.Parent = backpack
                    end
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

    main_tab.TextField({
        Text = "Manual Farms",
        Editable = false,
        Callback = function(Value)
            handler.manual_farm = Value
        end,
        Menu = handler.ui_funcs
    })
end

local powerup_tab = UI.New({Title = 'PowerUps'}); do
    powerup_tab.Label({Text = 'Auto PowerUp'})

    powerup_tab.Toggle({Text = 'Auto Buy Power-Up', Callback = function(self)
        handler.buy_powerup = self
    end})

    powerup_tab.Toggle({Text = 'Auto Use Power-Up', Callback = function(self)
        handler.use_powerup = self
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

runservice.Heartbeat:Connect(function()
    handler:update_farm(handler:grab_farm())
    handler:update()
end)
