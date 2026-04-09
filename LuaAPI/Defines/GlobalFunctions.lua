--═══════════════════════════════════════════════════════════════
--== INTERNATIONAL GAMING CENTER NETWORK
--== www.igcn.mu
--== (C) 2010-2026 IGC-Network (R)
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--== File is a part of IGCN Group MuOnline Server files.
--═══════════════════════════════════════════════════════════════

------------------------------------------------------------------
-- GlobalFunctions.lua - 全局函数的类型定义
------------------------------------------------------------------
-- 为暴露给 Lua 的所有服务器函数提供的 LuaDoc 类型提示。
-- 这些是用于 IDE 自动补全的函数声明 - 并非实际实现。
--
-- 使用方法：使用命名空间语法调用函数：
--   Player.GetObjByIndex(index)
--   Object.ForEachPlayer(callback)
--   Timer.Create(interval, name, callback)
--
-- 完整文档请参阅：Reference/Functions/GLOBAL_FUNCTIONS.md
------------------------------------------------------------------

------------------------------------------------------------------
-- Server Namespace
------------------------------------------------------------------

Server = {}

---@return integer 服务器代码标识符
function Server.GetCode() end

---@return string 服务器显示名称
function Server.GetName() end

---@return integer VIP等级（未设置则为-1）
function Server.GetVIPLevel() end

---@return boolean 如果PvP被禁用则返回true
function Server.IsNonPvP() end

---@return boolean 如果+28选项启用则返回true
function Server.Is28Option() end

---@param iPlayerClassType integer 角色职业类型
---@return integer 该职业每级的属性点
function Server.GetClassPointsPerLevel(iPlayerClassType) end

------------------------------------------------------------------
-- Object 命名空间
------------------------------------------------------------------

Object = {}

---@return integer 最大对象总数
function Object.GetMax() end

---@return integer 最大怪物数量
function Object.GetMaxMonster() end

---@return integer 最大用户数量
function Object.GetMaxUser() end

---@return integer 最大在线用户数
function Object.GetMaxOnlineUser() end

---@return integer 最大排队用户数
function Object.GetMaxQueueUser() end

---@return integer 最大地面物品数
function Object.GetMaxItem() end

---@return integer 最大召唤怪物数
function Object.GetMaxSummonMonster() end

---@return integer 起始用户索引
function Object.GetStartUserIndex() end

---遍历所有对象（玩家、怪物、物品）
---@param callback function 回调函数(oObject) - 返回false则中断
function Object.ForEach(callback) end

---遍历所有已连接的玩家
---@param callback function 回调函数(oPlayer) - 返回false则中断
function Object.ForEachPlayer(callback) end

---遍历指定地图上的玩家
---@param mapNumber integer 地图编号
---@param callback function 回调函数(oPlayer) - 返回false则中断
function Object.ForEachPlayerOnMap(mapNumber, callback) end

---遍历所有存活的怪物
---@param callback function 回调函数(oMonster) - 返回false则中断
function Object.ForEachMonster(callback) end

---遍历指定地图上的怪物
---@param mapNumber integer 地图编号
---@param callback function 回调函数(oMonster) - 返回false则中断
function Object.ForEachMonsterOnMap(mapNumber, callback) end

---遍历指定职业的怪物
---@param monsterClass integer 怪物职业ID
---@param callback function 回调函数(oMonster) - 返回false则中断
function Object.ForEachMonsterByClass(monsterClass, callback) end

---遍历队伍成员
---@param partyNumber integer 队伍编号
---@param callback function 回调函数(oPlayer) - 返回false则中断
function Object.ForEachPartyMember(partyNumber, callback) end

---遍历战盟成员
---@param guildName string 战盟名称
---@param callback function 回调函数(oPlayer) - 返回false则中断
function Object.ForEachGuildMember(guildName, callback) end

---遍历范围内附近的对象
---@param centerIndex integer 中心对象索引
---@param range integer 地图单位范围
---@param callback function 回调函数(oObject, distance) - 返回false则中断
function Object.ForEachNearby(centerIndex, range, callback) end

---统计指定地图上的玩家数量（可选过滤器）
---@param mapNumber integer 地图编号
---@param filter? function 可选的过滤函数(oPlayer) -> boolean
---@return integer 符合条件的人数
function Object.CountPlayersOnMap(mapNumber, filter) end

