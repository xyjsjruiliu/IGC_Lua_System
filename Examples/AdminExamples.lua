--═══════════════════════════════════════════════════════════════
-- 管理员与GM命令示例
--═══════════════════════════════════════════════════════════════

------------------------------------------------------------------
-- 玩家管理命令
------------------------------------------------------------------

function GM_TeleportPlayer(adminIndex, targetName, map, x, y)
	local oTarget = Player.GetObjByName(targetName)

	if not oTarget then
		Message.Send(0, adminIndex, 0,
			string.format("玩家 '%s' 未找到或不在线", targetName))
		return false
	end

	Move.ToMap(oTarget.Index, map, x, y)
	Message.Send(0, oTarget.Index, 0, "GM 将你传送了！")
	Message.Send(0, adminIndex, 0,
		string.format("已将 %s 传送到地图 %d (%d, %d)", targetName, map, x, y))

	Log.Add(string.format("[GM] 管理员将 %s 传送到地图 %d", targetName, map))
	return true
end

function GM_SummonPlayer(adminIndex, targetName)
	local oAdmin = Player.GetObjByIndex(adminIndex)
	local oTarget = Player.GetObjByName(targetName)

	if not oAdmin or not oTarget then
		return false
	end

	Move.ToMap(oTarget.Index, oAdmin.MapNumber, oAdmin.X, oAdmin.Y)
	Message.Send(0, oTarget.Index, 0, "GM 召唤了你！")
	Message.Send(0, adminIndex, 0, string.format("已召唤 %s", targetName))

	Log.Add(string.format("[GM] 管理员召唤了 %s", targetName))
	return true
end

function GM_GotoPlayer(adminIndex, targetName)
	local oTarget = Player.GetObjByName(targetName)

	if not oTarget then
		return false
	end

	Move.ToMap(adminIndex, oTarget.MapNumber, oTarget.X, oTarget.Y)
	Message.Send(0, adminIndex, 0,
		string.format("已传送到 %s (地图 %d)", targetName, oTarget.MapNumber))

	Log.Add(string.format("[GM] 管理员前往了 %s", targetName))
	return true
end

-- 注意：Item.Create 需要 CreateItemInfo 结构体，而非原始物品ID
function GM_GiveItem(adminIndex, targetName, itemId, itemLevel)
	local oTarget = Player.GetObjByName(targetName)

	if not oTarget then
		Message.Send(0, adminIndex, 0, "玩家未找到")
		return false
	end

	local stItem = CreateItemInfo()
	stItem.ItemId = itemId
	stItem.ItemLevel = itemLevel or 0
	stItem.LootIndex = oTarget.Index
	stItem.TargetInvenPos = 255

	Item.Create(oTarget.Index, stItem)

	Message.Send(0, oTarget.Index, 1, "GM 给了你一件物品！")
	Message.Send(0, adminIndex, 0,
		string.format("已给予 %s 物品 %d (等级 %d)", targetName, itemId, itemLevel or 0))

	Log.Add(string.format("[GM] 给予 %s 物品 %d", targetName, itemId))
	return true
end

function GM_SetLevel(adminIndex, targetName, newLevel)
	local oTarget = Player.GetObjByName(targetName)

	if not oTarget then
		Message.Send(0, adminIndex, 0, "玩家未找到")
		return false
	end

	oTarget.Level = newLevel
	Player.ReCalc(oTarget.Index)

	Message.Send(0, oTarget.Index, 1,
		string.format("GM 将你的等级设置为 %d！", newLevel))
	Message.Send(0, adminIndex, 0,
		string.format("已将 %s 的等级设置为 %d", targetName, newLevel))

	Log.Add(string.format("[GM] 将 %s 的等级设置为 %d", targetName, newLevel))
	return true
end

------------------------------------------------------------------
-- 广播命令
------------------------------------------------------------------

