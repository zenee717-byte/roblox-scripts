-- Sniffer: cari semua RemoteEvent / RemoteFunction yang dipanggil dari client
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "FireServer" or method == "InvokeServer" then
        warn("[Sniffer] Remote:", self.Name, "Method:", method, "Args:", ...)
    end
    return old(self, ...)
end)

print("✅ Remote Sniffer aktif! Tekan block/parry sekali buat lihat nama remote di console.")
