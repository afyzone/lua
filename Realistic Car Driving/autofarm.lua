-- https://www.roblox.com/games/5829141886
local players = game:GetService('Players')
local client = players.LocalPlayer

shared.afy = not shared.afy

local set_car = function(car, pos)
    for i,v in pairs(car:GetDescendants()) do
        if (not v:IsA('BasePart') or v:IsDescendantOf(car.Wheels)) then continue end

        v.CanCollide = false
        v.CFrame = pos
    end
end

while (shared.afy) do task.wait()
    local my_car = workspace:FindFirstChild(client.Name .. 'sCar')

    if (my_car) then
        local initial_pos = my_car.Body["#Weight"].CFrame * CFrame.new(0, 1, 0)

        while (shared.afy and my_car and initial_pos) do task.wait()
            my_car.Body["#Weight"]["#GRAVCOMP"].Force = Vector3.new(100000, 0, 100000)
            set_car(my_car, initial_pos)
        end
    end
end
