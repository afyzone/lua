--[[
	Code from 2021-2022
	discord = https://discord.gg/VudGqHwCHb
]]

-- Services
local players = game:GetService("Players")
local pathfind = game:GetService("PathfindingService")
local runservice = game:GetService('RunService')
local replicatedstorage = game:GetService('ReplicatedStorage')
local userinputservice = game:GetService('UserInputService')

-- Variables
local client = players.LocalPlayer
local playergui = client:WaitForChild('PlayerGui')
local main_color = Color3.fromRGB(255, 94, 159)
local req = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or getgenv().request or request
local targetgroup = 32353519
local MenuVis = true
local currentlymoving = false
local tempadornee;
local main_gui = playergui and playergui:FindFirstChild('Main')
local clean_parts = workspace.CleaningParts
local smart_walk_tick = tick()
local firetouchinterest = function(...)
	local args = {...}
	task.spawn(function()
		fireclickdetector(unpack(args))
	end)
end

local flags = {
	farm_method = 'Tween',
	tween_speed = 2.25,
	food_minimum = 20,
	minstamina = 20,
	farm_location = 'Gym',
	roadworktype = 'Speed',
	punchingtype = 'Strike Power Training',
	foodtype = 'Chicken',
	calisthenictype = 'Push Up',
	eating = false,
	walkspeed = 16,
	autodeposit = false,
	autowithdraw = false,
	antimod = false,
	jobtype = 'Both',
	healthmin = 10,
	downbool = false
}

local highrank = {
	'Contributors',
	'Staff',
	'Developers',
	'Developers+',
	'Co-Creators',
	'Head Developer'
}

local all_foods = {
	'Chicken',
	'Cheeseburger',
	'Milkshake',
	'Protein Shake',
	'Sushi'
}

-- Extra
client.DevCameraOcclusionMode = "Invisicam"
client.CameraMaxZoomDistance = math.huge
for i, v in pairs(getconnections(client.Idled)) do 
	v:Disable()
end

