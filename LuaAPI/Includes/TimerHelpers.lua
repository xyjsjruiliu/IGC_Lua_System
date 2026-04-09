--═══════════════════════════════════════════════════════════════
--== INTERNATIONAL GAMING CENTER NETWORK
--== www.igcn.mu
--== (C) 2010-2026 IGC-Network (R)
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--== File is a part of IGCN Group MuOnline Server files.
--═══════════════════════════════════════════════════════════════

------------------------------------------------------------------
-- TimerHelpers.lua - 定时器辅助函数库
------------------------------------------------------------------
-- 为常用定时器模式提供的便捷封装。
-- 提供基于秒数的 API 以及防抖、节流、
-- 倒计时、超时和带自动清理的重试等模式。
------------------------------------------------------------------

TimerHelpers = {}

------------------------------------------------------------------
-- 延迟执行（秒数便捷方法）
------------------------------------------------------------------

-- 在指定延迟后执行函数（单位：秒）
-- @param seconds: 延迟秒数
-- @param name: 必需的定时器名称（字符串）
-- @param callback: 待执行的函数
-- @return: 定时器 ID，出错时返回 -1
function TimerHelpers.Delay(seconds, name, callback)
	return Timer.Create(seconds * 1000, name, callback)
end

-- 示例:
-- TimerHelpers.Delay(5, "NoticeTimer", function() 
--     Log.Add("5 seconds have passed") 
-- end)

------------------------------------------------------------------
-- 重复执行（秒数便捷方法）
------------------------------------------------------------------

-- 重复执行函数（按秒数间隔）
-- @param seconds: 间隔秒数
-- @param name: 必需的定时器名称（字符串）
-- @param callback: 待执行的函数
-- @param aliveTimeSeconds: 可选 - 经过此秒数后自动移除定时器
-- @return: 定时器 ID，出错时返回 -1
function TimerHelpers.Repeat(seconds, name, callback, aliveTimeSeconds)
	local aliveTimeMs = aliveTimeSeconds and (aliveTimeSeconds * 1000) or -1
	return Timer.CreateRepeating(seconds * 1000, name, callback, aliveTimeMs)
end

-- 示例:
-- TimerHelpers.Repeat(1, "HealthRegen", function()
--     Log.Add("Tick")
-- end)
--
-- 60秒后自动移除的示例:
-- TimerHelpers.Repeat(1, "TempBuff", function()
--     -- Your repeating logic here
-- end, 60)

------------------------------------------------------------------
-- 倒计时定时器
------------------------------------------------------------------

-- 执行倒计时，每秒触发回调函数
-- @param seconds: 倒计时总秒数
-- @param name: 必需的定时器名称（字符串）
-- @param onTick: 每秒调用一次，参数为剩余秒数
-- @param onComplete: 倒计时结束时调用
-- @return: 定时器 ID，出错时返回 -1
function TimerHelpers.Countdown(seconds, name, onTick, onComplete)
	return Timer.RepeatNTimes(1000, name, seconds, function(current, total)
		local remaining = total - current + 1
		
		if onTick then
			onTick(remaining)
		end
		
		if current == total and onComplete then
			onComplete()
		end
	end)
end

-- 示例:
-- TimerHelpers.Countdown(10, "EventCountdown",
--     function(remaining) 
--         Log.Add("Event starts in " .. remaining .. " seconds")
--     end,
--     function() 
--         Log.Add("Event started!")
--     end
-- )

------------------------------------------------------------------
-- 防抖（防止快速重复执行）
------------------------------------------------------------------

-- 对函数调用进行防抖处理 - 每次调用都会重启定时器
-- 只有在延迟期间没有新调用时，最后一次调用才会执行
-- GameServer 会自动移除相同名称的旧定时器
-- @param name: 唯一的防抖标识符（会自动添加前缀）
-- @param delayMs: 延迟毫秒数
-- @param callback: 延迟后执行的函数
-- @return: 定时器 ID
function TimerHelpers.Debounce(name, delayMs, callback)
	return Timer.Create(delayMs, "Debounce_" .. name, callback)
end

-- 示例：防止按钮刷屏点击
-- function onButtonClick(player)
--     TimerHelpers.Debounce("button_" .. player.Index, 1000, function()
--         Log.Add("Button clicked by player " .. player.Index)
--         -- Process click here
--     end)
-- end
-- 
-- 快速点击每次都会重启定时器。
-- 只有在连续1秒没有新点击后，最后一次点击才会执行。

------------------------------------------------------------------
-- 节流（限制执行频率）
------------------------------------------------------------------

