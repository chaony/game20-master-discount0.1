local M = class("QiXiCoupleView",LikeOO.OOPopBase)

M.m_uiName = "QiXi/QiXiCouple"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
	if self.m_model.is_tokens == true then
		self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 20})
	end
	local active_data = self.m_model:getActiveData() or {}
	self:setText("close_title_text", active_data.name or "")
	self:setTextByLanKey("text_timer_title", "qi_xi_008")
	self:setTextByLanKey("title_name_1", "qi_xi_010")
	self:setTextByLanKey("title_name_2", "qi_xi_011")
	self:setTextByLanKey("title_name_3", "qi_xi_012")
	self:setTextByLanKey("title_name_4", "qi_xi_013")
	self:refreshUI()
	self:moveToIndex()
end

function M:refreshUI()
	self:updateGiftButton()
	self:createLoopScroll()
end

function M:createLoopScroll()
	local data = self.m_model:getGiftData()
	if self.m_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params ={
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_obj, cell_data)
				self:updateCell(index, cell_obj, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg("get_reward", cell_data)
			end
		}
		self.m_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_scroll_view:reloadData(data, true)
	end
end

function M:updateCell(index, obj, cell_data)
	local cfg = cell_data.cfg
	local status_free = cell_data.status_free
	local status_fee = cell_data.status_fee
	local status_pay = self.m_model:getwrriorPayStatus()
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	if luaBehaviour then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "dl_text", "sdk_txt_007")
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_title", "gf_str_0028", index)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "uncomplished_text", "qi_xi_017")
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "buy_btn_text", "qi_xi_016")
		
		local free_itemParent = luaBehaviour:FindGameObject("free_itemParent")
		UIUtil.destroyAllChild(free_itemParent.transform)
		local free_item = GameUtil:createItemElement(cfg.free_reward[1], true, true, nil)
		UIUtil.setScale(free_item.transform, 0.8)
		free_item.transform:SetParent(free_itemParent.transform, false)
		local luaBhvItemFree = UIUtil.findLuaBehaviour(free_item)
		if luaBhvItemFree then
			if status_free == 2 then
				LuaBehaviourUtil.setObjectVisible(luaBhvItemFree, "duigoudi_img", true)
			else
				LuaBehaviourUtil.setObjectVisible(luaBhvItemFree, "duigoudi_img", false)
			end
		end
		
		local pay_itemParent = luaBehaviour:FindGameObject("pay_itemParent")
		UIUtil.destroyAllChild(pay_itemParent.transform)
		local pay_item = GameUtil:createItemElement(cfg.fee_incentives[1], true, true, nil)
		UIUtil.setScale(pay_item.transform, 0.8)
		pay_item.transform:SetParent(pay_itemParent.transform, false)
		local luaBhvItemPay = UIUtil.findLuaBehaviour(pay_item)
		if luaBhvItemPay then
			if status_fee == 2 then
				LuaBehaviourUtil.setObjectVisible(luaBhvItemPay, "duigoudi_img", true)
			else
				LuaBehaviourUtil.setObjectVisible(luaBhvItemPay, "duigoudi_img", false)
				if status_pay == 0 then
					LuaBehaviourUtil.setObjectVisible(luaBhvItemPay, "lock_image", true)
				else
					LuaBehaviourUtil.setObjectVisible(luaBhvItemPay, "lock_image", false)
				end
			end
		end

		local status = 0
		if status_free == 1 or status_fee == 1 then
			status = 1
		elseif status_free == 2 then
			status = 2
		end
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "uncomplished_flag", status == 0)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_btn", status == 1)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "got_flag", status == 2)
	end
end

function M:moveToIndex()
	if self.m_scroll_view then
		local day_count = self.m_model:getLoginDayCount() or 1
		self.m_scroll_view:moveToCellIndex(day_count - 4)
	end
end

function M:updateGiftButton()
	local pay_status = self.m_model:getwrriorPayStatus()
	if pay_status > 0 then
		self:setObjectVisible("gift_buy_btn", false)
	else
		local war_order_data = self.m_model:getWarOrderData() or {}
		self:setTextByLanKey("gift_buy_btn_text", "qi_xi_007", war_order_data.price or 0)
	end
end

function M:updateActivityTimer()
	local time_left = self.m_model:getTimeLeft()
	if time_left > 0 then
		self:setTextByLanKey("text_timer", GameUtil:formatTimeBySecond(time_left))
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