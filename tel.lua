-- Args
local args = {...}

-- Thanks to Lyqyd for this function
local function split(separator)
    local results = {}
    for match in string.gmatch(input, "[^ ]+") do
        table.insert(results, match)
    end
    
    return results
end

-- Main function
function main()
    
    -- Open rednet
    local side = args[0] or "top"
    
    -- peer ID
    local peer
    
    -- Get peer
    if args[1] == nil then
        write("peer ID> ")
        peer = read()
    
    else
        peer = args[1]
    end
    
    -- Run event loop
    while true do
    
        event = {os.pullEvent()} -- Get event
        
        if event[0] ~= "rednet_message" and event[0] ~= "modem_message" then
            rednet.send(peer, event) -- Send event
        
        elseif event[0] == "rednet_message" then
        
            -- Check if get
            if split(event[1])[0] == "get" then
            
                -- Get cursor pos
                if split(event[1])[1] == "cursor" then
                
                    success, retval = pcall(term.getCursorPos())
                    
                    if success ~= true then
                        rednet.send(peer, nil)
                    
                    else
                        rednet.send(peer, retval)
                    end
                
                -- Get if term is colour
                elseif split(event[1)[1] == "iscolor" then
                    success, retval = pcall(term.isColor())
                    
                    if success ~= true then
                        rednet.send(peer, nil)
                    
                    else
                        rednet.send(peer, retval)
                    end
                    
                elseif split(event[1])[1] == "size" then
                    success, retval = pcall(term.getSize())
                    
                    if success ~= true then
                        rednet.send(peer, nil)
                    
                    else
                        rednet.send(peer, retval)
                    end
                end
            
            -- Update terminal
            else
                success, retval = pcall(loadString(event[1])())
                
                if success ~= true then
                    rednet.send(peer, nil)
                
                else
                    rednet.send(peer, retval)
                end
            
            end
        end
    end
end


-- Run
main()