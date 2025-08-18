-- // Auto Chest + Server Hop Fix
-- By ChatGPT, sudah diperbaiki bug teleport & chest stuck

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")
local Http = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local PlaceID = game.PlaceId

---------------------------------------------------------------------
-- 🟢 Notifier
local function Notify(msg)
    print("[NOTIFY] " .. msg)
end

---------------------------------------------------------------------
-- 🟢 Teleport Helper
local function TeleportTo(pos)
    if HRP then
        HRP.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
    end
end

---------------------------------------------------------------------
-- 🟢 Open Chest Fix
local function OpenChest(chest)
    if not chest or not chest.PrimaryPart then return false end
    local opened = false

    -- geser sedikit biar tombol E muncul
    TeleportTo(chest.PrimaryPart.Position + chest.PrimaryPart.CFrame.LookVector * 2)

    for i = 1, 15 do -- coba max 15x
        for _, v in ipairs(chest:GetDescendants()) do
            if v:IsA("ProximityPrompt") and v.ActionText:lower():find("open") then
                if v.Enabled then
                    fireproximityprompt(v, 1)
                    task.wait(0.2)
                    fireproximityprompt(v, 0)
                    opened = true
                    Notify("📦 Chest dibuka!")
                    return true
                end
            elseif v:IsA("ClickDetector") then
                fireclickdetector(v)
                opened = true
                Notify("📦 Chest dibuka (ClickDetector)!")
                return true
            end
        end
        task.wait(0.3)
    end

    return opened
end

---------------------------------------------------------------------
-- 🟢 Ambil Drop (Diamond / Item)
local function CollectDrops()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("TouchTransmitter") and obj.Parent then
            firetouchinterest(HRP, obj.Parent, 0)
            firetouchinterest(HRP, obj.Parent, 1)
        end
    end
end

---------------------------------------------------------------------
-- 🟢 Server Hop
local function TPReturner()
    local servers = {}
    local req = syn and syn.request or http_request or request
    local body = game:HttpGet("https://games.roblox.com/v1/games/"..PlaceID.."/servers/Public?sortOrder=Asc&limit=100")
    local data = Http:JSONDecode(body)

    for _, v in ipairs(data.data) do
        if v.playing < v.maxPlayers and v.id ~= game.JobId then
            Notify("🔄 Teleport ke server "..v.id)
            local success = pcall(function()
                TeleportService:TeleportToPlaceInstance(PlaceID, v.id, LocalPlayer)
            end)

            -- fallback: cek setelah 5 detik
            task.delay(5, function()
                if LocalPlayer.Parent == Players then
                    Notify("❌ Teleport gagal → coba server lain")
                    TPReturner()
                end
            end)
            return
        end
    end

    Notify("⚠️ Tidak ada server yang kosong, retry 5 detik...")
    task.delay(5, TPReturner)
end

-- Event kalau teleport gagal (772, dsb)
TeleportService.TeleportInitFailed:Connect(function(player, result, errorMessage)
    if player == LocalPlayer then
        Notify("⚠️ Teleport gagal ("..tostring(result)..") → retry...")
        task.delay(2, TPReturner)
    end
end)

---------------------------------------------------------------------
-- 🟢 Main Loop
task.spawn(function()
    while task.wait(2) do
        for _, chest in ipairs(workspace:GetDescendants()) do
            if chest:IsA("Model") and chest.Name:lower():find("chest") then
                Notify("➡️ Menuju chest: "..chest.Name)
                if OpenChest(chest) then
                    task.wait(1)
                    CollectDrops() -- ambil diamond / item setelah chest terbuka
                    task.wait(1)
                    TPReturner() -- hop ke server lain
                end
            end
        end
    end
end)