-- Functions
local moveto, forceusetool, get_floor, fire_click, eatfood, use_food, playernearobj, safestbag, has_item, autowithdraw, gym_road, playerradiuscheck, senkai_road, bankpart, get_strike_power, get_bodycondition, get_strike_speed; do 
	moveto = function(destination, increment, targetY, postY, upsideDown)
		if currentlyMoving then return end
		currentlyMoving = true
	
		local character = client.Character
		if not (character and character.PrimaryPart) then
			currentlyMoving = false
			return
		end
	
		local root = character.PrimaryPart
		local currentPos = root.Position
		local destinationPos = (typeof(destination) == "CFrame" and destination.Position or destination) + Vector3.new(0, postY or 0, 0)
	
		targetY = root.CFrame.X > 5000 and -27.7 or -23.7
	
		local function moveToTarget(targetPos, increment)
			local distance = (targetPos - currentPos).Magnitude
			local direction = (targetPos - currentPos).Unit
	
			while distance > (increment / 10) do
				currentPos = currentPos + direction * (increment / 10)
				root.CFrame = CFrame.new(currentPos)
	
				if not upsideDown then
					local rotationX = root.Rotation.X
					if rotationX < 10 and rotationX > -10 then
						root.CFrame = root.CFrame * CFrame.Angles(math.pi, 0, 0)
					end
				end
	
				task.wait()
				distance = (targetPos - currentPos).Magnitude
			end
		end
	
		if (math.abs(destinationPos.X - root.Position.X) > 1 or
			math.abs(destinationPos.Z - root.Position.Z) > 1) and
			not (root.Position.Y >= (targetY - 1) and root.Position.Y <= (targetY + 1)) then
	
			moveToTarget(Vector3.new(currentPos.X, targetY, currentPos.Z), 1.2)
		end
	
		local finalTarget = (math.abs(destinationPos.X - root.Position.X) > 1 or
							 math.abs(destinationPos.Z - root.Position.Z) > 1)
							 and Vector3.new(destinationPos.X, targetY, destinationPos.Z) or destinationPos
	
		moveToTarget(finalTarget, (math.abs(destinationPos.X - root.Position.X) > 1 or
									math.abs(destinationPos.Z - root.Position.Z) > 1)
									and 1.2 or increment)
		currentlyMoving = false
	end
	
	forceusetool = function(tool)
		local char = client.Character 
		local root = char and char.PrimaryPart
		local hum = char and char:FindFirstChild('Humanoid')

		if not (char and root and hum) then return; end
		if (flags.eating or flags.autopunchingbag or char:FindFirstChild('Roadwork Training')) then return; end

		if (client.Backpack:FindFirstChild(tool)) then 
			hum:EquipTool(client.Backpack:FindFirstChild(tool))
		end

		if (char:FindFirstChild(tool)) then 
			char:FindFirstChild(tool):Activate()
		end
	end

	get_floor = function()
		local part = nil 
		local dist = math.huge 

		local char = client.Character 
		local root = char and char.PrimaryPart

		if (char and root) then 
			if (clean_parts:FindFirstChild(client.Name)) then 
				local player_model = clean_parts:FindFirstChild(client.Name)

				for _, v in pairs(player_model:GetChildren()) do 
					if (v:IsA('Part')) then 
						local mag = (v.Position - root.Position).magnitude
						
						if (mag < dist) then 
							dist = mag 
							part = v
						end
					end
				end
			end
		end

		return part
	end

	fire_click = function()
		local char = client.Character
		local root = char and char.PrimaryPart

		if (char and root) then 
			local floor = get_floor() 

			if (floor ~= nil) then 
				local mag = (floor.Position - root.Position).magnitude
				local click = floor and floor:FindFirstChild('ClickDetector')
				
				if (click and mag < 8) then 
					fireclickdetector(click)
					moveto(CFrame.new(root.Position.X, -23.7, root.Position.Z), flags.tween_speed)
				end
			end
		end
	end

	has_item = function(item)
		local char = client.Character 
		local backpack = client.Backpack

		return char and (char:FindFirstChild(item) or backpack:FindFirstChild(item))
	end

	use_food = function(hunger)
		local char = client.Character 
		local root = char and char.PrimaryPart
		local hum = char and char:FindFirstChild('Humanoid')
		if (not (char and root and hum)) then return end 

		for i,v in pairs(all_foods) do
			if has_item(v) then
				if (hunger >= flags.food_minimum) then return end

				if (client.Backpack:FindFirstChild(v)) then 
					hum:EquipTool(client.Backpack:FindFirstChild(v))
				end

				if (char:FindFirstChild(v)) then 
					char:FindFirstChild(v):Activate()
				end

				return true
			end
		end
	end

	eatfood = function()
		if (not flags.eating or not flags.autofood) then return end 
		local char = client.Character 
		local root = char and char.PrimaryPart
		local hum = char and char:FindFirstChild('Humanoid')

		if (char and root and hum) then
			local selectedfood = (flags.foodtype == 'Chicken' and workspace.Purchases.Chicken.Chicken or flags.foodtype == 'Cheeseburger' and workspace.Purchases.Burger.Cheeseburger or flags.foodtype == 'Milkshake' and workspace.Purchases.Burger.Milkshake or flags.foodtype == 'Protein Shake' and workspace.Purchases["GYM Rats"]["Protein Shake"]) or workspace.Purchases.Sushi.Sushi
			local foodpart = selectedfood:FindFirstChildWhichIsA('BasePart')
			local hunger = playergui and playergui:FindFirstChild('Main') and playergui.Main.HUD.Hunger.Clipping.Size.X.Scale * 100

			if (hunger >= flags.food_minimum) then return end

			repeat task.wait()
				if (flags.autofood and hunger <= flags.food_minimum) then
					if (use_food(hunger)) then
						use_food(hunger)
						
						moveto(CFrame.new(root.Position.X, -23.7, root.Position.Z), flags.tween_speed)
					else
						local mag = (foodpart.Position - root.Position).magnitude
				
						if (mag < 12) then
							for i = 1, 5 do
								fireclickdetector(selectedfood.ClickDetector)
								task.wait(.6)
							end

							moveto(CFrame.new(foodpart.Position), flags.tween_speed, -10, -23.7)

						elseif (flags.autofood) then 
							moveto(CFrame.new(foodpart.Position), flags.tween_speed, -10, -7)
						end
					end
				end
			until (playergui.Main.HUD.Hunger.Clipping.Size.X.Scale * 100) > 95 or not flags.autofood
		end

		flags.eating = false
	end

	get_strike_power = function()
		local part = nil 
		local dist = math.huge 

		local char = client.Character 
		local root = char and char.PrimaryPart

		if (char and root) then 
			for _, v in pairs(workspace.Purchases.GYM:GetChildren()) do 
				if (v:IsA('Model') and v.Name == 'Strike Power Training' and v:FindFirstChildWhichIsA('BasePart').CFrame.Y <= 25 and (workspace.GangBase.GYM.Position - v:FindFirstChildWhichIsA('BasePart').Position).magnitude > 150) then 
					local mag = (v:GetPivot().Position - root.Position).magnitude
					
					if (mag < dist) then 
						dist = mag 
						part = v
					end
				end
			end
		end

		return part
	end

	get_bodycondition = function()
		local part = nil 
		local dist = math.huge 

		local char = client.Character 
		local root = char and char.PrimaryPart

		if (char and root) then 
			for _, v in pairs(workspace.Purchases.GYM:GetChildren()) do 
				if (v:IsA('Model') and v.Name == 'Body Conditioning' and v:FindFirstChildWhichIsA('BasePart').CFrame.Y <= 25 and (workspace.GangBase.GYM.Position - v:FindFirstChildWhichIsA('BasePart').Position).magnitude > 150) then 
					local mag = (v:GetPivot().Position - root.Position).magnitude
					
					if (mag < dist) then 
						dist = mag 
						part = v
					end
				end
			end
		end

		return part
	end

	get_strike_speed = function()
		local part = nil 
		local dist = math.huge 

		local char = client.Character 
		local root = char and char.PrimaryPart

		if (char and root) then 
			for _, v in pairs(workspace.Purchases.GYM:GetChildren()) do 
				if (v:IsA('Model') and v.Name == 'Strike Speed Training' and v:FindFirstChildWhichIsA('BasePart').CFrame.Y <= 25 and (workspace.GangBase.GYM.Position - v:FindFirstChildWhichIsA('BasePart').Position).magnitude > 150) then 
					local mag = (v:GetPivot().Position - root.Position).magnitude
					
					if (mag < dist) then 
						dist = mag 
						part = v
					end
				end
			end
		end

		return part
	end

	playerradiuscheck = function(radius)
		local clientPosition = client.Character and client.Character.PrimaryPart and client.Character.PrimaryPart.Position
	
		if not clientPosition then return end
		for _, player in pairs(game.Players:GetPlayers()) do
			if player ~= client and player.Character then
				if player.Character.PrimaryPart and player.Character.PrimaryPart.Position then
					local distance = (Vector3.new(playerPosition.X, 0, playerPosition.Z) - Vector3.new(client.Character.PrimaryPart.Position.X, 0, client.Character.PrimaryPart.Position.Z)).magnitude
	
					if distance <= radius then
						return true
					end
				end
			end
		end
	end

	autowithdraw = function()
		if (not flags.autowithdraw) then return end
		local char = client.Character 
		local root = char and char.PrimaryPart
		local hum = char and char:FindFirstChild('Humanoid')
	
		if (char and root and hum) then
			local remainingcash = math.floor(getrenv()._G.Replica.Data.Cash)
			local bankcash = math.floor(getrenv()._G.Replica.Data.Bank)
	
			if (bankcash == 0) then return end
	
			if (remainingcash < 5000) then
				moveto(bankpart.Position, flags.tween_speed, -10, -10)
				replicatedstorage:FindFirstChild("Events"):FindFirstChild("Bank"):FireServer("Withdraw", math.min(250000, bankcash, remainingcash + bankcash))
			end
		end
	end

	playernearobj = function(player, obj)
		local playerposition = player.Character and player.Character.PrimaryPart and player.Character.PrimaryPart.Position
		local objposition = obj:FindFirstChildWhichIsA('BasePart') and obj:FindFirstChildWhichIsA('BasePart').Position
	
		if objposition and playerposition then
			local distance = (Vector3.new(objposition.X, 0, objposition.Z) - Vector3.new(playerposition.X, 0, playerposition.Z)).magnitude
	
			return distance < 30
		end
	end

	safestbag = function(players)
		local closest, obj = math.huge, nil
	
		for _, v in pairs(workspace.Trainings:GetChildren()) do
			if v:IsA('Model') and v.Name == 'PunchingBag' and v:FindFirstChildWhichIsA('BasePart').CFrame.X < 5000 and v:FindFirstChildWhichIsA('BasePart').CFrame.Y <= 25 and (workspace.GangBase.GYM.Position - v:FindFirstChildWhichIsA('BasePart').Position).magnitude > 150 then
				local main = v:FindFirstChild('Main')
	
				if main then
					local is_near = false
	
					for _, player in pairs(game.Players:GetPlayers()) do
						if player ~= client and playernearobj(player, v) then
							is_near = true
							break
						end
					end
	
					if not is_near then
						local distance = (main.Position - client.Character.PrimaryPart.Position).magnitude
	
						if distance < closest then
							closest = distance
							obj = main
						end
					end
				end
			end
		end
	
		return obj
	end
