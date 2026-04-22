--═══════════════════════════════════════════════════════════════
--== INTERNATIONAL GAMING CENTER NETWORK
--== www.igcn.mu
--== (C) 2010-2026 IGC-Network (R)
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--== File is a part of IGCN Group MuOnline Server files.
--═══════════════════════════════════════════════════════════════

------------------------------------------------------------------
-- Event Callbacks事件回调 - 服务器事件处理器
------------------------------------------------------------------
-- 所有由游戏服务器事件触发的回调函数.
-- 同步：同步执行 (可以返回值给C++)
-- 异步: 异步执行 (不期望返回任何值)
------------------------------------------------------------------

------------------------------------------------------------------
-- 连接上线 & 账号认证 事件
------------------------------------------------------------------

-- 当玩家进入角色选择界面时调用 (异步)
function onCharacterSelectEnter(oPlayer)
	if (oPlayer ~= nil) then
		
	end
end

-- 当玩家成功连接到服务器时调用 (异步)
function onPlayerConnect(oPlayer)
	if (oPlayer ~= nil) then
		
	end
end

-- 当玩家使用角色登录时调用 (异步)
function onPlayerLogin(oPlayer)
	if (oPlayer ~= nil) then
		
	end
end

-- 当玩家断开与服务器的连接时调用 (异步)
function onPlayerDisconnect(oPlayer)
	if (oPlayer ~= nil) then
		
	end
end

------------------------------------------------------------------
-- 服务器 生命周期 事件
------------------------------------------------------------------

-- 游戏服务器启动时调用 (异步)
function onGameServerStart()
	
end

-- 当服务器强制关闭、立即断开所有玩家连接时调用 (异步)
function onDisconnectAllPlayers()
	
end

-- 当服务器启动优雅关闭时调用，请求所有玩家登出 (异步)
function onLogOutAllPlayers()
	
end

-- 当服务器启动重启时调用，断开玩家连接并允许重连 (异步)
function onDisconnectAllPlayersWithReconnect()
	
end
------------------------------------------------------------------
-- 仓库 事件
------------------------------------------------------------------

-- 当玩家打开仓库时调用 (异步)
function onOpenWarehouse(oPlayer)
	if (oPlayer ~= nil) then

	end
end

-- 当玩家关闭仓库时调用 (异步)
function onCloseWarehouse(oPlayer)
	if (oPlayer ~= nil) then
		
	end
end

------------------------------------------------------------------
-- 交易 事件
------------------------------------------------------------------

-- 当玩家向另一名玩家发送交易请求时调用 (同步 - 可阻止交易)
-- 返回非零值以阻止交易请求的发送
function onTradeRequestSend(oPlayer, oTarget)
	if (oPlayer ~= nil) then
		if (oTarget ~= nil) then
			
		end
	end
	return 0
end

-- 当玩家收到另一名玩家的交易响应时调用 (同步 - 可阻止响应处理)
-- 返回非零值以阻止处理该响应
-- bResponse: true = 接受, false = 拒绝
function onTradeResponseReceive(oPlayer, oTarget, bResponse)
	if (oPlayer ~= nil) then
		if (oTarget ~= nil) then
			
		end
	end
	return 0
end

-- 当双方玩家在交易窗口中点击“确定”按钮时调用 (同步 - 可阻止交易完成)
-- 返回非零值以阻止交易完成
function onTradeAccept(oPlayer, oTarget)
	if (oPlayer ~= nil) then
		if (oTarget ~= nil) then
			
		end
	end
	return 0
end

-- 当任意一方玩家取消交易时调用 (同步 - 可阻止交易取消)
-- 返回非零值以阻止交易取消
function onTradeCancel(oPlayer, oTarget)
	if (oPlayer ~= nil) then
		if (oTarget ~= nil) then
			
		end
	end
	return 0
end

------------------------------------------------------------------
-- 特殊事件入场（血色、赤色、恶魔）
------------------------------------------------------------------

-- 当玩家进入血色城堡事件时调用 (异步)
function onBloodCastleEnter(oPlayer, iEventLevel)
	if (oPlayer ~= nil) then
		
	end
end

-- 当玩家进入赤色要塞事件时调用 (异步)
function onChaosCastleEnter(oPlayer, iEventLevel)
	if (oPlayer ~= nil) then
		
	end
end

-- 当玩家进入恶魔广场事件时调用 (异步)
function onDevilSquareEnter(oPlayer, iEventLevel)
	if (oPlayer ~= nil) then
		
	end
end

