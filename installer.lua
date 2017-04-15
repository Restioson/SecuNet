-- Installer

term.clear()
term.setCursorPos(1,1)

io.write("[ Secure Network and Routing API by Restioson ]\n")
sleep(0.75)
write("Installation directory > ")
local dir = read()
write("\nNote: if you copy the libraries somewhere else, SecuNet *will not work*. You will need to update the api dir with the updater\n")
shell.run("mkdir " .. dir)

print("")
term.clear()
term.setCursorPos(1,1)

io.write("[ Secure Network and Routing API by Restioson ]\n")
sleep(0.75)
textutils.slowPrint("This network is encrypted using the AES cipher")
textutils.slowPrint("It uses a pure-lua implementation, written by ")
textutils.slowWrite("SquidDev")
sleep(0.5)
io.write(" https://github.com/SquidDev-CC/aeslua") 

print("")
sleep(4)
term.clear()
term.setCursorPos(1,1)

io.write("[ Secure Network and Routing API by Restioson ]\n")
sleep(0.75)
textutils.slowPrint("To prevent DDOS attacks, each message has a unique")
textutils.slowPrint("UUID attached, and a message is only processed if")
textutils.slowWrite("the UUID matches what the client and server have")
textutils.slowWrite("agreed upon. It uses a uuid library written by TurboTuTone")
sleep(0.5)
io.write(" http://tinyurl.com/compcuuid") 

print("")
sleep(4)
term.clear()
term.setCursorPos(1,1)

io.write("[ Secure Network and Routing API by Restioson ]\n")

textutils.slowPrint("ComputerCraft does not support sending")
textutils.slowPrint("binary over modems, and as such I have used")
textutils.slowPrint("Base64 encoding to send encrypted messages.")
textutils.slowPrint("The library used is licensed under the")
textutils.slowPrint("LGPL2 library")
print("http://lua-users.org/wiki/BaseSixtyFour")

print("")
sleep(4)
term.clear()
term.setCursorPos(1,1)
io.write("[ Secure Network and Routing API by Restioson ]\n")

textutils.slowPrint("It also uses a Lua implementation of the SHA256")
textutils.slowPrint("hashing algorithm written by Anavrins to ensure message")
textutils.slowPrint("integrity ")
print("http://tinyurl.com/anavrin-sha")

print("")
sleep(4)
term.clear()
term.setCursorPos(1,1)

io.write("[ Secure Network and Routing API by Restioson ]\n")
textutils.slowPrint("More detailed credits are on the forum thread")
sleep(4)
term.clear()
term.setCursorPos(1,1)

io.write("[ Secure Network and Routing API by Restioson ]\n")
textutils.slowPrint("+-+-+- Installing dependencies -+-+-+")

-- Install AES api for Lua
textutils.slowPrint("*** Installing Advanced Encryption Standard API ***")
shell.run("wget https://git.io/aeslua " .. dir .. "/apis/aeslua") -- Written by SquidDev https://github.com/SquidDev-CC/aeslua
textutils.slowPrint("*** Installation complete ***")
sleep(0.75)
term.clear()
term.setCursorPos(1,1)

-- Install UUID API for lua
textutils.slowPrint("*** Installing UUID API ***")
shell.run("pastebin get p14nFkYQ  " .. dir .. "/apis/uuid")
textutils.slowPrint("*** Installation complete ***")
sleep(0.75)
term.clear()
term.setCursorPos(1,1)

-- Install SHA2 api for Lua
textutils.slowPrint("*** Installing Secure Hashing Algorith API ***")
shell.run("pastebin get 6UV4qfNF " .. dir .. "/apis/sha")
textutils.slowPrint("*** Installation complete ***")
sleep(0.75)
term.clear()
term.setCursorPos(1,1)

-- Install Base64 api for Lua
textutils.slowPrint("*** Installing Base 64 encoding API ***")
shell.run("pastebin get BqqWB5sN " .. dir .. "/apis/base64")
textutils.slowPrint("*** Installation complete ***")
sleep(0.75)
term.clear()
term.setCursorPos(1,1)
        
-- Install client API
textutils.slowPrint("*** Installing Secure Network and Routing API ***")
shell.run("wget https://git.io/vSkXL " .. dir .. "/apis/secunet")
textutils.slowPrint("*** Installation complete ***")
sleep(0.75)
term.clear()
term.setCursorPos(1,1)

-- Replace %SECUNET_API_DIR% with installation dir

-- Open file
local secunet_file = fs.open(dir .. "/apis/secunet")

-- Read data
local data = secunet_file.read()

-- Replace %SECUNET_API_DIR% with installation dir
secunet_file.write(data:gsub("%SECUNET_API_DIR%", dir))

textutils.slowPrint("+-+-+- Dependencies successfully installed -+-+-+")
sleep(2)
term.clear()
term.setCursorPos(1,1)

-- Install chat client
io.write("[ Secure Network and Routing API by Restioson ]\n")
textutils.slowPrint("+-+-+- Installing Utilities -+-+-+")

-- Install chat client
-- TODO install chat client

textutils.slowPrint("+-+-+- Utilities successfully installed -+-+-+")

sleep(2)
term.clear()

term.clear()
term.setCursorPos(1,1)
io.write("[ Secure Network and Routing API by Restioson ]\n")
textutils.slowWrite("Thank you for installing Secure Network and Routing API")
sleep(2)
term.clear()
term.setCursorPos(1,1)
