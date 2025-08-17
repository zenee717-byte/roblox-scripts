-- 99 Nights In The Forest - Scanner untuk ProximityPrompt
for _, obj in ipairs(workspace:GetDescendants()) do
    if obj:IsA("ProximityPrompt") then
        print("Prompt ditemukan:", obj.Name, "Parent:", obj.Parent.Name)
    end
end
