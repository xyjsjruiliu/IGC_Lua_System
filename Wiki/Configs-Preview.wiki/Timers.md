# Timer API - Admin Guide

## What Are Timers?

Timers let you schedule actions to happen after a delay or repeatedly. Think of them like kitchen timers:
- **One-shot**: Ding once after X seconds (like a microwave)
- **Repeating**: Ding every X seconds (like an alarm clock)
- **Limited**: Ding N times then stop (like a workout interval timer)

**Visual Timers** show a countdown/countup on player's screen in-game.

---

## Quick Start - Copy & Paste Examples

### Example 1: Simple Delay (No Visual)
```lua
-- Wait 5 seconds, then do something
Timer.Create(5000, "MyTimer", function()
    Log.Add("5 seconds have passed!")
end)
```

### Example 2: Show Countdown to One Player
```lua
-- Show 30-second countdown to player
function GiveBuff(player)
    Timer.Create(30000, "Buff_" .. player.Index, function()
        Log.Add("Buff expired for player " .. player.Index)
    end, 30000, player.Index, 2, false)
    -- Player sees: 00:30, 00:29, 00:28... counting down
end
```

### Example 3: Show Countdown to Multiple Players
```lua
-- Show 5-minute event timer to multiple players
function StartEvent(player1, player2, player3)
    local players = {player1.Index, player2.Index, player3.Index}
    
    Timer.Create(300000, "EventTimer", function()
        Log.Add("Event ended!")
    end, 300000, players, 1, false)
    -- All players see: 05:00, 04:59, 04:58...
end
```

### Example 4: Repeating Action Every Second
```lua
-- Do something every 1 second for 10 seconds total
function ApplyPoison(player)
    Timer.RepeatNTimes(1000, "Poison_" .. player.Index, 10, function(tick, total)
        Log.Add("Poison tick " .. tick .. " of " .. total)
        -- Deal damage here
    end, player.Index, 2, false)
    -- Player sees: 00:10, 00:09, 00:08... counting down
    -- Damage happens every second
end
```

---

## Visual Timer Display Types

When you add a visual timer, you choose what text shows on screen:

| Type | Text Shown | Best For |
|------|------------|----------|
| `0` | No text | Hidden timers (no visual) |
| `1` | "Time limit" | Event duration, deadlines |
| `2` | "Remaining time" | Buffs, debuffs, cooldowns |
| `3` | "Hunting time" | Quest timers, hunting events |
| `5` | "Survival time" | Wave defense, survival mode |

**Count Up vs Count Down:**
- `false` (default) = Counts DOWN: 00:30 → 00:29 → 00:28...
- `true` = Counts UP: 00:00 → 00:01 → 00:02...

---

## Basic Timer Functions

### Timer.Create - One-Shot Timer

**Do something once after a delay:**

```lua
Timer.Create(milliseconds, "TimerName", function()
    -- Your code here
end)
```

**With visual countdown:**
```lua
Timer.Create(milliseconds, "TimerName", function()
    -- Your code here
end, milliseconds, playerIndex, visualType, false)
```

**Parameters Explained:**
- `milliseconds` - How long to wait (1000 = 1 second, 60000 = 1 minute)
- `"TimerName"` - Unique name (creating same name replaces old timer)
- `function() ... end` - What to do when timer fires
- `playerIndex` - Which player sees the countdown (use player.Index)
- `visualType` - What text to show (see table above)
- `false` - Count down (use `true` to count up)

**Examples:**

```lua
-- Wait 10 seconds, no visual
Timer.Create(10000, "WelcomeMessage", function()
    Log.Add("Welcome!")
end)

-- Show 1 minute countdown to player
Timer.Create(60000, "Quest_" .. player.Index, function()
    Log.Add("Quest time expired")
end, 60000, player.Index, 2, false)
```

---

### Timer.CreateRepeating - Repeating Timer

