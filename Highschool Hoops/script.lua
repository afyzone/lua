-- https://www.roblox.com/games/13876564679
-- Auto Guard, Auto Green

-- Off Ball Move to Player (Hold Q)
-- Hold to shoot

local services = setmetatable({}, {
    __index = function(self, key)
        local service = pcall(cloneref, game:FindService(key)) and cloneref(game:GetService(key)) or Instance.new(key)
        rawset(self, key, service)

        return rawget(self, key)
    end
})

local players = services.Players
local runservice = services.RunService
local virtualinputmanager = services.VirtualInputManager
local userinputservice = services.UserInputService

local client = players.LocalPlayer
local playergui = client:WaitForChild('PlayerGui')
local random = Random.new()
local additional_speed, last_e_release, firing, e_held, q_held, target_position, body_velocity, direction_anim, target_hold_player = 0, 0, false

shared.afy_flags = shared.afy_flags or {
    auto_block = false,
    auto_ankle_break = false,
    ball_reach = true
}

local hoops = {}; do
    if (workspace:FindFirstChild('Hoops')) then
        for i,v in (workspace.Hoops:GetDescendants()) do
            if (not v.Name:find('Hoop')) then continue end

            table.insert(hoops, v.Rim.Rim)
        end
    end
end

local ball_reach_handler = function(ball)
    local cloned_ball = ball:Clone(); do
        local og_size = ball.Size
        
        cloned_ball.Parent = v
        cloned_ball.Transparency = 0
        v.Transparency = 1
        v.Size = shared.afy_flags.ball_reach and vector.create(5, 5, 5) or og_size

        task.spawn(function()
            while (ball and cloned_ball) do
                v.Size = shared.afy_flags.ball_reach and vector.create(5, 5, 5) or og_size
                cloned_ball.CFrame = ball.CFrame
                task.wait()
            end
        end)
    end
end

workspace.Balls.ChildAdded:Connect(ball_reach_handler)
for i,v in (workspace.Balls:GetChildren()) do
    ball_reach_handler(v)
end

local get_char, get_root, get_hum, position_between_two_instances, get_closest_in_table, calculate_ping_factor; do
    get_char = function(player)
        return player.Character
    end

    get_root = function(char)
        return char and char:FindFirstChild('HumanoidRootPart')
    end

    get_hum = function(char)
        return char and char:FindFirstChildWhichIsA('Humanoid')
    end

    position_between_two_instances = function(instance, instance2, distance)
        local pivot_pos, pivot_pos2 = instance:GetPivot().Position, instance2:GetPivot().Position
        local magnitude = vector.magnitude(pivot_pos - pivot_pos2)

        return (pivot_pos):Lerp(pivot_pos2, distance / magnitude)
    end

    get_closest_in_table = function(tbl, range)
        local char = get_char(client)
        local root = get_root(char)
        local dist, closest = math.huge

        if not (char and root) then return end

        for i,v in (tbl) do
            local mag = vector.magnitude(v:GetPivot().Position - root.Position)

            if (range and mag > range) then continue end

            if (mag < dist) then
                closest = v
                dist = mag
            end
        end

        return closest, dist
    end

    calculate_ping_factor = function()
        local ping_text = playergui.TopbarStandard.Holders.Left.Widget.IconButton.Menu.IconSpot.Contents.IconLabelContainer.IconLabel.Text:gsub("[^%d%.]", "")
        local ping = tonumber(ping_text)
        local factor = -0.001 * ping + 0.9

        factor = math.clamp(factor, 0.5, 1)

        return factor
    end
end

if (not original_namecall) then
    getgenv().original_namecall = hookmetamethod(game, '__namecall', function(...)
        return old_namecall(...)
    end)
end

