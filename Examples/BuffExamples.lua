--═══════════════════════════════════════════════════════════════
-- Buff 系统示例
--═══════════════════════════════════════════════════════════════
-- Buff.Add 函数签名：
--   Buff.Add(oPlayer, iBuffIndex, EffectType1, EffectValue1, EffectType2, EffectValue2,
--             iBuffDuration, BuffSendValue, nAttackerIndex)
-- Buff.AddItem 函数签名：
--   Buff.AddItem(oPlayer, iBuffIndex)
-- Buff.Remove 函数签名：
--   Buff.Remove(oPlayer, iBuffIndex)
-- Buff.CheckUsed 函数签名：
--   Buff.CheckUsed(oPlayer, iBuffIndex)
-- 所有 Buff 函数都接收 oPlayer 对象，而不是玩家索引。
--═══════════════════════════════════════════════════════════════

--═══════════════════════════════════════════════════════════════
-- Buff.AddItem - 物品增益（效果类型从物品配置中加载）
--═══════════════════════════════════════════════════════════════

function UseContractDamagePotion(iPlayerIndex)
	local oPlayer = Player.GetObjByIndex(iPlayerIndex)
	if not oPlayer then return end

	Buff.AddItem(oPlayer, Enums.BuffType.CONTRACT_DAMAGE_ITEM)

	Message.Send(0, iPlayerIndex, 0, "契约伤害药水已激活！")
	Log.Add(string.format("[增益] %s 激活了契约伤害增益", oPlayer.AccountId))
end

function ActivateCombatPotions(iPlayerIndex)
	local oPlayer = Player.GetObjByIndex(iPlayerIndex)
	if not oPlayer then return end

	Buff.AddItem(oPlayer, Enums.BuffType.CONTRACT_DAMAGE_ITEM)
	Buff.AddItem(oPlayer, Enums.BuffType.CONTRACT_ATTACKSPEED_PCS)
	Buff.AddItem(oPlayer, Enums.BuffType.CONTRACT_HP_ITEM)

	Message.Send(0, iPlayerIndex, 1, "战斗增益已激活！")
end

function GiveEventRewardBuff(iPlayerIndex, rewardType)
	local oPlayer = Player.GetObjByIndex(iPlayerIndex)
	if not oPlayer then return end

	if rewardType == "damage" then
		Buff.AddItem(oPlayer, Enums.BuffType.PCS_SCROLL_ANGER)
	elseif rewardType == "defense" then
		Buff.AddItem(oPlayer, Enums.BuffType.PCS_SCROLL_DEFENSE)
	elseif rewardType == "speed" then
		Buff.AddItem(oPlayer, Enums.BuffType.PCS_SCROLL_HASTE)
	end
end

--═══════════════════════════════════════════════════════════════
-- Buff.Add - 完全手动控制
--═══════════════════════════════════════════════════════════════

function ApplyFireDebuff(iTargetIndex, iCasterIndex, iDamagePerTick, iDuration)
	local oTarget = Player.GetObjByIndex(iTargetIndex)
	if not oTarget then return end

	Buff.Add(oTarget, Enums.BuffType.FIREATTACK, Enums.EffectType.GIVE_DMG_TICK,
		iDamagePerTick, 0, 0, iDuration, 0, iCasterIndex)

	Message.Send(0, iTargetIndex, 0, "你燃烧起来了！")
end

function ApplyFrostDebuff(iTargetIndex, iCasterIndex)
	local oTarget = Player.GetObjByIndex(iTargetIndex)
	if not oTarget then return end

	Buff.Add(oTarget, Enums.BuffType.ICEATTACK, Enums.EffectType.ICE_DMG_TICK,
		50, 0, 0, 10, 0, iCasterIndex)
end

function ApplyPoisonArrow(iTargetIndex, iCasterIndex, iDotDamage, iDebuffTime)
	local oTarget = Player.GetObjByIndex(iTargetIndex)
	if not oTarget then return end

	Buff.Add(oTarget, Enums.BuffType.POISONARROW, Enums.EffectType.POISON_DMG_TICK,
		iDotDamage, 0, 0, iDebuffTime, 0, iCasterIndex)
end

