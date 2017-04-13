-- Installs the installers and the updaters...
io.write("Installation directory: ")
local dir = read()
io.write("\n")
shell.run("wget https://git.io/vSSeW " .. dir .. "/secunet-installers/")
shell.run("wget https://git.io/vSSez " .. dir .. "/secunet-installers/")
shell.run("wget https://git.io/vSSew " .. dir .. "/secunet-installers/")
