return function(UI)
	return function(mainGui, globalConnections, inspectObj)
		local RunService = game:GetService("RunService")

		local titleBar = UI("TextLabel", { Size = UDim2.new(1, 0, 0, 25), BackgroundColor3 = Color3.new(0.2, 0.5, 0.2), TextColor3 = Color3.new(1, 1, 1), Text = " RT Item Checker", Font = Enum.Font.Code, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left })
		local closeBtn = UI("TextButton", { Size = UDim2.new(0, 25, 1, 0), Position = UDim2.new(1, -25, 0, 0), BackgroundColor3 = Color3.new(0.8, 0.1, 0.1), TextColor3 = Color3.new(1, 1, 1), Text = "X", Font = Enum.Font.Code, TextSize = 12, BorderSizePixel = 0, Parent = titleBar })
		
		local filterFrame = UI("Frame", { Size = UDim2.new(1, 0, 0, 50), Position = UDim2.new(0, 0, 0, 25), BackgroundColor3 = Color3.new(0.12, 0.12, 0.12), BorderSizePixel = 0 })
		local classFilterInput = UI("TextBox", { Size = UDim2.new(1, -10, 0, 20), Position = UDim2.new(0, 5, 0, 5), BackgroundColor3 = Color3.new(0.2, 0.2, 0.2), TextColor3 = Color3.new(1, 1, 1), Text = "ParticleEmitter, Fire, Smoke, Sparkles, Trail, Beam, Explosion", PlaceholderText = "Ignore Classes (e.g. Part, Script)", Font = Enum.Font.Code, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Parent = filterFrame })
		local nameFilterInput = UI("TextBox", { Size = UDim2.new(1, -10, 0, 20), Position = UDim2.new(0, 5, 0, 28), BackgroundColor3 = Color3.new(0.2, 0.2, 0.2), TextColor3 = Color3.new(1, 1, 1), Text = "", PlaceholderText = "Ignore Names (e.g. Bullet, Debris)", Font = Enum.Font.Code, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Parent = filterFrame })

		local scroll = UI("ScrollingFrame", { Size = UDim2.new(1, 0, 1, -75), Position = UDim2.new(0, 0, 0, 75), BackgroundColor3 = Color3.new(0.1, 0.1, 0.1), BorderSizePixel = 0, ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0), UI("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }) })
		local frame = UI("Frame", { Size = UDim2.new(0, 350, 0, 320), Position = UDim2.new(0.5, -175, 0.5, -160), BackgroundColor3 = Color3.new(0.15, 0.15, 0.15), BorderSizePixel = 0, Visible = false, Parent = mainGui, titleBar, filterFrame, scroll })

		closeBtn.MouseButton1Click:Connect(function() frame.Visible = false end)

		local dragging, dragStart, startPos, dragInput
		titleBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				dragStart = input.Position
				startPos = frame.Position
			end
		end)
		titleBar.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)
		frame.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				dragInput = input
			end
		end)

		table.insert(globalConnections, RunService.RenderStepped:Connect(function()
			if dragging and dragInput then
				frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + (dragInput.Position - dragStart).X, startPos.Y.Scale, startPos.Y.Offset + (dragInput.Position - dragStart).Y)
			end
		end))

		local ignoredClasses = {}
		local ignoredNames = {}

		local function updateFilters()
			ignoredClasses = {}
			for s in string.gmatch(classFilterInput.Text, "([^,]+)") do
				ignoredClasses[s:match("^%s*(.-)%s*$")] = true
			end
			ignoredNames = {}
			for s in string.gmatch(nameFilterInput.Text, "([^,]+)") do
				ignoredNames[s:match("^%s*(.-)%s*$")] = true
			end
		end

		updateFilters()
		classFilterInput:GetPropertyChangedSignal("Text"):Connect(updateFilters)
		nameFilterInput:GetPropertyChangedSignal("Text"):Connect(updateFilters)

		local trackedItems = {}
		local uiRows = {}
		local layoutCounter = 0

		local function isItemValid(obj)
			if not obj or not obj.Parent then return false end
			if obj:FindFirstAncestorWhichIsA("Backpack") then return false end
			
			local model = obj:FindFirstAncestorWhichIsA("Model")
			if model and model:FindFirstChildWhichIsA("Humanoid") then return false end
			
			if ignoredClasses[obj.ClassName] then return false end
			if ignoredNames[obj.Name] then return false end
			
			return true
		end

		local function addItem(obj)
			if trackedItems[obj] then return end
			if not isItemValid(obj) then return end
			
			trackedItems[obj] = true
			layoutCounter = layoutCounter - 1

			local row = UI("Frame", { Size = UDim2.new(1, 0, 0, 25), BackgroundTransparency = 1, LayoutOrder = layoutCounter, Parent = scroll })
			local nameLbl = UI("TextLabel", { Size = UDim2.new(1, -60, 1, 0), BackgroundTransparency = 1, TextColor3 = Color3.new(0.9, 0.9, 0.9), Text = " " .. obj.Name .. " [" .. obj.ClassName .. "]", Font = Enum.Font.Code, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = row })
			local inspectBtn = UI("TextButton", { Size = UDim2.new(0, 60, 1, 0), Position = UDim2.new(1, -60, 0, 0), BackgroundColor3 = Color3.new(0.8, 0.5, 0.2), TextColor3 = Color3.new(1, 1, 1), Text = "Inspect", Font = Enum.Font.Code, TextSize = 12, BorderSizePixel = 0, Parent = row })

			table.insert(uiRows, 1, {row = row, obj = obj})

			if #uiRows > 200 then
				local oldest = table.remove(uiRows)
				if oldest.row then oldest.row:Destroy() end
				if oldest.obj then trackedItems[oldest.obj] = nil end
			end

			inspectBtn.MouseButton1Click:Connect(function()
				if inspectObj then
					inspectObj(obj)
				end
			end)

			local conn
			conn = obj.AncestryChanged:Connect(function(_, parent)
				if not parent or not obj:IsDescendantOf(workspace) or not isItemValid(obj) then
					trackedItems[obj] = nil
					row:Destroy()
					conn:Disconnect()
				end
			end)
		end

		table.insert(globalConnections, workspace.DescendantAdded:Connect(function(descendant)
			addItem(descendant)
		end))

		return function() frame.Visible = not frame.Visible end
	end
end