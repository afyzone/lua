-- https://www.roblox.com/games/16621558371
local players = game:GetService("Players")
local virtualinputmanager = game:GetService('VirtualInputManager')
local replicatedstorage = game:GetService("ReplicatedStorage")

local client = players.LocalPlayer
shared.afy = not shared.afy

while (shared.afy and task.wait()) do
    for i,v in pairs(client.PlayerGui.MainUI.Frames.TypingFrame.Holder.Box.Content:GetChildren()) do
        if (v.Text:sub(1, 1) == '<') then
            local char = v.Text:sub(4, 4)
            
            virtualinputmanager:SendKeyEvent(true, char == '.' and Enum.KeyCode.Period or char == ' ' and Enum.KeyCode.Space or Enum.KeyCode[char:upper()], false, workspace)
            virtualinputmanager:SendKeyEvent(false, char == '.' and Enum.KeyCode.Period or char == ' ' and Enum.KeyCode.Space or Enum.KeyCode[char:upper()], false, workspace)
        end
    end
    
    replicatedstorage:FindFirstChild("_GAME"):FindFirstChild("_MODULES"):FindFirstChild("Utilities"):FindFirstChild("NetworkUtility"):FindFirstChild("Events"):FindFirstChild("UpdateDesk"):FireServer('Smash')
end
