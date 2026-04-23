# IGC Lua System 

> **版本号：21.1.2.10S** | **IGC-Network (R) © 2010-2026** | [www.igcn.mu](https://www.igcn.mu)

---

## TODO-LIST

---

### 1、绝地求生（组队赛）系统

#### 系统概览

| 项目 | 值 |
|---|---|
| 事件名称 | 绝地求生 |
| 地图 | 古战场 (MapNumber = 6) |
| 持续时间 | 10 分钟 |
| 报名时间 | 每晚 19:27 开始报名（提前3分钟入场） |
| 开赛时间 | 19:30 |
| 报名要求 | 400 级以上，对话特定 NPC 或 `/绝地` 命令 |
| 组队 | 最多 3 人/队 |
| 游戏模式 | PvP 生死战，死亡传送回勇者大陆 |
| 胜利条件 | 最后存活的队伍获胜 |
| 世界BOSS | 最后5分钟地图中央刷新世界BOSS，时间结束未击杀则消失 |
| 奖励 | 祝福宝石 (Bless) |

---

#### 核心流程时序

```
19:27:00  EventScheduler触发预告 → 全场广播"绝地求生3分钟后开放报名"
19:27:00  EventScheduler触发开始 → BR.StartSignup()，state=SIGNUP
          玩家通过NPC或命令报名
19:30:00  3分钟倒计时结束 → BR.StartGame()，state=PLAYING
          所有报名玩家传送至古战场
          开始10分钟倒计时
19:35:00  游戏5分钟后 → BR.SpawnBoss()，state=BOSS_PHASE
          地图中央刷新世界BOSS
19:40:00  10分钟到 或 只剩1队 → BR.EndGame()
          BOSS未击杀则自动消失
          发放奖励，传送回勇者大陆
          state=IDLE，重置所有数据
```

---

#### 📋 详细步骤

##### **步骤1：创建 `BattleRoyale.lua` 核心文件**

创建 `LuaAPI/BattleRoyale.lua`，包含：

- **配置常量**：
  - `BR_MAP = 6` — 古战场
  - `BR_DURATION = 600` — 10分钟（秒）
  - `BR_ENTRY_TIME = 180` — 提前3分钟入场（秒）
  - `BR_MIN_LEVEL = 400` — 最低等级
  - `BR_MAX_TEAM_SIZE = 3` — 最大队伍人数
  - `BR_SPAWN_X/Y` — 出生点坐标
  - `BR_BOSS_CLASS` — 世界BOSS怪物ID
  - `BR_BOSS_SPAWN_TIME = 300` — BOSS在最后5分钟刷新（游戏开始后5分钟）
  - `BR_REWARD_ITEM_TYPE/INDEX` — 祝福宝石的物品类型和索引（Bless = type 14, index 13 → ItemId = 14×512+13 = 7181）

- **状态机枚举**：
  ```
  BR_STATE = {
    IDLE       = 0,  -- 空闲，等待报名
    SIGNUP     = 1,  -- 报名中（19:27~19:30）
    PLAYING    = 2,  -- 游戏进行中（19:30~19:40）
    BOSS_PHASE = 3,  -- BOSS阶段（游戏开始后5分钟）
    REWARDING  = 4,  -- 发放奖励中
    FINISHED   = 5,  -- 游戏结束
  }
  ```

- **核心数据结构**：
  - `BR.teams = {}` — 队伍列表，每个队伍 `{members = {playerIndex1, ...}, alive = true}`
  - `BR.players = {}` — 玩家数据，key=playerIndex，value `{teamId, alive, name, level}`
  - `BR.state = BR_STATE.IDLE`
  - `BR.startTime = 0` — 游戏开始时间戳
  - `BR.bossIndex = -1` — 世界BOSS的对象索引
  - `BR.bossSpawned = false`

---

##### **步骤2：实现报名系统（NPC对话 + 命令 + 队伍逻辑）**

在 `BattleRoyale.lua` 中实现：

**2a. 命令报名** — 在 `Callbacks.lua` 的 `onUseCommand` 中拦截 `/绝地` 或 `/jdqs` 命令：
- 检查 `BR.state == BR_STATE.SIGNUP`
- 检查玩家等级 >= 400
- 检查玩家未在其他队伍中
- 如果玩家已组队：将整队报名（队长操作，队伍人数<=3）
- 如果玩家未组队：创建新队伍（单人队伍），或加入已有不满人的队伍

**2b. NPC对话报名** — 在 `Callbacks.lua` 的 `onNpcTalk` 中拦截特定NPC：
- 检查NPC类型（使用特定NPC Class ID）
- 执行与命令报名相同的逻辑

**2c. 报名成功后**：
- 发送消息确认报名
- 如果状态是 SIGNUP，给玩家显示倒计时

---

##### **步骤3：实现时间调度和阶段控制**

**3a. 修改 `EventScheduler.xml`**：
```xml
<Event Type="3" Name="绝地求生" NoticePeriod="180" Duration="780">
  <Start Year="-1" Month="-1" Day="-1" DayOfWeek="-1" Hour="19" Minute="27" Second="0" />
</Event>
```
- NoticePeriod=180秒（提前3分钟预告）
- Duration=780秒（报名3分钟 + 比赛10分钟 + 缓冲）

**3b. 修改 `Enums.EventType`**：
```lua
BATTLE_ROYALE = 3,
```

**3c. 修改 `EventHandler.lua`** 添加处理：
- `noticeHandlers[3]` → 19:27 预告广播：全场通知"绝地求生将在3分钟后开始报名！"
- `startHandlers[3]` → 开始报名阶段：`BR.StartSignup()`
- `endHandlers[3]` → 事件结束：`BR.ForceEnd()`

**3d. 定时器控制阶段**：
- `BR.StartSignup()`：设置 state=SIGNUP，全场广播，启动3分钟倒计时定时器
- 3分钟倒计时结束后 → `BR.StartGame()`：传送所有报名玩家到古战场，state=PLAYING
- 游戏5分钟后 → `BR.SpawnBoss()`：state=BOSS_PHASE，地图中央刷新世界BOSS
- 游戏10分钟总时间到 → `BR.EndGame()`：结算奖励

---

##### **步骤4：实现入场和游戏进行逻辑**

**4a. 入场（`BR.StartGame()`）**：
- 遍历 `BR.teams`，将所有报名玩家传送到古战场 `Move.ToMap(playerIndex, 6, spawnX, spawnY)`
- 给每个玩家发送倒计时UI：`Utility.SendEventTimer(playerIndex, 600000, 0, 2, 0)`
- 全场广播"绝地求生正式开始！存活到最后！"

**4b. PvP 控制**：
- 在 `Callbacks.lua` 的 `onCheckUserTarget` 中，如果目标在古战场且 `BR.state == PLAYING/BOSS_PHASE`，**允许**攻击（不阻止）
- 对于非参赛玩家，在古战场保持原有保护规则
- 参赛玩家之间可以自由攻击

**4c. 死亡处理** — 在 `Callbacks.lua` 的 `onPlayerDie` 中：
- 如果死亡玩家在古战场且是参赛者：
  - 标记 `BR.players[playerIndex].alive = false`
  - 传送回勇者大陆：`Move.ToMap(playerIndex, 0, 130, 130)`
  - 全场广播该玩家阵亡消息
  - 检查该玩家所在队伍是否全部阵亡 → 如果是，标记 `team.alive = false`
  - 检查是否只剩一支存活队伍 → 如果是，触发 `BR.EndGame()`

---

##### **步骤5：实现世界BOSS刷新和奖励发放**

**5a. BOSS刷新（`BR.SpawnBoss()`）**：
- 在古战场中央坐标生成世界BOSS：
  ```lua
  BR.bossIndex = EventMonsterTracker.SpawnAndRegister(
    Enums.EventType.BATTLE_ROYALE, BR_BOSS_CLASS, 6, 
    bossX1, bossY1, bossX2, bossY2, 0
  )
  ```
- 全场广播"世界BOSS已出现在地图中央！"

**5b. BOSS击杀奖励** — 在 `Callbacks.lua` 的 `onMonsterDie` 中：
- 如果击杀的怪物被 `EventMonsterTracker` 追踪且属于 `BATTLE_ROYALE` 事件：
  - 全场广播"世界BOSS已被击杀！"
  - 给击杀者队伍额外奖励

**5c. 游戏结束（`BR.EndGame()`）**：
- 确定获胜队伍（最后存活的队伍）
- 全场广播获胜队伍名称和成员
- 给获胜队伍每个成员发放祝福宝石：
  ```lua
  local blessId = Helpers.MakeItemId(14, 13) -- Bless of Blessing
  -- 使用 ItemBag 或直接给物品
  ItemBag.Use(playerIndex, Enums.ItemBagType.INVENTORY, blessId, 1)
  ```
- 清理地图上剩余BOSS（如果未被击杀）：`EventMonsterTracker.CleanupMonsters(Enums.EventType.BATTLE_ROYALE)`
- 传送所有参赛玩家回勇者大陆
- 重置所有状态：`BR.Reset()`

---

##### **步骤6：集成到 Main.lua 和 Callbacks.lua**

**6a. `Main.lua`**：
```lua
LoadScript(BASE .. "BattleRoyale.lua")
```
并在初始化部分：
```lua
BattleRoyale.Initialize()
```

**6b. `Callbacks.lua` 修改点**：

| 回调函数 | 修改内容 |
|---|---|
| `onUseCommand` | 拦截 `/绝地` `/jdqs` 命令 → `BattleRoyale.HandleCommand()` |
| `onNpcTalk` | 拦截报名NPC → `BattleRoyale.HandleNpcTalk()` |
| `onCheckUserTarget` | 绝地求生期间在古战场允许PvP |
| `onPlayerDie` | 参赛玩家死亡处理 → `BattleRoyale.OnPlayerDie()` |
| `onMonsterDie` | 世界BOSS击杀处理 → `BattleRoyale.OnMonsterDie()` |
| `onPlayerDisconnect` | 参赛玩家断线处理 → `BattleRoyale.OnPlayerDisconnect()` |
| `onPlayerRespawn` | 阻止参赛玩家在古战场重生 |

---

##### **步骤7：配置 EventScheduler.xml**

在 `EventScheduler.xml` 中新增绝地求生事件：
```xml
<Event Type="3" Name="绝地求生" NoticePeriod="180" Duration="780">
  <Start Year="-1" Month="-1" Day="-1" DayOfWeek="-1" Hour="19" Minute="27" Second="0" />
</Event>
```

---

##### **步骤8：更新 Enums.lua**

在 `Enums.EventType` 中新增：
```lua
BATTLE_ROYALE = 3,
```

---

#### 文件变更清单

| 文件 | 操作 | 说明 |
|---|---|---|
| `LuaAPI/BattleRoyale.lua` | **新建** | 绝地求生核心逻辑 |
| `LuaAPI/Main.lua` | 修改 | 加载 BattleRoyale.lua + 初始化 |
| `LuaAPI/Callbacks.lua` | 修改 | 接入命令、NPC、死亡、PvP等回调 |
| `LuaAPI/EventHandler.lua` | 修改 | 添加绝地求生事件处理器 |
| `LuaAPI/Defines/Enums.lua` | 修改 | 新增 BATTLE_ROYALE 事件类型 |
| `LuaAPI/Config/EventScheduler.xml` | 修改 | 新增绝地求生调度事件 |
| `ROADMAP.md` | 修改 | 更新进度 |

---

## 2、