local Flags = {
	Radius = 15,
}

shared.afy = not shared.afy
print(shared.afy)
if (not shared.afy) then return end

local Connections = setmetatable({}, { __mode = 'kv' })
local CharacterCons = setmetatable({}, { __mode = 'kv' })

local Services = setmetatable({}, {
	__index = function(self, key)
		local Service = rawget(self, key) or pcall(cloneref, game:FindService(key)) and cloneref(game:GetService(key)) or Instance.new(key)
		rawset(self, key, Service)

		return rawget(self, key)
	end
})

local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local VirtualInputManager = Services.VirtualInputManager

local Client = Players.LocalPlayer
local IsBlocking, BlockId
local AttackAnims = {}

for _, obj in (ReplicatedStorage.ReplicatedModules.ModuleListFei.EffectModuleMain.ClientAnimations:GetDescendants()) do
	if (not obj:IsA("Animation")) then continue end

	if (obj.Name:find("Swing") or obj.Name:find('Attack') or obj.Name:find('Uppercut') or obj.Name:find('Critical')) then
		AttackAnims[obj.AnimationId] = true
	end
end

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

local function CharacterAdded(target_char)
	if (CharacterCons[target_char]) then return end
	CharacterCons[target_char] = true

	local Player = Players:GetPlayerFromCharacter(target_char)
	if (Player and Player == Client) then return end

	local TargetRoot = target_char:WaitForChild("HumanoidRootPart")
	local TargetHum = target_char:WaitForChild("Humanoid")

	table.insert(Connections, TargetHum.AnimationPlayed:Connect(function(anim)
		local Char = GetChar(Client)
		local Root = GetRoot(Char)
		local AnimId = anim.Animation.AnimationId

		if (Char and Root and vector.magnitude(Root.Position - TargetRoot.Position) <= Flags.Radius) then
			local Combat = true

			if (Combat and AnimId and AttackAnims[AnimId]) then
				if (not IsBlocking) then
					while (anim.TimePosition / anim.Length * 100 < 50) do
						task.wait()
					end

					if (not anim.IsPlaying) then return end

					IsBlocking = true
					Block(IsBlocking)
				end

				local Id = {}
				BlockId = Id

				task.wait(0.2)

				if (BlockId == Id) then
					IsBlocking = false
					Block(IsBlocking)
				end
			end
		end
	end))
end

local function CharacterRemoved(target_char)
	CharacterCons[target_char] = nil
end

local function PlayerAdded(player)
	table.insert(Connections, player.CharacterAdded:Connect(CharacterAdded))

	local TargetChar = GetChar(player)

	if (TargetChar) then
		task.spawn(CharacterAdded, TargetChar)
	end
end

table.insert(Connections, Players.PlayerAdded:Connect(PlayerAdded))
table.insert(Connections, workspace.Entities.ChildAdded:Connect(CharacterAdded))
table.insert(Connections, workspace.Entities.ChildRemoved:Connect(CharacterRemoved))

for i,v in (Players:GetPlayers()) do
	task.spawn(PlayerAdded, v)
end

while (shared.afy) do task.wait() end

for i,v in (Connections) do
	v:Disconnect()
	v = nil
end

for i,v in (CharacterCons) do
	i = nil
	v = nil
end
