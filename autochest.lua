-- // 99 Night in the Forest Auto Chest + Hop
-- // By ChatGPT

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

local PlaceID = game.PlaceId

-- Function untuk cari server
local function findServer()
    local cursor
    local servers = {}
    local req = nil

    repeat
        local url = "https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=Asc&limit=100" ..
            (cursor and "&cursor=" .. cursor or "")
        req = game:HttpGet(url)
        local data = HttpService:JSONDecode(req)
        for _, v in pairs(data.data) do
            if v.playing < v.maxPlayers then
                table.insert(servers, v.id)
            end
        end
        cursor = data.nextPageCursor
    until not cursor

    return servers
end

-- Function hop server dengan retry
local function hopServer()
    local servers = findServer()
    if #servers == 0 then
        warn("⚠️ Tidak ada server tersedia, coba lagi...")
        task.wait(5)
        return hopServer()
    end

    for _, serverId in ipairs(servers) do
        local success, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(PlaceID, serverId, LocalPlayer)
        end)

        if success then
            print("✅ Pindah ke server:", serverId)
            break
        else
            warn("❌ Teleport gagal:", err)
            task.wait(3) -- delay biar gak spam
        end
    end
end

-- Function untuk buka chest
local function openChest(chest)
    fireproximityprompt(chest:FindFirstChildWhichIsA("ProximityPrompt"))
    task.wait(1.5)

    -- cek kalau ada diamond
    local drops = workspace:GetChildren()
    local found = false
    for _, v in pairs(drops) do
        if v.Name:lower():find("diamond") then
            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, v, 0)
            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, v, 1)
            found = true
        end
    end

    if not found then
        print("⚠️ Tidak ada diamond, langsung hop...")
        hopServer()
    else
        print("💎 Diamond ditemukan!")
    end
end

-- Loop cek chest
while task.wait(3) do
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") and v.Parent.Name:lower():find("chest") then
            openChest(v.Parent)
        end
    end
end
