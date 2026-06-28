local M = class("LittleGamesModel", LikeOO.OODataBase)

local __games_data = {
	{name = "new_str_0912", view_name = "LittleGames.PirateCask"},
	{name = "new_str_0913", view_name = "LittleGames.StopTheLock"},
	{name = "new_str_0914", view_name = "LittleGames.FindThePairs.FindThePairsMissions"},
	{name = "new_str_0915", view_name = "LittleGames.JigsawPuzzle"},
}

function M:onCreate()
	M.super.onCreate(self)
	self.is_mult = self.m_params.mult or false --是否是多期小游戏
	self.m_open_type = self.m_params.open_type or ""
	if self.is_mult == true then
		self:getData("mult_rank_info", {version = self.m_params.version or 1, start = 1, stop = 10})
	else
		self:getData("game_street_index", {group_id = self.m_params.group_id})
		self.m_title = self.m_params.title
	end
end

function M:onEnter()
	if self.is_mult == true then
		local game_street = ConfigManager:getCfgByName("mini_game")
		self.m_version = self.m_params.version
		self.m_game_street_cfg = game_street[self.m_version] or {}
		self.m_game_id = self.m_game_street_cfg.game_id
		self.m_game_type = self.m_game_street_cfg.game_type
		self.m_key = self.m_game_street_cfg.key
		self.m_end_ts = self.m_params.end_ts or 0
		self:initMultScoreRewardData()
	else
		local game_street = ConfigManager:getCfgByName("game_street")
		local group_id = self.m_data.group_id or 0
		self.m_group_id = group_id
		self.m_game_street_cfg = game_street[group_id] or {}
		self.m_game_id = self.m_game_street_cfg.game_id
		self.m_game_type = self.m_game_street_cfg.game_type
		self:initScoreRewardData()
	end


end

function M:getShowData()
	return __games_data
end

function M:getRankData()
	return self.m_data.ranks or {}
end

function M:updateData(data)
	table.merge(self.m_data, data)
	if self.is_mult == true then
		self:initMultScoreRewardData()
	else
		self:initScoreRewardData()
	end	
end

--单期市街
function M:initScoreRewardData()
	local data = self.m_data or {}
	local show_data = {}
	local cur_score = data.score or 0
	local score_recv = data.recv or {} -- 奖励领取记录
	local mile = self.m_game_street_cfg.mile or {}
	for index, v in pairs(mile) do
		local status = 0
		if table.keyof(score_recv, index) then
			status = -1-- 已领取
		else
			if cur_score >= index then
				status = 2 -- 可领取
			else
				status = 0 -- 未完成
			end
		end
		table.insert(show_data, {id = index, cfg = {milepost = index, reward = v.reward}, status = status})
	end
	table.sort(show_data, function(data1, data2)
		return data1.id < data2.id
	end)
	self.m_score_reward_data = show_data
	self.m_cur_score = cur_score
end

--多期市街
function M:initMultScoreRewardData()
	local data = self.m_data or {}
	local show_data = {}
	local cur_score = data.score or 0
	local score_recv = self.m_params.recv or {} -- 奖励领取记录 上一个界面 传过来的
	local mile = self.m_game_street_cfg.milepost_data or {}
	for index, v in pairs(mile) do
		local milepost = index or 0
		local status = 0
		if table.keyof(score_recv, index) then
			status = -1-- 已领取
		else
			if cur_score >= milepost then
				status = 2 -- 可领取
			else
				status = 0 -- 未完成
			end
		end
		table.insert(show_data, {id = index, cfg = {milepost = index, reward = v}, status = status})
	end
	table.sort(show_data, function(data1, data2)
		return data1.id < data2.id
	end)
	self.m_score_reward_data = show_data
	self.m_cur_score = cur_score
end

function M:getScoreRewardData()
	return self.m_score_reward_data, self.m_cur_score
end

function M:getSelfRankData()
	local data = {
		score = self.m_data.rank_score,
		rank = self.m_data.rank,
		user = UserDataManager.user_data.user_status or {},
	}
	return data
end


return M
