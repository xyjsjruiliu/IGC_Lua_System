--═══════════════════════════════════════════════════════════════
--== INTERNATIONAL GAMING CENTER NETWORK
--== www.igcn.mu
--== (C) 2010-2026 IGC-Network (R)
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--== File is a part of IGCN Group MuOnline Server files.
--═══════════════════════════════════════════════════════════════

------------------------------------------------------------------
-- BattleRoyale.lua - 绝地求生（组队赛）系统
------------------------------------------------------------------
-- 玩家报名后传送至古战场，互相厮杀，最后存活的队伍获胜。
-- 最后5分钟地图中央刷新世界BOSS，时间结束未击杀则消失。
-- 胜利队伍获得祝福宝石奖励。
--
-- [使用方法]
--   /绝地 或 /jdqs     - 报名参加绝地求生
--   对话报名NPC         - 通过NPC报名参加
--
-- [架构说明]
-- 本系统通过 BattleRoyale 命名空间管理所有状态和逻辑，
-- 在 Callbacks.lua 的各回调函数中调用分派。
-- 事件调度由 EventScheduler 驱动。
------------------------------------------------------------------

------------------------------------------------------------------
-- 全局命名空间
------------------------------------------------------------------

BattleRoyale = BattleRoyale or {}

------------------------------------------------------------------
-- 配置常量
------------------------------------------------------------------

--- 古战场地图编号
BattleRoyale.MAP = 6

--- 游戏持续时间（秒）：10分钟
BattleRoyale.DURATION = 600

--- 报名阶段时长（秒）：3分钟（提前3分钟入场）
BattleRoyale.SIGNUP_TIME = 180

--- 最低报名等级
BattleRoyale.MIN_LEVEL = 400

--- 最大队伍人数
BattleRoyale.MAX_TEAM_SIZE = 3

--- 世界BOSS在游戏开始后多少秒刷新（5分钟 = 最后5分钟）
BattleRoyale.BOSS_SPAWN_DELAY = 300

--- 世界BOSS怪物Class ID（需要根据服务器实际配置修改）
BattleRoyale.BOSS_CLASS = 439

--- 世界BOSS刷新区域坐标（古战场中央区域）
BattleRoyale.BOSS_X1 = 100
BattleRoyale.BOSS_Y1 = 100
BattleRoyale.BOSS_X2 = 130
BattleRoyale.BOSS_Y2 = 130

--- 玩家出生点坐标（古战场）
BattleRoyale.SPAWN_X = 120
BattleRoyale.SPAWN_Y = 120

--- 死亡后传送回勇者大陆的坐标
BattleRoyale.DEATH_MAP = 0
BattleRoyale.DEATH_X = 130
BattleRoyale.DEATH_Y = 130

--- 奖励物品：祝福宝石 (Bless) - Type 14, Index 13
BattleRoyale.REWARD_ITEM_TYPE = 14
BattleRoyale.REWARD_ITEM_INDEX = 13

--- 报名NPC类型（需要根据服务器实际配置修改）
BattleRoyale.SIGNUP_NPC_CLASS = 0

--- 命令关键词
BattleRoyale.CMD_KEYWORDS = { "/绝地", "/jdqs" }

------------------------------------------------------------------
-- 状态机枚举
------------------------------------------------------------------

BattleRoyale.STATE = {
	IDLE       = 0,  -- 空闲，等待报名
	SIGNUP     = 1,  -- 报名中（19:27~19:30）
	PLAYING    = 2,  -- 游戏进行中（19:30~19:40）
	BOSS_PHASE = 3,  -- BOSS阶段（游戏开始后5分钟）
	REWARDING  = 4,  -- 发放奖励中
	FINISHED   = 5,  -- 游戏结束
}

------------------------------------------------------------------
-- 核心数据结构
------------------------------------------------------------------

--- 当前状态
BattleRoyale.state = BattleRoyale.STATE.IDLE

--- 队伍列表
--- 每个队伍: { id = number, members = { playerIndex1, ... }, alive = true }
BattleRoyale.teams = {}

--- 下一个队伍ID
BattleRoyale.nextTeamId = 1

