-- 99 Nights in the Forest – Insta-Hop If No Diamond
-- Fokus: cepat seperti di video. Tested untuk executor umum (Delta-friendly).

-- ░ Setup Services / Vars
local Players = game:GetService("Players")
local Http = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local PlaceID = game.PlaceId
local VISITED = {[game.JobId] = true}
local HOP_LOCK = false
local SCAN_RADIUS = 50          -- jarak deteksi drop sekitar chest
local OPEN_TRIES = 15           -- jumlah percobaan buka chest
local OPEN_WAIT = 0.25          -- jeda antar percobaan buka
local DIAMOND_WINDOW = 2.0      -- berapa detik nunggu diamond setelah chest kebuka (cepat)

-- ░ Utils
local function HRP()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:FindFirstChild("HumanoidRootPart")
end

local function tpTo(pos, up)
    local root = HRP()
    if root then
        root.CFrame = CFrame.new(pos + Vector3.new(0, up or 3, 0))
    end
end

local function nearestBasePart(model)
    if model:IsA("BasePart") then return model end
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("BasePart") and d.CanCollide ~= false then
            return d
        end
    end
    return nil
end

local function notify(msg)
    pcall(function()
        game.StarterGui:SetCore("ChatMakeSystemMessage", {Text="[Forest] "..msg; Color=Color3.fromRGB(0,255,0)})
    end)
    print("[Forest] "..msg)
end

-- ░ Open Chest (robust)
local function openChest(chest)
    local pivot = chest.PrimaryPart or nearestBasePart(chest)
    if not pivot then return false end

    -- Posisi di DEPAN chest agar ProximityPrompt aktif
    local look = pivot.CFrame.LookVector
    tpTo(pivot.Position + look * 2, 2)

    for _ = 1, OPEN_TRIES do
        for _,v in ipairs(chest:GetDescendants()) do
            if v:IsA("ProximityPrompt") and (v.ActionText or ""):lower():find("open") and v.Enabled then
                -- hold & release supaya pasti kebuka
                pcall(function() fireproximityprompt(v, 1) end)
                task.wait(0.15)
                pcall(function() fireproximityprompt(v, 0) end)
                return true
            elseif v:IsA("ClickDetector") then
                pcall(function() fireclickdetector(v) end)
                return true
            end
        end
        task.wait(OPEN_WAIT)
    end
    return false
end

-- ░ Ambil diamond di sekitar posisi (radius kecil, cepat)
local function collectDiamondNear(pos)
    local root = HRP()
    if not root then return false end
    local got = false

    -- scan cepat di radius kecil
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = obj.Name:lower()
            if name:find("diamond") then
                local okPos = (obj.Position - pos).Magnitude <= SCAN_RADIUS
                if okPos then
                    tpTo(obj.Position, 2)
                    task.wait(0.05)
                    -- coba semua cara
                    for _,d in ipairs(obj:GetDescendants()) do
                        if d:IsA("ProximityPrompt") then pcall(function() fireproximityprompt(d) end) got = true end
                        if d:IsA("ClickDetector")  then pcall(function() fireclickdetector(d) end) got = true end
                        if d:IsA("TouchTransmitter") then
                            pcall(function() firetouchinterest(root, obj, 0) end)
                            pcall(function() firetouchinterest(root, obj, 1) end)
                            got = true
                        end
                    end
                    if got then return true end
                end
            end
        end
    end
    return false
end

-- ░ Cari semua chest (nama mengandung "chest")
local function getChests()
    local list = {}
    for _,m in ipairs(workspace:GetDescendants()) do
        if m:IsA("Model") and (m.Name:lower():find("chest")) then
            local pp = m.PrimaryPart or nearestBasePart(m)
            if pp then table.insert(list, m) end
        end
    end
    return list
end

-- ░ Server list (pagination)
local function iterServers()
    return coroutine.wrap(function()
        local cursor = nil
        while true do
            local url = "https://games.roblox.com/v1/games/"..PlaceID.."/servers/Public?sortOrder=Asc&limit=100"
            if cursor then url = url .. "&cursor="..cursor end
            local ok, body = pcall(game.HttpGet, game, url)
            if not ok then break end
            local data = Http:JSONDecode(body)
            for _,sv in ipairs(data.data or {}) do
                if sv.id and sv.id ~= game.JobId and (sv.playing or 0) < (sv.maxPlayers or 0) and not VISITED[sv.id] then
                    coroutine.yield(sv.id)
                end
            end
            cursor = data.nextPageCursor
            if not cursor then break end
        end
    end)
end

-- ░ Hop (kuat & retry)
local function hopNow(reason)
    if HOP_LOCK then return end
    HOP_LOCK = true
    notify("Hop → "..(reason or "no reason"))

    -- tandai agar tidak balik ke server ini
    VISITED[game.JobId] = true

    -- coba instance server dulu
    for serverId in iterServers() do
        notify("Teleport to server "..serverId)
        pcall(function()
            TeleportService:TeleportToPlaceInstance(PlaceID, serverId, LocalPlayer)
        end)

        -- jika 6 detik kemudian masih di server yang sama → coba server lain
        task.delay(6, function()
            if Players.LocalPlayer and Players.LocalPlayer.Parent == Players then
                if game.JobId ~= serverId then return end -- sudah pindah
                notify("Teleport gagal (instance) → coba server lain…")
                HOP_LOCK = false
                hopNow("retry instance fail")
            end
        end)
        return
    end

    -- fallback: random server di place
    notify("Tidak ada server kosong yang valid → teleport random")
    pcall(function() TeleportService:Teleport(PlaceID, LocalPlayer) end)

    task.delay(6, function()
        if Players.LocalPlayer and Players.LocalPlayer.Parent == Players then
            notify("Teleport random gagal → retry…")
            HOP_LOCK = false
            hopNow("random fail retry")
        end
    end)
end

-- ░ Event kegagalan teleport → langsung retry
TeleportService.TeleportInitFailed:Connect(function(_, result, msg)
    notify(("Teleport gagal (%s) → retry"):format(tostring(result)))
    HOP_LOCK = false
    task.delay(2, function() hopNow("TeleportInitFailed") end)
end)

-- ░ Anti-AFK sederhana
pcall(function()
    LocalPlayer.Idled:Connect(function()
        local vu = game:GetService("VirtualUser")
        vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end)

-- ░ MAIN: cepat & simple
task.defer(function()
    notify("Start – mencari chest…")
    while task.wait(0.5) do
        -- cari chest
        local chests = getChests()
        if #chests == 0 then
            -- jika tidak ada chest sama sekali → langsung hop
            hopNow("tidak ada chest")
            return
        end

        for _, chest in ipairs(chests) do
            if HOP_LOCK then return end
            local part = chest.PrimaryPart or nearestBasePart(chest)
            if part then
                tpTo(part.Position + part.CFrame.LookVector * 2, 2)
                local opened = openChest(chest)
                if opened then
                    -- window singkat: jika tidak muncul diamond → INSTAHOP
                    local t0 = tick()
                    local got = false
                    repeat
                        got = collectDiamondNear(part.Position)
                        if got then break end
                        task.wait(0.15)
                    until (tick() - t0) >= DIAMOND_WINDOW

                    if got then
                        notify("💎 Diamond diambil → lanjut di server ini")
                        -- lanjut cari chest lain tanpa hop
                    else
                        notify("❌ Chest tanpa diamond → INSTAHOP")
                        hopNow("chest no diamond")
                        return
                    end
                end
            end
        end
    end
end)
