local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

local Client = Players.LocalPlayer
local Backpack = Client:FindFirstChildWhichIsA('Backpack')
local CriminalSpawners = workspace.Game.Jobs.CriminalATMSpawners
local Connections, Parts = {}, {}

for Index, Connection in getconnections(Client.Idled) do
    Connection:Disconnect()
end

local function GetRoot(Character) return Character and Character:FindFirstChild('HumanoidRootPart') end
local function GetHumanoid(Character) return Character and Character:FindFirstChildWhichIsA('Humanoid') end

local function CreateInstance(Name : string, Properties : table)
    local Object = Instance.new(Name)

    for Property, Value in Properties or {} do
        Object[Property] = Value
    end

    table.insert(Parts, Object)

    return Object
end

local function CreateConnection(Signal : RBXScriptSignal, Callback)
    local Connection = Signal:Connect(Callback)
    table.insert(Connections, Connection)
    return Connection
end

local function GetATM()
    for Index, ATM in workspace.Game.Jobs.CriminalATMSpawners:GetChildren() do
        local ATMModel = ATM:FindFirstChildWhichIsA('Model')

        if ATMModel then
            if ATMModel:GetAttribute('State') == 'Busted' then continue end
            local ProximityPrompt = ATMModel:FindFirstChild('Attachment') and ATMModel.Attachment:FindFirstChild('ProximityPrompt')

            if ProximityPrompt and ProximityPrompt.Enabled then
                return ATMModel
            end
        end
    end
end

shared.afy = not shared.afy
print('[afy]', shared.afy)

local Floater = CreateInstance('Part', {
    Anchored = true,
    CFrame = CFrame.new(0, 1000, 0),
    CanCollide = true,
    Size = vector.create(10, 0.5, 10)
})

for Index, Instance in getnilinstances() do
    if Instance.Name ~= 'CriminalATMSpawner' then continue end
    Instance.Parent = CriminalSpawners
end

CreateConnection(workspace.Game.Jobs.CriminalATMSpawners.ChildRemoved, function(Child)
    task.wait()
    Child.Parent = CriminalSpawners
end)

while shared.afy and task.wait() do
    local Character = Client.Character
    local Root = GetRoot(Character)
    local Humanoid = GetHumanoid(Character)

    if not Root then continue end
    Root.AssemblyLinearVelocity = vector.zero
    
    local ATM = GetATM()

    if ATM then
        Root:PivotTo(CFrame.new(ATM:GetPivot().Position + vector.create(0, 3, 0)))
        local State = {ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("AttemptATMBustStart"):InvokeServer(ATM)}
        if not State[1] then continue end
        task.wait(3)
        local State = {ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("AttemptATMBustComplete"):InvokeServer(ATM)}
    else
        local Floater = workspace.Game.Jobs.CriminalDropOffSpawners.CriminalDropOffSpawnerPermanent
        Root:PivotTo(Floater.CFrame + vector.create(0, 2.5, 5))
        Humanoid:UnequipTools()

        local Checkout = Backpack:FindFirstChild('CriminalMoneyBag')

        if Checkout then
            Humanoid.WalkToPoint = Floater.Position
            task.wait(0.1)
        end
    end
end

for Index, Connection in Connections do
    Connection:Disconnect()
end

for Index, Part in Parts do
    Part:Destroy()
end