--- 玩家数据
--- key = playerIndex, value = { teamId, alive, name, level }
BattleRoyale.players = {}

--- 游戏开始时间戳（Timer.GetTick() 毫秒）
BattleRoyale.startTime = 0

--- 世界BOSS的对象索引（-1 表示未生成）
BattleRoyale.bossIndex = -1

--- 世界BOSS是否已刷新
BattleRoyale.bossSpawned = false

--- 定时器名称常量
BattleRoyale.TIMER_GAME = "BR_GameTimer"
BattleRoyale.TIMER_BOSS = "BR_BossTimer"
BattleRoyale.TIMER_COUNTDOWN = "BR_Countdown"

------------------------------------------------------------------
-- 辅助函数
------------------------------------------------------------------

--- 获取祝福宝石的ItemId
---@return integer 物品ID
function BattleRoyale.GetRewardItemId()
	return Helpers.MakeItemId(BattleRoyale.REWARD_ITEM_TYPE, BattleRoyale.REWARD_ITEM_INDEX)
end

--- 广播消息给所有参赛玩家
---@param msg string 消息内容
---@param msgType integer 消息类型（默认1=全局公告）
function BattleRoyale.BroadcastToPlayers(msg, msgType)
	msgType = msgType or 1
	for playerIndex, data in pairs(BattleRoyale.players) do
		if data.alive then
			Message.Send(0, playerIndex, msgType, msg)
		end
	end
end

--- 全服广播消息
---@param msg string 消息内容
function BattleRoyale.BroadcastAll(msg)
	Message.Send(0, -1, 1, msg)
end

--- 计算存活队伍数量
---@return integer 存活队伍数
function BattleRoyale.GetAliveTeamCount()
	local count = 0
	for _, team in ipairs(BattleRoyale.teams) do
		if team.alive then
			count = count + 1
		end
	end
	return count
end

--- 获取存活队伍列表
---@return table 存活队伍数组
function BattleRoyale.GetAliveTeams()
	local alive = {}
	for _, team in ipairs(BattleRoyale.teams) do
		if team.alive then
			table.insert(alive, team)
		end
	end
	return alive
end

--- 检查玩家是否是参赛者
---@param playerIndex integer 玩家索引
---@return boolean
function BattleRoyale.IsPlayer(playerIndex)
	return BattleRoyale.players[playerIndex] ~= nil
end

--- 获取玩家所在的队伍
---@param playerIndex integer 玩家索引
---@return table|nil 队伍对象
function BattleRoyale.GetPlayerTeam(playerIndex)
	local data = BattleRoyale.players[playerIndex]
	if not data then return nil end

	for _, team in ipairs(BattleRoyale.teams) do
		if team.id == data.teamId then
			return team
		end
	end
	return nil
end

--- 检查队伍是否还有存活成员
---@param team table 队伍对象
---@return boolean
function BattleRoyale.IsTeamAlive(team)
	for _, memberIndex in ipairs(team.members) do
		local data = BattleRoyale.players[memberIndex]
		if data and data.alive then
			return true
		end
	end
	return false
end

--- 刷新所有队伍的存活状态
function BattleRoyale.RefreshTeamAliveStatus()
	for _, team in ipairs(BattleRoyale.teams) do
		team.alive = BattleRoyale.IsTeamAlive(team)
	end
end

------------------------------------------------------------------
-- 报名系统
------------------------------------------------------------------