------------------------------------------------------------------
-- 玩家成长事件
------------------------------------------------------------------

-- 当玩家升级时调用 (异步)
function onPlayerLevelUp(oPlayer)
	if (oPlayer ~= nil) then
		
	end
end

-- 当玩家大师升级时调用 (异步)
function onPlayerMasterLevelUp(oPlayer)
	if (oPlayer ~= nil) then
		
	end
end

-- 当玩家输入命令时调用 (同步 - 可阻止执行)
-- 返回 1 则阻止该命令，返回 0（或不返回任何值）则允许执行.
-- szCmd 包含完整的命令字符串，包括前导斜杠 /.
-- 可在 Lua 中使用 string.gmatch 或类似的模式匹配方法对其进行分割.
function onUseCommand(oPlayer, szCmd)
	if (oPlayer ~= nil) then
		-- Split szCmd into parts (e.g. "/post Hello World" -> {"/post", "Hello", "World"})
		local parts = {}
		for part in string.gmatch(szCmd, "%S+") do
			table.insert(parts, part)
		end
		local cmd = parts[1] or ""

		-- =============================================
		-- 成就系统命令处理
		-- 使用方法：
		--   /成就        - 显示成就列表（第一页）
		--   /成就 2      - 显示第二页
		--   /成就 101    - 查看编号101的成就详情
		-- =============================================
		--if cmd == "/成就" or cmd == "/chengjiu" or cmd == "/c" then
		--	return AchievementSystem.HandleCommand(oPlayer, parts)
		--end

		-- =============================================
		-- 玩家信息查询命令
		-- 使用方法：
		--   /查询            - 查看自己的详细信息
		--   /查询 玩家名     - 查看指定玩家的详细信息
		--   /在线            - 查看在线玩家列表（第一页）
		--   /在线 2          - 查看在线列表第二页
		--   /在线 职业 剑士  - 按职业筛选在线玩家
		-- =============================================
		if cmd == "/查询" or cmd == "/chaxun" or cmd == "/query" then
			return PlayerInfo.HandleQueryCommand(oPlayer, parts)
		end

		if cmd == "/在线" or cmd == "/zaixian" or cmd == "/online" then
			return PlayerInfo.HandleOnlineCommand(oPlayer, parts)
		end

		-- =============================================
		-- 背包查询命令
		-- 使用方法：
		--   /背包            - 查看自己的背包（第一页）
		--   /背包 2          - 查看自己背包的第二页
		--   /背包 玩家名     - 查看指定玩家的背包（需 INVENTORY_SELF_ONLY = false）
		--   /背包 玩家名 2   - 查看指定玩家背包的第二页
		-- =============================================
		if cmd == "/背包" or cmd == "/beibao" or cmd == "/inv" or cmd == "/inventory" then
			return PlayerInfo.HandleInventoryCommand(oPlayer, parts)
		end
	end
	return 0
end

-- 当玩家进行角色转生时调用 (异步)
function onPlayerReset(oPlayer)

end

------------------------------------------------------------------
-- NPC交互事件
------------------------------------------------------------------

-- 当玩家与NPC对话时调用 (同步)
function onNpcTalk(oPlayer, oNpc)
	if (oPlayer ~= nil) then
		if (oNpc ~= nil) then
			
		end
	end
	return 0
end

-- 当玩家通过关闭窗口结束与NPC的对话时调用 (同步)
function onCloseWindow(oPlayer)
	if (oPlayer ~= nil) then
	
	end
	return 0
end

------------------------------------------------------------------
-- 背包管理事件
------------------------------------------------------------------

-- 当玩家通过鼠标右键使用任何物品时调用 (同步)
function onItemUse(iResult, oPlayer, oItem, iItemSourcePos, iItemTargetPos)
	if (oPlayer ~= nil) then
		
	end
	return 0
end

-- 当玩家在主背包中移动物品时调用 (异步)
function onInventoryMoveItem(oPlayer, iItemSourcePos, iItemTargetPos, btResult)
	if (oPlayer ~= nil) then
		
	end
end

-- 当玩家在活动背包中移动物品时调用 (异步)
function onEventInventoryMoveItem(oPlayer, iItemSourcePos, iItemTargetPos, btResult)
	if (oPlayer ~= nil) then
		
	end
end

-- 当玩家在宠物背包中移动物品时调用 (异步)
function onMuunInventoryMoveItem(oPlayer, iItemSourcePos, iItemTargetPos, btResult)
	if (oPlayer ~= nil) then
		
	end
end

------------------------------------------------------------------
-- 物品获取事件
------------------------------------------------------------------

