# IGC Lua System

> **版本号：21.1.2.10S** | **IGC-Network (R) © 2010-2026** | [www.igcn.mu](https://www.igcn.mu)

IGC Lua System 是 [IGCN MuOnline 游戏服务器](https://www.igcn.mu) 的 Lua 脚本扩展系统，允许服主和开发者通过 Lua 脚本自定义游戏逻辑、事件系统、玩家交互、战斗机制等核心功能，无需修改 C++ 源码。

---

## 📑 目录

- [项目概述](#-项目概述)
- [目录结构](#-目录结构)
- [快速开始](#-快速开始)
- [核心架构](#-核心架构)
  - [入口与加载顺序](#入口与加载顺序)
  - [事件回调系统](#事件回调系统)
  - [定时器系统](#定时器系统)
  - [事件调度器](#事件调度器)
- [API 命名空间参考](#-api-命名空间参考)
  - [Server — 服务器信息](#server--服务器信息)
  - [Object — 对象迭代与查询](#object--对象迭代与查询)
  - [Player — 玩家操作](#player--玩家操作)
  - [Combat — 战斗信息](#combat--战斗信息)
  - [Stats — 属性管理](#stats--属性管理)
  - [Inventory — 背包操作](#inventory--背包操作)
  - [Item — 物品系统](#item--物品系统)
  - [Monster — 怪物属性](#monster--怪物属性)
  - [ItemBag — 物品包系统](#itembag--物品包系统)
  - [Buff — 增益/减益系统](#buff--增益减益系统)
  - [Skill — 技能系统](#skill--技能系统)
  - [Viewport — 视野管理](#viewport--视野管理)
  - [Move — 移动/传送](#move--移动传送)
  - [Party — 组队](#party--组队)
  - [DB — 数据库查询](#db--数据库查询)
  - [Message — 消息发送](#message--消息发送)
  - [Timer — 定时器](#timer--定时器)
  - [ActionTick — 冷却计时器](#actiontick--冷却计时器)
  - [Scheduler — 事件调度](#scheduler--事件调度)
  - [Utility — 工具函数](#utility--工具函数)
  - [Log — 日志系统](#log--日志系统)
  - [Helpers — 辅助工具](#helpers--辅助工具)
  - [Language — 多语言系统](#language--多语言系统)
  - [EventMonsterTracker — 事件怪物追踪](#eventmonstertracker--事件怪物追踪)
- [数据结构](#-数据结构)
  - [玩家对象 (stObject)](#玩家对象-stobject)
  - [物品结构](#物品结构)
  - [枚举常量](#枚举常量-enums)
- [事件回调完整列表](#-事件回调完整列表)
- [定时器辅助库](#-定时器辅助库-timerhelpers)
- [定时器管理器](#-定时器管理器-timermanager)
- [事件调度器配置 (XML)](#-事件调度器配置-xml)
- [示例代码](#-示例代码)
- [最佳实践](#-最佳实践)
- [编码规范](#-编码规范)
- [版本兼容性说明](#-版本兼容性说明)
- [许可证](#-许可证)

---

## 📖 项目概述

IGC Lua System 通过 Lua 脚本引擎将 MU Online 服务器的核心功能暴露给脚本层，提供了：

- **30+ 事件回调** — 覆盖玩家登录/登出、物品操作、战斗、交易、NPC 对话等游戏核心事件
- **20 个 API 命名空间** — 包含 85+ 个函数，涵盖服务器管理、玩家操作、物品/背包、增益/减益、技能、传送、组队、数据库查询等
- **高性能对象迭代器** — C++ 实现的迭代器比手动 Lua 循环快 10-100 倍
- **灵活的定时器系统** — 支持一次性、重复、N 次定时器，以及防抖/节流等高级模式
- **事件调度系统** — 通过 XML 配置计划事件，自动管理预告、开始、结束全生命周期
- **怪物追踪系统** — 为自定义事件提供怪物生成、追踪、清理的一体化方案
- **完整的类型提示** — 提供 LuaDoc 注解，支持 IDE 自动补全

---

## 📁 目录结构

```
IGC_Lua_System/
├── README.md                          ← 本文件
├── LuaAPI/                            ← 核心 Lua 脚本目录（部署到服务器）
│   ├── Main.lua                       ← 脚本入口点，加载所有模块
│   ├── EventHandler.lua               ← 自定义事件处理器（分发表模式）
│   ├── Callbacks.lua                  ← 服务器事件回调函数定义
│   ├── Timers.lua                     ← 定时器回调入口
│   ├── Config/
│   │   └── EventScheduler.xml         ← 事件调度器 XML 配置文件
│   ├── Defines/
│   │   ├── Helpers.lua                ← 辅助工具函数（RGB、物品ID计算）
│   │   ├── Constants.lua              ← 全局常量（背包大小、装备槽位等）
│   │   ├── Enums.lua                  ← 枚举值（职业、地图、Buff、物品类别等）
│   │   ├── Structs.lua               ← C++ 对象的 LuaDoc 类型提示
│   │   └── GlobalFunctions.lua        ← 全局函数的 LuaDoc 类型提示
│   └── Includes/
│       ├── EventScheduler.lua         ← 事件调度逻辑引擎
│       ├── TimerHelpers.lua           ← 定时器辅助函数库
│       └── TimerManager.lua           ← 命名定时器存储管理器
├── Examples/                          ← 实用示例代码集合
│   ├── README.md                      ← 示例索引与说明
│   ├── IteratorExamples.lua           ← 9 种迭代器完整示例（50+ 函数）
│   ├── UtilityExamples.lua            ← 计数与查找函数示例（30+ 函数）
│   ├── FilterExamples.lua             ← 高级过滤技巧示例
│   ├── TimerExamples.lua              ← 定时器函数示例
│   ├── EventExamples.lua              ← 服务器事件示例（BOSS、入侵等）
│   ├── PvPExamples.lua                ← PvP 系统示例
│   ├── AdminExamples.lua              ← GM 管理命令示例
│   ├── CombatExamples.lua             ← 战斗机制示例
│   ├── BuffExamples.lua               ← Buff/Debuff 系统示例
│   ├── ExperienceExamples.lua         ← 经验系统示例
│   └── GuildExamples.lua              ← 战盟系统示例
└── Wiki/                              ← 详细 Wiki 文档
    ├── Configs.wiki/                  ← 稳定版文档
    └── Configs-Preview.wiki/          ← 预览版文档（最新）
```

---

## 🚀 快速开始

### 1. 安装

将 `LuaAPI/` 目录复制到游戏服务器的 `Plugins/LuaAPI/` 路径下。目录结构应保持：

```
Server/
└── Plugins/
    └── LuaAPI/
        ├── Main.lua
        ├── EventHandler.lua
        ├── Callbacks.lua
        ├── Timers.lua
        ├── Config/
        │   └── EventScheduler.xml
        ├── Defines/
        │   ├── Helpers.lua
        │   ├── Constants.lua
        │   ├── Enums.lua
        │   ├── Structs.lua
        │   └── GlobalFunctions.lua
        └── Includes/
            ├── EventScheduler.lua
            ├── TimerHelpers.lua
            └── TimerManager.lua
```

### 2. 编码注意

> ⚠️ **源文件格式为 UTF-8，因包含中文注释。实际使用时需要将文件编码转换为 ASCII 格式！**

### 3. 基本使用

编辑 `Callbacks.lua` 中的回调函数来实现你的自定义逻辑：

```lua
-- 玩家登录时发送欢迎消息
function onPlayerLogin(oPlayer)
    if oPlayer ~= nil then
        Message.Send(0, oPlayer.Index, 1, "欢迎回到 MU Online！")
        Log.Add(string.format("玩家 %s 已登录", oPlayer.Name))
    end
end

-- 怪物击杀奖励
function onMonsterKill(oPlayer, oTarget)
    if oPlayer ~= nil and oTarget ~= nil then
        if oTarget.Class == 275 then  -- 黄金哥布林
            Player.SetMoney(oPlayer.Index, 1000000, false)
            Message.Send(0, oPlayer.Index, 1, "黄金哥布林奖励：1,000,000 金币！")
        end
    end
end
```

### 4. 添加自定义事件

编辑 `EventHandler.lua` 添加事件处理器：

```lua
-- 在 startHandlers 表中添加
startHandlers[Enums.EventType.SAMPLE_EVENT_1] = function()
    Message.Send(0, -1, 1, "双倍经验活动已开始！")
    Log.Add("[双倍经验] 活动开始")
end
```

编辑 `Config/EventScheduler.xml` 配置事件时间：

```xml
<Event Type="0" Name="双倍经验" NoticePeriod="300" Duration="3600">
    <Start Hour="20" Minute="0" Second="0" />
</Event>
```

---

## 🏗️ 核心架构

### 入口与加载顺序

`Main.lua` 是脚本入口点，按以下顺序加载所有依赖：

```lua
LoadScript(BASE .. "Defines\\Helpers.lua")        -- 1. 辅助函数（其他模块依赖）
LoadScript(BASE .. "Defines\\Constants.lua")       -- 2. 常量定义
LoadScript(BASE .. "Defines\\Enums.lua")           -- 3. 枚举定义
LoadScript(BASE .. "EventHandler.lua")             -- 4. 事件处理器
LoadScript(BASE .. "Callbacks.lua")               -- 5. 事件回调
LoadScript(BASE .. "Includes\\TimerHelpers.lua")  -- 6. 定时器辅助
LoadScript(BASE .. "Includes\\EventScheduler.lua")-- 7. 事件调度器
LoadScript(BASE .. "Timers.lua")                  -- 8. 定时器回调
EventScheduler.Initialize()                        -- 9. 初始化调度器
```

> **注意**：`Structs.lua` 和 `GlobalFunctions.lua` 仅用于 IDE 自动补全，不在运行时加载。

### 事件回调系统

回调分为两类：

| 类型 | 说明 | 能否阻止操作 |
|------|------|------------|
| **同步 (Sync)** | 在 C++ 事件流中同步执行 | ✅ 可以返回非零值阻止 |
| **异步 (Async)** | 在事件之后异步执行 | ❌ 不能阻止 |

### 定时器系统

`Timers.lua` 定义了三个定时器入口：

```lua
function onTimerProcessSecond()  -- 每秒调用
function onTimerProcessMinute()   -- 每分钟调用
function onTimerProcessDayChange() -- 每天0点调用
```

### 事件调度器

`EventScheduler` 管理事件的生命周期：
- **预告通知** — 事件开始前的警告
- **事件开始** — 事件激活
- **事件结束** — 持续时间结束后

自动优化：如果所有事件的 `Second == -1`，调度器将降频为每分钟检查一次。

---

## 📡 API 命名空间参考

### Server — 服务器信息

| 函数 | 返回值 | 说明 |
|------|--------|------|
| `Server.GetCode()` | `integer` | 服务器代码标识 |
| `Server.GetName()` | `string` | 服务器显示名称 |
| `Server.GetVIPLevel()` | `integer` | VIP等级（-1=未设置） |
| `Server.IsNonPvP()` | `boolean` | PvP是否被禁用 |
| `Server.Is28Option()` | `boolean` | +28选项是否启用 |
| `Server.GetClassPointsPerLevel(class)` | `integer` | 指定职业每级属性点 |

### Object — 对象迭代与查询

**高性能迭代器**（比手动 Lua 循环快 10-100 倍）：

| 函数 | 说明 |
|------|------|
| `Object.ForEach(callback)` | 遍历所有对象 |
| `Object.ForEachPlayer(callback)` | 遍历所有在线玩家 |
| `Object.ForEachPlayerOnMap(mapNumber, callback)` | 遍历指定地图玩家 |
| `Object.ForEachMonster(callback)` | 遍历所有存活怪物 |
| `Object.ForEachMonsterOnMap(mapNumber, callback)` | 遍历指定地图怪物 |
| `Object.ForEachMonsterByClass(monsterClass, callback)` | 遍历指定类型怪物 |
| `Object.ForEachPartyMember(partyNumber, callback)` | 遍历队伍成员 |
| `Object.ForEachGuildMember(guildName, callback)` | 遍历战盟成员 |
| `Object.ForEachNearby(centerIndex, range, callback)` | 遍历范围内对象 |

**实用函数**：

| 函数 | 返回值 | 说明 |
|------|--------|------|
| `Object.CountPlayersOnMap(mapNumber, filter?)` | `integer` | 统计地图玩家数（可过滤） |
| `Object.CountMonstersOnMap(mapNumber, filter?)` | `integer` | 统计地图怪物数（可过滤） |
| `Object.GetObjByName(playerName)` | `object\|nil` | 按名称查找玩家 |
| `Object.AddMonster(class, map, x1, y1, x2, y2, element)` | `integer` | 生成怪物 |
| `Object.DelMonster(index)` | `integer` | 删除怪物 |
| `Object.AddNPC(class, map, x, y, npcType)` | `integer` | 添加NPC |

**回调返回值**：`return true` 继续迭代，`return false` 中断迭代。

### Player — 玩家操作

| 函数 | 说明 |
|------|------|
| `Player.IsConnected(index)` | 检查玩家是否在线 |
| `Player.GetObjByIndex(index)` | 按索引获取玩家对象 |
| `Player.GetObjByName(name)` | 按名称获取玩家对象 |
| `Player.GetIndexByName(name)` | 按名称获取玩家索引 |
| `Player.SetMoney(index, amount, reset)` | 设置金币 |
| `Player.SetRuud(index, base, obtained, show)` | 设置Ruud |
| `Player.Reset(index)` | 角色转生 |
| `Player.GetEvo(index)` | 获取进化等级(1-5) |
| `Player.ReCalc(index)` | 重新计算属性 |
| `Player.SendLife(index, life, flag, shield)` | 发送HP/盾更新包 |
| `Player.SendMana(index, mana, flag, bp)` | 发送MP/AG更新包 |
| `Player.SaveCharacter(index)` | 保存角色到数据库 |
| `Player.SetExp(index, target, exp, dmg, msb, monsterType)` | 发送经验包 |
| `Player.SendTradeOkButton(index, flag)` | 发送交易OK包 |
| `Player.SendTradeCancel(index, result)` | 发送交易取消包 |
| `Player.SendTradeResponse(response, index, name, level, guild)` | 发送交易响应 |

### Combat — 战斗信息

| 函数 | 返回值 | 说明 |
|------|--------|------|
| `Combat.GetTopDamageDealer(monsterIndex)` | `integer` | 造成最高伤害的玩家索引 |

### Stats — 属性管理

| 函数 | 说明 |
|------|------|
| `Stats.Set(index, statType, value, addType, levelUpPoint)` | 设置属性值 |
| `Stats.SendUpdate(index, statType, value, levelUpPoint)` | 发送属性更新 |
| `Stats.LevelUp(player, exp, monsterType, eventType)` | 给予经验值 |

### Inventory — 背包操作

| 函数 | 说明 |
|------|------|
| `Inventory.SendUpdate(index, pos)` | 发送背包更新 |
| `Inventory.SendDelete(index, pos)` | 发送物品删除 |
| `Inventory.SendList(index)` | 发送背包列表 |
| `Inventory.HasSpace(player, h, w)` | 检查背包空间 |
| `Inventory.Insert(index, item)` | 插入物品 |
| `Inventory.InsertAt(index, item, pos)` | 在指定位置插入物品 |
| `Inventory.Delete(index, pos)` | 删除物品 |
| `Inventory.SetSlot(index, start, type)` | 设置背包槽 |
| `Inventory.ReduceDur(player, pos, amount)` | 减少耐久度 |

### Item — 物品系统

| 函数 | 返回值 | 说明 |
|------|--------|------|
| `Item.IsValid(itemId)` | `integer` | 物品是否有效 |
| `Item.GetKindA(itemId)` | `integer` | 获取主类别 |
| `Item.GetKindB(itemId)` | `integer` | 获取子类别 |
| `Item.GetAttr(itemId)` | `ItemAttr` | 获取物品属性表 |
| `Item.IsSocket(itemId)` | `boolean` | 是否镶嵌物品 |
| `Item.IsElemental(itemId)` | `boolean` | 是否元素物品 |
| `Item.IsPentagram(itemId)` | `boolean` | 是否艾尔特 |
| `Item.Create(index, itemInfo)` | - | 创建物品 |

### Monster — 怪物属性

| 函数 | 返回值 | 说明 |
|------|--------|------|
| `Monster.GetAttr(class)` | `MonsterAttr\|nil` | 获取怪物属性表 |

### Buff — 增益/减益系统

| 函数 | 说明 |
|------|------|
| `Buff.Add(player, buffIndex, effect1, value1, effect2, value2, duration, sendValue, attacker)` | 添加Buff |
| `Buff.AddCashShop(player, itemId, duration)` | 添加商城Buff |
| `Buff.AddItem(player, buffIndex)` | 添加物品Buff |
| `Buff.Remove(player, buffIndex)` | 移除Buff |
| `Buff.CheckUsed(player, buffIndex)` | 检查Buff是否激活 |

### Skill — 技能系统

| 函数 | 说明 |
|------|------|
| `Skill.UseDuration(player, target, x, y, dir, magic)` | 使用持续技能 |
| `Skill.UseNormal(player, target, magic)` | 使用即时技能 |

### Move — 移动/传送

| 函数 | 返回值 | 说明 |
|------|--------|------|
| `Move.Gate(index, gateIndex)` | `boolean` | 通过传送门传送 |
| `Move.ToMap(index, map, x, y)` | - | 传送到指定地图 |
| `Move.Warp(index, x, y)` | - | 同地图传送 |

### Party — 组队

| 函数 | 返回值 | 说明 |
|------|--------|------|
| `Party.GetCount(partyNumber)` | `integer` | 获取队伍人数 |
| `Party.GetMember(partyNumber, arrayIndex)` | `integer` | 获取队伍成员索引 |

### DB — 数据库查询

| 函数 | 说明 |
|------|------|
| `DB.QueryDS(playerIndex, queryNumber, sql)` | 执行DataServer查询 |
| `DB.QueryJS(playerIndex, queryNumber, sql)` | 执行JoinServer查询 |

查询结果通过 `onDSDBQueryReceive` / `onJSDBQueryReceive` 回调异步返回。

### Message — 消息发送

```lua
Message.Send(senderIndex, targetIndex, type, text)
```

- `senderIndex`: 发送者索引（0=系统）
- `targetIndex`: 目标索引（-1=所有玩家）
- `type`: 0=黄金中央, 1=蓝色左侧, 2=绿色战盟, 3=红色左侧

### Timer — 定时器

| 函数 | 返回值 | 说明 |
|------|--------|------|
| `Timer.Create(interval, name, callback, aliveTime?)` | `integer` | 一次性定时器 |
| `Timer.CreateRepeating(interval, name, callback, aliveTime?)` | `integer` | 重复定时器 |
| `Timer.RepeatNTimes(interval, name, count, callback)` | `integer` | 执行N次的定时器 |
| `Timer.Remove(id)` | `boolean` | 按ID移除定时器 |
| `Timer.RemoveByName(name)` | `boolean` | 按名称移除定时器 |
| `Timer.Exists(id)` | `boolean` | 检查定时器是否存在 |
| `Timer.ExistsByName(name)` | `boolean` | 按名称检查 |
| `Timer.Start(id)` | `boolean` | 启动/恢复定时器 |
| `Timer.Stop(id)` | `boolean` | 暂停定时器 |
| `Timer.IsActive(id)` | `boolean` | 检查是否运行中 |
| `Timer.GetRemaining(id)` | `integer` | 获取剩余时间(ms) |
| `Timer.GetTick()` | `integer` | 获取当前tick(ms) |

> **重要**：所有时间参数单位为毫秒。定时器名称必须唯一——同名会替换旧定时器。

### ActionTick — 冷却计时器

每个玩家有 3 个独立的 ActionTick 计时器（索引 0-2，Lua 访问用 1-3）。

| 函数 | 说明 |
|------|------|
| `ActionTick.Get(playerIndex, timerIndex)` | 获取计数值 |
| `ActionTick.Set(playerIndex, timerIndex, value, name?)` | 设置计数值 |
| `ActionTick.GetName(playerIndex, timerIndex)` | 获取计时器名称 |
| `ActionTick.Clear(playerIndex, timerIndex)` | 清除计时器 |

### Scheduler — 事件调度

| 函数 | 返回值 | 说明 |
|------|--------|------|
| `Scheduler.LoadFromXML(path)` | `boolean` | 加载XML配置 |
| `Scheduler.GetEventCount()` | `integer` | 获取事件数量 |
| `Scheduler.CheckEventNotices()` | `table` | 检查预告通知 |
| `Scheduler.CheckEventStarts()` | `table` | 检查开始事件 |
| `Scheduler.CheckEventEnds()` | `table` | 检查结束事件 |
| `Scheduler.GetEventName(eventType)` | `string` | 获取事件名称 |
| `Scheduler.HasSecondPrecisionEvents()` | `boolean` | 是否需要秒级精度 |
| `Scheduler.IsEventActive(eventType)` | `boolean` | 事件是否活跃 |
| `Scheduler.GetElapsedTime(eventType)` | `integer` | 已过时间(秒) |
| `Scheduler.GetRemainingTime(eventType)` | `integer` | 剩余时间(秒) |
| `Scheduler.GetProgress(eventType)` | `integer` | 进度百分比(0-100) |

### Utility — 工具函数

| 函数 | 返回值 | 说明 |
|------|--------|------|
| `Utility.GetRandomRangedInt(min, max)` | `integer` | 随机整数 |
| `Utility.GetLargeRand()` | `integer` | 大随机数 |
| `Utility.FireCracker(index)` | - | 烟花效果 |
| `Utility.SendEventTimer(index, ms, countUp, displayType, delete)` | - | 发送可视化计时器 |

### Log — 日志系统

```lua
Log.Add(message)                    -- 普通日志
Log.AddC(color, message)           -- 彩色日志（使用 Helpers.RGB 或 Enums.LogColor）
```

### Helpers — 辅助工具

```lua
Helpers.RGB(r, g, b)               -- 创建DWORD颜色值
Helpers.MakeItemId(type, index)     -- 计算物品ID（type * 512 + index）
Helpers.GetItemType(itemId)         -- 提取物品类型（itemId / 512）
Helpers.GetItemIndex(itemId)        -- 提取物品索引（itemId % 512）
```

### Language — 多语言系统

```lua
Language.GetText(langCode, textType, textID)  -- 获取本地化文本
```

### EventMonsterTracker — 事件怪物追踪

| 函数 | 返回值 | 说明 |
|------|--------|------|
| `EventMonsterTracker.Register(eventType, objIndex, objClass, objType)` | - | 注册追踪 |
| `EventMonsterTracker.Unregister(eventType, objIndex)` | `boolean` | 取消追踪 |
| `EventMonsterTracker.IsTracked(eventType, objIndex)` | `boolean` | 是否被追踪 |
| `EventMonsterTracker.GetObjectInfo(eventType, objIndex)` | `table` | 获取对象信息 |
| `EventMonsterTracker.GetMonsterClass(eventType, objIndex)` | `integer` | 获取怪物Class |
| `EventMonsterTracker.GetMonsters(eventType, filter?)` | `table` | 获取所有追踪对象 |
| `EventMonsterTracker.GetCount(eventType, filter?)` | `integer` | 获取追踪数量 |
| `EventMonsterTracker.CleanupEvent(eventType, filter?)` | `integer` | 清理并删除 |
| `EventMonsterTracker.CleanupDead(eventType, filter?)` | `integer` | 清理死亡对象 |
| `EventMonsterTracker.GetActiveEvents()` | `table` | 获取活跃事件 |
| `EventMonsterTracker.ClearAll()` | `integer` | 清空所有追踪 |
| `EventMonsterTracker.SpawnAndRegister(eventType, class, map, x1, y1, x2, y2, element)` | `integer` | 生成并追踪 |
| `EventMonsterTracker.SpawnWaveAndRegister(eventType, class, count, map, x1, y1, x2, y2, element)` | `table` | 批量生成并追踪 |
| `EventMonsterTracker.RegisterNPC(eventType, npcIndex, npcClass)` | - | 注册NPC |

---

## 📊 数据结构

### 玩家对象 (stObject)

所有玩家、怪物、NPC 共享同一对象结构。关键属性：

#### 基本属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `Index` | integer | 服务器数组索引（只读） |
| `Type` | integer | 对象类型（Enums.ObjectType） |
| `Connected` | integer | 连接状态（1=已连接） |
| `Name` | string | 对象名称（只读） |
| `Level` | integer | 角色等级 |
| `Class` | integer | 角色职业 |
| `MapNumber` | integer | 当前地图ID |
| `X`, `Y` | integer | 当前坐标 |
| `Dir` | integer | 面向方向(0-7) |
| `Life` | number | 当前HP |
| `MaxLife` | number | 最大HP |
| `Mana` | number | 当前MP |
| `MaxMana` | number | 最大MP |
| `Shield` | integer | 当前护盾值 |
| `MaxShield` | integer | 最大护盾值 |
| `BP` | integer | 当前AG |
| `PartyNumber` | integer | 队伍ID（-1=不在队伍） |
| `Authority` | integer | 权限等级 |
| `GameMaster` | integer | GM状态标志 |

#### userData 子结构体

| 属性 | 类型 | 说明 |
|------|------|------|
| `Strength` | integer | 基础力量 |
| `Dexterity` | integer | 基础敏捷 |
| `Vitality` | integer | 基础体力 |
| `Energy` | integer | 基础智力 |
| `Command` | integer | 基础统率 |
| `AddStrength` | integer | 额外力量 |
| `AddDexterity` | integer | 额外敏捷 |
| `AddVitality` | integer | 额外体力 |
| `AddEnergy` | integer | 额外智力 |
| `AddCommand` | integer | 额外统率 |
| `LevelUpPoint` | integer | 可用升级点数 |
| `MasterLevel` | integer | 大师等级 |
| `MasterExp` | integer | 大师经验值 |
| `Money` | integer | 金币(Zen) |
| `Ruud` | integer | Ruud货币 |
| `Resets` | integer | 转生次数 |
| `VIPType` | integer | VIP等级（-1=无） |
| `VIPMode` | integer | VIP模式 |

#### ActionTickCount 子结构体

每个玩家有3个独立的计时器（Lua索引1-3）：

```lua
local tick = oPlayer.ActionTickCount[1].tick    -- 获取计数值
local name = oPlayer.ActionTickCount[1].name    -- 获取名称
ActionTick.Set(iPlayerIndex, 0, Timer.GetTick(), "MyTimer")  -- 设置
```

### 物品结构

| 结构 | 说明 | 可修改 |
|------|------|--------|
| `ItemAttr` | 物品模板（从ItemList.txt读取，只读） | ❌ |
| `ItemInfo` | 实际物品实例 | ✅ |
| `CreateItemInfo` | 创建新物品时的参数 | ✅ |
| `BagItem` | 物品包掉落模板 | ✅ |

**物品操作示例**：

```lua
-- 创建物品
local itemInfo = CreateItemInfo.new()
itemInfo.ItemId = Helpers.MakeItemId(14, 13)  -- 祝福宝石
itemInfo.ItemLevel = 0
itemInfo.Durability = 255
Item.Create(iPlayerIndex, itemInfo)

-- 读取物品
local item = oPlayer:GetInventoryItem(slot)
if item ~= nil and item.IsItemExist then
    local name = Item.GetAttr(item.Type):GetName()
    Log.Add("Slot " .. slot .. ": " .. name)
end
```

### 枚举常量 (Enums)

项目定义了丰富的枚举类型，以下是关键枚举概览：

| 枚举 | 说明 | 主要值 |
|------|------|--------|
| `CharacterClassType` | 角色职业 | WIZARD=0, KNIGHT=1, ELF=2, ... |
| `StatType` | 属性类型 | STRENGTH=0, AGILITY=1, VITALITY=2, ENERGY=3, COMMAND=4 |
| `ObjectType` | 对象类型 | EMPTY=-1, USER=1, MONSTER=2, NPC=3 |
| `MapIndex` | 地图编号 | LORENCIA=0, DUNGEON=1, DEVIAS=2, ... (140+地图) |
| `BuffType` | Buff类型 | 460+种Buff（攻击、防御、经验、技能等） |
| `EffectType` | Buff效果 | IMPROVE_DAMAGE=2, IMPROVE_DEFENSE=3, HP=4, ... |
| `ItemType/KindA/KindB` | 物品分类 | 武器、防具、翅膀、药水、宝石等 |
| `VIPMode` | VIP模式 | NONE=-1, DAY=0, NIGHT=1 |
| `HPManaUpdateFlag` | HP/MP更新 | INVENTORY_STATE_RESET=253, MAX_HP_MANA=254, CURRENT_HP_MANA=255 |
| `LogColor` | 日志颜色 | 140+种命名颜色（使用Helpers.RGB） |
| `PlayerState` | 玩家状态 | EMPTY=0, CONNECTED=1, LOGGED=2, PLAYING=3 |
| `NPCType` | NPC类型 | NONE=0, SHOP=1, WAREHOUSE=2, CHAOS_MIX=3, ... |
| `ResistanceType` | 抗性类型 | ICE=0, POISON=1, LIGHTNING=2, FIRE=3, ... |
| `EventType` | 事件类型 | SAMPLE_EVENT_1=0, SAMPLE_EVENT_2=1, ... |

---

## 📡 事件回调完整列表

### 连接 & 认证事件

| 回调 | 类型 | 参数 | 说明 |
|------|------|------|------|
| `onCharacterSelectEnter(oPlayer)` | Async | 玩家 | 进入角色选择 |
| `onPlayerConnect(oPlayer)` | Async | 玩家 | 连接到服务器 |
| `onPlayerLogin(oPlayer)` | Async | 玩家 | 登录角色 |
| `onPlayerDisconnect(oPlayer)` | Async | 玩家 | 断开连接 |

### 服务器生命周期事件

| 回调 | 类型 | 说明 |
|------|------|------|
| `onGameServerStart()` | Async | 服务器启动 |
| `onDisconnectAllPlayers()` | Async | 强制断开所有玩家 |
| `onLogOutAllPlayers()` | Async | 优雅关闭 |
| `onDisconnectAllPlayersWithReconnect()` | Async | 重启断开 |

### 仓库 & 交易事件

| 回调 | 类型 | 返回值 | 说明 |
|------|------|--------|------|
| `onOpenWarehouse(oPlayer)` | Async | - | 打开仓库 |
| `onCloseWarehouse(oPlayer)` | Async | - | 关闭仓库 |
| `onTradeRequestSend(oPlayer, oTarget)` | Sync | 非零阻止 | 发送交易请求 |
| `onTradeResponseReceive(oPlayer, oTarget, bResponse)` | Sync | 非零阻止 | 收到交易响应 |
| `onTradeAccept(oPlayer, oTarget)` | Sync | 非零阻止 | 双方确认交易 |
| `onTradeCancel(oPlayer, oTarget)` | Sync | 非零阻止 | 取消交易 |

### 特殊事件入场

| 回调 | 类型 | 参数 | 说明 |
|------|------|------|------|
| `onBloodCastleEnter(oPlayer, iEventLevel)` | Async | 血色城堡等级 | 进入血色城堡 |
| `onChaosCastleEnter(oPlayer, iEventLevel)` | Async | 赤色要塞等级 | 进入赤色要塞 |
| `onDevilSquareEnter(oPlayer, iEventLevel)` | Async | 恶魔广场等级 | 进入恶魔广场 |

### 玩家成长事件

| 回调 | 类型 | 说明 |
|------|------|------|
| `onPlayerLevelUp(oPlayer)` | Async | 玩家升级 |
| `onPlayerMasterLevelUp(oPlayer)` | Async | 大师升级 |
| `onUseCommand(oPlayer, szCmd)` | Sync | 玩家输入命令（返回1阻止） |
| `onPlayerReset(oPlayer)` | Async | 角色转生 |

### NPC 交互

| 回调 | 类型 | 返回值 | 说明 |
|------|------|--------|------|
| `onNpcTalk(oPlayer, oNpc)` | Sync | 非零阻止 | NPC对话 |
| `onCloseWindow(oPlayer)` | Sync | 非零阻止 | 关闭NPC窗口 |

### 背包 & 物品事件

| 回调 | 类型 | 说明 |
|------|------|------|
| `onItemUse(iResult, oPlayer, oItem, srcPos, tgtPos)` | Sync | 使用物品 |
| `onInventoryMoveItem(oPlayer, srcPos, tgtPos, result)` | Async | 背包移动物品 |
| `onEventInventoryMoveItem(...)` | Async | 活动背包移动物品 |
| `onMuunInventoryMoveItem(...)` | Async | Muun背包移动物品 |
| `onItemGet(oPlayer, type, level, dur, element)` | Async | 拾取地面物品 |
| `onEventItemGet(...)` | Async | 获取活动物品 |
| `onMuunItemGet(...)` | Async | 获取Muun物品 |
| `onItemEquip(oPlayer, srcPos, tgtPos, result)` | Async | 装备物品 |
| `onItemUnEquip(oPlayer, srcPos, tgtPos, result)` | Async | 卸下装备 |
| `onItemRepair(oPlayer, oItem)` | Async | 修复物品 |

### 地图 & 移动事件

| 回调 | 类型 | 说明 |
|------|------|------|
| `onCharacterJoinMap(oPlayer)` | Async | 加入地图 |
| `onMoveMap(oPlayer, mapNum, x, y, gate)` | Async | 地图间移动 |
| `onMapTeleport(oPlayer, gate)` | Async | 传送门传送 |
| `onTeleport(oPlayer, mapNum, x, y)` | Async | 命令/道具传送 |
| `onTeleportMagicUse(oPlayer, x, y)` | Async | 技能传送 |

### 战斗 & 死亡事件

| 回调 | 类型 | 说明 |
|------|------|------|
| `onPlayerKill(oPlayer, oTarget)` | Async | 击杀玩家 |
| `onPlayerDie(oPlayer, oTarget)` | Async | 玩家死亡 |
| `onPlayerRespawn(oPlayer)` | Async | 玩家重生 |
| `onMonsterKill(oPlayer, oTarget)` | Async | 击杀怪物 |
| `onMonsterDie(oPlayer, oTarget)` | Async | 怪物死亡 |
| `onMonsterSpawn(oPlayer)` | Async | 怪物生成 |
| `onMonsterRespawn(oPlayer)` | Async | 怪物重生 |
| `onCheckUserTarget(oPlayer, oTarget)` | Sync | 攻击目标检查（非零阻止） |
| `onUseDurationSkill(oPlayer, target, skill, x, y, dir)` | Sync | 持续技能使用 |
| `onUseNormalSkill(oPlayer, oTarget, skill)` | Sync | 即时技能使用 |

### 商店 & 交易

| 回调 | 类型 | 说明 |
|------|------|------|
| `onShopBuyItem(oPlayer, oItem)` | Sync | NPC购买 |
| `onShopSellItem(oPlayer, oItem)` | Sync | NPC出售 |
| `onShopSellEventItem(oPlayer, oItem)` | Async | 出售活动物品 |
| `onMossMerchantUse(oPlayer, iSectionId)` | Sync | 商人交互 |

### 数据库查询回调

| 回调 | 说明 |
|------|------|
| `onDSDBQueryReceive(playerIndex, queryNum, isLast, row, colCount, packet, oRow)` | DataServer查询结果 |
| `onJSDBQueryReceive(playerIndex, queryNum, isLast, row, colCount, packet, oRow)` | JoinServer查询结果 |

---

## ⏰ 定时器辅助库 (TimerHelpers)

提供常用定时器模式的高级封装：

| 函数 | 说明 |
|------|------|
| `TimerHelpers.Delay(seconds, name, callback)` | 延迟执行（秒） |
| `TimerHelpers.Repeat(seconds, name, callback, aliveTime?)` | 重复执行（秒） |
| `TimerHelpers.Countdown(seconds, name, onTick, onComplete)` | 倒计时定时器 |
| `TimerHelpers.Debounce(name, delayMs, callback)` | 防抖（延迟期间无新调用才执行） |
| `TimerHelpers.Throttle(name, intervalMs, callback)` | 节流（冷却期内忽略） |
| `TimerHelpers.Timeout(name, timeoutMs, condition, onSuccess, onTimeout)` | 条件等待 |
| `TimerHelpers.RetryWithBackoff(name, delay, maxAttempts, op, onSuccess, onFailure)` | 指数退避重试 |
| `TimerHelpers.RepeatWithJitter(baseMs, jitter%, name, callback, aliveMs?)` | 带抖动的重复定时器 |
| `TimerHelpers.CancelTimers(namePattern, suffixes)` | 按模式取消多个定时器 |
| `TimerHelpers.UniqueName(prefix)` | 生成唯一定时器名称 |

**防抖示例**：
```lua
TimerHelpers.Debounce("button_" .. player.Index, 1000, function()
    Log.Add("按钮点击处理")
end)
```

**节流示例**：
```lua
if TimerHelpers.Throttle("chat_" .. player.Index, 2000, function()
    -- 处理聊天消息
end) then
    -- 已执行
else
    Message.Send(0, player.Index, 0, "请稍后再试")
end
```

---

## 🗂️ 定时器管理器 (TimerManager)

命名定时器存储，便于跨文件访问：

```lua
-- 存储定时器（自动移除同名旧定时器）
TimerManager.Set("MyTimer", timerId)

-- 获取定时器ID
local id = TimerManager.Get("MyTimer")

-- 移除定时器
TimerManager.Remove("MyTimer")

-- 检查是否存在
if TimerManager.Exists("MyTimer") then
    -- ...
end

-- 列出所有定时器
local names = TimerManager.List()

-- 清除所有定时器
TimerManager.Clear()
```

---

## 📅 事件调度器配置 (XML)

`Config/EventScheduler.xml` 配置文件格式：

```xml
<EventScheduler>
    <Event Type="0" Name="示例事件 1" NoticePeriod="300" Duration="600">
        <Start Year="-1" Month="-1" Day="-1" DayOfWeek="-1" Hour="20" Minute="0" Second="0" />
    </Event>
</EventScheduler>
```

**属性说明**：

| 属性 | 说明 |
|------|------|
| `Type` | 事件类型ID（必须匹配 Enums.EventType） |
| `Name` | 事件显示名称 |
| `NoticePeriod` | 开始前预告秒数（0=不预告） |
| `Duration` | 持续时间秒数（0=不自动结束） |

**Start 时间组件**：

| 组件 | 值 | 说明 |
|------|------|------|
| `Year` | 具体年份 或 -1 | -1=任意年份 |
| `Month` | 1-12 或 -1 | -1=任意月份 |
| `Day` | 1-31 或 -1 | -1=任意日期 |
| `DayOfWeek` | 0-6 或 -1 | 0=周日, 6=周六, -1=任意 |
| `Hour` | 0-23 或 -1 | -1=任意小时 |
| `Minute` | 0-59 或 -1 | -1=任意分钟 |
| `Second` | 0-59 或 -1 | -1=任意秒（影响调度精度） |

> **精度优化**：如果所有事件的 `Second = -1`，调度器自动降为每分钟检查；否则每秒检查。

---

## 💡 示例代码

项目提供了 11 个示例文件，包含 200+ 个可复制粘贴的实用函数：

| 示例文件 | 类别 | 函数数 | 说明 |
|----------|------|--------|------|
| `IteratorExamples.lua` | 迭代器 | 50+ | 全部9种迭代器用法 |
| `UtilityExamples.lua` | 工具 | 30+ | 计数、查找、过滤 |
| `FilterExamples.lua` | 过滤 | 40+ | 高级过滤技巧 |
| `TimerExamples.lua` | 定时器 | 20+ | 各类定时器模式 |
| `EventExamples.lua` | 事件 | 15+ | BOSS、入侵、血色等 |
| `PvPExamples.lua` | PvP | 20+ | 竞技、混战、战盟战 |
| `AdminExamples.lua` | 管理 | 25+ | 传送、踢出、封禁等 |
| `CombatExamples.lua` | 战斗 | 25+ | AOE、DOT、控制等 |
| `BuffExamples.lua` | Buff | 15+ | 增益、减益、定时Buff |
| `ExperienceExamples.lua` | 经验 | 10+ | 经验分配、倍率等 |
| `GuildExamples.lua` | 战盟 | 10+ | 战盟广播、奖励等 |

### 常用代码片段

**全服广播**：
```lua
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

**地图玩家统计（带过滤）**：
```lua
local vipCount = Object.CountPlayersOnMap(0, function(oPlayer)
    return oPlayer.userData.VIPType >= 0
end)
```

**条件等待（等待玩家到达区域）**：
```lua
TimerHelpers.Timeout("PlayerAreaCheck", 30000,
    function()
        local dx = player.X - targetX
        local dy = player.Y - targetY
        return math.sqrt(dx * dx + dy * dy) <= targetRange
    end,
    function() Log.Add("玩家已到达！") end,
    function() Message.Send(0, player.Index, 0, "超时未到达！") end
)
```

---

## ✅ 最佳实践

### 1. 始终检查 nil

```lua
local oPlayer = Player.GetObjByIndex(iPlayerIndex)
if oPlayer ~= nil then
    -- 安全使用
end
```

### 2. 使用命名空间和枚举

```lua
-- ✅ 推荐
Player.SetMoney(iPlayerIndex, 1000000, false)
Stats.Set(iPlayerIndex, Enums.StatType.STRENGTH, 1000, 0, 0)

-- ❌ 避免
-- 使用魔法数字
```

### 3. 使用辅助函数计算物品ID

```lua
-- ✅ 正确
local itemId = Helpers.MakeItemId(14, 13)  -- 祝福宝石

-- ❌ 错误（容易出错）
local itemId = 14 * 512 + 13
```

### 4. 注意索引基数

```lua
-- C++风格：0基索引
local weapon = oPlayer:GetInventoryItem(0)

-- Lua风格：1基索引
local socket = itemInfo:GetSocket(1)
```

### 5. 同步回调必须快速完成

```lua
-- ✅ 快速验证
function onTradeRequestSend(oPlayer, oTarget)
    if oPlayer == nil or oTarget == nil then return 0 end
    -- 简单检查
    return 0
end

-- ❌ 不要在同步回调中做重量级操作
-- ❌ 不要在同步回调中执行数据库查询
```

### 6. 重连时清理定时器

```lua
function onPlayerDisconnect(oPlayer)
    if oPlayer ~= nil then
        TimerHelpers.CancelTimers("Player_" .. oPlayer.Index, {
            "Buff", "Debuff", "Poison", "Cooldown"
        })
    end
end
```

### 7. 缓存频繁访问的值

```lua
-- ✅ 好 - 缓存对象
local oPlayer = Player.GetObjByIndex(iPlayerIndex)
if oPlayer ~= nil then
    for i = 0, Constants.MAIN_INVENTORY_SIZE - 1 do
        local item = oPlayer:GetInventoryItem(i)
        -- ...
    end
end

-- ❌ 差 - 每次循环都查找
for i = 0, Constants.MAIN_INVENTORY_SIZE - 1 do
    local oPlayer = Player.GetObjByIndex(iPlayerIndex)
    -- ...
end
```

---

## 📐 编码规范

1. **文件编码**：源文件使用 UTF-8（含中文注释），部署时需转换为 ASCII
2. **函数命名**：使用 PascalCase（如 `GiveExperience`、`ApplyBuff`）
3. **常量引用**：使用 `Enums.XXX.YYY` 而非魔法数字
4. **nil 检查**：所有回调函数的 `oPlayer` / `oTarget` 参数必须做 nil 检查
5. **定时器命名**：使用描述性名称，用前缀区分作用域（如 `Player_123_Buff`）
6. **回调返回**：同步回调返回 `0` 允许、`1` 阻止；迭代器回调返回 `true` 继续、`false` 中断

---

## ⚠️ 版本兼容性说明

部分回调函数在 s6 版本中不可用：

| 回调 | s6 状态 |
|------|---------|
| `onPlayerLevelUp` | ❌ 不可用 |
| `onPlayerReset` | ❌ 不可用 |
| `onEventInventoryMoveItem` | ❌ 不可用 |
| `onMuunInventoryMoveItem` | ❌ 不可用 |
| `onEventItemGet` | ❌ 不可用 |
| `onMuunItemGet` | ❌ 不可用 |
| `onShopSellEventItem` | ❌ 不可用 |
| `onMapTeleport` | ❌ 不可用 |
| `onMonsterSpawn` | ❌ 不可用 |
| `onDisconnectAllPlayersWithReconnect` | ❌ 不可用 |
| `Timer.AddVisualPlayer` | ❌ 不可用 |
| `Timer.RemoveVisualPlayer` | ❌ 不可用 |
| `Timer.SetVisualPlayers` | ❌ 不可用 |

---

## 📄 许可证

```
(C) 2010-2026 IGC-Network (R)
www.igcn.mu

This file is a part of IGCN Group MuOnline Server files.
```

---

## 🔗 相关资源

- **官方网站**: [www.igcn.mu](https://www.igcn.mu)
- **Wiki 文档**: `Wiki/` 目录包含完整的 API 参考文档
- **示例代码**: `Examples/` 目录包含 200+ 实用函数
- **C++ 迭代器实现**: 参考 `ObjectIterators_CPP_Implementation.cpp`
- **VIP 系统说明**: 参考 `VIP_SYSTEM_NOTE.md`
- **迭代器更新日志**: 参考 `ITERATOR_UPDATE.md`