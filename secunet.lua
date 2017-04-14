-- Api for secure-rednet
 
--[[
 
 PACKET BREAKDOWN
 ----------------
 
 Items enclosed in [] means that they are encrypted.
 
 Pin IV [SHA256HMAC (Sender/Destination)*  NextUUID NextMessagePassword NextHMACPassword Message]
 
 * If implementation = server, then it will be who sent the packet. If implementation = client, then it will be destination for packet
 
 
 
]]--
 
 
-- Load APIs
os.loadAPI(shell.dir() .. "/secunet/apis/aeslua.lua")
os.loadAPI(shell.dir() .. "/secunet/apis/sha.lua")
os.loadAPI(shell.dir() .. "/secunet/apis/base64.lua")
os.loadAPI(shell.dir() .. "/secunet/apis/uuid.lua")
 
-- Variables
local connected = false
local server
local userdata
local username
local password
local channel
local modem

-- Generates IV table
local function generate_iv()
   
    local index = 1
    local iv = {}
   
    repeat
   
    iv[index] = math.random(1, 255)
    index = index + 1
   
    until index == 17
   
    return table.concat(iv)
 
end

-- Encrypt
local function encrypt(key, message, iv)
    return aeslua.encrypt(key, message, aeslua.AES256, aeslua.CBCMODE, iv)
end
 
-- Decrypt
local function decrypt(key, message, iv)
    return aeslua.decrypt(key, message, aealua.AES256, aeslua.CBCMODE, iv)
end

-- Returns 256 bit random string
local function random256()
    return tostring(math.random(10000000, 99999999))..tostring(math.random(10000000, 99999999))..tostring(math.random(10000000, 99999999))..tostring(math.random(10000000, 99999999))
end

-- Thanks to Lyqyd for this function
local function split(input)
    local results = {}
    for match in string.gmatch(input, "[^ ]+") do
        table.insert(results, match)
    end
   
    return results
end

-- Encrypt and save user's login details
function save_userdata(password, username)

    local user_file = assert(fs.open(shell.dir() + "/../users/" .. username .. ".dat", "w"))
    local iv = generate_iv()
    local data = iv .. " " .. base64.enc(encrypt(password, textutils.serialize(userdata), iv))
    print()
    user_file.write(data)
    user_file.close()
   
end

-- Old os.pullEvent
local oldPullEvent = os.pullEvent

-- New pullevent
local function pullEvent()

    -- Wait for event
    local event = table.pack(os.pullEventRaw())

    -- Handle terminate event
    if event[1] == "terminate" then

        -- Save userdata
        io.write("User details password > ")
        save_userdata(io.read())

        -- Reset os.pullEvent
        os.pullEvent = oldPullEvent

        -- Queue terminate event
        os.queueEvent(unpack(event))

    end

    -- Return event
    return unpack(event, 1, event.n)

end


-- Split cleartext data
local function splitData(cleartext)
   
    -- Data table
    local data = {}
   
    -- Split cleartext
    local cleartextSplit = split(cleartext)
   
    -- Put into data table
    data["hmac"] = table.remove(cleartextSplit, 1)
    data["sender"] = table.remove(cleartextSplit, 1)
    data["nextpin"] = table.remove(cleartextSplit, 1)
    data["nextmsgpassword"] = table.remove(cleartextSplit, 1)
    data["nexthashpasswd"] = table.remove(cleartextSplit, 1)
    data["message"] = table.concat(cleartextSplit)

    -- Return
    return data
 
end

-- Open and decrypt users' login details
local function get_userdata(username, password)
    
    -- Check if file exists
    if fs.exists(shell.dir() .. "/users/" .. username .. ".dat") ~= true then return end
    
    -- Open user's file
    local user_file = fs.open(shell.dir() .. "/users/" .. username .. ".dat", "r")
    
    -- Read all data
    local user_file_data = user_file.readAll()
    
    -- Data split by \t
    local user_file_data_split = split_tab(user_file_data)
    
    -- Iv serialised data
    local user_file_iv_serialized = table.remove(user_file_data_split, 1)
    
    -- Encrypted user data
    local data_encrypted = base64.dec(table.concat(user_file_data_split, " "))
    
    -- Unserialise IV
    local iv = textutils.unserialize(user_file_iv_serialized)
    
    -- Decrypt user data
    local cleartext_details = decrypt(password, data_encrypted, iv)
    
    -- File decrypted with wrong password
    if cleartext_details == nil then return false, nil end
    
    -- Close file handle
    user_file.close()
    
    -- Attempt to deserialize data
    if textutils.unserialize(cleartext_details) == nil then return false, nil end
    
    -- Successfully unserialized data
    print("Successfully loaded " .. table.getn(userdata) .. " users")
    
    -- Return
    return true, textutils.unserialize(cleartext_details)

