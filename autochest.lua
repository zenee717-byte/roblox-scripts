-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")
local Http = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local PlaceID = game.PlaceId

-- Variables
local ScreenGui, TextLabel
local DiamondCount = 0
local AllIDs = {}
local foundAnything = ""

------------------------------
-- GUI Notify
------------------------------
local function CreateNotifyGui()
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(0, 350, 0, 50)
    TextLabel.Position = UDim2.new(0.5, -175, 0.9, 0)
    TextLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    TextLabel.TextScaled = true
    TextLabel.Text = ""
    TextLabel.Visible = false
    TextLabel.Parent = ScreenGui
end

local function Notify(msg)
    pcall(function()
        game.StarterGui:SetCore("ChatMakeSystemMessage", {
            Text = "[AutoFarm] " .. msg,
            Color = Color3.fromRGB(0,255,0)
        })
    end)

    if TextLabel then
        coroutine.wrap(function()
            TextLabel.Text = msg
            TextLabel.Visible = true
            task.wait(2.5)
            TextLabel.Visible = false
        end)()
    end
end

------------------------------
-- Fungsi Ambil Diamond
------------------------------
local function PickupDiamond(diamond)
    if not diamond then return false end
    local picked = false

    local prompt = diamond:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        fireproximityprompt(prompt)
        picked = true
    end

    local touchPart = diamond:FindFirstChildWhichIsA("TouchTransmitter", true)
    if touchPart then
        firetouchinterest(HRP, diamond, 0)
        firetouchinterest(HRP, diamond, 1)
        picked = true
    end

    if picked then
        DiamondCount += 1
        Notify("💎 Diamond diambil! Total: " .. DiamondCount)
    end

    return picked
end

------------------------------
-- Fungsi buka chest
------------------------------
local function OpenChest(chest)
    for _, v in pairs(chest:GetDescendants()) do
        if v:IsA("ClickDetector") then
            fireclickdetector(v)
            return true
        elseif v:IsA("ProximityPrompt") then
            fireproximityprompt(v)
            return true
        end
    end
    return false
end

------------------------------
-- Auto Farm Chest Diamond
------------------------------
local function FarmChests()
    local chests = {}
    for _, chest in pairs(workspace:GetDescendants()) do
        if chest:IsA("Model") and chest.PrimaryPart then
            if string.find(chest.Name:lower(), "chest") then
                table.insert(chests, chest)
            end
        end
    end

    for _, chest in ipairs(chests) do
        Character:MoveTo(chest.PrimaryPart.Position)
        task.wait(1.5)

        -- Buka chest
        OpenChest(chest)
        task.wait(1)

        -- Cek diamond beberapa kali (biar sempet drop)
        local foundDiamond = false
        for i = 1, 6 do
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Part") or obj:IsA("MeshPart") then
                    if obj.Name:lower():match("diamond") then
                        Character:MoveTo(obj.Position)
                        task.wait(0.3)
                        if PickupDiamond(obj) then
                            foundDiamond = true
                        end
                    end
                end
            end
            if foundDiamond then break end
            task.wait(0.5) -- tunggu diamond spawn
        end

        if not foundDiamond then
            Notify("❌ Tidak ada diamond → Pindah server...")
            return false -- langsung hop
        else
            Notify("✅ Diamond ditemukan → lanjut ambil lagi di server ini")
            return true
        end
    end

    Notify("⚠️ Tidak ada chest ditemukan di server ini...")
    return false
end

------------------------------
-- ServerHop dengan retry aman
------------------------------
local function TPReturner()
    while true do
        local Site
        if foundAnything == "" then
            Site = game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=Asc&limit=100")
        else
            Site = game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=Asc&limit=100&cursor=" .. foundAnything)
        end

        local Servers = Http:JSONDecode(Site)
        if Servers.data then
            for _, v in pairs(Servers.data) do
                if tonumber(v.playing) < v.maxPlayers and v.id ~= game.JobId then
                    local already = false
                    for _, existing in pairs(AllIDs) do
                        if v.id == tostring(existing) then
                            already = true
                            break
                        end
                    end
                    if not already then
                        table.insert(AllIDs, v.id)
                        Notify("🔄 Teleport ke server baru: " .. v.id)
                        local success, err = pcall(function()
                            TeleportService:TeleportToPlaceInstance(PlaceID, v.id, LocalPlayer)
                        end)
                        if not success then
                            Notify("❌ Gagal teleport: " .. err .. " → coba lagi...")
                        else
                            return
                        end
                    end
                end
            end
        end

        if Servers.nextPageCursor then
            foundAnything = Servers.nextPageCursor
        else
            foundAnything = ""
        end

        task.wait(2) -- tunggu sebentar sebelum coba ulang
    end
end

------------------------------
-- MAIN LOOP
------------------------------
CreateNotifyGui()

while task.wait(5) do
    local success = FarmChests()
    if not success then
        TPReturner()
        break -- hentikan loop karena teleport akan handle loop lagi
    end
end
