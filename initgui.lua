print("[RoEditor_DEBUG] Reached ID: 30")
return function(UI)
    print("[RoEditor_DEBUG] Reached ID: 31")
	local Players = game:GetService("Players")
	local CoreGui = game:GetService("CoreGui")
	local ui = {}

	local highlightParent
	pcall(function() highlightParent = CoreGui end)
     print("[RoEditor_DEBUG] Reached ID: 32")
	if not highlightParent then highlightParent = workspace.CurrentCamera end

	ui.selectorHighlight = UI("Highlight", { FillColor = Color3.new(1, 0, 0), OutlineColor = Color3.new(1, 1, 1), FillTransparency = 0.5, OutlineTransparency = 0, Enabled = false, Parent = highlightParent })

	ui.killBtn = UI("TextButton", { Size = UDim2.new(0, 25, 1, 0), Position = UDim2.new(1, -25, 0, 0), BackgroundColor3 = Color3.new(0.8, 0.1, 0.1), TextColor3 = Color3.new(1, 1, 1), Text = "X", Font = Enum.Font.Code, TextSize = 14, BorderSizePixel = 0 })
	ui.minBtn = UI("TextButton", { Size = UDim2.new(0, 25, 1, 0), Position = UDim2.new(1, -50, 0, 0), BackgroundColor3 = Color3.new(0.6, 0.6, 0.2), TextColor3 = Color3.new(1, 1, 1), Text = "-", Font = Enum.Font.Code, TextSize = 14, BorderSizePixel = 0 })
	ui.refreshBtn = UI("TextButton", { Size = UDim2.new(0, 60, 1, 0), Position = UDim2.new(1, -110, 0, 0), BackgroundColor3 = Color3.new(0.2, 0.2, 0.2), TextColor3 = Color3.new(1, 1, 1), Text = "Refresh", Font = Enum.Font.Code, TextSize = 12, BorderSizePixel = 0 })
	ui.monitorBtn = UI("TextButton", { Size = UDim2.new(0, 50, 1, 0), Position = UDim2.new(1, -160, 0, 0), BackgroundColor3 = Color3.new(0.2, 0.3, 0.5), TextColor3 = Color3.new(1, 1, 1), Text = "Stats", Font = Enum.Font.Code, TextSize = 12, BorderSizePixel = 0 })
	ui.clinkerBtn = UI("TextButton", { Size = UDim2.new(0, 50, 1, 0), Position = UDim2.new(1, -210, 0, 0), BackgroundColor3 = Color3.new(0.5, 0.3, 0.1), TextColor3 = Color3.new(1, 1, 1), Text = "MiniGame", Font = Enum.Font.Code, TextSize = 12, BorderSizePixel = 0 })
	ui.exportBtn = UI("TextButton", { Size = UDim2.new(0, 50, 1, 0), Position = UDim2.new(1, -260, 0, 0), BackgroundColor3 = Color3.new(0.3, 0.5, 0.2), TextColor3 = Color3.new(1, 1, 1), Text = "Export", Font = Enum.Font.Code, TextSize = 12, BorderSizePixel = 0 })

	ui.titleBar = UI("TextLabel", { Size = UDim2.new(1, 0, 0, 25), BackgroundColor3 = Color3.new(0.05, 0.05, 0.05), TextColor3 = Color3.new(1, 1, 1), Text = " RoEditor [F3 Toggle]", TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.Code, TextSize = 14, Active = true, ui.killBtn, ui.minBtn, ui.refreshBtn, ui.monitorBtn, ui.clinkerBtn, ui.exportBtn })

	ui.searchBar = UI("TextBox", { Size = UDim2.new(0.5, 0, 0, 25), Position = UDim2.new(0, 0, 0, 25), BackgroundColor3 = Color3.new(0.18, 0.18, 0.18), TextColor3 = Color3.new(1, 1, 1), PlaceholderText = "Search Nodes...", Font = Enum.Font.Code, TextSize = 12, BorderSizePixel = 0 })

	ui.explorerLayout = UI("UIListLayout", {})
	ui.explorerFrame = UI("ScrollingFrame", { Size = UDim2.new(0.5, 0, 1, -50), Position = UDim2.new(0, 0, 0, 50), BackgroundColor3 = Color3.new(0.15, 0.15, 0.15), BorderSizePixel = 0, ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0), ui.explorerLayout })

	ui.inspectorLayout = UI("UIListLayout", {})
	ui.inspectorFrame = UI("ScrollingFrame", { Size = UDim2.new(0.5, 0, 1, -25), Position = UDim2.new(0.5, 0, 0, 25), BackgroundColor3 = Color3.new(0.12, 0.12, 0.12), BorderSizePixel = 0, ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0), ui.inspectorLayout })

	ui.resizeHandle = UI("TextButton", { Size = UDim2.new(0, 15, 0, 15), Position = UDim2.new(1, -15, 1, -15), BackgroundColor3 = Color3.new(0.3, 0.3, 0.3), TextColor3 = Color3.new(1, 1, 1), Text = "R", Font = Enum.Font.Code, TextSize = 12, BorderSizePixel = 0, ZIndex = 10 })

	ui.mainFrame = UI("Frame", { Size = UDim2.new(0, 600, 0, 400), Position = UDim2.new(0.5, -300, 0.5, -200), BackgroundColor3 = Color3.new(0.1, 0.1, 0.1), BorderSizePixel = 0, ClipsDescendants = true, ui.titleBar, ui.searchBar, ui.explorerFrame, ui.inspectorFrame, ui.resizeHandle })

	ui.gui = UI("ScreenGui", { Name = "RoEditor", ResetOnSpawn = false, DisplayOrder = 999999, ZIndexBehavior = Enum.ZIndexBehavior.Global, ui.mainFrame })

	local targetParent
	if type(gethui) == "function" then
		targetParent = gethui()
	else
		pcall(function() targetParent = CoreGui end)
      print("[RoEditor_DEBUG] Reached ID: 33")
		if not targetParent then targetParent = Players.LocalPlayer:WaitForChild("PlayerGui") end
	end
	ui.gui.Parent = targetParent

	return ui
end