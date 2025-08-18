-- Remote Sniffer ke Chat In-Game
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

-- fungsi buat kirim notifikasi ke chat
local function Notify(msg)
    StarterGui:SetCore("ChatMakeSystemMessage", {
        Text = "[Sniffer] "..tostring(msg),
        Color = Color3.fromRGB(0,255,0),
        Font = Enum.Font.SourceSansBold,
        FontSize = Enum.FontSize.Size24
    })
end

Notify("⚡ Remote Sniffer Aktif - Ambil diamond manual, hasilnya akan muncul di chat!")

-- Hook semua RemoteEvent & RemoteFunction
for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA("RemoteEvent") then
        local old; old = hookfunction(obj.FireServer, function(self, ...)
            if self == obj then
                Notify("RemoteEvent: "..self:GetFullName().." | Args: "..tostring(...))
            end
            return old(self, ...)
        end)
    elseif obj:IsA("RemoteFunction") then
        local old; old = hookfunction(obj.InvokeServer, function(self, ...)
            if self == obj then
                Notify("RemoteFunction: "..self:GetFullName().." | Args: "..tostring(...))
            end
            return old(self, ...)
        end)
    end
end
