return function(mainGui, globalConnections, RunService, fs)
	local HttpService = game:GetService("HttpService")
	local savePath = "roeditor/roclicker.json"

	local state = {
		cash = 0,
		lifetimeCash = 0,
		prestige = 0,
		multiplier = 1,
		startTime = os.time(),
		buildings = {
			{name = "Cursor",   count = 0, baseCost = 15,    mps = 0.5},
			{name = "Grandma",  count = 0, baseCost = 100,   mps = 4},
			{name = "Farm",     count = 0, baseCost = 1100,  mps = 20},
			{name = "Mine",     count = 0, baseCost = 12000, mps = 90},
			{name = "Factory",  count = 0, baseCost = 130000,mps = 360},
			{name = "Bank",     count = 0, baseCost = 1400000,mps = 2000}
		},
		clickUpgrades = {
			{name = "Plastic Mouse", cost = 500, power = 1, bought = false},
			{name = "Iron Mouse",    cost = 2500, power = 5, bought = false},
			{name = "Titanium Mouse",cost = 10000, power = 20, bought = false},
			{name = "Diamond Mouse", cost = 50000, power = 100, bought = false}
		},
		baseClickPower = 1,
		critChance = 0.05,
		critMult = 2.0
	}

	if fs then
		local saved = fs.read(savePath)
		if saved then
			pcall(function()
				local decoded = HttpService:JSONDecode(saved)
				if decoded then
					for k, v in pairs(decoded) do
						state[k] = v
					end
				end
			end)
		end
	end

	local function saveState()
		if fs then
			pcall(function()
				local encoded = HttpService:JSONEncode(state)
				fs.write(savePath, encoded)
			end)
		end
	end

	local function formatNumber(n)
		if n >= 1e15 then return string.format("%.2fq", n/1e15) end
		if n >= 1e12 then return string.format("%.2fT", n/1e12) end
		if n >= 1e9  then return string.format("%.2fB", n/1e9) end
		if n >= 1e6  then return string.format("%.2fM", n/1e6) end
		if n >= 1e3  then return string.format("%.2fk", n/1e3) end
		return math.floor(n)
	end

	local function getBuildingCost(bData)
		return math.floor(bData.baseCost * (1.15 ^ bData.count))
	end

	local function calculateMPS()
		local mps = 0
		for _, b in ipairs(state.buildings) do
			mps = mps + (b.count * b.mps)
		end
		return mps * state.multiplier
	end

	local function calculateClickPower()
		local power = state.baseClickPower
		for _, upg in ipairs(state.clickUpgrades) do
			if upg.bought then power = power + upg.power end
		end
		return power * state.multiplier
	end

	local frame = Instance.new("Frame")
	frame.Name = "RoClinkerUltimate"
	frame.Size = UDim2.new(0, 400, 0, 320)
	frame.Position = UDim2.new(0.5, -200, 0.5, -160)
	frame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
	frame.BorderSizePixel = 2
	frame.BorderColor3 = Color3.fromRGB(60, 60, 60)
	frame.Visible = false
	frame.Parent = mainGui
	
	local titleBar = Instance.new("Frame")
	titleBar.Size = UDim2.new(1, 0, 0, 25)
	titleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
	titleBar.Parent = frame

	local titleLbl = Instance.new("TextLabel")
	titleLbl.Size = UDim2.new(1, -60, 1, 0)
	titleLbl.Position = UDim2.new(0, 5, 0, 0)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Text = "RoClinker: Ultimate"
	titleLbl.TextColor3 = Color3.new(1, 1, 1)
	titleLbl.Font = Enum.Font.GothamBold
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.TextScaled = true
	titleLbl.Parent = titleBar

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 25, 1, 0)
	closeBtn.Position = UDim2.new(1, -25, 0, 0)
	closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
	closeBtn.Text = "X"
	closeBtn.TextColor3 = Color3.new(1,1,1)
	closeBtn.TextScaled = true
	closeBtn.Parent = titleBar

	local minBtn = Instance.new("TextButton")
	minBtn.Size = UDim2.new(0, 25, 1, 0)
	minBtn.Position = UDim2.new(1, -50, 0, 0)
	minBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
	minBtn.Text = "-"
	minBtn.TextColor3 = Color3.new(1,1,1)
	minBtn.TextScaled = true
	minBtn.Parent = titleBar

	local tabContainer = Instance.new("Frame")
	tabContainer.Size = UDim2.new(1, 0, 0, 25)
	tabContainer.Position = UDim2.new(0, 0, 0, 25)
	tabContainer.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
	tabContainer.Parent = frame

	local contentContainer = Instance.new("Frame")
	contentContainer.Size = UDim2.new(1, 0, 1, -80)
	contentContainer.Position = UDim2.new(0, 0, 0, 50)
	contentContainer.BackgroundTransparency = 1
	contentContainer.Parent = frame

	local footer = Instance.new("Frame")
	footer.Size = UDim2.new(1, 0, 0, 30)
	footer.Position = UDim2.new(0, 0, 1, -30)
	footer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	footer.Parent = frame

	local cashLbl = Instance.new("TextLabel")
	cashLbl.Size = UDim2.new(0.5, 0, 1, 0)
	cashLbl.BackgroundTransparency = 1
	cashLbl.TextColor3 = Color3.fromRGB(100, 255, 100)
	cashLbl.Font = Enum.Font.GothamBold
	cashLbl.TextScaled = true
	cashLbl.Text = "$0"
	cashLbl.Parent = footer

	local mpsLbl = Instance.new("TextLabel")
	mpsLbl.Size = UDim2.new(0.5, 0, 1, 0)
	mpsLbl.Position = UDim2.new(0.5, 0, 0, 0)
	mpsLbl.BackgroundTransparency = 1
	mpsLbl.TextColor3 = Color3.fromRGB(255, 200, 50)
	mpsLbl.Font = Enum.Font.GothamBold
	mpsLbl.TextScaled = true
	mpsLbl.Text = "0/s"
	mpsLbl.Parent = footer

	local currentTab = nil
	local function switchTab(tabFrame)
		if currentTab then currentTab.Visible = false end
		currentTab = tabFrame
		currentTab.Visible = true
	end

	local function createTabBtn(name, xOrder, targetFrame)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0.25, 0, 1, 0)
		btn.Position = UDim2.new((xOrder-1)*0.25, 0, 0, 0)
		btn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
		btn.Text = name
		btn.TextColor3 = Color3.new(1,1,1)
		btn.Font = Enum.Font.Gotham
		btn.TextScaled = true
		btn.BorderSizePixel = 0
		btn.Parent = tabContainer
		btn.MouseButton1Click:Connect(function() switchTab(targetFrame) end)
		return btn
	end

	local mainTab = Instance.new("Frame")
	mainTab.Size = UDim2.new(1, 0, 1, 0)
	mainTab.BackgroundTransparency = 1
	mainTab.Visible = false
	mainTab.Parent = contentContainer

	local bigClickBtn = Instance.new("TextButton")
	bigClickBtn.Size = UDim2.new(0.6, 0, 0.6, 0)
	bigClickBtn.Position = UDim2.new(0.2, 0, 0.2, 0)
	bigClickBtn.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
	bigClickBtn.Text = "CLICK"
	bigClickBtn.Font = Enum.Font.GothamBlack
	bigClickBtn.TextScaled = true
	bigClickBtn.TextColor3 = Color3.new(1,1,1)
	bigClickBtn.Parent = mainTab
	
	local critLbl = Instance.new("TextLabel")
	critLbl.Size = UDim2.new(1, 0, 0, 20)
	critLbl.Position = UDim2.new(0, 0, 0.85, 0)
	critLbl.BackgroundTransparency = 1
	critLbl.TextColor3 = Color3.fromRGB(255, 50, 50)
	critLbl.Font = Enum.Font.GothamBold
	critLbl.TextScaled = true
	critLbl.Text = ""
	critLbl.Parent = mainTab

	local shopTab = Instance.new("ScrollingFrame")
	shopTab.Size = UDim2.new(1, -10, 1, -10)
	shopTab.Position = UDim2.new(0, 5, 0, 5)
	shopTab.BackgroundTransparency = 1
	shopTab.ScrollBarThickness = 6
	shopTab.Visible = false
	shopTab.Parent = contentContainer
	
	local shopListLayout = Instance.new("UIListLayout")
	shopListLayout.Padding = UDim.new(0, 5)
	shopListLayout.Parent = shopTab

	local upgTab = Instance.new("ScrollingFrame")
	upgTab.Size = UDim2.new(1, -10, 1, -10)
	upgTab.Position = UDim2.new(0, 5, 0, 5)
	upgTab.BackgroundTransparency = 1
	upgTab.ScrollBarThickness = 6
	upgTab.Visible = false
	upgTab.Parent = contentContainer
	
	local upgListLayout = Instance.new("UIListLayout")
	upgListLayout.Padding = UDim.new(0, 5)
	upgListLayout.Parent = upgTab

	local prestigeTab = Instance.new("Frame")
	prestigeTab.Size = UDim2.new(1, 0, 1, 0)
	prestigeTab.BackgroundTransparency = 1
	prestigeTab.Visible = false
	prestigeTab.Parent = contentContainer

	local prestigeInfo = Instance.new("TextLabel")
	prestigeInfo.Size = UDim2.new(1, -20, 0, 60)
	prestigeInfo.Position = UDim2.new(0, 10, 0, 10)
	prestigeInfo.BackgroundTransparency = 1
	prestigeInfo.TextColor3 = Color3.new(0.8, 0.8, 1)
	prestigeInfo.TextWrapped = true
	prestigeInfo.TextScaled = true
	prestigeInfo.Text = "Reset progress to gain Prestige Points.\nEach point grants +50% global multiplier."
	prestigeInfo.Font = Enum.Font.Gotham
	prestigeInfo.Parent = prestigeTab

	local prestigeBtn = Instance.new("TextButton")
	prestigeBtn.Size = UDim2.new(0.6, 0, 0, 50)
	prestigeBtn.Position = UDim2.new(0.2, 0, 0.5, -25)
	prestigeBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 200)
	prestigeBtn.Text = "PRESTIGE"
	prestigeBtn.TextColor3 = Color3.new(1,1,1)
	prestigeBtn.TextScaled = true
	prestigeBtn.Font = Enum.Font.GothamBold
	prestigeBtn.Parent = prestigeTab

	local prestigeCostLbl = Instance.new("TextLabel")
	prestigeCostLbl.Size = UDim2.new(1, 0, 0, 20)
	prestigeCostLbl.Position = UDim2.new(0, 0, 1, -30)
	prestigeCostLbl.BackgroundTransparency = 1
	prestigeCostLbl.TextColor3 = Color3.new(1, 0.5, 0.5)
	prestigeCostLbl.TextScaled = true
	prestigeCostLbl.Text = "Requires $1.00M Cash"
	prestigeCostLbl.Parent = prestigeTab

	createTabBtn("Main", 1, mainTab)
	createTabBtn("Shop", 2, shopTab)
	createTabBtn("Upgrades", 3, upgTab)
	createTabBtn("Prestige", 4, prestigeTab)
	switchTab(mainTab)

	local shopButtons = {}
	for i, building in ipairs(state.buildings) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, -10, 0, 50)
		btn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
		btn.Font = Enum.Font.Gotham
		btn.TextColor3 = Color3.new(1,1,1)
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.Parent = shopTab
		
		local title = Instance.new("TextLabel")
		title.BackgroundTransparency = 1
		title.Position = UDim2.new(0, 10, 0, 5)
		title.Size = UDim2.new(1, -10, 0, 20)
		title.TextColor3 = Color3.new(1,1,1)
		title.Font = Enum.Font.GothamBold
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.TextScaled = true
		title.Parent = btn

		local cost = Instance.new("TextLabel")
		cost.BackgroundTransparency = 1
		cost.Position = UDim2.new(0, 10, 0, 25)
		cost.Size = UDim2.new(1, -10, 0, 20)
		cost.TextColor3 = Color3.fromRGB(200, 200, 200)
		cost.Font = Enum.Font.Gotham
		cost.TextXAlignment = Enum.TextXAlignment.Left
		cost.TextScaled = true
		cost.Parent = btn
		
		local count = Instance.new("TextLabel")
		count.BackgroundTransparency = 1
		count.Position = UDim2.new(1, -60, 0, 0)
		count.Size = UDim2.new(0, 50, 1, 0)
		count.TextColor3 = Color3.new(1,1,1)
		count.Font = Enum.Font.GothamBold
		count.TextScaled = true
		count.Parent = btn

		btn.MouseButton1Click:Connect(function()
			local price = getBuildingCost(building)
			if state.cash >= price then
				state.cash = state.cash - price
				building.count = building.count + 1
				saveState()
			end
		end)

		shopButtons[i] = {ui = btn, title = title, cost = cost, count = count, data = building}
	end

	local upgradeButtons = {}
	for i, upg in ipairs(state.clickUpgrades) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, -10, 0, 50)
		btn.BackgroundColor3 = Color3.fromRGB(60, 50, 70)
		btn.Font = Enum.Font.Gotham
		btn.Text = ""
		btn.Parent = upgTab

		local name = Instance.new("TextLabel")
		name.BackgroundTransparency = 1
		name.Position = UDim2.new(0, 10, 0, 5)
		name.Size = UDim2.new(1, -20, 0, 20)
		name.TextColor3 = Color3.new(1,1,1)
		name.Font = Enum.Font.GothamBold
		name.TextXAlignment = Enum.TextXAlignment.Left
		name.TextScaled = true
		name.Text = upg.name .. " (+" .. upg.power .. " Click)"
		name.Parent = btn

		local cost = Instance.new("TextLabel")
		cost.BackgroundTransparency = 1
		cost.Position = UDim2.new(0, 10, 0, 25)
		cost.Size = UDim2.new(1, -20, 0, 20)
		cost.TextColor3 = Color3.fromRGB(255, 200, 100)
		cost.Font = Enum.Font.Gotham
		cost.TextXAlignment = Enum.TextXAlignment.Left
		cost.TextScaled = true
		cost.Text = "Cost: $" .. formatNumber(upg.cost)
		cost.Parent = btn

		if upg.bought then btn.Visible = false end

		btn.MouseButton1Click:Connect(function()
			if not upg.bought and state.cash >= upg.cost then
				state.cash = state.cash - upg.cost
				upg.bought = true
				btn.Visible = false
				saveState()
			end
		end)
		
		upgradeButtons[i] = {ui = btn, data = upg}
	end

	local goldenBtn = Instance.new("ImageButton")
	goldenBtn.Size = UDim2.new(0, 40, 0, 40)
	goldenBtn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
	goldenBtn.BorderColor3 = Color3.new(1,1,1)
	goldenBtn.BorderSizePixel = 2
	goldenBtn.Visible = false
	goldenBtn.ZIndex = 10
	goldenBtn.Parent = frame
	local goldenCorner = Instance.new("UICorner")
	goldenCorner.CornerRadius = UDim.new(1, 0)
	goldenCorner.Parent = goldenBtn
	
	local goldenTimer = 0
	local goldenInterval = 15
	local currentInterval = 30
	local autoSaveTimer = 0

	goldenBtn.MouseButton1Click:Connect(function()
		goldenBtn.Visible = false
		local bonus = (calculateMPS() * 60) + (calculateClickPower() * 50)
		state.cash = state.cash + bonus
		
		local popup = Instance.new("TextLabel")
		popup.Size = UDim2.new(0, 100, 0, 20)
		popup.Position = goldenBtn.Position
		popup.BackgroundTransparency = 1
		popup.TextColor3 = Color3.fromRGB(255, 215, 0)
		popup.Text = "+$" .. formatNumber(bonus)
		popup.Font = Enum.Font.GothamBlack
		popup.TextStrokeTransparency = 0.5
		popup.TextScaled = true
		popup.Parent = frame
		
		game:GetService("TweenService"):Create(popup, TweenInfo.new(1), {Position = popup.Position - UDim2.new(0,0,0,50), TextTransparency = 1}):Play()
		game.Debris:AddItem(popup, 1)
	end)

	bigClickBtn.MouseButton1Click:Connect(function()
		local power = calculateClickPower()
		local isCrit = math.random() < state.critChance
		
		if isCrit then
			power = power * state.critMult
			critLbl.Text = "CRITICAL CLICK! x" .. state.critMult
			critLbl.Visible = true
			task.delay(0.5, function() critLbl.Visible = false end)
		end
		
		state.cash = state.cash + power
		state.lifetimeCash = state.lifetimeCash + power
	end)

	prestigeBtn.MouseButton1Click:Connect(function()
		if state.cash >= 1000000 then
			state.prestige = state.prestige + 1
			state.multiplier = 1 + (state.prestige * 0.5)
			
			state.cash = 0
			state.baseClickPower = 1
			for _, b in ipairs(state.buildings) do b.count = 0 end
			for _, u in ipairs(state.clickUpgrades) do u.bought = false end
			for _, uBtn in ipairs(upgradeButtons) do uBtn.ui.Visible = true end
			saveState()
		end
	end)

	local isCollapsed = false
	minBtn.MouseButton1Click:Connect(function()
		isCollapsed = not isCollapsed
		if isCollapsed then
			frame.Size = UDim2.new(0, 400, 0, 25)
			tabContainer.Visible = false
			contentContainer.Visible = false
			footer.Visible = false
			minBtn.Text = "+"
		else
			frame.Size = UDim2.new(0, 400, 0, 320)
			tabContainer.Visible = true
			contentContainer.Visible = true
			footer.Visible = true
			minBtn.Text = "-"
		end
	end)

	closeBtn.MouseButton1Click:Connect(function() 
		frame.Visible = false 
		saveState()
	end)

	local dragging, dragInput, dragStart, startPos
	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
		end
	end)
	titleBar.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)
	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
	end)

	table.insert(globalConnections, RunService.RenderStepped:Connect(function(dt)
		local currentMPS = calculateMPS()
		state.cash = state.cash + (currentMPS * dt)
		state.lifetimeCash = state.lifetimeCash + (currentMPS * dt)

		cashLbl.Text = "$" .. formatNumber(state.cash)
		mpsLbl.Text = formatNumber(currentMPS) .. "/s"
		
		if shopTab.Visible then
			for _, item in ipairs(shopButtons) do
				local price = getBuildingCost(item.data)
				item.title.Text = item.data.name .. " (+" .. formatNumber(item.data.mps * state.multiplier) .. "/s)"
				item.cost.Text = "$" .. formatNumber(price)
				item.count.Text = item.data.count
				
				if state.cash >= price then
					item.cost.TextColor3 = Color3.fromRGB(100, 255, 100)
				else
					item.cost.TextColor3 = Color3.fromRGB(200, 200, 200)
				end
			end
			shopTab.CanvasSize = UDim2.new(0, 0, 0, #state.buildings * 55)
		end
		
		if upgTab.Visible then
			upgTab.CanvasSize = UDim2.new(0, 0, 0, #state.clickUpgrades * 55)
		end
		
		if prestigeTab.Visible then
			prestigeBtn.Text = "PRESTIGE (Rank " .. state.prestige .. ")"
			local req = 1000000
			if state.cash < req then
				prestigeBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
				prestigeCostLbl.TextColor3 = Color3.fromRGB(255, 100, 100)
			else
				prestigeBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 200)
				prestigeCostLbl.TextColor3 = Color3.fromRGB(100, 255, 100)
			end
			prestigeInfo.Text = "Current Mult: x" .. state.multiplier .. "\nReset to gain +50%."
		end

		goldenTimer = goldenTimer + dt
		if goldenTimer > currentInterval then
			goldenTimer = 0
			currentInterval = math.random(15, 60)
			if not goldenBtn.Visible and not isCollapsed then
				goldenBtn.Position = UDim2.new(math.random(10, 90)/100, 0, math.random(20, 80)/100, 0)
				goldenBtn.Visible = true
				task.delay(5, function() goldenBtn.Visible = false end)
			end
		end

		autoSaveTimer = autoSaveTimer + dt
		if autoSaveTimer > 60 then
			autoSaveTimer = 0
			saveState()
		end

		if dragging and dragInput then
			local delta = dragInput.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end))

	return function()
		frame.Visible = not frame.Visible
		if frame.Visible then frame.Parent = mainGui end
	end
end