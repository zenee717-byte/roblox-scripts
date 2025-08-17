-- 99 Nights in the Forest – Diamonds AutoFarm + AutoHop + ESP + GUI
-- Tested on mobile executors (Delta). All-in-one single file.

-- ====== SAFETY / EXEC ENV ======
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LP = Players.LocalPlayer
local HRP do
    pcall(function()
        HRP = LP.Character and LP.Character:WaitForChild("HumanoidRootPart", 5)
    end)
end

local function gethui_safe()
    local ok, ui = pcall(function()
        return (gethui and gethui()) or game:FindFirstChildOfClass("CoreGui") or LP:WaitForChild("PlayerGui")
    end)
    return ok and ui or (game:FindFirstChildOfClass("CoreGui") or LP:WaitForChild("PlayerGui"))
end

-- fireproximityprompt wrapper (beberapa executor tidak expose fungsi ini)
local function firePrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    local ok = false
    if typeof(fireproximityprompt) == "function" then
        ok = pcall(fireproximityprompt, prompt)
    end
    if not ok then
        -- fallback manual hold
        pcall(function()
            prompt.HoldDuration = 0
            prompt:InputHoldBegin()
            task.wait()
            prompt:InputHoldEnd()
        end)
    end
end

-- ====== CONFIG ======
local LOOT_KEYWORDS = { "diamond", "diamonds", "crystal" } -- nama parent/item yang mengandung kata ini
local SCAN_INTERVAL = 0.40 -- detik antar scan
local HOP_CHECK_EVERY = 20 -- detik (cek apakah habis dan perlu hop)
local TELEPORT_REEXECUTE = true -- coba queue ulang script saat hop

-- ====== STATE ======
local state = {
    autoFarm = true,
    autoHop  = true,
    esp      = true,
    lastFoundTick = os.clock(),
    highlights = {},
}

-- ====== UI ======
local UI = {}
do
    local uiParent = gethui_safe()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NITF_DiamondsUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = uiParent

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.fromOffset(220, 160)
    Frame.Position = UDim2.new(0.05, 0, 0.2, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(30,30,35)
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.Draggable = true
    Frame.Parent = ScreenGui

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 32)
    Title.BackgroundColor3 = Color3.fromRGB(45,45,55)
    Title.BorderSizePixel = 0
    Title.Text = "Diamonds Farm"
    Title.TextColor3 = Color3.new(1,1,1)
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 18
    Title.Parent = Frame

    local function mkBtn(y, text)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, -20, 0, 30)
        b.Position = UDim2.new(0, 10, 0, y)
        b.BackgroundColor3 = Color3.fromRGB(60,60,70)
        b.BorderSizePixel = 0
        b.TextColor3 = Color3.new(1,1,1)
        b.Font = Enum.Font.SourceSansSemibold
        b.TextSize = 16
        b.Text = text
        b.Parent = Frame
        return b
    end

    local farmBtn = mkBtn(44, "Auto Farm: ON")
    local hopBtn  = mkBtn(80, "Auto Hop: ON")
    local espBtn  = mkBtn(116, "ESP: ON")

    local function setBtn(btn, on, label)
        btn.Text = label .. (on and "ON" or "OFF")
        btn.BackgroundColor3 = on and Color3.fromRGB(50,150,70) or Color3.fromRGB(120,60,60)
    end
    setBtn(farmBtn, state.autoFarm, "Auto Farm: ")
    setBtn(hopBtn,  state.autoHop,  "Auto Hop: ")
    setBtn(espBtn,  state.esp,      "ESP: ")

    farmBtn.MouseButton1Click:Connect(function()
        state.autoFarm = not state.autoFarm
        setBtn(farmBtn, state.autoFarm, "Auto Farm: ")
    end)
    hopBtn.MouseButton1Click:Connect(function()
        state.autoHop = not state.autoHop
        setBtn(hopBtn, state.autoHop, "Auto Hop: ")
    end)
    espBtn.MouseButton1Click:Connect(function()
        state.esp = not state.esp
        setBtn(espBtn, state.esp, "ESP: ")
        if not state.esp then
            -- clear highlights
            for inst, hl in pairs(state.highlights) do
                if hl and hl.Parent then hl:Destroy() end
            end
            state.highlights = {}
        end
    end)

    UI.root = ScreenGui
