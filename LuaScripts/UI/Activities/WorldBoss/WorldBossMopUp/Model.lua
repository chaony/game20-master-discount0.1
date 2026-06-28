local M = class("WorldBossMopUpModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_data = self.m_params.data
	self.m_boss_id = self.m_params.boss_id
	self.m_boss_hp_cid = self.m_data.boss_hp_cid
end

-- function M:getRewardBoxNum()
-- 	local num = 0
-- 	local max_damage = self.m_data.max_damage or 0
-- 	local world_boss = ConfigManager:getCfgByName("world_boss")
-- 	local world_boss_item = world_boss[self.m_boss_id] or {}
-- 	local reward_lost_hp = world_boss_item.reward_lost_hp or {}
-- 	for k,v in ipairs(reward_lost_hp) do
-- 		if v < max_damage then
-- 			num = k
-- 		end
-- 	end
-- 	return num
-- end

function M:getRewardBoxNum()
	local num = 0
	local max_damage = self.m_data.max_damage or 0
	local reward_lost_hp = self:getNewBossRewardCfg()
	if not(next(reward_lost_hp)) then
		local world_boss = ConfigManager:getCfgByName("world_boss")
		local world_boss_item = world_boss[self.m_boss_id] or {}
		reward_lost_hp = world_boss_item.reward_lost_hp or {}
	end
	for k,v in ipairs(reward_lost_hp) do
		if v < max_damage then
			num = k
		end
	end
	return num
end

function M:getNewBossRewardCfg()
	local world_boss_reward_cfg = ConfigManager:getCfgByName("world_boss_rewards")
	if world_boss_reward_cfg and next(world_boss_reward_cfg) and world_boss_reward_cfg[self.m_boss_id] then
		local reward_data = world_boss_reward_cfg[self.m_boss_id][self.m_boss_hp_cid]
		return reward_data.reward_lost_hp
	end
	return {}
end

return M
