--═══════════════════════════════════════════════════════════════
--== INTERNATIONAL GAMING CENTER NETWORK
--== www.igcn.mu
--== (C) 2010-2026 IGC-Network (R)
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--== AchieveSystem.lua - 成就系统（完善版）
--== 包含：物品拾取追踪、PvP/怪物击杀追踪、文件持久化、
--==       奖励发放、定时自动保存、回调分派注册
--═══════════════════════════════════════════════════════════════
--
-- [架构说明]
-- 本文件不再直接定义 onItemGet / onPlayerLogin 等全局回调函数，
-- 而是通过 AchievementSystem.RegisterCallbacks() 将处理函数
-- 注册到 Callbacks.lua 的分派表中。这样多个系统可以共享同
-- 一个回调，不会互相覆盖。
--
-- 如果你的 Callbacks.lua 尚未支持分派表，请调用
-- AchievementSystem.InstallGlobalHooks() 以兼容旧模式（会
-- 覆盖全局函数）。
--═══════════════════════════════════════════════════════════════

------------------------------------------------------------------
-- 全局命名空间
------------------------------------------------------------------

AchievementSystem = AchievementSystem or {}

------------------------------------------------------------------
-- 配置
------------------------------------------------------------------

--- 数据文件路径（相对于服务器根目录）
AchievementSystem.DataPath = "Plugins\\LuaAPI\\Config\\AchievementData.json"

--- 当前数据版本（用于迁移）
AchievementSystem.DATA_VERSION = 2

--- 自动保存间隔（秒）
AchievementSystem.AUTO_SAVE_INTERVAL = 300  -- 5分钟

--- 每页显示成就数
AchievementSystem.PER_PAGE = 6

--- 延迟保存毫秒数（拾取后防抖）
AchievementSystem.SAVE_DEBOUNCE_MS = 3000

------------------------------------------------------------------
-- 成就定义表
-- 字段说明：
--   id          - 成就唯一ID（100-999）
--   name        - 成就名称
--   desc        - 成就描述
--   category    - 分类键名（见 AchievementSystem.CategoryNames）
--   hidden      - [可选] 是否为隐藏成就（未完成前不显示描述）
--   itemId      - 关联物品ID（pickup 类）
--   targetCount - 目标数量（pickup/pickup_any/pickup_total/inventory/kill_monster/kill_player 类）
--   minLevel    - 最低强化等级（weapon/armor 类）
--   minCount    - 最低数量（excellent/set 类）
--   targetLevel - 目标角色等级（level 类）
--   targetMasterLevel - 目标大师等级（master_level 类）
--   targetMinutes - 目标在线分钟数（playtime 类）
--   rewards     - 奖励列表，每项格式：
--       { type = "zen",     value = 1000000 }
--       { type = "item",    itemId = 7181, count = 10 }
--       { type = "buff",    buffIndex = 10, effectType1 = 0, effectValue1 = 0,
--                          effectType2 = 0, effectValue2 = 0, duration = 3600 }
------------------------------------------------------------------