---统计指定地图上的怪物数量（可选过滤器）
---@param mapNumber integer 地图编号
---@param filter? function 可选的过滤函数(oMonster) -> boolean
---@return integer 符合条件的怪物数量
function Object.CountMonstersOnMap(mapNumber, filter) end

---根据名称查找玩家（优化提前退出）
---@param playerName string 要查找的玩家名称
---@return object|nil 玩家对象，未找到返回nil
function Object.GetObjByName(playerName) end

---在指定地图的边界框内生成怪物
---@param iMonIndex integer 怪物职业ID
---@param iMapNumber integer 地图编号
---@param iBeginX integer 生成区域起始X
---@param iBeginY integer 生成区域起始Y
---@param iEndX integer 生成区域结束X
---@param iEndY integer 生成区域结束Y
---@param iMonAttr integer 元素属性（Enums.ElementType），0表示无
---@return integer 生成的怪物对象索引，失败返回-1
function Object.AddMonster(iMonIndex, iMapNumber, iBeginX, iBeginY, iEndX, iEndY, iMonAttr) end

---立即从世界中移除怪物
---@param aIndex integer 怪物对象索引
---@return integer gObjDel的结果
function Object.DelMonster(aIndex) end

---在指定位置添加NPC到游戏
---@param iNPCIndex integer NPC职业ID
---@param iMapNumber integer 地图编号
---@param iX integer X坐标
---@param iY integer Y坐标
---@param iNpcType integer NPC类型（Enums.NPCType）
---@return integer 生成的NPC对象索引，失败返回-1
function Object.AddNPC(iNPCIndex, iMapNumber, iX, iY, iNpcType) end

------------------------------------------------------------------
-- Player 命名空间
------------------------------------------------------------------

Player = {}

---@param iPlayerIndex integer 玩家索引
---@return boolean 如果已连接则返回true
function Player.IsConnected(iPlayerIndex) end

---@param iPlayerIndex integer 玩家索引
---@return object|nil 玩家对象（stObject），未找到返回nil
function Player.GetObjByIndex(iPlayerIndex) end

---@param szPlayerName string 玩家名称
---@return object|nil 玩家对象（stObject），未找到返回nil
function Player.GetObjByName(szPlayerName) end

---@param szPlayerName string 玩家名称
---@return integer 玩家索引（未找到返回-1）
function Player.GetIndexByName(szPlayerName) end

---@param iPlayerIndex integer 玩家索引
---@param iAmount integer 金币数量（可为负数）
---@param bResetMoney boolean 是否先重置为0
function Player.SetMoney(iPlayerIndex, iAmount, bResetMoney) end

---@param iPlayerIndex integer 玩家索引
---@param iRuud integer 基础Ruud值
---@param iObtainedRuud integer 要添加/减少的Ruud
---@param bIsObtainedRuud boolean 是否显示通知
function Player.SetRuud(iPlayerIndex, iRuud, iObtainedRuud, bIsObtainedRuud) end

---@param iPlayerIndex integer 玩家索引
function Player.Reset(iPlayerIndex) end

---@param iPlayerIndex integer 玩家索引
---@return integer 进化等级（1-5，无效返回-1）
function Player.GetEvo(iPlayerIndex) end

---@param iPlayerIndex integer 玩家索引
function Player.ReCalc(iPlayerIndex) end

---修改HP或护盾值后向客户端发送生命/护盾更新包
---@param iPlayerIndex integer 玩家索引
---@param iLife integer 要发送的生命值
---@param flag integer 更新标志（见Enums.HPManaUpdateFlag）
---@param iShield integer 要发送的护盾值
function Player.SendLife(iPlayerIndex, iLife, flag, iShield) end

---修改法力或AG值后向客户端发送法力/AG更新包
---@param iPlayerIndex integer 玩家索引
---@param iMana integer 要发送的法力值
---@param flag integer 更新标志（见Enums.HPManaUpdateFlag）
---@param iBP integer 要发送的AG/体力值
function Player.SendMana(iPlayerIndex, iMana, flag, iBP) end


---将角色保存到数据库
---@param iPlayerIndex integer 玩家索引
function Player.SaveCharacter(iPlayerIndex) end

---向客户端发送经验包（修改oPlayer.Experience后必须调用）
---@param iPlayerIndex integer 接收经验的玩家
---@param iTargetIndex integer 经验来源（非战斗使用-1）
---@param i64Exp integer 经验值
---@param iAttackDamage integer 造成的伤害（自定义经验时为0）
---@param bMSBFlag boolean 大师技能书标志
---@param iMonsterType integer 怪物类型ID（自定义经验时为0）
function Player.SetExp(iPlayerIndex, iTargetIndex, i64Exp, iAttackDamage, bMSBFlag, iMonsterType) end

