--═══════════════════════════════════════════════════════════════
-- 定时器功能示例
--═══════════════════════════════════════════════════════════════
-- Timer.Create 创建一个单次定时器：
--   Timer.Create(持续时间毫秒, 唯一名称, 回调函数)
-- Timer.GetTick 返回当前服务器计时毫秒数。
-- 每秒/每分钟的逻辑在回调循环中完成，
-- 通过 Timer.Create 配合重复重新调度实现。
--═══════════════════════════════════════════════════════════════

------------------------------------------------------------------
-- 每秒任务
------------------------------------------------------------------

-- VIP 恢复 - 每秒调用
function TimerProcSecond()
	local currentTick = Timer.GetTick()

	Object.ForEachPlayer(function(oPlayer)
		if oPlayer.userData.VIPType >= 0 then
			oPlayer.Life = math.min(oPlayer.Life + 50, oPlayer.MaxLife)
			oPlayer.Mana = math.min(oPlayer.Mana + 50, oPlayer.MaxMana)
			Player.SendLife(oPlayer.Index, oPlayer.Life, Enums.HPManaUpdateFlag.CURRENT_HP_MANA, oPlayer.Shield)
			Player.SendMana(oPlayer.Index, oPlayer.Mana, Enums.HPManaUpdateFlag.CURRENT_HP_MANA, oPlayer.BP)
		end
		return true
	end)
end

-- PvP 区域 DOT（竞技场地图 6 安全区外）
function PvPZoneDOT()
	Object.ForEachPlayerOnMap(6, function(oPlayer)
		-- 坐标 50-60, 50-60 为安全区
		if not (oPlayer.X >= 50 and oPlayer.X <= 60 and oPlayer.Y >= 50 and oPlayer.Y <= 60) then
			oPlayer.Life = math.max(oPlayer.Life - 100, 1)
			Player.SendLife(oPlayer.Index, oPlayer.Life, Enums.HPManaUpdateFlag.CURRENT_HP_MANA, oPlayer.Shield)
		end
		return true
	end)
end

------------------------------------------------------------------
-- 每分钟任务
------------------------------------------------------------------

-- 在线时长奖励（含 VIP 倍率），状态在 Lua 表中跟踪
local lastBonusTick = {}

function TimerProcMinute()
	local currentTick = Timer.GetTick()
	local bonusInterval = 1800000  -- 30 分钟

	Object.ForEachPlayer(function(oPlayer)
		local idx = oPlayer.Index

		if not lastBonusTick[idx] then
			lastBonusTick[idx] = currentTick
			return true
		end

		if (currentTick - lastBonusTick[idx]) >= bonusInterval then
			local bonus = 1000000

			if oPlayer.userData.VIPType >= 0 then
				bonus = bonus * (oPlayer.userData.VIPType + 2)
			end

			Player.SetMoney(idx, bonus, false)
			Message.Send(0, idx, 1,
				string.format("在线奖励：%d 金币！", bonus))

			lastBonusTick[idx] = currentTick
		end

		return true
	end)
end

