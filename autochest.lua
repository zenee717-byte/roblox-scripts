-- Auto Diamond Chest Farm + Debug (99 Nights in the Forest)

-- UI
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

-- Variabel
local DiamondsCollected = 0
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HRP = LocalPlayer.Character and LocalPlayer.Character:WaitForChild("HumanoidRootPart")

local function UpdateUI()
    Counter.Text = tostring(DiamondsCollected)
end

-- Debug: Print semua chest yg punya ProximityPrompt
for _, obj in pairs(workspace:GetDescendants()) do
    local prompt = obj:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        print("Found chest:", obj.Name, "| Path:", obj:GetFullName())
    end
end

-- Auto buka chest
task.spawn(function()
    while task.wait(2) do
        pcall(function()
            HRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not HRP then return end

            for _, obj in pairs(workspace:GetDescendants()) do
                local prompt = obj:FindFirstChildOfClass("ProximityPrompt")
                if prompt and (obj.Name:lower():find("chest") or obj.Parent.Name:lower():find("chest")) then
                    -- Teleport ke chest
                    if obj:IsA("BasePart") then
                        HRP.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
                    elseif obj:IsA("Model") and obj.PrimaryPart then
                        HRP.CFrame = obj.PrimaryPart.CFrame + Vector3.new(0, 3, 0)
                    end

                    task.wait(0.5)
                    fireproximityprompt(prompt)

                    DiamondsCollected = DiamondsCollected + 1
                    UpdateUI()
                    task.wait(1)
                end
            end
        end)
    end
end)
