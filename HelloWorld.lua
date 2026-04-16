print("Hello World!")

for slot = 12, 75 do
	print(slot)
	--local item = oPlayer:GetInventoryItem(slot)
	--if item and item.ItemId ~= 0xFFFFFFFF then
	--	if Helpers.GetItemType(item.ItemId) == targetType
	--	   and Helpers.GetItemIndex(item.ItemId) == targetIndex then
	--		count = count + 1
	--	end
	--end
end

szCmd = "/成就 2"
local parts = {}
for part in string.gmatch(szCmd, "%S+") do
	print(part)
	table.insert(parts, part)
end

local cmd = parts[1] or ""
print(cmd)
print(parts[2])
