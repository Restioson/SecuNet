-- Updates SecuNet api
local dir = "secunet"
shell.run("rm " .. dir .. "/apis/secunet")
shell.run("wget https://git.io/vSkXL " .. dir .. "/apis/secunet")

-- Replace %SECUNET_API_DIR% with installation dir

-- Open file
local secunet_file = fs.open(dir .. "/apis/secunet")

-- Read data
local data = secunet_file.read()

-- Replace %SECUNET_API_DIR% with installation dir
secunet_file.write(data:gsub("%SECUNET_API_DIR%", dir))
