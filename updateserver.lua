-- Updates SecuNet server
io.write("Installation directory: ")
local dir = read()
io.write("\n")
shell.run("rm " .. dir .. "/server.lua")
shell.run("wget https://git.io/vSkXq " .. dir .. "/")
