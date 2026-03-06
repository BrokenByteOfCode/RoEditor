return function(UI)
	return function(mainGui, globalConnections, RunService, fs)
		local HttpService = game:GetService("HttpService")
		local savePath = "roeditor/roclicker.json"

		local state = {
			cash = 0, lifetimeCash = 0, prestige = 0, multiplier = 1, startTime = os.time(),
			buildings = {
				{name = "Cursor", count = 0, baseCost = 15, mps = 0.5},
				{name = "Grandma", count = 0, baseCost = 100, mps = 4},
				{name = "Farm", count = 0, baseCost = 1100, mps = 20},
				{name = "Mine", count = 0, baseCost = 12000, mps = 90},
				{name = "Factory", count = 0, baseCost = 130000, mps = 360},
				{name = "Bank", count = 0, baseCost = 1400000, mps = 2000}
			},
			clickUpgrades = {
				{name = "Plastic Mouse", cost = 500, power = 1, bought = false},
				{name = "Iron Mouse", cost = 2500, power = 5, bought = false},
				{name = "Titanium Mouse", cost = 10000, power = 20, bought = false},
				{name = "Diamond Mouse", cost = 50000, power = 100, bought = false}
			},
			baseClickPower = 1, critChance = 0.05, critMult = 2.0
		}

		if fs then pcall(function() local s = fs.read(savePath) if s then for k,v in pairs(HttpService:JSONDecode(s)) do state[k]=v end end end) end
		local function saveState() if fs then pcall(function() fs.write(savePath, HttpService:JSONEncode(state)) end) end end
		local function getBuildingCost(b) return math.floor(b.baseCost * (1.15 ^ b.count)) end
		local function calcMPS() local m = 0 for _,b in ipairs(state.buildings) do m = m + (b.count*b.mps) end return m * state.multiplier end
		local function calcClickPower() local p = state.baseClickPower for _,u in ipairs(state.clickUpgrades) do if u.bought then p = p + u.power end end return p * state.multiplier end

		local frame
		local titleBar = UI("Frame", { Size = UDim2.new(1, 0, 0, 25), BackgroundColor3 = Color3.fromRGB(50, 50, 55),
			UI("TextLabel", { Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 5, 0, 0), BackgroundTransparency = 1, Text = "RoClinker: Ultimate", TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, TextScaled = true }),
			UI("TextButton", { Size = UDim2.new(0, 25, 1, 0), Position = UDim2.new(1, -25, 0, 0), BackgroundColor3 = Color3.fromRGB(200, 60, 60), Text = "X", TextColor3 = Color3.new(1,1,1), TextScaled = true, Events = { MouseButton1Click = function() frame.Visible = false saveState() end } }),
			(function()
				local btn
				btn = UI("TextButton", { Size = UDim2.new(0, 25, 1, 0), Position = UDim2.new(1, -50, 0, 0), BackgroundColor3 = Color3.fromRGB(60, 120, 200), Text = "-", TextColor3 = Color3.new(1,1,1), TextScaled = true, Events = { MouseButton1Click = function()
					local b = btn.Text == "-"
					btn.Text = b and "+" or "-"
					frame.Size = UDim2.new(0, 400, 0, b and 25 or 320)
				end } })
				return btn
			end)()
		})

		local tabContainer = UI("Frame", { Size = UDim2.new(1, 0, 0, 25), Position = UDim2.new(0, 0, 0, 25), BackgroundColor3 = Color3.fromRGB(45, 45, 50) })
		local contentContainer = UI("Frame", { Size = UDim2.new(1, 0, 1, -80), Position = UDim2.new(0, 0, 0, 50), BackgroundTransparency = 1 })
		
		local cashLbl = UI("TextLabel", { Size = UDim2.new(0.5, 0, 1, 0), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(100, 255, 100), Font = Enum.Font.GothamBold, TextScaled = true, Text = "$0" })
		local mpsLbl = UI("TextLabel", { Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0.5, 0, 0, 0), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 200, 50), Font = Enum.Font.GothamBold, TextScaled = true, Text = "0/s" })
		local footer = UI("Frame", { Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 1, -30), BackgroundColor3 = Color3.fromRGB(25, 25, 30), cashLbl, mpsLbl })

		local currentTab
		local function createTab(name, idx, contentInst)
			contentInst.Parent = contentContainer
			UI("TextButton", { Size = UDim2.new(0.25, 0, 1, 0), Position = UDim2.new((idx-1)*0.25, 0, 0, 0), BackgroundColor3 = Color3.fromRGB(60, 60, 65), Text = name, TextColor3 = Color3.new(1,1,1), Font = Enum.Font.Gotham, TextScaled = true, BorderSizePixel = 0, Parent = tabContainer, Events = { MouseButton1Click = function() if currentTab then currentTab.Visible = false end currentTab = contentInst currentTab.Visible = true end } })
		end

		local critLbl = UI("TextLabel", { Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0.85, 0), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 50, 50), Font = Enum.Font.GothamBold, TextScaled = true, Text = "" })
		local mainTab = UI("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, critLbl, UI("TextButton", { Size = UDim2.new(0.6, 0, 0.6, 0), Position = UDim2.new(0.2, 0, 0.2, 0), BackgroundColor3 = Color3.fromRGB(80, 180, 80), Text = "CLICK", Font = Enum.Font.GothamBlack, TextScaled = true, TextColor3 = Color3.new(1,1,1), Events = { MouseButton1Click = function() local p = calcClickPower() if math.random() < state.critChance then p = p * state.critMult critLbl.Text = "CRIT! x" .. state.critMult critLbl.Visible = true task.delay(0.5, function() critLbl.Visible = false end) end state.cash = state.cash + p state.lifetimeCash = state.lifetimeCash + p end } }) })
		
		local shopTab = UI("ScrollingFrame", { Size = UDim2.new(1, -10, 1, -10), Position = UDim2.new(0, 5, 0, 5), BackgroundTransparency = 1, ScrollBarThickness = 6, Visible = false, UI("UIListLayout", { Padding = UDim.new(0, 5) }) })
		local upgTab = UI("ScrollingFrame", { Size = UDim2.new(1, -10, 1, -10), Position = UDim2.new(0, 5, 0, 5), BackgroundTransparency = 1, ScrollBarThickness = 6, Visible = false, UI("UIListLayout", { Padding = UDim.new(0, 5) }) })
		local prestigeTab = UI("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, UI("TextLabel", { Size = UDim2.new(1, -20, 0, 60), Position = UDim2.new(0, 10, 0, 10), BackgroundTransparency = 1, TextColor3 = Color3.new(0.8, 0.8, 1), TextWrapped = true, TextScaled = true, Text = "Reset to gain Prestige Points.\nEach grants +50% global mult.", Font = Enum.Font.Gotham }), UI("TextLabel", { Name = "CostLbl", Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 1, -30), BackgroundTransparency = 1, TextColor3 = Color3.new(1, 0.5, 0.5), TextScaled = true, Text = "Requires $1.00M Cash" }), UI("TextButton", { Name = "PBtn", Size = UDim2.new(0.6, 0, 0, 50), Position = UDim2.new(0.2, 0, 0.5, -25), BackgroundColor3 = Color3.fromRGB(150, 50, 200), Text = "PRESTIGE", TextColor3 = Color3.new(1,1,1), TextScaled = true, Font = Enum.Font.GothamBold, Events = { MouseButton1Click = function() if state.cash >= 1000000 then state.prestige = state.prestige + 1 state.multiplier = 1 + (state.prestige * 0.5) state.cash = 0 state.baseClickPower = 1 for _,b in ipairs(state.buildings) do b.count = 0 end for _,u in ipairs(state.clickUpgrades) do u.bought = false end saveState() end end } }) })

		createTab("Main", 1, mainTab)
		createTab("Shop", 2, shopTab)
		createTab("Upgrades", 3, upgTab)
		createTab("Prestige", 4, prestigeTab)
		currentTab = mainTab mainTab.Visible = true

		local shopButtons = {}
		for i, b in ipairs(state.buildings) do
			local title = UI("TextLabel", { BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 5), Size = UDim2.new(1, -10, 0, 20), TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, TextScaled = true })
			local cost = UI("TextLabel", { BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 25), Size = UDim2.new(1, -10, 0, 20), TextColor3 = Color3.fromRGB(200, 200, 200), Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, TextScaled = true })
			local count = UI("TextLabel", { BackgroundTransparency = 1, Position = UDim2.new(1, -60, 0, 0), Size = UDim2.new(0, 50, 1, 0), TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextScaled = true })
			local btn = UI("TextButton", { Size = UDim2.new(1, -10, 0, 50), BackgroundColor3 = Color3.fromRGB(60, 60, 65), Parent = shopTab, title, cost, count, Events = { MouseButton1Click = function() local price = getBuildingCost(b) if state.cash >= price then state.cash = state.cash - price b.count = b.count + 1 saveState() end end } })
			shopButtons[i] = {ui = btn, title = title, cost = cost, count = count, data = b}
		end

		for i, u in ipairs(state.clickUpgrades) do
			local upgBtn
			upgBtn = UI("TextButton", { Size = UDim2.new(1, -10, 0, 50), BackgroundColor3 = Color3.fromRGB(60, 50, 70), Parent = upgTab,
				UI("TextLabel", { BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 5), Size = UDim2.new(1, -20, 0, 20), TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, TextScaled = true, Text = u.name .. " (+" .. u.power .. " Click)" }),
				UI("TextLabel", { BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 25), Size = UDim2.new(1, -20, 0, 20), TextColor3 = Color3.fromRGB(255, 200, 100), Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, TextScaled = true, Text = "Cost: $" .. u.cost }),
				Events = { MouseButton1Click = function()
					if not u.bought and state.cash >= u.cost then
						state.cash = state.cash - u.cost
						u.bought = true
						upgBtn.Visible = false
						saveState()
					end
				end }
			})
		end

		frame = UI("Frame", { Name = "RoClinkerUltimate", Size = UDim2.new(0, 400, 0, 320), Position = UDim2.new(0.5, -200, 0.5, -160), BackgroundColor3 = Color3.fromRGB(35, 35, 40), BorderSizePixel = 2, BorderColor3 = Color3.fromRGB(60, 60, 60), Visible = false, Parent = mainGui, titleBar, tabContainer, contentContainer, footer })

		local dragging, dragStart, startPos, dragInput
		titleBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging, dragStart, startPos = true, input.Position, frame.Position end end)
		titleBar.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
		frame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)

		table.insert(globalConnections, RunService.RenderStepped:Connect(function(dt)
			local cmps = calcMPS()
			state.cash, state.lifetimeCash = state.cash + (cmps * dt), state.lifetimeCash + (cmps * dt)
			cashLbl.Text, mpsLbl.Text = "$" .. math.floor(state.cash), math.floor(cmps) .. "/s"
			
			if shopTab.Visible then
				for _, itm in ipairs(shopButtons) do
					local p = getBuildingCost(itm.data)
					itm.title.Text, itm.cost.Text, itm.count.Text = itm.data.name .. " (+" .. (itm.data.mps * state.multiplier) .. "/s)", "$" .. p, itm.data.count
					itm.cost.TextColor3 = state.cash >= p and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(200, 200, 200)
				end
			end
			
			if dragging and dragInput then frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + (dragInput.Position - dragStart).X, startPos.Y.Scale, startPos.Y.Offset + (dragInput.Position - dragStart).Y) end
		end))

		return function() frame.Visible = not frame.Visible if frame.Visible then frame.Parent = mainGui end end
	end
end