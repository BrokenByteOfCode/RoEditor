local HttpService = game:GetService("HttpService")

local REPO = "BrokenByteOfCode/RoEditor"
local REF = "main"

local sha = nil
pcall(function()
	local url = "https://api.github.com/repos/" .. REPO .. "/commits/" .. REF
	local res = game:HttpGet(url)
	local data = HttpService:JSONDecode(res)
	sha = data.sha
end)

local cacheEnabled = (sha and isfile and readfile and writefile and makefolder and isfolder)
local gitPath = "roeditor/cache/" .. tostring(sha) .. "/modules/git.lua"
local gitSrc

if cacheEnabled and isfile(gitPath) then
	gitSrc = readfile(gitPath)
else
	local url = "https://raw.githubusercontent.com/" .. REPO .. "/" .. (sha or REF) .. "/modules/git.lua"
	local ok, content = pcall(function() return game:HttpGet(url) end)
	if not ok then error("[loader] Critical: couldn't fetch git.lua") end
	gitSrc = content
	if cacheEnabled then
		pcall(function()
			if not isfolder("roeditor") then makefolder("roeditor") end
			if not isfolder("roeditor/cache") then makefolder("roeditor/cache") end
			if not isfolder("roeditor/cache/" .. sha) then makefolder("roeditor/cache/" .. sha) end
			if not isfolder("roeditor/cache/" .. sha .. "/modules") then makefolder("roeditor/cache/" .. sha .. "/modules") end
			writefile(gitPath, gitSrc)
		end)
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