-- 对函数执行进行节流控制 - 在冷却期内忽略调用
-- 第一次调用立即执行并进入冷却期
-- 冷却期内的后续调用将被忽略
-- @param name: 唯一的节流标识符（会自动添加前缀）
-- @param intervalMs: 冷却期毫秒数
-- @param callback: 待执行的函数（仅在非冷却期内执行）
-- @return: 执行时返回 true，被节流时返回 false
function TimerHelpers.Throttle(name, intervalMs, callback)
	local timerName = "Throttle_" .. name
	
	-- 检查是否仍在冷却期内
	if Timer.ExistsByName(timerName) then
		return false  -- Throttled - ignore this call
	end
	
	-- 立即执行回调函数
	if callback then
		callback()
	end
	
	-- 开始冷却期
	Timer.Create(intervalMs, timerName, function()
		-- 冷却期结束 - 定时器自动移除
	end)
	
	return true  -- 已执行
end

-- 示例：限制聊天频率
-- function onPlayerChat(player, message)
--     if TimerHelpers.Throttle("chat_" .. player.Index, 2000, function()
--         Log.Add("Player " .. player.Index .. " sent: " .. message)
--         -- Broadcast message here
--     end) then
--         -- Message sent
--     else
--         Message.Send(0, player.Index, 0, "Please wait before chatting again")
--     end
-- end
-- 
-- 第一次调用立即执行并启动2秒冷却期。
-- 2秒内的后续调用将被忽略。

------------------------------------------------------------------
-- 超时（条件未满足时自动取消）
------------------------------------------------------------------

-- 当条件满足时执行回调，否则超时后取消
-- 重复检查条件直到满足或达到超时时间
-- @param name: 必需的定时器名称（字符串）
-- @param timeoutMs: 最大等待毫秒数
-- @param condition: 条件函数，条件满足时返回 true
-- @param onSuccess: 条件满足时调用的函数
-- @param onTimeout: 达到超时时调用的函数
-- @return: 定时器 ID，出错时返回 -1
function TimerHelpers.Timeout(name, timeoutMs, condition, onSuccess, onTimeout)
	local checkInterval = math.min(100, timeoutMs / 10)  -- 检查10次，或每100毫秒检查一次
	local elapsed = 0
	
	return Timer.CreateRepeating(checkInterval, name, function()
		elapsed = elapsed + checkInterval
		
		if condition() then
			-- 条件满足 - 成功
			Timer.RemoveByName(name)
			if onSuccess then
				onSuccess()
			end
		elseif elapsed >= timeoutMs then
			-- 达到超时
			Timer.RemoveByName(name)
			if onTimeout then
				onTimeout()
			end
		end
	end, timeoutMs)  -- 存活时间，防止无限执行
end

-- 示例：等待玩家进入区域
-- local targetX, targetY, targetRange = 100, 100, 10
-- 
-- TimerHelpers.Timeout("PlayerAreaCheck", 30000,
--     function() 
--         -- 检查玩家是否在区域内
--         local dx = player.X - targetX
--         local dy = player.Y - targetY
--         local distance = math.sqrt(dx * dx + dy * dy)
--         return distance <= targetRange
--     end,
--     function() 
--         Log.Add("玩家已到达区域")
--         -- 发放奖励
--     end,
--     function() 
--         Message.Send(0, player.Index, 0, "您未能及时到达指定区域!")
--     end
-- )

------------------------------------------------------------------
-- 带指数退避的重试机制
------------------------------------------------------------------

-- 使用指数退避策略重试函数，直到成功或达到最大尝试次数
-- 每次失败后延迟时间翻倍
-- @param name: 必需的定时器名称（字符串）
-- @param initialDelayMs: 初始延迟毫秒数
-- @param maxAttempts: 最大尝试次数
-- @param operation: 待执行的函数，成功时应返回 true
-- @param onSuccess: 操作成功时调用的函数
-- @param onFailure: 所有尝试耗尽时调用的函数
-- @return: 定时器 ID，出错时返回 -1
function TimerHelpers.RetryWithBackoff(name, initialDelayMs, maxAttempts, operation, onSuccess, onFailure)
	local attempt = 0
	local delay = initialDelayMs
	
	local function tryExecute()
		attempt = attempt + 1
		
		local success = operation(attempt, maxAttempts)
		
		if success then
			if onSuccess then
				onSuccess(attempt)
			end
		elseif attempt >= maxAttempts then
			if onFailure then
				onFailure(attempt)
			end
		else
			-- 使用指数退避策略调度重试
			delay = delay * 2
			Timer.Create(delay, name, tryExecute)
		end
	end
	
	return Timer.Create(initialDelayMs, name, tryExecute)
