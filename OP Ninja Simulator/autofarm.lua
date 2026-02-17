-- https://www.roblox.com/games/4225025295 | Exec twice to toggle

shared.afy = not shared.afy
print('[afy]', shared.afy)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local OriginalRequire = require
local GameRequire = (function()
    require(ReplicatedStorage:FindFirstChild("Require") or game:FindFirstChild("Require", true))()
    return require
end)()
require = OriginalRequire

local Players = game:GetService('Players')
local Client = Players.LocalPlayer
local PlayerGui = Client:WaitForChild('PlayerGui')
local Backpack = Client:FindFirstChildWhichIsA('Backpack')
local BackpackFilter, SafePos = {"Shuriken", "InvisibilityTool", "ShadowCloneTool", "TeleportTool"}
local SwordDelay, ShurikenDelay, ClassDelay, RealmDelay = 0, 0, 0, 0
local PersonalRemotes = GameRequire('PersonalRemoteService')
local RemoteData = {
    Sword = 'อัพเกรดดาบแม็กซ์',
    Shuriken = "อัพเกรดดาวกระจาย",
    Realm = "อัพเกรดแอสเซนต์",
    Class = "อัพเกรดคลาส"
}

for i,v in getconnections(Client.Idled) do
    v:Disable()
end

if not SafePart then
    local SafePart, RandomCoordinate = Instance.new('Part'), math.random(4e3); do
        getgenv().SafePart = SafePart

        SafePart.Parent = workspace
        SafePart.Anchored = true
        SafePart.Size = vector.create(150, 1, 150)
        SafePart.CFrame = CFrame.new(vector.create(10e3, 10e3, 10e3) + vector.create(RandomCoordinate, 0, 0))
    end
end

local AutoUpgrade = function()
    local UpgradeF = PlayerGui:WaitForChild('MainGui'):FindFirstChild("UpgradeF")

    if UpgradeF then
        local Sword = UpgradeF["SwordF"]:FindFirstChild("MaxUpgradeBtn")
        local Shuriken = UpgradeF["ShurikenF"]:FindFirstChild("ShurikenImgBtn")
        local Class = UpgradeF["ClassF"]:FindFirstChild("ClassImgBtn")
        local Realm = UpgradeF["AscendF"]:FindFirstChild("AscendImgBtn")

        if Sword and tick() - SwordDelay > 2 then
            PersonalRemotes.RemoteFunction:InvokeServer(RemoteData.Sword)
            SwordDelay = tick()
        end

        if Shuriken and tick() - ShurikenDelay > 2 then
            PersonalRemotes.RemoteFunction:InvokeServer(RemoteData.Shuriken)
            ShurikenDelay = tick()
        end

        if Class and tick() - ClassDelay > 2 then
            PersonalRemotes.RemoteFunction:InvokeServer(RemoteData.Class)
            ClassDelay = tick()
        end

        if Realm and tick() - RealmDelay > 2 then
            PersonalRemotes.RemoteFunction:InvokeServer(RemoteData.Realm)
            RealmDelay = tick()
        end
    end
end

while shared.afy and task.wait() do
    local Char = Client.Character
    local Root = Char and Char:FindFirstChild('HumanoidRootPart')

    if Root then
        if not SafePos then
            SafePos = Root.CFrame
            Root.CFrame = SafePart.CFrame * CFrame.new(0, 3, 0)
        end

        local Katana = (function()
            for Index, Tool in (Backpack:GetChildren()) do
                if table.find(BackpackFilter, Tool.Name) then continue end
                return Tool
            end
        end)()
    
        if Katana then
            Katana.Parent = Char
        end

        local Katana = Char:FindFirstChildWhichIsA('Tool')

        if Katana then
            Katana:Activate()
            Katana.Parent = Backpack
        end

        AutoUpgrade()
    end
end

if SafePos then
    local Char = Client.Character
    local Root = Char and Char:FindFirstChild('HumanoidRootPart')

    if Root then
        Root.CFrame = SafePos
    end
end
