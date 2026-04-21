--═══════════════════════════════════════════════════════════════
--== INTERNATIONAL GAMING CENTER NETWORK
--== www.igcn.mu
--== (C) 2010-2026 IGC-Network (R)
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--== PlayerInfo.lua - 玩家信息查询系统
--== 提供命令接口，允许玩家查询其他在线玩家的基本信息
--═══════════════════════════════════════════════════════════════
--
-- [使用方法]
--   /查询 玩家名          - 查看指定玩家的详细信息
--   /查询                 - 查看自己的详细信息
--   /在线                 - 查看当前在线玩家列表（第一页）
--   /在线 2               - 查看在线列表第二页
--   /在线 职业 剑士       - 按职业筛选在线玩家
--
-- [架构说明]
-- 本系统通过 PlayerInfo.HandleCommand() 处理命令，
-- 在 Callbacks.lua 的 onUseCommand 中调用分派。
--═══════════════════════════════════════════════════════════════

------------------------------------------------------------------
-- 全局命名空间
------------------------------------------------------------------

PlayerInfo = PlayerInfo or {}

------------------------------------------------------------------
-- 配置
------------------------------------------------------------------

--- 每页显示的在线玩家数量
PlayerInfo.PLAYERS_PER_PAGE = 8

--- 冷却时间（毫秒）：同一玩家两次查询之间的最小间隔
PlayerInfo.COOLDOWN_MS = 3000

--- 是否允许查询自己
PlayerInfo.ALLOW_SELF_QUERY = true

--- 是否在查询结果中显示对方坐标
PlayerInfo.SHOW_COORDINATES = true

--- 是否在查询结果中显示对方金币
PlayerInfo.SHOW_MONEY = true

--- 是否在查询结果中显示对方装备概览
PlayerInfo.SHOW_EQUIPMENT_SUMMARY = true

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

------------------------------------------------------------------
-- 工具函数
------------------------------------------------------------------

--- 根据职业代码获取职业中文名称
---@param classCode integer 角色职业代码
---@return string 职业名称
function PlayerInfo.GetClassName(classCode)
	for _, entry in ipairs(Enums.CharacterClassTypeName) do
		if entry.id == classCode then
			return entry.name
		end
	end
	return "未知职业(" .. tostring(classCode) .. ")"
end

--- 根据地图编号获取地图中文名称
---@param mapNumber integer 地图编号
---@return string 地图名称
function PlayerInfo.GetMapName(mapNumber)
	for _, entry in pairs(MapIndex) do
		if entry.id == mapNumber then
			return entry.name
		end
	end
	return "未知地图(" .. tostring(mapNumber) .. ")"
end

--- 格式化金币显示
---@param money integer 金币数量
---@return string 格式化后的字符串
function PlayerInfo.FormatMoney(money)
	if money >= 100000000 then
		return string.format("%.1f亿", money / 100000000)
	elseif money >= 10000 then
		return string.format("%.1f万", money / 10000)
	else
		return tostring(money)
	end
end

--- 格式化时间（秒数转为 x小时x分钟 格式）
---@param seconds integer 秒数
---@return string 格式化后的字符串
function PlayerInfo.FormatTime(seconds)
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

--- 检查命令冷却
---@param oPlayer Object 查询者玩家对象
---@return boolean 是否允许查询
function PlayerInfo.CheckCooldown(oPlayer)
	local now = Timer.GetTick()
	local lastQuery = PlayerInfo._lastQueryTime[oPlayer.Index] or 0

	if now - lastQuery < PlayerInfo.COOLDOWN_MS then
		local remaining = math.ceil((PlayerInfo.COOLDOWN_MS - (now - lastQuery)) / 1000)
		Message.Send(0, oPlayer.Index, 3,
			string.format("【查询】操作太频繁，请等待 %d 秒", remaining))
		return false
	end

	PlayerInfo._lastQueryTime[oPlayer.Index] = now
	return true
end

------------------------------------------------------------------
-- 冷却存储
------------------------------------------------------------------

PlayerInfo._lastQueryTime = {}

------------------------------------------------------------------
-- 核心功能：查询玩家信息
------------------------------------------------------------------

