local M = class("GameOfHeavenAndEarthRewardModel", LikeOO.OODataBase)


function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_version = self.m_params.version or 1
	self.raceType = self.m_params.raceType
	self.m_open_tab_index = self.raceType == 2 and 1 or 2
	self.m_select_type_index = self.m_params.select_type_index or 1
	local cfg = ConfigManager:getCfgByName("full_service_reward")
	self.m_cur_reward_cfg = cfg[self.m_version] or {}
	
end

function M:getReward(type)
	if next(self.m_cur_reward_cfg) then
		local reward_list = {}
		for k,v in pairs(self.m_cur_reward_cfg) do
			if v.type == type then
				table.insert(reward_list,v)
			end
		end
		return reward_list
	else
		Logger.logAlways("请检查奖励表的配置.......full_service_reward")
		return {}
	end
end

return M
