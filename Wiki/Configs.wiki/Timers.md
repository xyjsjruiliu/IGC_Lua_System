# 计时器 API - 管理员指南

## 什么是计时器？

计时器允许你安排操作在延迟后或重复执行。可以把它们想象成厨房计时器：
- **一次性**：X 秒后响一次（比如微波炉）
- **重复**：每隔 X 秒响一次（比如闹钟）
- **有限次**：响 N 次后停止（比如健身间隔计时器）

**视觉计时器** 在游戏中显示在玩家屏幕上的倒计时/正计时。

---

## 快速开始 - 复制粘贴示例

### 示例 1: 简单延迟（无视觉）
```lua
-- 等待 5 秒，然后做某事
Timer.Create(5000, "MyTimer", function()
    Log.Add("已过 5 秒!")
end)
```

### 示例 2: 向一个玩家显示倒计时
```lua
-- 向玩家显示 30 秒倒计时
function GiveBuff(player)
    Timer.Create(30000, "Buff_" .. player.Index, function()
        Log.Add("Buff expired for player " .. player.Index)
    end, 30000, player.Index, 2, false)
    -- 玩家看到: 00:30, 00:29, 00:28... 倒计时
end
```

### 示例 3: 向多个玩家显示倒计时
```lua
-- 向多个玩家显示 5 分钟活动计时器
function StartEvent(player1, player2, player3)
    local players = {player1.Index, player2.Index, player3.Index}
    
    Timer.Create(300000, "EventTimer", function()
        Log.Add("活动结束!")
    end, 300000, players, 1, false)
    -- 所有玩家看到: 05:00, 04:59, 04:58...
end
```

### 示例 4: 每秒重复执行操作
```lua
-- 总共 10 秒内每秒执行一次
function ApplyPoison(player)
    Timer.RepeatNTimes(1000, "Poison_" .. player.Index, 10, function(tick, total)
        Log.Add("Poison tick " .. tick .. " of " .. total)
        -- Deal damage here
    end, player.Index, 2, false)
    -- 玩家看到: 00:10, 00:09, 00:08... 倒计时
    -- 每秒造成一次伤害
end
```

---

## 视觉计时器显示类型

当你添加视觉计时器时，选择屏幕上显示的文本：

| Type | Text Shown | Best For |
|------|------------|----------|
| `0` | 无文本 | 隐藏计时器（无视觉） |
| `1` | "时间限制" | 活动持续时间、截止时间 |
| `2` | "剩余时间" | Buff、debuff、冷却 |
| `3` | "狩猎时间" | 任务计时器、狩猎活动 |
| `5` | "生存时间" | 波次防御、生存模式 |

**正计时 vs 倒计时：**
- `false`（默认）= 倒计时：00:30 → 00:29 → 00:28...
- `true` = 正计时：00:00 → 00:01 → 00:02...

---

## 基础计时器函数

### Timer.Create - 一次性计时器

**在延迟后执行一次：**

```lua
Timer.Create(milliseconds, "TimerName", function()
    -- 你的代码写在这里
end)
```

**带视觉倒计时：**
```lua
Timer.Create(milliseconds, "TimerName", function()
    -- 你的代码写在这里
end, milliseconds, playerIndex, visualType, false)
```

**参数说明：**
- `milliseconds` - 等待时间（1000 = 1 秒，60000 = 1 分钟）
- `"TimerName"` - 唯一名称（创建相同名称会替换旧计时器）
- `function() ... end` - 计时器触发时执行什么
- `playerIndex` - 哪个玩家看到倒计时（使用 player.Index）
- `visualType` - 显示什么文本（见上表）
- `false` - 倒计时（使用 `true` 正计时）

**示例：**

```lua
-- 等待 10 秒，无视觉
Timer.Create(10000, "WelcomeMessage", function()
    Log.Add("欢迎!")
end)

-- 向玩家显示 1 分钟倒计时
Timer.Create(60000, "Quest_" .. player.Index, function()
    Log.Add("任务时间已过期")
end, 60000, player.Index, 2, false)
```

