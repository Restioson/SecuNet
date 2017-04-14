# SecuNet
Secure Network API for Computercraft which uses AES to encrypt messages.

# Documentation


## Code example
```lua
-- Load SecuNet api
os.loadAPI("path/to/secunet/installation/secunet/apis/secunet.lua")

-- This function will run while a background listener process listens for messages
local function my_script()
    
    -- Send a packet to destination_user
    secunet.send("Hello there!", "destination_user") -- Replace this with their secunet user id
    
    -- Print out any received packet
    local sender, message = secunet.receive()

    print("Got packet from " .. sender .. ": \"" .. message .."\"") -- E.g: Got packet from SecunetUser: "Hello!"
    
    -- Disconnect from the server
    secunet.disconnect()
    
end

-- Port
local port = 4000 -- Default SecuNet port

-- Modem side
local modem_side = "top" -- SecuNet's default modem side is top

 -- Prompt user for login
local username, password = secunet.login()

-- Run the listener process while running your script
secunet.mainloop(my_script, username, password, port, modem_side) -- username: Users secunet username. Not necessarily MC username
                                                      -- password: User's secunet password
                                                      -- modem_side: side modem is on
                                                      -- port: port for network packets to be sent to server on.
                                                      -- Should be same as server's port. Default is 4000
```

# Installation

###Client
To install SecuNet for the client, run `wget https://git.io/vSQOy installer.lua` and then `installer.lua`. This will start an installer for the API. Note: it is quite slow as it prints out all of the attributions as well.

## Server
To install SecuNet for the server, you will need to do the following:

1. Run `wget https://git.io/vSQOy installer.lua`
2. Run `installer.lua`
3. At the prompt, type whatever directory you want to install the server into
4. Run `wget https://git.io/vSkXq directory/for/server/server.lua`
5. To run the server, just run `directory/for/server/server.lua

Note: make sure that your modem is on the top of the server computer. I recommend using an ender modem for maximum range

# Credits
- AES Api by SquidDev: https://github.com/SquidDev-CC/aeslua
- UUID Api by TurboTuTone: http://www.computercraft.info/forums2/index.php?/topic/13924-uuid-api-universally-unique-identifier/
- Base 64 Api: http://lua-users.org/wiki/BaseSixtyFour
- SHA Api by Anavrins: http://www.computercraft.info/forums2/index.php?/topic/8169-sha-256-in-pure-lua/page__st__40

Thank you for all the help from the people on the Computer Mods Unofficial Discord, and SquidDev in particular.

# Usage
If you intend to use this in your code, please link in the forum post to this page ([https://github.com/Restioson/secunet](https://github.com/Restioson/secunet)). If you do not intend to publish it, then you do not need to link to this.
