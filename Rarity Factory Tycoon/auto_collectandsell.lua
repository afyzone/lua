shared.afy = not shared.afy

local players = game:GetService('Players')
local client = players.LocalPlayer

local my_tycoon = (function()
    for i,v in workspace.Tycoons:GetChildren() do
        if (v.Owner.Value ~= client.Name) then continue end

        return v
    end
end)()

local function is_purchasable(button : Instance) : bool
    if not (button:FindFirstChild('Button') and button.Button:FindFirstChild('BillboardGui') and button.Button.BillboardGui:FindFirstChild('Price')) then return end

    return button.Button.BillboardGui.Price.TextColor3 == Color3.fromRGB(96, 255, 114)
end

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

        firetouchinterest(v.Button, root, 0)
        firetouchinterest(v.Button, root, 1)
    end

    for i,v in (my_tycoon.Buttons:GetChildren()) do
        if not v:IsA('Model') or v.Button:FindFirstChild('BillboardGui') and v.Button.BillboardGui.Price.TextColor3 ~= Color3.fromRGB(96, 255, 114) then continue end

        firetouchinterest(v.Button, root, 0)
        firetouchinterest(v.Button, root, 1)
    end

    if is_purchasable(my_tycoon.Rebirth) then
        firetouchinterest(my_tycoon.Rebirth.Button, root, 0)
        firetouchinterest(my_tycoon.Rebirth.Button, root, 1)
    end
end
