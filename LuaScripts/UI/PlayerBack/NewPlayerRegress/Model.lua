local M = class("NewPlayerRegressModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_callback = self.m_params.callback
	self.m_callback_new = self.m_params.callback_new
	self.m_reward_data = {}
	self.m_day = math.floor((UserDataManager:getServerTime() - UserDataManager.new_comeback_ts or 0) / (60 * 60 * 24)) + 1
	if self.m_day > 7 then
		self.m_day = 7
	elseif self.m_day < 1 then
		self.m_day = 1
	end
	self.day_word_cache = {"oldPlayer_text_0001", "oldPlayer_text_0002", "oldPlayer_text_0003", "oldPlayer_text_0004", "oldPlayer_text_0005", 
						   	"oldPlayer_text_0006", "oldPlayer_text_0007", "oldPlayer_text_0008", "oldPlayer_text_0009", "oldPlayer_text_0010", }
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
		self.m_reward_data = turn_back_tab[vip_lev].new_days
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
