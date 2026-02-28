local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local ui = {}

ui.gui = Instance.new("ScreenGui")
ui.gui.Name = "RoEditor"
ui.gui.ResetOnSpawn = false
ui.gui.DisplayOrder = 999999
ui.gui.ZIndexBehavior = Enum.ZIndexBehavior.Global

ui.selectorHighlight = Instance.new("Highlight")
ui.selectorHighlight.FillColor = Color3.new(1, 0, 0)
ui.selectorHighlight.OutlineColor = Color3.new(1, 1, 1)
ui.selectorHighlight.FillTransparency = 0.5
ui.selectorHighlight.OutlineTransparency = 0
ui.selectorHighlight.Enabled = false

local highlightParent
pcall(function() highlightParent = CoreGui end)
if not highlightParent then
    highlightParent = workspace.CurrentCamera
end
ui.selectorHighlight.Parent = highlightParent

ui.mainFrame = Instance.new("Frame")
ui.mainFrame.Size = UDim2.new(0, 600, 0, 400)
ui.mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
ui.mainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
ui.mainFrame.BorderSizePixel = 0
ui.mainFrame.ClipsDescendants = true
ui.mainFrame.Parent = ui.gui

ui.titleBar = Instance.new("TextLabel")
ui.titleBar.Size = UDim2.new(1, 0, 0, 25)
ui.titleBar.BackgroundColor3 = Color3.new(0.05, 0.05, 0.05)
ui.titleBar.TextColor3 = Color3.new(1, 1, 1)
ui.titleBar.Text = " RoEditor [F3 Toggle]"
ui.titleBar.TextXAlignment = Enum.TextXAlignment.Left
ui.titleBar.Font = Enum.Font.Code
ui.titleBar.TextSize = 14
ui.titleBar.Parent = ui.mainFrame
ui.titleBar.Active = true

ui.killBtn = Instance.new("TextButton")
ui.killBtn.Size = UDim2.new(0, 25, 1, 0)
ui.killBtn.Position = UDim2.new(1, -25, 0, 0)
ui.killBtn.BackgroundColor3 = Color3.new(0.8, 0.1, 0.1)
ui.killBtn.TextColor3 = Color3.new(1, 1, 1)
ui.killBtn.Text = "X"
ui.killBtn.Font = Enum.Font.Code
ui.killBtn.TextSize = 14
ui.killBtn.BorderSizePixel = 0
ui.killBtn.Parent = ui.titleBar

ui.minBtn = Instance.new("TextButton")
ui.minBtn.Size = UDim2.new(0, 25, 1, 0)
ui.minBtn.Position = UDim2.new(1, -50, 0, 0)
ui.minBtn.BackgroundColor3 = Color3.new(0.6, 0.6, 0.2)
ui.minBtn.TextColor3 = Color3.new(1, 1, 1)
ui.minBtn.Text = "-"
ui.minBtn.Font = Enum.Font.Code
ui.minBtn.TextSize = 14
ui.minBtn.BorderSizePixel = 0
ui.minBtn.Parent = ui.titleBar

ui.refreshBtn = Instance.new("TextButton")
ui.refreshBtn.Size = UDim2.new(0, 60, 1, 0)
ui.refreshBtn.Position = UDim2.new(1, -110, 0, 0)
ui.refreshBtn.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
ui.refreshBtn.TextColor3 = Color3.new(1, 1, 1)
ui.refreshBtn.Text = "Refresh"
ui.refreshBtn.Font = Enum.Font.Code
ui.refreshBtn.TextSize = 12
ui.refreshBtn.BorderSizePixel = 0
ui.refreshBtn.Parent = ui.titleBar

ui.monitorBtn = Instance.new("TextButton")
ui.monitorBtn.Size = UDim2.new(0, 50, 1, 0)
ui.monitorBtn.Position = UDim2.new(1, -160, 0, 0)
ui.monitorBtn.BackgroundColor3 = Color3.new(0.2, 0.3, 0.5)
ui.monitorBtn.TextColor3 = Color3.new(1, 1, 1)
ui.monitorBtn.Text = "Stats"
ui.monitorBtn.Font = Enum.Font.Code
ui.monitorBtn.TextSize = 12
ui.monitorBtn.BorderSizePixel = 0
ui.monitorBtn.Parent = ui.titleBar

