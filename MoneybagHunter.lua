--[[
    Moneybag Hunter v3.3
    Two-Phase Routing: Phase 1 = coarse sweep with 250m skip radius,
    Phase 2 = visit every skipped node. 100% coverage, faster detection.
    /hunt toggle | /hunt status | /hunt reload
]]
script_name("Moneybag Hunter")
script_author("BOJO Dev")
script_version("3.3")

require 'lib.moonloader'
local sampev = require 'lib.samp.events'
local encoding = require 'encoding'
encoding.default = 'CP1251'
local u8 = encoding.UTF8

local POSITIONS_FILE = getWorkingDirectory() .. "\\config\\SavedPositions.json"
local MODEL_MONEYBAG = 1550
local MONEYBAG_DETECT_DIST = 300.0
local CLEAR_RADIUS = 250.0
local STREAM_WAIT_MS = 800
local FAST_WAIT_MS = 250
local Z_SAFETY_OFFSET = 5.0

local scanActive = false
local positions = {}
local currentIndex = 0
local moneybags = {}
local foundBag = false
local loopCount = 0
local lastTeleportName = ""
local totalTeleports = 0
local scanned = {}
local skipped = {}
local scannedCount = 0
local phase = 1
local streamWaitStart = 0

local C = { GOLD = "{BFA100}", GREEN = "{33AA33}", CYAN = "{33CCFF}", GRAY = "{888888}", RED = "{FF5555}", WHITE = "{FFFFFF}" }
local PREFIX = C.GOLD .. "[H]" .. C.WHITE .. " > "

local function msg(kind, text)
    if isSampAvailable() then
        local colors = { found = C.GREEN, scan = C.GOLD, passive = C.GRAY, status = C.CYAN, error = C.RED, info = C.WHITE }
        sampAddChatMessage(PREFIX .. (colors[kind] or colors.info) .. text, 0xFFFFFFFF)
    end
end

local function dist3d(x1, y1, z1, x2, y2, z2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2)
end

local function loadPositions()
    positions = {}
    local file = io.open(POSITIONS_FILE, "r")
    if not file then return false, "Cannot open SavedPositions.json" end
    local content = file:read("*a")
    file:close()
    if not content or content == "" then return false, "File is empty" end

    local func, err = loadstring("return " .. content)
    if not func then return false, "Parse error" end

    local success, data = pcall(func)
    if not success or type(data) ~= "table" then return false, "Invalid data" end

    for i, v in ipairs(data) do
        if type(v) == "table" and type(v.x) == "number" and type(v.y) == "number" and type(v.z) == "number" then
            table.insert(positions, v)
        end
    end

    if #positions == 0 and type(data.x) == "number" then
        table.insert(positions, data)
    end

    return #positions > 0, #positions
end

local function smartFindTarget()
    if not next(moneybags) then return nil end

    local bestPos, bestDist, bestBag = nil, MONEYBAG_DETECT_DIST, nil

    for _, pos in ipairs(positions) do
        for _, bag in pairs(moneybags) do
            local d = dist3d(pos.x, pos.y, pos.z, bag.x, bag.y, bag.z)
            if d < bestDist then
                bestDist = d
                bestPos = pos
                bestBag = bag
            end
        end
    end

    return bestPos, bestDist, bestBag
end

local function teleportTo(pos)
    if not pos then return end
    local tx = pos.x + (math.random() - 0.5) * 2.0
    local ty = pos.y + (math.random() - 0.5) * 2.0
    local tz = pos.z + Z_SAFETY_OFFSET

    if isCharInAnyCar(PLAYER_PED) then
        local car = storeCarCharIsInNoSave(PLAYER_PED)
        setCarCoordinates(car, tx, ty, tz)
        setCarHeading(car, math.random() * 360)
    else
        setCharCoordinates(PLAYER_PED, tx, ty, tz)
        setCharHeading(PLAYER_PED, math.random() * 360)
    end
    if pos.interior and pos.interior ~= 0 then setActiveInterior(pos.interior) end
    restoreCameraJumpcut()
    lastTeleportName = pos.name or "Unnamed"
    totalTeleports = totalTeleports + 1
