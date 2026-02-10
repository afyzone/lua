-- https://www.roblox.com/games/71315343/
-- Auto Zenkai Boost, Auto Farm Every Stat, Auto Reconnect, Auto Re-exec, Anti-AFK, Safe Farm, Auto Transform

local Flags = Flags or {
    Type = 'Auto', -- Auto, Agility, Attack, Defense, Ki 
    ZenkaiBoost = true,
    SafeFarm = true,
    OptimalWorld = true,
    Transform = true,
}

if not game:IsLoaded() then game.Loaded:Wait() task.wait(1) end

local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local TeleportService = game:GetService('TeleportService')
local GuiService = game:GetService('GuiService')
local Client = Players.LocalPlayer or Players.PlayerAdded:Wait()
local PlayerGui = Client:WaitForChild('PlayerGui')
local Network = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Library'):WaitForChild('Network'))
local StatUtils = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Shared'):WaitForChild('StatUtils'))

local WorldData, Connections, HiddenFlags = {
    ['Time Chamber'] = {
        PlaceId = 1362482151,
        Agility = 2,
        Attack = 2,
        Defense = 2,
        Ki = 2,
    },
    ['Gravity Chamber'] = {
        PlaceId = 3371469539,
        Agility = 6,
        Attack = 3,
        Defense = 0.5,
        Ki = 0.5,
    },
    ['Hell'] = {
        PlaceId = 15669378828,
        Agility = 0.5,
        Attack = 0.5,
        Defense = 4,
        Ki = 1.5,
    },
    ['Beerus Planet'] = {
        PlaceId = 3336119605,
        Agility = 0.5,
        Attack = 0.5,
        Defense = 3,
        Ki = 3,
    }
}, {}, {}

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

    GetStatInfo = function()
        local Stats = Client:FindFirstChild('Stats')

        if Stats then
            return Stats.Agility, Stats.Attack, Stats.Defense, Stats.Ki
        end
    end

    GetTransformInfo = function()
        local Character = Client.Character
        if not Character then return end

        local Stats = Client:FindFirstChild('Stats')
        local State = Character:FindFirstChild('State')

        if Stats and State then
            return Stats.SelectedMode.Value, State.ActiveMode.Value
        end
    end

    Transform = function()
        local EquippedMode, EnabledMode = GetTransformInfo()

        if EquippedMode and (not EnabledMode or EnabledMode == '') then
            Network:InvokeServer("Transform", "Quick")
            return true
        end
    end

    GetBestTraining = function()
        local Required = StatUtils:GetRequiredZenkaiStats(GetZenkai() + 1)
        
        for Index, Stat in { GetStatInfo() } do
            if Stat.Value < (Required or math.huge) then return Stat.Name end
        end
    end

    GetZenkai = function()
        local Stats = Client:FindFirstChild('Stats')

        if Stats then
            return Stats.ZenkaiBoost.Value
        end
    end

    Charge = function(Bool)
        if Bool then
            Network:InvokeServer("ChargeEnergy", true)
        else
            Network:FireServer("ChargeEnergy", false)
        end
    end

    GetOptimalWorld = function(TrainingStat)
        local Zenkai = GetZenkai() or 0
        local Agility, Attack, Defense, Ki = GetStatInfo()
        local TimeChamberThreshold = 1_250_000
        local CanTimeChamber = Agility.Value >= TimeChamberThreshold and Attack.Value >= TimeChamberThreshold and Defense.Value >= TimeChamberThreshold and Ki.Value >= TimeChamberThreshold
        local Candidates = {}

        if CanTimeChamber then
            table.insert(Candidates, {
                Name = "Time Chamber",
                Multi = WorldData["Time Chamber"][TrainingStat] or 1
            })
        end

        if Zenkai >= 6 then
            table.insert(Candidates, {
                Name = "Gravity Chamber",
                Multi = WorldData["Gravity Chamber"][TrainingStat] or 1
            })
        end

        if Zenkai >= 3 then
            table.insert(Candidates, {
                Name = "Hell",
                Multi = WorldData["Hell"][TrainingStat] or 1
            })
        end

        if Zenkai >= 5 then
            table.insert(Candidates, {
                Name = "Beerus Planet",
                Multi = WorldData["Beerus Planet"][TrainingStat] or 1
            })
        end

        table.insert(Candidates, { Name = "Earth", Multi = 1 })

        local BestWorld = Candidates[1]
        for Index, World in ipairs(Candidates) do
            if World.Multi > BestWorld.Multi then
                BestWorld = World
            end
        end

        return BestWorld.Name
    end
end

for Index, Connection in getconnections(Client.Idled) do
    Connection:Disconnect()
end

table.insert(Connections, Client.OnTeleport:Connect(function()
    local SerializedFlags = 'getgenv().Flags = {'
    for Setting, Value in Flags do
        local IsString = typeof(Value) == 'string'
        SerializedFlags..=(`%s={IsString and `'%s'` or `%s`},`):format(tostring(Setting), tostring(Value))
    end
    SerializedFlags..='}\n'

    queue_on_teleport(SerializedFlags..[[
        if afy then return end getgenv().afy = true
        loadstring(game:HttpGet('https://raw.githubusercontent.com/afyzone/lua/refs/heads/main/Dragon%20Ball%20Rage/AutoFarm.lua'))()
    ]])
end))

table.insert(Connections, TeleportService.TeleportInitFailed:Connect(function()
    task.wait(5)
    TeleportService:Teleport(game.PlaceId)
end))

table.insert(Connections, GuiService.ErrorMessageChanged:Connect(function()
    task.wait(2)
    TeleportService:Teleport(game.PlaceId)
end))

while shared.afy and task.wait() do
    local Character = Client.Character
    local Root = GetRoot(Character)
    if not Root then continue end

    if not HiddenFlags.OriginalCFrame then HiddenFlags.OriginalCFrame = Root.CFrame end

    if Flags.SafeFarm then
        Root.CFrame = CFrame.new(0, 10000, 0)
    end

    if Flags.Transform then
        if Transform() then continue end
    end

    local BestTraining = GetBestTraining()

    if Flags.ZenkaiBoost and not BestTraining then
        Network:InvokeServer("RequestZenkaiBoost")
        task.wait(2)
        continue
    end

    local BestTraining = Flags.Type == 'Auto' and BestTraining or Flags.Type
    local EnergyPercent = GetEnergyPercent()
    local OptimalWorld = GetOptimalWorld(BestTraining)
    local World = WorldData[OptimalWorld]
    local WorldId = World and World.PlaceId

    if Flags.OptimalWorld and WorldId ~= game.PlaceId then
        TeleportService:Teleport(WorldId)
        task.wait(5)
        continue
    end

    if BestTraining == "Agility" or BestTraining == "Attack" then
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

    if BestTraining == "Defense" then
        Network:FireServer("DefenseTrain") -- , {["Autododge"] = false}
    end

    if BestTraining == "Ki" then
        Network:FireServer("KiBlast", 'Left', vector.zero)
    end
end

for Index, Connection in Connections do
    Connection:Disconnect()
end

-- Name: Dragon Ball Rage PlaceId: 71315343
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
