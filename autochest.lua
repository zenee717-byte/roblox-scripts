-- Remote Sniffer by ChatGPT
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("⚡ Remote Sniffer Aktif - ambil diamond manual lalu cek console (F9)")

-- Hook RemoteEvent
for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA("RemoteEvent") then
        local old; old = hookfunction(obj.FireServer, function(self, ...)
            if self == obj then
                print("🔔 RemoteEvent Fired:", self:GetFullName(), "Args:", ...)
            end
            return old(self, ...)
        end)
    elseif obj:IsA("RemoteFunction") then
        local old; old = hookfunction(obj.InvokeServer, function(self, ...)
            if self == obj then
                print("🔔 RemoteFunction Invoked:", self:GetFullName(), "Args:", ...)
            end
            return old(self, ...)
        end)
    end
end
