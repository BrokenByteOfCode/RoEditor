print("[RoEditor_DEBUG] Reached ID: 5")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local git = getgenv().RoEditor_Git
if not git then error("[RoEditor] Git library not found in global env!") end

local REPO = "BrokenByteOfCode/RoEditor"
local REF = "main"
local loadedModules = {}

local function fetchModule(path)
    print("[RoEditor_DEBUG] Reached ID: 6")
	local content, err = git.fetch(REPO, REF, path)
	if not content then
		loadedModules[path] = false
		return nil
	end
	local ok, result = pcall(function()
     print("[RoEditor_DEBUG] Reached ID: 7")
		local func, lerr = loadstring(content, "=" .. path)
		if not func then return error(lerr) end
		return func()
	end)
	if ok then
		loadedModules[path] = true
		return result
	end
	return nil
end

local fsModule = fetchModule("modules/filesystem.lua")
if fsModule then fsModule.init() end

local UI = fetchModule("modules/UI.lua")
local ui = fetchModule("initgui.lua")(UI)
local props = fetchModule("modules/Properties.lua")(UI)
local audioModule = fetchModule("modules/Audio.lua")(UI)
local actionsModule = fetchModule("modules/Actions.lua")(UI)
local viewportModule = fetchModule("modules/Viewport.lua")(UI)
local guiPreviewModule = fetchModule("modules/GuiPreview.lua")(UI)
local scriptViewerModule = fetchModule("modules/ScriptViewer.lua")(UI)
local inspectorModule = fetchModule("modules/Inspector.lua")
local clinkerModule = fetchModule("modules/Clinker.lua")(UI)
local monitorModule = fetchModule("modules/Monitor.lua")(UI)
local modelExportModule = fetchModule("modules/modelexport.lua")(UI)

local globalConnections = {}
local inspectorConnections = {}
local nodeMap = setmetatable({}, {__mode = "k"})

local function cleanInspector()
    print("[RoEditor_DEBUG] Reached ID: 8")
	for _, conn in ipairs(inspectorConnections) do if conn.Connected then conn:Disconnect() end end
	table.clear(inspectorConnections)
	for _, child in pairs(ui.inspectorFrame:GetChildren()) do
		if not child:IsA("UIListLayout") then child:Destroy() end
	end
end

local modelExportApi
if modelExportModule then
	modelExportApi = modelExportModule(ui.gui, globalConnections, fsModule)
	ui.exportBtn.MouseButton1Click:Connect(modelExportApi.toggle)
end

local function inspectObj(obj)
    print("[RoEditor_DEBUG] Reached ID: 9")
	inspectorModule(obj, ui, cleanInspector, inspectorConnections, props, audioModule, actionsModule, viewportModule, guiPreviewModule, scriptViewerModule, Players, RunService, modelExportApi)
end

