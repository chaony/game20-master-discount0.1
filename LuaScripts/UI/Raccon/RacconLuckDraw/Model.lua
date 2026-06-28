local M = class("RacconLuckDrawModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_version = self.m_params.version or 1
	self.m_open_id = 346 
	self:getData("user_payment_common_lottery_index", {open_id = self.m_open_id, vsn = self.m_version})
end

function M:onEnter()
	self:dayCompute()
	self.m_is_reward_clear = false
	self.m_hero_cfg_id = ""
	self.m_version = self.m_params.version or 1 
	self.m_background = self.m_params.background
	self.m_hero_skin_data = self.m_params.hero_skin_data or {}
	self.m_active_data = self.m_params.active_data or {}
	self:updataServerData()
end

function M:getMainCfgVByK(key_name)
	local raccon_main_cfg = ConfigManager:getCfgByName("raccon_main") or {}
	local cur_vsn_cfg = raccon_main_cfg[self.m_version] or {}
	local value = cur_vsn_cfg[key_name]
	return value
end

function M:dayCompute()
	local active = UserDataManager:getActivesRechargeDataByOpenId(346)
	if active then
		local start_ts = active.start_ts
		self.m_day = GameUtil:getActityOpenDayCount(start_ts)
		self.m_end_ts = active.end_ts
	end
end

function M:isRewardClear()
	local is_clear = table.nums(self.m_lottery) >= 7
	return is_clear
end

function M:updataServerData(data)
	if data then
		table.merge(self.m_data, data)
	end
	self.m_day_price = self.m_data.day_price or 0
	self.m_lottery = self.m_data.lottery or {}
end

--获取奖励展示数据
function M:getShowData()
	local show_data = {}
	local hero_event_charge = ConfigManager:getCfgByName("raccon_gacha")
	local charge_data = hero_event_charge[self.m_version]
	for i, v in pairs(charge_data) do
		local stute = self:rewardStute(i)
		if v.hero_id and v.hero_id ~= "" then
			self.m_hero_cfg_id = v.hero_id
		end
		table.insert(show_data,{id = i,cfg = v,stute = stute})
	end
	return show_data
end

--获取奖励领取状态
function M:rewardStute(id)
	for i, v in pairs(self.m_lottery) do
		if v == id then
			return 1
		end
	end
	return 0
end

--获得消费价格
function M:getPrice()
	local raccon_gacha_main = ConfigManager:getCfgByName("raccon_gacha_main") or {}
	local cur_act_cfg = raccon_gacha_main[self.m_open_id] or {}
	local event = cur_act_cfg[self.m_version] or {}
	return event.price or 0
end

--判断今日是否已抽奖  0-没抽过 1-可以抽 2-抽完了
function M:todayIsCharge()
	local price = self:getPrice()
	local is_charge = self:IsCharge()
	if is_charge and self.m_day_price >= price then
		return 1
	elseif not is_charge then
		return 2
	end
	return 0
end

--是否今日可抽奖 
function M:IsCharge()
	for i, v in pairs(self.m_lottery) do
		if i == tostring(self.m_day) then
			return false --已抽奖
		end
	end
	return true --可抽奖
end

--获取基本显示信息
function M:BasicInfo()
	local event = ConfigManager:getCfgByName("hero_event")
	--return event[self.m_data.version or 1] or {}
	return event[self.m_version] or {}
end

return M
