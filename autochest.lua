-- 99 Nights in The Forest - Auto Collect Script (Delta Safe)

local player = game.Players.LocalPlayer

local function collect()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local parent = obj.Parent
            if parent and parent.Name then
                local name = parent.Name:lower()
                if string.find(name, "chest") or string.find(name, "diamond") then
                    pcall(function()
                        fireproximityprompt(obj)
                    end)
                end
            end
        end
    end
end

-- Auto collect loop
while task.wait(0.5) do
    collect()
end
