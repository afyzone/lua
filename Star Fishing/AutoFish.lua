-- https://www.roblox.com/games/86111605798689/
-- Auto Fish

local Flags = Flags or {
    Farm = 'Self', -- Self, Milky Way, Andromeda, Centaurus A, Hoag's Object, Negative Galaxy, The Eye
}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Client = Players.LocalPlayer
local Connections = {}

shared.afy = not shared.afy
print('[afy]', shared.afy)

local function GetRoot(Character) return Character and Character:FindFirstChild('HumanoidRootPart') end
local function GetHumanoid(Character) return Character and Character:FindFirstChild('Humanoid') end

local function Cast()
    local Character = Client.Character
    local Humanoid = GetHumanoid(Character)
    local Root = GetRoot(Character)
    if not Root then return end

    local Rod = Character:FindFirstChild('Rod')
    if not Rod then return end

    local Farming = Flags.Farm == 'Self' and Root or workspace.Zones:FindFirstChild(Flags.Farm) or Root
    local FarmType = {Farming:GetPivot().Position, Farming:GetPivot().LookVector}
    local CastArguments = {
        Humanoid,
        FarmType[1],
        FarmType[2],
        Rod.Model.Nodes.RodTip.Attachment
    }

    local Cast = ReplicatedStorage.Events.Global.Cast
    Cast:FireServer(table.unpack(CastArguments))

    local WithdrawBobber = ReplicatedStorage.Events.Global.WithdrawBobber
    WithdrawBobber:FireServer(Client.Character.Humanoid)
end

local ClientRecieveItems = ReplicatedStorage.Events.Global.ClientRecieveItems
table.insert(Connections, ClientRecieveItems.OnClientEvent:Connect(function(...)
    local Data = {...}
    local Info = Data[4] or {}
    local TimingTbl = Data[6] or {}

    for Index, StarData in Info do
        local Id = StarData['id']

        if Id then
            task.wait(TimingTbl[Index] or 3)
            local ClientItemConfirm = ReplicatedStorage.Events.Global.ClientItemConfirm
            ClientItemConfirm:FireServer(Id)
        end
    end
end))

while shared.afy and task.wait() do
    local Character = Client.Character
    local Root = GetRoot(Character)
    if not Root then continue end
    
    Cast()
end

for Index, Connection in Connections do
    Connection:Disconnect()
end
