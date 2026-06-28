local M = class("QiXiShoppingView",LikeOO.OOPopBase)

M.m_uiName = "QiXi/QiXiShopping"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
	self.m_gray_material = self:findText("material_node").material
	local active_data = self.m_model:getActiveData() or {}
	self:setText("close_title_text", active_data.name or "")
	self:setTextByLanKey("count_down_title_text", "qi_xi_026")
	self:setTextByLanKey("buy_title_text", "qi_xi_028")
	self:setTextByLanKey("rank_title_text", "qi_xi_030")
	self:setTextByLanKey("payback_title_text", "qi_xi_031")
	self:setTextByLanKey("shopping_rank_btn_text", "qi_xi_032")
	RedPointUtil:saveLocalRedPointFreshTime("QiXiShoppingRedDot")
	local attr_mode = 1
	if self.m_model:getTokenFlag() == true then
		attr_mode = 20
	end
	self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = attr_mode})
	self:refreshUI()
end

function M:refreshUI()
	self:refreshLeftUp()
	self:updateGiftInfo()
end

function M:refreshLeftUp()
	for i = 1, 8 do
		local base_btn_name = "word_btn_" .. i
		local reward = self.m_model:getReward(base_btn_name) or {}
		local free_itemParent = self:findGameObject(base_btn_name)
		UIUtil.destroyAllChild(free_itemParent.transform)
		local free_item = GameUtil:createItemElement(reward[1], false, true)
		UIUtil.setScale(free_item.transform, 1.5)
		free_item.transform:SetParent(free_itemParent.transform, false)
		local luaBhvItemFree = UIUtil.findLuaBehaviour(free_item)
		if luaBhvItemFree then
			LuaBehaviourUtil.setObjectVisible(luaBhvItemFree, "quality_img", false)
		end
	end
end

function M:updateGiftInfo()
	local info = self.m_model:getInfo()
	self:setTextByLanKey("buy_text", "qi_xi_029", info.score or 0)
	local rank_text = "qi_xi_045"
	if info.rank and info.rank > 0 then
		rank_text = info.rank
	end
	self:setTextByLanKey("rank_text", rank_text)
	self:setTextByLanKey("payback_text", info.rtn or 0)
	
	local gift_data_1 = self.m_model:getGiftData(1)
	self:setTextByLanKey("gift_name_text_1", gift_data_1.cfg.gift_name)
	self:setTextByLanKey("gift_btn_text_1", gift_data_1.cfg.price)
	if gift_data_1.cfg.time_limit > 0 then
		self:setTextByLanKey("limit_text_1", "qi_xi_034", gift_data_1.cfg.time_limit)
	else
		self:setTextByLanKey("limit_text_1", "qi_xi_033")
	end
	local gift_data_2 = self.m_model:getGiftData(2)
	if gift_data_2.status then
		self:setTextByLanKey("gift_name_text_2", gift_data_2.cfg.gift_name)
		if gift_data_2.status == 1 then
			self:setTextByLanKey("gift_btn_text_2", "qi_xi_046", gift_data_2.cfg.price)
		else
			self:setTextByLanKey("gift_btn_text_2", "qi_xi_048")
			local btn_img = self:findImage("gift_btn_2")
			btn_img.material = self.m_gray_material
		end
		if gift_data_2.cfg.time_limit > 0 then
			self:setTextByLanKey("limit_text_2", "qi_xi_034", gift_data_2.cfg.time_limit)
		else
			self:setTextByLanKey("limit_text_2", "qi_xi_033")
		end
	else
		self:setObjectVisible("gift_node_2", false)
	end

	if self.m_model:getTimeLimit() == 1  then
		local btn_img1 = self:findImage("gift_btn_1")
		local btn_img2 = self:findImage("gift_btn_2")
		local cost_img = self:findImage("gift_btn_cost_img")
		btn_img1.material = self.m_gray_material
		btn_img2.material = self.m_gray_material
		cost_img.material = self.m_gray_material
	end
	
	self:updateRewardLoopScroll_1()
	self:updateRewardLoopScroll_2()
end

function M:updateRewardLoopScroll_1()
	local data = self.m_model:getGiftData(1)
	if data then
		local reward_data = data.cfg.reward or {}
		if self.m_reward_loop_scroll_view_1 == nil then
			local loopscroll = self:findGameObject("reward_loopscroll_1")
			local params = {
				show_data = reward_data,
				one_line_count = 1,
				loop_scroll_object = loopscroll,
				update_cell = function(index, cell_object, cell_data)
					local item_data = RewardUtil:getProcessRewardData(cell_data)
					GameUtil:updateItemElementByData(cell_object, item_data, true, true)
				end,
				click_func = function(index, cell_object, cell_data, click_object, click_name)

				end
			}
			self.m_reward_loop_scroll_view_1 = LoopScrollViewUtil.new(params)
		else
			self.m_reward_loop_scroll_view_1:reloadData(reward_data)
		end
	end
end

function M:updateRewardLoopScroll_2()
	local data = self.m_model:getGiftData(2)
	if data then
		local reward_data = data.cfg.reward or {}
		if self.m_reward_loop_scroll_view_2 == nil then
			local loopscroll = self:findGameObject("reward_loopscroll_2")
			local params = {
				show_data = reward_data,
				one_line_count = 1,
				loop_scroll_object = loopscroll,
				update_cell = function(index, cell_object, cell_data)
					local item_data = RewardUtil:getProcessRewardData(cell_data)
					GameUtil:updateItemElementByData(cell_object, item_data, true, true)
				end,
				click_func = function(index, cell_object, cell_data, click_object, click_name)

				end
			}
			self.m_reward_loop_scroll_view_2 = LoopScrollViewUtil.new(params)
		else
			self.m_reward_loop_scroll_view_2:reloadData(reward_data)
		end
	end
end

function M:updateActivityTimer()
	local time_left = self.m_model:getTimeLeft()
	if time_left > 0 then
		self:setTextByLanKey("count_down_text", GameUtil:formatTimeBySecond(time_left))
	else
		self:updateMsg(99999)
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