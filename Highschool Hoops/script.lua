--https://www.roblox.com/games/13876564679
-- Auto Guard, Auto Green

local services = setmetatable({}, {
    __index = function(self, key)
        local service = pcall(cloneref, game:FindService(key)) and cloneref(game:GetService(key)) or Instance.new(key)
        rawset(self, key, service)

        return rawget(self, key)
    end
})

local players = services.Players
local runservice = services.RunService
local statsservice = services.Stats
local virtualinputmanager = services.VirtualInputManager

local client = players.LocalPlayer
local playergui = client:WaitForChild('PlayerGui')
local random = Random.new()
local firing, target_position, body_velocity = false

local hoops = {}; do
    for i,v in (workspace.Hoops:GetDescendants()) do
        if (not v.Name:find('Hoop')) then continue end

        table.insert(hoops, v.Rim.Rim)
    end
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
        local factor = -0.00175 * statsservice.Network.ServerStatsItem['Data Ping']:GetValue() + 0.9

        factor = math.clamp(factor, 0.5, 1)

        return factor
    end
end

local con; con = runservice.Heartbeat:Connect(function()
    if (not shared.afy) then
        con:Disconnect()
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
        else
            body_velocity.Velocity = direction_xz.Unit * hum.WalkSpeed
        end
    else
        if (body_velocity) then
            body_velocity:Destroy()
            body_velocity = nil
        end
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

            local closest_ball_holder = get_closest_in_table(balls, 20)
            local closest_hoop = get_closest_in_table(hoops)

            if (closest_ball_holder and closest_hoop) then
                local hoop_dist = vector.magnitude(closest_hoop.Position - root.Position)
                local move_pos = position_between_two_instances(closest_ball_holder, closest_hoop, closest_ball_holder.Head.Position.Y > (char.Head.Position.Y + closest_ball_holder:GetAttribute('Height')) and hoop_dist > 12 and 1 or 5)

                if (move_pos) then
                    local direction = (move_pos - root.Position)

                    if (vector.magnitude(direction) > 1) then
                        target_position = move_pos
                    end
                end
            end
        end
    end
end