function GM_GlobalAnnounce(message, messageType)
	local sent = 0

	Object.ForEachPlayer(function(oPlayer)
		Message.Send(0, oPlayer.Index, messageType or 2, message)
		sent = sent + 1
		return true
	end)

	Log.Add(string.format("[GM] 全局公告发送给 %d 名玩家：%s", sent, message))
	return sent
end

function GM_MapAnnounce(mapNumber, message, messageType)
	local sent = 0

	Object.ForEachPlayerOnMap(mapNumber, function(oPlayer)
		Message.Send(0, oPlayer.Index, messageType or 0, message)
		sent = sent + 1
		return true
	end)

	Log.Add(string.format("[GM] 地图 %d 公告发送给 %d 名玩家", mapNumber, sent))
	return sent
end

function GM_GuildAnnounce(guildName, message, messageType)
	local sent = 0

	Object.ForEachGuildMember(guildName, function(oMember)
		Message.Send(0, oMember.Index, messageType or 0, message)
		sent = sent + 1
		return true
	end)

	Log.Add(string.format("[GM] 战盟 '%s' 公告发送给 %d 名成员", guildName, sent))
	return sent
end

------------------------------------------------------------------
-- 批量操作
------------------------------------------------------------------

function GM_TeleportAllFromMap(adminIndex, sourceMap, targetMap, x, y)
	local teleported = 0

	Object.ForEachPlayerOnMap(sourceMap, function(oPlayer)
		Move.ToMap(oPlayer.Index, targetMap, x, y)
		Message.Send(0, oPlayer.Index, 0, "GM 批量传送！")
		teleported = teleported + 1
		return true
	end)

	Message.Send(0, adminIndex, 0,
		string.format("已将 %d 名玩家从地图 %d 传送到地图 %d",
			teleported, sourceMap, targetMap))

	Log.Add(string.format("[GM] 批量传送：%d 名玩家从地图 %d 到 %d",
		teleported, sourceMap, targetMap))

	return teleported
end

function GM_AwardZenToAll(adminIndex, zenAmount, minLevel)
	local awarded = 0

	Object.ForEachPlayer(function(oPlayer)
		if not minLevel or oPlayer.Level >= minLevel then
			Player.SetMoney(oPlayer.Index, zenAmount, false)
			Message.Send(0, oPlayer.Index, 1,
				string.format("GM 奖励：%d 金币！", zenAmount))
			awarded = awarded + 1
		end
		return true
	end)

	Message.Send(0, adminIndex, 0,
		string.format("已奖励 %d 金币给 %d 名玩家", zenAmount, awarded))

	Log.Add(string.format("[GM] 批量金币奖励：%d 金币给 %d 名玩家", zenAmount, awarded))

	return awarded
end

function GM_HealAllPlayers(adminIndex, mapNumber)
	local healed = 0

	local function healPlayer(oPlayer)
		oPlayer.Life = oPlayer.MaxLife
		oPlayer.Mana = oPlayer.MaxMana
		Player.SendLife(oPlayer.Index, oPlayer.Life, Enums.HPManaUpdateFlag.CURRENT_HP_MANA, oPlayer.Shield)
		Player.SendMana(oPlayer.Index, oPlayer.Mana, Enums.HPManaUpdateFlag.CURRENT_HP_MANA, oPlayer.BP)
		healed = healed + 1
		return true
	end

	if mapNumber then
		Object.ForEachPlayerOnMap(mapNumber, healPlayer)
	else
		Object.ForEachPlayer(healPlayer)
	end

	Message.Send(0, adminIndex, 0, string.format("已治疗 %d 名玩家", healed))
	Log.Add(string.format("[GM] 批量治疗：%d 名玩家", healed))

	return healed
end

------------------------------------------------------------------
-- 服务器监控
------------------------------------------------------------------

