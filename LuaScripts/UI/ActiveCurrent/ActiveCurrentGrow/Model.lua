local M = class("ActiveCurrentGrowModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("hero_gift_index")
end

function M:onEnter()
	--[[
	if self.m_data["end"] == 1 then
		GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
		--self.m_control:updateMsg(99999)
		return
	end
	]]--
	self.m_version = self.m_params.version or 0 
	self.m_daily_recv_rewards = self.m_params.daily_recv_rewards or 0 
	self.m_background = self.m_params.background
	self.m_hero_skin_data = self.m_params.hero_skin_data or {}
	self.m_gift_version = 0
	self.is_tokens = self.m_params.is_token
	self.m_cur_gift_data = nil
	self:getGiftData()

	local hero_event_daily_reward = ConfigManager:getCfgByName("hero_event_daily_reward") or {}
	self.m_cur_hero_event_daily_reward = hero_event_daily_reward[self.m_version] or {}
	local function sortFunc(a, b)
		return a.quality < b.quality
	end
	table.sort(self.m_cur_hero_event_daily_reward, sortFunc)
end

function M:updateNetData(response)
	if response then
		table.merge(self.m_data, response)
	end
	self:getGiftData()
end

function M:getGiftData()
	local hero_event_cfg = ConfigManager:getCfgByName("hero_event") or {}
	local cur_cfg = hero_event_cfg[self.m_version] or {}
	self.m_gift_version = cur_cfg.hero_gift or 0
	self.m_cur_gift_data = nil
	for i, v in pairs(self.m_data.actives) do
		if v.version == self.m_gift_version then
			self.m_cur_gift_data = v
			break
		end
	end
end

function M:getVersion()
	return self.m_version
end

function M:getEndTs()
	if self.m_cur_gift_data then
		return self.m_cur_gift_data.end_ts
	end
	return 0
end

--英雄成长礼包
function M:getGrowUpCfg(verson)
	local hero_gift_show_tab = ConfigManager:getCfgByName("hero_gift_show")
	local hero_gift_tab = ConfigManager:getCfgByName("hero_gift")
	local gift_tab = table.copy(hero_gift_tab[verson or 1]) or {}
	if gift_tab then
		for k,v in pairs(gift_tab) do
			v.id = k
		end
	end
	return hero_gift_show_tab[verson or 1], gift_tab
end

--成长礼包
function M:getGrowUpRewardData(version, id)
	if self.m_data.gifts_detail == nil then
		return
	end
	local data = self.m_data.gifts_detail[tostring(version)]
	local free_get = false
	if data and next(data) ~= nil then
		for k,v in pairs(data.free) do
			if id == v then
				free_get = true
			end
		end
		return free_get, data.pay[tostring(id)] or 0
	end
	return free_get, 0
end

--成长礼包下一个可领的
function M:getGrowUpCanGetReward(version, evo)
	local hero_show_tab, gift_tab = self:getGrowUpCfg(version)
	for i = 1, #gift_tab do
		local cell_data = gift_tab[i]
		local free_get, pay_num = self:getGrowUpRewardData(version, i)
		local can_get = evo >= cell_data.quality
		if can_get == true then
			local pay_get = false
			if (cell_data.time - pay_num) > 0 then
				pay_get = true
			else
				pay_get = false
			end
			if free_get == false or pay_get == true then
				return i
			end
		else
			return i
		end
	end
	return 1
end

function M:haveDailyRedPoint()
	if self.m_daily_recv_rewards == 0 and self:getCurRewardId() then
		return true
	end
	return false
end

function M:getMaxEvo()
	local hero_id = self.m_hero_skin_data.hero
	local max_data = UserDataManager:getHeroMaxEvo(hero_id)
	local max_evo = 0
	if max_data then
		max_evo = max_data.max_evo or 0
	end
	return max_evo
end

function M:getCurRewardId()
	local max_evo = self:getMaxEvo()
	for i = #self.m_cur_hero_event_daily_reward, 1, -1 do
		local quality = self.m_cur_hero_event_daily_reward[i].quality
		if max_evo >= quality then
			return i
		end
	end
	return nil
end

function M:checkActiveIsEnd(end_ts)
	return end_ts > UserDataManager:getServerTime()
end

return M
