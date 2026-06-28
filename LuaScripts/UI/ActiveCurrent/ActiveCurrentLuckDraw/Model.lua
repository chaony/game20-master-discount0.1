local M = class("ActiveCurrentLuckDrawModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_version = self.m_params.version or 1 
	self.m_lottery = self.m_params.lottery or {}
	self.m_background = self.m_params.background
	self.m_hero_skin_data = self.m_params.hero_skin_data or {}
	self.m_active_data = self.m_params.active_data or {}
	self.m_current_day = self.m_params.current_day or 0
	self.m_day_price = self.m_params.day_price or 0
end

function M:updataServerData(data)
	table.merge(self.m_lottery, data.lottery)
end

--获取奖励展示数据
function M:getShowData()
	local show_data = {}
	local hero_event_charge = ConfigManager:getCfgByName("hero_event_charge")
	local cur_season = UserDataManager:getCurSeason()
	local charge_data = hero_event_charge[self.m_version]
	local season = cur_season
	if charge_data[cur_season] == nil then
		season = 0
		for i, v in pairs(charge_data) do
			if i > season and i < cur_season then
				season = i
			end
		end
	end
	for i, v in pairs(charge_data[season]) do
		local stute = self:rewardStute(i)
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
	local event = ConfigManager:getCfgByName("hero_event")
	return event[self.m_version].price or 0
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
		if i == tostring(self.m_current_day) then
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

function M:isRewardClear()
	local is_clear = table.nums(self.m_lottery) >= 7
	return is_clear
end

return M