---向客户端发送交易OK按钮包
---@param iPlayerIndex integer 玩家索引
---@param btFlag integer 按钮标志：0=未同意（无边框），1=已同意（绿色边框），2=物品已从交易中移除
function Player.SendTradeOkButton(iPlayerIndex, btFlag) end

---向客户端发送交易取消/结果包
---@param iPlayerIndex integer 玩家索引
---@param btResult integer 结果代码：0=已取消，2=背包已满，3=请求已取消，4=强化物品，5=请求已取消，6=艾尔特超过限制，7=已装备255+ Errtel
function Player.SendTradeCancel(iPlayerIndex, btResult) end

---向客户端发送交易响应包
---@param bResponse boolean 响应（true=接受，false=拒绝）
---@param iPlayerIndex integer 玩家索引
---@param szName string 交易伙伴名称
---@param iLevel integer 交易伙伴等级（等级+大师等级）
---@param iGuildNumber integer 交易伙伴战盟编号
function Player.SendTradeResponse(bResponse, iPlayerIndex, szName, iLevel, iGuildNumber) end

---处理交易OK按钮点击
---@param iPlayerIndex integer 玩家索引
function Player.TradeOkButton(iPlayerIndex) end

---取消玩家的交易
---@param iPlayerIndex integer 玩家索引
function Player.TradeCancel(iPlayerIndex) end

------------------------------------------------------------------
-- Combat 命名空间
------------------------------------------------------------------

Combat = {}

---@param aTargetMonsterIndex integer 怪物索引
---@return integer 造成伤害最高的玩家索引
function Combat.GetTopDamageDealer(aTargetMonsterIndex) end

------------------------------------------------------------------
-- Stats 命名空间
------------------------------------------------------------------

Stats = {}

---@param iPlayerIndex integer 玩家索引
---@param iStatType integer 属性类型（0=力量，1=敏捷，2=体力，3=智力，4=统率）
---@param iStatValue integer 要添加的属性值
---@param iStatAddType integer 添加类型（0=基础，1=额外）
---@param iLevelUpPoint integer 要消耗的升级点数
function Stats.Set(iPlayerIndex, iStatType, iStatValue, iStatAddType, iLevelUpPoint) end

---@param iPlayerIndex integer 玩家索引
---@param iStatType integer 属性类型
---@param iStatValue integer 新的属性值
---@param iLevelUpPoint integer 剩余升级点数
function Stats.SendUpdate(iPlayerIndex, iStatType, iStatValue, iLevelUpPoint) end

---@param oPlayer object 玩家对象（stObject）
---@param i64AddExp integer 要添加的经验值
---@param iMonsterType integer 怪物类型（如果不是来自怪物则为0）
---@param szEventType string 事件类型名称
---@return boolean 如果发生了升级则返回true
function Stats.LevelUp(oPlayer, i64AddExp, iMonsterType, szEventType) end

------------------------------------------------------------------
-- Inventory 命名空间
------------------------------------------------------------------

Inventory = {}

---@param iPlayerIndex integer 玩家索引
---@param iInventoryPos integer 背包格子
function Inventory.SendUpdate(iPlayerIndex, iInventoryPos) end

---@param iPlayerIndex integer 玩家索引
---@param iInventoryPos integer 背包格子
function Inventory.SendDelete(iPlayerIndex, iInventoryPos) end

---@param iPlayerIndex integer 玩家索引
function Inventory.SendList(iPlayerIndex) end

---@param oPlayer object 玩家对象（stObject）
---@param iItemHeight integer 物品高度
---@param iItemWidth integer 物品宽度
---@return boolean 如果有空间则返回true
function Inventory.HasSpace(oPlayer, iItemHeight, iItemWidth) end

---@param iPlayerIndex integer 玩家索引
---@param oItem object 物品对象（ItemInfo）
function Inventory.Insert(iPlayerIndex, oItem) end

---@param iPlayerIndex integer 玩家索引
---@param oItem object 物品对象（ItemInfo）
---@param btInventoryPos integer 背包位置
---@return integer 结果代码
function Inventory.InsertAt(iPlayerIndex, oItem, btInventoryPos) end

