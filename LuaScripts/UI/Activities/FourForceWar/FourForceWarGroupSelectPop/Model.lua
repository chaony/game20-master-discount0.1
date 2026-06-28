local M = class("FourForceWarGroupSelectPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_index = self.m_params.index
	self.m_data = self.m_params.data
	local enjoy_spring_force = ConfigManager:getCfgByName("enjoy_spring_force")
	self.enjoy_spring_force = enjoy_spring_force[self.m_data.version][self.m_index]
end

function M:getLiteratureCfg()
	return self.enjoy_spring_force
end

function M:getGroupPeopleCount()
	return self.m_data.force_number[tostring(self.m_index)] or 0
end

function M:getRewardList()
	if self.enjoy_spring_force then
		return self.enjoy_spring_force.reward
	end
	return {}
end

local des_tab = {"enjoySpring_str_0045", "enjoySpring_str_0046", "enjoySpring_str_0047"}
function M:getNumsDesByNums(nums)
	local nums_des = "enjoySpring_str_0045"
	local nums_des_index = 1
	local common_value_tab = ConfigManager:getCommonValueById(711, {})
	for i = #common_value_tab, 1, -1 do
		local page_nums = common_value_tab[i]
		if nums >= page_nums then
			nums_des_index = i
			break
		end
	end
	nums_des_index = math.min(nums_des_index, #des_tab)
	nums_des = des_tab[nums_des_index]
	local nums_color = GlobalConfig.EnjoySpringPowerColor[nums_des_index] or GlobalConfig.EnjoySpringPowerColor[1]
	return nums_des, nums_color
end

return M
