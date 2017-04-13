-- Updates SecuNet api
io.write("Installation directory: ")
local dir = read()
io.write("\n")
shell.run("rm " .. dir .. "/apis/secunet/secunet.lua")
shell.run("wget https://git.io/vSkXL " .. dir .. "/apis/secunet/secunet.lua")
