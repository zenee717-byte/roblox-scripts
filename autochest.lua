-- 🌲 99 Nights in the Forest - Auto Diamond Chest Only
local Http = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceID = game.PlaceId
local AllIDs = {}
local foundAnything = ""
local ScreenGui, TextLabel
local ChestCount = 0 -- Counter

--------------------------
-- GUI Notifikasi
--------------------------
function CreateNotifyGui()
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(0, 350, 0, 50)
    TextLabel.Position = UDim2.new(0.5, -175, 0.9, 0)
    TextLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
    TextLabel.TextScaled = true
    TextLabel.Text = ""
    TextLabel.Visible = false
    TextLabel.Parent = ScreenGui
end

function Notify(msg)
    game.StarterGui:SetCore("ChatMakeSystemMessage", {
        Text = "[AutoDiamond] " .. msg,
        Color = Color3.fromRGB(0,255,255)
    })
    if TextLabel then
        TextLabel.Text = msg
        TextLabel.Visible = true
        task.wait(2.5)
        TextLabel.Visible = false
    end
end

--------------------------
-- Auto Ambil Diamond Chest
--------------------------
function FarmDiamondChest()
    local found = false
    for _, chest in pairs(workspace:GetDescendants()) do
        if chest:IsA("Model") and chest.Name:lower():find("diamond") then
            if chest:FindFirstChild("PrimaryPart") then
                found = true
                LocalPlayer.Character:MoveTo(chest.PrimaryPart.Position + Vector3.new(0,3,0))
                task.wait(2)
                for _, v in pairs(chest:GetDescendants()) do
                    if v:IsA("ClickDetector") then
                        fireclickdetector(v)
                        ChestCount += 1
                        Notify("✅ Diamond Chest dibuka! Total: " .. ChestCount)
                    end
                    if v:IsA("ProximityPrompt") then
                        fireproximityprompt(v)
                        ChestCount += 1
                        Notify("✅ Diamond Chest dibuka! Total: " .. ChestCount)
                    end
                end
            end
        end
    end
    if not found then
        Notify("❌ Tidak ada Diamond Chest → Serverhop...")
    end
    return found
end

--------------------------
-- ServerHop Diamond Only
--------------------------
function TPReturner()
    local Site
    if foundAnything == "" then
        Site = game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=Asc&limit=100")
    else
        Site = game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=Asc&limit=100&cursor=" .. foundAnything)
    end
    local Servers = Http:JSONDecode(Site)
    if Servers.data then
        for _,v in pairs(Servers.data) do
            local Possible = true
            if tonumber(v.playing) < v.maxPlayers and v.id ~= game.JobId then
                for _,Existing in pairs(AllIDs) do
                    if v.id == tostring(Existing) then
                        Possible = false
                    end
                end
                if Possible then
                    table.insert(AllIDs, v.id)
                    Notify("🔄 Teleport ke server lain cari Diamond Chest...")
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

--------------------------
-- MAIN LOOP
--------------------------
CreateNotifyGui()

while task.wait(5) do
    local got = FarmDiamondChest()
    task.wait(3)
    if not got then
        TPReturner()
    end
end
