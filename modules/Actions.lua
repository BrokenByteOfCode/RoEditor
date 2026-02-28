print("[RoEditor_DEBUG] Reached ID: 40")
return function(UI)
    print("[RoEditor_DEBUG] Reached ID: 41")
	return function(obj, inspectorFrame, cleanInspector, selectorHighlight, createReadOnly, Players, modelExportApi)
     print("[RoEditor_DEBUG] Reached ID: 42")
		local activeButtons = {}
		local row = UI("Frame", { Size = UDim2.new(1, 0, 0, 25), BackgroundTransparency = 1, Parent = inspectorFrame, UI("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder }) })

		table.insert(activeButtons, UI("TextButton", { BackgroundColor3 = Color3.new(0.6, 0.1, 0.1), TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.Code, TextSize = 12, Text = "Delete", BorderSizePixel = 1, BorderColor3 = Color3.new(0.1, 0.1, 0.1), Events = { MouseButton1Click = function() pcall(function() obj:Destroy() selectorHighlight.Enabled = false end) cleanInspector() createReadOnly(inspectorFrame, " Object Deleted") end } }))
      print("[RoEditor_DEBUG] Reached ID: 43")

		if obj:IsA("BasePart") or obj:IsA("Model") then
			table.insert(activeButtons, UI("TextButton", { BackgroundColor3 = Color3.new(0.1, 0.4, 0.1), TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.Code, TextSize = 12, Text = "Teleport To", BorderSizePixel = 1, BorderColor3 = Color3.new(0.1, 0.1, 0.1), Events = { MouseButton1Click = function() local char = Players.LocalPlayer.Character if char and char:FindFirstChild("HumanoidRootPart") then if obj:IsA("BasePart") then char.HumanoidRootPart.CFrame = obj.CFrame elseif obj:IsA("Model") then char.HumanoidRootPart.CFrame = obj:GetBoundingBox() end end end } }))
       print("[RoEditor_DEBUG] Reached ID: 44")
		end

		if obj.Archivable then
			table.insert(activeButtons, UI("TextButton", { BackgroundColor3 = Color3.new(0.1, 0.3, 0.6), TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.Code, TextSize = 12, Text = "Clone to WS", BorderSizePixel = 1, BorderColor3 = Color3.new(0.1, 0.1, 0.1), Events = { MouseButton1Click = function() pcall(function() local clone = obj:Clone() if clone then local char = Players.LocalPlayer.Character if char and char:FindFirstChild("HumanoidRootPart") then local spawnCFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5) if clone:IsA("Model") then clone:PivotTo(spawnCFrame) elseif clone:IsA("BasePart") then clone.CFrame = spawnCFrame end end clone.Parent = workspace end end) end } }))
       print("[RoEditor_DEBUG] Reached ID: 45")
		end

		if obj:IsA("Humanoid") then
			table.insert(activeButtons, UI("TextButton", { BackgroundColor3 = Color3.new(0.1, 0.6, 0.1), TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.Code, TextSize = 12, Text = "Heal", BorderSizePixel = 1, BorderColor3 = Color3.new(0.1, 0.1, 0.1), Events = { MouseButton1Click = function() pcall(function() obj.Health = obj.MaxHealth end) end } }))
       print("[RoEditor_DEBUG] Reached ID: 46")
			table.insert(activeButtons, UI("TextButton", { BackgroundColor3 = Color3.new(0.8, 0.1, 0.1), TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.Code, TextSize = 12, Text = "Kill", BorderSizePixel = 1, BorderColor3 = Color3.new(0.1, 0.1, 0.1), Events = { MouseButton1Click = function() pcall(function() obj.Health = 0 end) end } }))
       print("[RoEditor_DEBUG] Reached ID: 47")
		end

		table.insert(activeButtons, UI("TextButton", { BackgroundColor3 = Color3.new(0.4, 0.4, 0.4), TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.Code, TextSize = 12, Text = "Print Path", BorderSizePixel = 1, BorderColor3 = Color3.new(0.1, 0.1, 0.1), Events = { MouseButton1Click = function() local path = obj:GetFullName() print(path) if setclipboard then pcall(function() setclipboard(path) end) end end } }))
      print("[RoEditor_DEBUG] Reached ID: 48")

		if modelExportApi then
			table.insert(activeButtons, UI("TextButton", { BackgroundColor3 = Color3.new(0.5, 0.2, 0.6), TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.Code, TextSize = 12, Text = "Add to Export", BorderSizePixel = 1, BorderColor3 = Color3.new(0.1, 0.1, 0.1), Events = { MouseButton1Click = function() modelExportApi.add(obj) end } }))
       print("[RoEditor_DEBUG] Reached ID: 49")
		end

		local btnWidth = 1 / #activeButtons
		for i, btn in ipairs(activeButtons) do
			btn.Size = UDim2.new(btnWidth, 0, 1, 0)
			btn.LayoutOrder = i
			btn.Parent = row
		end
	end
end