-- 当玩家从地面拾取物品时调用 (异步)
function onItemGet(oPlayer, sItemType, sItemLevel, btItemDur, btItemElement)
	if (oPlayer ~= nil) then
		
	end
end

-- 当玩家获取活动物品时调用 (异步)
function onEventItemGet(oPlayer, sItemType, sItemLevel, btItemDur, btItemElement)
	if (oPlayer ~= nil) then
		
	end
end

-- 当玩家获取宠物物品时调用 (异步)
function onMuunItemGet(oPlayer, sItemType, sItemLevel, btItemDur, btItemElement)
	if (oPlayer ~= nil) then
		
	end
end

------------------------------------------------------------------
-- 装备事件
------------------------------------------------------------------

-- 当玩家装备物品时调用 (异步)
function onItemEquip(oPlayer, iItemSourcePos, iItemTargetPos, btResult)
	if (oPlayer ~= nil) then
		
	end
end

-- 当玩家卸下装备物品时调用 (异步)
function onItemUnEquip(oPlayer, iItemSourcePos, iItemTargetPos, btResult)
	if (oPlayer ~= nil) then
		
	end
end

------------------------------------------------------------------
-- 物品修复事件
------------------------------------------------------------------

-- 当玩家在NPC处修复物品时调用 (异步)
function onItemRepair(oPlayer, oItemm)
	if (oPlayer ~= nil) then
		if (oItemm ~= nil) then
			
		end
	end
end

------------------------------------------------------------------
-- 地图 & 移动事件
------------------------------------------------------------------

-- 当玩家在登录或传送后加入地图时调用 (异步)
function onCharacterJoinMap(oPlayer)
	if (oPlayer ~= nil) then
		
	end
end

-- 当玩家在地图之间移动时调用 (异步)
function onMoveMap(oPlayer, wMapNumber, btPosX, btPosY, iGateNumber)
	if (oPlayer ~= nil) then
		
	end
end

-- 当玩家使用地图传送门时调用 (异步)
function onMapTeleport(oPlayer, iGateNummber)
	if (oPlayer ~= nil) then
		
	end
end

-- 当玩家使用传送命令或道具时调用 (异步)
function onTeleport(oPlayer, wMapNumber, btPosX, btPosY)
	if (oPlayer ~= nil) then
		
	end
end

-- 当玩家使用传送魔法技能时调用 (异步)
function onTeleportMagicUse(oPlayer, btPosX, btPosY)
	if (oPlayer ~= nil) then
		
	end
end

------------------------------------------------------------------
-- 战斗 & 死亡事件
------------------------------------------------------------------

-- 当玩家击杀另一名玩家时调用 (异步)
function onPlayerKill(oPlayer, oTarget)
	if (oPlayer ~= nil) then
		if (oTarget ~= nil) then
			
		end
	end
end

-- 当玩家死亡时调用 (异步)
function onPlayerDie(oPlayer, oTarget)
	if (oPlayer ~= nil) then
		if (oTarget ~= nil) then
			
		end
	end
end

-- 当玩家死亡后重生时调用 (异步)
function onPlayerRespawn(oPlayer)
	if (oPlayer ~= nil) then
		
	end
end

-- 当玩家击杀怪物时调用 (异步)
function onMonsterKill(oPlayer, oTarget)
	if (oPlayer ~= nil) then
		if (oTarget ~= nil) then
			
		end
	end
end

-- 当怪物死亡时调用 (异步)
function onMonsterDie(oPlayer, oTarget)
	if (oPlayer ~= nil) then
		if (oTarget ~= nil) then
			
		end
	end
end

-- 当地图上生成怪物时调用 (异步)
function onMonsterSpawn(oPlayer)
	if (oPlayer ~= nil) then
		
	end
end

-- 当怪物死亡后重生时调用 (异步)
function onMonsterRespawn(oPlayer)
	if (oPlayer ~= nil) then
		
	end
end

