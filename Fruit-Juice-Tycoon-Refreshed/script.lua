-- https://www.roblox.com/games/6755746130 | Execute twice to toggle

ENABLE_AUTO_LOBBY = true
ENABLE_AUTO_SHAKEORBUY = true
ENABLE_AUTO_SELL = true
ENABLE_AUTO_PRESTIGE = true
ENABLE_AUTO_COLLECT = true
ENABLE_AUTO_BALOON = true

SHAKEORBUY_DELAY = 0
OBBY_DELAY = 20
SELL_DELAY = 20

local players = game:GetService('Players')
local replicatedstorage = game:GetService('ReplicatedStorage')
local client = players.LocalPlayer
local backpack = client:FindFirstChildWhichIsA('Backpack')

while (not client.OwnedTycoon.Value) do task.wait() end

local my_tycoon = client.OwnedTycoon.Value
local sell_time, shake_and_buttons, obby, prestige = 0, 0, 0, 0

shared.afy = not shared.afy

task.spawn(function()
    while (shared.afy and task.wait()) do
        local char = client.Character
        local root = char and char:FindFirstChild('HumanoidRootPart')
    
        if (char and root) then
            root.AssemblyLinearVelocity = Vector3.zero
        end
    end
end)

while (shared.afy and task.wait()) do
    local char = client.Character
    local root = char and char:FindFirstChild('HumanoidRootPart')

    if (char and root) then
        if (ENABLE_AUTO_SELL and tick() - sell_time > SELL_DELAY) then
            local current_pos = root.CFrame

            root.CFrame = my_tycoon.Essentials.JuiceMaker.AddFruitButton.CFrame
            task.wait(.5)
            fireproximityprompt(my_tycoon.Essentials.JuiceMaker.AddFruitButton.PromptAttachment.AddPrompt)
            root.CFrame = current_pos

            sell_time = tick()
        end

        if (ENABLE_AUTO_LOBBY and tick() - obby > OBBY_DELAY and workspace.ObbyParts.ObbyStartPart.Color ~= Color3.fromRGB(255,0,0)) then
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

        if (ENABLE_AUTO_PRESTIGE and tick() - prestige > 20) then
            replicatedstorage.Remotes['RequestPrestige']:FireServer()
            prestige = tick()
        end

        if (ENABLE_AUTO_COLLECT and my_tycoon:FindFirstChild('Essentials')) then
            local pick_fruit = backpack:FindFirstChild('PickFruit')

            if (pick_fruit) then
                pick_fruit.Parent = char
            else
                pick_fruit = char:FindFirstChild('PickFruit')
            end

            workspace.Ignored.CollectOrb.CollectOrb.Size = Vector3.new(200, 2, 2)
            workspace.Ignored.CollectOrb.CollectOrb.CFrame = my_tycoon.Essentials.CollectAll.CollectorPart.CFrame
        end

        if (ENABLE_AUTO_BALOON) then
            for i,v in (workspace.BalloonContainer:GetChildren()) do
                if (v:FindFirstChild('HitBox')) then
                    local current_pos = root.CFrame

                    root.CFrame = v.HitBox.CFrame
                    task.wait(.5)

                    if (v and v:FindFirstChild('HitBox')) then
                        firetouchinterest(root, v.HitBox, 0)
                    end

                    root.CFrame = current_pos
                end
            end
        end
    end
end
