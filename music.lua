local dfpwm = require("cc.audio.dfpwm")
local speaker = peripheral.find("speaker")
local monitors = { peripheral.find("monitor") }
local decoder = dfpwm.make_decoder()

peripheral.find("modem", rednet.open)

local songName = "None"
local numChunks = 0

local StationName = "ULTRAKILL"
local EAS = false

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

        if EAS then
            monitor.setCursorPos(1, 5) 
            monitor.setTextColor(colors.red)
            monitor.write("! EAS MODE ACTIVE !")
            monitor.setTextColor(colors.white)
        end

        monitor.setCursorPos(1, 10) 
        monitor.setTextColor(colors.gray)
        monitor.write("~ 2024 (C) CURVE Technologies ~")
        monitor.setTextColor(colors.white)
    end
end

term.clear()
term.setCursorPos(1, 1) 
updateMonitorSongName("None")
broadcast("None", 0, 0, nil, StationName)
print("Simple Music/Radio Player by Specifix")
while true do
    term.setTextColor(colors.yellow)
    write("Player> ")
    term.setTextColor(colors.white)
    local file = read()..".dfpwm"
    local chunks = 0
    if fs.exists(file) then
        numChunks = getTotalChunks(file)
        updateMonitorSongName(string.split(file, ".")[1], 0)
        broadcast(songName, 0, numChunks, nil, StationName)
        print("Now playing: "..songName)
        for chunk in io.lines(file, 16 * 1024) do
            chunks = chunks + 1
            updateMonitorSongName(songName, chunks)
            broadcast(songName, chunks, numChunks, chunk, StationName)
            local buffer = decoder(chunk)
        
            while not speaker.playAudio(buffer) do
                os.pullEvent("speaker_audio_empty")
            end
        end
    else
        term.setTextColor(colors.red)
        print("Not a DFPWM file or File not found!")
        updateMonitorSongName("None")
        broadcast("None", 0, 0, nil, StationName)
    end
    if chunks > 0 then
        term.setTextColor(colors.yellow)
        print("Audio finished, # of chunks: "..chunks)
        updateMonitorSongName("None")
        broadcast("None", 0, 0, nil, StationName)
    else
        term.setTextColor(colors.red)
        print("Failed to play audio.. It didn't load.")
        updateMonitorSongName("None")
        broadcast("None", 0, 0, nil, StationName)
    end
    term.setTextColor(colors.white)
end
