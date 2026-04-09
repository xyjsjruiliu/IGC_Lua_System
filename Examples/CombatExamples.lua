--═══════════════════════════════════════════════════════════════
-- 战斗系统示例
--═══════════════════════════════════════════════════════════════

------------------------------------------------------------------
-- 范围伤害 - ForEachNearby
------------------------------------------------------------------

-- 范围爆炸：对中心物体周围范围内所有怪物造成伤害
function AOE_DamageMonsters(centerIndex, range, damage)
	local hit = 0

	Object.ForEachNearby(centerIndex, range, function(oTarget, distance)
		if oTarget.Type == Enums.ObjectType.MONSTER then
			oTarget.Life = math.max(oTarget.Life - damage, 0)
			hit = hit + 1
		end
		return true
	end)

	return hit
end

-- 带衰减的范围伤害（最远距离伤害减少50%）
function AOE_DamageFalloff(centerIndex, range, baseDamage)
	local hit = 0

	Object.ForEachNearby(centerIndex, range, function(oTarget, distance)
		if oTarget.Type == Enums.ObjectType.MONSTER then
			local falloff = 1.0 - ((distance / range) * 0.5)
			local finalDamage = math.floor(baseDamage * falloff)
			oTarget.Life = math.max(oTarget.Life - finalDamage, 0)
			hit = hit + 1
		end
		return true
	end)

	return hit
end

-- 范围PVP伤害（仅玩家，最低保留1点生命）
function AOE_DamagePlayers(centerIndex, range, damage)
	local hit = 0

	Object.ForEachNearby(centerIndex, range, function(oTarget, distance)
		if oTarget.Type == Enums.ObjectType.USER then
			oTarget.Life = math.max(oTarget.Life - damage, 1)
			Player.SendLife(oTarget.Index, oTarget.Life, Enums.HPManaUpdateFlag.CURRENT_HP_MANA, oTarget.Shield)
			hit = hit + 1
		end
		return true
	end)

	return hit
end

------------------------------------------------------------------
-- 范围治疗
------------------------------------------------------------------

function AOE_HealPlayers(centerIndex, range, healAmount)
	local healed = 0

	Object.ForEachNearby(centerIndex, range, function(oTarget, distance)
		if oTarget.Type == Enums.ObjectType.USER then
			oTarget.Life = math.min(oTarget.Life + healAmount, oTarget.MaxLife)
			Player.SendLife(oTarget.Index, oTarget.Life, Enums.HPManaUpdateFlag.CURRENT_HP_MANA, oTarget.Shield)
			Message.Send(0, oTarget.Index, 0, string.format("+%d 生命值", healAmount))
			healed = healed + 1
		end
		return true
	end)

	return healed
end

------------------------------------------------------------------
-- 范围增益 - ForEachNearby
------------------------------------------------------------------

function AOE_BuffNearbyPlayers(centerIndex, range, buffIndex, duration)
	local buffed = 0

	Object.ForEachNearby(centerIndex, range, function(oTarget, distance)
		if oTarget.Type == Enums.ObjectType.USER then
			Buff.Add(oTarget, buffIndex, 0, 100, 0, 0, duration, 0, centerIndex)
			buffed = buffed + 1
		end
		return true
	end)

	return buffed
end

-- 全队增益
function Skill_PartyBuff(casterIndex, buffIndex, duration)
	local oCaster = Player.GetObjByIndex(casterIndex)
	if not oCaster or oCaster.PartyNumber < 0 then
		return 0
	end

	local buffed = 0

	Object.ForEachPartyMember(oCaster.PartyNumber, function(oMember)
		Buff.Add(oMember, buffIndex, 0, 100, 0, 0, duration, 0, casterIndex)
		Message.Send(0, oMember.Index, 0, "队伍增益已施加！")
		buffed = buffed + 1
		return true
	end)

	return buffed
end

------------------------------------------------------------------
-- 生命偷取
------------------------------------------------------------------

function Skill_Lifesteal(casterIndex, range, damagePercent, healPercent)
	local oCaster = Player.GetObjByIndex(casterIndex)
	if not oCaster then return 0 end

	local totalHealed = 0

	Object.ForEachNearby(casterIndex, range, function(oTarget, distance)
		if oTarget.Type == Enums.ObjectType.MONSTER then
			local damage = math.floor(oTarget.MaxLife * (damagePercent / 100))
			oTarget.Life = math.max(oTarget.Life - damage, 0)

			local heal = math.floor(damage * (healPercent / 100))
			oCaster.Life = math.min(oCaster.Life + heal, oCaster.MaxLife)
			Player.SendLife(oCaster.Index, oCaster.Life, Enums.HPManaUpdateFlag.CURRENT_HP_MANA, oCaster.Shield)
			totalHealed = totalHealed + heal
		end
		return true
	end)

	if totalHealed > 0 then
		Message.Send(0, casterIndex, 0, string.format("+%d 生命吸取", totalHealed))
	end

	return totalHealed
