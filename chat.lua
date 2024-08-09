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

if fs.exists("./history.json") then
    local _ = fs.open("./history.json", "r")
    local _json = textutils.unserializeJSON(_.readAll())
    messageHistory = _json
    _.close()
end

term.clear()
print("Femboyinator v1.0 by Specifix")
print("- Frame anyone as a femboy -")

while true do
    local event, username, message, uuid, isHidden = os.pullEvent("chat")

    messageHistory[username] = message

    local _ = fs.open("./history.json", "w")
    local _json = textutils.serializeJSON(messageHistory)
    _.write(_json)
    _.close()

    if string.starts(username, "nekoyuri") or string.starts(username, "Destroye3t") or string.starts(username, "WhiteWorrior123") then
        local args = string.split(message, " ")
        if string.starts(message, "femboy") then
            if messageHistory[args[2]] ~= nil then
                if args[2] == "nekoyuri" then
                    local _username = username
                    cb.sendMessage("i-i-i feel a little c-cute~ >w<", _username, "<>");
                    return
                end
                local femboyed = messageHistory[args[2]]:gsub("o", "wo"):gsub("r", "w"):gsub("l", "w").." >//w//<"
                femboyed = string.sub(femboyed, 1, 1).."-"..femboyed
                femboyed = string.lower(femboyed)
                local _username = args[2]
                print(args[2].."> "..femboyed)
                cb.sendMessage(femboyed, _username, "<>");
            else
                print("Femboy "..args[2].." is nil!")
            end
        end
    end
end
