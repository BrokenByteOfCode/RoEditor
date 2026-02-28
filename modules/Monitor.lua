return function(UI)
	return function(mainGui, globalConnections, RunService)
		local Stats = game:GetService("Stats")
		local fpsLbl = UI("TextLabel", { Size = UDim2.new(1, -10, 0, 15), Position = UDim2.new(0, 5, 0, 25), BackgroundTransparency = 1, TextColor3 = Color3.new(0.8, 0.8, 0.8), Font = Enum.Font.Code, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left })
		local memLbl = UI("TextLabel", { Size = UDim2.new(1, -10, 0, 15), Position = UDim2.new(0, 5, 0, 45), BackgroundTransparency = 1, TextColor3 = Color3.new(0.8, 0.8, 0.8), Font = Enum.Font.Code, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left })
		local netLbl = UI("TextLabel", { Size = UDim2.new(1, -10, 0, 15), Position = UDim2.new(0, 5, 0, 65), BackgroundTransparency = 1, TextColor3 = Color3.new(0.8, 0.8, 0.8), Font = Enum.Font.Code, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left })
		local instLbl = UI("TextLabel", { Size = UDim2.new(1, -10, 0, 15), Position = UDim2.new(0, 5, 0, 85), BackgroundTransparency = 1, TextColor3 = Color3.new(0.8, 0.8, 0.8), Font = Enum.Font.Code, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left })
		
		local frame
		local closeBtn = UI("TextButton", { Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(1, -20, 0, 0), BackgroundTransparency = 1, TextColor3 = Color3.new(1, 1, 1), Text = "X", Font = Enum.Font.Code, Events = { MouseButton1Click = function() frame.Visible = false end } })
		local title = UI("TextLabel", { Size = UDim2.new(1, 0, 0, 20), BackgroundColor3 = Color3.new(0.2, 0.3, 0.5), TextColor3 = Color3.new(1, 1, 1), Text = " System Monitor", Font = Enum.Font.Code, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, closeBtn })
		
		frame = UI("Frame", { Name = "MonitorFrame", Size = UDim2.new(0, 200, 0, 110), Position = UDim2.new(0.5, -100, 0.5, 50), BackgroundColor3 = Color3.new(0.08, 0.08, 0.15), BorderSizePixel = 1, BorderColor3 = Color3.new(0.3, 0.3, 0.5), Visible = false, Parent = mainGui, title, fpsLbl, memLbl, netLbl, instLbl })

		local dragging, dragInput, dragStart, startPos
		title.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = input.Position startPos = frame.Position end end)
		title.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
		frame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)

		local lastUpdate = 0
		table.insert(globalConnections, RunService.RenderStepped:Connect(function(dt)
			if frame.Visible then
				if dragging and dragInput then frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + (dragInput.Position - dragStart).X, startPos.Y.Scale, startPos.Y.Offset + (dragInput.Position - dragStart).Y) end
				if tick() - lastUpdate > 0.5 then
					lastUpdate = tick()
					local mem, net = "Not work. Please forgive me.", "Not work. Please forgive me."
					pcall(function() mem = math.floor(Stats:GetTotalMemoryUsageMb()) end)
					pcall(function() net = math.floor(Stats.Network.DataReceiveKbps) end)
					fpsLbl.Text, memLbl.Text, netLbl.Text, instLbl.Text = "FPS: " .. math.floor(1 / dt) .. " (" .. math.floor(dt*1000) .. "ms)", "Memory: " .. mem .. " MB", "Net In: " .. net .. " KB/s", "WS Instances: " .. #workspace:GetDescendants()
				end
			end
		end))

		return function() frame.Visible = not frame.Visible if frame.Visible then frame.Parent = mainGui end end
	end
end