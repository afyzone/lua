-- https://www.roblox.com/games/12858663764

local players = game:GetService('Players')
local replicatedstorage = game:GetService('ReplicatedStorage')
local client = players.LocalPlayer

shared.afy = not shared.afy

local upgrade = function()
    for i, v in (client:WaitForChild('PlayerGui'):WaitForChild('JobMenus'):WaitForChild('Garbage Collector'):WaitForChild('Section_Upgrades'):WaitForChild('Upgrades'):GetChildren()) do
        if (not v:IsA('Frame')) then continue end
        if (v.Buy.Text == 'MAX') then continue end

        local args = {
            [1] = "UpgradePlayer",
            [2] = v.Name,
            [3] = 1/0
        }
        
        replicatedstorage.Remotes.GarbageCollector:FireServer(unpack(args))        
    end

    local progress = client:WaitForChild('PlayerGui'):WaitForChild('MainUI'):WaitForChild('BottomMiddle'):WaitForChild('Retire'):WaitForChild('Progress')
    if (progress.Text:find('100')) then
        replicatedstorage.Remotes.Remote:FireServer("Retire")
    end
end

local sell = function()
    if (client:GetAttribute('TaskLock')) then return end
    
    local cap = client:WaitForChild('PlayerGui'):WaitForChild('MainUI'):WaitForChild('BottomMiddle'):WaitForChild('Garbage'):WaitForChild('Capacity')
    local current, max = unpack(cap.Text:split(' / '))

    if (current ~= max) then return end

    local args = {
        [1] = "Garbage_ThrowGarbage",
        [2] = workspace.TrashBins.Trashbin_Large
    }
    
    replicatedstorage.Remotes.GarbageCollector:FireServer(unpack(args))    
end

local collect = function(garbage)
    if (client:GetAttribute('TaskLock')) then return end

    local args = {
        [1] = garbage:GetAttribute('Searched') and "Garbage_PickUp" or "Garbage_Search",
        [2] = garbage
    }
    
    replicatedstorage.Remotes.GarbageCollector:FireServer(unpack(args))
end

while (shared.afy and task.wait()) do
    local garbage = workspace.Garbage:GetChildren()[1]

    if (garbage) then 
        collect(garbage)
    end

    sell()
    upgrade()
end
