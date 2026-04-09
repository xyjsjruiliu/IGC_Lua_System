# Lua 迭代器示例

完整示例集合，展示所有 12 个高性能迭代器与实用函数。

---

## ⚠️ 示例说明

**这些示例正在积极开发和测试中。** 尽管我们力求准确，但部分示例可能包含错误或过时的函数调用。这些问题将在定期审核中被修正。

如果你在使用示例时遇到问题：
- 请查阅主文档中的函数签名
- 先在开发环境中充分测试
- 向开发团队报告问题

---

## 📁 文件概览

### **核心示例**
| 文件 | 涵盖的函数 | 示例数量 | 描述 |
|------|-----------|---------|------|
| `IteratorExamples.lua` | 全部 9 个迭代器 | 50+ | 每个迭代器函数的完整示例 |
| `UtilityExamples.lua` | 计数与查找函数 | 30+ | 简单与带过滤的计数、玩家查找 |
| `FilterExamples.lua` | 带过滤的计数 | 40+ | 高级过滤技巧 |

### **使用场景示例**
| 文件 | 分类 | 示例数量 | 描述 |
|------|------|---------|------|
| `TimerExamples.lua` | 定时器函数 | 20+ | 每秒、每分钟、每小时定时器 |
| `EventExamples.lua` | 服务器事件 | 15+ | BOSS事件、入侵、血色城堡等 |
| `PvPExamples.lua` | PvP系统 | 20+ | 竞技场、自由混战、 guild战、决斗 |
| `AdminExamples.lua` | GM命令 | 25+ | 玩家管理、监控、批量操作 |
| `CombatExamples.lua` | 战斗机制 | 25+ | AOE伤害、增益、DOT、群体控制 |

---

## 🎯 快速参考

### 按迭代器函数

#### 1. **Object.ForEach** → `IteratorExamples.lua` (第10-120行)
- 统计所有对象类型
- 查找坐标处的对象
- 清理操作

#### 2. **Object.ForEachPlayer** → `IteratorExamples.lua` (第122-230行)
- 全服公告
- 在线奖励
- 服务器统计
- 自动保存系统

#### 3. **Object.ForEachPlayerOnMap** → `IteratorExamples.lua` (第232-340行)
- 地图传送
- 地图专属增益
- 区域奖励
- 地图人口统计

#### 4. **Object.ForEachMonster** → `IteratorExamples.lua` (第342-430行)
- 治疗所有怪物
- 杀死所有怪物
- 为怪物添加增益
- 寻找受伤怪物

#### 5. **Object.ForEachMonsterOnMap** → `IteratorExamples.lua` (第432-510行)
- 清除地图怪物
- 为地图怪物添加增益
- 生成控制
- 寻找BOSS

#### 6. **Object.ForEachMonsterByClass** → `IteratorExamples.lua` (第512-590行)
- 寻找黄金哥布林
- 公告BOSS刷新
- 杀死指定类型怪物
- 按类型添加增益

#### 7. **Object.ForEachPartyMember** → `IteratorExamples.lua` (第592-680行)
- 队伍奖励
- 队伍位置检查
- 队伍传送
- 队伍广播

#### 8. **Object.ForEachGuildMember** → `IteratorExamples.lua` (第682-780行)
- 战盟公告
- 战盟成就
- 战盟统计
- 战盟传送

#### 9. **Object.ForEachNearby** → `IteratorExamples.lua` (第782-880行)
- 范围治疗/伤害
- 寻找最近敌人
- 统计附近玩家数量
- 范围增益

#### 10. **Object.CountPlayersOnMap** → `UtilityExamples.lua` (第10-200行)
- 简单计数（所有玩家）
- 过滤计数（等级、VIP、职业等）
- 区域计数
- 复杂条件

#### 11. **Object.CountMonstersOnMap** → `UtilityExamples.lua` (第202-350行)
- 简单计数（所有怪物）
- BOSS计数
- 类型特定计数
- 区域计数

#### 12. **Object.GetObjByName** → `UtilityExamples.lua` (第352-450行)
- 按名称传送
- 在线检查
- 发送私信
- 按名称发放奖励

---

## 📚 按使用场景

### **服务器事件**
见：`EventExamples.lua`
- BOSS事件（准备、奖励）
- 入侵事件（波次、胜利/失败）
- 血色城堡
- 恶魔广场
- 攻城战
- 生存事件

### **PvP系统**
见：`PvPExamples.lua`
- 竞技场匹配与组队
- 自由混战（FFA）
- 战盟战
- 领土争夺
- 决斗系统

### **管理员/GM命令**
见：`AdminExamples.lua`
- 玩家管理（传送、踢出、封禁）
- 广播命令
- 批量操作
- 服务器监控
- 安全与反作弊

### **战斗机制**
见：`CombatExamples.lua`
- AOE伤害技能
- 增益与减益
- 持续伤害（DOT）
- 生命偷取
- 群体控制（恐惧、嘲讽、沉默）
- 召唤
- 横扫/顺劈攻击
- 环境伤害