---@param iPlayerIndex integer 玩家索引
---@param iInventoryItemPos integer 背包格子
function Inventory.Delete(iPlayerIndex, iInventoryItemPos) end

---@param iPlayerIndex integer 玩家索引
---@param iInventoryItemStartPos integer 起始位置
---@param btItemType integer 物品类型（0xFF表示清除）
function Inventory.SetSlot(iPlayerIndex, iInventoryItemStartPos, btItemType) end

---@param oPlayer object 玩家对象（stObject）
---@param iInventoryItemPos integer 背包格子
---@param iDurabilityMinus integer 要减少的耐久度
---@return integer 剩余耐久度
function Inventory.ReduceDur(oPlayer, iInventoryItemPos, iDurabilityMinus) end

---@return boolean 空间检查结果
function Inventory.RectCheck() end

------------------------------------------------------------------
-- Item 命名空间
------------------------------------------------------------------

Item = {}

---@param iItemId integer 物品ID
---@return integer 有效返回1，否则0
function Item.IsValid(iItemId) end

---@param iItemId integer 物品ID
---@return integer KindA类别
function Item.GetKindA(iItemId) end

---@param iItemId integer 物品ID
---@return integer KindB子类别
function Item.GetKindB(iItemId) end

---@param iItemId integer 物品ID
---@return object 物品属性结构体（ItemAttr）
function Item.GetAttr(iItemId) end

---@param iItemId integer 物品ID
---@return boolean 如果是镶嵌物品则返回true
function Item.IsSocket(iItemId) end

---@param iItemId integer 物品ID
---@return boolean 如果是卓越镶嵌配件则返回true
function Item.IsExcSocketAccessory(iItemId) end

---@param iItemId integer 物品ID
---@return boolean 如果是元素物品则返回true
function Item.IsElemental(iItemId) end

---@param iItemId integer 物品ID
---@return boolean 如果是艾尔特则返回true
function Item.IsPentagram(iItemId) end

---@param iItemId integer Item ID
---@return boolean True if master pentagram item
function Item.IsMasterPentagram(iItemId) end

---@param iItemId integer Item ID
---@return boolean True if pentagram jewel
function Item.IsPentagramJewel(iItemId) end

---@param iItemId integer Item ID
---@return boolean True if master pentagram jewel
function Item.IsMasterPentagramJewel(iItemId) end

---@param iItemId integer Item ID
---@return integer Set option index
function Item.GetSetOption(iItemId) end

---@param iMinLevel integer 最低等级
---@param iMaxLevel integer 最高等级
---@return integer 随机物品等级
function Item.GetRandomLevel(iMinLevel, iMaxLevel) end

---@param iPlayerIndex integer 玩家索引
---@param stItemCreate object CreateItemInfo结构体 物品创建信息
function Item.Create(iPlayerIndex, stItemCreate) end

---@param iPlayerIndex integer 玩家索引
---@param bGremoryCase integer Gremory箱子标志
---@param bDropMasterySet boolean 是否掉落精通套装
function Item.MakeRandomSet(iPlayerIndex, bGremoryCase, bDropMasterySet) end

------------------------------------------------------------------
-- Monster Namespace
------------------------------------------------------------------

Monster = {}

---Returns monster attribute table for given class
---@param iClass integer Monster class ID
---@return MonsterAttr|nil Monster attribute object, or nil if not found
function Monster.GetAttr(iClass) end

------------------------------------------------------------------
-- ItemBag Namespace
------------------------------------------------------------------

ItemBag = {}

---@param iBagType integer 物品包类型（0=掉落，1=背包，2=怪物，3=事件）
---@param iParam1 integer 参数1（取决于类型）
---@param iParam2 integer 参数2（取决于类型）
---@param strFileName string 物品包文件名
function ItemBag.Add(iBagType, iParam1, iParam2, strFileName) end

---@param iPlayerIndex integer 玩家索引
---@param stBagItem object 物品包物品结构体（BagItem）
function ItemBag.CreateItem(iPlayerIndex, stBagItem) end

------------------------------------------------------------------
-- Buff 命名空间
------------------------------------------------------------------

Buff = {}

---@param oPlayer object 玩家对象（stObject）
---@param iBuffIndex integer Buff索引
---@param EffectType1 integer 效果类型1
---@param EffectValue1 integer 效果值1
---@param EffectType2 integer 效果类型2
---@param EffectValue2 integer 效果值2
---@param iBuffDuration integer 持续时间（秒）
---@param BuffSendValue integer 发送值
---@param nAttackerIndex integer 攻击者索引
function Buff.Add(oPlayer, iBuffIndex, EffectType1, EffectValue1, EffectType2, EffectValue2, iBuffDuration, BuffSendValue, nAttackerIndex) end

