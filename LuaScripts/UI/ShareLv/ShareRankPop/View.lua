local M = class("ShareRankPopView",LikeOO.OOPopBase)

M.m_uiName = "ShareLv/ShareRankPop"
M.m_size_type = 2

local __TAB_BTN_NODE = {
	{btn_key = "tog_1", btn_text = "tog_1_text", text_key = "shareLv_str_0027", red_point_key = "m_daily_red_point" }, -- 人榜
	{btn_key = "tog_2", btn_text = "tog_2_text", text_key = "shareLv_str_0028", red_point_key = "m_weekly_red_point" }, -- 地榜
	{btn_key = "tog_3", btn_text = "tog_3_text", text_key = "shareLv_str_0029", red_point_key = "m_main_red_point" }, -- 天榜
}

function M:onEnter()
	self:setTextByLanKey("common_title_text", "new_str_0114")
	self:setTextByLanKey("rank_label_text", "new_str_0374")
	self:setTextByLanKey("player_label_text", "new_str_0372")
	self:setTextByLanKey("score_label_text", "shareLv_str_0031")
	self:setTextByLanKey("power_label_text", "shareLv_str_0030")
	self.m_toggle_btns={}
	for k,v in pairs(__TAB_BTN_NODE) do
		self:setTextByLanKey(v.btn_text, string.cutTextForString(Language:getTextByKey(v.text_key)))
		local tog_btn = self:findToggle(v.btn_key)
		self.m_toggle_btns[k] = tog_btn
		if k == self.m_model.m_select_index then
			tog_btn.isOn = true
		end
		UIUtil.addToggleListener(tog_btn, function(is_on) self:switchTabUpdate(is_on, k) end, nil, self.m_uiName)
	end
	if next(self.m_model.m_ranks_land)  == nil then
		self:setObjectVisible("tog_2", false)
	else	
		self:setObjectVisible("tog_2", true)	
		self:setObjectVisible("tog_1", true)
	end
	if next(self.m_model.m_ranks_sky)  == nil then
		self:setObjectVisible("tog_3", false)
	else
		self:setObjectVisible("tog_3", true)	
		self:setObjectVisible("tog_2", true)	
		self:setObjectVisible("tog_1", true)	
	end
	self:setTextByLanKey("common_no_have_text", "shareLv_str_0026")
	self:refreshUI()
end

function M:switchTabUpdate(is_on, update_key)
	if is_on then
		self:updateMsg(update_key)
	end
end

function M:switchTabNode(index) 
	self:refreshUI()
end

function M:refreshUI()
	self:updateListScroll()
end

function M:updateListScroll()
    local data = {}
	if self.m_model.m_select_index == 1 then
		data = self.m_model.m_ranks_people
	elseif self.m_model.m_select_index == 2 then	
		data = self.m_model.m_ranks_land
	elseif self.m_model.m_select_index == 3 then	
		data = self.m_model.m_ranks_sky
	end
	if next(data) ~= nil then
		self:setObjectVisible("CommonTipsNode", false)
	else
		self:setObjectVisible("CommonTipsNode", true)	
	end 
    if self.m_list_scroll == nil then
        local list_scroll = self:findGameObject("loopscroll")
        local params = {
        	ui_name = self.m_uiName,
            show_data = data,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                self:listHandle(cell_object, cell_data, index)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
				self.m_control:openView("Pops.PlayerInfo", {uid = cell_data.user.uid})
            end
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_list_scroll:reloadData(data)
    end
end

function M:listHandle(obj, data, index)
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	local top_three_flag = index < 4
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", top_three_flag)
	local rank_bg = LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_bg", not top_three_flag)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_text", not top_three_flag)

	local top_three_item = GlobalConfig.RANK_TOP_THREE_IMG[index]
	if top_three_flag and top_three_item then
		LuaBehaviourUtil.setImg(luaBehaviour,"top_three_rank_img", top_three_item.rank, top_three_item.atlas)
	end
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", index)
	local user = data.user or {}
	local head_node = luaBehaviour:FindGameObject("head_node")
    GameUtil:setUserAvatar(head_node, user, false, false, {show_flag = true, scale = 1})
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", user.name)
	local level = self.m_model:getDispLv(data.score or 0)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "combat_num_text", level.. Language:getTextByKey("new_str_0428"))


	local time = data.rank_time or 0
	local tm = TimeUtil.gmTime(time)
	local time_str = string.format("%d-%02d-%02d %02d:%02d", tm.year, tm.month, tm.day, tm.hour, tm.min)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "score_text", time_str)

	if not IsNull(rank_bg) then
		if index >= 100 then
			UIUtil:setLocalDelta(rank_bg.transform, 64,32)
		elseif	index >= 1000 then
			UIUtil:setLocalDelta(rank_bg.transform, 84,32)
		else
			UIUtil:setLocalDelta(rank_bg.transform, 32,32)	
		end
	end
end

function M:updateHint()
	self:setObjectVisible("zd_hint_bg", self.m_model.m_open_hint == true)
	if self.m_model.m_open_hint == true then
		if self.m_model.m_select_index == 1 then
			local str = Language:getTextByKey("tid#WuDaoChangRankDes001")
			local st2 = string.gsub(Language:getTextByKey(str or "???"), "\\n", "\n")
			self:setTextByLanKey("hint_count", st2)
		elseif self.m_model.m_select_index == 2 then	
			local str = Language:getTextByKey("tid#WuDaoChangRankDes002")
			local st2 = string.gsub(Language:getTextByKey(str or "???"), "\\n", "\n")
			self:setTextByLanKey("hint_count", st2)
		elseif self.m_model.m_select_index == 3 then	
			local str = Language:getTextByKey("tid#WuDaoChangRankDes003")
			local st2 = string.gsub(Language:getTextByKey(str or "???"), "\\n", "\n")
			self:setTextByLanKey("hint_count", st2)
		end
	end
end


return M