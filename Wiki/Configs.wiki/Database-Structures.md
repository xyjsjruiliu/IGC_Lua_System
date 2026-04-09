# 数据库查询结构

暴露给 Lua 的数据库查询结果结构完整参考。

---

## ⚠️ 重要：数据类型处理

**所有数据库查询结果都作为字符串返回**，无论数据库中的实际列类型是什么（INT、FLOAT、REAL、VARCHAR 等）。

### 类型转换要求

你必须手动将字符串结果转换为适当的 Lua 类型：

```lua
-- 对于整数（INT、BIGINT、SMALLINT、TINYINT）
local playerLevel = math.tointeger(oRow:GetValue())

-- 对于浮点数（FLOAT、REAL、DECIMAL、NUMERIC）
local experienceRate = tonumber(oRow:GetValue())

-- 对于字符串（VARCHAR、CHAR、TEXT）- 无需转换
local playerName = oRow:GetValue()
```

**示例：**
```lua
-- 查询返回: Level (INT), Money (BIGINT), Name (VARCHAR)
function DSDBQueryReceive(iPlayerIndex, iQueryNumber, bIsLastPacket, iCurrentRow, iColumnCount, iCurrentPacket, oRow)
	local columnName = oRow:GetColumnName()
	local valueStr = oRow:GetValue()  -- 始终是字符串!
	
	if columnName == "Level" then
		local level = math.tointeger(valueStr)  -- 转换为整数
		Log.Add(string.format("玩家等级: %d", level))
	elseif columnName == "Money" then
		local money = math.tointeger(valueStr)  -- 转换为整数
		Log.Add(string.format("玩家金币: %d", money))
	elseif columnName == "Name" then
		Log.Add(string.format("玩家名称: %s", valueStr))  -- 已经是字符串
	end
end
```

---

## 目录

