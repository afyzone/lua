-- https://www.roblox.com/games/4225025295 | Exec twice to toggle

local players = game:GetService('Players')
local virtualinputmanager = game:GetService('VirtualInputManager')
local guiservice = game:GetService("GuiService")
local client = players.LocalPlayer
local backpack = client:FindFirstChildWhichIsA('Backpack')
local playergui = client:WaitForChild('PlayerGui')
local gui_inset = guiservice:GetGuiInset()

local backpack_filter, safe_pos = {"Shuriken", "InvisibilityTool", "ShadowCloneTool", "TeleportTool"}

shared.afy = not shared.afy

for i,v in getconnections(client.Idled) do
    v:Disable()
end

if (not safe_part) then
    local safe_part, random_coordinate = Instance.new('Part'), math.random(3500); do
        getgenv().safe_part = safe_part

        safe_part.Parent = workspace
        safe_part.Anchored = true
        safe_part.Size = Vector3.new(150,1,150)
        safe_part.CFrame = CFrame.new(Vector3.new(9999,10000,9999) + Vector3.new(random_coordinate))
    end
end

local click_button = function(button)
    virtualinputmanager:SendMouseButtonEvent(button.AbsolutePosition.X + button.AbsoluteSize.X / 2, button.AbsolutePosition.Y + gui_inset.Y + (button.AbsoluteSize.Y / 2), 0, true, button, 1);
    virtualinputmanager:SendMouseButtonEvent(button.AbsolutePosition.X + button.AbsoluteSize.X / 2, button.AbsolutePosition.Y + gui_inset.Y + (button.AbsoluteSize.Y / 2), 0, false, button, 1)
end

local sword_delay, shuriken_delay, class_delay, realm_delay = 0, 0, 0, 0
local auto_upgrade = function()
    local main_gui = playergui:WaitForChild('MainGui'):FindFirstChild("UpgradeF")
    local failed = playergui:WaitForChild('MainGui'):FindFirstChild("UpgradeFailedF")

    if (failed and failed.Visible) then
        task.delay(0.1, function()
            failed.Visible = false
        end)
    end

    if (main_gui) then
        local sword = main_gui["SwordF"]:FindFirstChild("MaxUpgradeBtn")
        local shuriken = main_gui["ShurikenF"]:FindFirstChild("ShurikenImgBtn")
        local class = main_gui["ClassF"]:FindFirstChild("ClassImgBtn")
        local realm = main_gui["AscendF"]:FindFirstChild("AscendImgBtn")

        if (sword and tick() - sword_delay > 5) then
            task.wait()
            click_button(sword)

            sword_delay = tick()
        end

        if (shuriken and tick() - shuriken_delay > 5) then
            task.wait()
            click_button(shuriken)

            shuriken_delay = tick()
        end

        if (class and tick() - class_delay > 5) then
            task.wait()
            click_button(class)
            
            class_delay = tick()
        end

        if (realm and tick() - realm_delay > 5) then
            task.wait()
            click_button(realm)
            
            realm_delay = tick()
        end
    end
end

while (shared.afy and task.wait()) do
    local char = client.Character

    if (char) then
        local root = char:FindFirstChild('HumanoidRootPart')

        if (root) then
            if (not safe_pos) then
                safe_pos = root.CFrame
                root.CFrame = safe_part.CFrame * CFrame.new(0, 3, 0)
            end

            local katana = (function()
                for i,v in (backpack:GetChildren()) do
                    if (table.find(backpack_filter, v.Name)) then continue end
        
                    return v
                end
            end)()
        
            if (katana) then
                katana.Parent = char
            end

            katana = char:FindFirstChildWhichIsA('Tool')

            if (katana) then
                katana:Activate()
            end

            auto_upgrade()
        end
    end
end

if (safe_pos) then
    local char = client.Character

    if (char) then
        local root = char:FindFirstChild('HumanoidRootPart')

        if (root) then
            root.CFrame = safe_pos
        end
    end
end
