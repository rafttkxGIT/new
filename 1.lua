local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlareonHubGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
mainFrame.BorderColor3 = Color3.fromRGB(255, 100, 50)
mainFrame.BorderSizePixel = 0
mainFrame.Size = UDim2.new(0, 280, 0, 220)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -110)
mainFrame.Draggable = true
mainFrame.Active = true
mainFrame.Parent = screenGui
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = mainFrame
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(255, 100, 50)
mainStroke.Thickness = 2
mainStroke.Parent = mainFrame
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
titleBar.BorderSizePixel = 0
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.Parent = mainFrame
local titleBarCorner = Instance.new("UICorner")
titleBarCorner.CornerRadius = UDim.new(0, 16)
titleBarCorner.Parent = titleBar
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.BackgroundTransparency = 1
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.TextColor3 = Color3.fromRGB(255, 120, 60)
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Text = "Flareon Hub"
titleLabel.Parent = titleBar
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.BackgroundColor3 = Color3.fromRGB(255, 80, 50)
closeButton.BorderSizePixel = 0
closeButton.Size = UDim2.new(0, 32, 0, 32)
closeButton.Position = UDim2.new(1, -40, 0.5, -16)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 18
closeButton.Font = Enum.Font.GothamBold
closeButton.Text = "X"
closeButton.Parent = titleBar
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeButton
closeButton.MouseButton1Click:Connect(function() screenGui:Destroy() end)
closeButton.MouseEnter:Connect(function() closeButton.BackgroundColor3 = Color3.fromRGB(255, 60, 30) end)
closeButton.MouseLeave:Connect(function() closeButton.BackgroundColor3 = Color3.fromRGB(255, 80, 50) end)
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "Status"
statusLabel.Size = UDim2.new(1, -16, 0, 24)
statusLabel.Position = UDim2.new(0, 8, 0, 45)
statusLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextXAlignment = Enum.TextXAlignment.Center
statusLabel.Text = "📍 Target: None"
statusLabel.Parent = mainFrame
local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 8)
statusCorner.Parent = statusLabel
local statusStroke = Instance.new("UIStroke")
statusStroke.Color = Color3.fromRGB(100, 150, 200)
statusStroke.Thickness = 1
statusStroke.Parent = statusLabel
local autoHitButton = Instance.new("TextButton")
autoHitButton.Name = "AutoHitButton"
autoHitButton.Size = UDim2.new(1, -16, 0, 32)
autoHitButton.Position = UDim2.new(0, 8, 0, 72)
autoHitButton.BackgroundColor3 = Color3.fromRGB(40, 50, 70)
autoHitButton.BorderSizePixel = 0
autoHitButton.TextColor3 = Color3.fromRGB(120, 255, 120)
autoHitButton.TextSize = 13
autoHitButton.Font = Enum.Font.GothamBold
autoHitButton.Text = "⚡ Auto Hit: OFF"
autoHitButton.Parent = mainFrame
local autoHitCorner = Instance.new("UICorner")
autoHitCorner.CornerRadius = UDim.new(0, 10)
autoHitCorner.Parent = autoHitButton
local farmBossButton = Instance.new("TextButton")
farmBossButton.Name = "FarmBossButton"
farmBossButton.Size = UDim2.new(1, -16, 0, 32)
farmBossButton.Position = UDim2.new(0, 8, 0, 107)
farmBossButton.BackgroundColor3 = Color3.fromRGB(40, 50, 70)
farmBossButton.BorderSizePixel = 0
farmBossButton.TextColor3 = Color3.fromRGB(120, 180, 255)
farmBossButton.TextSize = 13
farmBossButton.Font = Enum.Font.GothamBold
farmBossButton.Text = "🎯 Farm Boss: OFF"
farmBossButton.Parent = mainFrame
local farmCorner = Instance.new("UICorner")
farmCorner.CornerRadius = UDim.new(0, 10)
farmCorner.Parent = farmBossButton
local footerLabel = Instance.new("TextLabel")
footerLabel.Name = "Footer"
footerLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
footerLabel.BorderSizePixel = 0
footerLabel.Size = UDim2.new(1, 0, 0, 20)
footerLabel.Position = UDim2.new(0, 0, 1, -20)
footerLabel.TextColor3 = Color3.fromRGB(200, 120, 80)
footerLabel.TextSize = 9
footerLabel.Font = Enum.Font.GothamBold
footerLabel.Text = "Flareon Hub v2.0"
footerLabel.Parent = mainFrame
local footerCorner = Instance.new("UICorner")
footerCorner.CornerRadius = UDim.new(0, 16)
footerCorner.Parent = footerLabel
local autoHitActive = false
local farmBossActive = false
local autoHitConnection = nil
local farmBossConnection = nil
local currentBoss = nil
local currentBossName = nil
local lastPriorityCheckTime = 0
local bossPriority = {["Grim Reaper"] = 3, ["Scarecrow Colossus"] = 2, ["Frankenbrute"] = 1}
local bossSequence = {"Grim Reaper", "Scarecrow Colossus", "Frankenbrute"}
local function getBossPriority(bossName) return bossPriority[bossName] or 0 end
local function isBossAlive(boss) return boss and boss.Parent == workspace and boss:FindFirstChild("RootPart") ~= nil end
local function findNextBoss() for _, bossName in ipairs(bossSequence) do local boss = workspace:FindFirstChild(bossName) if boss and boss:FindFirstChild("RootPart") then return boss, bossName end end return nil, nil end
local function findBestBoss() local bestBoss, bestBossName, bestPriority = nil, nil, 0 for bossName, priority in pairs(bossPriority) do local boss = workspace:FindFirstChild(bossName) if boss and boss:FindFirstChild("RootPart") and priority > bestPriority then bestBoss, bestBossName, bestPriority = boss, bossName, priority end end return bestBoss, bestBossName, bestPriority end
local function startAutoHit()
	autoHitActive = true
	autoHitButton.Text = "⚡ Auto Hit: ON"
	autoHitButton.TextColor3 = Color3.fromRGB(0, 255, 100)
	if autoHitConnection then autoHitConnection:Disconnect() end
	autoHitConnection = RunService.Heartbeat:Connect(function()
		if not autoHitActive then return end
		local currentChar = player.Character
		if not currentChar or not currentChar:FindFirstChild("Humanoid") then return end
		if currentChar:FindFirstChild("Humanoid").Health <= 0 then return end
		local punchTool = currentChar:FindFirstChildOfClass("Tool")
		if punchTool and punchTool.Name:lower():find("punch") then punchTool:Activate()
		else punchTool = player.Backpack:FindFirstChild("Punch")
			if punchTool then punchTool.Parent = currentChar wait(0.05) if currentChar:FindFirstChild("Punch") then currentChar:FindFirstChild("Punch"):Activate() end end
		end
	end)
