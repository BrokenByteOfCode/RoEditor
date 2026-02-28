local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local git = getgenv().RoEditor_Git
if not git then
    error("[RoEditor] Git library not found in global env!")
end

local REPO = "BrokenByteOfCode/RoEditor"
local REF  = "main"

local loadedModules = {}

local function fetchModule(path)
    local content, err = git.fetch(REPO, REF, path)
    if not content then
        warn("[RoEditor] ✖ Failed to load module: "..path.." – "..tostring(err))
        loadedModules[path] = false
        return nil
    end

    local ok, result = pcall(function()
        if content:sub(1,3) == '\239\187\191' then
            content = content:sub(4)
        end
        local func, lerr = loadstring(content, "=" .. path)
        if not func then return error(lerr) end
        return func()
    end)

    if ok then
        print("[RoEditor] ✔ Loaded module: " .. path)
        loadedModules[path] = true
        return result
    else
        warn("[RoEditor] ✖ Failed to execute module: " .. path .. " – " .. tostring(result))
        loadedModules[path] = false
        return nil
    end
end

local fsModule = fetchModule("modules/filesystem.lua")
if fsModule then fsModule.init() end

local ui = fetchModule("initgui.lua")
local props = fetchModule("modules/Properties.lua")
local audioModule = fetchModule("modules/Audio.lua")
local actionsModule = fetchModule("modules/Actions.lua")
local viewportModule = fetchModule("modules/Viewport.lua")
local guiPreviewModule = fetchModule("modules/GuiPreview.lua")
local scriptViewerModule = fetchModule("modules/ScriptViewer.lua")
local inspectorModule = fetchModule("modules/Inspector.lua")
local clinkerModule = fetchModule("modules/Clinker.lua")
local monitorModule = fetchModule("modules/Monitor.lua")
local modelExportModule = fetchModule("modules/modelexport.lua")

local globalConnections = {}
local inspectorConnections = {}
local nodeMap = setmetatable({}, {__mode = "k"})

local function cleanInspector()
	for _, conn in ipairs(inspectorConnections) do
		if conn.Connected then
			conn:Disconnect()
		end
	end
	table.clear(inspectorConnections)
	for _, child in pairs(ui.inspectorFrame:GetChildren()) do
		if not child:IsA("UIListLayout") then
			child:Destroy()
		end
	end
end

local modelExportApi
if modelExportModule then
	modelExportApi = modelExportModule(ui.gui, globalConnections, fsModule)
	ui.exportBtn.MouseButton1Click:Connect(modelExportApi.toggle)
end

local function inspectObj(obj)
	inspectorModule(obj, ui, cleanInspector, inspectorConnections, props, audioModule, actionsModule, viewportModule, guiPreviewModule, scriptViewerModule, Players, RunService, modelExportApi)
end