---@param oPlayer object 玩家对象（stObject）
---@param wItemID integer 物品ID
---@param iBuffDuration integer 持续时间（秒）
function Buff.AddCashShop(oPlayer, wItemID, iBuffDuration) end

---@param oPlayer object 玩家对象（stObject）
---@param iBuffIndex integer Buff索引
function Buff.AddItem(oPlayer, iBuffIndex) end

---@param oPlayer object 玩家对象（stObject）
---@param iBuffIndex integer Buff索引
function Buff.Remove(oPlayer, iBuffIndex) end

---@param oPlayer object 玩家对象（stObject）
---@param iBuffIndex integer Buff索引
---@return boolean 如果Buff活跃则返回true
function Buff.CheckUsed(oPlayer, iBuffIndex) end

------------------------------------------------------------------
-- Skill 命名空间
------------------------------------------------------------------

Skill = {}

---@param oPlayer object 玩家对象（stObject）
---@param oTarget Player 目标对象
---@param TargetXPos integer 目标X位置
---@param TargetYPos integer 目标Y位置
---@param iPlayerDirection integer 玩家方向
---@param iMagicNumber integer 魔法/技能编号
function Skill.UseDuration(oPlayer, oTarget, TargetXPos, TargetYPos, iPlayerDirection, iMagicNumber) end

---@param oPlayer object 玩家对象（stObject）
---@param oTarget Player 目标对象
---@param iMagicNumber integer 魔法/技能编号
function Skill.UseNormal(oPlayer, oTarget, iMagicNumber) end

------------------------------------------------------------------
-- Viewport 命名空间
------------------------------------------------------------------

Viewport = {}

---@param oPlayer object 玩家对象（stObject）
function Viewport.Create(oPlayer) end

---@param oPlayer object 玩家对象（stObject）
function Viewport.Destroy(oPlayer) end

------------------------------------------------------------------
-- Move 命名空间
------------------------------------------------------------------

Move = {}

---@param iPlayerIndex integer 玩家索引
---@param iGateIndex integer 传送门索引
---@return boolean 如果成功则返回true
function Move.Gate(iPlayerIndex, iGateIndex) end

---@param iTargetObjectIndex integer 目标索引
---@param iMapNumber integer 地图编号
---@param PosX integer X坐标
---@param PosY integer Y坐标
function Move.ToMap(iTargetObjectIndex, iMapNumber, PosX, PosY) end

---@param iTargetObjectIndex integer 目标索引
---@param PosX integer X坐标
---@param PosY integer Y坐标
function Move.Warp(iTargetObjectIndex, PosX, PosY) end

------------------------------------------------------------------
-- Party 命名空间
------------------------------------------------------------------

Party = {}

---@param iPartyNumber integer 队伍编号
---@return integer 成员数量
function Party.GetCount(iPartyNumber) end

---@param iPartyNumber integer 队伍编号
---@param iArrayIndex integer 数组索引（1=队长，2-5=成员）
---@return integer 玩家索引
function Party.GetMember(iPartyNumber, iArrayIndex) end

------------------------------------------------------------------
-- DB 命名空间
------------------------------------------------------------------

DB = {}

---@param iPlayerIndex integer 玩家索引
---@param iQueryNumber integer 查询标识符
---@param szQuery string SQL查询字符串
function DB.QueryDS(iPlayerIndex, iQueryNumber, szQuery) end

---@param iPlayerIndex integer 玩家索引
---@param iQueryNumber integer 查询标识符
---@param szQuery string SQL查询字符串
function DB.QueryJS(iPlayerIndex, iQueryNumber, szQuery) end

------------------------------------------------------------------
-- Message 命名空间
------------------------------------------------------------------

Message = {}

---@param iPlayerIndex integer 发送者玩家索引（0表示系统）
---@param aTargetIndex integer 目标索引（-1表示所有玩家）
---@param btType integer 消息类型（0=黄金中央，1=蓝色左侧，2=绿色战盟，3=红色左侧）
---@param szMessage string 消息文本
function Message.Send(iPlayerIndex, aTargetIndex, btType, szMessage) end

