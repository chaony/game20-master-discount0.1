local M = class("ActiveCurrentDailyRewardModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_version = self.m_params.version or 1
	self.m_hero_id = self.m_params.hero_id or 101
	self.m_max_evo = 0
	self:getMaxEvo()
	self.m_daily_recv_rewards = self.m_params.daily_recv_rewards or 0
	local hero_event_daily_reward = ConfigManager:getCfgByName("hero_event_daily_reward") or {}
	self.m_cur_cfg = hero_event_daily_reward[self.m_version] or {}
	local function sortFunc(a, b)
		return a.quality < b.quality
	end
	table.sort(self.m_cur_cfg, sortFunc)
	self:getCurRewardId()
end

function M:getMaxEvo()
	local max_data = UserDataManager:getHeroMaxEvo(self.m_hero_id)
	if max_data then
		self.m_max_evo = max_data.max_evo or 0
	else
		self.m_max_evo = 0
	end
end

function M:getCurRewardId()
	for i = #self.m_cur_cfg, 1, -1 do
		local quality = self.m_cur_cfg[i].quality
		if self.m_max_evo >= quality then
			return i
		end
	end
	return nil
end

return M
