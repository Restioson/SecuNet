-- Args
local args = {...}

-- Client id
local client

-- New terminal
local newTerm = {}

-- Old terminal
local oldTerm = new

-- Functions for new terminal
newTerm.write = function (text)
    oldTerm.write(text)
    rednet.send(client, string.format("term.write(%s)", text))
end

newTerm.blit = function (text, textcolors, backgroundcolors)
    oldTerm.write(text)
    rednet.send(client, string.format("term.blit(%s, %s, %s)", text, textcolors, backgroundcolors))
end

newTerm.clear = function ()
    oldTerm.clear()
    rednet.send(client, "term.clear()")
end

newTerm.clearLine = function ()
    oldTerm.clearLine()
    rednet.send(client, "term.clearLine()")
end


newTerm.getCursorPos = function ()
   rednet.send(client, "get cursor")
   return rednet.receive()
end

newTerm.setCursorPos = function (x, y)
    oldTerm.setCursorPos(x, y)
    rednet.send(client, string.format("term.setCursorPos(%s, %s)", x, y))
end

newTerm.setCursorBlink = function (bool)
    oldTerm.setCursorBlink(bool)
    rednet.send(client, string.format("term.setCursorBlink(%s)", bool))
end

newTerm.isColor = function ()
    rednet.send(client, "get iscolor")
    return rednet.receive()
end

newTerm.isColour = function ()
    rednet.send(client, "get iscolor")
    return rednet.receive()
end

newTerm.getSize = function ()
    rednet.send(client, "get size")
    local data = rednet.receive()
    return data[0], data[1]
end

newTerm.scroll = function (n)
    oldTerm.scroll(n)
    rednet.send(client, string.format("term.scroll(%s)", n))
end

newTerm.redirect = function (target)
    oldTerm.redirect(target)
    rednet.send(client, string.format("term.redirect(%s)", target))
end

newTerm.current = function ()
    return newTerm
end

newTerm.native = function ()
    return oldTerm.native()
end

newTerm.setTextColor = function (color)
    oldTerm.setTextColor(color)
    rednet.send(client, string.format("term.setTextColor(%s)", color))
end

newTerm.getTextColor = function()
    return oldTerm.getTextColor()
end

newTerm.setBackgroundColor = function (color)
    oldTerm.setBackgroundColor(color)
    rednet.send(client, string.format("term.setBackgroundColor(%s)", color))
end

newTerm.getBackgroundColor = function (color)
    return oldTerm.getBackgroundColor()
end


-- Main function
local function main()
    
    -- Side
    local side = args[0] or "top"
    
    -- Get client
    if args[1] == nil then
        write("Client ID> ")
        client = read()
    
    else
        client = args[1]
    end
    
    
    -- Open rednet
    rednet.open(side)
    
    parallel.waitForAny(waitMessage) -- TO BE CONT
    
end

-- Wait for message
local function waitMessage()

    -- Loop
    while true do
        local sender, message, protocol = rednet.receive() -- Receive message
        handlePacket(message) -- Handle it
    end
end

-- Handle data
local function handlePacket(packet) -- Basically a placeholder to make implementing a new protocol easier
    if type(packet) == "table" then -- If it is a table, attempt to queue it as an event
        local success, retval = pcall(os.queueEvent(unpack(packet)))
        
        if success ~= true then -- Print the error if it failed
            print(success)
        end
    end
end

-- Run
main()

    