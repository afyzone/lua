while (not game:IsLoaded()) do task.wait() end

if (getgenv().afy) then return end
getgenv().afy = true

local coregui = cloneref(game:GetService('CoreGui'))
local players = game:GetService("Players")
local runservice = game:GetService('RunService')
local userinputservice = game:GetService('UserInputService')
local teleportservice = game:GetService("TeleportService")
local httpservice = game:GetService('HttpService')
local virtualinputmanager = Instance.new('VirtualInputManager')

local client = players.LocalPlayer
local playergui = client:WaitForChild('PlayerGui')
local menuvisibility = false
local targetgroup = 34758135

getgenv().flags = getgenv().flags or {
	tooltype = 'Pushup',
	bobbing_speed = 15000,
	tween_speed = 25,
	min_player_amt = 0,
	toolfarm = false,
	job_farm = false,
	stamina_farm = false,
	auto_withdraw = false,
	auto_deposit = false,
	auto_fatigue = false,
	construction_farm = false,
	auto_muscle_boost = false,
	auto_workout_drink = false,
	auto_eat = false,
	antimod = false,
	auto_hidden_cap = false,
	auto_50kg_vest = false,
	auto_50kg_leg = false,
	auto_breathing_mask = false,
	auto_shadow_box = false,
	auto_blindfold = false,
	rejoin_low_player = false,
}

getgenv().hidden_flags = {
	dialogue_opened = 0,
	unequipcheck = 0,
	last_withdraw = 0,
	last_deposit = 0,
	fatigue_wait = false,
	consumer = false,
	should_eat = false,
	yield_tool_farm = false,
	using_tool = false,
	wait_for_tool = false,
	workout_drink_yield = false,
	eat_yield = false,
	currently_moving = false,
	muscle_yield = false,
	kicked = false,
	render_roblox = true,
	teleporting = false,
	good_stamina = false,
	good_health = false,
	equipping_item = false,
	shadow_farming_spot = nil,
	last_menu_init = 0,
	last_punch = 0,
	stamina_farm_cache = {},
	equip_checks = {
		['50kgvest_equipped'] = 0,
		['50kgleg_equipped'] = 0,
		['breathingmask_equipped'] = 0,
		['blindfold_equipped'] = 0,
		['hiddencap_equipped'] = 0,
	}
}

local blacklisted_uids = {
	[4203884193] = 'Dome',
}

local highrank = {
	['Owner'] = true,
	['Studio Developer'] = true,
	['Developer'] = true,
	['Birb'] = true,
	['Admin'] = true,
	['Assets Uploader'] = true,
	['Moderator'] = true
}

task.spawn(function()
	local start_wait = os.clock()
	while (os.clock() - start_wait <= 45) do task.wait() end
	if (playergui:FindFirstChild('LoadingScreen')) then
		hidden_flags.kicked = true
		client:Kick('took too long to load')
	end
end)

client.DevCameraOcclusionMode = "Invisicam"
client.CameraMaxZoomDistance = math.huge
for i, v in (getconnections(client.Idled)) do
	v:Disable()
end

