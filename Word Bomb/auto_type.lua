-- https://www.roblox.com/games/2653064683/
-- Auto Type; I haven't put a UI on it since im too lazy so it is unfinished until i work on it again

local services = setmetatable({}, {
    __index = function(self, key)
        local service = pcall(cloneref, game:FindService(key)) and cloneref(game:GetService(key)) or Instance.new(key)
        rawset(self, key, service)

        return rawget(self, key)
    end
})

local players = services.Players
local virtualinputmanager = services.VirtualInputManager

local client = players.LocalPlayer
local playergui = client:WaitForChild('PlayerGui')
local game_ui = playergui:WaitForChild('GameUI')
local prompt_frame = game_ui.Container.GameSpace.DefaultUI.GameContainer.DesktopContainer.InfoFrameContainer.InfoFrame:WaitForChild('TextFrame')

local word_list = {
    ['Default'] = loadstring(game:HttpGet('https://gist.githubusercontent.com/raw/6f3d37a9f5068a0fc2203ac77077ce06/'))(),
    ['Old'] = loadstring(game:HttpGet('https://pastebin.com/raw/kTSEH2sZ'))(),
    ['Long'] = loadstring(game:HttpGet('https://gist.githubusercontent.com/raw/71101a9a7e1513e9b603339f6530b615/'))()
}

local keys = {
	['A'] = 0x41,
	['B'] = 0x42,
	['C'] = 0x43,
	['D'] = 0x44,
	['E'] = 0x45,
	['F'] = 0x46,
	['G'] = 0x47,
	['H'] = 0x48,
	['I'] = 0x49,
	['J'] = 0x4A,
	['K'] = 0x4B,
	['L'] = 0x4C,
	['M'] = 0x4D,
	['N'] = 0x4E,
	['O'] = 0x4F,
	['P'] = 0x50,
	['Q'] = 0x51,
	['R'] = 0x52,
	['S'] = 0x53,
	['T'] = 0x54,
	['U'] = 0x55,
	['V'] = 0x56,
	['W'] = 0x57,
	['X'] = 0x58,
	['Y'] = 0x59,
	['Z'] = 0x5A,
    ['Enter'] = 0x0D,
}

local AnswerMachine = {}; do
    AnswerMachine.__index = AnswerMachine

    function AnswerMachine.new()
        local self = setmetatable({}, AnswerMachine)

        self.auto_type = true
        self.typing = false
        self.auto_enter = true
        self.pre_type_delay = 0
        self.delay_per_char = 0.1
        self.enter_delay = 0
        self.selected_word_list = word_list['Default']
        self.used_words = {}

        return self
    end

    function AnswerMachine:UpdateWordType(text)
        local selected_word_list = word_list[text]
        if (not selected_word_list) then return end

        self.selected_word_list = selected_word_list
    end

    function AnswerMachine:ClearUsedWords()
        table.clear(self.used_words)
    end

    function AnswerMachine:GetPromptLetters()
        local word = ''

        for i,v in (prompt_frame:GetChildren()) do
            local letter = v:FindFirstChild('Letter')

            if not (v.Name == 'LetterFrame' and letter) then continue end

            word = `{word}{v.Letter.TextLabel.Text}`
        end

        return word
    end

    function AnswerMachine:GetWord()
        local letters = self:GetPromptLetters()
        if (not letters) then return end

        for i,v in (self.selected_word_list) do
            local candidate_word = v:lower()
            if (table.find(self.used_words, candidate_word) and not candidate_word:find(letters:lower())) then continue end

            return candidate_word
        end

        for i,v in (word_list['Default']) do -- If unavailable
            local candidate_word = v:lower()
            if (table.find(self.used_words, candidate_word) and not candidate_word:find(letters:lower())) then continue end

            return candidate_word
        end
    end

    function AnswerMachine:TypeAnswer()
        if (self.typing) then return end
        self.typing = true

        local word = self:GetWord()

        if (word) then
            task.wait(self.pre_type_delay)
            table.insert(self.used_words, word)

            for char in word:gmatch('.') do
                keypress(keys[char:upper()])

                task.wait(self.delay_per_char)
            end

            if (self.auto_enter) then
                task.wait(self.enter_delay)

                keypress(keys['Enter'])
            end
        end

        self.typing = false
    end
end

local answer_handler = AnswerMachine.new(); do
    answer_handler.auto_enter = true
    answer_handler.pre_type_delay = 2
    answer_handler.delay_per_char = 0.1
    answer_handler.enter_delay = 0.2

    answer_handler:ClearUsedWords()
    answer_handler:UpdateWordType('Long')
end

local game_container = game_ui.Container.GameSpace.DefaultUI:FindFirstChild('GameContainer')
local type_box = game_container.DesktopContainer.Typebar:FindFirstChild('Typebox')

if (game_container and type_box) then
    type_box:GetPropertyChangedSignal('Visible'):Connect(function()
        local value = type_box.Visible

        if (value and answer_handler.auto_type) then
            answer_handler:TypeAnswer()
        end
    end)
end

game_ui.DescendantAdded:Connect(function(child)
    if (child.Name == 'Typebox') then
        warn(child:GetFullName())
        local value = child.Visible

        if (value and answer_handler.auto_type) then
            answer_handler:TypeAnswer()
        end
    end
end)
