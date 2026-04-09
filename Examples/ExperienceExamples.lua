--═══════════════════════════════════════════════════════════════
-- 经验系统示例
--═══════════════════════════════════════════════════════════════
-- Player.SetExp 函数签名:
--   Player.SetExp(iPlayerIndex, iTargetIndex, i64Exp, iAttackDamage, bMSBFlag, iMonsterType)
-- 必须先修改 oPlayer.Experience，再调用 Player.SetExp 发送数据包。
-- Message.Send 函数签名:
--   Message.Send(iPlayerIndex, aTargetIndex, btType, szMessage)
--═══════════════════════════════════════════════════════════════

-- 基础经验给予
function GiveExperience(oPlayer, amount)
	oPlayer.Experience = oPlayer.Experience + amount
	Player.SetExp(oPlayer.Index, -1, amount, 0, false, 0)
	Message.Send(0, oPlayer.Index, 0, string.format("获得了 %d 点经验值！", amount))
end

-- 任务奖励经验
function CompleteQuest(oPlayer, questName, expReward)
	Log.Add(string.format("%s 完成了任务：%s", oPlayer.Name, questName))

	oPlayer.Experience = oPlayer.Experience + expReward
	Player.SetExp(oPlayer.Index, -1, expReward, 0, false, 0)

	Message.Send(0, oPlayer.Index, 1,
		string.format("Quest Complete: %s! +%d EXP", questName, expReward))
end

-- 基于等级的经验缩放
function GiveScaledExperience(oPlayer, baseAmount)
	local multiplier = 1.0

	if oPlayer.Level < 100 then
		multiplier = 2.0
	elseif oPlayer.Level < 200 then
		multiplier = 1.5
	end

	local finalAmount = math.floor(baseAmount * multiplier)

	oPlayer.Experience = oPlayer.Experience + finalAmount
	Player.SetExp(oPlayer.Index, -1, finalAmount, 0, false, 0)

	if multiplier > 1.0 then
		Message.Send(0, oPlayer.Index, 0,
			string.format("Gained %d exp (x%.1f bonus!)", finalAmount, multiplier))
	end
end

-- 队伍经验分配
function DistributePartyExp(partyLeaderIndex, totalExp)
	local partyCount = Party.GetCount(partyLeaderIndex)

	if partyCount == 0 then
		return
	end

	local bonusMultiplier = 1.0 + (partyCount * 0.1)
	local totalWithBonus = math.floor(totalExp * bonusMultiplier)
	local expPerMember = math.floor(totalWithBonus / partyCount)

	Log.Add(string.format("队伍经验：总计 %d，每人 %d（x%.1f 加成）",
		totalWithBonus, expPerMember, bonusMultiplier))

	Object.ForEachPartyMember(partyLeaderIndex, function(oMember)
		oMember.Experience = oMember.Experience + expPerMember
		Player.SetExp(oMember.Index, -1, expPerMember, 0, false, 0)

		Message.Send(0, oMember.Index, 0,
			string.format("Party EXP: +%d (x%.1f bonus)", expPerMember, bonusMultiplier))
		return true
	end)
end

-- BOSS击杀经验
function OnBossKilled(oPlayer, bossIndex, bossClass)
	local bossRewards = {
		[275] = 500000,
		[276] = 750000,
		[277] = 1000000
	}

	local expReward = bossRewards[bossClass] or 100000

	oPlayer.Experience = oPlayer.Experience + expReward
	Player.SetExp(oPlayer.Index, bossIndex, expReward, 0, false, bossClass)

	-- 向所有玩家广播
	Object.ForEachPlayer(function(oP)
		Message.Send(0, oP.Index, 1,
			string.format("%s 击败了一只BOSS，获得了 %d 点经验值！", oPlayer.Name, expReward))
		return true
	end)
end

-- 活动经验倍率（Lua侧变量）
local eventExpMultiplier = 1.0
local eventExpActive = false

function SetEventExpMultiplier(multiplier, duration)
	eventExpMultiplier = multiplier
	eventExpActive = true

	Object.ForEachPlayer(function(oP)
		Message.Send(0, oP.Index, 1,
			string.format("经验活动：x%.1f 持续 %d 分钟！", multiplier, duration / 60))
		return true
	end)

	Timer.Create(duration * 1000, "exp_event_end", function()
		eventExpMultiplier = 1.0
		eventExpActive = false

		Object.ForEachPlayer(function(oP)
			Message.Send(0, oP.Index, 1, "经验活动结束了！")
			return true
		end)
	end)
end

function GiveEventExperience(oPlayer, baseAmount)
	local finalAmount = math.floor(baseAmount * eventExpMultiplier)

	oPlayer.Experience = oPlayer.Experience + finalAmount
	Player.SetExp(oPlayer.Index, -1, finalAmount, 0, false, 0)

	if eventExpActive and eventExpMultiplier > 1.0 then
		Message.Send(0, oPlayer.Index, 0,
			string.format("Gained %d exp (Event x%.1f!)", finalAmount, eventExpMultiplier))
	end
