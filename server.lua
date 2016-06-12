-- Load APIs
os.loadAPI("disk/secunet/apis/secunet")

-- Thanks to Lyqyd for this function
local function string.split(separator)
	local results = {}
	for match in string.gmatch(input, "[^,]+") do
		table.insert(results, match)
	end
	
	return results
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