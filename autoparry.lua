-- Blade Ball - Auto Parry (Delta Compatible)
-- by ChatGPT | F key + UI button fallback + Toggle UI/Key

-- ===== SETTINGS =====
local MAX_RANGE   = 55      -- radius deteksi bola (studs)
local TRIGGER_AT  = 10      -- jarak memicu parry (studs)
local SPEED_MIN   = 35      -- kecepatan minimal bola (studs/s)
local DOT_MIN     = 0.75    -- seberapa mengarah ke kita (0..1)
local REACTION    = 0.035   -- delay reaksi "manusiawi" (detik)
local COOLDOWN    = 0.25    -- jeda antar parry (detik)
local TOGGLE_KEY  = Enum.KeyCode.P

-- ===== SERVICES =====
local Players = game:GetService("Players")
local RS      = game:GetService("RunService")
local UIS     = game:GetService("UserInputService")
local VIM     = game:GetService("VirtualInputManager")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

-- ===== STATE =====
local ENABLED = true
local lastParry = 0
local HRP

local function getHRP()
    local c = LP.Character or LP.CharacterAdded:Wait()
    HRP = c:WaitForChild("HumanoidRootPart")
end
getHRP()
LP.CharacterAdded:Connect(function() getHRP() end)

-- ===== UI =====
local gui = Instance.new("ScreenGui")
gui.Name = "BB_AutoParry_UI"
gui.ResetOnSpawn = false
pcall(function() gui.Parent = game.CoreGui end)

local btn = Instance.new("TextButton")
btn.Parent = gui
btn.Size = UDim2.fromOffset(140, 44)
btn.Position = UDim2.new(0, 14, 0, 90)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 18
btn.TextColor3 = Color3.new(1,1,1)

local function refreshUI()
    btn.Text = "Auto Parry: " .. (ENABLED and "ON" or "OFF")
    btn.BackgroundColor3 = ENABLED and Color3.fromRGB(40,160,40) or Color3.fromRGB(160,40,40)
end
btn.MouseButton1Click:Connect(function() ENABLED = not ENABLED; refreshUI() end)
UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == TOGGLE_KEY then
        ENABLED = not ENABLED
        refreshUI()
    end
end)
refreshUI()

-- ===== Cari tombol BLOK di UI (fallback untuk mobile) =====
local blockBtn
local function findBlockButton()
    for _, d in ipairs(PG:GetDescendants()) do
        if d:IsA("TextButton") or d:IsA("ImageButton") then
            local name = (d.Name or ""):lower()
            local text = (d:IsA("TextButton") and (d.Text or "") or ""):lower()
            if name:find("block") or name:find("parry") or text:find("block") or text:find("blok") or text:find("parry") then
                blockBtn = d
                return
            end
        end
    end
end
findBlockButton()
PG.DescendantAdded:Connect(function() if not blockBtn then findBlockButton() end end)

local function clickButton(btnObj)
    if not btnObj or not btnObj.Parent then return end
    local pos = btnObj.AbsolutePosition + (btnObj.AbsoluteSize / 2)
    VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
    task.wait(0.02)
    VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
end

-- ===== Tekan F + klik tombol BLOK (fallback) =====
local function triggerParry()
    local now = os.clock()
    if now - lastParry < COOLDOWN then return end
    lastParry = now

    task.delay(REACTION, function()
        -- Tekan F (desktop/controller mapping)
        VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        task.wait(0.02)
        VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)

        -- Fallback: klik tombol BLOK di UI (mobile)
        if blockBtn then
            clickButton(blockBtn)
        end
    end)
end

-- ===== Helper: deteksi bola & arah =====
local function isBall(part)
    if not part:IsA("BasePart") then return false end
    local n = (part.Name or ""):lower()
    return n == "ball" or n:find("ball") or n:find("blade") or part:GetAttribute("Ball") == true
end

-- ===== Loop utama =====
RS.Heartbeat:Connect(function()
    if not ENABLED or not HRP then return end
    local myPos = HRP.Position
    for _, obj in ipairs(workspace:GetDescendants()) do
        if isBall(obj) then
            local rel = myPos - obj.Position
            local dist = rel.Magnitude
            if dist <= MAX_RANGE then
                local v = obj.AssemblyLinearVelocity
                local speed = v.Magnitude
                if speed >= SPEED_MIN then
                    local dirToMe  = rel.Unit
                    local dirBall  = v.Unit
                    local dot = dirBall:Dot(dirToMe)  -- >0 berarti ke arah kita
                    if dot >= DOT_MIN and dist <= TRIGGER_AT then
                        triggerParry()
                    end
                end
            end
        end
    end
end)

print("[BB] Auto Parry loaded. Toggle via UI atau tombol [P].")
