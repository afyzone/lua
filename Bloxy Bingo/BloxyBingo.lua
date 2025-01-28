-- /// game.GameId == 5244411056 \\
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local SubContainer = LocalPlayer.PlayerGui.Bingo.StaticDisplayArea.Cards.PlayerArea.Cards.Container.SubContainer

local firebutton, GetCards; do
    firebutton = function(button)
        if button then
            for i, signal in pairs(getconnections(button.MouseButton1Click)) do
                signal:Fire()
            end
            for i, signal in pairs(getconnections(button.MouseButton1Down)) do
                signal:Fire()
            end
            for i, signal in pairs(getconnections(button.Activated)) do
                signal:Fire()
            end
        end
    end
    
    GetCards = function()
        return SubContainer:FindFirstChild("Blocks") and SubContainer.Blocks.Block or SubContainer.VerticalScroll.Cards
    end
end

while task.wait() do
    local Cards;
    local BingoButton = SubContainer.Buttons.ClaimButton
    Cards = GetCards()
    if Cards and BingoButton then
        for _, card in pairs(Cards:GetChildren()) do
            if card:IsA("Frame") then
                if card and card:FindFirstChild("Content") and card.Content:FindFirstChild("Numbers") then
                    for _, button in pairs(card.Content.Numbers:GetChildren()) do
                        firebutton(button)
                        task.wait()
                    end
                    if card and card:FindFirstChild("ToGo") and card.ToGo.ToGoText.Text == "BINGO!" then
                        firebutton(BingoButton)
                    end
                end
            end
        end
    end
end
