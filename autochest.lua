-- 🌲 99 Nights in the Forest - Auto Diamond Chest + Chest Checker + Serverhop + GUI Notify
local Http = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceID = game.PlaceId
local AllIDs = {}
local foundAnything = ""
local ScreenGui, TextLabel
local ChestCount = 0

------------------------------
-- Buat GUI Notifikasi
------------------------------
function CreateNotifyGui()
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

function Notify(msg)
    game.StarterGui:SetCore("ChatMakeSystemMessage", {
        Text = "[AutoFarm] " .. msg,
        Color = Color3.fromRGB(0,255,0)
    })

    if TextLabel then
        TextLabel.Text = msg
        TextLabel.Visible = true
        task.wait(2.5)
        TextLabel.Visible = false
    end
end

------------------------------
-- Fungsi buka chest (helper)
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
-- Fungsi cek diamond dalam chest
------------------------------
local function ChestHasDiamond(chest)
    for _, v in pairs(chest:GetDescendants()) do
        if v:IsA("MeshPart") or v:IsA("Part") then
            if string.find(v.Name:lower(), "diamond") then
                return true
            end
        end
    end
    return false
end

------------------------------
-- Auto Farm Chest Diamond
------------------------------
function FarmChests()
    local foundDiamond = false

    -- 🔹 Prioritas Diamond Chest
    for _, chest in pairs(workspace:GetDescendants()) do
        if chest:IsA("Model") and string.find(chest.Name:lower(), "diamond") then
            LocalPlayer.Character:MoveTo(chest.PrimaryPart.Position)
            task.wait(2)
            if OpenChest(chest) then
                ChestCount += 1
                foundDiamond = true
                Notify("💎 Diamond Chest dibuka! Total: " .. ChestCount)
            end
        end
    end

    -- 🔹 Kalau tidak ada Diamond Chest → cek chest biasa
    if not foundDiamond then
        for _, chest in pairs(workspace:GetDescendants()) do
            if chest:IsA("Model") and string.find(chest.Name:lower(), "chest") 
                and not string.find(chest.Name:lower(), "diamond") then

                if ChestHasDiamond(chest) then
                    LocalPlayer.Character:MoveTo(chest.PrimaryPart.Position)
                    task.wait(2)
                    if OpenChest(chest) then
                        ChestCount += 1
                        foundDiamond = true
                        Notify("✨ Chest biasa berisi diamond dibuka! Total: " .. ChestCount)
                    end
                end
            end
        end
    end

    -- 🔹 Kalau sama sekali tidak ada diamond → hop
    if not foundDiamond then
        Notify("❌ Tidak ada diamond → Pindah server...")
    end

    return foundDiamond
end

------------------------------
-- ServerHop
------------------------------
function TPReturner()
    local Site
    if foundAnything == "" then
        Site = game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=Asc&limit=100")
    else
        Site = game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=Asc&limit=100&cursor=" .. foundAnything)
    end
    local Servers = Http:JSONDecode(Site)
    if Servers.data then
        for i,v in pairs(Servers.data) do
            local Possible = true
            if tonumber(v.playing) < v.maxPlayers and v.id ~= game.JobId then
                for _,Existing in pairs(AllIDs) do
                    if v.id == tostring(Existing) then
                        Possible = false
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
