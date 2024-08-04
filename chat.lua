local cb = peripheral.find("chatBox")

function string.starts(String,Start)
    return string.sub(String,1,string.len(Start))==Start
end

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

local messageHistory = {}

if fs.exists("rom/history.json") then
    local _ = fs.open("rom/history.json", "r")
    local _json = textutils.unserializeJSON(_.readAll())
    messageHistory = _json
    _.close()
end

while true do
    local event, username, message, uuid, isHidden = os.pullEvent("chat")

    messageHistory[username] = message

    local _ = fs.open("rom/history.json", "w+")
    local _json = textutils.serializeJSON(messageHistory)
    _.write(_json)
    _.close()

    if string.starts(username, "nekoyuri") then
        local args = string.split(message, " ")
        if string.starts(message, "femboy") then
            if messageHistory[args[2]] ~= nil then
                local femboyed = messageHistory[args[2]]:gsub("o", "wo"):gsub("r", "w"):gsub("l", "w").." >//w//<"
                femboyed = string.sub(femboyed, 1, 1).."-"..femboyed
                femboyed = string.lower(femboyed)
                local _username = args[2]
                if (_username == "WhiteWorrior123" or _username == "glitch_inthecode") then
                    _username = "§2"..args[2]
                end
                print(args[2].."> "..femboyed)
                cb.sendMessage(femboyed, args[2], "<>");
            else
                print("Femboy "..args[2].." is nil!")
            end
        end
    end
end
