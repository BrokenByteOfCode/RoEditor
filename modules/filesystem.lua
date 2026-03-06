local fs = {}

local function safeCall(fn, ...)
    if fn then
        return pcall(fn, ...)
    end
    return false
end

function fs.init()
    if makefolder then
        pcall(function() makefolder("roeditor") end)
    end
end

function fs.write(path, data)
    if writefile then
        pcall(function() writefile(path, data) end)
    end
end

function fs.read(path)
    if readfile and isfile then
        local success, res = pcall(function()
            if isfile(path) then
                return readfile(path)
            end
        end)
        if success then return res end
    end
    return nil
end

function fs.exists(path)
    if isfile and isfolder then
        return isfile(path) or isfolder(path)
    elseif isfile then
        return isfile(path)
    elseif isfolder then
        return isfolder(path)
    end
    return false
end

function fs.mkdir(path)
    if makefolder then
        pcall(function() makefolder(path) end)
    end
end

function fs.copy(src, dest)
    if not src or not dest then return false end
    local data = fs.read(src)
    if data then
        fs.write(dest, data)
        return true
    end
    return false
end

function fs.move(src, dest)
    if fs.copy(src, dest) then
        fs.delete(src)
        return true
    end
    return false
end

function fs.delete(path)
    if delfile then pcall(function() delfile(path) end) end
    if deletefile then pcall(function() deletefile(path) end) end
    if removefile then pcall(function() removefile(path) end) end

    if delfolder then pcall(function() delfolder(path) end) end
    if deletefolder then pcall(function() deletefolder(path) end) end
    if removefolder then pcall(function() removefolder(path) end) end
end

function fs.list(path)
    local items = {}
    if listfiles then
        local ok, res = pcall(function() return listfiles(path) end)
        if ok and type(res) == "table" then
            for _,v in ipairs(res) do table.insert(items, v) end
        end
    end
    if listfolders then
        local ok, res = pcall(function() return listfolders(path) end)
        if ok and type(res) == "table" then
            for _,v in ipairs(res) do table.insert(items, v) end
        end
    end
    return items
end

return fs