function ApplyBlessBuffManual(iPlayerIndex, iDamageBonus, iDuration)
	local oPlayer = Player.GetObjByIndex(iPlayerIndex)
	if not oPlayer then return end

	Buff.Add(oPlayer, Enums.BuffType.BLESS, Enums.EffectType.IMPROVE_DAMAGE,
		iDamageBonus, 0, 0, iDuration, 0, 0)

	Message.Send(0, iPlayerIndex, 1,
		string.format("祝福：+%d 伤害，持续 %d 秒", iDamageBonus, iDuration))
end

function ApplyDefenseBuff(iPlayerIndex, iDefenseBonus, iDuration)
	local oPlayer = Player.GetObjByIndex(iPlayerIndex)
	if not oPlayer then return end

	Buff.Add(oPlayer, Enums.BuffType.DEFENSE_POWER_INC, Enums.EffectType.IMPROVE_DEFENSE,
		iDefenseBonus, 0, 0, iDuration, 0, 0)
end

function ApplyHasteBuff(iPlayerIndex, iSpeedBonus, iDuration)
	local oPlayer = Player.GetObjByIndex(iPlayerIndex)
	if not oPlayer then return end

	Buff.Add(oPlayer, Enums.BuffType.HASTE, Enums.EffectType.HASTE_INCREASE_ATTACKSPEED,
		iSpeedBonus, 0, 0, iDuration, 0, 0)
end

function ApplyExpBoostBuff(iPlayerIndex, iExpPercent, iDuration)
	local oPlayer = Player.GetObjByIndex(iPlayerIndex)
	if not oPlayer then return end

	Buff.Add(oPlayer, Enums.BuffType.EXPUP_CHARM1, Enums.EffectType.EXPERIENCE,
		iExpPercent, 0, 0, iDuration, 0, 0)

	Message.Send(0, iPlayerIndex, 1,
		string.format("+%d%% 经验值，持续 %d 秒！", iExpPercent, iDuration))
end

function ApplyStun(iTargetIndex, iCasterIndex, iStunDuration)
	local oTarget = Player.GetObjByIndex(iTargetIndex)
	if not oTarget then return end

	Buff.Add(oTarget, Enums.BuffType.STUN, Enums.EffectType.NONE,
		0, 0, 0, iStunDuration, 0, iCasterIndex)

	Message.Send(0, iTargetIndex, 0, "眩晕！")
end

function ApplyParalyze(iTargetIndex, iCasterIndex, iDuration)
	local oTarget = Player.GetObjByIndex(iTargetIndex)
	if not oTarget then return end

	Buff.Add(oTarget, Enums.BuffType.PARALYZE, Enums.EffectType.NONE,
		0, 0, 0, iDuration, 0, iCasterIndex)
end

function ApplyBlind(iTargetIndex, iCasterIndex, iDuration)
	local oTarget = Player.GetObjByIndex(iTargetIndex)
	if not oTarget then return end

	Buff.Add(oTarget, Enums.BuffType.BLIND, Enums.EffectType.BLIND,
		0, 0, 0, iDuration, 0, iCasterIndex)
end

function ApplyDefenseReduction(iTargetIndex, iCasterIndex, iDefenseReduction, iDuration)
	local oTarget = Player.GetObjByIndex(iTargetIndex)
	if not oTarget then return end

	Buff.Add(oTarget, Enums.BuffType.DEFENSE_POWER_DEC, Enums.EffectType.DECREASE_DEFENSE,
		iDefenseReduction, 0, 0, iDuration, 0, iCasterIndex)
end

function ApplyDamageReflect(iPlayerIndex, iReflectPercent, iDuration)
	local oPlayer = Player.GetObjByIndex(iPlayerIndex)
	if not oPlayer then return end

	Buff.Add(oPlayer, Enums.BuffType.DAMAGE_REFLECT, Enums.EffectType.DAMAGEREFLECT,
		iReflectPercent, 0, 0, iDuration, 0, 0)

	Message.Send(0, iPlayerIndex, 1,
		string.format("反射 %d%% 伤害！", iReflectPercent))
end

--═══════════════════════════════════════════════════════════════
-- Buff.Remove 和 Buff.CheckUsed
--═══════════════════════════════════════════════════════════════

