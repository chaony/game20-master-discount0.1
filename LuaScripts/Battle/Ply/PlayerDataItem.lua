---@class PlayerDataItem 玩家数据类
---@field player PlayerModel
local M = {}

M.__index = M

function M.new()
	local instance = setmetatable({}, M)
	return instance
end

--数据类型
M.name = nil
--数据计算方式
M.calculateType = nil
--初始值（面板属性）
M.initialValue = nil
--加法计算
M.addList = nil
--乘法计算
M.mulList = nil
--同类加异类乘
M.mulAfterAddList = nil
--加法临时列表
M.addListTemp = nil
--乘法临时列表
M.mulListTemp = nil
--同类加异类乘临时列表
M.mulAfterAddListTemp = nil
--额外加法计算
M.extraAddList = nil
--最终结果（每次计算后需要刷新）
M.value = nil
--在获取value的时候判断是否需要更新
M.needRefresh = true

local key_table = {hp= 1,atk= 1}

function M:init(name)
	self.name = name
	self.calculateType = "add"
	self.initialValue = 0
	self.addList = {}
	self.mulList = {}
	self.mulAfterAddList = Battle.ListMap.new()

	self.addListTemp = {}
	self.mulListTemp = {}
	self.mulAfterAddListTemp = Battle.ListMap.new()

	self.list = Battle.ListMap.new();
	self.extraAddList = {}
	self.value = 0
	--保护数据不被更改
	-- -1 不受保护 0 阻止减少 1 阻止增加 
	self.protectedState = -1;
	self.m_listen_name = nil
	self.m_listen_atr = nil
end

--设定保护状态
function M:setProtectedState( state )
	self.protectedState = state;
end

function M:setLinks( links)
	self.links = links
end


function M:setCalType(type)
	self.calculateType = type
end

--初始值（面板属性）
function M:setInitialValue(value)
	self.initialValue = value
	if key_table[self.name] ~= nil then
		self.tempValue = {}
		for i = 1, 10 do
			local temp = {}
			temp[self.name] = value
			table.insert(self.tempValue, temp)
		end
	end
	self:refreshData()
end

--初始值（面板属性）
function M:getInitialValue()
	return self.initialValue or 0
end

--加（负值即为减）
function M:addToAddList(value)
	if value ~= 0 then
		table.insert(self.addList, value)
		self:refreshData()
		if self.links ~= nil then
			for i, v in ipairs(self.links) do
				v:addToAddList(value)
			end
		end
	end
end

--临时加（负值即为减）
function M:addToAddListTemp(value)
	if value ~= 0 then
		table.insert(self.addListTemp, value)
		self:refreshData()
		if self.links ~= nil then
			for i, v in ipairs(self.links) do
				v:addToAddListTemp(value)
			end
		end
	end
end

--移除加成
function M:removeFromAddList(value)
	if value ~= 0 then
		table.removebyvalue(self.addList, value, false)
		self:refreshData()
		if self.links ~= nil then
			for i, v in ipairs(self.links) do
				v:removeFromAddList(value)
			end
		end
	end
end

--乘法计算
function M:addToMulList(value)
	if value ~= 0 then
		table.insert(self.mulList, value)
		self:refreshData()
		if self.links ~= nil then
			for i, v in ipairs(self.links) do
				v:addToMulList(value)
			end
		end
	end
end

--临时乘
function M:addToMulListTemp(value)
	if value ~= 0 then
		table.insert(self.mulListTemp, value)
		self:refreshData()
		if self.links ~= nil then
			for i, v in ipairs(self.links) do
				v:addToMulListTemp(value)
			end
		end
	end
end

--移除乘法计算
function M:removeFromMulList(value)
	if value ~= 0 then
		--TODO 按值移除可能有隐藏(BUG) 当加入2个相同的值的时候，移除的时候会同时移除，但这不是我们想要的
		--TODO 所有用到的都同理
		table.removebyvalue(self.mulList, value, false)
		self:refreshData()
		if self.links ~= nil then
			for i, v in ipairs(self.links) do
				v:removeFromMulList(value)
			end
		end
	end
