-- 🌲 99 Nights in the Forest - Auto Farm Diamond Chest Only + Serverhop + Notifikasi + Counter
local Http = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceID = game.PlaceId
local AllIDs = {}
local foundAnything = ""
local ScreenGui, TextLabel
local ChestCount = 0 -- 🔢 Counter Diamond chest

------------------------------
-- Buat GUI Notifikasi --
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
    -- Chat message
    game.StarterGui:SetCore("ChatMakeSystemMessage", {
        Text = "[AutoFarm] " .. msg,
        Color = Color3.fromRGB(0,255,0)
    })

    -- Popup GUI
    if TextLabel then
        TextLabel.Text = msg
        TextLabel.Visible = true
        task.wait(2.5)
        TextLabel.Visible = false
    end
end

------------------------------
-- Fungsi Auto Ambil Diamond Chest --
------------------------------
function FarmDiamondChests()
    local found = false
    for i, chest in pairs(workspace:GetDescendants()) do
        -- Hanya buka chest yang ada kata "diamond"
        if chest:IsA("Model") and string.find(chest.Name:lower(), "diamond") then
            found = true
            if chest.PrimaryPart then
                LocalPlayer.Character:MoveTo(chest.PrimaryPart.Position)
                task.wait(2)
            end
            for _, v in pairs(chest:GetDescendants()) do
                if v:IsA("ClickDetector") then
                    fireclickdetector(v)
                    ChestCount += 1
                    Notify("💎 Diamond Chest dibuka! Total: " .. ChestCount)
                end
                if v:IsA("ProximityPrompt") then
                    fireproximityprompt(v)
                    ChestCount += 1
                    Notify("💎 Diamond Chest dibuka! Total: " .. ChestCount)
                end
            end
        end
    end
    if not found then
        Notify("💨 Tidak ada Diamond Chest → Pindah server...")
    end
end

------------------------------
-- Fungsi ServerHop --
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
-- MAIN LOOP --
------------------------------
CreateNotifyGui()

while task.wait(5) do
    FarmDiamondChests()
    task.wait(3)
    TPReturner()
end
