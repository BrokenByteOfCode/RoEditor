return function(obj, ui, cleanInspector, inspectorConnections, props, audioModule, actionsModule, viewportModule, guiPreviewModule, scriptViewerModule, Players, RunService)
	cleanInspector()
	
	if obj:IsA("BasePart") or obj:IsA("Model") then
		ui.selectorHighlight.Adornee = obj
		ui.selectorHighlight.Enabled = true
		viewportModule(obj, ui.inspectorFrame, inspectorConnections, RunService)
	elseif obj:IsA("GuiObject") or obj:IsA("ScreenGui") then
		ui.selectorHighlight.Enabled = false
		guiPreviewModule(obj, ui.inspectorFrame, inspectorConnections, RunService)
	elseif obj:IsA("LuaSourceContainer") then
		ui.selectorHighlight.Enabled = false
		scriptViewerModule(obj, ui.inspectorFrame, inspectorConnections, RunService)
	else
		ui.selectorHighlight.Enabled = false
	end
	
	actionsModule(obj, ui.inspectorFrame, cleanInspector, ui.selectorHighlight, props.createReadOnly, Players)
	props.createEditableString(ui.inspectorFrame, obj, "Name")
	props.createReadOnly(ui.inspectorFrame, " Class: " .. obj.ClassName)
	props.createReadOnly(ui.inspectorFrame, " Parent: " .. (obj.Parent and obj.Parent.Name or "None"))
	
	if obj:IsA("BasePart") then
		props.createEditableVector3(ui.inspectorFrame, obj, "Position")
		props.createEditableVector3(ui.inspectorFrame, obj, "Size")
		props.createEditableColor3(ui.inspectorFrame, obj, "Color")
		props.createEditableNumber(ui.inspectorFrame, obj, "Transparency")
		props.createEditableNumber(ui.inspectorFrame, obj, "Reflectance")
		props.createEditableBool(ui.inspectorFrame, obj, "Anchored")
		props.createEditableBool(ui.inspectorFrame, obj, "CanCollide")
		props.createEditableBool(ui.inspectorFrame, obj, "CastShadow")
	elseif obj:IsA("Humanoid") then
		props.createEditableNumber(ui.inspectorFrame, obj, "Health")
		props.createEditableNumber(ui.inspectorFrame, obj, "MaxHealth")
		props.createEditableNumber(ui.inspectorFrame, obj, "WalkSpeed")
		props.createEditableNumber(ui.inspectorFrame, obj, "JumpPower")
		props.createEditableNumber(ui.inspectorFrame, obj, "JumpHeight")
		props.createEditableBool(ui.inspectorFrame, obj, "UseJumpPower")
		props.createEditableBool(ui.inspectorFrame, obj, "AutoRotate")
		props.createEditableBool(ui.inspectorFrame, obj, "PlatformStand")
		props.createEditableBool(ui.inspectorFrame, obj, "Sit")
		props.createEditableString(ui.inspectorFrame, obj, "DisplayName")
	elseif obj:IsA("ScreenGui") then
		props.createEditableBool(ui.inspectorFrame, obj, "Enabled")
		props.createEditableBool(ui.inspectorFrame, obj, "ResetOnSpawn")
		props.createEditableBool(ui.inspectorFrame, obj, "IgnoreGuiInset")
		props.createEditableNumber(ui.inspectorFrame, obj, "DisplayOrder")
	elseif obj:IsA("GuiObject") then
		props.createEditableUDim2(ui.inspectorFrame, obj, "Position")
		props.createEditableUDim2(ui.inspectorFrame, obj, "Size")
		props.createEditableBool(ui.inspectorFrame, obj, "Visible")
		props.createEditableNumber(ui.inspectorFrame, obj, "BackgroundTransparency")
		if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
			props.createEditableString(ui.inspectorFrame, obj, "Text")
			props.createEditableColor3(ui.inspectorFrame, obj, "TextColor3")
		elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
			props.createEditableString(ui.inspectorFrame, obj, "Image")
			props.createEditableColor3(ui.inspectorFrame, obj, "ImageColor3")
			props.createEditableNumber(ui.inspectorFrame, obj, "ImageTransparency")
		end
	elseif obj:IsA("Decal") or obj:IsA("Texture") then
		props.createEditableString(ui.inspectorFrame, obj, "Texture")
		props.createEditableColor3(ui.inspectorFrame, obj, "Color3")
		props.createEditableNumber(ui.inspectorFrame, obj, "Transparency")
		if obj:IsA("Texture") then
			props.createEditableNumber(ui.inspectorFrame, obj, "StudsPerTileU")
			props.createEditableNumber(ui.inspectorFrame, obj, "StudsPerTileV")
		end
	elseif obj:IsA("Light") then
		props.createEditableNumber(ui.inspectorFrame, obj, "Range")
		props.createEditableNumber(ui.inspectorFrame, obj, "Brightness")
		props.createEditableColor3(ui.inspectorFrame, obj, "Color")
		props.createEditableBool(ui.inspectorFrame, obj, "Shadows")
	elseif obj:IsA("Sound") then
		audioModule(obj, ui.inspectorFrame, inspectorConnections, RunService)
		props.createEditableString(ui.inspectorFrame, obj, "SoundId")
		props.createEditableBool(ui.inspectorFrame, obj, "Playing")
		props.createEditableBool(ui.inspectorFrame, obj, "Looped")
		props.createEditableNumber(ui.inspectorFrame, obj, "Volume")
		props.createEditableNumber(ui.inspectorFrame, obj, "PlaybackSpeed")
		props.createEditableNumber(ui.inspectorFrame, obj, "TimePosition")
	elseif obj:IsA("LuaSourceContainer") then
		if obj:IsA("Script") or obj:IsA("LocalScript") then
			props.createEditableBool(ui.inspectorFrame, obj, "Disabled")
		end
	elseif obj:IsA("Lighting") then
		props.createEditableColor3(ui.inspectorFrame, obj, "Ambient")
		props.createEditableColor3(ui.inspectorFrame, obj, "OutdoorAmbient")
		props.createEditableNumber(ui.inspectorFrame, obj, "Brightness")
		props.createEditableColor3(ui.inspectorFrame, obj, "ColorShift_Bottom")
		props.createEditableColor3(ui.inspectorFrame, obj, "ColorShift_Top")
		props.createEditableNumber(ui.inspectorFrame, obj, "EnvironmentDiffuseScale")
		props.createEditableNumber(ui.inspectorFrame, obj, "EnvironmentSpecularScale")
		props.createEditableBool(ui.inspectorFrame, obj, "GlobalShadows")
		props.createEditableNumber(ui.inspectorFrame, obj, "ClockTime")
		props.createEditableString(ui.inspectorFrame, obj, "TimeOfDay")
		props.createEditableNumber(ui.inspectorFrame, obj, "GeographicLatitude")
	elseif obj:IsA("Atmosphere") then
		props.createEditableNumber(ui.inspectorFrame, obj, "Density")
		props.createEditableNumber(ui.inspectorFrame, obj, "Offset")
		props.createEditableColor3(ui.inspectorFrame, obj, "Color")
		props.createEditableColor3(ui.inspectorFrame, obj, "Decay")
		props.createEditableNumber(ui.inspectorFrame, obj, "Glare")
		props.createEditableNumber(ui.inspectorFrame, obj, "Haze")
	elseif obj:IsA("Sky") then
		props.createEditableBool(ui.inspectorFrame, obj, "CelestialBodiesShown")
		props.createEditableNumber(ui.inspectorFrame, obj, "StarCount")
		props.createEditableString(ui.inspectorFrame, obj, "SkyboxBk")
		props.createEditableString(ui.inspectorFrame, obj, "SkyboxDn")
		props.createEditableString(ui.inspectorFrame, obj, "SkyboxFt")
		props.createEditableString(ui.inspectorFrame, obj, "SkyboxLf")
		props.createEditableString(ui.inspectorFrame, obj, "SkyboxRt")
		props.createEditableString(ui.inspectorFrame, obj, "SkyboxUp")
		props.createEditableString(ui.inspectorFrame, obj, "SunTextureId")
		props.createEditableString(ui.inspectorFrame, obj, "MoonTextureId")
	elseif obj:IsA("BloomEffect") then
		props.createEditableNumber(ui.inspectorFrame, obj, "Intensity")
		props.createEditableNumber(ui.inspectorFrame, obj, "Size")
		props.createEditableNumber(ui.inspectorFrame, obj, "Threshold")
		props.createEditableBool(ui.inspectorFrame, obj, "Enabled")
	elseif obj:IsA("BlurEffect") then
		props.createEditableNumber(ui.inspectorFrame, obj, "Size")
		props.createEditableBool(ui.inspectorFrame, obj, "Enabled")
	elseif obj:IsA("ColorCorrectionEffect") then
		props.createEditableNumber(ui.inspectorFrame, obj, "Brightness")
		props.createEditableNumber(ui.inspectorFrame, obj, "Contrast")
		props.createEditableNumber(ui.inspectorFrame, obj, "Saturation")
		props.createEditableColor3(ui.inspectorFrame, obj, "TintColor")
		props.createEditableBool(ui.inspectorFrame, obj, "Enabled")
	elseif obj:IsA("SunRaysEffect") then
		props.createEditableNumber(ui.inspectorFrame, obj, "Intensity")
		props.createEditableNumber(ui.inspectorFrame, obj, "Spread")
		props.createEditableBool(ui.inspectorFrame, obj, "Enabled")
	elseif obj:IsA("StringValue") then
		props.createEditableString(ui.inspectorFrame, obj, "Value")
	elseif obj:IsA("IntValue") or obj:IsA("NumberValue") then
		props.createEditableNumber(ui.inspectorFrame, obj, "Value")
	elseif obj:IsA("BoolValue") then
		props.createEditableBool(ui.inspectorFrame, obj, "Value")
	elseif obj:IsA("Color3Value") then
		props.createEditableColor3(ui.inspectorFrame, obj, "Value")
	elseif obj:IsA("Vector3Value") then
		props.createEditableVector3(ui.inspectorFrame, obj, "Value")
	elseif obj:IsA("ParticleEmitter") then
		props.createEditableBool(ui.inspectorFrame, obj, "Enabled")
		props.createEditableString(ui.inspectorFrame, obj, "Texture")
		props.createEditableNumber(ui.inspectorFrame, obj, "ZOffset")
		props.createEditableNumber(ui.inspectorFrame, obj, "Rate")
		props.createEditableNumber(ui.inspectorFrame, obj, "VelocityInheritance")
		props.createEditableNumber(ui.inspectorFrame, obj, "LightEmission")
		props.createEditableNumber(ui.inspectorFrame, obj, "LightInfluence")
		props.createEditableNumber(ui.inspectorFrame, obj, "TimeScale")
	elseif obj:IsA("RemoteEvent") then
		props.createReadOnly(ui.inspectorFrame, " [RemoteEvent]")
	elseif obj:IsA("RemoteFunction") then
		props.createReadOnly(ui.inspectorFrame, " [RemoteFunction]")
	elseif obj:IsA("Camera") then
		props.createEditableNumber(ui.inspectorFrame, obj, "FieldOfView")
		props.createEditableNumber(ui.inspectorFrame, obj, "DiagonalFieldOfView")
		props.createEditableNumber(ui.inspectorFrame, obj, "MaxAxisFieldOfView")
	end
end