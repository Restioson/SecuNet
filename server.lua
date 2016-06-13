-- Load APIs
os.loadAPI("disk/secunet/apis/secunet")
os.loadAPI("disk/secunet/apis/uuid")

-- Variables

local userdata = {} -- (Array of usernames as keys with values as table of userdata [HashMap<String, HashMap<String, String>>])
local usernameByPin = {} -- Look up username by pin
local hosts = {} -- Similar to DNS : Lookup usrname by hostname
local reverseHosts = {} -- Reverse hosts


-- Thanks to Lyqyd for this function
local function string.split(separator)
	local results = {}
	for match in string.gmatch(input, "[^ ]+") do
		table.insert(results, match)
	end
	
	return results
end

-- Returns 32 bit random 
local function random256()
    return toString(math.random(10000000, 99999999))..toString(math.random(10000000, 99999999))..toString(math.random(10000000, 99999999))..toString(math.random(10000000, 99999999))
end

-- Generates a user
local function generateUser(username, hostnames) -- Hostnames is an array of hostnames

	local user = {}
	user["pin"] = uuid.Generate()
	user["msgpassword"] = random256()
	user["hmacpassword"] = random256()
	user["username"] = username
	
	for key, value in pairs(hostnames) do
		hosts[value] = username
	end
	
	hosts[username] = username
	reverseHosts[username] = hostnames
	usernameByPin[user["pin"]] = username
	
end

-- Split cleartext data for server
local function splitDataServer(cleartext)
	
	-- Data table
	data = {}
	
	-- Split cleartext
	cleartextSplit = string.split(cleartext)
	
	-- Put into data table
	data["hmac"] = cleartextSplit[0]
	data["destination"] = cleartextSplit[1]
	data["nextmsgpassword"] = cleartextSplit[2]
	data["nexthashpasswd"] = cleartextSplit[3]
	data["message"] = cleartextSplit[4]
	
	return data

end

-- Lookup usrname from hostname
local function lookup(name)
	return hosts[name]
end

-- Reverse lookup
local function reverseLookup(username)
	return reverseHosts[username]
end

-- Extracts data from packet
local function handleData(packet)
 
    -- Split message
    local messagesplit = split(packet)
 
    -- Filter for spam
    if usernameByPin[messagesplit[0]] ~= nil then
       
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

-- Send message
local function send(message, destinationuser, sender)
 
    -- Check for connection
    assert(connected, "Not connected to server!")
   
    -- Create header
    local pin = userdata["pin"]
    local destination = destinationip
    local nextmsgpasswd = random256()
    local nexthashpasswd = random256()
    local nextpin = uuid.Generate()
    local hmac = sha.hmac(message, userdata[destinationuser]["hmacpassword"])
	local iv = generateIV()
   
    -- Create encrypted message body
    local messagebody = " " .. encrypt(userdata[destinationuser]["msgpassword"], hmac .. " " .. sender .. " " .. nextpin .. " " .. msgpasswd .. " " .. hashpasswd .. " " .. userdata[destinationuser]["msgpassword"] ..  message) 
   
    -- Concat pin with messagebody
    local message = pin .. " " .. iv .. " " messagebody
   
    -- Transmit to server
    modem.transmit(channel, channel, message)
   
    -- Save the next passwords and pins
    userdata["messagepassword"] = nextmspasswd
    userdata["hmacpassword"] = nexthashpasswd
    userdata["pin"] = nextpin
   
       
end

-- Listen for packets
while true
	local event = {os.pullEvent()} -- event[0] = event
		if event[0] == "modem_message" then -- event[1] = modemside; event[2] = senderchannel; event[3] = replychannel; event[4] = message; event[5] = senderDistance;
		
		local handleDataErrorHappened, data = pcall(handleData, event[4])
		
		if handleDataErrorHappened ~=  true then
		
		else
			
			local usrname = usernameByPin[data["pin"]]
			
			userdata["hmacpassword"] = messageData["nexthashpasswd"]
			userdata["msgpassword"] = messageData["nextmsgpasswd"]
			userdata["pin"] = messageData["nextpin"]
				
			data["destination"] = data["sender"]
			
			lookupErrorHappened, username = pcall(lookup(data["destination"]))
			
			if (lookupErrorHappened ~= true) then
			
			elseif username ~= nil
				send()
				
			
			-- TO BE CONTINUED...
		
		
		
		