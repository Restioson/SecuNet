-- Installs SecuNet quickly
io.write("Installation directory: ")
local dir = read()
io.write("\n")
shell.run("wget https://git.io/aeslua " .. dir .. "/apis/aeslua.lua")
shell.run("pastebin get p14nFkYQ  " .. dir .. "/apis/uuid.lua")
shell.run("pastebin get 6UV4qfNF " .. dir .. "/apis/sha.lua")
shell.run("pastebin get BqqWB5sN " .. dir .. "/apis/base64.lua")
shell.run("wget https://git.io/vSkXL " .. dir .. "/apis/secunet.lua")
