--[[
    Moneybag Hunter v3.1
    Cluster-skipping scan: After checking a position, clears all nearby (300m)
    positions too — no redundant TPs. /hunt toggle | /hunt status | /hunt reload
]]
script_name("Moneybag Hunter")
script_author("BOJO Dev")
script_version("3.1")

require 'lib.moonloader'
local sampev = require 'lib.samp.events'
local encoding = require 'encoding'
encoding.default = 'CP1251'
local u8 = encoding.UTF8

local POSITIONS_FILE = getWorkingDirectory() .. "\\config\\SavedPositions.json"
local MODEL_MONEYBAG = 1550
local MONEYBAG_DETECT_DIST = 300.0
local CLEAR_RADIUS = 300.0
local STREAM_WAIT_MS = 800
local Z_SAFETY_OFFSET = 5.0

local scanActive = false
local positions = {}
local currentIndex = 0
local moneybags = {}
local foundBag = false
local loopCount = 0
local lastTeleportName = ""
local totalTeleports = 0
local cleared = {}
local clearedCount = 0
local streamWaitStart = 0

local function chat(msg, color)
    if isSampAvailable() then
        sampAddChatMessage("{BFA100}[Hunt]{FFFFFF} " .. msg, color or 0xFFFFFFFF)
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

--[[
  SMART SCAN: For each saved position, check if ANY tracked moneybag
  is within 300m of that position's coordinates. If found, teleport there
  directly — no need to TP to every position one by one.
]]
local function smartFindTarget()
    if not next(moneybags) then return nil end  -- no moneybags tracked

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

local function markClusterCleared(posIdx)
    if cleared[posIdx] then return end
    cleared[posIdx] = true
    clearedCount = clearedCount + 1
    local cx, cy, cz = positions[posIdx].x, positions[posIdx].y, positions[posIdx].z
    for i, pos in ipairs(positions) do
        if not cleared[i] then
            local d = dist3d(cx, cy, cz, pos.x, pos.y, pos.z)
            if d < CLEAR_RADIUS then
                cleared[i] = true
                clearedCount = clearedCount + 1
            end
        end
    end
end

local function findNearestUncleared()
    local px, py, pz = getCharCoordinates(PLAYER_PED)
    local bestIdx, bestDist = nil, math.huge
    for i, pos in ipairs(positions) do
        if not cleared[i] then
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
    if not isSampAvailable() then chat("You need to be in SA:MP first"); return end
    if #positions == 0 then chat("No positions loaded! Use /hunt reload"); return end

    -- SMART: first check if any saved position has a moneybag within 300m
    local target, dist, bag = smartFindTarget()
    if target then
        chat(("MONEYBAG LOCATED near '%s' (%.1fm) — warping..."):format(target.name or "Unnamed", dist))
        teleportTo(target)
        foundBag = true
        return
    end

    -- No match found — start cluster-skipping scan
    cleared = {}; clearedCount = 0; loopCount = 0; foundBag = false; totalTeleports = 0
    currentIndex = findNearestUncleared() or 1
    if currentIndex <= #positions then
        chat(("Smart scan: no matches. Starting cluster scan from '%s'..."):format(positions[currentIndex].name or "Unnamed"))
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
    if not scanActive then chat("Scan is not active"); return end
    scanActive = false
    local _, _, bc = getNearestMoneybag()
    chat(("Scan OFF — TP: %d, Cleared: %d/%d, Bags: %d"):format(totalTeleports, clearedCount, #positions, bc))
end

function sampev.onCreatePickup(id, model, pickupType, position)
    if model == MODEL_MONEYBAG then
        moneybags[id] = {x = position.x, y = position.y, z = position.z}
        -- If scan is running, immediately check if this new bag is near a saved position
        if scanActive and not foundBag then
            local target, dist, _ = smartFindTarget()
            if target then
                chat(("MONEYBAG SPAWNED near '%s' (%.1fm) — warping!"):format(target.name or "Unnamed", dist))
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
        chat("Moneybag was picked up by someone")
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
            local remaining = #positions - clearedCount
            chat(("At '%s' | TP#%d | Cleared %d/%d (%d remain) | Bags: %d"):format(
                positions[currentIndex].name or "Unnamed", totalTeleports, clearedCount, #positions, remaining, bc))
        elseif foundBag then
            chat(("MONEYBAG FOUND near %s | TP#%d"):format(lastTeleportName, totalTeleports))
        else
            -- Show smart scan info
            local target, dist, _ = smartFindTarget()
            if target then
                chat(("READY: '%s' has a moneybag %.1fm away — /hunt to go!"):format(target.name or "Unnamed", dist))
            else
                chat(("IDLE — %d positions, %d bags tracked | /hunt to start"):format(#positions, bc))
            end
        end
    elseif sub == "reload" then
        local ok, n = loadPositions()
        chat(ok and ("Reloaded %d positions"):format(n) or "Reload failed")
    elseif sub == "" then
        if scanActive then stopScan() else startScan() end
    else
        chat("Commands: /hunt (toggle), /hunt status, /hunt reload")
    end
    return 1
end

function main()
    repeat wait(100) until isSampAvailable()
    wait(5000)

    local ok, n = loadPositions()
    sampAddChatMessage("{BFA100}[Hunt]{FFFFFF} " .. (ok and ("Loaded " .. n .. " positions | Smart scan ready") or "Load error"), 0xFFFFFFFF)

    sampRegisterChatCommand("hunt", onCommand)

    while true do
        wait(0)

        if isSampAvailable() then
            local bagCount = 0
            for _ in pairs(moneybags) do bagCount = bagCount + 1 end

            -- Passive smart check (even when idle)
            if not scanActive and not foundBag and bagCount > 0 then
                local target, dist = smartFindTarget()
                if target and lastTeleportName ~= target.name then
                    chat(("SMART: '%s' has moneybag nearby (%.1fm) — /hunt to go"):format(target.name or "Unnamed", dist))
                    lastTeleportName = target.name
                end
            end

            -- Scan logic with cluster skipping
            if scanActive and not foundBag then
                -- Always re-check for any new moneybag
                local target, dist = smartFindTarget()
                if target then
                    foundBag = true; scanActive = false
                    chat(("MONEYBAG FOUND near '%s' (%.1fm) — warping!"):format(target.name or "Unnamed", dist))
                    teleportTo(target)
                elseif streamWaitStart > 0 then
                    -- Waiting for pickups to stream in at current position
                    local elapsed = (os.clock() - streamWaitStart) * 1000
                    if elapsed >= STREAM_WAIT_MS then
                        -- No match here — mark cluster cleared, move to next
                        markClusterCleared(currentIndex)
                        local remaining = #positions - clearedCount
                        chat(("No bags at '%s'. Cleared %d/%d (%d remain)"):format(
                            positions[currentIndex].name or "Unnamed", clearedCount, #positions, remaining))
                        local nextIdx = findNearestUncleared()
                        if nextIdx then
                            currentIndex = nextIdx
                            teleportTo(positions[currentIndex])
                            streamWaitStart = os.clock()
                        else
                            loopCount = loopCount + 1
                            chat(("Full clear #%d. %d bags tracked — no match. /hunt to re-scan"):format(loopCount, bagCount))
                            scanActive = false
                            streamWaitStart = 0
                        end
                    end
                end
            end
        end
    end
end