------------------------------------------------------------------
-- Timer 命名空间
------------------------------------------------------------------

Timer = {}

---@return integer 滴答计数（自启动以来的毫秒数）

---创建一次性定时器（只触发一次）
---@param interval integer 延迟毫秒数
---@param name string 唯一定时器名称（必需）
---@param callback function 要执行的函数
---@param aliveTime? integer 可选的自动移除时间（毫秒），-1表示无限制
---@return integer 定时器ID（错误返回-1）
function Timer.Create(interval, name, callback, aliveTime) end

---创建重复定时器（按固定间隔触发）
---@param interval integer 间隔毫秒数
---@param name string 唯一定时器名称（必需）
---@param callback function 要执行的函数
---@param aliveTime? integer 可选的自动移除时间（毫秒），-1表示无限制
---@return integer 定时器ID（错误返回-1）
function Timer.CreateRepeating(interval, name, callback, aliveTime) end

---创建触发N次后自动移除的定时器
---@param interval integer 间隔毫秒数
---@param name string 唯一定时器名称（必需）
---@param count integer 触发次数（必须>0）
---@param callback function 回调函数接收(currentCount, maxCount)
---@return integer 定时器ID（错误返回-1）
function Timer.RepeatNTimes(interval, name, count, callback) end

---根据ID移除定时器
---@param timerId integer 定时器ID
---@return boolean 如果成功则返回true
function Timer.Remove(timerId) end

---根据名称移除定时器
---@param name string 定时器名称
---@return boolean 如果成功则返回true
function Timer.RemoveByName(name) end

---根据ID检查定时器是否存在
---@param timerId integer 定时器ID
---@return boolean 如果存在则返回true
function Timer.Exists(timerId) end

---根据名称检查定时器是否存在
---@param name string 定时器名称
---@return boolean 如果存在则返回true
function Timer.ExistsByName(name) end

---启动或重启已停止的定时器
---@param timerId integer 定时器ID
---@return boolean 如果成功则返回true
function Timer.Start(timerId) end

---停止运行中的定时器（可重新启动）
---@param timerId integer 定时器ID
---@return boolean 如果成功则返回true
function Timer.Stop(timerId) end

---检查定时器当前是否在运行
---@param timerId integer 定时器ID
---@return boolean 如果在运行则返回true
function Timer.IsActive(timerId) end

---获取距离下次触发的剩余时间
---@param timerId integer 定时器ID
---@return integer 剩余毫秒数（无效返回-1）
function Timer.GetRemaining(timerId) end

function Timer.GetTick() end

------------------------------------------------------------------
-- ActionTick 命名空间
------------------------------------------------------------------

ActionTick = {}

---@param iPlayerIndex integer 玩家索引
---@param iTimerIndex integer 定时器索引（0-2）
---@return integer 滴答计数值
function ActionTick.Get(iPlayerIndex, iTimerIndex) end

---@param iPlayerIndex integer 玩家索引
---@param iTimerIndex integer 定时器索引（0-2）
---@param tickValue integer 要设置的滴答值
---@param timerName string|nil 可选的定时器名称
---@return boolean 如果成功则返回true
function ActionTick.Set(iPlayerIndex, iTimerIndex, tickValue, timerName) end

---@param iPlayerIndex integer 玩家索引
---@param iTimerIndex integer 定时器索引（0-2）
---@return string 定时器名称
function ActionTick.GetName(iPlayerIndex, iTimerIndex) end

---@param iPlayerIndex integer 玩家索引
---@param iTimerIndex integer 定时器索引（0-2）
---@return boolean 如果成功则返回true
function ActionTick.Clear(iPlayerIndex, iTimerIndex) end

------------------------------------------------------------------
-- Scheduler 命名空间
------------------------------------------------------------------

Scheduler = {}

---@param szXmlEventFileName string XML事件文件名
---@return boolean 如果成功则返回true
function Scheduler.LoadFromXML(szXmlEventFileName) end

---@return integer 已加载的事件数量
function Scheduler.GetEventCount() end

---@param currentTick integer 当前滴答计数
function Scheduler.CheckEventNotices(currentTick) end

---@param currentTick integer 当前滴答计数
function Scheduler.CheckEventStarts(currentTick) end

---@param currentTick integer 当前滴答计数
function Scheduler.CheckEventEnds(currentTick) end

---@param iEventId integer 事件ID
---@return string 事件名称
function Scheduler.GetEventName(iEventId) end

