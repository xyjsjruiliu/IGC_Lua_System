# MuLua 脚本参考

MU Online 服务器 Lua 脚本系统完整文档。

---

## ⚠️ 文档声明

**本文档和示例正在积极开发中。** 虽然我们努力保持准确性，但某些示例或文档可能包含错误。这些将根据报告定期修复。

如果你遇到任何问题或不准之处：
- 双重检查实际 API 行为
- 向开发团队报告问题
- 定期检查更新

---

## 快速开始

1. **Lua 脚本新手？** 从 [指南](https://www.lua.org/pil/1.html) 开始
2. **需要函数？** 查看 [Global-Functions](Global-Functions.md)
3. **处理玩家？** 从 [Player-Structure](Player-Structure.md) 开始
4. **处理物品？** 查看 [Item-Structures](Item-Structures.md)
5. **需要示例？** 浏览下面的示例部分

---

## 文档结构

### 结构体

暴露给 Lua 的游戏服务器对象 - 这些不能被实例化，只能通过函数访问：

- **[Player-Structure](Player-Structure.md)** - 主要玩家/角色对象 (stObject)
  - 玩家字段（Index、Level、Life、Mana 等）
  - userData 子结构（属性、货币、VIP、重置）
  - ActionTickCount 计时器（冷却系统）
  - 方法：`GetInventoryItem()`、`GetWarehouseItem()`

- **[Item-Structures](Item-Structures.md)** - 物品系统结构
  - ItemAttr（来自 ItemList.txt 的只读模板）
  - CreateItemInfo（创建新物品）
  - ItemInfo（实际物品实例）
  - BagItem（物品袋掉落模板）

- **[Database-Structures](Database-Structures.md)** - 数据库查询结果
  - QueryResultDS（DataServer 查询结果）
  - QueryResultJS（JoinServer 查询结果）
  - 查询响应的回调处理器

### 函数

- **[Global-Functions](Global-Functions.md)** - 完整 API 参考
  - 20 个命名空间中 85+ 个函数
  - Server、Player、Item、Inventory、Combat 等

- **[Callbacks](Callbacks.md)** - 事件回调
  - 游戏服务器事件（初始化、销毁、加入、离开）
  - 玩家事件（登录、登出、升级、死亡、重生）
  - 物品事件（使用、丢弃、捡取、装备、修理）
  - 战斗事件（攻击、击杀、死亡）
  - 数据库事件（查询结果）
  - 地图和移动事件
  - 商店和交易事件

### 代码组织

- **`Defines/Constants.lua`** - 游戏常量
  - 物品栏大小、装备槽位
  - 地图编号、传送门编号
  - 系统限制和边界

- **`Defines/Enums.lua`** - 枚举值
  - 角色职业、VIP 模式
  - 物品类别、抗性类型
  - 事件类型、消息类型

- **`Defines/Helpers.lua`** - 辅助函数
  - `RGB(r, g, b)` - 创建 DWORD 颜色值（Windows API 兼容）
  - `MakeItemId(type, index)` - 从类型和索引创建物品 ID
  - `GetItemType(id)` - 从物品 ID 提取物品类型
  - `GetItemIndex(id)` - 从物品 ID 提取物品索引

- **`Defines/Structs.lua`** - LuaDoc 结构体类型提示
  - IDE 自动完成支持（可选）
  - Player、Item、数据库结构的类型注解
  - 运行时不加载

- **`Defines/GlobalFunctions.lua`** - LuaDoc 函数类型提示
  - IDE 自动完成支持（可选）
  - 所有服务器函数的类型注解
  - 运行时不加载

---

## 常见任务

### 处理玩家

```lua
-- 获取玩家对象
local oPlayer = Player.GetObjByIndex(iPlayerIndex)
if oPlayer ~= nil then
    -- 访问玩家数据
    Log.Add(string.format("玩家: 等级 %d, HP: %.0f", oPlayer.Level, oPlayer.Life))
    
    -- 访问用户数据
    local money = oPlayer.userData.Money
    local resets = oPlayer.userData.Resets
end
```

**参见：** [Player-Structure](Player-Structure.md)

### 处理物品

```lua
-- 处理物品 ID
local itemId = Helpers.MakeItemId(14, 13)  -- 创建 7181（祝福宝石）
local itemType = Helpers.GetItemType(itemId)  -- 返回 14
local itemIndex = Helpers.GetItemIndex(itemId)  -- 返回 13

Log.Add(string.format("物品ID: %d, 类型: %d, 索引: %d", itemId, itemType, itemIndex))

-- 获取物品模板
local itemAttr = Item.GetAttr(itemId)
if itemAttr ~= nil then
	local itemName = itemAttr:GetName()
	Log.Add("物品: " .. itemName)
end

-- 创建新物品
local itemInfo = CreateItemInfo.new()
itemInfo.ItemId = Helpers.MakeItemId(0, 0)  -- 短剑（剑士）
itemInfo.ItemLevel = 9
itemInfo.Durability = 255
Item.Create(iPlayerIndex, itemInfo)

-- 从物品栏检查物品类型
local invItem = oPlayer:GetInventoryItem(12)  -- 物品栏槽位 12
if invItem ~= nil then
	local type = Helpers.GetItemType(invItem.ItemId)
	local index = Helpers.GetItemIndex(invItem.ItemId)
	Log.Add(string.format("物品栏 12 号槽位: 类型=%d, 索引=%d", type, index))
end
```

**参见：** [Item-Structures](Item-Structures.md)

### 冷却系统

```lua
-- 检查冷却
local oPlayer = Player.GetObjByIndex(iPlayerIndex)
local lastTick = oPlayer.ActionTickCount[1].tick

if (Timer.GetTick() - lastTick) >= 30000 then
    -- 已过 30 秒
    ActionTick.Set(iPlayerIndex, 0, Timer.GetTick(), "Teleport")
    -- 执行动作
else
    Message.Send(0, iPlayerIndex, 0, "冷却中")
end
```

**参见：** [Player-Structure](Player-Structure.md) 中的 ActionTickCount 结构部分

### 数据库查询

```lua
-- 执行查询
DB.QueryDS(iPlayerIndex, 1, string.format("SELECT Name, cLevel, Money FROM Character WHERE Name = '%s'", playerName))

-- 处理结果 - 重要: 所有值都作为字符串返回!
function DSDBQueryReceive(iPlayerIndex, iQueryNumber, bIsLastPacket, iCurrentRow, iColumnCount, iCurrentPacket, oRow)
	if iQueryNumber == 1 and oRow ~= nil then
		local columnName = oRow:GetColumnName()
		local valueStr = oRow:GetValue()  -- 始终是字符串!
		
		-- 将数值列转换为适当类型
		if columnName == "cLevel" or columnName == "Money" then
			local numValue = math.tointeger(valueStr)  -- 转换为整数
			Log.Add(string.format("%s = %d", columnName, numValue))
		else
			Log.Add(string.format("%s = %s", columnName, valueStr))  -- 字符串
		end
		
		if bIsLastPacket == 1 then
			Log.Add("查询完成")
		end
	end
end
```

**参见：** [Database-Structures](Database-Structures.md) 获取类型转换详情

### 遍历对象（高性能）

```lua
-- 遍历所有对象（玩家、怪物、物品）
Object.ForEach(function(oObject)
    if oObject.Type == Enums.ObjectType.MONSTER then
        Log.Add(string.format("怪物职业 %d", oObject.Class))
    end
    return true
end)

-- 遍历所有玩家（比 Lua 循环快 10-20 倍）
Object.ForEachPlayer(function(oPlayer)
    if oPlayer.Level >= 400 then
        Message.Send(0, oPlayer.Index, 1, "高级玩家奖励!")
    end
    return true  -- 继续（返回 false 可中断）
end)

-- 遍历特定地图上的玩家
Object.ForEachPlayerOnMap(0, function(oPlayer)  -- Lorencia
    Player.SetMoney(oPlayer.Index, 1000000, false)
    return true
end)

-- 遍历地图上的怪物
Object.ForEachMonsterOnMap(2, function(oMonster)  -- Devias
    oMonster.AddLife = oMonster.AddLife + 5000
    return true
end)

-- 查找特定怪物类型
Object.ForEachMonsterByClass(275, function(oMonster)  -- 黄金哥布林
    Log.Add(string.format("发现在地图 %d", oMonster.MapNumber))
    return false  -- 找到第一个后中断
end)

-- 队伍操作
Object.ForEachPartyMember(partyNumber, function(oMember)
    Message.Send(0, oMember.Index, 0, "队伍任务完成!")
    return true
end)

-- 公会操作
Object.ForEachGuildMember("TopGuild", function(oMember)
    Player.SetMoney(oMember.Index, 5000000, false)
    return true
end)

-- AOE 效果
Object.ForEachNearby(playerIndex, 10, function(oObject, distance)
    if oObject.Type == Enums.ObjectType.USER then
        Buff.Add(oObject, buffIndex, 0, 100, 0, 0, 60, 0, playerIndex)
    end
    return true
end)

-- 带可选筛选器的实用函数
local playerCount = Object.CountPlayersOnMap(0)  -- 所有玩家
local elitePlayers = Object.CountPlayersOnMap(0, function(oPlayer)
    return oPlayer.Level >= 400  -- 仅高级玩家
end)
local monsterCount = Object.CountMonstersOnMap(2)  -- 所有怪物
local bossCount = Object.CountMonstersOnMap(2, function(oMonster)
    return oMonster.Class >= 200  -- 仅 Boss
end)
local oTarget = Object.GetObjByName("PlayerName")  -- 快速查找
```

**参见：** [Global-Functions](Global-Functions.md) 中的 Object 命名空间部分

---

## API 组织

函数按命名空间组织以提高清晰度：

| 命名空间 | 函数数量 | 描述 |
|-----------|-----------|-------------|
| `Server` | 6 | 服务器信息（代码、名称、VIP 等级） |
| `Object` | 20 | 对象限制、高性能迭代器和实用函数 |
| `Player` | 9 | 玩家操作（获取、重算、重置） |
| `Combat` | 1 | 战斗信息 |
| `Stats` | 3 | 角色属性管理 |
| `Inventory` | 10 | 物品栏操作 |
| `Item` | 12 | 物品创建和属性 |
| `ItemBag` | 2 | 物品袋系统 |
| `Buff` | 5 | Buff 管理 |
| `Skill` | 2 | 技能使用 |
| `Viewport` | 2 | 视口创建/销毁 |
| `Move` | 3 | 传送和移动 |
| `Party` | 2 | 队伍信息 |
| `DB` | 2 | 数据库查询 |
| `Message` | 1 | 向玩家发送消息 |
| `Timer` | 1 | 获取当前 tick 计数值 |
| `ActionTick` | 4 | 冷却计时器管理 |
| `Scheduler` | 7 | 事件调度器系统 |
| `Utility` | 3 | 随机数、特效 |
| `Log` | 2 | 服务器日志 |

**参见：** [Global-Functions](Global-Functions.md)

---

## 文件结构

```
Scripts/
├── Defines/
│   ├── Helpers.lua          (辅助函数)
│   ├── Constants.lua        (游戏常量)
│   ├── Enums.lua           (枚举)
│   ├── Structs.lua         (结构体类型提示 - 可选)
│   └── GlobalFunctions.lua (函数类型提示 - 可选)
├── Includes/
│   └── EventScheduler.lua  (事件调度器系统)
├── Callbacks.lua           (事件处理器)
├── EventHandler.lua        (自定义事件处理器)
└── Main.lua               (入口点)
```

---

## 最佳实践

### 1. 始终检查 nil

```lua
local oPlayer = Player.GetObjByIndex(iPlayerIndex)
if oPlayer ~= nil then
    -- 安全访问玩家字段
end
```

### 2. 使用命名空间函数

```lua
-- ✅ 推荐（组织清晰）
Player.SetMoney(iPlayerIndex, 1000000)
Stats.Set(iPlayerIndex, Enums.StatType.STRENGTH, 1000)

```

### 3. 使用辅助函数

```lua
-- ✅ 正确
local itemId = Helpers.MakeItemId(0, 0)

-- ❌ 错误
local itemId = 0 * 512 + 0  -- 易出错
```

### 4. 理解索引差异

```lua
-- 玩家方法使用 0 基索引（C++ 风格）
local weapon = oPlayer:GetInventoryItem(0)

-- 数组方法使用 1 基索引（Lua 风格）
local socket = itemInfo:GetSocket(1)

-- ActionTickCount 数组使用 1 基索引
local tick = oPlayer.ActionTickCount[1].tick  -- 第一个计时器（C++ 索引 0）
```

### 5. 检查物品存在

```lua
local item = oPlayer:GetInventoryItem(slot)
if item ~= nil and item.IsItemExist then
    -- 安全使用物品
end
```

---

## 学习路径

### 初学者

1. 阅读 [Player-Structure](Player-Structure.md) 了解玩家对象
2. 查看 [Global-Functions](Global-Functions.md) 了解基本函数
3. 浏览结构文档中的示例
4. 查看 `Callbacks.lua` 了解事件模式

### 中级

1. 学习 [Item-Structures](Item-Structures.md) 了解物品系统
2. 学习 [Callbacks](Callbacks.md) 中的数据库查询
3. 使用 ActionTickCount 实现冷却系统
4. 创建自定义事件处理器

### 高级

1. 构建复杂的任务系统
2. 实现自定义掉落表
3. 创建定时事件
4. 开发高级战斗机制

---

## 性能提示

### 直接字段访问很快

```lua
-- ✅ 非常快 - 直接内存访问
local hp = oPlayer.Life
local level = oPlayer.Level
```

### 缓存常用值

```lua
-- ✅ 好 - 在循环中缓存
local Player.IsConnected = Player.IsConnected
for i = 0, 100 do
    if Player.IsConnected(i) then
        -- 处理玩家
    end
end

-- ❌ 较慢 - 每次迭代表查找
for i = 0, 100 do
    if Player.IsConnected(i) then
        -- 处理玩家
    end
end
```

### 在紧密循环中最小化函数调用

```lua
-- ✅ 更好 - 缓存玩家对象
local oPlayer = Player.GetObjByIndex(iPlayerIndex)
if oPlayer ~= nil then
    for i = 0, Constants.MAIN_INVENTORY_SIZE - 1 do
        local item = oPlayer:GetInventoryItem(i)
        if item ~= nil and item.IsItemExist then
            -- 使用缓存的玩家对象处理物品
            Log.Add(string.format("槽位 %d: %s", i, item.Type))
        end
    end
end

-- ❌ 较慢 - 重复函数调用
for i = 0, Constants.MAIN_INVENTORY_SIZE - 1 do
    local oPlayer = Player.GetObjByIndex(iPlayerIndex)  -- 调用 120 次!
    if oPlayer ~= nil then
        local item = oPlayer:GetInventoryItem(i)
        -- 处理物品
    end
end
```

---

## 其他资源

- **文档：** 本文档中的完整 API 参考
- **示例：** 示例目录中的实用示例
- **支持：** 联系开发团队获取帮助

---

## 贡献

添加新功能时：

1. 更新 `Reference/` 中的相关结构文档
2. 更新 `Reference/` 中的函数文档
3. 添加展示实用用法的示例
4. 添加主要功能时更新此自述文件
5. 保持 `Defines/Structs.lua` 类型提示同步
