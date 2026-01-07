-- https://www.roblox.com/games/101271234790940
-- Auto Guard + Auto Green

local Players = game:GetService('Players')
local Client = Players.LocalPlayer
local PlayerGui = Client:WaitForChild('PlayerGui')
local UserInputService = game:GetService('UserInputService')

local Hoops = {}; do
	for i,v in workspace:WaitForChild('Courts'):GetDescendants() do
		if v.Name ~= 'BackboardPos' then continue end

		table.insert(Hoops, v)
	end
end

local GetChar, GetRoot, GetHum, GetDistance, GetClosestInTable, PositionBetweenTwoInstances, WalkTo; do
	GetChar = function(Player) return Player and Player.Character end
	GetRoot = function(Char) return Char and Char:FindFirstChild('HumanoidRootPart') end
	GetHum = function(Char) return Char and Char:FindFirstChildWhichIsA('Humanoid') end

	GetDistance = function(Instance, Instance2)
		local Position = typeof(Instance) == 'CFrame' and Instance.Position or typeof(Instance) == 'Instance' and Instance:GetPivot().Position or Instance
		local Position2 = typeof(Instance2) == 'CFrame' and Instance2.Position or typeof(Instance2) == 'Instance' and Instance2:GetPivot().Position or Instance2

		return Position and Position2 and vector.magnitude(Position - Position2)
	end

	GetClosestInTable = function(Tbl, MaxDistance)
		local Char = Client.Character
		local Root = GetRoot(Char)

		if Char and Root then
			local Dist, Closest = math.huge

			for i,v in Tbl or {} do
				local Distance = GetDistance(Root, v)

				if MaxDistance and Distance > MaxDistance then continue end

				if Distance < Dist then
					Dist = Distance
					Closest = v
				end
			end

			return Closest
		end
	end

	PositionBetweenTwoInstances = function(instance, instance2, distance)
		local pivot_pos, pivot_pos2 = instance:GetPivot().Position, instance2:GetPivot().Position
		local magnitude = vector.magnitude(pivot_pos - pivot_pos2)

		return (pivot_pos):Lerp(pivot_pos2, distance / magnitude)
	end

	WalkTo = function(Point)
		local Char = GetChar(Client)
		local Root = GetRoot(Char)
		local Hum = GetHum(Char)
		if not Root then return end

		local Direction = Point - Root.Position
		local PointDist = GetDistance(Point, Root)

		if PointDist < 0.1 then
			Root.AssemblyLinearVelocity = vector.zero
			Hum:Move(vector.zero)
			return
		end

		local UnitDir = vector.normalize(Direction)

		Hum:Move(Direction)
		Root.AssemblyLinearVelocity = UnitDir * 35
	end
end

shared.afy = not shared.afy
print('[afy]', shared.afy)

local OldNamecall; OldNamecall = hookmetamethod(game, '__namecall', function(...)
	local Method = getnamecallmethod()

	if Method == 'FireServer' then
		local Self, Args = select(1, ...), { select(2, ...) }

		if Self.Name == 'FinishShot' then
			Args[2] = 0.99
			return OldNamecall(Self, unpack(Args))
		end
	end

	return OldNamecall(...)
end)

while shared.afy and task.wait() do
	local Char = GetChar(Client)
	local Root = GetRoot(Char)
	local Hum = GetHum(Char)

	if not (Root and Hum) then continue end

	local IsGuarding = UserInputService:IsKeyDown('F')

	if IsGuarding then
		local ClosestHoop = GetClosestInTable(Hoops)

		if ClosestHoop then
			local Characters = {}; do
				for i,v in Players:GetPlayers() do
					if v == Client then continue end
					local PlayerChar = GetChar(v)

					if PlayerChar then
						table.insert(Characters, PlayerChar)
					end
				end
			end

			local ClosestPlayer = GetClosestInTable(Characters)

			if ClosestPlayer then
				local Point = PositionBetweenTwoInstances(ClosestPlayer, ClosestHoop, 4)

				WalkTo(Point)
			end
		end
	end
end

hookmetamethod(game, '__namecall', OldNamecall)
