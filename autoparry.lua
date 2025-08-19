-- Auto Parry Prediksi Bola
-- Fokus hanya parry timing

-- Ambil services
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

-- Remote untuk parry
local ParryRemote = RS:WaitForChild("Remotes"):WaitForChild("ParryButtonPress")

-- Config
local CHECK_INTERVAL = 0.05 -- seberapa sering cek bola
local PARRY_DISTANCE = 20   -- jarak trigger parry (studs)

-- Fungsi parry
local function doParry()
    ParryRemote:FireServer()
    print("🔥 Auto Parry Triggered!")
end

-- Loop pengecekan bola
task.spawn(function()
    while task.wait(CHECK_INTERVAL) do
        -- Pastikan character ada
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            continue
        end
        hrp = player.Character.HumanoidRootPart

        -- Cari bola di Workspace
        local ballsFolder = workspace:FindFirstChild("Balls")
        if ballsFolder then
            for _, ball in ipairs(ballsFolder:GetChildren()) do
                if ball:IsA("BasePart") then
                    -- Hitung jarak
                    local dist = (ball.Position - hrp.Position).Magnitude

                    if dist <= PARRY_DISTANCE then
                        -- Kalau bola deket → parry
                        doParry()
                    end
                end
            end
        end
    end
end)
