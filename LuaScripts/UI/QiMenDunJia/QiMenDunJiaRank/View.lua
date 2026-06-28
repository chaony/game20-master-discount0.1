local M = class("QiMenDunJiaRankView",LikeOO.OOPopBase)

M.m_uiName = "QiMenDunJia/QiMenDunJiaRank"
M.m_size_type = 2
M.m_iphoneXAdapter = true

local __TAB_BTN_NODE = { 
	{btn_key = "tog_1", text_key = "tog_1_text", show_text = "qi_men_dun_jia_str_016" }, 	-- 个人榜
	{btn_key = "tog_2", text_key = "tog_2_text", show_text = "qi_men_dun_jia_str_015" }, 	-- 帮会榜
	{btn_key = "tog_3", text_key = "tog_3_text", show_text = "new_str_0373" },				-- 奖励
}

function M:onEnter()
	self.m_toggle_btns = {}
	for k,v in pairs(__TAB_BTN_NODE) do
		self:setTextByLanKey(v.text_key, v.show_text)
		local tog_btn = self:findToggle(v.btn_key)
		self.m_toggle_btns[k] = tog_btn
		UIUtil.addToggleListener(tog_btn, function(is_on) self:switchTabUpdate(is_on, k) end,nil,self.m_uiName)
		if k == 1 then
			tog_btn.isOn = true
			self:setTextColor(v.text_key, GlobalConfig.COMMON_COLLOR.COMMON_25)
		else
			self:setTextColor(v.text_key, GlobalConfig.COMMON_COLLOR.COMMON_24)
		end
	end
	self.m_reward_loop_scroll_view_cache = {}
	self:setTextByLanKey("common_title_text", "qi_men_dun_jia_str_014")
	self:setTextByLanKey("inside_rank_label_text", "qi_men_dun_jia_str_053")
	self:setTextByLanKey("player_label_text", "qi_men_dun_jia_str_054")
	self:setTextByLanKey("lv_label_text", "qi_men_dun_jia_str_055")
	self:setTextByLanKey("score_label_text", "qi_men_dun_jia_str_056")
	self:setTextByLanKey("inside_rank_own_rank_title_text", "qi_men_dun_jia_str_057")

	self:setTextByLanKey("rank_union_label_text", "qi_men_dun_jia_str_064")
	self:setTextByLanKey("union_label_text", "qi_men_dun_jia_str_058")
	self:setTextByLanKey("rank_progress_label_text", "qi_men_dun_jia_str_059")
	self:setTextByLanKey("rank_own_rank_title_text", "qi_men_dun_jia_str_060")
	
	self:setTextByLanKey("reward_own_union_name_title_text", "qi_men_dun_jia_str_061")
	self:setTextByLanKey("reward_rank_label_text", "qi_men_dun_jia_str_053")
	self:setTextByLanKey("reward_union_label_text", "qi_men_dun_jia_str_063")
	
	self:setTextByLanKey("progress_label_text", "qi_men_dun_jia_str_034", self.m_model:getGuildExploreRewardLimit())
	self:refreshUI()
end

function M:switchTabUpdate(is_on, update_key)
	local tog_nod = __TAB_BTN_NODE[update_key]
	if is_on then
		self:updateMsg("check_tag", update_key)
		self:setTextColor(tog_nod.text_key, GlobalConfig.COMMON_COLLOR.COMMON_25)
	else
		self:setTextColor(tog_nod.text_key, GlobalConfig.COMMON_COLLOR.COMMON_24)
	end
end

function M:refreshUI()
	if self.m_model.m_sel_tab_index == 1 then --帮内排行
		self:updateInsideRankLoopScroll()
		local own_data = self.m_model:getMyInsideRankData()
		local own_info = self:findGameObject("inside_rank_own_info")
		if own_data and own_data.rank and own_data.score then
			own_info:SetActive(true)
			self:updateInsideRankLoopScrollCell(own_info, own_data)
		else
			own_info:SetActive(false)
		end
	elseif self.m_model.m_sel_tab_index == 2 then --帮会排行
		self:updateRankLoopScroll()
		local own_data = self.m_model:getMyRankData()
		local own_info = self:findGameObject("rank_own_info")
		if own_data and own_data.rank and own_data.score then
			own_info:SetActive(true)
			self:updateRankLoopScrollCell(own_info, own_data)
		else
			own_info:SetActive(false)
		end
	else --奖励排行
		local own_data = self.m_model:getMyRankData()
		self:setText("reward_own_union_name_text", own_data.user.guild_name)
		self:setTextByLanKey("reward_own_union_rank_text", "qi_men_dun_jia_str_017", own_data.rank)
		if own_data.rank == nil or own_data.rank == 0 then
			self:setTextByLanKey("reward_own_union_rank_text", "qi_men_dun_jia_str_021")
		else
			self:setTextByLanKey("reward_own_union_rank_text", "qi_men_dun_jia_str_017", own_data.rank)
		end
		self:updateRewardLoopScroll()
	end
end

function M:switchNode(index)
    self:setObjectVisible("inside_rank_node", index == 1)
	self:setObjectVisible("rank_node", index == 2)
    self:setObjectVisible("reward_node", index == 3)
	self:setObjectVisible("tog_lock1", index == 1)
	self:setObjectVisible("tog_lock2", index == 2)
	self:setObjectVisible("tog_lock3", index == 3)
	self:refreshUI()
end

--帮会排行
function M:updateRankLoopScroll()
	local data = self.m_model:getRankData()
	if self.m_rank_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("rank_loopscroll")
		local params = {
            show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data) 
				self:updateRankLoopScrollCell(cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
        		self.m_control:openView("Pops.PlayerInfo", {uid = cell_data.user.uid, look_model = 1})
			end
		}
		self.m_rank_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_rank_loop_scroll_view:reloadData(data)
	end
