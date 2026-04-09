# 调度器 API

## 概览
用于管理带 XML 配置支持的定时事件的事件调度器系统。支持循环事件、公告和持续时间事件。

## 函数

### Scheduler.LoadFromXML
从 XML 配置文件加载事件调度。

```lua
success = Scheduler.LoadFromXML(filePath)
```

**参数：**
- `filePath` (string): XML 配置文件路径

**返回：** `boolean` - 成功/失败

**示例：**
```lua
local success = Scheduler.LoadFromXML("Config/EventScheduler.xml")
if success then
    Log.Add("调度器加载成功")
else
    Log.AddC(2, "加载调度器失败!")
end
```

### Scheduler.GetEventCount
获取已加载事件的总数。

```lua
count = Scheduler.GetEventCount()
```

**返回：** `number` - 事件数量

**示例：**
```lua
local count = Scheduler.GetEventCount()
Log.Add(string.format("已加载 %d 个调度事件", count))
```

### Scheduler.CheckEventStarts
检查当前时间哪些事件应该开始。

```lua
eventTypes = Scheduler.CheckEventStarts()
```

**返回：** `table` - 触发的事件类型 ID 数组

**示例：**
```lua
local startedEvents = Scheduler.CheckEventStarts()
for _, eventType in ipairs(startedEvents) do
    local name = Scheduler.GetEventName(eventType)
    Log.Add(string.format("事件开始: %s (类型: %d)", name, eventType))
    OnEventStart(eventType)
end
```

### Scheduler.CheckEventEnds
检查当前时间哪些事件应该结束（基于持续时间）。

```lua
eventTypes = Scheduler.CheckEventEnds()
```

**返回：** `table` - 已结束的事件类型 ID 数组

**示例：**
```lua
local endedEvents = Scheduler.CheckEventEnds()
for _, eventType in ipairs(endedEvents) do
    local name = Scheduler.GetEventName(eventType)
    Log.Add(string.format("事件结束: %s (类型: %d)", name, eventType))
    OnEventEnd(eventType)
end
```

### Scheduler.CheckEventNotices
检查当前时间哪些事件应该发送公告，包含剩余时间信息。

```lua
notices = Scheduler.CheckEventNotices()
```

**返回：** `table` - EventNotice 对象数组

**EventNotice 结构：**
- `type` (number): 事件类型 ID
- `secondsRemaining` (number): 距离事件开始的秒数

**示例：**
```lua
local notices = Scheduler.CheckEventNotices()
for _, notice in ipairs(notices) do
    local name = Scheduler.GetEventName(notice.type)
    local timeStr = FormatTimeRemaining(notice.secondsRemaining)
    
    Message.Send(0, -1, 0, name .. " 将在 " .. timeStr .. " 后开始!")
    Log.Add(string.format("[公告] %s 将在 %s 后开始", name, timeStr))
end
```

**辅助函数示例：**
```lua
-- 将秒数格式化为人类可读的时间字符串
local function FormatTimeRemaining(seconds)
    if seconds < 60 then
        return string.format("%d second%s", seconds, seconds ~= 1 and "s" or "")
    elseif seconds < 3600 then
        local minutes = math.floor(seconds / 60)
        return string.format("%d minute%s", minutes, minutes ~= 1 and "s" or "")
    else
        local hours = math.floor(seconds / 3600)
        local minutes = math.floor((seconds % 3600) / 60)
        if minutes == 0 then
            return string.format("%d hour%s", hours, hours ~= 1 and "s" or "")
        else
            return string.format("%d hour%s %d minute%s", 
                hours, hours ~= 1 and "s" or "",
                minutes, minutes ~= 1 and "s" or "")
        end
    end
end
```

**输出示例：**
- "Blood Castle 将在 5 分钟后开始!"
- "Devil Square 将在 1 小时 30 分钟后开始!"
- "Golden Invasion 将在 45 秒后开始!"


### Scheduler.GetEventName
通过类型 ID 获取事件名称。

```lua
name = Scheduler.GetEventName(eventType)
```

**参数：**
- `eventType` (number): 事件类型 ID

**返回：** `string` - 事件名称，如果未找到则为空字符串

**示例：**
```lua
local name = Scheduler.GetEventName(100)
Log.Add(string.format("事件名称: %s", name))
```

### Scheduler.HasSecondPrecisionEvents
检查是否有任何事件需要秒级精度计时。

```lua
hasSecondPrecision = Scheduler.HasSecondPrecisionEvents()
```

**返回：** `boolean` - 如果任何事件具有秒级精度调度则为真

**示例：**
```lua
if Scheduler.HasSecondPrecisionEvents() then
    Log.Add("调度器需要每秒检查")
    -- 每秒调用检查函数
else
    Log.Add("调度器可以每分钟检查")
    -- 每分钟调用检查函数
end
```

