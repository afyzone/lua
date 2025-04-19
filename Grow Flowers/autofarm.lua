-- https://www.roblox.com/games/110404078250920/

local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Client = Players.LocalPlayer
local PlayerGui = Client:WaitForChild('PlayerGui')

getconnections(Client.Idled)[1]:Disconnect()

shared.afy = not shared.afy
print(shared.afy)

local MyFarm; do 
	for i,v in (workspace.Plots:GetChildren()) do
		if (v:GetAttribute('Owner') == Client.Name) then
			MyFarm = v
		end
		
		if MyFarm then break end 
	end
end

assert(MyFarm, 'My farm was not found.')

local GetChar, GetRoot, GetBackpack, GetAffordableSeed, GetSellable, GetOwnedSeed, GetRandomCFrameOnPart; do
	GetChar = function(player)
		return player and player.Character
	end

	GetBackpack = function(player)
		return player and player:FindFirstChildWhichIsA('Backpack')
	end

	GetRoot = function(char)
		return char and char:FindFirstChild('HumanoidRootPart')
	end

	GetAffordableSeed = function()
		local SeedShop = PlayerGui.MainHUD.SeedShop.Seeds
		local MyMoney = Client.leaderstats.Credits.Value
		
		local HighestCost, BestSeed = 0
	
		for _, SeedItem in (SeedShop:GetChildren()) do
			if (SeedItem:IsA("Frame")) then
				local CostLabel = SeedItem.Buttons.Coins.Label
				local CostText = CostLabel and CostLabel.Text

				if (CostText and CostText ~= 'NO STOCK') then
					local CostValue = tonumber(string.match(CostText, "(%d+)"))

					if (CostValue and MyMoney >= CostValue and CostValue > HighestCost) then
						HighestCost = CostValue
						BestSeed = SeedItem.Holder.SeedLabel.Text
					end
				end
			end
		end
	
		return BestSeed
	end

	GetOwnedSeed = function()
		local Char = GetChar(Client)
	
		for i,v in (Char and Char:GetChildren() or {}) do
			if (v:IsA('Tool') and v:GetAttribute('Type') == 'SeedTool') then
				return v
			end
		end
	
		local Backpack = GetBackpack(Client)
	
		for i,v in (Char and Backpack and Backpack:GetChildren() or {}) do
			if (v:IsA('Tool') and v:GetAttribute('Type') == 'SeedTool') then
				v.Parent = Char
				return v
			end
		end
	end

	GetSellable = function()
		local Backpack = GetBackpack(Client)
	
		for i,v in (Backpack and Backpack:GetChildren() or {}) do
			if (v:IsA('Tool') and v:GetAttribute('Type') == 'Flower') then
				return true
			end
		end
	end
	
	GetRandomCFrameOnPart = function()
		local Locations = MyFarm.Ground:GetChildren()
		local Part = Locations[math.random(1, #Locations)]
		
		local RandomOffset = vector.create(
			(math.random() - 0.5) * Part.Size.X,
			(math.random() - 0.5) * Part.Size.Y,
			(math.random() - 0.5) * Part.Size.Z
		)
		
		return CFrame.new(Part.CFrame:PointToWorldSpace(RandomOffset))
	end
end

for i,v in (workspace.FloatingIsland:GetChildren()) do
	if (not v:FindFirstChild('Texture')) then continue end

	v.CanCollide = false
end

while shared.afy and task.wait() do
	local Seed = GetOwnedSeed()
	local Char = GetChar(Client)
	local Root = GetRoot(Char)

	if (Seed) then
		local CFramePlanted = GetRandomCFrameOnPart()

		if (CFramePlanted) then
			ReplicatedStorage:WaitForChild("Events"):WaitForChild("Client"):WaitForChild("PlaceRequest"):FireServer(CFramePlanted, Seed)
		end
	else
		local AffordableSeed = GetAffordableSeed()

		if (AffordableSeed) then
			ReplicatedStorage:WaitForChild("Events"):WaitForChild("Client"):WaitForChild("RequestBuy"):InvokeServer(AffordableSeed, "Seed")
		end
	end

	for i,v in (Root and MyFarm.Flowers:GetDescendants() or {}) do
		if (not v:IsA('ProximityPrompt')) then continue end

		Root.CFrame = CFrame.new(v.Parent:GetPivot().Position + vector.create(0, -6, 0))
		fireproximityprompt(v)
	end

	local SellFlag = GetSellable()

	if (SellFlag) then
		ReplicatedStorage:WaitForChild("Events"):WaitForChild("Client"):WaitForChild("RequestSell"):InvokeServer(true)
	end
end

for i,v in (workspace.FloatingIsland:GetChildren()) do
	if (not v:FindFirstChild('Texture')) then continue end

	v.CanCollide = true
end
