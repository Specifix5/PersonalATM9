local miners = { peripheral.find("digitalMiner") }
if #miners == 0 then
    print("No Digital miners found!")
    return
end

local miner = miners[1]

local function mine()
    if miner.getToMine() == 0 then
        miner.reset()
        miner.start()
        return true
    end
    return false
end

term.clear()
print("By Specifix5 -- Digital Miner Restarter v1.1")
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
            print("Can't detect any blocks! Retry count: "..failAmount)
            sleep(10)
        end
    else
        failAmount = 0
        previousAmount = miner.getToMine()
    end
end
