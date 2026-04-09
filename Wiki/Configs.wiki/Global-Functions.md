# 全局函数参考

游戏服务器暴露给 Lua 脚本系统的完整函数参考。

**函数调用方式：**
- **命名空间：** `Player.GetObjByIndex(index)` ✅ 推荐（组织清晰）
两种方法性能**完全相同**（零开销）。命名空间通过 C++ 双向绑定实现。

---

## 目录

- [Server](#server-命名空间)
- [Object](#object-命名空间)
- [Player](#player-命名空间)
- [Combat](#combat-命名空间)
- [Stats](#stats-命名空间)
- [Inventory](#inventory-命名空间)
- [Item](#item-命名空间)
- [Monster](#monster-namespace)
- [ItemBag](#itembag-命名空间)
- [Buff](#buff-命名空间)
- [Skill](#skill-命名空间)
- [Viewport](#viewport-命名空间)
- [Move](#move-命名空间)
- [Party](#party-命名空间)
- [DB](#db-命名空间)
- [Message](#message-命名空间)
- [Timer](#timer-命名空间)
- [ActionTick](#actiontick-命名空间)
- [Scheduler](#scheduler-命名空间)
- [Utility](#utility-命名空间)
- [Log](#log-命名空间)

---

## Server 命名空间

服务器配置和信息函数。

### Server.GetCode

```lua
Server.GetCode()
```


**返回：** `int` - 服务器唯一代码标识符

**描述：** 返回当前游戏服务器的唯一代码标识符。

**用法：**
```lua
local serverCode = Server.GetCode()
Log.Add(string.format("服务器代码: %d", serverCode))
```

---

### Server.GetName

```lua
Server.GetName()
```


**返回：** `string` - 服务器显示名称

**描述：** 返回当前游戏服务器的显示名称。

**用法：**
```lua
local serverName = Server.GetName()
Log.Add("服务器: " .. serverName)
Message.Send(0, -1, 1, string.format("欢迎来到 %s!", serverName))
```

---

### Server.GetVIPLevel

```lua
Server.GetVIPLevel()
```


**返回：** `int` - VIP 等级设置（未设置则为 `-1`）

**描述：** 返回当前游戏服务器的 VIP 等级设置。

**用法：**
```lua
local vipLevel = Server.GetVIPLevel()
if vipLevel > 0 then
    Log.Add(string.format("VIP 等级: %d", vipLevel))
end
```

---

### Server.IsNonPvP

```lua
Server.IsNonPvP()
```


**返回：** `bool` - 如果禁用 PvP 则为 `true`，否则为 `false`

**描述：** 返回服务器是否全局禁用 PvP。

**用法：**
```lua
if Server.IsNonPvP() then
    Log.Add("此服务器已禁用 PvP")
    Message.Send(0, iPlayerIndex, 0, "这是非 PvP 服务器")
end
```

---

### Server.Is28Option

```lua
Server.Is28Option()
```


**返回：** `bool` - 如果启用 +28 则为 `true`，否则为 `false`

**描述：** 返回服务器是否全局启用物品 +28 选顷。

**用法：**
```lua
if Server.Is28Option() then
    -- 允许创建 +28 物品
    itemInfo.Option3 = 7  -- +28
end
```

---

### Server.GetClassPointsPerLevel

```lua
Server.GetClassPointsPerLevel(iPlayerClassType)
```


**参数：**
- `iPlayerClassType` (int): 角色职业类型

**返回：** `int` - 指定职业每级获得的属性点数

**描述：** 返回指定角色职业每级获得的属性点数。这是游戏规则设置。

**用法：**
```lua
local pointsPerLevel = Server.GetClassPointsPerLevel(Enums.CharacterClassType.WIZARD)
Log.Add(string.format("法师每级获得 %d 点属性", pointsPerLevel))
```

---

## Object 命名空间

对象管理和限制。

### Object.GetMax

```lua
Object.GetMax()
```


**返回：** `int` - 最大对象总数

**描述：** 返回最大对象总数（怪物 + 玩家 + 召唤物）。

**用法：**
```lua
local maxObjects = Object.GetMax()
Log.Add(string.format("最大对象数: %d", maxObjects))
```

---

### Object.GetMaxMonster

```lua
Object.GetMaxMonster()
```


**返回：** `int` - 最大怪物数量

**描述：** 返回最大怪物对象数量。

**用法：**
```lua
local maxMonsters = Object.GetMaxMonster()
```

---

### Object.GetMaxUser

```lua
Object.GetMaxUser()
```


**返回：** `int` - 最大用户数量

**描述：** 返回最大玩家对象数量（在线 + 排队）。

**用法：**
```lua
local maxUsers = Object.GetMaxUser()
```

---

### Object.GetMaxOnlineUser

```lua
Object.GetMaxOnlineUser()
```

> ⚠️ **s6 不可用** — 此函数在 s6 版本中不存在。

**返回：** `int` - 最大在线玩家容量

**描述：** 返回最大在线玩家容量。

**用法：**
```lua
local maxOnline = Object.GetMaxOnlineUser()
Log.Add(string.format("最大在线玩家数: %d", maxOnline))
```

---

### Object.GetMaxQueueUser

```lua
Object.GetMaxQueueUser()
```

> ⚠️ **s6 不可用** — 此函数在 s6 版本中不存在。

**返回：** `int` - 最大排队玩家容量

**描述：** 返回最大排队玩家容量。

**用法：**
```lua
local maxQueue = Object.GetMaxQueueUser()
```

---

### Object.GetMaxItem

```lua
Object.GetMaxItem()
```


**返回：** `int` - 最大地上物品数量

**描述：** 返回最大地上物品数量。

**用法：**
```lua
local maxItems = Object.GetMaxItem()
```

---

### Object.GetMaxSummonMonster

```lua
Object.GetMaxSummonMonster()
```


**返回：** `int` - 最大召唤怪物数量

**描述：** 返回最大召唤怪物数量。

**用法：**
```lua
local maxSummons = Object.GetMaxSummonMonster()
```

---

### Object.GetStartUserIndex

```lua
Object.GetStartUserIndex()
```


**返回：** `int` - 玩家对象范围的起始索引

**描述：** 返回玩家对象范围的起始索引。用于遍历玩家。

**用法：**
```lua
local startIndex = Object.GetStartUserIndex()
local Player.IsConnected = Player.IsConnected

for i = startIndex, Object.GetMaxUser() - 1 do
    if Player.IsConnected(i) then
        local oPlayer = Player.GetObjByIndex(i)
        -- 处理玩家
    end
end
```

---

### Object.ForEach

```lua
Object.ForEach(callback)
```

**参数：**
- `callback` (function): 对每个对象调用的回调函数。接收 `oObject` (object)。返回 `false` 可中断遍历。

**返回：** 无

**描述：** 遍历所有对象，包括玩家、怪物、召唤物和物品。跳过空槽（OBJ_EMPTY）。当你需要处理所有对象类型时使用。

**用法：**
```lua
-- 使用专用迭代器分别计算玩家和怪物数量
local playerCount = 0
local monsterCount = 0

Object.ForEachPlayer(function(oPlayer)
    playerCount = playerCount + 1
    return true
end)

Object.ForEachMonster(function(oMonster)
    monsterCount = monsterCount + 1
    return true
end)

Log.Add(string.format("对象: %d 名玩家, %d 只怪物", playerCount, monsterCount))

-- 查找在特定坐标的玩家
local targetX, targetY = 100, 100
Object.ForEachPlayer(function(oPlayer)
    if oPlayer.X == targetX and oPlayer.Y == targetY then
        Log.Add(string.format("找到玩家 %s 在 (%d, %d)", 
            oPlayer.AccountId, targetX, targetY))
        return false  -- 中断
    end
    return true
end)
```

---

### Object.ForEachPlayer

```lua
Object.ForEachPlayer(callback)
```

**参数：**
- `callback` (function): 对每个玩家调用的回调函数。接收 `oPlayer` (object)。返回 `false` 可中断遍历。

**返回：** 无

**描述：** 遍历所有已连接的玩家（PLAYER_PLAYING 状态）。高性能 C++ 遍历 — 比 Lua 循环快 10-20 倍。

**用法：**
```lua
-- 统计在线玩家数量
local playerCount = 0
Object.ForEachPlayer(function(oPlayer)
    playerCount = playerCount + 1
    return true  -- 继续
end)
Log.Add(string.format("在线玩家: %d", playerCount))

-- 查找特定玩家（提前中断）
Object.ForEachPlayer(function(oPlayer)
    if oPlayer.Name == "TargetPlayer" then
        Log.Add("找到玩家!")
        return false  -- 中断
    end
    return true  -- 继续
end)

-- 向所有高级玩家发送消息
Object.ForEachPlayer(function(oPlayer)
    if oPlayer.Level >= 400 then
        Message.Send(0, oPlayer.Index, 1, "精英玩家奖励!")
    end
    return true
end)
```

---

### Object.ForEachPlayerOnMap

```lua
Object.ForEachPlayerOnMap(mapNumber, callback)
```

**参数：**
- `mapNumber` (int): 要筛选的地图编号
- `callback` (function): 对地图上每个玩家调用的回调函数。接收 `oPlayer` (object)。返回 `false` 可中断遍历。

**返回：** 无

**描述：** 仅遍历特定地图上的玩家。比手动筛选更高效。

**用法：**
```lua
-- 统计在 Lorencia 的玩家数量
local lorenciaPlayers = 0
Object.ForEachPlayerOnMap(0, function(oPlayer)
    lorenciaPlayers = lorenciaPlayers + 1
    return true
end)
Log.Add(string.format("Lorencia 玩家数: %d", lorenciaPlayers))

-- 给 Devias 所有玩家发放奖励
Object.ForEachPlayerOnMap(2, function(oPlayer)
    Player.SetMoney(oPlayer.Index, 1000000, false)
    Message.Send(0, oPlayer.Index, 0, "Devias 奖励: 1kk zen!")
    return true
end)

-- 将所有玩家从特定地图传送走
Object.ForEachPlayerOnMap(10, function(oPlayer)
    Move.ToMap(oPlayer.Index, 0, 130, 130)  -- 到 Lorencia
    return true
end)
```

---

### Object.ForEachMonster

```lua
Object.ForEachMonster(callback)
```

**参数：**
- `callback` (function): 对每个怪物调用的回调函数。接收 `oMonster` (object)。返回 `false` 可中断遍历。

**返回：** 无

**描述：** 遍历服务器上所有存活的怪物。

**用法：**
```lua
-- 统计所有怪物数量
local monsterCount = 0
Object.ForEachMonster(function(oMonster)
    monsterCount = monsterCount + 1
    return true
end)
Log.Add(string.format("怪物总数: %d", monsterCount))

-- 治疗所有怪物
Object.ForEachMonster(function(oMonster)
    oMonster.Life = oMonster.MaxLife
    return true
end)

-- 查找特定怪物职业
Object.ForEachMonster(function(oMonster)
    if oMonster.Class == 275 then  -- 黄金哥布林
        Log.Add(string.format("黄金哥布林在地图 %d", oMonster.MapNumber))
    end
    return true
end)
```

---

### Object.ForEachMonsterOnMap

```lua
Object.ForEachMonsterOnMap(mapNumber, callback)
```

**参数：**
- `mapNumber` (int): 要筛选的地图编号
- `callback` (function): 对地图上每个怪物调用的回调函数。接收 `oMonster` (object)。返回 `false` 可中断遍历。

**返回：** 无

**描述：** 仅遍历特定地图上的怪物。

**用法：**
```lua
-- 杀死 Devias 所有怪物
Object.ForEachMonsterOnMap(2, function(oMonster)
    oMonster.Life = 0
    oMonster.Live = false
    return true
end)

-- 给特定地图的怪物增加生命
Object.ForEachMonsterOnMap(10, function(oMonster)
    oMonster.AddLife = oMonster.AddLife + 5000
    oMonster.Life = math.min(oMonster.Life + 5000, oMonster.MaxLife)
    return true
end)

-- 按地图统计怪物数量
local counts = {}
for mapNum = 0, 10 do
    local count = 0
    Object.ForEachMonsterOnMap(mapNum, function(oMonster)
        count = count + 1
        return true
    end)
    if count > 0 then
        Log.Add(string.format("地图 %d: %d 只怪物", mapNum, count))
    end
end
```

---

### Object.ForEachMonsterByClass

```lua
Object.ForEachMonsterByClass(monsterClass, callback)
```

**参数：**
- `monsterClass` (int): 要筛选的怪物职业 ID
- `callback` (function): 对每只指定职业怪物调用的回调函数。接收 `oMonster` (object)。返回 `false` 可中断遍历。

**返回：** 无

**描述：** 仅遍历指定职业类型的怪物。

**用法：**
```lua
-- 查找所有黄金哥布林
Object.ForEachMonsterByClass(275, function(oMonster)
    Log.Add(string.format("黄金哥布林: 地图 %d 在 (%d, %d)", 
        oMonster.MapNumber, oMonster.X, oMonster.Y))
    return true
end)

-- 杀死所有白魔导师
Object.ForEachMonsterByClass(230, function(oMonster)
    oMonster.Life = 0
    oMonster.Live = false
    return true
end)

-- 统计特定怪物类型数量
local bossCount = 0
Object.ForEachMonsterByClass(666, function(oMonster)  -- Boss 职业
    bossCount = bossCount + 1
    return true
end)
Log.Add(string.format("Boss 数量: %d", bossCount))
```

---

### Object.ForEachPartyMember

```lua
Object.ForEachPartyMember(partyNumber, callback)
```

**参数：**
- `partyNumber` (int): 队伍编号（来自 `oPlayer.PartyNumber`）
- `callback` (function): 对每个队伍成员调用的回调函数。接收 `oPlayer` (object)。返回 `false` 可中断遍历。

**返回：** 无

**描述：** 遍历指定队伍的所有成员。

**用法：**
```lua
-- 给整个队伍发放奖励
function AwardPartyBonus(iPlayerIndex)
    local oPlayer = Player.GetObjByIndex(iPlayerIndex)
    
    if oPlayer ~= nil and oPlayer.PartyNumber >= 0 then
        Object.ForEachPartyMember(oPlayer.PartyNumber, function(oMember)
            Player.SetMoney(oMember.Index, 5000000, false)
            Message.Send(0, oMember.Index, 1, "队伍奖励: 5kk zen!")
            return true
        end)
    end
end

-- 检查队伍是否在同一位置
function IsPartyInMap(partyNumber, targetMap)
    local allInMap = true
    
    Object.ForEachPartyMember(partyNumber, function(oMember)
        if oMember.MapNumber ~= targetMap then
            allInMap = false
            return false  -- 提前中断
        end
        return true
    end)
    
    return allInMap
end

-- 发送队伍消息
function PartyBroadcast(partyNumber, message)
    Object.ForEachPartyMember(partyNumber, function(oMember)
        Message.Send(0, oMember.Index, 0, message)
        return true
    end)
end
```

---

### Object.ForEachGuildMember

```lua
Object.ForEachGuildMember(guildName, callback)
```

**参数：**
- `guildName` (string): 要筛选的公会名称
- `callback` (function): 对每个公会成员调用的回调函数。接收 `oPlayer` (object)。返回 `false` 可中断遍历。

**返回：** 无

**描述：** 遍历指定公会的所有在线成员。

**用法：**
```lua
-- 发送公会消息
function GuildBroadcast(guildName, message)
    Object.ForEachGuildMember(guildName, function(oMember)
        Message.Send(0, oMember.Index, 2, message)
        return true
    end)
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

-- 发放公会成就奖励
Object.ForEachGuildMember("TopGuild", function(oMember)
    Player.SetMoney(oMember.Index, 10000000, false)
    Message.Send(0, oMember.Index, 1, "公会成就奖励!")
    return true
end)

-- 检查所有公会成员是否在同一地图
function IsGuildInSameMap(guildName, targetMap)
    local allInMap = true
    
    Object.ForEachGuildMember(guildName, function(oMember)
        if oMember.MapNumber ~= targetMap then
            allInMap = false
            return false  -- 提前中断
        end
        return true
    end)
    
    return allInMap
end
```

---

### Object.ForEachNearby

```lua
Object.ForEachNearby(centerIndex, range, callback)
```

**参数：**
- `centerIndex` (int): 中心对象索引
- `range` (int): 地图单位范围
- `callback` (function): 对每个附近对象调用的回调函数。接收 `oObject` (object) 和 `distance` (int)。返回 `false` 可中断遍历。

**返回：** 无

**描述：** 遍历指定中心对象范围内所有对象。自动计算距离并按相同地图筛选。

**用法：**
```lua
-- 对附近玩家施加范围 buff
function ApplyAOEBuff(iPlayerIndex, range)
    local oCenter = Player.GetObjByIndex(iPlayerIndex)
    if not oCenter then return end
    
    Object.ForEachPlayerOnMap(oCenter.MapNumber, function(oPlayer)
        local dx = math.abs(oPlayer.X - oCenter.X)
        local dy = math.abs(oPlayer.Y - oCenter.Y)
        local distance = math.sqrt(dx * dx + dy * dy)
        
        if distance <= range then
            Buff.Add(oPlayer.Index, 50, 0, 100, 0, 0, 60, 0, iPlayerIndex)
            Message.Send(0, oPlayer.Index, 0, "范围 buff 已施加!")
        end
        return true
    end)
end

-- 查找距离玩家最近的怪物
function FindNearestMonster(iPlayerIndex)
    local nearestMonster = nil
    local nearestDistance = 999999
    local oCenter = Player.GetObjByIndex(iPlayerIndex)
    if not oCenter then return nil, 0 end
    
    Object.ForEachMonsterOnMap(oCenter.MapNumber, function(oMonster)
        local dx = math.abs(oMonster.X - oCenter.X)
        local dy = math.abs(oMonster.Y - oCenter.Y)
        local distance = math.sqrt(dx * dx + dy * dy)
        
        if distance < nearestDistance and distance <= 50 then
            nearestMonster = oMonster
            nearestDistance = distance
        end
        return true
    end)
    
    return nearestMonster, nearestDistance
end

-- 统计区域内的玩家数量
function CountPlayersInArea(iCenterIndex, radius)
    local count = 0
    local oCenter = Player.GetObjByIndex(iCenterIndex)
    if not oCenter then return 0 end
    
    Object.ForEachPlayerOnMap(oCenter.MapNumber, function(oPlayer)
        local dx = math.abs(oPlayer.X - oCenter.X)
        local dy = math.abs(oPlayer.Y - oCenter.Y)
        local distance = math.sqrt(dx * dx + dy * dy)
        
        if distance <= radius then
            count = count + 1
        end
        return true
    end)
    
    return count
end
```

---

### Object.CountPlayersOnMap

```lua
Object.CountPlayersOnMap(mapNumber)
Object.CountPlayersOnMap(mapNumber, filter)
```

**参数：**
- `mapNumber` (int): 地图编号
- `filter` (function, 可选): 筛选回调函数。接收 `oPlayer`，返回 `true` 计数，`false` 跳过

**返回：** `int` - 符合条件的玩家数量

**描述：** 统计特定地图上的玩家。可选筛选回调允许自定义条件，灵活性高且无需完整遍历。

**用法：**
```lua
-- 简单统计（所有玩家）
local totalPlayers = Object.CountPlayersOnMap(0)
if totalPlayers > 50 then
    Log.Add("Lorencia 太拥挤了!")
end

-- 统计高级玩家
local elitePlayers = Object.CountPlayersOnMap(0, function(oPlayer)
    return oPlayer.Level >= 400
end)

-- 统计 VIP 玩家（0 = 基础 VIP，-1 = 非 VIP）
local vipCount = Object.CountPlayersOnMap(0, function(oPlayer)
    return oPlayer.userData.VIPType >= 0
end)

-- 统计具有特定属性的玩家
local strongPlayers = Object.CountPlayersOnMap(0, function(oPlayer)
    return oPlayer.userData.Strength >= 1000 and oPlayer.userData.Dexterity >= 1000
end)

-- 复杂活动验证
local readyPlayers = Object.CountPlayersOnMap(10, function(oPlayer)
    return oPlayer.Level >= 400 
       and oPlayer.PartyNumber >= 0
       and oPlayer.userData.Resets >= 5
       and oPlayer.userData.Money >= 10000000
end)

-- 统计区域内的玩家
local playersInArea = Object.CountPlayersOnMap(2, function(oPlayer)
    return oPlayer.X >= 100 and oPlayer.X <= 150 
       and oPlayer.Y >= 100 and oPlayer.Y <= 150
end)

-- 检查所有地图的高级玩家
for mapNum = 0, 10 do
    local count = Object.CountPlayersOnMap(mapNum, function(oPlayer)
        return oPlayer.Level >= 400
    end)
    if count > 0 then
        Log.Add(string.format("地图 %d: %d 名精英玩家", mapNum, count))
    end
end
```

---

### Object.CountMonstersOnMap

```lua
Object.CountMonstersOnMap(mapNumber)
Object.CountMonstersOnMap(mapNumber, filter)
```

**参数：**
- `mapNumber` (int): 地图编号
- `filter` (function, 可选): 筛选回调函数。接收 `oMonster`，返回 `true` 计数，`false` 跳过

**返回：** `int` - 符合条件的怪物数量

**描述：** 统计特定地图上的怪物。可选筛选回调允许自定义条件。

**用法：**
```lua
-- 简单统计（所有怪物）
local totalMonsters = Object.CountMonstersOnMap(2)
if totalMonsters < 10 then
    Log.Add("Devias 需要刷新怪物!")
end

-- 统计 Boss 怪物
local bossCount = Object.CountMonstersOnMap(2, function(oMonster)
    return oMonster.Class >= 200 and oMonster.Class <= 250
end)

-- 统计特定怪物类型
local goldenGoblins = Object.CountMonstersOnMap(0, function(oMonster)
    return oMonster.Class == 275
end)

-- 统计高 HP 怪物
local tankMonsters = Object.CountMonstersOnMap(2, function(oMonster)
    return oMonster.Life > 50000
end)

-- 统计区域内的怪物
local monstersInArea = Object.CountMonstersOnMap(3, function(oMonster)
    return oMonster.X >= 50 and oMonster.X <= 100 
       and oMonster.Y >= 50 and oMonster.Y <= 100
end)

-- 统计低 HP 怪物（用于 AOE 终结）
local lowHpMonsters = Object.CountMonstersOnMap(2, function(oMonster)
    local hpPercent = (oMonster.Life / oMonster.MaxLife) * 100
    return hpPercent < 20
end)

-- 活动验证
function CanStartBossEvent(mapNumber)
    -- 检查是否还有怪物
    local monsterCount = Object.CountMonstersOnMap(mapNumber)
    if monsterCount > 0 then
        return false, "地图上还有怪物"
    end
    
    -- 检查是否有足够玩家准备就绪
    local readyPlayers = Object.CountPlayersOnMap(mapNumber, function(oPlayer)
        return oPlayer.Level >= 400 and oPlayer.PartyNumber >= 0
    end)
    
    if readyPlayers < 5 then
        return false, "玩家数量不足"
    end
    
    return true, "活动可以开始"
end
```

---

### Object.GetObjByName

```lua
Object.GetObjByName(playerName)
```

**参数：**
- `playerName` (string): 玩家角色名称

**返回：** `object|nil` - 如果找到则返回玩家对象，否则返回 `nil`

**描述：** 优化的玩家搜索，支持提前退出。比 `Player.GetObjByName()` 更高效，适用于单次查找。

**用法：**
```lua
-- 查找并传送玩家
local oTarget = Object.GetObjByName("PlayerName")
if oTarget ~= nil then
    Move.ToMap(oTarget.Index, 0, 130, 130)
    Log.Add(string.format("已传送 %s", oTarget.Name))
else
    Log.Add("玩家未找到或已离线")
end

-- 检查玩家是否在线
function IsPlayerOnline(playerName)
    return Object.GetObjByName(playerName) ~= nil
end

-- 向特定玩家发送消息
local oPlayer = Object.GetObjByName("Admin")
if oPlayer ~= nil then
    Message.Send(0, oPlayer.Index, 1, "GM 消息")
end
```

---

### Object.AddMonster

```lua
Object.AddMonster(iMonIndex, iMapNumber, iBeginX, iBeginY, iEndX, iEndY, iMonAttr)
```

**参数：**
- `iMonIndex` (int): 怪物职业 ID（与 `oMonster.Class` 相同）
- `iMapNumber` (int): 生成怪物的地图
- `iBeginX` (int): 生成区域起始 X 坐标
- `iBeginY` (int): 生成区域起始 Y 坐标
- `iEndX` (int): 生成区域结束 X 坐标
- `iEndY` (int): 生成区域结束 Y 坐标
- `iMonAttr` (int): 元素属性 — 使用 `Enums.ElementType` 值，`0` 表示无属性

**返回：** `int` — 生成怪物的对象索引，失败则返回 `-1`

**描述：** 在指定地图上生成指定职业的怪物。实际位置在定义的边界框内随机选择。
怪物完全初始化并立即进入世界。
如果 `iMonAttr > 0`，则覆盖怪物的艾尔特主属性。

**注意：**
- 如果服务器对象池已满或 `gObjSetMonster` 失败则返回 `-1`。
- `iBeginX`/`iBeginY` 可以等于 `iEndX`/`iEndY` 以在固定点生成。

**用法：**
```lua
-- 在 Devias（地图 2）固定位置生成一只 Balrog
local monIndex = Object.AddMonster(26, 2, 100, 100, 100, 100, 0)
if monIndex >= 0 then
    Log.Add(string.format("已在索引 %d 生成 Balrog", monIndex))
end

-- 在随机区域生成一只火属性 Boss
local monIndex = Object.AddMonster(275, 7, 50, 50, 80, 80, Enums.ElementType.FIRE)
if monIndex < 0 then
    Log.Add("[错误] 生成 Boss 失败 - 对象池可能已满")
end

-- 生成一波怪物用于活动
function SpawnEventWave(mapNumber, monClass, count, x1, y1, x2, y2)
    local spawned = 0
    for i = 1, count do
        local idx = Object.AddMonster(monClass, mapNumber, x1, y1, x2, y2, 0)
        if idx >= 0 then
            spawned = spawned + 1
        end
    end
    Log.Add(string.format("在地图 %d 生成了 %d/%d 只怪物", mapNumber, spawned, count))
    return spawned
end
```

---

### Object.DelMonster

```lua
Object.DelMonster(aIndex)
```

**参数：**
- `aIndex` (int): 要删除的怪物对象索引

**返回：** `int` — 内部 `gObjDel` 调用的结果

**描述：** 立即将指定对象索引处的怪物从世界中移除。
使用 `Object.AddMonster` 返回的索引或从迭代器回调获取的索引。

**用法：**
```lua
-- 通过索引删除特定怪物
Object.DelMonster(monIndex)

-- 从地图清除所有特定职业的怪物
Object.ForEachMonsterOnMap(mapNumber, function(oMonster)
    if oMonster.Class == 275 then
        Object.DelMonster(oMonster.Index)
    end
    return true
end)

-- 生成并在 60 秒后安排删除
local idx = Object.AddMonster(26, 2, 100, 100, 100, 100, 0)
if idx >= 0 then
    Timer.Create(60000, "remove_monster_" .. idx, function()
        Object.DelMonster(idx)
    end)
end
```

---

## Player 命名空间

玩家管理和操作。

### Player.IsConnected

```lua
Player.IsConnected(iPlayerIndex)
```


**参数：**
- `iPlayerIndex` (int): 玩家对象索引

**返回：** `bool` - 如果已连接并在游戏中则为 `true`，否则为 `false`

**描述：** 检查给定索引的玩家是否已连接并处于 PLAYER_PLAYING 状态。

**用法：**
```lua
if Player.IsConnected(iPlayerIndex) then
    Log.Add("玩家在线并游戏中")
end
```

---

### Player.GetObjByIndex

```lua
Player.GetObjByIndex(iPlayerIndex)
```


**参数：**
- `iPlayerIndex` (int): 玩家对象索引

**返回：** `object` - 指定索引处的玩家对象 (stObject)，如果未找到则为 `nil`

**描述：** 返回指定索引处的玩家对象。

**用法：**
```lua
local oPlayer = Player.GetObjByIndex(iPlayerIndex)
if oPlayer ~= nil then
    Log.Add(string.format("玩家: %s, 等级: %d", oPlayer.Name, oPlayer.Level))
end
```

---

### Player.GetObjByName

```lua
Player.GetObjByName(szPlayerName)
```


**参数：**
- `szPlayerName` (string): 玩家角色名称

**返回：** `object` - 玩家对象 (stObject)，如果未找到则为 `nil`

**描述：** 通过名称查找玩家并返回其对象。

**用法：**
```lua
local oPlayer = Player.GetObjByName("PlayerName")
if oPlayer ~= nil then
    Log.Add(string.format("在索引 %d 找到玩家", oPlayer.Index))
end
```

---

### Player.GetIndexByName

```lua
Player.GetIndexByName(szPlayerName)
```


**参数：**
- `szPlayerName` (string): 玩家角色名称

**返回：** `int` - 玩家索引，如果未找到则为 `-1`

**描述：** 通过名称查找玩家并返回其索引。

**用法：**
```lua
local index = Player.GetIndexByName("PlayerName")
if index >= 0 then
    Log.Add(string.format("在索引 %d 找到玩家", index))
    Message.Send(0, index, 0, "你好!")
end
```

---

### Player.SetMoney

```lua
Player.SetMoney(iPlayerIndex, iAmount, bResetMoney)
```


**参数：**
- `iPlayerIndex` (int): 玩家对象索引
- `iAmount` (int): Zen 金额（可以为负数来减少）
- `bResetMoney` (bool): 如果为 `true`，则先重置为 0

**返回：** 无

**描述：** 设置或修改玩家的 zen 货币。

**用法：**
```lua
-- 增加 1,000,000 zen
Player.SetMoney(iPlayerIndex, 1000000, false)

-- 重置并设置为 5,000,000 zen
Player.SetMoney(iPlayerIndex, 5000000, true)

-- 减少 500,000 zen
Player.SetMoney(iPlayerIndex, -500000, false)
```

---



### Player.SaveCharacter
保存角色数据到数据库。

```lua
Player.SaveCharacter(playerIndex)
```

**参数：**
- `playerIndex` (number): 玩家索引

**示例：**
```lua
local oPlayer = Player.GetObjByIndex(100)
Player.SetMoney(oPlayer.Index, 100000, false)
Player.SaveCharacter(oPlayer.Index)
Log.Add(string.format("已保存角色: %s", oPlayer.Name))
```


### Player.SetExp
向玩家发送经验值数据包（修改 oPlayer.Experience 后必须调用）。

```lua
Player.SetExp(playerIndex, targetIndex, exp, attackDamage, msbFlag, monsterType)
```

**参数：**
- `playerIndex` (number): 接收经验的玩家索引
- `targetIndex` (number): 来源索引（给予经验的怪物/玩家）
- `exp` (number): 经验值数量
- `attackDamage` (number): 造成的伤害（用于显示）
- `msbFlag` (boolean): 大师技能书标志
- `monsterType` (number): 怪物类型 ID

**示例：**
```lua
-- 从自定义活动给予经验
local oPlayer = Player.GetObjByIndex(100)
oPlayer.Experience = oPlayer.Experience + 50000
Player.SetExp(oPlayer.Index, -1, 50000, 0, false, 0)

-- 击杀自定义 Boss 后给予经验
function OnBossKilled(oPlayer, bossIndex)
    local expReward = 100000
    oPlayer.Experience = oPlayer.Experience + expReward
    Player.SetExp(oPlayer.Index, bossIndex, expReward, 0, false, 0)
    Message.Send(oPlayer.Index, 0, string.format("获得 %d 经验!", expReward))
end

-- 队伍经验分配
function GivePartyExp(partyLeaderIndex, totalExp)
    local partyCount = Party.GetCount(partyLeaderIndex)
    local expPerMember = math.floor(totalExp / partyCount)
    
    Object.ForEachPartyMember(partyLeaderIndex, function(oPlayer)
        oPlayer.Experience = oPlayer.Experience + expPerMember
        Player.SetExp(oPlayer.Index, -1, expPerMember, 0, false, 0)
    end)
end
```

**注意：**
- 修改 `oPlayer.Experience` 后必须调用
- 非战斗经验使用 `targetIndex = -1`
- 自定义经验可以使用 `false` 和 `0` 作为 msbFlag 和 monsterType


### Player.SetRuud

```lua
Player.SetRuud(iPlayerIndex, iRuud, iObtainedRuud, bIsObtainedRuud)
```

> ⚠️ **s6 不可用** — 此函数在 s6 版本中不存在。

**参数：**
- `iPlayerIndex` (int): 玩家对象索引
- `iRuud` (int): 基础 Ruud 值（当 `iObtainedRuud = 0` 时使用）
- `iObtainedRuud` (int): 要增加（>0）或减少（<0）的 Ruud
- `bIsObtainedRuud` (bool): 如果为 `true` 则显示通知

**返回：** 无

**描述：** 设置或修改玩家的 Ruud 货币。

**用法：**
```lua
-- 增加 1000 Ruud 并显示通知
Player.SetRuud(iPlayerIndex, 0, 1000, true)

-- 设置为正好 5000 Ruud
Player.SetRuud(iPlayerIndex, 5000, 0, false)

-- 减少 500 Ruud
Player.SetRuud(iPlayerIndex, 0, -500, false)
```

---

### Player.Reset

```lua
Player.Reset(iPlayerIndex)
```

> ⚠️ **s6 不可用** — 此函数在 s6 版本中不存在。

**参数：**
- `iPlayerIndex` (int): 玩家对象索引

**返回：** 无

**描述：** 对指定玩家执行角色重置操作。

**用法：**
```lua
Player.Reset(iPlayerIndex)
Log.Add(string.format("玩家 %d 执行了重置", iPlayerIndex))
```

---

### Player.GetEvo

```lua
Player.GetEvo(iPlayerIndex)
```


**参数：**
- `iPlayerIndex` (int): 玩家对象索引

**返回：** `int` - 进化等级 (1-5)，如果无效则为 `-1`

**描述：** 返回角色进化/职业等级。

**用法：**
```lua
local evo = Player.GetEvo(iPlayerIndex)
if evo >= 3 then
    Log.Add("玩家已达到三转或更高")
    -- 允许三转物品
end
```

---

### Player.ReCalc

```lua
Player.ReCalc(iPlayerIndex)
```


**参数：**
- `iPlayerIndex` (int): 玩家对象索引

**返回：** 无

**描述：** 重新计算角色所有属性、伤害、防御等。

**用法：**
```lua
-- 装备改变后
Player.ReCalc(iPlayerIndex)

-- 属性修改后
Stats.Set(iPlayerIndex, Enums.StatType.STRENGTH, 100, 0, 0)
Player.ReCalc(iPlayerIndex)
```

---

### Player.SendLife

```lua
Player.SendLife(iPlayerIndex, iLife, flag, iShield)
```

**参数：**
- `iPlayerIndex` (int): 玩家对象索引
- `iLife` (int): 要发送的生命值
- `flag` (int): 更新标志 — 使用 `Enums.HPManaUpdateFlag` 值
- `iShield` (int): 要发送的护盾值

**返回：** 无

**描述：** 向玩家客户端发送生命/护盾更新数据包。
直接修改 `oPlayer.Life`、`oPlayer.MaxLife`、`oPlayer.Shield` 或 `oPlayer.MaxShield` 后必须调用，
以便客户端反映更改。

**注意：**
- 使用 `Enums.HPManaUpdateFlag.CURRENT_HP_MANA`（`255`）发送当前生命/护盾值。
- 最大 HP 改变后（升级、属性改变、buff）使用 `Enums.HPManaUpdateFlag.MAX_HP_MANA`（`254`）。
- 物品操作失败后使用 `Enums.HPManaUpdateFlag.INVENTORY_STATE_RESET`（`253`）恢复物品栏交互。

**用法：**
```lua
-- 将玩家恢复到满 HP 并同步客户端
oPlayer.Life = oPlayer.MaxLife
oPlayer.Shield = oPlayer.MaxShield
Player.SendLife(oPlayer.Index, oPlayer.Life, Enums.HPManaUpdateFlag.CURRENT_HP_MANA, oPlayer.Shield)

-- 属性改变增加 MaxLife 后，发送新最大值
Stats.Set(oPlayer.Index, Enums.StatType.VITALITY, oPlayer.userData.Vitality + 10, 0, 0)
Player.ReCalc(oPlayer.Index)
Player.SendLife(oPlayer.Index, (oPlayer.MaxLife + oPlayer.AddLife), Enums.HPManaUpdateFlag.MAX_HP_MANA, (oPlayer.MaxShield + oPlayer.AddShield))
```

---

### Player.SendMana

```lua
Player.SendMana(iPlayerIndex, iMana, flag, iBP)
```

**参数：**
- `iPlayerIndex` (int): 玩家对象索引
- `iMana` (int): 要发送的魔法值
- `flag` (int): 更新标志 — 使用 `Enums.HPManaUpdateFlag` 值
- `iBP` (int): 要发送的 AG/体力值

**返回：** 无

**描述：** 向玩家客户端发送魔法/AG 更新数据包。
直接修改 `oPlayer.Mana`、`oPlayer.MaxMana`、`oPlayer.BP` 或 `oPlayer.MaxBP` 后必须调用，
以便客户端反映更改。

**用法：**
```lua
-- 恢复魔法和 AG，然后同步客户端
oPlayer.Mana = oPlayer.MaxMana
oPlayer.BP = oPlayer.MaxBP
Player.SendMana(oPlayer.Index, oPlayer.Mana, Enums.HPManaUpdateFlag.CURRENT_HP_MANA, oPlayer.BP)

-- 属性改变影响 MaxMana 后
Player.ReCalc(oPlayer.Index)
Player.SendMana(oPlayer.Index, (oPlayer.MaxMana + oPlayer.AddMana), Enums.HPManaUpdateFlag.MAX_HP_MANA, oPlayer.MaxBP)
```

---

## Combat 命名空间

战斗相关函数。

### Combat.GetTopDamageDealer

```lua
Combat.GetTopDamageDealer(aTargetMonsterIndex)
```


**参数：**
- `aTargetMonsterIndex` (int): 怪物对象索引

**返回：** `int` - 对指定怪物造成最多伤害的玩家索引，如果没有则为 `-1`

**描述：** 返回对指定怪物造成最多伤害的玩家索引。

**用法：**
```lua
function onMonsterDie(oPlayer, oMonster)
    if oMonster ~= nil then
        local topPlayerIndex = Combat.GetTopDamageDealer(oMonster.Index)
        
        if topPlayerIndex >= 0 then
            -- 奖励最高伤害者
            Player.SetMoney(topPlayerIndex, 1000000, false)
            Message.Send(0, topPlayerIndex, 1, "最高伤害奖励: 1kk zen!")
        end
    end
end
```

---

## Stats 命名空间

角色属性和升级。

### Stats.Set

```lua
Stats.Set(iPlayerIndex, iStatType, iStatValue, iStatAddType, iLevelUpPoint)
```


**参数：**
- `iPlayerIndex` (int): 玩家对象索引
- `iStatType` (int): 属性类型 (0=力量, 1=敏捷, 2=体力, 3=智力, 4=指挥)
- `iStatValue` (int): 要添加的属性值
- `iStatAddType` (int): 添加类型 (0=基础属性, 1=附加属性)
- `iLevelUpPoint` (int): 使用的升级点数

**返回：** 无

**描述：** 增加玩家的基础或附加属性。

**用法：**
```lua
-- 增加 10 点基础力量
Stats.Set(iPlayerIndex, Enums.StatType.STRENGTH, 10, 0, 0)

-- 增加 50 点附加智力（来自物品/buff）
Stats.Set(iPlayerIndex, Enums.StatType.ENERGY, 50, 1, 0)
```

---

### Stats.SendUpdate

```lua
Stats.SendUpdate(iPlayerIndex, iStatType, iStatValue, iLevelUpPoint)
```


**参数：**
- `iPlayerIndex` (int): 玩家对象索引
- `iStatType` (int): 属性类型
- `iStatValue` (int): 新属性值
- `iLevelUpPoint` (int): 剩余升级点数

**返回：** 无

**描述：** 向玩家客户端发送属性更新数据包。

**用法：**
```lua
Stats.SendUpdate(iPlayerIndex, Enums.StatType.STRENGTH, 100, 0)
```

---

### Stats.LevelUp

```lua
Stats.LevelUp(oPlayer, i64AddExp, iMonsterType, szEventType)
```


**参数：**
- `oPlayer` (object): 玩家对象 (stObject)
- `i64AddExp` (UINT64): 要添加的经验值
- `iMonsterType` (int): 怪物类型（如果不是来自怪物则为 0）
- `szEventType` (string): 事件类型名称

**返回：** `bool` - 如果发生升级则为 `true`，否则为 `false`

**描述：** 向玩家添加经验值，达到阈值时处理升级。

**用法：**
```lua
local oPlayer = Player.GetObjByIndex(iPlayerIndex)
if oPlayer ~= nil then
    Stats.LevelUp(oPlayer, 1000000, 0, "Quest")
end
```

---

## Inventory 命名空间

物品栏管理函数。

### Inventory.SendUpdate

```lua
Inventory.SendUpdate(iPlayerIndex, iInventoryPos)
```


**参数：**
- `iPlayerIndex` (int): 玩家对象索引
- `iInventoryPos` (int): 物品栏槽位索引

**返回：** 无

**描述：** 发送单个物品栏槽位的更新数据包。

**用法：**
```lua
-- 更新武器槽位
Inventory.SendUpdate(iPlayerIndex, 0)
```

---

### Inventory.SendDelete

```lua
Inventory.SendDelete(iPlayerIndex, iInventoryPos)
```


**参数：**
- `iPlayerIndex` (int): 玩家对象索引
- `iInventoryPos` (int): 物品栏槽位索引

**返回：** 无

**描述：** 发送物品栏槽位的删除数据包。

**用法：**
```lua
Inventory.SendDelete(iPlayerIndex, 12)
```

---

### Inventory.SendList

```lua
Inventory.SendList(iPlayerIndex)
```


**参数：**
- `iPlayerIndex` (int): 玩家对象索引

**返回：** 无

**描述：** 向玩家发送完整物品栏列表数据包。

**用法：**
```lua
Inventory.SendList(iPlayerIndex)
```

---

### Inventory.HasSpace

```lua
Inventory.HasSpace(oPlayer, iItemHeight, iItemWidth)
```


**参数：**
- `oPlayer` (object): 玩家对象 (stObject)
- `iItemHeight` (int): 物品高度 (1-4)
- `iItemWidth` (int): 物品宽度 (1-2)

**返回：** `bool` - 如果有足够空间则为 `true`，否则为 `false`

**描述：** 检查物品栏是否有足够的空位放置指定尺寸的物品。

**用法：**
```lua
local oPlayer = Player.GetObjByIndex(iPlayerIndex)
if oPlayer ~= nil then
    if Inventory.HasSpace(oPlayer, 2, 1) then
        -- 有空间放置 2x1 物品
        Log.Add("物品栏有空间")
    else
        Message.Send(0, iPlayerIndex, 0, "物品栏已满")
    end
end
```

---

### Inventory.Insert

```lua
Inventory.Insert(iPlayerIndex, oItem)
```


**参数：**
- `iPlayerIndex` (int): 玩家对象索引
- `oItem` (object): 物品对象 (ItemInfo)

**返回：** 无

**描述：** 将物品对象插入第一个可用的物品栏槽位。

**用法：**
```lua
Inventory.Insert(iPlayerIndex, oItem)
```

---

### Inventory.InsertAt

```lua
Inventory.InsertAt(iPlayerIndex, oItem, btInventoryPos)
```


**参数：**
- `iPlayerIndex` (int): 玩家对象索引
- `oItem` (object): 物品对象 (ItemInfo)
- `btInventoryPos` (BYTE): 物品栏位置

**返回：** `BYTE` - 结果代码

**描述：** 在指定物品栏位置插入物品。

**用法：**
```lua
local result = Inventory.InsertAt(iPlayerIndex, oItem, 12)
if result == 1 then
    Log.Add("物品插入成功")
end
```

---

### Inventory.Delete

```lua
Inventory.Delete(iPlayerIndex, iInventoryItemPos)
```


**参数：**
- `iPlayerIndex` (int): 玩家对象索引
- `iInventoryItemPos` (int): 物品栏槽位索引

**返回：** 无

**描述：** 从指定物品栏位置移除物品。

**用法：**
```lua
Inventory.Delete(iPlayerIndex, 12)
Log.Add("物品已从 12 号槽位删除")
```

---

### Inventory.SetSlot

```lua
Inventory.SetSlot(iPlayerIndex, iInventoryItemStartPos, btItemType)
```


**参数：**
- `iPlayerIndex` (int): 玩家对象索引
- `iInventoryItemStartPos` (int): 起始位置
- `btItemType` (BYTE): 物品类型（使用 `0xFF` 清除）

**返回：** 无

**描述：** 设置物品栏槽位状态。使用 `0xFF` 清除物品占用的槽位。

**用法：**
```lua
-- 清除从位置 12 开始的物品槽位
Inventory.SetSlot(iPlayerIndex, 12, 0xFF)
```

---

### Inventory.ReduceDur

```lua
Inventory.ReduceDur(oPlayer, iInventoryItemPos, iDurabilityMinus)
```


**参数：**
- `oPlayer` (object): 玩家对象 (stObject)
- `iInventoryItemPos` (int): 物品栏槽位索引
- `iDurabilityMinus` (int): 要减少的耐久度

**返回：** `int` - 剩余耐久度

**描述：** 减少指定物品栏槽位物品的耐久度。

**用法：**
```lua
local oPlayer = Player.GetObjByIndex(iPlayerIndex)
if oPlayer ~= nil then
    local remainingDur = Inventory.ReduceDur(oPlayer, 0, 1)
    Log.Add(string.format("剩余耐久度: %d", remainingDur))
end
```

---

## Item 命名空间

物品信息和创建函数。

### Item.IsValid

```lua
Item.IsValid(iItemId)
```


**参数：**
- `iItemId` (int): 物品 ID

**返回：** `int` - 如果有效则为 `1`，否则为 `0`

**描述：** 返回物品 ID 是否有效。

**用法：**
```lua
local itemId = Helpers.MakeItemId(0, 0)
if Item.IsValid(itemId) == 1 then
    Log.Add("有效物品")
end
```

---

### Item.GetKindA

```lua
Item.GetKindA(iItemId)
```


**参数：**
- `iItemId` (int): 物品 ID

**返回：** `int` - KindA 类别类型

**描述：** 返回指定物品的 KindA 属性（主要类别）。

**用法：**
```lua
local kindA = Item.GetKindA(Helpers.MakeItemId(0, 0))
if kindA == Enums.ItemKindA.WEAPON then
    Log.Add("这是武器")
end
```

---

### Item.GetKindB

```lua
Item.GetKindB(iItemId)
```


**参数：**
- `iItemId` (int): 物品 ID

**返回：** `int` - KindB 子类别类型

**描述：** 返回指定物品的 KindB 属性（次要类别/子类型）。

**用法：**
```lua
local kindB = Item.GetKindB(Helpers.MakeItemId(0, 0))
if kindB == Enums.ItemKindB.SWORD_KNIGHT then
    Log.Add("骑士剑")
end
```

---

### Item.GetAttr

```lua
Item.GetAttr(iItemId)
```


**参数：**
- `iItemId` (int): 物品 ID

**返回：** `object` - 包含所有物品属性的结构 (ItemAttr)

**描述：** 返回包含所有物品属性的结构（宽度、高度、耐久度、需求等）。

**用法：**
```lua
local itemId = Helpers.MakeItemId(0, 0)
local attr = Item.GetAttr(itemId)

if attr ~= nil then
    local itemName = attr:GetName()
    Log.Add(string.format("物品: %s", itemName))
    Log.Add(string.format("大小: %dx%d", attr.Width, attr.Height))
    Log.Add(string.format("伤害: %d-%d", attr.DamageMin, attr.DamageMax))
end
```

---

### Item.IsSocket

```lua
Item.IsSocket(iItemId)
```


**参数：**
- `iItemId` (int): 物品 ID

**返回：** `bool` - 如果是凹槽物品则为 `true`，否则为 `false`

**描述：** 返回物品是否可以拥有凹槽选项。

**用法：**
```lua
if Item.IsSocket(Helpers.MakeItemId(0, 0)) then
    Log.Add("物品支持凹槽")
end
```

---

### Item.IsExcSocketAccessory

```lua
Item.IsExcSocketAccessory(iItemId)
```

> ⚠️ **s6 不可用** — 此函数在 s6 版本中不存在。请改用 `Item.GetExcellentOption()`。

**参数：**
- `iItemId` (int): 物品 ID

**返回：** `bool` - 如果是卓越凹槽饰品则为 `true`，否则为 `false`

**描述：** 返回物品是否是卓越凹槽饰品。

**用法：**
```lua
if Item.IsExcSocketAccessory(itemId) then
    -- 处理卓越饰品
end
```

---

### Item.IsElemental

```lua
Item.IsElemental(iItemId)
```

> ⚠️ **s6 不可用** — 此函数在 s6 版本中不存在。

**参数：**
- `iItemId` (int): 物品 ID

**返回：** `bool` - 如果是元素物品则为 `true`，否则为 `false`

**描述：** 返回物品是否是元素类型。

**用法：**
```lua
if Item.IsElemental(itemId) then
    -- 处理元素物品
end
```

---

### Item.IsPentagram

```lua
Item.IsPentagram(iItemId)
```

> ⚠️ **s6 不可用** — 此函数在 s6 版本中不存在。

**参数：**
- `iItemId` (int): 物品 ID

**返回：** `bool` - 如果是艾尔特则为 `true`，否则为 `false`

**描述：** 返回物品是否是艾尔特类型。

**用法：**
```lua
if Item.IsPentagram(itemId) then
    -- 处理艾尔特
end
```

---

### Item.IsMasterPentagram

```lua
Item.IsMasterPentagram(iItemId)
```

> ⚠️ **Not available in s6** — This function does not exist in the s6 build.

**Parameters:**
- `iItemId` (int): Item ID

**Returns:** `bool` - `true` if master pentagram item, `false` otherwise

**Description:** Returns whether item is a master pentagram type.

**Usage:**
```lua
if Item.IsMasterPentagram(itemId) then
    -- Handle master pentagram
end
```

---

### Item.IsPentagramJewel

```lua
Item.IsPentagramJewel(iItemId)
```

> ⚠️ **Not available in s6** — This function does not exist in the s6 build.

**Parameters:**
- `iItemId` (int): Item ID

**Returns:** `bool` - `true` if pentagram jewel, `false` otherwise

**Description:** Returns whether item is a pentagram jewel.

**Usage:**
```lua
if Item.IsPentagramJewel(itemId) then
    -- Handle pentagram jewel
end
```

---

### Item.IsMasterPentagramJewel

```lua
Item.IsMasterPentagramJewel(iItemId)
```

> ⚠️ **Not available in s6** — This function does not exist in the s6 build.

**Parameters:**
- `iItemId` (int): Item ID

**Returns:** `bool` - `true` if master pentagram jewel, `false` otherwise

**Description:** Returns whether item is a master pentagram jewel.

**Usage:**
```lua
if Item.IsMasterPentagramJewel(itemId) then
    -- Handle master pentagram jewel
end
```

---

### Item.GetExcellentOption

```lua
Item.GetExcellentOption(iItemId)
```

> 🔵 **仅 s6** — 此函数仅存在于 s6 版本。

**参数：**
- `iItemId` (int): 物品 ID

**返回：** `int` - 卓越选项位掩码

**描述：** 返回给定物品的卓越选项位掩码。在 s7+ 中此功能拆分为专用的类型检查函数。

**用法：**
```lua
local excOptions = Item.GetExcellentOption(itemId)
if excOptions > 0 then
    Log.Add(string.format("物品拥有卓越选项: %d", excOptions))
end
```

---

### Item.GetSetOption

```lua
Item.GetSetOption(iItemId)
```


**参数：**
- `iItemId` (int): 物品 ID

**返回：** `int` - 套装选项索引

**描述：** 生成古代/套装选项并返回套装索引。

**用法：**
```lua
local setIndex = Item.GetSetOption(itemId)
Log.Add(string.format("套装选项: %d", setIndex))
```

---

### Item.GetRandomLevel

```lua
Item.GetRandomLevel(iMinLevel, iMaxLevel)
```


**参数：**
- `iMinLevel` (int): 最小等级
- `iMaxLevel` (int): 最大等级

**返回：** `int` - 随机物品等级

**描述：** 返回最小和最大范围内的随机物品等级。

**用法：**
```lua
local itemLevel = Item.GetRandomLevel(0, 9)  -- 随机 0-9
Log.Add(string.format("随机等级: %d", itemLevel))
```

---

### Item.Create

```lua
Item.Create(iPlayerIndex, stItemCreate)
```


**参数：**
- `iPlayerIndex` (int): 玩家对象索引
- `stItemCreate` (object): 物品创建信息 (CreateItemInfo 结构)

**返回：** 无

**描述：** 根据 CreateItemInfo 结构创建物品。可以生成在地上或物品栏中。

**用法：**
```lua
local itemInfo = CreateItemInfo.new()
itemInfo.MapNumber = oPlayer.MapNumber
itemInfo.X = oPlayer.X
itemInfo.Y = oPlayer.Y
itemInfo.ItemId = Helpers.MakeItemId(14, 13)  -- 祝福宝石
itemInfo.ItemLevel = 0
itemInfo.Durability = 1
itemInfo.Option1 = 0
itemInfo.Option2 = 0
itemInfo.Option3 = 0
itemInfo.LootIndex = iPlayerIndex
itemInfo.TargetInvenPos = 255  -- 自动查找槽位

Item.Create(iPlayerIndex, itemInfo)
```

---

### Item.MakeRandomSet

```lua
Item.MakeRandomSet(iPlayerIndex, bGremoryCase, bDropMasterySet)
```


**参数：**
- `iPlayerIndex` (int): 玩家对象索引
- `bGremoryCase` (int): 格雷莫里箱子标志
- `bDropMasterySet` (bool): 掉落大师套装标志

**返回：** 无

**描述：** 为玩家生成随机套装物品，掉落在玩家脚下或添加到格雷莫里箱子。

**用法：**
```lua
-- 在地上掉落随机套装物品
Item.MakeRandomSet(iPlayerIndex, 0, false)

-- 添加到格雷莫里箱子
Item.MakeRandomSet(iPlayerIndex, 1, false)
```

---

## Monster Namespace

Monster management functions for reading monster data.

### Monster.GetAttr

```lua
Monster.GetAttr(iClass)
```

**Parameters:**
- `iClass` (int): Monster class ID

**Returns:** `MonsterAttr` - Monster attribute object, or `nil` if not found

**Description:** Returns the attribute table for a monster class. Provides access to stats, combat values, resistances and other configuration data for the given monster class ID.

> 📖 See [Monster Structure](Monster-Structure) for full `MonsterAttr` field reference.

**Usage:**
```lua
local attr = Monster.GetAttr(275) -- Kundun
if attr ~= nil then
    Log.Add(string.format("Kundun HP: %d, Defense: %d", attr.HP, attr.Defense))
    Log.Add(string.format("Name: %s", attr:GetName()))
end
```

---

## ItemBag Namespace

Item bag system functions.

### ItemBag.Add

```lua
ItemBag.Add(iBagType, iParam1, iParam2, strFileName)
```


**参数：**
- `iBagType` (int): 袋子类型 (0=DROP, 1=INVENTORY, 2=MONSTER, 3=EVENT)
- `iParam1` (int): 参数 1（取决于袋子类型）
- `iParam2` (int): 参数 2（取决于袋子类型）
- `strFileName` (string): 袋子文件名（不含 .txt 扩展名）

**返回：** 无

**描述：** 加载物品袋配置文件。

**袋子类型：**
- **0 (DROP):** 地上物品掉落
  - `iParam1`: 物品 ID
  - `iParam2`: 物品等级
- **1 (INVENTORY):** 从物品栏打开
  - `iParam1`: 物品 ID
  - `iParam2`: 物品等级
- **2 (MONSTER):** 怪物掉落
  - `iParam1`: 怪物职业
  - `iParam2`: 地图编号（0 = 所有地图）
- **3 (EVENT):** 活动奖励
  - `iParam1`: 活动 ID
  - `iParam2`: 活动等级

**用法：**
```lua
-- 幸运盒物品的掉落袋
ItemBag.Add(0, Helpers.MakeItemId(14, 11), 0, 'Item_(14,11,0)_Luck_Box')

-- 红色丝带盒物品栏袋
ItemBag.Add(1, Helpers.MakeItemId(12, 32), 0, 'Item_(12,32,0)_Red_Ribbon_Box')

-- 黑暗精灵怪物袋（职业 340）
ItemBag.Add(2, 340, 0, 'Monster_(340)_Dark_Elf')

-- 混沌城堡 1 级奖励活动袋
ItemBag.Add(3, 14, 1, 'Event_ChaosCastle(1)_Reward')
```

---

### ItemBag.CreateItem

```lua
ItemBag.CreateItem(iPlayerIndex, stBagItem)
```


**参数：**
- `iPlayerIndex` (int): 玩家对象索引
- `stBagItem` (object): 袋子物品结构 (BagItem)

**返回：** 无

**描述：** 根据物品袋结构创建并掉落物品。

**用法：**
```lua
ItemBag.CreateItem(iPlayerIndex, bagItemStruct)
```

---

### ItemBag.Use
```lua
ItemBag.Use(playerIndex, bagType, param1, param2)
```

**参数：**
- `playerIndex` (int): 玩家对象索引
- `bagType` (int): 物品袋类型（使用 Enums.ItemBagType）
- `param1` (int): 取决于袋子类型（见下文）
- `param2` (int): 取决于袋子类型（见下文）

**返回：** 无

**描述：** 使用物品袋向玩家发放物品。物品必须在 ItemBagScript.lua 中注册为袋子。

---

## 袋子类型

### DROP - 使用物品袋（掉落在地）
```lua
ItemBag.Use(oPlayer.Index, Enums.ItemBagType.DROP, itemId, itemLevel)
```
使用注册为袋子的物品。内容掉落在玩家位置。

**示例：**
```lua
-- 使用物品 14/13（注册为袋子）- 内容掉落在地
ItemBag.Use(oPlayer.Index, Enums.ItemBagType.DROP, 14, 13)
```

---

### INVENTORY - 使用物品袋（放入物品栏）
```lua
ItemBag.Use(oPlayer.Index, Enums.ItemBagType.INVENTORY, itemId, itemLevel)
```
使用注册为袋子的物品。内容进入玩家物品栏。

**示例：**
```lua
-- 使用物品 14/13（注册为袋子）- 内容放入物品栏
ItemBag.Use(oPlayer.Index, Enums.ItemBagType.INVENTORY, 14, 13)
```

---

### MONSTER - 怪物掉落
```lua
ItemBag.Use(oPlayer.Index, Enums.ItemBagType.MONSTER, monsterClass, oPlayer.Index)
```
掉落特定怪物类型的战利品。

**示例：**
```lua
-- 掉落黄金哥布林战利品
ItemBag.Use(oPlayer.Index, Enums.ItemBagType.MONSTER, 53, oPlayer.Index)
```

---

### EVENT - 活动袋
```lua
ItemBag.Use(oPlayer.Index, Enums.ItemBagType.EVENT, eventBagId, oPlayer.Index)
```
使用 ItemBagScript.lua 中的活动专属袋子。

**示例：**
```lua
ItemBag.Use(oPlayer.Index, Enums.ItemBagType.EVENT, 300, oPlayer.Index)
```

---

## 简单示例

**使用奖励盒物品（掉落内容）：**
```lua
function UseRewardBox(oPlayer)
    local boxItemId = 14
    local boxLevel = 13
    ItemBag.Use(oPlayer.Index, Enums.ItemBagType.DROP, boxItemId, boxLevel)
    Message.Send(0, oPlayer.Index, 0, "奖励盒已打开!")
end
```

**使用奖励盒物品（放入物品栏）：**
```lua
function UseRewardBox(oPlayer)
    local boxItemId = 14
    local boxLevel = 13
    ItemBag.Use(oPlayer.Index, Enums.ItemBagType.INVENTORY, boxItemId, boxLevel)
    Message.Send(0, oPlayer.Index, 0, "奖励已收到!")
end
```

**活动奖励：**
```lua
function GiveEventReward(oPlayer)
    ItemBag.Use(oPlayer.Index, Enums.ItemBagType.EVENT, 500, oPlayer.Index)
    Message.Send(0, oPlayer.Index, 0, "活动奖励已收到!")
end
```

**掉落 Boss 战利品：**
```lua
function DropBossLoot(oPlayer, bossClass)
    ItemBag.Use(oPlayer.Index, Enums.ItemBagType.MONSTER, bossClass, oPlayer.Index)
end
```

---

**注意：** 对于 DROP 和 INVENTORY 类型，物品（itemId + itemLevel）必须在 ItemBagScript.lua 中注册为袋子。

---

## Buff 命名空间

Buff 管理函数。

### Buff.Add

```lua
Buff.Add(oPlayer, iBuffIndex, EffectType1, EffectValue1, EffectType2, EffectValue2, iBuffDuration, BuffSendValue, nAttackerIndex)
```


**参数：**
- `oPlayer` (object): 玩家对象 (stObject)
- `iBuffIndex` (int): Buff 索引
- `EffectType1` (BYTE): 效果类型 1
- `EffectValue1` (int): 效果值 1
- `EffectType2` (BYTE): 效果类型 2
- `EffectValue2` (int): 效果值 2
- `iBuffDuration` (int): 持续时间（秒）
- `BuffSendValue` (WORD): 发送值
- `nAttackerIndex` (int): 攻击者索引

**返回：** 无

**描述：** 向玩家添加具有指定参数的 buff 效果。

**用法：**
```lua
local oPlayer = Player.GetObjByIndex(iPlayerIndex)
if oPlayer ~= nil then
    Buff.Add(oPlayer, buffIndex, 0, 100, 0, 0, 60, 0, -1)
end
```

---

### Buff.AddCashShop

```lua
Buff.AddCashShop(oPlayer, wItemID, iBuffDuration)
```


**参数：**
- `oPlayer` (object): 玩家对象 (stObject)
- `wItemID` (WORD): 现金商城物品 ID
- `iBuffDuration` (int): 持续时间（秒）

**返回：** 无

**描述：** 添加现金商城物品使用的 buff 效果。

**用法：**
```lua
local oPlayer = Player.GetObjByIndex(iPlayerIndex)
if oPlayer ~= nil then
    Buff.AddCashShop(oPlayer, itemID, 3600)  -- 1 小时 buff
end
```

---

### Buff.AddItem

```lua
Buff.AddItem(oPlayer, iBuffIndex)
```


**参数：**
- `oPlayer` (object): 玩家对象 (stObject)
- `iBuffIndex` (int): Buff 索引

**返回：** 无

**描述：** 向玩家添加基于物品的 buff。

**用法：**
```lua
local oPlayer = Player.GetObjByIndex(iPlayerIndex)
if oPlayer ~= nil then
    Buff.AddItem(oPlayer, buffIndex)
end
```

---

### Buff.Remove

```lua
Buff.Remove(oPlayer, iBuffIndex)
```


**参数：**
- `oPlayer` (object): 玩家对象 (stObject)
- `iBuffIndex` (int): Buff 索引

**返回：** 无

**描述：** 如果 buff 处于激活状态则从玩家移除指定 buff。

**用法：**
```lua
local oPlayer = Player.GetObjByIndex(iPlayerIndex)
if oPlayer ~= nil then
    Buff.Remove(oPlayer, buffIndex)
end
```

---

### Buff.CheckUsed

```lua
Buff.CheckUsed(oPlayer, iBuffIndex)
```


**参数：**
- `oPlayer` (object): 玩家对象 (stObject)
- `iBuffIndex` (int): Buff 索引

**返回：** `bool` - 如果 buff 处于激活状态则为 `true`，否则为 `false`

**描述：** 返回玩家是否具有指定激活的 buff。

**用法：**
```lua
local oPlayer = Player.GetObjByIndex(iPlayerIndex)
if oPlayer ~= nil then
    if Buff.CheckUsed(oPlayer, buffIndex) then
        Log.Add("Buff 已激活")
    end
end
```

---

## Skill 命名空间

技能使用函数。

### Skill.UseDuration

```lua
Skill.UseDuration(oPlayer, oTarget, TargetXPos, TargetYPos, iPlayerDirection, iMagicNumber)
```


**参数：**
- `oPlayer` (object): 使用技能的玩家对象 (stObject)
- `oTarget` (object): 目标对象 (stObject)
- `TargetXPos` (int): 目标 X 坐标
- `TargetYPos` (int): 目标 Y 坐标
- `iPlayerDirection` (int): 玩家朝向
- `iMagicNumber` (int): 魔法/技能编号

**返回：** 无

**描述：** 对目标使用持续性技能。

**用法：**
```lua
local oPlayer = Player.GetObjByIndex(iPlayerIndex)
local oTarget = Player.GetObjByIndex(targetIndex)

if oPlayer ~= nil and oTarget ~= nil then
    Skill.UseDuration(oPlayer, oTarget, oTarget.X, oTarget.Y, oPlayer.Dir, magicNumber)
end
```

---

### Skill.UseNormal

```lua
Skill.UseNormal(oPlayer, oTarget, iMagicNumber)
```


**参数：**
- `oPlayer` (object): 使用技能的玩家对象 (stObject)
- `oTarget` (object): 目标对象 (stObject)
- `iMagicNumber` (int): 魔法/技能编号

**返回：** 无

**描述：** 对目标使用即时技能。

**用法：**
```lua
local oPlayer = Player.GetObjByIndex(iPlayerIndex)
local oTarget = Player.GetObjByIndex(targetIndex)

if oPlayer ~= nil and oTarget ~= nil then
    Skill.UseNormal(oPlayer, oTarget, magicNumber)
end
```

---

## Viewport 命名空间

视口管理函数。

### Viewport.Create

```lua
Viewport.Create(oPlayer)
```


**参数：**
- `oPlayer` (object): 玩家对象 (stObject)

**返回：** 无

**描述：** 为玩家创建视口，显示周围对象。

**用法：**
```lua
local oPlayer = Player.GetObjByIndex(iPlayerIndex)
if oPlayer ~= nil then
    Viewport.Create(oPlayer)
end
```

---

### Viewport.Destroy

```lua
Viewport.Destroy(oPlayer)
```


**参数：**
- `oPlayer` (object): 玩家对象 (stObject)

**返回：** 无

**描述：** 销毁玩家视口，隐藏周围对象。

**用法：**
```lua
local oPlayer = Player.GetObjByIndex(iPlayerIndex)
if oPlayer ~= nil then
    Viewport.Destroy(oPlayer)
end
```

---

## Move 命名空间

移动和传送函数。

### Move.Gate

```lua
Move.Gate(iPlayerIndex, iGateIndex)
```


**参数：**
- `iPlayerIndex` (int): 玩家对象索引
- `iGateIndex` (int): 传送门索引（来自传送门配置）

**返回：** `bool` - 如果成功则为 `true`，否则为 `false`

**描述：** 通过指定传送门索引传送玩家。

**用法：**
```lua
if Move.Gate(iPlayerIndex, 17) then
    Log.Add("玩家已通过传送门")
else
    Message.Send(0, iPlayerIndex, 0, "无法使用传送门")
end
```

---

### Move.ToMap

```lua
Move.ToMap(iTargetObjectIndex, iMapNumber, PosX, PosY)
```


**参数：**
- `iTargetObjectIndex` (int): 目标对象索引（玩家或怪物）
- `iMapNumber` (int): 目标地图编号
- `PosX` (BYTE): 目标 X 坐标
- `PosY` (BYTE): 目标 Y 坐标

**返回：** 无

**描述：** 将玩家或怪物传送到指定地图和坐标。

**用法：**
```lua
-- 传送到 Lorencia
Move.ToMap(iPlayerIndex, 0, 130, 130)

-- 传送到 Devias
Move.ToMap(iPlayerIndex, 2, 220, 70)
```

---

### Move.Warp

```lua
Move.Warp(iTargetObjectIndex, PosX, PosY)
```


**参数：**
- `iTargetObjectIndex` (int): 目标对象索引（玩家或怪物）
- `PosX` (BYTE): 目标 X 坐标
- `PosY` (BYTE): 目标 Y 坐标

**返回：** 无

**描述：** 在当前地图内传送玩家或怪物。

**用法：**
```lua
-- 在当前地图内传送
Move.Warp(iPlayerIndex, 150, 150)
```

---

## Party 命名空间

队伍系统函数。

### Party.GetCount

```lua
Party.GetCount(iPartyNumber)
```


**参数：**
- `iPartyNumber` (int): 队伍编号

**返回：** `int` - 队伍成员数量

**描述：** 返回指定队伍的成员数量。

**用法：**
```lua
local oPlayer = Player.GetObjByIndex(iPlayerIndex)
if oPlayer ~= nil and oPlayer.PartyNumber >= 0 then
    local memberCount = Party.GetCount(oPlayer.PartyNumber)
    Log.Add(string.format("队伍有 %d 名成员", memberCount))
end
```

---

### Party.GetMember

```lua
Party.GetMember(iPartyNumber, iArrayIndex)
```


**参数：**
- `iPartyNumber` (int): 队伍编号
- `iArrayIndex` (int): 数组索引（1=队长，2-5=成员）

**返回：** `int` - 玩家索引

**描述：** 返回队伍在指定位置的玩家索引。索引 1 始终是队伍队长。

**用法：**
```lua
local oPlayer = Player.GetObjByIndex(iPlayerIndex)
if oPlayer ~= nil and oPlayer.PartyNumber >= 0 then
    -- 获取队伍队长
    local leaderIndex = Party.GetMember(oPlayer.PartyNumber, 1)
    local oLeader = Player.GetObjByIndex(leaderIndex)
    
    if oLeader ~= nil then
        Log.Add(string.format("队伍队长: %s", oLeader.Name))
    end
    
    -- 获取所有队伍成员
    local memberCount = Party.GetCount(oPlayer.PartyNumber)
    for i = 1, memberCount do
        local memberIndex = Party.GetMember(oPlayer.PartyNumber, i)
        local oMember = Player.GetObjByIndex(memberIndex)
        if oMember ~= nil then
            Log.Add(string.format("成员 %d: %s", i, oMember.Name))
        end
    end
end
```

---

## DB 命名空间

数据库查询函数。

### DB.QueryDS

```lua
DB.QueryDS(iPlayerIndex, iQueryNumber, szQuery, ...)
```


**参数：**
- `iPlayerIndex` (int): 玩家对象索引
- `iQueryNumber` (int): 查询标识符（用于匹配响应）
- `szQuery` (string): SQL 查询字符串（支持格式字符串）
- `...` (可变参数): 可选的格式字符串参数

**返回：** 无

**描述：** 在 DataServer 数据库上执行 SQL 查询。结果在 `DSDBQueryReceive` 回调中接收。

**用法：**
```lua
-- 简单查询
DB.QueryDS(iPlayerIndex, 1, "SELECT * FROM Character WHERE Name = 'Player1'")

-- 带参数的查询
local playerName = "TestPlayer"
DB.QueryDS(iPlayerIndex, 1001, string.format("SELECT Name, cLevel FROM Character WHERE Name = '%s'", playerName))

-- 在回调中处理结果
function DSDBQueryReceive(iUserIndex, iQueryNumber, btIsLastPacket, iCurrentRow, btColumnCount, btCurrentPacket, oRow)
    if iQueryNumber == 1001 and oRow ~= nil then
        local columnName = oRow:GetColumnName()
        local value = oRow:GetValue()
        Log.Add(string.format("%s = %s", columnName, value))
    end
end
```

---

### DB.QueryJS

```lua
DB.QueryJS(iPlayerIndex, iQueryNumber, szQuery, ...)
```


**参数：**
- `iPlayerIndex` (int): 玩家对象索引
- `iQueryNumber` (int): 查询标识符（用于匹配响应）
- `szQuery` (string): SQL 查询字符串（支持格式字符串）
- `...` (可变参数): 可选的格式字符串参数

**返回：** 无

**描述：** 在 JoinServer 数据库上执行 SQL 查询。结果在 `JSDBQueryReceive` 回调中接收。

**用法：**
```lua
-- 查询账号信息
local accountId = "admin"
DB.QueryJS(iPlayerIndex, 2001, string.format("SELECT memb_guid FROM MEMB_INFO WHERE memb___id = '%s'", accountId))

-- 在回调中处理结果
function JSDBQueryReceive(iUserIndex, iQueryNumber, btIsLastPacket, iCurrentRow, btColumnCount, btCurrentPacket, oRow)
    if iQueryNumber == 2001 and oRow ~= nil then
        local columnName = oRow:GetColumnName()
        local value = oRow:GetValue()
        Log.Add(string.format("%s = %s", columnName, value))
    end
end
```

**参见：** [[Database-Structures|Database-Structures]] 获取详细查询示例

---

## Message 命名空间

消息和通知函数。

### Message.Send

```lua
Message.Send(iPlayerIndex, aTargetIndex, btType, szMessage)
```


**参数：**
- `iPlayerIndex` (int): 玩家索引（系统消息使用 0）
- `aTargetIndex` (int): 目标索引（`-1` 表示所有玩家，特定索引表示单个玩家）
- `btType` (BYTE): 消息类型：
  - `0` = 金色居中屏幕文字
  - `1` = 蓝色左侧文字
  - `2` = 绿色公会公告
  - `3` = 红色左侧文字
- `szMessage` (string): 消息文本

**返回：** 无

**描述：** 向玩家发送公告消息。

**用法：**
```lua
-- 发送给单个玩家（普通）
Message.Send(0, iPlayerIndex, 0, "你好玩家!")

-- 发送给所有玩家（金色）
Message.Send(0, -1, 1, "服务器将在 5 分钟后重启!")

-- 发送给单个玩家（蓝色）
Message.Send(0, iPlayerIndex, 2, "任务完成!")
```

---

## Timer 命名空间

计时器和 tick 函数。

### Timer.GetTick

```lua
Timer.GetTick()
```


**返回：** `ULONGLONG` - 系统启动后的毫秒数

**描述：** 返回系统启动后的毫秒数。用于冷却时间计算。

**用法：**
```lua
local currentTick = Timer.GetTick()

-- 检查是否已过 30 秒
if (currentTick - lastActionTick) >= 30000 then
    Log.Add("已过 30 秒")
end
```

---

## ActionTick 命名空间

玩家动作计时器/冷却管理。

### ActionTick.Get

```lua
ActionTick.Get(iPlayerIndex, iTimerIndex)
```


**参数：**
- `iPlayerIndex` (int): 玩家对象索引
- `iTimerIndex` (int): 计时器索引 (0-2)

**返回：** `ULONGLONG` - tick 计数值，如果无效则为 `0`

**描述：** 通过索引获取玩家动作计时器的 tick 计数值。

**用法：**
```lua
local lastTeleportTick = ActionTick.Get(iPlayerIndex, 0)

if (Timer.GetTick() - lastTeleportTick) >= 30000 then
    Log.Add("可以传送了")
end
```

---

### ActionTick.Set

```lua
ActionTick.Set(iPlayerIndex, iTimerIndex, tickValue, [timerName])
```


**参数：**
- `iPlayerIndex` (int): 玩家对象索引
- `iTimerIndex` (int): 计时器索引 (0-2)
- `tickValue` (ULONGLONG): 要设置的 tick 计数值
- `timerName` (string, 可选): 用于调试的计时器名称

**返回：** `bool` - 如果成功则为 `true`，否则为 `false`

**描述：** 通过索引设置玩家动作计时器的 tick 计数值。

**用法：**
```lua
-- 不带名称
ActionTick.Set(iPlayerIndex, 0, Timer.GetTick())

-- 带名称（用于调试）
ActionTick.Set(iPlayerIndex, 0, Timer.GetTick(), "Teleport")
ActionTick.Set(iPlayerIndex, 1, Timer.GetTick(), "Potion")
ActionTick.Set(iPlayerIndex, 2, Timer.GetTick(), "Buff")
```

---

### ActionTick.GetName

```lua
ActionTick.GetName(iPlayerIndex, iTimerIndex)
```


**参数：**
- `iPlayerIndex` (int): 玩家对象索引
- `iTimerIndex` (int): 计时器索引 (0-2)

**返回：** `string` - 计时器名称，如果未设置则为空字符串

**描述：** 通过索引获取玩家动作计时器的名称（用于调试）。

**用法：**
```lua
local tickName = ActionTick.GetName(iPlayerIndex, 0)
Log.Add(string.format("计时器 0: %s", tickName))
```

---

### ActionTick.Clear

```lua
ActionTick.Clear(iPlayerIndex, iTimerIndex)
```


**参数：**
- `iPlayerIndex` (int): 玩家对象索引
- `iTimerIndex` (int): 计时器索引 (0-2)

**返回：** `bool` - 如果成功则为 `true`，否则为 `false`

**描述：** 清除玩家动作计时器，将名称和 tick 值重置为 0。

**用法：**
```lua
-- 玩家断开连接时清除所有计时器
for i = 0, 2 do
    ActionTick.Clear(iPlayerIndex, i)
end
```

---

## Scheduler 命名空间

事件调度器系统函数。

### Scheduler.LoadFromXML

```lua
Scheduler.LoadFromXML(szXmlEventFileName)
```


**参数：**
- `szXmlEventFileName` (string): XML 事件文件名（不含路径/扩展名）

**返回：** `bool` - 如果成功则为 `true`，否则为 `false`

**描述：** 从 XML 文件加载事件配置。

**用法：**
```lua
Scheduler.LoadFromXML("Events")
```

---

### Scheduler.GetEventCount

```lua
Scheduler.GetEventCount()
```


**返回：** `int` - 已加载事件数量

**描述：** 返回调度器中已加载的事件数量。

**用法：**
```lua
local eventCount = Scheduler.GetEventCount()
Log.Add(string.format("已加载 %d 个事件", eventCount))
```

---

### Scheduler.CheckEventNotices

```lua
Scheduler.CheckEventNotices(currentTick)
```


**参数：**
- `currentTick` (ULONGLONG): 当前 tick 计数值

**返回：** 无

**描述：** 根据当前时间检查并触发事件公告。

**用法：**
```lua
Scheduler.CheckEventNotices(Timer.GetTick())
```

---

### Scheduler.CheckEventStarts

```lua
Scheduler.CheckEventStarts(currentTick)
```


**参数：**
- `currentTick` (ULONGLONG): 当前 tick 计数值

**返回：** 无

**描述：** 根据当前时间检查并触发事件开始。

**用法：**
```lua
Scheduler.CheckEventStarts(Timer.GetTick())
```

---

### Scheduler.CheckEventEnds

```lua
Scheduler.CheckEventEnds(currentTick)
```


**参数：**
- `currentTick` (ULONGLONG): 当前 tick 计数值

**返回：** 无

**描述：** 根据当前时间检查并触发事件结束。

**用法：**
```lua
Scheduler.CheckEventEnds(Timer.GetTick())
```

---

### Scheduler.GetEventName

```lua
Scheduler.GetEventName(iEventId)
```


**参数：**
- `iEventId` (int): 事件 ID

**返回：** `string` - 事件名称

**描述：** 通过事件 ID 返回事件名称。

**用法：**
```lua
local eventName = Scheduler.GetEventName(1)
Log.Add(string.format("事件: %s", eventName))
```

---

### Scheduler.HasSecondPrecisionEvents

```lua
Scheduler.HasSecondPrecisionEvents()
```


**返回：** `bool` - 如果任何事件使用秒级精度则为 `true`，否则为 `false`

**描述：** 返回是否有任何已加载事件使用秒级精度计时。

**用法：**
```lua
if Scheduler.HasSecondPrecisionEvents() then
    Log.Add("调度器需要秒级精度检查")
end
```

---

## Utility 命名空间

实用工具和辅助函数。

### Utility.GetRandomRangedInt

```lua
Utility.GetRandomRangedInt(min, max)
```


**参数：**
- `min` (int): 最小值（包含）
- `max` (int): 最大值（包含）

**返回：** `int` - min 和 max 之间的随机值（包含）

**描述：** 返回 min 和 max（包含）之间的随机整数值。

**用法：**
```lua
local randomNum = Utility.GetRandomRangedInt(0, 100)  -- 0-100
Log.Add(string.format("随机数: %d", randomNum))

-- 随机物品等级
local itemLevel = Utility.GetRandomRangedInt(0, 15)  -- 0-15
```

---

### Utility.GetLargeRand

```lua
Utility.GetLargeRand()
```


**返回：** `int` - 大随机数

**描述：** 返回一个大随机数。

**用法：**
```lua
local largeRand = Utility.GetLargeRand()
```

---

### Utility.FireCracker

```lua
Utility.FireCracker(iPlayerIndex)
```


**参数：**
- `iPlayerIndex` (int): 玩家对象索引

**返回：** 无

**描述：** 为指定玩家生成烟花视觉特效。

**用法：**
```lua
Utility.FireCracker(iPlayerIndex)
```

---

### Utility.SendEventTimer
```lua
Utility.SendEventTimer(playerIndex, milliseconds, countUp, displayType, deleteTimer)
```

> ⚠️ **s6 不可用** — 此函数在 s6 版本中不存在。

**参数：**
- `playerIndex` (int): 玩家对象索引
- `milliseconds` (int): 计时器持续时间（毫秒）（1000 = 1 秒）
- `countUp` (int): 计数方向 - `0` = 倒计时，`1` = 正计时
- `displayType` (int): 文本标签类型（见下表）
- `deleteTimer` (int): 到期前移除 - `0` = 正常显示计时器，`1` = 立即移除

**显示类型：**
| 值 | 显示文本 |
|-------|------------|
| `0` | 无文本 |
| `1` | "时间限制" |
| `2` | "剩余时间" |
| `3` | "狩猎时间" |
| `5` | "生存时间" |

**返回：** 无

**描述：** 向特定玩家屏幕直接发送可视倒计时或正计时。计时器归零时自动消失。仅当你需要在自然到期前移除计时器时使用 `deleteTimer = 1`。

**用法：**
```lua
-- 显示 60 秒倒计时，文本为"剩余时间"
Utility.SendEventTimer(oPlayer.Index, 60000, 0, 2, 0)
-- 玩家看到: "剩余时间: 01:00" 倒计时
-- 60 秒后自动消失

-- 显示 30 秒正计时，文本为"狩猎时间"
Utility.SendEventTimer(oPlayer.Index, 30000, 1, 3, 0)
-- 玩家看到: "狩猎时间: 00:00" 正计时到 00:30
-- 30 秒后自动消失

-- 在计时器到期前取消/移除
-- 重要: displayType 必须与创建时的计时器匹配!
Utility.SendEventTimer(oPlayer.Index, 0, 0, 2, 1)
-- 必须使用相同的 displayType (2) 与创建时
```

**示例：**
```lua
-- 显示 buff 持续时间（完成时自动移除）
function ShowBuffTimer(oPlayer, durationSeconds)
    local ms = durationSeconds * 1000
    Utility.SendEventTimer(oPlayer.Index, ms, 0, 2, 0)
    -- 持续时间秒后计时器自动消失
end

-- 提前取消 buff 计时器
function CancelBuffTimer(oPlayer)
    -- 必须使用与 ShowBuffTimer 中相同的 displayType (2)!
    Utility.SendEventTimer(oPlayer.Index, 0, 0, 2, 1)
    -- 在到期前立即移除计时器
end

-- 带取消的活动注册
local eventTimerType = 3  -- 存储类型以供后续移除

function ShowRegistrationTimer(oPlayer, durationSeconds)
    local ms = durationSeconds * 1000
    Utility.SendEventTimer(oPlayer.Index, ms, 1, eventTimerType, 0)
end

function CancelRegistration(oPlayer)
    -- 使用与 ShowRegistrationTimer 相同的类型
    Utility.SendEventTimer(oPlayer.Index, 0, 0, eventTimerType, 1)
end
```

**重要注意事项：**
- 这是**仅视觉**计时器 - 到期时不会触发回调
- 倒计时/正计时完成后计时器**自动消失**
- 计时器在客户端自动计数
- **关键：** 提前移除时（`deleteTimer = 1`），必须使用创建时的相同 `displayType`
- 要更新计时器，发送新的相同类型（替换之前的）

**常见错误：**
```lua
-- ❌ 错误 - displayType 不匹配!
Utility.SendEventTimer(oPlayer.Index, 60000, 0, 2, 0)  -- 用类型 2 创建
Utility.SendEventTimer(oPlayer.Index, 0, 0, 1, 1)      -- 尝试用类型 1 移除（无效!）

-- ✅ 正确 - displayType 匹配
Utility.SendEventTimer(oPlayer.Index, 60000, 0, 2, 0)  -- 用类型 2 创建
Utility.SendEventTimer(oPlayer.Index, 0, 0, 2, 1)      -- 用类型 2 移除（有效!）
```

**与 Timer.Create 的区别：**

| 功能 | Timer.Create | Utility.SendEventTimer |
|---------|--------------|------------------------|
| 视觉显示 | ✓ 是 | ✓ 是 |
| 到期时回调 | ✓ 是 | ✗ 否 |
| 到期时自动清理 | ✓ 是 | ✓ 是 |
| 命名计时器 | ✓ 是 | ✗ 否 |
| 同时多人 | ✓ 是 | ✗ 一次一个 |
| 控制函数 | ✓ 是（启动/停止/移除） | ✗ 仅手动 |
| 移除方式 | 按名称 | 按匹配类型 |

**何时使用：**
- 当你需要代码在时间到期时执行时使用 **Timer.Create**
- 当你需要纯视觉指示器且单独处理逻辑时使用 **Utility.SendEventTimer**

---

## Log 命名空间

服务器日志函数。

### Log.Add

```lua
Log.Add(szLog)
```


**参数：**
- `szLog` (string): 日志消息

**返回：** 无

**描述：** 向游戏服务器控制台添加日志消息（默认白色）。

**用法：**
```lua
Log.Add("服务器启动成功")
Log.Add(string.format("玩家 %s 已连接", playerName))
```

---

### Log.AddC

```lua
Log.AddC(dwLogColor, szLog)
```


**参数：**
- `dwLogColor` (DWORD): 日志颜色（使用 `Enums.LogColor` 或 `Helpers.RGB()`）
- `szLog` (string): 日志消息

**返回：** 无

**描述：** 向游戏服务器控制台添加彩色日志消息。

**用法：**
```lua
-- 使用预定义颜色
Log.AddC(Enums.LogColor.Red, "严重错误!")
Log.AddC(Enums.LogColor.Green, "活动已开始")
Log.AddC(Enums.LogColor.Yellow, "警告: 内存不足")

-- 使用自定义 RGB 颜色
Log.AddC(Helpers.RGB(255, 0, 255), "自定义洋红色消息")
```

---

## 另请参见

- [CALLBACKS](Callbacks.md) - 事件回调参考
- [Player-Structure](Player-Structure.md) - 玩家对象结构
- [Item-Structures](Item-Structures.md) - 物品结构
- [Database-Structures](Database-Structures.md) - 数据库查询结构
- `Defines/GlobalFunctions.lua` - IDE 类型提示
