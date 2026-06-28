---@class ArenaRaceChallengeModel:OODataBase
local M = class("ArenaRaceChallengeModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	self.m_match_type = self.m_params.match_type or 0
	M.super.onCreate(self)
	if self.m_match_type == 2 then
		self:getData("race_arena_season_refresh_challenges")
	else
		self:getData("race_arena_refresh_challenges")
	end
end

function M:onEnter()
	self.races = self.m_params.races;
	self.m_daily_times = self.m_params.daily_times
	
	--剩余次数
	self.m_self_rank = self.m_params.self_rank or 0
	self.m_self_score = self.m_params.self_score or 0
	self.m_cross_season = self.m_params.cross_season or 1
	self.remain_time = self.m_params.remain_time or 1
	self.m_open_type = self.m_params.open_type or 0
	self.m_up_nums = self.m_params.up_nums or 0 --天级晋级联赛的人数
	self.m_need_refresh_main = false --关闭界面的时候是否要刷新天级赛地级赛主界面
end

function M:updateParams( m_params )
	self.races = m_params.races;
	--剩余次数
	self.m_daily_times = m_params.daily_times or 0
	self.remain_time = m_params.remain_time or 1;
	self.m_self_rank = m_params.rank or self.m_self_rank
	self.m_self_score = m_params.score or self.m_self_score
	self.m_cross_season = m_params.cross_season or self.m_cross_season
end
function M:isMaxTime()
	local max_times = self:getMaxTimes()
	local cur_times = self.m_daily_times
	local is_max_time = false
	if max_times == 0 then
	elseif cur_times >= max_times then
		is_max_time = true
	end
	return is_max_time
end

function M:getMaxTimes()
	local max_times = ConfigManager:getCommonValueById(448,0)
	return max_times
end

function M:getTopDes()
	local common_cfg_id = 492
	local season = self.m_cross_season
	local target_rank = ConfigManager:getCommonValueById(492,100)
	local target_rank2 = ConfigManager:getCommonValueById(493,100)

	local tips_str = ""
	if self.m_self_rank == 0 then
		tips_str = Language:getTextByKey("new_str_0076")
		return tips_str
	end
	if self.m_match_type == 1 then
		local down_nums =  math.abs(target_rank - target_rank2) --要降级的人数
		if season < 5 then --五星联赛未开启
			if self.m_self_rank > down_nums  then
				tips_str = Language:getTextByKey("arena_str_0021", self.m_self_rank - down_nums)
			else
				tips_str = Language:getTextByKey("arena_str_0022")
			end
		else
			if self.m_up_nums and self.m_up_nums > 0 then
				target_rank = self.m_up_nums
			end
			if self.m_self_rank <= self.m_up_nums  then --能晋级的
				tips_str = Language:getTextByKey("arena_str_0032")
			elseif self.m_self_rank <= down_nums then --可保级的
				tips_str = Language:getTextByKey("arena_str_0031", self.m_self_rank - self.m_up_nums)
			else --掉级的
				tips_str = Language:getTextByKey("arena_str_0021", self.m_self_rank - down_nums)
			end
		end
	elseif self.m_match_type == 2 then
		tips_str = Language:getTextByKey("arena_str_0036")
	else
		if season <= 2 then
			target_rank = ConfigManager:getCommonValueById(492,100)
		else
			target_rank = ConfigManager:getCommonValueById(493,100)
		end
		if self.m_self_rank > target_rank then
			tips_str = Language:getTextByKey("arena_str_0019", self.m_self_rank - target_rank)
		else
			tips_str = Language:getTextByKey("arena_str_0020")
		end
	end
	return tips_str
end

function M:updateData(data)
	table.merge(self.m_data, data)
	self.m_daily_times = data.daily_times or self.m_daily_times
	self.m_self_rank = data.rank or self.m_self_rank
	self.m_self_score = data.score or self.m_self_score
	self.m_cross_season = data.cross_season or self.m_cross_season
end

function M:getListData()
	return self.m_data.challenges
end


function M:getFreeTimes()
	return self.remain_time;
end

function M:refreshFreeTimes()
	local arena_free_times = ConfigManager:getVipValueByKey("race_arena_free_times", 0)
	local free_times =  self.m_data.free_times or 0
	self.remain_time = arena_free_times - free_times
	--return self.remain_time
end

return M
