--═══════════════════════════════════════════════════════════════
--== INTERNATIONAL GAMING CENTER NETWORK
--== www.igcn.mu
--== (C) 2010-2026 IGC-Network (R)
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--== File is a part of IGCN Group MuOnline Server files.
--═══════════════════════════════════════════════════════════════

------------------------------------------------------------------
-- Structs.lua - C++ 类型定义
------------------------------------------------------------------
-- 为暴露给 Lua 的 C++ 对象提供的 LuaDoc 类型提示。
-- 这些结构体无法在 Lua 中创建 - 它们是通过函数（如 Player.GetObjByIndex()）
-- 访问的 C++ 对象。
--
-- 完整文档请参阅：Reference/STRUCTS.md
------------------------------------------------------------------

------------------------------------------------------------------
-- userData 结构体
------------------------------------------------------------------

---@class userData
---@field Strength integer 基础力量属性
---@field Dexterity integer 基础敏捷属性
---@field Vitality integer 基础体力属性
---@field Energy integer 基础智力属性
---@field Command integer 基础统率属性
---@field AddStrength integer 额外力量（蓝色属性）
---@field AddDexterity integer 额外敏捷（蓝色属性）
---@field AddVitality integer 额外体力（蓝色属性）
---@field AddEnergy integer 额外智力（蓝色属性）
---@field AddCommand integer 额外统率（蓝色属性）
---@field LevelUpPoint integer 可用的升级点数
---@field DBClass integer 数据库中的角色职业 ID
---@field MasterLevel integer 当前大师等级
---@field MasterExp integer 当前大师等级经验值
---@field MasterNextExp integer 升到下一大师等级所需经验值
---@field ThirdTreePoint integer 第三技能树可用的精通点数
---@field UsedThirdTreePoint integer 第三技能树已使用的精通点数
---@field FourthTreePoint integer 第四技能树可用的精通点数
---@field UsedFourthTreePoint integer 第四技能树已使用的精通点数
---@field Money integer 金币（Zen）数量
---@field Ruud integer Ruud 货币数量
---@field Resets integer 今日总转生次数
---@field VIPType integer VIP 等级（-1 = 无）
---@field VIPMode integer 激活的 VIP 模式

------------------------------------------------------------------
-- ActionTickCount 结构体
------------------------------------------------------------------

---@class ActionTickCount
---@field name string 计时器名称（最多15个字符，只读）
---@field tick integer 计时器计数值（只读，使用 ActionTick.Set 修改）

------------------------------------------------------------------
-- TrackedObjectData 结构体
------------------------------------------------------------------

---@class TrackedObjectData
---@field class integer 怪物/NPC 的等级 ID
---@field type integer 对象类型（Enums.ObjectType: 2=怪物, 3=NPC）

------------------------------------------------------------------
-- 玩家对象 (stObject)
------------------------------------------------------------------
-- 注意：此结构体用于游戏中所有对象（玩家、怪物、NPC），
-- 而不仅仅是玩家。它代表了统一的对象结构。
--
-- 重要提示：并非所有字段对所有对象类型都有效：
-- - userData: 仅对玩家和类玩家 NPC 可用
-- - 对于怪物/NPC，某些字段可能未使用或含义不同
-- - 始终检查对象类型字段以确定哪些字段有效
------------------------------------------------------------------

