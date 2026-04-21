print("Hello World!")

---- 背包信息
--for slot = 12, 75 do
--	print(slot)
--	--local item = oPlayer:GetInventoryItem(slot)
--	--if item and item.ItemId ~= 0xFFFFFFFF then
--	--	if Helpers.GetItemType(item.ItemId) == targetType
--	--	   and Helpers.GetItemIndex(item.ItemId) == targetIndex then
--	--		count = count + 1
--	--	end
--	--end
--end
---- 背包信息
--
---- 命令行
--szCmd = "/成就 2"
--local parts = {}
--for part in string.gmatch(szCmd, "%S+") do
--	print(part)
--	table.insert(parts, part)
--end
--
--local cmd = parts[1] or ""
--print(cmd)
--print(parts[2])
---- 命令行


Enums = {}

Enums.CharacterClassType = {
	WIZARD			= 0,	-- 魔法师
	KNIGHT			= 1,	-- 剑士
	ELF				= 2,	-- 弓箭手
	MAGUMSA			= 3,	-- 魔剑士
	DARKLORD		= 4,	-- 圣导师
	SUMMONER		= 5,	-- 召唤术士
	MONK			= 6,	-- 格斗家
	LANCER			= 7,	-- 梦幻骑士
	RUNEWIZARD		= 8,	-- 符文法师
	SLAYER			= 9,	-- 疾风
	GUNCRUSHER		= 10,	-- 火枪手
	LIGHTWIZARD		= 11,	-- 光明法师
	LEMURIAMAGE		= 12,	-- 圣光学者
	ILLUSIONKNIGHT	= 13,	-- 赤色战士
	ALCHEMIST		= 14,	-- 炼金术士
	CRUSADER		= 15,	-- 圣骑士
	MAX = 16,
}
-- 用法: if oPlayer.Class == Enums.CharacterClassType.WIZARD then print("玩家是魔法师") end
-- 用法: for i = 0, Enums.CharacterClassType.MAX - 1 do print("职业ID: " .. i) end

Enums.CharacterClassTypeName = {
	{ name = "魔法师",			id = Enums.CharacterClassType.WIZARD },
	{ name = "剑士",			id = Enums.CharacterClassType.KNIGHT },
	{ name = "弓箭手",				id = Enums.CharacterClassType.ELF },
	{ name = "魔剑士",			id = Enums.CharacterClassType.MAGUMSA },
	{ name = "圣导师",		id = Enums.CharacterClassType.DARKLORD },
	{ name = "召唤术士",		id = Enums.CharacterClassType.SUMMONER },
	{ name = "格斗家",			id = Enums.CharacterClassType.MONK },
	{ name = "梦幻骑士",			id = Enums.CharacterClassType.LANCER },
	{ name = "符文法师",		id = Enums.CharacterClassType.RUNEWIZARD },
	{ name = "疾风",			id = Enums.CharacterClassType.SLAYER },
	{ name = "火枪手",		id = Enums.CharacterClassType.GUNCRUSHER },
	{ name = "光明法师",	id = Enums.CharacterClassType.LIGHTWIZARD },
	{ name = "圣光学者",	id = Enums.CharacterClassType.LEMURIAMAGE },
	{ name = "赤色战士",	id = Enums.CharacterClassType.ILLUSIONKNIGHT },
	{ name = "炼金术士",		id = Enums.CharacterClassType.ALCHEMIST },
	{ name = "圣骑士",		id = Enums.CharacterClassType.CRUSADER }
}
-- 用法: for i, class in ipairs(Enums.CharacterClassTypeName) do print(class.name) end


function GetClassName(classCode)
	for _, entry in ipairs(Enums.CharacterClassTypeName) do
		if entry.id == classCode then
			return entry.name
		end
	end
	return "未知职业(" .. tostring(classCode) .. ")"
end

print(GetClassName(Enums.CharacterClassType.WIZARD))

