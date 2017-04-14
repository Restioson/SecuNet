--[[
Router server for Secure Net
]]---

-- Load APIs
os.loadAPI(shell.dir() .. "/apis/uuid.lua")
os.loadAPI(shell.dir() .. "/apis/base64.lua")
os.loadAPI(shell.dir() .. "/apis/aeslua.lua")
os.loadAPI(shell.dir() .. "/apis/sha.lua")

-- Variables
local userdata = {} -- Array of usernames as keys with values as table of userdata [HashMap<String, HashMap<String, String>>]
local username_by_pin = {} -- Look up username by pin
local hosts = {} -- Similar to DNS : Lookup usrname by hostname
local modem = peripheral.wrap("top") -- Modem
local channel = 4000 -- TODO enable config

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
    return hmac == sha.hmac(message, userdata[username]["hmacpassword"]):toHex()
   
end

-- Saves user data
local function save_userdata(password)
    
    -- Open file
    local user_file = assert(fs.open(shell.dir() .. "/users/server.dat", "w"))
    
    -- Generate iv
    local iv = generate_iv()

    -- Debug
    print(textutils.serialize(iv))
    print(encrypt(password, textutils.serialize(userdata)), iv)
    print(base64.enc(encrypt(password, textutils.serialize(userdata), iv)))
    print(textutils.serialize(encrypt))

    -- Format data for writing
    local data = textutils.serialize(iv) .. "\t".. base64.enc(encrypt(password, textutils.serialize(userdata), iv))
    
    -- Write data
    user_file.write(data)
    
    -- Close file handle
    user_file.close()

end

-- Save single user to file
local function save_user_file(username)
    
    -- Open file
    local user_file = assert(fs.open("disk/users/" .. username .. ".dat", "w"))
    
    -- Generate iv
    local iv = generate_iv()
    
    -- Format data for writing
    local data = textutils.serialize(iv) .. "\t" .. base64.enc(encrypt("password", textutils.serialize(userdata[username])), iv)
    
    -- Write data
    user_file.write(data)
    
    -- Close file handle
    user_file.close()

end

-- Get size of table including string indexes
local function table_size(t)

    -- Size
    local size = 0

    -- Iterate through table
    for key, value in pairs(t) do 
        size = size + 1 
    end
    
    -- Return
    return size
    
end
    
-- Open and decrypt users' login details
local function get_userdata(password)
    
    -- Check if file exists
    if fs.exists(shell.dir() .. "/users/server.dat") ~= true then return end
    
    -- Open user's file
    local user_file = fs.open(shell.dir() .. "/users/server.dat", "r")
    
    -- Read all data
    local user_file_data = user_file.readAll()
    
    -- Close file handle
    user_file.close()
    
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
    
    -- Attempt to deserialize data
    if textutils.unserialize(cleartext_details) == nil then 
        return false, nil
    end
    
    -- User data temp table
    local userdata_temp = textutils.unserialize(cleartext_details)
    
    -- Successfully unserialized data
    print("Successfully loaded " .. table_size(userdata_temp) .. " users")
    
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
    local data = {}
    
    -- Split cleartext
    local cleartextSplit = split(cleartext)
    
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
        local success, data = pcall(split_data, decryptedData)
        
        -- Failed splitting data
        if success ~= true then
        
            return nil
       
        -- Split successful
        else
           
            -- Check HMAC
            local success, valid = pcall(check_hmac, data["hmac"], data["message"])
           
            -- Error comparing HMACs
            if success ~= true then
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
local function send(message, destination, sender)
   
    -- Create header
    local pin = userdata[destination]["pin"]
    local nextmsgpasswd = random256()
    local nexthashpasswd = random256()
    local nextpin = uuid.Generate()
    local hmac = sha.hmac(message, userdata[destination]["hmacpassword"]):toHex()
    local iv = generate_iv()
   
    -- Create encrypted message body
    local messagebody = " " .. base64.enc(encrypt(userdata[destination]["msgpassword"], hmac .. "" .. sender .. " " .. nextpin .. " " .. nextmsgpasswd .. " " .. nexthashpasswd .. " " ..  message, iv))
   
    -- Concat pin with messagebody
    local message = pin .. " " .. iv .. " " .. messagebody
   
    -- Transmit to client
    modem.transmit(channel, channel, message)
   
    -- Save the next passwords and pins
    userdata["messagepassword"] = nextmsgpasswd
    userdata["hmacpassword"] = nexthashpasswd
    userdata["pin"] = nextpin
   
       
end