---@class Object
---@field userData userData UserData 子结构体（只读指针；仅对玩家和类玩家 NPC 有效）
---@field Index integer 服务器数组中玩家对象的索引（只读）
---@field Type integer 对象类型（只读；Enums.ObjectType.USER玩家 | MONSTER怪物 | NPC）
---@field NPCType, BYTE （只读；Enums.NPCType,NONE | SHOP | WAREHOUSE | CHAOS_MIX | GOLDEN_ARCHER | PENTAGRAM_MIX | MAP_MOVE | LAST_MAN_STANDING）
---@field Connected integer 连接状态（1=已连接，0=已断开）
---@field UserNumber integer 唯一的用户会话编号（只读）
---@field DBNumber integer 数据库角色 ID（memb_guid；只读）
---@field LangCode integer 客户端语言代码
---@field Class integer 角色职业代码
---@field Level integer 角色等级
---@field AccountId string 账户登录名（只读）
-- @field Name string 玩家、怪物或 NPC 的对象名称（只读）
---@field Life number 当前生命值（HP）
---@field MaxLife number 最大生命值（HP）
---@field AddLife integer 来自物品/增益的额外生命值
---@field Shield integer 当前护盾值
---@field AddShield integer 来自物品/增益的额外护盾值
---@field MaxShield integer 最大护盾值
---@field Mana number 当前魔法值（MP）
---@field MaxMana number 最大魔法值（MP）
---@field AddMana integer 来自物品/增益的额外魔法值
---@field BP integer 当前 AG/体力值
---@field AddBP integer 来自物品/增益的额外 AG
---@field MaxBP integer 最大 AG
---@field PKCount integer 当前 PK 次数
---@field PKLevel integer PK 等级/状态（0-6）
---@field PKTime integer PK 状态剩余时间
---@field PKTotalCount integer 总 PK 次数（终身）
---@field X integer 当前 X 坐标
---@field Y integer 当前 Y 坐标
---@field Dir integer 面向方向（0-7）
---@field MapNumber integer 当前地图 ID
---@field Authority integer 权限等级
---@field AuthorityCode integer 权限验证码
---@field Penalty integer 惩罚标志/类型
---@field GameMaster integer 游戏管理员状态标志
---@field PenaltyMask integer 惩罚限制位掩码
---@field AttackDamageMin integer 最小攻击伤害（总计）
---@field AttackDamageMax integer 最大攻击伤害（总计）
---@field AttackDamageMinLeft integer 最小伤害（左手）
---@field AttackDamageMinRight integer 最小伤害（右手）
---@field AttackDamageMaxLeft integer 最大伤害（左手）
---@field AttackDamageMaxRight integer 最大伤害（右手）
---@field MagicDamageMin integer 最小魔法伤害
---@field MagicDamageMax integer 最大魔法伤害
---@field CurseDamageMin integer 最小诅咒伤害
---@field CurseDamageMax integer 最大诅咒伤害
---@field CurseSpell integer 激活的诅咒法术效果
---@field CombatPower integer 总战斗力评级
---@field CombatPowerAttackDamage integer 来自攻击伤害的战斗力
---@field Defense integer 总防御值
---@field AttackRating integer 攻击成功率
---@field DefenseRating integer 防御/格挡成功率
---@field AttackSpeed integer 攻击速度值
---@field MagicSpeed integer 魔法/技能施放速度
---@field PentagramMainAttribute integer 主艾尔特属性类型
---@field PentagramAttributePattern integer 艾尔特属性模式 ID
---@field PentagramDefense integer 基础艾尔特防御（PVM）
---@field PentagramDefensePvP integer 艾尔特防御（PVP）
---@field PentagramDefenseRating integer 艾尔特防御率（PVM）
---@field PentagramDefenseRatingPvP integer 艾尔特防御率（PVP）
---@field PentagramAttackMin integer 最小艾尔特攻击（PVM）
---@field PentagramAttackMax integer 最大艾尔特攻击（PVM）
---@field PentagramAttackMinPvP integer 最小艾尔特攻击（PVP）
---@field PentagramAttackMaxPvP integer 最大艾尔特攻击（PVP）
---@field PentagramAttackRating integer 艾尔特攻击率（PVM）
---@field PentagramAttackRatingPvP integer 艾尔特攻击率（PVP）
---@field PentagramDamageMin integer 最小艾尔特伤害修正值
---@field PentagramDamageMax integer 最大艾尔特伤害修正值
---@field PentagramDamageOrigin integer 基础艾尔特伤害
---@field PentagramCriticalDamageRate integer 致命一击伤害率
---@field PentagramExcellentDamageRate integer 卓越一击伤害率
---@field PartyNumber integer 队伍 ID（如果不在队伍中则为 -1）
---@field WinDuels integer 决斗胜利总次数
---@field LoseDuels integer 决斗失败总次数
---@field Live integer 存活状态（1=存活，0=死亡）
---@field ActionTickCount ActionTickCount[] 3个计时器的数组（Lua 索引 1-3）
---@field TradeMoney integer 交易窗口中提供的 Zen 数量
---@field TradeOk integer 交易确认状态（0=未确认，1=已确认）
-- @field TargetNumber short 目标对象索引（正在攻击的怪物/玩家）
-- @field TargetNpcNumber short NPC 对象索引（玩家正在交互的 NPC）

