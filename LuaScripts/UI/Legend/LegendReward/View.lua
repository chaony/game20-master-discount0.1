local M = class("LegendRewardView",LikeOO.OOPopBase)

M.m_uiName = "Legend/LegendReward"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_no_have_text", "new_str_0351")
	self:setTextByLanKey("auto_get_btn_text", "qi_men_dun_jia_str_047") --一键领取
	if self.m_model.m_data.value == 0 then
		self:setTextByLanKey("daily_label_text", "legend_str_007", Language:getTextByKey("legend_str_010"))
	else
		self:setTextByLanKey("daily_label_text", "legend_str_007", tostring(self.m_model.m_data.value))
	end
	if self.m_model.m_data.week_value == 0 then
		self:setTextByLanKey("weekly_label_text", "legend_str_008", Language:getTextByKey("legend_str_010"))
	else
		self:setTextByLanKey("weekly_label_text", "legend_str_008", tostring(self.m_model.m_data.week_value or 0))
	end
	if self.m_model.m_data.rank == 0 then
		self:setTextByLanKey("rank_label_text", "legend_str_009", Language:getTextByKey("legend_str_011"))
	else
		self:setTextByLanKey("rank_label_text", "legend_str_009", tostring(self.m_model.m_data.rank))
	end
	
	self.m_toggle_btns = {}
	for k,v in pairs(self.m_model:getTabBtnNode()) do
		self:setTextByLanKey(v.btn_text, string.cutTextForString(Language:getTextByKey(v.text_key)))
		local tog_btn = self:findToggle(v.btn_key)
		tog_btn.gameObject:SetActive(v.open)
		self.m_toggle_btns[k] = tog_btn
		if k == self.m_model.m_open_tab_index then
			tog_btn.isOn = true
		end
		UIUtil.addToggleListener(tog_btn, function(is_on) 
			if is_on then
				self:updateMsg(k)
			end
		end,nil,self.m_uiName)
	end
	self:updateMsg(self.m_model.m_open_tab_index)
	self:refreshUI()
end

function M:refreshUI()
	
end

function M:switchTabNode(index)
	local sel_btn_key = nil
	local tabBtnNode = self.m_model:getTabBtnNode()
	for k,v in pairs(tabBtnNode) do
		local cur_tab_text = self:findText(v.btn_text)
		cur_tab_text.color = index == k and GlobalConfig.COMMON_COLLOR.COMMON_25 or GlobalConfig.COMMON_COLLOR.COMMON_24
		if index == k then
			sel_btn_key = v.btn_key
			self:setTextByLanKey("common_title_text", v.text_key)
		end
		self:setObjectVisible("tab_node_" .. k, index == k)
	end
	if index == 1 or index == 2 then
		self:updateQuestsLoopScroll(tabBtnNode[index].quest_key)
	else
		self:updateRankLoopScroll()
	end
	--if index == 3 then
	--	self:setTextByLanKey("rank_label_text", "new_str_0889", tostring(self.m_model.m_data.rank))
	--else
	--	if self.m_model.m_data.max_rank <= 0 then
	--		self:setTextByLanKey("rank_label_text", "new_str_0888", Language:getTextByKey("new_str_0076"))
	--	else
	--		local cfg = ConfigManager:getHighArenaCfgByRank(self.m_model.m_data.max_rank)
	--		self:setTextByLanKey("rank_label_text", "new_str_0888", Language:getTextByKey(tostring(cfg.division_name or "new_str_0076")))
	--	end
	--end
	self:refreshRedPoint()
	self:setObjectVisible("auto_get_btn", self.m_model.m_Daily_red_point)
end

