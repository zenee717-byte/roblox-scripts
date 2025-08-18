-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")
local Http = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local PlaceID = game.PlaceId

-- Variables
local DiamondCount = 0
local AllIDs = {}
local foundAnything = ""

------------------------------
-- GUI Notify
------------------------------
local function Notify(msg)
    pcall(function()
        game.StarterGui:SetCore("ChatMakeSystemMessage", {
            Text = "[AutoFarm] " .. msg,
            Color = Color3.fromRGB(0,255,0)
        })
    end)
end

------------------------------
-- Pickup Diamond
------------------------------
local function PickupDiamond(diamond)
    if not diamond then return false end
    local picked = false

    local prompt = diamond:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        fireproximityprompt(prompt)
        picked = true
    end

    local touch = diamond:FindFirstChildWhichIsA("TouchTransmitter", true)
    if touch then
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
-- Open Chest + Cek Drop
------------------------------
local function OpenChest(chest, waitTime)
    for _, v in pairs(chest:GetDescendants()) do
        if v:IsA("ClickDetector") then
            fireclickdetector(v)
        elseif v:IsA("ProximityPrompt") then
            fireproximityprompt(v)
        end
    end

    -- tunggu drop spawn
    task.wait(waitTime)

    local gotDiamond = false
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Part") or obj:IsA("MeshPart") then
            if obj.Name:lower():match("diamond") then
                Character:MoveTo(obj.Position)
                task.wait(0.3)
                if PickupDiamond(obj) then
                    gotDiamond = true
                end
            end
        end
    end

    return gotDiamond
end

------------------------------
-- Server Hop
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

        for _, v in pairs(Servers.data) do
            if tonumber(v.playing) < v.maxPlayers and v.id ~= game.JobId then
                local skip = false
                for _, id in pairs(AllIDs) do
                    if id == v.id then skip = true break end
                end
                if not skip then
                    table.insert(AllIDs, v.id)
                    Notify("🔄 Server hop ke: " .. v.id)
                    local success = pcall(function()
                        TeleportService:TeleportToPlaceInstance(PlaceID, v.id, LocalPlayer)
                    end)
                    if success then return else
                        Notify("❌ Gagal teleport, cari server lain...")
                    end
                end
            end
        end

        if Servers.nextPageCursor then
            foundAnything = Servers.nextPageCursor
        else
            foundAnything = ""
        end
        task.wait(2)
    end
end

------------------------------
-- Main
------------------------------
while task.wait(3) do
    local found = false

    -- cari chest
    for _, chest in pairs(workspace:GetDescendants()) do
        if chest:IsA("Model") and chest.PrimaryPart then
            if string.find(chest.Name:lower(), "diamond") then
                Character:MoveTo(chest.PrimaryPart.Position)
                task.wait(1.5)
                local success = OpenChest(chest, 6) -- diamond chest tunggu lebih lama
                if success then
                    found = true
                    TPReturner()
                    break
                else
                    TPReturner()
                    break
                end
            elseif string.find(chest.Name:lower(), "chest") then
                Character:MoveTo(chest.PrimaryPart.Position)
                task.wait(1.5)
                local success = OpenChest(chest, 2) -- chest biasa tunggu sebentar
                if success then
                    found = true
                    TPReturner()
                    break
                else
                    TPReturner()
                    break
                end
            end
        end
    end

    if not found then
        Notify("❌ Tidak ada chest → server hop")
        TPReturner()
    end
end
