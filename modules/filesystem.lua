local fs = {}

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

return fs