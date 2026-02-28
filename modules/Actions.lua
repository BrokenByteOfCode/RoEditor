return function(obj, inspectorFrame, cleanInspector, selectorHighlight, createReadOnly, Players, modelExportApi)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 25)
	row.BackgroundTransparency = 1
	row.Parent = inspectorFrame
	
	local listLayout = Instance.new("UIListLayout")
	listLayout.FillDirection = Enum.FillDirection.Horizontal
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = row

	local activeButtons = {}
	local btnCount = 0

	local delBtn = Instance.new("TextButton")
	delBtn.BackgroundColor3 = Color3.new(0.6, 0.1, 0.1)
	delBtn.TextColor3 = Color3.new(1, 1, 1)
	delBtn.Font = Enum.Font.Code
	delBtn.TextSize = 12
	delBtn.Text = "Delete"
	delBtn.BorderSizePixel = 1
	delBtn.BorderColor3 = Color3.new(0.1, 0.1, 0.1)
	table.insert(activeButtons, delBtn)
	btnCount = btnCount + 1

	delBtn.MouseButton1Click:Connect(function()
		pcall(function()
			obj:Destroy()
			selectorHighlight.Enabled = false
		end)
		cleanInspector()
		createReadOnly(inspectorFrame, " Object Deleted")
	end)

	if obj:IsA("BasePart") or obj:IsA("Model") then
		local tpBtn = Instance.new("TextButton")
		tpBtn.BackgroundColor3 = Color3.new(0.1, 0.4, 0.1)
		tpBtn.TextColor3 = Color3.new(1, 1, 1)
		tpBtn.Font = Enum.Font.Code
		tpBtn.TextSize = 12
		tpBtn.Text = "Teleport To"
		tpBtn.BorderSizePixel = 1
		tpBtn.BorderColor3 = Color3.new(0.1, 0.1, 0.1)
		table.insert(activeButtons, tpBtn)
		btnCount = btnCount + 1

		tpBtn.MouseButton1Click:Connect(function()
			local char = Players.LocalPlayer.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				if obj:IsA("BasePart") then
					char.HumanoidRootPart.CFrame = obj.CFrame
				elseif obj:IsA("Model") then
					char.HumanoidRootPart.CFrame = obj:GetBoundingBox()
				end
			end
		end)
	end

	if obj.Archivable then
		local cloneBtn = Instance.new("TextButton")
		cloneBtn.BackgroundColor3 = Color3.new(0.1, 0.3, 0.6)
		cloneBtn.TextColor3 = Color3.new(1, 1, 1)
		cloneBtn.Font = Enum.Font.Code
		cloneBtn.TextSize = 12
		cloneBtn.Text = "Clone to WS"
		cloneBtn.BorderSizePixel = 1
		cloneBtn.BorderColor3 = Color3.new(0.1, 0.1, 0.1)
		table.insert(activeButtons, cloneBtn)
		btnCount = btnCount + 1

		cloneBtn.MouseButton1Click:Connect(function()
			pcall(function()
				local clone = obj:Clone()
				if clone then
					local char = Players.LocalPlayer.Character
					if char and char:FindFirstChild("HumanoidRootPart") then
						local spawnCFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
						if clone:IsA("Model") then
							clone:PivotTo(spawnCFrame)
						elseif clone:IsA("BasePart") then
							clone.CFrame = spawnCFrame
						end
					end
					clone.Parent = workspace
				end
			end)
		end)
	end
	
	if obj:IsA("Humanoid") then
		local healBtn = Instance.new("TextButton")
		healBtn.BackgroundColor3 = Color3.new(0.1, 0.6, 0.1)
		healBtn.TextColor3 = Color3.new(1, 1, 1)
		healBtn.Font = Enum.Font.Code
		healBtn.TextSize = 12
		healBtn.Text = "Heal"
		healBtn.BorderSizePixel = 1
		healBtn.BorderColor3 = Color3.new(0.1, 0.1, 0.1)
		table.insert(activeButtons, healBtn)
		btnCount = btnCount + 1

		healBtn.MouseButton1Click:Connect(function()
			pcall(function() obj.Health = obj.MaxHealth end)
		end)

		local killHBtn = Instance.new("TextButton")
		killHBtn.BackgroundColor3 = Color3.new(0.8, 0.1, 0.1)
		killHBtn.TextColor3 = Color3.new(1, 1, 1)
		killHBtn.Font = Enum.Font.Code
		killHBtn.TextSize = 12
		killHBtn.Text = "Kill"
		killHBtn.BorderSizePixel = 1
		killHBtn.BorderColor3 = Color3.new(0.1, 0.1, 0.1)
		table.insert(activeButtons, killHBtn)
		btnCount = btnCount + 1

		killHBtn.MouseButton1Click:Connect(function()
			pcall(function() obj.Health = 0 end)
		end)
	end

	local pathBtn = Instance.new("TextButton")
	pathBtn.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
	pathBtn.TextColor3 = Color3.new(1, 1, 1)
	pathBtn.Font = Enum.Font.Code
	pathBtn.TextSize = 12
	pathBtn.Text = "Print Path"
	pathBtn.BorderSizePixel = 1
	pathBtn.BorderColor3 = Color3.new(0.1, 0.1, 0.1)
	table.insert(activeButtons, pathBtn)
	btnCount = btnCount + 1

	pathBtn.MouseButton1Click:Connect(function()
		local path = obj:GetFullName()
		print(path)
		if setclipboard then
			pcall(function() setclipboard(path) end)
		end
	end)

	if modelExportApi then
		local expBtn = Instance.new("TextButton")
		expBtn.BackgroundColor3 = Color3.new(0.5, 0.2, 0.6)
		expBtn.TextColor3 = Color3.new(1, 1, 1)
		expBtn.Font = Enum.Font.Code
		expBtn.TextSize = 12
		expBtn.Text = "Add to Export"
		expBtn.BorderSizePixel = 1
		expBtn.BorderColor3 = Color3.new(0.1, 0.1, 0.1)
		table.insert(activeButtons, expBtn)
		btnCount = btnCount + 1

		expBtn.MouseButton1Click:Connect(function()
			modelExportApi.add(obj)
		end)
	end

	local btnWidth = 1 / btnCount
	for i, btn in ipairs(activeButtons) do
		btn.Size = UDim2.new(btnWidth, 0, 1, 0)
		btn.LayoutOrder = i
		btn.Parent = row
	end
end