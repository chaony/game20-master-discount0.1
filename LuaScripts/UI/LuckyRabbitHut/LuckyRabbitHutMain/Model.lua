local M = class("LuckyRabbitHutMainModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	--local m_params = self.m_params --获取参数
	self:getData("rabbit_index")
end

function M:onEnter()
	self.mileage_cfg = ConfigManager:getCfgByName("rabbit_mileage")
	self.notice_cfg =  ConfigManager:getCfgByName("rabbit_notice")
	self.gacha_reward_cfg = ConfigManager:getCfgByName("rabbit_gacha_reward")

	self:getActiveTs()
	self:initData()
	
end

function M:initData(data)
	--init net data
	self.m_data = data or self.m_data
	
	self.m_version = self.m_data.version
	self.m_daily_time = self.m_data.daily_times	--今日抽奖次数
	self.m_self_rank = self.m_data.self_rank	--自己抽奖排名
	self.m_self_times = self.m_data.self_times	--自己抽奖总次数
	self.m_total_times = self.m_data.total_times	--跨服组抽奖总次数
	self.m_bonus_info = self.m_data.bonus_info	--股份信息

	self.gacha_cfg =  ConfigManager:getCfgByName("rabbit_gacha")
	self.rabbit_ticket_data = self.gacha_cfg[self.m_version].gacha[1]
	
	local rabbit_gacha = ConfigManager:getCfgByName("rabbit_notice")
	self.gacha_cfg = rabbit_gacha[self.m_version]
	local rabbit_mileage =  ConfigManager:getCfgByName("rabbit_mileage")
	self.mileage_cfg = rabbit_mileage[self.m_version]
end

function M:getBonusInfo()
	local self_bonus = self.m_bonus_info.self_bonus --个人分红奖励
	local self_bonus_rank = self.m_bonus_info.self_bonus_rank	--个人排名奖励
	local self_bonus_total = self.m_bonus_info.self_bonus_total	--个人总奖励
	local self_rate = self.m_bonus_info.self_rate	--个人股份
	local total_jackpot = self.m_bonus_info.total_jackpot	--跨服组分红奖池
	local total_rate = self.m_bonus_info.total_rate	--跨服组总分红比例
	
	local result = {}
	result.jackpot = total_jackpot --self.m_total_times * total_rate
	result.rate = self_rate
	result.bonus = self_bonus
	result.bonus_total = self_bonus_total
	
	return result
end

function M:refreshData()
	local callback = function (data)	
		self:initData(data)	
	end
	self:getNetData("rabbit_index", nil , callback)
end


function M:getActiveByOpenId()
	local active_tab = ConfigManager:getCfgByName("active")
	for i, v in pairs(active_tab) do
		if v.open_id == 433 and v.version == (self.m_version or 1) then
			return v
		end
	end
	return nil
end

--UserDataManager:getActivesDataByOpenId() 获取活动数据
function M:getActiveTs()
	local active_cfg = self:getActiveByOpenId()
	local cur_ts = UserDataManager:getServerTime()
	if active_cfg then
		local start_time = active_cfg.start_time
		local end_time = active_cfg.end_time
		local show_time = active_cfg.show_time
		self.start_ts = self:stringTimeByNumberTime(start_time)	--活动开启时间
		self.end_ts = self:stringTimeByNumberTime(end_time)		--活动总结束时间戳
		self.show_ts = self:stringTimeByNumberTime(show_time)
		self.is_show_date = cur_ts >= self.end_ts and cur_ts <= self.show_ts
	end
	return self.start_ts , self.end_ts , self.show_ts
end

function M:stringTimeByNumberTime(time_string)
	local _, _, y, moth, d, h, mi, s = string.find(time_string, "(%d+)-(%d+)-(%d+)%s*(%d+):(%d+):(%d+)")
	return os.time({year = y, month = moth, day = d, hour = h, min = mi, sec = s})
end

--获取额外解锁的分红比例
function M:getExReturnRatio()
	local exRatio = 0
	for i, v in ipairs(self.mileage_cfg) do
		if self.m_total_times >= v.times then
			exRatio = exRatio + v["return"]
		end
	end
	return exRatio
end

function M:destroy()

	M.super.destroy(self)
end

return M