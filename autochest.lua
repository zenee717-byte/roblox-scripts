local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

local PLACE_ID = game.PlaceId

-- Buat UI sederhana untuk notifikasi
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DiamondNotifier"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local NotifyLabel = Instance.new("TextLabel")
NotifyLabel.Size = UDim2.new(0.3, 0, 0.05, 0)
NotifyLabel.Position = UDim2.new(0.35, 0, 0.05, 0)
NotifyLabel.BackgroundTransparency = 0.3
NotifyLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
NotifyLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
NotifyLabel.TextScaled = true
NotifyLabel.Font = Enum.Font.SourceSansBold
NotifyLabel.Text = "💎 Diamond Finder Ready"
NotifyLabel.Parent = ScreenGui

-- Fungsi untuk update notifikasi
local function Notify(msg, color)
    NotifyLabel.Text = msg
    if color then
        NotifyLabel.TextColor3 = color
    end
    print(msg) -- juga keluar di console
end

-- Fungsi cari dan ambil diamond
local function findAndCollectDiamonds()
    task.spawn(function()
        while task.wait(2) do
            local foundDiamond = false
            Notify("🔍 Mencari chest...", Color3.fromRGB(255, 255, 0))

            -- Cari chest
            for _, chest in ipairs(workspace:GetDescendants()) do
                if chest:IsA("Model") and chest.Name:lower():find("chest") then
                    local prompt = chest:FindFirstChildOfClass("ProximityPrompt")
                    if prompt then
                        fireproximityprompt(prompt)
                        task.wait(1)
                    end

                    -- Cari drop diamond di sekitar
                    for _, drop in ipairs(workspace:GetChildren()) do
                        if drop:IsA("Tool") and drop.Name:lower():find("diamond") then
                            foundDiamond = true
                            local dprompt = drop:FindFirstChildOfClass("ProximityPrompt")
                            if dprompt then
                                fireproximityprompt(dprompt)
                                Notify("✅ Diamond diambil: " .. drop.Name, Color3.fromRGB(0, 255, 0))
                            end
                        end
                    end
                end
            end

            -- Kalau tidak ada diamond sama sekali, hoop server
            if not foundDiamond then
                Notify("⚠️ Tidak ada diamond, hoop server lain...", Color3.fromRGB(255, 0, 0))
                TeleportService:Teleport(PLACE_ID, LocalPlayer)
                break
            end
        end
    end)
end

-- Auto jalan setiap spawn
Players.LocalPlayer.CharacterAdded:Connect(function()
    task.wait(3)
    Notify("✅ Spawned! Mulai cari diamond...", Color3.fromRGB(0, 255, 255))
    findAndCollectDiamonds()
end)

-- Pertama kali juga langsung start
findAndCollectDiamonds()
