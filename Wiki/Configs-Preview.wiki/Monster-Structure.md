# Monster Structure Reference

Reference for the `MonsterAttr` C++ object exposed to Lua via `Monster.GetAttr()`.

---

## Table of Contents

- [MonsterAttr](#monsterattr)
  - [Basic Stats](#basic-stats)
  - [Combat Stats](#combat-stats)
  - [Movement & Timing](#movement--timing)
  - [Pentagram Stats](#pentagram-stats)
  - [Advanced Stats](#advanced-stats)
  - [Flags](#flags)
  - [Methods](#methods)

---

## MonsterAttr

Returned by `Monster.GetAttr(iClass)`. Represents the static attribute configuration of a monster class loaded from `MonsterAttr.bmd`.

> ⚠️ This object cannot be created in Lua — it is a C++ object accessible only through `Monster.GetAttr()`.

### Basic Stats

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

### Combat Stats

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

### Movement & Timing

| Field | Type | Access | Description |
|-------|------|--------|-------------|
| `MoveRange` | integer | read-write | Movement range (tiles) |
| `AttackRange` | integer | read-write | Attack range (tiles) |
| `ViewRange` | integer | read-write | View/detection range (tiles) |
| `MoveSpeed` | integer | read-write | Movement speed |
| `AttackSpeed` | integer | read-write | Attack speed |
| `RegenTime` | integer | read-write | Respawn time (ms) |

### Pentagram Stats

| Field | Type | Access | Description |
|-------|------|--------|-------------|
| `PentagramMainAttribute` | integer | read-write | Main pentagram attribute |
| `PentagramAttributePattern` | integer | read-write | Pentagram attribute pattern |
| `PentagramDefense` | integer | read-write | Pentagram defense |
| `PentagramAttackMin` | integer | read-write | Pentagram minimum attack |
| `PentagramAttackMax` | integer | read-write | Pentagram maximum attack |
| `PentagramAttackRate` | integer | read-write | Pentagram attack rating |
| `PentagramDefenseRate` | integer | read-write | Pentagram defense rating |

### Advanced Stats

| Field | Type | Access | Description |
|-------|------|--------|-------------|
| `MonsterExpLevel` | integer | read-write | Monster exp level modifier |
| `CriticalDamageResistance` | integer | read-write | Critical damage resistance |
| `ExcellentDamageResistance` | integer | read-write | Excellent damage resistance |
| `DebuffApplyResistance` | integer | read-write | Debuff apply resistance |
| `DamageAbsorb` | integer | read-write | Damage absorption |

### Flags

| Field | Type | Access | Description |
|-------|------|--------|-------------|
| `IsEliteMonster` | boolean | read-write | Is an elite monster |
| `IsRadiancePunishImmune` | boolean | read-write | Immune to radiance punishment |

### Methods

#### GetName

```lua
attr:GetName()
```

**Returns:** `string` — Monster name.

---

#### GetResistance

```lua
attr:GetResistance(iType)
```

**Parameters:**
- `iType` (integer): Resistance type index (0 to MAX_RESISTENCE_TYPE-1)

**Returns:** `integer` — Resistance value, or `-1` if `iType` is out of range.

---

## Example

```lua
local attr = Monster.GetAttr(275) -- Kundun
if attr ~= nil then
    Log.Add(string.format("[%s] Level: %d, HP: %d, Def: %d",
        attr:GetName(), attr.Level, attr.HP, attr.Defense))

    -- Check fire resistance (type 0)
    local fireRes = attr:GetResistance(0)
    Log.Add(string.format("Fire resistance: %d", fireRes))
end
```
