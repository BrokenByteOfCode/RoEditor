return function(mainGui, globalConnections, fs)
    local HttpService = game:GetService("HttpService")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 320, 0, 420)
    frame.Position = UDim2.new(0.5, 100, 0.5, -210)
    frame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
    frame.Visible = false
    frame.Parent = mainGui
    frame.BorderSizePixel = 0
    frame.ZIndex = 20

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 25)
    titleBar.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    titleBar.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -30, 1, 0)
    title.Position = UDim2.new(0, 5, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Text = "Model Export"
    title.Font = Enum.Font.Code
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 25, 1, 0)
    closeBtn.Position = UDim2.new(1, -25, 0, 0)
    closeBtn.BackgroundColor3 = Color3.new(0.8, 0.1, 0.1)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.Code
    closeBtn.TextSize = 14
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = titleBar
    
    closeBtn.MouseButton1Click:Connect(function() frame.Visible = false end)

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, -115)
    scroll.Position = UDim2.new(0, 0, 0, 25)
    scroll.BackgroundColor3 = Color3.new(0.12, 0.12, 0.12)
    scroll.ScrollBarThickness = 4
    scroll.BorderSizePixel = 0
    scroll.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 2)
    layout.Parent = scroll

    local inputContainer = Instance.new("Frame")
    inputContainer.Size = UDim2.new(1, 0, 0, 40)
    inputContainer.Position = UDim2.new(0, 0, 1, -90)
    inputContainer.BackgroundColor3 = Color3.new(0.18, 0.18, 0.18)
    inputContainer.BorderSizePixel = 0
    inputContainer.Parent = frame

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -10, 0, 15)
    nameLabel.Position = UDim2.new(0, 5, 0, 2)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    nameLabel.Text = "File Name (saves to workspace/roeditor/)"
    nameLabel.Font = Enum.Font.Code
    nameLabel.TextSize = 10
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = inputContainer

    local nameInput = Instance.new("TextBox")
    nameInput.Size = UDim2.new(1, -10, 0, 20)
    nameInput.Position = UDim2.new(0, 5, 0, 18)
    nameInput.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    nameInput.TextColor3 = Color3.new(1, 1, 1)
    nameInput.PlaceholderText = "export_model"
    nameInput.Text = ""
    nameInput.Font = Enum.Font.Code
    nameInput.TextSize = 12
    nameInput.BorderSizePixel = 0
    nameInput.Parent = inputContainer

    local exportBtn = Instance.new("TextButton")
    exportBtn.Size = UDim2.new(0.5, 0, 0, 50)
    exportBtn.Position = UDim2.new(0, 0, 1, -50)
    exportBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
    exportBtn.TextColor3 = Color3.new(1, 1, 1)
    exportBtn.Text = "Save .rbxmx"
    exportBtn.Font = Enum.Font.Code
    exportBtn.TextSize = 14
    exportBtn.BorderSizePixel = 0
    exportBtn.Parent = frame

    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0.5, 0, 0, 50)
    clearBtn.Position = UDim2.new(0.5, 0, 1, -50)
    clearBtn.BackgroundColor3 = Color3.new(0.6, 0.2, 0.2)
    clearBtn.TextColor3 = Color3.new(1, 1, 1)
    clearBtn.Text = "Clear List"
    clearBtn.Font = Enum.Font.Code
    clearBtn.TextSize = 14
    clearBtn.BorderSizePixel = 0
    clearBtn.Parent = frame

    local selectedInstances = {}

    local function updateList()
        for _, child in ipairs(scroll:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        
        for i, obj in ipairs(selectedInstances) do
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 24)
            row.BackgroundColor3 = (i % 2 == 0) and Color3.new(0.14, 0.14, 0.14) or Color3.new(0.16, 0.16, 0.16)
            row.BorderSizePixel = 0
            row.Parent = scroll
            
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -30, 1, 0)
            lbl.Position = UDim2.new(0, 5, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.TextColor3 = Color3.new(0.9, 0.9, 0.9)
            lbl.Text = obj.Name .. " [" .. obj.ClassName .. "]"
            lbl.Font = Enum.Font.Code
            lbl.TextSize = 11
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextTruncate = Enum.TextTruncate.AtEnd
            lbl.Parent = row
            
            local remBtn = Instance.new("TextButton")
            remBtn.Size = UDim2.new(0, 24, 1, 0)
            remBtn.Position = UDim2.new(1, -24, 0, 0)
            remBtn.BackgroundTransparency = 1
            remBtn.TextColor3 = Color3.new(0.8, 0.3, 0.3)
            remBtn.Text = "x"
            remBtn.Font = Enum.Font.Code
            remBtn.TextSize = 12
            remBtn.Parent = row
            
            remBtn.MouseButton1Click:Connect(function()
                table.remove(selectedInstances, i)
                updateList()
            end)
        end
        scroll.CanvasSize = UDim2.new(0, 0, 0, #selectedInstances * 24)
        title.Text = "Model Export (" .. #selectedInstances .. ")"
    end

    clearBtn.MouseButton1Click:Connect(function()
        table.clear(selectedInstances)
        updateList()
    end)

    exportBtn.MouseButton1Click:Connect(function()
        if #selectedInstances == 0 then return end
        
        local fileName = nameInput.Text
        if fileName:match("^%s*$") then fileName = "export_model" end
        fileName = fileName:gsub("[^a-zA-Z0-9_%-]", "")
        
        local folder = "roeditor"
        local fullPath = folder .. "/" .. fileName .. ".rbxmx"
        
        exportBtn.Text = "Saving..."
        
        if makefolder then
            pcall(function() makefolder(folder) end)
        end
        
        local success, err = pcall(function()
            if saveinstance then
                saveinstance({Instances = selectedInstances, FileName = fullPath}) 
            else
                local xml = '<roblox version="4">\n'
                
                local function serialize(obj)
                    local ref = HttpService:GenerateGUID(false)
                    local s = '<Item class="' .. obj.ClassName .. '" referent="RBX' .. ref .. '">\n'
                    s = s .. '<Properties>\n'
                    s = s .. '<string name="Name">' .. obj.Name .. '</string>\n'
                    s = s .. '</Properties>\n'
                    
                    for _, child in ipairs(obj:GetChildren()) do
                        s = s .. serialize(child)
                    end
                    s = s .. '</Item>\n'
                    return s
                end
                
                for _, obj in ipairs(selectedInstances) do
                    xml = xml .. serialize(obj)
                end
                xml = xml .. '</roblox>'
                
                if fs then
                    fs.write(fullPath, xml)
                elseif writefile then
                    writefile(fullPath, xml)
                else
                    error("No file writing function found (fs.write or writefile)")
                end
            end
        end)
        
        if success then
            exportBtn.Text = "Saved: " .. fileName
            exportBtn.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
        else
            exportBtn.Text = "Failed"
            exportBtn.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
            warn("[RoEditor] Export Error: " .. tostring(err))
        end
        
        task.delay(2, function() 
            exportBtn.Text = "Save .rbxmx" 
            exportBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
        end)
    end)

    local dragging, dragStart, startPos, dragInput
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    table.insert(globalConnections, game:GetService("RunService").RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))

    local api = {}
    function api.add(obj)
        table.insert(selectedInstances, obj)
        updateList()
        frame.Visible = true
    end
    function api.toggle()
        frame.Visible = not frame.Visible
    end
    return api
end