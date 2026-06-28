---@class Battle_List
---@class List @
local M = {}

M.__index = M

function M.new()
	local instance = setmetatable({list = {}, Count = 0}, M)
	return instance
end

M.Count = 0
--数组
M.list = nil

function M:ctor()
	if self.list == nil then
	   self.list = {}
	end
end

--加入一个元素
function M:add( item )
	if item ~= nil then
		table.insert(self.list, item)
		self.Count = #self.list
	end
end

--加入一个元素
function M:insert( id , item )
	if item ~= nil then
		table.insert(self.list, id+1, item)
		self.Count = #self.list
		--for i = self.Count, id + 1, -1 do
		--	self.list[i] = self.list[i - 1]
		--end
		--self.list[id] = item
		--self.Count = self.Count + 1
	end
end

--删除一个元素
function M:removeAt( index )
	if self.Count > index then
		table.remove(self.list, (index+1) )
		self.Count = #self.list
		--self.list[index] = nil
		--self.Count = self.Count - 1
		----重新设置list的索引
		--self:resetIndex(index)
	end
end


--重新设置list索引
--function M:resetIndex( index )
--	for i=0,self.Count-1,1 do
--		if i >= index then
--			self.list[i] = self.list[i+1]
--			self.list[i+1] = nil
--		end
--	end
--end


--获取一个元素
---@return PlayerModel | Player_View | PlayerSkillItem
function M:get( index )
	return self.list[index+1]
end


--设置一个元素
function M:set( index, item )
	--table.insert(self.list, index+1, item)
	--self.list[index+1] = item
	if index < self.Count then
		self.list[index+1] = item
	else
		Logger.logErrorAlways(index, "list not set this item by index")
	end
end


--删除某个元素
function M:remove( item, removeall )
	for i=self.Count,1,-1 do
		if self.list[i] == item then
			table.remove(self.list, i)
			if removeall == false then
				break
			end
		end
	end
	self.Count = #self.list
end


--清除数组
function M:clear()
	if self.Count ~= 0 then
		for i = self.Count,1,-1 do
			table.remove(self.list, i)
		end
		self.Count = 0
	end
end


--是否包含某个元素
function M:contains( item )
	for i=self.Count,1,-1 do
		if self.list[i] == item then
			return true
		end
	end
	return false
end

function M:clone()
	local list = Battle.List.new()
	for i = 0, self.Count - 1 do
		list:add(self:get(i))
	end
	return list
end

--comp a>b为升序，a<b为降序
function M:sort(comp)
	self:quickSort(comp, 1, self.Count)
end

function M:quickSort(comp, low, high)
	local i=low
	local j=high
	local temp = 0

	if low < high then
		temp = self.list[low]
		while(i ~= j)
		do
			while(j > i and comp(self.list[j], temp))
			do
				j = j - 1	
			end

			if i < j then
				self.list[i] = self.list[j]
				i = i + 1
			end

			while(i < j and comp(temp, self.list[i]))
			do
				i = i + 1
			end

			if i < j then
				self.list[j] = self.list[i]
				j = j - 1
			end
		end
		self.list[i] = temp
		self:quickSort(comp, low, i - 1)
		self:quickSort(comp, i + 1, high)
	end
end

--- 安全遍历
---@param func fun(data:PlayerModel | Player_View | PlayerSkillItem | PlayerBuf_Model)
function M:safeWalkInverted(func)
	if func then
		for i = self.Count, 1, -1 do
			local data = self:get(i-1)
			if data then
				func(data)
			end
		end
	end
end

return M
