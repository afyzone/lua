-- https://www.roblox.com/games/7647631063/

local Players = game:GetService('Players')
local TextChatService = game:GetService('TextChatService')
local Client = Players.LocalPlayer
local LastHit, Connections = 0, {}

local GetChar, CharacterAdded, CreateConnection; do
	GetChar = function(player)
		return player and player.Character
	end
    
    CharacterAdded = function(Char)
        if (not Char) then return end

        for i,v in (Connections) do
            v:Disconnect()
            v = nil
        end

        for i,v in workspace.Quiz:GetDescendants() do
            if (not v:IsA('TouchTransmitter')) then continue end

            local Part = v.Parent
            
            CreateConnection(Part.Touched, function(HitPart)
                if (Part.Transparency ~= 1 and tick() - LastHit > 1 and HitPart:IsDescendantOf(Char)) then
                    local Answers = Part.Script.Answers.Value:split('|')

                    local Random = math.random(#Answers)
                    local Answer = Answers[Random]

                    TextChatService.TextChannels.RBXGeneral:SendAsync(Answer)
                    LastHit = tick()
                end
            end)
        end
    end

    CreateConnection = function(signal, func)
        local Conn = signal:Connect(func)
        table.insert(Connections, Conn)

        return Conn
    end
end

CharacterAdded(Client.Character)
CreateConnection(Client.CharacterAdded, CharacterAdded)

shared.afy = not shared.afy
print(shared.afy)

while (shared.afy and task.wait()) do end

for i,v in (Connections) do
    v:Disconnect()
    v = nil
end