### **定时器函数**
见：`TimerExamples.lua`
- 每秒（增益、活动监控）
- 每分钟（奖励、自动保存、人口统计）
- 每5分钟（生成控制、统计）
- 每小时（奖励、排名、清理）
- 事件驱动（攻城、BOSS、锦标赛）

### **过滤示例**
见：`FilterExamples.lua`
- 玩家过滤（等级、VIP、属性、位置）
- 怪物过滤（类型、HP、区域）
- 实际使用场景（事件资格、PvP平衡）

---

## 💡 使用方法

### 1. **找到你的使用场景**
浏览上面的表格或直接打开相关文件。

### 2. **复制函数**
每个函数都是独立的，可以直接使用：

```lua
-- 来自 IteratorExamples.lua
function SendGlobalAnnouncement(message, messageType)
    local count = 0
    
    Object.ForEachPlayer(function(oPlayer)
        Message.Send(0, oPlayer.Index, messageType or 0, message)
        count = count + 1
        return true
    end)
    
    Log.Add(string.format("已向 %d 名玩家发送公告", count))
end
```

### 3. **适配你的服务器**
修改参数、奖励或逻辑以适应你服务器的需求。

### 4. **测试**
始终先在开发环境中测试新函数！

---

## ⚠️ 重要说明

### **VIP 系统**
示例假设使用以下VIP等级系统：
```lua
-1 = 无VIP
 0 = 基础VIP（最低）
 1+ = 更高VIP等级
```

如果你的服务器使用不同系统，请调整比较逻辑:
- `>= 0` = 拥有任意VIP等级
- `> 0` = 拥有VIP等级1或更高
- `== -1` = 无VIP

详见：VIP_SYSTEM_NOTE.md

### **性能**
所有迭代器函数比手动Lua循环快10-100倍。适合用于：
- ✅ 处理大量对象的定时器函数
- ✅ 事件系统
- ✅ 批量操作
- ✅ 统计收集

避免用于:
- ❌ 单个玩家操作（改用 GetObjByName）
- ❌ 简单检查（改用不带过滤器的 CountPlayersOnMap）

### **回调返回值**
```lua
-- 继续迭代
return true

-- 提前中断迭代
return false

-- 同样表示继续（无返回值）
-- 只需省略 return 语句
```

---

## 🔧 常用模式

### **简单计数**
```lua
local count = Object.CountPlayersOnMap(0)
```

### **带过滤的计数**
```lua
local vipCount = Object.CountPlayersOnMap(0, function(oPlayer)
    return oPlayer.userData.VIPType >= 0
end)
```

### **查找并处理**
```lua
local oPlayer = Object.GetObjByName("PlayerName")
if oPlayer then
    Player.SetMoney(oPlayer.Index, 1000000, false)
end
```

### **迭代并处理**
```lua
Object.ForEachPlayer(function(oPlayer)
    if oPlayer.Level >= 400 then
        -- 处理高等级玩家
    end
    return true
end)
```

### **提前退出**
```lua
Object.ForEachMonster(function(oMonster)
    if oMonster.Class == 275 then
        Log.Add("找到黄金哥布林!")
        return false  -- 停止搜索
    end
    return true
end)
```

---

## 📖 示例索引

### **IteratorExamples.lua**
```
Object.ForEach
├── CountAllObjects()            -- 统计所有对象
├── FindObjectAtPosition()       -- 查找坐标处的对象
└── CleanupDisconnectedObjects() -- 清理已断开连接的对象

Object.ForEachPlayer
├── SendGlobalAnnouncement()     -- 发送全服公告
├── AwardOnlineBonus()           -- 发放在线奖励
├── CollectPlayerStats()         -- 收集玩家统计
├── FindRichestPlayer()          -- 寻找最富玩家
└── AutoSaveAllPlayers()         -- 自动保存所有玩家

Object.ForEachPlayerOnMap
├── TeleportAllFromMap()         -- 传送地图上所有玩家
├── ApplyMapBuff()               -- 施加地图增益
├── IsMapEmpty()                 -- 检查地图是否为空
├── AwardZoneBonus()             -- 发放区域奖励
└── GetMapDemographics()         -- 获取地图人口统计

Object.ForEachMonster
├── HealAllMonsters()            -- 治疗所有怪物
├── KillAllMonsters()            -- 杀死所有怪物
├── BuffAllMonsters()            -- 为所有怪物添加增益
├── FindWoundedMonsters()        -- 寻找受伤怪物
└── GetMonsterStats()            -- 获取怪物统计

Object.ForEachMonsterOnMap
├── ClearMapMonsters()           -- 清除地图怪物
├── BuffMapMonsters()            -- 为地图怪物添加增益
├── CheckMonsterDensity()        -- 检查怪物密度
└── FindBossOnMap()              -- 寻找地图上的BOSS

Object.ForEachMonsterByClass
├── FindGoldenGoblins()          -- 寻找黄金哥布林
├── AnnounceBossSpawn()          -- 公告BOSS刷新
├── KillMonsterType()            -- 杀死指定类型怪物
└── BuffMonsterType()            -- 为指定类型怪物添加增益

Object.ForEachPartyMember
├── AwardPartyBonus()            -- 发放队伍奖励
├── IsPartyTogether()            -- 检查队伍是否在一起
├── GetPartyAverageLevel()       -- 获取队伍平均等级
├── TeleportParty()              -- 传送队伍
└── PartyBroadcast()             -- 队伍广播

Object.ForEachGuildMember
├── GuildBroadcast()             -- 战盟广播
├── AwardGuildAchievement()      -- 发放战盟成就
├── GetOnlineGuildCount()        -- 获取在线战盟成员数
├── TeleportGuildToWar()         -- 传送战盟参战
└── GetGuildStats()              -- 获取战盟统计

Object.ForEachNearby
├── AOEHeal()                    -- 范围治疗
├── AOEDamage()                  -- 范围伤害
├── FindNearestEnemy()           -- 寻找最近敌人
├── CountPlayersInArea()         -- 统计区域内玩家数量
├── ApplyAreaBuff()              -- 施加区域增益
└── GetNearbyObjectsInfo()       -- 获取附近对象信息
```