ui.clinkerBtn = Instance.new("TextButton")
ui.clinkerBtn.Size = UDim2.new(0, 50, 1, 0)
ui.clinkerBtn.Position = UDim2.new(1, -210, 0, 0)
ui.clinkerBtn.BackgroundColor3 = Color3.new(0.5, 0.3, 0.1)
ui.clinkerBtn.TextColor3 = Color3.new(1, 1, 1)
ui.clinkerBtn.Text = "MiniGame"
ui.clinkerBtn.Font = Enum.Font.Code
ui.clinkerBtn.TextSize = 12
ui.clinkerBtn.BorderSizePixel = 0
ui.clinkerBtn.Parent = ui.titleBar

ui.exportBtn = Instance.new("TextButton")
ui.exportBtn.Size = UDim2.new(0, 50, 1, 0)
ui.exportBtn.Position = UDim2.new(1, -260, 0, 0)
ui.exportBtn.BackgroundColor3 = Color3.new(0.3, 0.5, 0.2)
ui.exportBtn.TextColor3 = Color3.new(1, 1, 1)
ui.exportBtn.Text = "Export"
ui.exportBtn.Font = Enum.Font.Code
ui.exportBtn.TextSize = 12
ui.exportBtn.BorderSizePixel = 0
ui.exportBtn.Parent = ui.titleBar

ui.searchBar = Instance.new("TextBox")
ui.searchBar.Size = UDim2.new(0.5, 0, 0, 25)
ui.searchBar.Position = UDim2.new(0, 0, 0, 25)
ui.searchBar.BackgroundColor3 = Color3.new(0.18, 0.18, 0.18)
ui.searchBar.TextColor3 = Color3.new(1, 1, 1)
ui.searchBar.PlaceholderText = "Search Nodes..."
ui.searchBar.Font = Enum.Font.Code
ui.searchBar.TextSize = 12
ui.searchBar.BorderSizePixel = 0
ui.searchBar.Parent = ui.mainFrame

ui.explorerFrame = Instance.new("ScrollingFrame")
ui.explorerFrame.Size = UDim2.new(0.5, 0, 1, -50)
ui.explorerFrame.Position = UDim2.new(0, 0, 0, 50)
ui.explorerFrame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
ui.explorerFrame.BorderSizePixel = 0
ui.explorerFrame.ScrollBarThickness = 6
ui.explorerFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ui.explorerFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ui.explorerFrame.Parent = ui.mainFrame

ui.explorerLayout = Instance.new("UIListLayout")
ui.explorerLayout.Parent = ui.explorerFrame

ui.inspectorFrame = Instance.new("ScrollingFrame")
ui.inspectorFrame.Size = UDim2.new(0.5, 0, 1, -25)
ui.inspectorFrame.Position = UDim2.new(0.5, 0, 0, 25)
ui.inspectorFrame.BackgroundColor3 = Color3.new(0.12, 0.12, 0.12)
ui.inspectorFrame.BorderSizePixel = 0
ui.inspectorFrame.ScrollBarThickness = 6
ui.inspectorFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ui.inspectorFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ui.inspectorFrame.Parent = ui.mainFrame

ui.inspectorLayout = Instance.new("UIListLayout")
ui.inspectorLayout.Parent = ui.inspectorFrame

ui.resizeHandle = Instance.new("TextButton")
ui.resizeHandle.Size = UDim2.new(0, 15, 0, 15)
ui.resizeHandle.Position = UDim2.new(1, -15, 1, -15)
ui.resizeHandle.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
ui.resizeHandle.TextColor3 = Color3.new(1, 1, 1)
ui.resizeHandle.Text = "R"
ui.resizeHandle.Font = Enum.Font.Code
ui.resizeHandle.TextSize = 12
ui.resizeHandle.BorderSizePixel = 0
ui.resizeHandle.ZIndex = 10
ui.resizeHandle.Parent = ui.mainFrame

local targetParent
if type(gethui) == "function" then
    targetParent = gethui()
else
    pcall(function() targetParent = CoreGui end)
    if not targetParent then
        targetParent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end
end

ui.gui.Parent = targetParent

return ui