--// Auto Diamond Farm 99 Nights in the Forest
--// by jen nnn

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local PlaceID = game.PlaceId

-- Notif helper
local function Notify(txt)
    game.StarterGui:SetCore("SendNotification", {
        Title = "💎 Diamond Farm",
        Text = txt,
        Duration = 4
    })
end

-- Ambil diamond di sekitar
local function CollectDiamonds()
    for _, drop in pairs(workspace:GetDescendants()) do
        if drop:IsA("Part") and drop.Name:lower():find("diamond") then
            HRP.CFrame = drop.CFrame + Vector3.new(0, 2, 0)
            fireproximityprompt(drop:FindFirstChildOfClass("ProximityPrompt"))
            task.wait(0.2)
        end
    end
end

-- Buka chest yang ada diamond
local function SearchChest()
    for _, chest in pairs(workspace:GetDescendants()) do
        if chest:IsA("Model") and chest.Name:lower():find("chest") then
            if chest:FindFirstChildWhichIsA("ProximityPrompt") then
                -- Teleport ke chest
                HRP.CFrame = chest.PrimaryPart and chest.PrimaryPart.CFrame + Vector3.new(0,3,0) or chest:GetModelCFrame()
                task.wait(0.5)
                -- Buka
                fireproximityprompt(chest:FindFirstChildWhichIsA("ProximityPrompt"))
                task.wait(1)
                -- Ambil diamond kalau drop
                CollectDiamonds()
                return true
            end
        end
    end
    return false
end

-- ServerHop fix anti 771
local function ServerHop()
    Notify("🔄 Cari server lain...")
    local cursor = ""
    local success = false
    local tried = 0

    while not success and tried < 5 do
        tried += 1
        local url = ("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100%s")
            :format(PlaceID, cursor ~= "" and "&cursor="..cursor or "")

        local ok, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)

        if ok and result and result.data then
            for _, v in pairs(result.data) do
                if v.playing < v.maxPlayers and v.id ~= game.JobId then
                    success = true
                    Notify("➡️ Pindah server...")
                    TeleportService:TeleportToPlaceInstance(PlaceID, v.id, LocalPlayer)
                    break
                end
            end
            cursor = result.nextPageCursor or ""
        else
            cursor = ""
        end
        task.wait(2)
    end

    if not success then
        Notify("⚠️ Gagal cari server, retry...")
        task.wait(5)
        ServerHop()
    end
end

-- Main loop
task.spawn(function()
    while task.wait(2) do
        local found = SearchChest()
        if not found then
            ServerHop()
        end
    end
end)

Notify("✅ Diamond Farm Aktif")
