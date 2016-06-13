-- Load APIs
os.loadAPI("disk/secunet/apis/secunet")
os.loadAPI("disk/secunet/apis/uuid")

-- Variables

local userdata = {} -- (Array of usernames as keys with values as table of userdata [HashMap<String, HashMap<String, String>>])
local usernameByPin = {} -- Look up username by pin
local hosts = {} -- Similar to DNS : Lookup usrname by hostname
local reverseHosts = {} -- Reverse of hosts table


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
local function generateUser(hostnames) -- Hostnames is an array of hostnames
	user = {}
	user["pin"] = uuid.Generate()
	user["messagepassword"] = random256()

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

-- 

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

-- Listen for packets
local event = {os.pullEvent()} -- event[0] = event
    if event[0] == "modem_message" then -- event[1] = modemside; event[2] = senderchannel; event[3] = replychannel; event[4] = message; event[5] = senderDistance;
	
	local handleDataErrorHappened, data = pcall(handleData, event[4])
	
	if handleDataErrorHappened ~=  true then
		
	else
		