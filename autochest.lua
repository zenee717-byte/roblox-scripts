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
    if not diamond then return end

    -- ProximityPrompt
    local prompt = diamond:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        fireproximityprompt(prompt)
        DiamondCount += 1
        Notify("💎 Diamond diambil! Total: " .. DiamondCount)
        return
    end

    -- TouchInterest
    local touchPart = diamond:FindFirstChildWhichIsA("TouchTransmitter", true)
    if touchPart then
        firetouchinterest(HRP, diamond, 0)
        firetouchinterest(HRP, diamond, 1)
        DiamondCount += 1
        Notify("💎 Diamond diambil! Total: " .. DiamondCount)
        return
    end

    print("⚠️ Diamond ditemukan tapi tidak ada cara ambil (mungkin RemoteEvent).")
end

-- Auto-collect diamond yang spawn baru
game.Workspace.ChildAdded:Connect(function(child)
    if child.Name:lower():match("diamond") then
        task.wait(0.2)
        PickupDiamond(child)
    end
end)

-- Auto-collect diamond yang sudah ada
for _, child in ipairs(game.Workspace:GetChildren()) do
    if child.Name:lower():match("diamond") then
        PickupDiamond(child)
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
-- Auto Farm Chest Diamond
------------------------------
local function FarmChests()
    local foundDiamond = false

    -- Cek Diamond Chest
    for _, chest in pairs(workspace:GetDescendants()) do
        if chest:IsA("Model") and string.find(chest.Name:lower(), "diamond") and chest.PrimaryPart then
            Character:MoveTo(chest.PrimaryPart.Position)
            task.wait(1.5)
            OpenChest(chest)
            task.wait(1)
            foundDiamond = true
        end
    end

    -- Cek chest biasa kalau diamond chest tidak ada
    if not foundDiamond then
        for _, chest in pairs(workspace:GetDescendants()) do
            if chest:IsA("Model") and string.find(chest.Name:lower(), "chest") 
                and not string.find(chest.Name:lower(), "diamond") and chest.PrimaryPart then

                Character:MoveTo(chest.PrimaryPart.Position)
                task.wait(1.5)
                OpenChest(chest)
                task.wait(1)
                foundDiamond = true
            end
        end
    end

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
                    Notify("🔄 Teleport ke server baru...")
                    TeleportService:TeleportToPlaceInstance(PlaceID, v.id, LocalPlayer)
                    return -- hentikan loop setelah teleport
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
    task.wait(2)
    if not success then
        TPReturner()
        break -- hentikan loop saat teleport
    end
end
