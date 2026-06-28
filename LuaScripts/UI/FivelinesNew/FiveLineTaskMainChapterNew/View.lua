local M = class("FiveLineTaskMainChapterNewView",LikeOO.OOPopBase)

M.m_uiName = "FivelinesNew/FiveLineTaskMainChapterNew"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "new_str_0648")
	local show_point_cfg = self.m_model:getShowPointCfg()
	local reward_item_node = self:findGameObject("reward_item_node")
	local reward_bg_image_name = "a_zjm_gqjl_yuanbaodi" -- 默认用元宝底图
	self.m_reward_bg_image = self:findGameObject("reward_bg_image")
	GameUtil:updateResourcesImg(self.m_reward_bg_image, "Texture/main/" .. reward_bg_image_name)
	local drop = show_point_cfg.drop or {}
	local ui_element = GameUtil:updateItemElement(reward_item_node, drop[1], true, true)
	if show_point_cfg then
		if #drop > 0 and self.m_model.is_has_drop then
			local process_data = ui_element.process_data
			local reward_str = tostring(process_data.name) .. "x" .. tostring(process_data.data_num)
			self:setTextByLanKey("tips_text" ,"new_str_0721", Language:getTextByKey(show_point_cfg.name), reward_str)
			local data_type = process_data.data_type
			--local reward_bg_image_name = "a_zjm_gqjl_yuanbaodi" -- 默认用元宝底图
			--if data_type == RewardUtil.REWARD_TYPE_KEYS.EXP then
			--	reward_bg_image_name = "a_zjm_gqjl_jingyandi"-- 经验底图
			--elseif data_type == RewardUtil.REWARD_TYPE_KEYS.ITEM then
			--	if process_data.item_cfg.type == GlobalConfig.ITEM_TYPE.IDLE_DUST then
			--		reward_bg_image_name = "a_zjm_gqjl_tupodi" -- 突破丹底图
			--	end
			--end
			--self.m_reward_bg_image = self:findGameObject("reward_bg_image")
			--GameUtil:updateResourcesImg(self.m_reward_bg_image, "Texture/main/" .. reward_bg_image_name)
		else
			self:setTextByLanKey("tips_text","four_tower_str_0006")
		end
	else
		self:setTextByLanKey("tips_text","four_tower_str_0006")
	end
	self:refreshUI()
end

function M:refreshUI()
	self:updateLoopScroll()
end

