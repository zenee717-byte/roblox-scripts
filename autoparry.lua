-- ✅ Auto Parry Script dengan UI Toggle
-- Game: Blade Ball (atau game dengan ParryButtonPress)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

-- Remote Parry
local ParryRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ParryButtonPress")

-- Settings
local AutoParryEnabled = true
local DetectionRadius = 60 -- jarak deteksi bola
local ReactionDelay = 0.05 -- delay reaksi biar natural

-- UI Toggle
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local ToggleButton = Instance.new("TextButton", ScreenGui)
ToggleButton.Size = UDim2.new(0, 120, 0, 40)
ToggleButton.Position = UDim2.new(0.5, -60, 0, 100)
ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Text = "AutoParry: ON"

ToggleButton.MouseButton1Click:Connect(function()
    AutoParryEnabled = not AutoParryEnabled
    ToggleButton.Text = "AutoParry: " .. (AutoParryEnabled and "ON" or "OFF")
end)

-- Fungsi Auto Parry
RunService.Heartbeat:Connect(function()
    if not AutoParryEnabled then return end
    if not Character or not Character:FindFirstChild("HumanoidRootPart") then return end
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Velocity.Magnitude > 10 then
            -- cek kalau mendekat
            local dist = (obj.Position - HRP.Position).Magnitude
            if dist < DetectionRadius then
                task.delay(ReactionDelay, function()
                    pcall(function()
                        ParryRemote:FireServer()
                        print("⚡ Auto Parry Triggered!")
                    end)
                end)
            end
        end
    end
end)