---@return boolean 如果有任何事件使用秒级精度则返回true
function Scheduler.HasSecondPrecisionEvents() end

------------------------------------------------------------------

---检查事件当前是否正在运行
---@param eventType integer 事件类型ID
---@return boolean 如果事件活跃则返回true
function Scheduler.IsEventActive(eventType) end

---获取事件开始后经过的时间（秒）
---@param eventType integer 事件类型ID
---@return integer 经过的秒数（如果不活跃返回-1）
function Scheduler.GetElapsedTime(eventType) end

---获取事件结束前的剩余时间（秒）
---@param eventType integer 事件类型ID
---@return integer 剩余秒数（如果不活跃或无持续时间返回-1）
function Scheduler.GetRemainingTime(eventType) end

---获取事件进度百分比（0-100）
---@param eventType integer 事件类型ID
---@return integer 进度百分比（如果不活跃或无持续时间返回-1）
function Scheduler.GetProgress(eventType) end

-- Utility 命名空间
------------------------------------------------------------------

Utility = {}

---@param iValue integer 最大值（包含）
---@return integer 0到iValue之间的随机值
function Utility.GetRandomRangedInt(min, max) end

---@return integer 大随机数
function Utility.GetLargeRand() end

---@param iPlayerIndex integer 玩家索引
function Utility.FireCracker(iPlayerIndex) end

---向玩家发送视觉计时器
---@param playerIndex integer 玩家索引
---@param milliseconds integer 计时器持续时间（毫秒）
---@param countUp integer 0=倒计时，1=正计时
---@param displayType integer 文本类型（0=无，1=时间限制，2=剩余，3=狩猎，5=生存）
---@param deleteTimer integer 0=显示计时器，1=移除计时器
function Utility.SendEventTimer(playerIndex, milliseconds, countUp, displayType, deleteTimer) end

------------------------------------------------------------------
-- ItemBag 命名空间
------------------------------------------------------------------

ItemBag = {}

---使用物品包给玩家发放物品
---@param playerIndex integer 玩家索引
---@param bagType integer 物品包类型（使用Enums.ItemBagType）
---@param param1 integer 取决于物品包类型
---@param param2 integer 取决于物品包类型
function ItemBag.Use(playerIndex, bagType, param1, param2) end

------------------------------------------------------------------
-- Log 命名空间
------------------------------------------------------------------

Log = {}

---@param szLog string 日志消息
function Log.Add(szLog) end

---@param dwLogColor integer 日志颜色（DWORD）
---@param szLog string 日志消息
function Log.AddC(dwLogColor, szLog) end

------------------------------------------------------------------
-- Helpers 命名空间
------------------------------------------------------------------

Helpers = {}

---@param r integer 红色分量（0-255）
---@param g integer 绿色分量（0-255）
---@param b integer 蓝色分量（0-255）
---@return integer DWORD颜色值（Windows COLORREF）
function Helpers.RGB(r, g, b) end

---@param ItemType integer 物品类型/分组（0-15）
---@param ItemIndex integer 分组内的物品索引（0-511）
---@return integer ItemId
function Helpers.MakeItemId(ItemType, ItemIndex) end

---@param ItemId integer 物品ID
---@return integer 物品类型（0-15）
function Helpers.GetItemType(ItemId) end

---@param ItemId integer 物品ID
---@return integer 物品索引（0-511）
function Helpers.GetItemIndex(ItemId) end
------------------------------------------------------------------
-- Language 命名空间
------------------------------------------------------------------

Language = {}

---从语言文件获取本地化文本
---@param iLangID integer 语言代码（oPlayer.LangCode）
---@param iTextType integer 文本类型（Enums.eLANGUAGE_TEXT_TYPE）
---@param iTextID integer 语言文件中的文本ID
---@return string 本地化文本，未找到返回空字符串
function Language.GetText(iLangID, iTextType, iTextID) end

------------------------------------------------------------------
-- EventMonsterTracker 命名空间
------------------------------------------------------------------

EventMonsterTracker = {}

---将对象注册到事件跟踪
---@param iEventType integer 事件类型ID
---@param iObjectIndex integer 对象索引
---@param iObjectClass integer 怪物/NPC职业ID
---@param iObjectType integer 对象类型（Enums.ObjectType: 2=怪物，3=NPC）
function EventMonsterTracker.Register(iEventType, iObjectIndex, iObjectClass, iObjectType) end

