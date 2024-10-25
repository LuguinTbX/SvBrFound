
local function loadScript(url)
	local success, response = pcall(function()
		return game:HttpGet(url, true)
	end)

	if success then
		local successLoad, err = pcall(function()
			loadstring(response)()
		end)

		if not successLoad then
			warn("Erro ao carregar o script: " .. err)
		end
	else
		warn("Erro ao obter o script da URL: " .. response)
	end
end


local script1Url = "https://raw.githubusercontent.com/LuguinTbX/SvBrFound/refs/heads/main/thegoat.lua"


loadScript(script1Url)
wait() 

local function removeTexturesAndDecals(object)
	if object:IsA("Texture") or object:IsA("Decal") then
		object:Destroy()
	end
end


for _, descendant in pairs(game.Workspace:GetDescendants()) do
	removeTexturesAndDecals(descendant)
end


game.Workspace.DescendantAdded:Connect(function(newDescendant)
	removeTexturesAndDecals(newDescendant)
end)


game.ChildAdded:Connect(function(newChild)
	if newChild:IsA("Texture") or newChild:IsA("Decal") then
		newChild:Destroy()
	end
end)
