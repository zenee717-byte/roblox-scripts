-- Auto Remote Scanner by ChatGPT
-- Fokus cari remote buat ambil diamond

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local keywords = {"collect", "gem", "diamond", "pickup", "loot"}

local function Notify(msg)
    StarterGui:SetCore("ChatMakeSystemMessage", {
        Text = "[Scanner] " .. tostring(msg),
        Color = Color3.fromRGB(0, 200, 255),
        Font = Enum.Font.SourceSansBold,
        FontSize = Enum.FontSize.Size24
    })
end

Notify("🔍 Scanner Aktif - Ambil diamond manual, hasil remote akan muncul di chat!")

-- fungsi cek nama remote ada keyword atau tidak
local function hasKeyword(name)
    local lname = name:lower()
    for _, key in ipairs(keywords) do
        if string.find(lname, key) then
            return true
        end
    end
    return false
end

-- Hook semua RemoteEvent & RemoteFunction
for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA("RemoteEvent") and hasKeyword(obj.Name) then
        local old; old = hookfunction(obj.FireServer, function(self, ...)
            if self == obj then
                Notify("RemoteEvent: " .. self:GetFullName() .. " | Args: " .. game:GetService("HttpService"):JSONEncode({...}))
            end
            return old(self, ...)
        end)
    elseif obj:IsA("RemoteFunction") and hasKeyword(obj.Name) then
        local old; old = hookfunction(obj.InvokeServer, function(self, ...)
            if self == obj then
                Notify("RemoteFunction: " .. self:GetFullName() .. " | Args: " .. game:GetService("HttpService"):JSONEncode({...}))
            end
            return old(self, ...)
        end)
    end
end
