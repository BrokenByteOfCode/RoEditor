return function(UI)
	return function(mainGui, globalConnections, fs)
		local HttpService = game:GetService("HttpService")
		local frame
		
		local closeBtn = UI("TextButton", { Size = UDim2.new(0, 25, 1, 0), Position = UDim2.new(1, -25, 0, 0), BackgroundColor3 = Color3.new(0.8, 0.1, 0.1), TextColor3 = Color3.new(1, 1, 1), Text = "X", Font = Enum.Font.Code, TextSize = 14, BorderSizePixel = 0, Events = { MouseButton1Click = function() frame.Visible = false end } })
		local title = UI("TextLabel", { Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 5, 0, 0), BackgroundTransparency = 1, TextColor3 = Color3.new(1, 1, 1), Text = "Model Export", Font = Enum.Font.Code, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left })
		local titleBar = UI("Frame", { Size = UDim2.new(1, 0, 0, 25), BackgroundColor3 = Color3.new(0.1, 0.1, 0.1), title, closeBtn })
		
		local scroll = UI("ScrollingFrame", { Size = UDim2.new(1, 0, 1, -115), Position = UDim2.new(0, 0, 0, 25), BackgroundColor3 = Color3.new(0.12, 0.12, 0.12), ScrollBarThickness = 4, BorderSizePixel = 0, UI("UIListLayout", { Padding = UDim.new(0, 2) }) })
		local nameInput = UI("TextBox", { Size = UDim2.new(1, -10, 0, 20), Position = UDim2.new(0, 5, 0, 18), BackgroundColor3 = Color3.new(0.1, 0.1, 0.1), TextColor3 = Color3.new(1, 1, 1), PlaceholderText = "export_model", Text = "", Font = Enum.Font.Code, TextSize = 12, BorderSizePixel = 0 })
		local inputContainer = UI("Frame", { Size = UDim2.new(1, 0, 0, 40), Position = UDim2.new(0, 0, 1, -90), BackgroundColor3 = Color3.new(0.18, 0.18, 0.18), BorderSizePixel = 0, UI("TextLabel", { Size = UDim2.new(1, -10, 0, 15), Position = UDim2.new(0, 5, 0, 2), BackgroundTransparency = 1, TextColor3 = Color3.new(0.7, 0.7, 0.7), Text = "File Name (saves to workspace/roeditor/)", Font = Enum.Font.Code, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left }), nameInput })
		
		local selectedInstances = {}
		local clearBtn, exportBtn

		local function updateList()
			for _, child in ipairs(scroll:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
			for i, obj in ipairs(selectedInstances) do
				UI("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundColor3 = (i % 2 == 0) and Color3.new(0.14, 0.14, 0.14) or Color3.new(0.16, 0.16, 0.16), BorderSizePixel = 0, Parent = scroll,
					UI("TextLabel", { Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 5, 0, 0), BackgroundTransparency = 1, TextColor3 = Color3.new(0.9, 0.9, 0.9), Text = obj.Name .. " [" .. obj.ClassName .. "]", Font = Enum.Font.Code, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }),
					UI("TextButton", { Size = UDim2.new(0, 24, 1, 0), Position = UDim2.new(1, -24, 0, 0), BackgroundTransparency = 1, TextColor3 = Color3.new(0.8, 0.3, 0.3), Text = "x", Font = Enum.Font.Code, TextSize = 12, Events = { MouseButton1Click = function() table.remove(selectedInstances, i) updateList() end } })
				})
			end
			scroll.CanvasSize = UDim2.new(0, 0, 0, #selectedInstances * 24)
			title.Text = "Model Export (" .. #selectedInstances .. ")"
		end

		clearBtn = UI("TextButton", { Size = UDim2.new(0.5, 0, 0, 50), Position = UDim2.new(0.5, 0, 1, -50), BackgroundColor3 = Color3.new(0.6, 0.2, 0.2), TextColor3 = Color3.new(1, 1, 1), Text = "Clear List", Font = Enum.Font.Code, TextSize = 14, BorderSizePixel = 0, Events = { MouseButton1Click = function() table.clear(selectedInstances) updateList() end } })
		exportBtn = UI("TextButton", { Size = UDim2.new(0.5, 0, 0, 50), Position = UDim2.new(0, 0, 1, -50), BackgroundColor3 = Color3.new(0.2, 0.6, 0.2), TextColor3 = Color3.new(1, 1, 1), Text = "Save .rbxmx", Font = Enum.Font.Code, TextSize = 14, BorderSizePixel = 0, Events = { MouseButton1Click = function()
			if #selectedInstances == 0 then return end
			local fileName = nameInput.Text:match("^%s*$") and "export_model" or nameInput.Text:gsub("[^a-zA-Z0-9_%-]", "")
			local fullPath = "roeditor/" .. fileName .. ".rbxmx"
			exportBtn.Text = "Saving..."
			if makefolder then pcall(function() makefolder("roeditor") end) end
			local success, err = pcall(function()
				if saveinstance then saveinstance({Instances = selectedInstances, FileName = fullPath}) 
				else
					local xml = '<roblox version="4">\n'
					local function serialize(obj)
						local s = '<Item class="' .. obj.ClassName .. '" referent="RBX' .. HttpService:GenerateGUID(false) .. '">\n<Properties>\n<string name="Name">' .. obj.Name .. '</string>\n</Properties>\n'
						for _, child in ipairs(obj:GetChildren()) do s = s .. serialize(child) end
						return s .. '</Item>\n'
					end
					for _, obj in ipairs(selectedInstances) do xml = xml .. serialize(obj) end
					xml = xml .. '</roblox>'
					if fs then fs.write(fullPath, xml) elseif writefile then writefile(fullPath, xml) else error("No file writing function found") end
				end
			end)
			if success then exportBtn.Text, exportBtn.BackgroundColor3 = "Saved: " .. fileName, Color3.new(0.2, 0.8, 0.2)
			else exportBtn.Text, exportBtn.BackgroundColor3 = "Failed", Color3.new(0.8, 0.2, 0.2) end
			task.delay(2, function() exportBtn.Text, exportBtn.BackgroundColor3 = "Save .rbxmx", Color3.new(0.2, 0.6, 0.2) end)
		end } })

		frame = UI("Frame", { Size = UDim2.new(0, 320, 0, 420), Position = UDim2.new(0.5, 100, 0.5, -210), BackgroundColor3 = Color3.new(0.15, 0.15, 0.15), Visible = false, Parent = mainGui, BorderSizePixel = 0, ZIndex = 20, titleBar, scroll, inputContainer, exportBtn, clearBtn })

		local dragging, dragStart, startPos, dragInput
		titleBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging, dragStart, startPos = true, input.Position, frame.Position end end)
		titleBar.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
		frame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
		table.insert(globalConnections, game:GetService("RunService").RenderStepped:Connect(function() if dragging and dragInput then frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + (dragInput.Position - dragStart).X, startPos.Y.Scale, startPos.Y.Offset + (dragInput.Position - dragStart).Y) end end))

		return {
			add = function(obj) table.insert(selectedInstances, obj) updateList() frame.Visible = true end,
			toggle = function() frame.Visible = not frame.Visible end
		}
	end
end