-- Player methods
---@param iInventoryPos integer 背包槽位（0 到 INVENTORY_SIZE-1）
---@return ItemInfo|nil 如果有效则返回物品指针，否则返回 nil
function Object:GetInventoryItem(iInventoryPos) end

---@param iWarehousePos integer 仓库槽位（0 到 WAREHOUSE_SIZE-1）
---@return ItemInfo|nil 如果有效则返回物品指针，否则返回 nil
function Object:GetWarehouseItem(iWarehousePos) end

---@param iTradeBoxPos integer 交易栏槽位（0 到 TRADE_BOX_SIZE-1）
---@return ItemInfo|nil 如果有效则返回物品指针，否则返回 nil
function Object:GetTradeItem(iTradeBoxPos) end

------------------------------------------------------------------
-- ItemAttr Structure (只读)
------------------------------------------------------------------

---@class ItemAttr
---@field HasItemInfo integer 物品有有效信息（0-1）
---@field Level integer 物品等级（0-15）
---@field Serial integer 序列号是否启用（0-1）
---@field Width integer 背包占用宽度（1-2）
---@field Height integer 背包占用高度（1-4）
---@field TwoHands integer 是否双手物品（0-1）
---@field Option integer 物品选项标志
---@field QuestItem boolean 是否为任务物品
---@field SetAttribute integer 套装物品属性/ID
---@field DamageMin integer 最小物理伤害
---@field DamageMax integer 最大物理伤害
---@field AttackRate integer 攻击成功率加成
---@field DefenseRate integer 防御/格挡率加成
---@field Defense integer 防御值
---@field CombatPower integer 战斗力评级
---@field MagicPower integer 魔法力评级
---@field AttackSpeed integer 攻击速度加成
---@field WalkSpeed integer 移动速度加成
---@field Durability integer 最大耐久度
---@field MagicDurability integer 最大魔法耐久度
---@field ReqLevel integer 所需等级
---@field ReqStrength integer 所需力量
---@field ReqAgility integer 所需敏捷
---@field ReqEnergy integer 所需能量
---@field ReqVitality integer 所需体力
---@field ReqCommand integer 所需统率
---@field Value integer 物品基础价值
---@field BuyMoney integer 从 NPC 购买的价格
---@field ItemKindA integer 主物品类别
---@field ItemKindB integer 次物品类别
---@field ItemCategory integer 物品类别分类
---@field ItemSlot integer 装备槽位（0-11）
---@field ResistanceType integer 主要抗性类型
---@field SkillType integer 关联的技能类型
---@field MasteryGrade integer 精通系统等级
---@field LegendaryGrade integer 传奇物品等级
---@field PentagramType integer 艾尔特元素类型
---@field MasteryPentagram boolean 是否启用艾尔特精通
---@field ElementalDamage integer 元素伤害值
---@field ElementalDefense integer 元素防御值
---@field Dump integer 是否可以丢弃（0-1）
---@field Transaction integer 是否可以交易（0-1）
---@field PersonalStore integer 是否可以在个人商店出售（0-1）
---@field StoreWarehouse integer 是否可以存入仓库（0-1）
---@field SellToNPC integer 是否可以卖给 NPC（0-1）
---@field ExpensiveItem integer 贵重物品标志（0-1）
---@field Repair integer 是否可以修理（0-1）
---@field ItemOverlap integer 是否可以堆叠（0-255）
---@field NonValue integer 是否无价值（0-1）

-- ItemAttr methods
---@return string 物品名称（最多 96 个字符）
function ItemAttr:GetName() end

---@param iClass integer 职业索引（0-15）
---@return integer 所需的职业进化等级（0-5，如果无效则为 -1）
function ItemAttr:GetRequireClass(iClass) end

