local M = class("AXianTimeTableModel", LikeOO.OODataBase)

local _TAB_NODE = {{"演武场","raid"},
				   {"玄武遗迹","world_boss"},
				   {"侠客试炼","train"},
				   {"江湖传奇","legend"},
}

function M:onCreate()
	M.super.onCreate(self)
	self:getData("one_key_sweep_index")
end

--读取配置后，增加两个null的作为未开启的选项
function M:onEnter()
	self.m_select_id = 1
	self.m_course_data = {}
	local open_condition_data = ConfigManager:getCfgByName("open_condition")
	if open_condition_data[361] then
		self.m_active_data = open_condition_data[361]	
	end
	local cfg_data = ConfigManager:getCfgByName("axian_curriculum")
	for k,v in ipairs(cfg_data) do
		table.insert(self.m_course_data,v)			
	end
	self:addFakeData()
	self.m_skin_id = self.m_data.skin_id
end

--增加未学习数据
function M:addFakeData()
	local nums = table.nums(self.m_course_data)
	self.m_course_nums = nums
	for i = 1,2 do
		table.insert(self.m_course_data,{})
	end
end

function M:getCurrentData()
	local data = self.m_course_data[self.m_select_id]
	if data then
		return data
	end
	return {}
end

function M:refreshData(callback)
	local function netCallback(response)
	 	self.m_data = response
		callback()
	end
	self:getNetData("one_key_sweep_index",nil,netCallback)
end

function M:getCurrentState(index)
	local course_name = self.m_course_data[index].name
	for k,v in ipairs(_TAB_NODE) do
		if course_name == v[1] then
			return self.m_data[v[2]]
		end
	end
end

function M:getCompletetheAllState()
	local gray_flag = false
	for k,v in pairs(self.m_data) do
		if v == 0 then
			gray_flag = true
			return gray_flag
		end
	end
	if self.m_data["raid"] == 1 then
		local costitem = RewardUtil:getProcessRewardData(self.m_course_data[2].cost[1])
		local cost_nums = self.m_course_data[2].cost[1][3]
		local hava_nums = costitem.user_num
		gray_flag = cost_nums > hava_nums
	end
	return gray_flag
end

function M:getCompletetheAllActive()
	local active_flag = true
	for k,v in pairs(self.m_data) do
		if v == 0 then
			active_flag = false
			return active_flag
		end
	end
	return active_flag
end

return M