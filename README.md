# SecuNet
Secure Network API for Computercraft based on the system of AES and the triple pass/key wrap protocol.

# Code example
```lua
-- Load SecuNet api
os.loadAPI("secunet/apis/secunet")

-- This function will run while a background listener process listens for messages
function my_script()
    
    -- Default network port
    local port = 4000
    
     -- Prompt user for login
    local username, password = secunet.login()
    
    -- Connect to SecuNet router server
    secunet.connect(username, password, 4000) -- username: Users secunet username. Not necessarily MC username
                                              -- password: User's secunet password; 
                                              -- port = port for network packets to be sent to server on. Should be same as server's port
    
    -- Send a packet to destination_user
    secunet.send("Hello there!", "destination_user")
    
    -- Print out any received packet
    local sender, message = secunet.receive()
    
    print("Got packet from " .. sender .. ": \"" .. message .."\"") -- E.g: Got packet from SecunetUser: "Hello!"
    
    -- Disconnect from the server
    secunet.disconnect()
    
end

-- Run the listener process while running your script
secunet.mainloop(my_script)
```

# Installation

## Client
To install SecuNet for the client, run `pastebin run 6AuiT33N`. This will start an installer for the API. Note: it is quite slow as it prints out all of the attributions as well. 

## Server
To install SecuNet for the server, you will need to do the following:

1. Run `pastebin run 6AuiT33N`
2. At the prompt, type whatever directory you want to install the server into
3. Run `wget https://git.io/vSkXq directory/for/server/server`

# Credits
AES Api by SquidDev: https://github.com/SquidDev-CC/aeslua
UUID Api by TurboTuTone: http://www.computercraft.info/forums2/index.php?/topic/13924-uuid-api-universally-unique-identifier/
Base 64 Api: http://lua-users.org/wiki/BaseSixtyFour
SHA Api by Anavrins: http://www.computercraft.info/forums2/index.php?/topic/8169-sha-256-in-pure-lua/page__st__40

# Usage
If you intend to use this in your code, please link in the forum post to this page. If you do not intend to publish it, then you do not need to link to this. 
