local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MuscleLegendsGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 250, 0, 180)
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -90)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
mainFrame.BorderSizePixel = 2
mainFrame.Draggable = true
mainFrame.Active = true
mainFrame.Parent = screenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
titleLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "Muscle Legends Farm"
titleLabel.Parent = mainFrame

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "Status"
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0, 30)
statusLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextSize = 10
statusLabel.Font = Enum.Font.Gotham
statusLabel.Text = "Target: None"
statusLabel.Parent = mainFrame

-- AutoHit Button
local autoHitButton = Instance.new("TextButton")
autoHitButton.Name = "AutoHitButton"
autoHitButton.Size = UDim2.new(0.9, 0, 0, 35)
autoHitButton.Position = UDim2.new(0.05, 0, 0, 55)
autoHitButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
autoHitButton.TextColor3 = Color3.fromRGB(100, 255, 100)
autoHitButton.TextSize = 12
autoHitButton.Font = Enum.Font.Gotham
autoHitButton.Text = "AutoHit: OFF"
autoHitButton.Parent = mainFrame

-- Farm Boss Button
local farmBossButton = Instance.new("TextButton")
farmBossButton.Name = "FarmBossButton"
farmBossButton.Size = UDim2.new(0.9, 0, 0, 35)
farmBossButton.Position = UDim2.new(0.05, 0, 0, 95)
farmBossButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
farmBossButton.TextColor3 = Color3.fromRGB(100, 100, 255)
farmBossButton.TextSize = 12
farmBossButton.Font = Enum.Font.Gotham
farmBossButton.Text = "Farm: OFF"
farmBossButton.Parent = mainFrame

-- State Management
local autoHitActive = false
local farmBossActive = false
local autoHitConnection = nil
local farmBossConnection = nil
local currentBoss = nil

-- Boss Array (order de prioridade)
local bossSequence = {
	"Grim Reaper",
	"Frankenbrute",
	"Scarecrow Colossus"
}

-- Find Next Living Boss
local function findNextBoss()
	for _, bossName in ipairs(bossSequence) do
		local boss = workspace:FindFirstChild(bossName)
		if boss and boss:FindFirstChild("RootPart") then
			return boss, bossName
		end
	end
	return nil, nil
end

-- Check if Boss is Valid
local function isBossAlive(boss)
	if not boss then return false end
	if boss.Parent ~= workspace then return false end
	if not boss:FindFirstChild("RootPart") then return false end
	return true
end

-- AutoHit Function
local function startAutoHit()
	autoHitActive = true
	autoHitButton.Text = "AutoHit: ON"
	autoHitButton.TextColor3 = Color3.fromRGB(0, 255, 0)
	
	autoHitConnection = RunService.Heartbeat:Connect(function()
		if not autoHitActive then return end
		
		local currentChar = player.Character
		if not currentChar or not currentChar:FindFirstChild("Humanoid") then return end
		if currentChar:FindFirstChild("Humanoid").Health <= 0 then return end
		
		local punchTool = currentChar:FindFirstChildOfClass("Tool")
		if punchTool and punchTool.Name:lower():find("punch") then
			punchTool:Activate()
		else
			punchTool = player.Backpack:FindFirstChild("Punch")
			if punchTool then
				punchTool.Parent = currentChar
				wait(0.05)
				if currentChar:FindFirstChild("Punch") then
					currentChar:FindFirstChild("Punch"):Activate()
				end
			end
		end
	end)
end

local function stopAutoHit()
	autoHitActive = false
	autoHitButton.Text = "AutoHit: OFF"
	autoHitButton.TextColor3 = Color3.fromRGB(100, 255, 100)
	if autoHitConnection then
		autoHitConnection:Disconnect()
		autoHitConnection = nil
	end
end

-- Farm Boss Function (Multi-Boss Rotation)
local function startFarmBoss()
	farmBossActive = true
	farmBossButton.Text = "Farm: ON"
	farmBossButton.TextColor3 = Color3.fromRGB(0, 255, 0)
	
	farmBossConnection = RunService.Heartbeat:Connect(function()
		if not farmBossActive then return end
		
		local currentChar = player.Character
		if not currentChar or not currentChar:FindFirstChild("HumanoidRootPart") then return end
		if currentChar:FindFirstChild("Humanoid").Health <= 0 then return end
		
		-- Verifica se boss atual ainda vive
		if not isBossAlive(currentBoss) then
			currentBoss = nil
		end
		
		-- Procura proximo boss vivo
		if not currentBoss then
			currentBoss, currentBossName = findNextBoss()
			if currentBoss then
				statusLabel.Text = "Target: " .. currentBossName
			else
				statusLabel.Text = "Target: None"
				return
			end
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
	farmBossButton.Text = "Farm: OFF"
	farmBossButton.TextColor3 = Color3.fromRGB(100, 100, 255)
	statusLabel.Text = "Target: None"
	currentBoss = nil
	if farmBossConnection then
		farmBossConnection:Disconnect()
		farmBossConnection = nil
	end
end

-- Button Events
autoHitButton.MouseButton1Click:Connect(function()
	if autoHitActive then
		stopAutoHit()
	else
		startAutoHit()
	end
end)

farmBossButton.MouseButton1Click:Connect(function()
	if farmBossActive then
		stopFarmBoss()
	else
		startFarmBoss()
	end
end)

-- Persist on Death
player.CharacterAdded:Connect(function(newChar)
	character = newChar
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
end)

-- Cleanup on Script Stop
script.AncestryChanged:Connect(function()
	if script.Parent == nil then
		if autoHitConnection then autoHitConnection:Disconnect() end
		if farmBossConnection then farmBossConnection:Disconnect() end
		screenGui:Destroy()
	end
end)
