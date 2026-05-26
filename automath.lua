script_name("Auto Math & Reaction")
script_author("Assistant & BOJO Dev")
script_version("5.1")

require "lib.moonloader"
local ffi = require 'ffi'
local sampev = require 'lib.samp.events'
local imgui = require 'mimgui'

local guiVisible = imgui.new.bool(false)
local mathEnabled = imgui.new.bool(true)
local reactEnabled = imgui.new.bool(true)
local VK_F9 = 0x78

-- ==========================================
-- ⚙️ CONFIGURATION SETTINGS (ULTIMATE UNIVERSAL)
-- ==========================================
local CONFIG = {
    -- 🧮 MATH SETTINGS
    MATH_CMD = "/ans",         -- Command para sa Math (e.g., /ans, /math)
    MATH_MIN_DELAY = 8,        -- Minimum seconds
    MATH_MAX_DELAY = 13,       -- Maximum seconds
    MATH_TRIGGERS = {
        -- English Standard
        "math:", "solve", "what is", "calculate", "equation", "compute", 
        "quick math", "math test", "solve this", "math problem", 
        "first to solve", "who can solve", "fast math", "calculator",
        "question:", "answer this",
        
        -- Tagalog / Pinoy Servers
        "sagutin", "sino makakasagot", "paunahan sumagot", 
        "unang makakasagot", "matematika", "paunahan i-solve",
        
        -- Server Tags / Symbols
        "[math]", "** math", ">> math", "reaction math", "mini-event: math"
    },

    -- ⌨️ REACTION TEST SETTINGS
    REACTION_CMD = "",         -- Command para sa Reaction (I-blangko "" kung normal chat lang)
    REACTION_MIN_DELAY = 3,    -- Mas mabilis ang reaction test kaya 3 to 6 seconds lang
    REACTION_MAX_DELAY = 4,
    REACTION_TRIGGERS = {
        -- English Standard
        "type this", "first to type", "type the word", "reaction test", 
        "reactiontest", "reaction: type", "first one to type", "fast typing", 
        "type:", "reaction:", "copy this", "write this", "quick typing", 
        "type exactly", "keyboard test", "fastest to type", "who can type",
        
        -- Tagalog / Pinoy Servers
        "paunahan i-type", "paunahan mag type", "unang makaka-type", 
        "kopyahin", "i-type ang", "type nyo", "paunahan magtype",
        
        -- Server Tags / Symbols
        "[reaction]", "** reaction", ">> reaction", "mini-event: reaction"
    }
}

local pending = {
    text = nil,
    cmd = "",
    sendTime = 0,
    info = ""
}

-- ==========================================
-- GUI RENDER
-- ==========================================
local GUI_COLORS = {
    header = imgui.ImVec4(0.15, 0.55, 0.85, 1.0),
    headerBg = imgui.ImVec4(0.10, 0.12, 0.18, 1.0),
    accent = imgui.ImVec4(0.20, 0.65, 0.90, 1.0),
    success = imgui.ImVec4(0.20, 0.75, 0.30, 1.0),
    danger = imgui.ImVec4(0.80, 0.20, 0.20, 1.0),
    text = imgui.ImVec4(0.85, 0.85, 0.90, 1.0),
    muted = imgui.ImVec4(0.50, 0.50, 0.55, 1.0),
    section = imgui.ImVec4(0.20, 0.70, 0.90, 1.0),
}

imgui.OnInitialize(function()
    local style = imgui.GetStyle()
    style.WindowRounding = 6.0
    style.FrameRounding = 4.0
    style.ItemSpacing = imgui.ImVec2(8, 6)
    style.ScrollbarSize = 10.0
end)

local function coloredText(color, text)
    imgui.PushStyleColor(imgui.Col.Text, color)
    imgui.TextUnformatted(text)
    imgui.PopStyleColor()
end

