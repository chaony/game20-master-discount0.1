local M = class("PeakArenaFightView",LikeOO.OOPopBase)

M.m_uiName = "PeakArena/PeakArenaFight"
M.m_size_type = 1
M.m_iphoneXAdapter = true

local __TAB_BTN_NODE = { 
	{lua_name = "UI.PeakArena.PeakArenaFight.GroupGameNode", text_key = "peak_str_0032"}, -- 我的比赛
	{lua_name = "UI.PeakArena.PeakArenaFight.RankGameNode", text_key = "peak_str_0033"}, -- 我的比赛
	{lua_name = "UI.PeakArena.PeakArenaFight.ChamGameNode", text_key = "peak_str_0034"}, -- 我的比赛
}

function M:onEnter()
	self:setTextByLanKey("no_get_des", "peak_str_0030")
	self.m_content_panel = self:findGameObject("common_panel")
    self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 18})
	self:setTextByLanKey("close_title_text", "peak_str_0006")
	self:setTextByLanKey("common_no_have_text", "peak_str_0064")
	self:setTextByLanKey("star_text", "peak_arenafight_star_text")
	self:setTextByLanKey("lock_text", "peak_arenafight_lock_text")
	self:setTextByLanKey("team2_btn_text", "peak_arena_zhenrong")
	self:setTextByLanKey("zb_btn_text", "UnionWar_str_006")
	self:setObjectVisible("b_r_com", true)
	if self.m_model.m_top_data.week == 1 and self.m_model:checkMyGroup() == false then
		self:setObjectVisible("no_get_com", true)
		self:setTextByLanKey("no_get_rank", self.m_model:getMyScoreRank())
		self:setObjectVisible("dowm_timg", false)
		self:setObjectVisible("game_type", false)
		self:setObjectVisible("bottom_com", false)
		return
	end
	local index = 1
	if self.m_model.m_top_data.week == 1 then
		index = 1
	elseif self.m_model.m_top_data.week == 2 or self.m_model.m_top_data.week == 3 or self.m_model.m_top_data.week == 4 then	
		index = 2
	elseif self.m_model.m_top_data.week == 5 or self.m_model.m_top_data.week == 6 or self.m_model.m_top_data.week == 7 then
		index = 3
	end
	if self.m_model.is_promotion == true and self.m_model.m_top_data.week == 1 then --小组赛轮空
		self:setObjectVisible("promotion_com", true)
	else
		local btn_tab = __TAB_BTN_NODE[index]
		local tab_cls = CustomRequire(btn_tab.lua_name)
		self.m_cur_tab_node = tab_cls.new(self.m_control, {parent = self.m_content_panel})
		self:setObjectVisible("promotion_com", false)
	end
	self:refreshUI()
end

function M:clickLeft()
	if self.m_model.m_top_data.week == 1 then
		self.m_model.m_selete_battle_log = self.m_model.m_selete_battle_log - 1
    	if self.m_model.m_selete_battle_log <= 0 then
        	self.m_model.m_selete_battle_log = 1
			return
    	end
	else
		self.m_model.m_battle_index_64 = self.m_model.m_battle_index_64 - 1
		if self.m_model.m_battle_index_64 <= 0 then
        	self.m_model.m_battle_index_64 = 1
			return
    	end
	end
	self:refreshUI()
end

function M:clickRight()
	if self.m_model.m_top_data.week == 1 then
		self.m_model.m_selete_battle_log = self.m_model.m_selete_battle_log + 1
		if self.m_model.m_selete_battle_log > self.m_model.m_max_teaams then
			self.m_model.m_selete_battle_log = self.m_model.m_max_teaams
			return
		end
    	if self.m_model.m_selete_battle_log > 3 then
    	    self.m_model.m_selete_battle_log = 3
			return
    	end
	else
		self.m_model.m_battle_index_64 = self.m_model.m_battle_index_64 + 1
		if self.m_model.m_battle_index_64 > 4 then
        	self.m_model.m_battle_index_64 = 4
			return
    	end	
	end
	self:refreshUI()
end

--刷新UI
function M:refreshUI()
	if self.m_model.m_top_data.week == 1 then
		self:setTextByLanKey("game_type", "peak_str_0035")
		if self.m_model.is_promotion == true then
			self:setObjectVisible("bottom_com", false)
		else
			self:setTextByLanKey("se_num", "peak_str_0036", self.m_model.m_selete_battle_log)
			if self.m_model.m_max_teaams > 1 then
				self:setObjectVisible("bottom_com", true)
			else
				self:setObjectVisible("bottom_com", false)
			end
		end
	elseif self.m_model.m_top_data.week == 2 or self.m_model.m_top_data.week == 3 or self.m_model.m_top_data.week == 4 then	
		self:setTextByLanKey("game_type", "peak_str_0033")
		self:setTextByLanKey("se_num", "peak_str_0037", self.m_model.m_battle_index_64)
		self:setObjectVisible("bottom_com", true)
	elseif self.m_model.m_top_data.week == 5 or self.m_model.m_top_data.week == 6 or self.m_model.m_top_data.week == 7 then
		self:setTextByLanKey("game_type", "peak_str_0034")
		self:setObjectVisible("bottom_com", false)
	end
	if self.m_cur_tab_node then
		self.m_cur_tab_node:refreshUI()
	end
	if self.m_model.m_top_data.week == 7 then
		self:setObjectVisible("dowm_timg", false)
	else
		self:setObjectVisible("dowm_timg", true)	
	end
end

function M:updateTime()
	local end_tim = self.m_model:getDownTime()
	if end_tim > 0 and end_tim >= UserDataManager:getServerTime() then
		self:setTextByLanKey("star_time", GameUtil:formatTimeBySecond(end_tim - UserDataManager:getServerTime()))
		local lock_tim = end_tim - UserDataManager:getServerTime() - 3600
		if lock_tim <= 0 then
			self:setTextByLanKey("lock_time", "peak_str_0007")
		else
			self:setTextByLanKey("lock_time", GameUtil:formatTimeBySecond(lock_tim))
		end
	end
end

function M:destroy()
	if self.m_attr_node then
		self.m_attr_node:destroy()
		self.m_attr_node = nil
	end
    M.super.destroy(self)
end

return M