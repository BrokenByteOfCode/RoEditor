return function(obj, inspectorFrame, inspectorConnections, RunService)
	local vpContainer = Instance.new("Frame")
	vpContainer.Size = UDim2.new(1, 0, 0, 200)
	vpContainer.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
	vpContainer.BorderSizePixel = 0
	vpContainer.Active = true
	vpContainer.Parent = inspectorFrame

	local vpFrame = Instance.new("ViewportFrame")
	vpFrame.Size = UDim2.new(1, 0, 1, -25)
	vpFrame.BackgroundColor3 = Color3.new(0.05, 0.05, 0.05)
	vpFrame.BorderSizePixel = 0
	vpFrame.Ambient = Color3.new(1, 1, 1)
	vpFrame.LightColor = Color3.new(1, 1, 1)
	vpFrame.Parent = vpContainer
	
	local helpLbl = Instance.new("TextLabel")
	helpLbl.Size = UDim2.new(1, 0, 0, 15)
	helpLbl.BackgroundTransparency = 1
	helpLbl.TextColor3 = Color3.new(0.7, 0.7, 0.7)
	helpLbl.Text = " L-Drag: Orbit | R/M-Drag: Pan | Scroll: Zoom"
	helpLbl.TextXAlignment = Enum.TextXAlignment.Left
	helpLbl.Font = Enum.Font.Code
	helpLbl.TextSize = 10
	helpLbl.Parent = vpContainer

	local spinBtn = Instance.new("TextButton")
	spinBtn.Size = UDim2.new(1, 0, 0, 25)
	spinBtn.Position = UDim2.new(0, 0, 1, -25)
	spinBtn.BackgroundColor3 = Color3.new(0.2, 0.2, 0.25)
	spinBtn.TextColor3 = Color3.new(1, 1, 1)
	spinBtn.Font = Enum.Font.Code
	spinBtn.TextSize = 12
	spinBtn.Text = "Toggle Spin: OFF"
	spinBtn.BorderSizePixel = 0
	spinBtn.Parent = vpContainer

	local oldArchivable = obj.Archivable
	obj.Archivable = true
	local clone = obj:Clone()
	obj.Archivable = oldArchivable

	if clone then
		clone.Parent = vpFrame
		local cam = Instance.new("Camera")
		cam.CameraType = Enum.CameraType.Scriptable
		
		local cf, size
		if clone:IsA("Model") then
			cf, size = clone:GetBoundingBox()
		else
			cf = clone.CFrame
			size = clone.Size
		end
		
		local radius = size.Magnitude / 2
		if radius == 0 then radius = 1 end
		local fov = math.rad(cam.FieldOfView)
		local distance = (radius / math.tan(fov / 2)) * 1.2
		local camFocus = cf.Position
		local camAngles = Vector2.new(math.rad(45), -math.rad(20))
		
		local function updateCamera()
			cam.CFrame = CFrame.new(camFocus) * CFrame.Angles(0, camAngles.X, 0) * CFrame.Angles(camAngles.Y, 0, 0) * CFrame.new(0, 0, distance)
		end
		
		updateCamera()
		vpFrame.CurrentCamera = cam
		cam.Parent = vpFrame

		local isSpinning = false
		local isOrbiting = false
		local isPanning = false
		local lastPos = Vector2.new()

		spinBtn.MouseButton1Click:Connect(function()
			isSpinning = not isSpinning
			spinBtn.Text = "Toggle Spin: " .. (isSpinning and "ON" or "OFF")
			spinBtn.BackgroundColor3 = isSpinning and Color3.new(0.1, 0.4, 0.1) or Color3.new(0.2, 0.2, 0.25)
		end)

		table.insert(inspectorConnections, vpContainer.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				isOrbiting = true
				lastPos = Vector2.new(input.Position.X, input.Position.Y)
			elseif input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 then
				isPanning = true
				lastPos = Vector2.new(input.Position.X, input.Position.Y)
			end
		end))

		table.insert(inspectorConnections, vpContainer.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				isOrbiting = false
			elseif input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 then
				isPanning = false
			end
		end))

		table.insert(inspectorConnections, vpContainer.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseWheel then
				distance = math.clamp(distance - input.Position.Z * (distance * 0.1), 0.1, 10000)
				updateCamera()
			elseif input.UserInputType == Enum.UserInputType.MouseMovement then
				local currPos = Vector2.new(input.Position.X, input.Position.Y)
				local delta = currPos - lastPos
				lastPos = currPos
				
				if isOrbiting then
					camAngles = Vector2.new(camAngles.X - math.rad(delta.X * 0.5), math.clamp(camAngles.Y - math.rad(delta.Y * 0.5), -math.pi / 2.1, math.pi / 2.1))
					updateCamera()
				elseif isPanning then
					local right = cam.CFrame.RightVector
					local up = cam.CFrame.UpVector
					local panSpeed = distance * 0.002
					camFocus = camFocus - (right * delta.X * panSpeed) + (up * delta.Y * panSpeed)
					updateCamera()
				end
			end
		end))

		table.insert(inspectorConnections, RunService.RenderStepped:Connect(function(dt)
			if not vpContainer.Parent then return end
			if isSpinning then
				camAngles = Vector2.new(camAngles.X + math.rad(45) * dt, camAngles.Y)
				updateCamera()
			end
		end))
	end
end