-- Installs the installers and the updaters... getting out of hand
io.write("Installation directory: ")
local dir = read()
io.write("\n")
shell.run("wget https://git.io/vSSeW " .. dir .. "/secunet-installers/update.lua")
shell.run("wget https://git.io/vSSez " .. dir .. "/secunet-installers/updateserver.lua")
shell.run("wget https://git.io/vSSew " .. dir .. "/secunet-installers/quickinstall.lua")
