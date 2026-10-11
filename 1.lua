local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- State para Fast Punch
local State = getgenv().__FGState
if not State then
	State = {
		running = true,
		fastPunch = false,
		fastPunchGeneration = 0,
		fastPunchToolPaused = false,
		rockGeneration = 0,
		selectedRock = nil,
		rockSessionStartedAt = nil,
		rockVisualReadyAt = math.huge,
	}
	getgenv().__FGState = State
end

-- ============ THREADS (Fast Punch) ============

local threads = {}
local threadGenerations = {}

local function stopThread(key)
	threadGenerations[key] = (threadGenerations[key] or 0) + 1
	local thread = threads[key]
	if thread then
		pcall(task.cancel, thread)
		threads[key] = nil
	end
end

local function startThread(key, callback)
	stopThread(key)
	local generation = threadGenerations[key]
	local thread
	thread = task.defer(function()
		local ok, err = pcall(callback)
		if not ok and State.running then
			print("ERROR " .. key .. ": " .. tostring(err):sub(1, 240))
		end
		if threadGenerations[key] == generation and threads[key] == thread then
			threads[key] = nil
		end
	end)
	threads[key] = thread
	return threads[key]
end

local function getCharacter()
	return player.Character
end

local function getHumanoid()
	local char = getCharacter()
	return char and char:FindFirstChildWhichIsA("Humanoid")
end

local function getPunch()
	local char = getCharacter()
	local humanoid = getHumanoid()
	if not char or not humanoid then return nil end
	for _, container in ipairs({ char, player:FindFirstChild("Backpack") }) do
		if container then
			for _, child in ipairs(container:GetChildren()) do
				if child:IsA("Tool") and child.Name:lower() == "punch" then
					if child.Parent ~= char then
						humanoid:EquipTool(child)
					end
					return child
				end
			end
		end
	end
	return nil
end

local function clearRockSelection()
	State.rockGeneration = State.rockGeneration + 1
	State.selectedRock = nil
	State.rockSessionStartedAt = nil
	State.rockVisualReadyAt = math.huge
end

local function setFastPunch(enabled)
	State.fastPunchGeneration = State.fastPunchGeneration + 1
	local generation = State.fastPunchGeneration
	State.fastPunch = enabled == true

	if not State.fastPunch then
		State.fastPunchToolPaused = false
		clearRockSelection()
		stopThread("fastPunchEquip")
		stopThread("fastPunchHit")
		if State.clearFastPunchVisual then State.clearFastPunchVisual() end
		pcall(function()
			local char = getCharacter()
			local punch = char and char:FindFirstChild("Punch")
			local attackTime = punch and punch:FindFirstChild("attackTime")
			if attackTime then attackTime.Value = 0.3 end
			local backpack = player:FindFirstChild("Backpack")
			if punch and backpack then punch.Parent = backpack end
		end)
		return
	end

	startThread("fastPunchEquip", function()
		while State.running and State.fastPunch and State.fastPunchGeneration == generation do
			pcall(function()
				local punch = not State.fastPunchToolPaused and getPunch() or nil
				local attackTime = punch and punch:FindFirstChild("attackTime")
				if attackTime then attackTime.Value = 0 end
			end)
			task.wait(0.05)
		end
	end)

	startThread("fastPunchHit", function()
		local lastVisual = 0
		while State.running and State.fastPunch and State.fastPunchGeneration == generation do
			pcall(function()
				local event = player:FindFirstChild("muscleEvent")
				local punch = not State.fastPunchToolPaused and getPunch() or nil
				if event and event:IsA("RemoteEvent") then
					pcall(event.FireServer, event, "punch", "rightHand")
					pcall(event.FireServer, event, "punch", "leftHand")
				end
				if punch and time() - lastVisual >= 0.12 then
					lastVisual = time()
					pcall(punch.Activate, punch)
					if State.playFastPunchVisual then State.playFastPunchVisual() end
				end
			end)
			task.wait(0.01)
		end
	end)
