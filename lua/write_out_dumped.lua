-- Author: Kurt Roots
-- Company: CogCubed
-- *****************************************************
-- Description: It is possible to take a snapshot of the 
-- Sifteo Base contents and store them in filesystem.bin. 
-- But if you want to read anything useful, you need to 
-- know the volume and key. This code simulates writing 
-- to a volume and key (reality - done in game) and then 
-- returning that value from the captured filesystem. 
-- I assume you have a volume 1 and that key 90 is free, 
-- otherwise, sorry. Any key, 0 to ff (255) can be used.
-- *****************************************************
--
-- Usage: siftulator -F filesystem.bin -e write_out_dumped.lua

-- Lua script file

sys = System()
fs = Filesystem()
c = Cube(0)

sys:setOptions{numCubes=1}
sys:init()


function shortVolumeString(vol)
    -- Return a tiny (4 char) representation of a volume, for the usage map

    if not vol then
        -- Block is totally unallocated
        return ' .. '
    end

    local type = fs:volumeType(vol)
    local parent = fs:volumeParent(vol)

    if t == 0x0000 or t == 0xffff then
        -- Deleted / Incomplete
        return ' __ '
    end

    -- Under a parent? Display the parent's info.
    if parent > 0 then
        return string.format(" %02x ", parent)
    end

    -- Normal volume
    return string.format("<%02x>", vol)
    --print(vol)
end

function longVolumeString(vol)
    -- Return a string representation of a volume

    local str = string.format("Volume<%02x> type=%04x parent=%02x {",
        vol, fs:volumeType(vol), fs:volumeParent(vol))

    local map = fs:volumeMap(vol)
    local ec = fs:volumeEraseCounts(vol)

    for i, block in ipairs(map) do
        str = string.format("%s %02x:%d", str, block, ec[i])
    end

    return str .. " }"
end

function dumpAllocation()
    local blocks = {}
    local vols = fs:listVolumes()

    -- Create a reverse mapping from blocks to volumes
    for i, vol in ipairs(vols) do
        local map = fs:volumeMap(vol)
        for j, block in ipairs(map) do
            blocks[block] = vol
        end
    end

    -- Display all FS blocks

    local prevStr = nil
    for block = 1, 128 do

        local str = shortVolumeString(blocks[block])
        io.write((str == prevStr and str ~= ' .. ') and '----' or str)
        prevStr = str

        if (block % 16) == 0 then
            io.write("\n")
            prevStr = nil
        end
    end

    -- Display all volumes

    io.write("\n")
    for i, vol in ipairs(vols) do
        print(longVolumeString(vol))
    end
end


dumpAllocation()

--test writing to memory
fs:writeObject(1,90,"0123456789")

--output status
print("write complete")

--now read contents
print(fs:readObject(1,90))

--output status
print("output complete")

sys:exit()
fe:exit()