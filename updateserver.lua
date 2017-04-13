-- Updates SecuNet server
io.write("Installation directory: ")
local dir = read()
io.write("\n")
shell.run("wget https://git.io/vSkXq " .. dir .. "/apis/secunet")