end

-- 每日任务加成（Lua侧状态跟踪）
local dailyQuestData = {}

function GiveDailyQuestExp(oPlayer, questId, baseExp)
	local key = oPlayer.Name

	if not dailyQuestData[key] then
		dailyQuestData[key] = { count = 0, lastReset = os.time() }
	end

	-- 如果跨天则重置
	local now = os.time()
	if os.date("%d", now) ~= os.date("%d", dailyQuestData[key].lastReset) then
		dailyQuestData[key].count = 0
		dailyQuestData[key].lastReset = now
	end

	dailyQuestData[key].count = dailyQuestData[key].count + 1
	local bonusMultiplier = 1.0 + (dailyQuestData[key].count * 0.05)
	local finalExp = math.floor(baseExp * bonusMultiplier)

	oPlayer.Experience = oPlayer.Experience + finalExp
	Player.SetExp(oPlayer.Index, -1, finalExp, 0, false, 0)

	Message.Send(0, oPlayer.Index, 0,
		string.format("Daily Quest %d: +%d exp (x%.2f bonus!)",
			dailyQuestData[key].count, finalExp, bonusMultiplier))
end

-- VIP经验加成
function GiveVIPExperience(oPlayer, baseAmount)
	-- VIPType: -1 = 无VIP, 0+ = VIP等级
	local vipLevel = oPlayer.userData.VIPType
	local multiplier = 1.0

	if vipLevel >= 0 then
		multiplier = 1.0 + ((vipLevel + 1) * 0.1)
	end

	local finalAmount = math.floor(baseAmount * multiplier)

	oPlayer.Experience = oPlayer.Experience + finalAmount
	Player.SetExp(oPlayer.Index, -1, finalAmount, 0, false, 0)

	if vipLevel >= 0 then
		Message.Send(0, oPlayer.Index, 0,
			string.format("Gained %d exp (VIP %d: x%.1f)", finalAmount, vipLevel, multiplier))
	end
end

-- 公会经验共享
function ShareGuildExperience(guildName, totalExp)
	local memberCount = 0

	Object.ForEachGuildMember(guildName, function(oMember)
		memberCount = memberCount + 1
		return true
	end)

	if memberCount == 0 then
		return
	end

	local expPerMember = math.floor(totalExp / memberCount)

	Object.ForEachGuildMember(guildName, function(oMember)
		oMember.Experience = oMember.Experience + expPerMember
		Player.SetExp(oMember.Index, -1, expPerMember, 0, false, 0)

		Message.Send(0, oMember.Index, 0,
			string.format("Guild EXP Share: +%d (%d members)", expPerMember, memberCount))
		return true
	end)

	Log.Add(string.format("Guild %s shared %d exp among %d members",
		guildName, totalExp, memberCount))
end

-- 区域清空奖励
function GiveAreaClearBonus(mapNumber)
	local monsterCount = Object.CountMonstersOnMap(mapNumber)

	if monsterCount == 0 then
		local mapBonuses = {
			[0] = 10000,
			[1] = 25000,
			[2] = 15000,
			[7] = 100000
		}

		local bonus = mapBonuses[mapNumber] or 5000

		Object.ForEachPlayerOnMap(mapNumber, function(oPlayer)
			oPlayer.Experience = oPlayer.Experience + bonus
			Player.SetExp(oPlayer.Index, -1, bonus, 0, false, 0)

			Message.Send(0, oPlayer.Index, 1,
				string.format("区域已清空！奖励：+%d EXP", bonus))
			return true
		end)
	end
end

-- 连杀经验加成（Lua侧状态）
local comboKills = {}

function OnMonsterKilled(oPlayer, monsterIndex, baseExp)
	local key = oPlayer.Name

	if not comboKills[key] then
		comboKills[key] = { count = 0, lastKillTime = 0 }
	end

	local now = Timer.GetTick()

	if (now - comboKills[key].lastKillTime) > 5000 then
		comboKills[key].count = 0
	end

	comboKills[key].count = comboKills[key].count + 1
	comboKills[key].lastKillTime = now

	local comboBonus = math.min(comboKills[key].count * 0.1, 2.0)
	local finalExp = math.floor(baseExp * (1.0 + comboBonus))

	oPlayer.Experience = oPlayer.Experience + finalExp
	Player.SetExp(oPlayer.Index, monsterIndex, finalExp, 0, false, 0)

	if comboKills[key].count > 1 then
		Message.Send(0, oPlayer.Index, 0,
			string.format("Combo x%d! +%d exp (x%.1f)",
				comboKills[key].count, finalExp, 1.0 + comboBonus))
	end
end

--═══════════════════════════════════════════════════════════════
-- 经验系统示例结束
--═══════════════════════════════════════════════════════════════