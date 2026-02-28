local HttpService = game:GetService("HttpService")

local git = {}

git._apiBase = "https://api.github.com/repos/"
git._rawBase = "https://raw.githubusercontent.com/"

function git.resolveCommit(repo, ref)
    local url = git._apiBase .. repo .. "/commits/" .. ref
    local ok, response = pcall(function()
        return game:HttpGet(url)
    end)

    if not ok then
        return nil, response
    end

    local data = HttpService:JSONDecode(response)
    return data.sha
end

function git.fetch(repo, ref, filePath)
    local sha, err = git.resolveCommit(repo, ref)
    if not sha then
        return nil, ("couldn't resolve %s@%s: %s"):format(repo, ref, err)
    end

    local rawUrl = git._rawBase .. repo .. "/" .. sha .. "/" .. filePath
    local ok, content = pcall(function()
        return game:HttpGet(rawUrl)
    end)

    if not ok then
        return nil, content
    end

    if type(content) == "string" and content:sub(1,3) == '\239\187\191' then
        content = content:sub(4)
    end

    return content
end

function git.load(repo, ref, filePath)
    local content, err = git.fetch(repo, ref, filePath)
    if not content then
        error(err)
    end
    return loadstring(content)()
end

return git
