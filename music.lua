local dfpwm = require("cc.audio.dfpwm")
local speaker = peripheral.find("speaker")
local monitors = { peripheral.find("monitor") }
local decoder = dfpwm.make_decoder()

local songName = "None"

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

function updateMonitorSongName(newName)
    songName = newName
    for _, monitor in pairs(monitors) do
        monitor.clear()
        monitor.setCursorPos(1, 1) 
        monitor.setTextColor(colors.white)
        monitor.write("Simple Music Player by ")
        monitor.write(colors.yellow)
        monitor.write("Specifix\n")
        monitor.setTextColor(colors.white)
        monitor.write("Currently playing: ")
        if songName == "None" then
            monitor.setTextColor(colors.red)
        else
            monitor.setTextColor(colors.yellow)
        end
        monitor.write(songName)
        monitor.setTextColor(colors.white)
    end
end

term.clear()
term.setCursorPos(1, 1) 
updateMonitorSongName("None")
print("Simple Music Player by Specifix")
while true do
    term.setTextColor(colors.yellow)
    write("Player> ")
    term.setTextColor(colors.white)
    local file = read()
    local chunks = 0
    if string.split(file, ".")[2] ~= nil and string.split(file, ".")[2] == "dfpwm" then
        updateMonitorSongName(string.split(file, ".")[1])
        print("Now playing: "..songName)
        for chunk in io.lines(file, 16 * 1024) do
            chunks = chunks + 1
            local buffer = decoder(chunk)
        
            while not speaker.playAudio(buffer) do
                os.pullEvent("speaker_audio_empty")
            end
        end
    end
    if chunks > 0 then
        term.setTextColor(colors.yellow)
        print("Audio finished, # of chunks: "..chunks)
        updateMonitorSongName("None")
    else
        term.setTextColor(colors.red)
        print("Failed to play audio.. It didn't load.")
        updateMonitorSongName("None")
    end
    term.setTextColor(colors.white)
end
