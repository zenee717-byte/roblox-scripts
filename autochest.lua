-- Auto Chest + Auto Ambil Diamond + Auto Hoop
-- Game: 99 Nights in the Forest

-- Variabel
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer
local diamondCount = 0
local checking = false

-- ID server tujuan (server game, bukan lobby)
local SERVER_GAME_PLACEID = 1234567890 -- ganti ke PlaceId server game

-- Fungsi buka chest
local function bukaChest(chest)
    local prompt = chest:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then
        fireproximityprompt(prompt)
        print("🔓 Chest dibuka:", chest.Name)
    end
end

-- Fungsi ambil diamond drop
local function ambilDrop(drop)
    local prompt = drop:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then
        fireproximityprompt(prompt)
        diamondCount += 1
        print("💎 Diamond berhasil diambil! Total:", diamondCount)
    end
end

-- Listener: kalau ada diamond baru muncul di workspace
workspace.ChildAdded:Connect(function(obj)
    if obj.Name == "Diamond" then
        task.wait(0.3) -- kasih waktu biar bisa dipickup
        ambilDrop(obj)
    end
end)

-- Cek semua chest yang ada
local function checkAllChests()
    checking = true
    local adaDiamondChest = false

    for _, chest in pairs(workspace:GetDescendants()) do
        if chest:IsA("Model") and chest.Name:lower():find("chest") then
            bukaChest(chest)
            if chest.Name == "DiamondChest" then
                adaDiamondChest = true
            end
        end
    end

    task.wait(5) -- tunggu semua drop keluar

    -- Kalau sudah buka semua chest, cek apakah ada diamond
    local adaDiamond = false
    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name == "Diamond" then
            adaDiamond = true
        end
    end

    if not adaDiamond and not adaDiamondChest then
        print("🚪 Tidak ada Diamond, teleport ke server game...")
        TeleportService:Teleport(SERVER_GAME_PLACEID, player)
    else
        print("✅ Diamond masih ada atau chest diamond ditemukan.")
    end

    checking = false
end

-- Loop auto check
while task.wait(10) do
    if not checking then
        checkAllChests()
    end
end
