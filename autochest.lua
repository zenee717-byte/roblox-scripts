-- Auto Farm Chest + Instant Hop (Jika Chest Kosong)
-- Script cepat: buka chest, langsung cek diamond, kalau tidak ada → langsung hop

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")
local Http = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local PlaceID = game.PlaceId

---------------------------------------------------------------------
-- Notifier
local function Notify(msg)
    print("[AutoFarm] " .. msg)
end

-- Cepat Teleport ke Lokasi
local function TeleportTo(pos)
    if HRP then
        HRP.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
    end
end

---------------------------------------------------------------------
-- Fungsi Open Chest (max 10 percobaan)
local function OpenChest(chest)
    if not (chest and chest.PrimaryPart) then return false end

    TeleportTo(chest.PrimaryPart.Position + chest.PrimaryPart.CFrame.LookVector * 2)
    for i = 1, 10 do
        for _, v in ipairs(chest:GetDescendants()) do
            if v:IsA("ProximityPrompt") and v.ActionText:lower():find("open") and v.Enabled then
                fireproximityprompt(v, 1) task.wait(0.2) fireproximityprompt(v, 0)
                Notify("📦 Chest dibuka!")
                return true
            elseif v:IsA("ClickDetector") then
                fireclickdetector(v)
                Notify("📦 Chest dibuka (ClickDetector)!")
                return true
            end
        end
        task.wait(0.3)
    end

    Notify("⏱ Chest gagal dibuka setelah 10x, skip...")
    return false
end

---------------------------------------------------------------------
-- Cek dan Ambil Diamond (langsung return)
local function TryPickDiamond()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("TouchTransmitter") and obj.Parent then
            if obj.Parent.Name:lower():find("diamond") then
                firetouchinterest(HRP, obj.Parent, 0)
                firetouchinterest(HRP, obj.Parent, 1)
                Notify("💎 Diamond ditemukan & diambil!")
                return true
            end
        end
    end
    return false
end

---------------------------------------------------------------------
-- Server Hop Cepat
local function TPReturner()
    local body = game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=Asc&limit=100")
    local data = Http:JSONDecode(body)

    for _, v in ipairs(data.data or {}) do
        if v.playing < v.maxPlayers and v.id ~= game.JobId then
            Notify("🔄 Hop ke server: " .. v.id)
            pcall(function()
                TeleportService:TeleportToPlaceInstance(PlaceID, v.id, LocalPlayer)
            end)
            task.delay(5, function()
                if LocalPlayer.Parent == Players then
                    Notify("❌ Teleport gagal / tidak pindah, retry...")
                    TPReturner()
                end
            end)
            return
        end
    end

    Notify("⚠️ Semua server penuh → teleport random")
    TeleportService:Teleport(PlaceID, LocalPlayer)
end

TeleportService.TeleportInitFailed:Connect(function(_, result)
    Notify("⚠️ Teleport gagal: " .. tostring(result) .. " → retry")
    task.delay(2, TPReturner)
end)

---------------------------------------------------------------------
-- MAIN LOOP
task.spawn(function()
    while task.wait(1) do
        for _, chest in ipairs(workspace:GetDescendants()) do
            if chest:IsA("Model") and chest.Name:lower():find("chest") then
                Notify("➡️ Menuju chest: " .. chest.Name)
                if OpenChest(chest) then
                    task.wait(0.5)
                    if TryPickDiamond() then
                        Notify("✅ Diamond berhasil diambil. Tunggu chest berikutnya...")
                        task.wait(2)
                    else
                        Notify("❌ Tidak ada diamond → Hop!")
                        TPReturner()
                        return
                    end
                end
            end
        end
    end
end)
