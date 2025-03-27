-- https://www.roblox.com/games/161766693/

local Connections = {}
shared.afy = not shared.afy

local GetMyTycoon = function()
    local TycoonDropper = workspace.DropStorage:FindFirstChildWhichIsA('Model')
    local MyTycoon = TycoonDropper and workspace.Tycoons:FindFirstChild(TycoonDropper.Name)

    return MyTycoon, TycoonDropper
end

local Tycoon, Dropper = GetMyTycoon()

table.insert(Connections, Dropper.ChildAdded:Connect(function(drop)
    local DroppedTime = tick()

    while (shared.afy and drop and tick() - DroppedTime < 10) do
        for i,v in (Tycoon.PurchasedObjects:GetChildren()) do
			task.wait()

			drop.AssemblyLinearVelocity = vector.zero

            local Upgrade = v:FindFirstChild('Upgrade')
            local UpgradeTouch = Upgrade and Upgrade:FindFirstChildWhichIsA('TouchTransmitter')

            if (not UpgradeTouch) then continue end

            drop.CFrame = Upgrade.CFrame
            firetouchinterest(drop, Upgrade, 0)
            firetouchinterest(drop, Upgrade, 1)
        end

        task.wait()
    end

    local Seller = Tycoon.Essentials.TeamColor
    drop.CFrame = Seller.CFrame
    firetouchinterest(drop, Seller, 0)
    firetouchinterest(drop, Seller, 1)
end))

while (shared.afy) do task.wait() end

for i,v in Connections do
	v:Disconnect()
end
