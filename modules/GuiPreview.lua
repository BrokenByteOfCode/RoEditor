return function(obj, inspectorFrame, inspectorConnections, RunService)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 0, 200)
	container.BackgroundColor3 = Color3.new(0.05, 0.05, 0.05)
	container.BorderSizePixel = 0
	container.ClipsDescendants = true
	container.Parent = inspectorFrame

	local helpLbl = Instance.new("TextLabel")
	helpLbl.Size = UDim2.new(1, 0, 0, 15)
	helpLbl.BackgroundTransparency = 1
	helpLbl.TextColor3 = Color3.new(0.7, 0.7, 0.7)
	helpLbl.Text = " UI Preview"
	helpLbl.TextXAlignment = Enum.TextXAlignment.Left
	helpLbl.Font = Enum.Font.Code
	helpLbl.TextSize = 10
	helpLbl.ZIndex = 10
	helpLbl.Parent = container

	local camera = workspace.CurrentCamera
	local vpSize = camera and camera.ViewportSize or Vector2.new(1920, 1080)

	local virtualScreen = Instance.new("Frame")
	virtualScreen.Name = "VirtualScreen"
	virtualScreen.Size = UDim2.new(0, vpSize.X, 0, vpSize.Y)
	virtualScreen.BackgroundTransparency = 1
	virtualScreen.Position = UDim2.new(0.5, 0, 0.5, 0)
	virtualScreen.AnchorPoint = Vector2.new(0.5, 0.5)
	virtualScreen.Parent = container

	local scale = Instance.new("UIScale")
	scale.Scale = 200 / math.max(1, vpSize.Y)
	scale.Parent = virtualScreen

	table.insert(inspectorConnections, container:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		if container.AbsoluteSize.X > 0 and vpSize.X > 0 then
			local scaleX = container.AbsoluteSize.X / vpSize.X
			local scaleY = 200 / vpSize.Y
			scale.Scale = math.min(scaleX, scaleY)
		end
	end))

	local oldArchivable = obj.Archivable
	obj.Archivable = true
	local clone = obj:Clone()
	obj.Archivable = oldArchivable

	if clone then
		if clone:IsA("ScreenGui") then
			for _, child in ipairs(clone:GetChildren()) do
				child.Parent = virtualScreen
			end
			clone:Destroy()
		elseif clone:IsA("GuiObject") then
			clone.Parent = virtualScreen
		else
			clone:Destroy()
		end
	end
end