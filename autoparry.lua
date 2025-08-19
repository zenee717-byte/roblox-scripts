-- Auto Detect Auto Parry Blade Ball
-- by ChatGPT

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- cari remote otomatis
local ParryRemote
for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA("RemoteEvent") and string.lower(obj.Name):find("parry") or string.lower(obj.Name):find("block") then
        ParryRemote = obj
        warn("[AUTO DETECT] Ketemu Remote Parry:", obj.Name)
        break
    end
end

-- kalau ga ketemu
if not ParryRemote then
    warn("[AUTO DETECT] Gagal cari Remote! Coba pencet tombol F sekali biar muncul di ReplicatedStorage.")
end

-- fungsi utama auto parry
local function autoParry()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local HRP = char:WaitForChild("HumanoidRootPart")

    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name == "Ball" and obj:IsA("BasePart") then
            local dist = (obj.Position - HRP.Position).Magnitude
            if dist < 40 then -- jarak parry
                pcall(function()
                    ParryRemote:FireServer()
                end)
            end
        end
    end
end

-- loop
RunService.Heartbeat:Connect(function()
    if ParryRemote then
        autoParry()
    end
end)