AchievementSystem.Definitions = {

    -- ═══════════════════ 宝石拾取类 ═══════════════════

    {
        id = 101, name = "宝石收藏家", desc = "累计拾取祝福宝石 x10",
        category = "pickup", itemId = 7181, targetCount = 10,
        rewards = {
            { type = "zen",  value = 500000 },
            { type = "buff", buffIndex = 10, effectType1 = 0, effectValue1 = 0,
              effectType2 = 0, effectValue2 = 0, duration = 600 },
        },
    },
    {
        id = 102, name = "宝石大师", desc = "累计拾取祝福宝石 x100",
        category = "pickup", itemId = 7181, targetCount = 100,
        rewards = {
            { type = "zen",  value = 5000000 },
            { type = "item", itemId = 7181, count = 10 },
            { type = "buff", buffIndex = 10, effectType1 = 0, effectValue1 = 0,
              effectType2 = 0, effectValue2 = 0, duration = 1800 },
        },
    },
    {
        id = 103, name = "灵魂使者", desc = "累计拾取灵魂宝石 x10",
        category = "pickup", itemId = 7194, targetCount = 10,
        rewards = {
            { type = "zen",  value = 500000 },
            { type = "buff", buffIndex = 11, effectType1 = 0, effectValue1 = 0,
              effectType2 = 0, effectValue2 = 0, duration = 600 },
        },
    },
    {
        id = 104, name = "灵魂猎手", desc = "累计拾取灵魂宝石 x100",
        category = "pickup", itemId = 7194, targetCount = 100,
        rewards = {
            { type = "zen",  value = 5000000 },
            { type = "item", itemId = 7194, count = 10 },
            { type = "buff", buffIndex = 11, effectType1 = 0, effectValue1 = 0,
              effectType2 = 0, effectValue2 = 0, duration = 1800 },
        },
    },
    {
        id = 105, name = "生命守护者", desc = "累计拾取生命宝石 x10",
        category = "pickup", itemId = 7190, targetCount = 10,
        rewards = {
            { type = "zen",  value = 300000 },
            { type = "buff", buffIndex = 8, effectType1 = 0, effectValue1 = 0,
              effectType2 = 0, effectValue2 = 0, duration = 600 },
        },
    },
    {
        id = 106, name = "混沌收集者", desc = "累计拾取混沌宝石 x10",
        category = "pickup", itemId = 6159, targetCount = 10,
        rewards = {
            { type = "zen",  value = 1000000 },
            { type = "buff", buffIndex = 7, effectType1 = 0, effectValue1 = 0,
              effectType2 = 0, effectValue2 = 0, duration = 600 },
        },
    },
    {
        id = 107, name = "创世宝石猎人", desc = "累计拾取创世宝石 x50",
        category = "pickup", itemId = 7841, targetCount = 50,
        rewards = {
            { type = "zen",  value = 20000000 },
            { type = "item", itemId = 7841, count = 5 },
            { type = "buff", buffIndex = 6, effectType1 = 0, effectValue1 = 0,
              effectType2 = 0, effectValue2 = 0, duration = 3600 },
        },
    },

    -- ═══════════════════ 武器强化类 ═══════════════════

    {
        id = 201, name = "新手武器", desc = "拥有 +5 以上强化等级的武器",
        category = "weapon", minLevel = 5,
        rewards = {
            { type = "zen", value = 200000 },
        },
    },
    {
        id = 202, name = "进阶武器", desc = "拥有 +9 以上强化等级的武器",
        category = "weapon", minLevel = 9,
        rewards = {
            { type = "zen",  value = 1000000 },
            { type = "buff", buffIndex = 10, effectType1 = 0, effectValue1 = 0,
              effectType2 = 0, effectValue2 = 0, duration = 600 },
        },
    },
    {
        id = 203, name = "传说武器", desc = "拥有 +13 以上强化等级的武器",
        category = "weapon", minLevel = 13,
        rewards = {
            { type = "zen",  value = 10000000 },
            { type = "buff", buffIndex = 11, effectType1 = 0, effectValue1 = 0,
              effectType2 = 0, effectValue2 = 0, duration = 1800 },
        },
    },
    {
        id = 204, name = "神器武器", desc = "拥有 +15 强化等级的武器",
        category = "weapon", minLevel = 15,
        rewards = {
            { type = "zen",  value = 50000000 },
            { type = "buff", buffIndex = 6, effectType1 = 0, effectValue1 = 0,
              effectType2 = 0, effectValue2 = 0, duration = 3600 },
        },
    },

    -- ═══════════════════ 防具强化类 ═══════════════════

    {
        id = 301, name = "防具收集", desc = "拥有 +5 以上强化等级的防具",
        category = "armor", minLevel = 5,
        rewards = {
            { type = "zen", value = 200000 },
        },
    },
    {
        id = 302, name = "高级防具", desc = "拥有 +9 以上强化等级的防具",
        category = "armor", minLevel = 9,
        rewards = {
            { type = "zen",  value = 1000000 },
            { type = "buff", buffIndex = 8, effectType1 = 0, effectValue1 = 0,
              effectType2 = 0, effectValue2 = 0, duration = 600 },
        },
    },
    {
        id = 303, name = "套装收集者", desc = "拥有 3 件以上套装装备",
        category = "set", minCount = 3,
        rewards = {
            { type = "zen",  value = 3000000 },
            { type = "buff", buffIndex = 10, effectType1 = 0, effectValue1 = 0,
              effectType2 = 0, effectValue2 = 0, duration = 1200 },
        },
    },

    -- ═══════════════════ 卓越属性类 ═══════════════════

    {
        id = 401, name = "初露锋芒", desc = "拥有 1 件卓越装备",
        category = "excellent", minCount = 1,
        rewards = {
            { type = "zen", value = 100000 },
        },
    },
    {
        id = 402, name = "卓越骑士", desc = "拥有 5 件以上卓越装备",
        category = "excellent", minCount = 5,
        rewards = {
            { type = "zen",  value = 2000000 },
            { type = "buff", buffIndex = 11, effectType1 = 0, effectValue1 = 0,
              effectType2 = 0, effectValue2 = 0, duration = 600 },
        },
    },
    {
        id = 403, name = "卓越大师", desc = "拥有 10 件以上卓越装备",
        category = "excellent", minCount = 10,
        rewards = {
            { type = "zen",  value = 10000000 },
            { type = "buff", buffIndex = 6, effectType1 = 0, effectValue1 = 0,
              effectType2 = 0, effectValue2 = 0, duration = 1800 },
        },
    },

    -- ═══════════════════ 角色等级类 ═══════════════════

    {
        id = 501, name = "初出茅庐", desc = "角色等级达到 100",
        category = "level", targetLevel = 100,
        rewards = {
            { type = "zen",  value = 1000000 },
            { type = "buff", buffIndex = 10, effectType1 = 0, effectValue1 = 0,
              effectType2 = 0, effectValue2 = 0, duration = 600 },
        },
    },
    {
        id = 502, name = "小有名气", desc = "角色等级达到 300",
        category = "level", targetLevel = 300,
        rewards = {
            { type = "zen",  value = 5000000 },
            { type = "item", itemId = 7181, count = 5 },
            { type = "buff", buffIndex = 11, effectType1 = 0, effectValue1 = 0,
              effectType2 = 0, effectValue2 = 0, duration = 1200 },
        },
    },
    {
        id = 503, name = "一方霸主", desc = "角色等级达到 400",
        category = "level", targetLevel = 400,
        rewards = {
            { type = "zen",  value = 20000000 },
            { type = "item", itemId = 7194, count = 5 },
            { type = "buff", buffIndex = 6, effectType1 = 0, effectValue1 = 0,
              effectType2 = 0, effectValue2 = 0, duration = 3600 },
        },
    },

    -- ═══════════════════ 大师等级类 ═══════════════════

    {
        id = 511, name = "初入大师", desc = "大师等级达到 50",
        category = "master_level", targetMasterLevel = 50,
        rewards = {
            { type = "zen",  value = 3000000 },
            { type = "buff", buffIndex = 10, effectType1 = 0, effectValue1 = 0,
              effectType2 = 0, effectValue2 = 0, duration = 600 },
        },
    },
    {
        id = 512, name = "大师之路", desc = "大师等级达到 200",
        category = "master_level", targetMasterLevel = 200,
        rewards = {
            { type = "zen",  value = 10000000 },
            { type = "item", itemId = 7181, count = 10 },
            { type = "buff", buffIndex = 11, effectType1 = 0, effectValue1 = 0,
              effectType2 = 0, effectValue2 = 0, duration = 1800 },
        },
    },
    {
        id = 513, name = "宗师之巅", desc = "大师等级达到 400",
        category = "master_level", targetMasterLevel = 400,
        rewards = {
            { type = "zen",  value = 50000000 },
            { type = "item", itemId = 7194, count = 10 },
            { type = "buff", buffIndex = 6, effectType1 = 0, effectValue1 = 0,
              effectType2 = 0, effectValue2 = 0, duration = 3600 },
        },
    },

    -- ═══════════════════ 背包容量类 ═══════════════════

    {
        id = 601, name = "背包探险家", desc = "背包物品数量达到 20",
        category = "inventory", targetCount = 20,
        rewards = {
            { type = "zen", value = 500000 },
        },
    },
    {
        id = 602, name = "背包收藏家", desc = "背包物品数量达到 50",
        category = "inventory", targetCount = 50,
        rewards = {
            { type = "zen",  value = 3000000 },
            { type = "buff", buffIndex = 10, effectType1 = 0, effectValue1 = 0,
              effectType2 = 0, effectValue2 = 0, duration = 600 },
        },
    },

    -- ═══════════════════ 拾取综合类 ═══════════════════

    {
        id = 701, name = "全宝石收藏家", desc = "累计拾取任意宝石总计 500 个",
        category = "pickup_any", targetCount = 500,
        rewards = {
            { type = "zen",  value = 10000000 },
            { type = "item", itemId = 7181, count = 20 },
            { type = "item", itemId = 7194, count = 20 },
            { type = "buff", buffIndex = 6, effectType1 = 0, effectValue1 = 0,
              effectType2 = 0, effectValue2 = 0, duration = 3600 },
        },
    },
    {
        id = 702, name = "幸运新手", desc = "累计拾取物品 100 次",
        category = "pickup_total", targetCount = 100,
        rewards = {
            { type = "zen",  value = 1000000 },
            { type = "buff", buffIndex = 10, effectType1 = 0, effectValue1 = 0,
              effectType2 = 0, effectValue2 = 0, duration = 600 },
        },
    },
    {
        id = 703, name = "资深探索者", desc = "累计拾取物品 1000 次",
        category = "pickup_total", targetCount = 1000,
        rewards = {
            { type = "zen",  value = 10000000 },
            { type = "buff", buffIndex = 11, effectType1 = 0, effectValue1 = 0,
              effectType2 = 0, effectValue2 = 0, duration = 1800 },
        },
    },

    -- ═══════════════════ 怪物击杀类 ═══════════════════

    {
        id = 801, name = "猎魔新手", desc = "累计击杀怪物 100 只",
        category = "kill_monster", targetCount = 100,
        rewards = {
            { type = "zen", value = 500000 },
        },
    },
    {
        id = 802, name = "猎魔老手", desc = "累计击杀怪物 1000 只",
        category = "kill_monster", targetCount = 1000,
        rewards = {
            { type = "zen",  value = 5000000 },
            { type = "buff", buffIndex = 10, effectType1 = 0, effectValue1 = 0,
              effectType2 = 0, effectValue2 = 0, duration = 600 },
        },
    },
    {
        id = 803, name = "屠魔勇士", desc = "累计击杀怪物 10000 只",
        category = "kill_monster", targetCount = 10000,
        rewards = {
            { type = "zen",  value = 30000000 },
            { type = "item", itemId = 7181, count = 20 },
            { type = "buff", buffIndex = 6, effectType1 = 0, effectValue1 = 0,
              effectType2 = 0, effectValue2 = 0, duration = 3600 },
        },
    },

    -- ═══════════════════ PvP 击杀类 ═══════════════════

    {
        id = 901, name = "初战告捷", desc = "累计击杀玩家 10 人",
        category = "kill_player", targetCount = 10,
        rewards = {
            { type = "zen", value = 1000000 },
        },
    },
    {
        id = 902, name = "战场常客", desc = "累计击杀玩家 100 人",
        category = "kill_player", targetCount = 100,
        rewards = {
            { type = "zen",  value = 10000000 },
            { type = "buff", buffIndex = 11, effectType1 = 0, effectValue1 = 0,
              effectType2 = 0, effectValue2 = 0, duration = 1800 },
        },
    },
    {
        id = 903, name = "战争之王", desc = "累计击杀玩家 500 人",
        category = "kill_player", targetCount = 500,
        rewards = {
            { type = "zen",  value = 50000000 },
            { type = "item", itemId = 7841, count = 5 },
            { type = "buff", buffIndex = 6, effectType1 = 0, effectValue1 = 0,
              effectType2 = 0, effectValue2 = 0, duration = 3600 },
        },
    },

    -- ═══════════════════ 在线时长类 ═══════════════════

    {
        id = 1001, name = "驻足片刻", desc = "累计在线时长 60 分钟",
        category = "playtime", targetMinutes = 60,
        rewards = {
            { type = "zen", value = 200000 },
        },
    },
    {
        id = 1002, name = "日夜相伴", desc = "累计在线时长 600 分钟",
        category = "playtime", targetMinutes = 600,
        rewards = {
            { type = "zen",  value = 3000000 },
            { type = "buff", buffIndex = 10, effectType1 = 0, effectValue1 = 0,
              effectType2 = 0, effectValue2 = 0, duration = 600 },
        },
    },
    {
        id = 1003, name = "不离不弃", desc = "累计在线时长 3000 分钟",
        category = "playtime", targetMinutes = 3000,
        rewards = {
            { type = "zen",  value = 20000000 },
            { type = "item", itemId = 7181, count = 10 },
            { type = "buff", buffIndex = 6, effectType1 = 0, effectValue1 = 0,
              effectType2 = 0, effectValue2 = 0, duration = 1800 },
        },
    },

    -- ═══════════════════ 转生类 ═══════════════════

    {
        id = 1101, name = "轮回初启", desc = "完成第 1 次转生",
        category = "reset", targetCount = 1,
        rewards = {
            { type = "zen", value = 1000000 },
        },
    },
    {
        id = 1102, name = "浴火重生", desc = "累计转生 10 次",
        category = "reset", targetCount = 10,
        rewards = {
            { type = "zen",  value = 10000000 },
            { type = "item", itemId = 7181, count = 5 },
        },
    },
    {
        id = 1103, name = "永恒轮回", desc = "累计转生 50 次",
        category = "reset", targetCount = 50,
        rewards = {
            { type = "zen",  value = 50000000 },
            { type = "item", itemId = 7194, count = 10 },
            { type = "buff", buffIndex = 6, effectType1 = 0, effectValue1 = 0,
              effectType2 = 0, effectValue2 = 0, duration = 3600 },
        },
    },
}

