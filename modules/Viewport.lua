print("[RoEditor_DEBUG] Reached ID: 84")
return function(UI)
    print("[RoEditor_DEBUG] Reached ID: 85")
	return function(obj, inspectorFrame, inspectorConnections, RunService)
     print("[RoEditor_DEBUG] Reached ID: 86")
		local vpFrame = UI("ViewportFrame", { Size = UDim2.new(1, 0, 1, -25), BackgroundColor3 = Color3.new(0.05, 0.05, 0.05), BorderSizePixel = 0, Ambient = Color3.new(1, 1, 1), LightColor = Color3.new(1, 1, 1) })
		
		local spinBtn = UI("TextButton", { Size = UDim2.new(1, 0, 0, 25), Position = UDim2.new(0, 0, 1, -25), BackgroundColor3 = Color3.new(0.2, 0.2, 0.25), TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.Code, TextSize = 12, Text = "Toggle Spin: OFF", BorderSizePixel = 0 })
		local vpContainer = UI("Frame", { Size = UDim2.new(1, 0, 0, 200), BackgroundColor3 = Color3.new(0.1, 0.1, 0.1), BorderSizePixel = 0, Active = true, Parent = inspectorFrame, vpFrame, UI("TextLabel", { Size = UDim2.new(1, 0, 0, 15), BackgroundTransparency = 1, TextColor3 = Color3.new(0.7, 0.7, 0.7), Text = " L-Drag: Orbit | R/M-Drag: Pan | Scroll: Zoom", TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.Code, TextSize = 10 }), spinBtn })

		local clone = obj.Archivable and obj:Clone() or (function() obj.Archivable = true local c = obj:Clone() obj.Archivable = false return c end)()
      print("[RoEditor_DEBUG] Reached ID: 87")

		if clone then
			clone.Parent = vpFrame
			local cam = Instance.new("Camera")
			cam.CameraType = Enum.CameraType.Scriptable
			
			local cf, size = clone:IsA("Model") and clone:GetBoundingBox() or (clone.CFrame), clone:IsA("Model") and select(2, clone:GetBoundingBox()) or clone.Size
			local distance = (math.max(size.Magnitude / 2, 1) / math.tan(math.rad(cam.FieldOfView) / 2)) * 1.2
			local camFocus, camAngles = cf.Position, Vector2.new(math.rad(45), -math.rad(20))
			
			local function updateCamera() cam.CFrame = CFrame.new(camFocus) * CFrame.Angles(0, camAngles.X, 0) * CFrame.Angles(camAngles.Y, 0, 0) * CFrame.new(0, 0, distance) end
			updateCamera()
			vpFrame.CurrentCamera = cam
			cam.Parent = vpFrame

			local isSpinning, isOrbiting, isPanning, lastPos = false, false, false, Vector2.new()

			spinBtn.MouseButton1Click:Connect(function()
       print("[RoEditor_DEBUG] Reached ID: 88")
				isSpinning = not isSpinning
				spinBtn.Text = "Toggle Spin: " .. (isSpinning and "ON" or "OFF")
				spinBtn.BackgroundColor3 = isSpinning and Color3.new(0.1, 0.4, 0.1) or Color3.new(0.2, 0.2, 0.25)
			end)

			table.insert(inspectorConnections, vpContainer.InputBegan:Connect(function(input)
       print("[RoEditor_DEBUG] Reached ID: 89")
				if input.UserInputType == Enum.UserInputType.MouseButton1 then isOrbiting = true lastPos = Vector2.new(input.Position.X, input.Position.Y)
				elseif input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 then isPanning = true lastPos = Vector2.new(input.Position.X, input.Position.Y) end
			end))

			table.insert(inspectorConnections, vpContainer.InputEnded:Connect(function(input)
       print("[RoEditor_DEBUG] Reached ID: 90")
				if input.UserInputType == Enum.UserInputType.MouseButton1 then isOrbiting = false
				elseif input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 then isPanning = false end
			end))

			table.insert(inspectorConnections, vpContainer.InputChanged:Connect(function(input)
       print("[RoEditor_DEBUG] Reached ID: 91")
				if input.UserInputType == Enum.UserInputType.MouseWheel then
					distance = math.clamp(distance - input.Position.Z * (distance * 0.1), 0.1, 10000)
					updateCamera()
				elseif input.UserInputType == Enum.UserInputType.MouseMovement then
					local currPos = Vector2.new(input.Position.X, input.Position.Y)
					local delta = currPos - lastPos
					lastPos = currPos
					if isOrbiting then
						camAngles = Vector2.new(camAngles.X - math.rad(delta.X * 0.5), math.clamp(camAngles.Y - math.rad(delta.Y * 0.5), -math.pi / 2.1, math.pi / 2.1))
					elseif isPanning then
						camFocus = camFocus - (cam.CFrame.RightVector * delta.X * distance * 0.002) + (cam.CFrame.UpVector * delta.Y * distance * 0.002)
					end
					updateCamera()
				end
			end))

			table.insert(inspectorConnections, RunService.RenderStepped:Connect(function(dt)
       print("[RoEditor_DEBUG] Reached ID: 92")
				if vpContainer.Parent and isSpinning then
					camAngles = Vector2.new(camAngles.X + math.rad(45) * dt, camAngles.Y)
					updateCamera()
				end
			end))
		end
	end
end