getgenv().old_namecall = function(...)
    if (not shared.afy) then return original_namecall(...) end

    local method, self, args = getnamecallmethod(), select(1, ...), {select(2, ...)}

    if (method == 'SetAttribute' and args[1] == 'Direction' and direction_anim) then
        local char = get_char(client)

        if (self == char) then
            args[2] = direction_anim

            return original_namecall(self, unpack(args))
        end
    end

    if (method == 'FireServer' and tostring(self) == 'Actions') then
        if (args[1] and args[1].Action == 'StartMeter') then
            args[1].Shift = false
            args[1].ShotType = 'Normal'
            args[1].ShotName = 'Reg'
        end

        return original_namecall(self, unpack(args))
    end

    return original_namecall(...)
end

local con; con = runservice.Heartbeat:Connect(function()
    if (not shared.afy) then
        return con:Disconnect()
    end

    local char = get_char(client)
    local root = get_root(char)
    local hum = get_hum(char)

    if not (char and root and hum) then return end
    
    if (not body_velocity) then
        body_velocity = Instance.new("BodyVelocity")
        body_velocity.Parent = root
        body_velocity.MaxForce = vector.create(math.huge, 0, math.huge)
    end
    
    local guarding = char:GetAttribute('Guarding')

    if (guarding and target_position) then
        local current_pos = root.Position
        local direction_xz = vector.create(target_position.X - current_pos.X, 0, target_position.Z - current_pos.Z)

        if direction_xz.magnitude < 1 then
            body_velocity.Velocity = vector.zero
            body_velocity:Destroy()
            body_velocity = nil
            target_position = nil

            direction_anim = nil
        else
            local normalized_dirxz = vector.normalize(direction_xz)
            body_velocity.Velocity = normalized_dirxz * (hum.WalkSpeed + additional_speed)
            root.Velocity = normalized_dirxz * (hum.WalkSpeed + additional_speed)

            local dot_right = vector.dot(normalized_dirxz, root.CFrame.RightVector)

            if (dot_right > 0) then
                direction_anim = 'R'
            else
                direction_anim = 'L'
            end
        end
    else
        if (body_velocity) then
            body_velocity:Destroy()
            body_velocity = nil

            direction_anim = nil
        end
    end
end)

local input_start_con; input_start_con = userinputservice.InputBegan:Connect(function(input, chat)
    if (not shared.afy) then
        return input_start_con:Disconnect()
    end

    if (chat) then return end

    if (input.KeyCode == Enum.KeyCode.E and not e_held and os.clock() - last_e_release > 0.2) then
        e_held = true
    end

    if (input.KeyCode == Enum.KeyCode.Q) then
        q_held = true
    end
end)

local input_ended_con; input_ended_con = userinputservice.InputEnded:Connect(function(input, chat)
    if (not shared.afy) then
        return input_ended_con:Disconnect()
    end

    if (chat) then return end

    if (input.KeyCode == Enum.KeyCode.E) then
        last_e_release = os.clock()
        e_held = false
    end

    if (input.KeyCode == Enum.KeyCode.Q) then
        q_held = false
    end
end)

local on_teleport, executed; on_teleport = client.OnTeleport:Connect(function()
    if (not shared.afy) then
        return on_teleport:Disonnect()
    end

    if (queue_on_teleport and not executed) then
        executed = true
        queue_on_teleport(`shared.afy_flags = {shared.afy_flags}; loadstring(game:HttpGet('https://raw.githubusercontent.com/afyzone/lua/refs/heads/main/Highschool%20Hoops/script.lua'))()`)
    end
end)

shared.afy = not shared.afy
print(shared.afy)