end

function M:updateRankLoopScrollCell(cell_object, cell_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	if luaBehaviour then
		if next(cell_data) ~= nil then
			
			--排行
			if cell_data.rank <= 3 and cell_data.rank > 0 then
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", true)
				LuaBehaviourUtil.setImg(luaBehaviour, "top_three_rank_img", "a_phb_icon_"..cell_data.rank, "common_ui")
				for i = 1, 3 do
					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "Ui_Rank_Bang_00"..i, i == cell_data.rank)
				end
			else
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", false)
			end
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", cell_data.rank)
			
			--帮会
			local union_cfg = ConfigManager:getCfgByName("guild_flag")[cell_data.user.flag]
			if union_cfg then
				local icon_img = self:findImage("icon_img")
				GameUtil:updateResourcesImg(icon_img, "Texture/union_emblem/" .. union_cfg.icon)
			end
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", cell_data.user.guild_name or cell_data.user.name)
			
			--进度
			local progress_str = cell_data.score
			local score = cell_data.score
			if score > self.m_model:getScoreLimit() then
				local date = TimeUtil.gmTime(cell_data.time)
				progress_str = Language:getTextByKey("qi_men_dun_jia_str_018", date.year, date.month, date.day, date.hour, date.min) .. "完成"
			end
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "progress_text", progress_str)
			
			--排行-无
			if cell_data.rank == 0 then
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", "kingsoft_text_0042")
			end
		end 
	end
end

--帮内排行
function M:updateInsideRankLoopScroll()
	local data = self.m_model:getInsideRankData()
	if self.m_inside_rank_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("inside_rank_loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateInsideRankLoopScrollCell(cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self.m_control:openView("Pops.PlayerInfo", {uid = cell_data.user.uid, look_model = 1})
			end
		}
		self.m_inside_rank_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_inside_rank_loop_scroll_view:reloadData(data)
	end
end

function M:updateInsideRankLoopScrollCell(cell_object, cell_data, my)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	if luaBehaviour then
		if next(cell_data) ~= nil then
			if cell_data.rank <= 3 and cell_data.rank > 0 then
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", true)
				LuaBehaviourUtil.setImg(luaBehaviour, "top_three_rank_img", "a_phb_icon_"..cell_data.rank, "common_ui")
			else
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", false)
			end
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", cell_data.rank)
			local head_node = luaBehaviour:FindGameObject("head_node")
			GameUtil:setUserAvatar(head_node, cell_data.user,nil,nil,{show_flag = true, scale = 1})
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", cell_data.user.name)
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "level_text", cell_data.user.level)
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "race_score_text", GameUtil:formatValueToString(cell_data.score))
			if cell_data.rank == 0 then
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", "kingsoft_text_0042")
			end
		else
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_bg", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_text", false)
			if my and my == true then
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "none_rank_text", "未上榜")
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", UserDataManager.user_data:getUserStatusDataByKey("name"))
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "level_text", UserDataManager.user_data:getUserStatusDataByKey("level"))
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "race_score_text", "0")
				local head_node = luaBehaviour:FindGameObject("head_node")
				local user = UserDataManager.user_data.user_status
				GameUtil:setUserAvatar(head_node, user, nil, nil, {show_flag = true, scale = 1})
			end
		end
	end
end

function M:updateRewardLoopScroll()
    local data = self.m_model.ranks_rewards
    if self.m_reward_loop_scroll_view == nil then
		self.m_reward_loop_scroll_view_cache = {}
        local loopscroll = self:findGameObject("reward_loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self:updateRewardLoopScrollCell(cell_obj, index, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
        
            end
        }
        self.m_reward_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_reward_loop_scroll_view:reloadData(data)
    end
end

function M:updateRewardLoopScrollCell(obj, index, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", index <= 3 and data.rank[2] == nil) 
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_bg", index > 3 or data.rank[2] ~= nil)
		local rank_str = ""
        if index <= 3 and data.rank[2] == nil then
            LuaBehaviourUtil.setImg(luaBehaviour, "top_three_rank_img", "a_phb_icon_"..index, "common_ui")
        else
            rank_str = data.rank[1]
            if data.rank[2] then
				rank_str = data.rank[1] .."-"..data.rank[2]
            end
        end
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", rank_str)
        local loop_scroll_object_all = luaBehaviour:FindGameObject("reward_all_loopscroll")
		local loop_scroll_object_top = luaBehaviour:FindGameObject("reward_top_loopscroll")
		self:updateRewardLoopScrollRewardLoopScroll(tostring(loop_scroll_object_all), loop_scroll_object_all, data.reward or {})
		self:updateRewardLoopScrollRewardLoopScroll(tostring(loop_scroll_object_top), loop_scroll_object_top, data.reward_inside or {})
    end    
end

function M:updateRewardLoopScrollRewardLoopScroll(loop_scroll_key, loop_scroll_object, reward_data)
	if self.m_reward_loop_scroll_view_cache[loop_scroll_key] == nil then
		local params = {
			show_data = reward_data,
			one_line_count = 1,
			loop_scroll_object = loop_scroll_object,
			update_cell = function(index, cell_object, cell_data)
				local item_data = RewardUtil:getProcessRewardData(cell_data)
				GameUtil:updateItemElementByData(cell_object, item_data, true, true)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)

			end
		}
		self.m_reward_loop_scroll_view_cache[loop_scroll_key] = LoopScrollViewUtil.new(params)
	else
		self.m_reward_loop_scroll_view_cache[loop_scroll_key]:reloadData(reward_data)
	end
end

return M