function RefreshPlayerBuff(iPlayerIndex, buffType, duration)
	local oPlayer = Player.GetObjByIndex(iPlayerIndex)
	if not oPlayer then return end

	Buff.Remove(oPlayer, buffType)

	if buffType == Enums.BuffType.ATTACK_POWER_INC then
		Buff.Add(oPlayer, buffType, Enums.EffectType.IMPROVE_DAMAGE,
			100, 0, 0, duration, 0, 0)
	elseif buffType == Enums.BuffType.DEFENSE_POWER_INC then
		Buff.Add(oPlayer, buffType, Enums.EffectType.IMPROVE_DEFENSE,
			80, 0, 0, duration, 0, 0)
	end

	Message.Send(0, iPlayerIndex, 1, "增益已刷新！")
end

function HasCombatBuff(iPlayerIndex)
	local oPlayer = Player.GetObjByIndex(iPlayerIndex)
	if not oPlayer then return false end

	return Buff.CheckUsed(oPlayer, Enums.BuffType.ATTACK_POWER_INC)
end

--═══════════════════════════════════════════════════════════════
-- 带过期通知的定时增益
-- Timer.Create 是单次定时器；使用 aliveTime 参数自动清理
--═══════════════════════════════════════════════════════════════

function ApplyTimedBuff(iPlayerIndex, buffType, duration)
	local oPlayer = Player.GetObjByIndex(iPlayerIndex)
	if not oPlayer then return end

	if buffType == "combat" then
		Buff.Add(oPlayer, Enums.BuffType.ATTACK_POWER_INC, Enums.EffectType.IMPROVE_DAMAGE,
			150, 0, 0, duration, 0, 0)
		Message.Send(0, iPlayerIndex, 1,
			string.format("战斗增益已激活，持续 %d 秒！", duration))

	elseif buffType == "defense" then
		Buff.Add(oPlayer, Enums.BuffType.DEFENSE_POWER_INC, Enums.EffectType.IMPROVE_DEFENSE,
			100, 0, 0, duration, 0, 0)
		Message.Send(0, iPlayerIndex, 1,
			string.format("防御增益已激活，持续 %d 秒！", duration))
	end

	-- 增益过期时通知
	Timer.Create(duration * 1000, "buff_expire_" .. iPlayerIndex, function()
		local oP = Player.GetObjByIndex(iPlayerIndex)
		if oP then
			Message.Send(0, iPlayerIndex, 0, "你的增益已过期！")
		end
	end)
end

--═══════════════════════════════════════════════════════════════
-- 基于等级的增益
--═══════════════════════════════════════════════════════════════

function ApplyLevelBasedBuff(iPlayerIndex)
	local oPlayer = Player.GetObjByIndex(iPlayerIndex)
	if not oPlayer then return end

	if oPlayer.Level < 100 then
		Buff.Add(oPlayer, Enums.BuffType.BEGINNER_ATTACK_POWER_INC, Enums.EffectType.IMPROVE_DAMAGE,
			50, 0, 0, 3600, 0, 0)
		Message.Send(0, iPlayerIndex, 1, "新手奖励：+50 攻击力，持续1小时！")

	elseif oPlayer.Level < 400 then
		Buff.Add(oPlayer, Enums.BuffType.EXPUP_CHARM1, Enums.EffectType.EXPERIENCE,
			30, 0, 0, 3600, 0, 0)
		Message.Send(0, iPlayerIndex, 1, "修炼奖励：+30% 经验值，持续1小时！")

	else
		Buff.Add(oPlayer, Enums.BuffType.ATTACK_POWER_INC, Enums.EffectType.IMPROVE_DAMAGE,
			200, 0, 0, 1800, 0, 0)
		Buff.Add(oPlayer, Enums.BuffType.DEFENSE_POWER_INC, Enums.EffectType.IMPROVE_DEFENSE,
			150, 0, 0, 1800, 0, 0)
		Message.Send(0, iPlayerIndex, 1, "大师奖励：+200 攻击力，+150 防御力，持续30分钟！")
	end
end

--═══════════════════════════════════════════════════════════════
-- 队伍增益（使用 Object.ForEachPartyMember）
--═══════════════════════════════════════════════════════════════

