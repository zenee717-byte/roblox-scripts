-- ⚡ Auto Parry Debug Version

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local ParryRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ParryButtonPress")

local AutoParry = true
local DetectionRadius = 70
local ReactionDelay = 0.02

-- UI Toggle
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Toggle = Instance.new("TextButton", ScreenGui)
Toggle.Size = UDim2.new(0, 140, 0, 40)
Toggle.Position = UDim2.new(0.5, -70, 0, 120)
Toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
Toggle.Text = "AutoParry: ON"

Toggle.MouseButton1Click:Connect(function()
    AutoParry = not AutoParry
    Toggle.Text = "AutoParry: " .. (AutoParry and "ON" or "OFF")
end)

-- Debug fungsi kasih highlight ke bola
local function highlightBall(ball, color)
    if ball:FindFirstChild("Highlight") then return end
    local hl = Instance.new("Highlight", ball)
    hl.FillColor = color
    hl.OutlineColor = color
    hl.FillTransparency = 0.5
end

-- Deteksi bola
RunService.Heartbeat:Connect(function()
    if not AutoParry then return end
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local HRP = character.HumanoidRootPart

    local ballsFolder = workspace:FindFirstChild("Balls")
    if not ballsFolder then return end

    for _, ball in ipairs(ballsFolder:GetChildren()) do
        if ball:IsA("BasePart") then
            local dist = (ball.Position - HRP.Position).Magnitude

            if dist <= DetectionRadius then
                if ball.Velocity.Magnitude > 1 then
                    local direction = (HRP.Position - ball.Position).Unit
                    local velocityDir = ball.Velocity.Unit
                    local dot = direction:Dot(velocityDir)

                    if dot > 0.7 then
                        -- highlight merah kalau bola target kamu
                        highlightBall(ball, Color3.fromRGB(255,0,0))

                        task.delay(ReactionDelay, function()
                            pcall(function()
                                ParryRemote:FireServer()
                                warn("⚡ Auto Parry Triggered!")
                            end)
                        end)
                    else
                        -- highlight kuning kalau bola deket tapi bukan ke arah kamu
                        highlightBall(ball, Color3.fromRGB(255,255,0))
                    end
                end
            end
        end
    end
end)
