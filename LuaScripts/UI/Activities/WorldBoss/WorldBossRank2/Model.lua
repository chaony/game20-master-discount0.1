local M = class("WorldBossRank2Model", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_world_boss_reward_cfg = ConfigManager:getCfgByName("world_boss_rewards")
	self.m_data = self.m_params.data
	self.m_boss_id = self.m_params.boss_id
	self:getBoxReward()
end

function M:updateData(data, like_index)
	table.merge(self.m_data, data)
	if like_index and self.m_data.kill_ranks[like_index] then
		self.m_data.kill_ranks[like_index].score = self.m_data.kill_ranks[like_index].score + 1
	end
end

function M:updateAllLikeData()
	if self.m_data.kill_ranks then
		for like_index = 1, #self.m_data.kill_ranks do
			self.m_data.kill_ranks[like_index].score = self.m_data.kill_ranks[like_index].score + 1
		end
	end
end

function M:getRankData()
	return self.m_data.kill_ranks or {}
end

function M:isRecv(index)
	if self.m_data.recv then
		for i, v in pairs(self.m_data.recv) do
			if v == index then
				return true
			end
		end
	end 
	return false
end

function M:isLike(uid)
	if self.m_data.like then
		for i, v in pairs(self.m_data.like) do
			if v == uid then
				return true
			end
		end
	end
	return false
end

function M:getBoxStatus(index)
	local stauts = 0
	if self:isRecv(index) then
		stauts = -1
	elseif index <= #(self:getRankData()) then
		stauts = 2	
	end
	return stauts
end

function M:isHaveRewardCanGet()
	local rank_data = self:getRankData()
	for i = 1, #(rank_data)  do
		if not self:isRecv(i) then
			return true
		end
		local data = rank_data[i]
		local uid = data.user.uid
		if not(self:isLike(uid)) then
			return true
		end
	end
	return false
end

function M:getBoxReward()
	if self.m_world_boss_reward_cfg and next(self.m_world_boss_reward_cfg) and self.m_world_boss_reward_cfg[self.m_boss_id] then
		local reward_data = self.m_world_boss_reward_cfg[self.m_boss_id][self.m_data.boss_hp_cid] or {}
		return reward_data.rewards_all
	end
	return {}
end

return M
