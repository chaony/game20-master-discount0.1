local M = class("RacconModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("raccon_index")
end

function M:onEnter()
	self.m_is_tokens = self.m_params.is_token
	self:dayCompute()
	self:getLittleGameCfg()
	self.m_help_id = 0-- self:getHelpDes()
	self:updateData()
end

function M:updateData(response)
	if response then
		table.merge(self.m_data,response)
	end
	self.m_version = self:getActVsn()
	self.m_finish_option = self.m_data.finish_option or {}
	self.m_finish_stage = self.m_data.finish_stage or {}
	self.m_chapter_recv = self.m_data.chapter_recv or {}
	self.m_stage_recv = self.m_data.stage_recv or {}
	self.m_health = self.m_data.health or 0
end

function M:getOpenCfgNameById(open_id)
	local open_condition = ConfigManager:getCfgByName("open_condition")
	local o_item = open_condition[open_id] or {}
	local name = o_item.name
	return name
end

function M:getMainCfgVByK(key_name)
	local raccon_main_cfg = ConfigManager:getCfgByName("raccon_main") or {}
	local cur_vsn_cfg = raccon_main_cfg[self.m_version] or {}
	local value = cur_vsn_cfg[key_name]
	return value
end

function M:getLittleGameCfg()
	local little_game_open_id = 342
	local tongyong_little_game = ConfigManager:getCfgByName("tongyong_little_game") or {}
	local tongyong_little_game_end = ConfigManager:getCfgByName("tongyong_little_game_end")
	local cur_game_cfg = tongyong_little_game[little_game_open_id] or {}
	local cur_vsn_cfg = cur_game_cfg[self.m_version] or {}
	local game_id = cur_vsn_cfg.game_id or 0
	return game_id
end

function M:dayCompute()
	local active = UserDataManager:getActivesRechargeDataByOpenId(346)
	if active then
		local start_ts = active.start_ts
		self.m_day = GameUtil:getActityOpenDayCount(start_ts)
		self.m_end_ts = active.end_ts
	end
end

--计算时间
function M:setCurrentDay()
	local cur_tim = UserDataManager:getServerTime() --当前时间
	local surplus_time = cur_tim - self.m_params.open_active_data.start_ts --从活动开始到当前时间的差值
	local remain_day, remain_hour, remain_min, remain_sec = GameUtil:getTimeLayoutBySecond(surplus_time) --换算活动开启时间
	remain_day = remain_day + 1
	if remain_day < 1 then
		remain_day = 1
	elseif remain_day > 7 then
		remain_day = 7
	end
	return remain_day
end


function M:getEndTs()
	local active = UserDataManager:getActivesDataByOpenId(339)
	if active and active.end_ts then
		return active.end_ts - UserDataManager:getServerTime() + 2
	end
	return 0
end

function M:getActStatus(open_id)
	open_id = open_id or 339
	local active = UserDataManager:getActivesDataByOpenId(open_id)
	if active and active.open_status then
		return active.open_status
	end
	return 0
end

function M:getActVsn(open_id, is_recharge)
	open_id = open_id or 339
	local active = nil
	if is_recharge then
		active = UserDataManager:getActivesRechargeDataByOpenId(open_id)
	else
		active = UserDataManager:getActivesDataByOpenId(open_id)
	end 
	if active and active.version then
		return active.version
	end
	return 1
end

return M
