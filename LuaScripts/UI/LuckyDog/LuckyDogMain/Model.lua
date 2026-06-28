local M = class("LuckyDogMainModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_open_id = 427
	local activity_info = UserDataManager:getActivesDataByOpenId(self.m_open_id) or {}
	self.m_version = activity_info.version or 0
	self:getData("lucky_treasure_index", {open_id = self.m_open_id, vsn = self.m_version})
end

function M:onEnter()
	self.m_tips_index = 0
	self.m_score = self.m_data.score or 0
	self:initGiftData()
end

function M:getOpenID()
	return self.m_open_id
end

function M:getVersion()
	return self.m_version
end

function M:getActiveCfg()
	local gift_tab = ConfigManager:getCfgByName("lucky_treasure") or {}
	local gift_open_id_tab = gift_tab[self.m_open_id] or {}
	local gift_version_tab = gift_open_id_tab[self.m_version] or {}
	return gift_version_tab
end

--积分商店抽奖池的版本号
function M:getLibrary()
	local active_cfg = self:getActiveCfg()
	return active_cfg.library or 0
end

function M:getActiveDes()
	local active_cfg = self:getActiveCfg()
	return active_cfg.des or ""
end

function M:updateGiftData(data)
	table.merge(self.m_data, data)
	self.m_score = self.m_data.score or 0
	self:initGiftData()
end

function M:initGiftData()
	self.m_gift_data = {}
	local gift_tab = ConfigManager:getCfgByName("lucky_treasure_reward") or {}
	local gift_open_id_tab = gift_tab[self.m_open_id] or {}
	local gift_version_tab = gift_open_id_tab[self.m_version] or {}
	local loot_times_data = self.m_data.times or {}
	local amount_data = self.m_data.amount or {}
	for id, amount in pairs(amount_data) do
		local cfg = gift_version_tab[tonumber(id)] or {}
		local loot_times = loot_times_data[id] or 0
		table.insert(self.m_gift_data, {id = id, cfg = cfg, loot_times = loot_times, amount = amount})
	end
end

function M:getGiftData()
	return self.m_gift_data
end

function M:getScore()
	return self.m_score
end

function M:getNextTips()
	local tips_data = self.m_data.big_win_msg or {}
	
	self.m_tips_index = self.m_tips_index + 1
	if self.m_tips_index > #tips_data then
		self.m_tips_index = 1
	end

	local gift_tab = ConfigManager:getCfgByName("lucky_treasure_reward") or {}
	local gift_open_id_tab = gift_tab[self.m_open_id] or {}
	local gift_version_tab = gift_open_id_tab[self.m_version] or {}
	local tips_item = tips_data[self.m_tips_index] or {}
	local reward_data = gift_version_tab[tips_item.reward_id] or {}
	local reward_cfg
	if reward_data.reward then
		reward_cfg = RewardUtil:getProcessRewardData(reward_data.reward[1])
		if tips_item.server_name == nil or tips_item.server_name == "" then
			tips_item.server_name = UserDataManager.server_data:getServerNameById(tips_item.server)
		end
		return Language:getTextByKey("lucky_dog_007", tips_item.server_name or "", tips_item.name or "", tips_item.cost or 0, reward_cfg.name or "" .. "x" .. reward_cfg.data_num or 0)
	end
end

function M:getTimeLeft()
	local left_time = 0
	local activity_info = UserDataManager:getActivesDataByOpenId(self.m_open_id)
	if activity_info then
		local server_time = UserDataManager:getServerTime()
		local end_time = activity_info.end_ts
		left_time = end_time - server_time
	end
	return left_time
end

function M:isShowTime()
	local activity_info = UserDataManager:getActivesDataByOpenId(self.m_open_id)
	if activity_info then
		local server_time = UserDataManager:getServerTime()
		return server_time >= activity_info.show_start_ts
	end
	return false
end

function M:getActiveData()
	local activity_info = UserDataManager:getActivesDataByOpenId(self.m_open_id) or {}
	local active_tab = ConfigManager:getCfgByName("active")
	return active_tab[activity_info.id or 0]
end

return M
