local M = class("RacconCollectView",LikeOO.OOPopBase)

M.m_uiName = "Raccon/RacconCollect"
M.m_size_type = 1
M.m_iphoneXAdapter = true
local fly_anim_init_pos = {-448, -220, 3}
function M:onEnter()
	--if self.m_model.m_active_data ~= nil then
	--	self:setTextByLanKey("close_title_text", self.m_model.m_active_data.cell_data.cfg.name)
	--	local bg_img = self:findGameObject("bg_img")
	--	GameUtil:updateResourcesImg(bg_img,"Texture/ActiveCurrent/"..self.m_model.m_background) --设置背景
	--end
	self:setTextByLanKey("close_title_text","raccon_text_0002")
	self:setTextByLanKey("look_btn_text","new_str_0724")
	self:setTextByLanKey("gift_btn_text","raccon_text_0017")
	self:setTextByLanKey("get_des_text","raccon_text_0018")
	self:setTextByLanKey("tab_btn1_text1","raccon_text_0015")
	self:setTextByLanKey("tab_btn1_text2","raccon_text_0015")
	self:setTextByLanKey("tab_btn2_text1","raccon_text_0016")
	self:setTextByLanKey("tab_btn2_text2","raccon_text_0016")
	self.m_sequence_tab = {}
	self:refreshUI()
end

--刷新UI
function M:refreshUI()
	self:updateBtnStatus()
	self:setHeroInfo()
	self:updateLoopScroll()
end

function M:updateBtnStatus()
	self:setObjectVisible("tab_btn1_text1", self.m_model.m_cur_tab_index == 1)
	self:setObjectVisible("tab_btn1_text2", self.m_model.m_cur_tab_index ~= 1)
	self:setObjectVisible("tab_btn2_text1", self.m_model.m_cur_tab_index == 2)
	self:setObjectVisible("tab_btn2_text2", self.m_model.m_cur_tab_index ~= 2)
end

function M:refreshRedPoint()
	self:setObjectVisible("tab_btn_red_point_img1", self.m_model.m_red_flag1)
	self:setObjectVisible("tab_btn_red_point_img2", self.m_model.m_red_flag2)
end

function M:showClickTx()
	if self.m_show_tx then
		return
	end
	self.m_show_tx = true
	self:setObjectVisible("UI_Raccon_JiKaCe_001", true)
	self.m_control:setOnceTimer(1,function()
		self.m_show_tx = false
		self:setObjectVisible("UI_Raccon_JiKaCe_001", false)
	end)
end

function M:setHeroInfo()
	local card_count = self.m_model:getCardCount()
	if card_count == 0 then
		for i = 1, 3 do
			self:setObjectVisible("hero_img" .. i, false)
		end
		return
	end
	
	for i = 1, card_count do
		self:setObjectVisible("hero_img" .. i, true)
		local card_data, card_img, card_name = self.m_model:getCardData(i)
		if card_data then
			local reward_data = RewardUtil:getProcessRewardData(card_data[1])
			local hero_img = self:findGameObject("hero_img" .. i)
			local luaBehaviour = UIUtil.findLuaBehaviour(hero_img.transform)
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "hero_text", "x" .. reward_data.user_num)
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "hero_name_text", card_name)
			GameUtil:updateResourcesImg(hero_img.gameObject, "Texture/raccon/" .. card_img)
		end
	end
	
	local hide_index = card_count + 1
	if hide_index <= 3 then
		for i = hide_index, 3 do
			self:setObjectVisible("hero_img" .. i, false)
		end
	end
end

--右上，传记详情
function M:updateLoopScroll()
	local data = self.m_model:getZhuanjiDetailData()
	if self.m_loop_scroll_zhuanji_detail == nil then
		local loopscroll = self:findGameObject("loopscroll")
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
						self:updateMsg(status == 1 and "detail_reward_btn" or "detail_goto_btn", cell_data)
					end
				elseif click_name == "jifen_obj" then
					GameUtil:lookInfoTips(self.m_control, {click_transform = click_object.transform, msg = Language:getTextByKey("tid#EventPointDes_1")})
				end
			end
		}
		self.m_loop_scroll_zhuanji_detail = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_zhuanji_detail:reloadData(data)
	end
	self:refreshRedPoint()
end

