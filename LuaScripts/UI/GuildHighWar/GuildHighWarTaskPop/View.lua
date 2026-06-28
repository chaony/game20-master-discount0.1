local M = class("GuildHighWarTaskPopView",LikeOO.OOPopBase)

M.m_uiName = "GuildHighWar/GuildHighWarTaskPop"
M.m_size_type = 2
M.m_iphoneXAdapter = true

local __TAB_BTN_NODE = {
	{btn_key = "tog_1", text_key = "tog_1_text", show_text = "qi_men_dun_jia_str_003" }, -- 个人
	{btn_key = "tog_2", text_key = "tog_2_text", show_text = "qi_men_dun_jia_str_002"}, -- 帮会
}

function M:onEnter()
	self:setTextByLanKey("common_title_text", "guild_high_war_new_0036")
	self:refreshUI()
end

function M:refreshUI()
	--self:updateTitleNode()
	--self:updateAllLoopScroll()
	self:updateLoopScroll()
	--self:refreshRedPoint()
end

function M:updateAllLoopScroll()
	for k, v in pairs(self.m_task_type_cache) do
		self:updateLoopScroll(v)
	end
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

function M:switchNode(index)
	self:setObjectVisible("tog_lock1", index == 1)
	self:setObjectVisible("tog_lock2", index == 2)
	self:setObjectVisible("loopscroll_mine", index == 1)
	self:setObjectVisible("loopscroll_union", index == 2)
	self:setObjectVisible("top_title_node", index == 2)
	self:updateAutoGetBtnStatus()
end

function M:updateCurrentLoopScroll()
	self:updateLoopScroll(self.m_task_type_cache[self.m_model.m_select_tab_index])
end

function M:updateLoopScroll()
	local data = self.m_model:getTaskData()
	if self.m_loopscroll_view_cache == nil then
		local loopscroll = self:findGameObject("loopscroll_mine")
		local params = {
			ui_name = self.m_uiName,
			show_data = data,
			one_line_count = 1,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateLoopScrollCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if click_name == "goto_btn" then
					local status = cell_data.status
					if status ~= -1 then
						self:updateMsg(status == 1 and "reward_btn" or "goto_btn", cell_data)
					end
				elseif click_name == "score_btn" then
					self:updateMsg("score_btn",click_object)
				end
			end
		}
		self.m_loopscroll_view_cache= LoopScrollViewUtil.new(params)
	else
		self.m_loopscroll_view_cache:reloadData(data)
	end
end

function M:updateLoopScrollCell(index, cell_object, cell_data)
	local transform = cell_object.transform
	local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	local node = luaBehaviour:FindGameObject("node")

	-- 名字
	UIUtil.setTextByLanKey(node.transform, "name_text", cell_data.name or "")
	
	-- 进度
	local slider = UIUtil.findSlider(node.transform, "progress_slider")
	slider.value = cell_data.cur_progress / cell_data.target_value
	
	local progress_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "progress_slider_text", "new_str_0471", math.min(cell_data.cur_progress, cell_data.target_value), cell_data.target_value)
	local finish_text = luaBehaviour:FindText("finish_text")
	
	-- 前往、领取按钮
	local goto_btn = UIUtil.findButton(node.transform, "goto_btn")
	local goto_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "goto_btn_text", "new_str_0056") --领取
	local receive_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "receive_btn_text", "new_str_0058") --已领取
	local incomplete_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "incomplete_btn_text", "new_str_0057") --未完成
	local order_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "score_text", cell_data.order) --未完成
	--local incomplete_btn_text = luaBehaviour:FindImage("incomplete_btn_text") --未完成
	local goto_btn_text_show = false
	local receive_btn_text_show = false
	local incomplete_btn_text_show = false
	local progress_text_show = true
	goto_btn.gameObject:SetActive(false)
	goto_btn.enabled = false
	if cell_data.status == 0 then--前往
		goto_btn.gameObject:SetActive(not cell_data.lock_flag)
		local go_type = cell_data.go_type or {}
		if _G.next(go_type) then
			UIUtil.setImg(node.transform, "a_ui_currency_btn_small_3", "common_ui", "goto_btn")
			goto_btn.enabled = true
			goto_btn_text_show = true
		else
			UIUtil.setImg(node.transform, "a_ui_currency_btn_small_3", "common_ui", "goto_btn")
			goto_btn.enabled = false
			goto_btn.gameObject:SetActive(false)
			incomplete_btn_text_show = true
		end
	elseif cell_data.status == 1 then--可领取
		goto_btn.gameObject:SetActive(true)
		goto_btn.enabled = true
		goto_btn_text_show = true
		UIUtil.setImg(node.transform, "a_ui_currency_btn_small_2", "common_ui", "goto_btn")
	else-- 已领取
		goto_btn.gameObject:SetActive(false)
		receive_btn_text_show = true
		progress_text_show = false
	end
	goto_btn_text.gameObject:SetActive(goto_btn_text_show)
	receive_btn_text.gameObject:SetActive(receive_btn_text_show)
	incomplete_btn_text.gameObject:SetActive(incomplete_btn_text_show)
	progress_text.gameObject:SetActive(progress_text_show)
	finish_text.gameObject:SetActive(not progress_text_show)

	-- 奖励
	local all_reward_node = luaBehaviour:FindGameObject("reward_node")
	GameUtil:createRewards(all_reward_node.transform, cell_data.reward, true, true)
	--self:updateLoopScrollCellRewardLoopScroll(scroll_view_key, tostring(cell_object), loop_scroll_object_reward, cell_data.cfg.reward)
end

