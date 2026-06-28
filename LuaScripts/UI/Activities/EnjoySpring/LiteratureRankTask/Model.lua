local M = class("LiteratureRankTaskModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.is_tokens = self.m_params.is_token
	self:getData("enjoy_spring_wenqu_index")
end

function M:onEnter()
	--Logger.log(self.m_data,"enjoy_spring_wenqu_index ======")
	self.m_rank_tab = 1
	self.m_task_tab = self.m_params.task_tab or 1
	self.open_id = 309
	local enjoy_spring_force = ConfigManager:getCfgByName("enjoy_spring_force")
	self.enjoy_spring_force = enjoy_spring_force[self.m_data.version]
	local enjoy_spring_task = ConfigManager:getCfgByName("enjoy_spring_task")
	self.enjoy_spring_task = enjoy_spring_task[self.m_data.version]
	local war_order = ConfigManager:getCfgByName("war_order")
	self.war_order = war_order[self.open_id]
	self:updateData()
end

function M:getEnjoySpringForceCfg(id)
	local id = id or self.m_data.force
	if self.enjoy_spring_force then
		return self.enjoy_spring_force[id]
	end
	return {}
end

function M:setRankTabIndex(index)
	self.m_rank_tab = index
end

function M:setTaskTabIndex(index)
	self.m_task_tab = index
end

function M:updateData(data)
	if data then
		table.merge(self.m_data, data)
	end
	local tongyong_warrior_reward = ConfigManager:getCfgByName("tongyong_warrior_reward")
	if tongyong_warrior_reward[self.open_id] then
		if self.m_data.war_order and self.m_data.war_order.cur_version then
			self.tongyong_warrior_reward = tongyong_warrior_reward[self.open_id][self.m_data.war_order.cur_version]
		end
	end
end

function M:getTask()
	if self.m_task_tab == 1 then
		if self.m_data.my_task and self.m_data.my_task.task_id and self.m_data.my_task.task_id > 0 then
			return self.enjoy_spring_task[tonumber(self.m_data.my_task.task_id)]
		end
	else
		if self.m_data.friend_task and self.m_data.friend_task.task_id and self.m_data.friend_task.task_id > 0then
			return self.enjoy_spring_task[tonumber(self.m_data.friend_task.task_id)]
		end
	end
end

function M:getTaskStatus()
	local self_status = 0
	local friend_status = 0
	if self.m_task_tab == 1 then
		if self.m_data.my_task  then
			if self.m_data.my_task.task_id and self.m_data.my_task.task_id > 0 then
				self_status = self.m_data.my_task[tostring(self.m_data.my_task.task_id)].status
			end
		end
		friend_status = self.m_data.my_task.receive_status
	else
		if self.m_data.friend_task.task_id and self.m_data.friend_task.task_id > 0 then
			self_status = self.m_data.friend_task[tostring(self.m_data.friend_task.task_id)].status
		end
		friend_status = self.m_data.friend_task.invite_status
	end
	return self_status, friend_status
end

function M:getAllTaskStatus()
	local self_status = {0,0}
	local friend_status = {0,0}
		if self.m_data.my_task  then
			if self.m_data.my_task.task_id and self.m_data.my_task.task_id > 0 then
				self_status[1] = self.m_data.my_task[tostring(self.m_data.my_task.task_id)].status
			end
		end
		friend_status[1] = self.m_data.my_task.receive_status
		if self.m_data.friend_task.task_id and self.m_data.friend_task.task_id > 0 then
			self_status[2] = self.m_data.friend_task[tostring(self.m_data.friend_task.task_id)].status
		end
		friend_status[2] = self.m_data.friend_task.invite_status
	return self_status, friend_status
end

function M:getTaskValue()
	local self_value = 0
	local friend_value = 0
	if self.m_task_tab == 1 then
		if self.m_data.my_task  then
			if self.m_data.my_task.task_id and self.m_data.my_task.task_id > 0 then
				self_value = self.m_data.my_task[tostring(self.m_data.my_task.task_id)].value
			end
		end
		friend_value = self.m_data.my_task.receive_value
	else
		if self.m_data.friend_task.task_id and self.m_data.friend_task.task_id > 0 then
			self_value = self.m_data.friend_task[tostring(self.m_data.friend_task.task_id)].value
		end
		friend_value = self.m_data.friend_task.invite_value
	end
	return self_value, friend_value
end

function M:getTaskEndTime()
	if self.m_task_tab == 1 then
		if self.m_data.my_task  then
			if self.m_data.my_task.task_id and self.m_data.my_task.task_id > 0 then
				return self.m_data.my_task[tostring(self.m_data.my_task.task_id)].expire_time
			end
		end
	else
		if self.m_data.friend_task.task_id and self.m_data.friend_task.task_id > 0 then
			return self.m_data.friend_task[tostring(self.m_data.friend_task.task_id)].expire_time
		end
	end
end

function M:getTaskCreateTime()
	if self.m_task_tab == 1 then
		if self.m_data.my_task  then
			if self.m_data.my_task.task_id and self.m_data.my_task.task_id > 0 then
				return self.m_data.my_task[tostring(self.m_data.my_task.task_id)].create_time
			end
		end
	else
		if self.m_data.friend_task.task_id and self.m_data.friend_task.task_id > 0 then
			return self.m_data.friend_task[tostring(self.m_data.friend_task.task_id)].create_time
		end
	end
end

function M:getTaskReceivedCount()
	local received_count = 0
	local max_count = 0
	if self.m_task_tab == 1 then
		if self.m_data then
			received_count = self.m_data.finish_my_task or 0
		end
		max_count = ConfigManager:getCommonValueById(710, 0)
	else
		if self.m_data then
			received_count = self.m_data.receive_friend_task or 0
		end
		max_count = ConfigManager:getCommonValueById(720, 0)
	end
	return received_count, max_count
end

function M:getFriendReceiveTaskTime()
	if self.m_data.my_task  then
		return self.m_data.my_task.receive_task_time
	end
end

function M:getRankUser(index)
	if self.m_rank_tab == 1 then
		if self.m_data.one_force_rank.ranks and self.m_data.one_force_rank.ranks[index] then
			return self.m_data.one_force_rank.ranks[index]
		end
	else
		if self.m_data.force_rank.ranks and self.m_data.force_rank.ranks[index] then
			return self.m_data.force_rank.ranks[index]
		end
	end
end

function M:getFreshTaskCost()
	local renovate = ConfigManager:getCfgByName("renovate")
	if renovate[22] then
		return renovate[22].cost[1]
	end
end

function M:getWarriorCfg()
	return self.war_order, self.tongyong_warrior_reward
end

function M:getWrriorRewardStatus(id)
	local status = 0
	if self.m_data.war_order then
		if table.keyof(self.m_data.war_order.free_received, tonumber(id)) then
			status = 2
		elseif table.keyof(self.m_data.war_order.pay_received, tonumber(id)) then
			status = 2
		else
			if self.tongyong_warrior_reward then
				local cfg = self.tongyong_warrior_reward[id]
				if cfg then
					if cfg.fee_incentives and next(cfg.fee_incentives) ~= nil then
						local pay_status = self:getwrriorPayStatus()
						if pay_status > 0 and self.m_data.war_order.ms and self.m_data.war_order.ms >= cfg.condition then
							status = 1
						end
					else
						if self.m_data.war_order.ms and self.m_data.war_order.ms >= cfg.condition then
							status = 1
						end
					end
				end
			end
		end
	end
	return status
end

function M:getWrriorValue()
	local value = 0
	if self.m_data.war_order then
		value = self.m_data.war_order.ms or 0
	end
	return value
end

function M:getwrriorPayStatus()
	if self.m_data.war_order then
		return self.m_data.war_order.pay_status
	else
		return 0
	end
end

function M:getActiveCfgByOpenId(open_id)
	local active_tab = ConfigManager:getCfgByName("active")
	for i,v in pairs(active_tab) do
		if v.open_id == open_id then
			return v
		end
	end
	local active_recharge_tab = ConfigManager:getCfgByName("active_recharge")
	for i,v in pairs(active_recharge_tab) do
		if v.open_id == open_id then
			return v
		end
	end
	return nil
end

function M:getActStatus()
	local active = UserDataManager:getActivesDataByOpenId(self.open_id)
	if active and active.open_status then
		return active.open_status
	end
	return 0
end

return M