end

-- ============ GUI ============

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Flareon Hub (Hallowen Event)"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "Main"
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 63, 77)
mainFrame.BorderSizePixel = 0
mainFrame.Size = UDim2.new(0, 359, 0, 302)
mainFrame.Position = UDim2.new(0.37871, 0, 0.24144, 0)
mainFrame.Draggable = true
mainFrame.Active = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 20)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(15, 37, 45)
mainStroke.Thickness = 4
mainStroke.Parent = mainFrame

local MainimageLabel = Instance.new("ImageLabel")
MainimageLabel.Name = "background"
MainimageLabel.BorderSizePixel = 0
MainimageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainimageLabel.Image = "rbxassetid://137469878965534"
MainimageLabel.Size = UDim2.new(0, 359, 0, 302)
MainimageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
MainimageLabel.Parent = mainFrame

local imageCorner = Instance.new("UICorner")
imageCorner.CornerRadius = UDim.new(0, 20)
imageCorner.Parent = MainimageLabel

local mainGradient = Instance.new("UIGradient")
mainGradient.Rotation = 5345
mainGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0.000, Color3.fromRGB(25, 63, 77)),
	ColorSequenceKeypoint.new(0.234, Color3.fromRGB(79, 108, 118)),
	ColorSequenceKeypoint.new(1.000, Color3.fromRGB(255, 255, 255))
}
mainGradient.Parent = MainimageLabel

local mainuiStroke = Instance.new("UIStroke")
mainuiStroke.Color = Color3.fromRGB(15, 37, 45)
mainuiStroke.Thickness = 4
mainuiStroke.Parent = MainimageLabel

local mainTextButton = Instance.new("TextButton")
mainTextButton.TextWrapped = true
mainTextButton.BorderSizePixel = 0
mainTextButton.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
mainTextButton.TextColor3 = Color3.fromRGB(0, 0, 0)
mainTextButton.TextSize = 25
mainTextButton.FontFace = Font.new("SourceSansPro", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
mainTextButton.Size = UDim2.new(0, 200, 0, 50)
mainTextButton.Text = "AUTO HIT: OFF"
mainTextButton.Name = "AUTO HIT"
mainTextButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
mainTextButton.Position = UDim2.new(0.22284, 0, 0.50662, 0)
mainTextButton.Parent = mainFrame

local mainuiconer = Instance.new("UICorner")
mainuiconer.CornerRadius = UDim.new(0, 11)
mainuiconer.Parent = mainTextButton

local mainuiGradient = Instance.new("UIGradient")
mainuiGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0.000, Color3.fromRGB(86, 106, 194)),
	ColorSequenceKeypoint.new(1.000, Color3.fromRGB(57, 147, 255))
}
mainuiGradient.Parent = mainTextButton

local mainuitextbutton = Instance.new("TextButton")
mainuitextbutton.BorderSizePixel = 0
mainuitextbutton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
mainuitextbutton.TextWrapped = true
mainuitextbutton.TextColor3 = Color3.fromRGB(0, 0, 0)
mainuitextbutton.TextSize = 25
mainuitextbutton.FontFace = Font.new("SourceSansPro", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
mainuitextbutton.Size = UDim2.new(0, 200, 0, 50)
mainuitextbutton.Text = "FAST PUNCH: OFF"
mainuitextbutton.Name = "FAST PUNCH"
mainuitextbutton.BorderColor3 = Color3.fromRGB(0, 0, 0)
mainuitextbutton.Position = UDim2.new(0.22284, 0, 0.73179, 0)
mainuitextbutton.Parent = mainFrame

local mainuitextbuttonCorner = Instance.new("UICorner")
mainuitextbuttonCorner.CornerRadius = UDim.new(0, 11)
mainuitextbuttonCorner.Parent = mainuitextbutton

local mainuitextbuttonGradient = Instance.new("UIGradient")
mainuitextbuttonGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0.000, Color3.fromRGB(86, 106, 194)),
	ColorSequenceKeypoint.new(1.000, Color3.fromRGB(57, 147, 255))
}
mainuitextbuttonGradient.Parent = mainuitextbutton