-- Listen for packets
local function listen()

    -- Loop
    while true do

        -- Open modem
        modem.open(channel)

        -- Wait for event
        local event = {os.pullEvent("modem_message")} -- event[1] = event --Wait for event

        -- event[1] = event name; event[2] = modemside; event[3] = senderchannel; event[4] = replychannel; event[5] = message; event[6] = senderDistance;

        -- Handle data
        local handle_data_success, data = pcall(handle_data, event[5])

        -- Error handling data
        if handle_data_success == false then

        -- No error handling data
        else

            -- Username
            local username = username_by_pin[data["pin"]]

            -- Set new passwords and pins
            userdata[username]["hmacpassword"] = data["nexthashpasswd"]
            userdata[username]["msgpassword"] = data["nextmsgpasswd"]
            userdata[username]["pin"] = data["nextpin"]

            -- Destination lookup
            local lookup_success, destination = pcall(lookup(data["destination"]))

            -- Lookup error
            if lookup_success == false then

             -- Send packet to destination
            elseif destination ~= nil then
                send(data["message"], destination, username)
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
    local username = table.remove(args, 1)

    -- Hosts
    local hosts = {username, unpack(args)}
    
    -- Generate & save user
    userdata[username] = generate_user(username, hosts)
    
    -- Answer of save as seperate file
    local answer = ""
    
    -- Get whether to save as seperate file
    repeat
        
        io.write("Save as seperate file (Y/N)? ")
        answer = string.lower(read())

        if answer ~= "y" and answer ~= "n" then print("Please answer Y or N") end
    
    until answer == "y" or answer == "n"

    -- Save as seperate file if yes
    if answer == "y" then 
        
        -- Repeat until drive inserted
        repeat
            io.write("Please insert drive! Press enter to continue")
            read()
        until fs.exists("disk")
        
        save_user_file(username)
        
        print("Saved as " .. "disk/users/" .. username .. ".dat with password \"password\"")
    
    end
    
    -- Print user
        
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
    
end
    
-- Quit command
local function command_quit(args)
    
    -- Ask for server's password
    io.write("Enter server password: ")
        
    -- Save userdata with password
    save_userdata(read("*"))
    
    -- Send terminate event
    os.queueEvent("terminate")

end

-- Help command
local function command_server_help(args)
    
    -- Print help
    print("Server help page:")
    print("- add_user: adds user. Aliases: user_add")
    print("- remove_user: removes user. Aliases: user_remove")
    print("- quit: quits server shell. Aliases: none")
    print(" - server_help: prints this help page. Aliases: help_server")
    print("All user scripts and CraftOS commands will work as normal")
    print("WARNING: Cntrl + T will terminate both running programs and the shell")

end

-- Run shell
local function server_shell(pass)

    -- Commands table
    local commands = {quit = command_quit}
    commands["add_user"] = command_add_user
    commands["user_add"] = command_add_user
    commands["remove_user"] = command_remove_user
    commands["user_remove"] = command_remove_user
    commands["server_help"] = command_server_help
    commands["help_server"] = command_server_help
    
    -- Set terminal colour to yellow
    term.setTextColor(colors.yellow)
    
    -- Print version info
    print("SecuNet server shell v 1.0.0 running under " .. os.version())
    
    -- Set terminal colour back to white
    term.setTextColor(colors.white)
    
    -- Loop
    while true do
        
        -- Set terminal colour to green
        term.setTextColor(colors.green)
        
        -- Print a prompt to the screen
        io.write("user@" .. os.getComputerLabel() .. ":" .. shell.dir() .. "$ ")
        
        -- Set terminal colour back to white
        term.setTextColor(colors.white)
    
        -- Get input
        local input = read()
        
        -- Args
        local args = split(input)
        
        -- Command
        local command = table.remove(args, 1)
        
        -- Execute command
        if commands[command] then commands[command](args)
        else shell.run(input) end
        
        -- Save userdata
        save_userdata(pass)
    
    end
end

-- Main thread
function main()
    
    -- Variables to hold values to be returned by pcall of get_userdata
    local pcall_success = false
    local success = false
    local userdata_temp = ""
    
    -- Server password
    local password = ""
    
    -- Gets server data
    repeat
        
        -- Get server password
        io.write("Enter server password: ")
        password = read("*")
        
        -- Try to decrypt login data
        pcall_success, success, userdata_temp = pcall(get_userdata, password)

        -- Error
        if not pcall_success then print("Error while getting userdata:") end
        print(success) -- This will now be the error message (somewhat ironically)

        -- File doesn't exist: break out of loop
        if success == nil then success = true end

        -- Wrong password
        if not success then print("Error! Wrong password") end



    -- Exit loop
    until success == true
    
    -- Set userdata
    if userdata_temp ~= nil then userdata = userdata_temp end
    
    -- Wait for shell to quit
    parallel.waitForAny(listen, function() server_shell(password) end)

end

-- Run mainloop
main()
