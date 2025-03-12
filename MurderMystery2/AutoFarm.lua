local Services = setmetatable({}, {
	__index = function(self, key)
		local Service = pcall(cloneref, game:FindService(key)) and cloneref(game:GetService(key)) or Instance.new(key)
		rawset(self, key, Service)

		return rawget(self, key)
	end
})

local Stats = Services.Stats
local Players = Services.Players

local Client = Players.LocalPlayer
local PlayerGui = Client:WaitForChild('PlayerGui')

getconnections(Client.Idled)[1]:Disable()

local Flags = {
	AutoCoins = true,
	TweenSpeed = 0.4,
}

local HiddenFlags = {
	GunDebounce = 0,
	CachedCoins = setmetatable({}, { __mode = "kv" })
}

local GetChar, GetHum, GetRoot, GetBackpack, GetRole, TeleportTo, MoveTo, SmartWait, GetMap, GetClosestCoin, SmartGet, IsBagFull; do
	GetChar = function(player)
		return player and player.Character
	end

	GetRoot = function(character)
		return character and character:FindFirstChild('HumanoidRootPart')
	end

	GetHum = function(character)
		return character and character:FindFirstChildWhichIsA('Humanoid')
	end

	GetBackpack = function(player)
		return player and player:FindFirstChildWhichIsA('Backpack')
	end

	TeleportTo = function(pos)
		local Char = GetChar(Client)
		local Root = GetRoot(Char)

		if (Char and Root) then
			Root.CFrame = pos
		end
	end

	MoveTo = function(pos, increment)
		if (HiddenFlags.CurrentlyMoving) then return end
		HiddenFlags.CurrentlyMoving = true

		local Char = GetChar(Client)
		local Root = GetRoot(Char)
		local Increment = increment or 5

		if (Char and Root) then
			local Distance = vector.magnitude(pos - Root.Position)
			local Direction = vector.normalize(pos - Root.Position)
			local CurrentPos = Root.Position

			while (Distance > Increment) do
				CurrentPos += Direction * Increment
				Root.CFrame = CFrame.new(CurrentPos)
				Root.AssemblyLinearVelocity = vector.zero

				SmartWait()
				Distance = vector.magnitude(pos - CurrentPos)
			end
			Root.CFrame = CFrame.new(pos)
		end

		HiddenFlags.CurrentlyMoving = false
	end

	SmartWait = function(_delay, flags_key)
		local Char = GetChar(Client)
		local Root = GetRoot(Char)
		local StartTime = tick()

		if (Char and Root) then
			local InitCFrame = Root.CFrame

			while (Char and Root and (not flags_key or Flags[flags_key]) and tick() - StartTime <= (_delay or 1/60)) do
				task.wait(1/60)

				Root.CFrame = InitCFrame
				Root.AssemblyLinearVelocity = vector.zero

				for _, v in (Char:GetDescendants()) do
					if (v:IsA('BasePart')) then
						v.CanCollide = false
					end
				end
			end
		end
	end

	GetMap = function()
		for i,v in (workspace:GetChildren()) do
			if (not v:FindFirstChild('CoinContainer')) then continue end
			return v
		end
	end

	GetClosestCoin = function(Map, Range)
		local Char = GetChar(Client)
		local Root = GetRoot(Char)

		local Dist, InRange, Closest = math.huge, {}

		if (Char and Root and Map) then
			for i,v in (Map.CoinContainer:GetChildren()) do
				if (not (v:FindFirstChildWhichIsA('TouchTransmitter') and v:FindFirstChild('CoinVisual'))) then continue end

				local CoinMagnitude = vector.magnitude(Root.Position - v:GetPivot().Position)

				if (Range and CoinMagnitude <= Range) then
					table.insert(InRange, v)
				end

				if (CoinMagnitude < Dist and not HiddenFlags.CachedCoins[v]) then
					Dist = CoinMagnitude
					Closest = v
				end
			end
		end

		if (Range) then
			return InRange
		end

		return Closest
	end

	GetRole = function(player)
		local Char = GetChar(player)
		local Backpack = GetBackpack(player)

		if (Backpack) then
			for i,v in (Backpack:GetChildren()) do
				if (v:IsA('Tool') and v.Name == 'Knife' or v.Name == 'Gun') then
					return v.Name
				end
			end
		end

		if (Char) then
			for i,v in (Char:GetChildren()) do
				if (v:IsA('Tool') and v.Name == 'Knife' or v.Name == 'Gun') then
					return v.Name
				end
			end
		end
	end

	SmartGet = function(obj, ...)
		local path = {...}

		for i, v in (path) do
			if (not obj) then return end

			obj = obj:FindFirstChild(v)
		end

		return obj
	end

	IsBagFull = function()
		local FullBagIcon = SmartGet(PlayerGui, 'MainGUI', 'Game', 'CoinBags', 'Container', 'Coin', 'FullBagIcon')

		return FullBagIcon and FullBagIcon.Visible
	end
