--═══════════════════════════════════════════════════════════════
--== INTERNATIONAL GAMING CENTER NETWORK
--== www.igcn.mu
--== (C) 2010-2026 IGC-Network (R)
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--== File is a part of IGCN Group MuOnline Server files.
--═══════════════════════════════════════════════════════════════

------------------------------------------------------------------
-- Helpers.lua - 全局辅助函数
------------------------------------------------------------------
-- 颜色转换和物品ID计算的实用工具函数。
-- 通过 Use() 全局加载 - 无需 require。
------------------------------------------------------------------

Helpers = {}

-- 重现 Windows API 中的 COLORREF RGB 宏
-- 将 RGB 颜色分量 (0-255) 转换为单个 DWORD 值
-- 用法: local color = Helpers.RGB(255, 0, 0)  — 红色
function Helpers.RGB(r, g, b)
	return (r & 0xFF) | ((g & 0xFF) << 8) | ((b & 0xFF) << 16)
end

-- 根据 ItemType 和 ItemIndex 计算 ItemId
-- ItemType: 物品组/类别 (0-15)
-- ItemIndex: 该组内的物品索引 (0-511)
-- 用法: local itemId = Helpers.MakeItemId(14, 13)
function Helpers.MakeItemId(ItemType, ItemIndex)
	return ItemType * 512 + ItemIndex
end

-- 从 ItemId 中提取 ItemType
-- 返回物品组/类别 (0-15)
-- 用法: local itemType = Helpers.GetItemType(7181)  -- 返回 14	实际是祝福宝石
function Helpers.GetItemType(ItemId)
	return math.floor(ItemId / 512)
end

-- 从 ItemId 中提取 ItemIndex
-- 返回该组内的物品索引 (0-511)
-- 用法: local itemIndex = Helpers.GetItemIndex(7181)  -- 返回 13	实际是祝福宝石
function Helpers.GetItemIndex(ItemId)
	return ItemId % 512
end

