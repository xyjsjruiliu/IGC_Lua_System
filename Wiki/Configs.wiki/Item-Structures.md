# 物品结构参考

暴露给 Lua 的物品相关 C++ 结构体完整参考。

---

## 目录

- [ItemAttr 结构](#itemattr-结构)
- [CreateItemInfo 结构](#createiteminfo-结构)
- [ItemInfo 结构](#iteminfo-结构)
- [BagItem 结构](#bagitem-结构)
- [BagItemResult 结构](#bagitemresult-结构)
- [使用示例](#使用示例)

---

## ItemAttr 结构

**访问方式：** 通过 `Item.GetAttr(itemId)` 或 `GetItemAttr(itemId)`

**C++ 类型：** `ITEM_ATTRIBUTE`

**描述：** 来自 ItemList.txt 的只读物品模板数据。包含基础物品统计、需求和属性。

**注意：** 所有字段都是**只读的**。此结构不能被实例化。

### 基础物品信息

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `HasItemInfo` | BYTE | 物品信息是否已加载有效 (0-1) |
| `Level` | WORD | 物品等级 (0-15) |
| `Serial` | char | 物品序列号是否启用 (0-1) |

### 物品尺寸

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `Width` | BYTE | 物品栏宽度 (1-2) |
| `Height` | BYTE | 物品栏高度 (1-4) |

### 物品标志

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `TwoHands` | BYTE | 是否为双手物品 (0-1) |
| `Option` | BYTE | 物品选项标志 (0-1) |
| `QuestItem` | bool | 是否为任务物品 (0-1) |
| `SetAttribute` | BYTE | 套装物品属性/ID (0-255) |

### 战斗属性

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `DamageMin` | WORD | 最小物理伤害 (0-65535) |
| `DamageMax` | WORD | 最大物理伤害 (0-65535) |
| `AttackRate` | WORD | *(仅 s7+)* 攻击成功率加成 (0-65535) |
| `DefenseRate` | WORD | 防御/格挡成功率加成 (0-65535) |
| `Defense` | WORD | 防御值 (0-65535) |
| `CombatPower` | int | *(仅 s7+)* 战斗功率评级 |
| `MagicPower` | int | 魔法功率评级 |

### 速度

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `AttackSpeed` | BYTE | 攻击速度加成 (0-255) |
| `WalkSpeed` | BYTE | 行走速度加成 (0-255) |

### 耐久度

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `Durability` | BYTE | 最大耐久度 (0-255) |
| `MagicDurability` | BYTE | 魔杖类物品的最大魔法耐久度 (0-255) |

### 需求

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `ReqLevel` | WORD | 所需角色等级 (0-15) |
| `ReqStrength` | WORD | 所需力量属性 (0-65535) |
| `ReqAgility` | WORD | 所需敏捷属性 (0-65535) |
| `ReqEnergy` | WORD | 所需智力属性 (0-65535) |
| `ReqVitality` | WORD | 所需体力属性 (0-65535) |
| `ReqCommand` | WORD | 所需指挥属性 (0-65535) |

### 经济价值

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `Value` | WORD | 基础物品价值 (0-65535) |
| `BuyMoney` | int | 从 NPC 购买价格 |

### 物品分类

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `ItemKindA` | BYTE | 主要物品类别 (0-255) |
| `ItemKindB` | BYTE | 次要物品类别/子类型 (0-255) |
| `ItemCategory` | int | 物品类别分类 |
| `ItemSlot` | int | 装备槽位（可穿戴物品为 0-11） |

### 抗性

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `ResistanceType` | char | 主要抗性类型 (0-6) |

### 技能/精通

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `SkillType` | int | 关联的技能类型 |
| `MasteryGrade` | BYTE | *(仅 s7+)* 精通系统等级 |
| `LegendaryGrade` | BYTE | *(仅 s7+)* 传说物品等级 |

### 艾尔特系统

> ⚠️ **s6 不可用** — 以下所有艾尔特字段在 s6 版本中不存在。

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `PentagramType` | BYTE | 艾尔特元素类型 (1-2) |
| `MasteryPentagram` | bool | 艾尔特精通是否启用 |
| `ElementalDamage` | int | 元素伤害值 |
| `ElementalDefense` | int | 元素防御值 |

### 物品行为标志

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `Dump` | BYTE | 可丢弃 (0-1) |
| `Transaction` | BYTE | 可交易给其他玩家 (0-1) |
| `PersonalStore` | BYTE | 可在个人商店出售 (0-1) |
| `StoreWarehouse` | BYTE | 可存入仓库 (0-1) |
| `SellToNPC` | BYTE | 可出售给 NPC 商人 (0-1) |
| `ExpensiveItem` | BYTE | *(仅 s7+)* 是否标记为高价物品 (0-1) |
| `Repair` | BYTE | 可修理 (0-1) |
| `ItemOverlap` | BYTE | 可堆叠（用于堆叠物品）(0-255) |
| `NonValue` | BYTE | *(仅 s7+)* 无货币价值 (0-1) |

### 方法

#### GetName

```lua
itemAttr:GetName()
```

**返回：** `string` - 物品名称（最多 96 个字符）

**用法：**
```lua
local itemAttr = Item.GetAttr(itemId)
if itemAttr ~= nil then
    local itemName = itemAttr:GetName()
    Log.Add("物品: " .. itemName)
end
```

---

#### GetRequireClass

```lua
itemAttr:GetRequireClass(iClass)
```

**参数：**
- `iClass` (int): 职业索引 (0 到 15)

**返回：** `int` - 所需最低职业进化等级：
- `0` = 完全无法使用
- `1` = 从基础职业（一转）开始可用
- `2` = 从二转开始可用
- `3` = 从三转开始可用
- `4` = 从四转开始可用
- `5` = 仅在五转可用
- `-1` = 无效的职业索引

**用法：**
```lua
local itemAttr = Item.GetAttr(itemId)
local reqEvo = itemAttr:GetRequireClass(Enums.CharacterClassType.WIZARD)

if reqEvo == 0 then
    Log.Add("法师无法使用此物品")
elseif reqEvo > 0 then
    Log.Add(string.format("需要职业进化等级: %d", reqEvo))
end
```

---

#### GetResistance

```lua
itemAttr:GetResistance(iType)
```

**参数：**
- `iType` (int): 抗性类型索引 (0 到 MAX_RESISTANCE_TYPE-1)

**返回：** `int` - 抗性值 (0-255，无效类型为 -1)

**用法：**
```lua
local itemAttr = Item.GetAttr(itemId)
local fireRes = itemAttr:GetResistance(Enums.ResistanceType.FIRE)

if fireRes > 0 then
    Log.Add(string.format("火焰抗性: %d", fireRes))
end
```

---

## CreateItemInfo 结构

**访问方式：** 通过实例化: `CreateItemInfo.new()`

**C++ 类型：** `ITEM_CREATE_INFO`

**描述：** 用于创建新物品的结构体。与 `Item.Create()` 或 `ItemCreateSend()` 一起使用。

### 位置

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `MapNumber` | WORD | 物品生成的地图编号 |
| `X` | BYTE | X 坐标 |
| `Y` | BYTE | Y 坐标 |

### 物品标识

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `ItemId` | int | 物品类型/ID（使用 `Helpers.MakeItemId()`） |
| `ItemLevel` | BYTE | 物品等级 (0-15) |

### 耐久度

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `Durability` | BYTE | 物品耐久度值 |

### 基础选项

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `Option1` | BYTE | 幸运选项（0 = 无幸运，1 = 有幸运） |
| `Option2` | BYTE | 技能选项（0 = 无技能，1 = +技能） |
| `Option3` | BYTE | 追加选项等级 (0-7，每级增加 +4/+8/+12/+16/+20/+24/+28) |

### 战利品系统

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `LootIndex` | int | 物品所属的玩家索引（-1 = 任何人都可捡取） |

### 高级选项

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `NewOption` | BYTE | 卓越选项位掩码 |
| `SetOption` | BYTE | 套装/古代选项 |
| `ItemOptionEx` | BYTE | *(仅 s7+)* 物品选项 ex（380 选项） |

### 时间相关

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `Duration` | time_t | 物品持续时间戳 |

### 艾尔特系统

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `MainAttribute` | BYTE | *(仅 s7+)* 艾尔特主属性 |

### 物品栏

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `TargetInvenPos` | BYTE | *(仅 s7+)* 目标物品栏位置（255 = 自动查找槽位） |

### 宠物系统

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `PetCreate` | bool | 创建为宠物物品 |

### 方法

**注意：** 所有数组方法使用 1 基索引（Lua 标准）

#### GetSocket / SetSocket

```lua
itemInfo:GetSocket(index)
itemInfo:SetSocket(index, value)
```

**参数：**
- `index` (int): 凹槽索引（1 到 MAX_SOCKET_OPTION）
- `value` (int): 凹槽选项值 (0-255)

**返回：** `int` - 凹槽值（无效索引为 -1）

---

#### GetHarmonyOptionType / SetHarmonyOptionType *(仅 s7+)*

```lua
itemInfo:GetHarmonyOptionType(index)
itemInfo:SetHarmonyOptionType(index, value)
```

**参数：**
- `index` (int): 再生选项（1 到 MAX_HARMONY_OPTION）
- `value` (int): 再生类型 (0-255)

**返回：** `int` - 再生类型（无效索引为 -1）

---

#### GetHarmonyOptionValue / SetHarmonyOptionValue *(仅 s7+)*

```lua
itemInfo:GetHarmonyOptionValue(index)
itemInfo:SetHarmonyOptionValue(index, value)
```

**参数：**
- `index` (int): 再生选项（1 到 MAX_HARMONY_OPTION）
- `value` (int): 再生值 (-32768 到 32767)

**返回：** `int` - 再生值（无效索引为 -1）

---

#### GetOptSlot / SetOptSlot *(仅 s7+)*

```lua
itemInfo:GetOptSlot(index)
itemInfo:SetOptSlot(index, value)
```

**参数：**
- `index` (int): 选项槽位（1 到 MAX_OPT_SLOT）
- `value` (int): 选项值 (0-255)

**返回：** `int` - 选项值（无效索引为 -1）

---

## ItemInfo 结构

**访问方式：** 通过 `ItemInfo.new()` 或 `oPlayer:GetInventoryItem(index)`

**C++ 类型：** `stItemInfo`

**描述：** 表示具有所有属性和选项的实际物品实例。

### 物品标识

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `SerialNumber` | UINT64 | 物品唯一序列号 |
| `HasSerial` | char | 是否检查序列号 (0-1) |
| `Type` | short | 物品类型/ID |
| `Level` | short | 物品等级 (0-15) |
| `Slot` | BYTE | 物品装备槽位 |

### 物品属性

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `TwoHands` | BYTE | 是否为双手物品 (0-1) |
| `AttackSpeed` | BYTE | 攻击速度 |
| `WalkSpeed` | BYTE | 行走速度 |

### 伤害

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `DamageMin` | WORD | 最小伤害 |
| `DamageMax` | WORD | 最大伤害 |

### 防御

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `Defense` | WORD | 防御值 |
| `DefenseRate` | WORD | 防御率（成功格挡） |

### 评级

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `AttackRate` | WORD | *(仅 s7+)* 攻击评级 |
| `MagicPower` | WORD | 魔法功率 |
| `CurseSpell` | WORD | 诅咒魔法 |
| `CombatPower` | WORD | *(仅 s7+)* 战斗功率 |

### 耐久度

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `Durability` | float | 当前耐久度 |
| `DurabilitySmall` | WORD | 耐久度小值 |
| `BaseDurability` | float | 基础耐久度 |

### 需求

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `ReqLevel` | WORD | 需求等级 |
| `ReqStrength` | WORD | 需求力量 |
| `ReqAgility` | WORD | 需求敏捷 |
| `ReqEnergy` | WORD | 需求智力 |
| `ReqVitality` | WORD | 需求体力 |
| `ReqCommand` | WORD | 需求指挥 |

### 经济

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `Value` | int | 物品价值 |
| `SellMoney` | UINT64 | 出售价格 |
| `BuyMoney` | UINT64 | 购买价格 |

### 状态标志

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `IsItemExist` | bool | 物品是否存在 |
| `IsValidItem` | bool | 是否为有效物品 |
| `SkillChange` | bool | 技能改变标志 |
| `QuestItem` | bool | 是否为任务物品 |

### 基础选项

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `Option1` | BYTE | 幸运 (0-1) |
| `Option2` | BYTE | 技能 (0-1) |
| `Option3` | BYTE | 追加选项 (0-7) |
| `NewOption` | BYTE | 卓越选项（位掩码） |

### 高级选项

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `SetOption` | BYTE | 套装选项 |
| `SetAddStat` | BYTE | 套装附加属性 |
| `ItemOptionEx` | BYTE | 物品选项 ex（380 选项） |
| `BonusSocketOption` | BYTE | 奖励凹槽选项 |

### 宠物物品

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `IsLoadPetItemInfo` | BOOL | 宠物物品信息是否已加载 |
| `PetItemLevel` | int | 宠物物品等级 |
| `PetItemExp` | UINT64 | 宠物物品经验 |

### 附加选项

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `ImproveDurabilityRate` | BYTE | 提升耐久度比率 |
| `PeriodItemOption` | BYTE | 期限物品选项标志 |
| `IsLoadHarmonyOptionInfo` | BOOL | *(仅 s7+)* 再生选项信息是否已加载 |
| `ElementalDefense` | WORD | *(仅 s7+)* 元素防御 |

### 传说选项

> ⚠️ **s6 不可用** — 传说选项字段在 s6 版本中不存在。

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `LegendaryAddOptionType` | BYTE | 传说附加选项类型 |
| `LegendaryAddOptionValue` | WORD | 传说附加选项值 |

### 方法

**注意：** 
- `GetRequireClass` 和 `GetResistance` 使用 0 基索引
- `GetSocket`、`GetHarmonyOption` 和 `GetOptSlot` 使用 1 基索引

#### GetRequireClass / SetRequireClass

```lua
item:GetRequireClass(index)
item:SetRequireClass(index, value)
```

**参数：**
- `index` (int): 职业索引（0-15，0 基）
- `value` (int): 职业需求 (0-5)

**返回：** `int` - 职业需求（无效为 -1）

---

#### GetResistance / SetResistance

```lua
item:GetResistance(index)
item:SetResistance(index, value)
```

**参数：**
- `index` (int): 抗性类型（0 基）
- `value` (int): 抗性值

**返回：** `int` - 抗性值（无效为 -1）

---

#### GetSocket / SetSocket

```lua
item:GetSocket(index)
item:SetSocket(index, value)
```

**参数：**
- `index` (int): 凹槽索引（1 基）
- `value` (int): 凹槽值 (0-255)

**返回：** `int` - 凹槽值（无效为 -1）

---

#### GetHarmonyOptionType / SetHarmonyOptionType *(仅 s7+)*

```lua
item:GetHarmonyOptionType(index)
item:SetHarmonyOptionType(index, value)
```

**参数：**
- `index` (int): 再生选项（1 基）
- `value` (int): 再生类型 (0-255)

**返回：** `int` - 再生类型（无效为 -1）

---

#### GetHarmonyOptionValue / SetHarmonyOptionValue *(仅 s7+)*

```lua
item:GetHarmonyOptionValue(index)
item:SetHarmonyOptionValue(index, value)
```

**参数：**
- `index` (int): 再生选项（1 基）
- `value` (int): 再生值 (0-65535)

**返回：** `int` - 再生值（无效为 -1）

---

#### GetOptSlot / SetOptSlot *(仅 s7+)*

```lua
item:GetOptSlot(index)
item:SetOptSlot(index, value)
```

**参数：**
- `index` (int): 选项槽位（1 基）
- `value` (int): 选项值 (0-255)

**返回：** `int` - 选项值（无效为 -1）

---

#### Convert

```lua
item:Convert()
```

**描述：** 根据当前选项重新计算物品属性

**用法：**
```lua
local item = ItemInfo.new()
item.Type = Helpers.MakeItemId(0, 0)
item.Level = 9
item.Option1 = 1
item.Option2 = 1
item:Convert()  -- 应用所有选项
```

---

#### Clear

```lua
item:Clear()
```

**描述：** 清除当前位置的物品（移除所有物品数据）

**用法：**
```lua
local item = player.Inventory[12]
if item ~= nil and item.Type > 0 then
    item:Clear()  -- 从物品栏 12 号槽位移除物品
end

-- 清除事件物品栏中的所有物品
for i = 0, Constants.EVENT_INVENTORY_SIZE - 1 do
    local item = player.EventInventory[i]
    if item ~= nil and item.Type > 0 then
        item:Clear()
    end
end
```

---


## BagItem 结构

**访问方式：** 通过物品袋系统回调

**C++ 类型：** `BAG_SECTION_ITEM`

**描述：** 用于随机掉落生成的物品袋文件中的物品模板。

### 字段

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `ItemType` | BYTE | 物品类型 (0-21) |
| `ItemIndex` | WORD | 物品索引 (0-511) |
| `ItemMinLevel` | BYTE | 最小物品等级 (0-15) |
| `ItemMaxLevel` | BYTE | 最大物品等级 (0-15) |
| `Skill` | short | 是否有技能选项 (-1, 0, 1) |
| `Luck` | short | 是否有幸运选项 (-1, 0, 1) |
| `Option` | short | 是否有追加选项 (-1, 0, 1-7) |
| `Anc` | short | 是否为古代/套装物品 (0-1) |
| `Socket` | short | 是否为凹槽物品 (-2, 0-5) |
| `Exc` | short | 🔵 *(仅 s6)* 是否为卓越物品 (-1, 0-1) |
| `Elemental` | short | *(仅 s7+)* 是否为元素物品 (-1, 0-5) |
| `ErrtelRank` | short | *(仅 s7+)* 错误等级是否启用 (1-5) |
| `MuunEvolutionItemType` | BYTE | *(仅 s7+)* Muun 进化物品类型 |
| `MuunEvolutionItemIndex` | WORD | *(仅 s7+)* Muun 进化物品索引 |
| `Durability` | WORD | 物品耐久度 |
| `Duration` | DWORD | 物品持续时间 |

### 方法

**注意：** 所有数组方法使用 1 基索引

#### GetSocket / SetSocket *(仅 s7+)*

```lua
bagItem:GetSocket(index)
bagItem:SetSocket(index, value)
```

**参数：**
- `index` (int): 凹槽索引（1 基）
- `value` (int): 凹槽值

**返回：** `int` - 凹槽值（无效为 -1）

---

#### GetExc / SetExc *(仅 s7+)*

```lua
bagItem:GetExc(index)
bagItem:SetExc(index, value)
```

**参数：**
- `index` (int): 卓越选项索引（1 基）
- `value` (int): 卓越选项值

**返回：** `int` - 卓越选项（无效为 -1）

---

#### GetOptSlot / SetOptSlot *(仅 s7+)*

```lua
bagItem:GetOptSlot(index)
bagItem:SetOptSlot(index, value)
```

**参数：**
- `index` (int): 选项槽位（1 基）
- `value` (int): 选项值

**返回：** `int` - 选项值（无效为 -1）

---

## BagItemResult 结构

**访问方式：** 通过物品袋系统回调（物品掉落传递给回调后的结果对象）

**C++ 类型：** `BAG_ITEM_RESULT_LUA`

**描述：** 描述从物品袋实际创建/掉落的物品。传递给袋子回调作为结果。

### 位置

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `MapNumber` | WORD | 物品掉落的地图 |
| `X` | BYTE | X 坐标 |
| `Y` | BYTE | Y 坐标 |

### 物品标识

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `ItemNum` | int | 物品类型 ID |
| `ItemLevel` | BYTE | 物品等级 |
| `ItemDurability` | WORD | 物品耐久度 |

### 基础选项

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `Option1` | BYTE | 幸运选项 (0-1) |
| `Option2` | BYTE | 技能选项 (0-1) |
| `Option3` | BYTE | 追加选项等级 (0-7) |

### 高级选项

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `SetOption` | BYTE | 套装/古代选项 |
| `Duration` | time_t | 物品持续时间 |
| `ExcOption` | BYTE | 🔵 *(仅 s6)* 卓越选项位掩码 |
| `SocketCount` | int | 🔵 *(仅 s6)* 凹槽数量 |

### 状态标志 *(仅 s7+)*

> ⚠️ **s6 不可用** — 以下所有字段在 s6 版本中不存在。

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `IsSocket` | BYTE | 物品是否有凹槽 |
| `IsElemental` | BYTE | 物品是否为元素 |
| `ErrtelRank` | BYTE | 错误等级 |
| `MuunEvolutionItemNum` | int | Muun 进化物品编号 |
| `UseGremoryCase` | bool | 通过格雷莫里箱子掉落 |
| `GremoryCaseType` | BYTE | 格雷莫里箱子类型 |
| `GremoryCaseGiveType` | BYTE | 格雷莫里箱子给予类型 |
| `GremoryCaseReceiptDuration` | DWORD | 格雷莫里箱子领取持续时间 |

### 方法 *(仅 s7+)*

> ⚠️ **s6 不可用** — 以下方法在 s6 版本中不存在。

#### GetSocket / SetSocket

```lua
result:GetSocket(index)
result:SetSocket(index, value)
```

**参数：**
- `index` (int): 凹槽索引（1 基）
- `value` (int): 凹槽值

**返回：** `int` - 凹槽值（无效为 -1）

---

#### GetExc / SetExc

```lua
result:GetExc(index)
result:SetExc(index, value)
```

**参数：**
- `index` (int): 卓越选项索引（1 基）
- `value` (int): 卓越选项值

**返回：** `int` - 卓越选项（无效为 -1）

---

#### GetOptSlot / SetOptSlot

```lua
result:GetOptSlot(index)
result:SetOptSlot(index, value)
```

**参数：**
- `index` (int): 选项槽位（1 基）
- `value` (int): 选项值

**返回：** `int` - 选项值（无效为 -1）

---

## 使用示例

### 示例 1: 获取物品属性

```lua
local itemId = Helpers.MakeItemId(0, 0)  -- 短剑
local itemAttr = Item.GetAttr(itemId)

if itemAttr ~= nil then
    local itemName = itemAttr:GetName()
    Log.Add(string.format("物品: %s", itemName))
    Log.Add(string.format("伤害: %d-%d", itemAttr.DamageMin, itemAttr.DamageMax))
    Log.Add(string.format("需求力量: %d", itemAttr.ReqStrength))
    Log.Add(string.format("大小: %dx%d", itemAttr.Width, itemAttr.Height))
end
```

### 示例 2: 创建基础物品

```lua
local itemInfo = CreateItemInfo.new()
itemInfo.ItemId = Helpers.MakeItemId(14, 13)  -- 祝福宝石
itemInfo.ItemLevel = 0
itemInfo.Durability = 1
itemInfo.LootIndex = iPlayerIndex
itemInfo.TargetInvenPos = 255  -- 自动查找槽位

Item.Create(iPlayerIndex, itemInfo)
```

### 示例 3: 创建卓越物品

```lua
local itemInfo = CreateItemInfo.new()
itemInfo.MapNumber = oPlayer.MapNumber
itemInfo.X = oPlayer.X
itemInfo.Y = oPlayer.Y
itemInfo.ItemId = Helpers.MakeItemId(0, 1)  -- 短剑
itemInfo.ItemLevel = 9
itemInfo.Durability = 255
itemInfo.Option1 = 1  -- 幸运
itemInfo.Option2 = 1  -- 技能
itemInfo.Option3 = 4  -- +16
itemInfo.NewOption = 0x3F  -- 所有 6 个卓越选项
itemInfo.LootIndex = iPlayerIndex
itemInfo.TargetInvenPos = 255

Item.Create(iPlayerIndex, itemInfo)
```

### 示例 4: 检查物品栏物品

```lua
local oPlayer = Player.GetObjByIndex(iPlayerIndex)
if oPlayer ~= nil then
    local weapon = oPlayer:GetInventoryItem(Constants.EQUIPMENT_SLOT_LEFT_HAND)
    
    if weapon ~= nil and weapon.IsItemExist then
        Log.Add(string.format("武器: 类型 %d +%d", weapon.Type, weapon.Level))
        Log.Add(string.format("伤害: %d-%d", weapon.DamageMin, weapon.DamageMax))
        Log.Add(string.format("耐久度: %.1f/%.1f", weapon.Durability, weapon.BaseDurability))
        
        if weapon.Option1 == 1 then
            Log.Add("有幸运")
        end
        
        if weapon.NewOption > 0 then
            Log.Add("有卓越选项")
        end
    end
end
```

### 示例 5: 遍历物品栏

```lua
local oPlayer = Player.GetObjByIndex(iPlayerIndex)
if oPlayer ~= nil then
    for i = 0, Constants.MAIN_INVENTORY_SIZE - 1 do
        local item = oPlayer:GetInventoryItem(i)
        
        if item ~= nil and item.IsItemExist then
            local itemAttr = Item.GetAttr(item.Type)
            if itemAttr ~= nil then
                local itemName = itemAttr:GetName()
                Log.Add(string.format("槽位 %d: %s +%d", i, itemName, item.Level))
            end
        end
    end
end
```

### 示例 6: 检查职业需求

```lua
local itemAttr = Item.GetAttr(itemId)
if itemAttr ~= nil then
    local reqEvo = itemAttr:GetRequireClass(oPlayer.Class)
    local playerEvo = Player.GetEvo(oPlayer.Index)
    
    if reqEvo == 0 then
        Message.Send(0, oPlayer.Index, 0, "你的职业无法使用此物品")
    elseif playerEvo < reqEvo then
        Message.Send(0, oPlayer.Index, 0, string.format("需要职业进化等级 %d", reqEvo))
    else
        Message.Send(0, oPlayer.Index, 0, "你可以使用此物品")
    end
end
```

### 示例 7: 创建带凹槽选项的物品

```lua
local itemInfo = CreateItemInfo.new()
itemInfo.ItemId = Helpers.MakeItemId(0, 0)
itemInfo.ItemLevel = 13
itemInfo.Durability = 255
itemInfo.LootIndex = iPlayerIndex
itemInfo.TargetInvenPos = 255

-- 设置所有 5 个凹槽
for i = 1, Constants.MAX_SOCKET_OPTION do
    itemInfo:SetSocket(i, 50)  -- 凹槽值 50
end

Item.Create(iPlayerIndex, itemInfo)
```

### 示例 8: 创建带再生选项的物品

```lua
local itemInfo = CreateItemInfo.new()
itemInfo.ItemId = Helpers.MakeItemId(0, 0)
itemInfo.ItemLevel = 15
itemInfo.Durability = 255

-- 设置再生选项
itemInfo:SetHarmonyOptionType(1, 5)  -- 再生类型 5
itemInfo:SetHarmonyOptionValue(1, 100)  -- 再生值 100

itemInfo.LootIndex = iPlayerIndex
itemInfo.TargetInvenPos = 255

Item.Create(iPlayerIndex, itemInfo)
```

### 示例 9: 修改现有物品

```lua
local oPlayer = Player.GetObjByIndex(iPlayerIndex)
if oPlayer ~= nil then
    local item = oPlayer:GetInventoryItem(0)
    
    if item ~= nil and item.IsItemExist then
        -- 添加凹槽选项
        item:SetSocket(1, 50)
        
        -- 更新客户端物品
        Inventory.SendUpdate(iPlayerIndex, 0)
    end
end
```

### 示例 10: 检查物品抗性

```lua
local itemAttr = Item.GetAttr(itemId)
if itemAttr ~= nil then
    local fireRes = itemAttr:GetResistance(Enums.ResistanceType.FIRE)
    local iceRes = itemAttr:GetResistance(Enums.ResistanceType.ICE)
    local lightRes = itemAttr:GetResistance(Enums.ResistanceType.LIGHTNING)
    
    Log.Add(string.format("火: %d, 冰: %d, 雷: %d", fireRes, iceRes, lightRes))
end
```

---

## 重要注意事项

1. **ItemAttr vs ItemInfo：**
   - `ItemAttr` = 来自 ItemList.txt 的只读模板（通过 `Item.GetAttr()` 获取）
   - `ItemInfo` = 具有耐久度、选项等的实际物品实例

2. **数组索引：**
   - `GetRequireClass()` 和 `GetResistance()` 使用 0 基索引（C++ 风格）
   - `GetSocket()`、`GetHarmonyOption()`、`GetOptSlot()` 使用 1 基索引（Lua 风格）

3. **物品 ID 创建：**
   - 始终使用 `Helpers.MakeItemId(ItemType, ItemIndex)`
   - 公式：`ItemId = ItemType * 512 + ItemIndex`

4. **空值检查：**
   - 访问物品对象前始终检查是否为 `nil`
   - 检查 ItemInfo 对象的 `IsItemExist` 标志

5. **Option3 值：**
   - 0 = +0, 1 = +4, 2 = +8, 3 = +12, 4 = +16, 5 = +20, 6 = +24, 7 = +28

6. **卓越选项位掩码：**
   - `0x01` = 第 1 选项，`0x02` = 第 2 选项，`0x04` = 第 3 选项
   - `0x08` = 第 4 选项，`0x10` = 第 5 选项，`0x20` = 第 6 选项
   - `0x3F` = 所有 6 个选项

---

## 另请参见

- [[PLAYER|Player-Structure]] - 玩家对象参考
- [[Global-Functions|Global-Functions]] - 全局函数
- `Defines/Constants.lua` - 物品常量
- `Defines/Enums.lua` - 物品枚举
- `Defines/Helpers.lua` - 辅助函数
