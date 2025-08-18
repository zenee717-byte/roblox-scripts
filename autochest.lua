--// Auto Diamond Farm 99 Nights in the Forest
--// by jen nnn (modded with UI ON/OFF + Counter)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")

local Character, HRP
local PlaceID = game.PlaceId
local Farming = true
local DiamondCount = 0

-- === Notif helper
local function Notify(txt)
    StarterGui:SetCore("SendNotification", {
        Title = "💎 Diamond Farm",
        Text = txt,
        Duration = 4
    })
end

-- === Update Character
local function UpdateChar()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    HRP = Character:WaitForChild("HumanoidRootPart")
end
UpdateChar()
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    UpdateChar()
    if Farming then
        Notify("⚰️ Respawn! Auto ServerHop...")
        task.delay(2, function()
            ServerHop()
        end)
    end
end)

-- === Collect Diamonds
local function CollectDiamonds()
    for _, drop in pairs(workspace:GetDescendants()) do
        if drop:IsA("Part") and drop.Name:lower():find("diamond") then
            if HRP then
                HRP.CFrame = drop.CFrame + Vector3.new(0, 2, 0)
                local prompt = drop:FindFirstChildOfClass("ProximityPrompt")
                if prompt then
                    fireproximityprompt(prompt)
                    DiamondCount += 1
                    pcall(function()
                        game.CoreGui.DiamondCounter.TextLabel.Text = "💎 Diamond: " .. DiamondCount
                    end)
                    task.wait(0.3)
                end
            end
        end
    end
end

-- === Search Chest
function SearchChest()
    for _, chest in pairs(workspace:GetDescendants()) do
        if chest:IsA("Model") and chest.Name:lower():find("chest") then
            local prompt = chest:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then
                local cf = chest.PrimaryPart and chest.PrimaryPart.CFrame or chest:GetModelCFrame()
                HRP.CFrame = cf + Vector3.new(0, 3, 0)
                task.wait(0.5)
                fireproximityprompt(prompt)
                task.wait(1)
                CollectDiamonds()
                return true
            end
        end
    end
    return false
end

-- === Safe Teleport
function SafeTeleport(serverId)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.CharacterAdded:Wait()
        task.wait(1)
        UpdateChar()
    end
    local success, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(PlaceID, serverId, LocalPlayer)
    end)
    if not success then
        warn("Teleport gagal: " .. tostring(err))
        task.wait(2)
        ServerHop()
    end
end

-- === ServerHop
function ServerHop()
    if not Farming then return end
    Notify("🔄 Cari server lain...")
    local cursor = ""
    local success = false
    local tried = 0

    while not success and tried < 5 do
        tried += 1
        local url = ("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100%s")
            :format(PlaceID, cursor ~= "" and "&cursor="..cursor or "")

        local ok, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)

        if ok and result and result.data then
            for _, v in pairs(result.data) do
                if v.playing < v.maxPlayers and v.id ~= game.JobId then
                    success = true
                    Notify("➡️ Pindah server...")
                    SafeTeleport(v.id)
                    break
                end
            end
            cursor = result.nextPageCursor or ""
        else
            cursor = ""
        end
        task.wait(2)
    end

    if not success and Farming then
        Notify("⚠️ Gagal cari server, retry...")
        task.wait(5)
        ServerHop()
    end
end

-- === UI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "DiamondCounter"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 200, 0, 80)
Frame.Position = UDim2.new(0.05, 0, 0.1, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BackgroundTransparency = 0.3
Frame.Active = true
Frame.Draggable = true

local TextLabel = Instance.new("TextLabel", Frame)
TextLabel.Size = UDim2.new(1, 0, 0.5, 0)
TextLabel.Text = "💎 Diamond: 0"
TextLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
TextLabel.TextScaled = true
TextLabel.BackgroundTransparency = 1

local Toggle = Instance.new("TextButton", Frame)
Toggle.Size = UDim2.new(1, 0, 0.5, 0)
Toggle.Position = UDim2.new(0, 0, 0.5, 0)
Toggle.Text = "🟢 ON"
Toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
Toggle.TextScaled = true

Toggle.MouseButton1Click:Connect(function()
    Farming = not Farming
    Toggle.Text = Farming and "🟢 ON" or "🔴 OFF"
    if Farming then
        Notify("✅ AutoFarm Aktif")
    else
        Notify("⛔ AutoFarm Dimatikan")
    end
end)

-- === Main Loop
task.spawn(function()
    while task.wait(2) do
        if Farming then
            local found = SearchChest()
            if not found then
                ServerHop()
            end
        end
    end
end)

Notify("✅ Diamond Farm Aktif (UI ON/OFF + Counter)")