------------------------------------------------------------------
-- 武器 / 防具 ItemType 列表（MU 物品分组 0-15）
------------------------------------------------------------------

AchievementSystem.WeaponTypes = { 0, 1, 2, 3, 4, 5, 6 }
AchievementSystem.ArmorTypes  = { 7, 8, 9, 10, 11 }

--- 常见宝石 ItemId 列表（用于 pickup_any 类别统计）
AchievementSystem.GemItemIds = { 7181, 7194, 7190, 6159, 7841, 7842, 7843 }

--- 分类显示名称
AchievementSystem.CategoryNames = {
    pickup        = "宝石拾取",
    pickup_any    = "全宝石收集",
    pickup_total  = "物品拾取",
    weapon        = "武器强化",
    armor         = "防具强化",
    excellent     = "卓越装备",
    set           = "套装收集",
    level         = "角色等级",
    master_level  = "大师等级",
    inventory     = "背包容量",
    kill_monster  = "怪物击杀",
    kill_player   = "PvP击杀",
    playtime      = "在线时长",
    reset         = "转生成就",
}

--- 分类显示顺序
AchievementSystem.CategoryOrder = {
    "pickup", "pickup_any", "pickup_total",
    "weapon", "armor", "excellent", "set",
    "level", "master_level", "inventory",
    "kill_monster", "kill_player", "playtime", "reset",
}

------------------------------------------------------------------
-- ID → 成就定义 快速查找索引
------------------------------------------------------------------

AchievementSystem._byId = {}

---构建 ID 查找索引（在 Definitions 加载后调用）
function AchievementSystem.BuildIndex()
    AchievementSystem._byId = {}
    for _, ach in ipairs(AchievementSystem.Definitions) do
        AchievementSystem._byId[ach.id] = ach
    end
end

---根据 ID 获取成就定义（O(1) 查找）
---@param achId integer
---@return table|nil
function AchievementSystem.GetById(achId)
    return AchievementSystem._byId[achId]
end

------------------------------------------------------------------
-- 内存数据存储
-- 格式: PlayerProgress[账号名] = {
--     pickup      = { [itemId] = count, ... },
--     pickup_total= total_count,
--     kill_monster= total_count,
--     kill_player = total_count,
--     resets      = total_count,
--     playtime    = total_minutes,    -- 累计在线分钟
--     completed   = { [achId] = true, ... },
--     rewards_claimed = { [achId] = true, ... },
--     lastUpdate  = timestamp,
--     lastLogin   = timestamp,        -- 上次登录时间（用于计算在线时长）
-- }
------------------------------------------------------------------

AchievementSystem.PlayerProgress = {}

------------------------------------------------------------------
-- JSON 持久化工具
------------------------------------------------------------------

