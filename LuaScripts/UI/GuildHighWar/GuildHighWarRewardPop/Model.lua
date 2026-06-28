local M = class("GuildHighWarRewardPopModel", LikeOO.OODataBase)

local __TAB_BTN_NODE = {
    { btn_key = "checkpoint_togglebtn", lua_name = "", btn_text = "checkpoint_btn_text", text_key = "new_str_0125", open = true, sort = 1, red_point_img = "checkpoint_red_point_img"}, -- 关卡
    --{ btn_key = "tower_togglebtn", lua_name = "", btn_text = "tower_btn_text", text_key = "new_str_0126", open = true, sort = 2, red_point_img = "tower_red_point_img"}, -- 爬塔
	{ btn_key = "tower_togglebtn", lua_name = "", btn_text = "tower_btn_text", text_key = "new_str_0126", open = true, sort = 4, red_point_img = "tower_red_point_img"}, -- 五行阵
    { btn_key = "score_togglebtn", lua_name = "", btn_text = "score_btn_text", text_key = "new_str_0127", open = true, sort = 3, red_point_img = "score_red_point_img"}, -- 积分
}

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	local sort = self.m_params.id
	self:getData("guild_high_war_daily_gift_index")
end

function M:onEnter()
	self:updateData()
	self.is_watch = self.m_params.is_watch
	self.m_sel_tab_index = next(self.m_daily_gift_num) and 1 or 2
	self.m_open_tab_index = next(self.m_daily_gift_num) and 1 or 2
	self.m_cur_daily_index = 1 --每日奖励里的页签
	self.m_total_guild_data = self.m_params.total_guild_data or {}
	self.m_guild_id = UserDataManager.user_data:getUserStatusDataByKey("guild_id")
	self.m_guild_data = self:getGuildDataById(self.m_guild_id) or {}
	--self.m_guild_high_war_reward_rank_cfg, self.m_cfg_key = self:getCurSeasonRewardCfg()--m_cfg_key 放配置的id
	self.m_index = self.m_params.index
	self.m_cur_box_cfg = self:getCurBoxRewardCfg()
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

function M:updateData(response)
	if response then
		table.merge(self.m_data, response)
	end
	self.m_g_rank = self.m_data.g_rank or 0 -- 战绩排名
	self.m_g_score = self.m_data.g_score or 0 --战绩
	self.m_rank = self.m_data.rank or 0 --功勋排名
	self.m_score = self.m_data.score or 0 --功勋
	--self.m_daily_gift_num = self.m_data.daily_gift_num or {} -- 宝箱总数
	self.m_daily_gift_num = {}
	self.m_daily_gift = self.m_data.daily_gift or {} -- // 已领取的宝箱
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

function M:getRankShowDataByType(cfg_type)
	local cfg_key = self.m_cfg_key[cfg_type] or {}
	return cfg_key
end

function M:initData(data)
	self.m_data = data or self.m_data
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
