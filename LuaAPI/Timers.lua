--═══════════════════════════════════════════════════════════════
--== INTERNATIONAL GAMING CENTER NETWORK
--== www.igcn.mu
--== (C) 2010-2026 IGC-Network (R)
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--== File is a part of IGCN Group MuOnline Server files.
--═══════════════════════════════════════════════════════════════

------------------------------------------------------------------
-- 计时器回调（由 C++ 引擎调用）
------------------------------------------------------------------

-- 每秒调用一次
function onTimerProcessSecond()
	EventScheduler.ProcessEvents()
end

-- 每分钟调用一次
function onTimerProcessMinute()
	-- 在此添加基于分钟的处理逻辑
end

-- 每小时调用一次
function onTimerProcessHour()
	-- 在此添加基于小时的处理逻辑
end

-- 每天调用一次 (午夜0点)
function onTimerProcessDayChange()
	-- 在此添加基于每天的处理逻辑
end