local moveto, get_char, get_hum, get_root, get_backpack, get_closest_job, get_closest_job_board, get_best_job, get_balance, get_bank_balance, deposit, withdraw, check_bed_available, has_item, use_item, get_new_server, shadow_exists, is_ragdolled, send_data, smart_wait; do
	moveto = function(destination, increment, targetY, postY)
		if hidden_flags.currently_moving then return end
		hidden_flags.currently_moving = true
	
		local char = get_char(client)
		local root = get_root(char)

		if not (char and char:FindFirstChild('HumanoidRootPart')) then
			hidden_flags.currently_moving = false
			return
		end

		local increment = increment or flags.tween_speed
	
		local currentPos = root.Position
		local destinationPos = (typeof(destination) == "CFrame" and destination.Position or destination) + vector.create(0, postY or 0, 0)
		destinationPos = vector.create(destinationPos.X, targetY or (workspace.FallenPartsDestroyHeight + 50), destinationPos.Z)

		local targetY = targetY or (workspace.FallenPartsDestroyHeight + 50) -- 480

		local function moveToTarget(targetPos)
			currentPos = root.Position
			local distanceXZ = vector.create(targetPos.X - currentPos.X, 0, targetPos.Z - currentPos.Z).magnitude
			local directionXZ = vector.create(targetPos.X - currentPos.X, 0, targetPos.Z - currentPos.Z).Unit
			
			local distanceY = math.abs(targetPos.Y - currentPos.Y)
			local directionY = (targetPos.Y > currentPos.Y) and 1 or -1
		
			while distanceXZ > (increment / 10) or distanceY > (flags.bobbing_speed / 10) do
				-- if (root.Anchored) then break end
				while (root.Anchored) do
					smart_wait()
					task.wait()
				end

				if distanceXZ > (increment / 10) then
					currentPos = currentPos + directionXZ * (increment / 10)
				end
				
				if distanceY > (flags.bobbing_speed / 10) then
					currentPos = currentPos + vector.create(0, directionY * (flags.bobbing_speed / 10), 0)
				else
					currentPos = vector.create(currentPos.X, targetPos.Y, currentPos.Z) -- Directly set Y if within range
				end
				
				root.CFrame = CFrame.new(currentPos)
				smart_wait(1/60)
				
				distanceXZ = vector.create(targetPos.X - currentPos.X, 0, targetPos.Z - currentPos.Z).Magnitude
				distanceY = math.abs(targetPos.Y - currentPos.Y)
			end
		end
		
		
		if (math.abs(destinationPos.X - root.Position.X) > 1 or
			math.abs(destinationPos.Z - root.Position.Z) > 1) and
			not (root.Position.Y >= ((workspace.FallenPartsDestroyHeight + 50) - 1) and root.Position.Y <= ((workspace.FallenPartsDestroyHeight + 50) + 1)) then
	
			moveToTarget(vector.create(root.Position.X, (workspace.FallenPartsDestroyHeight + 50), root.Position.Z))
			-- root.CFrame = CFrame.new(root.Position.X, (workspace.FallenPartsDestroyHeight + 50), root.Position.Z)
		end

		local finalTarget = (math.abs(destinationPos.X - root.Position.X) > 1 or
							 math.abs(destinationPos.Z - root.Position.Z) > 1)
							 and vector.create(destinationPos.X, targetY, destinationPos.Z) or destinationPos
			 
		moveToTarget(finalTarget)
		hidden_flags.currently_moving = false
	end

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
		return player and player:FindFirstChildWhichIsA('Backpack')
	end

	get_closest_job = function()
		local dist, closest = math.huge

		local char = get_char(client)
		local root = char and get_root(char)
		
		if (root) then
			for i,v in (workspace.Ignore.Interactables.JobsRelated:GetDescendants()) do
				if (v:IsA('BillboardGui') and v.Adornee and v.Enabled) then
					local mag = (v.Adornee.Position - root.Position).magnitude

					if (mag < dist) then
						dist = mag
						closest = v.Adornee
					end
				end
			end
			
			for i,v in (workspace.Ignore.VFX:GetChildren()) do
				local trashbag = v:FindFirstChildWhichIsA('BillboardGui')

				if (trashbag and trashbag.Adornee and trashbag.Enabled) then
					local mag = (trashbag.Adornee.Position - root.Position).magnitude

					if (mag < dist) then
						dist = mag
						closest = trashbag.Adornee
					end
				end
			end
		end

		return closest
	end

	get_closest_job_board = function()
		local dist, closest = math.huge

		local char = get_char(client)
		local root = char and get_root(char)
		
		if (root) then
			for i,v in (workspace.Ignore.Interactables.JobsRelated["Job Borders"]:GetChildren()) do
				if (not get_best_job(v)) then continue end
				if (v:GetPivot().Position.Y > 500) then continue end

				local mag = (v:GetPivot().Position - root.Position).magnitude

				if (mag < dist) then
					dist = mag
					closest = v
				end
			end
		end

		return closest
	end

	get_best_job = function(board)
		local highest, best = 0

		local char = get_char(client)
		local root = char and get_root(char)
		
		if (root) then
			for i,v in (board.Posters:GetChildren()) do
				if (v.SurfaceGui.Info.Text:lower():find('graffiti') or 
					v.SurfaceGui.Info.Text:lower():find('posters') or 
					v.SurfaceGui.Info.Text:lower():find('trashbags') or 
					v.SurfaceGui.Info.Text:lower():find('dirt')) then continue end

				local price = v.SurfaceGui:FindFirstChild('Reward') and 
								v.SurfaceGui.Reward.Text and 
								tonumber(v.SurfaceGui.Reward.Text:gsub("[^%d,]", ""):gsub(",", ""):gmatch("%d+")())

				if (price and price > highest) then
					highest = price
					best = v
				end
			end
		end

		return best
	end

	get_balance = function()
		local str_bal = playergui.HUD.Bars.MainHUD.Cash.Text:gsub("[^%d,]", ""):gsub(",", ""):gmatch("%d+")()
		return str_bal and tonumber(str_bal)
	end

	get_bank_balance = function()
		local str_bal = playergui.HUD.Tabs.ATM.Balance.ContentText:gsub("[^%d,]", ""):gsub(",", ""):gmatch("%d+")()
		return str_bal and tonumber(str_bal)
	end

	deposit = function(amt)
		if (os.clock() - hidden_flags.last_deposit <= 1) then return end
		hidden_flags.last_deposit = os.clock()
		playergui.HUD.Tabs.ATM.AmountBox.Text = tostring(amt)

		for i,v in getconnections(playergui.HUD.Tabs.ATM.Deposit.MouseButton1Click) do
			v:Fire()
			task.wait(0.1)
		end
	end

	withdraw = function(amt)
		if (os.clock() - hidden_flags.last_withdraw <= 1) then return end
		hidden_flags.last_withdraw = os.clock()
		playergui.HUD.Tabs.ATM.AmountBox.Text = tostring(amt)

		for i,v in getconnections(playergui.HUD.Tabs.ATM.Withdraw.MouseButton1Click) do
			v:Fire()
			task.wait(0.1)
		end
	end

	check_bed_available = function()
		for i,v in (workspace.Ignore.Interactables.Beds:GetChildren()) do
			if (v.Name == 'mesa massagem' and not v:GetAttribute('Used')) then
				return true
			end
		end
	end

	has_item = function(item_name)
		local backpack = get_backpack(client)
		local char = get_char(client)
		local hum = get_hum(char)

		if (char and hum and item_name and backpack) then
			if (backpack:FindFirstChild(item_name)) then
				return true
			end

			for i,v in (char:GetChildren()) do
				if (not v:IsA('Tool')) then continue end

				if (v.Name == item_name) then
					return true
				end
			end
		end
	end

	use_item = function(item_name, quick_delay, equip_only)
		local backpack = get_backpack(client)
		local char = get_char(client)
		local hum = get_hum(char)

		if (hidden_flags.yield_tool_farm) then return end
		if (hidden_flags.wait_for_tool) then return end
		if (hidden_flags.using_tool) then return end

		if (hum and not quick_delay) then
			hum:UnequipTools()
		end

		if (char and hum and item_name and backpack and (quick_delay or not char:FindFirstChildWhichIsA('Model'))) then
			if (backpack:FindFirstChild(item_name)) then
				hidden_flags.using_tool = true
				hum:EquipTool(backpack:FindFirstChild(item_name))
				task.wait()
				hidden_flags.using_tool = false
			end

			if (not equip_only and char:FindFirstChild(item_name)) then
				hidden_flags.using_tool = true
				char:FindFirstChild(item_name):Activate()
				task.wait(quick_delay and 0 or 1)
				hidden_flags.using_tool = false
			end
		end
	end

	get_new_server = function()
		local request = httprequest or request
		if (request) then
			local servers = {}
			local req = request({Url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true", game.PlaceId)})
			local body = httpservice:JSONDecode(req.Body)
	
			if (body and body.data) then
				for i, v in (body.data) do
					if (type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.playing > flags.min_player_amt and v.id ~= game.JobId) then
						table.insert(servers, 1, v.id)
					end
				end
			end
	
			if #servers > 0 then
				return servers[math.random(1, #servers)]
			end
		end
	end

	shadow_exists = function()
		for i,v in (workspace.LivingBeings:GetChildren()) do
			if (v:GetAttribute('ShadowFor') ~= client.Name) then continue end

			return v
		end
	end

	is_ragdolled = function()
		local char = get_char(client)

		if (char) then
			local ragdoll = char:FindFirstChild('Instances | Ragdoll Module')

			return ragdoll
		end
	end

	send_data = function(data)
		local function collect_stats()
			local stats_checker = playergui:FindFirstChild("HUD")
				and playergui.HUD:FindFirstChild("Tabs")
				and playergui.HUD.Tabs:FindFirstChild("StatsChecker")
		
			if (not stats_checker) then return "StatsChecker not found." end
		
			local stats_data = {}
		
			for _, label in (stats_checker:GetDescendants()) do
				if label:IsA("TextLabel") then
					table.insert(stats_data, `{label.Name}: {label.RichText and label.ContentText or label.Text}`)
				end
			end
		
			return table.concat(stats_data, "\n")
		end

		local stats_data = collect_stats()

		local data = {
			["username"] = "Ryujin | etocats",
			["content"] = "Alert!",
			["embeds"] = {
				{
					["title"] = "**etocats**",
					["description"] = `{stats_data}\nKick reason: {data}\nRejoining...`,
					["type"] = "rich",
					["color"] = tonumber(0x7269da),
				}
			}
		}

		local newdata = httpservice:JSONEncode(data)
		
		local headers = {["content-type"] = "application/json"}
		local webhook = {Url = flags.webhook, Body = newdata, Method = "POST", Headers = headers}
		request = http_request or request or HttpPost or syn.request
		request(webhook)
	end

	smart_wait = function(wait_time, flag_string)
		local char = get_char(client)
		local root = get_root(char)
		local start_time = os.clock()
		
		if (char and root) then
			local init_cframe = root.CFrame

			while (char and root and (not flag_string or flags[flag_string]) and os.clock() - start_time <= (wait_time or 0)) do
				root.CFrame = init_cframe
				task.wait()
			end
		end
	end
end

while (not get_root(get_char(client))) do task.wait() end

local Menu = loadstring(game:HttpGet("https://gist.githubusercontent.com/afyzone/78dc2d17017eb642fb42190d72741f7e/raw/ee08eeecf80ccec1b50f1157001dd5d80f5babe6/myasurauilib.lua", true))(); do 
	local update_menu_name = function()
		while (task.wait()) do 
			local name, placeholder = 'made by @leadmarker and @afyzone | discord.gg/VudGqHwCHb', ''
			for i = 1, #name do
				local character = string.sub(name, i, i)
				placeholder = placeholder .. character 
				Menu:SetTitle(placeholder)
				task.wait(0.05)
			end
			task.wait(1)
		end
	end
	
	task.spawn(update_menu_name)
	
	Menu.Accent = Color3.fromRGB(255, 94, 159)
	Menu.Watermark()
	Menu.Watermark:Update('discord.gg/VudGqHwCHb') 

	-- Tabs 
	local Main = Menu.Tab("Main")

	-- Containers
	local Credits = Menu.Container('Main', 'Credits', 'Left'); do
		Menu.Button('Main', 'Credits', 'Join Discord', function()
			setclipboard('https://discord.gg/VudGqHwCHb')
		end)

		Menu.Button('Main', 'Credits', '@leadmarker', function()
			setclipboard('@leadmarker')
		end)

		Menu.Button('Main', 'Credits', '@afyzone', function()
			setclipboard('@afyzone')
		end)
	end

	local Settings = Menu.Container('Main', 'Settings', 'Right'); do 
		Menu.Slider('Main', 'Settings', 'Bobbing Speed', 0, 15000, flags.bobbing_speed, '', 1, function(self)
			flags.bobbing_speed = self
		end)

		Menu.Slider('Main', 'Settings', 'Tween Speed', 0, 50, flags.tween_speed, '', 1, function(self)
			flags.tween_speed = self
		end)

		Menu.Button('Main', 'Settings', 'Render Roblox', function()
			runservice:Set3dRenderingEnabled(not hidden_flags.render_roblox)
			hidden_flags.render_roblox = not hidden_flags.render_roblox
		end)

		Menu.Button('Main', 'Settings', 'Show Stats', function()
			playergui.HUD.Tabs.StatsChecker.Visible = not playergui.HUD.Tabs.StatsChecker.Visible
			playergui.HUD.Tabs.StatsChecker.Position = UDim2.fromScale(0.5, 0.5)
		end)

		Menu.Button('Main', 'Settings', 'Show Bank', function()
			playergui.HUD.Tabs.ATM.Visible = not playergui.HUD.Tabs.ATM.Visible
			playergui.HUD.Tabs.ATM.Position = UDim2.fromScale(0.243839845, 0.27913636)
		end)

		Menu.Button('Main', 'Settings', 'Rejoin', function()
			hidden_flags.kicked = true
			client:Kick('rejoin was requested by user')
		end)
	end

	local Farming = Menu.Container('Main', 'Money Farm', 'Right'); do
		Menu.CheckBox('Main', 'Money Farm', 'Auto Deposit', flags.auto_deposit, function(self)
			flags.auto_deposit = self

			task.spawn(function()
				while (flags.auto_deposit and task.wait()) do
					local balance = get_balance()
					
					if (balance >= 950_000) then
						deposit(balance - 50000)
					end
				end
			end)
		end)

		Menu.CheckBox('Main', 'Money Farm', 'Construction Farm', flags.construction_farm, function(self)
			flags.construction_farm = self

			task.spawn(function()
				while (flags.construction_farm and task.wait()) do
					local char = get_char(client)
					local root = get_root(char)
					
					if (hidden_flags.consumer) then continue end
					if (hidden_flags.fatigue_wait) then continue end
	
					if (char and root) then
						local deliver, job_complete = (function()
							for i,v in (workspace.Ignore.Interactables.JobsRelated.Boxes:GetChildren()) do
								if (v.Name == 'DeliveryArea') then
									if (v:FindFirstChildWhichIsA('BillboardGui')) then
										return v:FindFirstChildWhichIsA('BillboardGui').Adornee
									end
								end
							end
						end)()
						
						if (playergui.HUD.Main.Jobs.ObjectivesList:FindFirstChild("1")) then
							local current_job = playergui.HUD.Main.Jobs.Title.Text
							local status = playergui.HUD.Main.Jobs.ObjectivesList["1"].Text:match(": (.+)")
	
							if (current_job and status) then
								local job_status = status and #status:gsub('/', '') > 1 and status:gsub('/', '')
								
								if (job_status) then
									local current_status, finished_status = status:match("([^/]+)/([^/]+)")
	
									job_complete = current_status == finished_status:match("%d+")
								end
							end
						end
	
						if (deliver and job_complete == false) then
							if (char:FindFirstChild('CarriedBox')) then
								local mag = (vector.create(deliver.Position.X, 0, deliver.Position.Z) - vector.create(root.Position.X, 0, root.Position.Z)).magnitude
								if (mag > 300) then
									moveto(deliver.Position, flags.tween_speed)
								elseif (mag > 10) then
									moveto(deliver.Position, flags.tween_speed)
									root.CFrame = CFrame.new(deliver.Position.X - 1, 487, deliver.Position.Z + 2)
								else
									root.CFrame = CFrame.new(deliver.Position.X - 1, 487, deliver.Position.Z + 2)
								end
							else
								local prompter = workspace.Ignore.Interactables.JobsRelated.Boxes.RecieveArea
								
								local mag = (vector.create(prompter.Position.X, 0, prompter.Position.Z) - vector.create(root.Position.X, 0, root.Position.Z)).magnitude
								if (mag > 300) then
									moveto(prompter.Position, flags.tween_speed)
								elseif (mag > 10) then
									moveto(prompter.Position, flags.tween_speed)
									root.CFrame = CFrame.new(prompter.Position.X, 483, prompter.Position.Z)
								else
									root.CFrame = CFrame.new(prompter.Position.X, 483, prompter.Position.Z)
								end
	
								if (playergui.HUD.Main.Jobs.ObjectivesList:FindFirstChild("1") and playergui.HUD.Main.Jobs.ObjectivesList["1"].TextColor3 == Color3.fromRGB(85, 255, 127)) then continue end
		
								if ((not playergui.HUD.Main.Dialogue.Visible or playergui.HUD.Main.Dialogue.Position.Y.Scale > 1) and prompter:FindFirstChildWhichIsA('ProximityPrompt')) then
									root.CFrame = CFrame.new(prompter.Position.X, 484, prompter.Position.Z)
									smart_wait(0.2, 'construction_farm')
									root.CFrame = CFrame.new(prompter.Position.X, 484, prompter.Position.Z)
									prompter:FindFirstChildWhichIsA('ProximityPrompt').Enabled = true
									fireproximityprompt(prompter:FindFirstChildWhichIsA('ProximityPrompt'))
								end
							end
						else
							local prompter = workspace.Ignore.NPCs.Jobs["Construction Worker"].HumanoidRootPart
							local mag = (vector.create(prompter.Position.X, 0, prompter.Position.Z) - vector.create(root.Position.X, 0, root.Position.Z)).magnitude

							if (mag > 300) then
								moveto(prompter.Position, flags.tween_speed)
							elseif (mag > 10) then
								moveto(prompter.Position, flags.tween_speed)
								root.CFrame = CFrame.new(prompter.Position.X, 484, prompter.Position.Z)
							else
								root.CFrame = CFrame.new(prompter.Position.X, 484, prompter.Position.Z)
							end
	
							if ((not playergui.HUD.Main.Dialogue.Visible or playergui.HUD.Main.Dialogue.Position.Y.Scale > 1) and prompter:FindFirstChildWhichIsA('ProximityPrompt')) then
								if (os.clock() - hidden_flags.last_menu_init > 2) then
									hidden_flags.last_menu_init = os.clock()
								end

								root.CFrame = CFrame.new(prompter.Position.X, 484, prompter.Position.Z)
								smart_wait(0.2, 'construction_farm')
								root.CFrame = CFrame.new(prompter.Position.X, 484, prompter.Position.Z)
								prompter:FindFirstChildWhichIsA('ProximityPrompt').Enabled = true
								fireproximityprompt(prompter:FindFirstChildWhichIsA('ProximityPrompt'))
								hidden_flags.dialogue_opened = os.clock()
							end
	
							if (playergui.HUD.Main.Dialogue.Options:FindFirstChild('1')) then
								if (playergui.HUD.Main.Dialogue.Options['1'].OptionText.Text:find('help')) then
									if (hidden_flags.yield_tool_farm and os.clock() - hidden_flags.last_menu_init > 1 and not hidden_flags.using_tool) then
										virtualinputmanager:SendKeyEvent(true, 'One', false, nil)
									end
								else
									smart_wait(1, 'construction_farm')
									virtualinputmanager:SendKeyEvent(true, 'One', false, nil)
								end
							end
								
							if (hidden_flags.yield_tool_farm and os.clock() - hidden_flags.dialogue_opened > 10) then
								moveto(prompter.Position, flags.tween_speed, 470)
							end
						end
					end
				end
			end)
		end)

		Menu.CheckBox('Main', 'Money Farm', 'Job Farm', flags.job_farm, function(self)
			flags.job_farm = self

			task.spawn(function()
				while (flags.job_farm and task.wait()) do 
					local char = get_char(client)
					local root = char and get_root(char)
				
					if (hidden_flags.consumer) then continue end
					if (hidden_flags.fatigue_wait) then continue end
					if not (char and root) then continue end
	
					local job_part = get_closest_job()
	
					if (job_part) then
						local high_point = job_part.Name == 'cat'
						
						if ((vector.create(job_part.Position.X, 0, job_part.Position.Z) - vector.create(root.Position.X, 0, root.Position.Z)).magnitude > 25) then
							moveto(job_part.Position, flags.tween_speed)
						else
							root.CFrame = CFrame.new(job_part.Position.X, high_point and job_part.Position.Y - 8 or 480, job_part.Position.Z)
						end

						smart_wait(0.3, 'job_farm')

						if (job_part and (job_part:GetPivot().Position - root.Position).magnitude < 25) then
							if (job_part:FindFirstChildWhichIsA('ClickDetector')) then
								if ((vector.create(job_part.Position.X, 0, job_part.Position.Z) - vector.create(root.Position.X, 0, root.Position.Z)).magnitude > 25) then
									moveto(job_part.Position + vector.create(0, -5, 0), flags.tween_speed)
								else
									root.CFrame = CFrame.new(job_part.Position.X, high_point and job_part.Position.Y - 5 or 483, job_part.Position.Z)
									smart_wait(0.3, 'job_farm')
								end
								
								if (job_part:FindFirstChildWhichIsA('ClickDetector')) then
									fireclickdetector(job_part:FindFirstChildWhichIsA('ClickDetector'))
								end
							else
								root.CFrame = CFrame.new(job_part.Position.X, high_point and job_part.Position.Y - 8 or 484, job_part.Position.Z)
								firetouchinterest(root, job_part, 0)
								task.wait()
								firetouchinterest(root, job_part, 1)
							end
						end
					else
						local job_board = get_closest_job_board()
	
						if (job_board) then
							if ((vector.create(job_board:GetPivot().Position.X, 0, job_board:GetPivot().Position.Z) - vector.create(root.Position.X, 0, root.Position.Z)).magnitude > 25) then
								moveto(job_board:GetPivot().Position, flags.tween_speed)
							else
								root.CFrame = CFrame.new(job_board:GetPivot().Position.X, 480, job_board:GetPivot().Position.Z)
							end
	
							smart_wait(.2, 'job_farm')
	
							if ((vector.create(job_board:GetPivot().Position.X, 0, job_board:GetPivot().Position.Z) - vector.create(root.Position.X, 0, root.Position.Z)).magnitude > 25) then
								moveto(job_board:GetPivot().Position, flags.tween_speed)
							else
								root.CFrame = CFrame.new(job_board:GetPivot().Position.X, 483, job_board:GetPivot().Position.Z)
							end
	
							local best_job = get_best_job(job_board)
							
							if (best_job and (best_job:GetPivot().Position - root.Position).magnitude < 20) then
								if (best_job:FindFirstChildWhichIsA('ClickDetector')) then
									root.CFrame = CFrame.new(job_board:GetPivot().Position.X, 483, job_board:GetPivot().Position.Z)
									smart_wait(1, 'job_farm')
	
									if (best_job and best_job:FindFirstChildWhichIsA('ClickDetector')) then
										root.CFrame = CFrame.new(job_board:GetPivot().Position.X, 483, job_board:GetPivot().Position.Z)
										fireclickdetector(best_job:FindFirstChildWhichIsA('ClickDetector'))
										smart_wait(0.5, 'job_farm')
									end
								end
							end
						end
					end
				end
			end)
		end)
	end

	local StatsFarm = Menu.Container('Main', 'Stat Farms', 'Left'); do
		Menu.CheckBox('Main', 'Stat Farms', 'Auto Muscle Boost', flags.auto_muscle_boost, function(self)
			flags.auto_muscle_boost = self

			task.spawn(function()
				while (flags.auto_muscle_boost and task.wait()) do
					local char = get_char(client)
					local root = get_root(char)
	
					if (hidden_flags.fatigue_wait) then continue end
	
					if (char and root) then
						local muscleboost = playergui.HUD.Miscs.PlayerStates.States:FindFirstChild('MuscleBoost')
	
						if (muscleboost and not muscleboost.Visible and (not hidden_flags.workout_drink_yield and not hidden_flags.eat_yield)) then
							hidden_flags.muscle_yield = true
							hidden_flags.consumer = true
		
							local consumable = workspace.Ignore.Interactables.Buyables["Muscle Gain 7000"]
							moveto(consumable.Position, flags.tween_speed)
		
							for i = 1, 20 do
								if ((vector.create(consumable.Position.X, 0, consumable.Position.Z) - vector.create(root.Position.X, 0, root.Position.Z)).magnitude > 25) then
									moveto(consumable.Position, flags.tween_speed)
								else
									root.CFrame = CFrame.new(consumable.Position.X, 483, consumable.Position.Z)
								end
	
								smart_wait(0.2, 'auto_muscle_boost')
								fireclickdetector(consumable:FindFirstChildWhichIsA('ClickDetector'))
								smart_wait(0.2, 'auto_muscle_boost')
								use_item(consumable.Name)
							end
	
							if (muscleboost and muscleboost.Visible) then
								hidden_flags.muscle_yield = false
								hidden_flags.consumer = false
							end
						end
					end
				end
			end)
		end)

		Menu.CheckBox('Main', 'Stat Farms', 'Auto Workout Drink', flags.auto_workout_drink, function(self)
			flags.auto_workout_drink = self

			task.spawn(function()
				while (flags.auto_workout_drink and task.wait()) do
					local char = get_char(client)
					local root = get_root(char)
	
					if (hidden_flags.fatigue_wait) then continue end
	
					if (char and root) then
						local xpboost = playergui.HUD.Miscs.PlayerStates.States:FindFirstChild('XPBoost')
	
						if (xpboost and not xpboost.Visible and (not hidden_flags.muscle_yield and not hidden_flags.eat_yield)) then
							hidden_flags.workout_drink_yield = true
							hidden_flags.consumer = true
		
							local consumable = workspace.Ignore.Interactables.Buyables["Workout Drink"]
							moveto(consumable.Position, flags.tween_speed)
		
							for i = 1, 20 do
								if ((vector.create(consumable.Position.X, 0, consumable.Position.Z) - vector.create(root.Position.X, 0, root.Position.Z)).magnitude > 25) then
									moveto(consumable.Position, flags.tween_speed)
								else
									root.CFrame = CFrame.new(consumable.Position.X, 483, consumable.Position.Z)
								end
	
								smart_wait(0.2, 'auto_workout_drink')
								fireclickdetector(consumable:FindFirstChildWhichIsA('ClickDetector'))
								smart_wait(0.2, 'auto_workout_drink')
								use_item(consumable.Name)
							end
	
							if (xpboost and xpboost.Visible) then
								hidden_flags.workout_drink_yield = false
								hidden_flags.consumer = false
							end
						end
					end
				end
			end)
		end)

		Menu.CheckBox('Main', 'Stat Farms', 'Auto Eat', flags.auto_eat, function(self)
			flags.auto_eat = self

			task.spawn(function()
				while (flags.auto_eat and task.wait()) do
					local char = get_char(client)
					local root = get_root(char)
	
					if (hidden_flags.fatigue_wait) then continue end
	
					if (char and root) then
						if (hidden_flags.should_eat and (not hidden_flags.muscle_yield and not hidden_flags.workout_drink_yield)) then
							hidden_flags.eat_yield = true
							hidden_flags.consumer = true
		
							local consumable = workspace.Ignore.Interactables.Buyables["Ramen"]
	
							if (has_item(consumable.Name)) then
								root.CFrame = CFrame.new(root.Position.X, 480, root.Position.Z)
								use_item(consumable.Name)
							else
								moveto(consumable.Position, flags.tween_speed)
								for i = 1, 20 do
									if ((vector.create(consumable.Position.X, 0, consumable.Position.Z) - vector.create(root.Position.X, 0, root.Position.Z)).magnitude > 25) then
										moveto(consumable.Position, flags.tween_speed)
									else
										root.CFrame = CFrame.new(consumable.Position.X, 483, consumable.Position.Z)
									end

									smart_wait(0.2, 'auto_eat')
									fireclickdetector(consumable:FindFirstChildWhichIsA('ClickDetector'))
								end
							end
	
							if (not hidden_flags.should_eat) then
								hidden_flags.eat_yield = false
								hidden_flags.consumer = false
							end
						end
					end
				end
			end)
		end)

		Menu.CheckBox('Main', 'Stat Farms', 'Auto Fatigue', flags.auto_fatigue, function(self)
			flags.auto_fatigue = self

			task.spawn(function()
				while (flags.auto_fatigue and task.wait()) do
					local char = get_char(client)
					local root = get_root(char)
					
					if (hidden_flags.consumer) then continue end
					
					if (char and root and hidden_flags.fatigue_wait) then
						local prompter = workspace.Ignore.NPCs["Important NPCs"].Shozuki.HumanoidRootPart
						
						if ((vector.create(prompter.Position.X, 0, prompter.Position.Z) - vector.create(root.Position.X, 0, root.Position.Z)).magnitude > 25) then
							moveto(prompter.Position, flags.tween_speed)
						else
							root.CFrame = CFrame.new(prompter.Position.X, 483, prompter.Position.Z)
						end
	
						if (hidden_flags.fatigue_wait >= 90) then
							if ((not playergui.HUD.Main.Dialogue.Visible or playergui.HUD.Main.Dialogue.Position.Y.Scale > 1) and prompter:FindFirstChildWhichIsA('ProximityPrompt')) then
								if (os.clock() - hidden_flags.last_menu_init > 2) then
									hidden_flags.last_menu_init = os.clock()
								end

								root.CFrame = CFrame.new(prompter.Position.X, 483, prompter.Position.Z)
								smart_wait(0.2, 'auto_fatigue')
								root.CFrame = CFrame.new(prompter.Position.X, 483, prompter.Position.Z)
								prompter:FindFirstChildWhichIsA('ProximityPrompt').Enabled = true
								fireproximityprompt(prompter:FindFirstChildWhichIsA('ProximityPrompt'))
								hidden_flags.dialogue_opened = os.clock()
							end
	
							if (playergui.HUD.Main.Dialogue.Options:FindFirstChild('1')) then
								if (hidden_flags.yield_tool_farm and os.clock() - hidden_flags.last_menu_init > 1 and not hidden_flags.using_tool) then
									virtualinputmanager:SendKeyEvent(true, 'One', false, nil)
								end
							elseif (os.clock() - hidden_flags.dialogue_opened > 10) then
								moveto(prompter.Position, flags.tween_speed)
							end
						end
					end
				end
			end)
		end)

		Menu.CheckBox('Main', 'Stat Farms', 'Auto Withdraw', flags.auto_withdraw, function(self)
			flags.auto_withdraw = self

			task.spawn(function()
				while (flags.auto_withdraw and task.wait()) do
					local bank_balance = get_bank_balance()
					local balance = get_balance()
	
					if (balance > 50_000) then continue end
	
					if (bank_balance >= 1_000_000) then
						withdraw(1_000_000)
					
					elseif bank_balance > 0 then
						withdraw(bank_balance)
					end
				end
			end)
		end)

		Menu.CheckBox('Main', 'Stat Farms', 'Auto Shadow Box', flags.auto_shadow_box, function(self)
			flags.auto_shadow_box = self

			hidden_flags.shadow_farming_spot = math.random(5000, 15000)

			task.spawn(function()
				while (flags.auto_shadow_box and task.wait()) do
					local char = get_char(client)
					local root = get_root(char)
					local item = workspace.Ignore.Interactables.Buyables["Shadow Boxing"]

					if (hidden_flags.consumer) then continue end
					if (hidden_flags.fatigue_wait) then continue end

					if (char and root) then
						if (has_item('Shadow Boxing')) then
							if (hidden_flags.good_stamina and hidden_flags.good_health) then
								hidden_flags.shadow_in_progress = true

								if (not root.Anchored) then
									if ((vector.create(item.Position.X, 0, item.Position.Z) - vector.create(root.Position.X, 0, root.Position.Z)).magnitude > 25) then
										moveto(item.Position + vector.create(-10, 0, 0), flags.tween_speed)
									else
										root.CFrame = CFrame.new(item.Position.X, hidden_flags.shadow_farming_spot, item.Position.Z)
									end

									hidden_flags.shadow_farming = true
									smart_wait(1, 'auto_shadow_box')
									use_item('Shadow Boxing')
								end
							else
								hidden_flags.shadow_in_progress = false

								if ((vector.create(item.Position.X, 0, item.Position.Z) - vector.create(root.Position.X, 0, root.Position.Z)).magnitude > 25) then
									moveto(item.Position + vector.create(-10, 0, 0), flags.tween_speed)
								else
									root.CFrame = CFrame.new(item.Position.X, hidden_flags.shadow_farming_spot, item.Position.Z)
								end

								if (root.Anchored) then
									use_item('Shadow Boxing')
								end
							end

							local get_shadow_status = shadow_exists()

							if (get_shadow_status or root.Anchored) then
								hidden_flags.shadow_farming = true
								hidden_flags.shadow_in_progress = true
								use_item('Combat', true, true)

								if (get_shadow_status) then
									if (get_shadow_status:FindFirstChild('HumanoidRootPart')) then
										root.CFrame = get_shadow_status.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4)
									end

									if (os.clock() - hidden_flags.last_punch > 0.2) then
										game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("imezx_warp@1.0.9"):WaitForChild("warp"):WaitForChild("Index"):WaitForChild("Event"):WaitForChild("Reliable"):FireServer(buffer.fromstring("\23"),{{"M1"}})
										hidden_flags.last_punch = os.clock()
									end
								end
							end
						else
							hidden_flags.shadow_farming = false

							moveto(item.Position + vector.create(-10, 0, 0), flags.tween_speed)
							root.CFrame = CFrame.new(item.Position + vector.create(-10, 0, 0))
							smart_wait(0.3, 'auto_shadow_box')
							fireclickdetector(item:FindFirstChildWhichIsA('ClickDetector'))
						end
					end
				end

				hidden_flags.shadow_in_progress = false
			end)
		end)

		Menu.CheckBox('Main', 'Stat Farms', 'Stamina Farm', flags.stamina_farm, function(self)
			flags.stamina_farm = self

			task.spawn(function()
				while (flags.stamina_farm and task.wait()) do
					local char = get_char(client)
					local root = get_root(char)
					local backpack = get_backpack(client)
	
					if (hidden_flags.consumer) then continue end
					if (hidden_flags.fatigue_wait) then continue end
	
					if (char and root and backpack) then
						if (playergui.HUD.Miscs.Roadwork.Visible and playergui.HUD.Miscs.Roadwork.Position.X.Scale >= 0) then
							for i,v in (workspace.Ignore.Interactables.Roadworks:GetDescendants()) do
								if (v:IsA('BillboardGui')) then
									for i = #hidden_flags.stamina_farm_cache, 1, -1 do
										if hidden_flags.stamina_farm_cache[i] == v then continue end

										table.remove(hidden_flags.stamina_farm_cache, i)
									end

									if ((vector.create(v.Parent.Position.X, 0, v.Parent.Position.Z) - vector.create(root.Position.X, 0, root.Position.Z)).magnitude > 25) then
										moveto(v.Parent.Position + vector.create(0, -8.2, 0), flags.tween_speed)
									else
										root.CFrame = CFrame.new(v.Parent.Position.X, 480, v.Parent.Position.Z)
									end
	
									if (v and v.Parent and (not hidden_flags.stamina_farm_cache[v] or os.clock() - hidden_flags.stamina_farm_cache[v] > 1)) then
										root.CFrame = CFrame.new(v.Parent.Position.X, 485.8, v.Parent.Position.Z)
										hidden_flags.stamina_farm_cache[v] = os.clock()
										smart_wait(0.3, 'stamina_farm')
									end
	
									-- task.wait()
	
									if (v and v.Parent) then
										root.CFrame = CFrame.new(v.Parent.Position.X, 480, v.Parent.Position.Z)
									end
								end
							end
						else
							local prompter = workspace.Ignore.NPCs["Important NPCs"].Saitama.HumanoidRootPart

							if ((vector.create(prompter.Position.X, 0, prompter.Position.Z) - vector.create(root.Position.X, 0, root.Position.Z)).magnitude > 25) then
								moveto(prompter.Position, flags.tween_speed)
							else
								root.CFrame = CFrame.new(prompter.Position.X, 482, prompter.Position.Z)
							end
	
							if (not hidden_flags.yield_tool_farm and not hidden_flags.wait_for_tool and prompter:FindFirstChildWhichIsA('ProximityPrompt')) then
								if (os.clock() - hidden_flags.last_menu_init > 2) then
									hidden_flags.last_menu_init = os.clock()
								end

								root.CFrame = CFrame.new(prompter.Position.X, 483, prompter.Position.Z)
								smart_wait(0.2, 'stamina_farm')
								root.CFrame = CFrame.new(prompter.Position.X, 483, prompter.Position.Z)
								smart_wait(0.2, 'stamina_farm')
								root.CFrame = CFrame.new(prompter.Position.X, 483, prompter.Position.Z)
								prompter:FindFirstChildWhichIsA('ProximityPrompt').Enabled = true
								fireproximityprompt(prompter:FindFirstChildWhichIsA('ProximityPrompt'))
								hidden_flags.dialogue_opened = os.clock()
							end
	
							if (playergui.HUD.Main.Dialogue.Options:FindFirstChild('1')) then
								local stun = char:GetAttribute('StunType')

								if (hidden_flags.yield_tool_farm and os.clock() - hidden_flags.last_menu_init > 1 and not hidden_flags.using_tool and not stun) then
									virtualinputmanager:SendKeyEvent(true, 'One', false, nil)
								end
	
							else
								if (hidden_flags.dialogue_opened > 6) then
									moveto(prompter.Position, flags.tween_speed)
								else
									root.CFrame = CFrame.new(prompter.Position.X, 482, prompter.Position.Z)
								end
							end
						end
					end
				end
			end)
		end)

		Menu.ComboBox('Main', 'Stat Farms', 'Tool Farm Type', flags.tooltype, {'Squat', 'Pushup', 'Situp', 'Jumping Rope', 'Jumping Jacks', 'One Hand Pushups', 'Handstand Pushup'}, function(self)
			flags.tooltype = self
		end)

		Menu.CheckBox('Main', 'Stat Farms', 'Tool Farm', flags.toolfarm, function(self)
			flags.toolfarm = self
			
			local char = get_char(client)
			local hum = get_hum(char)

			hidden_flags.tool_farming_spot = math.random(5000, 15000)

			if (char and hum and not hidden_flags.wait_for_tool) then
				hum:UnequipTools()
			end

			task.spawn(function()
				while (flags.toolfarm and task.wait()) do
					local char = get_char(client)
					local root = get_root(char)
					local hum = get_hum(char)
					local backpack = get_backpack(client)
	
					if (hidden_flags.consumer) then continue end
					if (hidden_flags.fatigue_wait) then continue end
					if (hidden_flags.yield_tool_farm) then continue end
					if (hidden_flags.shadow_in_progress) then continue end
					if (hidden_flags.equipping_item) then continue end
					if (is_ragdolled() or not hidden_flags.good_stamina) then continue end
	
					if (char and hum and root and backpack) then
						if ((flags.auto_eat or flags.auto_workout_drink or flags.auto_muscle_boost) and not (flags.job_farm or flags.stamina_farm or flags.auto_fatigue or flags.construction_farm or flags.auto_shadow_box)) then
							moveto(vector.create(root.Position.X, hidden_flags.tool_farming_spot, root.Position.Z), flags.tween_speed)
						end
						
						if (not hidden_flags.wait_for_tool) then
							if (os.clock() - hidden_flags.unequipcheck > 10) then
								hum:UnequipTools()
								hidden_flags.unequipcheck = os.clock()
							end
		
							use_item(flags.tooltype, true)
						end
					end
				end
			end)
		end)

		Menu.CheckBox('Main', 'Stat Farms', 'Auto 50KG Vest', flags.auto_50kg_vest, function(self)
			flags.auto_50kg_vest = self
	
			task.spawn(function()
				while (flags.auto_50kg_vest and task.wait()) do
					local char = get_char(client)

					if (hidden_flags.consumer) then continue end
					if (hidden_flags.equipping_item and hidden_flags.equipping_item ~= '50kg_vest') then continue end
	
					if (char) then
						if (has_item('50KG Vest') and not hidden_flags.wait_for_tool) then
							if (char:FindFirstChild('50kg vest')) then
								if (os.clock() - hidden_flags.equip_checks['50kgvest_equipped'] > 10 or hidden_flags.equipping_item) then
									hidden_flags.equipping_item = false
								end
							else
								local hum = get_hum(char)
		
								if (hum and os.clock() - hidden_flags.unequipcheck > 10) then
									hum:UnequipTools()
									hidden_flags.unequipcheck = os.clock()
								end
								
								hidden_flags.equipping_item = '50kg_vest'
								hidden_flags.equip_checks['50kgvest_equipped'] = os.clock()
								use_item('50KG Vest')
							end
						end
					end
				end
			end)
		end)

		Menu.CheckBox('Main', 'Stat Farms', 'Auto 50KG Leg Weights', flags.auto_50kg_leg, function(self)
			flags.auto_50kg_leg = self
	
			task.spawn(function()
				while (flags.auto_50kg_leg and task.wait()) do
					local char = get_char(client)

					if (hidden_flags.consumer) then continue end
					if (hidden_flags.equipping_item and hidden_flags.equipping_item ~= '50kg_leg') then continue end
	
					if (char) then
						if (has_item('50KG Leg Weights') and not hidden_flags.wait_for_tool) then
							if (char:FindFirstChild('50kg leg weights')) then
								if (os.clock() - hidden_flags.equip_checks['50kgleg_equipped'] > 10 or hidden_flags.equipping_item) then
									hidden_flags.equipping_item = false
								end
							else
								local hum = get_hum(char)
		
								if (hum and os.clock() - hidden_flags.unequipcheck > 10) then
									hum:UnequipTools()
									hidden_flags.unequipcheck = os.clock()
								end
								
								hidden_flags.equipping_item = '50kg_leg'
								hidden_flags.equip_checks['50kgleg_equipped'] = os.clock()
								use_item('50KG Leg Weights')
							end
						end
					end
				end
			end)
		end)

		Menu.CheckBox('Main', 'Stat Farms', 'Auto Breathing Mask', flags.auto_breathing_mask, function(self)
			flags.auto_breathing_mask = self
	
			task.spawn(function()
				while (flags.auto_breathing_mask and task.wait()) do
					local char = get_char(client)

					if (hidden_flags.consumer) then continue end
					if (hidden_flags.equipping_item and hidden_flags.equipping_item ~= 'breathingmask') then continue end

					if (char) then
						if (has_item('Breathing Mask') and not hidden_flags.wait_for_tool) then
							if (char:FindFirstChild('Breathing Mask')) then
								if (os.clock() - hidden_flags.equip_checks['breathingmask_equipped'] > 10 or hidden_flags.equipping_item) then
									hidden_flags.equipping_item = false
								end
							else
								local hum = get_hum(char)
		
								if (hum and os.clock() - hidden_flags.unequipcheck > 10) then
									hum:UnequipTools()
									hidden_flags.unequipcheck = os.clock()
								end
								
								hidden_flags.equipping_item = 'breathingmask'
								hidden_flags.equip_checks['breathingmask_equipped'] = os.clock()
								use_item('Breathing Mask')
							end
						end
					end
				end
			end)
		end)

		Menu.CheckBox('Main', 'Stat Farms', 'Auto Blindfold', flags.auto_blindfold, function(self)
			flags.auto_blindfold = self
	
			task.spawn(function()
				while (flags.auto_blindfold and task.wait()) do
					local char = get_char(client)

					if (hidden_flags.consumer) then continue end
					if (hidden_flags.equipping_item and hidden_flags.equipping_item ~= 'blindfold') then continue end

					if (char) then
						if (has_item('Blindfold') and not hidden_flags.wait_for_tool) then
							if (char:FindFirstChild('Blindfold')) then
								if (os.clock() - hidden_flags.equip_checks['blindfold_equipped'] > 10 or hidden_flags.equipping_item) then
									hidden_flags.equipping_item = false
								end
							else
								local hum = get_hum(char)
		
								if (hum and os.clock() - hidden_flags.unequipcheck > 10) then
									hum:UnequipTools()
									hidden_flags.unequipcheck = os.clock()
								end
								
								hidden_flags.equipping_item = 'blindfold'
								hidden_flags.equip_checks['blindfold_equipped'] = os.clock()
								use_item('Blindfold')
							end
						end
					end
				end
			end)
		end)
	end
end

local AntiMod = Menu.Container('Main', 'Anonimity', 'Right'); do
	Menu.CheckBox('Main', 'Anonimity', 'Auto Hidden Cap', flags.auto_hidden_cap, function(self)
		flags.auto_hidden_cap = self

		task.spawn(function()
			while (flags.auto_hidden_cap and task.wait()) do
				local char = get_char(client)

				if (hidden_flags.consumer) then continue end
				if (hidden_flags.equipping_item and hidden_flags.equipping_item ~= 'hiddencap') then continue end

				if (char) then
					if (has_item('Hidden Cap') and not hidden_flags.wait_for_tool) then
						if (char:FindFirstChild('hiddencap')) then
							if (os.clock() - hidden_flags.equip_checks['hiddencap_equipped'] > 10 or hidden_flags.equipping_item) then
								hidden_flags.equipping_item = false
							end
						else
							local hum = get_hum(char)

							if (hum and os.clock() - hidden_flags.unequipcheck > 10) then
								hum:UnequipTools()
								hidden_flags.unequipcheck = os.clock()
							end
							
							hidden_flags.equipping_item = 'hiddencap'
							hidden_flags.equip_checks['hiddencap_equipped'] = os.clock()
							use_item('Hidden Cap')
						end
					end
				end
			end
		end)
	end)

	Menu.CheckBox('Main', 'Anonimity', 'Anti Mod', flags.antimod, function(self)
		flags.antimod = self

		task.spawn(function()
			for _, v in (players:GetPlayers()) do
				if (v == client) then continue end
				if (v.Parent ~= players) then continue end

				if (not blacklisted_uids[v.UserId]) then 
					if (not v:IsInGroup(targetgroup)) then continue end
					if (not v:GetRoleInGroup(targetgroup)) then continue end
					if (not highrank[v:GetRoleInGroup(targetgroup)]) then continue end 
				end

				local defined_role = blacklisted_uids[v.UserId] or v:GetRoleInGroup(targetgroup)
				if (flags.antimod) then
					hidden_flags.kicked = true
					client:Kick(`A {defined_role} was in your game. Username: {v.Name}`)
					break
				else
					Menu.Notify(`A  {defined_role} is in your game. Username: {v.Name}`)
				end
			end
		end)
	end)
	
	Menu.Slider('Main', 'Anonimity', 'Minimum Player Amount', 0, 32, flags.min_player_amt, '', 1, function(self)
		flags.min_player_amt = self
	end)

	Menu.CheckBox('Main', 'Anonimity', 'Rejoin On Minimum Player Amount', flags.rejoin_low_player, function(self)
		flags.rejoin_low_player = self
	end)

	players.PlayerAdded:Connect(function(player)
		while (player and player.Parent ~= players) do task.wait() end
		if (not player) then return end

		if (not blacklisted_uids[player.UserId]) then
			if (not player:IsInGroup(targetgroup)) then return end
			if (not player:GetRoleInGroup(targetgroup)) then return end
			if (not highrank[player:GetRoleInGroup(targetgroup)]) then return end
		end

		local defined_role = blacklisted_uids[player.UserId] or player:GetRoleInGroup(targetgroup)

		if (flags.antimod) then
			hidden_flags.kicked = true
			client:Kick(`A {defined_role} was in your game. Username: {player.Name}`)
		else
			Menu.Notify(`A {defined_role} is in your game. Username: {player.Name}`)
		end
	end)

	players.PlayerRemoving:Connect(function()
		if (not flags.rejoin_low_player) then return end

		if (#players:GetPlayers() <= flags.min_player_amt) then
			hidden_flags.kicked = true
			client:Kick(`Server low on players, player amount is {#players:GetPlayers()}`)
		end
	end)
end

task.spawn(function()
	while (task.wait()) do
		if (hidden_flags.yield_tool_farm) then
			for i,v in getconnections(playergui.HUD.Main.Dialogue.Skip.MouseButton1Click) do
				v:Fire()
				task.wait(0.1)
			end
		end

		local char = get_char(client)
		local root = get_root(char)

		if (char and root and playergui.HUD.Main.Dialogue.Visible and playergui.HUD.Main.Dialogue.Position.Y.Scale < 1 and os.clock() - hidden_flags.dialogue_opened > 10) then
			moveto(root.Position, flags.tween_speed, 470)
			hidden_flags.dialogue_opened = os.clock()
		end
	end
end)

playergui.HUD.Miscs.ServerStats.Uptime:GetPropertyChangedSignal('Text'):Connect(function()
	local hours, minutes, seconds = unpack(playergui.HUD.Miscs.ServerStats.Uptime.Text:split(':'))
	hours, minutes, seconds = tonumber(hours), tonumber(minutes), tonumber(seconds)
	
	if (hours >= 7 and minutes >= 45) then
		hidden_flags.kicked = true
		client:Kick(`server timed out {hours}:{minutes}:{seconds}`)
	end
end)

runservice.PostSimulation:Connect(function()
	local char = get_char(client) 
	local root = char and get_root(char)
	local hum = char and get_hum(char)

	if (char and root and hum) then
		local stamina, maxstamina = client:GetAttribute('Stamina'), client:GetAttribute('MaxStamina')
		local health, maxhealth = hum.Health, hum.MaxHealth
		local menu_status = playergui.HUD.Main.Dialogue.Visible and playergui.HUD.Main.Dialogue.Position.Y.Scale < 1

		hidden_flags.yield_tool_farm = menu_status

		if (stamina and maxstamina and stamina / maxstamina < 0.2) then
			hidden_flags.good_stamina = false
		end
		
		if (stamina and maxstamina and stamina / maxstamina > 0.9) then
			hidden_flags.good_stamina = true
		end

		if (health / maxhealth < 0.2) then
			hidden_flags.good_health = false
		end
		
		if (health / maxhealth > 0.9) then
			hidden_flags.good_health = true
		end
		
		local hunger = client:GetAttribute('Hunger')

		if (hunger) then
			if (hunger < 20) then
				hidden_flags.should_eat = true
			end

			if (hunger >= 100) then
				hidden_flags.should_eat = false
			end
		end
		
		local fatigue_str = playergui.HUD.Bars.MainHUD.FatigueStamina.Text:match('Fatigue:%s*([%d%.]+)')
		local fatigue = fatigue_str and tonumber(fatigue_str)
		local balance = get_balance()
		local bank_balance = get_bank_balance()

		if (fatigue and fatigue == 0) then
			if (hidden_flags.fatigue_wait) then
				virtualinputmanager:SendKeyEvent(true, 'Space', false, nil)
			end

			hidden_flags.fatigue_wait = false
		end

		if (flags.auto_fatigue and fatigue and fatigue >= 90 and balance and bank_balance) then
			if (balance < 10_000 and bank_balance >= 10_000) then
				withdraw(10_000)
			end

			if (balance >= 10_000 and check_bed_available()) then
				hidden_flags.fatigue_wait = fatigue
			end
		end
	end


	if (hidden_flags.currently_moving or flags.auto_shadow_box or flags.job_farm or flags.stamina_farm or flags.construction_farm or hidden_flags.consumer or hidden_flags.fatigue_wait or (flags.auto_eat and hidden_flags.should_eat)) then
		if (char and root) then
			if (char:FindFirstChildWhichIsA('Highlight')) then
				virtualinputmanager:SendKeyEvent(true, 'W', false, nil)
				virtualinputmanager:SendKeyEvent(true, 'D', false, nil)
				task.wait()
				virtualinputmanager:SendKeyEvent(false, 'W', false, nil)
				virtualinputmanager:SendKeyEvent(false, 'D', false, nil)
			end

			if (not flags.auto_shadow_box and root.Anchored) then
				warn('root was Anchored, might be moving too fast')
				-- root.Anchored = false
			end

			hum:ChangeState(16)

			root.Velocity = vector.create(0, 2, 0)

			for i,v in (hum:GetPlayingAnimationTracks()) do
				v:Stop()
			end

			for _, v in (char:GetDescendants()) do 
				if (v:IsA('BasePart')) then 
					v.CanCollide = false 
				end
			end
		end

		if char and root and root.Rotation.X < 10 and root.Rotation.X > -10 and not flags.auto_shadow_box then
			local upVector = vector.create(0, -0.75, 1)
			local rightVector = -root.CFrame.RightVector

			root.CFrame = CFrame.fromMatrix(root.Position, rightVector, upVector)
		end
	end
end)

client.OnTeleport:Connect(function()
	local final_string = 'getgenv().flags = {\n'
	for i, v in (flags) do 
		local is_string = type(v) == 'string' and `'{tostring(v)}'` or tostring(v)
		final_string = final_string .. i .. ' = ' .. is_string .. ',\n'
	end

	final_string = final_string .. '}'

	if (queue_on_teleport) then
		queue_on_teleport(`{final_string}\nloadstring(game:HttpGet('https://raw.githubusercontent.com/afyzone/lua/refs/heads/main/Ryujin/gui.lua'))()`)
	end
end)

coregui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
	if (child.Name == 'ErrorPrompt' and not hidden_flags.kicked) then
		local msg = child:FindFirstChild('MessageArea') and child.MessageArea:FindFirstChild('ErrorFrame') and child.MessageArea.ErrorFrame:FindFirstChild('ErrorMessage')
		client:Kick(`was kicked by the game for: {msg and msg.Text}`)
	end
end)

teleportservice.TeleportInitFailed:Connect(function(player)
	if (player ~= client) then return end
	
	teleportservice.Teleport(teleportservice, game.PlaceId)
end)

local old; old = hookmetamethod(game, '__namecall', function(...)
	local method = getnamecallmethod()

	if (method:lower() == 'teleport' or method:lower() == 'kick') then
		if (not hidden_flags.teleporting) then
			hidden_flags.teleporting = true
			local self, key = ...
			client.Kick(client, `afy rejoin for: {key}`)

			if (flags.webhook) then
				send_data(key)

				task.wait(0.5)
			end
			
			local new_server = get_new_server()
			if (new_server) then
				teleportservice.TeleportToPlaceInstance(teleportservice, game.PlaceId, new_server)
			else
				teleportservice.Teleport(teleportservice, game.PlaceId)
			end
		end

		return
	end

	return old(...)
end)

playergui.HUD.Secondary.Trainings.ChildAdded:Connect(function(child)
	if not (flags.toolfarm and hidden_flags.good_stamina) then return end
	if (hidden_flags.yield_tool_farm) then return end
	hidden_flags.wait_for_tool = true

	if (child.Name == 'Circle') then
		while (flags.toolfarm and child and task.wait()) do
			local ring = child:FindFirstChild('Ring')
			local keybind = child:FindFirstChild('Keybind')
			local btn = keybind and Enum.KeyCode[keybind.Text]
		
			if (ring and btn and ring.Size.Y.Scale <= 0.5) then
				-- task.wait(0.1)
				virtualinputmanager:SendKeyEvent(true, btn, false, nil)
				virtualinputmanager:SendKeyEvent(false, btn, false, nil)
				break
			end
		end
	elseif (child.Name == 'Square') then
		local keybind = child:FindFirstChild('Keybind')
		local btn = keybind and Enum.KeyCode[keybind.Text]

		if (btn) then
			virtualinputmanager:SendKeyEvent(true, btn, false, nil)
			virtualinputmanager:SendKeyEvent(false, btn, false, nil)
		end
	end
end)

playergui.HUD.Secondary.Trainings.ChildRemoved:Connect(function()
	hidden_flags.wait_for_tool = false
end)

userinputservice.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode['M'] then
		menuvisibility = not menuvisibility
		
		Menu:SetVisible(menuvisibility)
	end
end)

Menu.Watermark:SetVisible(true)
Menu:SetTab("Main")
Menu:SetVisible(true)
Menu:Init()