-- 地图人口公告（仅限人数 >= 10 的地图）
function AnnounceMapPopulation()
	local popularMaps = {}

	for mapNum = 0, 10 do
		local count = Object.CountPlayersOnMap(mapNum)
		if count >= 10 then
			table.insert(popularMaps, { map = mapNum, count = count })
		end
	end

	if #popularMaps == 0 then return end

	table.sort(popularMaps, function(a, b) return a.count > b.count end)

	local message = "热门地图："
	for i = 1, math.min(3, #popularMaps) do
		message = message .. string.format("地图%d(%d) ",
			popularMaps[i].map, popularMaps[i].count)
	end

	Object.ForEachPlayer(function(oPlayer)
		Message.Send(0, oPlayer.Index, 0, message)
		return true
	end)
end

-- 公会活动日志
function TrackGuildActivity()
	local guilds = {}

	Object.ForEachPlayer(function(oPlayer)
		-- GuildName 是 stObject 上的真实字段
		local guildName = oPlayer.GuildName
		if guildName and guildName ~= "" then
			if not guilds[guildName] then
				guilds[guildName] = { count = 0, totalLevel = 0 }
			end
			guilds[guildName].count = guilds[guildName].count + 1
			guilds[guildName].totalLevel = guilds[guildName].totalLevel + oPlayer.Level
		end
		return true
	end)

	for guildName, data in pairs(guilds) do
		local avg = math.floor(data.totalLevel / data.count)
		Log.Add(string.format("[Guild] %s: %d online (avg lvl %d)",
			guildName, data.count, avg))
	end
end

------------------------------------------------------------------
-- 每 5 分钟任务
------------------------------------------------------------------

-- 刷怪控制：每个在线玩家对应 3 只怪物目标
function AutoSpawnControl()
	local spawnMaps = { 0, 2, 3, 7, 8 }

	for _, mapNum in ipairs(spawnMaps) do
		local playerCount = Object.CountPlayersOnMap(mapNum)
		local monsterCount = Object.CountMonstersOnMap(mapNum)
		local targetCount = playerCount * 3

		if monsterCount < targetCount then
			local needed = targetCount - monsterCount
			Log.Add(string.format("[Spawn] Map %d needs %d monsters (players: %d, current: %d)",
				mapNum, needed, playerCount, monsterCount))

			for i = 1, needed do
				Object.AddMonster(20, mapNum, 0, 0, 255, 255, Enums.ElementType.NONE)
			end
		end
	end
end

-- 服务器统计日志
function CollectServerStatistics()
	local stats = {
		totalPlayers = 0,
		totalMonsters = 0,
		vipPlayers = 0,
		avgLevel = 0,
		totalLevel = 0
	}

	Object.ForEachPlayer(function(oPlayer)
		stats.totalPlayers = stats.totalPlayers + 1
		stats.totalLevel = stats.totalLevel + oPlayer.Level

		if oPlayer.userData.VIPType >= 0 then
			stats.vipPlayers = stats.vipPlayers + 1
		end

		return true
	end)

	Object.ForEachMonster(function(oMonster)
		stats.totalMonsters = stats.totalMonsters + 1
		return true
	end)

	if stats.totalPlayers > 0 then
		stats.avgLevel = math.floor(stats.totalLevel / stats.totalPlayers)
	end

	Log.Add(string.format("[Stats] Players: %d (VIP: %d, Avg Lvl: %d) | Monsters: %d",
		stats.totalPlayers, stats.vipPlayers, stats.avgLevel, stats.totalMonsters))
end

------------------------------------------------------------------
-- 每小时任务
------------------------------------------------------------------

-- 小时奖励（含 VIP 倍率），状态在 Lua 表中跟踪
local lastHourlyTick = {}

function HourlyRewards()
	local currentTick = Timer.GetTick()
	local hourlyInterval = 3600000

	Object.ForEachPlayer(function(oPlayer)
		local idx = oPlayer.Index

		if not lastHourlyTick[idx] then
			lastHourlyTick[idx] = currentTick
			return true
		end

		if (currentTick - lastHourlyTick[idx]) >= hourlyInterval then
			local reward = 5000000

			if oPlayer.userData.VIPType >= 0 then
				reward = reward * (oPlayer.userData.VIPType + 2)
			end

			Player.SetMoney(idx, reward, false)
			Message.Send(0, idx, 1,
				string.format("小时奖励：%d 金币！", reward))

			lastHourlyTick[idx] = currentTick
		end

		return true
	end)
end

-- 每日排行榜公告（按重置次数和等级取前三）
function UpdateDailyRankings()
	local players = {}

	Object.ForEachPlayer(function(oPlayer)
		table.insert(players, {
			Name = oPlayer.Name,
			Level = oPlayer.Level,
			Resets = oPlayer.userData.Resets
		})
		return true
	end)

	table.sort(players, function(a, b)
		if a.Resets ~= b.Resets then
			return a.Resets > b.Resets
		end
		return a.Level > b.Level
	end)

	local announcement = "顶尖玩家："
	for i = 1, math.min(3, #players) do
		announcement = announcement .. string.format("%d.%s(转生%d/等级%d) ",
			i, players[i].Name, players[i].Resets, players[i].Level)
	end

	Object.ForEachPlayer(function(oPlayer)
		Message.Send(0, oPlayer.Index, 2, announcement)
		return true
	end)

	Log.Add(string.format("[排行榜] %s", announcement))
end

-- 每小时清理：清除空地图的怪物
function HourlyMapCleanup()
	for mapNum = 0, 10 do
		local playerCount = Object.CountPlayersOnMap(mapNum)

		if playerCount == 0 then
			local monsterCount = Object.CountMonstersOnMap(mapNum)

			if monsterCount > 0 then
				Object.ForEachMonsterOnMap(mapNum, function(oMonster)
					Object.DelMonster(oMonster.Index)
					return true
				end)

				Log.Add(string.format("[清理] 地图 %d：清除了 %d 只怪物",
					mapNum, monsterCount))
			end
		end
	end
end

------------------------------------------------------------------
-- 基于事件的单次定时器
------------------------------------------------------------------

-- Boss 活动：清空地图，验证至少 5 名合格玩家，然后生成 Boss
function BossEventTimer(eventMap, bossClass)
	Object.ForEachMonsterOnMap(eventMap, function(oMonster)
		Object.DelMonster(oMonster.Index)
		return true
	end)

	local participants = Object.CountPlayersOnMap(eventMap, function(oPlayer)
		return oPlayer.Level >= 400
	end)

	if participants >= 5 then
		Log.Add(string.format("[Boss活动] 开始，参与人数：%d", participants))

		Object.ForEachPlayerOnMap(eventMap, function(oPlayer)
			Message.Send(0, oPlayer.Index, 2, "Boss活动开始！")
			return true
		end)

		-- 在地图中央生成火属性 Boss
		local monIndex = Object.AddMonster(bossClass, eventMap, 120, 120, 120, 120, Enums.ElementType.FIRE)
		if monIndex >= 0 then
			Log.Add(string.format("[Boss Event] Boss spawned at index %d", monIndex))
		end
	else
		Log.Add(string.format("[Boss Event] Cancelled - need 5 players (have %d)", participants))
	end
end

-- 锦标赛：开始阶段标记参与者，结束阶段找出最后的幸存者
local tournamentParticipants = {}  -- [玩家索引] = true

function PvPTournamentStart(arenaMap)
	tournamentParticipants = {}

	Object.ForEachMonsterOnMap(arenaMap, function(oMonster)
		Object.DelMonster(oMonster.Index)
		return true
	end)

	local participants = 0

	Object.ForEachPlayerOnMap(arenaMap, function(oPlayer)
		tournamentParticipants[oPlayer.Index] = true
		Message.Send(0, oPlayer.Index, 2, "锦标赛开始！")
		participants = participants + 1
		return true
	end)

	Log.Add(string.format("[锦标赛] 开始，参与人数：%d", participants))
end

function PvPTournamentEnd(arenaMap)
	local winner = nil

	Object.ForEachPlayerOnMap(arenaMap, function(oPlayer)
		if tournamentParticipants[oPlayer.Index] then
			winner = oPlayer
			return false  -- 找到第一个即停止
		end
		return true
	end)

	if winner then
		Player.SetMoney(winner.Index, 50000000, false)

		Object.ForEachPlayer(function(oPlayer)
			Message.Send(0, oPlayer.Index, 2,
				string.format("锦标赛冠军：%s！", winner.Name))
			return true
		end)

		Log.Add(string.format("[锦标赛] 冠军：%s", winner.Name))
	end

	tournamentParticipants = {}
end

--═══════════════════════════════════════════════════════════════
-- 定时器示例结束
--═══════════════════════════════════════════════════════════════