---

### Timer.CreateRepeating - 重复计时器

**按间隔重复执行：**

```lua
Timer.CreateRepeating(milliseconds, "TimerName", function()
    -- 你的代码写在这里
end)
```

**带视觉（需要持续时间）：**
```lua
Timer.CreateRepeating(intervalMs, "TimerName", function()
    -- 你的代码写在这里
end, durationMs, playerIndex, visualType, false)
```

**重要：** 视觉仅在你设置持续时间时有效（它重复多长时间）。

**示例：**

```lua
-- 每 5 分钟自动保存（永久，无视觉）
Timer.CreateRepeating(300000, "AutoSave", function()
    Log.Add("正在自动保存...")
end)

-- 30 秒内每 3 秒治疗一次（带视觉）
Timer.CreateRepeating(3000, "Heal_" .. player.Index, function()
    Log.Add("正在治疗玩家 " .. player.Index)
end, 30000, player.Index, 2, false)
-- 玩家看到 30 秒倒计时，每 3 秒治疗一次
```

---

### Timer.RepeatNTimes - 有限次重复计时器

**执行 N 次后停止：**

```lua
Timer.RepeatNTimes(milliseconds, "TimerName", count, function(current, total)
    Log.Add("Execution " .. current .. " of " .. total)
end)
```

**带视觉：**
```lua
Timer.RepeatNTimes(milliseconds, "TimerName", count, function(current, total)
    -- 你的代码写在这里
end, playerIndex, visualType, false)
```

**回调接收两个数字：**
- `current` - 这是第几次执行（1, 2, 3...）
- `total` - 总执行次数

**示例：**

```lua
-- 每 30 秒生成一波，共 5 波
Timer.RepeatNTimes(30000, "Waves", 5, function(wave, totalWaves)
    Log.Add("Spawning wave " .. wave .. " of " .. totalWaves)
    -- Spawn monsters here
end)

-- 向玩家显示倒计时
Timer.RepeatNTimes(30000, "BossWaves", 5, function(wave, total)
    Log.Add("Wave " .. wave)
end, player.Index, 1, false)
-- 玩家看到 30 秒倒计时，重置 5 次
```

---

## 计时器控制函数

### 移除计时器

```lua
-- 按名称移除
Timer.RemoveByName("TimerName")

-- 按 ID 移除
Timer.Remove(timerId)
```

**示例：**
```lua
-- 提前取消 buff
Timer.RemoveByName("Buff_" .. player.Index)
```

---

### 检查计时器状态

```lua
-- 检查计时器是否存在
if Timer.ExistsByName("MyTimer") then
    Log.Add("计时器正在运行")
end

-- 检查计时器是否激活
if Timer.IsActive(timerId) then
    Log.Add("计时器处于激活状态")
end

-- 获取剩余时间（毫秒）
local remaining = Timer.GetRemaining(timerId)
Log.Add("剩余时间: " .. (remaining / 1000) .. " 秒")
```

---

### 暂停和恢复

```lua
-- 停止计时器（可稍后重启）
Timer.Stop(timerId)

-- 恢复计时器
Timer.Start(timerId)
```

**示例：**
```lua
-- 暂停活动
function PauseEvent()
    Timer.Stop(eventTimerId)
    Log.Add("活动已暂停")
end

-- 恢复活动
function ResumeEvent()
    Timer.Start(eventTimerId)
    Log.Add("活动已恢复")
end
```

---

## 管理视觉计时器

> ⚠️ **s6 不可用** — `Timer.AddVisualPlayer`、`Timer.RemoveVisualPlayer` 和 `Timer.SetVisualPlayers` 在 s6 版本中不存在。在 s6 中，视觉玩家只能在计时器创建时通过 `Timer.Create` / `Timer.CreateRepeating` / `Timer.RepeatNTimes` 的 `players`、`visualType` 和 `countUp` 参数分配。

### 添加玩家到视觉计时器

```lua
Timer.AddVisualPlayer(timerId, playerIndex)
```

