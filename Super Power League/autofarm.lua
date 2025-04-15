-- https://www.roblox.com/games/137681066791460

local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Client = Players.LocalPlayer
local PlayerGui = Client:WaitForChild('PlayerGui')
local Icons = {
	['rbxassetid://94814792785652'] = 'Power',
	['rbxassetid://134317346328662'] = 'Health',
	['rbxassetid://126277523665080'] = 'Defense',
	['rbxassetid://128337057508912'] = 'Psychics',
	['rbxassetid://104195452885717'] = 'Magic',
}

getconnections(Client.Idled)[1]:Disconnect()

local Hooks = loadstring(game:HttpGet('https://raw.githubusercontent.com/afyzone/lua/refs/heads/main/%23Libraries/HookHandler/HookHandler.lua'))()
namecall = function(...)
	local Method = Hooks.getnamecallmethod()

	if (Method == 'FireServer' and select(1, ...) == ReplicatedStorage.Events.Rejoin) then return end

	return ...
end

shared.afy = not shared.afy
print(shared.afy)

local GetChar, GetRoot, GetStat, ConvertReqText, GetTrainingPart, GetTask; do
	GetChar = function(player)
		return player and player.Character
	end

	GetRoot = function(char)
		return char and char:FindFirstChild('HumanoidRootPart')
	end

	GetStat = function(Type)
		return ReplicatedStorage.Data[Client.Name].Stats[Type].Value
	end
	
	ConvertReqText = function(ReqText)
		local Cleaned = ReqText:gsub("REQ", ""):gsub(',', ''):gsub("%s", "")
		local NumStr = Cleaned:match("^[%d%.]+")
	
		if not NumStr then return end
	
		local Suffix = Cleaned:sub(#NumStr + 1)
		local Number = tonumber(NumStr)
	
		if not Number then return end
	
		Suffix = Suffix:upper()
	
		local Multipliers = {
			M  = 1e6,
			B  = 1e9,
			T  = 1e12,
			QD = 1e15
		}
	
		if (Suffix ~= "") then
			if Multipliers[Suffix] then
				Number *= Multipliers[Suffix]
			else
				local Sfx2 = Suffix:sub(1,2)
	
				if (Multipliers[Sfx2]) then
					Number *= Multipliers[Sfx2]
	
				else
					local Sfx1 = Suffix:sub(1,1)
	
					if (Multipliers[Sfx1]) then
						Number *= Multipliers[Sfx1]
					end
				end
			end
		end
	
		return Number
	end

	GetTrainingPart = function(Type)
		local TrainingType = workspace.TrainingInterface:FindFirstChild(Type)
		local MyStat = GetStat(Type)
		local BestValue, BestInstance = 0
	
		for _, v in (TrainingType:GetChildren()) do
			local TrainUi = v:FindFirstChild("TrainUi")
	
			if (TrainUi and TrainUi:FindFirstChild("Frame")) then
				local Frame = TrainUi.Frame
	
				if (Frame:FindFirstChild("Req") and Frame.Req:IsA("TextLabel")) then
					local ReqText = Frame.Req.Text
					local ReqNumber = ConvertReqText(ReqText)
	
					if (ReqNumber and ReqNumber <= MyStat and ReqNumber > BestValue) then
						BestValue = ReqNumber
						BestInstance = v
					end
				end
			end
		end
	
		return BestInstance
	end

	GetTask = function()
		local Task = PlayerGui.HUD.RightUi.Tasks.Tasks.TaskList.TaskList:FindFirstChild("1")
	
		for i,v in (Task and Task:GetChildren() or {}) do
			if (not v:IsA('Frame')) then continue end
			local Icon = v:FindFirstChild('Icon')
			local Progress = v:FindFirstChild('Progress')
	
			if (Icon and Progress) then
				local Bar = Progress:FindFirstChild('Bar')
				if (Bar) then
					if (Bar.BackgroundColor3 == Color3.fromRGB(0, 175, 0)) then continue end
	
					return Icons[Icon.Image]
				end
			end
		end
	end
end

while shared.afy and task.wait() do
	local Upgrade = GetTask()
	local Char = GetChar(Client)
	local Root = GetRoot(Char)

	if (Upgrade) then
		local TrainingPart = GetTrainingPart(Upgrade)

		if (TrainingPart and Root) then
			Root.CFrame = TrainingPart.CFrame + vector.create(0, -2, 0)
		end

		if (Upgrade == 'Power') then
			ReplicatedStorage:WaitForChild("Events"):WaitForChild("Train"):WaitForChild("TrainPower"):FireServer(TrainingPart and tonumber(TrainingPart.Name) or 0)
		end

		if (Upgrade == 'Health') then
			ReplicatedStorage:WaitForChild("Events"):WaitForChild("Train"):WaitForChild("TrainHealth"):FireServer(TrainingPart and tonumber(TrainingPart.Name) or 0)
		end

		if (Upgrade == 'Defense') then
			ReplicatedStorage:WaitForChild("Events"):WaitForChild("Train"):WaitForChild("TrainDefense"):FireServer(TrainingPart and tonumber(TrainingPart.Name) or 0)
		end

		if (Upgrade == 'Psychics') then
			ReplicatedStorage:WaitForChild("Events"):WaitForChild("Train"):WaitForChild("TrainPsychics"):FireServer(TrainingPart and tonumber(TrainingPart.Name) or 0)
		end

		if (Upgrade == 'Magic') then
			ReplicatedStorage:WaitForChild("Events"):WaitForChild("Train"):WaitForChild("TrainMagic"):FireServer(TrainingPart and tonumber(TrainingPart.Name) or 0)
		end
	end

	ReplicatedStorage:WaitForChild("Events"):WaitForChild("Other"):WaitForChild("EquipWeight"):FireServer(true)
	ReplicatedStorage:WaitForChild("Events"):WaitForChild("Train"):WaitForChild("TrainMobility"):FireServer()
	ReplicatedStorage:WaitForChild("Events"):WaitForChild("Other"):WaitForChild("StartMainTask"):FireServer("MainTask")
	ReplicatedStorage:WaitForChild("Events"):WaitForChild("Other"):WaitForChild("ClaimMainTask"):FireServer(1)
end