function ApplyPartyBuff(iPlayerIndex, buffType, duration)
	local oPlayer = Player.GetObjByIndex(iPlayerIndex)
	if not oPlayer then return end

	if oPlayer.PartyNumber < 0 then
		Message.Send(0, iPlayerIndex, 0, "你不在队伍中！")
		return
	end

	local buffedCount = 0

	Object.ForEachPartyMember(oPlayer.PartyNumber, function(oMember)
		if buffType == "combat" then
			Buff.Add(oMember, Enums.BuffType.ATTACK_POWER_INC, Enums.EffectType.IMPROVE_DAMAGE,
				100, 0, 0, duration, 0, 0)
		elseif buffType == "defense" then
			Buff.Add(oMember, Enums.BuffType.DEFENSE_POWER_INC, Enums.EffectType.IMPROVE_DEFENSE,
				80, 0, 0, duration, 0, 0)
		elseif buffType == "exp" then
			Buff.Add(oMember, Enums.BuffType.PARTY_EXP_INCREASE_SCROLL, Enums.EffectType.EXPERIENCE,
				50, 0, 0, duration, 0, 0)
		end

		buffedCount = buffedCount + 1
		return true
	end)

	Message.Send(0, iPlayerIndex, 1,
		string.format("已向 %d 名队伍成员施加 %s 增益！", buffedCount, buffType))
end

--═══════════════════════════════════════════════════════════════
-- 范围增益（使用 ForEachPlayerOnMap 并检查距离）
--═══════════════════════════════════════════════════════════════

function ApplyAreaBuff(iPlayerIndex, range, buffDuration)
	local oPlayer = Player.GetObjByIndex(iPlayerIndex)
	if not oPlayer then return end

	local buffedCount = 0

	Object.ForEachPlayerOnMap(oPlayer.MapNumber, function(oTarget)
		local dx = oTarget.X - oPlayer.X
		local dy = oTarget.Y - oPlayer.Y

		if math.sqrt(dx * dx + dy * dy) <= range then
			Buff.Add(oTarget, Enums.BuffType.ATTACK_POWER_INC, Enums.EffectType.IMPROVE_DAMAGE,
				80, 0, 0, buffDuration, 0, 0)
			Buff.Add(oTarget, Enums.BuffType.DEFENSE_POWER_INC, Enums.EffectType.IMPROVE_DEFENSE,
				60, 0, 0, buffDuration, 0, 0)

			Message.Send(0, oTarget.Index, 1, "获得范围增益！")
			buffedCount = buffedCount + 1
		end

		return true
	end)

	Log.Add(string.format("[范围增益] %s 在 %d 范围内增益了 %d 名玩家",
		oPlayer.AccountId, range, buffedCount))
end

--═══════════════════════════════════════════════════════════════
-- PvP 减益效果
--═══════════════════════════════════════════════════════════════

function ApplyPvPDebuff(iAttackerIndex, iTargetIndex, debuffType)
	local oAttacker = Player.GetObjByIndex(iAttackerIndex)
	local oTarget = Player.GetObjByIndex(iTargetIndex)

	if not oAttacker or not oTarget then return end

	if debuffType == "slow" then
		Buff.Add(oTarget, Enums.BuffType.REDUCE_ATTACK_SPEED, Enums.EffectType.REDUCE_ATTACK_SPEED,
			40, 0, 0, 8, 0, iAttackerIndex)
		Message.Send(0, iTargetIndex, 0, "你的攻击速度已降低！")

	elseif debuffType == "weakness" then
		Buff.Add(oTarget, Enums.BuffType.ATTACK_POWER_DEC, Enums.EffectType.DECREASE_ATTACKPOWER,
			50, 0, 0, 10, 0, iAttackerIndex)
		Message.Send(0, iTargetIndex, 0, "你的攻击力已削弱！")

	elseif debuffType == "poison" then
		Buff.Add(oTarget, Enums.BuffType.POISON, Enums.EffectType.POISON_DMG_TICK,
			30, 0, 0, 12, 0, iAttackerIndex)
		Message.Send(0, iTargetIndex, 0, "你中毒了！")
	end
end

--═══════════════════════════════════════════════════════════════
-- 增益示例结束
--═══════════════════════════════════════════════════════════════