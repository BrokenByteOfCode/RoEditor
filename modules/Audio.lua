return function(UI)
	return function(obj, inspectorFrame, inspectorConnections, RunService)
		UI("Frame", { Size = UDim2.new(1, 0, 0, 25), BackgroundTransparency = 1, Parent = inspectorFrame,
			UI("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder }),
			UI("TextButton", { Size = UDim2.new(0.33, 0, 1, 0), BackgroundColor3 = Color3.new(0.1, 0.4, 0.1), TextColor3 = Color3.new(1, 1, 1), Text = "Play", Font = Enum.Font.Code, TextSize = 12, LayoutOrder = 1, Events = { MouseButton1Click = function() pcall(function() obj:Play() end) end } }),
			UI("TextButton", { Size = UDim2.new(0.34, 0, 1, 0), BackgroundColor3 = Color3.new(0.6, 0.6, 0.1), TextColor3 = Color3.new(1, 1, 1), Text = "Pause", Font = Enum.Font.Code, TextSize = 12, LayoutOrder = 2, Events = { MouseButton1Click = function() pcall(function() obj:Pause() end) end } }),
			UI("TextButton", { Size = UDim2.new(0.33, 0, 1, 0), BackgroundColor3 = Color3.new(0.6, 0.1, 0.1), TextColor3 = Color3.new(1, 1, 1), Text = "Stop", Font = Enum.Font.Code, TextSize = 12, LayoutOrder = 3, Events = { MouseButton1Click = function() pcall(function() obj:Stop() end) end } })
		})

		local timeLabel = UI("TextLabel", { Size = UDim2.new(1, 0, 0, 15), BackgroundTransparency = 1, TextColor3 = Color3.new(0.9, 0.9, 0.9), TextXAlignment = Enum.TextXAlignment.Center, Font = Enum.Font.Code, TextSize = 12, Text = "Time: 00:00.0 / 00:00.0" })
		local barFill = UI("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Color3.new(0.2, 0.8, 0.2), BorderSizePixel = 0 })

		UI("Frame", { Size = UDim2.new(1, 0, 0, 35), BackgroundTransparency = 1, Parent = inspectorFrame,
			timeLabel,
			UI("Frame", { Size = UDim2.new(0.9, 0, 0, 10), Position = UDim2.new(0.05, 0, 0, 20), BackgroundColor3 = Color3.new(0.2, 0.2, 0.2), BorderSizePixel = 0, barFill })
		})

		table.insert(inspectorConnections, RunService.RenderStepped:Connect(function()
			if obj.Parent then
				local pos, len = obj.TimePosition, obj.TimeLength
				if obj.IsLoaded then
					timeLabel.Text = string.format("Time: %02d:%04.1f / %02d:%04.1f", math.floor(pos / 60), pos % 60, math.floor(len / 60), len % 60)
				else
					timeLabel.Text = "Loading Audio..."
				end
				barFill.Size = UDim2.new(len > 0 and math.clamp(pos / len, 0, 1) or 0, 0, 1, 0)
			end
		end))
	end
end