end

-- ====== HELPERS ======
local function nameMatches(str)
    if not str then return false end
    local s = string.lower(str)
    for _, key in ipairs(LOOT_KEYWORDS) do
        if string.find(s, key) then return true end
    end
    return false
end

local function nearestRoot()
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        return LP.Character.HumanoidRootPart
    end
    return nil
end

local function getAllDiamondPrompts()
    local list = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local p = obj.Parent
            if p and (nameMatches(p.Name) or nameMatches(obj.Name)) then
                table.insert(list, obj)
            end
        end
    end
    return list
end

-- ESP management
local function ensureHighlight(modelOrPart)
    if not state.esp then return end
    if not modelOrPart then return end
    local key = modelOrPart
    if state.highlights[key] and state.highlights[key].Parent then return end

    local hl = Instance.new("Highlight")
    hl.FillTransparency = 0.75
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = modelOrPart
    hl.Parent = gethui_safe()
    state.highlights[key] = hl
end

local function cleanupDeadHighlights()
    for inst, hl in pairs(state.highlights) do
        if not inst or not inst.Parent or not hl or not hl.Parent then
            state.highlights[inst] = nil
            if hl and hl.Parent then hl:Destroy() end
        end
    end
end

-- ====== AUTO FARM LOOP ======
task.spawn(function()
    while task.wait(SCAN_INTERVAL) do
        if not state.autoFarm then
            cleanupDeadHighlights()
            continue
        end

        local prompts = getAllDiamondPrompts()
        local anyFound = #prompts > 0
        if anyFound then state.lastFoundTick = os.clock() end

        -- ESP update
        if state.esp then
            for _, pr in ipairs(prompts) do
                local adornee = pr.Parent
                if adornee and adornee:IsA("Model") then
                    ensureHighlight(adornee)
                else
                    ensureHighlight(adornee or pr)
                end
            end
            cleanupDeadHighlights()
        end

        -- Try collect all found prompts
        for _, pr in ipairs(prompts) do
            -- optional: move close if too far (be conservative)
            local root = nearestRoot()
            if root and pr.Parent and pr.Parent:IsA("BasePart") then
                -- if distance > N, you could tween or set CFrame (danger). We'll just try prompt first.
            end
            firePrompt(pr)
            task.wait(0.05)
        end
    end
end)

-- ====== AUTO HOP LOOP ======
local function queueSelfOnTeleport()
    local src = [[
        -- re-exec on teleport
        local url = "]] .. (getgenv and getgenv().__NITF_URL or "") .. [["
        if url ~= "" then
            loadstring(game:HttpGet(url))()
        end
    ]]
    if TELEPORT_REEXECUTE then
        pcall(function()
            (queue_on_teleport or syn and syn.queue_on_teleport or function(_) end)(src)
        end)
    end
end

task.spawn(function()
    queueSelfOnTeleport()
    while task.wait(HOP_CHECK_EVERY) do
        if not state.autoHop then continue end
        -- if no diamonds detected for a while, hop
        local noLootFor = os.clock() - (state.lastFoundTick or 0)
        if noLootFor > (HOP_CHECK_EVERY * 1.5) then
            -- fetch server list and hop
            local ok, body = pcall(function()
                return game:HttpGet(("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId))
            end)
            if ok and body then
                local data = HttpService:JSONDecode(body)
                local candidates = {}
                for _, s in ipairs(data.data or {}) do
                    if s.id ~= game.JobId and s.playing < s.maxPlayers then
                        table.insert(candidates, s.id)
                    end
                end
                if #candidates > 0 then
                    queueSelfOnTeleport()
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, candidates[math.random(1, #candidates)], LP)
                end
            end
        end
    end
end)

-- ====== OPTIONAL: remember raw URL if loaded via loadstring(HttpGet(URL)) ======
-- Jika kamu memanggil script ini lewat loadstring(HttpGet(URL)), sebelum execute, set getgenv().__NITF_URL = URL
-- Contoh:
-- getgenv().__NITF_URL = "https://raw.githubusercontent.com/USER/REPO/main/nitf_diamonds.lua"
-- loadstring(game:HttpGet(getgenv().__NITF_URL))()
