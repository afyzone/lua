local client = game:GetService('Players').LocalPlayer
shared.afy = not shared.afy

while shared.afy and task.wait() do
    local char = client.Character
    local root = char and char:FindFirstChild('HumanoidRootPart')

    if (char and root) then
        game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvent"):WaitForChild("Client"):FireServer(178)
        game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvent"):WaitForChild("Client"):FireServer(188, 13)

        root.AssemblyLinearVelocity = Vector3.new(0, 0, -9e9)
    else
        game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvent"):WaitForChild("Client"):FireServer(179, true)
        game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvent"):WaitForChild("Client"):FireServer(306, false)
    end
end
