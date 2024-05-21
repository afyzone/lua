-- https://www.roblox.com/games/17348055576
local runservice = game:GetService('RunService')
local replicatedstorage = game:GetService("ReplicatedStorage")
local tools = {
    "Weight",
    "Skill",
    "Punch",
}

runservice.PreRender:Connect(function()
    for _,v in (tools) do
        replicatedstorage:FindFirstChild("Remote"):FindFirstChild("Event"):FindFirstChild("Tool"):FindFirstChild("[C-S]TryEquipTool"):FireServer(v)
        replicatedstorage:FindFirstChild("Remote"):FindFirstChild("Event"):FindFirstChild("Game"):FindFirstChild("[C-S]TryClick"):FireServer()
    end

    replicatedstorage:FindFirstChild("Remote"):FindFirstChild("Event"):FindFirstChild("Eco"):FindFirstChild("[C-S]PlayerTryRebirth"):FireServer()
end)