local mainuiTextButton2 = Instance.new("TextButton")
mainuiTextButton2.BorderSizePixel = 0
mainuiTextButton2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
mainuiTextButton2.TextWrapped = true
mainuiTextButton2.TextColor3 = Color3.fromRGB(0, 0, 0)
mainuiTextButton2.TextSize = 25
mainuiTextButton2.FontFace = Font.new("SourceSansPro", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
mainuiTextButton2.Size = UDim2.new(0, 200, 0, 50)
mainuiTextButton2.Text = "FARM: OFF"
mainuiTextButton2.Name = "FARM"
mainuiTextButton2.BorderColor3 = Color3.fromRGB(0, 0, 0)
mainuiTextButton2.Position = UDim2.new(0.22284, 0, 0.28477, 0)
mainuiTextButton2.Parent = mainFrame

local mainuiTextButton2Corner = Instance.new("UICorner")
mainuiTextButton2Corner.CornerRadius = UDim.new(0, 11)
mainuiTextButton2Corner.Parent = mainuiTextButton2

local mainuiTextButton2Gradient = Instance.new("UIGradient")
mainuiTextButton2Gradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0.000, Color3.fromRGB(86, 106, 194)),
	ColorSequenceKeypoint.new(1.000, Color3.fromRGB(57, 147, 255))
}
mainuiTextButton2Gradient.Parent = mainuiTextButton2

local mainuiTextlabel3 = Instance.new("TextLabel")
mainuiTextlabel3.BorderSizePixel = 0
mainuiTextlabel3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
mainuiTextlabel3.TextWrapped = true
mainuiTextlabel3.TextColor3 = Color3.fromRGB(0, 0, 0)
mainuiTextlabel3.TextSize = 14
mainuiTextlabel3.TextScaled = true
mainuiTextlabel3.FontFace = Font.new("HighwayGothic", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
mainuiTextlabel3.Size = UDim2.new(0, 359, 0, 50)
mainuiTextlabel3.Text = "Flareon Hub"
mainuiTextlabel3.Name = "DETAILS"
mainuiTextlabel3.BackgroundTransparency = 1
mainuiTextlabel3.BorderColor3 = Color3.fromRGB(0, 0, 0)
mainuiTextlabel3.Parent = mainFrame

local mainuiTextlabel3gradient = Instance.new("UIGradient")
mainuiTextlabel3gradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0.000, Color3.fromRGB(86, 106, 194)),
	ColorSequenceKeypoint.new(1.000, Color3.fromRGB(57, 147, 255))
}
mainuiTextlabel3gradient.Parent = mainuiTextlabel3

local mainuiUiStroke = Instance.new("UIStroke")
mainuiUiStroke.Color = Color3.fromRGB(34, 86, 105)
mainuiUiStroke.Thickness = 4
mainuiUiStroke.Parent = mainuiTextlabel3