MapIndex = {
	{ name = "勇者大陆",	id = 0 },
	{ name = "地下城",	id = 1 },
	{ name = "冰风谷",	id = 2 },
	{ name = "仙踪林",	id = 3 },
	{ name = "失落之塔",	id = 4 },
	{ name = "流放地",	id = 5 },
	{ name = "古战场",	id = 6 },
	{ name = "亚特兰蒂斯",	id = 7 },
	{ name = "死亡沙漠",	id = 8 },
	{ name = "恶魔广场 1-4",	id = 9 },
	{ name = "天空之城",	id = 10 },
	{ name = "血色城堡 1",	id = 11 },
	{ name = "血色城堡 2",	id = 12 },
	{ name = "血色城堡 3",	id = 13 },
	{ name = "血色城堡 4",	id = 14 },
	{ name = "血色城堡 5",	id = 15 },
	{ name = "血色城堡 6",	id = 16 },
	{ name = "血色城堡 7",	id = 17 },
	{ name = "赤色要塞 1",	id = 18 },
	{ name = "赤色要塞 2",	id = 19 },
	{ name = "赤色要塞 3",	id = 20 },
	{ name = "赤色要塞 4",	id = 21 },
	{ name = "赤色要塞 5",	id = 22 },
	{ name = "赤色要塞 6",	id = 23 },
	{ name = "卡利玛神庙 1",	id = 24 },
	{ name = "卡利玛神庙 2",	id = 25 },
	{ name = "卡利玛神庙 3",	id = 26 },
	{ name = "卡利玛神庙 4",	id = 27 },
	{ name = "卡利玛神庙 5",	id = 28 },
	{ name = "卡利玛神庙 6",	id = 29 },
	{ name = "罗兰峡谷",	id = 30 },
	{ name = "魔炼之地",	id = 31 },
	{ name = "恶魔广场5-7",	id = 32 },
	{ name = "幽暗深林1-2",	id = 33 },
	{ name = "狼魂要塞 P1",	id = 34 },
	{ name = "狼魂要塞 P2",	id = 35 },
	{ name = "卡利玛神庙 7",	id = 36 },
	{ name = "坎特鲁废墟",	id = 37 },
	{ name = "坎特鲁遗址",	id = 38 },
	{ name = "坎特鲁[提炼之塔]",	id = 39 },
	{ name = "GM休息处",	id = 40 },
	{ name = "巴卡斯兵营",	id = 41 },
	{ name = "巴卡斯休息室",	id = 42 },
	{ name = "幻影寺庙 1",	id = 45 },
	{ name = "幻影寺庙 2",	id = 46 },
	{ name = "幻影寺庙 3",	id = 47 },
	{ name = "幻影寺庙 4",	id = 48 },
	{ name = "幻影寺庙 5",	id = 49 },
	{ name = "幻影寺庙 6",	id = 50 },
	{ name = "幻术园",	id = 51 },
	{ name = "血色城堡 8",	id = 52 },
	{ name = "赤色要塞 7",	id = 53 },
	{ name = "安宁池",	id = 56 },
	{ name = "冰霜之城",	id = 57 },
	{ name = "孵化魔地",	id = 58 },
	{ name = "圣诞村庄",	id = 62 },
	{ name = "囚禁之岛",	id = 63 },
	{ name = "决斗场",	id = 64 },
	{ name = "生魂广场 1",	id = 65 },
	{ name = "生魂广场 2",	id = 66 },
	{ name = "生魂广场 3",	id = 67 },
	{ name = "生魂广场 4",	id = 68 },
	{ name = "帝国要塞 1",	id = 69 },
	{ name = "帝国要塞 2",	id = 70 },
	{ name = "帝国要塞 3",	id = 71 },
	{ name = "帝国要塞 4",	id = 72 },
	{ name = "罗兰市场",	id = 79 },
	{ name = "卡伦特 1",	id = 80 },
	{ name = "卡伦特 1",	id = 81 },
	{ name = "生魂广场奖励l",	id = 82 },
	{ name = "生魂广场奖励l",	id = 83 },
	{ name = "生魂广场奖励l",	id = 84 },
	{ name = "生魂广场奖励l",	id = 85 },
	{ name = "生魂广场奖励l",	id = 86 },
	{ name = "生魂广场奖励l",	id = 87 },
	{ name = "生魂广场奖励l",	id = 88 },
	{ name = "生魂广场奖励l",	id = 89 },
	{ name = "生魂广场奖励l",	id = 90 },
	{ name = "阿卡伦 1",	id = 91 },
	{ name = "阿卡伦 2",	id = 92 },
	{ name = "德班泰尔",	id = 95 },
	{ name = "德班泰尔 (阿卡伦事件区域)",	id = 96 },
	{ name = "赤色要塞生存战地图",	id = 97 },
	{ name = "赤色要塞生存战地图 1",	id = 98 },
	{ name = "赤色要塞生存战地图 2",	id = 99 },
	{ name = "乌尔克山 1",	id = 100 },
	{ name = "乌尔克山 2",	id = 101 },
	{ name = "磨炼广场",	id = 102 },
	{ name = "磨炼广场 [战斗区域1]",	id = 103 },
	{ name = "磨炼广场 [战斗区域2]",	id = 104 },
	{ name = "磨炼广场 [战斗区域3]",	id = 105 },
	{ name = "磨炼广场 [战斗区域4]",	id = 106 },
	{ name = "纳尔斯",	id = 110 },
	{ name = "ARCABATTLE_NARS",	id = 111 },
	{ name = "菲利亚",	id = 112 },
	{ name = "尼克斯湖",	id = 113 },
	{ name = "四转地图 [资格空间]",	id = 114 },
	{ name = "梦幻迷宫",	id = 115 },
	{ name = "深渊地下城 1",	id = 116 },
	{ name = "深渊地下城 2",	id = 117 },
	{ name = "深渊地下城 3",	id = 118 },
	{ name = "深渊地下城 4",	id = 119 },
	{ name = "深渊地下城 5",	id = 120 },
	{ name = "四转地图",	id = 121 },
	{ name = "黑暗沼泽",	id = 122 },
	{ name = "库贝拉矿山 火",	id = 123 },
	{ name = "库贝拉矿山 水",	id = 124 },
	{ name = "库贝拉矿山 土",	id = 125 },
	{ name = "库贝拉矿山 风",	id = 126 },
	{ name = "库贝拉矿山 暗",	id = 127 },
	{ name = "深渊亚特兰蒂斯 1",	id = 128 },
	{ name = "深渊亚特兰蒂斯 2",	id = 129 },
	{ name = "深渊亚特兰蒂斯 3",	id = 130 },
	{ name = "焦蛇峡谷",	id = 131 },
	{ name = "红烟天空之城",	id = 132 },
	{ name = "阿尼尔神庙",	id = 133 },
	{ name = "暗魂之森",	id = 134 },
	{ name = "古老克托姆",	id = 135 },
	{ name = "火焰克托姆",	id = 136 },
	{ name = "坎特鲁地下区域",	id = 137 },
	{ name = "伊尼格斯火山",	id = 138 },
	{ name = "BOSS大乱斗",	id = 139 },
	{ name = "血腥死亡沙漠",	id = 140 },
	{ name = "托蒙塔岛",	id = 141 },
	{ name = "深渊卡伦特",	id = 142 },
	{ name = "卡达玛哈地下神庙",	id = 143 },
	{ name = "毁灭沼泽",	id = 144 },
	{ name = "阿奎拉斯圣殿",	id = 145 },
}
--- 根据地图编号获取地图中文名称
---@param mapNumber integer 地图编号
---@return string 地图名称
function GetMapName(mapNumber)
	for _, entry in pairs(MapIndex) do
		if entry.id == mapNumber then
			return entry.name
		end
	end
	return "未知地图(" .. tostring(mapNumber) .. ")"
end

print(GetMapName(145))


function FormatMoney(money)
	if money >= 100000000 then
		return string.format("%.1f亿", money / 100000000)
	elseif money >= 10000 then
		return string.format("%.1f万", money / 10000)
	else
		return tostring(money)
	end
end

print(FormatMoney(14512142))


function FormatTime(seconds)
	if seconds < 60 then
		return string.format("%d秒", seconds)
	elseif seconds < 3600 then
		return string.format("%d分钟", math.floor(seconds / 60))
	elseif seconds < 86400 then
		local hours = math.floor(seconds / 3600)
		local mins = math.floor((seconds % 3600) / 60)
		return string.format("%d小时%d分钟", hours, mins)
	else
		local days = math.floor(seconds / 86400)
		local hours = math.floor((seconds % 86400) / 3600)
		return string.format("%d天%d小时", days, hours)
	end
end

print(FormatTime(86400))