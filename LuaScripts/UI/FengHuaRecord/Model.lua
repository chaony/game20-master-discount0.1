local M = class("FengHuaRecordModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("fenghua_record_index")
end

function M:onEnter()
	self.m_cur_skin_id = self.m_data.skin_id
	--self.fenghua_record = ConfigManager:getCfgByName("fenghua_record")
	self.fenghua_record_skin = ConfigManager:getCfgByName("fenghua_record_skin")
	self.m_select_skin_id = 0
	self:initList()
end

function M:initList()
	self.select_skin_list = {}
	local tmp_list = {}
	for k,v in pairs(self.fenghua_record_skin) do
		if self.m_cur_skin_id == k then
			self.select_skin_list[#self.select_skin_list + 1] = k
		else
			tmp_list[#tmp_list + 1] = k
		end
	end
	local function sortFunc(id1, id2)
		local flag1 = self:getSkinHave(id1) == true and 0 or 1
		local flag2 = self:getSkinHave(id2) == true and 0 or 1
		return flag1 < flag2
	end
	table.sort(tmp_list, sortFunc)
	for k,v in pairs(tmp_list) do
		self.select_skin_list[#self.select_skin_list + 1] = v
	end
end

function M:getSkinHave(skin_id)
	local skin_list_active = self.m_data.record
	for k,v in pairs(skin_list_active) do
		if v == skin_id then
			return true
		end
	end
	return false
end

--[[
function M:haveNums()
	local skin_list_state = self.m_data.record
	local name = tostring(self.select_name)
	local id = 0
	for k1,v1 in ipairs(self.fenghua_record) do
		if v1.name == name then
			id = k1
		end
	end
	local select_skin = skin_list_state[tostring(id)]
	if select_skin then
		if next(select_skin) then
			return #select_skin
		end
	end
	return 0
end
]]--

function M:updateData(response)
	table.merge(self.m_data,response)
end

return M