**示例：**
```lua
-- 玩家中途加入活动
Timer.AddVisualPlayer(eventTimerId, newPlayer.Index)
Message.Send(0, newPlayer.Index, 0, "你已加入活动!")
```

---

### 从视觉计时器移除玩家

```lua
Timer.RemoveVisualPlayer(timerId, playerIndex)
```

**示例：**
```lua
-- 玩家离开活动
Timer.RemoveVisualPlayer(eventTimerId, leavingPlayer.Index)
```

---

### 更新所有视觉玩家

```lua
local newPlayers = {player1.Index, player2.Index, player3.Index}
Timer.SetVisualPlayers(timerId, newPlayers)
```

---

## 常见管理员用例

### 用例 1: 带过期时间的玩家 Buff

```lua
function ApplyStrengthBuff(player, durationSeconds)
    local name = "Buff_" .. player.Index
    local durationMs = durationSeconds * 1000
    
    -- 在这里应用 buff 效果
    
    -- 显示倒计时并在过期时移除 buff
    Timer.Create(durationMs, name, function()
        -- 在这里移除 buff 效果
        Message.Send(0, player.Index, 0, "Buff 已过期!")
    end, durationMs, player.Index, 2, false)
end

-- 用法: ApplyStrengthBuff(player, 60)  -- 60 秒 buff
```

---

### 用例 2: 向所有玩家显示活动倒计时

```lua
function StartEventTimer(durationMinutes)
    local durationMs = durationMinutes * 60 * 1000
    
    -- 构建所有在线玩家列表
    local players = {}
    for i = 0, 10000 do
        if Players[i] ~= nil and Players[i].Connected == 3 then
            table.insert(players, i)
        end
    end
    
    -- 向所有人显示计时器
    Timer.Create(durationMs, "GlobalEvent", function()
        Log.Add("活动时间已过期!")
    end, durationMs, players, 1, false)
    
    Log.Add("活动已为 " .. #players .. " 名玩家启动")
end

-- 用法: StartEventTimer(10)  -- 10 分钟活动
```

---

### 用例 3: 基于波次的怪物生成

```lua
function StartMonsterWaves(waveCount, delaySeconds)
    Timer.RepeatNTimes(delaySeconds * 1000, "MonsterWaves", waveCount, 
        function(currentWave, totalWaves)
            Log.Add("Spawning wave " .. currentWave .. " of " .. totalWaves)
            
            -- 在这里生成你的怪物
            
            if currentWave == totalWaves then
                Log.Add("最后一波已生成!")
            end
        end)
end

-- 用法: StartMonsterWaves(5, 30)  -- 5 波，每 30 秒间隔
```

---

### 用例 4: 持续伤害（中毒/燃烧）

```lua
function ApplyPoison(player, tickDamage, durationSeconds)
    local ticks = durationSeconds
    local name = "Poison_" .. player.Index
    
    Timer.RepeatNTimes(1000, name, ticks, function(tick, total)
        -- Deal damage here
        Log.Add("Poison damage to player " .. player.Index)
        
        if tick == total then
            Message.Send(0, player.Index, 0, "中毒效果已消失")
        end
    end, player.Index, 2, false)
end

-- 用法: ApplyPoison(player, 10, 10)  -- 每秒 10 伤害，持续 10 秒
```

---

### 用例 5: 计划服务器重启警告

```lua
function ScheduleRestart(minutesUntilRestart)
    local warnings = {30, 15, 10, 5, 3, 2, 1}  -- 要警告的分钟数
    
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

-- 用法: ScheduleRestart(60)  -- 60 分钟后重启
```

---

### 用例 6: 临时活动 NPC

```lua
function SpawnTemporaryNPC(mapNumber, x, y, durationMinutes)
    -- 在这里生成 NPC（获取 NPC 索引）
    local npcIndex = 12345  -- 你的生成 NPC 索引
    
    local durationMs = durationMinutes * 60 * 1000
    
    Timer.Create(durationMs, "TempNPC_" .. npcIndex, function()
        -- 在这里删除 NPC
        Log.Add("临时 NPC 已移除")
    end)
    
    Log.Add("临时 NPC 已生成，持续 " .. durationMinutes .. " 分钟")
end

-- 用法: SpawnTemporaryNPC(0, 100, 100, 30)  -- 30 分钟
```