local function createNode(obj, parentFrame, depth)
    print("[RoEditor_DEBUG] Reached ID: 10")
	local indent = depth * 15
	local expandBtn = UI("TextButton", { Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, indent, 0, 0), BackgroundColor3 = Color3.new(0.15, 0.15, 0.15), TextColor3 = Color3.new(0.8, 0.8, 0.8), Font = Enum.Font.Code, TextSize = 14, BorderSizePixel = 0 })
	local selectBtn = UI("TextButton", { Size = UDim2.new(1, -(indent + 20), 1, 0), Position = UDim2.new(0, indent + 20, 0, 0), BackgroundTransparency = 1, TextColor3 = Color3.new(0.9, 0.9, 0.9), TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.Code, TextSize = 12, Text = " " .. obj.Name })
	
	local childrenFrame = UI("Frame", { Name = "ChildrenFrame", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2, Visible = false, UI("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }) })
	local rowFrame = UI("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), LayoutOrder = 1, expandBtn, selectBtn })
	local nodeFrame = UI("Frame", { Name = "NodeFrame", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = parentFrame, UI("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }), rowFrame, childrenFrame })
	
	nodeMap[nodeFrame] = obj
	local populated = false
	local myConnections = {}

	table.insert(myConnections, nodeFrame.Destroying:Connect(function()
     print("[RoEditor_DEBUG] Reached ID: 11")
		for _, conn in ipairs(myConnections) do if conn.Connected then conn:Disconnect() end end
	end))

	table.insert(myConnections, obj:GetPropertyChangedSignal("Name"):Connect(function() selectBtn.Text = " " .. obj.Name end))
     print("[RoEditor_DEBUG] Reached ID: 12")

	local function updateIcon()
     print("[RoEditor_DEBUG] Reached ID: 13")
		expandBtn.Text = next(obj:GetChildren()) == nil and "-" or (childrenFrame.Visible and "v" or ">")
	end

	local function doPopulate()
     print("[RoEditor_DEBUG] Reached ID: 14")
		if populated then return end
		populated = true
		for _, child in ipairs(obj:GetChildren()) do createNode(child, childrenFrame, depth + 1) end
		table.insert(myConnections, obj.ChildAdded:Connect(function(child)
      print("[RoEditor_DEBUG] Reached ID: 15")
			createNode(child, childrenFrame, depth + 1)
			updateIcon()
		end))
		table.insert(myConnections, obj.ChildRemoved:Connect(function(child)
      print("[RoEditor_DEBUG] Reached ID: 16")
			for _, frame in ipairs(childrenFrame:GetChildren()) do
				if frame:IsA("Frame") and nodeMap[frame] == child then frame:Destroy() end
			end
			updateIcon()
		end))
	end

	updateIcon()

	expandBtn.MouseButton1Click:Connect(function()
     print("[RoEditor_DEBUG] Reached ID: 17")
		if next(obj:GetChildren()) == nil then return end
		doPopulate()
		childrenFrame.Visible = not childrenFrame.Visible
		updateIcon()
	end)

	selectBtn.MouseButton1Click:Connect(function() inspectObj(obj) end)
     print("[RoEditor_DEBUG] Reached ID: 18")
end

local function populate()
    print("[RoEditor_DEBUG] Reached ID: 19")
	for _, child in pairs(ui.explorerFrame:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	createNode(workspace, ui.explorerFrame, 0)
	createNode(Players, ui.explorerFrame, 0)
	createNode(game:GetService("Lighting"), ui.explorerFrame, 0)
	createNode(game:GetService("ReplicatedStorage"), ui.explorerFrame, 0)
end

ui.refreshBtn.MouseButton1Click:Connect(populate)

if clinkerModule then
	local toggleClinker = clinkerModule(ui.gui, globalConnections, RunService, fsModule)
	ui.clinkerBtn.MouseButton1Click:Connect(toggleClinker)
end

if monitorModule then
	local toggleMonitor = monitorModule(ui.gui, globalConnections, RunService)
	ui.monitorBtn.MouseButton1Click:Connect(toggleMonitor)
end

table.insert(globalConnections, ui.searchBar:GetPropertyChangedSignal("Text"):Connect(function()
    print("[RoEditor_DEBUG] Reached ID: 20")
	local q = string.lower(ui.searchBar.Text)
	if q == "" then
		for frame, _ in pairs(nodeMap) do frame.Visible = true end
		return
	end
	for frame, _ in pairs(nodeMap) do frame.Visible = false end
	for frame, obj in pairs(nodeMap) do
		if string.find(string.lower(obj.Name), q) or string.find(string.lower(obj.ClassName), q) then
			frame.Visible = true
			local cur = frame.Parent
			while cur and cur ~= ui.explorerFrame do
				if cur.Name == "ChildrenFrame" or cur.Name == "NodeFrame" then cur.Visible = true end
				cur = cur.Parent
			end
		end
	end
end))

table.insert(globalConnections, ui.killBtn.MouseButton1Click:Connect(function()
    print("[RoEditor_DEBUG] Reached ID: 21")
	for _, conn in ipairs(globalConnections) do if conn.Connected then conn:Disconnect() end end
	cleanInspector()
	ui.selectorHighlight:Destroy()
	ui.gui:Destroy()
end))

local isCollapsed = false
local expandedSize = UDim2.new(0, 600, 0, 400)

table.insert(globalConnections, ui.minBtn.MouseButton1Click:Connect(function()
    print("[RoEditor_DEBUG] Reached ID: 22")
	isCollapsed = not isCollapsed
	if isCollapsed then
		expandedSize = ui.mainFrame.Size
		ui.mainFrame.Size = UDim2.new(expandedSize.X.Scale, expandedSize.X.Offset, 0, 25)
		ui.minBtn.Text = "+"
		ui.resizeHandle.Visible = false
	else
		ui.mainFrame.Size = expandedSize
		ui.minBtn.Text = "-"
		ui.resizeHandle.Visible = true
	end
end))

local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
local resizing, resizeStartMouse, resizeStartSize = false, nil, nil

table.insert(globalConnections, ui.resizeHandle.InputBegan:Connect(function(input)
    print("[RoEditor_DEBUG] Reached ID: 23")
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		resizing = true
		resizeStartMouse = input.Position
		resizeStartSize = ui.mainFrame.AbsoluteSize
	end
end))

table.insert(globalConnections, ui.resizeHandle.InputEnded:Connect(function(input)
    print("[RoEditor_DEBUG] Reached ID: 24")
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then resizing = false end
end))

table.insert(globalConnections, ui.titleBar.InputBegan:Connect(function(input)
    print("[RoEditor_DEBUG] Reached ID: 25")
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = ui.mainFrame.Position
	end
end))

table.insert(globalConnections, ui.titleBar.InputEnded:Connect(function(input)
    print("[RoEditor_DEBUG] Reached ID: 26")
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end))

table.insert(globalConnections, UserInputService.InputChanged:Connect(function(input)
    print("[RoEditor_DEBUG] Reached ID: 27")
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end))

table.insert(globalConnections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
    print("[RoEditor_DEBUG] Reached ID: 28")
	if not gameProcessed and input.KeyCode == Enum.KeyCode.F3 then
		ui.gui.Enabled = not ui.gui.Enabled
		ui.selectorHighlight.Enabled = ui.gui.Enabled and ui.selectorHighlight.Adornee ~= nil
	end
end))

table.insert(globalConnections, RunService.RenderStepped:Connect(function()
    print("[RoEditor_DEBUG] Reached ID: 29")
	if dragInput then
		if dragging then
			local delta = dragInput.Position - dragStart
			ui.mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		elseif resizing then
			local delta = dragInput.Position - resizeStartMouse
			ui.mainFrame.Size = UDim2.new(0, math.max(400, resizeStartSize.X + delta.X), 0, math.max(300, resizeStartSize.Y + delta.Y))
		end
	end
end))

populate()