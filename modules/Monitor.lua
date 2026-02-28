return function(mainGui, globalConnections, RunService)
	local Stats = game:GetService("Stats")
	
	local frame = Instance.new("Frame")
	frame.Name = "MonitorFrame"
	frame.Size = UDim2.new(0, 200, 0, 110)
	frame.Position = UDim2.new(0.5, -100, 0.5, 50)
	frame.BackgroundColor3 = Color3.new(0.08, 0.08, 0.15)
	frame.BorderSizePixel = 1
	frame.BorderColor3 = Color3.new(0.3, 0.3, 0.5)
	frame.Visible = false
	frame.Parent = mainGui

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 20)
	title.BackgroundColor3 = Color3.new(0.2, 0.3, 0.5)
	title.TextColor3 = Color3.new(1, 1, 1)
	title.Text = " System Monitor"
	title.Font = Enum.Font.Code
	title.TextSize = 12
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = frame

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 20, 1, 0)
	closeBtn.Position = UDim2.new(1, -20, 0, 0)
	closeBtn.BackgroundTransparency = 1
	closeBtn.TextColor3 = Color3.new(1, 1, 1)
	closeBtn.Text = "X"
	closeBtn.Font = Enum.Font.Code
	closeBtn.Parent = title

	local fpsLbl = Instance.new("TextLabel")
	fpsLbl.Size = UDim2.new(1, -10, 0, 15)
	fpsLbl.Position = UDim2.new(0, 5, 0, 25)
	fpsLbl.BackgroundTransparency = 1
	fpsLbl.TextColor3 = Color3.new(0.8, 0.8, 0.8)
	fpsLbl.Font = Enum.Font.Code
	fpsLbl.TextSize = 11
	fpsLbl.TextXAlignment = Enum.TextXAlignment.Left
	fpsLbl.Parent = frame

	local memLbl = Instance.new("TextLabel")
	memLbl.Size = UDim2.new(1, -10, 0, 15)
	memLbl.Position = UDim2.new(0, 5, 0, 45)
	memLbl.BackgroundTransparency = 1
	memLbl.TextColor3 = Color3.new(0.8, 0.8, 0.8)
	memLbl.Font = Enum.Font.Code
	memLbl.TextSize = 11
	memLbl.TextXAlignment = Enum.TextXAlignment.Left
	memLbl.Parent = frame

	local netLbl = Instance.new("TextLabel")
	netLbl.Size = UDim2.new(1, -10, 0, 15)
	netLbl.Position = UDim2.new(0, 5, 0, 65)
	netLbl.BackgroundTransparency = 1
	netLbl.TextColor3 = Color3.new(0.8, 0.8, 0.8)
	netLbl.Font = Enum.Font.Code
	netLbl.TextSize = 11
	netLbl.TextXAlignment = Enum.TextXAlignment.Left
	netLbl.Parent = frame
	
	local instLbl = Instance.new("TextLabel")
	instLbl.Size = UDim2.new(1, -10, 0, 15)
	instLbl.Position = UDim2.new(0, 5, 0, 85)
	instLbl.BackgroundTransparency = 1
	instLbl.TextColor3 = Color3.new(0.8, 0.8, 0.8)
	instLbl.Font = Enum.Font.Code
	instLbl.TextSize = 11
	instLbl.TextXAlignment = Enum.TextXAlignment.Left
	instLbl.Parent = frame

	local dragging, dragInput, dragStart, startPos
	title.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
		end
	end)
	title.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)
	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
	end)
	
	closeBtn.MouseButton1Click:Connect(function()
		frame.Visible = false
	end)

	local lastUpdate = 0
	table.insert(globalConnections, RunService.RenderStepped:Connect(function(dt)
		if frame.Visible then
			if dragging and dragInput then
				local delta = dragInput.Position - dragStart
				frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
			
			if tick() - lastUpdate > 0.5 then
				lastUpdate = tick()
				local fps = math.floor(1 / dt)
				
				local mem = "Not work. Please forgive me."
				pcall(function()
					mem = math.floor(Stats:GetTotalMemoryUsageMb())
				end)

				local net = "Not work. Please forgive me."
				pcall(function()
					net = math.floor(Stats.Network.DataReceiveKbps)
				end)
				
				fpsLbl.Text = "FPS: " .. fps .. " (" .. math.floor(dt*1000) .. "ms)"
				memLbl.Text = "Memory: " .. mem .. " MB"
				netLbl.Text = "Net In: " .. net .. " KB/s"
				
				local count = #workspace:GetDescendants()
				instLbl.Text = "WS Instances: " .. count
			end
		end
	end))

	return function()
		frame.Visible = not frame.Visible
		if frame.Visible then frame.Parent = mainGui end
	end
end