--- 玩家报名参加绝地求生
---@param oPlayer Object 玩家对象
---@return boolean 是否报名成功
function BattleRoyale.SignUp(oPlayer)
	if not oPlayer then return false end

	-- 检查是否在报名阶段
	if BattleRoyale.state ~= BattleRoyale.STATE.SIGNUP then
		Message.Send(0, oPlayer.Index, 3, "【绝地求生】当前不在报名时间段内！")
		return false
	end

	-- 检查等级
	if oPlayer.Level < BattleRoyale.MIN_LEVEL then
		Message.Send(0, oPlayer.Index, 3,
			string.format("【绝地求生】需要 %d 级以上才能参加！", BattleRoyale.MIN_LEVEL))
		return false
	end

	-- 检查是否已报名
	if BattleRoyale.IsPlayer(oPlayer.Index) then
		Message.Send(0, oPlayer.Index, 3, "【绝地求生】你已经报名了！")
		return false
	end

	-- 检查队伍情况
	local partyNumber = oPlayer.PartyNumber or -1
	local playerIndex = oPlayer.Index

	if partyNumber >= 0 then
		-- 玩家在队伍中，整队报名
		-- 检查是否有人在队伍中且已报名
		local teamMembers = {}
		local alreadySigned = false
		local teamTooLarge = false

		Object.ForEachPlayer(function(oMember)
			if oMember and oMember.PartyNumber == partyNumber then
				if BattleRoyale.IsPlayer(oMember.Index) then
					alreadySigned = true
				end
				table.insert(teamMembers, oMember)
			end
			return true
		end)

		if #teamMembers > BattleRoyale.MAX_TEAM_SIZE then
			Message.Send(0, oPlayer.Index, 3,
				string.format("【绝地求生】队伍人数超过 %d 人上限！", BattleRoyale.MAX_TEAM_SIZE))
			return false
		end

		if alreadySigned then
			Message.Send(0, oPlayer.Index, 3, "【绝地求生】你的队伍中有人已经报名！")
			return false
		end

		-- 检查所有队员等级
		for _, member in ipairs(teamMembers) do
			if member.Level < BattleRoyale.MIN_LEVEL then
				Message.Send(0, oPlayer.Index, 3,
					string.format("【绝地求生】队员 %s 等级不足 %d 级！",
						member.Name, BattleRoyale.MIN_LEVEL))
				return false
			end
		end

		-- 创建队伍，所有队员加入
		local team = {
			id = BattleRoyale.nextTeamId,
			members = {},
			alive = true,
		}
		BattleRoyale.nextTeamId = BattleRoyale.nextTeamId + 1

		for _, member in ipairs(teamMembers) do
			table.insert(team.members, member.Index)
			BattleRoyale.players[member.Index] = {
				teamId = team.id,
				alive = true,
				name = member.Name,
				level = member.Level,
			}
		end

		table.insert(BattleRoyale.teams, team)

		-- 通知所有队员
		for _, member in ipairs(teamMembers) do
			Message.Send(0, member.Index, 1, "【绝地求生】报名成功！比赛即将开始，请准备！")
		end

		BattleRoyale.BroadcastAll(
			string.format("【绝地求生】%s 队伍已报名！当前已报名 %d 队",
				oPlayer.Name, #BattleRoyale.teams))
		return true
	else
		-- 玩家不在队伍中，单独报名
		-- 检查是否有可加入的未满队伍（可选：自动组队功能）
		-- 目前采用单独成队的方式
		local team = {
			id = BattleRoyale.nextTeamId,
			members = { playerIndex },
			alive = true,
		}
		BattleRoyale.nextTeamId = BattleRoyale.nextTeamId + 1

		BattleRoyale.players[playerIndex] = {
			teamId = team.id,
			alive = true,
			name = oPlayer.Name,
			level = oPlayer.Level,
		}

		table.insert(BattleRoyale.teams, team)

		Message.Send(0, oPlayer.Index, 1, "【绝地求生】报名成功！比赛即将开始，请准备！")
		BattleRoyale.BroadcastAll(
			string.format("【绝地求生】%s 已报名！当前已报名 %d 队",
				oPlayer.Name, #BattleRoyale.teams))
		return true
	end
end

--- 处理NPC对话报名
---@param oPlayer Object 玩家对象
---@param oNpc Object NPC对象
---@return integer 0=不阻止, 1=阻止
function BattleRoyale.HandleNpcTalk(oPlayer, oNpc)
	if not oPlayer or not oNpc then return 0 end

	-- 检查是否是报名NPC
	if oNpc.Class ~= BattleRoyale.SIGNUP_NPC_CLASS then
		return 0
	end

	BattleRoyale.SignUp(oPlayer)
	return 1
end

--- 处理命令报名
---@param oPlayer Object 玩家对象
---@return integer 1=阻止命令传播
function BattleRoyale.HandleCommand(oPlayer)
	if not oPlayer then return 0 end
	BattleRoyale.SignUp(oPlayer)
	return 1
end

------------------------------------------------------------------
-- 时间调度和阶段控制
------------------------------------------------------------------

--- 开始报名阶段（由 EventScheduler 触发）
function BattleRoyale.StartSignup()
	-- 重置所有状态
	BattleRoyale.Reset()

	-- 设置报名状态
	BattleRoyale.state = BattleRoyale.STATE.SIGNUP

	-- 广播报名开始
	BattleRoyale.BroadcastAll("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	BattleRoyale.BroadcastAll("【绝地求生】报名已开放！3分钟后开赛！")
	BattleRoyale.BroadcastAll(string.format("【绝地求生】报名要求：%d级以上，输入 /绝地 报名",
		BattleRoyale.MIN_LEVEL))
	BattleRoyale.BroadcastAll("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

	Log.Add("[绝地求生] 报名阶段开始")

	-- 启动3分钟倒计时定时器，到时开始游戏
	Timer.Create(BattleRoyale.SIGNUP_TIME * 1000, BattleRoyale.TIMER_COUNTDOWN, function()
		BattleRoyale.StartGame()
	end)
end

--- 开始游戏（传送所有报名玩家进入古战场）
function BattleRoyale.StartGame()
	-- 检查是否有足够玩家
	local totalPlayers = 0
	for _ in pairs(BattleRoyale.players) do
		totalPlayers = totalPlayers + 1
	end

	if totalPlayers < 1 then
		BattleRoyale.BroadcastAll("【绝地求生】报名人数不足，比赛取消！")
		BattleRoyale.Reset()
		return
	end

	-- 设置游戏状态
	BattleRoyale.state = BattleRoyale.STATE.PLAYING
	BattleRoyale.startTime = Timer.GetTick()

	-- 传送所有玩家到古战场
	for playerIndex, data in pairs(BattleRoyale.players) do
		if data.alive then
			Move.ToMap(playerIndex, BattleRoyale.MAP,
				BattleRoyale.SPAWN_X, BattleRoyale.SPAWN_Y)
		end
	end

	-- 广播游戏开始
	BattleRoyale.BroadcastAll("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	BattleRoyale.BroadcastAll("【绝地求生】比赛正式开始！存活到最后！")
	BattleRoyale.BroadcastAll(string.format("【绝地求生】参赛队伍：%d 队，共 %d 人",
		#BattleRoyale.teams, totalPlayers))
	BattleRoyale.BroadcastAll("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

	-- 给参赛玩家发送倒计时UI
	for playerIndex, data in pairs(BattleRoyale.players) do
		if data.alive then
			Utility.SendEventTimer(playerIndex, BattleRoyale.DURATION * 1000, 0, 2, 0)
		end
	end

	Log.Add(string.format("[绝地求生] 游戏开始，%d 队 %d 人参赛",
		#BattleRoyale.teams, totalPlayers))

	-- 启动游戏倒计时定时器
	Timer.Create(BattleRoyale.DURATION * 1000, BattleRoyale.TIMER_GAME, function()
		BattleRoyale.EndGame()
	end)

	-- 启动BOSS刷新定时器（5分钟后刷新BOSS）
	Timer.Create(BattleRoyale.BOSS_SPAWN_DELAY * 1000, BattleRoyale.TIMER_BOSS, function()
		BattleRoyale.SpawnBoss()
	end)
end

--- 刷新世界BOSS
function BattleRoyale.SpawnBoss()
	if BattleRoyale.state ~= BattleRoyale.STATE.PLAYING then
		return
	end

	BattleRoyale.state = BattleRoyale.STATE.BOSS_PHASE
	BattleRoyale.bossSpawned = true

	-- 在古战场中央生成世界BOSS
	BattleRoyale.bossIndex = EventMonsterTracker.SpawnAndRegister(
		Enums.EventType.BATTLE_ROYALE,
		BattleRoyale.BOSS_CLASS,
		BattleRoyale.MAP,
		BattleRoyale.BOSS_X1, BattleRoyale.BOSS_Y1,
		BattleRoyale.BOSS_X2, BattleRoyale.BOSS_Y2,
		0
	)

	BattleRoyale.BroadcastToPlayers("【绝地求生】⚠ 世界BOSS已出现在地图中央！击杀可获得额外奖励！")
	BattleRoyale.BroadcastAll("【绝地求生】⚠ 绝地求生世界BOSS已出现！")

	Log.Add("[绝地求生] 世界BOSS已刷新")
end

--- 结束游戏
function BattleRoyale.EndGame()
	-- 防止重复调用
	if BattleRoyale.state == BattleRoyale.STATE.IDLE then
		return
	end

	BattleRoyale.state = BattleRoyale.STATE.REWARDING

	-- 清理定时器
	Timer.RemoveByName(BattleRoyale.TIMER_GAME)
	Timer.RemoveByName(BattleRoyale.TIMER_BOSS)
	Timer.RemoveByName(BattleRoyale.TIMER_COUNTDOWN)

	-- 清理世界BOSS（如果未被击杀）
	if BattleRoyale.bossSpawned then
		EventMonsterTracker.CleanupMonsters(Enums.EventType.BATTLE_ROYALE)
		BattleRoyale.bossSpawned = false
		BattleRoyale.bossIndex = -1
	end

	-- 确定获胜队伍
	local aliveTeams = BattleRoyale.GetAliveTeams()

	if #aliveTeams == 1 then
		-- 只有一支队伍存活，宣布胜利
		local winnerTeam = aliveTeams[1]
		local memberNames = {}
		for _, memberIndex in ipairs(winnerTeam.members) do
			local data = BattleRoyale.players[memberIndex]
			if data then
				table.insert(memberNames, data.name)
			end
		end

		BattleRoyale.BroadcastAll("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
		BattleRoyale.BroadcastAll("【绝地求生】🏆 比赛结束！")
		BattleRoyale.BroadcastAll(string.format("【绝地求生】🏆 获胜队伍：%s",
			table.concat(memberNames, ", ")))
		BattleRoyale.BroadcastAll("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

		-- 给获胜队伍发放奖励
		for _, memberIndex in ipairs(winnerTeam.members) do
			local data = BattleRoyale.players[memberIndex]
			if data then
				local blessId = BattleRoyale.GetRewardItemId()
				ItemBag.Use(memberIndex, Enums.ItemBagType.INVENTORY, blessId, 1)
				Message.Send(0, memberIndex, 1, "【绝地求生】🏆 恭喜你获得祝福宝石奖励！")
			end
		end
	elseif #aliveTeams == 0 then
		-- 没有队伍存活（时间到且都死了）
		BattleRoyale.BroadcastAll("【绝地求生】比赛结束，没有队伍存活！")
	else
		-- 时间到，多支队伍存活
		BattleRoyale.BroadcastAll("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
		BattleRoyale.BroadcastAll("【绝地求生】比赛时间到！多支队伍存活，平局！")
		BattleRoyale.BroadcastAll("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	end

	-- 传送所有参赛玩家回勇者大陆
	for playerIndex, data in pairs(BattleRoyale.players) do
		Move.ToMap(playerIndex, BattleRoyale.DEATH_MAP,
			BattleRoyale.DEATH_X, BattleRoyale.DEATH_Y)
	end

	Log.Add("[绝地求生] 游戏结束，重置状态")

	-- 重置所有状态
	BattleRoyale.Reset()
end

--- 强制结束（由 EventScheduler 结束事件触发）
function BattleRoyale.ForceEnd()
	if BattleRoyale.state == BattleRoyale.STATE.IDLE then
		return
	end

	-- 清理定时器
	Timer.RemoveByName(BattleRoyale.TIMER_GAME)
	Timer.RemoveByName(BattleRoyale.TIMER_BOSS)
	Timer.RemoveByName(BattleRoyale.TIMER_COUNTDOWN)

	-- 清理BOSS
	if BattleRoyale.bossSpawned then
		EventMonsterTracker.CleanupMonsters(Enums.EventType.BATTLE_ROYALE)
	end

	BattleRoyale.BroadcastAll("【绝地求生】比赛被强制终止！")

	-- 传送所有玩家回勇者大陆
	for playerIndex, data in pairs(BattleRoyale.players) do
		Move.ToMap(playerIndex, BattleRoyale.DEATH_MAP,
			BattleRoyale.DEATH_X, BattleRoyale.DEATH_Y)
	end

	BattleRoyale.Reset()
end

------------------------------------------------------------------
-- 游戏事件处理
------------------------------------------------------------------

--- 玩家死亡处理
---@param oPlayer Object 死亡玩家对象
---@param oKiller Object 击杀者对象（可为nil）
function BattleRoyale.OnPlayerDie(oPlayer, oKiller)
	if not oPlayer then return end

	-- 检查玩家是否是参赛者且在游戏地图上
	if not BattleRoyale.IsPlayer(oPlayer.Index) then return end
	if oPlayer.MapNumber ~= BattleRoyale.MAP then return end
	if BattleRoyale.state ~= BattleRoyale.STATE.PLAYING
		and BattleRoyale.state ~= BattleRoyale.STATE.BOSS_PHASE then
		return
	end

	local data = BattleRoyale.players[oPlayer.Index]
	if not data or not data.alive then return end

	-- 标记玩家阵亡
	data.alive = false

	-- 广播阵亡消息
	local killerName = "环境"
	if oKiller and oKiller.Type == Enums.ObjectType.USER then
		killerName = oKiller.Name
	end

	BattleRoyale.BroadcastToPlayers(
		string.format("【绝地求生】☠ %s 被 %s 击杀！", data.name, killerName))

	-- 传送回勇者大陆
	Move.ToMap(oPlayer.Index, BattleRoyale.DEATH_MAP,
		BattleRoyale.DEATH_X, BattleRoyale.DEATH_Y)

	-- 刷新队伍存活状态
	BattleRoyale.RefreshTeamAliveStatus()

	-- 检查是否只剩一支队伍
	local aliveTeamCount = BattleRoyale.GetAliveTeamCount()
	if aliveTeamCount <= 1 then
		-- 延迟1秒结束，确保死亡消息已发送
		Timer.Create(1000, "BR_EndGame_Delay", function()
			BattleRoyale.EndGame()
		end)
	end
end

--- 怪物死亡处理（检查是否是绝地求生BOSS）
---@param oPlayer Object 击杀者玩家对象
---@param oMonster Object 怪物对象
function BattleRoyale.OnMonsterDie(oPlayer, oMonster)
	if not oPlayer or not oMonster then return end
	if not BattleRoyale.bossSpawned then return end
	if BattleRoyale.state ~= BattleRoyale.STATE.BOSS_PHASE then return end

	-- 检查是否是绝地求生事件注册的BOSS（使用 Index 和 Class 匹配）
	local isEventMonster = EventMonsterTracker.IsTracked(
		Enums.EventType.BATTLE_ROYALE, oMonster.Index)

	if isEventMonster then
		BattleRoyale.BroadcastAll("【绝地求生】🔥 世界BOSS已被击杀！")

		-- 给击杀者所在队伍额外奖励
		local data = BattleRoyale.players[oPlayer.Index]
		if data then
			local team = BattleRoyale.GetPlayerTeam(oPlayer.Index)
			if team then
				for _, memberIndex in ipairs(team.members) do
					local memberData = BattleRoyale.players[memberIndex]
					if memberData and memberData.alive then
						local blessId = BattleRoyale.GetRewardItemId()
						ItemBag.Use(memberIndex, Enums.ItemBagType.INVENTORY, blessId, 1)
						Message.Send(0, memberIndex, 1,
							"【绝地求生】🔥 你的队伍击杀了世界BOSS！获得额外祝福宝石！")
					end
				end
			end
		end

		BattleRoyale.bossSpawned = false
		BattleRoyale.bossIndex = -1

		Log.Add("[绝地求生] 世界BOSS被击杀")
	end
end

--- 玩家断线处理
---@param oPlayer Object 断线玩家对象
function BattleRoyale.OnPlayerDisconnect(oPlayer)
	if not oPlayer then return end
	if not BattleRoyale.IsPlayer(oPlayer.Index) then return end
	if BattleRoyale.state == BattleRoyale.STATE.IDLE then return end

	local data = BattleRoyale.players[oPlayer.Index]
	if not data then return end

	-- 标记玩家阵亡
	data.alive = false

	BattleRoyale.BroadcastToPlayers(
		string.format("【绝地求生】☠ %s 断线离开！", data.name))

	-- 刷新队伍存活状态
	BattleRoyale.RefreshTeamAliveStatus()

	-- 检查是否只剩一支队伍
	local aliveTeamCount = BattleRoyale.GetAliveTeamCount()
	if aliveTeamCount <= 1 then
		Timer.Create(1000, "BR_EndGame_Delay", function()
			BattleRoyale.EndGame()
		end)
	end
end

--- 检查PvP是否允许（在 onCheckUserTarget 中调用）
---@param oAttacker Object 攻击者
---@param oTarget Object 目标
---@return integer 0=不处理（走正常保护流程）, 1=允许攻击（绝地求生PvP，跳过保护）, 2=阻止攻击
function BattleRoyale.CheckPvP(oAttacker, oTarget)
	if not oAttacker or not oTarget then return 0 end

	-- 只在游戏进行中或BOSS阶段处理绝地求生PvP
	if BattleRoyale.state ~= BattleRoyale.STATE.PLAYING
		and BattleRoyale.state ~= BattleRoyale.STATE.BOSS_PHASE then
		return 0
	end

	-- 如果攻击者和目标都是参赛者，且目标在古战场，允许PvP（跳过所有保护）
	if BattleRoyale.IsPlayer(oAttacker.Index)
		and BattleRoyale.IsPlayer(oTarget.Index)
		and oTarget.MapNumber == BattleRoyale.MAP then
		return 1  -- 允许攻击（绝地求生PvP，跳过保护检查）
	end

	return 0  -- 非绝地求生相关，不处理，走正常保护流程
end

--- 玩家重生处理（在 onPlayerRespawn 中调用）
--- 阻止参赛玩家在古战场中重生
---@param oPlayer Object 重生玩家对象
---@return integer 0=不阻止, 1=阻止重生
function BattleRoyale.OnPlayerRespawn(oPlayer)
	if not oPlayer then return 0 end
	if BattleRoyale.state ~= BattleRoyale.STATE.PLAYING
		and BattleRoyale.state ~= BattleRoyale.STATE.BOSS_PHASE then
		return 0
	end

	-- 如果玩家是参赛者且在古战场，阻止重生（因为已在 OnPlayerDie 中传送回勇者大陆）
	if oPlayer.MapNumber == BattleRoyale.MAP and BattleRoyale.IsPlayer(oPlayer.Index) then
		-- 强制传送回勇者大陆
		Move.ToMap(oPlayer.Index, BattleRoyale.DEATH_MAP,
			BattleRoyale.DEATH_X, BattleRoyale.DEATH_Y)
		return 1
	end

	return 0
end

------------------------------------------------------------------
-- 重置和初始化
------------------------------------------------------------------

--- 重置所有状态
function BattleRoyale.Reset()
	BattleRoyale.state = BattleRoyale.STATE.IDLE
	BattleRoyale.teams = {}
	BattleRoyale.players = {}
	BattleRoyale.nextTeamId = 1
	BattleRoyale.startTime = 0
	BattleRoyale.bossIndex = -1
	BattleRoyale.bossSpawned = false

	-- 清理所有相关定时器
	Timer.RemoveByName(BattleRoyale.TIMER_GAME)
	Timer.RemoveByName(BattleRoyale.TIMER_BOSS)
	Timer.RemoveByName(BattleRoyale.TIMER_COUNTDOWN)
	Timer.RemoveByName("BR_EndGame_Delay")
end

--- 系统初始化
function BattleRoyale.Initialize()
	BattleRoyale.Reset()
	Log.Add("[绝地求生] 系统初始化完成")
	Log.Add("[绝地求生] 命令：/绝地 或 /jdqs 报名")
end