### **UtilityExamples.lua**
```
CountPlayersOnMap (Simple)
├── CheckMapPopulation()         -- 检查地图人口
├── MonitorCrowdedMaps()         -- 监控拥挤地图
└── IsMapBalanced()              -- 判断地图是否平衡

CountPlayersOnMap (Filtered)
├── CountElitePlayersPerMap()    -- 统计各地图精英玩家数
├── CountVIPPlayersOnMap()       -- 统计地图VIP玩家数
├── CountPlayersByClassOnMap()   -- 按职业统计地图玩家数
├── CountRichPlayersOnMap()      -- 统计地图上富裕玩家数
├── CountVeteranPlayersOnMap()   -- 统计地图上老玩家数
├── CountPlayersInArea()         -- 统计区域内玩家数
├── CountSoloPlayersOnMap()      -- 统计地图上单人玩家数
├── CountPartiedPlayersOnMap()   -- 统计地图上组队玩家数
├── CountGuildPlayersOnMap()     -- 统计地图上战盟玩家数
└── CountLowHPPlayersOnMap()     -- 统计地图上低血量玩家数

CountMonstersOnMap (Simple)
├── CheckMapRespawn()            -- 检查地图刷新
├── MonitorMonsterDensity()      -- 监控怪物密度
└── IsMapClear()                 -- 判断地图是否清空

CountMonstersOnMap (Filtered)
├── CountBossesOnMap()           -- 统计地图BOSS数量
├── CountMonsterTypeOnMap()      -- 统计地图上指定类型怪物数量
├── CountWoundedMonstersOnMap()  -- 统计地图上受伤怪物数量
├── CountTankMonstersOnMap()     -- 统计地图上肉盾怪物数量
├── CountMonstersInArea()        -- 统计区域内怪物数量
└── CountEliteMonstersOnMap()    -- 统计地图上精英怪物数量

GetObjByName
├── TeleportPlayerByName()       -- 按名称传送玩家
├── IsPlayerOnline()             -- 检查玩家是否在线
├── SendPrivateMessage()         -- 发送私信
├── GetPlayerInfo()              -- 获取玩家信息
├── AwardPlayerByName()          -- 按名称发放奖励
└── KickPlayerByName()           -- 按名称踢出玩家

Combined Usage
├── CheckEventEligibility()      -- 检查事件资格
├── CheckPvPBalance()            -- 检查PvP平衡
├── CalculateDynamicDifficulty() -- 计算动态难度
├── AutoSpawnControl()           -- 自动生成控制
├── CheckGuildWarReady()         -- 检查战盟战就绪状态
├── InvitePlayersToParty()       -- 邀请玩家入队
└── AwardTopPlayers()            -- 奖励顶尖玩家
```

---

## 🎓 学习路径

1. **从简单示例开始** → `UtilityExamples.lua`
2. **学习迭代器** → `IteratorExamples.lua`
3. **探索过滤器** → `FilterExamples.lua`
4. **添加定时器** → `TimerExamples.lua`
5. **构建事件** → `EventExamples.lua`
6. **创建PvP** → `PvPExamples.lua`
7. **管理工具** → `AdminExamples.lua`
8. **战斗系统** → `CombatExamples.lua`

---

## 📝 贡献

添加新示例时:
1. 使用清晰、描述性的函数名
2. 添加注释解释逻辑
3. 放入合适的文件
4. 更新本README

---

## ❓ 支持

- 查阅主文档: `../Reference/GLOBAL_FUNCTIONS.md`
- C++ 实现: `../ObjectIterators_CPP_Implementation.cpp`
- 变更日志: `../ITERATOR_UPDATE.md`
- VIP说明: `../VIP_SYSTEM_NOTE.md`

---

**总示例数: 200+**  
**覆盖函数: 12/12**  
**全部可直接复制粘贴使用!** ✅