end
local function stopAutoHit()
	autoHitActive = false
	autoHitButton.Text = "⚡ Auto Hit: OFF"
	autoHitButton.TextColor3 = Color3.fromRGB(120, 255, 120)
	if autoHitConnection then autoHitConnection:Disconnect() autoHitConnection = nil end
end
local function startFarmBoss()
	farmBossActive = true
	farmBossButton.Text = "🎯 Farm Boss: ON"
	farmBossButton.TextColor3 = Color3.fromRGB(0, 200, 255)
	lastPriorityCheckTime = tick()
	if farmBossConnection then farmBossConnection:Disconnect() end
	farmBossConnection = RunService.Heartbeat:Connect(function()
		if not farmBossActive then return end
		local currentChar = player.Character
		if not currentChar or not currentChar:FindFirstChild("HumanoidRootPart") then return end
		if currentChar:FindFirstChild("Humanoid").Health <= 0 then return end
		if tick() - lastPriorityCheckTime >= 10 then lastPriorityCheckTime = tick() local bestBoss, bestBossName, bestPriority = findBestBoss() local currentPriority = currentBossName and getBossPriority(currentBossName) or 0 if bestBoss and bestPriority > currentPriority then currentBoss, currentBossName = bestBoss, bestBossName statusLabel.Text = "📍 Target: " .. currentBossName .. " (SWAP)" end end
		if not isBossAlive(currentBoss) then currentBoss, currentBossName = nil, nil end
		if not currentBoss then currentBoss, currentBossName = findNextBoss() if currentBoss then statusLabel.Text = "📍 Target: " .. currentBossName else statusLabel.Text = "📍 Target: None" return end end
		local bossRoot = currentBoss:FindFirstChild("RootPart") if not bossRoot then return end
		local charHRP = currentChar:FindFirstChild("HumanoidRootPart") if charHRP then charHRP.CFrame = bossRoot.CFrame charHRP.Velocity = Vector3.new(0, 0, 0) end
	end)
end
local function stopFarmBoss()
	farmBossActive = false
	farmBossButton.Text = "🎯 Farm Boss: OFF"
	farmBossButton.TextColor3 = Color3.fromRGB(120, 180, 255)
	statusLabel.Text = "📍 Target: None"
	currentBoss, currentBossName = nil, nil
	if farmBossConnection then farmBossConnection:Disconnect() farmBossConnection = nil end
end
autoHitButton.MouseButton1Click:Connect(function() if autoHitActive then stopAutoHit() else startAutoHit() end end)
autoHitButton.MouseEnter:Connect(function() autoHitButton.BackgroundColor3 = Color3.fromRGB(50, 60, 85) end)
autoHitButton.MouseLeave:Connect(function() autoHitButton.BackgroundColor3 = Color3.fromRGB(40, 50, 70) end)
farmBossButton.MouseButton1Click:Connect(function() if farmBossActive then stopFarmBoss() else startFarmBoss() end end)
farmBossButton.MouseEnter:Connect(function() farmBossButton.BackgroundColor3 = Color3.fromRGB(50, 60, 85) end)
farmBossButton.MouseLeave:Connect(function() farmBossButton.BackgroundColor3 = Color3.fromRGB(40, 50, 70) end)
player.CharacterAdded:Connect(function(newChar) character = newChar end)
game:BindToClose(function() if autoHitConnection then autoHitConnection:Disconnect() end if farmBossConnection then farmBossConnection:Disconnect() end screenGui:Destroy() end)
