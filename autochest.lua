-- Auto Chest Hunter + Safe Server Hop (Only Diamond)
-- Fix: Hop hanya kalau dapat diamond

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
    print("[NOTIFY] " .. msg)
end

-- Teleport Helper
local function TeleportTo(pos)
    if HRP then
        HRP.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
    end
end

---------------------------------------------------------------------
-- Open Chest (return true kalau sukses)
local function OpenChest(chest)
    if not chest or not chest.PrimaryPart then return false end
    local success = false

    -- geser dekat chest
    TeleportTo(chest.PrimaryPart.Position + chest.PrimaryPart.CFrame.LookVector * 2)

    for i = 1, 20 do
        for _, v in ipairs(chest:GetDescendants()) do
            if v:IsA("ProximityPrompt") and v.ActionText:lower():find("open") then
                if v.Enabled then
                    fireproximityprompt(v, 1)
                    task.wait(0.2)
                    fireproximityprompt(v, 0)
                    success = true
                    Notify("📦 Chest terbuka!")
                    return true
                end
            elseif v:IsA("ClickDetector") then
                fireclickdetector(v)
                success = true
                Notify("📦 Chest terbuka (ClickDetector)!")
                return true
            end
        end
        task.wait(0.3)
    end

    return success
end

-- Collect Drop → return true kalau ada diamond
local function CollectDrops()
    local gotDiamond = false
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("TouchTransmitter") and obj.Parent then
            firetouchinterest(HRP, obj.Parent, 0)
            firetouchinterest(HRP, obj.Parent, 1)
            -- cek nama / parent mengandung "Diamond"
            if obj.Parent.Name:lower():find("diamond") then
                gotDiamond = true
                Notify("💎 Diamond ditemukan & diambil!")
            end
        end
    end
    return gotDiamond
end

---------------------------------------------------------------------
-- Server Hop
local function TPReturner()
    local body = game:HttpGet("https://games.roblox.com/v1/games/"..PlaceID.."/servers/Public?sortOrder=Asc&limit=100")
    local data = Http:JSONDecode(body)

    for _, v in ipairs(data.data) do
        if v.playing < v.maxPlayers and v.id ~= game.JobId then
            Notify("🔄 Hop ke server "..v.id)
            local success = pcall(function()
                TeleportService:TeleportToPlaceInstance(PlaceID, v.id, LocalPlayer)
            end)

            -- retry jika gagal
            task.delay(5, function()
                if LocalPlayer.Parent == Players then
                    Notify("❌ Teleport gagal, coba lagi")
                    TPReturner()
                end
            end)
            return
        end
    end
    task.delay(5, TPReturner)
end

TeleportService.TeleportInitFailed:Connect(function(_, result)
    Notify("⚠️ Teleport gagal: "..tostring(result).." → retry...")
    task.delay(3, TPReturner)
end)

---------------------------------------------------------------------
-- Main Loop
task.spawn(function()
    while task.wait(2) do
        for _, chest in ipairs(workspace:GetDescendants()) do
            if chest:IsA("Model") and chest.Name:lower():find("chest") then
                Notify("➡️ Menuju chest: "..chest.Name)
                local opened = OpenChest(chest)

                if opened then
                    task.wait(1)
                    local gotDiamond = CollectDrops()

                    if gotDiamond then
                        task.wait(2)
                        TPReturner() -- hop hanya kalau diamond ketemu
                    else
                        Notify("❌ Chest tidak ada diamond, skip...")
                    end
                else
                    Notify("❌ Chest gagal dibuka, skip...")
                end
            end
        end
    end
end)
