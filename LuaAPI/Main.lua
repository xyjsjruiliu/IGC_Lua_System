--═══════════════════════════════════════════════════════════════
--== INTERNATIONAL GAMING CENTER NETWORK
--== www.igcn.mu
--== (C) 2010-2026 IGC-Network (R)
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--== File is a part of IGCN Group MuOnline Server files.
--═══════════════════════════════════════════════════════════════

------------------------------------------------------------------
-- Main.lua - 服务器脚本入口点
------------------------------------------------------------------
-- 初始化核心服务器功能和计时器回调。
-- 当脚本从 C++ 刷新时，模块会自动重新加载。
------------------------------------------------------------------

local BASE = "Plugins\\LuaAPI\\"

-- 加载全局依赖项（顺序很重要）
LoadScript(BASE .. "Defines\\Helpers.lua")
LoadScript(BASE .. "Defines\\Constants.lua")
LoadScript(BASE .. "Defines\\Enums.lua")
LoadScript(BASE .. "EventHandler.lua")
LoadScript(BASE .. "Callbacks.lua")
LoadScript(BASE .. "Includes\\TimerHelpers.lua")
LoadScript(BASE .. "Includes\\EventScheduler.lua")
LoadScript(BASE .. "Timers.lua")

-- 初始化事件调度器
EventScheduler.Initialize()
