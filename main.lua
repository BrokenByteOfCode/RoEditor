local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local git = getgenv().RoEditor_Git
if not git then error("[RoEditor] Git library not found in global env!") end
print("[RoEditor] git library found")

local REPO = "BrokenByteOfCode/RoEditor"
local REF = "main"

local configPath = "roeditor/modules_config.json"
local config = {
	audio = true, viewport = true, guiprev = true,
	script = true, clinker = true, monitor = true, rtitems = true
}

if type(isfile) == "function" and isfile(configPath) then
	pcall(function()
		local parsed = HttpService:JSONDecode(readfile(configPath))
		for k, v in pairs(parsed) do config[k] = v end
	end)
end

local preInitGui = Instance.new("ScreenGui")
preInitGui.Name = "RoEditorPreInit"
preInitGui.DisplayOrder = 1000000
preInitGui.Parent = (type(gethui) == "function") and gethui() or CoreGui

local preFrame = Instance.new("Frame")
preFrame.Size = UDim2.new(0, 300, 0, 320)
preFrame.Position = UDim2.new(0.5, -150, 0.5, -160)
preFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
preFrame.BorderSizePixel = 0
preFrame.Parent = preInitGui
Instance.new("UICorner", preFrame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = " RoEditor Options"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.Code
title.TextSize = 18
title.Parent = preFrame

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -100)
scroll.Position = UDim2.new(0, 10, 0, 40)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 4
scroll.Parent = preFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.Parent = scroll

local optModules = {
	{id = "audio", name = "Audio Player"},
	{id = "viewport", name = "3D Viewport"},
	{id = "guiprev", name = "GUI Preview"},
	{id = "script", name = "Script Decompiler"},
	{id = "clinker", name = "RoClinker Game"},
	{id = "monitor", name = "System Monitor"},
	{id = "rtitems", name = "RT Items Checker"}
}

for _, m in ipairs(optModules) do
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 30)
	row.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
	row.BorderSizePixel = 0
	row.Parent = scroll
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)
	
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.65, 0, 1, 0)
	lbl.Position = UDim2.new(0, 10, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = m.name
	lbl.TextColor3 = Color3.new(0.9, 0.9, 0.9)
	lbl.Font = Enum.Font.Code
	lbl.TextSize = 14
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = row
	
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 60, 0, 22)
	btn.Position = UDim2.new(1, -70, 0, 4)
	btn.BackgroundColor3 = config[m.id] and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.Code
	btn.TextSize = 12
	btn.Text = config[m.id] and "ON" or "OFF"
	btn.Parent = row
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
	
	btn.MouseButton1Click:Connect(function()
		config[m.id] = not config[m.id]
		btn.BackgroundColor3 = config[m.id] and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
		btn.Text = config[m.id] and "ON" or "OFF"
	end)
end

local continueBtn = Instance.new("TextButton")
continueBtn.Size = UDim2.new(1, -40, 0, 35)
continueBtn.Position = UDim2.new(0, 20, 1, -50)
continueBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 210)
continueBtn.TextColor3 = Color3.new(1, 1, 1)
continueBtn.Font = Enum.Font.Code
continueBtn.TextSize = 14
continueBtn.Text = "Save & Continue"
continueBtn.Parent = preFrame
Instance.new("UICorner", continueBtn).CornerRadius = UDim.new(0, 6)

local waitEvent = Instance.new("BindableEvent")
continueBtn.MouseButton1Click:Connect(function()
	waitEvent:Fire()
end)

waitEvent.Event:Wait()
preInitGui:Destroy()

if type(writefile) == "function" then
	pcall(function()
		if type(makefolder) == "function" and not isfolder("roeditor") then makefolder("roeditor") end
		writefile(configPath, HttpService:JSONEncode(config))
	end)
end

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

local errorOccurred = false

local function triggerFatalError(err)
	errorOccurred = true
	statusLabel.Text = "Something goes wrong, I can't handle that. Please sorry."
	statusLabel.TextColor3 = Color3.new(1, 0.4, 0.4)
	barFill.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	barFill.Size = UDim2.new(1, 0, 1, 0)
	
	loadFrame.Size = UDim2.new(0, 300, 0, 130)
	
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 100, 0, 25)
	closeBtn.Position = UDim2.new(0.5, -50, 0, 90)
	closeBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
	closeBtn.TextColor3 = Color3.new(1, 1, 1)
	closeBtn.Text = "Close"
	closeBtn.Font = Enum.Font.Code
	closeBtn.Parent = loadFrame
	
	closeBtn.MouseButton1Click:Connect(function()
		loaderGui:Destroy()
		if _G.RoEditor_Main_Gui and _G.RoEditor_Main_Gui.Parent then
			_G.RoEditor_Main_Gui:Destroy()
		end
	end)
	
	warn("[RoEditor] Fatal Error: " .. tostring(err))