### Scheduler.IsEventActive
检查事件是否当前正在运行。

```lua
isActive = Scheduler.IsEventActive(eventType)
```

**参数：**
- `eventType` (number): 事件类型 ID

**返回：** `boolean` - 如果事件处于激活状态则为真，否则为假

**示例：**
```lua
if Scheduler.IsEventActive(100) then
    Log.Add("Blood Castle 当前处于激活状态")
else
    Log.Add("Blood Castle 未在运行")
end
```

### Scheduler.GetElapsedTime
获取事件开始后经过的时间（秒）。

```lua
elapsed = Scheduler.GetElapsedTime(eventType)
```

**参数：**
- `eventType` (number): 事件类型 ID

**返回：** `number` - 经过的时间（秒），如果事件未激活则返回 -1

**示例：**
```lua
local elapsed = Scheduler.GetElapsedTime(100)
if elapsed >= 0 then
    local mins = math.floor(elapsed / 60)
    local secs = elapsed % 60
    Log.Add(string.format("事件已运行 %d:%02d", mins, secs))
end
```

### Scheduler.GetRemainingTime
获取距离事件结束的剩余时间（秒）。

```lua
remaining = Scheduler.GetRemainingTime(eventType)
```

**参数：**
- `eventType` (number): 事件类型 ID

**返回：** `number` - 剩余时间（秒），如果事件未激活或无持续时间则返回 -1

**示例：**
```lua
local remaining = Scheduler.GetRemainingTime(100)
if remaining >= 0 then
    local mins = math.floor(remaining / 60)
    local secs = remaining % 60
    Message.Send(-1, 0, string.format(
        "事件将在 %d:%02d 后结束", mins, secs
    ))
end
```

### Scheduler.GetProgress
获取事件进度百分比 (0-100)。

```lua
progress = Scheduler.GetProgress(eventType)
```

**参数：**
- `eventType` (number): 事件类型 ID

**返回：** `number` - 进度百分比 (0-100)，如果事件未激活或无持续时间则返回 -1

**示例：**
```lua
local progress = Scheduler.GetProgress(100)
if progress >= 0 then
    Log.Add(string.format("事件进度: %d%%", progress))
end
```

## 完整示例

### 示例 1: 基础事件监控
```lua
-- 每秒/每分钟从游戏循环调用
function CheckScheduledEvents()
    -- 检查正在开始的事件
    local startedEvents = Scheduler.CheckEventStarts()
    for _, eventType in ipairs(startedEvents) do
        OnEventStart(eventType)
    end
    
    -- 检查正在结束的事件
    local endedEvents = Scheduler.CheckEventEnds()
    for _, eventType in ipairs(endedEvents) do
        OnEventEnd(eventType)
    end
    
    -- 检查公告
    local noticeEvents = Scheduler.CheckEventNotices()
    for _, eventType in ipairs(noticeEvents) do
        OnEventNotice(eventType)
    end
end

function OnEventStart(eventType)
    local name = Scheduler.GetEventName(eventType)
    Message.Send(-1, 1, string.format("%s 已开始!", name))
    Log.Add(string.format("事件 %d 已开始: %s", eventType, name))
end

function OnEventEnd(eventType)
    local name = Scheduler.GetEventName(eventType)
    Message.Send(-1, 1, string.format("%s 已结束!", name))
    Log.Add(string.format("事件 %d 已结束: %s", eventType, name))
end

function OnEventNotice(eventType)
    local name = Scheduler.GetEventName(eventType)
    local remaining = Scheduler.GetRemainingTime(eventType)
    
    if remaining > 0 then
        local mins = math.floor(remaining / 60)
        Message.Send(-1, 1, string.format(
            "%s 将在 %d 分钟后开始!", name, mins
        ))
    end
end
```

### 示例 2: 事件计时器显示
```lua
function DisplayEventTimer(eventType)
    if not Scheduler.IsEventActive(eventType) then
        Message.Send(-1, 0, "当前没有事件在运行")
        return
    end
    
    local name = Scheduler.GetEventName(eventType)
    local elapsed = Scheduler.GetElapsedTime(eventType)
    local remaining = Scheduler.GetRemainingTime(eventType)
    local progress = Scheduler.GetProgress(eventType)
    
    if remaining >= 0 then
        local mins = math.floor(remaining / 60)
        local secs = remaining % 60
        
        Message.Send(-1, 1, string.format(
            "%s | 剩余时间: %d:%02d | 进度: %d%%",
            name, mins, secs, progress
        ))
    else
        Message.Send(-1, 1, string.format(
            "%s | 已用时间: %d 秒",
            name, elapsed
        ))
    end
end

-- 每 30 秒显示计时器
Timer.CreateRepeating(30000, "event_timer_display", function()
    if Scheduler.IsEventActive(100) then
        DisplayEventTimer(100)
    end
end)
```

