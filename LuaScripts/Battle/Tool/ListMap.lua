---@class ListMap
local M = {}

M.__index = M

function M.new()
	local instance = setmetatable({}, M)
	instance:ctor()
	return instance
end

function M:ctor()
	if self.list == nil then
	   self.list = Battle.List.new()
	end
	if self.map == nil then
		self.map = {}
	end
	self.Count = 0
end


function M:sort( comp )
	self.list:sort( comp )
end

--加入某个值
function M:add( key, value )
	local keyItem = self.map[key]
	if keyItem == nil then
		self.map[key] = value
		self.list:add(key);
		self.Count = self.Count + 1;
	else
		Logger.logError(" 加入了相同的 key "..key )
	end
end

--设定值
function M:set( key, value )
	if self:contains(key) then
		self.map[key] = value
	end
end


--获取一个元素
function M:get( key )
	return self.map[key]
end


--删除某个元素
function M:remove( key )
	local item = self:get(key)
	if item ~= nil then
		self.map[key] = nil;
		self.list:remove(key)
		self.Count = self.Count - 1;
	end
end

--删除某个元素
function M:removeValue( value )
	for i = self.list.Count, 1, -1 do
		local k = self.list:get(i-1)
		local v = self.map[k]
		if v == value then
			self:remove(k)
		end
	end
end


--清除数组
function M:clear()
	if self.Count ~= 0 then
		self.list:clear();
		for i, v in pairs(self.map) do
			self.map[i] = nil;
		end
		self.Count = 0
	end
end


--是否包含某个元素
function M:contains( key )
	local item = self:get(key)
	if item ~= nil then
		return true;
	end
	return false
end


return M