---从事件跟踪中注销对象
---@param iEventType integer 事件类型ID
---@param iObjectIndex integer 对象索引
---@return boolean 如果已注销则返回true，未找到返回false
function EventMonsterTracker.Unregister(iEventType, iObjectIndex) end

---检查对象是否被事件跟踪
---@param iEventType integer 事件类型ID
---@param iObjectIndex integer 对象索引
---@return boolean 如果被跟踪则返回true
function EventMonsterTracker.IsTracked(iEventType, iObjectIndex) end

---获取存储的对象信息
---@param iEventType integer 事件类型ID
---@param iObjectIndex integer 对象索引
---@return TrackedObjectData 对象数据（未找到时class=-1, type=-1）
function EventMonsterTracker.GetObjectInfo(iEventType, iObjectIndex) end

---获取存储的对象职业
---@param iEventType integer 事件类型ID
---@param iObjectIndex integer 对象索引
---@return integer 怪物/NPC职业ID，未找到返回-1
function EventMonsterTracker.GetMonsterClass(iEventType, iObjectIndex) end

---获取事件跟踪的所有对象索引
---@param iEventType integer 事件类型ID
---@param iFilterType? integer 可选过滤器：-1=全部（默认），2=怪物，3=NPC
---@return table 对象索引数组
function EventMonsterTracker.GetMonsters(iEventType, iFilterType) end

---获取跟踪对象的数量
---@param iEventType integer 事件类型ID
---@param iFilterType? integer 可选过滤器：-1=全部（默认），2=怪物，3=NPC
---@return integer 跟踪对象数量
function EventMonsterTracker.GetCount(iEventType, iFilterType) end

---清理事件的对象（删除并取消跟踪）
---@param iEventType integer 事件类型ID
---@param iFilterType? integer 可选过滤器：-1=全部（默认），2=怪物，3=NPC
---@return integer 移除的对象数量
function EventMonsterTracker.CleanupEvent(iEventType, iFilterType) end

---仅清理事件的怪物
---@param iEventType integer 事件类型ID
---@return integer 移除的怪物数量
function EventMonsterTracker.CleanupMonsters(iEventType) end

---仅清理事件的NPC
---@param iEventType integer 事件类型ID
---@return integer 移除的NPC数量
function EventMonsterTracker.CleanupNPCs(iEventType) end

---从跟踪中清理死亡对象（不删除它们）
---@param iEventType integer 事件类型ID
---@param iFilterType? integer 可选过滤器：-1=全部（默认），2=怪物，3=NPC
---@return integer 从跟踪中移除的对象数量
function EventMonsterTracker.CleanupDead(iEventType, iFilterType) end

---获取活跃的事件类型
---@return table 事件类型ID数组
function EventMonsterTracker.GetActiveEvents() end

---清除所有跟踪数据
---@return integer 清除的事件数量
function EventMonsterTracker.ClearAll() end

---生成单个怪物并注册到跟踪
---@param iEventType integer 事件类型ID
---@param iMonsterClass integer 怪物职业ID
---@param iMapNumber integer 地图编号
---@param iX1 integer 生成区域起始X
---@param iY1 integer 生成区域起始Y
---@param iX2 integer 生成区域结束X
---@param iY2 integer 生成区域结束Y
---@param iElement integer 元素属性（0=无）
---@return integer 怪物对象索引，失败返回-1
function EventMonsterTracker.SpawnAndRegister(iEventType, iMonsterClass, iMapNumber, iX1, iY1, iX2, iY2, iElement) end

---生成一波怪物并将所有怪物注册到跟踪
---@param iEventType integer 事件类型ID
---@param iMonsterClass integer 怪物职业ID
---@param iCount integer 要生成的怪物数量
---@param iMapNumber integer 地图编号
---@param iX1 integer 生成区域起始X
---@param iY1 integer 生成区域起始Y
---@param iX2 integer 生成区域结束X
---@param iY2 integer 生成区域结束Y
---@param iElement integer 元素属性（0=无）
---@return table 生成的怪物索引数组
function EventMonsterTracker.SpawnWaveAndRegister(iEventType, iMonsterClass, iCount, iMapNumber, iX1, iY1, iX2, iY2, iElement) end

---注册现有NPC到跟踪
---@param iEventType integer 事件类型ID
---@param iNpcIndex integer NPC对象索引
---@param iNpcClass integer NPC职业ID
function EventMonsterTracker.RegisterNPC(iEventType, iNpcIndex, iNpcClass) end