### 示例 3: 事件阶段系统
```lua
function GetEventPhase(eventType)
    local progress = Scheduler.GetProgress(eventType)
    
    if progress < 0 then
        return "未激活"
    elseif progress < 25 then
        return "开始中"
    elseif progress < 75 then
        return "进行中"
    elseif progress < 100 then
        return "即将结束"
    else
        return "已完成"
    end
end

function OnEventTick(eventType)
    local phase = GetEventPhase(eventType)
    
    if phase == "开始中" then
        -- 事件刚启动，生成怪物
        SpawnEventMonsters()
    elseif phase == "即将结束" then
        -- 事件即将结束，最后警告
        local remaining = Scheduler.GetRemainingTime(eventType)
        if remaining <= 60 then
            Message.Send(-1, 1, "事件将在 1 分钟后结束!")
        end
    end
end
```

### 示例 4: 基于进度的动态奖励
```lua
function CalculateEventReward(eventType, baseReward)
    local progress = Scheduler.GetProgress(eventType)
    
    if progress < 0 then
        return 0
    end
    
    -- 完成奖励加成
    local multiplier = 1.0
    
    if progress >= 100 then
        multiplier = 2.0  -- 完全完成双倍奖励
    elseif progress >= 75 then
        multiplier = 1.5  -- 75%+ 完成 50% 加成
    elseif progress >= 50 then
        multiplier = 1.25 -- 50%+ 完成 25% 加成
    end
    
    return math.floor(baseReward * multiplier)
end

function GiveEventCompletionReward(oPlayer, eventType)
    local reward = CalculateEventReward(eventType, 100000)

    if reward > 0 then
        Player.SetMoney(oPlayer.Index, reward, false)
        Message.Send(0, oPlayer.Index, 0, string.format(
            "事件奖励: +%d Zen!", reward
        ))
    end
end
```

### 示例 5: 倒计时公告
```lua
-- 在特定间隔公告剩余时间
Timer.CreateRepeating(60000, "event_countdown", function()
    local eventType = 100
    
    if not Scheduler.IsEventActive(eventType) then
        return
    end
    
    local remaining = Scheduler.GetRemainingTime(eventType)
    
    if remaining < 0 then
        return
    end
    
    local mins = math.floor(remaining / 60)
    local name = Scheduler.GetEventName(eventType)
    
    -- 在特定时间点公告
    if remaining == 600 then
        Message.Send(-1, 1, string.format("%s 将在 10 分钟后结束!", name))
    elseif remaining == 300 then
        Message.Send(-1, 1, string.format("%s 将在 5 分钟后结束!", name))
    elseif remaining == 60 then
        Message.Send(-1, 1, string.format("%s 将在 1 分钟后结束!", name))
    elseif remaining % 600 == 0 and mins > 10 then
        Message.Send(-1, 0, string.format("%s: 剩余 %d 分钟", name, mins))
    end
end)
```

### 示例 6: 事件统计追踪
```lua
local eventStats = {}

function OnEventStart(eventType)
    eventStats[eventType] = {
        startTime = os.time(),
        participants = 0,
        completions = 0
    }
    
    local name = Scheduler.GetEventName(eventType)
    Message.Send(-1, 1, string.format("%s 已开始!", name))
end

function OnEventEnd(eventType)
    local stats = eventStats[eventType]
    if stats then
        local name = Scheduler.GetEventName(eventType)
        local duration = os.time() - stats.startTime
        
        Log.Add(string.format(
            "事件 %s 已结束 | 持续时间: %d秒 | 参与者: %d | 完成者: %d",
            name, duration, stats.participants, stats.completions
        ))
        
        Message.Send(-1, 1, string.format(
            "%s 已结束! %d 名玩家参与，%d 名完成",
            name, stats.participants, stats.completions
        ))
    end
end

function TrackEventParticipation(oPlayer, eventType)
    if eventStats[eventType] then
        eventStats[eventType].participants = eventStats[eventType].participants + 1
    end
end

function TrackEventCompletion(oPlayer, eventType)
    if eventStats[eventType] then
        eventStats[eventType].completions = eventStats[eventType].completions + 1
    end
end
```