while (shared.afy and task.wait()) do
    local char = get_char(client)
    local root = get_root(char)
    local hum = get_hum(char)

    if (char and root and hum) then
        local meter = client:GetAttribute('MeterActive')
        
        if (meter) then
            if (not firing) then
                firing = true

                task.spawn(function()
                    while (client:GetAttribute('MeterActive') and client:GetAttribute('Meter') < calculate_ping_factor()) do task.wait() end
                    virtualinputmanager:SendKeyEvent(false, 'E', false, nil)
                end)
            end
        else
            firing = false
        end

        local client_ball = char:GetAttribute('HasBall')

        if (shared.afy_flags.auto_ankle_break and client_ball) then
            for i,v in (players:GetPlayers()) do
                local t_char = get_char(v)
                local t_root = get_root(t_char)

                if (v == client or not t_root) then continue end

                local mag = vector.magnitude(t_root.Position - root.Position)
                if (mag > 12) then continue end

                local t_reaching = t_char:GetAttribute('Reach')

                if (t_reaching) then
                    virtualinputmanager:SendKeyEvent(true, 'A', false, nil)
                    virtualinputmanager:SendKeyEvent(true, 'Z', false, nil)
                    virtualinputmanager:SendKeyEvent(false, 'A', false, nil)
                    virtualinputmanager:SendKeyEvent(false, 'Z', false, nil)
                end
            end
        end

        local guarding = char:GetAttribute('Guarding')

        if (guarding) then
            local balls = {}; do
                for i,v in (workspace.Balls:GetChildren()) do
                    local ball_owner_name = v:GetAttribute('CurrentOwner')

                    if (ball_owner_name and ball_owner_name ~= '') then 
                        local ball_owner = players:FindFirstChild(ball_owner_name)
                        local ball_owner_char = ball_owner and get_char(ball_owner)

                        if (ball_owner_char) then
                            table.insert(balls, ball_owner_char)
                        end
                    end
                end
            end

            local closest_ball_holder = get_closest_in_table(balls, 15)
            local closest_ball_holder_root = closest_ball_holder and get_root(closest_ball_holder)
            local closest_hoop = get_closest_in_table(hoops)

            if (closest_ball_holder and closest_ball_holder_root and closest_hoop) then
                local hoop_dist = vector.magnitude(closest_hoop.Position - root.Position)

                local target_layuping = closest_ball_holder_root:FindFirstChild('Movement') and vector.magnitude(closest_ball_holder_root.Movement.Velocity)
                local target_shooting = closest_ball_holder:GetAttribute('Shooting')
                local target_dunking = closest_ball_holder:GetAttribute('Dunking')
                local target_posting = closest_ball_holder:GetAttribute('Posting')

                local close_in;

                if (target_dunking) then
                    close_in = false
                else
                    local first_condition = (hoop_dist < 20 and target_layuping and target_layuping > 7.5)
                    local second_condition = (target_shooting and hoop_dist > 10)
                    
                    close_in = (first_condition or second_condition)
                end

                additional_speed = close_in and 0 or 0
                local distance = target_posting and 10 or 6

                local move_pos = position_between_two_instances(closest_ball_holder_root, closest_hoop, close_in and 2 or distance)

                if (move_pos) then
                    local direction = (move_pos - root.Position)

                    if (vector.magnitude(direction) > 1) then
                        if (shared.afy_flags.auto_block) then
                            local closest_ball = get_closest_in_table(workspace.Balls:GetChildren())
    
                            if (closest_ball and closest_ball:GetAttribute('Blockable')) then
                                virtualinputmanager:SendKeyEvent(true, 'Space', false, nil)
                                virtualinputmanager:SendKeyEvent(false, 'Space', false, nil)
                            end
                        end

                        target_position = move_pos
                        hum.WalkToPoint = move_pos
                    end
                end
            end
        end

        if (q_held) then
            local t_chars = {}; do
                for i,v in (players:GetPlayers()) do
                    if (v == client or not v.Character) then continue end

                    table.insert(t_chars, v.Character)
                end
            end

            local closest_ball = get_closest_in_table(workspace.Balls:GetChildren())

            local closest_player = get_closest_in_table(t_chars)
            target_hold_player = target_hold_player or closest_player and get_root(closest_player)

            if (closest_ball and target_hold_player) then
                local move_pos = position_between_two_instances(target_hold_player, closest_ball, 4)

                if (move_pos) then
                    local direction = (move_pos - root.Position)

                    if (vector.magnitude(direction) > 0.2) then
                        hum.WalkToPoint = move_pos
                    end
                end
            end
        else
            target_hold_player = nil
        end

        if (e_held) then
            virtualinputmanager:SendKeyEvent(true, 'E', false, nil)
        end
    end
end
