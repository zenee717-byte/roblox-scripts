-- Auto Diamond Collector + UI for 99 Nights in the Forest

-- Buat UI sederhana untuk menampilkan jumlah diamond
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local Counter = Instance.new("TextLabel")

ScreenGui.Parent = game.CoreGui

Frame.Size = UDim2.new(0, 200, 0, 80)
Frame.Position = UDim2.new(0.8, 0, 0.1, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

Title.Size = UDim2.new(1, 0, 0.5, 0)
Title.BackgroundTransparency = 1
Title.Text = "💎 Diamonds"
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.TextScaled = true
Title.Parent = Frame

Counter.Size = UDim2.new(1, 0, 0.5, 0)
Counter.Position = UDim2.new(0, 0, 0.5, 0)
Counter.BackgroundTransparency = 1
Counter.Text = "0"
Counter.TextColor3 = Color3.fromRGB(255, 255, 255)
Counter.TextScaled = true
Counter.Parent = Frame

-- Counter diamond
local DiamondsCollected = 0
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HRP = LocalPlayer.Character and LocalPlayer.Character:WaitForChild("HumanoidRootPart")

-- Update UI function
local function UpdateUI()
    Counter.Text = tostring(DiamondsCollected)
end

-- Auto collect diamond
task.spawn(function()
    while task.wait(1) do
        HRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not HRP then continue end

        for _,v in pairs(workspace:GetChildren()) do
            if v:IsA("Tool") and v.Name == "Diamond" then
                -- Teleport ke diamond
                HRP.CFrame = v.Handle.CFrame + Vector3.new(0,3,0)
                task.wait(0.3)
                -- Ambil diamond
                firetouchinterest(HRP, v.Handle, 0)
                firetouchinterest(HRP, v.Handle, 1)

                DiamondsCollected = DiamondsCollected + 1
                UpdateUI()
            end
        end
    end
end)

-- Auto Hoop (misalnya ke tempat jual diamond)
task.spawn(function()
    while task.wait(5) do
        HRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if HRP then
            local hoop = workspace:FindFirstChild("Hoop") -- ganti sesuai nama di game
            if hoop and hoop:IsA("Part") then
                HRP.CFrame = hoop.CFrame + Vector3.new(0,3,0)
            end
        end
    end
end)