--- 查询并显示指定玩家的详细信息
---@param oRequester Object 发起查询的玩家对象
---@param targetName string|nil 目标玩家名称（nil则查询自己）
function PlayerInfo.QueryPlayer(oRequester, targetName)
	if not oRequester then return end

	-- 冷却检查
	if not PlayerInfo.CheckCooldown(oRequester) then return end

	-- 确定查询目标
	local oTarget
	local isSelfQuery = false

	if not targetName or targetName == "" then
		-- 查询自己
		if not PlayerInfo.ALLOW_SELF_QUERY then
			Message.Send(0, oRequester.Index, 3, "【查询】请输入要查询的玩家名称")
			return
		end
		oTarget = oRequester
		isSelfQuery = true
	else
		-- 查询他人
		oTarget = Player.GetObjByName(targetName)
		if not oTarget then
			Message.Send(0, oRequester.Index, 3,
				string.format("【查询】玩家「%s」不在线或不存在", targetName))
			return
		end
	end

	-- 构建信息面板
	PlayerInfo.DisplayPlayerInfo(oRequester, oTarget, isSelfQuery)
end

--- 显示玩家详细信息面板
---@param oRequester Object 发起查询的玩家
---@param oTarget Object 被查询的玩家
---@param isSelfQuery boolean 是否查询自己
function PlayerInfo.DisplayPlayerInfo(oRequester, oTarget, isSelfQuery)
	local targetName = oTarget.Name or "未知"
	local prefix = isSelfQuery and "【个人信息】" or string.format("【查询 - %s】", targetName)

	-- ═══ 头部 ═══
	Message.Send(0, oRequester.Index, 1, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	Message.Send(0, oRequester.Index, 1, prefix)
	Message.Send(0, oRequester.Index, 1, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

	-- ═══ 基础信息 ═══
	local className = PlayerInfo.GetClassName(oTarget.Class)
	Message.Send(0, oRequester.Index, 1,
		string.format("  角色名：%s", targetName))
	Message.Send(0, oRequester.Index, 1,
		string.format("  职  业：%s", className))
	Message.Send(0, oRequester.Index, 1,
		string.format("  等  级：%d", oTarget.Level))

	-- 大师等级（仅当大于0时显示）
	if oTarget.userData and oTarget.userData.MasterLevel > 0 then
		Message.Send(0, oRequester.Index, 1,
			string.format("  大师等级：%d", oTarget.userData.MasterLevel))
	end

	-- 转生次数
	if oTarget.userData and oTarget.userData.Resets > 0 then
		Message.Send(0, oRequester.Index, 1,
			string.format("  转生次数：%d", oTarget.userData.Resets))
	end

	-- ═══ 战力信息 ═══
	Message.Send(0, oRequester.Index, 1, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	Message.Send(0, oRequester.Index, 1, "  【战力属性】")

	-- 攻击力
	local atkMin = oTarget.AttackDamageMin or 0
	local atkMax = oTarget.AttackDamageMax or 0
	Message.Send(0, oRequester.Index, 1,
		string.format("  攻击力：%d ~ %d", atkMin, atkMax))

	-- 魔法攻击力
	local magicMin = oTarget.MagicDamageMin or 0
	local magicMax = oTarget.MagicDamageMax or 0
	Message.Send(0, oRequester.Index, 1,
		string.format("  魔法攻击：%d ~ %d", magicMin, magicMax))

	-- 防御力
	local defense = oTarget.Defense or 0
	Message.Send(0, oRequester.Index, 1,
		string.format("  防御力：%d", defense))

	-- 攻击速度
	local atkSpeed = oTarget.AttackSpeed or 0
	Message.Send(0, oRequester.Index, 1,
		string.format("  攻击速度：%d", atkSpeed))

	-- 战斗力
	local combatPower = oTarget.CombatPower or 0
	if combatPower > 0 then
		Message.Send(0, oRequester.Index, 1,
			string.format("  战斗力：%d", combatPower))
	end

	-- ═══ 生命/魔法 ═══
	Message.Send(0, oRequester.Index, 1,
		string.format("  生命值：%d / %d",
			math.floor(oTarget.Life or 0),
			math.floor(oTarget.MaxLife or 0)))
	Message.Send(0, oRequester.Index, 1,
		string.format("  魔法值：%d / %d",
			math.floor(oTarget.Mana or 0),
			math.floor(oTarget.MaxMana or 0)))

	-- 护盾
	local maxShield = oTarget.MaxShield or 0
	if maxShield > 0 then
		Message.Send(0, oRequester.Index, 1,
			string.format("  护  盾：%d / %d",
				math.floor(oTarget.Shield or 0), maxShield))
	end

	-- ═══ 位置信息 ═══
	if PlayerInfo.SHOW_COORDINATES then
		Message.Send(0, oRequester.Index, 1, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
		Message.Send(0, oRequester.Index, 1, "  【位置信息】")
		local mapName = PlayerInfo.GetMapName(oTarget.MapNumber)
		Message.Send(0, oRequester.Index, 1,
			string.format("  所在地图：%s (%d)", mapName, oTarget.MapNumber))
		Message.Send(0, oRequester.Index, 1,
			string.format("  坐  标：(%d, %d)", oTarget.X or 0, oTarget.Y or 0))
	end

	-- ═══ 金币信息（仅自己查询时显示） ═══
	if PlayerInfo.SHOW_MONEY and isSelfQuery and oTarget.userData then
		Message.Send(0, oRequester.Index, 1, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
		Message.Send(0, oRequester.Index, 1, "  【财产信息】")
		Message.Send(0, oRequester.Index, 1,
			string.format("  金  币：%s", PlayerInfo.FormatMoney(oTarget.userData.Money or 0)))
		Message.Send(0, oRequester.Index, 1,
			string.format("  Ruud：%d", oTarget.userData.Ruud or 0))
	end

	-- Message.Send(0, oRequester.Index, 3, string.format("PK状态：%s（杀人者）", oTarget.PKLevel))
	-- ═══ PK信息 ═══
	-- if oTarget.PKLevel > 3 then
	-- 	Message.Send(0, oRequester.Index, 1, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	-- 	Message.Send(0, oRequester.Index, 3,
	-- 		string.format("  ? PK状态：%d（杀人者）", oTarget.PKLevel))
	-- end

	-- ═══ 队伍/公会信息 ═══
	local hasSocialInfo = false
	if oTarget.PartyNumber and oTarget.PartyNumber >= 0 then
		if not hasSocialInfo then
			Message.Send(0, oRequester.Index, 1, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
			Message.Send(0, oRequester.Index, 1, "  【社交信息】")
			hasSocialInfo = true
		end
		Message.Send(0, oRequester.Index, 1,
			string.format("  队伍编号：%d", oTarget.PartyNumber))
	end

	if oTarget.GuildNumber and oTarget.GuildNumber > 0 then
		if not hasSocialInfo then
			Message.Send(0, oRequester.Index, 1, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
			Message.Send(0, oRequester.Index, 1, "  【社交信息】")
			hasSocialInfo = true
		end
		Message.Send(0, oRequester.Index, 1,
			string.format("  战盟编号：%d", oTarget.GuildNumber))
	end

	-- ═══ 装备概览 ═══
	if PlayerInfo.SHOW_EQUIPMENT_SUMMARY then
		PlayerInfo.DisplayEquipmentSummary(oRequester, oTarget)
	end

	-- ═══ 底部 ═══
	Message.Send(0, oRequester.Index, 1, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
end

--- 显示装备概览
---@param oRequester Object 发起查询的玩家
---@param oTarget Object 被查询的玩家
function PlayerInfo.DisplayEquipmentSummary(oRequester, oTarget)
	-- 装备槽位定义
	local equipSlots = {
		{ slot = 0, label = "左手" },
		{ slot = 1, label = "右手" },
		{ slot = 2, label = "头盔" },
		{ slot = 3, label = "铠甲" },
		{ slot = 4, label = "护腿" },
		{ slot = 5, label = "护手" },
		{ slot = 6, label = "靴子" },
		{ slot = 7, label = "翅膀" },
		{ slot = 9, label = "项链" },
		{ slot = 10, label = "左戒" },
		{ slot = 11, label = "右戒" },
	}

	local hasAnyEquip = false
	local equipLines = {}

	for _, equip in ipairs(equipSlots) do
		local item = oTarget:GetInventoryItem(equip.slot)
		if item and item.IsItemExist then
			hasAnyEquip = true
			local itemName = "未知物品"
			local itemAttr = Item.GetAttr(item.Type)
			if itemAttr then
				itemName = itemAttr:GetName()
			end

			-- 强化等级
			local levelStr = ""
			if item.Level and item.Level > 0 then
				levelStr = "+" .. item.Level
			end

			-- 属性标记
			local options = {}
			if item.Option1 and item.Option1 ~= 0 then
				table.insert(options, "幸")
			end
			if item.Option2 and item.Option2 ~= 0 then
				table.insert(options, "技")
			end
			if item.Option3 and item.Option3 > 0 then
				table.insert(options, "+" .. item.Option3)
			end
			if item.NewOption and item.NewOption ~= 0 then
				table.insert(options, "卓")
			end
			if item.SetOption and item.SetOption ~= 0 then
				table.insert(options, "套")
			end

			local optionStr = ""
			if #options > 0 then
				optionStr = "[" .. table.concat(options, "") .. "]"
			end

			table.insert(equipLines,
				string.format("  %s：%s%s %s",
					equip.label, itemName, levelStr, optionStr))
		end
	end

	if hasAnyEquip then
		Message.Send(0, oRequester.Index, 1, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
		Message.Send(0, oRequester.Index, 1, "  【装备概览】")
		for _, line in ipairs(equipLines) do
			Message.Send(0, oRequester.Index, 1, line)
		end
	end
end

------------------------------------------------------------------
-- 在线玩家列表
------------------------------------------------------------------

--- 显示在线玩家列表（支持分页和职业筛选）
---@param oPlayer Object 发起查询的玩家
---@param page integer 页码
---@param filterClass integer|nil 职业筛选（nil=全部）
function PlayerInfo.ShowOnlineList(oPlayer, page, filterClass)
	if not oPlayer then return end

	-- 冷却检查
	if not PlayerInfo.CheckCooldown(oPlayer) then return end

	-- 收集在线玩家列表
	local players = {}
	Object.ForEachPlayer(function(oTarget)
		if oTarget and oTarget.Connected == Enums.PlayerState.PLAYING then
			if not filterClass or oTarget.Class == filterClass then
				-- 不包括自己（可选）
				table.insert(players, {
					Name  = oTarget.Name or "?",
					Level = oTarget.Level or 0,
					Class = oTarget.Class or 0,
					Map   = oTarget.MapNumber or 0,
					MasterLevel = (oTarget.userData and oTarget.userData.MasterLevel) or 0,
				})
			end
		end
		return true
	end)

	-- 排序：等级高的在前
	table.sort(players, function(a, b)
		if a.Level ~= b.Level then return a.Level > b.Level end
		return a.MasterLevel > b.MasterLevel
	end)

	local total = #players
	local perPage = PlayerInfo.PLAYERS_PER_PAGE
	local totalPages = math.max(1, math.ceil(total / perPage))

	if page < 1 then page = 1 end
	if page > totalPages then page = totalPages end

	local startIdx = (page - 1) * perPage + 1
	local endIdx = math.min(page * perPage, total)

	-- 标题
	local title = "【在线玩家列表】"
	if filterClass then
		title = string.format("【在线%s列表】", PlayerInfo.GetClassName(filterClass))
	end

	Message.Send(0, oPlayer.Index, 1, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	Message.Send(0, oPlayer.Index, 1, title)
	Message.Send(0, oPlayer.Index, 1,
		string.format("  当前在线：%d 人  第 %d/%d 页", total, page, totalPages))
	Message.Send(0, oPlayer.Index, 1, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

	-- 显示本页玩家
	if total == 0 then
		Message.Send(0, oPlayer.Index, 1, "  暂无符合条件的在线玩家")
	else
		for i = startIdx, endIdx do
			local p = players[i]
			local className = PlayerInfo.GetClassName(p.Class)
			local levelStr = p.Level
			if p.MasterLevel > 0 then
				levelStr = levelStr + p.MasterLevel
			end
			local mapName = PlayerInfo.GetMapName(p.Map)

			Message.Send(0, oPlayer.Index, 1,
				string.format("  %d. %s | %s Lv%d | %s",
					i, p.Name, className, levelStr, mapName))
		end
	end

	Message.Send(0, oPlayer.Index, 1, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	Message.Send(0, oPlayer.Index, 1,
		string.format("  使用 /在线 %d 翻页  |  /查询 玩家名 查看详情", page + 1))
end

------------------------------------------------------------------
-- 职业名称 → 职业代码 反向查找
------------------------------------------------------------------

--- 根据职业名称关键字查找职业代码
---@param nameKey string 职业名称关键字
---@return integer|nil 职业代码
function PlayerInfo.FindClassCodeByName(nameKey)
	if not nameKey then return nil end
	nameKey = string.lower(nameKey)

	-- 精确匹配
	for _, entry in ipairs(Enums.CharacterClassTypeName) do
		if string.lower(entry.name) == nameKey then
			return entry.id
		end
	end

	-- 模糊匹配（包含）
	for _, entry in ipairs(Enums.CharacterClassTypeName) do
		if string.find(string.lower(entry.name), nameKey, 1, true) then
			return entry.id
		end
	end

	-- 英文别名匹配
	local aliases = {
		["wizard"]   = 0, ["wiz"]    = 0, ["法师"]    = 0, ["魔法师"]  = 0,
		["knight"]   = 1, ["dk"]     = 1, ["剑士"]    = 1,
		["elf"]      = 2, ["弓箭手"] = 2,
		["magumsa"]  = 3, ["mg"]     = 3, ["魔剑士"]  = 3,
		["darklord"] = 4, ["dl"]     = 4, ["圣导师"]  = 4,
		["summoner"] = 5, ["sum"]    = 5, ["召唤术士"] = 5,
		["monk"]     = 6, ["rf"]     = 6, ["格斗家"]  = 6,
		["lancer"]   = 7, ["le"]     = 7, ["梦幻骑士"] = 7,
		["runewizard"] = 8, ["rw"]   = 8, ["符文法师"] = 8,
		["slayer"]   = 9, ["sl"]     = 9, ["疾风"]    = 9,
		["guncrusher"] = 10, ["gc"]  = 10, ["火枪手"]  = 10,
	}

	if aliases[nameKey] then
		return aliases[nameKey]
	end

	return nil
end

------------------------------------------------------------------
-- 命令处理
------------------------------------------------------------------

--- 处理 /查询 命令
---@param oPlayer Object 发起命令的玩家
---@param parts table 命令分割后的数组
---@return integer 1=阻止命令传播, 0=继续传播
function PlayerInfo.HandleQueryCommand(oPlayer, parts)
	if not oPlayer then return 0 end

	if #parts == 1 then
		-- 无参数：查询自己
		PlayerInfo.QueryPlayer(oPlayer, nil)
	else
		-- 有参数：查询指定玩家
		PlayerInfo.QueryPlayer(oPlayer, parts[2])
	end

	return 1
end

--- 处理 /在线 命令
---@param oPlayer Object 发起命令的玩家
---@param parts table 命令分割后的数组
---@return integer 1=阻止命令传播, 0=继续传播
function PlayerInfo.HandleOnlineCommand(oPlayer, parts)
	if not oPlayer then return 0 end

	local page = 1
	local filterClass = nil

	if #parts >= 2 then
		-- 检查是否是 "职业 玩家名" 格式：/在线 职业 剑士
		if parts[2] == "职业" or string.lower(parts[2]) == "class" then
			if #parts >= 3 then
				filterClass = PlayerInfo.FindClassCodeByName(parts[3])
				if not filterClass then
					Message.Send(0, oPlayer.Index, 3,
						string.format("【在线】未找到职业「%s」，请检查名称", parts[3]))
					return 1
				end
			end
		else
			-- 尝试解析为页码
			local num = tonumber(parts[2])
			if num then
				page = num
			else
				-- 尝试作为职业名
				filterClass = PlayerInfo.FindClassCodeByName(parts[2])
				if not filterClass then
					Message.Send(0, oPlayer.Index, 3,
						string.format("【在线】无法识别参数「%s」，请输入页码或职业名", parts[2]))
					return 1
				end
			end
		end
	end

	-- 如果有第三个参数且第二个是职业，第三个可能是页码
	if #parts >= 3 and filterClass then
		local num = tonumber(parts[3])
		if num then
			page = num
		end
	end

	PlayerInfo.ShowOnlineList(oPlayer, page, filterClass)
	return 1
end

------------------------------------------------------------------
-- 初始化
------------------------------------------------------------------

--- 系统初始化
function PlayerInfo.Initialize()
	PlayerInfo._lastQueryTime = {}
	Log.Add("[玩家信息] 查询系统初始化完成")
	Log.Add("[玩家信息] 命令列表：/查询 [玩家名]  /在线 [页码|职业名]")
end