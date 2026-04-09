--═══════════════════════════════════════════════════════════════
-- 实用函数 - 完整示例
--═══════════════════════════════════════════════════════════════
-- 注意：Object.CountPlayersOnMap 和 Object.CountMonstersOnMap
-- 都需要一个地图编号参数 - 没有全局计数函数。
--═══════════════════════════════════════════════════════════════

------------------------------------------------------------------
-- CountPlayersOnMap - 简单用法
------------------------------------------------------------------

function CheckMapPopulation()
	local mapNames = {
		[0] = "勇者大陆", [1] = "地下城", [2] = "冰风谷",
		[3] = "仙踪林", [4] = "失落之塔", [5] = "流放地",
		[6] = "古战场", [7] = "亚特兰蒂斯", [8] = "死亡沙漠", [10] = "天空之城"
	}

	Log.Add("=== 地图人口 ===")

	for mapNum, name in pairs(mapNames) do
		local count = Object.CountPlayersOnMap(mapNum)
		if count > 0 then
			Log.Add(string.format("%s (地图 %d): %d 名玩家", name, mapNum, count))
		end
	end
end

function MonitorCrowdedMaps(threshold)
	for mapNum = 0, 255 do
		local count = Object.CountPlayersOnMap(mapNum)
		if count > threshold then
			Log.Add(string.format("警告: 地图 %d 有 %d 名玩家 (阈值: %d)",
				mapNum, count, threshold))
		end
	end
end

function IsMapBalanced(map1, map2, maxDifference)
	local count1 = Object.CountPlayersOnMap(map1)
	local count2 = Object.CountPlayersOnMap(map2)
	local diff = math.abs(count1 - count2)
	return diff <= maxDifference, diff
end

------------------------------------------------------------------
-- CountPlayersOnMap - 带筛选条件
------------------------------------------------------------------

function CountElitePlayersPerMap()
	local results = {}

	for mapNum = 0, 10 do
		local count = Object.CountPlayersOnMap(mapNum, function(oPlayer)
			return oPlayer.Level >= 400
		end)

		if count > 0 then
			results[mapNum] = count
			Log.Add(string.format("地图 %d: %d 名精英玩家 (400级以上)", mapNum, count))
		end
	end

	return results
end

function CountVIPPlayersOnMap(mapNumber, minVIPType)
	return Object.CountPlayersOnMap(mapNumber, function(oPlayer)
		return oPlayer.userData.VIPType >= (minVIPType or 0)
	end)
end

function CountRichPlayersOnMap(mapNumber, minZen)
	return Object.CountPlayersOnMap(mapNumber, function(oPlayer)
		return oPlayer.userData.Money >= minZen
	end)
end

function CountVeteranPlayersOnMap(mapNumber, minResets)
	return Object.CountPlayersOnMap(mapNumber, function(oPlayer)
		return oPlayer.userData.Resets >= minResets
	end)
end

function CountSoloPlayersOnMap(mapNumber)
	return Object.CountPlayersOnMap(mapNumber, function(oPlayer)
		return oPlayer.PartyNumber < 0
	end)
end

function CountPlayersInArea(mapNumber, x1, y1, x2, y2)
	return Object.CountPlayersOnMap(mapNumber, function(oPlayer)
		return oPlayer.X >= x1 and oPlayer.X <= x2
			and oPlayer.Y >= y1 and oPlayer.Y <= y2
	end)
end

------------------------------------------------------------------
-- CountMonstersOnMap
------------------------------------------------------------------

function CheckMapRespawn(mapNumber, minMonsters)
	local count = Object.CountMonstersOnMap(mapNumber)

	if count < minMonsters then
		Log.Add(string.format("地图 %d 需要刷新: %d/%d 只怪物",
			mapNumber, count, minMonsters))
		return true
	end

	return false
end

function IsMapClear(mapNumber)
	return Object.CountMonstersOnMap(mapNumber) == 0
end

function CountBossesOnMap(mapNumber)
	return Object.CountMonstersOnMap(mapNumber, function(oMonster)
		return oMonster.Class >= 200 and oMonster.Class <= 250
	end)
end

function CountMonsterTypeOnMap(mapNumber, monsterClass)
	return Object.CountMonstersOnMap(mapNumber, function(oMonster)
		return oMonster.Class == monsterClass
	end)
end

function CountWoundedMonstersOnMap(mapNumber, hpThreshold)
	return Object.CountMonstersOnMap(mapNumber, function(oMonster)
		return (oMonster.Life / oMonster.MaxLife) < (hpThreshold / 100)
	end)
