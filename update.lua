-- Updates SecuNet api
local dir = "secunet"
shell.run("rm " .. dir .. "/apis/secunet")
shell.run("wget https://git.io/vSkXL " .. dir .. "/apis/secunet")
