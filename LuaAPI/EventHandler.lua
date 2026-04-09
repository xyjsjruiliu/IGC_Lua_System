--═══════════════════════════════════════════════════════════════
--== INTERNATIONAL GAMING CENTER NETWORK
--== www.igcn.mu
--== (C) 2010-2026 IGC-Network (R)
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--== File is a part of IGCN Group MuOnline Server files.
--═══════════════════════════════════════════════════════════════

------------------------------------------------------------------
-- EventHandler.lua - 事件实现处理器
------------------------------------------------------------------
-- 包含所有计划事件的事件处理器实现。
-- 使用分发表实现 O(1) 的事件查找和执行。
-- 通过在相应的处理器表中创建条目来添加新事件。
------------------------------------------------------------------

EventHandlers = {}

------------------------------------------------------------------
-- 辅助函数 / 工具函数
------------------------------------------------------------------

-- 将剩余时间格式化为可读格式
local function FormatTimeRemaining(seconds)
	if seconds < 60 then
		-- 少于1分钟: 显示 秒数
		return string.format("%d 秒%s", seconds, seconds ~= 1 and "s" or "")

	elseif seconds < 3600 then
		-- 少于1小时: 显示 分钟 和 秒数
		local minutes = math.floor(seconds / 60)
		local secs = seconds % 60

		if secs == 0 then
			return string.format("%d 分钟%s", minutes, minutes ~= 1 and "s" or "")
		else
			return string.format("%d 分钟%s %d 秒%s",
				minutes, minutes ~= 1 and "s" or "",
				secs, secs ~= 1 and "s" or "")
		end

	else
		-- 超过1小时: 显示 小时 和 分钟
		local hours = math.floor(seconds / 3600)
		local minutes = math.floor((seconds % 3600) / 60)

		if minutes == 0 then
			return string.format("%d 小时%s", hours, hours ~= 1 and "s" or "")
		else
			return string.format("%d 小时%s %d 分钟%s",
				hours, hours ~= 1 and "s" or "",
				minutes, minutes ~= 1 and "s" or "")
		end
	end
end

------------------------------------------------------------------
-- 分发表 / 分发表
------------------------------------------------------------------

local noticeHandlers = {}  -- 事件前警告处理器
local startHandlers = {}   -- 事件开始警告处理器
local endHandlers = {}     -- 事件结束警告处理器

------------------------------------------------------------------
-- 分发器
------------------------------------------------------------------

-- 分发事件公告（在事件开始前调用）
-- 参数:
--   eventType - 事件类型ID
--   timeRemaining - 距离事件开始的秒数
function EventHandlers.OnEventNotice(eventType, timeRemaining)
	local handler = noticeHandlers[eventType]
	if handler then
		handler(timeRemaining)
	end
end

-- 分发事件开始
function EventHandlers.OnEventStart(eventType)
	local handler = startHandlers[eventType]
	if handler then
		handler()
	end
end

-- 分发事件结束 (持续时间结束后)
function EventHandlers.OnEventEnd(eventType)
	local handler = endHandlers[eventType]
	if handler then
		handler()
	end
end

------------------------------------------------------------------
-- 公告处理器 (预事件 警告)
------------------------------------------------------------------

noticeHandlers[Enums.EventType.SAMPLE_EVENT_1] = function(timeRemaining)
	local name = Scheduler.GetEventName(Enums.EventType.SAMPLE_EVENT_1)
	local timeStr = FormatTimeRemaining(timeRemaining)
	Message.Send(0, -1, 0, name .. " starts in " .. timeStr .. "!")
	Log.Add(string.format("[公告示例1] %s starting in %s", name, timeStr))
end

noticeHandlers[Enums.EventType.SAMPLE_EVENT_2] = function(timeRemaining)
	local name = Scheduler.GetEventName(Enums.EventType.SAMPLE_EVENT_2)
	local timeStr = FormatTimeRemaining(timeRemaining)
	Message.Send(0, -1, 0, name .. " opens in " .. timeStr .. "!")
	Log.Add(string.format("[公告示例2] %s opening in %s", name, timeStr))
end

noticeHandlers[Enums.EventType.SAMPLE_EVENT_3] = function(timeRemaining)
	local name = Scheduler.GetEventName(Enums.EventType.SAMPLE_EVENT_3)
	local timeStr = FormatTimeRemaining(timeRemaining)
	Message.Send(0, -1, 0, name .. " starts in " .. timeStr .. "!")
	Log.Add(string.format("[公告示例3] %s starting in %s", name, timeStr))
end

------------------------------------------------------------------
-- 开始处理器 (事件 开始)
------------------------------------------------------------------

startHandlers[Enums.EventType.SAMPLE_EVENT_1] = function()
	local name = Scheduler.GetEventName(Enums.EventType.SAMPLE_EVENT_1)
	Message.Send(0, -1, 1, name .. " has started!")
	Log.Add(string.format("[事件示例1] %s started", name))
end

startHandlers[Enums.EventType.SAMPLE_EVENT_2] = function()
	local name = Scheduler.GetEventName(Enums.EventType.SAMPLE_EVENT_2)
	Message.Send(0, -1, 1, name .. " is now open!")
	Log.Add(string.format("[事件示例2] %s opened", name))
end

startHandlers[Enums.EventType.SAMPLE_EVENT_3] = function()
	local name = Scheduler.GetEventName(Enums.EventType.SAMPLE_EVENT_3)
	Message.Send(0, -1, 1, name .. " - Double EXP!")
	Log.Add(string.format("[事件示例3] %s started", name))
end

------------------------------------------------------------------
-- 结束处理器 (事件 完成)
------------------------------------------------------------------

endHandlers[Enums.EventType.SAMPLE_EVENT_1] = function()
	local name = Scheduler.GetEventName(Enums.EventType.SAMPLE_EVENT_1)
	Message.Send(0, -1, 1, name .. " has ended!")
	Log.Add(string.format("[事件示例1] %s ended", name))
end

endHandlers[Enums.EventType.SAMPLE_EVENT_2] = function()
	local name = Scheduler.GetEventName(Enums.EventType.SAMPLE_EVENT_2)
	Message.Send(0, -1, 1, name .. " has closed!")
	Log.Add(string.format("[事件示例2] %s closed", name))
end

endHandlers[Enums.EventType.SAMPLE_EVENT_3] = function()
	local name = Scheduler.GetEventName(Enums.EventType.SAMPLE_EVENT_3)
	Message.Send(0, -1, 1, name .. " has ended!")
	Log.Add(string.format("[事件示例3] %s ended", name))
end