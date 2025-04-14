-- https://www.roblox.com/games/137681066791460
-- unfinished

local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Client = Players.LocalPlayer
local PlayerGui = Client:WaitForChild('PlayerGui')
local Icons = {
    ['rbxassetid://94814792785652'] = 'Punch',
    ['rbxassetid://134317346328662'] = 'Health',
}

shared.afy = not shared.afy
print(shared.afy)

while shared.afy and task.wait() do
    local Task = PlayerGui.HUD.RightUi.Tasks.Tasks.TaskList.TaskList["1"]:FindFirstChild("1")
    local TaskIcon = Task and Task:FindFirstChild('Icon')
    local Upgrade = TaskIcon and Icons[TaskIcon.Image]

    if (Upgrade) then
        if (Upgrade == 'Punch') then
            ReplicatedStorage:WaitForChild("Events"):WaitForChild("Train"):WaitForChild("TrainPower"):FireServer(0)
        end

        if (Upgrade == 'Health') then
            ReplicatedStorage:WaitForChild("Events"):WaitForChild("Train"):WaitForChild("TrainHealth"):FireServer(0)
        end

        if (Upgrade == 'Defence') then
            ReplicatedStorage:WaitForChild("Events"):WaitForChild("Train"):WaitForChild("TrainDefense"):FireServer(1)
        end

        if (Upgrade == 'Psychics') then
            ReplicatedStorage:WaitForChild("Events"):WaitForChild("Train"):WaitForChild("TrainPsychics"):FireServer(0)
        end
    end

    ReplicatedStorage:WaitForChild("Events"):WaitForChild("Train"):WaitForChild("TrainMobility"):FireServer()
    ReplicatedStorage:WaitForChild("Events"):WaitForChild("Other"):WaitForChild("StartMainTask"):FireServer("MainTask")
    ReplicatedStorage:WaitForChild("Events"):WaitForChild("Other"):WaitForChild("ClaimMainTask"):FireServer(1)
end
