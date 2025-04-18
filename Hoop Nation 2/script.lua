-- https://www.roblox.com/games/15558033314/
-- Features: Auto Green, Auto Guard

shared.afy = not shared.afy

local services = setmetatable({}, {
    __index = function(self, key)
        local service = pcall(cloneref, game:FindService(key)) and cloneref(game:GetService(key)) or Instance.new(key)
        rawset(self, key, service)

        return rawget(self, key)
    end
})

local players = services.Players
local replicatedstorage = services.ReplicatedStorage
local virtualinputmanager = services.VirtualInputManager

local client = players.LocalPlayer
local random = Random.new()
local firing = false

local hoops = {}; do
    for i,v in (workspace.Courts:GetChildren()) do
        for i,v in (v:GetChildren()) do
            if (not v.Name:find('Hoop')) then continue end

            table.insert(hoops, v)
        end

        if (not v.Name:find('Hoop')) then continue end

        table.insert(hoops, v)
    end
end

local get_char, get_root, get_hum, position_between_two_points, get_closest_player, get_closest_in_table; do
    get_char = function(player)
        return player.Character
    end

    get_root = function(char)
        return char and char:FindFirstChild('HumanoidRootPart')
    end

    get_hum = function(char)
        return char and char:FindFirstChildWhichIsA('Humanoid')
    end

    position_between_two_points = function(instance, instance2, distance)
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

print(shared.afy)
while (shared.afy and task.wait()) do
    local char = get_char(client)
    local root = get_root(char)
    local hum = get_hum(char)

    if (char and hum and root) then
        local meter = char:FindFirstChild('Meter')
        local uigradient = meter.Meter.Bar.UIGradient
        local t = uigradient.Transparency.Keypoints

        if (t) then 
            local second_keypoint = t[2]
            local third_keypoint = t[3]

            if (second_keypoint and second_keypoint.Time > 0.95 and third_keypoint and third_keypoint.Time > 0.95) then
                virtualinputmanager:SendKeyEvent(false, 'E', false, nil)
            end
        end

        local closest_hoop = get_closest_in_table(hoops)
        local blocking = root:FindFirstChild('BodyGyro')

        local ball_holders = {}; do
            for i,v in (workspace.Courts:GetDescendants()) do
                if not (v.Name == 'Basketball' and v:FindFirstChild('Player')) then continue end
                
                if (v.Player.Value) then
                    table.insert(ball_holders, v.Player.Value.Character)
                end
            end
        end
        
        local closest_ball_holder = get_closest_in_table(ball_holders, 15)
        local closest_ball_holder_root = get_root(closest_ball_holder)
        local is_shooting = closest_ball_holder_root and closest_ball_holder_root:FindFirstChild('BodyGyro')

        if (blocking and closest_ball_holder and closest_hoop) then
            local move_pos = position_between_two_points(closest_ball_holder, closest_hoop, is_shooting and random:NextNumber(1.8, 2.2) or random:NextNumber(6.8, 7.2))

            if (move_pos and vector.magnitude(move_pos - root.Position) > 0.2) then
                hum.WalkToPoint = move_pos
            end
        end
    end
end
