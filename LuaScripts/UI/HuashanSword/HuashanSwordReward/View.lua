local M = class("HuashanSwordRewardView",LikeOO.OOPopBase)

M.m_uiName = "Arena/ArenaHigher/ArenaHigherReward"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "new_str_0284")
	self:setTextByLanKey("common_no_have_text", "new_str_0351")
	self:setTextByLanKey("score_label_text", "")
	self:setObjectVisible("score_bg_img", false)
	local my_rank = self.m_model.m_data.rank or 0
	if my_rank <= 0 then
		self:setTextByLanKey("dw_label_text", "new_str_0887", Language:getTextByKey("new_str_0076"))
	else
		local cfg = ConfigManager:getHuaShanCfgByRankAndVsn(my_rank, self.m_model.m_version)
		self:setTextByLanKey("dw_label_text", "new_str_0887", Language:getTextByKey(tostring(cfg.division_name or "new_str_0076")))
		local cfg = ConfigManager:getHuaShanCfgByRankAndVsn(my_rank, self.m_model.m_version)
		local segment_node = self:findGameObject("own_segment_node")
		CommonUIUtil:setSegmentInfo(segment_node, cfg, false, "pub_ui")
		
		local luaBehaviour = UIUtil.findLuaBehaviour(segment_node)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "segment_rank_text", false)
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
	self:setTextByLanKey("title_text", "new_str_0270")
	self:refreshUI()
end

function M:refreshUI()
	
end

function M:switchTabNode(index)
	local sel_btn_key = nil
	for k,v in pairs(self.m_model:getTabBtnNode()) do
		local cur_tab_text = self:findText(v.btn_text)
		cur_tab_text.color = index == k and GlobalConfig.COMMON_COLLOR.COMMON_1 or GlobalConfig.COMMON_COLLOR.COMMON_5
		if index == k then
			sel_btn_key = v.btn_key
			self:setTextByLanKey("common_title_text", v.text_key)
		end
		if index == 3 then
			self:setObjectVisible("tab_node_" .. k, 2 == k)
		else
			self:setObjectVisible("tab_node_" .. k, 3 == k)
		end
	end
	if index == 1 then
		self:updateRankLoopScroll(1)
	elseif index == 2 then
		self:updateRankLoopScroll(2)	
	else
		self:updateDwLoopScroll()
	end
	local my_rank = self.m_model.m_data.rank or 0
	local max_rank = self.m_model.m_data.max_rank or 0
	if index == 2 then
		self:setTextByLanKey("rank_label_text", "new_str_0889", tostring(my_rank))
	else
		if max_rank <= 0 then
			self:setTextByLanKey("rank_label_text", "new_str_0888", Language:getTextByKey("new_str_0076"))
		else
			local cfg = ConfigManager:getHuaShanCfgByRankAndVsn(max_rank, self.m_model.m_version)
			self:setTextByLanKey("rank_label_text", "new_str_0888", Language:getTextByKey(tostring(cfg.division_name or "new_str_0076")))
		end
	end
	self:refreshRedPoint()
end

--[[
	创建日常列表
]]
function M:updateDailyQuestsLoopScroll()
	local data = self.m_model:getDailyQuestsData()
	self:setObjectVisible("common_tips_node", #data == 0)
	if self.m_daily_quests_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("daily_quests_loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateDailyQuestsScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg(click_name, {id = index, cell_data = cell_data})
			end
		}
		self.m_daily_quests_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_daily_quests_loop_scroll_view:reloadData(data, true)
	end
end

--Scroll内cell的回调
function M:updateDailyQuestsScrollViewCell(index, cell_object, cell_data)
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
	local goto_btn = luaBehaviour:FindButton("daily_quests_goto_btn") 	-- 前往、领取按钮
	local goto_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "goto_btn_text", "new_str_0029")
	local receive_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "receive_btn_text", "new_str_0056")
	local incomplete_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "incomplete_btn_text", "new_str_0057")
	local goto_btn_text_show = false
	local receive_btn_text_show = false
	local incomplete_btn_text_show = false
	if status == 0 then--前往
		goto_btn.gameObject:SetActive(not data.lock_flag and data.is_child ~= true)
		local go_type = cfg.go_type or {}
		LuaBehaviourUtil.setImg(luaBehaviour, "daily_quests_goto_btn", "a_ui_currency_btn_small_3", "common_ui")
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
		LuaBehaviourUtil.setImg(luaBehaviour, "daily_quests_goto_btn", "a_ui_currency_btn_small_2", "common_ui")
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
	local drop = cfg.reward1 or {}
	local reward_node = luaBehaviour:FindRectTransform("reward_node")
	GameUtil:createRewards(reward_node, drop, true, true, nil, 1)
	local task_finish_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "task_finish_text", "new_str_0058")
	task_finish_text.gameObject:SetActive(not data.lock_flag and status == -1)