---@param iType integer 抗性类型索引
---@return integer 抗性值（0-255，如果无效则为 -1）
function ItemAttr:GetResistance(iType) end

------------------------------------------------------------------
-- CreateItemInfo Structure
------------------------------------------------------------------

---@class CreateItemInfo
---@field MapNumber integer 物品生成的地图编号
---@field X integer X 坐标
---@field Y integer Y 坐标
---@field ItemId integer 物品类型/ID
---@field ItemLevel integer 物品等级（0-15）
---@field Durability integer 物品耐久度
---@field Option1 integer 幸运属性（0-1）
---@field Option2 integer 技能属性（0-1）
---@field Option3 integer 额外属性（0-7）
---@field LootIndex integer 所有者玩家索引（-1 = 任何人）
---@field NewOption integer 卓越属性位掩码
---@field SetOption integer 套装/远古属性
---@field ItemOptionEx integer 物品额外属性（380级）
---@field Duration integer 物品持续时间戳
---@field MainAttribute integer 主艾尔特属性
---@field TargetInvenPos integer 目标背包位置（255=自动）
---@field PetCreate boolean 是否创建为宠物物品

-- CreateItemInfo 方法（索引从 1 开始）
---@param index integer 镶嵌槽位（从 1 开始）
---@return integer 镶嵌宝石值（如果无效则为 -1）
function CreateItemInfo:GetSocket(index) end

---@param index integer 镶嵌槽位（从 1 开始）
---@param value integer 镶嵌宝石值（0-255）
function CreateItemInfo:SetSocket(index, value) end

---@param index integer 再生属性索引（从 1 开始）
---@return integer 再生属性类型（如果无效则为 -1）
function CreateItemInfo:GetHarmonyOptionType(index) end

---@param index integer 再生属性索引（从 1 开始）
---@param value integer 再生属性类型（0-255）
function CreateItemInfo:SetHarmonyOptionType(index, value) end

---@param index integer 再生属性索引（从 1 开始）
---@return integer 再生属性值（如果无效则为 -1）
function CreateItemInfo:GetHarmonyOptionValue(index) end

---@param index integer 再生属性索引（从 1 开始）
---@param value integer 再生属性值
function CreateItemInfo:SetHarmonyOptionValue(index, value) end

---@param index integer 属性槽位索引（从 1 开始）
---@return integer 属性值（如果无效则为 -1）
function CreateItemInfo:GetOptSlot(index) end

---@param index integer 属性槽位索引（从 1 开始）
---@param value integer 属性值（0-255）
function CreateItemInfo:SetOptSlot(index, value) end

------------------------------------------------------------------
-- ItemInfo Structure
------------------------------------------------------------------

---@class ItemInfo
---@field SerialNumber integer 物品唯一序列号
---@field HasSerial integer 序列号检查标志（0-1）
---@field Type integer 物品类型/ID
---@field Level integer 物品等级（0-15）
---@field Slot integer 物品装备槽位
---@field TwoHands integer 是否双手物品（0-1）
---@field AttackSpeed integer 攻击速度
---@field WalkSpeed integer 移动速度
---@field DamageMin integer 最小伤害
---@field DamageMax integer 最大伤害
---@field Defense integer 防御值
---@field DefenseRate integer 防御率
---@field AttackRate integer 攻击成功率
---@field MagicPower integer 魔法力
---@field CurseSpell integer 诅咒法术
---@field CombatPower integer 战斗力
---@field Durability number 当前耐久度
---@field DurabilitySmall integer 耐久度小数值
---@field BaseDurability number 基础耐久度
---@field ReqLevel integer 所需等级
---@field ReqStrength integer 所需力量
---@field ReqAgility integer 所需敏捷
---@field ReqEnergy integer 所需能量
---@field ReqVitality integer 所需体力
---@field ReqCommand integer 所需统率
---@field Value integer 物品价值
---@field SellMoney integer 出售价格
---@field BuyMoney integer 购买价格
---@field IsItemExist boolean 物品是否存在
---@field IsValidItem boolean 是否为有效物品
---@field SkillChange boolean 技能是否改变标志
---@field QuestItem boolean 是否为任务物品
---@field Option1 integer 是否幸运（0-1）
---@field Option2 integer 是否带技能（0-1）
---@field Option3 integer 额外属性（0-7）
---@field NewOption integer 卓越属性位掩码
---@field SetOption integer 套装属性
---@field SetAddStat integer 套装附加属性
---@field ItemOptionEx integer 物品额外属性（380级）
---@field BonusSocketOption integer 奖励镶嵌属性
---@field IsLoadPetItemInfo boolean 是否已加载宠物信息
---@field PetItemLevel integer 宠物物品等级
---@field PetItemExp integer 宠物物品经验值
---@field ImproveDurabilityRate integer 耐久度提升率
---@field PeriodItemOption integer 时限物品标志
---@field ElementalDefense integer 元素防御
---@field LegendaryAddOptionType integer 传奇附加属性类型
---@field LegendaryAddOptionValue integer 传奇附加属性值

