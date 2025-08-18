--// Services
local Players = game:GetService("Players")
local Http = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

local PlaceID = game.PlaceId

--// Buat ScreenGui scanner
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "DiamondScanner"

local InfoLabel = Instance.new("TextLabel", ScreenGui)
InfoLabel.Size = UDim2.new(0, 400, 0, 300)
InfoLabel.Position = UDim2.new(0, 20, 0, 200)
InfoLabel.BackgroundTransparency = 0.3
InfoLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
InfoLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
InfoLabel.Font = Enum.Font.Code
InfoLabel.TextSize = 16
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
InfoLabel.Text = "Scanning..."

--// Function collect drop
local function collectDrops()
    for _, v in pairs(workspace.Items:GetChildren()) do
        if v:IsA("Part") or v:IsA("MeshPart") then
            local n = v.Name:lower()
            if n:find("diamond") or n:find("gem") or n:find("emerald") then
                HRP.CFrame = v.CFrame + Vector3.new(0, 3, 0)
                task.wait(0.2)
            end
        end
    end
end

--// Function buka chest
local function openChest(chest)
    if chest and chest:FindFirstChild("ChestLid") then
        HRP.CFrame = chest.ChestLid.CFrame + Vector3.new(0, 3, 0)
        local prompt = chest.ChestLid:FindFirstChildWhichIsA("ProximityPrompt")
        if prompt then
            fireproximityprompt(prompt)
            task.wait(2)
            collectDrops()
        end
    end
end

--// Function serverhop
local function serverHop()
    local servers = {}
    local req = game:HttpGet(string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100", PlaceID))
    local data = Http:JSONDecode(req)
    for _, s in pairs(data.data) do
        if s.playing < s.maxPlayers and s.id ~= game.JobId then
            table.insert(servers, s.id)
        end
    end
    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(PlaceID, servers[math.random(1, #servers)], LocalPlayer)
    else
        warn("Serverhop gagal.")
    end
end

--// Update scanner UI
task.spawn(function()
    while task.wait(2) do
        local lines = {"[ SCANNER ] Found drops:"}
        for _, v in pairs(workspace.Items:GetChildren()) do
            if v:IsA("Part") or v:IsA("MeshPart") then
                local dist = (HRP.Position - v.Position).Magnitude
                table.insert(lines, string.format("%s  |  %.1f studs", v.Name, dist))
            end
        end
        InfoLabel.Text = table.concat(lines, "\n")
    end
end)

--// Main loop
while task.wait(5) do
    local foundChest = false
    for _, v in pairs(workspace.Items:GetChildren()) do
        if v.Name == "Item Chest" then
            foundChest = true
            openChest(v)
        end
    end
    if not foundChest then
        serverHop()
    end
end