local mainuiTextlabel4 = Instance.new("TextLabel")
mainuiTextlabel4.BorderSizePixel = 0
mainuiTextlabel4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
mainuiTextlabel4.TextWrapped = true
mainuiTextlabel4.TextColor3 = Color3.fromRGB(255, 255, 255)
mainuiTextlabel4.TextSize = 14
mainuiTextlabel4.TextScaled = true
mainuiTextlabel4.FontFace = Font.new("SourceSansPro", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
mainuiTextlabel4.Size = UDim2.new(0, 175, 0, 14)
mainuiTextlabel4.Text = "Recomended size: 3"
mainuiTextlabel4.Name = "TextLabel"
mainuiTextlabel4.BackgroundTransparency = 1
mainuiTextlabel4.BorderColor3 = Color3.fromRGB(0, 0, 0)
mainuiTextlabel4.Position = UDim2.new(0.25627, 0, 2.72, 0)
mainuiTextlabel4.Parent = mainuiTextlabel3

local mainuiTextlabel5 = Instance.new("TextLabel")
mainuiTextlabel5.BorderSizePixel = 0
mainuiTextlabel5.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
mainuiTextlabel5.TextWrapped = true
mainuiTextlabel5.TextColor3 = Color3.fromRGB(0, 0, 0)
mainuiTextlabel5.TextSize = 14
mainuiTextlabel5.TextScaled = true
mainuiTextlabel5.FontFace = Font.new("HighwayGothic", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
mainuiTextlabel5.Size = UDim2.new(0, 334, 0, 21)
mainuiTextlabel5.Text = "V: 2.0"
mainuiTextlabel5.Name = "Version"
mainuiTextlabel5.BackgroundTransparency = 1
mainuiTextlabel5.BorderColor3 = Color3.fromRGB(0, 0, 0)
mainuiTextlabel5.Position = UDim2.new(0.03343, 0, 1, 0)
mainuiTextlabel5.Parent = mainuiTextlabel3

local UiUIGradient = Instance.new("UIGradient")
UiUIGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0.000, Color3.fromRGB(86, 106, 194)),
	ColorSequenceKeypoint.new(1.000, Color3.fromRGB(57, 147, 255))
}
UiUIGradient.Parent = mainuiTextlabel5

local uiuistroke = Instance.new("UIStroke")
uiuistroke.Color = Color3.fromRGB(34, 86, 105)
uiuistroke.Thickness = 4
uiuistroke.Parent = mainuiTextlabel5

-- Target label original: entre AUTO HIT e FAST PUNCH
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "TargetLabel"
statusLabel.BackgroundTransparency = 1
statusLabel.BorderSizePixel = 0
statusLabel.Size = UDim2.new(0, 175, 0, 14)
statusLabel.Position = UDim2.new(0.25627, 0, 0.68, 0)
statusLabel.Text = "Target: None"
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextSize = 14
statusLabel.TextScaled = true
statusLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
statusLabel.TextXAlignment = Enum.TextXAlignment.Center
statusLabel.Parent = mainFrame

-- GUI duplicada removida: mantêm-se os elementos originais definidos acima.



-- ============ AUTO HIT LOGIC ============

local autoHitActive = false
local autoHitConnection = nil

local function startAutoHit()
	autoHitActive = true
	mainTextButton.Text = "AUTO HIT: ON"
	
	if autoHitConnection then autoHitConnection:Disconnect() end
	autoHitConnection = RunService.Heartbeat:Connect(function()
		if not autoHitActive then return end
		local currentChar = player.Character
		if not currentChar or not currentChar:FindFirstChild("Humanoid") then return end
		if currentChar.Humanoid.Health <= 0 then return end
		local punchTool = currentChar:FindFirstChildOfClass("Tool")
		if punchTool and punchTool.Name:lower():find("punch") then
			punchTool:Activate()
		else
			punchTool = player.Backpack:FindFirstChild("Punch")
			if punchTool then
				punchTool.Parent = currentChar
				task.wait(0.05)
				local p = currentChar:FindFirstChild("Punch")
				if p then p:Activate() end
			end
		end
	end)
end

local function stopAutoHit()
	autoHitActive = false
	mainTextButton.Text = "AUTO HIT: OFF"
	
	if autoHitConnection then autoHitConnection:Disconnect() autoHitConnection = nil end
end

-- ============ FARM BOSS LOGIC ============

local farmBossActive = false
local farmBossConnection = nil
local currentBoss = nil
local currentBossName = nil
local lastPriorityCheckTime = 0
local bossPriority = { ["Grim Reaper"] = 3, ["Scarecrow Colossus"] = 2, ["Frankenbrute"] = 1 }
local bossSequence = { "Grim Reaper", "Scarecrow Colossus", "Frankenbrute" }

