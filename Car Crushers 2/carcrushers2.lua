local players = game:GetService("Players")
local replicatestorage = game:GetService("ReplicatedStorage")
local runservice = game:GetService("RunService")

local client = players.LocalPlayer
local car_collection = workspace.CarCollection
local gui_script = getsenv(client.PlayerGui:FindFirstChild("GUIs"))
local open_func = gui_script["OpenDealership"]
local spawn_func = gui_script["SpawnButton"]

local flags = {
    initial_spawn = 0,
    spawn_time = 0,
    last_flip = false,
}

local get_current_car, get_char, get_root, get_hum, retrieve_money, retrieve_best_car; do
    get_current_car = function()
        local car = car_collection:FindFirstChild(client.Name)
        local model = car and car:FindFirstChild('Car')

        local wheel_part = model and model:FindFirstChild('Wheels') and model.Wheels:FindFirstChildWhichIsA('Part')
        local engine_part = model and model:FindFirstChild('Body') and model.Body:FindFirstChild('Engine') and (model.Body.Engine:FindFirstChildWhichIsA('Part') or model.Body.Engine:FindFirstChildWhichIsA('MeshPart'))

        local broken_check = model and wheel_part and engine_part

        return broken_check and model.PrimaryPart and model
    end

    get_char = function(player)
        return player and player:IsA('Player') and player.Character
    end

    get_root = function(char)
        return char and char:FindFirstChild('HumanoidRootPart')
    end

    get_hum = function(char)
        return char and char:FindFirstChildWhichIsA('Humanoid')
    end

    retrieve_money = function()
        return client:FindFirstChild('Money') and client.Money.Value
    end

    spawn_check = function()
        return client:FindFirstChild('SpawnTimer') and client.SpawnTimer.Value <= 0
    end

    retrieve_best_car = function()
        open_func()
        spawn_func(true, Enum.UserInputState.Begin)
        flags.initial_spawn = os.clock()
    end

    destroy_car = function(car)
        if (os.clock() - flags.initial_spawn >= 30) then
            replicatestorage.rE.Delete:FireServer()
        end

        if (car and os.clock() - flags.spawn_time > 0.25) then
            flags.spawn_time = os.clock()
            flags.last_flip = not flags.last_flip

            car.PrimaryPart.Velocity = vector.create(0, 250 * (not flags.last_flip and 1 or -1), 0)
            car.PrimaryPart.CFrame *= CFrame.Angles(180, 0, 0)
        end
    end
end

shared.afy = not shared.afy

print(shared.afy)
while (shared.afy and task.wait()) do
    local char = get_char(client)
    local able_car = spawn_check()
    local current_car = get_current_car()

    if (current_car) then
        destroy_car(current_car)

    elseif (char and able_car) then
        retrieve_best_car()
    end
end
