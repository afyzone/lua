-- https://www.roblox.com/games/87700573492940/
-- Features: Auto Drill, Auto Sell, Auto Collect, Auto Buy Best Hand Drill

local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Client = Players.LocalPlayer
local PlayerGui = Client:WaitForChild('PlayerGui')

local Plot = nil
local HiddenFlags = {
    SellDebounce = 0
}

for i,v in workspace.Plots:GetChildren() do
    if (v.Owner.Value == Client) then
        Plot = v
        break
    end
end

assert(Plot, 'My plot was not found')

local GetChar = function(player)
    return player and player.Character
end

local GetRoot = function(char)
    return char and char:FindFirstChild('HumanoidRootPart')
end

local Sell = function(all)
    local Char = GetChar(Client)
    local Root = GetRoot(Char)

    if (all) then
        local OrigPosition = Root and Root.CFrame

        if (Root) then
            Root.CFrame = CFrame.new(vector.create(-410, 80, 261))
        end

        task.delay(0.2, function()
            ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("OreService"):WaitForChild("RE"):WaitForChild("SellAll"):FireServer()
            
            local Char = GetChar(Client)
            local Root = GetRoot(Char)

            if (Root and OrigPosition) then
                Root.CFrame = OrigPosition
            end
        end)
    end
end

local GetHandDrill = function()
    for i,v in (Client.Backpack:GetChildren()) do
        if (v:IsA('Tool') and v:GetAttribute('Type') == 'HandDrill') then
            return v
        end
    end

    local Char = GetChar(Client)

    if (Char) then
        for i,v in (Char:GetChildren()) do
            if (v:IsA('Tool') and v:GetAttribute('Type') == 'HandDrill') then
                return v
            end
        end
    end
end

shared.afy = not shared.afy
print(shared.afy)

while shared.afy and task.wait(1/30) do
    local Char = GetChar(Client)
    local Root = GetRoot(Char)

    -- Auto Drill
    if (Char and Char:FindFirstChildWhichIsA('Tool')) then
        ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("OreService"):WaitForChild("RE"):WaitForChild("RequestRandomOre"):FireServer()
    end

    -- Auto Sell
    if (tick() - HiddenFlags.SellDebounce > 10) then
        Sell(true)

        HiddenFlags.SellDebounce = tick()
    end

    -- Collect Placed Drills
    for i,v in (Plot.Drills:GetChildren()) do
        if (not v:FindFirstChild('DrillData') or v.DrillData.Drilling.Value) then continue end

        ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("PlotService"):WaitForChild("RE"):WaitForChild("CollectDrill"):FireServer(v)
    end


    -- Buy Best Hand Drill
    local CurrentHandDrill = GetHandDrill()

    for i,v in (CurrentHandDrill and PlayerGui.Menu.CanvasGroup.HandDrills.Background.HandDrillList:GetChildren() or {}) do
        if (not v:IsA('Frame')) then continue end
        if (v.RebirthNeeded.Visible) then continue end
        
        local Cost = tonumber(string.match(v.Buy.TextLabel.Text:gsub(',', ''), "(%d+)"))

        if (Client.leaderstats.Cash.Value >= Cost and Cost > CurrentHandDrill:GetAttribute('Cost')) then
            ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("OreService"):WaitForChild("RE"):WaitForChild("BuyHandDrill"):FireServer(v.Title.Text)
        end
    end

    -- Equip Drill
    for i,v in (Char and Client.Backpack:GetChildren() or {}) do
        if (v:IsA('Tool') and v:GetAttribute('Type') == 'HandDrill') then
            v.Parent = Char
        end
    end
end
