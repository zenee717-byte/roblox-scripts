-- Auto Scanner GUI buat deteksi Chest & Diamond
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Buat ScreenGui
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "ScannerGUI"

local label = Instance.new("TextLabel", gui)
label.Size = UDim2.new(0, 400, 0, 100)
label.Position = UDim2.new(0.5, -200, 0, 50)
label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
label.BackgroundTransparency = 0.3
label.TextColor3 = Color3.fromRGB(0, 255, 0)
label.Font = Enum.Font.SourceSansBold
label.TextSize = 20
label.Text = "Scanning workspace..."
label.TextWrapped = true

-- Fungsi update text
local function updateText()
    local found = {}
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") or v:IsA("Part") or v:IsA("MeshPart") then
            if v.Name:lower():find("chest") or v.Name:lower():find("diamond") then
                table.insert(found, v:GetFullName())
            end
        end
    end
    if #found > 0 then
        label.Text = "Found Objects:\n" .. table.concat(found, "\n")
    else
        label.Text = "No Chest/Diamond found!"
    end
end

-- Update tiap 3 detik
while true do
    updateText()
    task.wait(3)
end
