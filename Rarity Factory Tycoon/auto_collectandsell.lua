shared.afy = not shared.afy

local players = game:GetService('Players')
local client = players.LocalPlayer

my_tycoon = (function()
    for i,v in workspace.Tycoons:GetChildren() do
        if (v.Owner.Value ~= client.Name) then continue end

        return v
    end
end)()

while (shared.afy and task.wait()) do
    if not my_tycoon then return end

    local char = client.Character
    local root = char and char:FindFirstChild('HumanoidRootPart')

    if not (char or root) then return end

    for i,v in (my_tycoon.Drops:GetChildren()) do
        v.CFrame = root.CFrame
    end
    
    firetouchinterest(my_tycoon["Orb Processor"].Model.Deposit.Button, root, 0)
    firetouchinterest(my_tycoon["Orb Processor"].Model.Deposit.Button, root, 1)

    for i,v in (workspace.Obby.RewardButtons:GetChildren()) do
        if not v:IsA('Model') then continue end

        firetouchinterest(v.Button, root 0)
        firetouchinterest(v.Button, root 1)
    end
end
