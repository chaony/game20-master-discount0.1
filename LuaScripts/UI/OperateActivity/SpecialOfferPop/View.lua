local M = class("SpecialOfferPopView", LikeOO.OOPopBase)

M.m_uiName = "OperateActivity/SpecialOfferPop"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "new_str_0797")
	self.gray_img = self:findImage("gray_img")
	self.one_key_btn = self:findGameObject("one_key_btn")
	self:refreshUI()
end

function M:refreshUI()
	self:createLoopScroll()
	if self.m_model:getPackCanBuy() then
		self.one_key_btn:GetComponent("Image").material = nil
		self.one_key_btn:GetComponent("Button").interactable = true
	else
		self.one_key_btn:GetComponent("Image").material = self.gray_img.material
		self.one_key_btn:GetComponent("Button").interactable = false
	end
end

function M:createLoopScroll()
	local data = self.m_model:getListData()
	if self.m_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params ={
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell =function(index, cell_obj, cell_data)
				self:update_Gift(cell_obj, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg(click_name, cell_data)
			end
		}
		self.m_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_scroll_view:reloadData(data)
	end
end

function M:update_Gift(cell_obj, cell_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
	if luaBehaviour then
		local rewardNode = luaBehaviour:FindGameObject("rewardNode")
		GameUtil:createRewards(rewardNode.transform, cell_data.reward, true, true)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_red_point", false)
		local gift = self.m_model:getGiftOffData(cell_data.id)
		local pay = self.m_model:getBuyGiftOffData(cell_data.id)
		if cell_data.charge_id == 0 then
			if gift == true then
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_reward_btn", false)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_reward", true)
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "get_reward_text", "gf_str_0048")
			else
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_reward_btn", true)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_red_point", true)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_reward", false)
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "get_reward_btn_text", "new_str_0278")
			end
		else
			if pay == true or self.m_model.m_gift_off_data.once_pay > 0 then
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_reward_btn", false)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_reward", true)
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "get_reward_text", "gf_str_0048")
			else
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_reward_btn", true)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_reward", false)
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "get_reward_btn_text", "gf_str_0029", cell_data.price)
			end
		end
	end
end

return M