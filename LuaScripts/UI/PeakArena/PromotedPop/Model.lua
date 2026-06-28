local M = class("PromotedPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	local pro_data = self.m_params.top_arena_data or {}
	self.m_callback = self.m_params.cb
	if next(pro_data) == nil then
		return
	end
	self.is_win = pro_data.win == 1
	self.step = pro_data.step
	self.count = pro_data.count
	local reward_tab = self:getRankRewards()
	local index = self:getRank()
	local cfg = reward_tab[index]
	self.rewards = cfg.reward or {}
end

function M:getReward()
	return self.rewards or {}
end

--胜利
function M:getStepName(index)
	if index == 1 then
		return Language:getTextByKey("peak_str_0057") -- 32强赛
	elseif index == 2 then
		return Language:getTextByKey("peak_str_0056") --"16强赛"
	elseif index == 3 then
		return Language:getTextByKey("peak_str_0055") --"8强赛"
	elseif index == 4 then
		return Language:getTextByKey("peak_str_0054") --"4强赛"
	elseif index == 5 then
		return Language:getTextByKey("peak_str_0061") --"2强"
	elseif index == 6 then
		return Language:getTextByKey("peak_str_0051") --"冠军"
	elseif index == 7 then
		return Language:getTextByKey("peak_str_0053") --"季军"
	end
end

--失败
function M:getSetpRank(index)
	if index == 1 then
		return "33"
	elseif index == 2 then
		return Language:getTextByKey("peak_str_0057")  --"32强" 
	elseif index == 3 then
		return Language:getTextByKey("peak_str_0056")  --"16强"
	elseif index == 4 then
		return Language:getTextByKey("peak_str_0055")  --"8强"
	elseif index == 5 then
		return Language:getTextByKey("peak_str_0054")  --"4强"
	elseif index == 6 then
		return Language:getTextByKey("peak_str_0052") --"亚军"
	elseif index == 7 then
		return Language:getTextByKey("peak_str_0054") --"4强"
	end
end

function M:getSetpRatio()
	local rank_num = 0
	if self.step == 1 then
		rank_num = 33
	elseif self.step == 2 then
		rank_num = 17
	elseif self.step == 3 then
		rank_num = 9
	elseif self.step == 4 then
		rank_num = 5
	elseif self.step == 5 then
		rank_num = 3
	elseif self.step == 6 then
		rank_num = 2
	elseif self.step == 7 then
		rank_num = 4
	end
	return math.floor((1 - (rank_num/self.count)) *100)
end

function M:getRank()
	if self.is_win == true then
		if self.step == 1 then 
			return 6
		elseif self.step == 2 then
			return 5
		elseif self.step == 3 then
			return 4
		elseif self.step == 4 then
			return 4
		elseif self.step == 5 then
			return 2
		elseif self.step == 6 then
			return 1
		elseif self.step == 7 then
			return 2
		else
			return 7	
		end
	else
		if self.step == 1 then 
			return 7
		elseif self.step == 2 then
			return 6
		elseif self.step == 3 then
			return 5
		elseif self.step == 4 then
			return 4
		elseif self.step == 5 then
			return 4
		elseif self.step == 6 then
			return 3
		elseif self.step == 7 then
			return 2
		else
			return 7	
		end
	end
end

function M:getRankRewards()
	local reward_tab = ConfigManager:getCfgByName("arena_reward_list")
	local peak_reward_tab = reward_tab[4]
	local new_tab = {}
	for k,v in pairs(peak_reward_tab) do
		v.id = k
		table.insert(new_tab, v)
	end
	local function sortFunc(id_one, id_two)
		return id_one.id < id_two.id
    end
	table.sort(new_tab, sortFunc)
	return new_tab
end

function M:getDownTime()
	local server_time = UserDataManager:getServerTime()
	local next_fresh_time = TimeUtil.getIntTimestamp(server_time)
	return next_fresh_time + 24*3600
end

return M
