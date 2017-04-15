-- Updates SecuNet server
local dir = "secunet"
shell.run("rm " .. dir .. "/server.lua")
shell.run("wget https://git.io/vSkXq " .. dir .. "/server.lua")

-- Replace %SECUNET_API_DIR% with installation dir

-- Open file
local secunet_file = fs.open(dir .. "/server.lua")

-- Read data
local data = secunet_file.read()

-- Replace %SECUNET_API_DIR% with installation dir
secunet_file.write(data:gsub("%SECUNET_API_DIR%", dir))
