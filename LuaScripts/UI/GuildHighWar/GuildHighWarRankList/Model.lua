local M = class("GuildHighWarRankListModel", LikeOO.OODataBase)

local __TAB_BTN_NODE = {
    { btn_key = "checkpoint_togglebtn", lua_name = "", btn_text = "checkpoint_btn_text", text_key = "new_str_0125", open = true, sort = 1, red_point_img = "checkpoint_red_point_img"}, -- 关卡
    --{ btn_key = "tower_togglebtn", lua_name = "", btn_text = "tower_btn_text", text_key = "new_str_0126", open = true, sort = 2, red_point_img = "tower_red_point_img"}, -- 爬塔
	{ btn_key = "tower_togglebtn", lua_name = "", btn_text = "tower_btn_text", text_key = "new_str_0126", open = true, sort = 4, red_point_img = "tower_red_point_img"}, -- 五行阵
    { btn_key = "score_togglebtn", lua_name = "", btn_text = "score_btn_text", text_key = "new_str_0127", open = true, sort = 3, red_point_img = "score_red_point_img"}, -- 积分
}

local __TAB_BTN_NODE2 = {
    { btn_key = "score_togglebtn_1", lua_name = "", btn_text = "score_btn_text_1", text_key = "new_str_0128", open = true, sort = 1001, red_point_img = "score_red_point_img_1" }, --"帝王丘英雄分数" 青龙
    { btn_key = "score_togglebtn_2", lua_name = "", btn_text = "score_btn_text_2", text_key = "new_str_0129", open = true, sort = 1002, red_point_img = "score_red_point_img_2" }, --"安金城英雄分数" 白虎
}

local __BTN_TYPES = {
	[1] = {name = Language:getTextByKey("new_str_0235")}, --"完成章节",
	[2] = {name = Language:getTextByKey("new_str_0235")}, --"爬塔进度",
}

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	local sort = self.m_params.rank_sort or 1
	-- 1：战绩榜，2：武勋榜，3：观战模式战力榜
	self:getData("guild_high_war_rank_info", {sort = sort, start = 1, stop = 10})
end

function M:onEnter()
	self.m_sel_tab_index = 1
	self.m_open_tab_index = 1
	self.m_btn_cfg = self:getRankCfgByIndex(1)
	self.m_index = self.m_params.index
	self.m_all_rank_types = self.m_params.all_rank_types
	self.m_total_rank_data = {}
	self:initData()
	self.m_cur_select_id = nil -- 天机楼当前选择展开的cell
	self.m_click_self = false --是否点击自己爬塔的详情
	self.big_stage = self.m_params.big_stage --大阶段  1:报名, 2:常规赛, 3:季后赛, 4:展示期
	self.playoff_type = self.m_params.playoff_type --季后赛后使用 -- 1:天级赛, 2:地级赛, 3:玄级赛, 4:人级赛, 5:后备赛
	--奖励
	self.m_total_guild_data = self.m_params.total_guild_data or {}
	self.m_guild_id = UserDataManager.user_data:getUserStatusDataByKey("guild_id")
	self.m_guild_data = self:getGuildDataById(self.m_guild_id) or {}
	self.m_guild_name =  UserDataManager.user_data:getUserStatusDataByKey("guild_name")
	--self.m_guild_high_war_reward_rank_cfg, self.m_cfg_key = self:getCurSeasonRewardCfg()--m_cfg_key 放配置的id
	self.m_index = self.m_params.index
	self.m_cur_box_cfg = self:getCurBoxRewardCfg()
	self.is_fist_quest = true
	
end

function M:initData(data)
	self.m_data = data or self.m_data
	-- 战绩自己排名用
	if self.m_sel_tab_index == 1 then
		self.m_score_z = self.m_data.score
		self.m_citys = self.m_data.citys
		self.m_rank = self.m_data.rank
		self.m_flag = self.m_data.flag
	else
		self.m_rank_ = self.m_data.rank
		self.m_score = self.m_data.score
	end
	self.m_count = self.m_data.count
	self:updateTotalRankData()
	--奖励
	self.m_cfg_key = {}
	self:setRewardData()
end

function M:updateTotalRankData()
	if self.m_total_rank_data[self.m_sel_tab_index] == nil then
		self.m_total_rank_data[self.m_sel_tab_index] = {}
	end
	self.m_total_rank_data[self.m_sel_tab_index] = self.m_data.ranks