local function createNode(obj, parentFrame, depth)
	local nodeFrame = Instance.new("Frame")
	nodeFrame.Name = "NodeFrame"
	nodeFrame.BackgroundTransparency = 1
	nodeFrame.Size = UDim2.new(1, 0, 0, 0)
	nodeFrame.AutomaticSize = Enum.AutomaticSize.Y
	nodeFrame.Parent = parentFrame
	nodeMap[nodeFrame] = obj

	local nodeLayout = Instance.new("UIListLayout")
	nodeLayout.SortOrder = Enum.SortOrder.LayoutOrder
	nodeLayout.Parent = nodeFrame

	local rowFrame = Instance.new("Frame")
	rowFrame.BackgroundTransparency = 1
	rowFrame.Size = UDim2.new(1, 0, 0, 20)
	rowFrame.LayoutOrder = 1
	rowFrame.Parent = nodeFrame

	local indent = depth * 15
	local expandBtn = Instance.new("TextButton")
	expandBtn.Size = UDim2.new(0, 20, 0, 20)
	expandBtn.Position = UDim2.new(0, indent, 0, 0)
	expandBtn.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
	expandBtn.TextColor3 = Color3.new(0.8, 0.8, 0.8)
	expandBtn.Font = Enum.Font.Code
	expandBtn.TextSize = 14
	expandBtn.BorderSizePixel = 0
	expandBtn.Parent = rowFrame

	local selectBtn = Instance.new("TextButton")
	selectBtn.Size = UDim2.new(1, -(indent + 20), 1, 0)
	selectBtn.Position = UDim2.new(0, indent + 20, 0, 0)
	selectBtn.BackgroundTransparency = 1
	selectBtn.TextColor3 = Color3.new(0.9, 0.9, 0.9)
	selectBtn.TextXAlignment = Enum.TextXAlignment.Left
	selectBtn.Font = Enum.Font.Code
	selectBtn.TextSize = 12
	selectBtn.Text = " " .. obj.Name
	selectBtn.Parent = rowFrame

	local childrenFrame = Instance.new("Frame")
	childrenFrame.Name = "ChildrenFrame"
	childrenFrame.BackgroundTransparency = 1
	childrenFrame.Size = UDim2.new(1, 0, 0, 0)
	childrenFrame.AutomaticSize = Enum.AutomaticSize.Y
	childrenFrame.LayoutOrder = 2
	childrenFrame.Visible = false
	childrenFrame.Parent = nodeFrame

	local childrenLayout = Instance.new("UIListLayout")
	childrenLayout.SortOrder = Enum.SortOrder.LayoutOrder
	childrenLayout.Parent = childrenFrame

	local populated = false
	local myConnections = {}

	table.insert(myConnections, nodeFrame.Destroying:Connect(function()
		for _, conn in ipairs(myConnections) do
			if conn.Connected then
				conn:Disconnect()
			end
		end
	end))

	table.insert(myConnections, obj:GetPropertyChangedSignal("Name"):Connect(function()
		selectBtn.Text = " " .. obj.Name
	end))

	local function updateIcon()
		if next(obj:GetChildren()) == nil then
			expandBtn.Text = "-"
		else
			expandBtn.Text = childrenFrame.Visible and "v" or ">"
		end
	end

	local function doPopulate()
		if populated then return end
		populated = true
		for _, child in ipairs(obj:GetChildren()) do
			createNode(child, childrenFrame, depth + 1)
		end
		table.insert(myConnections, obj.ChildAdded:Connect(function(child)
			createNode(child, childrenFrame, depth + 1)
			updateIcon()
		end))
		table.insert(myConnections, obj.ChildRemoved:Connect(function(child)
			for _, frame in ipairs(childrenFrame:GetChildren()) do
				if frame:IsA("Frame") and nodeMap[frame] == child then
					frame:Destroy()
				end
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

	selectBtn.MouseButton1Click:Connect(function()
		inspectObj(obj)
	end)
end

local function populate()
	for _, child in pairs(ui.explorerFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
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
		for frame, _ in pairs(nodeMap) do
			frame.Visible = true
		end
		return
	end
	for frame, _ in pairs(nodeMap) do
		frame.Visible = false
	end
	for frame, obj in pairs(nodeMap) do
		if string.find(string.lower(obj.Name), q) or string.find(string.lower(obj.ClassName), q) then
			frame.Visible = true
			local cur = frame.Parent
			while cur and cur ~= ui.explorerFrame do
				if cur.Name == "ChildrenFrame" or cur.Name == "NodeFrame" then
					cur.Visible = true
				end
				cur = cur.Parent
			end
		end
	end
end))

table.insert(globalConnections, ui.killBtn.MouseButton1Click:Connect(function()
	for _, conn in ipairs(globalConnections) do
		if conn.Connected then
			conn:Disconnect()
		end
	end
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

local dragging = false
local dragInput
local dragStart
local startPos
local resizing = false
local resizeStartMouse
local resizeStartSize

table.insert(globalConnections, ui.resizeHandle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		resizing = true
		resizeStartMouse = input.Position
		resizeStartSize = ui.mainFrame.AbsoluteSize
	end
end))

table.insert(globalConnections, ui.resizeHandle.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		resizing = false
	end
end))

table.insert(globalConnections, ui.titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = ui.mainFrame.Position
	end
end))

table.insert(globalConnections, ui.titleBar.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end))

table.insert(globalConnections, UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
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
			local newX = math.max(400, resizeStartSize.X + delta.X)
			local newY = math.max(300, resizeStartSize.Y + delta.Y)
			ui.mainFrame.Size = UDim2.new(0, newX, 0, newY)
		end
	end
end))

populate()