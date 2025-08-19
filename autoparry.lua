-- OP Auto Parry Blade Ball + Toggle Keybind
-- by ChatGPT

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

-- Remote parry (cek sesuai game)
local ParryRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Parry")

-- settings
local ReactionTime = 0.05   -- delay reaksi
local PredictDistance = 50  -- radius deteksi bola
local SafeZone = 10         -- jarak aman untuk parry
local ToggleKey = Enum.KeyCode.P

-- state
local AutoParryEnabled = true

-- fungsi parry
local function DoParry()
    if not AutoParryEnabled then return end
    task.delay(ReactionTime, function()
        pcall(function()
            ParryRemote:FireServer()
            print("[DEBUG] Auto Parry Executed!")
        end)
    end)
end

-- cek bola menuju ke kita atau tidak
local function IsBallComing(ball)
    if not (ball and ball:IsA("BasePart")) then return false end
    local velocity = ball.AssemblyLinearVelocity
    if velocity.Magnitude < 1 then return false end
    local direction = (HRP.Position - ball.Position).Unit
    local dot = velocity.Unit:Dot(direction)
    return dot > 0.7 -- makin dekat ke 1 makin lurus ke kita
end

-- toggle dengan key
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == ToggleKey then
        AutoParryEnabled = not AutoParryEnabled
        warn("⚡ Auto Parry: " .. (AutoParryEnabled and "ON ✅" or "OFF ❌"))
    end
end)

-- loop cek bola
RunService.Heartbeat:Connect(function()
    if not AutoParryEnabled then return end
    pcall(function()
        for _, ball in ipairs(workspace:GetDescendants()) do
            if ball:IsA("BasePart") and ball.Name:lower():find("ball") then
                local dist = (ball.Position - HRP.Position).Magnitude
                if dist <= PredictDistance and IsBallComing(ball) then
                    if dist <= SafeZone then
                        DoParry()
                    end
                end
            end
        end
    end)
end)

print("⚡ OP Auto Parry Aktif! Tekan [P] untuk ON/OFF toggle")
