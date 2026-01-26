-- https://www.roblox.com/games/17262338236/Wordie
-- Prints Best Three Guesses

local WordList = loadstring(game:HttpGet('https://raw.githubusercontent.com/afyzone/lua/refs/heads/main/Wordle/WordList.lua'))()
local Players = game:GetService('Players')
local Client = Players.LocalPlayer
local PlayerGui = Client:WaitForChild('PlayerGui')

local function CharArray(String)
	local Result = {}

	for i = 1, #String do
		Result[i] = String:sub(i, i)
	end

	return Result
end

local function CountLetters(Word)
	local Counts = {}

	for i = 1, #Word do
		local Char = Word:sub(i, i)
		Counts[Char] = (Counts[Char] or 0) + 1
	end

	return Counts
end

local function PassesGreens(Word, Greens)
	for i = 1, #Greens do
		local G = Greens:sub(i, i)
		if G ~= "_" and Word:sub(i, i) ~= G then return end
	end

	return true
end

local function PassesYellows(Word, Yellows)
	for Position, Letters in Yellows do
		for _, Char in Letters do
			if not Word:find(Char, 1, true) then return end
			if Word:sub(Position, Position) == Char then return end
		end
	end

	return true
end

local function PassesGrays(Word, Grays)
	for Char in Grays do
		if Word:find(Char, 1, true) then return end
	end

	return true
end

local function SolveWordle(Greens, Yellows, Grays)
	local Results = {}

	for _, Word in WordList do
		Word = Word:upper()

		if not PassesGreens(Word, Greens) then continue end
		if not PassesYellows(Word, Yellows) then continue end
		if not PassesGrays(Word, Grays) then continue end

		table.insert(Results, Word)
	end

	return Results
end

local function GetData()
	local Greens = '_____'
	local Grays = {}
	local Yellows = {}

	local function SetCharAt(String, Index, Char)
		return String:sub(1, Index - 1) .. Char .. String:sub(Index + 1)
	end

	local Rows = PlayerGui.MainUI.Game.InputArea.Rows

	for _, Value in Rows:GetDescendants() do
		if Value:IsA('TextLabel') and Value.Name == 'TextArea' and Value.Text ~= '' then
			local Stroke = Value.Parent.UIStroke
			local Letter = Value.Text:upper()

			if Stroke.Color == Color3.fromRGB(49, 49, 52) then -- Gray
				Grays[Letter] = true

			elseif Stroke.Color == Color3.fromRGB(49, 161, 52) then -- Green
				local Placement = tonumber(Value.Parent.Name:match('%d+'))
				Greens = SetCharAt(Greens, Placement, Letter)
			end
		end
	end

	for _, Row in Rows:GetChildren() do
		for _, Letter in Row:GetChildren() do
			local Stroke = Letter.UIStroke

			if Stroke.Color == Color3.fromRGB(165, 140, 28) then -- Yellow
				local Placement = tonumber(Letter.Name:match('%d+'))
				local Char = Letter.TextArea.Text:upper()

				Yellows[Placement] = Yellows[Placement] or {}
				table.insert(Yellows[Placement], Char)
			end
		end
	end

	for i = 1, #Greens do
		local Char = Greens:sub(i, i)

		if Char ~= '_' then
			Grays[Char] = nil
		end
	end

	for _, Letters in Yellows do
		for _, Char in Letters do
			Grays[Char] = nil
		end
	end

	return Greens, Yellows, Grays
end

local function RankWords(WordList)
	local Frequency = {}

	for _, Word in WordList do
		local Seen = {}

		for i = 1, #Word do
			local C = Word:sub(i, i)

			if not Seen[C] then
				Frequency[C] = (Frequency[C] or 0) + 1
				Seen[C] = true
			end
		end
	end

	table.sort(WordList, function(A, B)
		local ScoreA, ScoreB = 0, 0
		local SeenA, SeenB = {}, {}

		for i = 1, #A do
			local C = A:sub(i, i)

			if not SeenA[C] then
				ScoreA += Frequency[C] or 0
				SeenA[C] = true
			end
		end

		for i = 1, #B do
			local C = B:sub(i, i)

			if not SeenB[C] then
				ScoreB += Frequency[C] or 0
				SeenB[C] = true
			end
		end

		return ScoreA > ScoreB
	end)

	return WordList
end

shared.afy = not shared.afy
print('[afy]', shared.afy)

while shared.afy and task.wait(1) do
	local Possible = SolveWordle(GetData())
	local Best = RankWords(Possible)

	print(Best[1], Best[2], Best[3])
end