**Do something repeatedly at an interval:**

```lua
Timer.CreateRepeating(milliseconds, "TimerName", function()
    -- Your code here
end)
```

**With visual (requires duration):**
```lua
Timer.CreateRepeating(intervalMs, "TimerName", function()
    -- Your code here
end, durationMs, playerIndex, visualType, false)
```

**Important:** Visual only works if you set a duration (how long it repeats for).

**Examples:**

```lua
-- Auto-save every 5 minutes forever (no visual)
Timer.CreateRepeating(300000, "AutoSave", function()
    Log.Add("Auto-saving...")
end)

-- Heal every 3 seconds for 30 seconds total (with visual)
Timer.CreateRepeating(3000, "Heal_" .. player.Index, function()
    Log.Add("Healing player " .. player.Index)
end, 30000, player.Index, 2, false)
-- Player sees 30-second countdown, heals every 3 seconds
```

---

### Timer.RepeatNTimes - Limited Repeating Timer

**Do something N times, then stop:**

```lua
Timer.RepeatNTimes(milliseconds, "TimerName", count, function(current, total)
    Log.Add("Execution " .. current .. " of " .. total)
end)
```

**With visual:**
```lua
Timer.RepeatNTimes(milliseconds, "TimerName", count, function(current, total)
    -- Your code here
end, playerIndex, visualType, false)
```

**The callback receives two numbers:**
- `current` - Which execution this is (1, 2, 3...)
- `total` - Total number of executions

**Examples:**

```lua
-- Spawn 5 waves, one every 30 seconds
Timer.RepeatNTimes(30000, "Waves", 5, function(wave, totalWaves)
    Log.Add("Spawning wave " .. wave .. " of " .. totalWaves)
    -- Spawn monsters here
end)

-- Show countdown to player
Timer.RepeatNTimes(30000, "BossWaves", 5, function(wave, total)
    Log.Add("Wave " .. wave)
end, player.Index, 1, false)
-- Player sees 30-second countdown that resets 5 times
```

---

## Timer Control Functions

### Remove Timers

```lua
-- Remove by name
Timer.RemoveByName("TimerName")

-- Remove by ID
Timer.Remove(timerId)
```

**Example:**
```lua
-- Cancel a buff early
Timer.RemoveByName("Buff_" .. player.Index)
```

---

### Check Timer Status

```lua
-- Check if timer exists
if Timer.ExistsByName("MyTimer") then
    Log.Add("Timer is running")
end

-- Check if timer is active
if Timer.IsActive(timerId) then
    Log.Add("Timer is active")
end

-- Get remaining time (in milliseconds)
local remaining = Timer.GetRemaining(timerId)
Log.Add("Time left: " .. (remaining / 1000) .. " seconds")
```

---

### Pause and Resume

```lua
-- Stop timer (can restart later)
Timer.Stop(timerId)

-- Resume timer
Timer.Start(timerId)
```

**Example:**
```lua
-- Pause event
function PauseEvent()
    Timer.Stop(eventTimerId)
    Log.Add("Event paused")
end

-- Resume event
function ResumeEvent()
    Timer.Start(eventTimerId)
    Log.Add("Event resumed")
end
```

---

## Managing Visual Timers

> ⚠️ **Not available in s6** — `Timer.AddVisualPlayer`, `Timer.RemoveVisualPlayer` and `Timer.SetVisualPlayers` do not exist in the s6 build. In s6, visual players can only be assigned at timer creation time via the `players`, `visualType` and `countUp` parameters of `Timer.Create` / `Timer.CreateRepeating` / `Timer.RepeatNTimes`.

### Add Player to Visual Timer

```lua
Timer.AddVisualPlayer(timerId, playerIndex)
```

**Example:**
```lua
-- Player joins event mid-way
Timer.AddVisualPlayer(eventTimerId, newPlayer.Index)
Message.Send(0, newPlayer.Index, 0, "You joined the event!")
```