---

## 管理员重要提示

### 提示 1: 计时器名称必须唯一

```lua
-- ❌ 不好：相同名称 = 旧计时器被替换
Timer.Create(5000, "MyTimer", callback1)
Timer.Create(10000, "MyTimer", callback2)  -- 替换第一个计时器!

-- ✅ 好：不同名称
Timer.Create(5000, "Timer1", callback1)
Timer.Create(10000, "Timer2", callback2)
```

**对玩家专用计时器使用玩家索引作为名称：**
```lua
"Buff_" .. player.Index      -- "Buff_100", "Buff_101" 等
"Quest_" .. player.Index      -- "Quest_100", "Quest_101" 等
```

---

### 提示 2: 时间单位是毫秒

```
1 秒 = 1000 毫秒
1 分钟 = 60000 毫秒
5 分钟 = 300000 毫秒
```

**辅助函数增加可读性：**
```lua
local SECOND = 1000
local MINUTE = 60 * SECOND

Timer.Create(30 * SECOND, "Timer", callback)
Timer.Create(5 * MINUTE, "LongTimer", callback)
```

---

### 提示 3: 视觉计时器需要持续时间

```lua
-- ✅ 有效：提供了持续时间
Timer.Create(60000, "Timer", callback, 60000, player.Index, 2, false)
                                     -- ^^^^^^ 这使视觉生效

-- ❌ 不生效：没有持续时间
Timer.Create(60000, "Timer", callback, nil, player.Index, 2, false)
                                     -- ^^^ 视觉不会显示
```

---

### 提示 4: 玩家断开连接时清理

```lua
function onPlayerDisconnect(player)
    -- 移除所有玩家专用计时器
    Timer.RemoveByName("Buff_" .. player.Index)
    Timer.RemoveByName("Quest_" .. player.Index)
    Timer.RemoveByName("Poison_" .. player.Index)
end
```

---

### 提示 5: 多个玩家需要表

```lua
-- ✅ 正确：玩家索引表
local players = {player1.Index, player2.Index, player3.Index}
Timer.Create(60000, "Timer", callback, 60000, players, 2, false)

-- ❌ 错误：尝试传递多个值
Timer.Create(60000, "Timer", callback, 60000, player1.Index, player2.Index, 2, false)
```

---

## 故障排除

### 问题：视觉计时器不显示

**解决方案：** 确保你提供了持续时间（aliveTime 参数）：
```lua
-- 添加持续时间参数（通常与间隔相同）
Timer.Create(60000, "Timer", callback, 60000, player.Index, 2, false)
                                     -- ^^^^^^ 添加这个
```

---

### 问题：计时器立即触发

**解决方案：** 时间单位是毫秒，不是秒：
```lua
-- ❌ 错误：5 毫秒后触发（几乎是立即）
Timer.Create(5, "Timer", callback)

-- ✅ 正确：5 秒后触发
Timer.Create(5000, "Timer", callback)
```

---

### 问题：旧计时器没被替换

**解决方案：** 确保名称完全匹配：
```lua
Timer.Create(5000, "MyTimer", callback1)
Timer.Create(10000, "MyTimer", callback2)  -- 相同名称 = 替换
Timer.Create(10000, "MyTimer2", callback3) -- 不同名称 = 新计时器
```

---

### 问题：视觉显示错误时间

**解决方案：** 对于一次性计时器，持续时间应与间隔匹配：
```lua
-- ✅ 正确：两者都是 60000
Timer.Create(60000, "Timer", callback, 60000, player.Index, 2, false)

-- ❌ 错误：值不匹配
Timer.Create(60000, "Timer", callback, 30000, player.Index, 2, false)
-- 计时器在 60 秒后触发，但视觉显示 30 秒
```

