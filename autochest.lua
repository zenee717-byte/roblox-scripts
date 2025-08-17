-- Diamonds Farm Script Auto Start (langsung aktif)
-- 99 Nights in the Forest

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local lp = Players.LocalPlayer
local hrp = lp.Character and lp.Character:WaitForChild("HumanoidRootPart")

-- UI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 200, 0, 150)
Frame.Position = UDim2.new(0.05, 0, 0.25, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BackgroundTransparency = 0.2
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "Diamonds Farm"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18

local function makeButton(text, pos)
    local b = Instance.new("TextButton", Frame)
    b.Size = UDim2.new(1, -20, 0, 30)
    b.Position = UDim2.new(0, 10, 0, pos)
    b.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    b.TextColor3 = Color3.new(1,1,1)
    b.Text = text
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 16
    return b
end

local AutoFarmBtn = makeButton("Auto Farm: ON", 40)
local AutoHopBtn = makeButton("Auto Hop: ON", 80)
local ESPBtn = makeButton("ESP: ON", 120)

-- Variables (langsung aktif)
local AutoFarm = true
local AutoHop = true
local ESP = true

-- Functions
local function collectDiamonds()
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "Diamonds" and v:FindFirstChild("ProximityPrompt") then
            local prompt = v.ProximityPrompt
            if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                hrp.CFrame = v.CFrame + Vector3.new(0,2,0)
                task.wait(0.3)
                fireproximityprompt(prompt)
            end
        end
    end
end

local function hopServer()
    local servers = {}
    local req = game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
    local data = HttpService:JSONDecode(req)
    for _, v in pairs(data.data) do
        if v.playing < v.maxPlayers then
            table.insert(servers, v.id)
        end
    end
    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], lp)
    end
end

local function makeESP(part)
    local billboard = Instance.new("BillboardGui", part)
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.AlwaysOnTop = true
    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = "💎 Diamond"
    label.TextColor3 = Color3.fromRGB(0,255,255)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 14
end

-- Aktifkan ESP otomatis
for _, v in pairs(workspace:GetDescendants()) do
    if v.Name == "Diamonds" and not v:FindFirstChild("BillboardGui") then
        makeESP(v)
    end
end

-- Button toggle manual kalau mau matiin
AutoFarmBtn.MouseButton1Click:Connect(function()
    AutoFarm = not AutoFarm
    AutoFarmBtn.Text = "Auto Farm: " .. (AutoFarm and "ON" or "OFF")
end)

AutoHopBtn.MouseButton1Click:Connect(function()
    AutoHop = not AutoHop
    AutoHopBtn.Text = "Auto Hop: " .. (AutoHop and "ON" or "OFF")
end)

ESPBtn.MouseButton1Click:Connect(function()
    ESP = not ESP
    ESPBtn.Text = "ESP: " .. (ESP and "ON" or "OFF")
    if ESP then
        for _, v in pairs(workspace:GetDescendants()) do
            if v.Name == "Diamonds" and not v:FindFirstChild("BillboardGui") then
                makeESP(v)
            end
        end
    else
        for _, v in pairs(workspace:GetDescendants()) do
            if v:FindFirstChild("BillboardGui") then
                v.BillboardGui:Destroy()
            end
        end
    end
end)

-- Main loop
task.spawn(function()
    while task.wait(2) do
        if AutoFarm then
            collectDiamonds()
        end
        if AutoHop then
            local found = false
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name == "Diamonds" then
                    found = true
                    break
                end
            end
            if not found then
                hopServer()
            end
        end
    end
end)
