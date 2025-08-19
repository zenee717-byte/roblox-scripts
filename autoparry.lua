-- Universal Remote Sniffer (Delta Compatible)
for _, v in pairs(getgc(true)) do
    if typeof(v) == "function" and islclosure(v) and not is_synapse_function(v) then
        local info = debug.getinfo(v)
        if info.name == "FireServer" or info.name == "InvokeServer" then
            hookfunction(v, function(...)
                print("[Sniffer GC]", info.name, ...)
                return v(...)
            end)
        end
    end
end

print("✅ Universal Remote Sniffer aktif! Coba parry manual.")
