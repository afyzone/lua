-- https://www.roblox.com/games/73956553001240/

local modified_range = 14

local fake_view;

workspace.ChildAdded:Connect(function(child)
    if (not child:FindFirstChild('OnHit')) then return end

    if (fake_view) then
        fake_view:Destroy()
        fake_view = nil
    end

    fake_view = child.PrimaryPart:Clone(); do
        fake_view.Parent = child
    end

    child.PrimaryPart.Transparency = 1
    child.PrimaryPart.Size = vector.create(modified_range, modified_range, modified_range)
end)
