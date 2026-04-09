--═══════════════════════════════════════════════════════════════
--== INTERNATIONAL GAMING CENTER NETWORK
--== www.igcn.mu
--== (C) 2010-2026 IGC-Network (R)
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--== File is a part of IGCN Group MuOnline Server files.
--═══════════════════════════════════════════════════════════════

------------------------------------------------------------------
-- EventScheduler.lua - 事件调度逻辑
------------------------------------------------------------------
-- 管理事件时间、公告，并委托给事件处理器。
-- 自动将精度限制到分钟级，
-- 除非事件需要秒级精度。
------------------------------------------------------------------

EventScheduler = {}

------------------------------------------------------------------
-- 本地状态
------------------------------------------------------------------

-- 如果有任何事件需要秒级精度（Second != -1），则为 true
local needsSecondPrecision = false

-- 上次分钟检查的时间戳（用于限流）
local lastMinuteCheck = 0

------------------------------------------------------------------
-- 公共函数
------------------------------------------------------------------

-- 初始化事件调度器
-- 加载 XML 配置并处理事件
function EventScheduler.Initialize()
	-- 从 XML 配置加载事件
	Scheduler.LoadFromXML("Plugins\\LuaAPI\\Config\\EventScheduler.xml")
	
	-- 检查调度器是否需要秒级精度
	-- 如果任何事件有特定的秒数值（Second != -1），调度器将每秒检查一次事件
	-- 否则，为获得更好性能，限流为每分钟检查一次
	needsSecondPrecision = Scheduler.HasSecondPrecisionEvents()
	lastMinuteCheck = Timer.GetTick()
	
	local count = Scheduler.GetEventCount()
	-- Log.Add(string.format("[LuaEventScheduler] 已加载 %d 个事件", count))
end

-- 处理计划事件
-- 通过 Main.lua 中的计时器每秒调用一次
-- 如果不需要秒级精度，自动限流为每分钟执行一次
function EventScheduler.ProcessEvents()
	-- 如果不需要秒级精度，则限流为每分钟一次
	if not needsSecondPrecision then
		local currentTick = Timer.GetTick()
		local elapsed = currentTick - lastMinuteCheck
		
		if elapsed < 60000 then
			return
		end
		
		lastMinuteCheck = currentTick
	end
	
	-- 处理事件公告（预警） - 现在返回带有时间的 EventNotice
	local noticeEvents = Scheduler.CheckEventNotices()
	for _, notice in ipairs(noticeEvents) do
		EventHandlers.OnEventNotice(notice.type, notice.secondsRemaining)
	end
	
	-- 处理事件开始
	local triggeredEvents = Scheduler.CheckEventStarts()
	for _, eventType in ipairs(triggeredEvents) do
		EventHandlers.OnEventStart(eventType)
	end
	
	-- 处理事件结束（基于持续时间）
	local endedEvents = Scheduler.CheckEventEnds()
	for _, eventType in ipairs(endedEvents) do
		EventHandlers.OnEventEnd(eventType)
	end
end