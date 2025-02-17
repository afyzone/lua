-- https://www.roblox.com/games/7540727946/
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
local firing = false

local hoops = {}; do
    for i,v in (workspace.Courts:GetDescendants()) do
        if not (v:IsA('Model') and v.Name == 'Rim') then continue end

        table.insert(hoops, v)
    end
end

shared.afy = not shared.afy

local get_char, get_root, get_hum, get_closest_hoop, position_between_two_points, get_closest_in_table; do
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

    if (char and root and hum) then
        if (root.PlayerMeter.Enabled) then
            if (not firing) then
                firing = true
                root.PlayerMeter.Fill.UIGradient.Offset = Vector2.new(0, 0)

                task.spawn(function()
                    while (root.PlayerMeter.Fill.UIGradient.Offset.Y > -0.9) do task.wait() end
                    
                    virtualinputmanager:SendKeyEvent(false, 'E', false, nil)
                end)
            end
        else
            firing = false
        end

        local guarding = client.Values.guarding.Value
        local closest_hoop = get_closest_in_table(hoops)

        if (guarding and closest_hoop) then
            local ball_player_name = closest_hoop.Parent.Parent.Basketball.player.Value
            local ball_holder = ball_player_name and players:FindFirstChild(ball_player_name)
            local ball_character = ball_holder and ball_holder.Character

            if (ball_character) then
                local move_pos = position_between_two_points(ball_character, closest_hoop, random:NextNumber(4.8, 5.2))

                if (move_pos and vector.magnitude(move_pos - root.Position) > 0.2) then
                    hum.WalkToPoint = move_pos
                end
            end
        end
    end
end