-- ItemInfo 方法
---@param index integer 职业索引（从 0 开始）
---@return integer 职业需求（如果无效则为 -1）
function ItemInfo:GetRequireClass(index) end

---@param index integer 职业索引（从 0 开始）
---@param value integer 职业需求（0-5）
function ItemInfo:SetRequireClass(index, value) end

---@param index integer 抗性类型（从 0 开始）
---@return integer 抗性值（如果无效则为 -1）
function ItemInfo:GetResistance(index) end

---@param index integer 抗性类型（从 0 开始）
---@param value integer 抗性值
function ItemInfo:SetResistance(index, value) end

---@param index integer 镶嵌槽位（从 1 开始）
---@return integer 镶嵌宝石值（如果无效则为 -1）
function ItemInfo:GetSocket(index) end

---@param index integer 镶嵌槽位（从 1 开始）
---@param value integer 镶嵌宝石值（0-255）
function ItemInfo:SetSocket(index, value) end

---@param index integer 再生属性（从 1 开始）
---@return integer 再生属性类型（如果无效则为 -1）
function ItemInfo:GetHarmonyOptionType(index) end

---@param index integer 再生属性（从 1 开始）
---@param value integer 再生属性类型（0-255）
function ItemInfo:SetHarmonyOptionType(index, value) end

---@param index integer 再生属性（从 1 开始）
---@return integer 再生属性值（如果无效则为 -1）
function ItemInfo:GetHarmonyOptionValue(index) end

---@param index integer 再生属性（从 1 开始）
---@param value integer 再生属性值（0-65535）
function ItemInfo:SetHarmonyOptionValue(index, value) end

---@param index integer 属性槽位（从 1 开始）
---@return integer 属性值（如果无效则为 -1）
function ItemInfo:GetOptSlot(index) end

---@param index integer 属性槽位（从 1 开始）
---@param value integer 属性值（0-255）
function ItemInfo:SetOptSlot(index, value) end

-- 重新计算物品属性
function ItemInfo:Convert() end

-- 清除指定位置的物品
function ItemInfo:Clear() end

------------------------------------------------------------------
-- BagItem Structure
------------------------------------------------------------------

---@class BagItem
---@field ItemType BYTE 物品类型（0-21）
---@field ItemIndex WORD 物品索引（0-511）
---@field ItemMinLevel BYTE 最小物品等级（0-15）
---@field ItemMaxLevel BYTE 最大物品等级（0-15）
---@field Skill short 是否带技能（-1, 0, 1）
---@field Luck short 是否幸运（-1, 0, 1）
---@field Option short 是否带额外属性（-1, 0, 1-7）
---@field Anc short 是否为远古/套装（0-1）
---@field Socket short 是否为镶嵌物品（-2, 0-5）
---@field Elemental short 是否为元素（-1, 0-5）
---@field ErrtelRank short 艾尔特等级（1-5）
---@field MuunEvolutionItemType BYTE Muun 进化类型
---@field MuunEvolutionItemIndex WORD Muun 进化索引
---@field Durability WORD 物品耐久度
---@field Duration DWORD 物品持续时间

-- BagItem 方法（索引从 1 开始）
---@param index integer 镶嵌槽位（从 1 开始）
---@return integer 镶嵌宝石值（如果无效则为 -1）
function BagItem:GetSocket(index) end