imgui.OnFrame(function() return guiVisible[0] end, function()
    -- Pinaliit nang konti yung height dahil tinanggal ang input boxes
    imgui.SetNextWindowSize(imgui.ImVec2(430, 480), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowPos(imgui.ImVec2(400, 200), imgui.Cond.FirstUseEver)
    
    imgui.Begin("Auto Math & Reaction Control", guiVisible, imgui.WindowFlags.NoCollapse)

    -- Header
    imgui.PushStyleColor(imgui.Col.ChildBg, GUI_COLORS.headerBg)
    imgui.BeginChild("##header", imgui.ImVec2(0, 42), true)
    imgui.SetCursorPos(imgui.ImVec2(12, 10))
    imgui.PushStyleColor(imgui.Col.Text, GUI_COLORS.header)
    imgui.TextUnformatted("[  Auto Math & Reaction  ]")
    imgui.PopStyleColor()
    imgui.SameLine()
    imgui.SetCursorPosY(10)
    coloredText(GUI_COLORS.muted, "v5.1")
    imgui.SameLine(imgui.GetContentRegionMax().x - 70)
    imgui.SetCursorPosY(9)
    local statusText = ""
    local statusColor = GUI_COLORS.muted
    if pending.text then
        statusText = "Pending"
        statusColor = GUI_COLORS.success
    else
        statusText = "Idle"
        statusColor = GUI_COLORS.muted
    end
    coloredText(statusColor, statusText)
    imgui.EndChild()
    imgui.PopStyleColor()

    imgui.Dummy(imgui.ImVec2(0, 4))

    -- Toggle section
    imgui.PushStyleColor(imgui.Col.Text, GUI_COLORS.accent)
    imgui.TextUnformatted("FEATURES")
    imgui.PopStyleColor()

    imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.12, 0.14, 0.22, 0.8))
    imgui.BeginChild("##toggles", imgui.ImVec2(0, 48), true)
    imgui.SetCursorPos(imgui.ImVec2(10, 8))
    imgui.Checkbox("Math Solver", mathEnabled)
    imgui.SameLine()
    imgui.SetCursorPosX(200)
    imgui.Checkbox("Reaction Test", reactEnabled)
    imgui.EndChild()
    imgui.PopStyleColor()

    imgui.Dummy(imgui.ImVec2(0, 4))

    -- Math Triggers (Simplified List)
    if imgui.CollapsingHeader("MATH TRIGGERS##math", imgui.TreeNodeFlags.DefaultOpen) then
        imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.10, 0.12, 0.18, 0.6))
        imgui.BeginChild("##mathTriggers", imgui.ImVec2(0, 120), true)
        if #CONFIG.MATH_TRIGGERS == 0 then
            coloredText(GUI_COLORS.muted, "  (no triggers)")
        else
            for _, t in ipairs(CONFIG.MATH_TRIGGERS) do
                imgui.PushStyleColor(imgui.Col.Text, GUI_COLORS.text)
                imgui.TextUnformatted("  • " .. t)
                imgui.PopStyleColor()
            end
        end
        imgui.EndChild()
        imgui.PopStyleColor()
    end

    imgui.Dummy(imgui.ImVec2(0, 4))

    -- Reaction Triggers (Simplified List)
    if imgui.CollapsingHeader("REACTION TRIGGERS##react", imgui.TreeNodeFlags.DefaultOpen) then
        imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.10, 0.12, 0.18, 0.6))
        imgui.BeginChild("##reactTriggers", imgui.ImVec2(0, 120), true)
        if #CONFIG.REACTION_TRIGGERS == 0 then
            coloredText(GUI_COLORS.muted, "  (no triggers)")
        else
            for _, t in ipairs(CONFIG.REACTION_TRIGGERS) do
                imgui.PushStyleColor(imgui.Col.Text, GUI_COLORS.text)
                imgui.TextUnformatted("  • " .. t)
                imgui.PopStyleColor()
            end
        end
        imgui.EndChild()
        imgui.PopStyleColor()
    end

    imgui.End()
end)

-- ==========================================

local C = { GOLD = "{BFA100}", GREEN = "{33AA33}", CYAN = "{33CCFF}", GRAY = "{888888}", RED = "{FF5555}", WHITE = "{FFFFFF}", YELLOW = "{FFFF00}" }
local PREFIX = C.GOLD .. "[Auto]" .. C.WHITE .. " > "

