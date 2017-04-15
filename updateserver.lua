-- Updates SecuNet server
local dir = "secunet"
shell.run("rm " .. dir .. "/server.lua")
shell.run("wget https://git.io/vSkXq " .. dir .. "/server.lua")
