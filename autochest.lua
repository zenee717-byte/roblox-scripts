-- Infinite Diamond Scanner - Auto Farm (99 Nights in the Forest)
-- Versi agresif seperti di video

local Players = game:GetService("Players")
local Http = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")
local PlaceID = game.PlaceId
local Farming = false
local DiamondCount = 0

-- UI Setup
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 100)
Frame.Position = UDim2.new(0.05, 0, 0.1, 0)
Frame.BackgroundTransparency = 0.3
Frame.BackgroundColor3 = Color3.fromRGB(0,0,0)

local Counter = Instance.new("TextLabel", Frame)
Counter.Size = UDim2.new(1, 0, 0.4, 0)
Counter.Text = "Diamonds: 0"
Counter.TextScaled = true
Counter.TextColor3 = Color3.fromRGB(0, 255, 0)
Counter.BackgroundTransparency = 1

local Toggle = Instance.new("TextButton", Frame)
Toggle.Size = UDim2.new(1, 0, 0.4, 0)
Toggle.Position = UDim2.new(0, 0, 0.4, 0)
Toggle.Text = "▶️ Start"
Toggle.TextScaled = true
Toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

local DurationLabel = Instance.new("TextLabel", Frame)
DurationLabel.Size = UDim2.new(1, 0, 0.2, 0)
DurationLabel.Position = UDim2.new(0, 0, 0.8, 0)
DurationLabel.Text = "No diamond last 0s"
DurationLabel.TextScaled = true
DurationLabel.BackgroundTransparency = 1
DurationLabel.TextColor3 = Color3.fromRGB(255, 255, 0)

-- UI updates
Toggle.MouseButton1Click:Connect(function()
    Farming = not Farming
    Toggle.Text = Farming and "■ Stop" or "▶️ Start"
end)

-- Notify helper
local function Notify(txt)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {Title="Diamond Farm", Text=txt, Duration=3})
    end)
end

-- ServerHop Function
local function ServerHop()
    Notify("No diamond. Hop server...")
    local cursor = ""
    for _ = 1, 5 do
        local url = ("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100%s")
            :format(PlaceID, cursor ~= "" and "&cursor="..cursor or "")
        local ok, res = pcall(function() return Http:JSONDecode(game:HttpGet(url)) end)
        if ok and res and res.data then
            for _, s in ipairs(res.data) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(PlaceID, s.id, LocalPlayer)
                    return
                end
            end
            cursor = res.nextPageCursor or ""
        else
            break
        end
        task.wait(1)
    end
    task.wait(5)
    if Farming then ServerHop() end
end

-- Main loop scanning diamond
task.spawn(function()
    local idleTime = 0
    while true do
        task.wait(0.3)
        if Farming then
            local found = false
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Part") and obj.Name:lower():find("diamond") then
                    found = true
                    idleTime = 0
                    HRP.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
                    task.wait(0.1)
                    local p = obj:FindFirstChildOfClass("ProximityPrompt")
                    if p then fireproximityprompt(p) end
                    DiamondCount += 1
                    Counter.Text = "Diamonds: "..DiamondCount
                    Notify("Diamond collected!")
                    break
                end
            end
            if not found then
                idleTime += 0.3
                DurationLabel.Text = ("No diamond last %.1fs"):format(idleTime)
                if idleTime >= 5 then
                    ServerHop()
                    idleTime = 0
                end
            else
                idleTime = 0
            end
        end
    end
end)

Notify("Infinitely Auto Diamond Ready (Aggressive mode)")
