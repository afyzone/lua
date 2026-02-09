local Flags = {}
local HiddenFlags = {}

local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local TeleportService = game:GetService('TeleportService')
local Client = Players.LocalPlayer
local PlayerGui = Client:WaitForChild('PlayerGui')
local Network = require(ReplicatedStorage.Modules.Library.Network)
local WorldData, Connections = {
    ['Time Chamber'] = 1362482151,
    ['Gravity Chamber'] = 3371469539,
    ['Hell'] = 15669378828,
    ['Beerus Planet'] = 3336119605
}, {}

shared.afy = not shared.afy
print('[afy]', shared.afy)

local GetRoot; do
    GetRoot = function(Character) return Character and Character:FindFirstChild('HumanoidRootPart') end

    GetEnergyPercent = function()
        local Character = Client.Character
        local State = Character and Character:FindFirstChild('State')
        
        if State then
            local Energy = State:FindFirstChild('Energy')
            local MaxEnergy = State:FindFirstChild('MaxEnergy')

            if Energy and MaxEnergy then
                return (Energy.Value / MaxEnergy.Value) * 100
            end
        end
    end

    GetBestTraining = function()
        for Index, Training in PlayerGui.PlayerInterface.Center.Zenkai.Container.Progress:GetChildren() do
            if not Training:IsA('Frame') then continue end

            local Progress = Training.Bar.Slider.Size.X.Scale
            if Progress == 1 then continue end

            local Name = Training.Name:gsub('Bar', '')
            return Name
        end
    end

    GetStatInfo = function()
        local Stats = Client:FindFirstChild('Stats')

        if Stats then
            return Stats.Agility.Value, Stats.Attack.Value, Stats.Defense.Value, Stats.Ki.Value
        end
    end

    GetZenkai = function()
        return Client.leaderstats["Zenkai Boosts"].Value
    end

    Charge = function(Bool)
        if Bool then
            Network:InvokeServer("ChargeEnergy", true)
        else
            Network:FireServer("ChargeEnergy", false)
        end
    end

    GetOptimalWorld = function(Training)
        if Training == "Agility" or Training == "Attack" then
            return Zenkai >= 5 and "Gravity Chamber" or "Time Chamber"

        elseif Training == "Defense" or Training == "Ki" then
            return Zenkai >= 5 and "Beerus Planet" or Zenkai >= 3 and "Hell" or "Time Chamber"
        end
    end
end

for Index, Connection in getconnections(Client.Idled) do
    Connection:Disconnect()
end

table.insert(Connections, Client.OnTeleport:Connect(function()
    queue_on_teleport([[
        if afy then return end getgenv().afy = true
        loadstring(game:HttpGet('https://raw.githubusercontent.com/afyzone/lua/refs/heads/main/Dragon%20Ball%20Rage/AutoFarm.lua'))()
    ]])
end))

while shared.afy and task.wait() do
    local Character = Client.Character
    local Root = GetRoot(Character)
    if not Root then continue end

    if not HiddenFlags.OriginalCFrame then HiddenFlags.OriginalCFrame = Root.CFrame end
    Root.CFrame = CFrame.new(0, 10000, 0)

    local BestTraining = GetBestTraining()
    if not BestTraining then
        Network:InvokeServer("RequestZenkaiBoost")
        task.wait(2)
        continue
    end

    local Zenkai = GetZenkai()
    local EnergyPercent = GetEnergyPercent()
    local Agility, Attack, Defense, Ki = GetStatInfo()
    local TimeChamberThreshold = 1250000
    local CanTimeChamber = Agility >= TimeChamberThreshold and Attack >= TimeChamberThreshold and Defense >= TimeChamberThreshold and Ki >= TimeChamberThreshold
    local AgilityAttackPair = (BestTraining == "Agility" or BestTraining == "Attack")
    local DefenceKiPair  = (BestTraining == "Defense" or BestTraining == "Ki")
    local OptimalWorld = GetOptimalWorld()

    if OptimalWorld and (OptimalWorld ~= 'Time Chamber' or CanTimeChamber) and WorldData[OptimalWorld] ~= game.PlaceId then
        TeleportService:Teleport(WorldData[OptimalWorld])
    end

    if AgilityAttackPair then
        Network:FireServer("FastFlight", true)
        Network:FireServer("Combat")
        continue
    end

    if EnergyPercent < 20 then
        HiddenFlags.ShouldCharge = true
    end

    if EnergyPercent > 90 then
        HiddenFlags.ShouldCharge = false
    end

    if HiddenFlags.ShouldCharge then Charge(true) continue end

    local Charging = Character:WaitForChild('State'):WaitForChild('Charging')
    if Charging and Charging.Value then Charge(false) continue end

    if DefenceKiPair then
        Network:FireServer("DefenseTrain") -- , {["Autododge"] = false}
        Network:FireServer("KiBlast", 'Left', vector.zero)
    end
end

for Index, Connection in Connections do
    Connection:Disconnect()
end

Root.CFrame = HiddenFlags.OriginalCFrame

-- Name: Prince SSJ3 âœ¨ | Dragon Ball Rage PlaceId: 71315343
-- Name: Yardrat PlaceId: 1357512648
-- Name: Time Chamber PlaceId: 1362482151
-- Name: Beerus Planet PlaceId: 3336119605
-- Name: Gravity Chamber PlaceId: 3371469539
-- Name: HFIL PlaceId: 15669378828
-- Name: Plushenza PlaceId: 105326626626130


-- local GameTables = {}
-- for Index, Table in shared.afy and getgc(true) or {} do 
--     if type(Table) == 'table' and rawget(Table, 'Remote') then 
--         -- Table.Remote.Name = Table.Name

--         if Table.Name == 'ChargeEnergy' then
--             if Table.Folder.Name == 'Functions' then Table.Name = 'ChargeEnergyStart' end
--             if Table.Folder.Name == 'Events' then Table.Name = 'ChargeEnergyStop' end
--         end

--         GameTables[Table.Name] = Table
--     end
-- end
-- GameTables.ChargeEnergyStart.Remote:FireServer("\a", true)
-- GameTables.ChargeEnergyStop.Remote:FireServer(false)
-- GameTables.RequestZenkaiBoost.Remote:FireServer("\x11")
-- GameTables.FastFlight.Remote:FireServer(true)
-- GameTables.Combat.Remote:FireServer()
-- GameTables.DefenseTrain.Remote:FireServer()
-- GameTables.KiBlast.Remote:FireServer('Left', vector.zero)
