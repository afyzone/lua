local Services = setmetatable({}, {
	__index = function(self, key)
		local Service = pcall(cloneref, game:FindService(key)) and cloneref(game:GetService(key)) or Instance.new(key)
		rawset(self, key, Service)

		return rawget(self, key)
	end
})

local Players = Services.Players

local Client = Players.LocalPlayer
local PlayerGui = Client:WaitForChild('PlayerGui')

local Flags = {
	AutoCoins = true
}

local HiddenFlags = {
	GunDebounce = 0,
}

local GetChar, GetHum, GetRoot, GetBackpack, GetRole, MoveTo, SmartWait, GetMap, GetClosestCoin, IsBagFull; do
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

	MoveTo = function(pos)
		local Char = GetChar(Client)
		local Root = GetRoot(Char)

		if (Char and Root) then
			Root.CFrame = pos
		end
	end

	SmartWait = function(_delay, flags_key)
		local Char = GetChar(Client)
		local Root = GetRoot(Char)
		local StartTime = tick()

		if (Char and Root) then
			local InitCFrame = Root.CFrame

			while (Char and Root and (not flags_key or Flags[flags_key]) and tick() - StartTime <= (_delay or 0)) do
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

	GetClosestCoin = function(Map)
		local Char = GetChar(Client)
		local Root = GetRoot(Char)

		if (not Root) then return end

		local Dist, Closest = math.huge

		for i,v in (Map.CoinContainer:GetChildren()) do
			if (not (v:FindFirstChildWhichIsA('TouchTransmitter') and v:FindFirstChild('CoinVisual'))) then continue end
			local CoinMagnitude = vector.magnitude(Root.Position - v:GetPivot().Position)

			if (CoinMagnitude < Dist) then
				Dist = CoinMagnitude
				Closest = v
			end
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

	IsBagFull = function()
		return PlayerGui:FindFirstChild('MainGUI') and
			PlayerGui.MainGUI:FindFirstChild('Game') and
			PlayerGui.MainGUI.Game:FindFirstChild('CoinBags') and
			PlayerGui.MainGUI.Game.CoinBags:FindFirstChild('Container') and
			PlayerGui.MainGUI.Game.CoinBags.Container:FindFirstChild('Coin') and
			PlayerGui.MainGUI.Game.CoinBags.Container.Coin:FindFirstChild('FullBagIcon') and
			PlayerGui.MainGUI.Game.CoinBags.Container.Coin.FullBagIcon.Visible
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

					Root.CFrame = CFrame.new(TargetRoot.Position + vector.create(0, -2, 0), TargetRoot.Position)

					if (tick() - HiddenFlags.GunDebounce > 1) then
						SmartWait(0.2)
						local GunRemote = Char["Gun"]["KnifeLocal"]["CreateBeam"]["RemoteFunction"]

						task.spawn(GunRemote.InvokeServer, GunRemote, 1, TargetRoot.Position + TargetRoot.AssemblyLinearVelocity * 0.1, "AH2")
						HiddenFlags.GunDebounce = tick()
					end
				end
			else
				local DroppedGun = Map:FindFirstChild('GunDrop')

				if (DroppedGun and DroppedGun:FindFirstChildWhichIsA('TouchTransmitter')) then
					local GunPivot = DroppedGun:GetPivot()
					MoveTo(CFrame.new(GunPivot.X, GunPivot.Y - 50, GunPivot.Z))

					if (DroppedGun:FindFirstChildWhichIsA('TouchTransmitter')) then
						SmartWait(1.5)
						MoveTo(GunPivot)
					end

				else
					MoveTo(workspace.Lobby.Spawns.Spawn.CFrame + vector.create(0, 2.8, 0))
				end
			end
		elseif (Flags.AutoCoins) then
			local Coin = GetClosestCoin(Map)

			if (Coin) then
				local CoinPivot = Coin:GetPivot()

				MoveTo(CFrame.new(CoinPivot.X, CoinPivot.Y - 50, CoinPivot.Z))

				if (Coin:FindFirstChildWhichIsA('TouchTransmitter')) then
					SmartWait(1.5)
					MoveTo(CoinPivot)
					SmartWait(0.1)
					MoveTo(CFrame.new(CoinPivot.X, CoinPivot.Y - 5, CoinPivot.Z))
					SmartWait(0.1)
				end
			else
				MoveTo(workspace.Lobby.Spawns.Spawn.CFrame + vector.create(0, 2.8, 0))
			end
		end
	end
end
