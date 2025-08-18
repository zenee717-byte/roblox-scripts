--// Auto Claim Diamond Only 99 Nights
-- by jen nnn + GitHub Copilot

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

-- UI Notif
local function Notify(txt)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "💎 Auto Claim",
            Text = txt,
            Duration = 3
        })
    end)
end

-- Ambil diamond drop
local function CollectDiamonds()
    local collected = 0
    for _, drop in pairs(workspace:GetDescendants()) do
        if drop:IsA("Part") and drop.Name:lower():find("diamond") then
            HRP.CFrame = drop.CFrame + Vector3.new(0, 2, 0)
            local prompt = drop:FindFirstChildOfClass("ProximityPrompt")
            if prompt then
                fireproximityprompt(prompt)
            end
            collected += 1
            task.wait(0.1)
        end
    end
    return collected
end

-- Main loop hanya claim diamond
task.spawn(function()
    while task.wait(1) do
        local got = CollectDiamonds()
        if got > 0 then
            Notify("✅ Dapat "..got.." Diamond!")
        end
    end
end)

Notify("🚀 Auto Claim Diamond Aktif")