end

-- 示例：重试操作
-- TimerHelpers.RetryWithBackoff("RetryOperation", 1000, 5,
--     function(attempt, max)
--         Log.Add("尝试次数 " .. attempt .. "/" .. max)
--         -- 尝试执行操作，成功时返回 true
--         return math.random() > 0.7  -- 示例：30% 成功率
--     end,
--     function(attempt)
--         Log.Add("经过 " .. attempt .. " 次尝试后成功")
--     end,
--     function(attempt)
--         Log.Add("经过 " .. attempt .. " 次尝试后失败")
--     end
-- )

------------------------------------------------------------------
-- 带抖动的间隔定时器（防止惊群效应）
------------------------------------------------------------------

-- 创建带有随机抖动的重复定时器
-- 防止所有服务器/客户端在同一精确时间点执行
-- @param baseIntervalMs: 基础间隔毫秒数
-- @param jitterPercent: 抖动百分比（0-100）
-- @param name: 必需的定时器名称（字符串）
-- @param callback: 待执行的函数
-- @param aliveTimeMs: 可选 - 经过此毫秒数后自动移除定时器
-- @return: 定时器 ID，出错时返回 -1
function TimerHelpers.RepeatWithJitter(baseIntervalMs, jitterPercent, name, callback, aliveTimeMs)
	-- 计算抖动范围
	local jitterRange = baseIntervalMs * (jitterPercent / 100)
	local minInterval = baseIntervalMs - (jitterRange / 2)
	local maxInterval = baseIntervalMs + (jitterRange / 2)
	
	-- 范围内的随机间隔
	local interval = math.random(minInterval, maxInterval)
	
	return Timer.CreateRepeating(interval, name, callback, aliveTimeMs or -1)
end

-- 示例：带抖动的周期性任务
-- TimerHelpers.RepeatWithJitter(60000, 10, "PeriodicTask", function()
--     Log.Add("Task executed")
--     -- 在此处编写周期性任务逻辑
-- end)
-- 每 60 秒 ± 6 秒（54-66 秒）执行一次

------------------------------------------------------------------
-- 按模式取消多个定时器
------------------------------------------------------------------

-- 移除具有相同名称模式的多个定时器
-- @param namePattern: 基础名称模式（例如 "Player_" .. index）
-- @param suffixes: 要附加的定时器名称后缀数组
function TimerHelpers.CancelTimers(namePattern, suffixes)
	for _, suffix in ipairs(suffixes) do
		local name = namePattern .. "_" .. suffix
		Timer.RemoveByName(name)
	end
end

-- 示例：在玩家断开连接时清理所有玩家相关的定时器
-- function onPlayerDisconnect(player)
--     local prefix = "Player_" .. player.Index
--     TimerHelpers.CancelTimers(prefix, {
--         "Buff",
--         "Debuff",
--         "Poison",
--         "Cooldown"
--     })
-- end

------------------------------------------------------------------
-- 辅助函数：生成唯一的定时器名称
------------------------------------------------------------------

-- 生成带有前缀和随机后缀的唯一定时器名称
-- @param prefix: 名称前缀
-- @return: 唯一名称字符串
function TimerHelpers.UniqueName(prefix)
	return prefix .. "_" .. os.time() .. "_" .. math.random(1000, 9999)
end

-- 示例:
-- local name = TimerHelpers.UniqueName("TempTimer")
-- Timer.Create(1000, name, function()
--     Log.Add("Unique timer fired")
-- end)

------------------------------------------------------------------
-- 使用说明
------------------------------------------------------------------

-- GameServer 要求定时器名称必须提供。
-- 当您创建同名的新定时器时，GameServer 
-- 会自动移除旧的定时器 —— 无需手动清理！
--
-- 最佳实践：
--   1. 使用描述性名称：使用 "EventCountdown" 而不是 "t1"
--   2. 为相关的定时器使用前缀：如 "Player_123_Buff"
--   3. 对于不应频繁触发的操作使用防抖（Debounce）
--   4. 对于需要限频的操作使用节流（Throttle）
--   5. 在断开连接时使用 CancelTimers() 清理定时器
--
-- 直接定时器 API：
--   Timer.Create(intervalMs, name, callback)
--   Timer.CreateRepeating(intervalMs, name, callback, aliveTimeMs)
--   Timer.RepeatNTimes(intervalMs, name, count, callback)
--   Timer.RemoveByName(name)
--   Timer.ExistsByName(name)
--   Timer.GetCount()