-- 更新
function M:updateLoopScrollCell(index, cell_object, cell_data)
	local transform = cell_object.transform
	local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	local node = luaBehaviour:FindGameObject("node")

	-- 名字
	UIUtil.setTextByLanKey(node.transform, "name_text", cell_data.name)
	UIUtil.setTextByLanKey(node.transform, "reward_num_text", tostring(cell_data.score))

	--进度
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "progress_text", "new_str_0471", math.min(cell_data.value or 0, cell_data.target_value), cell_data.target_value)
	if cell_data.target_type == 378 then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "progress_text", "new_str_0471",cell_data.status == 0 and 0 or 1, 1)
	end
	-- LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "progress_text", "new_str_0471", math.min(cell_data.value, cell_data.target_value), cell_data.target_value)
	-- 前往、领取按钮
	local goto_btn = UIUtil.findButton(node.transform, "goto_btn")
	local goto_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "goto_btn_text", "new_str_0029")
	local receive_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "receive_btn_text", "new_str_0056")
	local incomplete_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "incomplete_btn_text", "new_str_0058")
	local goto_btn_text_show = false
	local receive_btn_text_show = false
	local incomplete_btn_text_show = false
	if cell_data.status == 0 then--前往
		goto_btn.gameObject:SetActive(not cell_data.lock_flag)
		local go_type = {cell_data.go_type}  or {}
		if _G.next(go_type) then
			UIUtil.setImg(node.transform, "a_ui_currency_btn_small_3", "common_ui", "goto_btn")
			goto_btn.enabled = true
			goto_btn_text_show = true
		else
			UIUtil.setImg(node.transform, "a_ui_currency_btn_small_3", "common_ui", "goto_btn")
			goto_btn.enabled = false
			incomplete_btn_text_show = true
		end

	elseif cell_data.status == 1 then--可领取
		goto_btn.gameObject:SetActive(true)
		goto_btn.enabled = true
		receive_btn_text_show = true
		UIUtil.setImg(node.transform, "a_ui_currency_btn_small_2", "common_ui", "goto_btn")
	else-- 已领取
		goto_btn.gameObject:SetActive(false)
		incomplete_btn_text_show = true
	end

	goto_btn_text.gameObject:SetActive(goto_btn_text_show)
	receive_btn_text.gameObject:SetActive(receive_btn_text_show)
	incomplete_btn_text.gameObject:SetActive(incomplete_btn_text_show)

	local btn_spine = UIUtil.findTrans(node.transform, "btn_spine")
	btn_spine.gameObject:SetActive(not cell_data.lock_flag and cell_data.status == 1)

	-- 奖励
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "reward_node_1", false)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "reward_node_2", false)
	if cell_data.reward[1] ~= nil then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "reward_node_1", true)
		local reward_node_1 = luaBehaviour:FindRectTransform("reward_node_1")
		GameUtil:createRewards(reward_node_1, {cell_data.reward[1]}, true, true, nil, 0.85)
	end
	if cell_data.reward[2] ~= nil then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "reward_node_2", true)
		local reward_node_2 = luaBehaviour:FindRectTransform("reward_node_2")
		GameUtil:createRewards(reward_node_2, {cell_data.reward[2]}, true, true, nil, 0.85)
	end

	LuaBehaviourUtil.setText(luaBehaviour, "reward_num_text",tostring(cell_data.score) )
end

function M:killAnim(i)
	if self.m_sequence_tab[i] then
		self.m_sequence_tab[i]:Kill()
		self.m_sequence_tab[i] = nil
	end
end

function M:playFlyAnim(reward)
	for i = 1, 3 do
		local fly_spine = self:findGameObject("hero_lizi_spine" .. i)
		local start_pos = fly_spine.transform.position
		self:runAnim(i, fly_spine, start_pos, i == 3 and reward or nil)
	end
end

function M:runAnim(i, fly_obj, start_pos, reward)
	if fly_obj then
		self:killAnim()
		self.m_control.m_view:lockTouch()
		self.m_control:setOnceTimer(0.72, function()
			self.m_control.m_view:unlockTouch()
			if reward then
				RewardUtil:rewardTipsByData(reward)
				self:refreshUI()
			end
		end)
		local trans = fly_obj.transform
		self:setObjectVisible("hero_lizi_spine" .. i, true)
		UIUtil.setLocalPosition(trans, start_pos.x, start_pos.y, 0)
		local end_btn =self:findGameObject("end_pos")
		local end_pos = end_btn.transform.localPosition --trans.parent:InverseTransformPoint(end_btn.transform.position)
		local sequence = Tweening.DOTween.Sequence()
		sequence:Append(trans:DOLocalMove(Vector3(end_pos.x, end_pos.y, 0),0.5))
		sequence:AppendCallback(function()
			UIUtil.setLocalPosition(trans, fly_anim_init_pos[i], start_pos.y, 0)
		end)
		sequence:OnComplete(function()
			self.m_sequence_tab[i] = nil
			self:setObjectVisible("hero_lizi_spine" .. i, false)
		end)
		sequence:SetAutoKill(true)
		self.m_sequence_tab[i] = sequence
	end
end

function M:destroy()
	for i = 1, 3 do
		self:killAnim(i)
	end
	M.super.destroy(self)
end

return M