--═══════════════════════════════════════════════════════════════
-- 事件系统示例
--═══════════════════════════════════════════════════════════════
-- 状态在Lua表中跟踪，不作为C++对象的自定义字段。
--═══════════════════════════════════════════════════════════════

------------------------------------------------------------------
-- Boss事件
------------------------------------------------------------------

-- 检查地图是否清空且有足够符合条件的玩家，然后标记事件开始
function PrepareBossEvent(eventMap, minPlayers, minLevel)
	local monsterCount = Object.CountMonstersOnMap(eventMap)
	if monsterCount > 0 then
		Log.Add(string.format("[Boss事件] 地图 %d 未清空（剩余 %d 只怪物）", eventMap, monsterCount))
		return false
	end

	local eligible = Object.CountPlayersOnMap(eventMap, function(oPlayer)
		return oPlayer.Level >= minLevel
	end)

	if eligible < minPlayers then
		Object.ForEachPlayerOnMap(eventMap, function(oPlayer)
			Message.Send(0, oPlayer.Index, 0,
				string.format("Need %d players level %d+ (have %d)", minPlayers, minLevel, eligible))
			return true
		end)
		return false
	end

	Object.ForEachPlayerOnMap(eventMap, function(oPlayer)
		Message.Send(0, oPlayer.Index, 2, "Boss事件将在10秒后开始！")
		return true
	end)

	Log.Add(string.format("[Boss Event] Starting on map %d with %d eligible players",
		eventMap, eligible))
	return true
end

-- 根据Combat.GetTopDamageDealer计算的伤害比例，在Boss被击杀后奖励玩家
function BossDeathReward(eventMap, monsterIndex, totalReward)
	local topIndex = Combat.GetTopDamageDealer(monsterIndex)
	local participants = Object.CountPlayersOnMap(eventMap)

	if participants == 0 then return end

	local share = math.floor(totalReward / participants)

	Object.ForEachPlayerOnMap(eventMap, function(oPlayer)
		local reward = share
		if oPlayer.Index == topIndex then
			reward = share * 2  -- 伤害最高者双倍奖励
		end

		Player.SetMoney(oPlayer.Index, reward, false)
		Message.Send(0, oPlayer.Index, 1,
			string.format("Boss奖励：%d 金币！", reward))
		return true
	end)

	Log.Add(string.format("[Boss事件] 已向 %d 名玩家发放奖励", participants))
end

------------------------------------------------------------------
-- 入侵事件
------------------------------------------------------------------

function StartInvasionEvent(targetMap, duration)
	Object.ForEachPlayer(function(oPlayer)
		Message.Send(0, oPlayer.Index, 2,
			string.format("怪物入侵地图 %d！坚守 %d 分钟！",
				targetMap, math.floor(duration / 60000)))
		return true
	end)

	Timer.Create(duration, "invasion_end_" .. targetMap, function()
		InvasionEnd(targetMap)
	end)

	Log.Add(string.format("[入侵] 地图 %d 开始，持续 %d 毫秒", targetMap, duration))
end

function InvasionEnd(targetMap)
	local remaining = Object.CountMonstersOnMap(targetMap)

	if remaining == 0 then
		-- 胜利
		Object.ForEachPlayerOnMap(targetMap, function(oPlayer)
			Player.SetMoney(oPlayer.Index, 10000000, false)
			Message.Send(0, oPlayer.Index, 1, "入侵胜利！奖励：1000万金币！")
			return true
		end)
		Log.Add("[入侵] 胜利！")
	else
		-- 失败
		Object.ForEachPlayerOnMap(targetMap, function(oPlayer)
			Message.Send(0, oPlayer.Index, 2, "入侵失败！怪物获胜了！")
			return true
		end)
		Log.Add("[入侵] 失败 - 时间耗尽")
	end
end

------------------------------------------------------------------
-- 血色城堡
------------------------------------------------------------------

function BloodCastleEntry(playerIndex, bcLevel)
	local oPlayer = Player.GetObjByIndex(playerIndex)
	if not oPlayer then return false end

	local bcMap = 11 + bcLevel
	local currentParticipants = Object.CountPlayersOnMap(bcMap)

	if currentParticipants >= 10 then
		Message.Send(0, playerIndex, 0, "血色城堡已满！")
		return false
	end

	if oPlayer.PartyNumber >= 0 then
		local partyReady = true

		Object.ForEachPartyMember(oPlayer.PartyNumber, function(oMember)
			if oMember.Level < (bcLevel * 50) then
				partyReady = false
				return false
			end
			return true
		end)

		if not partyReady then
			Message.Send(0, playerIndex, 0, "队伍成员未达到等级要求！")
			return false
		end
	end

	return true