---

### 问题：重复计时器视觉倒计时不流畅

**解决方案：** 这是预期的。对于带视觉的重复计时器：
- 视觉显示剩余总时间
- 回调仍在每个间隔触发
- 如果你想要每次执行的倒计时，使用 RepeatNTimes

---

## 高级：获取计时器统计

```lua
-- 获取计时器总数
local count = Timer.GetCount()
Log.Add("激活的计时器: " .. count)

-- 获取详细统计
local stats = Timer.GetStats()
Log.Add("总计: " .. stats.totalCount)
Log.Add("激活: " .. stats.activeCount)
Log.Add("重复: " .. stats.repeatingCount)
```

---

## 快速参考

### 创建函数

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `Timer.Create` | `(interval, name, callback, [aliveTime], [players], [visualType], [countUp])` | `number` (ID) | 一次性计时器 - 延迟后触发一次 |
| `Timer.CreateRepeating` | `(interval, name, callback, [aliveTime], [players], [visualType], [countUp])` | `number` (ID) | 重复计时器 - 每个间隔触发 |
| `Timer.RepeatNTimes` | `(interval, name, count, callback, [players], [visualType], [countUp])` | `number` (ID) | 有限次重复 - 触发 N 次 |

**参数：**
- `interval` - 时间（毫秒）（1000 = 1 秒）
- `name` - 唯一计时器名称（字符串）
- `callback` - 计时器触发时调用的函数
- `count` - 重复次数（仅 RepeatNTimes）
- `aliveTime` - 自动移除时间（可选，默认 = 从不）
- `players` - 玩家索引（数字）或索引表（可选）
- `visualType` - 显示类型: 0=无, 1=时间限制, 2=剩余, 3=狩猎, 5=生存（可选，默认=0）
- `countUp` - true=正计时, false=倒计时（可选，默认=false）

---

### 控制函数

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `Timer.Start` | `(timerID)` | `boolean` | 启动/恢复计时器 |
| `Timer.Stop` | `(timerID)` | `boolean` | 暂停计时器（可重启） |
| `Timer.Remove` | `(timerID)` | `boolean` | 完全移除计时器 |
| `Timer.RemoveByName` | `(name)` | `boolean` | 按名称移除计时器 |

---

### 查询函数

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `Timer.Exists` | `(timerID)` | `boolean` | 检查计时器是否存在 |
| `Timer.ExistsByName` | `(name)` | `boolean` | 按名称检查计时器是否存在 |
| `Timer.IsActive` | `(timerID)` | `boolean` | 检查计时器是否运行中 |
| `Timer.GetRemaining` | `(timerID)` | `number` | 获取剩余时间（毫秒）（未激活返回 -1） |
| `Timer.GetCount` | `()` | `number` | 获取计时器总数 |
| `Timer.GetStats` | `()` | `table` | 获取详细统计（totalCount、activeCount 等） |

---

### 视觉函数

> ⚠️ **s6 不可用** — 以下函数在 s6 版本中不存在。

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `Timer.AddVisualPlayer` | `(timerID, playerIndex)` | `boolean` | 添加玩家到视觉计时器 |
| `Timer.RemoveVisualPlayer` | `(timerID, playerIndex)` | `boolean` | 从视觉计时器移除玩家 |
| `Timer.SetVisualPlayers` | `(timerID, playerTable)` | `boolean` | 替换所有视觉玩家 |

**注意：** 函数成功返回 `true`，失败返回 `false`（创建函数返回计时器 ID 或 -1 表示错误）

---

## 记住

1. **计时器名称唯一** - 相同名称替换旧计时器
2. **时间是毫秒** - 1000 = 1 秒
3. **视觉需要持续时间** - 设置 aliveTime 参数
4. **使用 player.Index** 处理玩家专用计时器
5. **断开连接时清理** - 移除玩家计时器
6. **先测试** - 在测试服务器上尝试计时器后再上正式服

---

*需要帮助？使用服务器日志中的 `Log.Add()` 来调试计时器问题。*
