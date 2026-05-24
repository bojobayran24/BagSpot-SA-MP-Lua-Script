script_name("Auto Math Detector")
script_author("Assistant")
script_version("2.2")

require "lib.moonloader"
local sampev = require 'lib.samp.events'

local C = { GOLD = "{BFA100}", GREEN = "{33AA33}", CYAN = "{33CCFF}", GRAY = "{888888}", RED = "{FF5555}", WHITE = "{FFFFFF}", YELLOW = "{FFFF00}" }
local PREFIX = C.GOLD .. "[M]" .. C.WHITE .. " > "

local function msg(kind, text)
    if isSampAvailable() then
        local colors = { found = C.GREEN, scan = C.GOLD, warn = C.YELLOW, status = C.CYAN, error = C.RED, info = C.WHITE, debug = C.GRAY }
        sampAddChatMessage(PREFIX .. (colors[kind] or colors.info) .. text, 0xFFFFFFFF)
    end
end

local DEBUG = false
local ANSWER_CMD = "/ans"
local pendingAnswer = nil
local pendingSendTime = 0
local pendingEquation = nil

local function stripColorCodes(s)
    return (s:gsub("{%x%x%x%x%x%x}", ""))
end

local function normalizeEquation(e)
    e = e:gsub("%s+", "")
    e = e:gsub("[xX×]", "*")
    e = e:gsub("[÷]", "/")
    e = e:gsub("[−–—]", "-")
    e = e:gsub("[＋]", "+")
    e = e:gsub("[／]", "/")
    e = e:gsub("[＊]", "*")
    e = e:gsub("[．]", ".")
    return e
end

local function extractEquationFromMessage(text)
    local msg = stripColorCodes(text)
    local lower = msg:lower()
    local solvePos = lower:find("solve", 1, true)
    if not solvePos then return nil end

    local after = msg:sub(solvePos + #"solve")
    after = after:gsub("^[%s:]+", "")

    local candidate = after:match("^([0-9%+%-%*/xX%.%(%)%s×÷−–—＋／＊．]+)")
    if not candidate then return nil end

    candidate = normalizeEquation(candidate)

    if candidate:find("[^0-9%+%-%*/%.%(%)]+") then
        return nil
    end

    if not (candidate:find("%d") and candidate:find("[%+%-%*/]")) then
        return nil
    end

    return candidate
end

function main()
    while not isSampAvailable() do wait(100) end
    printStringNow("~g~Math Detector Loaded~n~~w~Will auto-answer math prompts", 3000)

    while true do
        wait(0)

        if pendingAnswer then
            local remaining = pendingSendTime - os.clock()
            if remaining > 0 then
                printStringNow(string.format("~w~Math answer in ~y~%d~w~s", math.ceil(remaining)), 500)
            end
        end

        if pendingAnswer and os.clock() >= pendingSendTime then
            sampSendChat(ANSWER_CMD .. " " .. pendingAnswer)
            pendingAnswer = nil
            pendingSendTime = 0
            pendingEquation = nil
        end
    end
end

function sampev.onServerMessage(color, text)
    if DEBUG then
        msg("debug", text)
    end

    if not (text:find("Math:", 1, true) and text:lower():find("solve", 1, true)) then
        return
    end

    local equation = extractEquationFromMessage(text)
    if not equation then
        if DEBUG then
            msg("warn", "Could not extract equation from: " .. stripColorCodes(text))
        end
        return
    end

    if DEBUG then
        msg("info", "Equation: " .. equation)
    end

    local func, loadErr = load("return " .. equation)
    if not func then
        if DEBUG then
            msg("error", "load() failed: " .. tostring(loadErr))
        end
        return
    end

    local ok, result = pcall(func)
    if not ok then
        if DEBUG then
            msg("error", "calc failed: " .. tostring(result))
        end
        return
    end

    local answer = math.floor(tonumber(result) + 0.5)

    local delay = math.random(8, 13)
    pendingAnswer = answer
    pendingSendTime = os.clock() + delay
    pendingEquation = equation

    msg("found", ("%d \183 %s \183 %ds delay"):format(answer, equation, delay))
end
