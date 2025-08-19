-- Remote Sniffer untuk cari RemoteEvent Parry
local ReplicatedStorage = game:GetService("ReplicatedStorage")

for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA("RemoteEvent") then
        obj.OnClientEvent:Connect(function(...)
            print("[Sniffer] Remote dipanggil:", obj.Name, ...)
        end)
    end
end

print("✅ Sniffer aktif! Tekan tombol F (block) di game untuk lihat nama Remote di console Delta.")
