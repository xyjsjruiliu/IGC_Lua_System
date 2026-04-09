--═══════════════════════════════════════════════════════════════
-- 对象迭代器函数 - 过滤器示例
--═══════════════════════════════════════════════════════════════
-- 用于 CountPlayersOnMap 和 CountMonstersOnMap 的可选过滤器回调示例
--
-- 重要提示：VIP 等级系统
--   userData.VIPType: -1 = 无VIP, 0+ = 拥有VIP
--   使用: oPlayer.userData.VIPType >= 0 来检查是否有任何VIP
--═══════════════════════════════════════════════════════════════

------------------------------------------------------------------
-- 基础计数 - 无过滤器
------------------------------------------------------------------

local totalPlayers = Object.CountPlayersOnMap(0)
Log.Add(string.format("勇者大陆: %d 名玩家", totalPlayers))

local totalMonsters = Object.CountMonstersOnMap(2)
Log.Add(string.format("冰风谷: %d 只怪物", totalMonsters))

------------------------------------------------------------------
-- 玩家过滤器
------------------------------------------------------------------

local elitePlayers = Object.CountPlayersOnMap(0, function(oPlayer)
	return oPlayer.Level >= 400
end)

local vipPlayers = Object.CountPlayersOnMap(0, function(oPlayer)
	return oPlayer.userData.VIPType >= 0
end)

local veteranPlayers = Object.CountPlayersOnMap(0, function(oPlayer)
	return oPlayer.userData.Resets >= 10
end)

local richPlayers = Object.CountPlayersOnMap(0, function(oPlayer)
	return oPlayer.userData.Money >= 100000000
end)

local soloPlayers = Object.CountPlayersOnMap(0, function(oPlayer)
	return oPlayer.PartyNumber < 0
end)

local strongPlayers = Object.CountPlayersOnMap(0, function(oPlayer)
	return oPlayer.userData.Strength >= 1000
		and oPlayer.userData.Dexterity >= 1000
		and oPlayer.userData.Vitality >= 1000
end)

local playersInArea = Object.CountPlayersOnMap(2, function(oPlayer)
	return oPlayer.X >= 100 and oPlayer.X <= 150
		and oPlayer.Y >= 100 and oPlayer.Y <= 150
end)

------------------------------------------------------------------
-- 怪物过滤器
------------------------------------------------------------------

local bossCount = Object.CountMonstersOnMap(2, function(oMonster)
	return oMonster.Class >= 200 and oMonster.Class <= 250
end)

local goldenGoblins = Object.CountMonstersOnMap(0, function(oMonster)
	return oMonster.Class == 275
end)

local lowHpMonsters = Object.CountMonstersOnMap(2, function(oMonster)
	return (oMonster.Life / oMonster.MaxLife) < 0.2
end)

local monstersInArea = Object.CountMonstersOnMap(3, function(oMonster)
	return oMonster.X >= 50 and oMonster.X <= 100
		and oMonster.Y >= 50 and oMonster.Y <= 100
end)

------------------------------------------------------------------
-- 实际应用场景
------------------------------------------------------------------

-- 活动开启条件：地图清空，足够数量的合格玩家
function CanStartBossEvent(mapNumber, minPlayers, minLevel, minResets)
	if Object.CountMonstersOnMap(mapNumber) > 0 then
		return false, "请先清除所有怪物"
	end

	local eligible = Object.CountPlayersOnMap(mapNumber, function(oPlayer)
		return oPlayer.Level >= minLevel and oPlayer.userData.Resets >= minResets
	end)

	if eligible < minPlayers then
		return false, string.format("需要 %d 名合格玩家 (当前 %d 名)", minPlayers, eligible)
	end

	local solo = Object.CountPlayersOnMap(mapNumber, function(oPlayer)
		return oPlayer.PartyNumber < 0
	end)

	if solo > 0 then
		return false, "所有玩家必须组队"
	end

	return true, "活动可以开始了！"
end

-- 基于地图平均等级动态调整难度
function GetEventDifficulty(mapNumber)
	local totalLevel = 0
	local playerCount = 0

	Object.ForEachPlayerOnMap(mapNumber, function(oPlayer)
		totalLevel = totalLevel + oPlayer.Level
		playerCount = playerCount + 1
		return true
	end)

	if playerCount == 0 then return "简单" end

	local avgLevel = totalLevel / playerCount

	if avgLevel >= 400 then return "困难"
	elseif avgLevel >= 350 then return "普通"
	else return "简单"
	end
end

-- 仅奖励符合条件的参与者
function AwardEventRewards(mapNumber, minLevel, minResets, rewardBase)
	local eliteCount = Object.CountPlayersOnMap(mapNumber, function(oPlayer)
		return oPlayer.Level >= minLevel and oPlayer.userData.Resets >= minResets
	end)

	local reward = rewardBase * eliteCount

	Object.ForEachPlayerOnMap(mapNumber, function(oPlayer)
		if oPlayer.Level >= minLevel and oPlayer.userData.Resets >= minResets then
			Player.SetMoney(oPlayer.Index, reward, false)
			Message.Send(0, oPlayer.Index, 1,
				string.format("活动奖励: %d 金币！", reward))
		end
		return true
	end)

	Log.Add(string.format("Awarded %d zen to %d players", reward, eliteCount))
end

-- 怪物重生触发器
function NeedsRespawn(mapNumber, monsterClass, minCount)
	local count = Object.CountMonstersOnMap(mapNumber, function(oMonster)
		return oMonster.Class == monsterClass
	end)

	if count < minCount then
		Log.Add(string.format("Map %d needs respawn: %d/%d of class %d",
			mapNumber, count, minCount, monsterClass))
		return true
	end

	return false
end

-- 每分钟低血量警报
function CheckLowHPPlayers()
	for mapNum = 0, 10 do
		local lowHp = Object.CountPlayersOnMap(mapNum, function(oPlayer)
			return (oPlayer.Life / oPlayer.MaxLife) < 0.3
		end)

		if lowHp > 3 then
			Log.Add(string.format("地图 %d: %d 名玩家血量过低！", mapNum, lowHp))
		end
	end
end

--═══════════════════════════════════════════════════════════════
-- 过滤器示例结束
--═══════════════════════════════════════════════════════════════