---

### Remove Player from Visual Timer

```lua
Timer.RemoveVisualPlayer(timerId, playerIndex)
```

**Example:**
```lua
-- Player leaves event
Timer.RemoveVisualPlayer(eventTimerId, leavingPlayer.Index)
```

---

### Update All Visual Players

```lua
local newPlayers = {player1.Index, player2.Index, player3.Index}
Timer.SetVisualPlayers(timerId, newPlayers)
```

---

## Common Admin Use Cases

### Use Case 1: Player Buff with Expiration

```lua
function ApplyStrengthBuff(player, durationSeconds)
    local name = "Buff_" .. player.Index
    local durationMs = durationSeconds * 1000
    
    -- Apply buff effect here
    
    -- Show countdown and remove buff when expires
    Timer.Create(durationMs, name, function()
        -- Remove buff effect here
        Message.Send(0, player.Index, 0, "Buff expired!")
    end, durationMs, player.Index, 2, false)
end

-- Usage: ApplyStrengthBuff(player, 60)  -- 60 second buff
```

---

### Use Case 2: Event Countdown for All Players

```lua
function StartEventTimer(durationMinutes)
    local durationMs = durationMinutes * 60 * 1000
    
    -- Build list of all online players
    local players = {}
    for i = 0, 10000 do
        if Players[i] ~= nil and Players[i].Connected == 3 then
            table.insert(players, i)
        end
    end
    
    -- Show timer to everyone
    Timer.Create(durationMs, "GlobalEvent", function()
        Log.Add("Event time expired!")
    end, durationMs, players, 1, false)
    
    Log.Add("Event started for " .. #players .. " players")
end

-- Usage: StartEventTimer(10)  -- 10 minute event
```

---

### Use Case 3: Wave-Based Monster Spawning

```lua
function StartMonsterWaves(waveCount, delaySeconds)
    Timer.RepeatNTimes(delaySeconds * 1000, "MonsterWaves", waveCount, 
        function(currentWave, totalWaves)
            Log.Add("Spawning wave " .. currentWave .. " of " .. totalWaves)
            
            -- Spawn your monsters here
            
            if currentWave == totalWaves then
                Log.Add("Final wave spawned!")
            end
        end)
end

-- Usage: StartMonsterWaves(5, 30)  -- 5 waves, 30 seconds apart
```

---

### Use Case 4: Damage Over Time (Poison/Burn)

```lua
function ApplyPoison(player, tickDamage, durationSeconds)
    local ticks = durationSeconds
    local name = "Poison_" .. player.Index
    
    Timer.RepeatNTimes(1000, name, ticks, function(tick, total)
        -- Deal damage here
        Log.Add("Poison damage to player " .. player.Index)
        
        if tick == total then
            Message.Send(0, player.Index, 0, "Poison wore off")
        end
    end, player.Index, 2, false)
end

-- Usage: ApplyPoison(player, 10, 10)  -- 10 damage per second for 10 seconds
```

---

### Use Case 5: Scheduled Server Restart Warning

```lua
function ScheduleRestart(minutesUntilRestart)
    local warnings = {30, 15, 10, 5, 3, 2, 1}  -- Minutes to warn at
    
    for _, warningTime in ipairs(warnings) do
        if warningTime < minutesUntilRestart then
            local delayMs = (minutesUntilRestart - warningTime) * 60 * 1000
            local name = "RestartWarning_" .. warningTime
            
            Timer.Create(delayMs, name, function()
                Log.Add("Server restart in " .. warningTime .. " minutes!")
                -- Send message to all players
            end)
        end
    end
end

-- Usage: ScheduleRestart(60)  -- Restart in 60 minutes
```

---

### Use Case 6: Temporary Event NPC