end

shared.afy = not shared.afy
print(shared.afy)

while (shared.afy and task.wait()) do
	if (PlayerGui.MainGUI.Game.Waiting.Visible) then continue end

	local Map = GetMap()

	if (Map) then
		local FullBag = IsBagFull()

		if (FullBag or not Flags.AutoCoins) then
			local GameInfo = {}

			for i,v in (Players:GetPlayers()) do
				local Role = GetRole(v)

				if (Role) then
					GameInfo[Role] = v
				end
			end

			if (GameInfo['Knife'] == Client) then
				local Char = GetChar(GameInfo['Knife'])
				local Hum = GetHum(Char)

				if (Char and Hum) then
					Hum.Health = 0
				end

			elseif (GameInfo['Gun'] == Client) then
				local Char = GetChar(GameInfo['Gun'])
				local TargetChar = GetChar(GameInfo['Knife'])

				local Root = GetRoot(Char)
				local TargetRoot = GetRoot(TargetChar)

				local Hum = GetHum(Char)

				if (Char and Hum and Root and TargetChar and TargetRoot) then
					local ClientGun = Client.Backpack:FindFirstChild('Gun')

					if (ClientGun) then
						Hum:EquipTool(ClientGun)
					end

					local Gun = Char:FindFirstChild('Gun')

					if (tick() - HiddenFlags.GunDebounce > 3) then
						if (Gun) then
							Gun.Handle.CFrame = CFrame.new(TargetRoot.Position + vector.create(0, -1.5, 0), TargetRoot.Position)

							SmartWait(0.2)

							local GunRemote = SmartGet(Char, "Gun", "KnifeLocal", "CreateBeam", "RemoteFunction")

							if (GunRemote) then
								task.spawn(GunRemote.InvokeServer, GunRemote, 1, TargetRoot.Position + TargetRoot.AssemblyLinearVelocity * vector.create(0.1, 0, 0.1), "AH2")
								HiddenFlags.GunDebounce = tick()
							end
						end
					else
						Root.CFrame = CFrame.new(TargetRoot.Position + vector.create(0, -50, 0), TargetRoot.Position)
					end
				end
			else
				local DroppedGun = Map:FindFirstChild('GunDrop')

				if (DroppedGun and DroppedGun:FindFirstChildWhichIsA('TouchTransmitter')) then
					local GunPivot = DroppedGun:GetPivot()
					TeleportTo(CFrame.new(GunPivot.X, GunPivot.Y - 50, GunPivot.Z))

					if (DroppedGun:FindFirstChildWhichIsA('TouchTransmitter')) then
						SmartWait(1)
						TeleportTo(GunPivot)
					end

				else
					TeleportTo(workspace.Lobby.Spawns.Spawn.CFrame + vector.create(0, 2.8, 0))
				end
			end

		elseif (Flags.AutoCoins) then
			local Coin = GetClosestCoin(Map)
			local Char = GetChar(Client)
			local Root = GetRoot(Char)

			if (Char and Root and Coin) then
				local CoinPivot = Coin:GetPivot()

				if (vector.magnitude(CoinPivot.Position - Root.Position) > 500) then
					TeleportTo(CFrame.new(CoinPivot.X, CoinPivot.Y - 50, CoinPivot.Z))
				end

				if (Coin:FindFirstChildWhichIsA('TouchTransmitter')) then
					MoveTo(vector.create(CoinPivot.X, CoinPivot.Y - 5, CoinPivot.Z), Flags.TweenSpeed)

					local Coins = GetClosestCoin(Map, 7)

					for i,v in (Coins) do
						HiddenFlags.CachedCoins[v] = true
						v:PivotTo(Char.Head.CFrame)
					end
				end
			else
				TeleportTo(workspace.Lobby.Spawns.Spawn.CFrame + vector.create(0, 2.8, 0))
			end
		end
	end
end
