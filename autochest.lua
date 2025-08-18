-- // Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")
local Http = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local PlaceID = game.PlaceId

-- // Variables
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
-- Fungsi Teleport Cepat
------------------------------
local function TeleportTo(pos)
    if HRP then
        HRP.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
    end
end

------------------------------
-- Fungsi Ambil Diamond
------------------------------
local function PickupDiamond(diamond)
    if not diamond then return false end
    local picked = false

    for _, v in ipairs(diamond:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            fireproximityprompt(v)
            picked = true
        elseif v:IsA("ClickDetector") then
            fireclickdetector(v)
            picked = true
        elseif v:IsA("TouchTransmitter") then
            firetouchinterest(HRP, diamond, 0)
            firetouchinterest(HRP, diamond, 1)
            picked = true
        end
    end

    if picked then
        DiamondCount += 1
        Notify("💎 Diamond diambil! Total: " .. DiamondCount)
    end

    return picked
end

-- Auto-collect diamond spawn baru
workspace.DescendantAdded:Connect(function(obj)
    if obj.Name:lower():match("diamond") then
        task.wait(0.2)
        PickupDiamond(obj)
    end
end)

------------------------------
-- Fungsi buka chest
------------------------------
local function OpenChest(chest)
    for _, v in ipairs(chest:GetDescendants()) do
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
    local anyDiamondFound = false
    local chests = {}

    for _, chest in ipairs(workspace:GetDescendants()) do
        if chest:IsA("Model") and chest.PrimaryPart and chest.Name:lower():match("chest") then
            table.insert(chests, chest)
        end
    end

    for _, chest in ipairs(chests) do
        TeleportTo(chest.PrimaryPart.Position)
        task.wait(0.5)
        OpenChest(chest)

        -- tunggu diamond spawn (cek 10x setiap 0.5s)
        for i = 1, 10 do
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name:lower():match("diamond") then
                    TeleportTo(obj.Position)
                    task.wait(0.2)
                    if PickupDiamond(obj) then
                        anyDiamondFound = true
                    end
                end
            end
            task.wait(0.5)
        end
    end

    if not anyDiamondFound then
        Notify("❌ Tidak ada diamond → Pindah server...")
    end

    return anyDiamondFound
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
        local foundServer = false

        if Servers.data then
            for _, v in ipairs(Servers.data) do
                if tonumber(v.playing) < v.maxPlayers and v.id ~= game.JobId then
                    local already = false
                    for _, existing in ipairs(AllIDs) do
                        if v.id == tostring(existing) then
                            already = true
                            break
                        end
                    end
                    if not already then
                        table.insert(AllIDs, v.id)
                        Notify("🔄 Teleport ke server baru: "..v.id)
                        local success, err = pcall(function()
                            TeleportService:TeleportToPlaceInstance(PlaceID, v.id, LocalPlayer)
                        end)
                        if success then
                            return
                        else
                            Notify("❌ Gagal teleport: "..err.." → mencoba server lain...")
                        end
                    end
                end
            end
        end

        -- Next page
        if Servers.nextPageCursor then
            foundAnything = Servers.nextPageCursor
        else
            foundAnything = ""
            -- fallback teleport ke server random
            Notify("⚠️ Semua server penuh → teleport random...")
            TeleportService:Teleport(PlaceID, LocalPlayer)
        end

        task.wait(2)
    end
end

------------------------------
-- MAIN LOOP
------------------------------
CreateNotifyGui()

while task.wait(5) do
    local success = FarmChests()
    task.wait(2)
    if not success then
        TPReturner() -- tidak ada break, biar selalu lanjut
    end
end
