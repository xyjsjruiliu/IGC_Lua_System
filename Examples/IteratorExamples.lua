--═══════════════════════════════════════════════════════════════
-- 迭代器函数 - 完整示例
--═══════════════════════════════════════════════════════════════

------------------------------------------------------------------
-- Object.ForEachPlayer - 所有已连接的玩家
------------------------------------------------------------------

function SendGlobalAnnouncement(message, messageType)
	local count = 0

	Object.ForEachPlayer(function(oPlayer)
		Message.Send(0, oPlayer.Index, messageType or 0, message)
		count = count + 1
		return true
	end)

	Log.Add(string.format("已向 %d 名玩家发送公告", count))
end

function CollectPlayerStats()
	local stats = {
		totalPlayers = 0,
		totalLevel = 0,
		maxLevel = 0,
		minLevel = 999,
		avgLevel = 0,
		vipCount = 0,
		totalResets = 0
	}

	Object.ForEachPlayer(function(oPlayer)
		stats.totalPlayers = stats.totalPlayers + 1
		stats.totalLevel = stats.totalLevel + oPlayer.Level

		if oPlayer.Level > stats.maxLevel then stats.maxLevel = oPlayer.Level end
		if oPlayer.Level < stats.minLevel then stats.minLevel = oPlayer.Level end

		if oPlayer.userData.VIPType >= 0 then
			stats.vipCount = stats.vipCount + 1
		end

		stats.totalResets = stats.totalResets + oPlayer.userData.Resets

		return true
	end)

	if stats.totalPlayers > 0 then
		stats.avgLevel = math.floor(stats.totalLevel / stats.totalPlayers)
	end

	return stats
end

function FindRichestPlayer()
	local richest = nil
	local maxMoney = 0

	Object.ForEachPlayer(function(oPlayer)
		if oPlayer.userData.Money > maxMoney then
			maxMoney = oPlayer.userData.Money
			richest = oPlayer
		end
		return true
	end)

	if richest then
		Log.Add(string.format("最富有的玩家：%s 拥有 %d 金币", richest.Name, maxMoney))
	end

	return richest
end

------------------------------------------------------------------
-- Object.ForEachPlayerOnMap - 特定地图上的玩家
------------------------------------------------------------------

function TeleportAllFromMap(sourceMap, targetMap, x, y)
	local teleported = 0

	Object.ForEachPlayerOnMap(sourceMap, function(oPlayer)
		Move.ToMap(oPlayer.Index, targetMap, x, y)
		Message.Send(0, oPlayer.Index, 0, "你已被传送！")
		teleported = teleported + 1
		return true
	end)

	Log.Add(string.format("已将 %d 名玩家从地图 %d 传送", teleported, sourceMap))
end

function IsMapEmpty(mapNumber)
	local isEmpty = true

	Object.ForEachPlayerOnMap(mapNumber, function(oPlayer)
		isEmpty = false
		return false  -- 找到第一个即停止
	end)

	return isEmpty
end

function AwardZoneBonus(mapNumber, bonusZen)
	Object.ForEachPlayerOnMap(mapNumber, function(oPlayer)
		Player.SetMoney(oPlayer.Index, bonusZen, false)
		Message.Send(0, oPlayer.Index, 1,
			string.format("区域奖励：%d 金币！", bonusZen))
		return true
	end)
end

------------------------------------------------------------------
-- Object.ForEachMonster - 所有存活的怪物
------------------------------------------------------------------

function HealAllMonsters()
	local healed = 0

	Object.ForEachMonster(function(oMonster)
		oMonster.Life = oMonster.MaxLife
		oMonster.Mana = oMonster.MaxMana
		healed = healed + 1
		return true
	end)

	Log.Add(string.format("已治疗 %d 只怪物", healed))
end

function KillAllMonsters()
	local killed = 0

	Object.ForEachMonster(function(oMonster)
		Object.DelMonster(oMonster.Index)
		killed = killed + 1
		return true
	end)

	Log.Add(string.format("已杀死 %d 只怪物", killed))
end

