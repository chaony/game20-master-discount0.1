local M = class("DragonswordStoryModel",LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end


function M:onEnter()
	self.m_version = self.m_params.version  --版本号
	self.m_open_data = self.m_params.open_data --开启时间
	self.m_active_data = self.m_params.active_data
	self.m_login_recv = self.m_params.login_recv or {} --领取数据
	self.m_start_time = self:stringTimeByNumberTime(self.m_active_data.start_time) --活动开始时间
	self.m_end_time = self:stringTimeByNumberTime(self.m_active_data.end_time)  --活动结束时间
	self.m_current_start_day = self.m_params.current_day or 0  --当前日期为活动开启后的第几天
	self.m_current_open_day = self.m_current_start_day  --当前要展开故事id（天数）
end

--刷新领取数据
function M:updateServerData(response)
	self.m_login_recv = response.login_recv
end

--获取故事
function M:getStorData()
	local dragonsword_login = ConfigManager:getCfgByName("dragonsword_login")
	return dragonsword_login[self.m_version]
end

--时间转换  从具体年月日转换为时间戳
function M:stringTimeByNumberTime(time_string)
	local _, _, y, moth, d, h, mi, s = string.find(time_string, "(%d+)-(%d+)-(%d+)%s*(%d+):(%d+):(%d+)")
	 return os.time({year = y, month = moth, day = d, hour = h, min = mi, sec = s})
end

--获取活动开始时间
function M:getCurrentDay()
	local cur_tim = UserDataManager:getServerTime() --当前时间
	local surplus_time = cur_tim - self.m_start_time --从活动开始到当前时间的差值
	local remain_day, remain_hour, remain_min, remain_sec = GameUtil:getTimeLayoutBySecond(surplus_time) --换算活动开启时间
	return remain_day + 1
end

--获取奖励是否已领取
function M:getRewardIsReceive(day_id)
	for i, v in pairs(self.m_login_recv) do
		if v == day_id then
			return true
		end
	end
	return false
end

return M