end

function M:insertRankData(new_rank_data)
	for i = 1, #new_rank_data do
		table.insert(self.m_total_rank_data[self.m_sel_tab_index], new_rank_data[i])
	end
end

function M:getLoadIndex()
	local max_rank_count = self.m_count
	local cur_rank_nums = table.nums(self:getRankData())
	local start_pos, end_pos = 0, 0
	if cur_rank_nums + 10 <= max_rank_count then
		start_pos = cur_rank_nums + 1
		end_pos = cur_rank_nums + 10
	elseif max_rank_count - cur_rank_nums > 0 then
		start_pos = cur_rank_nums + 1
		end_pos = max_rank_count
	end
	return start_pos, end_pos
end


function M:getRankCfgByIndex(index)
	if __BTN_TYPES[index] then
		return __BTN_TYPES[index]
	end
end

function M:getTabBtnNode()
    return __TAB_BTN_NODE
end

function M:getSortByIndex(index)
    local item = __TAB_BTN_NODE[index] or {}
    return item.sort or -1
end

function M:getTabBtnNode2()
    return __TAB_BTN_NODE2
end

function M:getSortByIndex2(index)
    local item = __TAB_BTN_NODE2[index] or {}
    return item.sort or -1
end

function M:getRankData()
	local ranks = self.m_total_rank_data[self.m_sel_tab_index] or {}
	return ranks
end

function M:getRankItemCount()
	local ranks = self.m_data.ranks or {}
	return #ranks
end

function M:getRankDataByIndex(index)
	local ranks = self.m_data.ranks or {}
	return ranks[index]
end

function M:getOwnRankData()
	local userData = UserDataManager.user_data:getOwnRankData({ rank = self.m_rank, score = self.m_score })
	userData.rank = self.m_rank_ or 0
	return userData
end

function M:getOwnFightRankData() --获取自己战绩排行数据
	local userData = UserDataManager.user_data:getOwnRankData({ rank = self.m_rank, score = self.m_score })
	userData.rank = self.m_rank or 0
	userData.score = self.m_score_z or 0
	userData.citys = self.m_citys or {}
	userData.user.name = userData.user.guild_name
	userData.user.flag = self.m_flag or 0
	return userData
end

function M:getRankRedPointById(id)
	local red_dot =  {}
	local value = red_dot[tostring(id)] or 0
	return value == 1
end

function M:getRankRedPointBySort(sort)
	if sort == 3 then
		for k,v in pairs(__TAB_BTN_NODE2) do
			if self:getRankRedPointById(v.sort) then
				return true
			end
		end
	else
		return self:getRankRedPointById(sort)
	end
	return false
end

function M:updateRedPoint(data)
	local red_dot = self.m_data.red_dot or {}
	red_dot[tostring(data.id)] = data.red_point
end

function M:changeIndex(offset_idx)
	local index = self.m_index + offset_idx
	if index < 1 then
		self.m_index = #self.m_all_rank_types
	elseif index > #self.m_all_rank_types then
		self.m_index = 1
	else
		self.m_index = index
	end
	self.m_rank_cfg = self.m_all_rank_types[self.m_index]
	
end

--- 网络数据回调，需要复写
function M:netData(data, tag)
	if tag == "rank_rank_quest_recv" then
		local quest_id = data.quest_id
		if quest_id then
			local quests = self.m_reward_data.quests or {}
			local quest = quests[tostring(quest_id)]
			if quest then
				quest.recv = 1
			end
			self:initQuestsData()
		end
	end

end
-------------------------------奖励
function M:setRewardData()
	local cfg = ConfigManager:getCfgByName("guild_high_war_reward_rank")
	if cfg then
		for k,v in ipairs(cfg) do
			local list = {}
			for m,n in pairs(v) do
				n.index = m
				table.insert(list,n)
			end
			table.sort(list,function(a, b)
				return a.index < b.index
			end)
			self.m_cfg_key[k] = list
		end
	end
end

function M:getCurBoxRewardCfg()
	local cur_season = 4--UserDataManager:getCurSeason() + 1
	local guild_high_war_reward_day = ConfigManager:getCfgByName("guild_high_war_reward_day") or {}
	local temp_season = 0
	for i, v in pairs(guild_high_war_reward_day) do
		if cur_season >= i then
			temp_season = math.max(temp_season, i)
		end
	end
	return guild_high_war_reward_day[temp_season]