function FindWoundedMonsters(hpThreshold)
	local wounded = {}

	Object.ForEachMonster(function(oMonster)
		local hpPercent = (oMonster.Life / oMonster.MaxLife) * 100
		if hpPercent < hpThreshold then
			table.insert(wounded, {
				Class = oMonster.Class,
				Index = oMonster.Index,
				HP = hpPercent,
				Map = oMonster.MapNumber,
				X = oMonster.X,
				Y = oMonster.Y
			})
		end
		return true
	end)

	return wounded
end

------------------------------------------------------------------
-- Object.ForEachMonsterOnMap - 特定地图上的怪物
------------------------------------------------------------------

function ClearMapMonsters(mapNumber)
	local cleared = 0

	Object.ForEachMonsterOnMap(mapNumber, function(oMonster)
		Object.DelMonster(oMonster.Index)
		cleared = cleared + 1
		return true
	end)

	Log.Add(string.format("Cleared %d monsters from map %d", cleared, mapNumber))
end

function CheckMonsterDensity(mapNumber, expectedCount)
	local count = 0

	Object.ForEachMonsterOnMap(mapNumber, function(oMonster)
		count = count + 1
		return true
	end)

	if count < expectedCount then
		Log.Add(string.format("地图 %d：怪物数量不足 (%d/%d)",
			mapNumber, count, expectedCount))
		return true  -- 需要重生
	end

	return false
end

function FindBossOnMap(mapNumber)
	local bosses = {}

	Object.ForEachMonsterOnMap(mapNumber, function(oMonster)
		if oMonster.Class >= 200 and oMonster.Class <= 250 then
			table.insert(bosses, {
				Class = oMonster.Class,
				Index = oMonster.Index,
				HP = (oMonster.Life / oMonster.MaxLife) * 100,
				X = oMonster.X,
				Y = oMonster.Y
			})
		end
		return true
	end)

	return bosses
end

------------------------------------------------------------------
-- Object.ForEachMonsterByClass - 特定类型的怪物
------------------------------------------------------------------

