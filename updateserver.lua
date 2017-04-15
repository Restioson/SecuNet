-- Updates SecuNet server
local old_dir = shell.dir()
write("Installation directory > ")
local dir = read():gsub(" ","")
shell.setDir("")
shell.run("rm " .. dir .. "/server.lua")
shell.run("wget https://git.io/vSkXq " .. dir .. "/server.lua")

-- Replace %SECUNET_API_DIR% with installation dir

-- Open file (reading)
local secunet_file_read = fs.open(dir .. "/server.lua", "r")

-- Read data
local data = secunet_file_read.readAll()
secunet_file_read.close()

-- Open file (writing)
local secunet_file = fs.open(dir .. "/server.lua", "w")

-- Replace %SECUNET_API_DIR% with installation dir
secunet_file.write(data:gsub("%%SECUNET_API_DIR%%", dir))
secunet_file.close()
shell.setDir(old_dir)
