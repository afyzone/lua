-- https://www.roblox.com/games/5829141886
local players = game:GetService('Players')
local client = players.LocalPlayer
local last_wheelset_time = 0

shared.afy = not shared.afy

local set_car = function(car, pos)
    for i,v in (car:GetDescendants()) do
        if (not v:IsA('BasePart')) then continue end
        
        v.CFrame = CFrame.new(v.CFrame.X, pos.Y, v.CFrame.Z)
        
        if (v:IsDescendantOf(car.Wheels)) then 
            if (os.clock() - last_wheelset_time > 0.2) then
            	v.CFrame = pos
            	last_wheelset_time = os.clock()
            end
            
            continue 
        end

        v.CanCollide = false
        v.CFrame = pos
    end
end

print(shared.afy)
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
