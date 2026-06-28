---@class ArenaPeakChallengeModel:OODataBase
local M = class("ArenaPeakChallengeModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	self.m_match_type = self.m_params.match_type or 0
	self.m_ban_num=self.m_params.ban_num
	self.m_forbidden_hero_ids=self.m_params.heros_ban
	self.rise_id=self.m_params.rise_id
	self.m_week_rule=self.m_params.week_rule
	if self.rise_id then
		local cfg=ConfigManager:getCfgByName("rise_arena_base")[self.rise_id]
		self.team_num=cfg.team_num
	end
	M.super.onCreate(self)
	self:getData("rise_arena_rivals_info")
end

function M:onEnter()
	self.races = self.m_params.races;
	self.m_daily_times = self.m_params.daily_times
	
	--剩余次数
	self.m_self_rank = self.m_params.self_rank or 0
	self.m_self_score = self.m_params.self_score or 0
	self.m_cross_season = self.m_params.cross_season or 1
	--self.remain_time = self.m_params.remain_time or 1

	self.refresh_cd =self.m_data.rival_refresh_cd
	self.rise_id=self.m_params.rise_id
	self.ban_num=self.m_params.ban_num
	self.m_battle_mode=self.m_params.battle_mode
	self.lave_dare_num=self.m_params.lave_dare_num

	self.m_open_type = self.m_params.open_type or 0
	self.m_up_nums = self.m_params.up_nums or 0 --天级晋级联赛的人数
	self.m_need_refresh_main = false --关闭界面的时候是否要刷新天级赛地级赛主界面
end

function M:updateParams( m_params )
	self.races = m_params.races;
	--剩余次数
	self.m_daily_times = m_params.daily_times or 0
	--self.remain_time = m_params.remain_time or 1;
	self.m_self_rank = m_params.rank or self.m_self_rank
	self.m_self_score = m_params.score or self.m_self_score
	--self.m_cross_season = m_params.cross_season or self.m_cross_season

	self.rise_id=m_params.rise_id
	self.ban_num=m_params.ban_num
	self.m_battle_mode=m_params.battle_mode
end
function M:isMaxTime()
	--local max_times = self:getMaxTimes()
	--local cur_times = self.m_daily_times
	--local is_max_time = false
	--if max_times == 0 then
	--elseif cur_times >= max_times then
	--	is_max_time = true
	--end
	--return is_max_time
	return self.lave_dare_num<=0
end

function M:getMaxTimes()
	local max_times = ConfigManager:getCommonValueById(448,0)
	return max_times
end

function M:getTopDes()
	--local common_cfg_id = 492
	--local season = self.m_cross_season
	--local target_rank = ConfigManager:getCommonValueById(492,100)
	--local target_rank2 = ConfigManager:getCommonValueById(493,100)
	--
	local tips_str = ""
	--if self.m_self_rank == 0 then
	--	tips_str = Language:getTextByKey("new_str_0076")
	--	return tips_str
	--end
	--if self.m_match_type == 1 then
	--	local down_nums =  math.abs(target_rank - target_rank2) --要降级的人数
	--	if season < 5 then --五星联赛未开启
	--		if self.m_self_rank > down_nums  then
	--			tips_str = Language:getTextByKey("arena_str_0021", self.m_self_rank - down_nums)
	--		else
	--			tips_str = Language:getTextByKey("arena_str_0022")
	--		end
	--	else
	--		if self.m_up_nums and self.m_up_nums > 0 then
	--			target_rank = self.m_up_nums
	--		end
	--		if self.m_self_rank <= self.m_up_nums  then --能晋级的
	--			tips_str = Language:getTextByKey("arena_str_0032")
	--		elseif self.m_self_rank <= down_nums then --可保级的
	--			tips_str = Language:getTextByKey("arena_str_0031", self.m_self_rank - self.m_up_nums)
	--		else --掉级的
	--			tips_str = Language:getTextByKey("arena_str_0021", self.m_self_rank - down_nums)
	--		end
	--	end
	--elseif self.m_match_type == 2 then
	--	tips_str = Language:getTextByKey("arena_str_0036")
	--else
	--	if season <= 2 then
	--		target_rank = ConfigManager:getCommonValueById(492,100)
	--	else
	--		target_rank = ConfigManager:getCommonValueById(493,100)
	--	end
	--	if self.m_self_rank > target_rank then
	--		tips_str = Language:getTextByKey("arena_str_0019", self.m_self_rank - target_rank)
	--	else
	--		tips_str = Language:getTextByKey("arena_str_0020")
	--	end
	--end
	local cfg=ConfigManager:getCfgByName("rise_arena_base")
	local target_rank=cfg[self.rise_id].promote_rank
	local index=0
	if target_rank then
		if self.m_self_rank > target_rank then
			index=50+self.rise_id
			tips_str = Language:getTextByKey("arena_str_00"..index, self.m_self_rank - target_rank)
		else
			index=54+self.rise_id
			tips_str = Language:getTextByKey("arena_str_00"..index)
		end
	end

	return tips_str
end

function M:updateData(data)
	table.merge(self.m_data, data)
	--self.m_daily_times = data.daily_times or self.m_daily_times
	self.m_self_rank = data.rank or self.m_self_rank
	self.m_self_score = data.score or self.m_self_score
	--self.m_cross_season = data.cross_season or self.m_cross_season


	self.refresh_cd =self.m_data.rival_refresh_cd
end

function M:getListData()
	return self.m_data.rivals
end

function M:getFreeTimes()
	self.remain_time=self.lave_dare_num
	return self.remain_time;
end


function M:refreshFreeTimes()
	local arena_free_times = ConfigManager:getVipValueByKey("race_arena_free_times", 0)
	local free_times =  self.m_data.free_times or 0
	self.remain_time = arena_free_times - free_times
	--return self.remain_time
end

return M
