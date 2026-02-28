return function(obj, inspectorFrame, inspectorConnections, RunService)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 0, 30)
	container.BackgroundTransparency = 1
	container.Parent = inspectorFrame

	local listLayout = Instance.new("UIListLayout")
	listLayout.FillDirection = Enum.FillDirection.Horizontal
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = container

	local viewBtn = Instance.new("TextButton")
	viewBtn.Size = UDim2.new(0.5, 0, 1, 0)
	viewBtn.BackgroundColor3 = Color3.new(0.2, 0.4, 0.6)
	viewBtn.TextColor3 = Color3.new(1, 1, 1)
	viewBtn.Font = Enum.Font.Code
	viewBtn.TextSize = 12
	viewBtn.Text = "Decompile"
	viewBtn.BorderSizePixel = 1
	viewBtn.BorderColor3 = Color3.new(0.1, 0.1, 0.1)
	viewBtn.Parent = container

	local copyBtn = Instance.new("TextButton")
	copyBtn.Size = UDim2.new(0.5, 0, 1, 0)
	copyBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
	copyBtn.TextColor3 = Color3.new(1, 1, 1)
	copyBtn.Font = Enum.Font.Code
	copyBtn.TextSize = 12
	copyBtn.Text = "Copy Code"
	copyBtn.BorderSizePixel = 1
	copyBtn.BorderColor3 = Color3.new(0.1, 0.1, 0.1)
	copyBtn.Parent = container

	local codeContainer = Instance.new("Frame")
	codeContainer.Size = UDim2.new(1, 0, 0, 300)
	codeContainer.BackgroundColor3 = Color3.new(0.05, 0.05, 0.05)
	codeContainer.BorderSizePixel = 0
	codeContainer.Visible = false
	codeContainer.Parent = inspectorFrame

	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, 0, 1, 0)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.XY
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.ScrollBarThickness = 6
	scroll.Parent = codeContainer

	local codeLbl = Instance.new("TextLabel")
	codeLbl.Size = UDim2.new(0, 0, 0, 0)
	codeLbl.AutomaticSize = Enum.AutomaticSize.XY
	codeLbl.BackgroundTransparency = 1
	codeLbl.TextColor3 = Color3.new(0.9, 0.9, 0.9)
	codeLbl.TextXAlignment = Enum.TextXAlignment.Left
	codeLbl.TextYAlignment = Enum.TextYAlignment.Top
	codeLbl.Font = Enum.Font.Code
	codeLbl.TextSize = 12
	codeLbl.Parent = scroll
	local cachedCode = nil

	local function getCode()
		if cachedCode then return cachedCode end
		if type(decompile) == "function" then
			local success, result = pcall(decompile, obj)
			if success and type(result) == "string" then
				cachedCode = result
			else
				cachedCode = "Error decompiling:\n" .. tostring(result)
			end
		else
			cachedCode = "Executor does not support 'decompile' function."
		end
		return cachedCode
	end

	viewBtn.MouseButton1Click:Connect(function()
		codeContainer.Visible = not codeContainer.Visible
		if codeContainer.Visible then
			viewBtn.Text = "Hide Code"
			codeLbl.Text = "Decompiling..."
			task.spawn(function()
				local code = getCode()
				codeLbl.RichText = false
				codeLbl.Text = code
			end)
		else
			viewBtn.Text = "Decompile"
		end
	end)

	copyBtn.MouseButton1Click:Connect(function()
		if setclipboard then
			setclipboard(getCode())
			local oldText = copyBtn.Text
			copyBtn.Text = "Copied!"
			task.wait(1)
			copyBtn.Text = oldText
		end
	end)
end