-- https://www.roblox.com/games/104715542330896/BlockSpin

local Services = setmetatable({}, {
	__index = function(self, key)
		local Service = rawget(self, key) or pcall(cloneref, game:FindService(key)) and cloneref(game:GetService(key)) or Instance.new(key)
		rawset(self, key, Service)

		return rawget(self, key)
	end
})

local Players = Services.Players
local VirtualInputManager = Services.VirtualInputManager

local Client = Players.LocalPlayer
local PlayerGui = Client:WaitForChild('PlayerGui')

local HiddenFlags = {}

local GetChar, GetRoot, GetHum, MoveTo, SmartWait, SmartGet, HasTool; do
    GetChar = function(player)
        return player and player.Character
    end

    GetRoot = function(char)
        return char and char:FindFirstChild('HumanoidRootPart')
    end

    GetHum = function(char)
        return char and char:FindFirstChildWhichIsA('Humanoid')
    end

    GetATM = function()
        local Dist, Closest = math.huge, {}
		local Char = GetChar(Client)
		local Root = GetRoot(Char)

        if (Char and Root) then
            for i,v in (workspace.Map.Props:GetChildren()) do
                if (v.Name ~= 'ATM') then continue end
                if (v:GetAttribute('disabled')) then continue end
                if (v:GetAttribute('active_hack_tool') ~= (HasTool('HackToolPro') and 'HackToolPro' or 'HackToolBasic')) then continue end
                if (v.hacker.Value) then continue end

                for i,v2 in (v:GetChildren()) do
                    local prox = v2:FindFirstChildWhichIsA('ProximityPrompt')
                    if (not prox) then continue end

                    local mag = vector.magnitude(v2:GetPivot().Position - Root.Position)

                    if (mag < Dist) then
                        Closest = {v, prox}
                        Dist = mag
                    end
                end
            end
        end

        return unpack(Closest)
    end

	MoveTo = function(pos, increment)
		if (HiddenFlags.CurrentlyMoving) then return end
		HiddenFlags.CurrentlyMoving = true

		local Char = GetChar(Client)
		local Root = GetRoot(Char)
		local Increment = increment or 0.5

		if (Char and Root) then
			local Distance = vector.magnitude(pos - Root.Position)
			local Direction = vector.normalize(pos - Root.Position)
			local CurrentPos = Root.Position

			while (Distance > Increment) do
				CurrentPos += Direction * Increment
				Root.CFrame = CFrame.new(CurrentPos)
				Root.AssemblyLinearVelocity = vector.zero

				SmartWait()
				Distance = vector.magnitude(pos - CurrentPos)
			end
			Root.CFrame = CFrame.new(pos)
		end

		HiddenFlags.CurrentlyMoving = false
	end

    SmartWait = function(_delay, flags_key)
		local Char = GetChar(Client)
		local Root = GetRoot(Char)
		local StartTime = tick()

		if (Char and Root) then
			local InitCFrame = Root.CFrame

			while (shared.afy and Char and Root and (not flags_key or Flags[flags_key]) and tick() - StartTime <= (_delay or 1/60)) do
				task.wait(1/60)

				Root.CFrame = InitCFrame
				Root.AssemblyLinearVelocity = vector.zero

				for _, v in (Char:GetDescendants()) do
					if (v:IsA('BasePart')) then
						v.CanCollide = false
					end
				end
			end
		end
	end

    SmartGet = function(Inst, Obj)
        if (not Inst) then return end
        
        local Objects = Obj:split('.')
        local Current = Inst 

        for i, v in Objects do 
            if (not Current) then return end

            Current = Current:FindFirstChild(v)
        end 

        return Current
    end

    HasTool = function(tool_name)
        local ItemsScrollingFrame = SmartGet(PlayerGui, 'Items.ItemsHolder.ItemsScrollingFrame')

        if (ItemsScrollingFrame) then
            for i,v in (ItemsScrollingFrame:GetChildren()) do
                if (not v:IsA('ImageButton')) then continue end

                if (v.ItemName.Text == tool_name) then
                    return true
                end
            end
        else
            local InventoryButton = SmartGet(PlayerGui, 'Sidebar.SidebarSlider.SidebarHolder.SidebarHolderSlider.Holder.InventoryButton')

            if (InventoryButton) then
                for i,v in getconnections(InventoryButton.MouseButton1Click) do
                    v:Function()
                end
            end
        end
    end
