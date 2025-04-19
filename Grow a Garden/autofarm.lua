-- https://www.roblox.com/games/126884695634066/

local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Client = Players.LocalPlayer
local PlayerGui = Client:WaitForChild('PlayerGui')

shared.afy = not shared.afy
print(shared.afy)

local MyFarm; do 
    for i,v in (workspace.Farm:GetChildren()) do
        if (v.Important.Data.Owner.Value == Client.Name) then
            MyFarm = v
        end
        
        if MyFarm then break end 
    end
end

assert(MyFarm, 'My farm was not found.')

local GetChar, GetRoot, GetBackpack, GetAffordableSeed, GetSellable, GetOwnedSeed, GetRandomPositionOnPart; do
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
        local SeedShop = PlayerGui.Seed_Shop.Frame.ScrollingFrame
        local MyMoney = Client.leaderstats.Sheckles.Value
    
        local HighestCost, BestSeed = 0
    
        for _, SeedItem in (SeedShop:GetChildren()) do
            if (SeedItem:IsA("Frame")) then
                local MainFrame = SeedItem:FindFirstChild("Main_Frame")

                if (MainFrame) then
                    local StockLabel = MainFrame:FindFirstChild("Stock_Text")
                    
                    if (StockLabel) then
                        local InStock = SeedItem.Frame.Sheckles_Buy.In_Stock
    
                        if (InStock and InStock.Visible) then
                            local CostLabel = InStock:FindFirstChild("Cost_Text")

                            if (CostLabel) then
                                local CostText = CostLabel.Text
                                local CostValue = tonumber(string.match(CostText, "(%d+)"))

                                if (CostValue and MyMoney >= CostValue and CostValue > HighestCost) then
                                    HighestCost = CostValue
                                    BestSeed = SeedItem.Name
                                end
                            end
                        end
                    end
                end
            end
        end
    
        return BestSeed
    end

    GetOwnedSeed = function()
        local Char = GetChar(Client)
    
        for i,v in (Char and Char:GetChildren() or {}) do
            if (v:IsA('Tool') and v:FindFirstChild('Plant_Name')) then
                return v.Plant_Name.Value
            end
        end
    
        local Backpack = GetBackpack(Client)
    
        for i,v in (Char and Backpack and Backpack:GetChildren() or {}) do
            if (v:IsA('Tool') and v:FindFirstChild('Plant_Name')) then
                v.Parent = Char
                return v.Plant_Name.Value
            end
        end
    end

    GetSellable = function()
        local Backpack = GetBackpack(Client)
    
        for i,v in (Backpack and Backpack:GetChildren() or {}) do
            if (v:IsA('Tool') and v:GetAttribute('WeightMulti')) then
                return true
            end
        end
    end
    
    GetRandomPositionOnPart = function()
        local Locations = MyFarm.Important.Plant_Locations:GetChildren()
        local Part = Locations[math.random(1, #Locations)]
        
        local RandomOffset = vector.create(
            (math.random() - 0.5) * Part.Size.X,
            (math.random() - 0.5) * Part.Size.Y,
            (math.random() - 0.5) * Part.Size.Z
        )
        
        return Part.CFrame:PointToWorldSpace(RandomOffset)
    end
end

for i,v in (workspace:GetChildren()) do
    if (not v:IsA('BasePart')) then continue end

    v.CanCollide = false
end

while shared.afy and task.wait() do
    local Seed = GetOwnedSeed()
    local Char = GetChar(Client)
    local Root = GetRoot(Char)

    if (Root) then
        Root.AssemblyLinearVelocity = vector.zero
    end

    if (Seed and Root) then
        local PositionPlanted = GetRandomPositionOnPart()

        Root.CFrame = CFrame.new(PositionPlanted + vector.create(0, -5, 0))
        task.wait(0.2)
        ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Plant_RE"):FireServer(PositionPlanted, Seed)
    else
        local AffordableSeed = GetAffordableSeed()

        if (AffordableSeed) then
            ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuySeedStock"):FireServer(AffordableSeed)
            task.wait(0.2)
        end
    end

    for i,v in (MyFarm.Important.Plants_Physical:GetDescendants()) do
        if (not v:IsA('ProximityPrompt')) then continue end
        
        if (Root) then
            Root.CFrame = CFrame.new(v.Parent:GetPivot().Position + vector.create(0, -6, 0))
            fireproximityprompt(v)
        end
    end

    local SellFlag = GetSellable()

    if (SellFlag and Root) then
        Root.CFrame = CFrame.new(62, -4, -0.6)
        task.wait(0.2)
        ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Sell_Inventory"):FireServer()
    end
end

for i,v in (workspace:GetChildren()) do
    if (not v:IsA('BasePart')) then continue end

    v.CanCollide = true
end
