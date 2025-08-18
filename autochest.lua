--// Services
local Players = game:GetService("Players")
local Http = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

local PlaceID = game.PlaceId

--// Ambil drop (diamond, emerald, gem)
local function collectDrops()
    for _, v in pairs(workspace.Items:GetChildren()) do
        if v:IsA("Part") or v:IsA("MeshPart") then
            local n = v.Name:lower()
            if n:find("diamond") or n:find("gem") or n:find("emerald") then
                HRP.CFrame = v.CFrame + Vector3.new(0, 3, 0)
                task.wait(0.3)
            end
        end
    end
end

--// Buka chest
local function openChest(chest)
    if chest and chest:FindFirstChild("ChestLid") then
        HRP.CFrame = chest.ChestLid.CFrame + Vector3.new(0, 3, 0)
        local prompt = chest.ChestLid:FindFirstChildWhichIsA("ProximityPrompt")
        if prompt then
            fireproximityprompt(prompt)
            task.wait(2) -- tunggu chest kebuka
            collectDrops()
        end
    end
end

--// Serverhop (pindah server acak)
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
        warn("Serverhop gagal, tidak ada server lain.")
    end
end

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
