-- 99 Nights in The Forest - Auto Farm Script
-- Buat Delta Executor

local player = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

-- Config
local AutoFarm = true
local ServerHop = true

-- Buat GUI Toggle
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Button = Instance.new("TextButton", ScreenGui)
Button.Size = UDim2.new(0,150,0,40)
Button.Position = UDim2.new(0,20,0,200)
Button.Text = "AutoFarm: ON"
Button.BackgroundColor3 = Color3.fromRGB(50,150,50)
Button.TextColor3 = Color3.fromRGB(255,255,255)
Button.Font = Enum.Font.SourceSansBold
Button.TextSize = 20

Button.MouseButton1Click:Connect(function()
    AutoFarm = not AutoFarm
    Button.Text = "AutoFarm: " .. (AutoFarm and "ON" or "OFF")
    Button.BackgroundColor3 = AutoFarm and Color3.fromRGB(50,150,50) or Color3.fromRGB(150,50,50)
end)

-- Fungsi collect
local function collect()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local parentName = obj.Parent and obj.Parent.Name:lower() or ""
            if parentName:find("chest") or parentName:find("diamond") then
                fireproximityprompt(obj)
                task.wait(0.1)
            end
        end
    end
end

-- Auto farm loop
task.spawn(function()
    while task.wait(2) do
        if AutoFarm then
            pcall(collect)
        end
    end
end)

-- Server Hop (kalau chest habis)
local function hop()
    local servers = {}
    local req = game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
    local data = HttpService:JSONDecode(req)
    for _,v in pairs(data.data) do
        if v.playing < v.maxPlayers and v.id ~= game.JobId then
            table.insert(servers,v.id)
        end
    end
    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1,#servers)], player)
    end
end

-- Loop server hop
task.spawn(function()
    while task.wait(30) do
        if AutoFarm and ServerHop then
            -- cek kalau tidak ada chest/diamond
            local found = false
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    local parentName = obj.Parent and obj.Parent.Name:lower() or ""
                    if parentName:find("chest") or parentName:find("diamond") then
                        found = true
                        break
                    end
                end
            end
            if not found then
                hop()
            end
        end
    end
end)