--[[
	创建日常列表
]]
function M:updateQuestsLoopScroll(quest_key)
	local data = self.m_model:getQuestsData(quest_key)
	self:setObjectVisible("common_tips_node", #data == 0)
	local loop_scroll_view_key = "m_"..string.lower(quest_key).."_quests_loop_scroll_view"
	if self[loop_scroll_view_key] == nil then
		local loopscroll = self:findGameObject(string.lower(quest_key).."_quests_loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateQuestsScrollViewCell(quest_key, index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg(click_name, {id = index, cell_data = cell_data})
			end
		}
		self[loop_scroll_view_key] = LoopScrollViewUtil.new(params)
	else
		self[loop_scroll_view_key]:reloadData(data, true)
	end
end

--Scroll内cell的回调
function M:updateQuestsScrollViewCell(quest_key, index, cell_object, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	local data = cell_data
	local cfg = data.cfg
	local cur_progress = data.cur_progress
	local target_value = data.target_value
	local status = data.status
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", cfg.name)
	LuaBehaviourUtil.setSliderValue(luaBehaviour, "progress_slider", cur_progress/target_value) 	-- 进度条
	local progress_slider_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "progress_slider_text", "new_str_0471", cur_progress, target_value)
	local finish_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "finish_text", "new_str_0470")
	local goto_btn = luaBehaviour:FindButton(string.lower(quest_key).."_quests_goto_btn") 	-- 前往、领取按钮
	local goto_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "goto_btn_text", "new_str_0029")
	local receive_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "receive_btn_text", "new_str_0056")
	local incomplete_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "incomplete_btn_text", "new_str_0057")
	local goto_btn_text_show = false
	local receive_btn_text_show = false
	local incomplete_btn_text_show = false
	if status == 0 then--前往
		goto_btn.gameObject:SetActive(not data.lock_flag and data.is_child ~= true)
		local go_type = cfg.go_type or {}
		LuaBehaviourUtil.setImg(luaBehaviour, string.lower(quest_key).."_quests_goto_btn", "a_ui_currency_btn_small_3", "common_ui")
		if _G.next(go_type) then
			goto_btn.enabled = true
			goto_btn_text_show = true
		else
			goto_btn.enabled = false
			incomplete_btn_text_show = true
		end
	elseif status == 2 then--领取
		goto_btn.gameObject:SetActive(data.is_child ~= true)
		goto_btn.enabled = true
		receive_btn_text_show = true
		LuaBehaviourUtil.setImg(luaBehaviour, string.lower(quest_key).."_quests_goto_btn", "a_ui_currency_btn_small_2", "common_ui")
	else-- 已领取
		goto_btn.gameObject:SetActive(false)
	end
	goto_btn_text.gameObject:SetActive(goto_btn_text_show and data.is_child ~= true)
	receive_btn_text.gameObject:SetActive(receive_btn_text_show and data.is_child ~= true)
	incomplete_btn_text.gameObject:SetActive(incomplete_btn_text_show and data.is_child ~= true)
	finish_text.gameObject:SetActive(not data.lock_flag and status == 2)
	progress_slider_text.gameObject:SetActive(status ~= 2)
	local btn_spine = luaBehaviour:FindRectTransform("btn_spine")
	btn_spine.gameObject:SetActive(not data.lock_flag and status == 2 and data.is_child ~= true)
	-- 奖励
	local drop = cfg.reward or {}
	local reward_node = luaBehaviour:FindRectTransform("reward_node")
	GameUtil:createRewards(reward_node, drop, true, true, nil, 1)
	local task_finish_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "task_finish_text", "new_str_0058")
	task_finish_text.gameObject:SetActive(not data.lock_flag and status == -1)
end

--[[
	创建排行列表
]]
function M:updateRankLoopScroll()
	local data = self.m_model:getRankData()
	local max_index = #data
	self:setObjectVisible("common_tips_node", #data == 0)
	if self.m_rank_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("rank_loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateRankScrollViewCell(index, cell_object, cell_data, max_index)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg(click_name, {id = index, cell_data = cell_data})
			end
		}
		self.m_rank_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_rank_loop_scroll_view:reloadData(data, true)
	end
end

--Scroll内cell的回调
function M:updateRankScrollViewCell(index, cell_object, cell_data, max_index)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	local reward = cell_data.reward or {} 	-- 奖励
	local reward_node = luaBehaviour:FindRectTransform("reward_node")
	GameUtil:createRewards(reward_node, reward, true, true, nil, 1)
	local rank = cell_data.rank or {}
	local first_rank = rank[1] or 0
	local second_rank = rank[2] or 0

	 local top_three_flag = first_rank > 0 and first_rank < 4
	 LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", top_three_flag)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_bg", not top_three_flag)
	 local top_three_item = GlobalConfig.RANK_TOP_THREE_IMG[first_rank]
	if top_three_item and top_three_flag then
		LuaBehaviourUtil.setImg(luaBehaviour,"top_three_rank_img", top_three_item.rank, top_three_item.atlas)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", "")
	else
		if index == max_index then
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", "new_str_0894", first_rank)
		else
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", first_rank .. "-" .. second_rank)
		end
	end
end

function M:refreshRedPoint()
	--local record_flag1 = RedPointUtil:hasRedPointById(14102)
	--local record_flag2 = RedPointUtil:hasRedPointById(14103)
	self:setObjectVisible("togglebtn_red_point_1", self.m_model.m_Daily_red_point)
	self:setObjectVisible("togglebtn_red_point_2", self.m_model.m_Weekly_red_point)
end

return M