function M:updateLoopScrollCellRewardLoopScroll(task_scroll_view_key, reward_scroll_view_key, loop_scroll_object, reward_data)
	if self.m_loopscroll_reward_view_cache[task_scroll_view_key][reward_scroll_view_key] == nil then
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
		self.m_loopscroll_reward_view_cache[task_scroll_view_key][reward_scroll_view_key] = LoopScrollViewUtil.new(params)
	else
		self.m_loopscroll_reward_view_cache[task_scroll_view_key][reward_scroll_view_key]:reloadData(reward_data)
	end
end

-- title
function M:updateTitleNode()
	self:setText("huoyue_count_text", self.m_model:getExploreValue())
	self:updateExploreProgressSliderLoopScroll()
	self:updateExploreProgressSlider()
end

function M:updateExploreProgressSliderLoopScroll()
	local data = self.m_model:getExploreData()
	if #data <= 0 then
		return
	end
	if self.m_explore_progress_slider_loopscroll_view == nil then
		local loopscroll = self:findGameObject("explore_slider_loopscroll")
		local params = {
			ui_name = self.m_uiName,
			show_data = data,
			one_line_count = 1,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateExploreProgressSliderLoopScrollCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if cell_data.status == 1 then -- 可领取
					self:updateMsg("box_reward", {click_transform = cell_object.transform, data = cell_data})
				else
					local rewards =cell_data.reward or {}
					local luaBehaviour = UIUtil.findLuaBehaviour(cell_object.transform)
					if luaBehaviour then
						local showNode = luaBehaviour:FindGameObject("showNode")
						self.m_control:openView("Pops.LookRewardTips",{rewards = rewards, click_transform = showNode.transform, show_check_mark = (cell_data.status == 2)})
					end
				end
			end
		}
		self.m_explore_progress_slider_loopscroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_explore_progress_slider_loopscroll_view:reloadData(data)
	end
end

function M:updateExploreProgressSliderLoopScrollCell(index, cell_object, cell_data)
	local transform = cell_object.transform
	local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	local score_text = LuaBehaviourUtil.setText(luaBehaviour, "score_text", tostring(cell_data.score))
	local finish_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "finish_text", "new_str_0080")
	local box_effect = luaBehaviour:FindRectTransform("UI_Arena_BX_01")
	local box_effect2 = luaBehaviour:FindRectTransform("UI_Arena_BX_02")
	local box_img = luaBehaviour:FindImage("box_img")
	score_text.color = cell_data.status == 0 and GlobalConfig.COMMON_COLLOR.COMMON_1 or Color( 255/255, 235/255, 68/255)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"got_flag_img",false)
	if cell_data.status == 0 then --未开启
		GameUtil:updateResourcesImg(box_img, "Texture/moon_shadow/a_yycs_weijiesuobaoxiang")
	elseif cell_data.status == 1 then --可领取
		GameUtil:updateResourcesImg(box_img, "Texture/moon_shadow/a_yycs_kelingqubaoxiang")
	elseif cell_data.status == 2 then --已领取
		GameUtil:updateResourcesImg(box_img, "Texture/moon_shadow/a_yycs_yilingqubaoxiang")
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"got_flag_img",true)
	end
	box_img:SetNativeSize()
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "line_img", true)
	if box_effect ~= nil then
		box_effect.gameObject:SetActive(false)
	end
	if box_effect2 ~= nil then
		box_effect2.gameObject:SetActive(false)
	end
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Arena_BX_01", cell_data.status == 1)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Arena_BX_02", cell_data.status == 1)
	if cell_data.status == 1 then
		if box_effect ~= nil then
			box_effect.gameObject:SetActive(true)
		end
		if box_effect2 ~= nil then
			box_effect2.gameObject:SetActive(true)
		end
	end
	
end

--设置选中cell为当前等级
function M:updateExploreProgressLoopScrollStatus()
	if self.m_explore_progress_slider_loopscroll_view then
		self.m_control:setOnceTimer(0.01, function()
			self.m_explore_progress_slider_loopscroll_view:setHorizontalNormalizedPosition(self.m_model:getExploreProgressLoopScrollPosition())
		end)
	end
end

function M:getExploreProgressLoopScrollPosition()
	return self.m_explore_progress_slider_loopscroll_view:getHorizontalNormalizedPosition()
end

function M:updateExploreProgressSlider()
	local explore_slider = self:findSlider("explore_slider")
	local show_data, cur_score = self.m_model:getExploreData()
	local box_num = #show_data
	local cur_index = 0
	local cur_num = 0
	for k, v in pairs(show_data) do
		if v.score < cur_score then
			cur_num = cur_num + 1
			cur_index = k
		else
			break
		end
	end
	local cur_num_real = cur_num
	if cur_num < box_num then
		local low_key_score = 0
		if show_data[cur_index] then
			low_key_score = show_data[cur_index].score or 0
		end
		local delta_score = show_data[cur_index + 1].score - low_key_score
		local score_left = cur_score - low_key_score
		cur_num_real = cur_num + score_left / delta_score
	end
	
	explore_slider.value = cur_num_real / box_num
end

function M:moveExploreProgressSliderLoopScrolllPage(off_index)
	self.m_explore_progress_slider_loopscroll_view:moveHorizontalPage(off_index)
end

function M:refreshRedPoint()
	self:setObjectVisible("tog_1_red_point_img", self.m_model:hasTaskMineReward())
	self:setObjectVisible("tog_2_red_point_img", self.m_model:hasTaskUnionOrExploreReward())
	
	self:updateAutoGetBtnStatus()
end

function M:updateAutoGetBtnStatus()
	self:setObjectVisible("auto_get_btn", self.m_model:hasTaskMineOrUnionReward())
end



return M