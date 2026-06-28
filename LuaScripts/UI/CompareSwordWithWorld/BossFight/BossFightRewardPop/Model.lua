local M = class("BossFightRewardModel", LikeOO.OODataBase)


function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_version = self.m_params.version
	self.m_rank = self.m_params.rank
	self.m_count = self.m_params.count
	self.m_type = self.m_params.count or 1
	self.m_open_tab_index = 1
	self:getReward()
end

function M:getReward(type)
	if type == -1 then  type = 1 end
	local cfg = ConfigManager:getCfgByName("full_service_reward")
	local cur_reward_cfg = cfg[self.m_version] or {}
	if next(cur_reward_cfg) then
		local reward_list = {}
		for k,v in pairs(cur_reward_cfg) do
			if v.type == type then
				table.insert(reward_list,v)
			end
		end
		table.sort(reward_list, function(data1, data2)
			return data1.rank[1] < data2.rank[1]
		end)
		return reward_list
	else
		Logger.logAlways("请检查奖励表的配置.......full_service_reward")
		return {}
	end
end

return M
