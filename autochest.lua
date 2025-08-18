-- Auto Fast Diamond Farm 99 Nights (Efisien & Debug)
-- by ChatGPT + Jen nnn

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local PlaceID = game.PlaceId

local function Notify(txt)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "💎 Fast Farm",
            Text = txt,
            Duration = 3
        })
    end)
end

-- Fungsi collect diamond lebih fleksibel
local function CollectDiamonds()
    local collected = 0
    for _, drop in ipairs(workspace:GetDescendants()) do
        -- Termasuk Part, MeshPart, UnionOperation
        if (drop:IsA("Part") or drop:IsA("MeshPart") or drop:IsA("UnionOperation")) 
            and drop.Name:lower():find("diamond") then

            print("[DEBUG] Found diamond:", drop.Name) -- log debug

            -- teleport sedikit di atas diamond
            HRP.CFrame = drop.CFrame + Vector3.new(0,2,0)
            task.wait(0.25)

            -- cek jika ada ProximityPrompt
            local prompt = drop:FindFirstChildOfClass("ProximityPrompt")
            if prompt and prompt.Enabled then
                fireproximityprompt(prompt)
                collected += 1
                print("[DEBUG] Collected diamond via prompt:", drop.Name)
                task.wait(0.2)
            else
                -- Jika tidak ada prompt, coba pakai touch (klik client-side)
                local success, err = pcall(function()
                    drop.CanCollide = false
                    drop.Anchored = true
                    -- teleport sedikit untuk "touch"
                    HRP.CFrame = drop.CFrame + Vector3.new(0,2,0)
                    task.wait(0.15)
                end)
                if success then
                    collected += 1
                    print("[DEBUG] Collected diamond via manual touch:", drop.Name)
                end
            end
        end
    end
    return collected
end

local function OpenAllChests()
    local opened = 0
    for _, chest in ipairs(workspace:GetDescendants()) do
        if chest:IsA("Model") and chest.Name:lower():find("chest") then
            local prompt = chest:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt and chest.PrimaryPart and prompt.Enabled then
                HRP.CFrame = chest.PrimaryPart.CFrame + Vector3.new(0, 3, 0)
                task.wait(0.2)
                fireproximityprompt(prompt)
                opened += 1
                task.wait(0.4)
            end
        end
    end
    return opened
end

local function ServerHop()
    Notify("🔄 ServerHop...")
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
            for _, v in ipairs(result.data) do
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
        task.wait(1)
    end
    Notify("⚠️ Retry ServerHop...")
    task.wait(3)
    ServerHop()
end

task.spawn(function()
    while true do
        local opened = OpenAllChests()
        if opened > 0 then
            Notify("🗝️ Chest dibuka: "..opened)
            task.wait(2.5)
        else
            Notify("❌ Tidak ada chest ditemukan.")
        end

        local got = CollectDiamonds()
        if got > 0 then
            Notify("✅ Dapat "..got.." Diamond!")
        else
            Notify("❌ Tidak ada diamond ditemukan.")
        end

        task.wait(1)
        ServerHop()
        task.wait(2)
    end
end)

Notify("🚀 Fast Diamond Farm Aktif!")
