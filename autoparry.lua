-- ⚡ Auto Parry pake Remote Ball Location

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

local ParryRemote = ReplicatedStorage.Remotes.ParryButtonPress
local ReportBallLocation = ReplicatedStorage.Remotes.ReportBallLocation

-- setting
local TriggerDist = 10   -- jarak parry ideal

-- pantau update bola lewat remote
ReportBallLocation.OnClientEvent:Connect(function(ball, position, velocity)
    if not HRP or not ball or not velocity then return end

    local dist = (position - HRP.Position).Magnitude
    if dist <= TriggerDist then
        local dirToPlayer = (HRP.Position - position).Unit
        local dot = dirToPlayer:Dot(velocity.Unit)

        if dot > 0.75 then
            -- bola ke arah player
            ParryRemote:FireServer()
            warn("⚡ PERFECT PARRY from Remote!")
        end
    end
end)
