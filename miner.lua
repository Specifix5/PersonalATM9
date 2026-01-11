local miner = peripheral.wrap("left")

local function mine()
    if miner.getToMine() == 0 then
        miner.reset()
        miner.start()
        return true
    end
    return false
end

term.clear()
print("By Specifix5 -- Digital Miner Restarter")
print("Starting to mine now!")

local running = true

local previousAmount = -1
local failAmount = 0

while running do
    if not mine() then
        sleep(10)
    end
    
    if previousAmount == 0 and miner.getToMine() == 0 then
        failAmount = failAmount + 1
        if failAmount > 3 then
            print("Can't detect any blocks -- Stopping, requires manual intervention!")
            running = false
        end
    else
        previousAmount = miner.getToMine()
    end
end
