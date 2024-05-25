-- https://www.roblox.com/games/13876564679
local replicatedstorage = game:GetService("ReplicatedStorage")
local virtualinputmanager = game:GetService('VirtualInputManager')
local players = game:GetService('Players')

local client = players.LocalPlayer
shared.afy = not shared.afy

while (shared.afy and task.wait()) do
    if (client:FindFirstChildWhichIsA('Backpack').CurrentBall.Value and client.PlayerGui.ShotMeter.Base.Bar.UIGradient.Offset.Y < 0.2) then
        virtualinputmanager:SendKeyEvent(false, Enum.KeyCode.E, false, workspace)
    end
end
