-- https://www.roblox.com/games/104715542330896/BlockSpin

local Flags = {
	StaminaFarm = true,
}

local Services = setmetatable({}, {
	__index = function(self, key)
		local Service = rawget(self, key) or pcall(game.FindService, game, key) and game:GetService(key) or Instance.new(key)
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
				-- if (v:GetAttribute('active_hack_tool') ~= (HasTool('HackToolPro') and 'HackToolPro' or 'HackToolBasic')) then continue end
				if (v.hacker.Value) then continue end

				for i,v2 in (v:GetChildren()) do
					local ProximityPrompt = v2:FindFirstChildWhichIsA('ProximityPrompt')
					if (not ProximityPrompt) then continue end

					local Magnitude = vector.magnitude(v2:GetPivot().Position - Root.Position)

					if (Magnitude < Dist) then
						Closest = {v, ProximityPrompt}
						Dist = Magnitude
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
		local Increment = increment or 1

		local function IncrementalMove(start_pos, end_pos)
			local Offset = end_pos - start_pos
			local Distance = vector.magnitude(Offset)
			local Direction = vector.normalize(Offset)
			local CurrentPos = start_pos

			while shared.afy and Distance > Increment do
				CurrentPos += Direction * Increment
				Root.CFrame = CFrame.new(CurrentPos)
				Root.AssemblyLinearVelocity = vector.zero
				SmartWait()
				Offset = end_pos - CurrentPos
				Distance = vector.magnitude(Offset)
			end

			if (not shared.afy) then return end
			Root.CFrame = CFrame.new(end_pos)
		end

		if (Char and Root) then
			local CurrentPos = Root.Position
			local DownPos = vector.create(CurrentPos.X, pos.Y, CurrentPos.Z)
			local AcrossPos = vector.create(pos.X, pos.Y, pos.Z)
			local FinalPos = pos

			IncrementalMove(CurrentPos, DownPos)
			IncrementalMove(DownPos, AcrossPos)
			IncrementalMove(AcrossPos, FinalPos)
		end

		HiddenFlags.CurrentlyMoving = false
	end

	SmartWait = function(_delay, flags_key)
		local Char = GetChar(Client)
		local Root = GetRoot(Char)
		local StartTime = tick()

		if (Char and Root) then
			local InitCFrame = Root.CFrame

			task.spawn(function()
				while (shared.afy and Char and Root and (not flags_key or Flags[flags_key]) and tick() - StartTime <= (_delay or 1/60)) do
					for _, v in (Char:GetDescendants()) do
						if (v:IsA('BasePart') or v:IsA('MeshPart')) then
							v.CanCollide = false
						end
					end

					Root.CFrame = InitCFrame
					Root.AssemblyLinearVelocity = vector.zero

					task.wait()
				end
			end)

			while (shared.afy and Char and Root and (not flags_key or Flags[flags_key]) and tick() - StartTime <= (_delay or 1/60)) do
				task.wait(1/60)
			end
		end
	end

	SmartGet = function(inst, obj)
		if (not inst) then return end

		local Objects = obj:split('.')
		local Current = inst

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

		if (Flags.StaminaFarm) then
			VirtualInputManager:SendKeyEvent(true, 'W', false, nil)
			VirtualInputManager:SendKeyEvent(true, 'LeftShift', false, nil)
		end
	end

	if (HasTool('HackToolUltimate') or HasTool('HackToolPro') or HasTool('HackToolBasic')) then
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

				if (TargetSize <= 0.06) then
					SmartWait(0.2)
				end
			end
		else
			local ATMHolder = SmartGet(PlayerGui, 'ATM.ATMHolder')
			local ATMHackButton = SmartGet(ATMHolder, 'ATMHomePage.Title.ATMHackButton')
			local ChooseOptionsHolder = SmartGet(PlayerGui, 'SelectOption.ChooseOptionsHolder')
			local ChooseOptionsScrollingFrame = SmartGet(ChooseOptionsHolder, 'ChooseOptionsScrollingFrame')

			if (ChooseOptionsHolder and ChooseOptionsHolder.Visible and ChooseOptionsScrollingFrame) then
				local ToolButton = ChooseOptionsScrollingFrame:FindFirstChild(HasTool('HackToolUltimate') and 'Ultimate Hack Tool' or HasTool('HackToolPro') and 'Pro Hack Tool' or 'Basic Hack Tool')

				if (ToolButton) then
					local TextButton = SmartGet(ToolButton, 'TextButton')

					if (TextButton) then
						for i,v in getconnections(TextButton.MouseButton1Click) do
							v:Function()
						end
					end
				end

			elseif (ATMHolder and ATMHolder.Visible and ATMHackButton) then
				for i,v in getconnections(ATMHackButton.MouseButton1Click) do
					v:Function()
				end

			else
				local ATM, ATM_Prox = GetATM()

				if (ATM and ATM_Prox) then
					MoveTo(ATM:GetPivot().Position + vector.create(0, -10, 0))
					fireproximityprompt(ATM_Prox)
				end
			end
		end
	else
		local AlleyWayGuy = SmartGet(workspace, 'Map.NPCs.AlleyWayGuy')
		if (not AlleyWayGuy) then continue end

		MoveTo(AlleyWayGuy:GetPivot().Position + vector.create(0, -10, 0))
		fireproximityprompt(workspace.ConsumableShopZone_Illegal.ProximityPrompt)

		local function GetBuyTool(tool_name)
			local ConsumableOptionsScrollingFrame = SmartGet(PlayerGui, 'ConsumableBuy.ConsumableOptionsHolder.ConsumableOptionsScrollingFrame')

			for i,v in (ConsumableOptionsScrollingFrame:GetChildren()) do
				local Options = SmartGet(v, 'Item.Options')
				local ConsumableName = SmartGet(Options, 'ConsumableName')
				local BuyButton = SmartGet(Options, 'ConsumableBuyButton')

				if (ConsumableName and ConsumableName.Text == tool_name and BuyButton and BuyButton.Visible) then
					return Options
				end
			end
		end

		local MoneyTextLabel = SmartGet(PlayerGui, 'TopRightHud.Holder.Frame.MoneyTextLabel')
		local MoneyText = MoneyTextLabel and MoneyTextLabel.Text
		local MoneyNumber = tonumber(MoneyText:match("%d+"))

		local function BuyTool(ToolType)
			local ConsumableBuyButton = SmartGet(ToolType, 'ConsumableBuyButton')

			if (ConsumableBuyButton) then
				for i,v in getconnections(ConsumableBuyButton.MouseButton1Click) do
					v:Function()
				end
			end
		end

		for i = 1, 5 do -- Not updating MoneyNumber on purpose
			local UltimateTool = GetBuyTool('Ultimate Hack Tool')
			local ProTool = GetBuyTool('Pro Hack Tool')
			local BasicTool = GetBuyTool('Basic Hack Tool')

			BuyTool(UltimateTool and MoneyNumber > 350 and UltimateTool or ProTool and MoneyNumber >= 150 and ProTool or BasicTool)
		end
	end
end
