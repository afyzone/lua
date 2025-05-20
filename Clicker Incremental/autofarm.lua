-- https://www.roblox.com/games/132735780578120/

shared.afy = not shared.afy
print(shared.afy)

local Players = game:GetService('Players')
local Client = Players.LocalPlayer

local function RGBtoKey(c)
    return ('%d,%d,%d'):format(
        math.floor(c.R * 255 + 0.5),
        math.floor(c.G * 255 + 0.5),
        math.floor(c.B * 255 + 0.5)
    )
end

local Colors = {
    ['168,119,79'] = Client.leaderstats.TotalClicks,
    ['255,255,11'] = Client.leaderstats.GoldenBobux,
    ['0,255,0'] = Client.leaderstats.Bobux,
    ['255,100,0'] = Client.CoolStuff.Points,
    ['255,255,0'] = Client.CoolStuff.Coins,
}

local function GetRobux()
    for i,v in workspace.BobuxFolder.TycoonBobux:GetChildren() do
        local Kick = v:FindFirstChild('Kick')
        if (Kick and Kick.Value) then continue end

        return v
    end

    for i,v in (workspace:GetChildren()) do
        if (v.Name ~= 'AutoBobux' and v.Name:find('Bobux') and v:FindFirstChild('Collect')) then
            local Kick = v:FindFirstChild('Kick')
            if (Kick and Kick.Value) then continue end
            
            return v
        end
    end
end

local function GetUpgradable()
    for i,v in (workspace.Upgrades:GetChildren()) do
        local Button = v:FindFirstChild('Button')
        local Cost = Button and Button:FindFirstChild('Cost')
        local MyCurrency = Colors[RGBtoKey(Button.SurfaceGui.SIGN.TextColor3)]

        local CanBeUpgraded = Button:FindFirstChild('CanBeUpgraded')
        if (CanBeUpgraded and not CanBeUpgraded.Value) then continue end

        if (Cost and MyCurrency and MyCurrency.Value >= Cost.Value and Button.ClickDetector.MaxActivationDistance ~= 0) then
            return Button
        end
    end
end

while shared.afy and task.wait() do
    local Char = Client.Character
    local Root = Char and Char:FindFirstChild('HumanoidRootPart')

    if (not Root) then continue end

    local Clicker = workspace.Clicker
    if (Clicker.Color == Color3.fromRGB(0, 255, 0) and vector.magnitude(Clicker.Position - Root.Position) < Clicker.ClickDetector.MaxActivationDistance) then
        fireclickdetector(Clicker.ClickDetector)
    end

    local Clicker = workspace.GBobuxClicker
    if (Clicker.Color == Color3.fromRGB(0, 255, 0) and vector.magnitude(Clicker.Position - Root.Position) < Clicker.ClickDetector.MaxActivationDistance) then
        fireclickdetector(Clicker.ClickDetector)
    end

    local Bobux = GetRobux()
    if (Bobux) then
        Bobux.CanCollide = false
        Bobux.Position = Root.Position
    end

    local Upgradable = GetUpgradable()
    if (Upgradable) then
        fireclickdetector(Upgradable.ClickDetector)
    end

    local ClickButton = workspace.ClickButton:FindFirstChild(workspace.ClickButonThingy.ClickButtonThing.SurfaceGui.SIGN.Text)
    if (ClickButton and vector.magnitude(ClickButton.Position - Root.Position) < ClickButton.ClickDetector.MaxActivationDistance - 1) then
        fireclickdetector(ClickButton.ClickDetector)
    end
end