end

--同类加异类乘
function M:addToMAAList(value, from)
	if value ~= 0 then
		local from_value = self.mulAfterAddList:get(from)
		if from_value == nil then
			from_value = {}
			self.mulAfterAddList:add(from, from_value)
		end
		table.insert(from_value, value)
		self:refreshData()
		if self.links ~= nil then
			for i, v in ipairs(self.links) do
				v:addToMAAList(value)
			end
		end
	end
end

--同类加异类乘临时
function M:addToMAAListTemp(value, from)
	if value ~= 0 then
		local from_value = self.mulAfterAddList:get(from)
		if from_value == nil then
			from_value = {}
			self.mulAfterAddListTemp:add(from, from_value)
		end
		table.insert(from_value, value)
		self:refreshData()
		if self.links ~= nil then
			for i, v in ipairs(self.links) do
				v:addToMAAListTemp(value)
			end
		end
	end
end

--移除同类加异类乘
function M:removeFromMAAList(value, from)
	if value ~= 0 then
		if self.mulAfterAddList:contains(from) then
			table.removebyvalue(self.mulAfterAddList:get(from), value, false)
			if table.nums(self.mulAfterAddList:get(from)) <= 0 then
				self.mulAfterAddList:remove(from)
			end
			self:refreshData()
			if self.links ~= nil then
				for i, v in ipairs(self.links) do
					v:removeFromMAAList(value)
				end
			end
		end
	end
end

function M:addToExtraAddList(value)
	if value ~= 0 then
		table.insert(self.extraAddList, value)
		self:refreshData()
		if self.links ~= nil then
			for i, v in ipairs(self.links) do
				v:addToExtraAddList(value)
			end
		end
	end
end

--移除加成
function M:removeFromExtraAddList(value)
	if value ~= 0 then
		table.removebyvalue(self.extraAddList, value, false)
		self:refreshData()
		if self.links ~= nil then
			for i, v in ipairs(self.links) do
				v:removeFromExtraAddList(value)
			end
		end
	end
end

--强制赋值，下一次刷新会被覆盖
function M:setForce(value)
	if value >= 0 then
		--不增加
		if self.protectedState ~= 1 then
			self.value = value
		end
	else
		--不减少
		if self.protectedState ~= 0 then
			self.value = value
		end
	end
end


--刷新数据
function M:refreshData()
	self.needRefresh = true
end

