local M = class("WdTowerRankModel", LikeOO.OODataBase)

local __TAB_BTN_NODE = {
    { btn_key = "checkpoint_togglebtn", lua_name = "", btn_text = "checkpoint_btn_text", text_key = "new_str_0125", open = true, sort = 1, red_point_img = "checkpoint_red_point_img"}, -- 关卡
    --{ btn_key = "tower_togglebtn", lua_name = "", btn_text = "tower_btn_text", text_key = "new_str_0126", open = true, sort = 2, red_point_img = "tower_red_point_img"}, -- 爬塔
	{ btn_key = "tower_togglebtn", lua_name = "", btn_text = "tower_btn_text", text_key = "new_str_0126", open = true, sort = 4, red_point_img = "tower_red_point_img"}, -- 五行阵
}

local __TAB_BTN_NODE2 = {
    { btn_key = "score_togglebtn_1", lua_name = "", btn_text = "score_btn_text_1", text_key = "new_str_0128", open = true, sort = 1001, red_point_img = "score_red_point_img_1" }, --"帝王丘英雄分数" 青龙
    { btn_key = "score_togglebtn_2", lua_name = "", btn_text = "score_btn_text_2", text_key = "new_str_0129", open = true, sort = 1002, red_point_img = "score_red_point_img_2" }, --"安金城英雄分数" 白虎
}

local __BTN_TYPES = {
	[1] = { name = Language:getTextByKey("new_str_0235")}, --"完成章节",
	[2] = {name = Language:getTextByKey("new_str_0235")}, --"爬塔进度",
}

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self.m_vsn = self.m_params.vsn or 1
	self:getData("wdtower_rank_info", {vsn = self.m_vsn, start = 1, stop = 50})
end

function M:getDesByKey(get_key)
	local vsn = self.m_vsn or 1
	local yinyang_tower_version = ConfigManager:getCfgByName("wdtower_base") or {}
	if yinyang_tower_version and yinyang_tower_version[vsn] and yinyang_tower_version[vsn][get_key] then
		return yinyang_tower_version[vsn][get_key]
	end
	return nil
end

function M:getRewardData(net_callback)
	local function callback(response)
		self.m_reward_data = response
		self:initQuestsData()
		net_callback()
	end
	self:getNetData("rank_rank_quest_info",{sort = self.m_params.id}, callback)
end

function M:onEnter()
	self.m_sel_tab_index = nil
	self.m_open_tab_index = 1
	--self.m_rank_cfg = self.m_params.rank_cfg or {}
	--self.m_rank_cfg.id = 1
	--self.m_btn_cfg = self:getRankCfgByIndex(self.m_rank_cfg.id)
	--self.m_id = self.m_data.sort
	Logger.log(self.m_id, "mid =======")
	self.m_index = self.m_params.index
	--self.m_all_rank_types = self.m_params.all_rank_types
	--self.m_cur_select_id = nil -- 天机楼当前选择展开的cell
	--self.m_click_self = false --是否点击自己爬塔的详情
end

function M:getRankCfgByIndex(index)
	if __BTN_TYPES[index] then
		return __BTN_TYPES[index]
	end
end

function M:getRewardData()
	local game_street_rank_cfg = {}
	local rank_cfg = ConfigManager:getCfgByName("wdtower_tower_ranking")
	if rank_cfg[self.m_vsn] then
		game_street_rank_cfg = rank_cfg[self.m_vsn]
	end
	return game_street_rank_cfg
end

function M:initData(data)
	self.m_data = data or self.m_data
end

function M:getTabBtnNode()
    return __TAB_BTN_NODE
end

function M:getTabBtnNode2()
    return __TAB_BTN_NODE2
end

function M:getRankData()
	local ranks = self.m_data.ranks or {}
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
	local data = UserDataManager.user_data:getOwnRankData(self.m_data)
	data.active_combat = self.m_data.active_combat or 0
	return data
end

function M:getRankRedPointById(id)
	local red_dot = self.m_data.red_dot or {}
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
	self.m_id = self.m_rank_cfg.id
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

return M
