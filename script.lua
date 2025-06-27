-- Teleport UI Script
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Tạo UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportUI"
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 120)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- Nút Save Position
local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(1, -10, 0, 25)
saveBtn.Position = UDim2.new(0, 5, 0, 5)
saveBtn.Text = "Save Position"
saveBtn.BackgroundColor3 = Color3.new(0.2, 0.5, 0.2)
saveBtn.TextColor3 = Color3.new(1, 1, 1)
saveBtn.BorderSizePixel = 0
saveBtn.Parent = frame

-- Dropdown
local dropdown = Instance.new("TextButton")
dropdown.Size = UDim2.new(1, -10, 0, 25)
dropdown.Position = UDim2.new(0, 5, 0, 35)
dropdown.Text = "Teleport"
dropdown.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
dropdown.TextColor3 = Color3.new(1, 1, 1)
dropdown.BorderSizePixel = 0
dropdown.Parent = frame

-- Nút Auto Teleport
local autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.new(1, -10, 0, 25)
autoBtn.Position = UDim2.new(0, 5, 0, 65)
autoBtn.Text = "Start Auto"
autoBtn.BackgroundColor3 = Color3.new(0.5, 0.2, 0.2)
autoBtn.TextColor3 = Color3.new(1, 1, 1)
autoBtn.BorderSizePixel = 0
autoBtn.Parent = frame

-- Toggle button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 20, 0, 20)
toggleBtn.Position = UDim2.new(1, -25, 0, 95)
toggleBtn.Text = "-"
toggleBtn.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = frame

-- Variables
local savedCFrame
local isAuto = false
local isTween = false
local connection

-- Tween function
local function Tween(targetCFrame)
    local hrp = player.Character.HumanoidRootPart
    local distance = (targetCFrame.Position - hrp.Position).Magnitude
    
    -- Tạo floor ảo
    local virtualFloor = Instance.new("Part")
    virtualFloor.Size = Vector3.new(20, 1, 20)
    virtualFloor.Anchored = true
    virtualFloor.CanCollide = true
    virtualFloor.Transparency = 1
    virtualFloor.Name = "VirtualFloor"
    virtualFloor.Parent = workspace
    
    -- Update floor position
    local function updateFloor()
        if virtualFloor and virtualFloor.Parent then
            virtualFloor.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 3.5, hrp.Position.Z)
        end
    end
    
    local floorConnection = RunService.Heartbeat:Connect(updateFloor)
    
    -- Tween với speed = 10
    local tween = TweenService:Create(hrp, TweenInfo.new(distance/10, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    tween:Play()
    tween.Completed:Wait()
    
    -- Cleanup
    if floorConnection then floorConnection:Disconnect() end
    if virtualFloor and virtualFloor.Parent then virtualFloor:Destroy() end
end

-- Save position
saveBtn.MouseButton1Click:Connect(function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        savedCFrame = player.Character.HumanoidRootPart.CFrame
        saveBtn.Text = "Position Saved!"
        wait(1)
        saveBtn.Text = "Save Position"
    end
end)

-- Dropdown toggle
dropdown.MouseButton1Click:Connect(function()
    isTween = not isTween
    dropdown.Text = isTween and "Tween" or "Teleport"
end)

-- Auto teleport
autoBtn.MouseButton1Click:Connect(function()
    if not savedCFrame then return end
    
    isAuto = not isAuto
    autoBtn.Text = isAuto and "Stop Auto" or "Start Auto"
    
    if isAuto then
        connection = RunService.Heartbeat:Connect(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                if isTween then
                    spawn(function() Tween(savedCFrame) end)
                else
                    player.Character.HumanoidRootPart.CFrame = savedCFrame
                end
            end
        end)
    else
        if connection then connection:Disconnect() end
    end
end)

-- Toggle UI
local isMinimized = false
toggleBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        frame.Size = UDim2.new(0, 200, 0, 25)
        saveBtn.Visible = false
        dropdown.Visible = false
        autoBtn.Visible = false
        toggleBtn.Text = "+"
        toggleBtn.Position = UDim2.new(1, -25, 0, 2)
    else
        frame.Size = UDim2.new(0, 200, 0, 120)
        saveBtn.Visible = true
        dropdown.Visible = true
        autoBtn.Visible = true
        toggleBtn.Text = "-"
        toggleBtn.Position = UDim2.new(1, -25, 0, 95)
    end
end)