function M:calculateData()
	local value = self.initialValue
	for k,v in ipairs(self.addList) do
		if v >= 0 then
			--不增加
			if self.protectedState ~= 1 then
				value = value + v
			end
		else
			--不减少
			if self.protectedState ~= 0 then
				value = value + v
			end
		end
		--value = value + v
	end

	for k,v in ipairs(self.addListTemp) do
		if v >= 0 then
			--不增加
			if self.protectedState ~= 1 then
				value = value + v
			end
		else
			--不减少
			if self.protectedState ~= 0 then
				value = value + v
			end
		end
		--value = value + v
	end

	for k,v in ipairs(self.mulList) do
		local precent = self:dataCalculate(GlobalTools.base1, v)
		if precent >= GlobalTools.base1 then
			--不增加
			if self.protectedState ~= 1 then
				value = GlobalTools:Mul( value,  precent)
			end
		else
			--不减少
			if self.protectedState ~= 0 then
				value = GlobalTools:Mul( value,  precent )
			end
		end
		--value = GlobalTools:Mul(value, self:dataCalculate(GlobalTools.base1, v) )
	end

	for k,v in ipairs(self.mulListTemp) do
		local precent = self:dataCalculate(GlobalTools.base1, v)
		if precent >= GlobalTools.base1 then
			--不增加
			if self.protectedState ~= 1 then
				value = GlobalTools:Mul( value,  precent)
			end
		else
			--不减少
			if self.protectedState ~= 0 then
				value = GlobalTools:Mul( value,  precent)
			end
		end
		--value = GlobalTools:Mul(value, self:dataCalculate(GlobalTools.base1, v) )
	end

	-- 1 + x + x1 + x2
	self.list:clear();
	for i = 1, self.mulAfterAddList.list.Count do
		local key = self.mulAfterAddList.list:get(i-1)
		local values = self.mulAfterAddList:get(key);
		local temp = GlobalTools.base1
		for i, v in ipairs(values) do
			temp = self:dataCalculate(temp, v)
		end
		self.list:add(key, temp)
	end

	-- 1 + y + y1 + y2
	for i = 1, self.mulAfterAddListTemp.list.Count do
		local key = self.mulAfterAddListTemp.list:get(i-1)
		local values = self.mulAfterAddListTemp:get(key);
		local temp = GlobalTools.base1
		for i, v in ipairs(values) do
			temp = self:dataCalculate(temp, v)
		end
		self.list:add(key, temp)
	end

	--
	for i = 1, self.list.list.Count do
		local k = self.list.list:get(i-1)
		local v = self.list:get(k)
		if v >= GlobalTools.base1 then
			--不增加
			if self.protectedState ~= 1 then
				value = GlobalTools:Mul(value, v)
			end
		else
			--不减少
			if self.protectedState ~= 0 then
				value = GlobalTools:Mul(value, v)
			end
		end
	end

	for k,v in ipairs(self.extraAddList) do
		if v >= 0 then
			if self.protectedState ~= 1 then
				value = value + v
			end
		else
			if self.protectedState ~= 0 then
				value = value + v
			end
		end
	end

	if self.name == "atk" and value < GlobalTools.base1 then
		value = GlobalTools.base1
	elseif self.name == "def" and value < GlobalTools.base0 then
		value = GlobalTools.base0
	end
	if self.m_listen_name and self.m_listen_name ~= "" and self.m_listen_atr and self.name == self.m_listen_atr and self.value ~= value  then
		EventDispatcher:dipatchEvent(self.m_listen_name,{before_value = self.value, after_value = value})
	end
	self.value = value

	if self.tempValue ~= nil then
		for i = 1, #self.tempValue do
			self.tempValue[i] = self:getValue()
		end
	end
end



function M:getValue()
	if self.needRefresh then
		self.needRefresh = false
		self:calculateData()
	end
	return self.value
end


function M:dataCalculate(value1, value2)
	if self.calculateType == "add" then
		return value1 + value2	
	elseif self.calculateType == "reduce" then
		return value1 - value2
	end
end

function M:clearTemp()
	for i = #self.addListTemp, 1,-1 do
		self.addListTemp[i] = nil
	end
	for i = #self.mulListTemp, 1,-1 do
		self.mulListTemp[i] = nil
	end
	self.mulAfterAddListTemp:clear()
	self:refreshData()
	--if self.links ~= nil then
	--	for i, v in ipairs(self.links) do
	--		v:clearTemp()
	--	end
	--end
end

-- 清理加成数据 临时&永久
function M:clearAllData()
	for i = #self.addListTemp, 1,-1 do
		self.addListTemp[i] = nil
	end
	for i = #self.mulListTemp, 1,-1 do
		self.mulListTemp[i] = nil
	end
	self.mulAfterAddListTemp:clear()
	
	for i = #self.addList, 1,-1 do
		self.addList[i] = nil
	end
	for i = #self.mulList, 1,-1 do
		self.mulList[i] = nil
	end
	self.mulAfterAddList:clear()
	
	self:refreshData()
	if self.links ~= nil then
		for i, v in ipairs(self.links) do
			v:clearAllData()
		end
	end
end

--listen_name消息事件名，atr_name要监听的属性
function M:setAtrChangeListen(listen_name, atr_name)
	if listen_name and listen_name ~= ""  and atr_name and atr_name ~= "" then
		self.m_listen_name = listen_name
		self.m_listen_atr = atr_name
	end
end

return M