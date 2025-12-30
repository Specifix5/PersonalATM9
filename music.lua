local dfpwm = require("cc.audio.dfpwm")
local speaker = peripheral.find("speaker")
local monitors = { peripheral.find("monitor") }
local decoder = dfpwm.make_decoder()

local rednetEnabled = false
local modems = { peripheral.find("modem") }
if #modems > 0 then
    for _, modem in pairs(modems) do
        local name = peripheral.getName(modem)
        rednet.open(name)
    end
    rednetEnabled = true
end

local songName = "None"
local numChunks = 0

local radioConfigs = {
    ["stationName"] = "ULTRAKILL",
    ["EAS"] = false
}

function string.split(inputstr, sep)
    if sep == nil then
      sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
      table.insert(t, str)
    end
    return t
end

function readEnvOverride()
    if not fs.exists("/radio.env") then
        print("/radio.env does not exist, skipping env override, using defaults")
        return
    end

    local currentLine = 0
    local success = 0
    for line in io.lines("/radio.env") do
        currentLine += 1
        local _split = string.split(line, "=")
        if #_split ~= 2 then
            print("Line "..currentLine.." malformed, skipping..")
        else
            local name, value = _split[1], _split[2]
            radioConfigs[name] = value
            success += 1
        end
    end

    if success > 0 then
        print("/radio.env found, overriden "..success.." config vars")
    end
end

function getTotalChunks(file)
    local _chunks = 0
    for chunk in io.lines(file, 16 * 1024) do
        _chunks = _chunks + 1
    end
    return _chunks
end

function broadcast(songName, currentChunk, numChunks, audio_chunk, stationName)
    rednet.broadcast({
        ["songName"] = songName,
        ["stationName"] = stationName,
        ["currentChunk"] = currentChunk,
        ["numChunks"] = numChunks,
        ["audio_chunk"] = audio_chunk,
        ["EAS"] = EAS
    }, "RADIO")
end

function listDfpwmFiles()
    local files = fs.list("/")
    local audioFiles = {}
    for _, file in ipairs(files) do
        if string.match(file, ".dfpwm") then
            local editedName = string.gsub(file, ".dfpwm", "")
            table.insert(audioFiles, editedName)
        end
    end

    term.setTextColor(colors.yellow)
    print("Available Audio Files (found "..#audioFiles.."):")
    term.setTextColor(colors.white)

    for i, file in ipairs(audioFiles) do
        print(i, file)
    end
end

function updateMonitorSongName(newName, currentChunk)
    songName = newName
    for _, monitor in pairs(monitors) do
        monitor.setTextScale(0.5)
        monitor.clear()
        monitor.setCursorPos(1, 1) 
        monitor.setTextColor(colors.white)
        monitor.write("Simple Music Player by ")
        monitor.setTextColor(colors.yellow)
        monitor.write("Specifix")
        monitor.setTextColor(colors.white)
        monitor.setCursorPos(1, 2) 
        monitor.write("Currently playing: ")
        if songName == "None" then
            monitor.setTextColor(colors.red)
        else
            monitor.setTextColor(colors.yellow)
        end
        monitor.write(songName)
        monitor.setTextColor(colors.white)

        if songName ~= "None" and currentChunk ~= nil then
            monitor.setCursorPos(1, 4) 
            monitor.write("Playing ")
            monitor.setTextColor(colors.yellow)
            monitor.write(currentChunk.."/"..numChunks)
            monitor.setTextColor(colors.white)
            monitor.write(" chunks")
        end

        if radioConfigs["EAS"] then
            monitor.setCursorPos(1, 5) 
            monitor.setTextColor(colors.red)
            monitor.write("! EAS MODE ACTIVE !")
            monitor.setTextColor(colors.white)
        end

        if rednetEnabled then
            monitor.setCursorPos(1, 6) 
            monitor.setTextColor(colors.yellow)
            monitor.write("REDNET ACTIVE, CAN BROADCAST")
            monitor.setTextColor(colors.white)
            monitor.setCursorPos(1, 7)
            monitor.write("Station: ")
            monitor.setTextColor(colors.yellow)
            monitor.write(radioConfigs["stationName"])
            monitor.setTextColor(colors.white)
            monitor.setCursorPos(1, 8)
            monitor.write("Channel: ")
            monitor.setTextColor(colors.yellow)
            monitor.write("#"..os.getComputerID())
        end

        monitor.setCursorPos(1, 10) 
        monitor.setTextColor(colors.gray)
        monitor.write("~ 2024-2025 (C) CURVE Technologies ~")
        monitor.setTextColor(colors.white)
    end
end

term.clear()
term.setCursorPos(1, 1) 
print("Simple Music/Radio Player by Specifix")
readEnvOverride()
if rednetEnabled then
    print("Rednet active, will broadcast..")
ebd
updateMonitorSongName("None")
broadcast("None", 0, 0, nil, radioConfigs["stationName"])
listDfpwmFiles()
while true do
    term.setTextColor(colors.yellow)
    write("Player> ")
    term.setTextColor(colors.white)
    local file = read()..".dfpwm"
    local chunks = 0
    if fs.exists(file) then
        numChunks = getTotalChunks(file)
        updateMonitorSongName(string.split(file, ".")[1], 0)
        broadcast(songName, 0, numChunks, nil, radioConfigs["stationName"])
        print("Now playing: "..songName)
        for chunk in io.lines(file, 16 * 1024) do
            chunks = chunks + 1
            updateMonitorSongName(songName, chunks)
            broadcast(songName, chunks, numChunks, chunk, radioConfigs["stationName"])
            local buffer = decoder(chunk)
        
            while not speaker.playAudio(buffer) do
                os.pullEvent("speaker_audio_empty")
            end
        end
    else
        term.setTextColor(colors.red)
        print("Not a DFPWM file or File not found!")
        updateMonitorSongName("None")
        broadcast("None", 0, 0, nil, radioConfigs["stationName"])
    end
    if chunks > 0 then
        term.setTextColor(colors.yellow)
        print("Audio finished, # of chunks: "..chunks)
        updateMonitorSongName("None")
        broadcast("None", 0, 0, nil, radioConfigs["stationName"])
    else
        term.setTextColor(colors.red)
        print("Failed to play audio.. It didn't load.")
        updateMonitorSongName("None")
        broadcast("None", 0, 0, nil, radioConfigs["stationName"])
    end
    term.setTextColor(colors.white)
    listDfpwmFiles()
end
