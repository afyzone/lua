-- https://www.roblox.com/games/6755746130 | Execute twice to toggle

AUTO_LOBBY = true
AUTO_SHAKEORBUY = true
AUTO_SELL = true
AUTO_PRESTIGE = true
AUTO_COLLECT = true
AUTO_BALOON = true

SHAKEORBUY_DELAY = 0
SELL_DELAY = 20

local players = game:GetService('Players')
local replicatedstorage = game:GetService('ReplicatedStorage')
local client = players.LocalPlayer
local backpack = client:FindFirstChildWhichIsA('Backpack')

while (not client.OwnedTycoon.Value) do task.wait() end

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
    local my_tycoon = client.OwnedTycoon.Value

    if (char and root and my_tycoon:FindFirstChild('Essentials')) then
        if (AUTO_SELL and tick() - sell_time > SELL_DELAY) then
            local current_pos = root.CFrame

            root.CFrame = my_tycoon.Essentials.JuiceMaker.AddFruitButton.CFrame
            task.wait(.5)
            
            if (my_tycoon:FindFirstChild('Essentials')) then
                fireproximityprompt(my_tycoon.Essentials.JuiceMaker.AddFruitButton.PromptAttachment.AddPrompt)
            end
            
            root.CFrame = current_pos

            sell_time = tick()
        end

        if (AUTO_LOBBY and tick() - obby > 20 and workspace.ObbyParts.ObbyStartPart.Color ~= Color3.fromRGB(255,0,0)) then
            local current_pos = root.CFrame

            root.CFrame = workspace.ObbyParts.RealObbyStartPart.CFrame
            task.wait(.5)
            root.CFrame = workspace.ObbyParts.Stages.Hard.VictoryPart.CFrame
            task.wait(.5)
            root.CFrame = current_pos

            obby = tick()
        end

        if (AUTO_SHAKEORBUY and tick() - shake_and_buttons > SHAKEORBUY_DELAY) then
            local current_pos = root.CFrame
            
            for i,v in (my_tycoon:GetDescendants()) do
                if (v:IsA('TouchTransmitter') and v.Parent) then
                    root.CFrame = v.Parent.CFrame
                    firetouchinterest(root, v.Parent, 0)
                    task.wait()
                end
            end

            root.CFrame = current_pos
            shake_and_buttons = tick()
        end

        if (AUTO_PRESTIGE and tick() - prestige > 20) then
            replicatedstorage.Remotes['RequestPrestige']:FireServer()
            prestige = tick()
        end

        if (AUTO_COLLECT and my_tycoon:FindFirstChild('Essentials')) then
            local pick_fruit = backpack:FindFirstChild('PickFruit')

            if (pick_fruit) then
                pick_fruit.Parent = char
            else
                pick_fruit = char:FindFirstChild('PickFruit')
            end

            workspace.Ignored.CollectOrb.CollectOrb.Size = Vector3.new(200, 2, 2)
            workspace.Ignored.CollectOrb.CollectOrb.CFrame = my_tycoon.Essentials.CollectAll.CollectorPart.CFrame
        end

        if (AUTO_BALOON) then
            local current_pos = root.CFrame

            for i,v in (workspace.BalloonContainer:GetChildren()) do
                if (v:FindFirstChild('HitBox')) then
                    root.CFrame = v.HitBox.CFrame
                    task.wait(.5)

                    if (v and v:FindFirstChild('HitBox')) then
                        firetouchinterest(root, v.HitBox, 0)
                    end
                end
            end

            root.CFrame = current_pos
        end
    end
end
