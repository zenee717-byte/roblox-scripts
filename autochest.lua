-- Auto Diamond Chest Collector + UI for 99 Nights in the Forest

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
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")

-- ambil diamonds dari leaderstats (kalau ada)
local function GetDiamonds()
    local stats = LocalPlayer:FindFirstChild("leaderstats")
    if stats and stats:FindFirstChild("Diamonds") then
        return stats.Diamonds.Value
    end
    return 0
end

-- Update UI
local function UpdateUI()
    Counter.Text = tostring(GetDiamonds())
end

-- Auto buka diamond chest
local function CollectDiamondChest()
    local HRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not HRP then return end

    -- cari chest
    for _,v in pairs(workspace:GetDescendants()) do
        if v.Name:lower():find("diamond") and v:FindFirstChildOfClass("ProximityPrompt") then
            -- teleport ke chest
            HRP.CFrame = v.CFrame + Vector3.new(0,3,0)
            task.wait(0.5)

            -- paksa buka chest
            local prompt = v:FindFirstChildOfClass("ProximityPrompt")
            if prompt then
                fireproximityprompt(prompt)
            end
        end
    end
end

-- Auto Server Hop kalau sudah ambil chest
local function ServerHop()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
end

-- Loop utama
task.spawn(function()
    while task.wait(5) do
        pcall(function()
            UpdateUI()
            CollectDiamondChest()

            -- kalau diamonds nambah, pindah server
            -- (bisa diganti sesuai logika kamu)
            -- contoh: kalau chest udah ga ada
            if not workspace:FindFirstChild("DiamondChest") then
                ServerHop()
            end
        end)
    end
end)