---@param index integer 镶嵌槽位（从 1 开始）
---@param value integer 镶嵌宝石值
function BagItem:SetSocket(index, value) end

---@param index integer 卓越属性槽位（从 1 开始）
---@return integer 卓越属性（如果无效则为 -1）
function BagItem:GetExc(index) end

---@param index integer 卓越属性槽位（从 1 开始）
---@param value integer 卓越属性值
function BagItem:SetExc(index, value) end

---@param index integer 属性槽位（从 1 开始）
---@return integer 属性值（如果无效则为 -1）
function BagItem:GetOptSlot(index) end

---@param index integer 属性槽位（从 1 开始）
---@param value integer 属性值
function BagItem:SetOptSlot(index, value) end

------------------------------------------------------------------
-- QueryResultDS Structure (Read-Only)
------------------------------------------------------------------

---@class QueryResultDS
---@field ColumnType integer Column data type (0-255)

-- QueryResultDS methods
---@return string Column name (max 30 chars)
function QueryResultDS:GetColumnName() end

---@return string Column value (max 64 chars)
function QueryResultDS:GetValue() end

------------------------------------------------------------------
-- QueryResultJS Structure (Read-Only)
------------------------------------------------------------------

---@class QueryResultJS
---@field ColumnType integer Column data type (0-255)

-- QueryResultJS methods
---@return string Column name (max 30 chars)
function QueryResultJS:GetColumnName() end

---@return string Column value (max 64 chars)
function QueryResultJS:GetValue() end

------------------------------------------------------------------
-- stLuaRow (Alias for QueryResultJS)
------------------------------------------------------------------

---@alias stLuaRow QueryResultJS

------------------------------------------------------------------
-- MonsterAttr Structure
------------------------------------------------------------------

---@class MonsterAttr
---@field Index integer Monster class index (readonly)
---@field Level integer Monster level
---@field ScriptHP integer Script-defined HP override
---@field HP integer Maximum HP
---@field MP integer Maximum MP
---@field DamageMin integer Minimum attack damage
---@field DamageMax integer Maximum attack damage
---@field Defense integer Defense rating
---@field MagicDefense integer Magic defense rating
---@field AttackRating integer Attack success rating
---@field DefenseRating integer Defense success rate
---@field MoveRange integer Movement range (tiles)
---@field AttackRange integer Attack range (tiles)
---@field AttackType integer Attack type (readonly)
---@field ViewRange integer View/detection range (tiles)
---@field MoveSpeed integer Movement speed
---@field AttackSpeed integer Attack speed
---@field RegenTime integer Respawn time (ms)
---@field Attribute integer Monster attribute flags (readonly)
---@field PentagramMainAttribute integer Pentagram main attribute
---@field PentagramAttributePattern integer Pentagram attribute pattern
---@field PentagramDefense integer Pentagram defense
---@field PentagramAttackMin integer Pentagram minimum attack
---@field PentagramAttackMax integer Pentagram maximum attack
---@field PentagramAttackRate integer Pentagram attack rating
---@field PentagramDefenseRate integer Pentagram defense rating
---@field MonsterExpLevel integer Monster exp level modifier
---@field CriticalDamageResistance integer Critical damage resistance
---@field ExcellentDamageResistance integer Excellent damage resistance
---@field DebuffApplyResistance integer Debuff apply resistance
---@field DamageAbsorb integer Damage absorption
---@field IsEliteMonster boolean Is an elite monster
---@field IsRadiancePunishImmune boolean Immune to radiance punishment
---@field ExtraDefense integer Extra defense
---@field ExtraDamageMin integer Extra minimum damage
---@field ExtraDamageMax integer Extra maximum damage
---@field DamageCorrection integer Damage correction factor
---@field IsTrap boolean Is a trap object (readonly)

---Returns monster name
---@return string
function MonsterAttr:GetName() end

---Returns resistance value for given type
---@param iType integer Resistance type index (0 to MAX_RESISTENCE_TYPE-1)
---@return integer Resistance value, or -1 if out of range
function MonsterAttr:GetResistance(iType) end

