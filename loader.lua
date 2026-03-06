local HttpService = game:GetService("HttpService")

local REPO = "BrokenByteOfCode/RoEditor"
local REF = "main"

local sha = nil
local commitErr

pcall(function()
	local url = "https://api.github.com/repos/" .. REPO .. "/commits/" .. REF
	local res = game:HttpGet(url)
	local data = HttpService:JSONDecode(res)
	sha = data.sha
end)

local lastShaPath = "roeditor/cache/lastsha.txt"
local prevSha
if isfile and isfile(lastShaPath) then
	prevSha = readfile(lastShaPath)
end

if (not sha) and isfile and prevSha then
	sha = prevSha
end

print("[loader] repo: " .. REPO .. " @" .. REF .. " -> sha: " .. tostring(sha))
if prevSha then
	print("[loader] previous sha from cache: " .. tostring(prevSha))
end

local cacheEnabled = (sha and isfile and readfile and writefile and makefolder and isfolder)

if cacheEnabled and prevSha and sha and prevSha ~= sha then
	print("[loader] Updating cache from " .. prevSha .. " -> " .. sha)
	local HttpService = game:GetService("HttpService")
	local function fetchTree(treeSha)
		local url = "https://api.github.com/repos/" .. REPO .. "/git/trees/" .. treeSha .. "?recursive=1"
		local ok, res = pcall(function()
			local json = game:HttpGet(url)
			return HttpService:JSONDecode(json)
		end)
		if ok and res and res.tree then
			return res.tree
		end
		return nil
	end

	local prevTree = fetchTree(prevSha)
	local newTree = fetchTree(sha)
	if prevTree and newTree then
		print("[loader] copying unchanged files from previous cache to new cache")
		local prevMap = {}
		for _, item in ipairs(prevTree) do
			if item.type == "blob" and item.path then
				prevMap[item.path] = item.sha
			end
		end
		for _, item in ipairs(newTree) do
			if item.type == "blob" and item.path then
				local path = item.path
				if prevMap[path] == item.sha then
					local src = "roeditor/cache/" .. prevSha .. "/" .. path
					local dst = "roeditor/cache/" .. sha .. "/" .. path
					local dir = dst:match("(.+)/[^/]+$")
					if dir and not isfolder(dir) then pcall(function() makefolder(dir) end) end
					if isfile(src) then
						local content = readfile(src)
						if content then writefile(dst, content) end
					end
				end
			end
		end
	end
end

local gitPath = "roeditor/cache/" .. tostring(sha) .. "/modules/git.lua"
local gitSrc

if cacheEnabled and isfile(gitPath) then
	print("[loader] taking git.lua from cache for sha " .. tostring(sha))
	gitSrc = readfile(gitPath)
	if prevSha ~= sha then
		pcall(function() writefile(lastShaPath, sha) end)
	end
else
	local url = "https://raw.githubusercontent.com/" .. REPO .. "/" .. (sha or REF) .. "/modules/git.lua"
	print("[loader] downloading git.lua from GitHub: " .. url)
	local ok, content = pcall(function() return game:HttpGet(url) end)
	if not ok then
		if cacheEnabled and isfile(gitPath) then
			warn("[loader] HTTP error fetching git.lua, loading cached copy")
			gitSrc = readfile(gitPath)
		else
			error("[loader] Critical: couldn't fetch git.lua: " .. tostring(content))
		end
	else
		gitSrc = content
		if cacheEnabled then
			pcall(function()
				print("[loader] caching git.lua for sha " .. tostring(sha))
				if not isfolder("roeditor") then makefolder("roeditor") end
				if not isfolder("roeditor/cache") then makefolder("roeditor/cache") end
				if not isfolder("roeditor/cache/" .. sha) then makefolder("roeditor/cache/" .. sha) end
				if not isfolder("roeditor/cache/" .. sha .. "/modules") then makefolder("roeditor/cache/" .. sha .. "/modules") end
				writefile(gitPath, gitSrc)
				writefile(lastShaPath, sha)
				if isfolder and listfolders then
					pcall(function()
						local ok, dirs = pcall(function() return listfolders("roeditor/cache") end)
						if ok and type(dirs) == "table" then
							table.sort(dirs)
							local excess = #dirs - 3
							for i = 1, excess do
								local old = dirs[i]
								local path = "roeditor/cache/" .. old
								if isfolder(path) then
									if delfolder then pcall(function() delfolder(path) end) end
									if deletefolder then pcall(function() deletefolder(path) end) end
									if removefolder then pcall(function() removefolder(path) end) end
								end
							end
						end
					end)
				end
			end)
		end
	end
end

if gitSrc:sub(1,3) == '\239\187\191' then gitSrc = gitSrc:sub(4) end

local gitFunc, gitErr = loadstring(gitSrc, "=git.lua")
if not gitFunc then error("[loader] Git compile error: " .. tostring(gitErr)) end

getgenv().RoEditor_Git = gitFunc()
getgenv().RoEditor_Git.initCache(sha)

local mainSrc = getgenv().RoEditor_Git.fetch(REPO, REF, "main.lua")
if not mainSrc then error("[loader] Failed to fetch main.lua via git lib") end

if mainSrc:sub(1,3) == '\239\187\191' then mainSrc = mainSrc:sub(4) end
local mainFunc, mainErr = loadstring(mainSrc, "=main.lua")
if mainFunc then
	mainFunc()
else
	error("[loader] Main compile error: " .. tostring(mainErr))
end