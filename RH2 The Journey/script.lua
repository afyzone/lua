-- https://www.roblox.com/games/6549794549/
-- Auto Guard, Auto Green

local services = setmetatable({}, {
    __index = function(self, key)
        local service = pcall(cloneref, game:FindService(key)) and cloneref(game:GetService(key)) or Instance.new(key)
        rawset(self, key, service)

        return self[key]
    end
})

local players = services.Players
local virtualinputmanager = services.VirtualInputManager

local client = players.LocalPlayer
local random = Random.new()
local color_rgb = Color3.fromRGB
local white_color = color_rgb(200, 200, 200)
local dark_brown = color_rgb(80, 63, 16)
local firing, connection, body_gyro_con = false
local moves = {
    ['W'] = nil,
    ['A'] = nil,
    ['S'] = nil,
    ['D'] = nil,
}

local hoops = {}; do
    for i,v in (workspace:GetDescendants()) do
        if (not v.Name:find('Hoop')) then continue end

        table.insert(hoops, v)
    end
end

local get_char, get_root, get_hum, setup_shoot, position_between_two_instances, get_closest_in_table; do
    get_char = function(player)
        return player.Character
    end

    get_root = function(char)
        return char and char:FindFirstChild('HumanoidRootPart')
    end

    get_hum = function(char)
        return char and char:FindFirstChildWhichIsA('Humanoid')
    end

    setup_shoot = function()
        virtualinputmanager:SendKeyEvent(false, 'E', false, nil)

        if (connection) then
            connection:Disconnect()
            connection = nil
        end
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
end

shared.afy = not shared.afy

client.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild('Humanoid')

    local forward_anim = Instance.new("Animation")
    forward_anim.AnimationId = "rbxassetid://10053690711"

    local backward_anim = Instance.new("Animation")
    backward_anim.AnimationId = "rbxassetid://10053509687"

    local left_anim = Instance.new("Animation")
    left_anim.AnimationId = "rbxassetid://10048687356"

    local right_anim = Instance.new("Animation")
    right_anim.AnimationId = "rbxassetid://10048696265"

    moves['W'] = hum:LoadAnimation(forward_anim)
    moves['A'] = hum:LoadAnimation(left_anim)
    moves['S'] = hum:LoadAnimation(backward_anim)
    moves['D'] = hum:LoadAnimation(right_anim)
end)

if (client.Character) then
    local hum = client.Character:FindFirstChild('Humanoid')

    local forward_anim = Instance.new("Animation")
    forward_anim.AnimationId = "rbxassetid://10053690711"

    local backward_anim = Instance.new("Animation")
    backward_anim.AnimationId = "rbxassetid://10053509687"

    local left_anim = Instance.new("Animation")
    left_anim.AnimationId = "rbxassetid://10048687356"

    local right_anim = Instance.new("Animation")
    right_anim.AnimationId = "rbxassetid://10048696265"

    moves['W'] = hum:LoadAnimation(forward_anim)
    moves['A'] = hum:LoadAnimation(left_anim)
    moves['S'] = hum:LoadAnimation(backward_anim)
    moves['D'] = hum:LoadAnimation(right_anim)
end

