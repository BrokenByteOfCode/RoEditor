return function(obj, inspectorFrame, inspectorConnections, RunService)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 25)
	row.BackgroundTransparency = 1
	row.Parent = inspectorFrame

	local listLayout = Instance.new("UIListLayout")
	listLayout.FillDirection = Enum.FillDirection.Horizontal
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = row

	local playBtn = Instance.new("TextButton")
	playBtn.Size = UDim2.new(0.33, 0, 1, 0)
	playBtn.BackgroundColor3 = Color3.new(0.1, 0.4, 0.1)
	playBtn.TextColor3 = Color3.new(1, 1, 1)
	playBtn.Text = "Play"
	playBtn.Font = Enum.Font.Code
	playBtn.TextSize = 12
	playBtn.LayoutOrder = 1
	playBtn.Parent = row

	local pauseBtn = Instance.new("TextButton")
	pauseBtn.Size = UDim2.new(0.34, 0, 1, 0)
	pauseBtn.BackgroundColor3 = Color3.new(0.6, 0.6, 0.1)
	pauseBtn.TextColor3 = Color3.new(1, 1, 1)
	pauseBtn.Text = "Pause"
	pauseBtn.Font = Enum.Font.Code
	pauseBtn.TextSize = 12
	pauseBtn.LayoutOrder = 2
	pauseBtn.Parent = row

	local stopBtn = Instance.new("TextButton")
	stopBtn.Size = UDim2.new(0.33, 0, 1, 0)
	stopBtn.BackgroundColor3 = Color3.new(0.6, 0.1, 0.1)
	stopBtn.TextColor3 = Color3.new(1, 1, 1)
	stopBtn.Text = "Stop"
	stopBtn.Font = Enum.Font.Code
	stopBtn.TextSize = 12
	stopBtn.LayoutOrder = 3
	stopBtn.Parent = row

	playBtn.MouseButton1Click:Connect(function()
		pcall(function() obj:Play() end)
	end)
	pauseBtn.MouseButton1Click:Connect(function()
		pcall(function() obj:Pause() end)
	end)
	stopBtn.MouseButton1Click:Connect(function()
		pcall(function() obj:Stop() end)
	end)
	
	local infoRow = Instance.new("Frame")
	infoRow.Size = UDim2.new(1, 0, 0, 35)
	infoRow.BackgroundTransparency = 1
	infoRow.Parent = inspectorFrame
	
	local timeLabel = Instance.new("TextLabel")
	timeLabel.Size = UDim2.new(1, 0, 0, 15)
	timeLabel.BackgroundTransparency = 1
	timeLabel.TextColor3 = Color3.new(0.9, 0.9, 0.9)
	timeLabel.TextXAlignment = Enum.TextXAlignment.Center
	timeLabel.Font = Enum.Font.Code
	timeLabel.TextSize = 12
	timeLabel.Text = "Time: 00:00.0 / 00:00.0"
	timeLabel.Parent = infoRow
	
	local barBg = Instance.new("Frame")
	barBg.Size = UDim2.new(0.9, 0, 0, 10)
	barBg.Position = UDim2.new(0.05, 0, 0, 20)
	barBg.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
	barBg.BorderSizePixel = 0
	barBg.Parent = infoRow
	
	local barFill = Instance.new("Frame")
	barFill.Size = UDim2.new(0, 0, 1, 0)
	barFill.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
	barFill.BorderSizePixel = 0
	barFill.Parent = barBg
	
	table.insert(inspectorConnections, RunService.RenderStepped:Connect(function()
		if obj.Parent then
			local pos = obj.TimePosition
			local len = obj.TimeLength
			if obj.IsLoaded then
				local mins = math.floor(pos / 60)
				local secs = pos % 60
				local lMins = math.floor(len / 60)
				local lSecs = len % 60
				timeLabel.Text = string.format("Time: %02d:%04.1f / %02d:%04.1f", mins, secs, lMins, lSecs)
			else
				timeLabel.Text = "Loading Audio..."
			end
			local frac = 0
			if len > 0 then
				frac = math.clamp(pos / len, 0, 1)
			end
			barFill.Size = UDim2.new(frac, 0, 1, 0)
		end
	end))
end