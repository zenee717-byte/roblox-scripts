-- Fast Diamond Farm 99 Nights (Efisien & Multi-Method)
-- by ChatGPT + Jen nnn

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local PlaceID = game.PlaceId

local function Notify(txt)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "💎 Fast Farm",
            Text = txt,
            Duration = 3
        })
    end)
end

-- 🔑 Collect Diamonds (all-in-one solution)
local function CollectDiamonds()
    local collected = 0
    for _, drop in ipairs(workspace:GetDescendants()) do
        if drop:IsA("BasePart") and (drop.Name:lower():find("diamond") or drop.Name:lower():find("gem") or drop.Name:lower():find("crystal")) then
            print("💎 Found diamond:", drop, "Class:", drop.ClassName)

            HRP.CFrame = drop.CFrame + Vector3.new(0, 2, 0)
            task.wait(0.2)

            local success = false

            -- 1️⃣ ProximityPrompt
            local prompt = drop:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt and prompt.Enabled then
                fireproximityprompt(prompt)
                collected += 1
                success = true
                print("✅ Collected via ProximityPrompt:", drop.Name)
                task.wait(0.3)
            end

            -- 2️⃣ Touch
            if not success then
                local ti = drop:FindFirstChildOfClass("TouchTransmitter") or drop:FindFirstChild("TouchInterest")
                if ti then
                    for i = 1, 3 do
                        HRP.CFrame = drop.CFrame + Vector3.new(0, 2, 0)
                        task.wait(0.15)
                    end
                    collected += 1
                    success = true
                    print("✅ Collected via Touch:", drop.Name)
                end
            end

            -- 3️⃣ RemoteEvent / RemoteFunction
            if not success then
                for _, child in ipairs(drop:GetDescendants()) do
                    if child:IsA("RemoteEvent") then
                        child:FireServer(drop)
                        collected += 1
                        success = true
                        print("✅ Collected via RemoteEvent:", child.Name)
                        break
                    elseif child:IsA("RemoteFunction") then
                        pcall(function()
                            child:InvokeServer(drop)
                            collected += 1
                            success = true
                            print("✅ Collected via RemoteFunction:", child.Name)
                        end)
                        break
                    end
                end
            end

            if not success then
                print("⚠️ Tidak bisa ambil diamond:", drop.Name)
            end
        end
    end
    return collected
end

-- 🔑 Open Chests
local function OpenAllChests()
    local opened = 0
    for _, chest in ipairs(workspace:GetDescendants()) do
        if chest:IsA("Model") and chest.Name:lower():find("chest") then
            local prompt = chest:FindFirstChildWhichIsA("ProximityPrompt", true)
            local part = chest.PrimaryPart or chest:FindFirstChildWhichIsA("BasePart")
            if prompt and part and prompt.Enabled then
                HRP.CFrame = part.CFrame + Vector3.new(0, 3, 0)
                task.wait(0.2)
                fireproximityprompt(prompt)
                opened += 1
                print("🗝️ Chest dibuka:", chest.Name)
                task.wait(0.5)
            end
        end
    end
    return opened
end

-- 🔑 ServerHop
local function ServerHop()
    Notify("🔄 ServerHop...")
    local cursor = ""
    for tried = 1, 5 do
        local url = ("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100%s")
            :format(PlaceID, cursor ~= "" and "&cursor="..cursor or "")
        local ok, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)
        if ok and result and result.data then
            for _, v in ipairs(result.data) do
                if v.playing < v.maxPlayers and v.id ~= game.JobId then
                    Notify("➡️ Pindah server...")
                    TeleportService:TeleportToPlaceInstance(PlaceID, v.id, LocalPlayer)
                    return
                end
            end
            cursor = result.nextPageCursor or ""
        else
            cursor = ""
        end
        task.wait(1)
    end
    Notify("⚠️ Tidak dapat server, coba lagi nanti...")
end

-- 🔄 Main Loop
task.spawn(function()
    while true do
        local opened = OpenAllChests()
        if opened > 0 then
            Notify("🗝️ Chest dibuka: "..opened)
            task.wait(2) -- beri waktu diamond spawn
        else
            Notify("❌ Tidak ada chest ditemukan.")
        end

        local got = CollectDiamonds()
        if got > 0 then
            Notify("✅ Dapat "..got.." Diamond!")
        else
            Notify("❌ Tidak ada diamond ditemukan.")
        end

        task.wait(1)
        ServerHop()
        task.wait(2)
    end
end)

Notify("🚀 Fast Diamond Farm Aktif!")
