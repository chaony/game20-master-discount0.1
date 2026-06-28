local M = class("HotelModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("hotel_index")
end

function M:onEnter()
	self.m_open_ts = self.m_data.open_ts
	self.m_his_coin = self.m_data.his_coin
	self.m_his_run_times = self.m_data.his_run_num
	self.m_is_daily_reward = self.m_data.daily_awarded
	self.m_times = self.m_data.lave_daily_run_num
	self.m_level = self.m_data.level
	self.m_rooms_lv = self.m_data.room_levels --当前房间等级
	self.m_back_spine_res = self:getBackSpineRes(self.m_level)
end

--更新酒楼每日经营次数、金券、历史经营次数
function M:updateTimesAndCoin(times, his_coin, his_run_times)
	self.m_times = times
	self.m_his_coin = his_coin
	self.m_his_run_times = his_run_times
end

--更新酒楼每日奖励
function M:updateDailyRewardState()
	self.m_is_daily_reward = true
end

--更新酒楼等级
function M:updateLevel(level)
	self.m_level = level
end

--酒楼经营时间——天
function M:getRunDay()
	local second = UserDataManager:getServerTime() - self.m_open_ts
	local day, hour, min, sec = GameUtil:getTimeLayoutBySecond(second)
	return day + 1
end

--酒楼红点
function M:isRoomRedPoint(room_id)
	local cfg = self:getRoomCfg(room_id)
	local game_group_id = cfg.game_street_groups[1]
	--点击红点
	local click_array = UserDataManager:getRedDotByKey("game_street_click")
	if type(click_array) == "table" then
		local index = table.keyof(click_array, game_group_id)
		if index ~= nil then
			return true
		end
	end
	--里程碑奖励红点
	local mile_array = UserDataManager:getRedDotByKey("game_street_mile")
	if type(mile_array) == "table" then
		local index = table.keyof(mile_array, game_group_id)
		if index ~= nil then
			return true
		end
	end
	return false
end

--酒楼抽卡红点
function M:isGachaRedPoint(room_id)
	local gacha_times = UserDataManager:getRedDotByKey("hotel_gacha_num") --酒楼抽卡次数>=5
	if type(gacha_times) == "table" then
		local index = table.keyof(gacha_times, room_id)
		if index ~= nil then
			return true
		end
	end
	return false
end

--根据酒楼等级，获取背景spine
function M:getBackSpineRes(hotel_level)
	local cfg = ConfigManager:getCfgByName("hotel_level")
	local level_cfg = cfg[hotel_level]
	local spine_res = level_cfg.res
	return spine_res
end

--获取某个房间的基本配置
function M:getRoomCfg(room_id)
	local base_cfg = ConfigManager:getCfgByName("hotel_room_base")
	local cfg = base_cfg[room_id]
	return cfg
end

return M