-- Called upon target attack attempt (Sync)
function onCheckUserTarget(oPlayer, oTarget)
	--if (oPlayer ~= nil) then
	--	if (oTarget ~= nil) then
	--
	--	end
	--end
	--return 0

	-- 地图等级保护配置: 地图ID = 最低攻击等级（低于此等级的玩家在该地图不能被其他玩家攻击）
	-- 使用 Enums.MapIndex 中的常量或直接填写数字ID
	-- 示例配置含义：
	--   LORENCIA(0)    = 勇者大陆，400级以下不能被攻击
	-- 添加或删除条目即可调整规则，不需要的地图直接删除对应行即可
	local MapLevelProtection = {
		{ name = "勇者大陆",	id = 0 , ProtectionLevel = 400 },
		{ name = "地下城",	id = 1 , ProtectionLevel = 400 },
		{ name = "冰风谷",	id = 2 , ProtectionLevel = 400 },
		{ name = "仙踪林",	id = 3 , ProtectionLevel = 400 },
		{ name = "失落之塔",	id = 4 , ProtectionLevel = 400 },
		{ name = "古战场",	id = 6 , ProtectionLevel = 400 },
		{ name = "亚特兰蒂斯",	id = 7 , ProtectionLevel = 400 },
		{ name = "死亡沙漠",	id = 8 , ProtectionLevel = 400 },
		{ name = "天空之城",	id = 10 , ProtectionLevel = 400 },
		{ name = "幽暗深林1-2",	id = 33 , ProtectionLevel = 400 },
		{ name = "坎特鲁废墟",	id = 37 , ProtectionLevel = 400 },
		{ name = "坎特鲁遗址",	id = 38 , ProtectionLevel = 400 },
		{ name = "幻术园",	id = 51 , ProtectionLevel = 400 },
		{ name = "安宁池",	id = 56 , ProtectionLevel = 800 },
		{ name = "冰霜之城",	id = 57 , ProtectionLevel = 800 },
		{ name = "卡伦特 1",	id = 80 , ProtectionLevel = 800 },
		{ name = "卡伦特 2",	id = 81 , ProtectionLevel = 800 },
		{ name = "阿卡伦 1",	id = 91 , ProtectionLevel = 800 },
		{ name = "阿卡伦 2",	id = 92 , ProtectionLevel = 800 },
		{ name = "德班泰尔",	id = 95 , ProtectionLevel = 800 },
		{ name = "乌尔克山 1",	id = 100 , ProtectionLevel = 800 },
		{ name = "乌尔克山 2",	id = 101 , ProtectionLevel = 800 },
		{ name = "纳尔斯",	id = 110 , ProtectionLevel = 800 },
		{ name = "菲利亚",	id = 112 , ProtectionLevel = 800 },
		{ name = "尼克斯湖",	id = 113 , ProtectionLevel = 900 },
		{ name = "深渊地下城 1",	id = 116 , ProtectionLevel = 950 },
		{ name = "深渊地下城 2",	id = 117 , ProtectionLevel = 950 },
		{ name = "深渊地下城 3",	id = 118 , ProtectionLevel = 950 },
		{ name = "深渊地下城 4",	id = 119 , ProtectionLevel = 950 },
		{ name = "深渊地下城 5",	id = 120 , ProtectionLevel = 950 },
		{ name = "黑暗沼泽",	id = 122 , ProtectionLevel = 1000 },
		{ name = "库贝拉矿山 火",	id = 123 , ProtectionLevel = 1050 },
		{ name = "库贝拉矿山 水",	id = 124 , ProtectionLevel = 1050 },
		{ name = "库贝拉矿山 土",	id = 125 , ProtectionLevel = 1050 },
		{ name = "库贝拉矿山 风",	id = 126 , ProtectionLevel = 1050 },
		{ name = "库贝拉矿山 暗",	id = 127 , ProtectionLevel = 1050 },
		{ name = "深渊亚特兰蒂斯 1",	id = 128 , ProtectionLevel = 1100 },
		{ name = "深渊亚特兰蒂斯 2",	id = 129 , ProtectionLevel = 1100 },
		{ name = "深渊亚特兰蒂斯 3",	id = 130 , ProtectionLevel = 1100 },
		{ name = "焦蛇峡谷",	id = 131 , ProtectionLevel = 1150 },
		{ name = "红烟天空之城",	id = 132 , ProtectionLevel = 1200 },
		{ name = "阿尼尔神庙",	id = 133 , ProtectionLevel = 1250 },
		{ name = "暗魂之森",	id = 134 , ProtectionLevel = 1300 },
		{ name = "古老克托姆",	id = 135 , ProtectionLevel = 800 },
		{ name = "火焰克托姆",	id = 136 , ProtectionLevel = 1350 },
		{ name = "坎特鲁地下区域",	id = 137 , ProtectionLevel = 1400 },
		{ name = "伊尼格斯火山",	id = 138 , ProtectionLevel = 1400 },
		{ name = "血腥死亡沙漠",	id = 140 , ProtectionLevel = 1500 },
		{ name = "托蒙塔岛",	id = 141 , ProtectionLevel = 1500 },
		{ name = "深渊卡伦特",	id = 142 , ProtectionLevel = 1550 },
		{ name = "卡达玛哈地下神庙",	id = 143 , ProtectionLevel = 1600 },
		{ name = "毁灭沼泽",	id = 144 , ProtectionLevel = 1650 },
		{ name = "阿奎拉斯圣殿",	id = 145 , ProtectionLevel = 1700 },
	}

	if oPlayer == nil or oTarget == nil then return 0 end

    -- 夜间保护: 每天0点~8点不能攻击其他玩家
    if oTarget.Type == Enums.ObjectType.USER then
		hour = tonumber(os.date("%H"))
		if hour >= 0 and hour < 8 then
			--print("夜间保护期间（0:00~8:00）无法攻击其他玩家。")
			Message.Send(0, oPlayer.Index, 0, "夜间保护期间（0:00~8:00）无法攻击其他玩家。")
			return 1
		end
    end

    -- 地图等级保护: 目标玩家在受保护地图中且等级低于该地图要求的保护等级时，阻止攻击
    if oTarget.Type == Enums.ObjectType.USER then
        --local minLevel = MapLevelProtection[oTarget.MapNumber]
		for _, entry in pairs(MapLevelProtection) do
			if entry.id == oTarget.MapNumber then
				if entry.ProtectionLevel and oTarget.Level < entry.ProtectionLevel then
					Message.Send(0, oPlayer.Index, 0, string.format("%s（%d级以下）的玩家受地图保护，无法攻击。", entry.name, entry.ProtectionLevel))
            		return 1
				end
			end
		end
    end

    ---- 仅 PvP: 阻止攻击 400 级以下玩家
    --if oTarget.Type == Enums.ObjectType.USER and oTarget.Level < 400 then
    --    Message.Send(0, oPlayer.Index, 0, "你不能攻击 400 级以下的玩家。")
    --    return 1
    --end

    -- 阻止同公会友军伤害
    --if oTarget.Type == Enums.ObjectType.USER and oPlayer.GuildNumber > 0 and oPlayer.GuildNumber == oTarget.GuildNumber then
    --    Message.Send(0, oPlayer.Index, 0, "你不能攻击战盟成员。")
    --    return 1
    --end

    return 0