---将 Lua 值编码为 JSON 字符串
---支持：nil, number, string, boolean, table（数组 + 对象）
---@param v any
---@return string
local function jsonEncode(v)
    if type(v) == "nil"     then return "null"
    elseif type(v) == "number" then
        -- 区分整数与浮点数，避免写入 1.0 等无效表示
        if math.floor(v) == v then
            return string.format("%d", v)
        end
        return tostring(v)
    elseif type(v) == "string" then
        return '"' .. v:gsub('\\', '\\\\')
                         :gsub('"', '\\"')
                         :gsub('\n', '\\n')
                         :gsub('\r', '\\r')
                         :gsub('\t', '\\t') .. '"'
    elseif type(v) == "boolean" then return v and "true" or "false"
    elseif type(v) == "table" then
        -- 判断是否为数组：正整数连续键 1..#v
        local isArray = true
        local maxIdx = 0
        for k in pairs(v) do
            if type(k) ~= "number" or k < 1 or math.floor(k) ~= k then
                isArray = false
                break
            end
            if k > maxIdx then maxIdx = k end
        end
        if isArray and maxIdx == #v then
            local parts = {}
            for i = 1, #v do
                parts[i] = jsonEncode(v[i])
            end
            return "[" .. table.concat(parts, ",") .. "]"
        else
            local parts = {}
            for kk, vv in pairs(v) do
                if type(kk) == "string" then
                    parts[#parts + 1] = '"' .. kk .. '":' .. jsonEncode(vv)
                elseif type(kk) == "number" then
                    -- 数字键转为字符串键存储（保持 JSON 合法性）
                    parts[#parts + 1] = '"' .. tostring(kk) .. '":' .. jsonEncode(vv)
                end
            end
            return "{" .. table.concat(parts, ",") .. "}"
        end
    else
        return "null"
    end
end

AchievementSystem.JsonEncode = jsonEncode

---将 JSON 字符串解码为 Lua 表
---@param jsonStr string
---@return table|nil, string|nil
local function jsonDecode(jsonStr)
    if not jsonStr or jsonStr == "" then
        return {}, nil
    end

    local pos = 1
    local len = #jsonStr

    local function skipWhitespace()
        while pos <= len do
            local c = jsonStr:sub(pos, pos)
            if c == " " or c == "\n" or c == "\r" or c == "\t" then
                pos = pos + 1
            else
                break
            end
        end
    end

    local function parseString()
        pos = pos + 1  -- skip opening "
        local result = {}
        while pos <= len do
            local c = jsonStr:sub(pos, pos)
            if c == '"' then
                pos = pos + 1
                return table.concat(result)
            elseif c == "\\" then
                pos = pos + 1
                local esc = jsonStr:sub(pos, pos)
                if     esc == "n"  then result[#result + 1] = "\n"
                elseif esc == "r"  then result[#result + 1] = "\r"
                elseif esc == "t"  then result[#result + 1] = "\t"
                elseif esc == "\\" then result[#result + 1] = "\\"
                elseif esc == '"'  then result[#result + 1] = '"'
                elseif esc == "/"  then result[#result + 1] = "/"
                elseif esc == "u" then
                    -- Unicode 转义：跳过 4 位十六进制
                    pos = pos + 4
                    result[#result + 1] = "?"
                else result[#result + 1] = esc end
                pos = pos + 1
            else
                result[#result + 1] = c
                pos = pos + 1
            end
        end
        return ""
    end

    local function parseNumber()
        local start = pos
        if jsonStr:sub(pos, pos) == "-" then pos = pos + 1 end
        while pos <= len do
            local c = jsonStr:sub(pos, pos)
            if c:match("[0-9%.eE%+%-]") then
                pos = pos + 1
            else
                break
            end
        end
        local numStr = jsonStr:sub(start, pos - 1)
        local n = tonumber(numStr)
        return n or 0
    end

    local function parseTrue()  pos = pos + 4; return true  end
    local function parseFalse() pos = pos + 5; return false end
    local function parseNull()  pos = pos + 4; return nil   end

    local function parseValue()
        skipWhitespace()
        if pos > len then return nil end
        local c = jsonStr:sub(pos, pos)
        if     c == '"' then return parseString()
        elseif c == "t" then return parseTrue()
        elseif c == "f" then return parseFalse()
        elseif c == "n" then return parseNull()
        elseif c == "[" then
            pos = pos + 1
            local arr = {}
            skipWhitespace()
            if jsonStr:sub(pos, pos) ~= "]" then
                while true do
                    arr[#arr + 1] = parseValue()
                    skipWhitespace()
                    if jsonStr:sub(pos, pos) == "]" then break end
                    if pos > len then break end
                    pos = pos + 1  -- skip ,
                end
            end
            pos = pos + 1
            return arr
        elseif c == "{" then
            pos = pos + 1
            local obj = {}
            skipWhitespace()
            if jsonStr:sub(pos, pos) ~= "}" then
                while true do
                    skipWhitespace()
                    local key = parseString()
                    skipWhitespace()
                    pos = pos + 1  -- skip :
                    local val = parseValue()
                    obj[key] = val
                    skipWhitespace()
                    if jsonStr:sub(pos, pos) == "}" then break end
                    if pos > len then break end
                    pos = pos + 1  -- skip ,
                end
            end
            pos = pos + 1
            return obj
        else
            return parseNumber()
        end
    end

    local ok, result = pcall(parseValue)
    if ok then return result else return {}, "JSON parse error" end
end

AchievementSystem.JsonDecode = jsonDecode

------------------------------------------------------------------
-- 文件持久化
------------------------------------------------------------------

---将玩家进度数据保存到 JSON 文件
---@return boolean
function AchievementSystem.SaveToFile()
    local data = {
        version    = AchievementSystem.DATA_VERSION,
        timestamp  = os.time(),
        players    = AchievementSystem.PlayerProgress,
    }
    local jsonStr = jsonEncode(data)

    local f, err = io.open(AchievementSystem.DataPath, "w")
    if not f then
        Log.Add("[成就系统] 保存失败: " .. tostring(err))
        return false
    end
    f:write(jsonStr)
    f:close()
    Log.Add("[成就系统] 数据已保存到: " .. AchievementSystem.DataPath)
    return true
end

---从 JSON 文件加载玩家进度数据
function AchievementSystem.LoadFromFile()
    local f, err = io.open(AchievementSystem.DataPath, "r")
    if not f then
        Log.Add("[成就系统] 无历史数据（首次启动），将创建新文件")
        AchievementSystem.PlayerProgress = {}
        return
    end
    local content = f:read("*all")
    f:close()
    if not content or content == "" then
        Log.Add("[成就系统] 数据文件为空，初始化为空数据")
        AchievementSystem.PlayerProgress = {}
        return
    end

    local data, parseErr = jsonDecode(content)
    if parseErr or type(data) ~= "table" then
        Log.Add("[成就系统] 数据解析失败: " .. tostring(parseErr) .. "，使用空数据")
        AchievementSystem.PlayerProgress = {}
        return
    end

    -- 数据迁移
    local version = data.version or 1
    data = AchievementSystem.MigrateData(data, version)

    if data.players and type(data.players) == "table" then
        AchievementSystem.PlayerProgress = data.players
        local count = 0
        for _ in pairs(AchievementSystem.PlayerProgress) do count = count + 1 end
        Log.Add(string.format("[成就系统] 已加载 %d 位玩家的成就数据（版本: %d）",
            count, AchievementSystem.DATA_VERSION))
    else
        AchievementSystem.PlayerProgress = {}
        Log.Add("[成就系统] 数据格式异常，初始化为空数据")
    end
end

---数据迁移：从旧版本格式升级到当前版本
---@param data table 已解析的数据
---@param oldVersion integer 旧版本号
---@return table 迁移后的数据
function AchievementSystem.MigrateData(data, oldVersion)
    if oldVersion < 2 then
        -- V1 → V2：为每个玩家添加新字段（kill_monster, kill_player, playtime, resets）
        if data.players and type(data.players) == "table" then
            for acct, pData in pairs(data.players) do
                pData.kill_monster = pData.kill_monster or 0
                pData.kill_player  = pData.kill_player or 0
                pData.playtime     = pData.playtime or 0
                pData.resets       = pData.resets or 0
                pData.lastLogin    = pData.lastLogin or 0
            end
        end
    end
    data.version = AchievementSystem.DATA_VERSION
    return data
end

------------------------------------------------------------------
-- 进度管理
------------------------------------------------------------------

---获取或初始化玩家的成就数据
---@param accountName string 账号名
---@return table 玩家成就数据
function AchievementSystem.GetPlayerData(accountName)
    if not accountName then return {} end
    if not AchievementSystem.PlayerProgress[accountName] then
        AchievementSystem.PlayerProgress[accountName] = {
            pickup         = {},        -- { [itemId] = 累计拾取数量 }
            pickup_total   = 0,         -- 总拾取次数
            kill_monster   = 0,         -- 击杀怪物总数
            kill_player    = 0,         -- 击杀玩家总数
            resets         = 0,         -- 转生总次数
            playtime       = 0,         -- 累计在线分钟数
            completed      = {},        -- { [achId] = true } 已完成成就
            rewards_claimed = {},       -- { [achId] = true } 已领取奖励
            lastUpdate     = os.time(),
            lastLogin      = os.time(), -- 上次登录（用于在线时长累计）
        }
    end
    return AchievementSystem.PlayerProgress[accountName]
end

---检查玩家是否已完成某个成就
---@param accountName string
---@param achId integer
---@return boolean
function AchievementSystem.IsCompleted(accountName, achId)
    local data = AchievementSystem.GetPlayerData(accountName)
    return data.completed[tostring(achId)] == true
end

---检查玩家是否已领取某成就奖励
---@param accountName string
---@param achId integer
---@return boolean
function AchievementSystem.IsRewardClaimed(accountName, achId)
    local data = AchievementSystem.GetPlayerData(accountName)
    return data.rewards_claimed[tostring(achId)] == true
end

------------------------------------------------------------------
-- 进度评估
------------------------------------------------------------------

---获取指定物品的累计拾取数量
---@param accountName string
---@param itemId integer
---@return integer
function AchievementSystem.GetPickupCount(accountName, itemId)
    local data = AchievementSystem.GetPlayerData(accountName)
    return data.pickup[tostring(itemId)] or 0
end

---获取背包中非空物品的数量
---@param oPlayer Object
---@return integer
function AchievementSystem.GetInventoryItemCount(oPlayer)
    local count = 0
    for slot = 12, Constants.MAIN_INVENTORY_SIZE + 11 do
        local item = oPlayer:GetInventoryItem(slot)
        if item and item.IsItemExist then
            count = count + 1
        end
    end
    return count
end

---获取装备 + 背包中满足条件的最高强化等级武器
---同时扫描装备槽(0-11)和背包槽(12+)
---@param oPlayer Object
---@param minLevel integer 最小强化等级
---@return integer count, integer maxLevel
function AchievementSystem.CountWeaponsByLevel(oPlayer, minLevel)
    local count = 0
    local maxLevel = 0
    -- 扫描装备槽 + 背包
    for slot = 0, Constants.MAIN_INVENTORY_SIZE + 11 do
        local item = oPlayer:GetInventoryItem(slot)
        if item and item.IsItemExist then
            local itemType = Helpers.GetItemType(item.Type)
            for _, wt in ipairs(AchievementSystem.WeaponTypes) do
                if itemType == wt and item.Level >= minLevel then
                    count = count + 1
                    if item.Level > maxLevel then
                        maxLevel = item.Level
                    end
                    break
                end
            end
        end
    end
    return count, maxLevel
end

---获取装备 + 背包中满足条件的最高强化等级防具
---@param oPlayer Object
---@param minLevel integer 最小强化等级
---@return integer count, integer maxLevel
function AchievementSystem.CountArmorsByLevel(oPlayer, minLevel)
    local count = 0
    local maxLevel = 0
    for slot = 0, Constants.MAIN_INVENTORY_SIZE + 11 do
        local item = oPlayer:GetInventoryItem(slot)
        if item and item.IsItemExist then
            local itemType = Helpers.GetItemType(item.Type)
            for _, at in ipairs(AchievementSystem.ArmorTypes) do
                if itemType == at and item.Level >= minLevel then
                    count = count + 1
                    if item.Level > maxLevel then
                        maxLevel = item.Level
                    end
                    break
                end
            end
        end
    end
    return count, maxLevel
end

---获取装备 + 背包中卓越物品的数量
---@param oPlayer Object
---@return integer
function AchievementSystem.CountExcellentItems(oPlayer)
    local count = 0
    for slot = 0, Constants.MAIN_INVENTORY_SIZE + 11 do
        local item = oPlayer:GetInventoryItem(slot)
        if item and item.IsItemExist and item.NewOption ~= 0 then
            count = count + 1
        end
    end
    return count
end

---获取装备 + 背包中套装物品的数量
---@param oPlayer Object
---@return integer
function AchievementSystem.CountSetItems(oPlayer)
    local count = 0
    for slot = 0, Constants.MAIN_INVENTORY_SIZE + 11 do
        local item = oPlayer:GetInventoryItem(slot)
        if item and item.IsItemExist and item.SetOption ~= 0 then
            count = count + 1
        end
    end
    return count
end

---评估单个成就的进度（基于实时数据和持久化数据）
---@param ach table 成就定义
---@param oPlayer Object 玩家对象
---@param accountName string 账号名
---@return integer current, integer target, boolean completed
function AchievementSystem.Evaluate(ach, oPlayer, accountName)
    local current = 0
    local target = 0
    local completed = false

    if ach.category == "pickup" then
        target = ach.targetCount
        current = AchievementSystem.GetPickupCount(accountName, ach.itemId)
        completed = current >= target

    elseif ach.category == "pickup_any" then
        local total = 0
        for _, gid in ipairs(AchievementSystem.GemItemIds) do
            total = total + AchievementSystem.GetPickupCount(accountName, gid)
        end
        target = ach.targetCount
        current = total
        completed = current >= target

    elseif ach.category == "pickup_total" then
        target = ach.targetCount
        local data = AchievementSystem.GetPlayerData(accountName)
        current = data.pickup_total or 0
        completed = current >= target

    elseif ach.category == "weapon" then
        target = ach.minLevel
        local _, maxLevel = AchievementSystem.CountWeaponsByLevel(oPlayer, 0)
        current = maxLevel
        completed = current >= target

    elseif ach.category == "armor" then
        target = ach.minLevel
        local _, maxLevel = AchievementSystem.CountArmorsByLevel(oPlayer, 0)
        current = maxLevel
        completed = current >= target

    elseif ach.category == "excellent" then
        target = ach.minCount
        current = AchievementSystem.CountExcellentItems(oPlayer)
        completed = current >= target

    elseif ach.category == "set" then
        target = ach.minCount
        current = AchievementSystem.CountSetItems(oPlayer)
        completed = current >= target

    elseif ach.category == "level" then
        target = ach.targetLevel
        current = oPlayer.Level
        completed = current >= target

    elseif ach.category == "master_level" then
        target = ach.targetMasterLevel
        current = (oPlayer.userData and oPlayer.userData.MasterLevel) or 0
        completed = current >= target

    elseif ach.category == "inventory" then
        target = ach.targetCount
        current = AchievementSystem.GetInventoryItemCount(oPlayer)
        completed = current >= target

    elseif ach.category == "kill_monster" then
        target = ach.targetCount
        local data = AchievementSystem.GetPlayerData(accountName)
        current = data.kill_monster or 0
        completed = current >= target

    elseif ach.category == "kill_player" then
        target = ach.targetCount
        local data = AchievementSystem.GetPlayerData(accountName)
        current = data.kill_player or 0
        completed = current >= target

    elseif ach.category == "playtime" then
        target = ach.targetMinutes
        local data = AchievementSystem.GetPlayerData(accountName)
        current = data.playtime or 0
        completed = current >= target

    elseif ach.category == "reset" then
        target = ach.targetCount
        local data = AchievementSystem.GetPlayerData(accountName)
        current = data.resets or 0
        completed = current >= target
    end

    return current, target, completed
end

------------------------------------------------------------------
-- 奖励发放
------------------------------------------------------------------

---给玩家发放成就奖励
---@param oPlayer Object 玩家对象
---@param rewards table 奖励列表
---@param achName string 成就名称（用于日志）
function AchievementSystem.GrantRewards(oPlayer, rewards, achName)
    if not rewards then return end

    for _, reward in ipairs(rewards) do
        if reward.type == "zen" then
            Player.SetMoney(oPlayer.Index, reward.value, false)
            Message.Send(0, oPlayer.Index, 1,
                string.format("  → 金币 +%s", AchievementSystem.FormatMoney(reward.value)))

        elseif reward.type == "item" then
            local itemInfo = CreateItemInfo.new()
            itemInfo.ItemId        = reward.itemId
            itemInfo.ItemLevel     = reward.itemLevel or 0
            itemInfo.Durability    = reward.count or 1
            itemInfo.LootIndex     = oPlayer.Index
            itemInfo.TargetInvenPos = 255  -- 自动查找栏位
            Item.Create(oPlayer.Index, itemInfo)
            local itemAttr = Item.GetAttr(reward.itemId)
            local name = itemAttr and itemAttr:GetName() or tostring(reward.itemId)
            Message.Send(0, oPlayer.Index, 1,
                string.format("  → 物品 x%d：%s", reward.count or 1, name))

        elseif reward.type == "buff" then
            -- 使用 Buff.Add 以支持持续时间的限时 Buff
            -- 如果 duration <= 0 则使用 Buff.AddItem（永久型 Buff）
            local duration = reward.duration or 0
            if duration > 0 then
                Buff.Add(oPlayer,
                    reward.buffIndex,
                    reward.effectType1  or 0, reward.effectValue1 or 0,
                    reward.effectType2  or 0, reward.effectValue2 or 0,
                    duration,
                    0,   -- BuffSendValue
                    -1)  -- nAttackerIndex（无攻击者）
                Message.Send(0, oPlayer.Index, 1,
                    string.format("  → BUFF（持续 %d 秒）", duration))
            else
                Buff.AddItem(oPlayer, reward.buffIndex)
                Message.Send(0, oPlayer.Index, 1, "  → BUFF（永久）")
            end
        end
    end

    Log.Add(string.format("[成就系统] %s 领取成就「%s」奖励", oPlayer.Name, achName))
end

---格式化金币显示
---@param money integer
---@return string
function AchievementSystem.FormatMoney(money)
    if money >= 100000000 then
        return string.format("%.1f亿", money / 100000000)
    elseif money >= 10000 then
        return string.format("%.1f万", money / 10000)
    else
        return tostring(money)
    end
end

------------------------------------------------------------------
-- 成就完成检查与通知
------------------------------------------------------------------

---当玩家拾取物品时更新进度并检查成就
---@param oPlayer Object
---@param sItemType integer C++ 传入的物品 Type（即物品组号 0-15）
---@param sItemLevel integer 物品等级
function AchievementSystem.CheckAchievementsOnPickup(oPlayer, sItemType, sItemLevel)
    if not oPlayer or not oPlayer.AccountId then return end
    local accountName = oPlayer.AccountId
    local playerData = AchievementSystem.GetPlayerData(accountName)

    -- 更新总拾取次数
    playerData.pickup_total = (playerData.pickup_total or 0) + 1

    -- 判断是否为宝石类物品并累计
    -- 注意：C++ onItemGet 传入的 sItemType 是物品 Type（0-15 的组号），
    -- 不是完整的 ItemId。这里使用 Helpers.MakeItemId 计算完整 ItemId，
    -- 但同组不同物品的 Index 不同。由于回调只提供 Type+Level，
    -- 无法精确还原 ItemIndex，因此我们对宝石类特殊处理：
    -- 已知宝石的 Type=14，通过 sItemLevel 无法区分具体宝石，
    -- 因此改为按 Type 记录，在定义中也使用 Type 匹配。
    --
    -- 但如果其他系统（如 onEventItemGet）传入的是完整 ItemId，
    -- 我们需要兼容两种情况。判断逻辑：
    --   sItemType >= 512 → 是完整 ItemId
    --   sItemType < 16   → 是物品组号（ItemType）
    local itemId = sItemType
    if sItemType < 16 then
        -- C++ 传入的是组号，构造完整 ItemId（Index=0 为该组第一个物品）
        -- 对宝石来说不精确，但用于粗略统计
        itemId = Helpers.MakeItemId(sItemType, 0)
    end

    -- 宝石类物品累计（通过 ItemAttr.ItemKindA 判断）
    local itemAttr = Item.GetAttr(itemId)
    if itemAttr then
        local kindA = itemAttr.ItemKindA
        -- ItemKindA: 9 = JEWEL, 56 = COMMON_JEWEL, 57 = 稀有宝石
        if kindA == 9 or kindA == 56 or kindA == 57 then
            playerData.pickup[tostring(itemId)] =
                (playerData.pickup[tostring(itemId)] or 0) + 1
        end
    end

    playerData.lastUpdate = os.time()

    -- 检查相关成就
    for _, ach in ipairs(AchievementSystem.Definitions) do
        if not AchievementSystem.IsCompleted(accountName, ach.id) then
            local relevant = false
            if ach.category == "pickup" then
                relevant = true  -- 无法精确判断，统一检查
            elseif ach.category == "pickup_any" then
                relevant = true
            elseif ach.category == "pickup_total" then
                relevant = true
            end

            if relevant then
                local current, target, completed =
                    AchievementSystem.Evaluate(ach, oPlayer, accountName)

                if completed then
                    AchievementSystem.OnAchievementComplete(oPlayer, ach, current)
                end
            end
        end
    end

    -- 防抖保存
    AchievementSystem.DebouncedSave(accountName)
end

---当玩家击杀怪物时更新进度并检查成就
---@param oPlayer Object
function AchievementSystem.CheckAchievementsOnMonsterKill(oPlayer)
    if not oPlayer or not oPlayer.AccountId then return end
    local accountName = oPlayer.AccountId
    local playerData = AchievementSystem.GetPlayerData(accountName)

    playerData.kill_monster = (playerData.kill_monster or 0) + 1
    playerData.lastUpdate = os.time()

    -- 检查击杀相关成就
    for _, ach in ipairs(AchievementSystem.Definitions) do
        if ach.category == "kill_monster" and not AchievementSystem.IsCompleted(accountName, ach.id) then
            local current, target, completed =
                AchievementSystem.Evaluate(ach, oPlayer, accountName)
            if completed then
                AchievementSystem.OnAchievementComplete(oPlayer, ach, current)
            end
        end
    end

    AchievementSystem.DebouncedSave(accountName)
end

---当玩家击杀另一名玩家时更新进度并检查成就
---@param oPlayer Object
function AchievementSystem.CheckAchievementsOnPlayerKill(oPlayer)
    if not oPlayer or not oPlayer.AccountId then return end
    local accountName = oPlayer.AccountId
    local playerData = AchievementSystem.GetPlayerData(accountName)

    playerData.kill_player = (playerData.kill_player or 0) + 1
    playerData.lastUpdate = os.time()

    for _, ach in ipairs(AchievementSystem.Definitions) do
        if ach.category == "kill_player" and not AchievementSystem.IsCompleted(accountName, ach.id) then
            local current, target, completed =
                AchievementSystem.Evaluate(ach, oPlayer, accountName)
            if completed then
                AchievementSystem.OnAchievementComplete(oPlayer, ach, current)
            end
        end
    end

    AchievementSystem.DebouncedSave(accountName)
end

---当玩家升级时检查等级相关成就
---@param oPlayer Object
function AchievementSystem.CheckAchievementsOnLevelUp(oPlayer)
    if not oPlayer or not oPlayer.AccountId then return end
    local accountName = oPlayer.AccountId

    for _, ach in ipairs(AchievementSystem.Definitions) do
        if ach.category == "level" and not AchievementSystem.IsCompleted(accountName, ach.id) then
            local current, target, completed =
                AchievementSystem.Evaluate(ach, oPlayer, accountName)
            if completed then
                AchievementSystem.OnAchievementComplete(oPlayer, ach, current)
            end
        end
    end
end

---当玩家大师升级时检查大师等级相关成就
---@param oPlayer Object
function AchievementSystem.CheckAchievementsOnMasterLevelUp(oPlayer)
    if not oPlayer or not oPlayer.AccountId then return end
    local accountName = oPlayer.AccountId

    for _, ach in ipairs(AchievementSystem.Definitions) do
        if ach.category == "master_level" and not AchievementSystem.IsCompleted(accountName, ach.id) then
            local current, target, completed =
                AchievementSystem.Evaluate(ach, oPlayer, accountName)
            if completed then
                AchievementSystem.OnAchievementComplete(oPlayer, ach, current)
            end
        end
    end
end

---当玩家转生时更新进度并检查成就
---@param oPlayer Object
function AchievementSystem.CheckAchievementsOnReset(oPlayer)
    if not oPlayer or not oPlayer.AccountId then return end
    local accountName = oPlayer.AccountId
    local playerData = AchievementSystem.GetPlayerData(accountName)

    playerData.resets = (playerData.resets or 0) + 1
    playerData.lastUpdate = os.time()

    for _, ach in ipairs(AchievementSystem.Definitions) do
        if ach.category == "reset" and not AchievementSystem.IsCompleted(accountName, ach.id) then
            local current, target, completed =
                AchievementSystem.Evaluate(ach, oPlayer, accountName)
            if completed then
                AchievementSystem.OnAchievementComplete(oPlayer, ach, current)
            end
        end
    end

    AchievementSystem.DebouncedSave(accountName)
end

---定期检查所有成就（玩家登录或定时触发）
---@param oPlayer Object
function AchievementSystem.CheckAllAchievements(oPlayer)
    if not oPlayer or not oPlayer.AccountId then return end
    local accountName = oPlayer.AccountId

    for _, ach in ipairs(AchievementSystem.Definitions) do
        if not AchievementSystem.IsCompleted(accountName, ach.id) then
            local current, target, completed =
                AchievementSystem.Evaluate(ach, oPlayer, accountName)
            if completed then
                AchievementSystem.OnAchievementComplete(oPlayer, ach, current)
            end
        end
    end
end

---防抖保存：避免频繁写入文件
---@param accountName string
function AchievementSystem.DebouncedSave(accountName)
    local timerName = "ach_save_" .. accountName
    Timer.RemoveByName(timerName)
    Timer.Create(AchievementSystem.SAVE_DEBOUNCE_MS, timerName, function()
        AchievementSystem.SaveToFile()
    end)
end

------------------------------------------------------------------
-- 成就完成处理
------------------------------------------------------------------

---成就完成时的处理
---@param oPlayer Object
---@param ach table 成就定义
---@param finalValue integer 最终进度值
function AchievementSystem.OnAchievementComplete(oPlayer, ach, finalValue)
    if not oPlayer or not oPlayer.AccountId then return end
    -- 双重检查：防止并发导致重复触发
    if AchievementSystem.IsCompleted(oPlayer.AccountId, ach.id) then return end

    local accountName = oPlayer.AccountId
    local playerData = AchievementSystem.GetPlayerData(accountName)

    -- 标记完成
    playerData.completed[tostring(ach.id)] = true
    playerData.lastUpdate = os.time()

    -- 玩家通知
    Message.Send(0, oPlayer.Index, 2,
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    Message.Send(0, oPlayer.Index, 2,
        "  ★ 成就完成 ★")
    Message.Send(0, oPlayer.Index, 1,
        string.format("  「%s」", ach.name))
    Message.Send(0, oPlayer.Index, 0,
        string.format("  %s", ach.desc))
    Message.Send(0, oPlayer.Index, 2,
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    -- 全服广播（高稀有度成就：id >= 900 或 >= 1100）
    if ach.id >= 900 then
        Message.Send(0, -1, 2,
            string.format("【成就】玩家 %s 完成了「%s」！", oPlayer.Name, ach.name))
    end

    Log.Add(string.format("[成就系统] %s 完成成就 #%d「%s」",
        oPlayer.Name, ach.id, ach.name))

    -- 延迟发放奖励（避免在回调栈中执行太多操作）
    if ach.rewards and #ach.rewards > 0 then
        local rewardTimerName = "ach_reward_" .. ach.id .. "_" .. oPlayer.Index
        Timer.Create(500, rewardTimerName, function()
            -- 再次验证玩家在线
            local oCheck = Player.GetObjByIndex(oPlayer.Index)
            if oCheck then
                Message.Send(0, oPlayer.Index, 1, "  奖励内容：")
                AchievementSystem.GrantRewards(oPlayer, ach.rewards, ach.name)
                playerData.rewards_claimed[tostring(ach.id)] = true
            end
        end)
    end

    -- 立即保存
    AchievementSystem.SaveToFile()
end

------------------------------------------------------------------
-- 在线时长追踪
------------------------------------------------------------------

---玩家登录时记录登录时间
---@param oPlayer Object
function AchievementSystem.OnPlayerLogin(oPlayer)
    if not oPlayer or not oPlayer.AccountId then return end
    local accountName = oPlayer.AccountId
    local playerData = AchievementSystem.GetPlayerData(accountName)

    -- 累加上次离开以来的时间（安全兜底，主要靠定时器）
    playerData.lastLogin = os.time()
    playerData.lastUpdate = os.time()
end

---玩家断开时累计在线时长
---@param oPlayer Object
function AchievementSystem.OnPlayerDisconnect(oPlayer)
    if not oPlayer or not oPlayer.AccountId then return end
    local accountName = oPlayer.AccountId
    local playerData = AchievementSystem.GetPlayerData(accountName)

    -- 累加在线时长（分钟）
    if playerData.lastLogin and playerData.lastLogin > 0 then
        local minutes = math.floor((os.time() - playerData.lastLogin) / 60)
        if minutes > 0 then
            playerData.playtime = (playerData.playtime or 0) + minutes
        end
    end
    playerData.lastLogin = 0

    -- 检查在线时长成就
    for _, ach in ipairs(AchievementSystem.Definitions) do
        if ach.category == "playtime" and not AchievementSystem.IsCompleted(accountName, ach.id) then
            local current, target, completed =
                AchievementSystem.Evaluate(ach, oPlayer, accountName)
            if completed then
                AchievementSystem.OnAchievementComplete(oPlayer, ach, current)
            end
        end
    end
end

---每分钟定时累加所有在线玩家的在线时长
function AchievementSystem.TickPlaytime()
    Object.ForEachPlayer(function(oPlayer)
        if oPlayer and oPlayer.AccountId and oPlayer.Connected == Enums.PlayerState.PLAYING then
            local playerData = AchievementSystem.GetPlayerData(oPlayer.AccountId)
            playerData.playtime = (playerData.playtime or 0) + 1
        end
        return true
    end)
end

------------------------------------------------------------------
-- 自动保存定时器
------------------------------------------------------------------

---启动自动保存定时器
function AchievementSystem.StartAutoSave()
    Timer.RemoveByName("ach_autosave")
    Timer.CreateRepeating(
        AchievementSystem.AUTO_SAVE_INTERVAL * 1000,
        "ach_autosave",
        function()
            AchievementSystem.SaveToFile()
        end
    )
    Log.Add(string.format("[成就系统] 自动保存已启动（间隔 %d 秒）",
        AchievementSystem.AUTO_SAVE_INTERVAL))
end

------------------------------------------------------------------
-- 回调注册（分派模式）
------------------------------------------------------------------

---将成就系统的回调注册到 Callbacks.lua 的分派表中
---Callbacks.lua 应该维护类似以下的分发表：
---   AchievementSystem.Callbacks = {
---       onItemGet = { handler1, handler2, ... },
---       onPlayerLogin = { ... },
---       ...
---   }
---然后在全局 onItemGet 中遍历调用
function AchievementSystem.RegisterCallbacks()
    -- 确保 Callbacks 分发表存在
    AchievementSystem.Callbacks = AchievementSystem.Callbacks or {
        onItemGet         = {},
        onEventItemGet    = {},
        onMuunItemGet     = {},
        onPlayerLogin     = {},
        onPlayerDisconnect= {},
        onPlayerLevelUp   = {},
        onPlayerMasterLevelUp = {},
        onPlayerReset     = {},
        onMonsterKill     = {},
        onPlayerKill      = {},
        onGameServerStart = {},
        onDisconnectAllPlayers = {},
        onLogOutAllPlayers     = {},
    }

    -- 注册拾取回调
    table.insert(AchievementSystem.Callbacks.onItemGet, function(oPlayer, sItemType, sItemLevel, btItemDur, btItemElement)
        AchievementSystem.CheckAchievementsOnPickup(oPlayer, sItemType, sItemLevel)
    end)
    table.insert(AchievementSystem.Callbacks.onEventItemGet, function(oPlayer, sItemType, sItemLevel, btItemDur, btItemElement)
        AchievementSystem.CheckAchievementsOnPickup(oPlayer, sItemType, sItemLevel)
    end)
    table.insert(AchievementSystem.Callbacks.onMuunItemGet, function(oPlayer, sItemType, sItemLevel, btItemDur, btItemElement)
        AchievementSystem.CheckAchievementsOnPickup(oPlayer, sItemType, sItemLevel)
    end)

    -- 注册登录/断开回调
    table.insert(AchievementSystem.Callbacks.onPlayerLogin, function(oPlayer)
        AchievementSystem.OnPlayerLogin(oPlayer)
        AchievementSystem.CheckAllAchievements(oPlayer)
    end)
    table.insert(AchievementSystem.Callbacks.onPlayerDisconnect, function(oPlayer)
        AchievementSystem.OnPlayerDisconnect(oPlayer)
    end)

    -- 注册成长回调
    table.insert(AchievementSystem.Callbacks.onPlayerLevelUp, function(oPlayer)
        AchievementSystem.CheckAchievementsOnLevelUp(oPlayer)
    end)
    table.insert(AchievementSystem.Callbacks.onPlayerMasterLevelUp, function(oPlayer)
        AchievementSystem.CheckAchievementsOnMasterLevelUp(oPlayer)
    end)
    table.insert(AchievementSystem.Callbacks.onPlayerReset, function(oPlayer)
        AchievementSystem.CheckAchievementsOnReset(oPlayer)
    end)

    -- 注册战斗回调
    table.insert(AchievementSystem.Callbacks.onMonsterKill, function(oPlayer, oTarget)
        AchievementSystem.CheckAchievementsOnMonsterKill(oPlayer)
    end)
    table.insert(AchievementSystem.Callbacks.onPlayerKill, function(oPlayer, oTarget)
        AchievementSystem.CheckAchievementsOnPlayerKill(oPlayer)
    end)

    -- 注册服务器生命周期回调
    table.insert(AchievementSystem.Callbacks.onGameServerStart, function()
        AchievementSystem.LoadFromFile()
        AchievementSystem.StartAutoSave()
        Log.Add("[成就系统] 服务器启动，数据加载完成")
    end)
    table.insert(AchievementSystem.Callbacks.onDisconnectAllPlayers, function()
        AchievementSystem.SaveToFile()
    end)
    table.insert(AchievementSystem.Callbacks.onLogOutAllPlayers, function()
        AchievementSystem.SaveToFile()
    end)

    Log.Add("[成就系统] 回调已注册到分派表")
end

---兼容模式：直接覆盖全局回调函数（当 Callbacks.lua 未使用分派表时）
---注意：这种方式会覆盖其他系统的同名回调，仅在无法修改 Callbacks.lua 时使用
function AchievementSystem.InstallGlobalHooks()
    -- 拾取事件
    function onItemGet(oPlayer, sItemType, sItemLevel, btItemDur, btItemElement)
        if oPlayer == nil then return end
        AchievementSystem.CheckAchievementsOnPickup(oPlayer, sItemType, sItemLevel)
    end

    function onEventItemGet(oPlayer, sItemType, sItemLevel, btItemDur, btItemElement)
        if oPlayer == nil then return end
        AchievementSystem.CheckAchievementsOnPickup(oPlayer, sItemType, sItemLevel)
    end

    function onMuunItemGet(oPlayer, sItemType, sItemLevel, btItemDur, btItemElement)
        if oPlayer == nil then return end
        AchievementSystem.CheckAchievementsOnPickup(oPlayer, sItemType, sItemLevel)
    end

    -- 登录/断开
    function onPlayerLogin(oPlayer)
        if oPlayer == nil then return end
        AchievementSystem.OnPlayerLogin(oPlayer)
        AchievementSystem.CheckAllAchievements(oPlayer)
    end

    function onPlayerDisconnect(oPlayer)
        if oPlayer == nil then return end
        AchievementSystem.OnPlayerDisconnect(oPlayer)
    end

    -- 成长事件
    function onPlayerLevelUp(oPlayer)
        if oPlayer == nil then return end
        AchievementSystem.CheckAchievementsOnLevelUp(oPlayer)
    end

    function onPlayerMasterLevelUp(oPlayer)
        if oPlayer == nil then return end
        AchievementSystem.CheckAchievementsOnMasterLevelUp(oPlayer)
    end

    function onPlayerReset(oPlayer)
        if oPlayer == nil then return end
        AchievementSystem.CheckAchievementsOnReset(oPlayer)
    end

    -- 战斗事件
    function onMonsterKill(oPlayer, oTarget)
        if oPlayer == nil then return end
        AchievementSystem.CheckAchievementsOnMonsterKill(oPlayer)
    end

    function onPlayerKill(oPlayer, oTarget)
        if oPlayer == nil then return end
        AchievementSystem.CheckAchievementsOnPlayerKill(oPlayer)
    end

    -- 服务器生命周期
    function onGameServerStart()
        AchievementSystem.LoadFromFile()
        AchievementSystem.StartAutoSave()
        Log.Add("[成就系统] 服务器启动，数据加载完成")
    end

    function onDisconnectAllPlayers()
        AchievementSystem.SaveToFile()
    end

    function onLogOutAllPlayers()
        AchievementSystem.SaveToFile()
    end

    Log.Add("[成就系统] 全局回调钩子已安装（兼容模式）")
end

------------------------------------------------------------------
-- 显示成就列表（分页，按分类排序）
------------------------------------------------------------------

function AchievementSystem.Show(oPlayer, page)
    if not oPlayer then return end

    local lines = {}
    lines[#lines + 1] = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    lines[#lines + 1] = "  【成就系统】  编号  名称"
    lines[#lines + 1] = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local perPage = AchievementSystem.PER_PAGE
    local total = #AchievementSystem.Definitions
    local totalPages = math.ceil(total / perPage)
    if page < 1 then page = 1 end
    if page > totalPages then page = totalPages end

    local startIdx = (page - 1) * perPage + 1
    local endIdx = math.min(page * perPage, total)

    -- 统计已完成数
    local completedCount = 0
    for _, ach in ipairs(AchievementSystem.Definitions) do
        if AchievementSystem.IsCompleted(oPlayer.AccountId, ach.id) then
            completedCount = completedCount + 1
        end
    end

    for i = startIdx, endIdx do
        local ach = AchievementSystem.Definitions[i]
        local isCompleted = AchievementSystem.IsCompleted(oPlayer.AccountId, ach.id)
        local isClaimed   = AchievementSystem.IsRewardClaimed(oPlayer.AccountId, ach.id)
        local current, target, _ = AchievementSystem.Evaluate(ach, oPlayer, oPlayer.AccountId)

        local status = isCompleted and "√" or "○"
        local prog = ""

        if ach.category == "level" or ach.category == "master_level" then
            prog = string.format("[%d/%d]", current, target)
        elseif ach.category == "weapon" or ach.category == "armor" then
            if current > 0 then
                prog = string.format("[+最大%d]", current)
            else
                prog = "[未达成]"
            end
        elseif ach.category == "playtime" then
            prog = string.format("[%d/%d分钟]", current, target)
        else
            prog = string.format("[%d/%d]", current, target)
        end

        local rewardHint = ""
        if isCompleted and not isClaimed then
            rewardHint = " ★待领"
        end

        lines[#lines + 1] = string.format("%s [%03d] %s %s%s",
            status, ach.id, ach.name, prog, rewardHint)
    end

    lines[#lines + 1] = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    lines[#lines + 1] = string.format("第 %d/%d 页  已完成: %d/%d",
        page, totalPages, completedCount, total)
    lines[#lines + 1] = "使用 /成就 编号 查看详情"
    lines[#lines + 1] = "使用 /成就 页码 翻页"

    for _, line in ipairs(lines) do
        Message.Send(0, oPlayer.Index, 1, line)
    end
end

------------------------------------------------------------------
-- 显示单个成就详情
------------------------------------------------------------------

function AchievementSystem.ShowDetail(oPlayer, achId)
    if not oPlayer then return end

    local ach = AchievementSystem.GetById(achId)
    if not ach then
        Message.Send(0, oPlayer.Index, 3, "【成就】无效的成就编号: " .. tostring(achId))
        Message.Send(0, oPlayer.Index, 0, "使用 /成就 查看成就列表")
        return
    end

    local isCompleted = AchievementSystem.IsCompleted(oPlayer.AccountId, ach.id)
    local isClaimed   = AchievementSystem.IsRewardClaimed(oPlayer.AccountId, ach.id)
    local current, target, _ = AchievementSystem.Evaluate(ach, oPlayer, oPlayer.AccountId)

    local statusText = isCompleted and "§a已完成§r" or "§e进行中§r"
    local percent = 0
    if target > 0 then
        percent = math.min(math.floor(current / target * 100), 100)
    end

    Message.Send(0, oPlayer.Index, 1, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    Message.Send(0, oPlayer.Index, 1,
        string.format("  【成就 #%03d】%s", ach.id, ach.name))
    Message.Send(0, oPlayer.Index, 1, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    Message.Send(0, oPlayer.Index, 1, "描述: " .. ach.desc)
    Message.Send(0, oPlayer.Index, 1,
        "分类: " .. (AchievementSystem.CategoryNames[ach.category] or ach.category))
    Message.Send(0, oPlayer.Index, 1, "状态: " .. statusText)

    -- 进度显示
    if ach.category == "level" or ach.category == "master_level" then
        Message.Send(0, oPlayer.Index, 1,
            string.format("进度: [%d/%d]  完成率: %d%%", current, target, percent))
    elseif ach.category == "weapon" or ach.category == "armor" then
        if current > 0 then
            Message.Send(0, oPlayer.Index, 1,
                string.format("当前: 最高强化等级 +%d", current))
        else
            Message.Send(0, oPlayer.Index, 1, "尚未达成条件")
        end
    elseif ach.category == "playtime" then
        Message.Send(0, oPlayer.Index, 1,
            string.format("进度: [%d/%d分钟]  完成率: %d%%", current, target, percent))
    else
        Message.Send(0, oPlayer.Index, 1,
            string.format("进度: [%d/%d]  完成率: %d%%", current, target, percent))
    end

    -- 奖励展示
    if ach.rewards and #ach.rewards > 0 then
        Message.Send(0, oPlayer.Index, 1, "奖励:")
        for _, r in ipairs(ach.rewards) do
            if r.type == "zen" then
                Message.Send(0, oPlayer.Index, 1,
                    "  ◆ 金币 " .. AchievementSystem.FormatMoney(r.value))
            elseif r.type == "item" then
                local ia = Item.GetAttr(r.itemId)
                local nm = ia and ia:GetName() or tostring(r.itemId)
                Message.Send(0, oPlayer.Index, 1,
                    string.format("  ◆ %s x%d", nm, r.count or 1))
            elseif r.type == "buff" then
                local durText = (r.duration and r.duration > 0)
                    and string.format("（持续 %d 秒）", r.duration)
                    or "（永久）"
                Message.Send(0, oPlayer.Index, 1,
                    "  ◆ BUFF" .. durText)
            end
        end
    end

    -- 状态提示
    if isCompleted then
        if not isClaimed then
            Message.Send(0, oPlayer.Index, 2, "奖励已自动发放！")
        else
            Message.Send(0, oPlayer.Index, 2, "奖励已领取！")
        end
    else
        -- 剩余提示
        if ach.category == "pickup" then
            local ia = Item.GetAttr(ach.itemId)
            local nm = ia and ia:GetName() or tostring(ach.itemId)
            Message.Send(0, oPlayer.Index, 1,
                string.format("提示: 还需 %d 个「%s」", target - current, nm))
        elseif ach.category == "level" then
            Message.Send(0, oPlayer.Index, 1,
                string.format("提示: 还需 %d 级", target - current))
        elseif ach.category == "master_level" then
            Message.Send(0, oPlayer.Index, 1,
                string.format("提示: 还需 %d 大师等级", target - current))
        elseif ach.category == "inventory" then
            Message.Send(0, oPlayer.Index, 1,
                string.format("提示: 背包还需 %d 件物品", target - current))
        elseif ach.category == "kill_monster" then
            Message.Send(0, oPlayer.Index, 1,
                string.format("提示: 还需击杀 %d 只怪物", target - current))
        elseif ach.category == "kill_player" then
            Message.Send(0, oPlayer.Index, 1,
                string.format("提示: 还需击杀 %d 名玩家", target - current))
        elseif ach.category == "playtime" then
            Message.Send(0, oPlayer.Index, 1,
                string.format("提示: 还需在线 %d 分钟", target - current))
        elseif ach.category == "reset" then
            Message.Send(0, oPlayer.Index, 1,
                string.format("提示: 还需 %d 次转生", target - current))
        end
    end

    Message.Send(0, oPlayer.Index, 1, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
end

------------------------------------------------------------------
-- 管理员命令
-- 用法: /achadmin 玩家名
------------------------------------------------------------------

function AchievementSystem.AdminShow(targetName)
    local oTarget = Player.GetObjByName(targetName)
    if not oTarget then
        Log.Add("[成就系统] 管理员查询：未找到玩家 " .. targetName)
        return
    end

    local accountName = oTarget.AccountId
    local playerData = AchievementSystem.GetPlayerData(accountName)

    Log.Add("========== 成就系统管理报告 ==========")
    Log.Add(string.format("玩家: %s（账号: %s）", oTarget.Name, accountName))
    Log.Add(string.format("累计拾取总次数: %d", playerData.pickup_total or 0))
    Log.Add(string.format("击杀怪物: %d", playerData.kill_monster or 0))
    Log.Add(string.format("击杀玩家: %d", playerData.kill_player or 0))
    Log.Add(string.format("转生次数: %d", playerData.resets or 0))
    Log.Add(string.format("在线时长: %d 分钟", playerData.playtime or 0))

    Log.Add("各宝石累计拾取：")
    for itemIdStr, cnt in pairs(playerData.pickup or {}) do
        local itemId = tonumber(itemIdStr)
        if itemId then
            local ia = Item.GetAttr(itemId)
            local nm = ia and ia:GetName() or tostring(itemId)
            Log.Add(string.format("  %s (ID:%d): %d", nm, itemId, cnt))
        end
    end

    Log.Add("已完成成就：")
    local completedCount = 0
    for achIdStr, _ in pairs(playerData.completed or {}) do
        local achId = tonumber(achIdStr)
        local ach = AchievementSystem.GetById(achId)
        Log.Add(string.format("  #%03d %s", achId, ach and ach.name or "?"))
        completedCount = completedCount + 1
    end
    Log.Add(string.format("总计: %d/%d", completedCount, #AchievementSystem.Definitions))
    Log.Add("========================================")
end

------------------------------------------------------------------
-- 命令处理
------------------------------------------------------------------

---处理 /成就 命令
---由 Callbacks.lua 的 onUseCommand 分派调用
---@param oPlayer Object
---@param parts table 命令分割后的数组
---@return integer 1=阻止命令传播, 0=继续传播
function AchievementSystem.HandleCommand(oPlayer, parts)
    if not oPlayer then return 0 end

    if #parts == 1 then
        -- 无参数：显示第一页
        AchievementSystem.Show(oPlayer, 1)
        return 1
    end

    local arg = parts[2]
    local num = tonumber(arg)

    if not num then
        -- 非数字参数
        if arg == "重置" or arg == "reset" then
            -- 管理员子命令：/成就 重置 玩家名
            if #parts >= 3 and oPlayer.GameMaster and oPlayer.GameMaster ~= 0 then
                AchievementSystem.AdminShow(parts[3])
                return 1
            end
        end
        Message.Send(0, oPlayer.Index, 3, "【成就】参数格式错误，请输入数字")
        Message.Send(0, oPlayer.Index, 0, "使用 /成就 查看成就列表")
        return 1
    end

    -- 判断是页码还是成就编号：
    -- 如果数字 <= 总页数 → 页码
    -- 如果数字 > 总页数  → 成就编号
    -- 如果数字是有效的成就ID → 优先作为成就编号
    local totalPages = math.ceil(#AchievementSystem.Definitions / AchievementSystem.PER_PAGE)

    if AchievementSystem.GetById(num) then
        -- 数字匹配某个成就ID → 显示详情
        AchievementSystem.ShowDetail(oPlayer, num)
    elseif num >= 1 and num <= totalPages then
        -- 合理的页码范围
        AchievementSystem.Show(oPlayer, num)
    else
        Message.Send(0, oPlayer.Index, 3,
            string.format("【成就】无效编号 %d（页码范围 1-%d）", num, totalPages))
    end

    return 1
end

------------------------------------------------------------------
-- 初始化
------------------------------------------------------------------

---系统初始化（在 Main.lua 加载后调用）
function AchievementSystem.Initialize()
    -- 1. 构建查找索引
    AchievementSystem.BuildIndex()

    -- 2. 加载持久化数据
    AchievementSystem.LoadFromFile()

    -- 3. 启动自动保存
    AchievementSystem.StartAutoSave()

    -- 4. 注册回调（使用兼容模式，直接覆盖全局函数）
    --    如果你的 Callbacks.lua 已支持分派表，
    --    改为调用 AchievementSystem.RegisterCallbacks()
    --AchievementSystem.InstallGlobalHooks()

    Log.Add(string.format("[成就系统] 初始化完成，共 %d 个成就定义",
        #AchievementSystem.Definitions))
end