print(shared.afy)
while (shared.afy and task.wait()) do
    local char = get_char(client)
    local root = get_root(char)
    local hum = get_hum(char)

    if (char and root and hum) then
        local head = char:FindFirstChild('Head')
        local meter = head and head:FindFirstChild('MeterUi Overhead')

        if (meter) then
            if (meter.Enabled) then
                if (not firing) then
                    firing = true
                    
                    if (not body_gyro_con) then
                        body_gyro_con = root:WaitForChild('BodyGyro'):GetPropertyChangedSignal('P'):Once(function()
                            last_shot_type = root.BodyGyro.P
                            body_gyro_con = nil
                        end)
                    end

                    task.spawn(function()
                        while (meter.Bar[30].BackgroundColor3 == dark_brown) do task.wait() end

                        local bar_count = 0; do
                            for i,v in (meter.Bar:GetChildren()) do
                                if (v.BackgroundColor3 ~= white_color) then continue end

                                bar_count += 1
                            end
                        end

                        for i,v in (meter.Bar:GetChildren()) do
                            if (v.BackgroundColor3 ~= white_color) then continue end

                            local close_floater = char:FindFirstChild('inFinishing')

                            local percent_offset = last_shot_type == 3000         and  0.172 or 0.12
                            percent_offset += close_floater                       and  0.028 or 0
                            percent_offset += bar_count < 4                       and  0.050 or 0
                            percent_offset += vector.magnitude(root.Velocity) > 3 and -0.050 or 0

                            local number_children = #meter.Bar:GetChildren()
                            local offset = math.floor(number_children * percent_offset)
                            local offset_i = i - offset
                            local new_index = offset_i < 30 and 30 or offset_i > number_children and number_children or offset_i

                            local new_setup = meter.Bar[new_index]

                            -- print(`moving shot: {last_shot_type == 3000}, percent_offset: {percent_offset}, bar_count: {bar_count}, close floater: {close_floater}, index: {new_index}, velocity: {vector.magnitude(root.Velocity)}`)

                            if (not connection) then
                                connection = new_setup:GetPropertyChangedSignal('BackgroundColor3'):Once(setup_shoot)
                                break
                            end
                        end
                    end)
                end
            else
                meter.Bar[30].BackgroundColor3 = dark_brown
                last_shot_type = nil
                firing = false
            end
        end

        local guarding = char:FindFirstChild('Currently_Guarding')

        if (guarding) then
            local balls = {}; do
                for i,v in (workspace.Balls:GetChildren()) do
                    local ball_owner_name = v.Values.LastOwner.Value

                    if (ball_owner_name and ball_owner_name ~= '') then 
                        local ball_owner = players:FindFirstChild(ball_owner_name)
                        local ball_owner_char = ball_owner and ball_owner.Character

                        if (ball_owner_char) then
                            table.insert(balls, ball_owner_char)
                        end
                    end
                end
            end

            local closest_ball_holder = get_closest_in_table(balls, 15)
            local closest_hoop = get_closest_in_table(hoops)

            if (closest_ball_holder and closest_hoop) then
                local move_pos = position_between_two_instances(closest_ball_holder, closest_hoop, closest_ball_holder.Ball.Position.Y > closest_ball_holder.Head.Position.Y and random:NextInteger(1.8, 2.2) or random:NextInteger(4.8, 5.2))

                if (move_pos) then
                    local direction = move_pos - root.Position

                    if (vector.magnitude(direction) > 0.2) then
                        hum.WalkToPoint = move_pos

                        direction = vector.create(direction.X, 0, direction.Z).Unit
                        
                        local forward   = vector.create(root.CFrame.LookVector.X,  0, root.CFrame.LookVector.Z).Unit
                        local right     = vector.create(root.CFrame.RightVector.X, 0, root.CFrame.RightVector.Z).Unit
                        
                        local dot_forward = vector.dot(direction, forward)
                        local dot_right = vector.dot(direction, right)
                        
                        if (math.abs(dot_forward) > math.abs(dot_right)) then
                            if (dot_forward > 0) then
                                moves['S']:Stop()
                                moves['A']:Stop()
                                moves['D']:Stop()
                                moves['W']:Play()
                            else
                                moves['W']:Stop()
                                moves['A']:Stop()
                                moves['D']:Stop()
                                moves['S']:Play()
                            end
                        else
                            if (dot_right > 0) then
                                moves['S']:Stop()
                                moves['A']:Stop()
                                moves['W']:Stop()
                                moves['D']:Play()
                            else
                                moves['S']:Stop()
                                moves['W']:Stop()
                                moves['D']:Stop()
                                moves['A']:Play()
                            end
                        end
                    end
                end
            end
        else
            moves['W']:Stop()
            moves['A']:Stop()
            moves['S']:Stop()
            moves['D']:Stop()
        end
    end
end
