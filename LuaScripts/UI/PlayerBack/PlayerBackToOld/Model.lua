local M = class("PlayerBackToOldModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_callback = self.m_params.callback
	self.m_callback_new = self.m_params.callback_new
	self.m_reward_data = {}
	self.m_day = math.floor((UserDataManager:getServerTime() - UserDataManager.comeback_ts or 0) / (60 * 60 * 24)) + 1
	if self.m_day > 7 then
		self.m_day = 7
	elseif self.m_day < 1 then
		self.m_day = 1
	end
	self.day_word_cache = {"第一天", "第二天", "第三天", "第四天", "第五天", "第六天", "第七天", "第八天", "第九天", "第十天", }
	self:updateRewardData()
end

function M:updateRewardData()
	local turn_back_tab = ConfigManager:getCfgByName("turnback") or {}
	local vip_level_tab = ConfigManager:getCfgByName("vip") or {}
	local vip_exp = UserDataManager.comeback_vip or 0
	local vip_lev = 0
	for level, item in ipairs(vip_level_tab) do
		if vip_exp < item.exp then
			break
		end
		vip_lev = level
	end
	if turn_back_tab[vip_lev] then
		self.m_reward_data = turn_back_tab[vip_lev].days
	end
end

function M:getRewardData()
	return self.m_reward_data
end

function M:getCurrentDay()
	return self.m_day
end

function M:getDayWordContent(day_num)
	return self.day_word_cache[day_num]
end

--7日数据
function M:getRewardStatus(day)
	if day > self.m_day then
		return 0 --未开启
	end
	local reward_got = UserDataManager.comeback_rcvd or {}
	for _, value in ipairs(reward_got) do
		if value == day then
			return 2 --已领取
		end
	end
	return 1 --待领取
end

return M
