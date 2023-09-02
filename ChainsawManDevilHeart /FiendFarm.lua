local players = game:GetService('Players')
local workspace = game:GetService('Workspace')
local RunService = game:GetService('RunService')
local TeleportService = game:GetService('TeleportService')
local plr = players.LocalPlayer

--[[ Preload ]] do
    game:GetService("LogService").MessageOut:Connect(function(Message)
        if string.find(Message, "Server Kick Message:") then
            TeleportService:Teleport(game.PlaceId)
        end
    end)

    clonefunction(loadstring)([[
        local old; old = hookmetamethod(game, '__namecall', function(self, ...) 
            local args = {...}

            if (getnamecallmethod() == "Kick" or getnamecallmethod() == "kick") then
                return
            end

            if getnamecallmethod() == 'InvokeServer' and self.Name == 'check' then
                return
            end

            if (getnamecallmethod() == 'FireServer' and args[1] == 'SprintBurst' or args[1] == 'KickBack') then 
                return 
            end
        
            return old(self, ...)
        end)
    ]])

    plr.DevCameraOcclusionMode = "Invisicam"
    if plr and plr.PlayerScripts and plr.PlayerScripts:FindFirstChild('Effects') then
        plr.PlayerScripts.Effects.Disabled = true
        plr.PlayerScripts.Effects:Destroy()
    end
end

local moveto, click_button, get_quest, closest_npc, gotomob, attack, antifall, nocooldown, kill_fiends; do
    moveto = function(pos, offset)
        if plr.Character and plr.Character:FindFirstChild('HumanoidRootPart') then
            local offset = offset or CFrame.new(0, 0, 0)
            plr.Character.HumanoidRootPart.CFrame = (((typeof(pos) == 'CFrame' and pos) or (typeof(pos) == 'Vector3' and CFrame.new(pos)) or pos.CFrame) * offset)
        end
    end;

    click_button = function(button)
        game:GetService("VirtualInputManager"):SendMouseButtonEvent(button.AbsolutePosition.X + button.AbsoluteSize.X / 2, button.AbsolutePosition.Y + 50, 0, true, button, 1);
        game:GetService("VirtualInputManager"):SendMouseButtonEvent(button.AbsolutePosition.X + button.AbsoluteSize.X / 2, button.AbsolutePosition.Y + 50, 0, false, button, 1)
    end

    get_quest = function()
        if not plr.PlayerGui:FindFirstChild('Quest') then
            repeat task.wait()
                repeat task.wait()
                    moveto(game:GetService("Workspace").DialogNPCs["grown up boy"].HumanoidRootPart, CFrame.new(0,6,0))
                    fireproximityprompt(game:GetService("Workspace").DialogNPCs["grown up boy"].ProximityPrompt)
                until plr:FindFirstChild('PlayerGui') and plr.PlayerGui:FindFirstChild('ProximityPrompts') and plr.PlayerGui.ProximityPrompts:FindFirstChild('Prompt') and plr.PlayerGui.ProximityPrompts.Prompt:FindFirstChild('TextButton') or plr.PlayerGui:FindFirstChild('Quest')
                
                if plr:FindFirstChild('PlayerGui') and plr.PlayerGui:FindFirstChild('dialogGUI') then
                    click_button(plr.PlayerGui.dialogGUI.f.sf.option.text)
                end
            until plr and plr.PlayerGui:FindFirstChild('Quest')
        elseif plr.PlayerGui.Quest.Completed.Visible == true then
            click_button(plr.PlayerGui.Quest.Completed.Yes)
        end
    end

    closest_npc = function()
        local dist = math.huge
        for i,v in pairs(game:GetService("Workspace").Living:GetChildren()) do
            if not (string.find(v.Name, 'Fiend') and v.Humanoid.Health > 0 and plr.Character:FindFirstChild('HumanoidRootPart') and (v.PrimaryPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude < dist) then continue end
            
            return v
        end
    end

    gotomob = function(mob)
        if (mob and mob.PrimaryPart ~= nil) then
            moveto(CFrame.new(mob.PrimaryPart.Position + Vector3.new(0, 7, 3), mob.PrimaryPart.Position))
            if (isnetworkowner(mob.PrimaryPart)) then
                for i,v in pairs(mob:GetChildren()) do
                    if not v:IsA('BasePart') then continue end
                    
                    v.Size = Vector3.new(25, 25, 25)
                    v.CanCollide = false
                    v.Transparency = 1
                    
                    if v.Name == 'Head' then
                        for i,v2 in pairs(v:GetChildren()) do
                            v2:Destroy()
                        end
                    end
                end
            end
        end
    end

    attack = function(mob)
        if plr.Character and plr.Character:FindFirstChild('HumanoidRootPart') and mob and mob.PrimaryPart and (mob.PrimaryPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude < 30 then
            game:GetService("ReplicatedStorage").events.remote:FireServer("NormalAttack");
            game:GetService("ReplicatedStorage").events.remote:FireServer("StrongAttack");
        end
    end

    antifall = function()
        if plr.Character and plr.Character:FindFirstChild('HumanoidRootPart') then
            plr.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
        end
    end

    nocooldown = function()
        if plr and plr.Character and plr.Character:FindFirstChild('Weapon') and plr.Character.Weapon.weapon.Handle.Enabled == true then
            plr.Character.Weapon.weapon.Handle.Enabled = false
        end
    end

    kill_fiends = function()
        local closest_npc = closest_npc()
        repeat task.wait()
            antifall()
            nocooldown()
            get_quest()
            gotomob(closest_npc)
            attack(closest_npc)
        until not closest_npc or not closest_npc.PrimaryPart or (closest_npc:FindFirstChild('Humanoid') and closest_npc.Humanoid.Health == 0)
        task.wait(5)
    end
end

--[[ Main ]] do
    while task.wait() do
        kill_fiends()
    end
end