end

-- Called when player uses a duration-based skill (Sync - return non-zero to block)
function onUseDurationSkill(oPlayer, aTargetIndex, iSkill, btX, btY, btDir)
	if (oPlayer ~= nil) then

	end
	return 0
end

-- Called when player uses a normal (instant) skill on a target (Sync - return non-zero to block)
function onUseNormalSkill(oPlayer, oTarget, iSkill)
	if (oPlayer ~= nil) then
		if (oTarget ~= nil) then

		end
	end
	return 0
end

------------------------------------------------------------------
-- 商店 & 交易事件
------------------------------------------------------------------

-- 当玩家从NPC商店购买物品时调用 (同步 - 可阻止购买)
function onShopBuyItem(oPlayer, oItem)
	if (oPlayer ~= nil) then
		if (oItem ~= nil) then
		
		end
		
	end
end

-- 当玩家向NPC商店出售物品时调用 (同步 - 可阻止出售)
function onShopSellItem(oPlayer, oItem)
	if (oPlayer ~= nil) then
		if (oItem ~= nil) then
		
		end
		
	end
end

-- 当玩家向NPC出售活动物品时调用 (异步)
function onShopSellEventItem(oPlayer, oItem)
	if (oPlayer ~= nil) then
		if (oItem ~= nil) then

		end
	end
end

-- Called when player interacts with Moss the Merchant (Sync - return non-zero to block)
function onMossMerchantUse(oPlayer, iSectionId)
	if (oPlayer ~= nil) then

	end
	return 0
end

------------------------------------------------------------------
-- 数据库查询事件
------------------------------------------------------------------
-- DS全局存储
local queryResultsDS = {}

-- 当收到 DataServer 数据库查询结果时调用 (异步)
function onDSDBQueryReceive(iPlayerIndex, iQueryNumber, bIsLastPacket, iCurrentRow, btColumnCount, btCurrentPacket, oRow)
	if (oRow ~= nil) then
		
	end
end

-- JS全局存储
local queryResultsJS = {}

-- 当收到 JoinServer 数据库查询结果时调用 (异步)
function onJSDBQueryReceive(iPlayerIndex, iQueryNumber, bIsLastPacket, iCurrentRow, btColumnCount, btCurrentPacket, oRow)
	if (oRow ~= nil) then
		
	end
end

