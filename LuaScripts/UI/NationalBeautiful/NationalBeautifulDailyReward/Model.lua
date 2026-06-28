local M = class("NationalBeautifulDailyRewardModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_version = self.m_params.version or 1
	self.m_hero_id = self.m_params.hero_id or 101
	self.m_open_id = self.m_params.open_id or 412
	self.m_max_evo = 0
	self.m_daily_recv_rewards = self.m_params.daily_recv_rewards or 0
	local hero_event_daily_reward = ConfigManager:getCfgByName("favor_growth_reward") or {}
	self.m_cur_cfg = hero_event_daily_reward[self.m_open_id][self.m_version] or {}
	local function sortFunc(a, b)
		return a.hero_evo < b.hero_evo
	end
	table.sort(self.m_cur_cfg, sortFunc)
	self.m_hero_id = self.m_cur_cfg[1].hero_id
	self:getMaxEvo()
	self.m_data = {recv = self.m_params.recv}
end

function M:updateServer(data)
	table.merge(self.m_data, data or {})
end

function M:getMaxEvo()
	local max_data = UserDataManager:getHeroMaxEvo(self.m_hero_id)
	if max_data then
		self.m_max_evo = max_data.max_evo or 0
	else
		self.m_max_evo = 0
	end
end

--是否有未领取的奖励
function M:getCurRewardId()
	for i = #self.m_cur_cfg, 1, -1 do
		local quality = self.m_cur_cfg[i].hero_evo
		local is_receive = self:getIsReceive(i)
		if self.m_max_evo >= quality and not is_receive then
			return i
		end
	end
	return nil
end

--可领取的最小奖励id
function M:getCurReceiveId()
	for i = 1,#self.m_cur_cfg do
		local quality = self.m_cur_cfg[i].hero_evo
		local is_receive = self:getIsReceive(i)
		if self.m_max_evo >= quality and not is_receive then
			return i
		end
	end
	return nil
end

--判断是否领取过
function M:getIsReceive(id)
	for i, v in pairs(self.m_data.recv) do
		if v == id then
			return true
		end
	end
	return false
end

return M