local function msg(kind, text)
    if isSampAvailable() then
        local colors = { found = C.GREEN, scan = C.GOLD, warn = C.YELLOW, status = C.CYAN, error = C.RED, info = C.WHITE, debug = C.GRAY }
        sampAddChatMessage(PREFIX .. (colors[kind] or colors.info) .. text, 0xFFFFFFFF)
    end
end

local DEBUG = false
local playerNick = ""
local lastSendTime = 0
local SEND_COOLDOWN = 1.5
local MAX_EQ_LEN = 60

local function getLocalName()
    if playerNick == "" and isSampAvailable() then
        local res, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
        if res then
            playerNick = sampGetPlayerNickname(id) or ""
        end
    end
    return playerNick
end

local function showStatus()
    local state = pending.text and "{FFFF00}Pending{FFFFFF}" or "{33AA33}Idle{FFFFFF}"
    local nextStr = ""
    if pending.text then
        local remain = math.ceil(pending.sendTime - os.clock())
        if remain < 0 then remain = 0 end
        nextStr = string.format(" | Next: {FFFF00}%s{FFFFFF} in {33AA33}%d{FFFFFF}s", pending.text, remain)
    end
    local triggers = table.concat(CONFIG.MATH_TRIGGERS, ", ")
    local reactTriggers = table.concat(CONFIG.REACTION_TRIGGERS, ", ")
    sampAddChatMessage(string.format("{BFA100}[Auto] {FFFFFF}Status: %s%s", state, nextStr), 0xFFFFFFFF)
    sampAddChatMessage(string.format("{BFA100}Math{888888}: [%s] %s {BFA100}| React{888888}: [%s] %s", 
        CONFIG.MATH_CMD, triggers, CONFIG.REACTION_CMD ~= "" and CONFIG.REACTION_CMD or "(raw)", reactTriggers), 0xFFFFFFFF)
end

local function stripColorCodes(s)
    return (s:gsub("{%x%x%x%x%x%x}", ""))
end

-- ==========================================
-- MATH LOGIC
-- ==========================================
local function normalizeEquation(e)
    e = e:gsub("%s+", "")
    e = e:gsub("[xX×]", "*")
    e = e:gsub("[÷]", "/")
    e = e:gsub("[−–—]", "-")
    e = e:gsub("[＋]", "+")
    e = e:gsub("[／]", "/")
    e = e:gsub("[＊]", "*")
    e = e:gsub("[．]", ".")
    -- Auto-insert multiplication for formats like 2(5+5)
    e = e:gsub("(%d)%(", "%1*(")
    e = e:gsub("%)(%d)", ")*%1")
    e = e:gsub("%)%(", ")*(")
    return e
end

local function extractEquationFromMessage(text)
    local msgText = stripColorCodes(text)
    local candidate = msgText:match("([%-%d%(][%d%+%-%*/xX×÷%.%s%(%)]+[%d%)])")
    
    if not candidate then return nil end
    if #candidate > MAX_EQ_LEN then return nil end

    candidate = normalizeEquation(candidate)

    if not (candidate:find("%d") and candidate:find("[%+%-%*/]")) then
        return nil
    end

    local numCount = 0
    for _ in candidate:gmatch("%d+") do numCount = numCount + 1 end
    if numCount < 2 then return nil end

    return candidate
end

-- ==========================================
-- REACTION LOGIC
-- ==========================================
local function extractReactionString(text, trigger)
    local msgText = stripColorCodes(text)
    
    -- Pattern 1: Hanapin sa loob ng quotes (e.g., Type 'ABCD')
    local match = msgText:match("['\"]([^'\"]+)['\"]")
    if match then
        match = match:gsub("^[%s%p]+", ""):gsub("[%s%p]+$", "")
        if #match >= 1 and #match <= 25 then return match end
    end
    
    -- Pattern 2: Kunin ang unang salita pagkatapos ng trigger word
    local lowerMsg = msgText:lower()
    local lowerTrigger = trigger:lower()
    local _, endPos = lowerMsg:find(lowerTrigger, 1, true)
    
    if endPos then
        local afterTrigger = msgText:sub(endPos + 1)
        afterTrigger = afterTrigger:gsub("^[%s:%-=>]+", "")
        -- Gumamit ng %S+ para isama lahat ng symbols tulad ng @ at #
        local targetWord = afterTrigger:match("(%S+)")
        if targetWord then
            targetWord = targetWord:gsub("^[%s]+", ""):gsub("[%s%.!]+$", "")
            if #targetWord >= 1 and #targetWord <= 25 then return targetWord end
        end
    end

    return nil
