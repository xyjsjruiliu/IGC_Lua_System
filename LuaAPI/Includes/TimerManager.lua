--═══════════════════════════════════════════════════════════════
--== INTERNATIONAL GAMING CENTER NETWORK
--== www.igcn.mu
--== (C) 2010-2026 IGC-Network (R)
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--== File is a part of IGCN Group MuOnline Server files.
--═══════════════════════════════════════════════════════════════

------------------------------------------------------------------
-- TimerManager.lua - 简单命名计时器存储
------------------------------------------------------------------
-- 使用字符串名称存储计时器 ID，便于跨文件访问。
-- 当重复使用相同名称时，自动移除旧计时器。
------------------------------------------------------------------

TimerManager = TimerManager or {}

------------------------------------------------------------------
-- 私有存储
------------------------------------------------------------------

-- 单一存储：名称 -> timerId
local timers = {}

------------------------------------------------------------------
-- 函数
------------------------------------------------------------------

-- 存储带名称的计时器（自动移除同名的旧计时器）
-- @param name: 计时器名称 (字符串)
-- @param timerId: Timer.Create/CreateRepeating/RepeatNTimes 返回的计时器 ID
function TimerManager.Set(name, timerId)
	-- Remove old timer if exists
	if timers[name] then
		Timer.Remove(timers[name])
	end
	
	timers[name] = timerId
end

-- 根据名称获取计时器 ID
-- @param name: 计时器名称
-- @return: 计时器 ID 或 nil（未找到时）
function TimerManager.Get(name)
	return timers[name]
end

-- 根据名称移除计时器
-- @param name: 计时器名称
-- @return: 如果移除成功返回 true，未找到返回 false
function TimerManager.Remove(name)
	if timers[name] then
		Timer.Remove(timers[name])
		timers[name] = nil
		return true
	end
	return false
end

-- 检查计时器是否存在
-- @param name: 计时器名称
-- @return: 存在返回 true
function TimerManager.Exists(name)
	return timers[name] ~= nil
end

-- 移除所有计时器
function TimerManager.Clear()
	for name, timerId in pairs(timers) do
		Timer.Remove(timerId)
	end
	timers = {}
end

-- 获取已存储的计时器数量
-- @return: 计时器数量
function TimerManager.Count()
	local count = 0
	for _ in pairs(timers) do
		count = count + 1
	end
	return count
end

-- 列出所有计时器名称（用于调试）
-- @return: 计时器名称数组
function TimerManager.List()
	local names = {}
	for name, _ in pairs(timers) do
		table.insert(names, name)
	end
	return names
end