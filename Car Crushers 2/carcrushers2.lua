-- Services
local players = game:GetService("Players")
local replicatestorage = game:GetService("ReplicatedStorage")
local runservice = game:GetService("RunService")

-- Variables
local client = players.LocalPlayer
local car_collection = workspace.CarCollection
local gui_script = getsenv(client.PlayerGui:FindFirstChild("GUIs"))
local open_func = gui_script["OpenDealership"]
local spawn_func = gui_script["SpawnButton"]

-- Functions
local get_current_car, get_char, get_root, get_hum, retrieve_money, retrieve_best_car; do
    get_current_car = function()
        local car = car_collection:FindFirstChild(client.Name)
        local model = car and car:FindFirstChild('Car')

        local wheel_part = model and model:FindFirstChild('Wheels') and model.Wheels:FindFirstChildWhichIsA('Part')
        local engine_part = model and model:FindFirstChild('Body') and model.Body:FindFirstChild('Engine') and model.Body.Engine:FindFirstChild('Engine')

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
    end

    destroy_car = function()
        local char = get_char(client)
        local hum = get_hum(char)
        local root = get_root(char)

        local initial_spawn, spawn_time = os.clock(), os.clock()

        if (char and hum and root and get_current_car()) then
            while (os.clock() - initial_spawn < 30 and task.wait()) do
                local car = get_current_car()
                
                if (not car) then break end

                if (car and os.clock() - spawn_time > 0.25) then
                    spawn_time = os.clock()
                    last_flip = not last_flip

                    car.PrimaryPart.Velocity = vector.create(0, 250 * (not last_flip and 1 or -1), 0)
                    car.PrimaryPart.CFrame *= CFrame.Angles(180, 0, 0)
                end
            end
            
            replicatestorage.rE.Delete:FireServer()
        end
    end
end

-- Loop
shared.afy = not shared.afy

print(shared.afy)
while (shared.afy and task.wait()) do
    local char = get_char(client)
    local able_car = spawn_check()

    if (char and able_car) then
        retrieve_best_car()
        destroy_car()
    end
end
