local M = class("FineClothesView",LikeOO.OOPopBase)

M.m_uiName = "FineClothes/FineClothes"
M.m_size_type = 2

local __TAB_BTN_NODE = {
	{btn_key = "toggle_btn_1", btn_text = "btn_text_1_price", btn_text_key = "fine_clothes_008"},
	{btn_key = "toggle_btn_2", btn_text = "btn_text_2_price", btn_text_key = "fine_clothes_008"},
}

function M:onEnter()
	self:setTextByLanKey("common_title_text", "fine_clothes_001")
	self.m_gray_image = self:findImage("gray_img")
	self.task_reward_item = self:findGameObject("task_reward_item")
	self:setObjectVisible("task_reward_item", false)
	local gift_data_page_1 = self.m_model:getGiftDataWithPageID(1) or {}
	local gift_data_page_2 = self.m_model:getGiftDataWithPageID(2) or {}
	self:setTextByLanKey("btn_get_text_1", "fine_clothes_009", gift_data_page_1.price or -1)
	self:setTextByLanKey("btn_get_text_2", "fine_clothes_009", gift_data_page_2.price or -1)
	self:setTextByLanKey("btn_text_1", "fine_clothes_010")
	self:setTextByLanKey("btn_text_2", "fine_clothes_010")
	
	for k, v in pairs(__TAB_BTN_NODE) do
		local gift_data_page = self.m_model:getGiftDataWithPageID(k) or {}
		self:setTextByLanKey(v.btn_text, gift_data_page.price or -1)

		local tog_btn = self:findToggle(v.btn_key)
		if k == self.m_model:getCurrentPage() then
			tog_btn.isOn = true
		end
		UIUtil.addToggleListener(tog_btn, function(is_on)
			if is_on then
				self:updateMsg("page_update", k)
			end
		end, nil, self.m_uiName)
	end
	self:refreshToggleStatus()
	self:initReward()

	RedPointUtil:saveLocalRedPointFreshTime("FineClothes") --每日首次登录直接弹出
end

function M:refreshToggleStatus()
	for k, v in pairs(__TAB_BTN_NODE) do
		if k == self.m_model:getCurrentPage() then
			--self:setTextColor(v.btn_text, GlobalConfig.COMMON_COLLOR.COMMON_1)
			self:setObjectVisible("reward_node_" .. k, true)
		else
			--self:setTextColor(v.btn_text, GlobalConfig.COMMON_COLLOR.COMMON_5)
			self:setObjectVisible("reward_node_" .. k, false)
		end
	end
end

function M:initReward()
	for k, v in pairs(__TAB_BTN_NODE) do
		local task_reward_content = self:findGameObject("reward_content_" .. k)
		UIUtil.destroyAllChild(task_reward_content.transform)
		local gift_data = self.m_model:getGiftDataWithPageID(k)
		for kk, vv in ipairs(gift_data.reward or {}) do
			local reward_item = GameUtil:instanceObject(self.task_reward_item, task_reward_content)
			local data = RewardUtil:getProcessRewardData(vv)
			local luaBehaviour = UIUtil.findLuaBehaviour(reward_item)
			if luaBehaviour and data then
				LuaBehaviourUtil.setText(luaBehaviour, "item_name", data.name or "")
			end
			reward_item:SetActive(true)
			local ItemNode = UIUtil.findTrans(reward_item.transform, "ItemNode")
			GameUtil:updateItemElement(ItemNode, vv, true, true)
		end
	end
	self:refreshRewardStatus()
end

function M:refreshRewardStatus()
	for k, v in pairs(__TAB_BTN_NODE) do
		local gift_data = self.m_model:getGiftDataWithPageID(k)
		local btn_get_img = self:findImage("btn_get_" .. k)
		if self.m_model:checkGiftTimesLimited(k, gift_data.id) == false then
			btn_get_img.material = nil
		else
			btn_get_img.material = self.m_gray_image.material
		end
	end
end

function M:updateActivityTimer()
	local end_ts = self.m_model:getEndTs()
	if end_ts >= 0 then
		local text = GameUtil:formatTimeBySecond(end_ts, 999)
		self:setTextByLanKey("time_down_text", text)
	else
		self:updateMsg(99999)
	end
end

return M