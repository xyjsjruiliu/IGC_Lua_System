# Monster 属性结构参考

MonsterAttr C++ 对象的参考文档，该对象通过 Monster.GetAttr() 暴露给 Lua 使用。

---

## 目录

- [MonsterAttr](#monsterattr)
  - [Basic Stats](#基础属性)
  - [Combat Stats](#战斗属性)
  - [Movement & Timing](#移动与时间属性)
  - [Pentagram Stats](#艾尔特属性)
  - [Advanced Stats](#进阶属性)
  - [Flags](#标记字段)
  - [Methods](#方法)

---

## MonsterAttr

由 Monster.GetAttr(iClass) 返回。表示从 MonsterAttr.bmd 加载的怪物职业静态属性配置。

> ⚠️ 此对象无法在 Lua 中创建——它是只能通过 Monster.GetAttr() 访问的 C++ 对象。

### 基础属性

| Field | Type | Access | Description |
|-------|------|--------|-------------|
| `Index` | integer | readonly | Monster class index |
| `Level` | integer | read-write | Monster level |
| `ScriptHP` | integer | read-write | Script-defined HP override |
| `HP` | integer | read-write | Maximum HP |
| `MP` | integer | read-write | Maximum MP |
| `Attribute` | integer | readonly | Monster attribute flags |
| `AttackType` | integer | readonly | Attack type |
| `IsTrap` | boolean | readonly | Is a trap object |

### 战斗属性

| Field | Type | Access | Description |
|-------|------|--------|-------------|
| `DamageMin` | integer | read-write | Minimum attack damage |
| `DamageMax` | integer | read-write | Maximum attack damage |
| `Defense` | integer | read-write | Defense rating |
| `MagicDefense` | integer | read-write | Magic defense rating |
| `AttackRating` | integer | read-write | Attack success rating |
| `DefenseRating` | integer | read-write | Defense success rate |
| `ExtraDefense` | integer | read-write | Extra defense *(s7+ only)* |
| `ExtraDamageMin` | integer | read-write | Extra minimum damage *(s7+ only)* |
| `ExtraDamageMax` | integer | read-write | Extra maximum damage *(s7+ only)* |
| `DamageCorrection` | integer | read-write | Damage correction factor *(s7+ only)* |

### 移动与时间属性

| Field | Type | Access | Description |
|-------|------|--------|-------------|
| `MoveRange` | integer | read-write | Movement range (tiles) |
| `AttackRange` | integer | read-write | Attack range (tiles) |
| `ViewRange` | integer | read-write | View/detection range (tiles) |
| `MoveSpeed` | integer | read-write | Movement speed |
| `AttackSpeed` | integer | read-write | Attack speed |
| `RegenTime` | integer | read-write | Respawn time (ms) |

### 艾尔特属性

| Field | Type | Access | Description |
|-------|------|--------|-------------|
| `PentagramMainAttribute` | integer | read-write | Main pentagram attribute |
| `PentagramAttributePattern` | integer | read-write | Pentagram attribute pattern |
| `PentagramDefense` | integer | read-write | Pentagram defense |
| `PentagramAttackMin` | integer | read-write | Pentagram minimum attack |
| `PentagramAttackMax` | integer | read-write | Pentagram maximum attack |
| `PentagramAttackRate` | integer | read-write | Pentagram attack rating |
| `PentagramDefenseRate` | integer | read-write | Pentagram defense rating |

### 进阶属性

| Field | Type | Access | Description |
|-------|------|--------|-------------|
| `MonsterExpLevel` | integer | read-write | Monster exp level modifier |
| `CriticalDamageResistance` | integer | read-write | Critical damage resistance |
| `ExcellentDamageResistance` | integer | read-write | Excellent damage resistance |
| `DebuffApplyResistance` | integer | read-write | Debuff apply resistance |
| `DamageAbsorb` | integer | read-write | Damage absorption |

### 标记字段

| Field | Type | Access | Description |
|-------|------|--------|-------------|
| `IsEliteMonster` | boolean | read-write | Is an elite monster |
| `IsRadiancePunishImmune` | boolean | read-write | Immune to radiance punishment |

### 方法

#### GetName

```lua
attr:GetName()
```

**返回值:** `string` — 怪物名称.

---

#### GetResistance

```lua
attr:GetResistance(iType)
```

**参数:**
- `iType` (integer): Resistance type index (0 to MAX_RESISTENCE_TYPE-1)

**返回值:** `integer` — Resistance value, or `-1` if `iType` is out of range.

---

## Example

```lua
local attr = Monster.GetAttr(275) -- 昆顿
if attr ~= nil then
    Log.Add(string.format("[%s] 等级: %d, HP: %d, 防御: %d",
        attr:GetName(), attr.Level, attr.HP, attr.Defense))

    -- 检查火属性抗性（类型 0）
    local fireRes = attr:GetResistance(0)
    Log.Add(string.format("火属性抗性: %d", fireRes))
end
```
