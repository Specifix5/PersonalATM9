local dfpwm = require("cc.audio.dfpwm")
local speakers = { peripheral.find("speaker") }
local monitors = { peripheral.find("monitor") }
local modems = { peripheral.find("modem") }
local wiredModems = {}
local decoder = dfpwm.make_decoder()

local rednetOpened = false

for _, modem in pairs(modems) do
    if modem.isWireless() and not rednetOpened then
        rednet.open(peripheral.getName(modem))
        rednetOpened = true
    elseif not modem.isWireless() then
        table.insert(wiredModems, modem)
    end
end

function updateMonitorSongName(newName, currentChunk, stationName, numChunks)
    songName = newName
    for _, monitor in pairs(monitors) do
        monitor.setTextScale(0.5)
        monitor.clear()
        monitor.setCursorPos(1, 1) 
        monitor.setTextColor(colors.white)
        monitor.write("Station: ")
        monitor.setTextColor(colors.yellow)
        monitor.write(stationName)
        monitor.setTextColor(colors.white)
        monitor.setCursorPos(1, 2) 
        monitor.write("Playing: ")
        if songName == "None" then
            monitor.setTextColor(colors.red)
        else
            monitor.setTextColor(colors.yellow)
        end
        monitor.write(songName)
        monitor.setTextColor(colors.white)

        if songName ~= "None" and currentChunk ~= nil then
            monitor.setCursorPos(1, 4) 
            monitor.write("Chunk: ")
            monitor.setTextColor(colors.yellow)
            monitor.write(currentChunk.."/"..numChunks)
            monitor.setTextColor(colors.white)
        end

        monitor.setCursorPos(1, 5) 
        monitor.write("Speakers/Modem: ")
        monitor.setTextColor(colors.yellow)
        monitor.write(#speakers.."/"..#wiredModems)
        monitor.setTextColor(colors.white)
    end
end

local function play_all(buffer)
    local speaker_funcs = {}
  
    for i, speaker in ipairs(speakers) do
        local speaker_name = peripheral.getName(speaker)
        speaker_funcs[i] = function()
            speaker.playAudio(buffer)
    
            -- wait until THIS speaker is ready for more buffer
            repeat
                local _, spkr = os.pullEvent("speaker_audio_empty")
            until spkr == speaker_name
        end
    end
    
    -- Unpack the table of functions into parallel.waitForAll, so it runs them all at once.
    parallel.waitForAll(table.unpack(speaker_funcs))
end

term.clear()

updateMonitorSongName("None", 0, "Idle", 0)
for _, speaker in pairs(speakers) do
    speaker.stop()
end

while true do
    id, message = rednet.receive("RADIO", 5)
    if message ~= nil and message.audio_chunk ~= nil then
        updateMonitorSongName(message.songName, message.currentChunk, message.stationName.." (CH#"..id..")", message.numChunks)
        local buffer = decoder(message.audio_chunk)
        play_all(buffer)

    elseif message == nil then
        updateMonitorSongName("None", 0, "Idle", 0)
    else
        updateMonitorSongName(message.songName, message.currentChunk, message.stationName.." (CH#"..id..")", message.numChunks)
    end
end
