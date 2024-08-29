local dfpwm = require("cc.audio.dfpwm")
local speaker = peripheral.find("speaker")
local decoder = dfpwm.make_decoder()

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

print("Simple Music Player by Specifix")
while true do
    write("Player> ")
    local file = read()
    local chunks = 0
    if string.split(file, ".")[2] ~= nil and string.split(file, ".")[2] == "dfpwm" then
        print("Now playing: "..string.split(file, ".")[1])
        for chunk in io.lines(file, 16 * 1024) do
            chunks = chunks + 1
            local buffer = decoder(chunk)
        
            while not speaker.playAudio(buffer) do
                os.pullEvent("speaker_audio_empty")
            end
        end
    end
    print("Audio finished, # of chunks: "..chunks)
end
