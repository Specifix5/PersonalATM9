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

while true do
    local event, username, message, uuid, isHidden = os.pullEvent("chat")

    messageHistory[username] = message

    if string.starts(username, "nekoyuri") then
        local args = string.split(message, " ")
        if string.starts(message, "femboy") then
            if messageHistory[args[2]] ~= nil then
                local femboyed = messageHistory[args[2]]:gsub("o", "wo"):gsub("r", "w").." >w<"
                print(args[2].."> "..femboyed)
                cb.sendMessage(femboyed, args[2], "<>");
            else
                print("Femboy "..args[2].." is nil!")
            end
        end
    end
end