end

-- Login
function login() 
    
    -- Login
    repeat
    
        io.write("Please enter your SecuNet username > ")
        local usrname = io.read()

        io.write("Please enter your SecuNet password > ")
        local passwd = read("*")
    
    until get_userdata(passwd, usrname) ~= nil
    
    -- Return
    return username, password

end      
 
-- Checks hmac against what it should be
local function check_hmac(hmac, message)
    
    -- Return
    return hmac == sha.hmac(message, userdata["hmacpassword"]):toHex()
   
end
 
-- Extracts data from packet
local function handle_data(packet)
 
    -- Split message
    local messagesplit = split(packet)
 
    -- Filter for spam
    if messagesplit[1] == userdata["pin"] then
       
        -- remove pin from message
        table.remove(messagesplit, 1)
       
        -- Decrypt data
        local decryptedData = decrypt(userdata["messagepassword"], base64.dec(messagesplit), textutils.serialize(table.remove(messagesplit1)))
       
        -- Split data
        local splitErrorHappened, data = pcall(splitData, decryptedData)
       
        if splitErrorHappened ~= true then
            error("Invalid packet")
       
        -- Split successful
        else
           
            -- Check hmac
            local hmacErrorHappened, valid = pcall(check_hmac, data["hmac"], data["message"])
           
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
    
    -- Send message event
    os.queueEvent("secunet_message", messageData["sender"], messageData["message"])
   
    -- Update userdata
    userdata["hmacpassword"] = messageData["nexthashpasswd"]
    userdata["msgpassword"] = messageData["nextmsgpasswd"]
    userdata["pin"] = messageData["nextpin"]
   
end
 
-- "Receive" message (Fetch from msgs table)
function receive()
   
   assert(connected, "Not connected to server!")
   
    -- Loop to check for message
    while true do
       
        -- Wait for data
        local message_event = {os.pullEvent("secunet_message")}
        
        -- Return message and sender
        return message_event[2], message_event[3]
        
    end
end
 
-- Receive message
local function listenForMessage()

    while true do
    
        -- Wait for event
        local event = {os.pullEvent()} -- event[1] = event
        
        if event[1] == "modem_message" then -- event[2] = modemside; event[3] = senderchannel; event[4] = replychannel; event[5] = message; event[6] = senderDistance;
           
            local handle_dataErrorHappened, data = pcall(handle_data, event[5])
           
            if handle_dataErrorHappened ~= true then
                
                print("Error handling data")                
           
            else
                registerMessage(data)
            end
           
        end
    end
   
end
 
-- Send message
function send(message, destinationip)
 
    -- Check for connection
    assert(connected, "Error: not connected to server")
   
    -- Create header
    local pin = userdata["pin"]
    local destination = destinationip
    local nextmsgpasswd = random256()
    local nexthashpasswd = random256()
    local nextpin = uuid.Generate()
    local hmac = sha.hmac(message, userdata["hmacpassword"]):toHex()
    local iv = generate_iv()

    -- Create encrypted message body
    local messagebody = " " .. base64.enc(encrypt(userdata["msgpassword"], hmac .. " " .. destination .. " " .. nextpin .. " " .. msgpasswd .. " " .. hashpasswd .. " " .. userdata["msgpassword"] ..  message)) 
   
    -- Concat pin with messagebody
    local message = pin .. " " .. textutils.serialize(iv) .. " " .. messagebody
   
    -- Transmit to server
    modem.transmit(channel, channel, message)
   
    -- Save the next passwords and pins
    userdata["messagepassword"] = nextmsgpasswd
    userdata["hmacpassword"] = nexthashpasswd
    userdata["pin"] = nextpin
   
end
 
-- Mainloop
function mainloop(script_function, username, password, port, modem_side)

    -- Set channel
    channel = port

    -- Get modem
    if modem_side == nil then modem_side = "top" end
    local modem = peripheral.wrap(modem_side)

    -- Set pullEvent to new pull event
    os.pullEvent = pullEvent
    
    -- Get userdata
    local success, userdata_temp = get_userdata(password, username)
    if not success then erorr("Invalid username or password!") end
    userdata = userdata_temp

    -- Connect
    connected = true
    modem.open(channel)
    
    -- Wait for the user's function to exit
    parallel.waitForAny(listenForMessage, script_function)
    
end
