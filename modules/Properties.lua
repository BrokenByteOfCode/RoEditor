return function(UI)
	local props = {}
	
	function props.createReadOnly(inspectorFrame, text)
		UI("TextLabel", { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, TextColor3 = Color3.new(0.9, 0.9, 0.9), TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.Code, TextSize = 12, Text = text, Parent = inspectorFrame })
	end

	local function createPropRow(inspectorFrame, propName, inputWidget)
		UI("Frame", { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Parent = inspectorFrame, UI("TextLabel", { Size = UDim2.new(0.4, 0, 1, 0), BackgroundTransparency = 1, TextColor3 = Color3.new(0.9, 0.9, 0.9), TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.Code, TextSize = 12, Text = " " .. propName .. ":" }), inputWidget })
	end

	function props.createEditableString(inspectorFrame, obj, propName)
		local box = UI("TextBox", { Size = UDim2.new(0.6, 0, 1, 0), Position = UDim2.new(0.4, 0, 0, 0), BackgroundColor3 = Color3.new(0.2, 0.2, 0.2), TextColor3 = Color3.new(1, 1, 0.5), Font = Enum.Font.Code, TextSize = 12, Text = tostring(obj[propName]), ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left })
		box.FocusLost:Connect(function() pcall(function() obj[propName] = box.Text end) box.Text = tostring(obj[propName]) end)
		createPropRow(inspectorFrame, propName, box)
	end

	function props.createEditableNumber(inspectorFrame, obj, propName)
		local box = UI("TextBox", { Size = UDim2.new(0.6, 0, 1, 0), Position = UDim2.new(0.4, 0, 0, 0), BackgroundColor3 = Color3.new(0.2, 0.2, 0.2), TextColor3 = Color3.new(1, 1, 0.5), Font = Enum.Font.Code, TextSize = 12, Text = tostring(obj[propName]), ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left })
		box.FocusLost:Connect(function() local val = tonumber(box.Text) if val then pcall(function() obj[propName] = val end) end box.Text = tostring(obj[propName]) end)
		createPropRow(inspectorFrame, propName, box)
	end

	function props.createEditableVector3(inspectorFrame, obj, propName)
		local box = UI("TextBox", { Size = UDim2.new(0.6, 0, 1, 0), Position = UDim2.new(0.4, 0, 0, 0), BackgroundColor3 = Color3.new(0.2, 0.2, 0.2), TextColor3 = Color3.new(1, 1, 0.5), Font = Enum.Font.Code, TextSize = 12, Text = tostring(obj[propName]), ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left })
		box.FocusLost:Connect(function() local parts = string.split(string.gsub(box.Text, " ", ""), ",") if parts[1] and parts[2] and parts[3] then local x, y, z = tonumber(parts[1]), tonumber(parts[2]), tonumber(parts[3]) if x and y and z then pcall(function() obj[propName] = Vector3.new(x, y, z) end) end end box.Text = tostring(obj[propName]) end)
		createPropRow(inspectorFrame, propName, box)
	end

	function props.createEditableColor3(inspectorFrame, obj, propName)
		local c = obj[propName]
		local box = UI("TextBox", { Size = UDim2.new(0.6, 0, 1, 0), Position = UDim2.new(0.4, 0, 0, 0), BackgroundColor3 = Color3.new(0.2, 0.2, 0.2), TextColor3 = Color3.new(1, 1, 0.5), Font = Enum.Font.Code, TextSize = 12, Text = typeof(c) == "Color3" and math.floor(c.R*255)..","..math.floor(c.G*255)..","..math.floor(c.B*255) or "", ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left })
		box.FocusLost:Connect(function() local parts = string.split(string.gsub(box.Text, " ", ""), ",") if parts[1] and parts[2] and parts[3] then local r, g, b = tonumber(parts[1]), tonumber(parts[2]), tonumber(parts[3]) if r and g and b then pcall(function() obj[propName] = Color3.fromRGB(r, g, b) end) end end local nc = obj[propName] box.Text = typeof(nc) == "Color3" and math.floor(nc.R*255)..","..math.floor(nc.G*255)..","..math.floor(nc.B*255) or "" end)
		createPropRow(inspectorFrame, propName, box)
	end

	function props.createEditableUDim2(inspectorFrame, obj, propName)
		local u = obj[propName]
		local box = UI("TextBox", { Size = UDim2.new(0.6, 0, 1, 0), Position = UDim2.new(0.4, 0, 0, 0), BackgroundColor3 = Color3.new(0.2, 0.2, 0.2), TextColor3 = Color3.new(1, 1, 0.5), Font = Enum.Font.Code, TextSize = 12, Text = typeof(u) == "UDim2" and u.X.Scale..","..u.X.Offset..","..u.Y.Scale..","..u.Y.Offset or "", ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left })
		box.FocusLost:Connect(function() local parts = string.split(string.gsub(box.Text, " ", ""), ",") if parts[1] and parts[2] and parts[3] and parts[4] then local xs, xo, ys, yo = tonumber(parts[1]), tonumber(parts[2]), tonumber(parts[3]), tonumber(parts[4]) if xs and xo and ys and yo then pcall(function() obj[propName] = UDim2.new(xs, xo, ys, yo) end) end end local nu = obj[propName] box.Text = typeof(nu) == "UDim2" and nu.X.Scale..","..nu.X.Offset..","..nu.Y.Scale..","..nu.Y.Offset or "" end)
		createPropRow(inspectorFrame, propName, box)
	end

	function props.createEditableBool(inspectorFrame, obj, propName)
		local btn = UI("TextButton", { Size = UDim2.new(0.2, 0, 1, 0), Position = UDim2.new(0.8, 0, 0, 0), BackgroundColor3 = Color3.new(0.2, 0.2, 0.2), TextColor3 = Color3.new(1, 1, 0.5), Font = Enum.Font.Code, TextSize = 12, Text = tostring(obj[propName]) })
		btn.MouseButton1Click:Connect(function() pcall(function() obj[propName] = not obj[propName] end) btn.Text = tostring(obj[propName]) end)
		UI("Frame", { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Parent = inspectorFrame, UI("TextLabel", { Size = UDim2.new(0.8, 0, 1, 0), BackgroundTransparency = 1, TextColor3 = Color3.new(0.9, 0.9, 0.9), TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.Code, TextSize = 12, Text = " " .. propName .. ":" }), btn })
	end

	return props
end