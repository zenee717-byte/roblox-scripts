-- Auto Collect Diamonds + Auto Hop + Notification + Diamond Counter
-- Game: 99 Nights in the Forest

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local lp = Players.LocalPlayer

-- UI Setup
local gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 190)
frame.Position = UDim2.new(0.05,0,0.2,0)
frame.BackgroundColor3 = Color3.fromRGB(25,25,30)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.Text = "Diamond Farm"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

local function mkBtn(text,pos)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(1, -20, 0, 30)
    b.Position = UDim2.new(0,10,0,pos)
    b.BackgroundColor3 = Color3.fromRGB(60,60,70)
    b.TextColor3 = Color3.new(1,1,1)
    b.Text = text
    b.Font = Enum.Font.SourceSans
    b.TextSize = 16
    return b
end

local farmBtn = mkBtn("Auto Farm: ON", 40)
local hopBtn  = mkBtn("Auto Hop: ON", 80)

-- Notification
local notif = Instance.new("TextLabel", frame)
notif.Size = UDim2.new(1, -20, 0, 30)
notif.Position = UDim2.new(0,10,0,120)
notif.BackgroundTransparency = 1
notif.TextColor3 = Color3.fromRGB(100,255,100)
notif.Text = ""
notif.Font = Enum.Font.SourceSans
notif.TextSize = 16

-- Diamond Counter
local diamondCounter = Instance.new("TextLabel", frame)
diamondCounter.Size = UDim2.new(1, -20, 0, 30)
diamondCounter.Position = UDim2.new(0,10,0,150)
diamondCounter.BackgroundTransparency = 1
diamondCounter.TextColor3 = Color3.fromRGB(0,200,255)
diamondCounter.Text = "Diamonds: 0"
diamondCounter.Font = Enum.Font.SourceSansBold
diamondCounter.TextSize = 16

-- States
local autoFarm = true
local autoHop = true
local lastCollect = os.clock()
local diamondCount = 0

farmBtn.MouseButton1Click:Connect(function()
    autoFarm = not autoFarm
    farmBtn.Text = "Auto Farm: " .. (autoFarm and "ON" or "OFF")
end)
hopBtn.MouseButton1Click:Connect(function()
    autoHop = not autoHop
    hopBtn.Text = "Auto Hop: " .. (autoHop and "ON" or "OFF")
end)

-- Functions
local function collectDiamonds()
    local collected = false
    for _, v in ipairs(workspace:GetDescendants()) do
        if v.Name:lower():find("diamond") and v:FindFirstChild("ProximityPrompt") then
            local prompt = v.ProximityPrompt
            if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and v:IsA("BasePart") then
                lp.Character.HumanoidRootPart.CFrame = v.CFrame + Vector3.new(0, 2, 0)
                task.wait(0.3)
                fireproximityprompt(prompt)
                collected = true
            end
        end
    end
    return collected
end

-- Main Loop
task.spawn(function()
    while task.wait(1) do
        if autoFarm then
            if collectDiamonds() then
                lastCollect = os.clock()
                diamondCount += 1
                diamondCounter.Text = "Diamonds: " .. diamondCount
                notif.Text = "Diamond collected!"
                task.delay(2, function() notif.Text = "" end)
            end
        end

        if autoHop and os.clock() - lastCollect > 10 then
            notif.Text = "No diamonds, hopping..."
            local resp = game:HttpGet(string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100", game.PlaceId))
            local data = HttpService:JSONDecode(resp)
            for _, s in ipairs(data.data or {}) do
                if s.id ~= game.JobId and s.playing < s.maxPlayers then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, lp)
                    return
                end
            end
        end
    end
end)