end

-- Finds nearest position eligible for Phase 1: not scanned AND not skipped
local function findNearestPhase1()
    local px, py, pz = getCharCoordinates(PLAYER_PED)
    local bestIdx, bestDist = nil, math.huge
    for i, pos in ipairs(positions) do
        if not scanned[i] and not skipped[i] then
            local d = dist3d(px, py, pz, pos.x, pos.y, pos.z)
            if d < bestDist then
                bestDist = d
                bestIdx = i
            end
        end
    end
    return bestIdx
end

-- Finds nearest skipped position for Phase 2: not scanned but IS skipped
local function findNearestPhase2()
    local px, py, pz = getCharCoordinates(PLAYER_PED)
    local bestIdx, bestDist = nil, math.huge
    for i, pos in ipairs(positions) do
        if not scanned[i] and skipped[i] then
            local d = dist3d(px, py, pz, pos.x, pos.y, pos.z)
            if d < bestDist then
                bestDist = d
                bestIdx = i
            end
        end
    end
    return bestIdx
end

local function startScan()
    if not isSampAvailable() then msg("error", "You need to be in SA:MP first"); return end
    if #positions == 0 then msg("error", "No positions loaded. Use /hunt reload"); return end

    local target, dist, bag = smartFindTarget()
    if target then
        msg("found", ("Located near '%s' (%.1fm)"):format(target.name or "Unnamed", dist))
        teleportTo(target)
        foundBag = true
        return
    end

    scanned = {}; skipped = {}; scannedCount = 0; loopCount = 0; foundBag = false; totalTeleports = 0; phase = 1
    currentIndex = findNearestPhase1() or 1
    if currentIndex <= #positions then
        msg("scan", ("Phase 1 starting at '%s'"):format(positions[currentIndex].name or "Unnamed"))
        teleportTo(positions[currentIndex])
        streamWaitStart = os.clock()
    end
    scanActive = true
end

local function getNearestMoneybag()
    if not isSampAvailable() then return nil, 0 end
    local px, py, pz = getCharCoordinates(PLAYER_PED)
    local nearest, nearestDist, total = nil, MONEYBAG_DETECT_DIST, 0
    for id, bag in pairs(moneybags) do
        total = total + 1
        local d = dist3d(px, py, pz, bag.x, bag.y, bag.z)
        if d < nearestDist then nearestDist = d; nearest = bag end
    end
    return nearest, nearestDist, total
end

