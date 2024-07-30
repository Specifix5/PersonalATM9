local cb = peripheral.find("chatBox")

while os.sleep(0.25) do
    local event, username, message, uuid, isHidden = os.pullEvent("chat")

    
    cb.sendMessage(message:gsub("o", "wo"):gsub("r", "w"), username, "<>");
end
