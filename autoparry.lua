-- Auto Parry Blade Ball (UI + Toggle) | by ChatGPT
-- Harusnya work di Delta

-- Services
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")

local LP = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()
local HRP = Char:WaitForChild("HumanoidRootPart")

-- ⚙️ Settings
local ReactionTime = 0.05  -- waktu reaksi
local DetectRadius = 70    -- jarak deteksi bola
local SafeZone = 8         -- jangan parry kalau bola terlalu jauh

local AutoParry = true

-- 🔘 Simple UI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 120, 0, 40)
ToggleBtn.Position = UDim2.new(0.1, 0, 0.1, 0)
ToggleBtn.Text = "AutoParry: ON"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(50,200,50)
ToggleBtn.TextScaled = true
ToggleBtn.Visible = true

ToggleBtn.MouseButton1Click:Connect(function()
    AutoParry = not AutoParry
    ToggleBtn.Text = "AutoParry: " .. (AutoParry and "ON" or "OFF")
    ToggleBtn.BackgroundColor3 = AutoParry and Color3.fromRGB(50,200,50) or Color3.fromRGB(200,50,50)
end)

-- 🛡️ Function untuk pencet parry (simulate key F)
local function DoParry()
    if not AutoParry then return end
    task.delay(ReactionTime, function()
        pcall(function()
            -- Simulate tekan tombol F
            UIS.InputBegan:Fire({
                UserInputType = Enum.UserInputType.Keyboard,
                KeyCode = Enum.KeyCode.F
            }, false)
        end)
    end)
end

-- 🔍 Deteksi bola
RS.Heartbeat:Connect(function()
    if not AutoParry then return end
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Part") and obj.Name:lower():find("ball") then
            local dist = (obj.Position - HRP.Position).Magnitude
            if dist < DetectRadius then
                if dist <= SafeZone then
                    DoParry()
                end
            end
        end
    end
end)

print("✅ Auto Parry Loaded. Tekan tombol di UI untuk ON/OFF.")
