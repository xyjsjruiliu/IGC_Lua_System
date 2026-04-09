--═══════════════════════════════════════════════════════════════
-- 公会系统示例
--═══════════════════════════════════════════════════════════════

-- 列出所有在线公会成员
function ListGuildMembers(guildName)
	local count = 0
	Log.Add(string.format("=== 公会成员：%s ===", guildName))

	Object.ForEachGuildMember(guildName, function(oPlayer)
		count = count + 1
		Log.Add(string.format("%d. %s (等级 %d)", count, oPlayer.Name, oPlayer.Level))
		return true
	end)

	Log.Add(string.format("在线成员总数：%d", count))
end

-- 获取在线公会成员的平均等级
function GetGuildAverageLevel(guildName)
	local totalLevel = 0
	local count = 0

	Object.ForEachGuildMember(guildName, function(oPlayer)
		totalLevel = totalLevel + oPlayer.Level
		count = count + 1
		return true
	end)

	if count > 0 then
		local average = totalLevel / count
		Log.Add(string.format("公会 %s 平均等级：%.2f (在线 %d 人)", guildName, average, count))
		return average
	end

	return 0
end

-- 统计在线公会成员数量
function GetOnlineGuildCount(guildName)
	local count = 0

	Object.ForEachGuildMember(guildName, function(oMember)
		count = count + 1
		return true
	end)

	return count
end

-- 向所有在线公会成员发送公告
function GuildBroadcast(guildName, message, messageType)
	local sent = 0

	Object.ForEachGuildMember(guildName, function(oMember)
		Message.Send(0, oMember.Index, messageType or 0, message)
		sent = sent + 1
		return true
	end)

	Log.Add(string.format("[公会] %s：已向 %d 名成员发送消息", guildName, sent))
	return sent
end

-- 为所有在线公会成员添加增益效果
function BuffGuild(guildName, oBuffPlayer, buffId, duration)
	-- oBuffPlayer 作为 Buff.Add 的增益来源对象
	local buffedCount = 0

	Object.ForEachGuildMember(guildName, function(oPlayer)
		Buff.Add(oPlayer, buffId, 0, 100, 0, 0, duration, 0, -1)
		buffedCount = buffedCount + 1
		Message.Send(0, oPlayer.Index, 1,
			string.format("公会增益已激活：%d 秒！", duration))
		return true
	end)

	Log.Add(string.format("Buffed %d members of guild %s", buffedCount, guildName))
end

-- 奖励所有在线公会成员
function GiveGuildReward(guildName, zenAmount, reason)
	local rewardedCount = 0

	Object.ForEachGuildMember(guildName, function(oPlayer)
		Player.SetMoney(oPlayer.Index, zenAmount, false)
		rewardedCount = rewardedCount + 1

		Message.Send(0, oPlayer.Index, 0,
			string.format("公会奖励：+%d 金币！原因：%s", zenAmount, reason))
		return true
	end)

	Log.Add(string.format("Rewarded %d guild members with %d Zen",
		rewardedCount, zenAmount))
end

-- 将所有在线公会成员传送到指定地图
function SummonGuild(guildName, targetMap, targetX, targetY)
	local summonedCount = 0

	Object.ForEachGuildMember(guildName, function(oPlayer)
		Move.ToMap(oPlayer.Index, targetMap, targetX, targetY)
		summonedCount = summonedCount + 1
		Message.Send(0, oPlayer.Index, 1, "公会召唤已激活！")
		return true
	end)

	Log.Add(string.format("Summoned %d guild members to map %d",
		summonedCount, targetMap))
end

-- 获取指定地图上的公会成员
function GetGuildMembersOnMap(guildName, mapNumber)
	local members = {}

	Object.ForEachGuildMember(guildName, function(oPlayer)
		if oPlayer.MapNumber == mapNumber then
			table.insert(members, oPlayer.Name)
		end
		return true
	end)

	return members
end

-- 获取公会PvP统计信息
function GetGuildPvPStats(guildName)
	local stats = {
		totalMembers = 0,
		pkPlayers = 0,
		totalPKCount = 0,
		averagePK = 0
	}

	Object.ForEachGuildMember(guildName, function(oPlayer)
		stats.totalMembers = stats.totalMembers + 1
		stats.totalPKCount = stats.totalPKCount + oPlayer.PKCount

		if oPlayer.PKLevel > 0 then
			stats.pkPlayers = stats.pkPlayers + 1
		end
		return true
	end)

	if stats.totalMembers > 0 then
		stats.averagePK = stats.totalPKCount / stats.totalMembers
	end

	Log.Add(string.format("Guild %s: %d online, %d PK players, avg PK %.2f",
		guildName, stats.totalMembers, stats.pkPlayers, stats.averagePK))

	return stats
end

-- 获取公会整体统计信息
function GetGuildStats(guildName)
	local stats = {
		onlineCount = 0,
		totalLevel = 0,
		avgLevel = 0,
		maxLevel = 0,
		totalResets = 0
	}

	Object.ForEachGuildMember(guildName, function(oMember)
		stats.onlineCount = stats.onlineCount + 1
		stats.totalLevel = stats.totalLevel + oMember.Level
		stats.totalResets = stats.totalResets + oMember.userData.Resets

		if oMember.Level > stats.maxLevel then
			stats.maxLevel = oMember.Level
		end

		return true
	end)

	if stats.onlineCount > 0 then
		stats.avgLevel = math.floor(stats.totalLevel / stats.onlineCount)
	end

	return stats
end

--═══════════════════════════════════════════════════════════════
-- 公会示例结束
--═══════════════════════════════════════════════════════════════