end

function M:UpdateRewardData(response)
	self.m_g_rank = response.g_rank or 0 -- 战绩排名
	self.m_g_score =response.g_score or 0 --战绩
	self.m_r_rank = response.rank or 0 --功勋排名
	self.m_r_score = response.score or 0 --功勋
	--self.m_daily_gift_num = self.m_data.daily_gift_num or {} -- 宝箱总数
	--self.m_daily_gift_num = {}
	--self.m_daily_gift = self.m_data.daily_gift or {} -- // 已领取的宝箱
	--self.m_get_box_nums = self:getBoxNums()
end

function M:getBoxNums()
	local box_nums_tab = {}
	for i, v in pairs(self.m_data.daily_gift) do
		if box_nums_tab[v.box_id] == nil then
			box_nums_tab[v.box_id] = 0
		end
		box_nums_tab[v.box_id] = box_nums_tab[v.box_id] + 1
	end
	return box_nums_tab
end

function M:getGuildDataById(guild_id)
	guild_id = tostring(guild_id)
	if self.m_total_guild_data[guild_id] then
		return self.m_total_guild_data[guild_id]
	end
	return nil
end

function M:getCurSeasonRewardCfg()
	local cur_season = UserDataManager:getCurSeason() + 1
	local guild_high_war_reward_rank = ConfigManager:getCfgByName("guild_high_war_reward_rank") or {}
	local temp_season = 0
	local cfg = {}
	local cfg_key = {}
	for i, v in pairs(guild_high_war_reward_rank) do
		if cur_season >= i then
			temp_season = math.max(temp_season, i)
		end
	end
	if temp_season ~= 0 then
		for i, v in pairs(guild_high_war_reward_rank[temp_season]) do
			local cfg_type = v.type
			if cfg[cfg_type] == nil then
				cfg[cfg_type] = {}
				cfg_key[cfg_type] = {}
			end
			cfg[cfg_type][tostring(i)] = v
			table.insert(cfg_key[cfg_type],i)
		end
	end
	for i, v in pairs(cfg_key) do
		table.sort(cfg_key[i])
	end
	return cfg, cfg_key
end

function M:getCfgDataByTypeAndIndex(cfg_type, index)
	if index and cfg_type then
		local cfg_id = self.m_cfg_key[cfg_type][index]
		local cfg_data = self.m_guild_high_war_reward_rank_cfg[cfg_type][tostring(cfg_id)]
		return cfg_data
	end
	return nil
end
local PLAYOFF_TYPE = {
	[1] = {3,4}, --天
	[2] = {5,6}, --地
	[3] = {7,8}, --玄
	[4] = {9,10}, --人
}
function M:getRankShowDataByType(cfg_type)
	if self.big_stage == 2 or  self.big_stage == 1 then
		return self.m_cfg_key[cfg_type]
	elseif self.big_stage == 3 then
		if self.playoff_type>0 and  self.playoff_type <=4 then
			return self.m_cfg_key[PLAYOFF_TYPE[self.playoff_type][cfg_type]]
		else
			return {}
		end
	end
	return {}
end

function M:getTabBtnNode()
	return __TAB_BTN_NODE
end

function M:getRewardId(index)
	local tag_nums = ConfigManager:getCommonValueById(702,7)
	local reward_id = index + (self.m_cur_daily_index - 1) * tag_nums
	return math.floor(reward_id)
end

function M:getDailyNodeData(index)
	local reward_id = self:getRewardId(index)
	if self.m_daily_gift[tostring(reward_id)] then
		return self.m_daily_gift[tostring(reward_id)]
	end
	return nil
end

function M:getRewardDataByBoxId(box_id)
	if self.m_cur_box_cfg[tonumber(box_id)] then
		return self.m_cur_box_cfg[tonumber(box_id)].box_reward
	end
	return nil
end

function M:updateRedPoint(data)
	local red_dot = self.m_data.red_dot or {}
	red_dot[tostring(data.id)] = data.red_point
end

function M:getTagName()
	--guild_high_war_text_0056
	local tag_nums = ConfigManager:getCommonValueById(702,7)
	local tag_names = {}
	for i = 1, tag_nums do
		table.insert(tag_names, "guild_high_war_text_00" .. 55 + i)
	end
	return tag_names
end

return M
