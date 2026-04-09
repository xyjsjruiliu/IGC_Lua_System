# EventMonsterTracker

System for tracking and managing monsters/NPCs spawned for custom events.

## Table of Contents

- [Overview](#overview)
- [Data Structures](#data-structures)
- [API Reference](#api-reference)
  - [Registration Functions](#registration-functions)
  - [Query Functions](#query-functions)
  - [Cleanup Functions](#cleanup-functions)
  - [Utility Functions](#utility-functions)
  - [Spawning Functions](#spawning-functions)
- [Usage Examples](#usage-examples)
- [Best Practices](#best-practices)
- [Notes](#notes)

---

## Overview

EventMonsterTracker provides centralized management of event-spawned objects, tracking monsters and NPCs by event type for easy cleanup and monitoring.

**Key Features:**
- Event-based organization by type ID
- Separate tracking for monsters and NPCs
- Safe cleanup with verification
- Batch spawn operations
- Query active events and object counts

---

## Data Structures

### TrackedObjectData

```lua
---@class TrackedObjectData
---@field class integer  -- Monster/NPC class ID
---@field type integer   -- Object type (2=MONSTER, 3=NPC)
```

Returned by `GetObjectInfo()` when querying tracked object information.

---

## API Reference

### Registration Functions

#### EventMonsterTracker.Register

Register an object to event tracking.

```lua
EventMonsterTracker.Register(iEventType, iObjectIndex, iObjectClass, iObjectType)
```

**Parameters:**
- `iEventType` (integer) - Event type ID
- `iObjectIndex` (integer) - Object index
- `iObjectClass` (integer) - Monster/NPC class ID
- `iObjectType` (integer) - Object type (Enums.ObjectType: 2=MONSTER, 3=NPC)

**Returns:** None

**Example:**
```lua
local monsterIndex = Object.AddMonster(14, 0, 100, 100, 110, 110, 0)
EventMonsterTracker.Register(1, monsterIndex, 14, Enums.ObjectType.MONSTER)
```

---

#### EventMonsterTracker.Unregister

Unregister object from event tracking (does not delete object).

```lua
local success = EventMonsterTracker.Unregister(iEventType, iObjectIndex)
```

**Parameters:**
- `iEventType` (integer) - Event type ID
- `iObjectIndex` (integer) - Object index

**Returns:** `boolean` - True if unregistered, false if not found

**Example:**
```lua
if EventMonsterTracker.Unregister(1, monsterIndex) then
	print("Monster unregistered from event")
end
```

---

#### EventMonsterTracker.IsTracked

Check if object is tracked for event.

```lua
local tracked = EventMonsterTracker.IsTracked(iEventType, iObjectIndex)
```

**Parameters:**
- `iEventType` (integer) - Event type ID
- `iObjectIndex` (integer) - Object index

**Returns:** `boolean` - True if tracked

**Example:**
```lua
if EventMonsterTracker.IsTracked(1, monsterIndex) then
	print("Monster is tracked for event 1")
end
```

---

### Query Functions

#### EventMonsterTracker.GetObjectInfo

Get stored object information.

```lua
local info = EventMonsterTracker.GetObjectInfo(iEventType, iObjectIndex)
```

**Parameters:**
- `iEventType` (integer) - Event type ID
- `iObjectIndex` (integer) - Object index

**Returns:** `TrackedObjectData` - Object data (class=-1, type=-1 if not found)

**Example:**
```lua
local info = EventMonsterTracker.GetObjectInfo(1, monsterIndex)
if info.class ~= -1 then
	print("Monster class: " .. info.class)
	print("Object type: " .. info.type)
end
```

---

#### EventMonsterTracker.GetMonsterClass

Get stored object class ID.

```lua
local class = EventMonsterTracker.GetMonsterClass(iEventType, iObjectIndex)
```

**Parameters:**
- `iEventType` (integer) - Event type ID
- `iObjectIndex` (integer) - Object index

**Returns:** `integer` - Monster/NPC class ID or -1 if not found

**Example:**
```lua
local monsterClass = EventMonsterTracker.GetMonsterClass(1, monsterIndex)
if monsterClass == 14 then
	print("This is a Goblin")
end
```

---

#### EventMonsterTracker.GetMonsters

Get all tracked object indices for event.

```lua
local indices = EventMonsterTracker.GetMonsters(iEventType, iFilterType)
```

**Parameters:**
- `iEventType` (integer) - Event type ID
- `iFilterType` (integer, optional) - Filter: -1=all (default), 2=MONSTER, 3=NPC

**Returns:** `table` - Array of object indices

**Example:**
```lua
-- Get all monsters for event
local monsters = EventMonsterTracker.GetMonsters(1, Enums.ObjectType.MONSTER)
for i, monsterIndex in ipairs(monsters) do
	local oMonster = Player.GetObjByIndex(monsterIndex)
	if oMonster ~= nil then
		print("Monster " .. i .. " HP: " .. oMonster.Life)
	end
end

-- Get all objects (monsters and NPCs)
local allObjects = EventMonsterTracker.GetMonsters(1)
print("Total objects: " .. #allObjects)
```

---

#### EventMonsterTracker.GetCount

Get count of tracked objects.

```lua
local count = EventMonsterTracker.GetCount(iEventType, iFilterType)
```

**Parameters:**
- `iEventType` (integer) - Event type ID
- `iFilterType` (integer, optional) - Filter: -1=all (default), 2=MONSTER, 3=NPC

**Returns:** `integer` - Number of tracked objects

**Example:**
```lua
local monsterCount = EventMonsterTracker.GetCount(1, Enums.ObjectType.MONSTER)
local npcCount = EventMonsterTracker.GetCount(1, Enums.ObjectType.NPC)
print("Event 1 has " .. monsterCount .. " monsters and " .. npcCount .. " NPCs")
```

---

### Cleanup Functions

#### EventMonsterTracker.CleanupEvent

Cleanup objects for event (delete and untrack). Performs safety verification before deletion.

```lua
local removed = EventMonsterTracker.CleanupEvent(iEventType, iFilterType)
```

**Parameters:**
- `iEventType` (integer) - Event type ID
- `iFilterType` (integer, optional) - Filter: -1=all (default), 2=MONSTER, 3=NPC

**Returns:** `integer` - Number of objects removed

**Example:**
```lua
-- Cleanup all event objects
local removed = EventMonsterTracker.CleanupEvent(1)
print("Removed " .. removed .. " objects from event 1")

-- Cleanup only monsters
local monstersRemoved = EventMonsterTracker.CleanupEvent(1, Enums.ObjectType.MONSTER)
```

---

#### EventMonsterTracker.CleanupMonsters

Cleanup only monsters for event.

```lua
local removed = EventMonsterTracker.CleanupMonsters(iEventType)
```

**Parameters:**
- `iEventType` (integer) - Event type ID

**Returns:** `integer` - Number of monsters removed

**Example:**
```lua
local removed = EventMonsterTracker.CleanupMonsters(1)
print("Removed " .. removed .. " monsters")
```

---

#### EventMonsterTracker.CleanupNPCs

Cleanup only NPCs for event.

```lua
local removed = EventMonsterTracker.CleanupNPCs(iEventType)
```

**Parameters:**
- `iEventType` (integer) - Event type ID

**Returns:** `integer` - Number of NPCs removed

**Example:**
```lua
local removed = EventMonsterTracker.CleanupNPCs(1)
print("Removed " .. removed .. " NPCs")
```

---

#### EventMonsterTracker.CleanupDead

Cleanup dead objects from tracking (without deleting them from game).

Removes objects from tracking if:
- Object no longer exists
- Object type/class changed
- Object Life == 0

```lua
local removed = EventMonsterTracker.CleanupDead(iEventType, iFilterType)
```

**Parameters:**
- `iEventType` (integer) - Event type ID
- `iFilterType` (integer, optional) - Filter: -1=all (default), 2=MONSTER, 3=NPC

**Returns:** `integer` - Number of objects removed from tracking

**Example:**
```lua
-- Clean up dead monsters from tracking
local cleaned = EventMonsterTracker.CleanupDead(1, Enums.ObjectType.MONSTER)
print("Cleaned " .. cleaned .. " dead monsters from tracking")
```

---

### Utility Functions

#### EventMonsterTracker.GetActiveEvents

Get active event types with tracked objects.

```lua
local eventTypes = EventMonsterTracker.GetActiveEvents()
```

**Returns:** `table` - Array of event type IDs

**Example:**
```lua
local activeEvents = EventMonsterTracker.GetActiveEvents()
for i, eventType in ipairs(activeEvents) do
	local count = EventMonsterTracker.GetCount(eventType)
	print("Event " .. eventType .. " has " .. count .. " tracked objects")
end
```

---

#### EventMonsterTracker.ClearAll

Clear all tracking data (does not delete objects).

```lua
local eventsCleared = EventMonsterTracker.ClearAll()
```

**Returns:** `integer` - Number of events cleared

**Example:**
```lua
local cleared = EventMonsterTracker.ClearAll()
print("Cleared tracking for " .. cleared .. " events")
```

---

### Spawning Functions

#### EventMonsterTracker.SpawnAndRegister

Spawn single monster and register to tracking.

```lua
local monsterIndex = EventMonsterTracker.SpawnAndRegister(
	iEventType, iMonsterClass, iMapNumber, iX1, iY1, iX2, iY2, iElement
)
```

**Parameters:**
- `iEventType` (integer) - Event type ID
- `iMonsterClass` (integer) - Monster class ID
- `iMapNumber` (integer) - Map number
- `iX1` (integer) - Spawn area start X
- `iY1` (integer) - Spawn area start Y
- `iX2` (integer) - Spawn area end X
- `iY2` (integer) - Spawn area end Y
- `iElement` (integer) - Elemental attribute (0=none)

**Returns:** `integer` - Monster object index or -1 if failed

**Example:**
```lua
local monsterIndex = EventMonsterTracker.SpawnAndRegister(
	1, 14, 0, 100, 100, 110, 110, 0
)
if monsterIndex ~= -1 then
	print("Spawned monster at index: " .. monsterIndex)
end
```

---

#### EventMonsterTracker.SpawnWaveAndRegister

Spawn wave of monsters and register all to tracking.

```lua
local monsters = EventMonsterTracker.SpawnWaveAndRegister(
	iEventType, iMonsterClass, iCount, iMapNumber, iX1, iY1, iX2, iY2, iElement
)
```

**Parameters:**
- `iEventType` (integer) - Event type ID
- `iMonsterClass` (integer) - Monster class ID
- `iCount` (integer) - Number of monsters to spawn
- `iMapNumber` (integer) - Map number
- `iX1` (integer) - Spawn area start X
- `iY1` (integer) - Spawn area start Y
- `iX2` (integer) - Spawn area end X
- `iY2` (integer) - Spawn area end Y
- `iElement` (integer) - Elemental attribute (0=none)

**Returns:** `table` - Array of spawned monster indices

**Example:**
```lua
local monsters = EventMonsterTracker.SpawnWaveAndRegister(
	1, 14, 10, 0, 100, 100, 150, 150, 0
)
print("Spawned " .. #monsters .. " monsters")
```

---

#### EventMonsterTracker.RegisterNPC

Register existing NPC to tracking.

```lua
EventMonsterTracker.RegisterNPC(iEventType, iNpcIndex, iNpcClass)
```

**Parameters:**
- `iEventType` (integer) - Event type ID
- `iNpcIndex` (integer) - NPC object index
- `iNpcClass` (integer) - NPC class ID

**Returns:** None

**Example:**
```lua
local npcIndex = Object.AddNPC(229, 0, 125, 125, Enums.NPCType.SHOP)
if npcIndex ~= -1 then
	EventMonsterTracker.RegisterNPC(1, npcIndex, 229)
	print("Registered NPC to event tracking")
end
```

---

## Usage Examples

### Spawn Monsters
```lua
local monsters = EventMonsterTracker.SpawnWaveAndRegister(
	1, 14, 10, 0, 100, 100, 150, 150, 0
)
print("Spawned " .. #monsters .. " monsters")
```

### Check Status
```lua
local count = EventMonsterTracker.GetCount(1, Enums.ObjectType.MONSTER)
print("Event 1 has " .. count .. " monsters alive")
```

### Cleanup Dead
```lua
local cleaned = EventMonsterTracker.CleanupDead(1, Enums.ObjectType.MONSTER)
print("Cleaned " .. cleaned .. " dead monsters from tracking")
```

### End Event
```lua
local removed = EventMonsterTracker.CleanupMonsters(1)
print("Event ended. Removed " .. removed .. " monsters")
```

---

## Best Practices

1. **Use unique event type IDs** - Avoid conflicts (e.g., 100-199 for custom events)
2. **Always cleanup on event end** - Use `CleanupEvent()` to remove all objects
3. **Periodic dead cleanup** - Call `CleanupDead()` to keep tracking accurate
4. **Type filtering** - Use `Enums.ObjectType.MONSTER` or `Enums.ObjectType.NPC` instead of magic numbers
5. **Check spawn results** - Always verify if `SpawnAndRegister()` returns -1 (failed)
6. **Batch spawn** - Use `SpawnWaveAndRegister()` instead of multiple `SpawnAndRegister()` calls

---

## Notes

- Tracked objects persist until explicitly cleaned up or server restarts
- `CleanupEvent()` performs safety verification before deletion
- `CleanupDead()` only removes from tracking, does not delete objects
- Maximum 200 event types supported (0-199)

