local props = {}

function props.createReadOnly(inspectorFrame, text)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 0, 20)
	lbl.BackgroundTransparency = 1
	lbl.TextColor3 = Color3.new(0.9, 0.9, 0.9)
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Font = Enum.Font.Code
	lbl.TextSize = 12
	lbl.Text = text
	lbl.Parent = inspectorFrame
end

function props.createEditableString(inspectorFrame, obj, propName)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 20)
	row.BackgroundTransparency = 1
	row.Parent = inspectorFrame

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.4, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.TextColor3 = Color3.new(0.9, 0.9, 0.9)
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Font = Enum.Font.Code
	lbl.TextSize = 12
	lbl.Text = " " .. propName .. ":"
	lbl.Parent = row

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(0.6, 0, 1, 0)
	box.Position = UDim2.new(0.4, 0, 0, 0)
	box.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
	box.TextColor3 = Color3.new(1, 1, 0.5)
	box.Font = Enum.Font.Code
	box.TextSize = 12
	box.Text = tostring(obj[propName])
	box.ClearTextOnFocus = false
	box.TextXAlignment = Enum.TextXAlignment.Left
	box.Parent = row

	box.FocusLost:Connect(function()
		pcall(function()
			obj[propName] = box.Text
		end)
		box.Text = tostring(obj[propName])
	end)
end

function props.createEditableNumber(inspectorFrame, obj, propName)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 20)
	row.BackgroundTransparency = 1
	row.Parent = inspectorFrame

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.4, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.TextColor3 = Color3.new(0.9, 0.9, 0.9)
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Font = Enum.Font.Code
	lbl.TextSize = 12
	lbl.Text = " " .. propName .. ":"
	lbl.Parent = row

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(0.6, 0, 1, 0)
	box.Position = UDim2.new(0.4, 0, 0, 0)
	box.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
	box.TextColor3 = Color3.new(1, 1, 0.5)
	box.Font = Enum.Font.Code
	box.TextSize = 12
	box.Text = tostring(obj[propName])
	box.ClearTextOnFocus = false
	box.TextXAlignment = Enum.TextXAlignment.Left
	box.Parent = row

	box.FocusLost:Connect(function()
		local val = tonumber(box.Text)
		if val then
			pcall(function()
				obj[propName] = val
			end)
		end
		box.Text = tostring(obj[propName])
	end)
end

function props.createEditableVector3(inspectorFrame, obj, propName)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 20)
	row.BackgroundTransparency = 1
	row.Parent = inspectorFrame

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.4, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.TextColor3 = Color3.new(0.9, 0.9, 0.9)
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Font = Enum.Font.Code
	lbl.TextSize = 12
	lbl.Text = " " .. propName .. ":"
	lbl.Parent = row

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(0.6, 0, 1, 0)
	box.Position = UDim2.new(0.4, 0, 0, 0)
	box.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
	box.TextColor3 = Color3.new(1, 1, 0.5)
	box.Font = Enum.Font.Code
	box.TextSize = 12
	box.Text = tostring(obj[propName])
	box.ClearTextOnFocus = false
	box.TextXAlignment = Enum.TextXAlignment.Left
	box.Parent = row

	box.FocusLost:Connect(function()
		local str = box.Text
		local parts = string.split(string.gsub(str, " ", ""), ",")
		if parts[1] and parts[2] and parts[3] then
			local x = tonumber(parts[1])
			local y = tonumber(parts[2])
			local z = tonumber(parts[3])
			if x and y and z then
				pcall(function()
					obj[propName] = Vector3.new(x, y, z)
				end)
			end
		end
		box.Text = tostring(obj[propName])
	end)
end

