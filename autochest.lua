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

    -- ProximityPrompt
    local prompt = diamond:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        fireproximityprompt(prompt)
        picked = true
    end

    -- TouchInterest
    local touchPart = diamond:FindFirstChildWhichIsA("TouchTransmitter", true)
    if touchPart then
        firetouchinterest(HRP, diamond, 0)
        firetouchinterest(HRP, diamond, 1)
        picked = true
    end

    if picked then
        DiamondCount += 1
        Notify("💎 Diamond diambil! Total: " .. DiamondCount)
    else
        print("⚠️ Diamond ditemukan tapi tidak ada cara ambil (mungkin RemoteEvent).")
    end

    return picked
end

-- Auto-collect diamond spawn baru
game.Workspace.ChildAdded:Connect(function(child)
    if child.Name:lower():match("diamond") then
        task.wait(0.2)
        PickupDiamond(child)
    end
end)

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
    local anyDiamondFound = false

    -- Ambil semua chest (diamond chest dulu, chest biasa nanti)
    local chests = {}
    for _, chest in pairs(workspace:GetDescendants()) do
        if chest:IsA("Model") and chest.PrimaryPart then
            if string.find(chest.Name:lower(), "diamond") then
                table.insert(chests, chest)
            elseif string.find(chest.Name:lower(), "chest") then
                table.insert(chests, chest)
            end
        end
    end

    for _, chest in ipairs(chests) do
        -- Pindah ke chest
        Character:MoveTo(chest.PrimaryPart.Position)
        task.wait(1.5)

        -- Buka chest
        local opened = OpenChest(chest)
        task.wait(1)

        -- Ambil semua diamond yang dekat chest
        local pickedCount = 0
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Part") or obj:IsA("MeshPart") then
                if obj.Name:lower():match("diamond") then
                    if (Character and HRP) then
                        Character:MoveTo(obj.Position)
                        task.wait(0.3)
                        if PickupDiamond(obj) then
                            pickedCount += 1
                        end
                    end
                end
            end
        end

        if pickedCount > 0 then
            anyDiamondFound = true
        end
    end

    if not anyDiamondFound then
        Notify("❌ Tidak ada diamond → Pindah server...")
    end

    return anyDiamondFound
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
                    return
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
