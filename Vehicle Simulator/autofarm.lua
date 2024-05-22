local players = game:GetService('Players')
local replicatedstorage = game:GetService("ReplicatedStorage")
local client = players.LocalPlayer
local camera = workspace:FindFirstChildWhichIsA('Camera')
shared.afy = not shared.afy

local get_car = function()
    for i,v in pairs(workspace.Vehicles:GetChildren()) do
        if (not v:FindFirstChild('owner') or v:FindFirstChild('owner') and v.owner.Value ~= client.Name) then continue end

        v.PrimaryPart = v.Chassis.VehicleSeat
        return v
    end
end

while (shared.afy and task.wait()) do
    local my_car = get_car()

    if (my_car) then
        if (client.PlayerGui:FindFirstChild('Endrace_results')) then
            client.PlayerGui.Endrace_results:Destroy()
        end
        
        if (not client.PlayerGui:FindFirstChild('RaceGui')) then
            replicatedstorage["Game Modes V2"].Shared.Remotes.RemoteEvents.Invite:FireServer(17)
            replicatedstorage["Game Modes V2"].Shared.Remotes.RemoteFunctions["join_mode"]:InvokeServer(17)
            replicatedstorage["Game Modes V2"].Shared.Remotes.RemoteEvents.Invite:FireServer(17)
        end

        while (not client.PlayerGui:FindFirstChild('RaceGui')) do
            task.wait()
        end

        local checkpoint = camera:FindFirstChildWhichIsA('Part')
        if (checkpoint) then
            my_car:PivotTo(checkpoint.CFrame * CFrame.new(0, 5, 0))
        end
    end
end
