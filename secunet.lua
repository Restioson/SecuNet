-- Api for secure-rednet
 
--[[
 
 PACKET BREAKDOWN
 ----------------
 
 Items enclosed in [] means that they are encrypted.
 
 Pin UUID [SHA256HMAC (Sender/Destination)*  NextUUID NextPin NextMessagePassword NextHMACPassword Message]
 
 * If implementation = server, then it will be who sent the packet. If implementation = client, then it will be destination for packet
 
 
 
]]--
 
 
-- Load APIs
os.loadAPI("aeslua")
os.loadAPI("sha")
os.loadAPI("base64")
os.loadAPI("uuid")
shell.run("thread")
 
 
-- Enable handling of cntrl + t
oldPullEvent = os.pullEvent
 
local function pullEventRaw()
   
    local event = {os.pullEventRaw()}
   
    if event[0] == "terminate" then
        io.write("User details password > ")
        saveUserdata(io.read())
        term.clear()
        term.setCursorPos(1,1)
        io.write("Terminated")
   
end
   
-- Set pullEvent to new pull event
os.pullEvent = pullEventRaw
 
-- Init modem
local modem = peripheral.wrap("top")
 
-- Variables
local connected = false
local server = nil
local userdata
local msgs = {}
 
-- Thanks to Lyqyd for this function
local function split(input)
    local results = {}
    for match in string.gmatch(input, "[^ ]+") do
        table.insert(results, match)
    end
   
    return results
end
 
-- Open and decrypt user's login details
local function getUserdata(password)
    local userfile = assert(fs.open("disk/secunet/user.dat", "r"))
    local userfileData = userfile.readAll()
    local iv = base64.dec(split(userfileData)[0])
    local cleartextDetails = decrypt(password, base64.dec(split(userfileData)[0]), iv)
   
    userfile.close()
   
    return textutils.deserialize(cleartextDetails)
   
end
 
-- Encrypt and save user's login details
local functions saveUserdata(password)
    local userfile = assert(fs.open("disk/secunet/user.dat", "w"))
    local iv = generateIV()
    local data = base64.enc(iv .. " " .. encrypt(password, textutils.serialize(userdata), iv))
   
    userfile.write(data)
    userfile.close()
   
end
   
 
-- Checks hmac against what it should be
local function checkHMAC(hmac, message)
   
    if hmac == sha.hmac(message, userdata["hmacpassword"]) then
        return true
    end
   
    return false
   
end
 
-- Generates IV table
local function generateIV()
   
    local index = 1
    local iv = {}
   
    repeat
   
    iv[index] = math.random(1, 255)
    index = index + 1
   
    until index == 17
   
    return iv
 
end
 
-- Encrypt
local function encrypt(key, message, iv)
    aeslua.encrypt(key, message, aeslua.AES256, aeslua.CBCMODE, iv)
end
 
-- Decrypt
local function decrypt(key, message, iv)
    aeslua.decrypt(key, message, aealua.AES256, aeslua.CBCMODE, iv)
end
 
-- Split cleartext data
local function splitData(cleartext)
   
    -- Data table
    local data = {}
   
    -- Split cleartext
    local cleartextSplit = split(cleartext)
   
    -- Put into data table
    data["hmac"] = cleartextSplit[0]
    data["sender"] = cleartextSplit[1]
	data["nextuuid"] = cleartextSplit[2]
    data["nextpin"] = cleartextSplit[3]
    data["nextmsgpassword"] = cleartextSplit[4]
    data["nexthashpasswd"] = cleartextSplit[5]
    data["message"] = cleartextSplit[6]
   
    return data
 
end
 
-- Extracts data from packet
local function handleData(packet)
 
    -- Split message
    local messagesplit = split(packet)
 
    -- Filter for spam
    if messagesplit[0] == userdata["pin"] then
       
        -- Pop pin from message
        messagesplit.pop(0)
       
        -- Decrypt data
        local decryptedData = decrypt(userdata["messagepassword"], messagesplit, messagesplit.pop(0))
       
        -- Split data
        local splitErrorHappened, data = pcall(splitData, decryptedData)
       
        if errorHappened ~= true then
            error("Invalid packet")
       
        -- Split successful
        else
           
            -- Check hmac
            local hmacErrorHappened, valid = pcall(data["hmac"], data["message"])
           
            if hmacErrorHappened ~= true then
                error("Error comparing HMACs!")
            end
           
            if valid then
                return data
    
            else 
                error("HMAC invalid!")
			end
			
		end
    end
end
 
-- Register message
local function registerMessage(messageData)
    table.insert(msgs, messageData["message"])
   
    userdata["hmacpassword"] = messageData["nexthashpasswd"]
    userdata["msgpassword"] = messageData["nextmsgpasswd"]
    userdata["pin"] = messageData["nextpin"]
   
end
 
-- "Receive" message (Fetch from msgs table)
function receive(timeout)
   
    -- Timer
    local timeout = timeout or nil
    local timer
   
    -- Begin timer
    if timeout ~= nil then
        timer = os.startTimer(timeout)
    end
   
    -- Loop to check for message
    while true do
       
        -- Check if data in table
        if table.getn(msgs) > 0 then
            return {table.pop(0)["sender"], table.pop(0)["message"]}
        end
       
        if timeout ~= nil then
            local event, timerid = os.pullEvent("timer")
            if timerid == timer then
                error("Receive timed out")
            end
        end
    end
end
 
-- Receive message
local function listenForMessage()
   
    while true do
        -- Wait for event
        local event = {os.pullEvent()} -- event[0] = event
        if event[0] == "modem_message" then -- event[1] = modemside; event[2] = senderchannel; event[3] = replychannel; event[4] = message; event[5] = senderDistance;
           
            local handleDataErrorHappened, data = pcall(handleData, event[4])
           
            if handleDataErrorHappened ~= true then
           
            else
                registerMessage(data)
            end
           
        end
    end
   
end
 
-- Send message
function send(message, destinationip)
 
    -- Check for connection
    assert(connected, "Not connected to server!")
   
    -- Create header
    local pin = userdata["pin"]
    local destination = destinationip
    local nextmsgpasswd = random256()
    local nexthashpasswd = random256()
    local nextpin = uuid.Generate()
    local hmac = sha.hmac(message, userdata["hmacpassword"])
	local iv = generateIV()
   
    -- Add new passwords to pending list
   
    -- Create encrypted message body
    local messagebody = " " .. encrypt(userdata["msgpassword"], hmac .. " " .. destination .. " " .. nextpin .. " " .. msgpasswd .. " " .. hashpasswd .. " " .. userdata["msgpassword"] ..  message) 
   
    -- Concat pin with messagebody
    local message = pin .. " " .. iv .. " " messagebody
   
    -- Transmit to server
    modem.transmit(channel, channel, message)
   
    -- Save the next passwords and pins
    userdata["messagepassword"] = nextmspasswd
    userdata["hmacpassword"] = nexthashpasswd
    userdata["pin"] = nextpin
   
       
end
 
-- Open modem, etc
function set_server(channel, userdataPassword)
 
    -- Check for connection
    assert(connected==false, "Already connected to server!")
   
    -- Get login details
    if userdata ~= nil then userdata = getUserdata(userdataPassword) end
   
    -- Connect
    connected = true
    modem.open(channel)
    server = channel
    os.startThread(listenForMessage)
end
 
-- Returns 32 bit random string
local function random256()
    return toString(math.random(10000000, 99999999))..toString(math.random(10000000, 99999999))..toString(math.random(10000000, 99999999))..toString(math.random(10000000, 99999999))
end