end

--[[
	创建段位列表
]]
function M:updateDwLoopScroll()
	local data = self.m_model:getDwData()
	self:setObjectVisible("common_tips_node", #data == 0)
	if self.m_dw_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("dw_loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateDwScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg(click_name, {id = index, cell_data = cell_data})
			end
		}
		self.m_dw_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_dw_loop_scroll_view:reloadData(data, true)
	end
end

--Scroll内cell的回调
function M:updateDwScrollViewCell(index, cell_object, cell_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	local data = cell_data
	local cfg = data.cfg
	local status = data.status
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", cfg.name) -- 名字
	local goto_btn = luaBehaviour:FindButton("dw_goto_btn") -- 前往、领取按钮
	local goto_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "goto_btn_text", "new_str_0029")
	local receive_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "receive_btn_text", "new_str_0056")
	local incomplete_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "incomplete_btn_text", "new_str_0057")
	local goto_btn_text_show = false
	local receive_btn_text_show = false
	local incomplete_btn_text_show = false
	if status == 0 then--前往
		goto_btn.gameObject:SetActive(not data.lock_flag)
		local go_type = cfg.go_type or {}
		LuaBehaviourUtil.setImg(luaBehaviour, "dw_goto_btn", "a_ui_currency_btn_small_3", "common_ui")
		if _G.next(go_type) then
			goto_btn.enabled = true
			goto_btn_text_show = true
		else
			goto_btn.enabled = false
			incomplete_btn_text_show = true
		end
	elseif status == 2 then--领取
		goto_btn.gameObject:SetActive(true)
		goto_btn.enabled = true
		receive_btn_text_show = true
		LuaBehaviourUtil.setImg(luaBehaviour, "dw_goto_btn", "a_ui_currency_btn_small_2", "common_ui")
	else-- 已领取
		goto_btn.gameObject:SetActive(false)
	end
	goto_btn_text.gameObject:SetActive(goto_btn_text_show)
	receive_btn_text.gameObject:SetActive(receive_btn_text_show)
	incomplete_btn_text.gameObject:SetActive(incomplete_btn_text_show)
	local btn_spine = luaBehaviour:FindRectTransform("btn_spine")
	btn_spine.gameObject:SetActive(not data.lock_flag and status == 2)
	local drop = cfg.drop or {} 	-- 奖励
	local reward_node = luaBehaviour:FindRectTransform("reward_node")
	GameUtil:createRewards(reward_node, drop, true, true, nil, 1)
	local task_finish_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "task_finish_text", "new_str_0058")
	task_finish_text.gameObject:SetActive(not data.lock_flag and status == -1)
	local rank = cfg.target_value or 0
	local cfg = ConfigManager:getHuaShanCfgCfgByRankMarkAndVsn(rank, self.m_model.m_version)
	local segment_node = LuaBehaviourUtil.setObjectVisible(luaBehaviour, "segment_node", true)
	CommonUIUtil:setSegmentInfo(segment_node, cfg, true, "pub_ui")
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "segment_rank_text", false)
end

--[[
	创建排行列表
]]
function M:updateRankLoopScroll(rank_type)
	local data = self.m_model:getRankData(rank_type)
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
	local record_flag1 = RedPointUtil:hasRedPointById(27602)
	self:setObjectVisible("togglebtn_red_point_3", record_flag1)
	self:setObjectVisible("togglebtn_red_point_2", false)
	self:setObjectVisible("togglebtn_red_point_1", false)
end

return M