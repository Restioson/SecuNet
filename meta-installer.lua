-- Installs the installers and the updaters... getting out of hand
io.write("Installation directory: ")
local dir = read()
io.write("\n")
shell.run("wget https://git.io/vSSeW " .. dir .. "/update.lua")
shell.run("wget https://git.io/vSSez " .. dir .. "/updateserver.lua")
shell.run("wget https://git.io/vSSew " .. dir .. "/quickinstall.lua")
shell.run("wget https://git.io/vSQOy " .. dir .. "/installer.lua")
