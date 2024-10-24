-- https://www.roblox.com/games/6755746130 | Execute twice to toggle

AUTO_OBBY = true
AUTO_SHAKEORBUY = true
AUTO_SELL = false
AUTO_PRESTIGE = true
AUTO_COLLECT = true
AUTO_BALOON = true
AUTO_USE_BUFFS = true
AUTO_CHEST = true
AVOID_BUYING_IF_STATUE = false

SHAKEORBUY_DELAY = 0
SELL_DELAY = 20

local players = game:GetService('Players')
local replicatedstorage = game:GetService('ReplicatedStorage')
local client = players.LocalPlayer
local backpack = client:FindFirstChildWhichIsA('Backpack')

for i, v in pairs(getconnections(client.Idled)) do 
    v:Disable()
end

while (not client.OwnedTycoon.Value) do task.wait() end

local sell_time, shake_and_buttons, obby, buff_delay = 0, 0, 0, 0

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
        if (AUTO_PRESTIGE and my_tycoon.Purchases:FindFirstChild('PrestigeStatue')) then
            replicatedstorage.Remotes['RequestPrestige']:FireServer()
        end

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

        if (AUTO_OBBY and tick() - obby > 20 and workspace.ObbyParts.ObbyStartPart.Color ~= Color3.fromRGB(255, 0, 0)) then
            local current_pos = root.CFrame

            root.CFrame = workspace.ObbyParts.RealObbyStartPart.CFrame
            task.wait(.5)
            root.CFrame = workspace.ObbyParts.Stages.Hard.VictoryPart.CFrame
            task.wait(.5)
            root.CFrame = current_pos

            obby = tick()
        end

        if (AUTO_USE_BUFFS and tick() - buff_delay > 10) then
            for i,v in (backpack:GetChildren()) do
                v.Parent = char
            end

            for i,v in (char:GetChildren()) do
                if (v:IsA('Tool')) then
                    v:Activate()
                end
            end
            
            buff_delay = tick()
        end

        if (AUTO_SHAKEORBUY and tick() - shake_and_buttons > SHAKEORBUY_DELAY) then
            local current_pos = root.CFrame
            
            for i,v in (my_tycoon:GetDescendants()) do
                if (my_tycoon:FindFirstChild('Buttons') and my_tycoon.Buttons:FindFirstChild('Statue') and v:IsDescendantOf(my_tycoon.Buttons)) then
                    if (AVOID_BUYING_IF_STATUE) then
                        if (v == my_tycoon.Buttons.Statue) then
                            root.CFrame = my_tycoon.Buttons.Statue.CFrame
                            firetouchinterest(root, my_tycoon.Buttons.Statue, 0)
                            task.wait()
                        end
                    else
                        if (v:IsA('TouchTransmitter') and v.Parent) then
                            root.CFrame = v.Parent.CFrame
                            firetouchinterest(root, v.Parent, 0)
                            task.wait()
                        end
                    end
                else
                    if (v:IsA('TouchTransmitter') and v.Parent) then
                        root.CFrame = v.Parent.CFrame
                        firetouchinterest(root, v.Parent, 0)
                        task.wait()
                    end
                end
            end

            root.CFrame = current_pos
            shake_and_buttons = tick()
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

        if (AUTO_CHEST and my_tycoon:FindFirstChild('Essentials')) then
            local current_chest = my_tycoon.Essentials.ItemChest1.InfoGui.ItemsLabel.Text:gsub(' items', '')
            local current_chest_stat = current_chest:split('/')

            if (current_chest_stat and current_chest_stat[1] == current_chest_stat[2]) then
                local current_pos = root.CFrame
                root.CFrame = my_tycoon.Essentials.ItemChest1.Root.CFrame
                task.wait(.5)
                fireproximityprompt(my_tycoon.Essentials.ItemChest1.Root.PromptAttachment.UsePrompt)
                root.CFrame = current_pos
            end
        end
    end
end