end

-- Preload
for _, v in pairs(workspace.Purchases.GYM:GetChildren()) do 
	if (v:IsA('Model') and v.Name == 'Roadwork Training') then 
		local part = v:FindFirstChild('Part')

		if (part.Position.X < 0) then 
			gym_road = v 
		end 

		if (part.Position.X > 0) then 
			senkai_road = v 
		end
	end

	if (gym_road and senkai_road) then break end 
end

for i,v in pairs(workspace:GetChildren()) do
	if v:IsA('Part') and v.Name == 'Part' and v:FindFirstChild('BillboardGui') and v.BillboardGui:FindFirstChild('Label') and v.BillboardGui.Label.Text == 'Open Bank Account' then
		bankpart = v
		break
	end
end

-- Meny
local Menu = loadstring(game:HttpGet("https://gist.githubusercontent.com/afyzone/78dc2d17017eb642fb42190d72741f7e/raw/681b721a045a8684899a161d469af1aebe22dd84/myasurauilib.lua", true))(); do 
	local update_menu_name = function()
		while (task.wait()) do 
			local name, placeholder = 'made by @leadmarker and @afyzone | discord.gg/VudGqHwCHb', ''
			for i = 1, #name do
				local character = string.sub(name, i, i)
				placeholder = placeholder .. character 
				Menu:SetTitle(placeholder)
				task.wait(.10)
			end
		end
	end
	
	task.spawn(update_menu_name)
	
	Menu.Accent = main_color
	Menu.Watermark()
	Menu.Watermark:Update('discord.gg/VudGqHwCHb') 

	-- Tabs 
	local Main = Menu.Tab("Main")

	-- Containers
	local Credits = Menu.Container('Main', 'Credits', 'Left'); do -- Credits
		Menu.Button('Main', 'Credits', 'Join Discord', function()
			setclipboard('https://discord.gg/VudGqHwCHb')
			if (Electron ~= nil and rawget(Electron, 'request')) then 
				Electron.request({Url = 'http://127.0.0.1:6463/rpc?v=1', Method = 'POST', Headers = {['Content-Type'] = 'application/json', Origin = 'https://discord.com'}, Body = game:GetService("HttpService"):JSONEncode({cmd = 'INVITE_BROWSER', nonce = game:GetService("HttpService"):GenerateGUID(false), args = {code = 'VudGqHwCHb'}})})
			end

			if (Fluxus ~= nil and rawget(Electron, 'request')) then 
				Fluxus.request({Url = 'http://127.0.0.1:6463/rpc?v=1', Method = 'POST', Headers = {['Content-Type'] = 'application/json', Origin = 'https://discord.com'}, Body = game:GetService("HttpService"):JSONEncode({cmd = 'INVITE_BROWSER', nonce = game:GetService("HttpService"):GenerateGUID(false), args = {code = 'VudGqHwCHb'}})})
			end

			if (getgenv().Valyse ~= nil) then 
				getgenv().request({Url = 'http://127.0.0.1:6463/rpc?v=1', Method = 'POST', Headers = {['Content-Type'] = 'application/json', Origin = 'https://discord.com'}, Body = game:GetService("HttpService"):JSONEncode({cmd = 'INVITE_BROWSER', nonce = game:GetService("HttpService"):GenerateGUID(false), args = {code = 'VudGqHwCHb'}})})
			end

			req({Url = 'http://127.0.0.1:6463/rpc?v=1', Method = 'POST', Headers = {['Content-Type'] = 'application/json', Origin = 'https://discord.com'}, Body = game:GetService("HttpService"):JSONEncode({cmd = 'INVITE_BROWSER', nonce = game:GetService("HttpService"):GenerateGUID(false), args = {code = 'VudGqHwCHb'}})})
		end)

		Menu.Button('Main', 'Credits', '@leadmarker', function()
			setclipboard('@leadmarker')
		end)

		Menu.Button('Main', 'Credits', '@afyzone', function()
			setclipboard('@afyzone')
		end)
	end

	local Settings = Menu.Container('Main', 'Settings', 'Right'); do 
		Menu.Slider('Main', 'Settings', 'Tween Speed', 0, 10, 2.25, '', 1, function(self)
			flags.tween_speed = self
		end)

		Menu.Slider('Main', 'Settings', 'Walk Speed', 16, 50, 16, '', 0, function(self)
			flags.walkspeed = self
		end)
	end

	local Farming = Menu.Container('Main', 'Job Farm', 'Right'); do -- Job Farm
		Menu.ComboBox('Main', 'Job Farm', 'Job Type', 'Both', {'Both', 'Delivery', 'Clean Floors'}, function(self)
			flags.jobtype = self
		end)

		Menu.CheckBox('Main', 'Job Farm', 'Auto Deposit', false, function(self)
			flags.autodeposit = self
		end)

		Menu.CheckBox('Main', 'Job Farm', 'Job Farm', false, function(self)
			flags.job_farm = self

			local jump_check = tick()

			if (not self) then 
				replicatedstorage.Events.EventCore:FireServer('Run', 'Start', false)
			end

			task.spawn(function()
				while (flags.job_farm and task.wait()) do 
					local char = client.Character 
					local root = char and char.PrimaryPart
					local hum = char and char:FindFirstChild('Humanoid')

					if (char and root) then 
						if (flags.autodeposit and client.PlayerGui.Main.HUD.Cash.Text:find('250,000')) then
							moveto(bankpart.Position, flags.tween_speed, -10, -10)
							replicatedstorage:FindFirstChild("Events"):FindFirstChild("Bank"):FireServer("Deposit", "250000")
						end

						autowithdraw()
						eatfood()

						local job_status = main_gui and main_gui:FindFirstChild('LabelJob')

						if (job_status.Text == '') then
							replicatedstorage.Events.EventCore:FireServer('Job')
						else
							local billboard = playergui and playergui:FindFirstChild('BillboardGui')

							if (billboard ~= nil) then 
								local get_part = billboard and billboard.Adornee

								if (job_status.Text:find('floor')) then
									if (flags.jobtype == 'Both' or flags.jobtype == 'Clean Floors') then
										local get_tile = get_floor()

										if (not get_tile) then 
											if (flags.job_farm) then 
												moveto(CFrame.new(get_part.Position), flags.tween_speed, -10, -4.8)
												moveto(CFrame.new(get_part.Position), flags.tween_speed, -10, -23.7)
											end
										else
											local get_tile = get_floor()
											if (get_tile and flags.job_farm) then
												if client.Character:FindFirstChild('Broom') then
													moveto(CFrame.new(get_tile.Position), flags.tween_speed, -10, -23.7)
												else
													moveto(CFrame.new(get_tile.Position), flags.tween_speed, -10, -4.8)
													fire_click()
												end
											end
										end
									else
										moveto(CFrame.new(root.Position.X, -23.7, root.Position.Z), flags.tween_speed)
										if (job_status.Text:find('floor')) then
											replicatedstorage:FindFirstChild("Events"):FindFirstChild("EventCore"):FireServer("CancelJob") 
											repeat task.wait() until job_status.Text == ''
										end
									end
								else
									if (flags.jobtype == 'Both' or flags.jobtype == 'Delivery') then
										local height = -5.5

										if (char:FindFirstChild('Crate') and tonumber(playergui.Main.LabelJob2.Text) > 179) then
											height = -23.7
										end

										moveto(CFrame.new(get_part.Position), flags.tween_speed, -10, height)
										local part = nil 
										local dist = math.huge 
									
										local char = client.Character 
										local root = char and char.PrimaryPart
									
										if (char and root) then 
											for _, v in pairs(workspace.Delivery:GetDescendants()) do 
												if (v:IsA('TouchTransmitter') and (v.Parent.Position - root.Position).magnitude < 5) then 
													local crate = v.Parent
													local mag = (crate.Position - root.Position).magnitude
													
													if (mag < dist) then 
														dist = mag 
														part = crate
													end
												end
											end

											if (part) then 
												firetouchinterest(root, part, 0)
												firetouchinterest(root, part, 1)
											end
										end

										moveto(CFrame.new(get_part.Position), flags.tween_speed, -10, -23.7)
									else
										moveto(CFrame.new(root.Position.X, -23.7, root.Position.Z), flags.tween_speed)
										if (job_status.Text:find('crate')) then
											replicatedstorage:FindFirstChild("Events"):FindFirstChild("EventCore"):FireServer("CancelJob") 

											while (job_status.Text ~= '' and task.wait()) do
												moveto(CFrame.new(root.Position.X, -23.7, root.Position.Z), flags.tween_speed)
											end
										end
									end
								end
							end
						end
					end
				end
			end)
		end)
	end

	local Stats = Menu.Container('Main', 'Stats', 'Left'); do -- Stats Farm 
		Menu.CheckBox('Main', 'Stats', 'Auto Withdraw', false, function(self)
			flags.autowithdraw = self
		end)

		Menu.Slider('Main', 'Stats', 'All Farms Stamina Minimum', 0, 100, 20, '', 0, function(self)
			flags.minstamina = self
		end)

		Menu.ComboBox('Main', 'Stats', 'Farm Area', 'Gym', {'Gym', 'Senkaimon'}, function(self)
			flags.farm_location = self
		end)

		Menu.ComboBox('Main', 'Stats', 'Roadwork Type', 'Speed', {'Speed', 'Stamina'}, function(self)
			flags.roadworktype = self
		end)

		Menu.CheckBox('Main', 'Stats', 'Auto Roadwork', false, function(self)
			flags.autoroadwork = self

			local jump_check = tick()

			if (not self) then 
				replicatedstorage.Events.EventCore:FireServer('Run', 'Start', false)
			end

			if (flags.autoroadwork) then 
				local char = client.Character
				local root = char and char.PrimaryPart

				if (char and root and root.CFrame.Y > 0 and flags.farm_location == 'Senkaimon') then 
					Menu.Notify('WARNING: Goto senkaimon area first')
					return 
				end
			end

			task.spawn(function()
				while (flags.autoroadwork and task.wait()) do 
					local char = client.Character 
					local root = char and char.PrimaryPart
					local hum = char and char:FindFirstChild('Humanoid')

					if (char and root and hum) then 
						local billboard = playergui and playergui:FindFirstChild('BillboardGui') and playergui:FindFirstChild('BillboardGui').Adornee ~= nil and playergui:FindFirstChild('BillboardGui')
						local roadwork_gain = playergui.RoadworkGain:FindFirstChild('Frame')

						autowithdraw()
						eatfood()
						
						if (not has_item('Roadwork Training') and not billboard) then
							local road_type = (flags.farm_location == 'Gym' and gym_road) or senkai_road
							local mag = (road_type:GetPivot().Position - root.Position).magnitude

							if (mag < 25) then 
								local road_type = (flags.farm_location == 'Gym' and gym_road.ClickDetector) or senkai_road.ClickDetector

								for i = 1, 3 do
									fireclickdetector(road_type)
									task.wait(.6)
								end

							else
								moveto(CFrame.new(road_type.Part.Position), flags.tween_speed, -10, -10)
							end
							
						elseif (billboard) then
							moveto(CFrame.new(billboard.Adornee.Position), flags.tween_speed, -10, -21.7)
							local part = nil 
							local dist = math.huge 
						
							local char = client.Character 
							local root = char and char.PrimaryPart
						
							if (char and root) then 
								for _, v in pairs(workspace.Roadworks:GetDescendants()) do 
									if (v:IsA('TouchTransmitter') and (v.Parent.Position - root.Position).magnitude < 5) then 
										local thing = v.Parent
										local mag = (thing.Position - root.Position).magnitude
										
										if (mag < dist) then 
											dist = mag 
											part = thing
										end
									end
								end

								if (part) then
									firetouchinterest(root, part, 0)
									firetouchinterest(root, part, 1)
								end
							end
						elseif (has_item('Roadwork Training') and not billboard) then 
							if (client.Backpack:FindFirstChild('Roadwork Training')) then 
								hum:EquipTool(client.Backpack:FindFirstChild('Roadwork Training'))
							end

							if (char:FindFirstChild('Roadwork Training') and roadwork_gain.Visible == false) then 
								char:FindFirstChild('Roadwork Training'):Activate()
							end

							if (roadwork_gain.Visible == true and roadwork_gain:FindFirstChild(flags.roadworktype)) then 
								firesignal(roadwork_gain[flags.roadworktype].MouseButton1Up)
							end

						elseif (billboard and roadwork_gain and roadwork_gain.Visible == true) then
							roadwork_gain.Visible = false
						end
					end
				end
			end)
		end)

		Menu.ComboBox('Main', 'Stats', 'Punching Bag Type', 'Strike Power Training', {'Strike Power Training', 'Strike Speed Training'}, function(self)
			flags.punchingtype = self
		end)

		Menu.CheckBox('Main', 'Stats', 'Auto Punching Bag', false, function(self)
			flags.autopunchingbag = self

			local jump_check = tick()

			if (not self) then 
				replicatedstorage.Events.EventCore:FireServer('Run', 'Start', false)
			end

			task.spawn(function()
				while (flags.autopunchingbag and task.wait()) do 
					local char = client.Character 
					local root = char and char.PrimaryPart
					local hum = char and char:FindFirstChild('Humanoid')

					if (char and root and hum) then
						local billboard = playergui and playergui:FindFirstChild('BillboardGui') and playergui:FindFirstChild('BillboardGui').Adornee ~= nil and playergui:FindFirstChild('BillboardGui')
						local item_type = (flags.punchingtype == 'Strike Power Training' and get_strike_power()) or get_strike_speed()
						local stamina = playergui and playergui:FindFirstChild('Main') and (playergui.Main.HUD.Stamina.Clipping.Size.X.Scale * 100) or 0

						autowithdraw()
						eatfood()

						if (not has_item(flags.punchingtype) and not char:FindFirstChild('Gloves') and not billboard) then
							local mag = (item_type.Part.Position - root.Position).magnitude
							
							if (mag < 12) then
								for i = 1, 3 do
									fireclickdetector(item_type.ClickDetector)
									task.wait(.6)
								end

							else
								moveto(CFrame.new(item_type.Part.Position), flags.tween_speed, -10, -8)
							end
							
						elseif (has_item(flags.punchingtype) and not char:FindFirstChild('Gloves') and not billboard) then
							local bestpunchbag = safestbag()

							if (not bestpunchbag) then
								moveto(CFrame.new(root.Position.X, -23.7, root.Position.Z), flags.tween_speed, -10, -7)
							end

							if (not client.Character:FindFirstChild('Ragdoll') and (client.Character.Humanoid.Health / client.Character.Humanoid.MaxHealth) * 100 > 20) then 
								moveto(CFrame.new(bestpunchbag.Position), flags.tween_speed, -10, -7)

								if (client.Backpack:FindFirstChild(flags.punchingtype)) then 
									hum:EquipTool(client.Backpack:FindFirstChild(flags.punchingtype))
								end
								
								if (char:FindFirstChild(flags.punchingtype) and (bestpunchbag.Position - root.Position).magnitude < 15) then 
									char:FindFirstChild(flags.punchingtype):Activate()
								end
							end

						elseif (char:FindFirstChild('Gloves') and billboard) then 
							if (stamina > flags.minstamina) then
								if (client.Backpack:FindFirstChild('Combat')) then 
									-- client.Backpack:FindFirstChild('Combat').Parent = char
									hum:EquipTool(client.Backpack:FindFirstChild('Combat'))
								end
	
								if (char:FindFirstChild('Combat') --[[and (billboard.Adornee.Position - root.Position).magnitude < 7]]) then 
									if (getrenv()._G.Replica.Data.Style == 'Lethwei') then
										if client.Character.Humanoid.WalkSpeed > 4 then
											flags.downbool = false
											char:FindFirstChild('Combat'):Activate()

											if (flags.punchingtype == 'Strike Power Training') then
												task.wait(.5)
											else
												task.wait(.2)
											end
										else
											flags.downbool = true
										end
									else
										char:FindFirstChild('Combat'):Activate()

										if (flags.punchingtype == 'Strike Power Training') then
											task.wait(.5)
										end
									end
								end
							end
							
							if billboard and billboard.Adornee.Position then
								if not tempadornee or (tempadornee - root.Position).magnitude > 15 then
									tempadornee = billboard.Adornee.Position + Vector3.new(0, 0, -3)
								end
							end

							if (tempadornee - root.Position).magnitude > 20 and (not client.Character:FindFirstChild('Ragdoll') and (client.Character.Humanoid.Health / client.Character.Humanoid.MaxHealth) * 100 > 20) then
								moveto(CFrame.new(tempadornee), flags.tween_speed, -10, -7)
							end
						end
					end
				end
			end)
		end)

		Menu.ComboBox('Main', 'Stats', 'Calisthenic Type', 'Push Up', {'Push Up', 'Sit Up', 'Squat'}, function(self)
			flags.calisthenictype = self
		end)

		Menu.CheckBox('Main', 'Stats', 'Auto Calisthenic', false, function(self)
			flags.autocalisthenic = self

			task.spawn(function()
				while (flags.autocalisthenic and task.wait()) do 
					local char = client.Character 
					local root = char and char.PrimaryPart
					local hum = char and char:FindFirstChild('Humanoid')

					if (char and root and hum) then
						local stamina = playergui and playergui:FindFirstChild('Main') and (playergui.Main.HUD.Stamina.Clipping.Size.X.Scale * 100) or 0
						local selectedtool = flags.calisthenictype

						autowithdraw()
						eatfood()

						if not (flags.autopunchingbag or flags.autoroadwork or flags.job_farm) then
							moveto(CFrame.new(root.Position.X, -23.7, root.Position.Z), flags.tween_speed)
						end

						if (stamina > flags.minstamina) then
							forceusetool(selectedtool)
						end
					end
				end
			end)
		end)

		Menu.ComboBox('Main', 'Stats', 'Alternative Durability Person', '', players:GetPlayers(), function(self)
			flags.autoduraperson = self
		end)

		Menu.Slider('Main', 'Stats', 'Health Minimum', 0, 100, 10, '', 0, function(self)
			flags.healthmin = self
		end)

		Menu.CheckBox('Main', 'Stats', 'Alternative Auto Durability', false, function(self)
			flags.autodura = self
			
			local initialdura = (client.Name < flags.autoduraperson and client) or players:FindFirstChild(flags.autoduraperson)
			
			task.spawn(function()
				while (flags.autodura and initialdura and task.wait()) do 
					local char = client.Character 
					local root = char and char.PrimaryPart
					local hum = char and char:FindFirstChild('Humanoid')
			
					if (char and root and hum) then
						local stamina = playergui and playergui:FindFirstChild('Main') and (playergui.Main.HUD.Stamina.Clipping.Size.X.Scale * 100) or 0
						local selectedfood = (flags.foodtype == 'Chicken' and workspace.Purchases.Chicken.Chicken or flags.foodtype == 'Cheeseburger' and workspace.Purchases.Burger.Cheeseburger or flags.foodtype == 'Milkshake' and workspace.Purchases.Burger.Milkshake or flags.foodtype == 'Protein Shake' and workspace.Purchases["GYM Rats"]["Protein Shake"]) or workspace.Purchases.Sushi.Sushi
						local item_type = get_bodycondition()

						autowithdraw()
						eatfood()

						if (not has_item('Body Conditioning') and not client.Character:FindFirstChild('OnHit')) then
							local mag = (item_type.Part.Position - root.Position).magnitude
							
							if (mag < 12) then
								for i = 1, 3 do
									fireclickdetector(item_type.ClickDetector)
									task.wait(.6)
								end

							else
								moveto(CFrame.new(item_type.Part.Position), flags.tween_speed, -10, -8)
							end

						elseif (initialdura == client) then
							if has_item('Body Conditioning') and not client.Character:FindFirstChild('OnHit') then
								if (client.Character.Humanoid.Health / client.Character.Humanoid.MaxHealth) * 100 > flags.healthmin then
									moveto(CFrame.new(item_type:FindFirstChildWhichIsA('BasePart').Position.X + 8, -23.7, item_type:FindFirstChildWhichIsA('BasePart').Position.Z + 5), flags.tween_speed)

									if not client.Character:FindFirstChild('OnHit') then
										if (client.Backpack:FindFirstChild('Body Conditioning')) then 
											hum:EquipTool(client.Backpack:FindFirstChild('Body Conditioning'))
										end
										
										if (char:FindFirstChild('Body Conditioning')) then 
											char:FindFirstChild('Body Conditioning'):Activate()
											task.wait(.5)
										end
									end

								else
									initialdura = players:FindFirstChild(flags.autoduraperson)
									moveto(CFrame.new(item_type:FindFirstChildWhichIsA('BasePart').Position.X + 5, -23.7, item_type:FindFirstChildWhichIsA('BasePart').Position.Z + 5), flags.tween_speed)
								end

							elseif client.Character:FindFirstChild('OnHit') then
								if (client.Character.Humanoid.Health / client.Character.Humanoid.MaxHealth) * 100 > flags.healthmin then
									moveto(CFrame.new(item_type:FindFirstChildWhichIsA('BasePart').Position.X + 8, -23.7, item_type:FindFirstChildWhichIsA('BasePart').Position.Z + 5), flags.tween_speed)

								else
									if client.Character:FindFirstChild('OnHit') then
										if (client.Backpack:FindFirstChild('Body Conditioning')) then 
											hum:EquipTool(client.Backpack:FindFirstChild('Body Conditioning'))
										end
										
										if (char:FindFirstChild('Body Conditioning')) then 
											char:FindFirstChild('Body Conditioning'):Activate()
											task.wait(.5)
										end
									end

									initialdura = players:FindFirstChild(flags.autoduraperson)
									moveto(CFrame.new(item_type:FindFirstChildWhichIsA('BasePart').Position.X + 5, -23.7, item_type:FindFirstChildWhichIsA('BasePart').Position.Z + 5), flags.tween_speed)
									
								end
							end

						else
							moveto(CFrame.new(item_type:FindFirstChildWhichIsA('BasePart').Position.X + 8, -23.7, item_type:FindFirstChildWhichIsA('BasePart').Position.Z + 5), flags.tween_speed)

							if (players[flags.autoduraperson].Character and players[flags.autoduraperson].Character:FindFirstChild('Humanoid') and (players[flags.autoduraperson].Character.Humanoid.Health / players[flags.autoduraperson].Character.Humanoid.MaxHealth) * 100 > flags.healthmin) then
								if (stamina > flags.minstamina) then
									if client.Character:FindFirstChild('OnHit') then
										if (client.Backpack:FindFirstChild('Body Conditioning')) then 
											hum:EquipTool(client.Backpack:FindFirstChild('Body Conditioning'))
										end
										
										if (char:FindFirstChild('Body Conditioning')) then 
											char:FindFirstChild('Body Conditioning'):Activate()
											task.wait(.5)
										end
									else
										if (client.Backpack:FindFirstChild('Combat')) then 
											hum:EquipTool(client.Backpack:FindFirstChild('Combat'))
										end
									
										if (char:FindFirstChild('Combat') and players[flags.autoduraperson].Character and players[flags.autoduraperson].Character:FindFirstChild('OnHit') and ((players[flags.autoduraperson].Character.Humanoid.Health / players[flags.autoduraperson].Character.Humanoid.MaxHealth) * 100 > flags.healthmin)) then 
											char:FindFirstChild('Combat'):Activate()
										end
									end
								end

							else
								initialdura = client
								moveto(CFrame.new(item_type:FindFirstChildWhichIsA('BasePart').Position.X + 5, -23.7, item_type:FindFirstChildWhichIsA('BasePart').Position.Z + 5), flags.tween_speed)
							end
						end

						if ((client.Character.Humanoid.Health / client.Character.Humanoid.MaxHealth) * 100 <= flags.healthmin and (players[flags.autoduraperson].Character.Humanoid.Health / players[flags.autoduraperson].Character.Humanoid.MaxHealth) * 100 <= flags.healthmin) then
							client.Character.Humanoid:UnequipTools()
							repeat task.wait()
								autowithdraw()
								eatfood()
								moveto(CFrame.new(item_type:FindFirstChildWhichIsA('BasePart').Position.X + 5, -23.7, item_type:FindFirstChildWhichIsA('BasePart').Position.Z + 5), flags.tween_speed)
							until ((client.Character.Humanoid.Health / client.Character.Humanoid.MaxHealth) * 100 > 99 or (players[flags.autoduraperson].Character.Humanoid.Health / players[flags.autoduraperson].Character.Humanoid.MaxHealth) * 100 > 99)

							if (client.Character.Humanoid.Health / client.Character.Humanoid.MaxHealth) * 100 > 99 then
								initialdura = client
							elseif (players[flags.autoduraperson].Character.Humanoid.Health / players[flags.autoduraperson].Character.Humanoid.MaxHealth) * 100 > 99 then
								initialdura = players:FindFirstChild(flags.autoduraperson)
							end
						end

						if (client.Character:FindFirstChild('OnHit') and players[flags.autoduraperson].Character:FindFirstChild('OnHit') or client.Character:FindFirstChild('Combat') and players[flags.autoduraperson].Character:FindFirstChild('Combat')) then
							client.Character.Humanoid:UnequipTools()
							initialdura = (client.Name < flags.autoduraperson and client) or players:FindFirstChild(flags.autoduraperson)
						end
					end
				end
			end)
		end)
	end

	local Food = Menu.Container('Main', 'Auto Food', 'Right'); do
		Menu.ComboBox('Main', 'Auto Food', 'Food Type', 'Chicken', {'Chicken', 'Cheeseburger', 'Milkshake', 'Sushi', 'Protein Shake'}, function(self)
			flags.foodtype = self
		end)

		Menu.Slider('Main', 'Auto Food', 'Food Minimum', 0, 100, 20, '', 0, function(self)
			flags.food_minimum = self
		end)

		Menu.CheckBox('Main', 'Auto Food', 'Food', false, function(self)
			flags.autofood = self

			task.spawn(function()
				while (flags.autofood and task.wait()) do 
					local char = client.Character 
					local root = char and char.PrimaryPart
					local hum = char and char:FindFirstChild('Humanoid')

					if (char and root and hum) then
						local hunger = playergui and playergui:FindFirstChild('Main') and (playergui.Main.HUD.Hunger.Clipping.Size.X.Scale * 100) or 0

						if hunger <= flags.food_minimum then
							flags.eating = true
						end
					end
				end
			end)
		end)
	end

	local AntiMod = Menu.Container('Main', 'Anti Mod', 'Right'); do
		Menu.CheckBox('Main', 'Anti Mod', 'Anti Mod', false, function(self)
			flags.antimod = self

			task.spawn(function()
				for _, v in pairs(players:GetPlayers()) do
					if v ~= client and v:IsInGroup(targetgroup) then
						if v:GetRoleInGroup(targetgroup) and table.find(highrank, v:GetRoleInGroup(targetgroup)) then
							if flags.antimod then
								client.Kick(client, 'A ' .. v:GetRoleInGroup(targetgroup) .. ' was in your game. Username: ' .. v.Name)
								break
							else
								Menu.Notify('A ' .. v:GetRoleInGroup(targetgroup) .. ' is in your game. Username: ' .. v.Name)
							end
						end
					end
				end
			end)
		end)
	end

	runservice.Heartbeat:Connect(function()
		if (flags.autoroadwork or flags.job_farm or flags.autopunchingbag or flags.autocalisthenic) then 
			if (flags.autoroadwork) then
				local char = client.Character 
				local hum = char and char:FindFirstChild('Humanoid')
			
				local stamina = playergui and playergui:FindFirstChild('Main') and playergui.Main.HUD.Stamina.Clipping.Size.X.Scale * 100
				if (stamina <= flags.minstamina) then 
					replicatedstorage.Events.EventCore:FireServer('Run', 'Start', false)
				elseif (stamina >= 95 and tick() - smart_walk_tick >= .5) then 
					replicatedstorage.Events.EventCore:FireServer('Run', 'Start', true, 1)
					smart_walk_tick = tick()
				end 
				
				if (stamina >= 95) then 
					if (char and hum) then 
						hum.WalkSpeed = flags.walkspeed 
					end
				end
			end

			if (client.Character and client.Character.PrimaryPart) then
				client.Character.PrimaryPart.Velocity = Vector3.new(0,0,0)
			end

			for i,v in pairs(client.Character.Humanoid:GetPlayingAnimationTracks()) do
				v:Stop()
			end
		end
	end)

	task.spawn(function()
		for _, v in pairs(players:GetPlayers()) do
			if v ~= client and v:IsInGroup(targetgroup) then
				if v:GetRoleInGroup(targetgroup) and table.find(highrank, v:GetRoleInGroup(targetgroup)) then
					if flags.antimod then
						client.Kick(client, 'A ' .. v:GetRoleInGroup(targetgroup) .. ' was in your game. Username: ' .. v.Name)
						break
					else
						Menu.Notify('A ' .. v:GetRoleInGroup(targetgroup) .. ' is in your game. Username: ' .. v.Name)
					end
				end
			end
		end
	end)

	players.PlayerAdded:Connect(function(player)
		if player:IsInGroup(targetgroup) then
			if player:GetRoleInGroup(targetgroup) and table.find(highrank, player:GetRoleInGroup(targetgroup)) then
				if flags.antimod then
					client.Kick(client, 'A ' .. player:GetRoleInGroup(targetgroup) .. ' was in your game. Username: ' .. player.Name)
				else
					Menu.Notify('A ' .. player:GetRoleInGroup(targetgroup) .. ' has joined your game. Username: ' .. player.Name)
				end	
			end
		end
	end)
	
	userinputservice.InputBegan:Connect(function(input)
		if input.KeyCode == Enum.KeyCode['M'] then
			Menu:SetVisible(not MenuVis)
			Menu:SetVisible(not MenuVis)
			MenuVis = not MenuVis
		end
	end)

	task.spawn(function()
		while task.wait() do
			if (flags.autoroadwork or flags.job_farm or flags.autopunchingbag or flags.autocalisthenic or flags.autodura) then
				client.Character.Humanoid:ChangeState(16)

				if (client.Character and client.Character.PrimaryPart) then
					client.Character.PrimaryPart.Velocity = Vector3.new()
				end

				local char = client.Character 
				local spawnprotectionui = main_gui and main_gui:FindFirstChild('Protection')

				if (spawnprotectionui and spawnprotectionui.Visible) then
					moveto(CFrame.new(client.Character.PrimaryPart.Position.X, -23.7, client.Character.PrimaryPart.Position.Z), flags.tween_speed)
			
					game:GetService("VirtualInputManager"):SendKeyEvent(true, "W", false, game)
					task.wait()
					game:GetService("VirtualInputManager"):SendKeyEvent(false, "W", false, game)
				end

				if (char) then 
					for _, v in pairs(char:GetDescendants()) do 
						if (v:IsA('BasePart') and v.CanCollide == true) then 
							v.CanCollide = false 
						end
					end
				end

				if flags.autopunchingbag then
					if (tempadornee and not client.Character:FindFirstChild('Ragdoll') and (client.Character.Humanoid.Health / client.Character.Humanoid.MaxHealth) * 100 > 20 and client.Character:FindFirstChild('Gloves')) then
						if (playerradiuscheck(35)) then
							moveto(CFrame.new(client.Character.PrimaryPart.Position.X, -23.7, client.Character.PrimaryPart.Position.Z), flags.tween_speed)
						else
							if (tempadornee - client.Character.PrimaryPart.Position).magnitude <= 20 then
								if (not flags.downbool) then
									client.Character.PrimaryPart.CFrame = CFrame.new(tempadornee + Vector3.new(0, -5, 0), tempadornee) * CFrame.Angles(0, math.rad(--[[50]]25), math.rad(90))
								else
									client.Character.PrimaryPart.CFrame = CFrame.new(tempadornee + Vector3.new(0, -9, 0), tempadornee) * CFrame.Angles(0, math.rad(--[[50]]0), math.rad(90))
								end
							end
						end
					end

				elseif flags.job_farm then
					if client.Character and client.Character.PrimaryPart.Rotation.X < 10 and client.Character.PrimaryPart.Rotation.X > -10 then
						client.Character.PrimaryPart.CFrame = client.Character.PrimaryPart.CFrame * CFrame.Angles(math.pi, 0, 0)
					end
				end
			end
		end
	end)

	task.spawn(function()
		while task.wait() do
			if (flags.autoroadwork or flags.job_farm or flags.autopunchingbag or flags.autocalisthenic) then
				if flags.autopunchingbag then
					if (client.Character:FindFirstChild('Ragdoll') or (client.Character.Humanoid.Health / client.Character.Humanoid.MaxHealth) * 100 <= 20) then
						moveto(CFrame.new(client.Character.PrimaryPart.Position.X, -23.7, client.Character.PrimaryPart.Position.Z), flags.tween_speed)
					end
				end
			end
		end
	end)
end

Menu.Watermark:SetVisible(true)
Menu:SetTab("Main")
Menu:SetVisible(true)
Menu:Init()
