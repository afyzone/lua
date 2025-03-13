local Flags = {
	Radius = 15,
}

shared.afy = not shared.afy
print(shared.afy)

if not shared.afy then return end
local Connections = {}

local Services = setmetatable({}, {
	__index = function(self, key)
		local Service = rawget(self, key) or pcall(cloneref, game:FindService(key)) and cloneref(game:GetService(key)) or Instance.new(key)
		rawset(self, key, Service)

		return rawget(self, key)
	end
})

local Players = Services.Players
local VirtualInputManager = Services.VirtualInputManager

local Client = Players.LocalPlayer
local IsBlocking, BlockId

local AttackAnims = {
	['rbxassetid://15257999438'] = 0.3,
	['rbxassetid://10329452223'] = 0.3,
	['rbxassetid://10329729708'] = 0.3,
	['rbxassetid://10299384075'] = 0.3,
	['rbxassetid://15257929575'] = 0.3,
	['rbxassetid://10299357768'] = 0.3,
	['rbxassetid://10299360808'] = 0.3,
}

local GetChar, GetRoot, Block; do
	GetChar = function(player)
		return player and player.Character
	end

	GetRoot = function(character)
		return character and character:FindFirstChild('HumanoidRootPart')
	end
  
	Block = function(enabled)
		local Char = GetChar(Client)
    
		if (Char) then
			VirtualInputManager:SendKeyEvent(enabled, 'F', false, nil)
		end
	end
end

local function CharacterAdded(player, target_char)
	if player == Client then return end

	local TargetRoot = target_char:WaitForChild("HumanoidRootPart")
	local TargetHum = target_char:WaitForChild("Humanoid")

	table.insert(Connections, TargetHum.AnimationPlayed:Connect(function(anim)
		local Char = GetChar(Client)
		local Root = GetRoot(Char)
		local AnimId = anim.Animation.AnimationId

		if Char and Root and vector.magnitude(Root.Position - TargetRoot.Position) <= Flags.Radius then
			local Combat = Char:FindFirstChild('sword')

			if Combat and AnimId and AttackAnims[AnimId] then
				if not IsBlocking then
					local InitDelay = tick()
					while (target_char:FindFirstChild('CanFeint')) do
						if (InitDelay - tick() >= AttackAnims[AnimId]) then break end
						task.wait()
					end

					if (not anim.IsPlaying) then
						return
					end

					IsBlocking = true
					Block(true)
				end

				local Id = {}
				BlockId = Id

				local InitialWait = tick()
				
				while tick() - InitialWait <= 0.2 do
					task.wait()
				end

				if BlockId == Id then
					IsBlocking = false
					Block(false)
				end
			end
		end
	end))
end

local function PlayerAdded(player)
	table.insert(Connections, player.CharacterAdded:Connect(function(char)
		CharacterAdded(player, char)
	end))

	local TargetChar = GetChar(player)

	if (TargetChar) then
		task.spawn(CharacterAdded, player, TargetChar)
	end
end

table.insert(Connections, Players.PlayerAdded:Connect(PlayerAdded))
for i,v in (Players:GetPlayers()) do
	task.spawn(PlayerAdded, v)
end

while (shared.afy) do task.wait() end

for i,v in (Connections) do
	v:Disconnect()
	v = nil
end
