local players = game:GetService('Players')
local replicatedstorage = game:GetService("ReplicatedStorage")
local client = players.LocalPlayer
local camera = workspace:FindFirstChildWhichIsA('Camera')

shared.afy = not shared.afy
getconnections(client.Idled)[1]:Disconnect()

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

        local checkpoint = camera:FindFirstChildWhichIsA('Part')
        if (checkpoint) then
            my_car.PrimaryPart.Anchored = false
            my_car:PivotTo(checkpoint.CFrame + Vector3.new(0, 1, 0))
        else
            my_car.PrimaryPart.Anchored = true
        end
    end
end
