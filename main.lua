local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local git = getgenv().RoEditor_Git
if not git then error("[RoEditor] Git library not found in global env!") end
print("[RoEditor] git library found")

local REPO = "BrokenByteOfCode/RoEditor"
local REF = "main"

local loaderGui = Instance.new("ScreenGui")
loaderGui.Name = "RoEditorLoader"
loaderGui.DisplayOrder = 1000000
loaderGui.Parent = (type(gethui) == "function") and gethui() or CoreGui

local loadFrame = Instance.new("Frame")
loadFrame.Size = UDim2.new(0, 300, 0, 100)
loadFrame.Position = UDim2.new(0.5, -150, 0.5, -50)
loadFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
loadFrame.BorderSizePixel = 0
loadFrame.Parent = loaderGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = loadFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 0, 15)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.Text = "Initializing..."
statusLabel.Font = Enum.Font.Code
statusLabel.TextSize = 14
statusLabel.Parent = loadFrame

local barBg = Instance.new("Frame")
barBg.Size = UDim2.new(1, -40, 0, 10)
barBg.Position = UDim2.new(0, 20, 0, 60)
barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
barBg.BorderSizePixel = 0
barBg.Parent = loadFrame

local barFill = Instance.new("Frame")
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
barFill.BorderSizePixel = 0
barFill.Parent = barBg

local function updateProgress(text, frac)
	statusLabel.Text = text
	barFill.Size = UDim2.new(frac, 0, 1, 0)
end

local loadedModules = {}
local function fetchModule(path)
	print("[RoEditor] fetching module: " .. path)
	local content, err = git.fetch(REPO, REF, path)
	if not content then
		print("[RoEditor] failed to fetch module " .. path .. ": " .. tostring(err))
		return nil
	end
	local func, lerr = loadstring(content, "=" .. path)
	if not func then
		print("[RoEditor] compile error in module " .. path .. ": " .. tostring(lerr))
		return nil
	end
	print("[RoEditor] loaded module: " .. path)
	return func()
end

local modulesToLoad = {
	{id = "fs", path = "modules/filesystem.lua"},
	{id = "UI", path = "modules/UI.lua"},
	{id = "initgui", path = "initgui.lua"},
	{id = "props", path = "modules/Properties.lua"},
	{id = "audio", path = "modules/Audio.lua"},
	{id = "actions", path = "modules/Actions.lua"},
	{id = "viewport", path = "modules/Viewport.lua"},
	{id = "guiprev", path = "modules/GuiPreview.lua"},
	{id = "script", path = "modules/ScriptViewer.lua"},
	{id = "inspector", path = "modules/Inspector.lua"},
	{id = "clinker", path = "modules/Clinker.lua"},
	{id = "monitor", path = "modules/Monitor.lua"},
}

local refs = {}
for i, m in ipairs(modulesToLoad) do
	updateProgress("Loading: " .. m.path, (i - 1) / #modulesToLoad)
	local res = fetchModule(m.path)
	refs[m.id] = res
	task.wait(0.05)
end

updateProgress("Starting...", 1)

local fsModule = refs.fs
if fsModule then fsModule.init() end

local UI = refs.UI
local ui = refs.initgui(UI)
local props = refs.props(UI)
local audioModule = refs.audio(UI)
local actionsModule = refs.actions(UI)
local viewportModule = refs.viewport(UI)
local guiPreviewModule = refs.guiprev(UI)
local scriptViewerModule = refs.script(UI)
local inspectorModule = refs.inspector
local clinkerModule = refs.clinker(UI)
local monitorModule = refs.monitor(UI)
local globalConnections = {}
local inspectorConnections = {}
local nodeMap = setmetatable({}, {__mode = "k"})

local function cleanInspector()
	for _, conn in ipairs(inspectorConnections) do if conn.Connected then conn:Disconnect() end end
	table.clear(inspectorConnections)
	for _, child in pairs(ui.inspectorFrame:GetChildren()) do
		if not child:IsA("UIListLayout") then child:Destroy() end
	end
end

local function inspectObj(obj)
	inspectorModule(obj, ui, cleanInspector, inspectorConnections, props, audioModule, actionsModule, viewportModule, guiPreviewModule, scriptViewerModule, Players, RunService)
end

local function createNode(obj, parentFrame, depth)
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
		for _, conn in ipairs(myConnections) do if conn.Connected then conn:Disconnect() end end
	end))

	table.insert(myConnections, obj:GetPropertyChangedSignal("Name"):Connect(function() selectBtn.Text = " " .. obj.Name end))

	local function updateIcon()
		expandBtn.Text = next(obj:GetChildren()) == nil and "-" or (childrenFrame.Visible and "v" or ">")
	end

	local function doPopulate()
		if populated then return end
		populated = true
		for _, child in ipairs(obj:GetChildren()) do createNode(child, childrenFrame, depth + 1) end
		table.insert(myConnections, obj.ChildAdded:Connect(function(child)
			createNode(child, childrenFrame, depth + 1)
			updateIcon()
		end))
		table.insert(myConnections, obj.ChildRemoved:Connect(function(child)
			for _, frame in ipairs(childrenFrame:GetChildren()) do
				if frame:IsA("Frame") and nodeMap[frame] == child then frame:Destroy() end
			end
			updateIcon()
		end))
	end

	updateIcon()

	expandBtn.MouseButton1Click:Connect(function()
		if next(obj:GetChildren()) == nil then return end
		doPopulate()
		childrenFrame.Visible = not childrenFrame.Visible
		updateIcon()
	end)

	selectBtn.MouseButton1Click:Connect(function() inspectObj(obj) end)
end

local function populate()
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
	for _, conn in ipairs(globalConnections) do if conn.Connected then conn:Disconnect() end end
	cleanInspector()
	ui.selectorHighlight:Destroy()
	ui.gui:Destroy()
end))

local isCollapsed = false
local expandedSize = UDim2.new(0, 600, 0, 400)

table.insert(globalConnections, ui.minBtn.MouseButton1Click:Connect(function()
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
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		resizing = true
		resizeStartMouse = input.Position
		resizeStartSize = ui.mainFrame.AbsoluteSize
	end
end))

table.insert(globalConnections, ui.resizeHandle.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then resizing = false end
end))

table.insert(globalConnections, ui.titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = ui.mainFrame.Position
	end
end))

table.insert(globalConnections, ui.titleBar.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end))

table.insert(globalConnections, UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end))

table.insert(globalConnections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.F3 then
		ui.gui.Enabled = not ui.gui.Enabled
		ui.selectorHighlight.Enabled = ui.gui.Enabled and ui.selectorHighlight.Adornee ~= nil
	end
end))

table.insert(globalConnections, RunService.RenderStepped:Connect(function()
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
loaderGui:Destroy()
print("[RoEditor] Loaded successfully!")