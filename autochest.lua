--// Auto Diamond Farm 99 Nights in the Forest
--// Efisien + Anti Respawn Stuck
--// by jen nnn & ChatGPT

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character
local HRP
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local PlaceID = game.PlaceId

-- 🔔 Notifikasi helper
local function Notify(txt)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "💎 Diamond Farm",
            Text = txt,
            Duration = 4
        })
    end)
end

-- 🧍 Update character / respawn fix
local function UpdateChar()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    HRP = Character:WaitForChild("HumanoidRootPart")
end
UpdateChar()

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    UpdateChar()
    Notify("⚰️ Respawn terdeteksi, lanjut farm...")
end)

-- 💠 Ambil diamond di sekitar
local function CollectDiamonds()
    local found = false
    for _, drop in pairs(workspace:GetDescendants()) do
        if drop:IsA("Part") or drop:IsA("MeshPart") then
            if drop.Name:lower():find("diamond") then
                found = true
                HRP.CFrame = drop.CFrame + Vector3.new(0, 3, 0)
                local prompt = drop:FindFirstChildOfClass("ProximityPrompt")
                if prompt then
                    fireproximityprompt(prompt)
                end
                task.wait(0.3)
            end
        end
    end
    return found
end

-- 📦 Buka semua chest
local function OpenAllChests()
    local opened = false
    for _, chest in pairs(workspace:GetDescendants()) do
        if chest:IsA("Model") and chest.Name:lower():find("chest") then
            local prompt = chest:FindFirstChildWhichIsA("ProximityPrompt", true)
            local ppart = chest.PrimaryPart or chest:FindFirstChild("HumanoidRootPart") or chest:FindFirstChildWhichIsA("BasePart")
            if prompt and ppart then
                opened = true
                HRP.CFrame = ppart.CFrame + Vector3.new(0, 3, 0)
                task.wait(0.5)
                fireproximityprompt(prompt)
                task.wait(1.2)
                CollectDiamonds()
            end
        end
    end
    return opened
end

-- 🔄 ServerHop (anti 771)
local function ServerHop()
    Notify("🔄 Cari server lain...")
    local cursor = ""
    while true do
        local url = ("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100%s")
            :format(PlaceID, cursor ~= "" and "&cursor="..cursor or "")

        local ok, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)

        if ok and result and result.data then
            for _, v in pairs(result.data) do
                if v.playing < v.maxPlayers and v.id ~= game.JobId then
                    Notify("➡️ Pindah server...")
                    TeleportService:TeleportToPlaceInstance(PlaceID, v.id, LocalPlayer)
                    return
                end
            end
            cursor = result.nextPageCursor or ""
            if cursor == "" then break end
        else
            break
        end
        task.wait(2)
    end
    Notify("⚠️ Tidak ada server, retry 5s...")
    task.wait(5)
    ServerHop()
end

-- 🔁 Main loop
task.spawn(function()
    while task.wait(2) do
        if CollectDiamonds() then
            -- kalau udah nemu diamond, tunggu bentar sebelum scan lagi
            task.wait(3)
        elseif OpenAllChests() then
            -- setelah buka chest, coba ambil diamond lagi
            task.wait(3)
        else
            -- kalau tidak ada diamond & chest, hop server
            ServerHop()
        end
    end
end)

Notify("✅ Diamond Farm Aktif")
