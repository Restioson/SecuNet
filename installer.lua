-- Installer

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
sleep(2)
term.clear()
term.setCursorPos(1,1)
io.write("[ Secure Network and Routing API by Restioson ]\n")

textutils.slowPrint("ComputerCraft does not support sending")
textutils.slowPrint("binary over modems, and as such I have")
textutils.slowPrint("used Base64 encoding to send encrypted")
textutils.slowPrint("messages. The library used is licensed")
textutils.slowPrint("under the LGPL2 library")
print("http://lua-users.org/wiki/BaseSixtyFour")

print("")
sleep(2)
term.clear()
term.setCursorPos(1,1)
io.write("[ Secure Network and Routing API by Restioson ]\n")

textutils.slowPrint("It also uses a Lua implementation of the SHA256")
textutils.slowPrint("hashing algorithm written by Anavrins")
print("http://tinyurl.com/mmgflo4")

print("")
sleep(2)
term.clear()
term.setCursorPos(1,1)


io.write("[ Secure Network and Routing API by Restioson ]\n")
textutils.slowPrint("To implement a TCP-like protocol, I used immibis'")
textutils.slowPrint("background thread API ")
io.write("http://tinyurl.com/h2zremp")
sleep(2)
term.clear()
term.setCursorPos(1,1)


io.write("[ Secure Network and Routing API by Restioson ]\n")
textutils.slowPrint("Please enter your one-time authentication pin")
io.write("> ")
otp = io.read()
term.clear()
term.setCursorPos(1,1)

io.write("[ Secure Network and Routing API by Restioson ]\n")
textutils.slowPrint("+-+-+- Installing dependencies -+-+-+")

-- Install AES api for Lua
textutils.slowPrint("*** Installing Advanced Encryption Standard API ***")
shell.run("pastebin run LYAxmSby get 86925e07cbabd70773e53d781bd8b2fe/aeslua.min.lua disk/secunet/apis/aeslua") -- Written by SquidDev https://github.com/SquidDev-CC/aeslua
textutils.slowPrint("*** Installation complete ***")
sleep(0.75)
term.clear()
term.setCursorPos(1,1)

-- Install SHA2 api for Lua
textutils.slowPrint("*** Installing Secure Hashing Algorith API ***")
shell.run("pastebin get yBfvuPNk disk/secunet/apis/sha")
textutils.slowPrint("*** Installation complete ***")
sleep(0.75)
term.clear()
term.setCursorPos(1,1)

-- Install background thread API
textutils.slowPrint("*** Installing Background Thread API ***")
shell.run("pastebin get KYtYxqHh disk/secunet/apis/thread")
textutils.slowPrint("*** Installation complete ***")
sleep(0.75)
term.clear()
term.setCursorPos(1,1)

-- Install Base64 api for Lua
textutils.slowPrint("*** Installing Base 64 encoding API ***")
shell.run("pastebin get BqqWB5sN disk/secunet/apis/base64")
textutils.slowPrint("*** Installation complete ***")
sleep(0.75)
term.clear()
term.setCursorPos(1,1)
		
-- Install client API
textutils.slowPrint("*** Installing Secure Network and Routing API ***")
shell.run("pastebin get Tz3JwuJG disk/secunet/apis/securenetwork")
textutils.slowPrint("*** Installation complete ***")
sleep(0.75)
term.clear()
term.setCursorPos(1,1)

textutils.slowPrint("+-+-+- Dependencies successfully installed -+-+-+")
sleep(2)
term.clear()
term.setCursorPos(1,1)

-- Install chat client
io.write("[ Secure Network and Routing API by Restioson ]\n")
textutils.slowPrint("+-+-+- Installing Utilities -+-+-+")

-- Install chat client

textutils.slowPrint("+-+-+- Utilities successfully installed -+-+-+")

sleep(2)

term.clear()
term.setCursorPos(1,1)
io.write("[ Secure Network and Routing API by Restioson ]\n")
textutils.slowWrite("Thank you for installing Secure Network and Routing API")
sleep(2)
term.clear()
term.setCursorPos(1,1)

