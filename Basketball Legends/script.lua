-- https://www.roblox.com/games/14259168147/
-- Auto Guard, Auto Green, Mag, Easier block

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
local playergui = client:WaitForChild('PlayerGui')
local random = Random.new()

local baskets = {}; do
    for i,v in (workspace.Game:GetChildren()) do
        if v:IsA('Model') and v.Name:find('Basket') then
            table.insert(baskets, v)
        end
    end

    if (workspace.Game:FindFirstChild('Courts')) then
        for i,v in (workspace.Game.Courts:GetChildren()) do
            for i,v in (v:GetChildren()) do
                if v:IsA('Model') and v.Name:find('Basket') then
                    table.insert(baskets, v)
                end
            end
        end
    end
end

local get_char, get_root, get_hum, position_between_two_instances, get_closest_in_table; do
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
end


local auto_green = playergui:WaitForChild('Visual'):WaitForChild('Shooting'):GetPropertyChangedSignal('Visible'):Connect(function()
    if (not shared.afy) then
        auto_green:Disonnect()
    end

    if (playergui.Visual.Shooting.Visible) then
        local start_time = os.clock()
        while (os.clock() - start_time <= 0.3285) do
            task.wait()
        end

        replicatedstorage.Packages.Knit.Services.ControlService.RE.Shoot:FireServer(random:NextNumber() >= 0.5 and 0.996 or 0.99)
        virtualinputmanager:SendKeyEvent(false, Enum.KeyCode.E, false, nil)
    end
end)

shared.afy = not shared.afy
print('shared.afy', shared.afy)

while (shared.afy and task.wait()) do
    local char = get_char(client)
    local root = get_root(char)
    local hum = get_hum(char)

    if not (char and root and hum) then return end

    for i,v in (workspace:GetChildren()) do
        if (not v:IsA('Part') or v.Name ~= 'Basketball') then continue end

        local mag = vector.magnitude(v.Position - root.Position)

        if (mag < 6) then
            firetouchinterest(v, root, 0)
        end
    end

    local player_with_ball = (function()
        local dist, closest = math.huge
    
        for _, v in (players:GetPlayers()) do
            if (v == client) then continue end

            local p_char = v.Character
            local p_root = p_char and p_char:FindFirstChild('HumanoidRootPart')

            if p_root and p_char:FindFirstChild("Basketball") then
                local distance = vector.magnitude(p_root.Position - root.Position)

                if (distance > 25) then continue end
    
                if (distance < dist) then
                    dist = distance
                    closest = p_char
                end
            end
        end
    
        return closest
    end)()

    if (player_with_ball) then
        local mag = vector.magnitude(player_with_ball.HumanoidRootPart.Position - root.Position)

        if (mag < 6 and player_with_ball:FindFirstChild('Basketball') and player_with_ball.Basketball:FindFirstChild('Attach')) then
            firetouchinterest(player_with_ball.Basketball.Attach, root, 0)
        end

        if (char:GetAttribute('Guarding')) then
            local closest_hoop, hoop_dist = get_closest_in_table(baskets)

            if (closest_hoop) then
                if (hoop_dist <= 15 and player_with_ball.Head.Position.Y > (char.Head.Position.Y + 1)) then
                    virtualinputmanager:SendKeyEvent(true, 'Space', false, nil)
                end

                local lerpto_position = position_between_two_instances(player_with_ball.HumanoidRootPart, closest_hoop, player_with_ball.Head.Position.Y > (char.Head.Position.Y + 1) and 1 or 6)
                
                if vector.magnitude(lerpto_position - root.Position) > 0.2 then
                    hum.WalkToPoint = lerpto_position
                end
            end
        end
    end
end