end

function BloodCastleComplete(bcMap, success)
	local participants = {}

	Object.ForEachPlayerOnMap(bcMap, function(oPlayer)
		table.insert(participants, oPlayer.Index)
		return true
	end)

	if success then
		local reward = 50000000
		for _, pIndex in ipairs(participants) do
			Player.SetMoney(pIndex, reward, false)
			Message.Send(0, pIndex, 1,
				string.format("血色城堡完成！奖励：%d 金币", reward))
		end
		Log.Add(string.format("[血色城堡] 成功！奖励了 %d 名玩家", #participants))
	else
		for _, pIndex in ipairs(participants) do
			Message.Send(0, pIndex, 0, "血色城堡失败！")
		end
		Log.Add(string.format("[血色城堡] 失败，参与者 %d 人", #participants))
	end

	for _, pIndex in ipairs(participants) do
		Move.ToMap(pIndex, 0, 130, 130)
	end
end

------------------------------------------------------------------
-- 恶魔广场
------------------------------------------------------------------

function DevilSquareWave(dsMap, waveNumber)
	local participants = Object.CountPlayersOnMap(dsMap)

	if participants == 0 then
		Log.Add("[恶魔广场] 无参与者 - 结束事件")
		return false
	end

	-- 清除上一波怪物
	Object.ForEachMonsterOnMap(dsMap, function(oMonster)
		Object.DelMonster(oMonster.Index)
		return true
	end)

	Object.ForEachPlayerOnMap(dsMap, function(oPlayer)
		Message.Send(0, oPlayer.Index, 2,
			string.format("恶魔广场第 %d 波！", waveNumber))
		return true
	end)

	Log.Add(string.format("[DS] Wave %d started with %d participants",
		waveNumber, participants))
	return true
end

function DevilSquareRewards(dsMap, wavesCompleted)
	local baseReward = 5000000
	local totalReward = baseReward * wavesCompleted

	Object.ForEachPlayerOnMap(dsMap, function(oPlayer)
		Player.SetMoney(oPlayer.Index, totalReward, false)
		Message.Send(0, oPlayer.Index, 1,
			string.format("Devil Square Complete! %d waves = %d zen",
				wavesCompleted, totalReward))
		return true
	end)

	Object.ForEachPlayerOnMap(dsMap, function(oPlayer)
		Move.ToMap(oPlayer.Index, 0, 130, 130)
		return true
	end)

	Log.Add(string.format("[DS] Completed %d waves, rewarded %d zen each",
		wavesCompleted, totalReward))
end

------------------------------------------------------------------
-- 生存事件 - 状态在Lua表中跟踪
------------------------------------------------------------------

local survivalData = {}

function StartSurvivalEvent(eventMap, duration)
	survivalData[eventMap] = {}

	Object.ForEachMonsterOnMap(eventMap, function(oMonster)
		Object.DelMonster(oMonster.Index)
		return true
	end)

	local participants = 0

	Object.ForEachPlayerOnMap(eventMap, function(oPlayer)
		survivalData[eventMap][oPlayer.Index] = { score = 0, alive = true }
		Message.Send(0, oPlayer.Index, 2,
			string.format("Survival Event! Last %d minutes!",
				math.floor(duration / 60000)))
		participants = participants + 1
		return true
	end)

	Log.Add(string.format("[生存] 开始，参与者 %d 人", participants))

	Timer.Create(duration, "survival_end_" .. eventMap, function()
		CompleteSurvivalEvent(eventMap)
	end)
end

function CompleteSurvivalEvent(eventMap)
	if not survivalData[eventMap] then return end

	local survivors = {}

	for pIndex, data in pairs(survivalData[eventMap]) do
		local oPlayer = Player.GetObjByIndex(pIndex)
		if oPlayer then
			table.insert(survivors, {
				Index = pIndex,
				Name = oPlayer.Name,
				Score = data.score
			})
		end
	end

	table.sort(survivors, function(a, b) return a.Score > b.Score end)

	for i, survivor in ipairs(survivors) do
		local reward = math.max(50000000 - ((i - 1) * 5000000), 10000000)

		Player.SetMoney(survivor.Index, reward, false)
		Message.Send(0, survivor.Index, 1,
			string.format("Survival Rank #%d! Reward: %d zen (Score: %d)",
				i, reward, survivor.Score))
	end

	Log.Add(string.format("[Survival] Completed with %d survivors", #survivors))
	survivalData[eventMap] = nil
end

--═══════════════════════════════════════════════════════════════
-- 怪物生成 / 移除 - Object.AddMonster + Object.DelMonster
--═══════════════════════════════════════════════════════════════

-- 在地图上生成一个Boss怪物，可带元素属性
-- iMonAttr: 使用Enums.ElementType, 0表示无元素
function SpawnBoss(mapNumber, bossClass, x, y, iMonAttr)
	local monIndex = Object.AddMonster(bossClass, mapNumber, x, y, x, y, iMonAttr or Enums.ElementType.NONE)

	if monIndex < 0 then
		Log.Add(string.format("[SpawnBoss] Failed to spawn class %d on map %d", bossClass, mapNumber))
		return -1
	end

	local elementName = "普通"
	for name, val in pairs(Enums.ElementType) do
		if val == iMonAttr then elementName = name end
	end

	Log.Add(string.format("[SpawnBoss] Spawned class %d at (%d,%d) map %d element %s index %d",
		bossClass, x, y, mapNumber, elementName, monIndex))

	Object.ForEachPlayer(function(oPlayer)
		Message.Send(0, oPlayer.Index, 2,
			string.format("A %s boss has appeared on map %d!", elementName, mapNumber))
		return true
	end)

	return monIndex
end

-- 在边界框内生成一波怪物，返回生成的索引列表
function SpawnMonsterWave(mapNumber, monClass, count, x1, y1, x2, y2, iMonAttr)
	local spawned = {}

	for i = 1, count do
		local idx = Object.AddMonster(monClass, mapNumber, x1, y1, x2, y2, iMonAttr or Enums.ElementType.NONE)
		if idx >= 0 then
			table.insert(spawned, idx)
		end
	end

	Log.Add(string.format("[Wave] Spawned %d/%d monsters (class %d) on map %d",
		#spawned, count, monClass, mapNumber))

	return spawned
end

-- 移除之前生成的一批怪物
function DespawnMonsterWave(spawnedIndices)
	local removed = 0
	for _, idx in ipairs(spawnedIndices) do
		Object.DelMonster(idx)
		removed = removed + 1
	end
	Log.Add(string.format("[Wave] Despawned %d monsters", removed))
end

-- 元素Boss事件：每个元素生成一个Boss，在持续时间后安排消失
function SpawnElementalBossEvent(mapNumber, bossClass, duration)
	local bosses = {}
	local spawnPositions = {
		{ x = 50,  y = 50,  element = Enums.ElementType.FIRE },
		{ x = 150, y = 50,  element = Enums.ElementType.WATER },
		{ x = 50,  y = 150, element = Enums.ElementType.EARTH },
		{ x = 150, y = 150, element = Enums.ElementType.WIND },
		{ x = 100, y = 100, element = Enums.ElementType.DARKNESS },
	}

	for _, pos in ipairs(spawnPositions) do
		local idx = Object.AddMonster(bossClass, mapNumber, pos.x, pos.y, pos.x, pos.y, pos.element)
		if idx >= 0 then
			table.insert(bosses, idx)
		end
	end

	Object.ForEachPlayerOnMap(mapNumber, function(oPlayer)
		Message.Send(0, oPlayer.Index, 2,
			string.format("Elemental Boss Event! Kill all 5 bosses in %d minutes!",
				math.floor(duration / 60000)))
		return true
	end)

	Log.Add(string.format("[Elemental Event] %d bosses spawned on map %d", #bosses, mapNumber))

	-- 持续时间后移除幸存者
	Timer.Create(duration, "elemental_event_end_" .. mapNumber, function()
		local remaining = 0
		for _, idx in ipairs(bosses) do
			local oMonster = Player.GetObjByIndex(idx)
			if oMonster and oMonster.Live == 1 then
				Object.DelMonster(idx)
				remaining = remaining + 1
			end
		end

		if remaining > 0 then
			Object.ForEachPlayerOnMap(mapNumber, function(oPlayer)
				Message.Send(0, oPlayer.Index, 0,
					string.format("Event ended. %d bosses escaped.", remaining))
				return true
			end)
		end
	end)
end

--═══════════════════════════════════════════════════════════════
-- 事件示例结束
--═══════════════════════════════════════════════════════════════