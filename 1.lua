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
mainFrame.Size = UDim2.new(0, 250, 0, 150)
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -75)
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
titleLabel.Text = "Muscle Legends"
titleLabel.Parent = mainFrame

-- AutoHit Button
local autoHitButton = Instance.new("TextButton")
autoHitButton.Name = "AutoHitButton"
autoHitButton.Size = UDim2.new(0.9, 0, 0, 40)
autoHitButton.Position = UDim2.new(0.05, 0, 0, 35)
autoHitButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
autoHitButton.TextColor3 = Color3.fromRGB(100, 255, 100)
autoHitButton.TextSize = 12
autoHitButton.Font = Enum.Font.Gotham
autoHitButton.Text = "AutoHit: OFF"
autoHitButton.Parent = mainFrame

-- Go Boss Button
local goBossButton = Instance.new("TextButton")
goBossButton.Name = "GoBossButton"
goBossButton.Size = UDim2.new(0.9, 0, 0, 40)
goBossButton.Position = UDim2.new(0.05, 0, 0, 80)
goBossButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
goBossButton.TextColor3 = Color3.fromRGB(100, 100, 255)
goBossButton.TextSize = 12
goBossButton.Font = Enum.Font.Gotham
goBossButton.Text = "Go Boss: OFF"
goBossButton.Parent = mainFrame

-- State Management
local autoHitActive = false
local goBossActive = false
local autoHitConnection = nil
local goBossConnection = nil

-- Find Boss with RootPart
local function findBoss()
	local boss = workspace:FindFirstChild("Grim Reaper")
	if boss then
		return boss
	end
	return nil
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

-- Go Boss Function (RootPart target)
local function startGoBoss()
	goBossActive = true
	goBossButton.Text = "Go Boss: ON"
	goBossButton.TextColor3 = Color3.fromRGB(0, 255, 0)
	
	goBossConnection = RunService.Heartbeat:Connect(function()
		if not goBossActive then return end
		
		local currentChar = player.Character
		if not currentChar or not currentChar:FindFirstChild("HumanoidRootPart") then return end
		if currentChar:FindFirstChild("Humanoid").Health <= 0 then return end
		
		local boss = findBoss()
		if not boss then return end
		
		-- Procura RootPart (não HumanoidRootPart)
		local bossRoot = boss:FindFirstChild("RootPart")
		if not bossRoot then return end
		
		local charHRP = currentChar:FindFirstChild("HumanoidRootPart")
		if charHRP then
			charHRP.CFrame = bossRoot.CFrame
			charHRP.Velocity = Vector3.new(0, 0, 0)
		end
	end)
end

local function stopGoBoss()
	goBossActive = false
	goBossButton.Text = "Go Boss: OFF"
	goBossButton.TextColor3 = Color3.fromRGB(100, 100, 255)
	if goBossConnection then
		goBossConnection:Disconnect()
		goBossConnection = nil
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

goBossButton.MouseButton1Click:Connect(function()
	if goBossActive then
		stopGoBoss()
	else
		startGoBoss()
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
		if goBossConnection then goBossConnection:Disconnect() end
		screenGui:Destroy()
	end
end)
