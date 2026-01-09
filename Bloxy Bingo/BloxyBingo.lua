-- /// game.GameId == 5244411056 \\
local Players = game:GetService('Players')
local Client = Players.LocalPlayer
local PlayerGui = Client:WaitForChild('PlayerGui')

getconnections(Client.Idled)[1]:Disconnect()

shared.afy = not shared.afy
print('[afy]', shared.afy)

while shared.afy and task.wait() do
    for Index, Button in PlayerGui.Bingo.StaticDisplayArea.Cards.PlayerArea.Cards.Container.SubContainer:GetDescendants() do
        local IsButton = Button:IsA('TextButton') or Button:IsA('ImageButton')
        if not IsButton then continue end
        
        if table.find({'Plus', 'Minus'}, Button.Name) then continue end

        for Index, Connection in getconnections(Button.Activated) do
            Connection:Function()
        end
    end
end
