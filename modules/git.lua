local git = {}

git._apiBase = "https://api.github.com/repos/"
git._rawBase = "https://raw.githubusercontent.com/"
git.currentSha = nil

function git.initCache(sha)
	git.currentSha = sha
end

local function ensureDir(path)
	if not makefolder or not isfolder then return end
	local parts = string.split(path, "/")
	local current = ""
	for i = 1, #parts - 1 do
		current = current .. parts[i]
		if not isfolder(current) then pcall(function() makefolder(current) end) end
		current = current .. "/"
	end
end

function git.fetch(repo, ref, filePath)
	local sha = git.currentSha
	local cacheEnabled = (sha and isfile and readfile and writefile and makefolder and isfolder)
	local cachePath = "roeditor/cache/" .. tostring(sha) .. "/" .. filePath

	if cacheEnabled and isfile(cachePath) then
		return readfile(cachePath)
	end

	local rawUrl = git._rawBase .. repo .. "/" .. (sha or ref) .. "/" .. filePath
	local ok, content = pcall(function() return game:HttpGet(rawUrl) end)
	
	if not ok then return nil, content end

	if type(content) == "string" and content:sub(1,3) == '\239\187\191' then
		content = content:sub(4)
	end

	if cacheEnabled then
		pcall(function()
			ensureDir(cachePath)
			writefile(cachePath, content)
		end)
	end

	return content
end

return git