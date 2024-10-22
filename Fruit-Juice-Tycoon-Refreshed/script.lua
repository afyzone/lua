-- Fruit-Juice-Tycoon-Refreshed | Execute twice to toggle

ENABLE_AUTO_LOBBY = true
ENABLE_AUTO_SHAKEORBUY = true
ENABLE_AUTO_SELL = true

SHAKEORBUY_DELAY = 0
OBBY_DELAY = 20
SELL_DELAY = 20

local players = game:GetService("Players")
local client = players.LocalPlayer

while (not client.OwnedTycoon.Value) do task.wait() end

local my_tycoon = client.OwnedTycoon.Value
local sell_time, shake_and_buttons, obby = 0, 0, 0

shared.afy = not shared.afy

while (shared.afy and task.wait()) do
    local char = client.Character
    local root = char and char.HumanoidRootPart

    if (char and root) then
        if (ENABLE_AUTO_SELL and tick() - sell_time > SELL_DELAY) then
            local current_pos = root.CFrame

            root.CFrame = my_tycoon.Essentials.JuiceMaker.AddFruitButton.CFrame
            task.wait(.5)
            fireproximityprompt(my_tycoon.Essentials.JuiceMaker.AddFruitButton.PromptAttachment.AddPrompt)
            root.CFrame = current_pos

            sell_time = tick()
        end

        if (ENABLE_AUTO_LOBBY and tick() - obby > OBBY_DELAY and workspace.ObbyParts.ObbyStartPart.Color ~= Color3.fromRGB(255, 0, 0)) then
            local current_pos = root.CFrame

            root.CFrame = workspace.ObbyParts.Stages.Hard.VictoryPart.CFrame
            task.wait(.5)
            firetouchinterest(root, workspace.ObbyParts.Stages.Hard.VictoryPart, 0)
            root.CFrame = current_pos

            obby = tick()
        end

        if (ENABLE_AUTO_SHAKEORBUY and tick() - shake_and_buttons > SHAKEORBUY_DELAY) then
            for i,v in (my_tycoon:GetDescendants()) do
                if (v:IsA('TouchTransmitter') and v.Parent) then
                    root.CFrame = v.Parent.CFrame
                    firetouchinterest(root, v.Parent, 0)
                    task.wait()
                end
            end

            shake_and_buttons = tick()
        end
    end
end
