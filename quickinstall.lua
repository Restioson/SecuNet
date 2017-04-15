-- Installs SecuNet quickly
write("Installation directory > ")
local dir = read()
write("\n")
shell.setDir("")
shell.run("wget https://git.io/aeslua " .. dir .. "/apis/aeslua")
shell.run("pastebin get p14nFkYQ  " .. dir .. "/apis/uuid")
shell.run("pastebin get 6UV4qfNF " .. dir .. "/apis/sha")
shell.run("pastebin get BqqWB5sN " .. dir .. "/apis/base64")
shell.run("wget https://git.io/vSkXL " .. dir .. "/apis/secunet")

-- Replace %SECUNET_API_DIR% with installation dir

-- Open file (reading)
local secunet_file_read = fs.open(dir .. "/apis/secunet", "r")

-- Read data
local data = secunet_file_read.readAll()
secunet_file_read.close()

-- Open file (writing)
local secunet_file = fs.open(dir .. "/apis/secunet", "w")

-- Replace %SECUNET_API_DIR% with installation dir
secunet_file.write(data:gsub("%%SECUNET_API_DIR%%", dir))
secunet_file.close()
