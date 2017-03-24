-- Load APIs
os.loadAPI("disk/secunet/apis/uuid")
os.loadAPI("disk/secunet/apis/base64")
os.loadAPI("disk/secunet/apis/aeslua")

-- Variables
local userdata = {} -- Array of usernames as keys with values as table of userdata [HashMap<String, HashMap<String, String>>]
local username_by_pin = {} -- Look up username by pin
local hosts = {} -- Similar to DNS : Lookup usrname by hostname
local modem = peripheral.wrap("top") -- Modem

-- Thanks to Lyqyd for this function
local function split(input)

    local results = {}
    
    for regexmatch in string.gmatch(input, "[^ ]+") do
        table.insert(results, regexmatch)
    end

    return results
end

-- Thanks to Lyqyd for this function
local function split_tab(input)

    local results = {}
    
    for regexmatch in string.gmatch(input, "[^\t]+") do -- edit to use \t
        table.insert(results, regexmatch)
    end

    return results
end


-- Generates IV table
local function generate_iv()
    
    -- Index counter
    local index = 1
    local iv = {}
    
    -- Loop
    repeat
        
        -- Set IV to random 
        iv[index] = math.random(1, 255)
        
        -- Increment index
        index = index + 1
    
    -- End loop
    until index == 17
    
    -- Return iv
    return iv
 
end

-- Encrypt
local function encrypt(key, message, iv)
    return aeslua.encrypt(key, message, aeslua.AES256, aeslua.CBCMODE, iv)
end

-- Decrypt
local function decrypt(key, message, iv)
    return aeslua.decrypt(key, message, aeslua.AES256, aeslua.CBCMODE, iv)
end

-- Checks hmac against what it should be
local function check_hmac(hmac, message, username)
    
    -- Return
    return hmac == sha.hmac(message, userdata[username]["hmacpassword"])
   
end

-- Saves user data
local function save_userdata(password)
    
    -- Check if file exists
    if fs.exists(shell.dir() .. "/users/server.dat") ~= true then return end
    
    -- Open file
    local user_file = assert(fs.open(shell.dir() .. "/users/server.dat", "w"))
    
    -- Generate iv
    local iv = generate_iv()
    
    -- Format data for writing
    local data = textutils.serialize(iv) .. "\t".. base64.enc(encrypt(password, textutils.serialize(userdata), iv))
    
    -- Write data
    user_file.write(data)
    
    -- Close file handle
    user_file.close()

end

-- Open and decrypt users' login details
local function get_userdata(password)
    
    -- Check if file exists
    if fs.exists(shell.dir() .. "/users/server.dat") ~= true then return end
    
    -- Open user's file
    local user_file = fs.open(shell.dir() .. "/users/server.dat", "r")
    
    -- Read all data
    local user_file_data = user_file.readAll()
    
    -- Data split by \t
    local user_file_data_split = split_tab(user_file_data)
    
    -- Iv serialised data
    local user_file_iv_serialized = table.remove(user_file_data_split, 1)
    
    -- Encrypted user data
    local dataEncrypted = base64.dec(table.concat(user_file_data_split, " "))
    
    -- Unserialise IV
    local iv = textutils.unserialize(user_file_iv_serialized)
    
    -- Decrypt user data
    local cleartext_details = decrypt(password, dataEncrypted, iv)
    
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

-- Returns 256 bit random 
local function random256()
    
    -- Random string
    local random_string = ""
    
    -- Number of rounds of random generation done
    local rounds = 1
    
    -- Repeat until enough rounds
    repeat
        
        -- Add to random string
        random_string = random_string .. tostring(math.random(10000000, 99999999))
        
        -- Increment random rounds
        rounds = rounds + 1
    
    until rounds == 4
    
    return random_string
end

-- Generates a user
local function generate_user(user, hostnames)
    
    -- User table
    local user = {pin = uuid.Generate(), msgpassword = random256(), hmacpassword = random256(), username = user, hosts = hostnames}
    
    -- Populate hostname lookup table
    for key, value in ipairs(hostnames) do hosts[value] = username end
    
    -- Populate user by pin table
    username_by_pin[user["pin"]] = username
    
    -- Return
    return user
    
end

-- Split cleartext data for server
local function split_data(cleartext)
    
    -- Data table
    data = {}
    
    -- Split cleartext
    cleartextSplit = split(cleartext)
    
    -- Populate data table
    data["hmac"] = table.remove(cleartextSplit, 1)
    data["destination"] = table.remove(cleartextSplit, (1))
    data["nextmsgpassword"] = table.remove(cleartextSplit, (1))
    data["nexthashpasswd"] = table.remove(cleartextSplit, (1))
    data["message"] = table.concat(cleartextSplit)
    
    return data

end

-- Lookup username from hostname
local function lookup(name)
    return hosts[name]
end

