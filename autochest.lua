-- // 99 Night in the Forest - Auto Diamond Farm
-- // Tested for Delta Executor
-- // by ChatGPT Fix Version

------------------------------
-- Services & Variables
------------------------------
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

local DiamondCount = 0
local PlaceID = game.PlaceId

------------------------------
-- Utilities
------------------------------
local function Notify(msg)
    game.StarterGui:SetCore("SendNotification", {
        Title = "💎 Auto Diamond",
        Text = msg,
        Duration = 3
    })
end

-- safe teleport HRP
local function SafeTP(pos)
    HRP.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
    task.wait(0.2)
end

------------------------------
-- Pickup Diamond
------------------------------
local function PickupDiamond(diamond)
    if not diamond or not diamond:IsA("BasePart") then return false end
    local picked = false

    -- teleport ke diamond
    HRP.CFrame = diamond.CFrame + Vector3.new(0, 3, 0) 
    task.wait(0.3)

    -- fire touch
    pcall(function()
        firetouchinterest(HRP, diamond, 0)
        task.wait(0.1)
        firetouchinterest(HRP, diamond, 1)
    end)

    -- cek kalau diamond hilang
    task.wait(0.5)
    if not diamond.Parent then
        picked = true
        DiamondCount += 1
        Notify("✅ Diamond diambil! Total: " .. DiamondCount)
    end

    return picked
end

------------------------------
-- Open Chest + Ambil Drop
------------------------------
local function OpenChest(chest, waitTime)
    -- teleport ke chest
    SafeTP(chest.Position)

    -- buka chest
    for _, v in pairs(chest:GetDescendants()) do
        if v:IsA("ClickDetector") then
            fireclickdetector(v)
        elseif v:IsA("ProximityPrompt") then
            fireproximityprompt(v)
        end
    end

    -- tunggu diamond spawn
    task.wait(waitTime or 2)

    local gotDiamond = false
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("BasePart") or obj:IsA("MeshPart") then
            if obj.Name:lower():match("diamond") then
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
local function ServerHop()
    Notify("🔄 Server Hop...")
    local servers = {}
    local req = game:HttpGet(
        ("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100")
        :format(PlaceID)
    )
    local data = HttpService:JSONDecode(req)
    if data and data.data then
        for _, v in pairs(data.data) do
            if v.playing < v.maxPlayers then
                TeleportService:TeleportToPlaceInstance(PlaceID, v.id, LocalPlayer)
                break
            end
        end
    end
end

------------------------------
-- Main Loop
------------------------------
Notify("🚀 Auto Diamond Started!")

task.spawn(function()
    while task.wait(1) do
        local foundDiamond = false

        for _, obj in pairs(workspace:GetChildren()) do
            if obj:IsA("Model") and obj.Name:lower():match("chest") then
                if OpenChest(obj, 2.5) then
                    foundDiamond = true
                    break
                end
            end
        end

        if not foundDiamond then
            ServerHop()
            break
        end
    end
end)
