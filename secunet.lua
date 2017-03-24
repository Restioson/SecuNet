-- Api for secure-rednet
 
--[[
 
 PACKET BREAKDOWN
 ----------------
 
 Items enclosed in [] means that they are encrypted.
 
 Pin IV [SHA256HMAC (Sender/Destination)*  NextUUID NextMessagePassword NextHMACPassword Message]
 
 * If implementation = server, then it will be who sent the packet. If implementation = client, then it will be destination for packet
 
 
 
]]--
 
 
-- Load APIs
os.loadAPI("/disk/secunet/apis/aeslua")
os.loadAPI("/disk/secunet/apis/sha")
os.loadAPI("/disk/secunet/apis/base64")
os.loadAPI("/disk/secunet/apis/uuid")
 
 
-- Init modem
local modem = peripheral.wrap("top")
 
-- Variables
local connected = false
local server
local userdata
local msgs = {}
local usrname
local passwd

 
-- Enable handling of cntrl + t
local oldPullEvent = os.pullEvent

-- Program terminated
local terminated = false
 
-- Encrypt and save user's login details
function save_userdata(password, username)

    local user_file = assert(fs.open(shell.dir() + "/../users/" .. username .. ".dat", "w"))
    local iv = generate_iv()
    local data = iv .. " " .. base64.enc(encrypt(password, textutils.serialize(userdata), iv))
    print()
    user_file.write(data)
    user_file.close()
   
end

-- New pullevent
local function pullEvent()
   
    local event = table.pack(os.pullEventRaw())
   
    if event[1] == "terminate" and terminated ~= true then
        io.write("User details password > ")
        save_userdata(io.read())
        terminated = true
        os.queueEvent("terminate")
    end
    
    return unpack(event, 1, event.n)
   
end

-- Returns 256 bit random string
local function random256()
    return tostring(math.random(10000000, 99999999))..tostring(math.random(10000000, 99999999))..tostring(math.random(10000000, 99999999))..tostring(math.random(10000000, 99999999))
end


-- Open and decrypt users' login details
local function get_userdata(password)
    
    -- Check if file exists
    if fs.exists(shell.dir() .. "/users/server.dat") ~= true then return end
    
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
        usrname = io.read()

        io.write("Please enter your SecuNet password > ")
        passwd = read("*")
    
    until get_userdata(passwd, usrname) ~= nil
    
    userdata = get_userdata(passwd, usrname)
end     
 
-- Thanks to Lyqyd for this function
local function split(input)
    local results = {}
    for match in string.gmatch(input, "[^ ]+") do
        table.insert(results, match)
    end
   
    return results
end
   
 
-- Checks hmac against what it should be
local function check_hmac(hmac, message)
    
    -- Return
    return hmac == sha.hmac(message, userdata["hmacpassword"])
   
end
 
-- Generates IV table
local function generate_iv()
   
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
    return aeslua.encrypt(key, message, aeslua.AES256, aeslua.CBCMODE, iv)
end
 
-- Decrypt
local function decrypt(key, message, iv)
    return aeslua.decrypt(key, message, aealua.AES256, aeslua.CBCMODE, iv)
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
   
    return data
 
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
       
        if errorHappened ~= true then
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
        message_event = {os.pullEvent("secunet_message")}
        
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
    local nextmsgpasswd = random128()
    local nexthashpasswd = random128()
    local nextpin = uuid.Generate()
    local hmac = sha.hmac(message, userdata["hmacpassword"])
    local iv = generate_iv()

    -- Create encrypted message body
    local messagebody = " " .. base64.enc(encrypt(userdata["msgpassword"], hmac .. " " .. destination .. " " .. nextpin .. " " .. msgpasswd .. " " .. hashpasswd .. " " .. userdata["msgpassword"] ..  message)) 
   
    -- Concat pin with messagebody
    local message = pin .. " " .. textutils.serialize(iv) .. " " .. messagebody
   
    -- Transmit to server
    modem.transmit(channel, channel, message)
   
    -- Save the next passwords and pins
    userdata["messagepassword"] = nextmspasswd
    userdata["hmacpassword"] = nexthashpasswd
    userdata["pin"] = nextpin
   
end
 
-- Mainloop
function mainloop(script_function)
   
    -- Set pullEvent to new pull event
    os.pullEvent = pullEvent
    
    -- Prompt user for login
    login()
        
    -- Connect
    connected = true
    modem.open(4000)
    
    -- Wait for the user's function to exit
    parallel.waitForAny(listenForMessage, script_function)
    
end
