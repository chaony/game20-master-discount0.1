local M = class("LanternFestivalModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("active_lantern_index")
end

function M:onEnter()
	self:dayCompute()
	self:initData()
	self.m_lantern_festival_cfg = ConfigManager:getCfgByName("lantern_festival") or {}
	self.m_lantern_reward_cfg = ConfigManager:getCfgByName("lantern_reward") or {}
	self.m_help_id = self:getHelpDes()
end

function M:dayCompute()
	local active = UserDataManager:getActivesDataByOpenId(271)
	if active then
		local start_ts = active.start_ts
		self.m_day = GameUtil:getActityOpenDayCount(start_ts)
		self.m_end_ts = active.end_ts
	end
end

function M:initData(response)
	if response then
		table.merge(self.m_data, response)
	end
	self.m_version = self.m_data.version or 1
	self.m_is_done = self.m_data.login_recv or {}--登录奖励领取
	self.m_status = self.m_data.riddle_ans or {}--灯谜数据
	self.m_score = self.m_data.score or 0 --点花灯积分
	self.m_quests = self.m_data.quests or {} --点花灯任务
	self.m_recv_list = self.m_data.recv_list or {} --点花灯抽到的奖励id
	self.m_clothes_gifts = self.m_data.clothes_gifts or {}
	self.m_gifts = self.m_data.gifts or {}
	self.m_exchange = self.m_data.exchange or {}
	self:dayCompute()
end

function M:getHelpDes()
	if self.m_lantern_festival_cfg[self.m_version] then
		return self.m_lantern_festival_cfg[self.m_version].des
	end
	return "get des id from lantern_festival failed"
end

function M:getNeedScore()
	if self.m_lantern_festival_cfg[self.m_version] then
		return self.m_lantern_festival_cfg[self.m_version].score
	end
	return 999
end

function M:getEndTs()
	local active = UserDataManager:getActivesDataByOpenId(271)
	if active and active.end_ts then
		return active.end_ts - UserDataManager:getServerTime()
	end
	return 0
end

function M:getActStatus(open_id)
	open_id = open_id or 271
	local active = UserDataManager:getActivesDataByOpenId(open_id)
	if active and active.open_status then
		return active.open_status
	end
	return 0
end

function M:getFunPlayRedPoint()
	local is_not_full = false
	local cur_lantern_reward_cfg = self.m_lantern_reward_cfg[self.m_version] or {}
	for i, v in pairs(cur_lantern_reward_cfg) do
		local index = table.indexof(self.m_recv_list, i)
		if not(index) then
			is_not_full = true
			break
		end
	end
	if is_not_full then
		if self.m_score >= self:getNeedScore() then
			return true
		end
		for day, v in pairs(self.m_quests) do
			if v.status == 1 then
				return true
			end
		end
	end
	
	return false
end

function M:getRiddlesRedPoint()
	if self.m_day then
		for day, v in pairs(self.m_status) do
			if self.m_day >= tonumber(day) and v.res == 0 then
				return true
			end
		end 
	end
	return false
end
return M
