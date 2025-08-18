--// Auto Diamond Farm 99 Nights in the Forest
--// by jen nnn (modded version)

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

-- Ambil diamond di sekitar
local function CollectDiamonds()
    for _, drop in pairs(workspace:GetDescendants()) do
        if drop:IsA("Part") and drop.Name:lower():find("diamond") then
            HRP.CFrame = drop.CFrame + Vector3.new(0, 3, 0)
            local prompt = drop:FindFirstChildOfClass("ProximityPrompt")
            if prompt then
                fireproximityprompt(prompt)
            end
            task.wait(0.2)
        end
    end
end

-- Cari & buka semua chest
local function OpenAllChests()
    local chestFound = false
    for _, chest in pairs(workspace:GetDescendants()) do
        if chest:IsA("Model") and chest.Name:lower():find("chest") then
            local prompt = chest:FindFirstChildWhichIsA("ProximityPrompt", true)
            local pivot = chest.PrimaryPart or chest:FindFirstChild("ChestLid")

            if prompt and pivot then
                chestFound = true
                -- Teleport ke chest
                HRP.CFrame = pivot.CFrame + Vector3.new(0, 3, 0)
                task.wait(0.5)
                -- Buka
                fireproximityprompt(prompt)
                task.wait(1)
                -- Ambil diamond setelah buka
                CollectDiamonds()
            end
        end
    end
    return chestFound
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

    Notify("⚠️ Gagal cari server, retry...")
    task.wait(5)
    ServerHop()
end

-- Main loop
task.spawn(function()
    while task.wait(3) do
        local found = OpenAllChests()
        if not found then
            ServerHop()
        end
    end
end)

Notify("✅ Diamond Farm Aktif")
