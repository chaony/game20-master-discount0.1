local M = class("ArenaHigherRankModel", LikeOO.OODataBase)

local __TAB_BTN_NODE = {
	{btn_key = "togglebtn_1", btn_text = "togglebtn_text_1", text_key = "new_str_0271", open = true, url_key = "high_arena_select_arena_rank"}, -- 赛季积分榜
	{btn_key = "togglebtn_2", btn_text = "togglebtn_text_2", text_key = "new_str_0270", open = true, url_key = "high_arena_select_arena_score_rank"}, -- 积分总榜
}

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData("high_arena_select_arena_rank", {start = 1, stop = 50})

end

function M:onEnter()
	self.m_open_tab_index = self.m_params.open_tab_index or 1
	self.m_cache_data = {}
	self:initData(self.m_data)
end

function M:getRankData()
	local index = self.m_sel_tab_index or 1
	local data = self.m_cache_data[index] or {}
	local ranks = data.ranks or {}
	return ranks
end

function M:getTabBtnNode()
	return __TAB_BTN_NODE
end

function M:initData(data, index)
	self.m_cache_data[index or self.m_open_tab_index] = data
end

function M:getDataByIndex(index)
	return self.m_cache_data[index or self.m_open_tab_index]
end

return M