end

function CountMonstersInArea(mapNumber, x1, y1, x2, y2)
	return Object.CountMonstersOnMap(mapNumber, function(oMonster)
		return oMonster.X >= x1 and oMonster.X <= x2
			and oMonster.Y >= y1 and oMonster.Y <= y2
	end)
end

------------------------------------------------------------------
-- GetObjByName
------------------------------------------------------------------

function TeleportPlayerByName(playerName, targetMap, x, y)
	local oPlayer = Player.GetObjByName(playerName)

	if oPlayer then
		Move.ToMap(oPlayer.Index, targetMap, x, y)
		Message.Send(0, oPlayer.Index, 0, "你已被传送!")
		Log.Add(string.format("已将 %s 传送到地图 %d", playerName, targetMap))
		return true
	else
		Log.Add(string.format("玩家 %s 未找到或离线", playerName))
		return false
	end
end

function IsPlayerOnline(playerName)
	return Player.GetObjByName(playerName) ~= nil
end

function SendPrivateMessage(playerName, message)
	local oPlayer = Player.GetObjByName(playerName)

	if oPlayer then
		Message.Send(0, oPlayer.Index, 0, message)
		return true
	end

	return false
end

function GetPlayerInfo(playerName)
	local oPlayer = Player.GetObjByName(playerName)

	if not oPlayer then return nil end

	return {
		Name = oPlayer.Name,
		AccountId = oPlayer.AccountId,
		Index = oPlayer.Index,
		Level = oPlayer.Level,
		Class = oPlayer.Class,
		Map = oPlayer.MapNumber,
		X = oPlayer.X,
		Y = oPlayer.Y,
		Money = oPlayer.userData.Money,
		Resets = oPlayer.userData.Resets,
		VIPType = oPlayer.userData.VIPType
	}
end

function AwardPlayerByName(playerName, zenAmount, itemId, itemLevel)
	local oPlayer = Player.GetObjByName(playerName)

	if not oPlayer then
		Log.Add(string.format("无法奖励 %s - 玩家离线", playerName))
		return false
	end

	Player.SetMoney(oPlayer.Index, zenAmount, false)

	if itemId then
		local stItem = CreateItemInfo()
		stItem.ItemId = itemId
		stItem.ItemLevel = itemLevel or 0
		stItem.LootIndex = oPlayer.Index
		stItem.TargetInvenPos = 255
		Item.Create(oPlayer.Index, stItem)
	end

	Message.Send(0, oPlayer.Index, 1,
		string.format("你获得了 %d 金币!", zenAmount))

	Log.Add(string.format("已奖励 %s: %d 金币", playerName, zenAmount))
	return true
end

------------------------------------------------------------------
-- Combined Checks
------------------------------------------------------------------

function CheckEventEligibility(mapNumber, minPlayers, minLevel, maxMonsters)
	local monsterCount = Object.CountMonstersOnMap(mapNumber)

	if monsterCount > maxMonsters then
		return false, string.format("怪物过多: %d (最大: %d)",
			monsterCount, maxMonsters)
	end

	local eligible = Object.CountPlayersOnMap(mapNumber, function(oPlayer)
		return oPlayer.Level >= minLevel
	end)

	if eligible < minPlayers then
		return false, string.format("符合条件的玩家不足: %d (需要 %d 名 %d+ 级以上的玩家)",
			eligible, minPlayers, minLevel)
	end

	return true, "活动可以开始了!"
end

function CheckPvPBalance(mapNumber, guild1, guild2, maxDifference)
	local count1 = Object.CountPlayersOnMap(mapNumber, function(oPlayer)
		return oPlayer.GuildName == guild1
	end)

	local count2 = Object.CountPlayersOnMap(mapNumber, function(oPlayer)
		return oPlayer.GuildName == guild2
	end)

	local diff = math.abs(count1 - count2)

	if diff > maxDifference then
		return false, string.format("不平衡: %s=%d, %s=%d (差值: %d)",
			guild1, count1, guild2, count2, diff)
	end

	return true, string.format("平衡: %s=%d, %s=%d",
		guild1, count1, guild2, count2)
end

function CalculateDynamicDifficulty(mapNumber)
	local totalPlayers = Object.CountPlayersOnMap(mapNumber)

	if totalPlayers == 0 then return "无" end

	local elitePlayers = Object.CountPlayersOnMap(mapNumber, function(oPlayer)
		return oPlayer.Level >= 400 and oPlayer.userData.Resets >= 5
	end)

	local elitePercent = (elitePlayers / totalPlayers) * 100

	if elitePercent >= 70 then return "地狱", 2.5
	elseif elitePercent >= 50 then return "困难", 2.0
	elseif elitePercent >= 30 then return "普通", 1.5
	else return "简单", 1.0
	end
