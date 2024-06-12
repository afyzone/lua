local yield_on = {
    'Epic',
    'Legendary'
}

local cloneref = cloneref or function(o) return o end
local virtualinputmanager = cloneref(game:GetService("VirtualInputManager"))
local players = cloneref(game:GetService('Players'))

local client = players.LocalPlayer

shared.afy = not shared.afy

while (shared.afy and task.wait()) do
    local playergui = client:WaitForChild('PlayerGui')
    local roll_button = playergui.Interface.Customisation.Family.Buttons_2.Roll
    local family = playergui.Interface.Customisation.Family.Family.Title

    if (family.Visible) then
        local flag;
        for i,v in (yield_on) do
            if (family.Text:find(v)) then
                shared.afy = false
                flag = true
            end
        end
        
        if (not flag) then
            virtualinputmanager:SendMouseButtonEvent(roll_button.AbsolutePosition.X + roll_button.AbsoluteSize.X / 2, roll_button.AbsolutePosition.Y + 50, 0, true, roll_button, 1)
            virtualinputmanager:SendMouseButtonEvent(roll_button.AbsolutePosition.X + roll_button.AbsoluteSize.X / 2, roll_button.AbsolutePosition.Y + 50, 0, false, roll_button, 1)
            task.wait()
        end
    end
end