-- Extracts data from packet
local function handle_data(packet)
 
    -- Split message
    local message_split = split(packet)
 
    -- Filter for spam
    if username_by_pin[message_split[1]] ~= nil then
       
        -- remove pin from message
       table.remove(message_split, 1)
       
        -- Decrypt data
        local decryptedData = decrypt(userdata["messagepassword"], base64.dec(message_split), textutils.unserialize(table.remove(message_split,1)))
       
        -- Split data
        local sucess, data = pcall(split_data, decryptedData)
        
        -- Failed splitting data
        if sucess ~= true then
        
            return nil
       
        -- Split successful
        else
           
            -- Check HMAC
            local sucess, valid = pcall(check_hmac, data["hmac"], data["message"])
           
            -- Error comparing HMACs
            if sucess ~= true then
                error("Error comparing HMACs!")
            end
            
            -- HMAC valid
            if valid then return data
            
            -- HMAC invalid
            else 
                return nil
            end
        end
    end
end

-- Send message
local function send(message, destinationip, sender)
 
    -- Check for connection
    assert(connected, "Not connected to server!")
   
    -- Create header
    local pin = userdata["pin"]
    local destination = destinationip
    local nextmsgpasswd = random128()
    local nexthashpasswd = random128()
    local nextpin = uuid.Generate()
    local hmac = sha.hmac(message, userdata[destinationuser]["hmacpassword"])
    local iv = generate_iv()
   
    -- Create encrypted message body
    local messagebody = " " .. base64.enc(encrypt(userdata[destinationuser]["msgpassword"], hmac .. "" .. sender .. " " .. nextpin .. " " .. msgpasswd .. " " .. hashpasswd .. " " .. userdata[destinationuser]["msgpassword"] ..  message)) 
   
    -- Concat pin with messagebody
    local message = pin .. " " .. iv .. " " .. messagebody
   
    -- Transmit to server
    modem.transmit(channel, channel, message)
   
    -- Save the next passwords and pins
    userdata["messagepassword"] = nextmspasswd
    userdata["hmacpassword"] = nexthashpasswd
    userdata["pin"] = nextpin
   
       
end

-- Listen for packets
local function listen()
    while true do
        os.queueEvent(".")
        os.pullEvent(".")
        modem.open(4000)
        local event = {os.pullEvent()} -- event[1] = event --Wait for event
        if event[1] == "modem_message" then -- event[2] = modemside; event[3] = senderchannel; event[4] = replychannel; event[5] = message; event[6] = senderDistance;
            print(event[5])
            local handle_dataErrorHappened, data = pcall(handle_data, event[5])
            
            if handle_dataErrorHappened ~=  true then
            
            else
                
                local usrname = username_by_pin[data["pin"]]
                
                userdata[usrname]["hmacpassword"] = messageData["nexthashpasswd"]
                userdata[usrname]["msgpassword"] = messageData["nextmsgpasswd"]
                userdata[usrname]["pin"] = messageData["nextpin"]
                
                lookupErrorHappened, username = pcall(lookup(data["destination"]))
                
                if (lookupErrorHappened ~= true) then
                
                elseif (username ~= nil) then
                    send(data["message"], data["destination"], usrname)
                end 
            end
        end
    end
end 

--------------------
-- Shell commands --
--------------------

-- Add user command
local function command_add_user(args)
    
    -- Check if have required number of arguments
    if #args == 0 then 
        
        -- Print usage
        print("Usage:\n    - add_user [username]\n    - add_user [username] [host1] [host2] ...")
        
        -- Return
        return
        
    end
    
    -- Username
    username = table.remove(args, 1)
    
    -- Generate & save user
    userdata[input] = generate_user(username, {username, unpack(args)})

end

-- Removes user
local function command_remove_user(args)

    -- Check if have required number of arguments
    if #args == 0 then
        
        -- Print usage
        print("Usage:\n    - remove_user [username]")
        
        -- Return
        return
    
    end
    
    -- Remove user
    userdata[args[1]] = nil

-- Quit command
local function command_quit(args)
    
    -- Ask for server's password
    io.write("Enter server password: ")
        
    -- Save userdata with password
    save_userdata(read("*"))

end

-- Run shell
local function server_shell()
    
    -- Prompt for server password
    io.write("Enter server password: ")
    local pass = read("*")
    
    -- Shell directory
    local dir = shell.dir()
    
    -- Commands table
    local commands = {quit = command_quit, add_user = command_add_user, remove_user = command_remove_user}
    
    -- Loop
    while true do
    
        -- Print a prompt to the screen
        io.write("> ")
    
        -- Get input
        input = read()
        
        -- Args
        args = split(input)
        args.remove(1)
        
        -- Execute command
        if commands[input] then commands[input](args)
        elseif shell.run(input)
        else print("Unknown command: \"" .. split(input[1]).."\"")
        
        -- Save userdata
        save_userdata(pass)
    
    end
end

-- Main thread
function main()
    
    -- Gets server data
    repeat
        
        -- Get server password
        io.write("Enter server password: ")
        password = read("*")
        
        -- Try to decrypt login data
        pcall_success, success, userdata = pcall(get_userdata, password)
        
        -- Wrong password
        if success ~= true then print("Error! Wrong password") end
    
    -- Exit loop
    until success == true

    -- Wait for shell to quit
    parallel.waitForAny(listen, server_shell)

end

-- Run mainloop
main()