### 示例 7: 多事件管理
```lua
function GetActiveEvents()
    local activeEvents = {}
    local totalEvents = Scheduler.GetEventCount()
    
    -- 检查所有可能的事件类型（根据需要调整范围）
    for eventType = 1, 200 do
        if Scheduler.IsEventActive(eventType) then
            table.insert(activeEvents, {
                type = eventType,
                name = Scheduler.GetEventName(eventType),
                elapsed = Scheduler.GetElapsedTime(eventType),
                remaining = Scheduler.GetRemainingTime(eventType),
                progress = Scheduler.GetProgress(eventType)
            })
        end
    end
    
    return activeEvents
end

function DisplayAllActiveEvents()
    local events = GetActiveEvents()
    
    if #events == 0 then
        Message.Send(-1, 0, "当前没有激活的事件")
        return
    end
    
    Message.Send(-1, 1, string.format("=== %d 个激活事件 ===", #events))
    
    for _, event in ipairs(events) do
        if event.remaining >= 0 then
            local mins = math.floor(event.remaining / 60)
            Message.Send(-1, 0, string.format(
                "%s: 剩余 %d 分钟 (%d%%)",
                event.name, mins, event.progress
            ))
        else
            Message.Send(-1, 0, string.format(
                "%s: 激活中 (已用 %d 秒)",
                event.name, event.elapsed
            ))
        end
    end
end
```

## XML 配置格式

```xml
<?xml version="1.0" encoding="utf-8"?>
<EventScheduler>
    <!-- 带持续时间和公告的事件 -->
    <Event Type="100" Name="Blood Castle" NoticePeriod="300" Duration="900">
        <Start Hour="12" Minute="0" />
        <Start Hour="18" Minute="0" />
        <Start Hour="22" Minute="0" />
    </Event>
    
    <!-- 每天在特定时间的事件 -->
    <Event Type="101" Name="Devil Square" Duration="600">
        <Start Hour="14" Minute="30" />
        <Start Hour="20" Minute="30" />
    </Event>
    
    <!-- 特定星期几的事件 -->
    <Event Type="102" Name="Castle Siege" Duration="7200">
        <Start DayOfWeek="0" Hour="20" Minute="0" />  <!-- 周日 -->
    </Event>
    
    <!-- 每小时的事件 -->
    <Event Type="103" Name="Golden Invasion" Duration="300">
        <Start Minute="0" />  <!-- 每小时整点 -->
    </Event>
    
    <!-- 带秒级精度的事件 -->
    <Event Type="104" Name="Test Event" Duration="60">
        <Start Hour="15" Minute="30" Second="0" />
    </Event>
</EventScheduler>
```

**时间组件值：**
- `Year`: 特定年份（例如 2025）或 -1 表示任意年份
- `Month`: 1-12 或 -1 表示任意月份
- `Day`: 1-31 或 -1 表示任意日期
- `DayOfWeek`: 0-6（0=周日，6=周六）或 -1 表示任意日期
- `Hour`: 0-23 或 -1 表示任意小时
- `Minute`: 0-59 或 -1 表示任意分钟
- `Second`: 0-59 或 -1 表示任意秒

**注意：** 使用 -1 或省略属性以匹配该组件的"任意"值。

## 数据结构

### EventNotice
由 `Scheduler.CheckEventNotices()` 返回。包含事件类型和距离开始的时间。

**属性：**
- `type` (number): 事件类型 ID
- `secondsRemaining` (number): 距离事件开始的秒数

**示例：**
```lua
local notices = Scheduler.CheckEventNotices()
for _, notice in ipairs(notices) do
    print(string.format("事件 %d 将在 %d 秒后开始", notice.type, notice.secondsRemaining))
end
```

**注意：** EventNotice 是使用 Sol3 注册的 C++ 用户类型。按上述方式直接访问字段。

## 最佳实践

1. **检查频率**: 如果使用秒级精度则每秒调用 `CheckEventStarts()`、`CheckEventEnds()`、`CheckEventNotices()`，否则每分钟调用一次就足够了

2. **事件 ID**: 使用一致的事件类型 ID（建议 1-999）并记录它们

3. **持续时间**: 对于应该自动结束的事件始终指定持续时间（秒）

4. **公告周期**: 对于需要开始前公告的事件设置公告周期（秒）

5. **激活检查**: 使用时间函数前始终检查 `IsEventActive()`

6. **错误处理**: 检查返回值（-1 表示未激活/无效事件）

7. **公告格式化**: 使用 `FormatTimeRemaining()` 等辅助函数显示用户友好的时间字符串，而不是原始秒数

8. **EventNotice 访问**: 直接访问 EventNotice 字段（`notice.type`、`notice.secondsRemaining`），而不是作为函数调用

## 注意事项

- 调度器自动防止同一秒内重复触发
- 无持续时间的事件保持激活状态直到手动结束
- 每个事件可以定义多个开始时间
- 时间组件支持通配符（-1 = 任意）
- 所有时间函数对未激活事件返回 -1
- 进度和剩余时间需要事件定义持续时间
- `CheckEventNotices()` 返回 EventNotice 对象（不仅仅是事件类型 ID），包含时间信息
- EventNotice 是 C++ 用户类型 - 直接访问字段，不是方法

## 另请参见
- [[Timer API|Timers]] - 自定义计时器
- [[Message API|Player-Structure]] - 事件公告
