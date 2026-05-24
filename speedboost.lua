-- speedboost.lua
-- Hold Left Alt to smoothly accelerate forward — longer hold = faster

script_name("SpeedBoost")
script_author("BOJO Dev")
script_version("4.0")

require 'lib.moonloader'
local ffi = require 'ffi'

local VEHICLE_POINTER_SELF = 0x00B6F980
local VEH_SPEED = 68
local VEH_SPIN = 80

local VK_LMENU = 0xA4  -- Left Alt

local MAX_SPEED = 250.0
local ACCEL_START = 0.1
local ACCEL_INCREASE = 0.003
local ACCEL_MAX = 2.5

local holdTime = 0

local function readPtr(addr)
    return ffi.cast("uint32_t*", addr)[0]
end

local function readFloat(addr)
    return ffi.cast("float*", addr)[0]
end

local function writeFloat(addr, val)
    ffi.cast("float*", addr)[0] = val
end

-- GTA/SA matrix: right=X, up=Y(forward!), at=Z(up)
-- forward = "up" vector at +16, +20, +24
local function getFwdDir(vehAddr)
    local sx = readFloat(vehAddr + VEH_SPEED)
    local sy = readFloat(vehAddr + VEH_SPEED + 4)
    local hspd = math.sqrt(sx*sx + sy*sy)
    if hspd > 0.5 then
        return sx / hspd, sy / hspd
    end
    local mat = readPtr(vehAddr + 20)
    if mat == 0 then return 0, 0 end
    local fx = readFloat(mat + 16)  -- up.x = forward.x
    local fy = readFloat(mat + 20)  -- up.y = forward.y
    local flen = math.sqrt(fx*fx + fy*fy)
    if flen < 0.01 then return 0, 0 end
    return fx / flen, fy / flen
end

function main()
    repeat wait(100) until isSampAvailable()
    wait(3000)

    while true do
        wait(0)

        if isKeyDown(VK_LMENU) then
            local v2 = readPtr(VEHICLE_POINTER_SELF)
            if v2 ~= 0 then
                holdTime = holdTime + 1

                local sx = readFloat(v2 + VEH_SPEED)
                local sy = readFloat(v2 + VEH_SPEED + 4)
                local sz = readFloat(v2 + VEH_SPEED + 8)
                local hspd = math.sqrt(sx*sx + sy*sy)

                if hspd < MAX_SPEED then
                    local dx, dy = getFwdDir(v2)
                    if dx ~= 0 or dy ~= 0 then
                        local currentAccel = ACCEL_START + (holdTime * ACCEL_INCREASE)
                        if currentAccel > ACCEL_MAX then currentAccel = ACCEL_MAX end
                        local newHspd = hspd + currentAccel
                        if newHspd > MAX_SPEED then newHspd = MAX_SPEED end
                        sx = dx * newHspd
                        sy = dy * newHspd
                    end
                end

                writeFloat(v2 + VEH_SPEED, sx)
                writeFloat(v2 + VEH_SPEED + 4, sy)
                writeFloat(v2 + VEH_SPEED + 8, sz)
                writeFloat(v2 + VEH_SPIN, 0.0)
                writeFloat(v2 + VEH_SPIN + 4, 0.0)
                writeFloat(v2 + VEH_SPIN + 8, 0.0)
            end
        else
            holdTime = 0
        end
    end
end