- [QueryResultDS 结构](#queryresultds-结构)
- [QueryResultJS 结构](#queryresultjs-结构)
- [使用示例](#使用示例)

---

## QueryResultDS 结构

**访问方式：** 通过 `DSDBQueryReceive` 回调参数

**C++ 类型：** `LuaQueryResultDS`

**描述：** 包含 DataServer 数据库查询结果的只读结构。不能被实例化 - 只能通过回调访问。

### 字段

| Field | Type | Description |
|-------|------|-------------|
| `ColumnType` | BYTE | 列数据类型 (0-255) |

### 方法

#### GetColumnName

```lua
oRow:GetColumnName()
```

**返回：** `string` - 列名称（最多 30 个字符）

**用法：**
```lua
function DSDBQueryReceive(iPlayerIndex, iQueryNumber, bIsLastPacket, iCurrentRow, iColumnCount, iCurrentPacket, oRow)
    local columnName = oRow:GetColumnName()
    Log.Add("列: " .. columnName)
end
```

---

#### GetValue

```lua
oRow:GetValue()
```

**返回：** `string` - 列值（最多 64 个字符）

**用法：**
```lua
function DSDBQueryReceive(iPlayerIndex, iQueryNumber, bIsLastPacket, iCurrentRow, iColumnCount, iCurrentPacket, oRow)
    local value = oRow:GetValue()
    Log.Add("值: " .. value)
end
```

---

### 回调函数

#### DSDBQueryReceive

```lua
function DSDBQueryReceive(iPlayerIndex, iQueryNumber, bIsLastPacket, iCurrentRow, iColumnCount, iCurrentPacket, oRow)
```

**调用时机：** 收到 DataServer 查询结果时

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `iPlayerIndex` | int | 发起查询的玩家对象索引 |
| `iQueryNumber` | int | 唯一查询标识符（定义查询时设置） |
| `bIsLastPacket` | bool | 如果是最后数据包则为 `1`，否则为 `0` |
| `iCurrentRow` | int | 当前数据包中处理的行号 |
| `iColumnCount` | int | 查询返回的总列数 |
| `iCurrentPacket` | int | 当前数据包编号（0 基，大结果集递增） |
| `oRow` | QueryResultDS | 包含列数据的查询结果行对象 |

**注意事项：**

- 大结果集分成多个数据包（每包最多 32 行）
- 回调在结果集的每一行触发一次
- 使用 `iQueryNumber` 匹配响应与对应的查询
- 检查 `bIsLastPacket` 了解何时收到所有结果
- 每个 `oRow` 包含当前行一列的数据

**用法：**
```lua
-- 发送查询
DB.QueryDS(iPlayerIndex, 1001, string.format("SELECT Name, Level FROM Character WHERE AccountID = '%s'", accountId))

-- 接收结果
function DSDBQueryReceive(iPlayerIndex, iQueryNumber, bIsLastPacket, iCurrentRow, iColumnCount, iCurrentPacket, oRow)
    if iQueryNumber == 1001 then
        local columnName = oRow:GetColumnName()
        local value = oRow:GetValue()
        
        Log.Add(string.format("%s = %s", columnName, value))
        
        if bIsLastPacket == 1 then
            Log.Add("查询完成")
        end
    end
end
```

---

## QueryResultJS 结构

**访问方式：** 通过 `JSDBQueryReceive` 回调参数

**C++ 类型：** `LuaQueryResultJS`（也称为 `stLuaRow`）

**描述：** 包含 JoinServer 数据库查询结果的只读结构。不能被实例化 - 只能通过回调访问。

**注意：** 此结构在某些上下文中也称为 `stLuaRow` - 它们是相同的。

### 字段

| Field | Type | Description |
|-------|------|-------------|
| `ColumnType` | BYTE | 列数据类型 (0-255) |

### 方法

#### GetColumnName

```lua
oRow:GetColumnName()
```

**返回：** `string` - 列名称（最多 30 个字符）

**用法：**
```lua
function JSDBQueryReceive(iPlayerIndex, iQueryNumber, bIsLastPacket, iCurrentRow, iColumnCount, iCurrentPacket, oRow)
    local columnName = oRow:GetColumnName()
    Log.Add("列: " .. columnName)
end
```

---

#### GetValue

```lua
oRow:GetValue()
```

**返回：** `string` - 列值（最多 64 个字符）

**用法：**
```lua
function JSDBQueryReceive(iPlayerIndex, iQueryNumber, bIsLastPacket, iCurrentRow, iColumnCount, iCurrentPacket, oRow)
    local value = oRow:GetValue()
    Log.Add("值: " .. value)
end
```

---

### 回调函数

#### JSDBQueryReceive

```lua
function JSDBQueryReceive(iPlayerIndex, iQueryNumber, bIsLastPacket, iCurrentRow, iColumnCount, iCurrentPacket, oRow)
```

**调用时机：** 收到 JoinServer 查询结果时

**参数：**

| Parameter | Type | Description |
|-----------|------|-------------|
| `iPlayerIndex` | int | 发起查询的玩家对象索引 |
| `iQueryNumber` | int | 唯一查询标识符（定义查询时设置） |
| `bIsLastPacket` | bool | 如果是最后数据包则为 `1`，否则为 `0` |
| `iCurrentRow` | int | 当前数据包中处理的行号 |
| `iColumnCount` | int | 查询返回的总列数 |
| `iCurrentPacket` | int | 当前数据包编号（0 基，大结果集递增） |
| `oRow` | QueryResultJS | 包含列数据的查询结果行对象 |

**注意事项：**

- 大结果集分成多个数据包（每包最多 32 行）
- 回调在结果集的每一行触发一次
- 使用 `iQueryNumber` 匹配响应与对应的查询
- 检查 `bIsLastPacket` 了解何时收到所有结果
- 每个 `oRow` 包含当前行一列的数据

**用法：**
```lua
-- 发送查询
DB.QueryJS(iPlayerIndex, 2001, string.format("SELECT memb__id, credits FROM MEMB_INFO WHERE memb__id = '%s'", accountId))

-- 接收结果
function JSDBQueryReceive(iPlayerIndex, iQueryNumber, bIsLastPacket, iCurrentRow, iColumnCount, iCurrentPacket, oRow)
    if iQueryNumber == 2001 then
        local columnName = oRow:GetColumnName()
        local value = oRow:GetValue()
        
        Log.Add(string.format("%s = %s", columnName, value))
        
        if bIsLastPacket == 1 then
            Log.Add("查询完成")
        end
    end
end
```

---

## 使用示例

### 示例 1: 基础查询结果处理器（DataServer）

```lua
function DSDBQueryReceive(iPlayerIndex, iQueryNumber, bIsLastPacket, iCurrentRow, iColumnCount, iCurrentPacket, oRow)
    local columnName = oRow:GetColumnName()
    local value = oRow:GetValue()
    
    Log.Add(string.format("玩家: %d", iPlayerIndex))
    Log.Add(string.format("查询: %d", iQueryNumber))
    Log.Add(string.format("列: %s = %s", columnName, value))
    
    if bIsLastPacket == 1 then
        Log.Add("已收到所有结果")
    end
end
```

### 示例 2: 基础查询结果处理器（JoinServer）

```lua
function JSDBQueryReceive(iPlayerIndex, iQueryNumber, bIsLastPacket, iCurrentRow, iColumnCount, iCurrentPacket, oRow)
    local columnName = oRow:GetColumnName()
    local value = oRow:GetValue()
    
    Log.Add(string.format("玩家: %d", iPlayerIndex))
    Log.Add(string.format("查询: %d", iQueryNumber))
    Log.Add(string.format("列: %s = %s", columnName, value))
    
    if bIsLastPacket == 1 then
        Log.Add("已收到所有结果")
    end
end
```

### 示例 3: 收集完整结果集（DataServer）

```lua
-- 全局存储
local queryResults = {}

function DSDBQueryReceive(iPlayerIndex, iQueryNumber, bIsLastPacket, iCurrentRow, iColumnCount, iCurrentPacket, oRow)
    -- 为此查询初始化存储
    if queryResults[iQueryNumber] == nil then
        queryResults[iQueryNumber] = {}
    end
    
    -- 为此行初始化存储
    if queryResults[iQueryNumber][iCurrentRow] == nil then
        queryResults[iQueryNumber][iCurrentRow] = {}
    end
    
    -- 存储列数据
    local columnName = oRow:GetColumnName()
    local value = oRow:GetValue()
    queryResults[iQueryNumber][iCurrentRow][columnName] = value
    
    -- 收到最后数据包时处理完整结果
    if bIsLastPacket == 1 then
        Log.Add(string.format("查询 %d 完成，共 %d 行", iQueryNumber, iCurrentRow))
        
        -- 处理所有行
        for rowNum, rowData in pairs(queryResults[iQueryNumber]) do
            Log.Add(string.format("行 %d:", rowNum))
            for colName, colValue in pairs(rowData) do
                Log.Add(string.format("  %s: %s", colName, colValue))
            end
        end
        
        -- 清理
        queryResults[iQueryNumber] = nil
    end
end
```

### 示例 4: 按编号处理特定查询（带类型转换）

```lua
function DSDBQueryReceive(iPlayerIndex, iQueryNumber, bIsLastPacket, iCurrentRow, iColumnCount, iCurrentPacket, oRow)
	local columnName = oRow:GetColumnName()
	local valueStr = oRow:GetValue()  -- 始终返回字符串!
	
	if iQueryNumber == 1001 then
		-- 处理玩家属性查询
		if columnName == "Level" then
			local level = math.tointeger(valueStr)  -- 转换为整数
			Log.Add(string.format("玩家等级: %d", level))
		elseif columnName == "Kills" then
			local kills = math.tointeger(valueStr)  -- 转换为整数
			Log.Add(string.format("玩家击杀数: %d", kills))
		elseif columnName == "Money" then
			local money = math.tointeger(valueStr)  -- 转换为整数
			Log.Add(string.format("玩家金币: %d", money))
		end
		
	elseif iQueryNumber == 1002 then
		-- 处理公会查询
		if columnName == "GuildName" then
			Log.Add(string.format("公会: %s", valueStr))  -- 字符串 - 无需转换
		elseif columnName == "GuildMaster" then
			Log.Add(string.format("会长: %s", valueStr))  -- 字符串 - 无需转换
		end
	end
end
```

### 示例 5: 追踪数据包进度

```lua
function DSDBQueryReceive(iPlayerIndex, iQueryNumber, bIsLastPacket, iCurrentRow, iColumnCount, iCurrentPacket, oRow)
    Log.Add(string.format("正在处理数据包 %d，行 %d", iCurrentPacket, iCurrentRow))
    Log.Add(string.format("结果中的总列数: %d", iColumnCount))
    
    local columnName = oRow:GetColumnName()
    local columnType = oRow.ColumnType
    local value = oRow:GetValue()
    
    Log.Add(string.format("%s (类型 %d): %s", columnName, columnType, value))
    
    if bIsLastPacket == 1 then
        Log.Add(string.format("查询 %d 已完成", iQueryNumber))
    end
end
```

### 示例 6: 使用类型转换构建角色数据（DataServer）

```lua
-- 用于角色数据的全局存储
local characterData = {}

-- 发送查询
function LoadCharacterData(iPlayerIndex, characterName)
	DB.QueryDS(iPlayerIndex, 3001, 
		string.format("SELECT Name, cLevel, Strength, Dexterity, Vitality, Energy, Money FROM Character WHERE Name = '%s'", characterName))
end

-- 接收结果
function DSDBQueryReceive(iPlayerIndex, iQueryNumber, bIsLastPacket, iCurrentRow, iColumnCount, iCurrentPacket, oRow)
	if iQueryNumber == 3001 then
		local columnName = oRow:GetColumnName()
		local valueStr = oRow:GetValue()
		
		-- 存储角色数据
		if characterData[iPlayerIndex] == nil then
			characterData[iPlayerIndex] = {}
		end
		
		-- 将数值列转换为适当类型
		if columnName == "cLevel" or columnName == "Strength" or columnName == "Dexterity" or 
		   columnName == "Vitality" or columnName == "Energy" or columnName == "Money" then
			characterData[iPlayerIndex][columnName] = math.tointeger(valueStr)
		else
			characterData[iPlayerIndex][columnName] = valueStr  -- 字符串（Name）
		end
		
		-- 完成后处理
		if bIsLastPacket == 1 then
			local data = characterData[iPlayerIndex]
			
			Log.Add(string.format("角色: %s", data.Name or "未知"))
			Log.Add(string.format("等级: %d", data.cLevel or 0))
			Log.Add(string.format("力量: %d, 敏捷: %d, 体力: %d, 智力: %d", 
				data.Strength or 0,
				data.Dexterity or 0,
				data.Vitality or 0,
				data.Energy or 0))
			Log.Add(string.format("金币: %d", data.Money or 0))
			
			-- 发送给玩家
			Message.Send(0, iPlayerIndex, 0, 
				string.format("角色已加载: %s (等级 %d)", data.Name, data.cLevel))
			
			-- 清理
			characterData[iPlayerIndex] = nil
		end
	end
end
```

### 示例 7: 使用类型转换查询账号积分（JoinServer）

```lua
-- 发送查询
function CheckAccountCredits(iPlayerIndex, accountId)
	DB.QueryJS(iPlayerIndex, 4001,
		string.format("SELECT credits, vip_level FROM MEMB_INFO WHERE memb__id = '%s'", accountId))
end

-- 接收结果
function JSDBQueryReceive(iPlayerIndex, iQueryNumber, bIsLastPacket, iCurrentRow, iColumnCount, iCurrentPacket, oRow)
	if iQueryNumber == 4001 then
		local columnName = oRow:GetColumnName()
		local valueStr = oRow:GetValue()
		
		if columnName == "credits" then
			local credits = math.tointeger(valueStr)  -- 转换为整数
			Message.Send(0, iPlayerIndex, 0, string.format("积分: %d", credits))
		elseif columnName == "vip_level" then
			local vipLevel = math.tointeger(valueStr)  -- 转换为整数
			Message.Send(0, iPlayerIndex, 0, string.format("VIP 等级: %d", vipLevel))
		end
	end
end
```

### 示例 8: 使用类型转换的玩家排行榜（DataServer）

```lua
-- 全局排行榜数据
local rankingData = {}

-- 发送查询（不与特定玩家关联）
function LoadTopPlayers()
	DB.QueryDS(-1, 5001,
		"SELECT TOP 10 Name, cLevel, Resets FROM Character ORDER BY Resets DESC, cLevel DESC")
end

-- 接收结果
function DSDBQueryReceive(iPlayerIndex, iQueryNumber, bIsLastPacket, iCurrentRow, iColumnCount, iCurrentPacket, oRow)
	if iQueryNumber == 5001 then
		local columnName = oRow:GetColumnName()
		local valueStr = oRow:GetValue()
		
		-- 初始化行存储
		if rankingData[iCurrentRow] == nil then
			rankingData[iCurrentRow] = {}
		end
		
		-- 使用适当类型转换存储列数据
		if columnName == "Name" then
			rankingData[iCurrentRow][columnName] = valueStr  -- 字符串
		else
			rankingData[iCurrentRow][columnName] = math.tointeger(valueStr)  -- 整数
		end
		
		-- 完成后显示
		if bIsLastPacket == 1 then
			Log.Add("=== 前 10 名玩家 ===")
			
			for rank, data in pairs(rankingData) do
				Log.Add(string.format("%d. %s - 等级 %d - 重置次数: %d",
					rank,
					data.Name or "未知",
					data.cLevel or 0,
					data.Resets or 0))
			end
			
			-- 清理
			rankingData = {}
		end
	end
end
```

### 示例 9: 多数据包结果

```lua
-- 用于大结果集的全局存储
local largeQueryResults = {}

function DSDBQueryReceive(iPlayerIndex, iQueryNumber, bIsLastPacket, iCurrentRow, iColumnCount, iCurrentPacket, oRow)
    if iQueryNumber == 6001 then
        Log.Add(string.format("数据包 %d - 大查询的第 %d 行", iCurrentPacket, iCurrentRow))
        
        -- 初始化存储
        if largeQueryResults[iCurrentRow] == nil then
            largeQueryResults[iCurrentRow] = {}
        end
        
        -- 存储数据
        local columnName = oRow:GetColumnName()
        local value = oRow:GetValue()
        largeQueryResults[iCurrentRow][columnName] = value
        
        -- 仅在收到最后数据包时处理
        if bIsLastPacket == 1 then
            Log.Add(string.format("大查询完成：收到共 %d 行", iCurrentRow))
            
            -- 处理所有行
            for rowNum, rowData in pairs(largeQueryResults) do
                -- 处理每一行...
            end
            
            -- 清理
            largeQueryResults = {}
        end
    end
end
```

### 示例 10: 错误处理

```lua
function DSDBQueryReceive(iPlayerIndex, iQueryNumber, bIsLastPacket, iCurrentRow, iColumnCount, iCurrentPacket, oRow)
    if iQueryNumber == 7001 then
        -- 检查查询是否返回结果
        if iCurrentRow == 0 and bIsLastPacket == 1 then
            Log.Add("查询未返回结果")
            Message.Send(0, iPlayerIndex, 0, "未找到数据")
            return
        end
        
        -- 检查列数
        if iColumnCount == 0 then
            Log.Add("查询未返回列")
            return
        end
        
        -- 安全提取值
        local columnName = oRow:GetColumnName()
        local value = oRow:GetValue()
        
        if columnName == nil or value == nil then
            Log.Add("无效的列数据")
            return
        end
        
        -- 处理有效数据
        Log.Add(string.format("%s = %s", columnName, value))
    end
end
```

---

## 重要注意事项

1. **只读结构：**
   - QueryResultDS 和 QueryResultJS 都是只读的
   - 不能在 Lua 中直接实例化
   - 只能通过回调参数访问

2. **回调执行：**
   - 回调在结果集的每一行每一列触发一次
   - 对于返回 3 列 5 行的查询，回调触发 15 次
   - 追踪 `iCurrentRow` 以区分不同行
   - 追踪 `iColumnCount` 以了解每行多少列

3. **多数据包结果：**
   - 大结果集分成数据包（每包最多 32 行）
   - 使用 `bIsLastPacket` 检测完成
   - `iCurrentPacket` 递增每个数据包
   - 结果必须在数据包之间累积

4. **查询编号使用：**
   - 使用唯一查询编号识别不同查询
   - 建议范围：1000-1999（DataServer）、2000-2999（JoinServer）
   - 追踪活动查询以避免冲突

5. **数据类型：**
   - 所有值作为字符串返回
   - 需要时转换为数字：`tonumber(value)`
   - 处理 NULL 值：检查空字符串或 nil

6. **性能：**
   - 最小化数据库查询
   - 尽可能缓存结果
   - 使用带参数的准备好的查询
   - 避免在紧密循环中查询

7. **字符串限制：**
   - 列名称：最多 30 个字符
   - 列值：最多 64 个字符
   - 更长的值可能被截断

8. **玩家索引：**
   - 对于不与特定玩家关联的查询使用 `-1`
   - 对于玩家特定查询使用实际玩家索引
   - `iPlayerIndex` 用于识别哪个玩家接收回调结果
   - 在处理结果前始终验证回调中的玩家索引

---

## 另请参见

- [[PLAYER|Player-Structure]] - 玩家对象参考
- [[ITEM|Item-Structures]] - 物品结构
- [[Global-Functions|Global-Functions]] - DB.QueryDS()、DB.QueryJS()
- [[Callbacks|Callbacks]] - 所有回调函数