--[[
	任务列表
]]
function M:updateLoopScroll()
	self.m_click_cell_object = nil
	local data = self.m_model:getMainQuestsData()
	self:setObjectVisible("CommonTipsNode", #data == 0)
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("task_loopscroll")
		local params = {
			ui_name = self.m_uiName,
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				local status = cell_data.status
				if status ~= -1 then
					self:updateMsg(status == 2 and "main_reward" or "goto_btn", cell_data)
					self.m_click_cell_object = cell_object
				end
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data, true)
	end
end

-- 更新
function M:updateScrollViewCell(index, cell_object, cell_data)
	local luabe = UIUtil.findLuaBehaviour(cell_object)
	local transform = cell_object.transform
	local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	local data = cell_data
	local cfg = data.cfg
	local cur_progress = data.cur_progress
	local target_value = data.target_value
	local status = data.status
	-- 名字
	local name_text = Language:getTextByKey("four_tower_str_0005",cfg.num)
	UIUtil.setTextByLanKey(transform, "name_text", name_text)
	-- 进度条
	--local slider = UIUtil.findSlider(transform, "progress_slider")
	--slider.value = cur_progress/target_value

	local progress_slider_text = LuaBehaviourUtil.setTextByLanKey(luabe, "progress_slider_text", "new_str_0471", cur_progress, target_value)
	local finish_text = LuaBehaviourUtil.setTextByLanKey(luabe, "finish_text", "new_str_0470")
	-- 前往、领取按钮
	local goto_btn = UIUtil.findButton(transform, "goto_btn")

	local goto_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "goto_btn_text", "new_str_0029")
	local receive_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "receive_btn_text", "new_str_0056")
	local tx_obj = self:findGameObject("UI_Task_TiShi_001")
	local incomplete_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "incomplete_btn_text", "new_str_0057")
	local goto_btn_text_show = false
	local receive_btn_text_show = false
	local incomplete_btn_text_show = false

	if status == 0 then --前往
		goto_btn.gameObject:SetActive(not data.lock_flag)
		local go_type = cfg.go_type or {}
		if _G.next(go_type) then
			UIUtil.setImg(transform, "a_ui_currency_btn_small_3", "common_ui", "goto_btn")
			goto_btn.enabled = true
			goto_btn_text_show = true
		else
			UIUtil.setImg(transform, "a_ui_currency_btn_small_3", "common_ui", "goto_btn")
			goto_btn.enabled = false
			incomplete_btn_text_show = true
		end
		--UIUtil.setImg(transform, "a_rw_jindu_lv", "main_ui", "progress_slider/Fill Area/Fill")
	elseif status == 2 then--领取
		goto_btn.gameObject:SetActive(true)
		goto_btn.enabled = true
		receive_btn_text_show = true
		UIUtil.setImg(transform, "a_ui_currency_btn_small_2", "common_ui", "goto_btn")
		--UIUtil.setImg(transform, "a_rw_jindu_cheng", "main_ui", "progress_slider/Fill Area/Fill")
	else-- 已领取
		goto_btn.gameObject:SetActive(false)
		--UIUtil.setImg(transform, "a_rw_jindu_cheng", "main_ui", "progress_slider/Fill Area/Fill")
	end
	goto_btn_text.gameObject:SetActive(goto_btn_text_show)
	receive_btn_text.gameObject:SetActive(receive_btn_text_show)
	incomplete_btn_text.gameObject:SetActive(incomplete_btn_text_show)
	-- 解锁文本
	--local lock_text = UIUtil.setTextByLanKey(transform, "lock_text", data.lock_text)

	local mask_show = data.lock_flag or status == -1
	UIUtil.setObjectVisible(transform, mask_show, "mask_img")
	--lock_text.gameObject:SetActive(mask_show)
	--slider.gameObject:SetActive(not mask_show)
	--slider.gameObject:SetActive(false)
	--goto_btn_text.gameObject:SetActive(not data.lock_flag)
	--finish_text.gameObject:SetActive(not data.lock_flag and status == 2)
	--progress_slider_text.gameObject:SetActive(not data.lock_flag and status ~= 2)
	--progress_slider_text.gameObject:SetActive(status ~= 2)
	local btn_spine = UIUtil.findTrans(transform, "btn_spine")
	--tx_obj.gameObject:SetActive(not data.lock_flag and status == 2)
	btn_spine.gameObject:SetActive(not data.lock_flag and status == 2)
	-- 奖励
	local drop = cfg.rewards or {}
	local reward_node = luaBehaviour:FindGameObject("reward_node")
	GameUtil:createRewards(reward_node.transform, drop, true, true, nil, 0.8)
	local out_color = data.lock_flag and Color( 120/255, 125/255, 132/255, 100/255) or Color( 184/255, 132/255, 19/255, 100/255)
	UIUtil.setOutlineExEffectColor(progress_slider_text, nil, out_color, 2)
	local task_finish_text = UIUtil.setTextByLanKey(transform, "task_finish_text", "new_str_0058")
	task_finish_text.gameObject:SetActive(not data.lock_flag and status == -1)
end

function M:runAnim(response)
	if self.m_click_cell_object then
		self:killAnim()
		self.m_control.m_view:lockTouch()
		self.m_control:setOnceTimer(0.3, function()
			self.m_control.m_view:unlockTouch()
		end)
		local luabe = UIUtil.findLuaBehaviour(self.m_click_cell_object)
		local cell_pos = self.m_click_cell_object.transform.localPosition
		local sequence = Tweening.DOTween.Sequence()
		sequence:Join(self.m_click_cell_object.transform:DOScale(0,0.2))
		sequence:AppendCallback(function()
			UIUtil.setLocalScale(self.m_click_cell_object.transform, 1, 1, 1)
			self:refreshUI()
			if response then
				RewardUtil:rewardTipsByData(response.reward)
			end
		end)
		sequence:OnComplete(function()
			self.m_sequence = nil
		end)
		sequence:SetAutoKill(true)
		self.m_sequence = sequence
	end
end

function M:killAnim()
	if self.m_sequence then
		self.m_sequence:Kill()
		self.m_sequence = nil
	end
end

function M:destroy()
	self:killAnim()
	M.super.destroy(self)
end

return M