end

------------------------------------------------------------------
-- 横扫/顺劈 - 范围内怪物
------------------------------------------------------------------

-- 360度横扫
function Skill_Sweep(casterIndex, range, damage)
	local hit = 0

	Object.ForEachNearby(casterIndex, range, function(oTarget, distance)
		if oTarget.Type == Enums.ObjectType.MONSTER then
			local distMod = 1.0 - (distance / range * 0.5)
			oTarget.Life = math.max(oTarget.Life - math.floor(damage * distMod), 0)
			hit = hit + 1
		end
		return true
	end)

	return hit
end

------------------------------------------------------------------
-- 环境伤害 / 安全区域治疗
------------------------------------------------------------------

-- 对站在危险区域内的玩家造成伤害
function Environmental_ZoneDamage(mapNumber, x1, y1, x2, y2, damage)
	local damaged = 0

	Object.ForEachPlayerOnMap(mapNumber, function(oPlayer)
		if oPlayer.X >= x1 and oPlayer.X <= x2
		   and oPlayer.Y >= y1 and oPlayer.Y <= y2 then
			oPlayer.Life = math.max(oPlayer.Life - damage, 1)
			Player.SendLife(oPlayer.Index, oPlayer.Life, Enums.HPManaUpdateFlag.CURRENT_HP_MANA, oPlayer.Shield)
			Message.Send(0, oPlayer.Index, 0, "区域伤害！")
			damaged = damaged + 1
		end
		return true
	end)

	return damaged
end

-- 治疗站在安全区域内的玩家
function Environmental_SafeZoneHeal(mapNumber, x1, y1, x2, y2, healAmount)
	local healed = 0

	Object.ForEachPlayerOnMap(mapNumber, function(oPlayer)
		if oPlayer.X >= x1 and oPlayer.X <= x2
		   and oPlayer.Y >= y1 and oPlayer.Y <= y2 then
			oPlayer.Life = math.min(oPlayer.Life + healAmount, oPlayer.MaxLife)
			oPlayer.Mana = math.min(oPlayer.Mana + healAmount, oPlayer.MaxMana)
			Player.SendLife(oPlayer.Index, oPlayer.Life, Enums.HPManaUpdateFlag.CURRENT_HP_MANA, oPlayer.Shield)
			Player.SendMana(oPlayer.Index, oPlayer.Mana, Enums.HPManaUpdateFlag.CURRENT_HP_MANA, oPlayer.BP)
			healed = healed + 1
		end
		return true
	end)

	return healed
end

------------------------------------------------------------------
-- 战斗最高伤害
------------------------------------------------------------------

-- 获取对怪物造成最高伤害的玩家（服务器内置）
function GetBossTopDamage(monsterIndex)
	return Combat.GetTopDamageDealer(monsterIndex)
end

------------------------------------------------------------------
-- 基于最高伤害的BOSS击杀奖励
------------------------------------------------------------------

function BossKillReward(monsterIndex, eventMap, totalReward)
	local topDealerIndex = Combat.GetTopDamageDealer(monsterIndex)

	-- 地图上所有玩家获得固定奖励
	local baseReward = math.floor(totalReward * 0.5)
	local playerCount = Object.CountPlayersOnMap(eventMap)

	if playerCount > 0 then
		local share = math.floor(baseReward / playerCount)

		Object.ForEachPlayerOnMap(eventMap, function(oPlayer)
			Player.SetMoney(oPlayer.Index, share, false)
			Message.Send(0, oPlayer.Index, 1,
				string.format("BOSS奖励：%d 金币！", share))
			return true
		end)
	end

	-- 最高伤害者额外奖励
	local oTop = Player.GetObjByIndex(topDealerIndex)
	if oTop then
		local bonus = math.floor(totalReward * 0.5)
		Player.SetMoney(topDealerIndex, bonus, false)
		Message.Send(0, topDealerIndex, 1,
			string.format("最高伤害奖励：%d 金币！", bonus))

		Log.Add(string.format("[战斗] 最高伤害玩家：%s（奖励：%d 金币）",
			oTop.Name, bonus))
	end
end

--═══════════════════════════════════════════════════════════════
-- 战斗示例结束
--═══════════════════════════════════════════════════════════════