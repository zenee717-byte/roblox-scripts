--// Fast Diamond Farm - 99 Nights in the Forest
--// Aggressive Version + Diamond Counter UI

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local PlaceID = game.PlaceId

-- === Diamond Counter ===
local diamondCount = 0

-- Buat UI ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DiamondCounterUI"
ScreenGui.Parent = PlayerGui

local CounterLabel = Instance.new("TextLabel")
CounterLabel.Size = UDim2.new(0, 200, 0, 50)
CounterLabel.Position = UDim2.new(0.5, -100, 0.05, 0)
CounterLabel.BackgroundTransparency = 0.3
CounterLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CounterLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
CounterLabel.TextScaled = true
CounterLabel.Font = Enum.Font.GothamBold
CounterLabel.Text = "💎 Diamonds: 0"
CounterLabel.Parent = ScreenGui

-- Update Counter UI
local function UpdateCounter()
    CounterLabel.Text = "💎 Diamonds: " .. diamondCount
end

-- === Notif Helper ===
local function Notify(txt)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "💎 Diamond Farm",
            Text = txt,
            Duration = 4
        })
    end)
end

-- === Update Character saat mati ===
local function UpdateChar()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    HRP = Character:WaitForChild("HumanoidRootPart")
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    UpdateChar()
    Notify("⚰️ Respawn terdeteksi, lanjut farming...")
end)

UpdateChar()

-- === Ambil diamond drop di sekitar ===
local function CollectDiamonds()
    for _, drop in pairs(workspace:GetDescendants()) do
        if drop:IsA("Part") and drop.Name:lower():find("diamond") then
            HRP.CFrame = drop.CFrame + Vector3.new(0, 3, 0)
            task.wait(0.2)
            local prox = drop:FindFirstChildOfClass("ProximityPrompt")
            if prox then
                fireproximityprompt(prox)
                diamondCount += 1
                UpdateCounter()
                Notify("✅ Dapat diamond! Total: " .. diamondCount)
            end
            task.wait(0.3)
        end
    end
end

-- === Cari chest & buka ===
local function OpenChests()
    for _, chest in pairs(workspace:GetDescendants()) do
        if chest:IsA("Model") and chest.Name:lower():find("chest") then
            local prompt = chest:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then
                if prompt.Enabled then
                    -- ✅ Bisa dibuka
                    HRP.CFrame = chest.PrimaryPart and chest.PrimaryPart.CFrame + Vector3.new(0, 3, 0) or chest:GetModelCFrame()
                    task.wait(0.3)
                    fireproximityprompt(prompt)
                    task.wait(0.8)
                    CollectDiamonds()
                    return true
                else
                    -- ❌ Chest ada tapi terkunci (Stronghold belum selesai)
                    return false
                end
            end
        end
    end
    return nil -- tidak ada chest sama sekali
end

-- === ServerHop ===
local function ServerHop()
    Notify("🔄 ServerHop...")
    local cursor = ""
    local success = false

    for _ = 1, 5 do
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
                    success = true
                    break
                end
            end
            if success then break end
            cursor = result.nextPageCursor or ""
        else
            cursor = ""
        end
        task.wait(1)
    end

    if not success then
        Notify("⚠️ Gagal cari server, retry 5 detik...")
        task.wait(5)
        ServerHop()
    end
end

-- === Main Loop ===
task.spawn(function()
    while task.wait(0.5) do
        local chestStatus = OpenChests()
        if chestStatus == false then
            -- chest ada tapi terkunci
            ServerHop()
        elseif chestStatus == nil then
            -- tidak ada chest sama sekali
            ServerHop()
        end
    end
end)

Notify("✅ Fast Diamond Farm Aktif dengan Counter")
