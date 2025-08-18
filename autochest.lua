-- Auto Teleport & Claim Diamond 99 Night in the Forest
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

-- Teleport dan ambil diamond
local function TeleportAndCollectDiamonds()
    local collected = 0
    for _, drop in pairs(workspace:GetDescendants()) do
        if drop:IsA("Part") and drop.Name:lower():find("diamond") then
            HRP.CFrame = drop.CFrame + Vector3.new(0, 2, 0)
            local prompt = drop:FindFirstChildOfClass("ProximityPrompt")
            if prompt then
                fireproximityprompt(prompt)
            end
            collected += 1
            task.wait(0.2)
        end
    end
    return collected
end

-- Main loop: teleport & claim diamond
task.spawn(function()
    while task.wait(1) do
        local got = TeleportAndCollectDiamonds()
        if got > 0 then
            Notify("✅ Dapat "..got.." Diamond!")
        end
    end
end)

Notify("🚀 Auto Teleport & Claim Diamond
