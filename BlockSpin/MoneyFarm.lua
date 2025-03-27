-- This is patched, leaving this for learning purposes
-- https://www.roblox.com/games/104715542330896/BlockSpin

local Flags = Flags or {
	StaminaFarm = true,
	TweenSpeed = 0.5,
	BuyAmount = 15,
	
	DepositAt = 10_000,
	DepositAmount = 5_000,
}

local Services = setmetatable({}, {
    __index = function(self, key)
		local cloneref = cloneref or function(...) return ... end
        local Succ, Result = pcall(cloneref, game:FindService(key))
        rawset(self, key, Succ and Result or Instance.new(key))

        return rawget(self, key)
    end
})

local Players = Services.Players
local VirtualInputManager = Services.VirtualInputManager
local ReplicatedStorage = Services.ReplicatedStorage

local Client = Players.LocalPlayer
local PlayerGui = Client:WaitForChild('PlayerGui')
local CounterTable = (function()
	for _, Obj in getgc and getgc(true) or {} do
		if (typeof(Obj) == 'table' and rawget(Obj, "event") and rawget(Obj, "func")) then
			return Obj
		end
	end
end)()

for i,v in getconnections(Client.Idled) do
	v:Disable()
end

local HiddenFlags = {
	MoneyDebounce = 0
}

local GetChar, GetRoot, GetHum, GetATM, MoveTo, SmartWait, SmartGet, HasTool, CallRemote, Deposit, Withdraw; do
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

				local disabled = v:GetAttribute('disabled')
				if (disabled) then continue end
				
				local hacker = v:FindFirstChildWhichIsA('ObjectValue')
				if (hacker and hacker.Value) then continue end

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
		local Increment = increment or Flags.TweenSpeed

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

	CallRemote = function(remote, ...)
		if (not CounterTable) then return end

		if (remote.ClassName == 'RemoteEvent') then
			CounterTable.event += 1

			remote:FireServer(CounterTable.event, ...)
		end

		if (remote.ClassName == 'RemoteFunction') then
			CounterTable.func += 1

			remote:InvokeServer(CounterTable.func, ...)
		end
	end

	Deposit = function(amount)
		CallRemote(ReplicatedStorage.Remotes.Get, "transfer_funds", "hand", "bank", amount)
	end

	Withdraw = function(amount)
		CallRemote(ReplicatedStorage.Remotes.Get, "transfer_funds", "bank", "hand", amount)
	end
end

shared.afy = not shared.afy
print(shared.afy)

while ((Flags.Enabled or shared.afy) and task.wait()) do
	local Char = GetChar(Client)
	local Hum = GetHum(Char)
	local Root = GetRoot(Char)

	if (Char and Hum and Root) then
		if (Hum:GetStateEnabled(Enum.HumanoidStateType.Seated)) then
			Hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
		end

		Root.AssemblyLinearVelocity = vector.create(0, 0.5, 0)

		if (Flags.StaminaFarm) then
			VirtualInputManager:SendKeyEvent(true, 'W', false, game)
			VirtualInputManager:SendKeyEvent(true, 'LeftShift', false, game)
		end

		if (Hum.Health / Hum.MaxHealth * 100 < 10) then
			CallRemote(ReplicatedStorage.Remotes.Send, "death_screen_request_respawn")
		end
	end

	local MoneyTextLabel = SmartGet(PlayerGui, 'TopRightHud.Holder.Frame.MoneyTextLabel')
	local MoneyText = MoneyTextLabel and MoneyTextLabel.Text
	local MoneyNumber = tonumber(MoneyText:match("%d+"))

	if (MoneyNumber and MoneyNumber >= (Flags.DepositAt or 10_000) and tick() - HiddenFlags.MoneyDebounce > 1) then
		Deposit(Flags.DepositAmount or 5_000)
		HiddenFlags.MoneyDebounce = tick()
	end

	if (HasTool('HackToolQuantum') or HasTool('HackToolUltimate') or HasTool('HackToolPro') or HasTool('HackToolBasic')) then
		local SliderMinigameFrame = SmartGet(PlayerGui, 'SliderMinigame.SliderMinigameFrame')
		local Bar = SmartGet(SliderMinigameFrame, 'Bar')
		local Needle = SmartGet(Bar, 'Needle')
		local Target = SmartGet(Bar, 'Target')

		if (SliderMinigameFrame and SliderMinigameFrame.Visible and Bar and Needle and Target) then	
			if (CounterTable) then	
				MoveTo(HiddenFlags.LastATM:GetPivot().Position + vector.create(0, -2, 0))
				CallRemote(ReplicatedStorage.Remotes.Send, "minigame_win", HiddenFlags.LastATM)
				MoveTo(HiddenFlags.LastATM:GetPivot().Position + vector.create(0, -10, 0))
			else
				local NeedleX = Needle.Position.X.Scale
				local TargetX = Target.Position.X.Scale
				local TargetSize = Target.Size.X.Scale / 2

				if NeedleX >= (TargetX - TargetSize) and NeedleX <= (TargetX + TargetSize) then
					if (TargetSize <= 0.06) then
						MoveTo(HiddenFlags.LastATM:GetPivot().Position + vector.create(0, -2, 0))
					end

					VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
					VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)

					if (TargetSize <= 0.06) then
						SmartWait(0.2)
						MoveTo(HiddenFlags.LastATM:GetPivot().Position + vector.create(0, -10, 0))
					end
				end
			end
		else
			local ATMHolder = SmartGet(PlayerGui, 'ATM.ATMHolder')
			local ATMHackButton = SmartGet(ATMHolder, 'ATMHomePage.Title.ATMHackButton')
			local ChooseOptionsHolder = SmartGet(PlayerGui, 'SelectOption.ChooseOptionsHolder')
			local ChooseOptionsScrollingFrame = SmartGet(ChooseOptionsHolder, 'ChooseOptionsScrollingFrame')

			if (ChooseOptionsHolder and ChooseOptionsHolder.Visible and ChooseOptionsScrollingFrame) then
				local ToolButton = ChooseOptionsScrollingFrame:FindFirstChild(HasTool('HackToolQuantum') and 'Quantum Hack Tool' or HasTool('HackToolUltimate') and 'Ultimate Hack Tool' or HasTool('HackToolPro') and 'Pro Hack Tool' or 'Basic Hack Tool')

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
					HiddenFlags.LastATM = ATM
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

		local function BuyTool(ToolType)
			local ConsumableBuyButton = SmartGet(ToolType, 'ConsumableBuyButton')

			if (ConsumableBuyButton) then
				for i,v in getconnections(ConsumableBuyButton.MouseButton1Click) do
					v:Function()
				end
			end
		end

		for i = 1, Flags.BuyAmount or 15 do
			local QuantumTool = GetBuyTool('Quantum Hack Tool')
			local UltimateTool = GetBuyTool('Ultimate Hack Tool')
			local ProTool = GetBuyTool('Pro Hack Tool')
			local BasicTool = GetBuyTool('Basic Hack Tool')

			BuyTool(QuantumTool and MoneyNumber >= 550 and QuantumTool or UltimateTool and MoneyNumber >= 350 and UltimateTool or ProTool and MoneyNumber >= 150 and ProTool or BasicTool)
			MoveTo(AlleyWayGuy:GetPivot().Position + vector.create(0, -10, 0))
		end
	end
end