end

shared.afy = not shared.afy
print(shared.afy)

while shared.afy and task.wait() do
    local Char = GetChar(Client)
    local Hum = GetHum(Char)
    local Root = GetRoot(Char)

    if (Char and Hum and Root) then
        if (Hum:GetStateEnabled(Enum.HumanoidStateType.Seated)) then
            Hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        end

        Root.AssemblyLinearVelocity = vector.create(0, 0.5, 0)
    end

    if (HasTool('HackToolPro') or HasTool('HackToolBasic')) then
        local SliderMinigameFrame = SmartGet(PlayerGui, 'SliderMinigame.SliderMinigameFrame')
        local Bar = SmartGet(SliderMinigameFrame, 'Bar')
        local Needle = SmartGet(Bar, 'Needle')
        local Target = SmartGet(Bar, 'Target')
    
        if (SliderMinigameFrame and SliderMinigameFrame.Visible and Bar and Needle and Target) then
            local NeedleX = Needle.Position.X.Scale
            local TargetX = Target.Position.X.Scale
            local TargetSize = Target.Size.X.Scale / 2

            if NeedleX >= (TargetX - TargetSize) and NeedleX <= (TargetX + TargetSize) then
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, nil, 0)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, nil, 0)
                SmartWait(0.2)
            end
        else
            local ATMHolder = SmartGet(PlayerGui, 'ATM.ATMHolder')
            local ATMHackButton = SmartGet(ATMHolder, 'ATMHomePage.Title.ATMHackButton')

            if (ATMHolder and ATMHolder.Visible and ATMHackButton) then
                for i,v in getconnections(ATMHackButton.MouseButton1Click) do
                    v:Function()
                end

                ATMHolder.Visible = false
            else
                local ATM, ATM_Prox = GetATM()

                if (ATM and ATM_Prox) then
                    MoveTo(ATM:GetPivot().Position + vector.create(0, -10, 0))
                    fireproximityprompt(ATM_Prox)
                end
            end
        end
    else
        MoveTo(workspace.Map.NPCs.AlleyWayGuy:GetPivot().Position + vector.create(0, -10, 0))

        fireproximityprompt(workspace.ConsumableShopZone_Illegal.ProximityPrompt)

        local ConsumableOptionsScrollingFrame = SmartGet(PlayerGui, 'ConsumableBuy.ConsumableOptionsHolder.ConsumableOptionsScrollingFrame')

        local function GetBuyTool(tool_name)
            for i,v in (ConsumableOptionsScrollingFrame:GetChildren()) do
                local Options = SmartGet(v, 'Item.Options')
                local ConsumableName = SmartGet(Options, 'ConsumableName')

                if (ConsumableName and ConsumableName.Text == tool_name) then
                    return Options
                end
            end
        end
        
        local ProTool = GetBuyTool('Pro Hack Tool')
        local ConsumableBuyButton = SmartGet(ProTool, 'ConsumableBuyButton')
        
        if (ConsumableBuyButton) then
            for i,v in getconnections(ConsumableBuyButton.MouseButton1Click) do
                v:Function()
            end
        end

        local BasicTool = GetBuyTool('Basic Hack Tool')
        local ConsumableBuyButton = SmartGet(BasicTool, 'ConsumableBuyButton')

        if (ConsumableBuyButton) then
            for i,v in getconnections(ConsumableBuyButton.MouseButton1Click) do
                v:Function()
            end
        end
    end
end