end

local function updateProgress(text, frac)
	if not errorOccurred then
		statusLabel.Text = text
		barFill.Size = UDim2.new(frac, 0, 1, 0)
	end
end

task.spawn(function()
	local success, err = pcall(function()
		local function fetchModule(path)
			local content, errFetch = git.fetch(REPO, REF, path)
			if not content then error("Failed to fetch module " .. path .. ": " .. tostring(errFetch)) end
			local func, lerr = loadstring(content, "=" .. path)
			if not func then error("Compile error in module " .. path .. ": " .. tostring(lerr)) end
			return func()
		end

		local modulesToLoad = {
			{id = "fs", path = "modules/filesystem.lua", core = true},
			{id = "UI", path = "modules/UI.lua", core = true},
			{id = "initgui", path = "initgui.lua", core = true},
			{id = "props", path = "modules/Properties.lua", core = true},
			{id = "audio", path = "modules/Audio.lua"},
			{id = "actions", path = "modules/Actions.lua", core = true},
			{id = "viewport", path = "modules/Viewport.lua"},
			{id = "guiprev", path = "modules/GuiPreview.lua"},
			{id = "script", path = "modules/ScriptViewer.lua"},
			{id = "inspector", path = "modules/Inspector.lua", core = true},
			{id = "clinker", path = "modules/Clinker.lua"},
			{id = "monitor", path = "modules/Monitor.lua"},
			{id = "rtitems", path = "modules/RTItemChecker.lua"},
		}

		local activeCount = 0
		for _, m in ipairs(modulesToLoad) do
			if m.core or config[m.id] then activeCount = activeCount + 1 end
		end

		local dummyFactory = function() return function() end end
		local refs = {}
		local isLoaded = {}
		local loadedCount = 0

		for _, m in ipairs(modulesToLoad) do
			if m.core or config[m.id] then
				updateProgress("Loading: " .. m.path, loadedCount / activeCount)
				refs[m.id] = fetchModule(m.path)
				isLoaded[m.id] = true
				loadedCount = loadedCount + 1
				task.wait(0.05)
			else
				refs[m.id] = dummyFactory
				isLoaded[m.id] = false
			end
		end

		updateProgress("Starting...", 1)

		local fsModule = refs.fs
		if fsModule then fsModule.init() end

		local UI = refs.UI
		local ui = refs.initgui(UI)
		_G.RoEditor_Main_Gui = ui.gui

		local settingsBtn = UI("TextButton", { Size = UDim2.new(0, 40, 1, 0), Position = UDim2.new(1, -90, 0, 0), BackgroundColor3 = Color3.new(0.3, 0.3, 0.3), TextColor3 = Color3.new(1, 1, 1), Text = "Cfg", Font = Enum.Font.Code, TextSize = 12, BorderSizePixel = 0, Parent = ui.titleBar })

		local props = refs.props(UI)
		local actionsModule = refs.actions(UI)
		local inspectorModule = refs.inspector
		
		local modInst = {
			audio = isLoaded.audio and refs.audio(UI) or dummyFactory(),
			viewport = isLoaded.viewport and refs.viewport(UI) or dummyFactory(),
			guiprev = isLoaded.guiprev and refs.guiprev(UI) or dummyFactory(),
			script = isLoaded.script and refs.script(UI) or dummyFactory(),
			clinker = nil,
			monitor = nil,
			rtitems = nil
		}
		
		local globalConnections = {}
		local inspectorConnections = {}
		local nodeMap = setmetatable({}, {__mode = "k"})
		local objToNode = setmetatable({}, {__mode = "k"})

		local function cleanInspector()
			for _, conn in ipairs(inspectorConnections) do if conn.Connected then conn:Disconnect() end end
			table.clear(inspectorConnections)
			for _, child in pairs(ui.inspectorFrame:GetChildren()) do
				if not child:IsA("UIListLayout") then child:Destroy() end
			end
		end

		local function expandTo(targetObj)
			if not targetObj then return end
			local lineage = {}
			local current = targetObj
			while current and current ~= game do
				table.insert(lineage, 1, current)
				current = current.Parent
			end
			
			for _, ancestor in ipairs(lineage) do
				local node = objToNode[ancestor]
				if node then
					node.frame.Visible = true
					if ancestor ~= targetObj then
						node.doPopulate()
						node.childrenFrame.Visible = true
						node.updateIcon()
					else
						local oldColor = node.selectBtn.TextColor3
						node.selectBtn.TextColor3 = Color3.new(0.2, 1, 0.2)
						task.delay(1.5, function()
							if node.selectBtn then
								node.selectBtn.TextColor3 = oldColor
							end
						end)
					end
				end
			end
		end

		local function inspectObj(obj)
			ui.gui.Enabled = true
			ui.searchBar.Text = "" 
			expandTo(obj)
			inspectorModule(obj, ui, cleanInspector, inspectorConnections, props, modInst.audio, actionsModule, modInst.viewport, modInst.guiprev, modInst.script, Players, RunService)
		end

		local function createNode(obj, parentFrame, depth)
			local indent = depth * 15
			local expandBtn = UI("TextButton", { Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, indent, 0, 0), BackgroundColor3 = Color3.new(0.15, 0.15, 0.15), TextColor3 = Color3.new(0.8, 0.8, 0.8), Font = Enum.Font.Code, TextSize = 14, BorderSizePixel = 0 })
			local selectBtn = UI("TextButton", { Size = UDim2.new(1, -(indent + 20), 1, 0), Position = UDim2.new(0, indent + 20, 0, 0), BackgroundTransparency = 1, TextColor3 = Color3.new(0.9, 0.9, 0.9), TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.Code, TextSize = 12, Text = " " .. obj.Name })
			
			local childrenFrame = UI("Frame", { Name = "ChildrenFrame", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2, Visible = false, UI("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }) })
			local rowFrame = UI("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), LayoutOrder = 1, expandBtn, selectBtn })
			local nodeFrame = UI("Frame", { Name = "NodeFrame", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = parentFrame, UI("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }), rowFrame, childrenFrame })
			
			nodeMap[nodeFrame] = obj
			
			local nodeData = {
				frame = nodeFrame,
				childrenFrame = childrenFrame,
				expandBtn = expandBtn,
				selectBtn = selectBtn
			}
			objToNode[obj] = nodeData
			
			local populated = false
			local myConnections = {}

			table.insert(myConnections, nodeFrame.Destroying:Connect(function()
				for _, conn in ipairs(myConnections) do if conn.Connected then conn:Disconnect() end end
			end))

			table.insert(myConnections, obj:GetPropertyChangedSignal("Name"):Connect(function() selectBtn.Text = " " .. obj.Name end))

			local function updateIcon()
				expandBtn.Text = next(obj:GetChildren()) == nil and "-" or (childrenFrame.Visible and "v" or ">")
			end
			nodeData.updateIcon = updateIcon

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
			nodeData.doPopulate = doPopulate

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

		local function alignButtons()
			local offset = 90 
			local btns = {
				{btn = ui.refreshBtn, width = 60, enabled = true},
				{btn = ui.monitorBtn, width = 50, enabled = config.monitor},
				{btn = ui.clinkerBtn, width = 50, enabled = config.clinker},
				{btn = ui.rtItemBtn, width = 50, enabled = config.rtitems}
			}
			for _, b in ipairs(btns) do
				if b.enabled then
					b.btn.Position = UDim2.new(1, -(offset + b.width), 0, 0)
					b.btn.Visible = true
					offset = offset + b.width
				else
					b.btn.Visible = false
				end
			end
		end

		if config.monitor then
			modInst.monitor = refs.monitor(UI)
			local toggleMonitor = modInst.monitor(ui.gui, globalConnections, RunService)
			ui.monitorBtn.MouseButton1Click:Connect(toggleMonitor)
		end

		if config.clinker then
			modInst.clinker = refs.clinker(UI)
			local toggleClinker = modInst.clinker(ui.gui, globalConnections, RunService, fsModule)
			ui.clinkerBtn.MouseButton1Click:Connect(toggleClinker)
		end

		if config.rtitems then
			modInst.rtitems = refs.rtitems(UI)
			local toggleRtItems = modInst.rtitems(ui.gui, globalConnections, inspectObj)
			ui.rtItemBtn.MouseButton1Click:Connect(toggleRtItems)
		end
		
		alignButtons()

		local settingsFrame = UI("Frame", {
			Name = "SettingsFrame",
			Size = UDim2.new(0, 220, 0, 280),
			Position = UDim2.new(0.5, -110, 0.5, -140),
			BackgroundColor3 = Color3.new(0.12, 0.12, 0.12),
			BorderSizePixel = 1,
			BorderColor3 = Color3.new(0.3, 0.3, 0.3),
			Visible = false,
			ZIndex = 100,
			Parent = ui.gui,
			UI("TextLabel", {
				Size = UDim2.new(1, 0, 0, 25),
				BackgroundColor3 = Color3.new(0.2, 0.2, 0.2),
				TextColor3 = Color3.new(1, 1, 1),
				Text = " Runtime Settings",
				Font = Enum.Font.Code,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 101
			}),
			UI("TextButton", {
				Name = "CloseBtn",
				Size = UDim2.new(0, 25, 0, 25),
				Position = UDim2.new(1, -25, 0, 0),
				BackgroundColor3 = Color3.new(0.8, 0.1, 0.1),
				TextColor3 = Color3.new(1, 1, 1),
				Text = "X",
				Font = Enum.Font.Code,
				BorderSizePixel = 0,
				ZIndex = 101,
				Events = { MouseButton1Click = function() settingsFrame.Visible = false end }
			})
		})

		settingsBtn.MouseButton1Click:Connect(function()
			settingsFrame.Visible = not settingsFrame.Visible
		end)

		local settingsScroll = UI("ScrollingFrame", {
			Size = UDim2.new(1, 0, 1, -25),
			Position = UDim2.new(0, 0, 0, 25),
			BackgroundTransparency = 1,
			ScrollBarThickness = 4,
			ZIndex = 101,
			Parent = settingsFrame,
			UI("UIListLayout", { Padding = UDim.new(0, 2) })
		})

		for _, m in ipairs(optModules) do
			local btn = UI("TextButton", {
				Size = UDim2.new(0, 40, 0, 20),
				Position = UDim2.new(1, -45, 0, 2),
				BackgroundColor3 = config[m.id] and Color3.new(0.2, 0.6, 0.2) or Color3.new(0.6, 0.2, 0.2),
				TextColor3 = Color3.new(1, 1, 1),
				Text = config[m.id] and "ON" or "OFF",
				Font = Enum.Font.Code,
				TextSize = 12,
				ZIndex = 102
			})
			
			UI("Frame", {
				Size = UDim2.new(1, 0, 0, 24),
				BackgroundTransparency = 1,
				ZIndex = 101,
				Parent = settingsScroll,
				UI("TextLabel", {
					Size = UDim2.new(1, -50, 1, 0),
					Position = UDim2.new(0, 5, 0, 0),
					BackgroundTransparency = 1,
					TextColor3 = Color3.new(0.9, 0.9, 0.9),
					Text = m.name,
					Font = Enum.Font.Code,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 102
				}),
				btn
			})
			
			btn.MouseButton1Click:Connect(function()
				config[m.id] = not config[m.id]
				btn.Text = config[m.id] and "ON" or "OFF"
				btn.BackgroundColor3 = config[m.id] and Color3.new(0.2, 0.6, 0.2) or Color3.new(0.6, 0.2, 0.2)
				
				pcall(function() writefile(configPath, HttpService:JSONEncode(config)) end)
				
				if config[m.id] and not isLoaded[m.id] then
					btn.Text = "..."
					task.spawn(function()
						local path
						for _, mod in ipairs(modulesToLoad) do
							if mod.id == m.id then path = mod.path break end
						end
						refs[m.id] = fetchModule(path)
						
						if m.id == "audio" or m.id == "viewport" or m.id == "guiprev" or m.id == "script" then
							modInst[m.id] = refs[m.id](UI)
						elseif m.id == "clinker" then
							modInst[m.id] = refs[m.id](UI)
							local toggleFn = modInst[m.id](ui.gui, globalConnections, RunService, fsModule)
							ui.clinkerBtn.MouseButton1Click:Connect(toggleFn)
						elseif m.id == "monitor" then
							modInst[m.id] = refs[m.id](UI)
							local toggleFn = modInst[m.id](ui.gui, globalConnections, RunService)
							ui.monitorBtn.MouseButton1Click:Connect(toggleFn)
						elseif m.id == "rtitems" then
							modInst[m.id] = refs[m.id](UI)
							local toggleFn = modInst[m.id](ui.gui, globalConnections, inspectObj)
							ui.rtItemBtn.MouseButton1Click:Connect(toggleFn)
						end
						
						isLoaded[m.id] = true
						btn.Text = "ON"
						alignButtons()
					end)
				else
					alignButtons()
				end
			end)
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
	end)

	if not success then
		triggerFatalError(err)
	else
		loaderGui:Destroy()
		print("[RoEditor] Loaded successfully!")
	end
end)