function GM_ServerStats(adminIndex)
	local stats = {
		totalPlayers = 0,
		totalMonsters = 0,
		vipPlayers = 0,
		elitePlayers = 0,
		avgLevel = 0,
		totalLevel = 0,
		mapDistribution = {}
	}

	Object.ForEachPlayer(function(oPlayer)
		stats.totalPlayers = stats.totalPlayers + 1
		stats.totalLevel = stats.totalLevel + oPlayer.Level

		if oPlayer.userData.VIPType >= 0 then
			stats.vipPlayers = stats.vipPlayers + 1
		end

		if oPlayer.Level >= 400 then
			stats.elitePlayers = stats.elitePlayers + 1
		end

		local map = oPlayer.MapNumber
		stats.mapDistribution[map] = (stats.mapDistribution[map] or 0) + 1

		return true
	end)

	Object.ForEachMonster(function(oMonster)
		stats.totalMonsters = stats.totalMonsters + 1
		return true
	end)

	if stats.totalPlayers > 0 then
		stats.avgLevel = math.floor(stats.totalLevel / stats.totalPlayers)
	end

	Message.Send(0, adminIndex, 0, "=== 服务器统计 ===")
	Message.Send(0, adminIndex, 0,
		string.format("玩家数：%d (VIP：%d，精英：%d)",
			stats.totalPlayers, stats.vipPlayers, stats.elitePlayers))
	Message.Send(0, adminIndex, 0,
		string.format("平均等级：%d | 怪物数：%d",
			stats.avgLevel, stats.totalMonsters))

	for map, count in pairs(stats.mapDistribution) do
		if count > 0 then
			Message.Send(0, adminIndex, 0,
				string.format("地图 %d：%d 名玩家", map, count))
		end
	end

	return stats
end

function GM_FindPlayers(adminIndex, criteria)
	local found = {}

	Object.ForEachPlayer(function(oPlayer)
		local match = true

		if criteria.minLevel and oPlayer.Level < criteria.minLevel then
			match = false
		end

		if criteria.maxLevel and oPlayer.Level > criteria.maxLevel then
			match = false
		end

		if criteria.mapNumber and oPlayer.MapNumber ~= criteria.mapNumber then
			match = false
		end

		if criteria.class and oPlayer.Class ~= criteria.class then
			match = false
		end

		if match then
			table.insert(found, {
				Name = oPlayer.Name,
				Level = oPlayer.Level,
				Map = oPlayer.MapNumber,
				Class = oPlayer.Class
			})
		end

		return true
	end)

	Message.Send(0, adminIndex, 0,
		string.format("找到 %d 名符合条件玩家", #found))

	for i, player in ipairs(found) do
		Message.Send(0, adminIndex, 0,
			string.format("%d. %s (等级 %d, 地图 %d, 职业 %d)",
				i, player.Name, player.Level, player.Map, player.Class))

		if i >= 10 then
			Message.Send(0, adminIndex, 0, "... (仅显示前10个)")
			break
		end
	end

	return found
end

function GM_FindSuspicious(adminIndex)
	local suspicious = {}

	Object.ForEachPlayer(function(oPlayer)
		local flags = {}

		if oPlayer.userData.Strength > 65000 then
			table.insert(flags, "高力量")
		end

		if oPlayer.userData.Money > 2000000000 then
			table.insert(flags, "高金币")
		end

		if oPlayer.Level == 400 and oPlayer.userData.Resets == 0 then
			table.insert(flags, "满级未转生")
		end

		if #flags > 0 then
			table.insert(suspicious, {
				Name = oPlayer.Name,
				Flags = flags,
				Map = oPlayer.MapNumber
			})
		end

		return true
	end)

	Message.Send(0, adminIndex, 0,
		string.format("找到 %d 名可疑玩家", #suspicious))

	for i, player in ipairs(suspicious) do
		Message.Send(0, adminIndex, 0,
			string.format("%s - %s (地图 %d)",
				player.Name, table.concat(player.Flags, ", "), player.Map))
	end

	return suspicious
end

--═══════════════════════════════════════════════════════════════
-- 管理员示例结束
--═══════════════════════════════════════════════════════════════