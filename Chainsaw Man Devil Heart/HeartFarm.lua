local spawn, moveto; do
    spawn = function()
        game:GetService("ReplicatedStorage"):WaitForChild("funs"):WaitForChild("SpawnPlayer"):InvokeServer()
    end

    moveto = function(pos, offset)
        if not isTweening and plr.Character and plr.Character:FindFirstChild('HumanoidRootPart') then
            local offset = offset or CFrame.new(0, 0, 0);
            local vec3, cframe;
            isTweening = false
            plr.Character.HumanoidRootPart.Anchored = true
            plr.Character.HumanoidRootPart.CFrame = ((pos.CFrame) * offset)
            plr.Character.HumanoidRootPart.Anchored = false
            isTweening = true
        end
    end;
end

local found;
for i,v in pairs(workspace:GetDescendants()) do
    if not (v:IsA('MeshPart') and v.MeshId == 'rbxassetid://12346512976') then continue end
    found = true
    if plr and plr.PlayerGui and plr.PlayerGui:FindFirstChild('Menu') then
        spawn()
        repeat task.wait() until plr and plr.Character and plr.Character:FindFirstChild('Humanoid') and not plr.Character:FindFirstChild('ForceField')
    end
    moveto(v)
    repeat task.wait() fireproximityprompt(v.ProximityPrompt) until not v or not v.ProximityPrompt
    break
end

if not found then
    local Next; repeat
        for i,v in next, game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100" .. ((Next and "&cursor="..Next) or ""))).data do
            if v.playing < v.maxPlayers and v.id ~= game.JobId then
                if pcall(game:GetService("TeleportService").TeleportToPlaceInstance, game:GetService("TeleportService"), game.PlaceId, v.id, game.Players.LocalPlayer) then break end
            end
        end
        Next = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100" .. ((Next and "&cursor="..Next) or ""))).nextPageCursor
    until not Next
end
