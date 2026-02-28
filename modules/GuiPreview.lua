print("[RoEditor_DEBUG] Reached ID: 55")
return function(UI)
    print("[RoEditor_DEBUG] Reached ID: 56")
	return function(obj, inspectorFrame, inspectorConnections, RunService)
     print("[RoEditor_DEBUG] Reached ID: 57")
		local vpSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
		local scale = UI("UIScale", { Scale = 200 / math.max(1, vpSize.Y) })
		local virtualScreen = UI("Frame", { Name = "VirtualScreen", Size = UDim2.new(0, vpSize.X, 0, vpSize.Y), BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), scale })
		
		local container = UI("Frame", { Size = UDim2.new(1, 0, 0, 200), BackgroundColor3 = Color3.new(0.05, 0.05, 0.05), BorderSizePixel = 0, ClipsDescendants = true, Parent = inspectorFrame,
			UI("TextLabel", { Size = UDim2.new(1, 0, 0, 15), BackgroundTransparency = 1, TextColor3 = Color3.new(0.7, 0.7, 0.7), Text = " UI Preview", TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.Code, TextSize = 10, ZIndex = 10 }),
			virtualScreen
		})

		table.insert(inspectorConnections, container:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
      print("[RoEditor_DEBUG] Reached ID: 58")
			if container.AbsoluteSize.X > 0 and vpSize.X > 0 then scale.Scale = math.min(container.AbsoluteSize.X / vpSize.X, 200 / vpSize.Y) end
		end))

		local oldArchivable = obj.Archivable
		obj.Archivable = true
		local clone = obj:Clone()
		obj.Archivable = oldArchivable

		if clone then
			if clone:IsA("ScreenGui") then
				for _, child in ipairs(clone:GetChildren()) do child.Parent = virtualScreen end
				clone:Destroy()
			elseif clone:IsA("GuiObject") then
				clone.Parent = virtualScreen
			else
				clone:Destroy()
			end
		end
	end
end