-- https://www.roblox.com/games/17452754927/
local serverscriptservice = game:GetService("ServerScriptService")
local players = game:GetService('Players')

local client = players.LocalPlayer
shared.afy = not shared.afy

local get_job = function()
    local lowest, job = 0

    for i,v in pairs(client.PlayerGui.GUI.Center.Inventory.Holder.Scroller.Grid:GetChildren()) do
        if not (v:IsA('ImageButton')) then continue end
        local salary = v.Holder.MoreStats.Salary.Text:match('%d+')

        if (tonumber(salary) > lowest) then
            lowest = tonumber(salary)
            job = v
        end
    end

    return job
end

while (shared.afy and task.wait()) do
    local bestjob = get_job()

    task.spawn(function()
        serverscriptservice:FindFirstChild("Server"):FindFirstChild("Services"):FindFirstChild("PlayerService"):FindFirstChild("Functions"):FindFirstChild("Roll"):InvokeServer()
    end)

    if (bestjob) then
        task.spawn(function()
            serverscriptservice:FindFirstChild("Server"):FindFirstChild("Services"):FindFirstChild("PlayerService"):FindFirstChild("Functions"):FindFirstChild("EquipJob"):InvokeServer(bestjob.Name)
        end)
    end
end