local function stopScan()
    if not scanActive then msg("error", "Scan is not running"); return end
    scanActive = false
    local _, _, bc = getNearestMoneybag()
    msg("status", ("Scan stopped | TP: %d | P%d: %d/%d | Bags: %d"):format(totalTeleports, phase, scannedCount, #positions, bc))
end

function sampev.onCreatePickup(id, model, pickupType, position)
    if model == MODEL_MONEYBAG then
        moneybags[id] = {x = position.x, y = position.y, z = position.z}
        if scanActive and not foundBag then
            local target, dist, _ = smartFindTarget()
            if target then
                msg("found", ("Spawned near '%s' (%.1fm) — warping"):format(target.name or "Unnamed", dist))
                teleportTo(target)
                foundBag = true; scanActive = false
            end
        end
    end
end
function sampev.onDestroyPickup(id) moneybags[id] = nil end
function sampev.onSendPickedUpPickup(pickupId)
    if moneybags[pickupId] then
        moneybags[pickupId] = nil
        msg("info", "Moneybag was picked up by someone else")
    end
end

local function onCommand(params)
    params = params or ""
    local parts = {}
    for w in params:gmatch("%S+") do parts[#parts+1] = w end
    local sub = parts[1] or ""

    if sub == "status" then
        local _, _, bc = getNearestMoneybag()
        if scanActive then
            local remaining = #positions - scannedCount
            msg("status", ("P%d: %d/%d | %d remain | bags: %d"):format(phase, scannedCount, #positions, remaining, bc))
        elseif foundBag then
            msg("found", ("Located at '%s' | TP: %d"):format(lastTeleportName, totalTeleports))
        else
            local target, dist, _ = smartFindTarget()
            if target then
                msg("passive", ("Detected near '%s' (%.1fm) \183 /hunt to travel"):format(target.name or "Unnamed", dist))
            else
                msg("status", ("Idle \183 %d positions \183 %d bags tracked \183 /hunt to start"):format(#positions, bc))
            end
        end
    elseif sub == "reload" then
        local ok, n = loadPositions()
        msg(ok and "info" or "error", ok and ("Reloaded %d positions"):format(n) or "Reload failed")
    elseif sub == "" then
        if scanActive then stopScan() else startScan() end
    else
        msg("info", "Commands: /hunt (toggle) /hunt status /hunt reload")
    end
    return 1
end

function main()
    repeat wait(100) until isSampAvailable()
    wait(5000)

    local ok, n = loadPositions()
    msg(ok and "info" or "error", ok and ("Loaded %d positions"):format(n) or "Load error")

    sampRegisterChatCommand("hunt", onCommand)

    while true do
        wait(0)

        if isSampAvailable() then
            local bagCount = 0
            for _ in pairs(moneybags) do bagCount = bagCount + 1 end

            -- Passive smart check
            if not scanActive and not foundBag and bagCount > 0 then
                local target, dist = smartFindTarget()
                if target and lastTeleportName ~= target.name then
                    msg("passive", ("Detected near '%s' (%.1fm) \183 /hunt to travel"):format(target.name or "Unnamed", dist))
                    lastTeleportName = target.name
                end
            end

            -- Two-Phase scan logic
            if scanActive and not foundBag then
                local target, dist = smartFindTarget()
                if target then
                    foundBag = true; scanActive = false
                    msg("found", ("Located near '%s' (%.1fm) — warping"):format(target.name or "Unnamed", dist))
                    teleportTo(target)
                elseif streamWaitStart > 0 then
                    local elapsed = (os.clock() - streamWaitStart) * 1000
                    local waitMs = bagCount > 0 and STREAM_WAIT_MS or FAST_WAIT_MS
                    if elapsed >= waitMs then
                        -- Mark current position as scanned
                        scanned[currentIndex] = true
                        scannedCount = scannedCount + 1

                        if phase == 1 then
                            -- Phase 1: skip nearby positions
                            local cx, cy, cz = positions[currentIndex].x, positions[currentIndex].y, positions[currentIndex].z
                            for i, pos in ipairs(positions) do
                                if not scanned[i] and not skipped[i] then
                                    if dist3d(cx, cy, cz, pos.x, pos.y, pos.z) < CLEAR_RADIUS then
                                        skipped[i] = true
                                    end
                                end
                            end
                        end

                        -- Find next target
                        local nextIdx = phase == 1 and findNearestPhase1() or findNearestPhase2()
                        if not nextIdx and phase == 1 then
                            -- Phase 1 exhausted — switch to Phase 2
                            phase = 2
                            nextIdx = findNearestPhase2()
                            if nextIdx then
                                msg("scan", ("Phase 1 done. Starting Phase 2 gap fill (%d positions)"):format(#positions - scannedCount))
                            end
                        end

                        if nextIdx then
                            currentIndex = nextIdx
                            msg("scan", ("P%d: %d/%d \183 %s"):format(phase, scannedCount + 1, #positions, positions[currentIndex].name or "Unnamed"))
                            teleportTo(positions[currentIndex])
                            streamWaitStart = os.clock()
                        else
                            -- Full cycle complete — reset
                            loopCount = loopCount + 1
                            scanned = {}; skipped = {}; scannedCount = 0; phase = 1
                            currentIndex = findNearestPhase1() or 1
                            msg("scan", ("Cycle #%d done \183 %d bags \183 /hunt to stop"):format(loopCount, bagCount))
                            teleportTo(positions[currentIndex])
                            streamWaitStart = os.clock()
                        end
                    end
                end
            end
        end
    end
end
