local Material = loadstring(game:HttpGet("https://raw.githubusercontent.com/broreallyplayingthisgame/My-UI/main/materiului.lua"))()
local UI = Material.Load({Title = "afy - The Difficulty Machine: REVAMP",Style = 2,SizeX = 500,SizeY = 400,
ColorOverrides = {
    MainFrame = Color3.fromRGB(15,15,15),
    Minimise = Color3.fromRGB(68, 208, 255),
    MinimiseAccent = Color3.fromRGB(3, 188, 182),
    Maximise = Color3.fromRGB(25,255,0),
    MaximiseAccent = Color3.fromRGB(0,255,110),
    NavBar = Color3.fromRGB(255, 253, 253),
    NavBarAccent = Color3.fromRGB(14, 13, 13),
    NavBarInvert = Color3.fromRGB(15,15,15),
    TitleBar = Color3.fromRGB(30, 30, 30),
    TitleBarAccent = Color3.fromRGB(255,255,255),
    Overlay = Color3.fromRGB(30, 30, 30),
    Banner = Color3.fromRGB(30, 30, 30),
    BannerAccent = Color3.fromRGB(255,255,255),
    Content = Color3.fromRGB(85,85,85),
    Button = Color3.fromRGB(40, 40, 40),
    ButtonAccent = Color3.fromRGB(235, 235, 235),
    ChipSet = Color3.fromRGB(170, 170, 170),
    ChipSetAccent = Color3.fromRGB(100,100,100),
    DataTable = Color3.fromRGB(160,160,160),
    DataTableAccent = Color3.fromRGB(45,45,45),
    Slider = Color3.fromRGB(45,45,45),
    SliderAccent = Color3.fromRGB(235,235,235),
    Toggle = Color3.fromRGB(230, 230, 230),
    ToggleAccent = Color3.fromRGB(235, 235, 235),
    Dropdown = Color3.fromRGB(45, 45, 45),
    DropdownAccent = Color3.fromRGB(235,235,235),
    ColorPicker = Color3.fromRGB(10, 10, 10),
    ColorPickerAccent = Color3.fromRGB(235,235,235),
    TextField = Color3.fromRGB(55,55,55),
    TextFieldAccent = Color3.fromRGB(235,235,235),
}
})

-- // vars \\ -- 
local workspace = game:GetService('Workspace')
local http      = game:GetService("HttpService")
local Players   = game:GetService('Players')
local plr       = Players.LocalPlayer
local chr       = plr.Character or plr.CharacterAdded:Wait()
local rootPart  = chr.HumanoidRootPart or chr:WaitForChild("HumanoidRootPart")
local hitter = {}
local Settings  = {
    normalsell = 'Luck'
}

--[[ Preload ]]
workspace.Lobby.MainSpawn.Devices.DifficultySpawner.Click.ClickDetector.MaxActivationDistance = 9e9

for i,v in pairs(getconnections(plr.Idled)) do 
    v:Disable()
end

for i,v in pairs(workspace.Lobby.UpgradeRoom.Upgrades:GetChildren()) do
    table.insert(hitter, v.Name)
end

--[[ Test ]] 
local farm = UI.New({Title = "Farming"})
local cred = UI.New({Title = "Credits"})

--[[ Functions ]]
local getseller, clickbutton, sellblocks; do
    getseller = function()
        for i,v in pairs(workspace.Lobby.UpgradeRoom.Upgrades:GetChildren()) do
            if v.Name == Settings.normalsell then
                return v
            end
        end
    end

    clickbutton = function()
        fireclickdetector(workspace.Lobby.MainSpawn.Devices.DifficultySpawner.Click.ClickDetector)
    end

    sellblocks = function()
        for i,v in pairs(workspace.Difficulties:GetChildren()) do
            if v:IsA('BasePart') and isnetworkowner(v) then
                firetouchinterest(v, getseller(), 0)
                firetouchinterest(v, getseller(), 1)
            end
            if v:IsA('Model') and isnetworkowner(v.PrimaryPart) then
                firetouchinterest(v.PrimaryPart, getseller(), 0)
                firetouchinterest(v.PrimaryPart, getseller(), 1)
            end

            if v:IsA('BasePart') and isnetworkowner(v) then
                firetouchinterest(v, workspace.Lobby.MainSpawn.Devices.EraseDifficulties, 0)
                firetouchinterest(v, workspace.Lobby.MainSpawn.Devices.EraseDifficulties, 1)
            end
            if v:IsA('Model') and isnetworkowner(v.PrimaryPart) then
                firetouchinterest(v.PrimaryPart, workspace.Lobby.MainSpawn.Devices.EraseDifficulties, 0)
                firetouchinterest(v.PrimaryPart, workspace.Lobby.MainSpawn.Devices.EraseDifficulties, 1)
            end
        end
    end
end

--[[ Main ]]
farm.Toggle({
    Text = 'Auto Click Difficulties',
    Callback = function(v)
        Settings.enableautoclick = v
        while Settings.enableautoclick do task.wait()
            clickbutton()
        end
    end
})

farm.Dropdown({
    Text = 'Sell Difficulty Area',
    Options = hitter,
    Callback = function(v)
        Settings.normalsell = v
    end
})

farm.Toggle({
    Text = 'Auto Sell Difficulties',
    Callback = function(v)
        Settings.autosell = v
        while Settings.autosell do task.wait()
            sellblocks()
        end
    end
})

--[[ Credits ]]
cred.Button({
    Text = "Scripter | afy#0679",
    Callback = function()
        setclipboard("afy#0679")
    end
})

cred.Button({
    Text = "Discord | discord.gg/EPsZZ5fQd5",
    Callback = function()
        local req = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or getgenv().request or request
        setclipboard("discord.gg/EPsZZ5fQd5")
        req({
            Url = 'http://127.0.0.1:6463/rpc?v=1',
            Method = 'POST',
            Headers = {
                ['Content-Type'] = 'application/json',
                Origin = 'https://discord.com'
            },
            Body = game:GetService("HttpService"):JSONEncode({
                cmd = 'INVITE_BROWSER',
                nonce = game:GetService("HttpService"):GenerateGUID(false),
                args = {code = 'EPsZZ5fQd5'}
            })
        })
        
    end
})