function FindGoldenGoblins()
	local goblins = {}

	Object.ForEachMonsterByClass(275, function(oMonster)
		table.insert(goblins, {
			Index = oMonster.Index,
			Map = oMonster.MapNumber,
			X = oMonster.X,
			Y = oMonster.Y,
			HP = (oMonster.Life / oMonster.MaxLife) * 100
		})
		return true
	end)

	if #goblins > 0 then
		Log.Add(string.format("找到 %d 只黄金哥布林", #goblins))
	end

	return goblins
end

function KillMonsterType(monsterClass)
	local killed = 0

	Object.ForEachMonsterByClass(monsterClass, function(oMonster)
		Object.DelMonster(oMonster.Index)
		killed = killed + 1
		return true
	end)

	Log.Add(string.format("已杀死 %d 只类型为 %d 的怪物", killed, monsterClass))
end

-- 向所有玩家公告 Boss 出生位置
function AnnounceBossSpawn(bossClass)
	Object.ForEachMonsterByClass(bossClass, function(oMonster)
		local msg = string.format("Boss 已在地图 %d 的 (%d, %d) 处出现！",
			oMonster.MapNumber, oMonster.X, oMonster.Y)

		Object.ForEachPlayer(function(oPlayer)
			Message.Send(0, oPlayer.Index, 2, msg)
			return true
		end)

		return false  -- 仅公告第一个
	end)
end

------------------------------------------------------------------
-- Object.ForEachPartyMember - 队伍迭代
------------------------------------------------------------------

function AwardPartyBonus(partyNumber, bonusZen)
	local awarded = 0

	Object.ForEachPartyMember(partyNumber, function(oMember)
		Player.SetMoney(oMember.Index, bonusZen, false)
		Message.Send(0, oMember.Index, 1,
			string.format("队伍奖励：%d 金币！", bonusZen))
		awarded = awarded + 1
		return true
	end)

	Log.Add(string.format("已向 %d 名队员发放队伍奖励", awarded))
end

function GetPartyAverageLevel(partyNumber)
	local totalLevel = 0
	local count = 0

	Object.ForEachPartyMember(partyNumber, function(oMember)
		totalLevel = totalLevel + oMember.Level
		count = count + 1
		return true
	end)

	if count > 0 then
		return math.floor(totalLevel / count)
	end

	return 0
end

function TeleportParty(partyNumber, targetMap, x, y)
	local teleported = 0

	Object.ForEachPartyMember(partyNumber, function(oMember)
		Move.ToMap(oMember.Index, targetMap, x, y)
		teleported = teleported + 1
		return true
	end)

	Log.Add(string.format("已传送 %d 名队伍成员", teleported))
end

------------------------------------------------------------------
-- Object.ForEachGuildMember - 战盟迭代
------------------------------------------------------------------

function GuildBroadcast(guildName, message, messageType)
	local sent = 0

	Object.ForEachGuildMember(guildName, function(oMember)
		Message.Send(0, oMember.Index, messageType or 0, message)
		sent = sent + 1
		return true
	end)

	Log.Add(string.format("已向 %d 名战盟成员发送消息", sent))
end

function AwardGuildAchievement(guildName, bonusZen, bonusItemId)
	local awarded = 0

	Object.ForEachGuildMember(guildName, function(oMember)
		Player.SetMoney(oMember.Index, bonusZen, false)

		if bonusItemId then
			local stItem = CreateItemInfo()
			stItem.ItemId = bonusItemId
			stItem.LootIndex = oMember.Index
			stItem.TargetInvenPos = 255
			Item.Create(oMember.Index, stItem)
		end

		Message.Send(0, oMember.Index, 1,
			string.format("战盟成就：%d 金币！", bonusZen))
		awarded = awarded + 1
		return true
	end)

	Log.Add(string.format("已向 %d 名战盟成员发放成就奖励", awarded))
end

function TeleportGuildToWar(guildName, targetMap, x, y)
	local teleported = 0

	Object.ForEachGuildMember(guildName, function(oMember)
		Move.ToMap(oMember.Index, targetMap, x, y)
		Message.Send(0, oMember.Index, 2, "战盟战争！准备战斗！")
		teleported = teleported + 1
		return true
	end)

	Log.Add(string.format("已将 %d 名战盟成员传送到战场", teleported))
end

------------------------------------------------------------------
-- 区域迭代（无需 ForEachNearby，使用地图 + 距离计算）
------------------------------------------------------------------

function AOEHeal(centerIndex, range, healAmount)
	local oCenter = Player.GetObjByIndex(centerIndex)
	if not oCenter then return 0 end

	local healed = 0

	Object.ForEachPlayerOnMap(oCenter.MapNumber, function(oPlayer)
		local dx = oPlayer.X - oCenter.X
		local dy = oPlayer.Y - oCenter.Y

		if math.sqrt(dx * dx + dy * dy) <= range then
			oPlayer.Life = math.min(oPlayer.Life + healAmount, oPlayer.MaxLife)
			Player.SendLife(oPlayer.Index, oPlayer.Life, Enums.HPManaUpdateFlag.CURRENT_HP_MANA, oPlayer.Shield)
			healed = healed + 1
		end
		return true
	end)

	return healed
end

function AOEDamage(centerIndex, range, damage)
	local oCenter = Player.GetObjByIndex(centerIndex)
	if not oCenter then return 0 end

	local damaged = 0

	Object.ForEachMonsterOnMap(oCenter.MapNumber, function(oMonster)
		local dx = oMonster.X - oCenter.X
		local dy = oMonster.Y - oCenter.Y

		if math.sqrt(dx * dx + dy * dy) <= range then
			oMonster.Life = math.max(oMonster.Life - damage, 0)
			damaged = damaged + 1
		end
		return true
	end)

	return damaged
end

function FindNearestMonster(centerIndex, maxRange)
	local oCenter = Player.GetObjByIndex(centerIndex)
	if not oCenter then return nil, 0 end

	local nearest = nil
	local nearestDist = maxRange + 1

	Object.ForEachMonsterOnMap(oCenter.MapNumber, function(oMonster)
		local dx = oMonster.X - oCenter.X
		local dy = oMonster.Y - oCenter.Y
		local dist = math.sqrt(dx * dx + dy * dy)

		if dist < nearestDist then
			nearest = oMonster
			nearestDist = dist
		end
		return true
	end)

	return nearest, nearestDist
end

--═══════════════════════════════════════════════════════════════
-- 迭代器示例结束
--═══════════════════════════════════════════════════════════════