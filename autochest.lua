--// Auto Diamond Farm 99 Nights in the Forest
--// by jen nnn + optimize

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local PlaceID = game.PlaceId

-- Notif helper
local function Notify(txt)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "💎 Diamond Farm",
            Text = txt,
            Duration = 4
        })
    end)
end

-- Ambil diamond drop di map
local function CollectDiamonds()
    local found = false
    for _, drop in pairs(workspace:GetDescendants()) do
        if drop:IsA("Part") or drop:IsA("MeshPart") then
            if drop.Name:lower():find("diamond") then
                found = true
                Notify("💠 Ambil diamond...")
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

-- Buka semua chest di map
local function OpenAllChests()
    local opened = false
    for _, chest in pairs(workspace:GetDescendants()) do
        if chest:IsA("Model") and chest.Name:lower():find("chest") then
            local prompt = chest:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then
                opened = true
                Notify("📦 Buka chest...")
                -- Teleport ke chest
                if chest.PrimaryPart then
                    HRP.CFrame = chest.PrimaryPart.CFrame + Vector3.new(0, 3, 0)
                else
                    pcall(function()
                        HRP.CFrame = chest:GetModelCFrame()
                    end)
                end
                task.wait(0.5)
                fireproximityprompt(prompt)
                task.wait(1.2)
                CollectDiamonds()
            end
        end
    end
    return opened
end

-- ServerHop fix anti 771
local function ServerHop()
    Notify("🔄 Cari server lain...")
    local cursor = ""
    local tried = 0

    while tried < 5 do
        tried += 1
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
        else
            cursor = ""
        end
        task.wait(2)
    end

    -- Retry kalau gagal
    Notify("⚠️ Gagal cari server, retry...")
    task.wait(5)
    ServerHop()
end

-- Main loop
task.spawn(function()
    while task.wait(3) do
        -- Step 1: cek diamond dulu
        local gotDiamond = CollectDiamonds()
        if gotDiamond then
            Notify("✅ Diamond ditemukan!")
        else
            -- Step 2: kalau gak ada, buka semua chest
            local opened = OpenAllChests()
            task.wait(1)
            local after = CollectDiamonds()
            if not after then
                if not opened then
                    -- Step 3: kalau chest pun kosong → hop
                    ServerHop()
                else
                    -- kalau sudah buka chest tapi tetep kosong → hop juga
                    ServerHop()
                end
            end
        end
    end
end)

Notify("🚀 Auto Diamond Farm Aktif")
