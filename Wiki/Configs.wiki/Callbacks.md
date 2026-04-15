# 事件回调参考

游戏服务器事件触发的所有事件回调函数的完整参考。

---

## 目录

- [回调类型](#回调类型)
- [连接和认证](#连接和认证)
- [服务器生命周期](#服务器生命周期)
- [仓库事件](#仓库事件)
- [特殊活动入口](#特殊活动入口)
- [玩家进度](#玩家进度)
- [命令处理](#命令处理)
- [NPC 交互](#npc-交互)
- [物品栏管理](#物品栏管理)
- [物品获取](#物品获取)
- [装备事件](#装备事件)
- [物品修理](#物品修理)
- [地图和移动](#地图和移动)
- [战斗和死亡](#战斗和死亡)
- [商店和交易](#商店和交易)
- [数据库查询](#数据库查询)

---

## 回调类型

**同步（Sync）：**
- 在 C++ 事件流中同步执行
- 可以返回值以影响游戏逻辑
- 可以阻止/允许操作
- 必须快速完成以避免阻塞

**异步（Async）：**
- 在事件后异步执行
- 无法返回值
- 无法阻止操作
- 用于日志、通知、自定义逻辑

---

## 连接和认证

### onCharacterSelectEnter

```lua
function onCharacterSelectEnter(oPlayer)
```

**类型：** 异步

**调用时机：** 玩家进入角色选择屏幕时

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `oPlayer` | object (stObject) | 进入角色选择的玩家对象 |

**用法：**
```lua
function onCharacterSelectEnter(oPlayer)
    if oPlayer ~= nil then
        Log.Add(string.format("玩家进入角色选择: %s", oPlayer.Name))
    end
end
```

---

### onPlayerConnect

```lua
function onPlayerConnect(oPlayer)
```

**类型：** 异步

**调用时机：** 玩家成功连接到游戏服务器时

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `oPlayer` | object (stObject) | 连接的玩家对象 |

**用法：**
```lua
function onPlayerConnect(oPlayer)
    if oPlayer ~= nil then
        Log.Add(string.format("玩家已连接: %s, IP: %s", oPlayer.Name, oPlayer.IP))
        Message.Send(0, oPlayer.Index, 1, "欢迎来到服务器!")
    end
end
```

---

### onPlayerLogin

```lua
function onPlayerLogin(oPlayer)
```

**类型：** 异步

**调用时机：** 玩家登录角色时

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `oPlayer` | object (stObject) | 登录的玩家对象 |

**用法：**
```lua
function onPlayerLogin(oPlayer)
    if oPlayer ~= nil then
        Log.Add(string.format("%s 已登录 - 等级 %d", oPlayer.Name, oPlayer.Level))
        
        -- 奖励每日登录奖励
        if CheckDailyLogin(oPlayer.Index) then
            Player.SetMoney(oPlayer.Index, 100000, false)
            Message.Send(0, oPlayer.Index, 0, "每日登录奖励: 100,000 zen!")
        end
    end
end
```

---

### onPlayerDisconnect

```lua
function onPlayerDisconnect(oPlayer)
```

**类型：** 异步

**调用时机：** 玩家断开服务器连接时

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `oPlayer` | object (stObject) | 断开的玩家对象 |

**用法：**
```lua
function onPlayerDisconnect(oPlayer)
    if oPlayer ~= nil then
        Log.Add(string.format("玩家已断开: %s", oPlayer.Name))
        
        -- 清理玩家专用数据
        ClearPlayerTimers(oPlayer.Index)
        RemoveFromActiveEvents(oPlayer.Index)
    end
end
```

---

## 服务器生命周期

### onGameServerStart

```lua
function onGameServerStart()
```

**类型：** 异步

**调用时机：** 游戏服务器启动时

**参数：** 无

**用法：**
```lua
function onGameServerStart()
    Log.Add("=== 游戏服务器已启动 ===")
    Log.Add(string.format("服务器: %s (代码: %d)", Server.GetName(), Server.GetCode()))
    Log.Add(string.format("最大玩家数: %d", Object.GetMaxOnlineUser()))
    
    -- 初始化服务器级系统
    InitializeEventScheduler()
    LoadItemBags()
    StartGlobalTimers()
end
```

---


### onDisconnectAllPlayers

```lua
function onDisconnectAllPlayers()
```

**类型：** 异步

**调用时机：** 服务器发起强制关闭时（立即断开所有玩家）

**参数：** 无

**用法：**
```lua
function onDisconnectAllPlayers()
    Log.Add("[服务器] 强制关闭已发起 - 正在断开所有玩家")
    
    -- 保存任何待处理的数据
    SaveServerState()
    
    -- 记录关闭事件
    Database.LogEvent("SERVER_FORCED_SHUTDOWN", os.date("%Y-%m-%d %H:%M:%S"))
end
```

---

### onLogOutAllPlayers

```lua
function onLogOutAllPlayers()
```

**类型：** 异步

**调用时机：** 服务器发起正常关闭时（请求所有玩家登出）

**参数：** 无

**用法：**
```lua
function onLogOutAllPlayers()
    Log.Add("[服务器] 正常关闭已发起 - 正在请求所有玩家登出")
    
    -- 通知所有玩家
    Message.Send(0, -1, 1, "服务器将在 5 分钟后维护。请安全登出。")
    
    -- 保存所有角色数据
    for player in Object.Iterator(Object.IteratorType.PLAYER) do
        if player ~= nil then
            Database.SaveCharacter(player.Index)
        end
    end
end
```

---

### onDisconnectAllPlayersWithReconnect

```lua
function onDisconnectAllPlayersWithReconnect()
```

> ⚠️ **s6 不可用** — 此回调在 s6 版本中不存在。

**类型：** 异步

**调用时机：** 服务器发起重启时（断开玩家但允许重连）

**参数：** 无

**用法：**
```lua
function onDisconnectAllPlayersWithReconnect()
    Log.Add("[服务器] 服务器重启已发起 - 玩家可以重连")
    
    -- 通知玩家关于重启
    Message.Send(0, -1, 1, "服务器正在重启。2 分钟后可以重连。")
    
    -- 记录重启事件及时间戳
    Database.LogEvent("SERVER_RESTART", os.date("%Y-%m-%d %H:%M:%S"))
    
    -- 保存重启标志用于重启后处理
    Server.SetCustomValue("last_restart_time", os.time())
end
```

---

## 仓库事件

### onOpenWarehouse

```lua
function onOpenWarehouse(oPlayer)
```

**类型：** 异步

**调用时机：** 玩家打开仓库时

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `oPlayer` | object (stObject) | 打开仓库的玩家 |

**用法：**
```lua
function onOpenWarehouse(oPlayer)
    if oPlayer ~= nil then
        Log.Add(string.format("%s 打开了仓库", oPlayer.Name))
        
        -- 检查 VIP 福利
        if oPlayer.userData.VIPType > 0 then
            Message.Send(0, oPlayer.Index, 0, "VIP: 扩展仓库空间已启用")
        end
    end
end
```

---

### onCloseWarehouse

```lua
function onCloseWarehouse(oPlayer)
```

**类型：** 异步

**调用时机：** 玩家关闭仓库时

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `oPlayer` | object (stObject) | 关闭仓库的玩家 |

**用法：**
```lua
function onCloseWarehouse(oPlayer)
    if oPlayer ~= nil then
        Log.Add(string.format("%s 关闭了仓库", oPlayer.Name))
    end
end
```

---

## 特殊活动入口

### onBloodCastleEnter

```lua
function onBloodCastleEnter(oPlayer, EventLevel)
```

**类型：** 异步

**调用时机：** 玩家进入血色城堡活动时

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `oPlayer` | object (stObject) | 进入活动的玩家 |
| `EventLevel` | int | 血色城堡等级 (1-8) |

**用法：**
```lua
function onBloodCastleEnter(oPlayer, EventLevel)
    if oPlayer ~= nil then
        Log.Add(string.format("%s 进入了血色城堡 %d", oPlayer.Name, EventLevel))
        Message.Send(0, oPlayer.Index, 1, string.format("血色城堡 %d - 祝你好运!", EventLevel))
    end
end
```

---

### onChaosCastleEnter

```lua
function onChaosCastleEnter(oPlayer, EventLevel)
```

**类型：** 异步

**调用时机：** 玩家进入赤色要塞活动时

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `oPlayer` | object (stObject) | 进入活动的玩家 |
| `EventLevel` | int | 赤色要塞等级 (1-7) |

**用法：**
```lua
function onChaosCastleEnter(oPlayer, EventLevel)
    if oPlayer ~= nil then
        Log.Add(string.format("%s 进入了赤色要塞 %d", oPlayer.Name, EventLevel))
    end
end
```

---

### onDevilSquareEnter

```lua
function onDevilSquareEnter(oPlayer, EventLevel)
```

**类型：** 异步

**调用时机：** 玩家进入恶魔广场活动时

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `oPlayer` | object (stObject) | 进入活动的玩家 |
| `EventLevel` | int | 恶魔广场等级 (1-7) |

**用法：**
```lua
function onDevilSquareEnter(oPlayer, EventLevel)
    if oPlayer ~= nil then
        Log.Add(string.format("%s 进入了恶魔广场 %d", oPlayer.Name, EventLevel))
    end
end
```

---

## 玩家进度

### onPlayerLevelUp

```lua
function onPlayerLevelUp(oPlayer)
```

> ⚠️ **s6 不可用** — 此回调在 s6 版本中不存在。

**类型：** 异步

**调用时机：** 玩家升级时

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `oPlayer` | object (stObject) | 升级的玩家 |

**用法：**
```lua
function onPlayerLevelUp(oPlayer)
    if oPlayer ~= nil then
        Log.Add(string.format("%s 达到等级 %d", oPlayer.Name, oPlayer.Level))
        
        -- 奖励等级里程碑
        if oPlayer.Level == 400 then
            Message.Send(0, -1, 1, string.format("%s 达到 400 级!", oPlayer.Name))
            Player.SetMoney(oPlayer.Index, 10000000, false)
        end
    end
end
```

---

### onPlayerMasterLevelUp

```lua
function onPlayerMasterLevelUp(oPlayer)
```

**类型：** 异步

**调用时机：** 玩家获得大师等级时

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `oPlayer` | object (stObject) | 获得大师等级的玩家 |

**用法：**
```lua
function onPlayerMasterLevelUp(oPlayer)
    if oPlayer ~= nil then
        local mlevel = oPlayer.userData.MasterLevel
        Log.Add(string.format("%s 达到大师等级 %d", oPlayer.Name, mlevel))
        
        if mlevel == 200 then
            Message.Send(0, -1, 1, string.format("%s 达到 ML 200!", oPlayer.Name))
        end
    end
end
```

---

### onUseCommand

```lua
function onUseCommand(oPlayer, szCmd)
```

**类型：** 同步（可以阻止命令执行）

**调用时机：** 玩家输入命令时（任何以 `/` 开头的字符串）

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `oPlayer` | object (stObject) | 输入命令的玩家 |
| `szCmd` | string | 完整命令字符串，与输入一致，包含前导 `/`（例如 `"/post Hello World"`） |

**返回值：**

| Return | Effect |
|--------|--------|
| `1` | 阻止命令 — C++ 停止处理它 |
| `0` 或 `nil` | 允许命令 — C++ 继续正常执行 |

**注意事项：**
- `szCmd` 是原始字符串。使用 Lua 中的 `string.gmatch(szCmd, "%S+")` 将其拆分。
- 第一部分（`parts[1]`）是包含 `/` 前缀的命令名称。
- 剩余部分是按顺序的参数。

**用法：**
```lua
function onUseCommand(oPlayer, szCmd)
	if oPlayer == nil then return 0 end

	-- 拆分为部分: "/post Hello World" -> {"/post", "Hello", "World"}
	local parts = {}
	for part in string.gmatch(szCmd, "%S+") do
		table.insert(parts, part)
	end

	local cmd = parts[1] or ""

	-- 示例: 自定义 /online 命令
	if cmd == "/online" then
		local count = 0
		Object.ForEachPlayer(function(oP)
			count = count + 1
			return true
		end)
		Message.Send(0, oPlayer.Index, 0, string.format("在线玩家: %d", count))
		return 1  -- 阻止默认处理器

	-- 示例: 阻止非 GM 玩家使用 /move
	elseif cmd == "/move" then
		if oPlayer.GameMaster == 0 then
			Message.Send(0, oPlayer.Index, 0, "你没有权限使用该命令。")
			Log.Add(string.format("[命令] %s 尝试使用 %s", oPlayer.Name, szCmd))
			return 1  -- 阻止
		end
	end

	return 0  -- 允许所有其他命令
end
```

---

### onPlayerReset

```lua
function onPlayerReset(oPlayer)
```

> ⚠️ **s6 不可用** — 此回调在 s6 版本中不存在。

**类型：** 同步

**调用时机：** 玩家执行角色转生时

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `oPlayer` | object (stObject) | 执行转生的玩家 |

**用法：**
```lua
function onPlayerReset(oPlayer)
    if oPlayer ~= nil then
        local resets = oPlayer.userData.Resets + 1
        Log.Add(string.format("%s 执行了第 %d 次转生", oPlayer.Name, resets))
        
        -- 奖励转生
        Message.Send(0, oPlayer.Index, 1, string.format("第 %d 次转生完成!", resets))
    end
end
```

---

## NPC 交互

### onNpcTalk

```lua
function onNpcTalk(oPlayer, oNpc)
```

**类型：** 同步

**调用时机：** 玩家与 NPC 对话时

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `oPlayer` | object (stObject) | 与 NPC 对话的玩家 |
| `oNpc` | object (stObject) | NPC 对象（与玩家/怪物结构相同） |

**返回值：**

| Return | Effect |
|--------|--------|
| `1` | 停止处理后续 C++ 代码 |
| `0` 或 `nil` | 允许命令 — C++ 继续正常执行 |

**用法：**
```lua
function onNpcTalk(oPlayer, oNpc)
    if oPlayer ~= nil and oNpc ~= nil then
        Log.Add(string.format("%s 与 NPC %d 对话", oPlayer.Name, oNpc.Class))
        
        -- 自定义 NPC 对话
        if oNpc.Class == 257 then  -- 自定义 NPC
            Message.Send(0, oPlayer.Index, 0, "欢迎来到我的商店!")
        end
    end
    return 0
end
```

---

### onCloseWindow

```lua
function onCloseWindow(oPlayer)
```

**类型：** 同步

**调用时机：** 玩家通过关闭 NPC 窗口结束对话时

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `oPlayer` | object (stObject) | 与 NPC 对话的玩家 |

**返回值：**

| Return | Effect |
|--------|--------|
| `1` | 停止处理后续 C++ 代码 |
| `0` 或 `nil` | 允许命令 — C++ 继续正常执行 |

**用法：**
```lua
function onCloseWindow(oPlayer)
    if oPlayer ~= nil then
        
    end
    return 0
end
```

---

## 物品栏管理

### onItemUse

```lua
function onItemUse(iResult, oPlayer, oItem, iItemSourcePos, iItemTargetPos)
```

**类型：** 同步

**调用时机：** 玩家使用右键可点击物品时

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `iResult` | int | 使用结果（-1 = 错误并解锁物品栏，1 = 成功并停止 C++ 代码执行，0 = 成功并继续 C++ 代码执行） |
| `oPlayer` | object (stObject) | 移动物品的玩家 |
| `oItem` | object (stItemInfo) | 被点击的物品 |
| `iItemSourcePos` | int | 源物品栏槽位 |
| `iItemTargetPos` | int | 目标物品栏槽位 |

### onInventoryMoveItem

```lua
function onInventoryMoveItem(oPlayer, iItemSourcePos, iItemTargetPos, btResult)
```

**类型：** 异步

**调用时机：** 玩家在主物品栏中移动物品时

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `oPlayer` | object (stObject) | 移动物品的玩家 |
| `iItemSourcePos` | int | 源物品栏槽位 |
| `iItemTargetPos` | int | 目标物品栏槽位 |
| `btResult` | int | 移动结果（1 = 成功，0 = 失败） |

**用法：**
```lua
function onInventoryMoveItem(oPlayer, iItemSourcePos, iItemTargetPos, btResult)
    if oPlayer ~= nil and btResult == 1 then
        Log.Add(string.format("%s 将物品从槽位 %d 移动到 %d", 
            oPlayer.Name, iItemSourcePos, iItemTargetPos))
    end
end
```

---

### onEventInventoryMoveItem

```lua
function onEventInventoryMoveItem(oPlayer, iItemSourcePos, iItemTargetPos, btResult)
```

> ⚠️ **s6 不可用** — 此回调在 s6 版本中不存在。

**类型：** 异步

**调用时机：** 玩家在事件物品栏中移动物品时

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `oPlayer` | object (stObject) | 移动物品的玩家 |
| `iItemSourcePos` | int | 源事件物品栏槽位 |
| `iItemTargetPos` | int | 目标事件物品栏槽位 |
| `btResult` | int | 移动结果（1 = 成功，0 = 失败） |

**用法：**
```lua
function onEventInventoryMoveItem(oPlayer, iItemSourcePos, iItemTargetPos, btResult)
    if oPlayer ~= nil and btResult == 1 then
        Log.Add(string.format("%s 移动事件物品 %d -> %d", 
            oPlayer.Name, iItemSourcePos, iItemTargetPos))
    end
end
```

---

### onMuunInventoryMoveItem

```lua
function onMuunInventoryMoveItem(oPlayer, iItemSourcePos, iItemTargetPos, btResult)
```

> ⚠️ **s6 不可用** — 此回调在 s6 版本中不存在。

**类型：** 异步

**调用时机：** 玩家在物品栏中移动 Muun 物品时

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `oPlayer` | object (stObject) | 移动 Muun 物品的玩家 |
| `iItemSourcePos` | int | 源 Muun 物品栏槽位 |
| `iItemTargetPos` | int | 目标 Muun 物品栏槽位 |
| `btResult` | int | 移动结果（1 = 成功，0 = 失败） |

**用法：**
```lua
function onMuunInventoryMoveItem(oPlayer, iItemSourcePos, iItemTargetPos, btResult)
    if oPlayer ~= nil and btResult == 1 then
        Log.Add(string.format("%s 移动 Muun 物品 %d -> %d", 
            oPlayer.Name, iItemSourcePos, iItemTargetPos))
    end
end
```

---

## 物品获取

### onItemGet

```lua
function onItemGet(oPlayer, sItemType, sItemLevel, btItemDur, btItemElement)
```

**类型：** 异步

**调用时机：** 玩家从地上捡起物品时

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `oPlayer` | object (stObject) | 捡起物品的玩家 |
| `sItemType` | short | 物品类型 ID |
| `sItemLevel` | short | 物品等级 |
| `btItemDur` | BYTE | 物品耐久度 |
| `btItemElement` | BYTE | 物品元素类型 |

**用法：**
```lua
function onItemGet(oPlayer, sItemType, sItemLevel, btItemDur, btItemElement)
    if oPlayer ~= nil then
        local itemAttr = Item.GetAttr(sItemType)
        if itemAttr ~= nil then
            local itemName = itemAttr:GetName()
            Log.Add(string.format("%s 捡起了: %s +%d", 
                oPlayer.Name, itemName, sItemLevel))
        end
    end
end
```

---

### onEventItemGet

```lua
function onEventItemGet(oPlayer, sItemType, sItemLevel, btItemDur, btItemElement)
```

> ⚠️ **s6 不可用** — 此回调在 s6 版本中不存在。

**类型：** 异步

**调用时机：** 玩家获得活动物品时

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `oPlayer` | object (stObject) | 获得物品的玩家 |
| `sItemType` | short | 物品类型 ID |
| `sItemLevel` | short | 物品等级 |
| `btItemDur` | BYTE | 物品耐久度 |
| `btItemElement` | BYTE | 物品元素类型 |

**用法：**
```lua
function onEventItemGet(oPlayer, sItemType, sItemLevel, btItemDur, btItemElement)
    if oPlayer ~= nil then
        Log.Add(string.format("%s 获得了活动物品: %d +%d", 
            oPlayer.Name, sItemType, sItemLevel))
    end
end
```

---

### onMuunItemGet

```lua
function onMuunItemGet(oPlayer, sItemType, sItemLevel, btItemDur, btItemElement)
```

> ⚠️ **s6 不可用** — 此回调在 s6 版本中不存在。

**类型：** 异步

**调用时机：** 玩家获得 Muun 物品时

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `oPlayer` | object (stObject) | 获得 Muun 的玩家 |
| `sItemType` | short | 物品类型 ID |
| `sItemLevel` | short | 物品等级 |
| `btItemDur` | BYTE | 物品耐久度 |
| `btItemElement` | BYTE | 物品元素类型 |

**用法：**
```lua
function onMuunItemGet(oPlayer, sItemType, sItemLevel, btItemDur, btItemElement)
    if oPlayer ~= nil then
        Log.Add(string.format("%s 获得了 Muun: %d +%d", 
            oPlayer.Name, sItemType, sItemLevel))
    end
end
```

---

## 装备事件

### onItemEquip

```lua
function onItemEquip(oPlayer, iItemSourcePos, iItemTargetPos, btResult)
```

**类型：** 异步

**调用时机：** 玩家装备物品时

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `oPlayer` | object (stObject) | 装备物品的玩家 |
| `iItemSourcePos` | int | 源物品栏槽位 |
| `iItemTargetPos` | int | 目标装备槽位 |
| `btResult` | int | 装备结果（1 = 成功，0 = 失败） |

**用法：**
```lua
function onItemEquip(oPlayer, iItemSourcePos, iItemTargetPos, btResult)
    if oPlayer ~= nil and btResult == 1 then
        local item = oPlayer:GetInventoryItem(iItemTargetPos)
        if item ~= nil then
            Log.Add(string.format("%s 在槽位 %d 装备了物品", 
                oPlayer.Name, iItemTargetPos))
            
            -- 装备改变后重新计算属性
            Player.ReCalc(oPlayer.Index)
        end
    end
end
```

---

### onItemUnEquip

```lua
function onItemUnEquip(oPlayer, iItemSourcePos, iItemTargetPos, btResult)
```

**类型：** 异步

**调用时机：** 玩家卸下装备时

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `oPlayer` | object (stObject) | 卸下装备的玩家 |
| `iItemSourcePos` | int | 源装备槽位 |
| `iItemTargetPos` | int | 目标物品栏槽位 |
| `btResult` | int | 卸下结果（1 = 成功，0 = 失败） |

**用法：**
```lua
function onItemUnEquip(oPlayer, iItemSourcePos, iItemTargetPos, btResult)
    if oPlayer ~= nil and btResult == 1 then
        Log.Add(string.format("%s 从槽位 %d 卸下了物品", 
            oPlayer.Name, iItemSourcePos))
        
        -- 重新计算属性
        Player.ReCalc(oPlayer.Index)
    end
end
```

---

## 物品修理

### onItemRepair

```lua
function onItemRepair(oPlayer, oItem)
```

**类型：** 异步

**调用时机：** 玩家在 NPC 处修理物品时

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `oPlayer` | object (stObject) | 修理物品的玩家 |
| `oItem` | object (ItemInfo) | 被修理的物品 |

**用法：**
```lua
function onItemRepair(oPlayer, oItem)
    if oPlayer ~= nil and oItem ~= nil then
        local itemAttr = Item.GetAttr(oItem.Type)
        if itemAttr ~= nil then
            local itemName = itemAttr:GetName()
            Log.Add(string.format("%s 修理了: %s", oPlayer.Name, itemName))
        end
    end
end
```

---

## 地图和移动

### onCharacterJoinMap

```lua
function onCharacterJoinMap(oPlayer)
```

**类型：** 异步

**调用时机：** 玩家在登录或传送后加入地图时

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `oPlayer` | object (stObject) | 加入地图的玩家 |

**用法：**
```lua
function onCharacterJoinMap(oPlayer)
    if oPlayer ~= nil then
        Log.Add(string.format("%s 加入了地图 %d，位置 (%d, %d)", 
            oPlayer.Name, oPlayer.MapNumber, oPlayer.X, oPlayer.Y))
        
        -- 检查地图特定事件
        if oPlayer.MapNumber == 10 then  -- 天空之城
            Message.Send(0, oPlayer.Index, 0, "欢迎来到 天空之城!")
        end
    end
end
```

---

### onMoveMap

```lua
function onMoveMap(oPlayer, wMapNumber, btPosX, btPosY, iGateNumber)
```

**类型：** 异步

**调用时机：** 玩家在不同地图间移动时

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `oPlayer` | object (stObject) | 移动的玩家 |
| `wMapNumber` | WORD | 目标地图编号 |
| `btPosX` | BYTE | 目标 X 坐标 |
| `btPosY` | BYTE | 目标 Y 坐标 |
| `iGateNumber` | int | 使用的传送门编号（如果不是传送门则为 -1） |

**用法：**
```lua
function onMoveMap(oPlayer, wMapNumber, btPosX, btPosY, iGateNumber)
    if oPlayer ~= nil then
        Log.Add(string.format("%s 移动到地图 %d (%d, %d)，通过传送门 %d", 
            oPlayer.Name, wMapNumber, btPosX, btPosY, iGateNumber))
    end
end
```

---

### onMapTeleport

```lua
function onMapTeleport(oPlayer, iGateNumber)
```

> ⚠️ **s6 不可用** — 此回调在 s6 版本中不存在。当传送门完成**而不进行**完整地图切换（同地图传送门或即时传送）时触发。在 s6 中此代码路径没有 Lua 回调。具有完整地图切换的传送门在 s6 和 s7+ 中都触发 `onMoveMap`。

**类型：** 异步

**调用时机：** 玩家使用地图传送门/入口时

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `oPlayer` | object (stObject) | 使用传送门的玩家 |
| `iGateNumber` | int | 传送门索引 |

**用法：**
```lua
function onMapTeleport(oPlayer, iGateNumber)
    if oPlayer ~= nil then
        Log.Add(string.format("%s 使用了传送门 %d", oPlayer.Name, iGateNumber))
        
        -- 检查传送门冷却
        local lastGateTick = oPlayer.ActionTickCount[1].tick
        if (Timer.GetTick() - lastGateTick) < 5000 then
            Message.Send(0, oPlayer.Index, 0, "传送门冷却: 5 秒")
        else
            ActionTick.Set(oPlayer.Index, 1, Timer.GetTick(), "Gate")
        end
    end
end
```

---

### onTeleport

```lua
function onTeleport(oPlayer, wMapNumber, btPosX, btPosY)
```

**类型：** 异步

**调用时机：** 玩家使用传送命令或物品时

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `oPlayer` | object (stObject) | 传送的玩家 |
| `wMapNumber` | WORD | 目标地图编号 |
| `btPosX` | BYTE | 目标 X 坐标 |
| `btPosY` | BYTE | 目标 Y 坐标 |

**用法：**
```lua
function onTeleport(oPlayer, wMapNumber, btPosX, btPosY)
    if oPlayer ~= nil then
        Log.Add(string.format("%s 传送到地图 %d (%d, %d)", 
            oPlayer.Name, wMapNumber, btPosX, btPosY))
    end
end
```

---

### onTeleportMagicUse

```lua
function onTeleportMagicUse(oPlayer, btPosX, btPosY)
```

**类型：** 异步

**调用时机：** 玩家使用传送魔法技能时

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `oPlayer` | object (stObject) | 使用传送技能的玩家 |
| `btPosX` | BYTE | 目标 X 坐标 |
| `btPosY` | BYTE | 目标 Y 坐标 |

**用法：**
```lua
function onTeleportMagicUse(oPlayer, btPosX, btPosY)
    if oPlayer ~= nil then
        Log.Add(string.format("%s 使用魔法传送到 (%d, %d)", 
            oPlayer.Name, btPosX, btPosY))
    end
end
```

---

## 战斗和死亡

### onCheckUserTarget

```lua
function onCheckUserTarget(oPlayer, oTarget)
```

**类型：** 同步（可以阻止目标锁定）

**调用时机：** 玩家尝试攻击任何目标时 — 另一个玩家（PvP）或怪物

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `oPlayer` | object (stObject) | 攻击的玩家 |
| `oTarget` | object (stObject) | 目标（玩家或怪物） |

**返回值：**

| Return | Effect |
|--------|--------|
| `1`（或任何非零值） | 阻止 — 攻击/目标锁定被拒绝 |
| `0` 或 `nil` | 允许 — 攻击正常进行 |

**注意事项：**
- 在攻击处理**之前**触发，允许完全阻止
- 同时为**玩家对玩家**和**玩家对怪物**触发
- 如果目标索引 `<= 0` 则 `oTarget` 可能为 `nil` — 使用前始终进行 nil 检查
- 检查 `oTarget.Type` 以区分玩家（`Enums.ObjectType.USER`）和怪物（`Enums.ObjectType.MONSTER`）目标

**用法：**
```lua
function onCheckUserTarget(oPlayer, oTarget)
    if oPlayer == nil or oTarget == nil then return 0 end

    -- 仅 PvP: 阻止攻击 50 级以下玩家
    if oTarget.Type == Enums.ObjectType.USER and oTarget.Level < 50 then
        Message.Send(0, oPlayer.Index, 0, "你不能攻击 50 级以下的玩家。")
        return 1
    end

    -- 阻止同公会友军伤害
    if oTarget.Type == Enums.ObjectType.USER and oPlayer.GuildNumber > 0 and oPlayer.GuildNumber == oTarget.GuildNumber then
        Message.Send(0, oPlayer.Index, 0, "你不能攻击公会成员。")
        return 1
    end

    return 0
end
```

---

### onPlayerKill

```lua
function onPlayerKill(oPlayer, oTarget)
```

**类型：** 异步

**调用时机：** 玩家击杀另一个玩家时

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `oPlayer` | object (stObject) | 击杀方玩家 |
| `oTarget` | object (stObject) | 被击杀的玩家 |

**用法：**
```lua
function onPlayerKill(oPlayer, oTarget)
    if oPlayer ~= nil and oTarget ~= nil then
        Log.Add(string.format("%s 击杀了 %s", oPlayer.Name, oTarget.Name))
        
        -- 奖励 PK 点数或惩罚
        Message.Send(0, -1, 0, string.format("%s 击杀了 %s!", 
            oPlayer.Name, oTarget.Name))
    end
end
```

---

### onPlayerDie

```lua
function onPlayerDie(oPlayer, oTarget)
```

**类型：** 异步

**调用时机：** 玩家死亡时

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `oPlayer` | object (stObject) | 死亡的玩家 |
| `oTarget` | Player/Monster | 杀死玩家的对象 |

**用法：**
```lua
function onPlayerDie(oPlayer, oTarget)
    if oPlayer ~= nil then
        if oTarget ~= nil then
            Log.Add(string.format("%s 被 %s 击杀", 
                oPlayer.Name, oTarget.Name or "怪物"))
        else
            Log.Add(string.format("%s 死亡了", oPlayer.Name))
        end
        
        -- 死亡时清除玩家计时器
        for i = 0, 2 do
            ActionTick.Clear(oPlayer.Index, i)
        end
    end
end
```

---

### onPlayerRespawn

```lua
function onPlayerRespawn(oPlayer)
```

**类型：** 异步

**调用时机：** 玩家死亡后重生时

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `oPlayer` | object (stObject) | 重生的玩家 |

**用法：**
```lua
function onPlayerRespawn(oPlayer)
    if oPlayer ~= nil then
        Log.Add(string.format("%s 在地图 %d 重生", 
            oPlayer.Name, oPlayer.MapNumber))
        
        Message.Send(0, oPlayer.Index, 0, "你已重生!")
    end
end
```

---

### onMonsterKill

```lua
function onMonsterKill(oPlayer, oTarget)
```

**类型：** 异步

**调用时机：** 玩家击杀怪物时

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `oPlayer` | object (stObject) | 击杀怪物的玩家 |
| `oTarget` | Monster | 被击杀的怪物 |

**用法：**
```lua
function onMonsterKill(oPlayer, oTarget)
    if oPlayer ~= nil and oTarget ~= nil then
        Log.Add(string.format("%s 击杀了怪物 %d", 
            oPlayer.Name, oTarget.Class))
        
        -- 奖励特定怪物
        if oTarget.Class == 275 then  -- 黄金哥布林
            Player.SetMoney(oPlayer.Index, 1000000, false)
            Message.Send(0, oPlayer.Index, 1, "黄金哥布林奖励: 1kk zen!")
        end
    end
end
```

---

### onMonsterDie

```lua
function onMonsterDie(oPlayer, oTarget)
```

**类型：** 异步

**调用时机：** 怪物死亡时

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `oPlayer` | object (stObject) | 击杀方玩家（可能为 nil） |
| `oTarget` | Monster | 死亡的怪物 |

**用法：**
```lua
function onMonsterDie(oPlayer, oTarget)
    if oTarget ~= nil then
        Log.Add(string.format("怪物 %d 死亡", oTarget.Class))
        
        if oPlayer ~= nil then
            Log.Add(string.format("击杀者: %s", oPlayer.Name))
        end
    end
end
```

---

### onMonsterSpawn

```lua
function onMonsterSpawn(oMonster)
```

> ⚠️ **s6 不可用** — 此回调在 s6 版本中不存在。

**类型：** 异步

**调用时机：** 怪物在地图上生成时

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `oMonster` | object (stObject) | 生成的怪物 |

**用法：**
```lua
function onMonsterSpawn(oMonster)
    if oMonster ~= nil then
        Log.Add(string.format("怪物 %d 在地图 %d 生成", 
            oMonster.Class, oMonster.MapNumber))
    end
end
```

---

### onMonsterRespawn

```lua
function onMonsterRespawn(oMonster)
```

**类型：** 异步

**调用时机：** 怪物死亡后重生时

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `oMonster` | object (stObject) | 重生的怪物 |

**用法：**
```lua
function onMonsterRespawn(oMonster)
    if oMonster ~= nil then
        Log.Add(string.format("怪物 %d 重生", oMonster.Class))
    end
end
```

---

### onUseDurationSkill

```lua
function onUseDurationSkill(oPlayer, aTargetIndex, iSkill, btX, btY, btDir)
```

**类型:** 同步（可以阻止使用技能）

**调用时机:** 玩家使用 duration-based 技能

**参数:**

| Parameter | Type | Description               |
|-----------|------|---------------------------|
| `oPlayer` | object (stObject) | 使用技能的玩家                   |
| `aTargetIndex` | integer | 技能目标编号 |
| `iSkill` | integer | 技能编号                      |
| `btX` | integer | Target X coordinate       |
| `btY` | integer | Target Y coordinate       |
| `btDir` | integer | Direction                 |

**返回:** 返回 非-0 则阻止该技能.

**用法:**
```lua
function onUseDurationSkill(oPlayer, aTargetIndex, iSkill, btX, btY, btDir)
    if oPlayer ~= nil then
        Log.Add(string.format("%s used duration skill %d on target %d", oPlayer.Name, iSkill, aTargetIndex))
    end
    return 0 -- allow
end
```

---

### onUseNormalSkill

```lua
function onUseNormalSkill(oPlayer, oTarget, iSkill)
```

**类型:** 同步（可以阻止使用技能）

**调用时机:** Player uses a normal (instant) skill on a target

**参数:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `oPlayer` | object (stObject) | 使用技能的玩家     |
| `oTarget` | object (stObject) | 技能目标编号      |
| `iSkill` | integer | 技能编号        |

**返回:** 返回 非-0 则阻止该技能.

**用法:**
```lua
function onUseNormalSkill(oPlayer, oTarget, iSkill)
    if oPlayer ~= nil and oTarget ~= nil then
        Log.Add(string.format("%s used skill %d on %s", oPlayer.Name, iSkill, oTarget.Name))
    end
    return 0 -- allow
end
```

---

## Shop & Trading

### onShopBuyItem

```lua
function onShopBuyItem(oPlayer, oItem)
```

**类型：** 同步（可以阻止购买）

**调用时机：** 玩家从 NPC 商店购买物品时

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `oPlayer` | object (stObject) | 购买物品的玩家 |
| `oItem` | object (ItemInfo) | 被购买的物品 |

**用法：**
```lua
function onShopBuyItem(oPlayer, oItem)
    if oPlayer ~= nil and oItem ~= nil then
        local itemAttr = Item.GetAttr(oItem.Type)
        if itemAttr ~= nil then
            local itemName = itemAttr:GetName()
            Log.Add(string.format("%s 购买了: %s", oPlayer.Name, itemName))
        end
    end
end
```

---

### onShopSellItem

```lua
function onShopSellItem(oPlayer, oItem)
```

**类型：** 同步（可以阻止出售）

**调用时机：** 玩家向 NPC 商店出售物品时

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `oPlayer` | object (stObject) | 出售物品的玩家 |
| `oItem` | object (ItemInfo) | 被出售的物品 |

**用法：**
```lua
function onShopSellItem(oPlayer, oItem)
    if oPlayer ~= nil and oItem ~= nil then
        local itemAttr = Item.GetAttr(oItem.Type)
        if itemAttr ~= nil then
            local itemName = itemAttr:GetName()
            Log.Add(string.format("%s 出售了: %s", oPlayer.Name, itemName))
        end
    end
end
```

---

### onShopSellEventItem

```lua
function onShopSellEventItem(oPlayer, oItem)
```

> ⚠️ **s6 不可用** — 此回调在 s6 版本中不存在。

**类型：** 异步

**调用时机：** 玩家向 NPC 出售活动物品时

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `oPlayer` | object (stObject) | 出售活动物品的玩家 |
| `oItem` | object (ItemInfo) | 被出售的活动物品 |

**用法：**
```lua
function onShopSellEventItem(oPlayer, oItem)
    if oPlayer ~= nil and oItem ~= nil then
        Log.Add(string.format("%s 出售了活动物品: %d", 
            oPlayer.Name, oItem.Type))
    end
end
```

---

### onMossMerchantUse

```lua
function onMossMerchantUse(oPlayer, iSectionId)
```

**类型:** 同步 (可以阻止动作)

**调用时机:** Player interacts with 摩斯抽奖

**参数:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `oPlayer` | object (stObject) | Player using Moss |
| `iSectionId` | integer | Section/action ID selected by the player |

**返回:** Return non-zero to block the action.

**用法:**
```lua
function onMossMerchantUse(oPlayer, iSectionId)
    if oPlayer ~= nil then
        Log.Add(string.format("%s used Moss section %d", oPlayer.Name, iSectionId))
    end
    return 0 -- allow
end
```

---

## Database Queries

### onDSDBQueryReceive

```lua
function onDSDBQueryReceive(iUserIndex, iQueryNumber, btIsLastPacket, iCurrentRow, btColumnCount, btCurrentPacket, oRow)
```

**类型：** 异步

**调用时机：** 收到 DataServer 数据库查询结果时

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `iUserIndex` | int | 发起查询的玩家索引 |
| `iQueryNumber` | int | 查询标识符 |
| `btIsLastPacket` | bool | 如果是最后数据包则为 `1`，否则为 `0` |
| `iCurrentRow` | int | 当前处理的行号 |
| `btColumnCount` | int | 结果中的总列数 |
| `btCurrentPacket` | int | 当前数据包编号 |
| `oRow` | object (LuaQueryResultDS) | 查询结果行对象 |

**用法：**
```lua
function onDSDBQueryReceive(iUserIndex, iQueryNumber, btIsLastPacket, iCurrentRow, btColumnCount, btCurrentPacket, oRow)
    if oRow ~= nil then
        local columnName = oRow:GetColumnName()
        local value = oRow:GetValue()
        
        Log.Add(string.format("查询 %d: %s = %s", iQueryNumber, columnName, value))
        
        if btIsLastPacket == 1 then
            Log.Add(string.format("查询 %d 完成", iQueryNumber))
        end
    end
end
```

**参见：** [Database-Structures](Database-Structures.md) 获取详细示例

---

### onJSDBQueryReceive

```lua
function onJSDBQueryReceive(iUserIndex, iQueryNumber, btIsLastPacket, iCurrentRow, btColumnCount, btCurrentPacket, oRow)
```

**类型：** 异步

**调用时机：** 收到 JoinServer 数据库查询结果时

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `iUserIndex` | int | 发起查询的玩家索引 |
| `iQueryNumber` | int | 查询标识符 |
| `btIsLastPacket` | bool | 如果是最后数据包则为 `1`，否则为 `0` |
| `iCurrentRow` | int | 当前处理的行号 |
| `btColumnCount` | int | 结果中的总列数 |
| `btCurrentPacket` | int | 当前数据包编号 |
| `oRow` | object (LuaQueryResultJS) | 查询结果行对象 |

**用法：**
```lua
function onJSDBQueryReceive(iUserIndex, iQueryNumber, btIsLastPacket, iCurrentRow, btColumnCount, btCurrentPacket, oRow)
    if oRow ~= nil then
        local columnName = oRow:GetColumnName()
        local value = oRow:GetValue()
        
        Log.Add(string.format("查询 %d: %s = %s", iQueryNumber, columnName, value))
        
        if btIsLastPacket == 1 then
            Log.Add(string.format("查询 %d 完成", iQueryNumber))
        end
    end
end
```

**参见：** [Database-Structures](Database-Structures.md) 获取详细示例

---

## 最佳实践

### 1. 始终检查 nil

```lua
function onPlayerLogin(oPlayer)
    if oPlayer ~= nil then
        -- 安全访问玩家
    end
end
```

### 2. 同步回调必须快速

```lua
function onShopBuyItem(oPlayer, oItem)
    -- ✅ 快速验证
    if oPlayer == nil or oItem == nil then
        return
    end
    
    -- ❌ 不要进行重处理
    -- ❌ 不要调用数据库查询
    -- ❌ 不要遍历数千个物品
end
```

### 3. 对重操作使用异步

```lua
function onPlayerLogin(oPlayer)
    if oPlayer ~= nil then
        -- ✅ 异步 - 对数据库查询安全
        DB.QueryDS(oPlayer.Index, 1001, 
            string.format("SELECT * FROM CustomData WHERE CharName = '%s'", oPlayer.Name))
    end
end
```

### 4. 断开连接时清理

```lua
function onPlayerDisconnect(oPlayer)
    if oPlayer ~= nil then
        -- 清除计时器
        for i = 0, 2 do
            ActionTick.Clear(oPlayer.Index, i)
        end
        
        -- 从全局表中移除
        g_ActivePlayers[oPlayer.Index] = nil
        g_QuestData[oPlayer.Index] = nil
    end
end
```

### 5. 正确处理数据库结果

```lua
-- 发送查询
function onPlayerLogin(oPlayer)
    DB.QueryDS(oPlayer.Index, 1, string.format("SELECT Level FROM Character WHERE Name = '%s'", oPlayer.Name))
end

-- 处理结果
function onDSDBQueryReceive(iUserIndex, iQueryNumber, btIsLastPacket, iCurrentRow, btColumnCount, btCurrentPacket, oRow)
    if iQueryNumber == 1 and oRow ~= nil then
        local columnName = oRow:GetColumnName()
        local value = oRow:GetValue()
        
        if columnName == "Level" then
            Log.Add(string.format("玩家等级: %s", value))
        end
    end
end
```

---

## 另请参见

- [PLAYER](Player-Structure.md) - 玩家对象结构
- [ITEM](Item-Structures.md) - 物品结构
- [DATABASE](Database-Structures.md) - 数据库查询结构
- [GLOBAL_FUNCTIONS](Global-Functions.md) - 所有服务器函数
