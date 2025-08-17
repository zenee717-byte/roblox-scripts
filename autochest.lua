-- 99 Nights in The Forest - Auto Collect Script
-- Buat Delta Executor

local player = game.Players.LocalPlayer

local function collect()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local parentName = obj.Parent and obj.Parent.Name:lower() or ""
            if parentName:find("chest") or parentName:find("diamond") then
                fireproximityprompt(obj)
            end
        end
    end
end

-- Auto collect loop
while task.wait(2) do
    pcall(collect)
end