```lua
function SpawnTemporaryNPC(mapNumber, x, y, durationMinutes)
    -- Spawn NPC here (get NPC index)
    local npcIndex = 12345  -- Your spawned NPC index
    
    local durationMs = durationMinutes * 60 * 1000
    
    Timer.Create(durationMs, "TempNPC_" .. npcIndex, function()
        -- Delete NPC here
        Log.Add("Temporary NPC removed")
    end)
    
    Log.Add("Temporary NPC spawned for " .. durationMinutes .. " minutes")
end

-- Usage: SpawnTemporaryNPC(0, 100, 100, 30)  -- 30 minutes
```

---

## Important Tips for Admins

### Tip 1: Timer Names Must Be Unique

```lua
-- ❌ BAD: Same name = old timer replaced
Timer.Create(5000, "MyTimer", callback1)
Timer.Create(10000, "MyTimer", callback2)  -- Replaces first timer!

-- ✅ GOOD: Different names
Timer.Create(5000, "Timer1", callback1)
Timer.Create(10000, "Timer2", callback2)
```

**Use player index in names for player-specific timers:**
```lua
"Buff_" .. player.Index      -- "Buff_100", "Buff_101", etc.
"Quest_" .. player.Index      -- "Quest_100", "Quest_101", etc.
```

---

### Tip 2: Time is in Milliseconds

```
1 second = 1000 milliseconds
1 minute = 60000 milliseconds
5 minutes = 300000 milliseconds
```

**Helper for readability:**
```lua
local SECOND = 1000
local MINUTE = 60 * SECOND

Timer.Create(30 * SECOND, "Timer", callback)
Timer.Create(5 * MINUTE, "LongTimer", callback)
```

---

### Tip 3: Visual Timers Need Duration

```lua
-- ✅ WORKS: Duration provided
Timer.Create(60000, "Timer", callback, 60000, player.Index, 2, false)
                                     -- ^^^^^^ This makes visual work

-- ❌ DOESN'T WORK: No duration
Timer.Create(60000, "Timer", callback, nil, player.Index, 2, false)
                                     -- ^^^ Visual won't show
```

---

### Tip 4: Clean Up on Player Disconnect

```lua
function onPlayerDisconnect(player)
    -- Remove all player-specific timers
    Timer.RemoveByName("Buff_" .. player.Index)
    Timer.RemoveByName("Quest_" .. player.Index)
    Timer.RemoveByName("Poison_" .. player.Index)
end
```

---

### Tip 5: Multiple Players Need a Table

```lua
-- ✅ CORRECT: Table of indices
local players = {player1.Index, player2.Index, player3.Index}
Timer.Create(60000, "Timer", callback, 60000, players, 2, false)

-- ❌ WRONG: Trying to pass multiple values
Timer.Create(60000, "Timer", callback, 60000, player1.Index, player2.Index, 2, false)
```

---

## Troubleshooting

### Problem: Visual timer doesn't show

**Solution:** Make sure you provide duration (aliveTime parameter):
```lua
-- Add duration parameter (same as interval usually)
Timer.Create(60000, "Timer", callback, 60000, player.Index, 2, false)
                                     -- ^^^^^^ Add this
```

---

### Problem: Timer fires immediately

**Solution:** Time is in milliseconds, not seconds:
```lua
-- ❌ WRONG: Fires after 5 milliseconds (instant)
Timer.Create(5, "Timer", callback)

-- ✅ RIGHT: Fires after 5 seconds
Timer.Create(5000, "Timer", callback)
```

---

### Problem: Old timer not replaced

**Solution:** Make sure names match exactly:
```lua
Timer.Create(5000, "MyTimer", callback1)
Timer.Create(10000, "MyTimer", callback2)  -- Same name = replaces
Timer.Create(10000, "MyTimer2", callback3) -- Different name = new timer
```

---

### Problem: Visual shows wrong time

