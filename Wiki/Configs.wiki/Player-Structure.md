# C++ 结构体参考

暴露给 Lua 脚本系统的 C++ 对象完整参考。

**重要：** 这些结构体不能在 Lua 中实例化。它们是只能通过特定函数访问的 C++ 对象。

---

## 目录

- [玩家对象](#玩家对象)
- [userData 结构](#userdata-结构)
- [ActionTickCount 结构](#actiontickcount-结构)
- [使用示例](#使用示例)

---

## 玩家对象

**访问方式：** 通过 `Player.GetObjByIndex()`、`Player.GetObjByName()` 或回调参数

**C++ 类型：** `stObject`

**注意：** 游戏中所有对象类型使用相同的 `stObject` 结构：
- 玩家
- 怪物
- NPC

所有对象共享相同的结构，具有公共字段如 `Index`、`MapNumber`、`X`、`Y`、`Class`、`Type` 等。

### 玩家标识

| Field | Type | Description |
|-------|------|-------------|
| `Index` | int | *(只读)* 玩家对象在服务器数组中的索引 |
| `Type` | int | *(只读)* 对象类型 - 见 `Enums.ObjectType` (USER, MONSTER, NPC) |
| `Connected` | int | 连接状态（1 = 已连接，0 = 已断开） |
| `UserNumber` | int | *(只读)* 唯一用户会话编号 |
| `DBNumber` | int | *(只读)* 数据库角色 ID (memb_guid) |
| `LangCode` | int | *(仅 s7+)* 客户端语言代码 (ID) |

**Type 字段用法：**
```lua
local oObject = Player.GetObjByIndex(iIndex)
if oObject then
	if oObject.Type == Enums.ObjectType.USER then
		-- 真实玩家 - userData 可访问
		local money = oObject.userData.Money
	elseif oObject.Type == Enums.ObjectType.MONSTER then
		-- 怪物 - 无 userData
	elseif oObject.Type == Enums.ObjectType.NPC then
		-- NPC - 仅玩家职业 NPC 可访问 userData
	end
end
```

### 角色信息

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `Class` | WORD | 角色职业代码 |
| `Level` | short | 角色等级 |
| `Name` | string | *(只读)* 角色名称（最多 10 个字符） |
| `AccountId` | string | *(只读)* 账号登录名 |

### 生命系统

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `Life` | double | 当前 HP |
| `MaxLife` | double | 最大 HP |
| `AddLife` | int | 来自物品/buff 的附加 HP |

### 护盾系统

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `Shield` | int | 当前护盾点数 |
| `AddShield` | int | 来自物品/buff 的附加护盾 |
| `MaxShield` | int | 最大护盾容量 |

### 魔法系统

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `Mana` | double | 当前魔法/MP |
| `MaxMana` | double | 最大魔法 |
| `AddMana` | int | 来自物品/buff 的附加魔法 |

### AG/体力系统

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `BP` | int | 当前 AG/体力点数 |
| `AddBP` | int | 来自物品/buff 的附加 AG |
| `MaxBP` | int | 最大 AG 容量 |

### PK 系统

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `PKCount` | int | 当前 PK 计数 |
| `PKLevel` | char | PK 等级/状态 (0-6) |
| `PKTime` | int | PK 状态剩余时间 |
| `PKTotalCount` | int | 生涯总 PK 计数 |

### 位置和地图

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `X` | BYTE | 当前 X 坐标 |
| `Y` | BYTE | 当前 Y 坐标 |
| `Dir` | BYTE | 朝向方向 (0-7) |
| `MapNumber` | WORD | 当前地图 ID |

### 目标和交互

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `TargetNumber` | short | 目标对象索引（正在攻击的怪物/玩家） |
| `TargetNpcNumber` | short | NPC 对象索引（玩家正在交互的 NPC） |

**用法：**
```lua
-- 检查玩家正在攻击谁
local oPlayer = Player.GetObjByIndex(playerIndex)
if oPlayer and oPlayer.TargetNumber >= 0 then
	local oTarget = Player.GetObjByIndex(oPlayer.TargetNumber)
	if oTarget then
		Log.Add(string.format("%s 正在攻击 %s", oPlayer.Name, oTarget.Name))
	end
end

-- 检查玩家正在与哪个 NPC 对话
if oPlayer and oPlayer.TargetNpcNumber >= 0 then
	local oNPC = Player.GetObjByIndex(oPlayer.TargetNpcNumber)
	if oNPC and oNPC.Type == Enums.ObjectType.NPC then
		Log.Add(string.format("%s 正在与 NPC 职业 %d 对话", oPlayer.Name, oNPC.Class))
	end
end
```

### Authority & Permissions

| Field | Type | Description |
|-------|------|-------------|
| `Authority` | DWORD | 权限等级 |
| `AuthorityCode` | DWORD | 权限验证代码 |
| `Penalty` | DWORD | 惩罚标志/类型 |
| `GameMaster` | DWORD | 游戏管理员状态标志 |
| `PenaltyMask` | DWORD | 惩罚限制位掩码 |

### Physical Attack Damage

| Field | Type | Description |
|-------|------|-------------|
| `AttackDamageMin` | int | 最小攻击伤害（总计） |
| `AttackDamageMax` | int | 最大攻击伤害（总计） |
| `AttackDamageMinLeft` | int | 左手武器最小伤害 |
| `AttackDamageMinRight` | int | 右手武器最小伤害 |
| `AttackDamageMaxLeft` | int | 左手武器最大伤害 |
| `AttackDamageMaxRight` | int | 右手武器最大伤害 |

### Magic Damage

| Field | Type | Description |
|-------|------|-------------|
| `MagicDamageMin` | int | 最小魔法/魔法伤害 |
| `MagicDamageMax` | int | 最大魔法/魔法伤害 |

### 诅咒伤害

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `CurseDamageMin` | int | 最小诅咒/黑暗伤害 |
| `CurseDamageMax` | int | 最大诅咒/黑暗伤害 |
| `CurseSpell` | int | 激活的诅咒魔法效果 |

### 战斗统计

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `CombatPower` | int | *(仅 s7+)* 总战斗功率评级 |
| `CombatPowerAttackDamage` | int | *(仅 s7+)* 来自攻击伤害的战斗功率 |
| `Defense` | int | 总防御值 |
| `AttackRating` | int | 攻击成功率 |
| `DefenseRating` | int | 防御/格挡成功率 |
| `AttackSpeed` | int | 攻击速度值 |
| `MagicSpeed` | int | 魔法/技能施放速度值 |

### 艾尔特系统 - 概览

> ⚠️ **s6 不可用** — 以下所有艾尔特字段在 s6 版本中不存在。

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `PentagramMainAttribute` | int | 艾尔特主属性类型 |
| `PentagramAttributePattern` | int | 艾尔特属性图案 ID |

### 艾尔特系统 - 防御

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `PentagramDefense` | int | 基础艾尔特防御（PvM） |
| `PentagramDefensePvP` | int | PvP 艾尔特防御 |
| `PentagramDefenseRating` | int | 艾尔特防御评级（PvM） |
| `PentagramDefenseRatingPvP` | int | PvP 艾尔特防御评级 |

### 艾尔特系统 - 攻击

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `PentagramAttackMin` | int | 最小艾尔特攻击（PvM） |
| `PentagramAttackMax` | int | 最大艾尔特攻击（PvM） |
| `PentagramAttackMinPvP` | int | 最小艾尔特攻击（PvP） |
| `PentagramAttackMaxPvP` | int | 最大艾尔特攻击（PvP） |
| `PentagramAttackRating` | int | 艾尔特攻击评级（PvM） |
| `PentagramAttackRatingPvP` | int | PvP 艾尔特攻击评级 |

### 艾尔特系统 - 伤害修饰符

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `PentagramDamageMin` | int | 最小艾尔特伤害修饰符 |
| `PentagramDamageMax` | int | 最大艾尔特伤害修饰符 |
| `PentagramDamageOrigin` | int | 基础艾尔特伤害 |
| `PentagramCriticalDamageRate` | int | 暴击伤害率 |
| `PentagramExcellentDamageRate` | int | 卓越伤害率 |

### 队伍和决斗系统

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `PartyNumber` | int | 队伍 ID（未在队伍中为 -1） |
| `WinDuels` | int | 决斗胜利总次数 |
| `LoseDuels` | int | 决斗失败总次数 |

### 状态

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `Live` | unsigned char | 存活状态（1 = 存活，0 = 死亡） |

### 交易

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `TradeMoney` | int | 当前交易窗口中放置的 Zen 金额 |
| `TradeOk` | int | 交易确认状态（1 = 玩家已按确定） |

### 动作 Tick 计数器

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `ActionTickCount` | ActionTickCount[3] | 3 个动作 tick 计数器数组（在 Lua 中索引为 1-3） |

### 用户数据

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `userData` | userData* | *(只读指针)* 用户数据子结构（见下方 userData 部分） |

### 方法

#### GetInventoryItem

```lua
oPlayer:GetInventoryItem(iInventoryPos)
```

**参数：**
- `iInventoryPos` (int): 物品栏槽位索引（0 到 INVENTORY_SIZE-1）

**返回：** 
- 如果槽位有有效物品则返回 `CItem` 对象
- 如果无物品或无效位置则返回 `nil`

**用法：**
```lua
local oPlayer = Player.GetObjByIndex(iPlayerIndex)
local weapon = oPlayer:GetInventoryItem(0)  -- 武器槽位

if weapon ~= nil then
    Log.Add("玩家装备了武器")
end
```

---

#### GetWarehouseItem

```lua
oPlayer:GetWarehouseItem(iWarehousePos)
```

**参数：**
- `iWarehousePos` (int): 仓库槽位索引（0 到 WAREHOUSE_SIZE-1）

**返回：**
- 如果槽位有有效物品则返回 `CItem` 对象
- 如果无物品或无效位置则返回 `nil`

**用法：**
```lua
local oPlayer = Player.GetObjByIndex(iPlayerIndex)
local item = oPlayer:GetWarehouseItem(0)

if item ~= nil then
    Log.Add("在仓库槽位 0 找到物品")
end
```

---

#### GetTradeItem

```lua
oPlayer:GetTradeItem(iTradePos)
```

**参数：**
- `iTradePos` (int): 交易框槽位索引（0 到 TRADE_BOX_SIZE-1）

**返回：**
- 如果槽位有有效物品则返回 `CItem` 对象
- 如果无物品或无效位置则返回 `nil`

---

#### SetIfState / GetIfStateUse / GetIfStateState / GetIfStateType

```lua
oPlayer:SetIfState(btUse, btState, btType)
oPlayer:GetIfStateUse()
oPlayer:GetIfStateState()
oPlayer:GetIfStateType()
```

**描述：** 控制玩家的 UI 界面状态（打开的窗口/对话框）。

| 参数 | 类型 | 描述 |
|-----------|------|-------------|
| `btUse` | BYTE | 界面是否在使用中 (0-1) |
| `btState` | BYTE | 当前界面状态值 |
| `btType` | BYTE | 界面类型标识符 |

---

## userData 结构

**访问方式：** 通过 `oPlayer.userData`

**C++ 类型：** `LPOBJ_USER_DATA`

**重要：** `userData` 字段仅在以下情况下可用：
- **玩家**（连接到服务器的真实玩家）
- **玩家型 NPC**（具有玩家角色职业的 NPC）

普通怪物和物品**没有**此结构。访问非玩家对象的 `userData` 可能导致 nil 或未定义行为。

### 基础属性

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `Strength` | WORD | 当前力量值 |
| `Dexterity` | WORD | 当前敏捷值 |
| `Vitality` | WORD | 当前体力值 |
| `Energy` | WORD | 当前智力值 |
| `Command` | WORD | 当前指挥值 |

### 附加属性（蓝色属性）

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `AddStrength` | int | 附加力量属性（蓝色） |
| `AddDexterity` | int | 附加敏捷属性（蓝色） |
| `AddVitality` | int | 附加体力属性（蓝色） |
| `AddEnergy` | int | 附加智力属性（蓝色） |
| `AddCommand` | int | 附加指挥属性（蓝色） |

### 属性点数

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `LevelUpPoint` | int | 可分配的升级点数 |

### 职业信息

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `DBClass` | BYTE | 数据库中的角色职业 ID |

### 大师等级系统

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `MasterLevel` | short | 当前大师等级 |
| `MasterExp` | UINT64 | 当前大师等级经验 |
| `MasterNextExp` | UINT64 | 下一大师等级所需经验 |
| `ThirdTreePoint` | int | 第三技能树中可用的大师等级点数 |
| `UsedThirdTreePoint` | int | 第三技能树中已使用的大师等级点数 |
| `FourthTreePoint` | int | *(仅 s7+)* 第四技能树中可用的大师等级点数 |
| `UsedFourthTreePoint` | int | *(仅 s7+)* 第四技能树中已使用的大师等级点数 |

### 货币

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `Money` | int | Zen（金币）数量 |
| `Ruud` | int | *(仅 s7+)* Ruud 货币数量 |

### 重置系统

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `Resets` | int | 已执行的重置总次数 |
| `ResetsToday` | int | *(仅 s7+)* 今日重置次数（每日计数器） |

### VIP 系统

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `VipType` | short | *(仅 s7+)* VIP 等级/类型（s7+ 无则为 -1，s6 无则为 0；查看 VIPSystem.xml 了解等级） |
| `VipMode` | int | *(仅 s7+)* 激活的 VIP 模式（见 Enums.VipMode） |

---

## ActionTickCount 结构

**访问方式：** 通过 `oPlayer.ActionTickCount[index]`（Lua 索引 1-3）

**C++ 类型：** `LuaTickCount`

**重要：** Lua 使用 1 基索引而 C++ 使用 0 基索引！

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `name` | char[16] | 计时器名称（最多 15 个字符，只读） |
| `tick` | ULONGLONG | tick 计数值（只读，使用 `ActionTick.Set()` 修改） |

### 索引映射

| Lua 索引 | C++ 索引 | 描述 |
|-----------|-----------|-------------|
| `ActionTickCount[1]` | `m_ActionTickCount[0]` | 第一个计时器槽位 |
| `ActionTickCount[2]` | `m_ActionTickCount[1]` | 第二个计时器槽位 |
| `ActionTickCount[3]` | `m_ActionTickCount[2]` | 第三个计时器槽位 |

---

## 使用示例

### 示例 1: 基础玩家信息

```lua
function PlayerLogin(oPlayer)
    if oPlayer ~= nil then
        Log.Add(string.format("玩家: %s", oPlayer.Name))
        Log.Add(string.format("等级: %d, 职业: %d", oPlayer.Level, oPlayer.Class))
        Log.Add(string.format("HP: %.0f/%.0f", oPlayer.Life, oPlayer.MaxLife))
        Log.Add(string.format("地图: %d 在 (%d, %d)", oPlayer.MapNumber, oPlayer.X, oPlayer.Y))
    end
end
```

### 示例 2: 访问用户数据

```lua
local oPlayer = Player.GetObjByIndex(iPlayerIndex)
if oPlayer ~= nil then
    local userData = oPlayer.userData
    
    Log.Add(string.format("力量: %d (+%d)", userData.Strength, userData.AddStrength))
    Log.Add(string.format("金币: %d Zen", userData.Money))
    Log.Add(string.format("重置次数: %d", userData.Resets))
    Log.Add(string.format("大师等级: %d", userData.MasterLevel))
end
```

### 示例 3: 动作 Tick 计数器 - 读取

```lua
local oPlayer = Player.GetObjByIndex(iPlayerIndex)
if oPlayer ~= nil then
    -- 读取第一个计时器（Lua 索引 1 = C++ 索引 0）
    local teleportTick = oPlayer.ActionTickCount[1].tick
    local teleportName = oPlayer.ActionTickCount[1].name
    
    Log.Add(string.format("计时器: %s = %llu", teleportName, teleportTick))
    
    -- 检查冷却
    if (Timer.GetTick() - teleportTick) >= 30000 then
        Log.Add("传送冷却已就绪")
    end
end
```

### 示例 4: 动作 Tick 计数器 - 设置

```lua
local oPlayer = Player.GetObjByIndex(iPlayerIndex)
if oPlayer ~= nil then
    -- 使用 ActionTick 函数设置计时器（0 基索引）
    ActionTick.Set(iPlayerIndex, 0, Timer.GetTick(), "Teleport")  -- 计时器槽位 0（Lua 索引 1）
    ActionTick.Set(iPlayerIndex, 1, Timer.GetTick(), "Potion")    -- 计时器槽位 1（Lua 索引 2）
    ActionTick.Set(iPlayerIndex, 2, Timer.GetTick(), "Buff")      -- 计时器槽位 2（Lua 索引 3）
end
```

### 示例 5: 遍历所有计时器

```lua
local oPlayer = Player.GetObjByIndex(iPlayerIndex)
if oPlayer ~= nil then
    for i = 1, 3 do
        local timer = oPlayer.ActionTickCount[i]
        Log.Add(string.format("计时器[%d]: %s = %llu", i, timer.name, timer.tick))
    end
end
```

### 示例 6: 战斗信息

```lua
local oPlayer = Player.GetObjByIndex(iPlayerIndex)
if oPlayer ~= nil then
    Log.Add(string.format("攻击: %d-%d", oPlayer.AttackDamageMin, oPlayer.AttackDamageMax))
    Log.Add(string.format("魔法: %d-%d", oPlayer.MagicDamageMin, oPlayer.MagicDamageMax))
    Log.Add(string.format("防御: %d", oPlayer.Defense))
    Log.Add(string.format("攻击评级: %d", oPlayer.AttackRating))
    Log.Add(string.format("攻击速度: %d", oPlayer.AttackSpeed))
end
```

### 示例 7: 队伍信息

```lua
local oPlayer = Player.GetObjByIndex(iPlayerIndex)
if oPlayer ~= nil then
    if oPlayer.PartyNumber >= 0 then
        local partyCount = Party.GetCount(oPlayer.PartyNumber)
        Log.Add(string.format("玩家在队伍 %d 中，共有 %d 名成员", 
            oPlayer.PartyNumber, partyCount))
        
        -- 获取队伍队长
        local leaderIndex = Party.GetMember(oPlayer.PartyNumber, 1)
        local oLeader = Player.GetObjByIndex(leaderIndex)
        if oLeader ~= nil then
            Log.Add("队伍队长: " .. oLeader.Name)
        end
    else
        Log.Add("玩家不在队伍中")
    end
end
```

### 示例 8: 物品栏访问

```lua
local oPlayer = Player.GetObjByIndex(iPlayerIndex)
if oPlayer ~= nil then
    -- 检查武器槽位
    local weapon = oPlayer:GetInventoryItem(0)
    if weapon ~= nil then
        Log.Add("玩家装备了武器")
    end
    
    -- 检查护甲槽位
    local armor = oPlayer:GetInventoryItem(2)
    if armor ~= nil then
        Log.Add("玩家装备了护甲")
    end
end
```

### 示例 9: 艾尔特系统

```lua
local oPlayer = Player.GetObjByIndex(iPlayerIndex)
if oPlayer ~= nil then
    Log.Add(string.format("艾尔特攻击: %d-%d (PvM)", 
        oPlayer.PentagramAttackMin, oPlayer.PentagramAttackMax))
    Log.Add(string.format("艾尔特攻击: %d-%d (PvP)", 
        oPlayer.PentagramAttackMinPvP, oPlayer.PentagramAttackMaxPvP))
    Log.Add(string.format("艾尔特防御: %d (PvM)", oPlayer.PentagramDefense))
    Log.Add(string.format("暴击率: %d%%", oPlayer.PentagramCriticalDamageRate))
end
```

### 示例 10: VIP 系统

```lua
local oPlayer = Player.GetObjByIndex(iPlayerIndex)
if oPlayer ~= nil then
    local userData = oPlayer.userData
    
    if userData.VipType >= 0 then
        Log.Add(string.format("VIP 类型: %d, 模式: %d", userData.VipType, userData.VipMode))
    else
        Log.Add("玩家不是 VIP")
    end
end
```

---

## 重要注意事项

1. **只读字段：** 大多数字段是只读的。使用适当的命名空间函数修改值：
   - 使用 `Player.SetMoney()` 修改金币
   - 使用 `Stats.Set()` 修改属性
   - 使用 `ActionTick.Set()` 修改计时器

2. **空值检查：** 访问字段前始终检查玩家对象是否为 `nil`：
   ```lua
   local oPlayer = Player.GetObjByIndex(iPlayerIndex)
   if oPlayer ~= nil then
       -- 安全访问字段
   end
   ```

3. **索引差异：** 
   - Lua 数组使用 1 基索引
   - C++ 函数使用 0 基索引
   - Lua 中的 `ActionTickCount[1]` = C++ 中的索引 0

4. **性能：** 直接字段访问非常快。可自由使用读取值。

5. **类型安全：** 字段返回其原生类型。在大多数情况下无需类型转换。

---

## 另请参见

- [GLOBAL_FUNCTIONS](Global-Functions.md) - 完整函数参考
- [CALLBACKS](Callbacks.md) - 事件回调参考
- `Constants.lua` - 游戏常量
- `Enums.lua` - 枚举值
