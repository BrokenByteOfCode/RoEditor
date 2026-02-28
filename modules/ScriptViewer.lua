print("[RoEditor_DEBUG] Reached ID: 77")
return function(UI)
    print("[RoEditor_DEBUG] Reached ID: 78")
	return function(obj, inspectorFrame, inspectorConnections, RunService)
     print("[RoEditor_DEBUG] Reached ID: 79")
		local codeLbl = UI("TextLabel", { Size = UDim2.new(0, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.XY, BackgroundTransparency = 1, TextColor3 = Color3.new(0.9, 0.9, 0.9), TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Font = Enum.Font.Code, TextSize = 12 })
		local codeContainer = UI("Frame", { Size = UDim2.new(1, 0, 0, 300), BackgroundColor3 = Color3.new(0.05, 0.05, 0.05), BorderSizePixel = 0, Visible = false, Parent = inspectorFrame, UI("ScrollingFrame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, AutomaticCanvasSize = Enum.AutomaticSize.XY, CanvasSize = UDim2.new(0, 0, 0, 0), ScrollBarThickness = 6, codeLbl }) })
		
		local cachedCode = nil
		local function getCode()
      print("[RoEditor_DEBUG] Reached ID: 80")
			if cachedCode then return cachedCode end
			if type(decompile) == "function" then
				local success, result = pcall(decompile, obj)
				cachedCode = (success and type(result) == "string") and result or "Error decompiling:\n" .. tostring(result)
			else
				cachedCode = "Executor does not support 'decompile' function."
			end
			return cachedCode
		end

		local viewBtn
		viewBtn = UI("TextButton", { Size = UDim2.new(0.5, 0, 1, 0), BackgroundColor3 = Color3.new(0.2, 0.4, 0.6), TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.Code, TextSize = 12, Text = "Decompile", BorderSizePixel = 1, BorderColor3 = Color3.new(0.1, 0.1, 0.1), Events = { MouseButton1Click = function()
      print("[RoEditor_DEBUG] Reached ID: 81")
			codeContainer.Visible = not codeContainer.Visible
			if codeContainer.Visible then
				viewBtn.Text = "Hide Code"
				codeLbl.Text = "Decompiling..."
				task.spawn(function()
        print("[RoEditor_DEBUG] Reached ID: 82")
					codeLbl.RichText = false
					codeLbl.Text = getCode()
				end)
			else
				viewBtn.Text = "Decompile"
			end
		end } })

		local copyBtn
		copyBtn = UI("TextButton", { Size = UDim2.new(0.5, 0, 1, 0), BackgroundColor3 = Color3.new(0.2, 0.6, 0.2), TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.Code, TextSize = 12, Text = "Copy Code", BorderSizePixel = 1, BorderColor3 = Color3.new(0.1, 0.1, 0.1), Events = { MouseButton1Click = function()
      print("[RoEditor_DEBUG] Reached ID: 83")
			if setclipboard then
				setclipboard(getCode())
				local oldText = copyBtn.Text
				copyBtn.Text = "Copied!"
				task.wait(1)
				copyBtn.Text = oldText
			end
		end } })

		UI("Frame", { Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Parent = inspectorFrame, UI("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder }), viewBtn, copyBtn })
	end
end