# EventMonsterTracker

用于追踪和管理自定义活动生成的怪物/NPC 的系统。

## 目录

- [概览](#概览)
- [数据结构](#数据结构)
- [API 参考](#api-参考)
  - [注册函数](#注册函数)
  - [查询函数](#查询函数)
  - [清理函数](#清理函数)
  - [实用函数](#实用函数)
  - [生成函数](#生成函数)
- [使用示例](#使用示例)
- [最佳实践](#最佳实践)
- [注意事项](#注意事项)

---

## 概览

EventMonsterTracker 提供活动生成对象的集中管理，按事件类型追踪怪物和 NPC，便于清理和监控。

**主要功能：**
- 按类型 ID 组织事件
- 分离追踪怪物和 NPC
- 带验证的安全清理
- 批量生成操作
- 查询活动事件和对象计数

---

## 数据结构

### TrackedObjectData

```lua
---@class TrackedObjectData
---@field class integer  -- 怪物/NPC 职业 ID
---@field type integer   -- 对象类型 (2=MONSTER, 3=NPC)
```

查询追踪对象信息时由 `GetObjectInfo()` 返回。

---

## API 参考

### 注册函数

#### EventMonsterTracker.Register

将对象注册到事件追踪。

```lua
EventMonsterTracker.Register(iEventType, iObjectIndex, iObjectClass, iObjectType)
```

**参数：**
- `iEventType` (integer) - 事件类型 ID
- `iObjectIndex` (integer) - 对象索引
- `iObjectClass` (integer) - 怪物/NPC 职业 ID
- `iObjectType` (integer) - 对象类型 (Enums.ObjectType: 2=MONSTER, 3=NPC)

**返回：** 无

**示例：**
```lua
local monsterIndex = Object.AddMonster(14, 0, 100, 100, 110, 110, 0)
EventMonsterTracker.Register(1, monsterIndex, 14, Enums.ObjectType.MONSTER)
```

---

#### EventMonsterTracker.Unregister

从事件追踪取消注册对象（不删除对象）。

```lua
local success = EventMonsterTracker.Unregister(iEventType, iObjectIndex)
```

**参数：**
- `iEventType` (integer) - 事件类型 ID
- `iObjectIndex` (integer) - 对象索引

**返回：** `boolean` - 如果取消注册成功为真，未找到为假

**示例：**
```lua
if EventMonsterTracker.Unregister(1, monsterIndex) then
	print("怪物已从事件取消注册")
end
```

---

#### EventMonsterTracker.IsTracked

检查对象是否被事件追踪。

```lua
local tracked = EventMonsterTracker.IsTracked(iEventType, iObjectIndex)
```

**参数：**
- `iEventType` (integer) - 事件类型 ID
- `iObjectIndex` (integer) - 对象索引

**返回：** `boolean` - 如果被追踪为真

**示例：**
```lua
if EventMonsterTracker.IsTracked(1, monsterIndex) then
	print("怪物正被事件 1 追踪")
end
```

---

### 查询函数

#### EventMonsterTracker.GetObjectInfo

获取存储的对象信息。

```lua
local info = EventMonsterTracker.GetObjectInfo(iEventType, iObjectIndex)
```

**参数：**
- `iEventType` (integer) - 事件类型 ID
- `iObjectIndex` (integer) - 对象索引

**返回：** `TrackedObjectData` - 对象数据（未找到时 class=-1, type=-1）

**示例：**
```lua
local info = EventMonsterTracker.GetObjectInfo(1, monsterIndex)
if info.class ~= -1 then
	print("怪物职业: " .. info.class)
	print("对象类型: " .. info.type)
end
```

---

#### EventMonsterTracker.GetMonsterClass

获取存储的对象职业 ID。

```lua
local class = EventMonsterTracker.GetMonsterClass(iEventType, iObjectIndex)
```

**参数：**
- `iEventType` (integer) - 事件类型 ID
- `iObjectIndex` (integer) - 对象索引

**返回：** `integer` - 怪物/NPC 职业 ID，未找到返回 -1

**示例：**
```lua
local monsterClass = EventMonsterTracker.GetMonsterClass(1, monsterIndex)
if monsterClass == 14 then
	print("这是哥布林")
end
```

---

#### EventMonsterTracker.GetMonsters

获取事件所有追踪对象索引。

```lua
local indices = EventMonsterTracker.GetMonsters(iEventType, iFilterType)
```

**参数：**
- `iEventType` (integer) - 事件类型 ID
- `iFilterType` (integer, 可选) - 筛选: -1=全部（默认）, 2=MONSTER, 3=NPC

**返回：** `table` - 对象索引数组

**示例：**
```lua
-- 获取事件的所有怪物
local monsters = EventMonsterTracker.GetMonsters(1, Enums.ObjectType.MONSTER)
for i, monsterIndex in ipairs(monsters) do
	local oMonster = Player.GetObjByIndex(monsterIndex)
	if oMonster ~= nil then
		print("怪物 " .. i .. " HP: " .. oMonster.Life)
	end
end

-- 获取所有对象（怪物和 NPC）
local allObjects = EventMonsterTracker.GetMonsters(1)
print("对象总数: " .. #allObjects)
```

---

#### EventMonsterTracker.GetCount

获取追踪对象计数。

```lua
local count = EventMonsterTracker.GetCount(iEventType, iFilterType)
```

**参数：**
- `iEventType` (integer) - 事件类型 ID
- `iFilterType` (integer, 可选) - 筛选: -1=全部（默认）, 2=MONSTER, 3=NPC

**返回：** `integer` - 追踪对象数量

**示例：**
```lua
local monsterCount = EventMonsterTracker.GetCount(1, Enums.ObjectType.MONSTER)
local npcCount = EventMonsterTracker.GetCount(1, Enums.ObjectType.NPC)
print("事件 1 有 " .. monsterCount .. " 只怪物和 " .. npcCount .. " 个 NPC")
```

---

### 清理函数

#### EventMonsterTracker.CleanupEvent

清理事件对象（删除并取消追踪）。删除前执行安全验证。

```lua
local removed = EventMonsterTracker.CleanupEvent(iEventType, iFilterType)
```

**参数：**
- `iEventType` (integer) - 事件类型 ID
- `iFilterType` (integer, 可选) - 筛选: -1=全部（默认）, 2=MONSTER, 3=NPC

**返回：** `integer` - 移除的对象数量

**示例：**
```lua
-- 清理所有事件对象
local removed = EventMonsterTracker.CleanupEvent(1)
print("从事件 1 移除了 " .. removed .. " 个对象")

-- 仅清理怪物
local monstersRemoved = EventMonsterTracker.CleanupEvent(1, Enums.ObjectType.MONSTER)
```

---

#### EventMonsterTracker.CleanupMonsters

仅清理事件的怪物。

```lua
local removed = EventMonsterTracker.CleanupMonsters(iEventType)
```

**参数：**
- `iEventType` (integer) - 事件类型 ID

**返回：** `integer` - 移除的怪物数量

**示例：**
```lua
local removed = EventMonsterTracker.CleanupMonsters(1)
print("移除了 " .. removed .. " 只怪物")
```

---

#### EventMonsterTracker.CleanupNPCs

仅清理事件的 NPC。

```lua
local removed = EventMonsterTracker.CleanupNPCs(iEventType)
```

**参数：**
- `iEventType` (integer) - 事件类型 ID

**返回：** `integer` - 移除的 NPC 数量

**示例：**
```lua
local removed = EventMonsterTracker.CleanupNPCs(1)
print("移除了 " .. removed .. " 个 NPC")
```

---

#### EventMonsterTracker.CleanupDead

从追踪中清理死亡对象（不游戏中删除它们）。

在以下情况下从追踪中移除对象：
- 对象不再存在
- 对象类型/职业改变
- 对象 Life == 0

```lua
local removed = EventMonsterTracker.CleanupDead(iEventType, iFilterType)
```

**参数：**
- `iEventType` (integer) - 事件类型 ID
- `iFilterType` (integer, 可选) - 筛选: -1=全部（默认）, 2=MONSTER, 3=NPC

**返回：** `integer` - 从追踪中移除的对象数量

**示例：**
```lua
-- 从追踪中清理死亡怪物
local cleaned = EventMonsterTracker.CleanupDead(1, Enums.ObjectType.MONSTER)
print("从追踪中清理了 " .. cleaned .. " 只死亡怪物")
```

---

### 实用函数

#### EventMonsterTracker.GetActiveEvents

获取有追踪对象的活动事件类型。

```lua
local eventTypes = EventMonsterTracker.GetActiveEvents()
```

**返回：** `table` - 事件类型 ID 数组

**示例：**
```lua
local activeEvents = EventMonsterTracker.GetActiveEvents()
for i, eventType in ipairs(activeEvents) do
	local count = EventMonsterTracker.GetCount(eventType)
	print("事件 " .. eventType .. " 有 " .. count .. " 个追踪对象")
end
```

---

#### EventMonsterTracker.ClearAll

清除所有追踪数据（不删除对象）。

```lua
local eventsCleared = EventMonsterTracker.ClearAll()
```

**返回：** `integer` - 清除的事件数量

**示例：**
```lua
local cleared = EventMonsterTracker.ClearAll()
print("清除了 " .. cleared .. " 个事件的追踪")
```

---

### 生成函数

#### EventMonsterTracker.SpawnAndRegister

生成单个怪物并注册到追踪。

```lua
local monsterIndex = EventMonsterTracker.SpawnAndRegister(
	iEventType, iMonsterClass, iMapNumber, iX1, iY1, iX2, iY2, iElement
)
```

**参数：**
- `iEventType` (integer) - 事件类型 ID
- `iMonsterClass` (integer) - 怪物职业 ID
- `iMapNumber` (integer) - 地图编号
- `iX1` (integer) - 生成区域起始 X
- `iY1` (integer) - 生成区域起始 Y
- `iX2` (integer) - 生成区域结束 X
- `iY2` (integer) - 生成区域结束 Y
- `iElement` (integer) - 元素属性（0=无）

**返回：** `integer` - 怪物对象索引，失败返回 -1

**示例：**
```lua
local monsterIndex = EventMonsterTracker.SpawnAndRegister(
	1, 14, 0, 100, 100, 110, 110, 0
)
if monsterIndex ~= -1 then
	print("生成的怪物索引: " .. monsterIndex)
end
```

---

#### EventMonsterTracker.SpawnWaveAndRegister

生成一波怪物并全部注册到追踪。

```lua
local monsters = EventMonsterTracker.SpawnWaveAndRegister(
	iEventType, iMonsterClass, iCount, iMapNumber, iX1, iY1, iX2, iY2, iElement
)
```

**参数：**
- `iEventType` (integer) - 事件类型 ID
- `iMonsterClass` (integer) - 怪物职业 ID
- `iCount` (integer) - 要生成的怪物数量
- `iMapNumber` (integer) - 地图编号
- `iX1` (integer) - 生成区域起始 X
- `iY1` (integer) - 生成区域起始 Y
- `iX2` (integer) - 生成区域结束 X
- `iY2` (integer) - 生成区域结束 Y
- `iElement` (integer) - 元素属性（0=无）

**返回：** `table` - 生成的怪物索引数组

**示例：**
```lua
local monsters = EventMonsterTracker.SpawnWaveAndRegister(
	1, 14, 10, 0, 100, 100, 150, 150, 0
)
print("生成了 " .. #monsters .. " 只怪物")
```

---

#### EventMonsterTracker.RegisterNPC

将现有 NPC 注册到追踪。

```lua
EventMonsterTracker.RegisterNPC(iEventType, iNpcIndex, iNpcClass)
```

**参数：**
- `iEventType` (integer) - 事件类型 ID
- `iNpcIndex` (integer) - NPC 对象索引
- `iNpcClass` (integer) - NPC 职业 ID

**返回：** 无

**示例：**
```lua
local npcIndex = Object.AddNPC(229, 0, 125, 125, Enums.NPCType.SHOP)
if npcIndex ~= -1 then
	EventMonsterTracker.RegisterNPC(1, npcIndex, 229)
	print("NPC 已注册到事件追踪")
end
```

---

## 使用示例

### 生成怪物
```lua
local monsters = EventMonsterTracker.SpawnWaveAndRegister(
	1, 14, 10, 0, 100, 100, 150, 150, 0
)
print("生成了 " .. #monsters .. " 只怪物")
```

### 检查状态
```lua
local count = EventMonsterTracker.GetCount(1, Enums.ObjectType.MONSTER)
print("事件 1 有 " .. count .. " 只存活怪物")
```

### 清理死亡对象
```lua
local cleaned = EventMonsterTracker.CleanupDead(1, Enums.ObjectType.MONSTER)
print("从追踪中清理了 " .. cleaned .. " 只死亡怪物")
```

### 结束事件
```lua
local removed = EventMonsterTracker.CleanupMonsters(1)
print("事件结束。移除了 " .. removed .. " 只怪物")
```

---

## 最佳实践

1. **使用唯一事件类型 ID** - 避免冲突（例如，自定义事件使用 100-199）
2. **事件结束时始终清理** - 使用 `CleanupEvent()` 移除所有对象
3. **定期清理死亡对象** - 调用 `CleanupDead()` 保持追踪准确
4. **类型筛选** - 使用 `Enums.ObjectType.MONSTER` 或 `Enums.ObjectType.NPC` 而不是魔法数字
5. **检查生成结果** - 始终验证 `SpawnAndRegister()` 是否返回 -1（失败）
6. **批量生成** - 使用 `SpawnWaveAndRegister()` 而不是多次调用 `SpawnAndRegister()`

---

## 注意事项

- 追踪对象持续存在直到明确清理或服务器重启
- `CleanupEvent()` 删除前执行安全验证
- `CleanupDead()` 仅从追踪中移除，不删除对象
- 支持最多 200 个事件类型（0-199）
