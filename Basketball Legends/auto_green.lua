-- https://www.roblox.com/games/14259168147/2X-Basketball-Legends
local players = game:GetService('Players')
local client = players.LocalPlayer
local playergui = client:WaitForChild('PlayerGui')

playergui.Visual.Shooting:GetPropertyChangedSignal('Visible'):Connect(function()
    if (playergui.Visual.Shooting.Visible) then
        task.delay(0.3, function()
            game:GetService("ReplicatedStorage").Packages.Knit.Services.ControlService.RE.Shoot:FireServer(100)
        end)
    end
end)