**Solution:** Duration should match interval for one-shot timers:
```lua
-- ✅ CORRECT: Both 60000
Timer.Create(60000, "Timer", callback, 60000, player.Index, 2, false)

-- ❌ WRONG: Mismatched values
Timer.Create(60000, "Timer", callback, 30000, player.Index, 2, false)
-- Timer fires after 60s but visual shows 30s
```

---

### Problem: Repeating timer visual doesn't count down smoothly

**Solution:** This is expected. For repeating timers with visuals:
- Visual shows total remaining time
- Callback still fires at each interval
- Use RepeatNTimes if you want countdown per execution

---

## Advanced: Get Timer Statistics

```lua
-- Get total timer count
local count = Timer.GetCount()
Log.Add("Active timers: " .. count)

-- Get detailed stats
local stats = Timer.GetStats()
Log.Add("Total: " .. stats.totalCount)
Log.Add("Active: " .. stats.activeCount)
Log.Add("Repeating: " .. stats.repeatingCount)
```

---

## Quick Reference

### Creation Functions

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `Timer.Create` | `(interval, name, callback, [aliveTime], [players], [visualType], [countUp])` | `number` (ID) | One-shot timer - fires once after delay |
| `Timer.CreateRepeating` | `(interval, name, callback, [aliveTime], [players], [visualType], [countUp])` | `number` (ID) | Repeating timer - fires every interval |
| `Timer.RepeatNTimes` | `(interval, name, count, callback, [players], [visualType], [countUp])` | `number` (ID) | Limited repeating - fires N times |

**Parameters:**
- `interval` - Time in milliseconds (1000 = 1 second)
- `name` - Unique timer name (string)
- `callback` - Function to call when timer fires
- `count` - Number of times to repeat (RepeatNTimes only)
- `aliveTime` - Auto-remove after this time (optional, default = never)
- `players` - Player index (number) or table of indices (optional)
- `visualType` - Display type: 0=none, 1=time limit, 2=remaining, 3=hunting, 5=survival (optional, default=0)
- `countUp` - true=count up, false=count down (optional, default=false)

---

### Control Functions

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `Timer.Start` | `(timerID)` | `boolean` | Start/resume timer |
| `Timer.Stop` | `(timerID)` | `boolean` | Pause timer (can be restarted) |
| `Timer.Remove` | `(timerID)` | `boolean` | Remove timer completely |
| `Timer.RemoveByName` | `(name)` | `boolean` | Remove timer by name |

---

### Query Functions

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `Timer.Exists` | `(timerID)` | `boolean` | Check if timer exists |
| `Timer.ExistsByName` | `(name)` | `boolean` | Check if timer exists by name |
| `Timer.IsActive` | `(timerID)` | `boolean` | Check if timer is running |
| `Timer.GetRemaining` | `(timerID)` | `number` | Get remaining time in milliseconds (-1 if not active) |
| `Timer.GetCount` | `()` | `number` | Get total number of timers |
| `Timer.GetStats` | `()` | `table` | Get detailed statistics (totalCount, activeCount, etc.) |

---

### Visual Functions

> ⚠️ **Not available in s6** — The following functions do not exist in the s6 build.

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `Timer.AddVisualPlayer` | `(timerID, playerIndex)` | `boolean` | Add player to visual timer |
| `Timer.RemoveVisualPlayer` | `(timerID, playerIndex)` | `boolean` | Remove player from visual timer |
| `Timer.SetVisualPlayers` | `(timerID, playerTable)` | `boolean` | Replace all visual players |

**Note:** Functions return `true` on success, `false` on failure (except creation functions which return timer ID or -1 on error)

---

## Remember

1. **Timer names are unique** - same name replaces old timer
2. **Time is in milliseconds** - 1000 = 1 second
3. **Visual needs duration** - set aliveTime parameter
4. **Use player.Index** for player-specific timers
5. **Clean up on disconnect** - remove player timers
6. **Test first** - try timers on test server before live

---

*Need help? Check your server logs with `Log.Add()` to debug timer issues.*