local virtualinputmanager = game:GetService("VirtualInputManager")
local players = game:GetService('Players')

local client = players.LocalPlayer
shared.auto_roll = not shared.auto_roll

local preferred_rarities = {
    'Epic',
    'Legendary'
}

local click_button = function(button)
    virtualinputmanager:SendMouseButtonEvent(button.AbsolutePosition.X + button.AbsoluteSize.X / 2, button.AbsolutePosition.Y + 50, 0, true, button, 1)
    virtualinputmanager:SendMouseButtonEvent(button.AbsolutePosition.X + button.AbsoluteSize.X / 2, button.AbsolutePosition.Y + 50, 0, false, button, 1)
end

local sanity_family = function(family: string, rarities: table)
    for i,v in rarities do
        if (family:find(v)) then
            return v
        end
    end
end

while (shared.auto_roll and task.wait()) do
    local current_family = client.PlayerGui.Interface.Customisation.Family.Family.Title.Text

    if (client.PlayerGui.Interface.Customisation.Family.Family.Title.Visible and not sanity_family(current_family, preferred_rarities)) then
        click_button(client.PlayerGui.Interface.Customisation.Family.Buttons_2.Roll)
    end
end
