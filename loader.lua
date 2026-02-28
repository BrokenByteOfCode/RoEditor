local HttpService = game:GetService("HttpService")

local REPO = "BrokenByteOfCode/RoEditor"
local REF  = "main"

local function bootstrapFetch(filePath)
    local url = "https://raw.githubusercontent.com/"..REPO.."/"..REF.."/"..filePath
    local ok, content = pcall(function()
        return game:HttpGet(url)
    end)
    if not ok then
        return nil
    end
    return content
end

local gitSrc = bootstrapFetch("modules/git.lua")
if not gitSrc then
    error("[loader] Critical: couldn't fetch git.lua")
end

if gitSrc:sub(1,3) == '\239\187\191' then
    gitSrc = gitSrc:sub(4)
end

local gitFunc, gitErr = loadstring(gitSrc, "=git.lua")
if not gitFunc then
    error("[loader] Git compile error: " .. tostring(gitErr))
end

getgenv().RoEditor_Git = gitFunc()
print("[loader] Git library loaded into memory")

local mainSrc = getgenv().RoEditor_Git.fetch(REPO, REF, "main.lua")
if not mainSrc then
    error("[loader] Failed to fetch main.lua via git lib")
else
    if mainSrc:sub(1,3) == '\239\187\191' then mainSrc = mainSrc:sub(4) end
    local mainFunc, mainErr = loadstring(mainSrc, "=main.lua")
    if mainFunc then
        mainFunc()
    else
        error("[loader] Main compile error: " .. tostring(mainErr))
    end
end