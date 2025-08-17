local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

-- Fungsi ambil diamond otomatis
local function PickupDiamond(diamond)
    if not diamond then return end

    -- Cek kalau ada ProximityPrompt
    local prompt = diamond:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        fireproximityprompt(prompt)
        print("✅ Ambil diamond dengan ProximityPrompt")
        return
    end

    -- Cek kalau ada TouchInterest
    local touchPart = diamond:FindFirstChildWhichIsA("TouchTransmitter", true)
    if touchPart then
        firetouchinterest(HRP, diamond, 0)
        firetouchinterest(HRP, diamond, 1)
        print("✅ Ambil diamond dengan TouchInterest")
        return
    end

    print("⚠️ Diamond ditemukan tapi tidak ada cara ambil (mungkin RemoteEvent).")
end

-- Pantau Workspace untuk spawn diamond baru
game:GetService("Workspace").ChildAdded:Connect(function(child)
    if child.Name:lower():match("diamond") then
        task.wait(0.2) -- tunggu biar prompt/partnya kebaca
        PickupDiamond(child)
    end
end)

-- Cari diamond yang sudah ada (kalau spawn sebelum script jalan)
for _, child in ipairs(game:GetService("Workspace"):GetChildren()) do
    if child.Name:lower():match("diamond") then
        PickupDiamond(child)
    end
end