end

-- ==========================================
-- MAIN LOOP
-- ==========================================
function main()
    while not isSampAvailable() do wait(100) end
    
    -- Initialize Local Name safely
    getLocalName()

    pcall(sampRegisterChatCommand, "autostatus", showStatus)

    local guiKeyPressed = false
    while true do
        wait(0)

        local f9down = isKeyDown(VK_F9)
        if f9down and not guiKeyPressed and not sampIsChatInputActive() and not sampIsDialogActive() then
            guiVisible[0] = not guiVisible[0]
            guiKeyPressed = true
        elseif not f9down then
            guiKeyPressed = false
        end

        if pending.text then
            local remaining = pending.sendTime - os.clock()
            if remaining > 0 then
                printStringNow(string.format("~w~Sending in ~y~%d~w~s", math.ceil(remaining)), 500)
            end
        end

        if pending.text and os.clock() >= pending.sendTime then
            local chatPayload = pending.text
            if pending.cmd and pending.cmd ~= "" then
                chatPayload = pending.cmd .. " " .. pending.text
            end
            
            sampSendChat(chatPayload)
            local sentText = pending.text
            lastSendTime = os.clock()
            pending.text = nil
            pending.sendTime = 0
            pending.cmd = ""

            msg("info", ("Sent: %s"):format(sentText))
        end
    end
end

-- ==========================================
-- CHAT SCANNER
-- ==========================================
function sampev.onServerMessage(color, text)
    local ok, err = pcall(function()
        if os.clock() - lastSendTime < SEND_COOLDOWN then return end
        if DEBUG then msg("debug", text) end

        local cleanText = stripColorCodes(text)
        local lowerText = cleanText:lower()

        local nick = getLocalName()
        if nick ~= "" and lowerText:find(nick:lower(), 1, true) then
            return
        end

        -- 1. I-check kung MATH TEST (kung enabled)
        if mathEnabled[0] then
            for _, trigger in ipairs(CONFIG.MATH_TRIGGERS) do
                if lowerText:find(trigger:lower(), 1, true) then
                    local equation = extractEquationFromMessage(cleanText)
                    if equation then
                        local func = loadstring("return " .. equation)
                        if func then
                            local ok2, result = pcall(func)
                            if ok2 then
                                local answer = tostring(math.floor(tonumber(result) + 0.5))
                                local delay = math.random(CONFIG.MATH_MIN_DELAY, CONFIG.MATH_MAX_DELAY)
                                
                                pending.text = answer
                                pending.cmd = CONFIG.MATH_CMD
                                pending.sendTime = os.clock() + delay
                                
                                msg("found", ("Math Solved: %s = %s \183 %ds delay"):format(equation, answer, delay))
                                return
                            end
                        end
                    end
                end
            end
        end

        -- 2. I-check kung REACTION TEST (kung enabled)
        if reactEnabled[0] then
            for _, trigger in ipairs(CONFIG.REACTION_TRIGGERS) do
                if lowerText:find(trigger:lower(), 1, true) then
                    local reactionString = extractReactionString(cleanText, trigger)
                    if reactionString then
                        local delay = math.random(CONFIG.REACTION_MIN_DELAY, CONFIG.REACTION_MAX_DELAY)
                        
                        pending.text = reactionString
                        pending.cmd = CONFIG.REACTION_CMD
                        pending.sendTime = os.clock() + delay
                        
                        msg("found", ("Reaction String: '%s' \183 %ds delay"):format(reactionString, delay))
                        return
                    end
                end
            end
        end
    end)
    if not ok and DEBUG then
        msg("error", tostring(err))
    end
end