function props.createEditableColor3(inspectorFrame, obj, propName)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 20)
	row.BackgroundTransparency = 1
	row.Parent = inspectorFrame

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.4, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.TextColor3 = Color3.new(0.9, 0.9, 0.9)
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Font = Enum.Font.Code
	lbl.TextSize = 12
	lbl.Text = " " .. propName .. ":"
	lbl.Parent = row

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(0.6, 0, 1, 0)
	box.Position = UDim2.new(0.4, 0, 0, 0)
	box.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
	box.TextColor3 = Color3.new(1, 1, 0.5)
	box.Font = Enum.Font.Code
	box.TextSize = 12
	local c = obj[propName]
	if typeof(c) == "Color3" then
		box.Text = math.floor(c.R * 255) .. "," .. math.floor(c.G * 255) .. "," .. math.floor(c.B * 255)
	end
	box.ClearTextOnFocus = false
	box.TextXAlignment = Enum.TextXAlignment.Left
	box.Parent = row

	box.FocusLost:Connect(function()
		local parts = string.split(string.gsub(box.Text, " ", ""), ",")
		if parts[1] and parts[2] and parts[3] then
			local r = tonumber(parts[1])
			local g = tonumber(parts[2])
			local b = tonumber(parts[3])
			if r and g and b then
				pcall(function()
					obj[propName] = Color3.fromRGB(r, g, b)
				end)
			end
		end
		local nc = obj[propName]
		if typeof(nc) == "Color3" then
			box.Text = math.floor(nc.R * 255) .. "," .. math.floor(nc.G * 255) .. "," .. math.floor(nc.B * 255)
		end
	end)
end

function props.createEditableUDim2(inspectorFrame, obj, propName)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 20)
	row.BackgroundTransparency = 1
	row.Parent = inspectorFrame

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.4, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.TextColor3 = Color3.new(0.9, 0.9, 0.9)
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Font = Enum.Font.Code
	lbl.TextSize = 12
	lbl.Text = " " .. propName .. ":"
	lbl.Parent = row

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(0.6, 0, 1, 0)
	box.Position = UDim2.new(0.4, 0, 0, 0)
	box.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
	box.TextColor3 = Color3.new(1, 1, 0.5)
	box.Font = Enum.Font.Code
	box.TextSize = 12
	local u = obj[propName]
	if typeof(u) == "UDim2" then
		box.Text = u.X.Scale .. "," .. u.X.Offset .. "," .. u.Y.Scale .. "," .. u.Y.Offset
	end
	box.ClearTextOnFocus = false
	box.TextXAlignment = Enum.TextXAlignment.Left
	box.Parent = row

	box.FocusLost:Connect(function()
		local parts = string.split(string.gsub(box.Text, " ", ""), ",")
		if parts[1] and parts[2] and parts[3] and parts[4] then
			local xs = tonumber(parts[1])
			local xo = tonumber(parts[2])
			local ys = tonumber(parts[3])
			local yo = tonumber(parts[4])
			if xs and xo and ys and yo then
				pcall(function()
					obj[propName] = UDim2.new(xs, xo, ys, yo)
				end)
			end
		end
		local nu = obj[propName]
		if typeof(nu) == "UDim2" then
			box.Text = nu.X.Scale .. "," .. nu.X.Offset .. "," .. nu.Y.Scale .. "," .. nu.Y.Offset
		end
	end)
end

function props.createEditableBool(inspectorFrame, obj, propName)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 20)
	row.BackgroundTransparency = 1
	row.Parent = inspectorFrame

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.8, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.TextColor3 = Color3.new(0.9, 0.9, 0.9)
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Font = Enum.Font.Code
	lbl.TextSize = 12
	lbl.Text = " " .. propName .. ":"
	lbl.Parent = row

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.2, 0, 1, 0)
	btn.Position = UDim2.new(0.8, 0, 0, 0)
	btn.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
	btn.TextColor3 = Color3.new(1, 1, 0.5)
	btn.Font = Enum.Font.Code
	btn.TextSize = 12
	btn.Text = tostring(obj[propName])
	btn.Parent = row

	btn.MouseButton1Click:Connect(function()
		pcall(function()
			obj[propName] = not obj[propName]
		end)
		btn.Text = tostring(obj[propName])
	end)
end

return props