end

function AutoSpawnControl(mapNumber, baseSpawnCount)
	local playerCount = Object.CountPlayersOnMap(mapNumber)
	local monsterCount = Object.CountMonstersOnMap(mapNumber)
	local desired = math.max(baseSpawnCount, playerCount * 2)
	local needed = desired - monsterCount

	if needed > 0 then
		Log.Add(string.format("地图 %d: 需要生成 %d 只怪物 (玩家: %d, 怪物: %d)",
			mapNumber, needed, playerCount, monsterCount))
		return needed
	end

	return 0
end

-- 奖励地图上等级最高的前 N 名玩家
function AwardTopPlayers(mapNumber, topCount, zenPerPlayer)
	local players = {}

	Object.ForEachPlayerOnMap(mapNumber, function(oPlayer)
		table.insert(players, {
			Name = oPlayer.Name,
			Index = oPlayer.Index,
			Level = oPlayer.Level
		})
		return true
	end)

	table.sort(players, function(a, b) return a.Level > b.Level end)

	local awarded = 0

	for i = 1, math.min(topCount, #players) do
		Player.SetMoney(players[i].Index, zenPerPlayer, false)
		Message.Send(0, players[i].Index, 1,
			string.format("第 %d 名奖励: %d 金币!", i, zenPerPlayer))
		awarded = awarded + 1
	end

	return awarded
end

------------------------------------------------------------------
-- 物品 ID 辅助函数
------------------------------------------------------------------

function CreateItemIdExamples()
	local kris       = Helpers.MakeItemId(0, 0)    -- 波刃剑
	local bless      = Helpers.MakeItemId(14, 13)  -- 祝福宝石
	local soul       = Helpers.MakeItemId(14, 14)  -- 灵魂宝石
	local chaos      = Helpers.MakeItemId(12, 15)  -- 玛雅之石
	local excalibur  = Helpers.MakeItemId(0, 19)   -- 大天使之剑

	Log.Add(string.format("波刃剑: %d", kris))
	Log.Add(string.format("祝福宝石: %d", bless))
	Log.Add(string.format("灵魂宝石: %d", soul))
	Log.Add(string.format("玛雅之石: %d", chaos))
	Log.Add(string.format("大天使之剑: %d", excalibur))
end

function IsItemJewel(itemId)
	local t = Helpers.GetItemType(itemId)
	return t == 12 or t == 13 or t == 14
end

function IsItemWeapon(itemId)
	local t = Helpers.GetItemType(itemId)
	return t >= 0 and t <= 5
end

function IsItemArmor(itemId)
	local t = Helpers.GetItemType(itemId)
	return t >= 6 and t <= 11
end

function CountItemInInventory(iPlayerIndex, targetType, targetIndex)
	local oPlayer = Player.GetObjByIndex(iPlayerIndex)
	if not oPlayer then return 0 end

	local count = 0

	for slot = 12, 75 do
		local item = oPlayer:GetInventoryItem(slot)
		if item and item.ItemId ~= 0xFFFFFFFF then
			if Helpers.GetItemType(item.ItemId) == targetType
			   and Helpers.GetItemIndex(item.ItemId) == targetIndex then
				count = count + 1
			end
		end
	end

	return count
end

function HasJewelOfBless(iPlayerIndex)
	local count = CountItemInInventory(iPlayerIndex, 14, 13)
	return count > 0, count
end

------------------------------------------------------------------
-- 颜色辅助函数
------------------------------------------------------------------

function LogServerStatus()
	local totalPlayers = 0

	for mapNum = 0, 10 do
		totalPlayers = totalPlayers + Object.CountPlayersOnMap(mapNum)
	end

	if totalPlayers < 50 then
		Log.AddC(Helpers.RGB(0, 255, 0),
			string.format("服务器负载: 低 (%d 名玩家)", totalPlayers))
	elseif totalPlayers < 200 then
		Log.AddC(Helpers.RGB(255, 165, 0),
			string.format("服务器负载: 中 (%d 名玩家)", totalPlayers))
	else
		Log.AddC(Helpers.RGB(255, 0, 0),
			string.format("服务器负载: 高 (%d 名玩家)", totalPlayers))
	end
end

--═══════════════════════════════════════════════════════════════
-- 实用函数示例结束
--═══════════════════════════════════════════════════════════════