local function getBossPriority(bossName) return bossPriority[bossName] or 0 end
local function isBossAlive(boss) return boss and boss.Parent == workspace and boss:FindFirstChild("RootPart") ~= nil end
local function findNextBoss()
	for _, bossName in ipairs(bossSequence) do
		local boss = workspace:FindFirstChild(bossName)
		if boss and boss:FindFirstChild("RootPart") then return boss, bossName end
	end
	return nil, nil
end
local function findBestBoss()
	local bestBoss, bestBossName, bestPriority = nil, nil, 0
	for bossName, priority in pairs(bossPriority) do
		local boss = workspace:FindFirstChild(bossName)
		if boss and boss:FindFirstChild("RootPart") and priority > bestPriority then
			bestBoss, bestBossName, bestPriority = boss, bossName, priority
		end
	end
	return bestBoss, bestBossName, bestPriority
end

local function startFarmBoss()
	farmBossActive = true
	mainuiTextButton2.Text = "FARM: ON"
	
	lastPriorityCheckTime = tick()
	if farmBossConnection then farmBossConnection:Disconnect() end
	farmBossConnection = RunService.Heartbeat:Connect(function()
		if not farmBossActive then return end
		local currentChar = player.Character
		if not currentChar or not currentChar:FindFirstChild("HumanoidRootPart") then return end
		if currentChar.Humanoid.Health <= 0 then return end
		if tick() - lastPriorityCheckTime >= 10 then
			lastPriorityCheckTime = tick()
			local bestBoss, bestBossName, bestPriority = findBestBoss()
			local currentPriority = currentBossName and getBossPriority(currentBossName) or 0
			if bestBoss and bestPriority > currentPriority then
				currentBoss, currentBossName = bestBoss, bestBossName
				statusLabel.Text = "Target: " .. currentBossName
			end
		end
		if not isBossAlive(currentBoss) then currentBoss, currentBossName = nil, nil end
		if not currentBoss then
			currentBoss, currentBossName = findNextBoss()
			if not currentBoss then
				statusLabel.Text = "Target: None"
				return
			end
			statusLabel.Text = "Target: " .. currentBossName
		end
		local bossRoot = currentBoss:FindFirstChild("RootPart")
		if not bossRoot then return end
		local charHRP = currentChar:FindFirstChild("HumanoidRootPart")
		if charHRP then
			charHRP.CFrame = bossRoot.CFrame
			charHRP.Velocity = Vector3.new(0, 0, 0)
		end
	end)
end

local function stopFarmBoss()
	farmBossActive = false
	mainuiTextButton2.Text = "FARM: OFF"

	currentBoss, currentBossName = nil, nil
	statusLabel.Text = "Target: None"
	if farmBossConnection then farmBossConnection:Disconnect() farmBossConnection = nil end
end

-- ============ BUTTON CONNECTIONS ============

mainTextButton.MouseButton1Click:Connect(function()
    if autoHitActive then stopAutoHit() else startAutoHit() end
end)

mainuiTextButton2.MouseButton1Click:Connect(function()
    if farmBossActive then stopFarmBoss() else startFarmBoss() end
end)

local fpOn = false
mainuitextbutton.MouseButton1Click:Connect(function()
    fpOn = not fpOn
    setFastPunch(fpOn)
    mainuitextbutton.Text = fpOn and "FAST PUNCH: ON" or "FAST PUNCH: OFF"
end)

-- ============ CLEANUP ============

player.CharacterAdded:Connect(function(newChar) character = newChar end)
game:BindToClose(function()
	if autoHitConnection then autoHitConnection:Disconnect() end
	if farmBossConnection then farmBossConnection:Disconnect() end
	stopThread("fastPunchEquip")
	stopThread("fastPunchHit")
	screenGui:Destroy()
end)

print("[Flareon Hub] Loaded.")
