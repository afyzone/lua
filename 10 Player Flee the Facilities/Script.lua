-- https://www.roblox.com/games/17600423422
-- Role & Computer ESP, Auto Complete Computer Minigame

local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Client = Players.LocalPlayer
local Challenge = ReplicatedStorage.Challenge
local ComputerChallenge = require(Client.PlayerScripts.Interact.ComputerChallenge)
local HiddenFlags = {Parts = {}, Connections = {}, HookedFunctions = {}}

shared.afy = not shared.afy
print('[afy]', shared.afy)

local CreateInstance = function(Name, Properties)
    local Instance = Instance.new(Name)
    table.insert(HiddenFlags.Parts, Instance)

    for Property, Value in Properties or {} do
        Instance[Property] = Value
    end

    return Instance
end

local CreateConnection = function(Signal, Callback)
    local Connection = Signal:Connect(Callback)
    table.insert(HiddenFlags.Connections, Connection)
    return Connection
end

local CreateHookFunction = function(Function, NewFunction)
    table.insert(HiddenFlags.HookedFunctions, Function)
    local OriginalFunction = hookfunction(Function, NewFunction)
    return OriginalFunction
end

CreateHookFunction(ComputerChallenge.StartChallenge, function() end)
CreateHookFunction(ComputerChallenge.StartContinuousChallenge, function() end)
CreateHookFunction(ComputerChallenge.EndContinuousChallenge, function() end)
CreateConnection(Challenge.OnClientEvent, function(Type, Computer, Start, End)
    if Type ~= 'Challenge' then return end

    local Difference = End - Start
    local Time = 0e-01100001 + 0e-01100110 + 0e-01111001 + Start + (Difference / 2)

    Challenge:FireServer(Computer, Type, Time)
end)

while shared.afy and task.wait() do
    local Character = Client.Character
    local IsClientBeast = Client:GetAttribute('Beast')

    if Character then
        for Index, Player in Players:GetPlayers() do
            if Player == Client then continue end
            local IsBeast = Player:GetAttribute('Beast')
            local PCharacter = Player.Character

            if PCharacter then
                local Highlight = PCharacter:FindFirstChildWhichIsA('Highlight') or CreateInstance('Highlight', {
                    Parent = PCharacter,
                    Enabled = true,
                })

                if IsClientBeast then
                    Highlight.FillColor = IsBeast and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                else
                    Highlight.FillColor = IsBeast and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
                end
            end
        end

        for Index, Computer in workspace.Map:GetChildren() do
            if Computer.Name ~= 'ComputerTable' then continue end
            
            local Highlight = Computer:FindFirstChildWhichIsA('Highlight') or CreateInstance('Highlight', {
                Enabled = true,
                Parent = Computer,
            })

            Highlight.FillColor = Computer:GetAttribute('Enabled') and (Computer:GetAttribute('Progress') or 0) >= 100 and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        end
    end
end

for Index, Part in HiddenFlags.Parts do
    Part:Destroy()
end

for Index, Connection in HiddenFlags.Connections do
    Connection:Disconnect()
end

for Index, Function in HiddenFlags.HookedFunctions do
    restorefunction(Function)
end
