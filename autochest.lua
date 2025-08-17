-- 🌲 99 Nights in the Forest - Auto Diamond Chest + Drop Checker + Serverhop + GUI Notify
local Http = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceID = game.PlaceId
local AllIDs = {}
local foundAnything = ""
local ScreenGui, TextLabel
local DiamondCount = 0

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
        TextLabel.Text = msg
        TextLabel.Visible = true
        task.wait(2.5)
        TextLabel.Visible = false
    end
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
-- Fungsi ambil diamond drop
------------------------------
local function TakeDiamonds()
    local taken = 0
    for _, drop in pairs(workspace:GetDescendants()) do
        if drop:IsA("Part") or drop:IsA("MeshPart") then
            if string.find(drop.Name:lower(), "diamond") then
                if (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) then
                    LocalPlayer.Character:MoveTo(drop.Position)
                    task.wait(0.5)
                    taken += 1
                end
            end
        end
    end
    return taken
end

------------------------------
-- Auto Farm Chest Diamond
------------------------------
local function FarmChests()
    local foundDiamond = false

    -- Cek Diamond Chest dulu
    for _, chest in pairs(workspace:GetDescendants()) do
        if chest:IsA("Model") and string.find(chest.Name:lower(), "diamond") and chest.PrimaryPart then
            LocalPlayer.Character:MoveTo(chest.PrimaryPart.Position)
            task.wait(2)
            OpenChest(chest)
            task.wait(2)

            local got = TakeDiamonds()
            if got > 0 then
                DiamondCount += got
                foundDiamond = true
                Notify("💎 Dapat " .. got .. " diamond! Total: " .. DiamondCount)
            end
        end
    end

    -- Kalau ga ada Diamond Chest → cek chest biasa
    if not foundDiamond then
        for _, chest in pairs(workspace:GetDescendants()) do
            if chest:IsA("Model") and string.find(chest.Name:lower(), "chest") 
                and not string.find(chest.Name:lower(), "diamond") and chest.PrimaryPart then

                LocalPlayer.Character:MoveTo(chest.PrimaryPart.Position)
                task.wait(2)
                OpenChest(chest)
                task.wait(2)

                local got = TakeDiamonds()
                if got > 0 then
                    DiamondCount += got
                    foundDiamond = true
                    Notify("✨ Dapat " .. got .. " diamond dari chest biasa! Total: " .. DiamondCount)
                end
            end
        end
    end

    -- Kalau tidak ada diamond sama sekali → serverhop
    if not foundDiamond then
        Notify("❌ Tidak ada diamond → Pindah server...")
    end

    return foundDiamond
end

------------------------------
-- ServerHop
------------------------------
local function TPReturner()
    local Site
    if foundAnything == "" then
        Site = game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=Asc&limit=100")
    else
        Site = game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=Asc&limit=100&cursor=" .. foundAnything)
    end

    local Servers = Http:JSONDecode(Site)
    if Servers.data then
        for _, v in pairs(Servers.data) do
            local Possible = true
            if tonumber(v.playing) < v.maxPlayers and v.id ~= game.JobId then
                for _, Existing in pairs(AllIDs) do
                    if v.id == tostring(Existing) then
                        Possible = false
                        break
                    end
                end
                if Possible then
                    table.insert(AllIDs, v.id)
                    Notify("🔄 Teleport ke server baru...")
                    TeleportService:TeleportToPlaceInstance(PlaceID, v.id, LocalPlayer)
                    task.wait(4)
                end
            end
        end
    end
    if Servers.nextPageCursor then
        foundAnything = Servers.nextPageCursor
    else
        foundAnything = ""
    end
end

------------------------------
-- MAIN LOOP
------------------------------
CreateNotifyGui()

while task.wait(5) do
    local success = FarmChests()
    task.wait(3)
    if not success then
        TPReturner()
    end
end
