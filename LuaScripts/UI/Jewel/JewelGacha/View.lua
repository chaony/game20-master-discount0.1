local M = class("JewelGachaView",LikeOO.OOPopBase)

M.m_uiName = "Jewel/JewelGacha"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("close_title_text", "jewel_text_002")
	self:setTextByLanKey("wish_btn_text", "jewel_text_015")
	self:setTextByLanKey("book_btn_text", "jewel_text_016")
	self:setTextByLanKey("main_btn_text", "jewel_text_001")
	self:setTextByLanKey("one_btn_text", "jewel_text_013", 1)
	self:setTextByLanKey("ten_btn_text", "jewel_text_013", 10)
	self:setObjectVisible("help_btn", true)
	self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {item_id = self.m_model.m_one_cost[2]})
	for i, v in pairs(self.m_model.m_wishes) do
		local obj = self:findGameObject("wish_jewel_" .. i)
		local luaBehaviour = UIUtil.findLuaBehaviour(obj)
		local function button_click()
			self:updateMsg("wish_btn", {times = v.times})
		end
		luaBehaviour:RegistButtonClick(button_click)
		--UIUtil.setButtonClick(obj.transform, click, {times = v.times}, nil, self.m_uiName)
		UIUtil.setText(obj.transform, Language:getTextByKey("jewel_text_014", v.times), "Image/times_text")
	end
	self.m_one_btn = self:findGameObject("one_btn")
	self.m_ten_btn = self:findGameObject("ten_btn")
	self.m_times_slider = self:findSlider("wish_slider")
	self.m_times_text = self:findText("wish_times_text")
	self:refreshUI()
end

function M:refreshUI()
	self:refreshWishJewels()
	self:refreshTimes()
	self:refreshBtn()
end

--抽卡消耗
function M:refreshBtn()
	--one btn
	local one_cost = self.m_model.m_one_cost
	local itemData = RewardUtil:getProcessRewardData(one_cost)
	UIUtil.setImg(self.m_one_btn.transform, itemData.icon_name, "item_icon", "item_img")
	self.m_model.m_is_can_gacha = true
	self.m_model.m_is_can_gacha10 = true
	if itemData.user_num >= itemData.data_num then
		UIUtil.setText(self.m_one_btn.transform, itemData.data_num, "item_num")
	else
		self.m_model.m_is_can_gacha = false
		UIUtil.setText(self.m_one_btn.transform, "<color=#F33535>" .. itemData.data_num .. "</color>", "item_num")
	end
	--ten btn
	local ten_cost = self.m_model.m_ten_cost
	itemData = RewardUtil:getProcessRewardData(ten_cost)
	UIUtil.setImg(self.m_ten_btn.transform, itemData.icon_name, "item_icon", "item_img")
	if itemData.user_num >= itemData.data_num then
		UIUtil.setText(self.m_ten_btn.transform, itemData.data_num, "item_num")
	else
		self.m_model.m_is_can_gacha10 = false
		UIUtil.setText(self.m_ten_btn.transform, "<color=#F33535>" .. itemData.data_num .. "</color>", "item_num")
	end
	--主页入口按钮，没有秘宝就不显示了
	local jewels = UserDataManager.jewel_data:getJewels()
	if next(jewels) then
		self:setObjectVisible("main_btn", true)
	else
		self:setObjectVisible("main_btn", false)
	end
end

--寻宝次数进度条
function M:refreshTimes()
	local value, value_text = self.m_model:getWishValue()
	self.m_times_slider.value = value
	self.m_times_text.text = value_text
end

--心愿秘宝
function M:refreshWishJewels()
	for i, v in pairs(self.m_model.m_wishes) do
		local obj = self:findGameObject("wish_jewel_" .. i)
		local luaBehaviour = UIUtil.findLuaBehaviour(obj)
		local id = v.jewel
		if id and id > 0 then
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"add", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"tx_mask", true)
			local cfg = UserDataManager.jewel_data:getDetailCfg(id)
			local icon_img = luaBehaviour:FindGameObject("tx_img")
			GameUtil:updateResourcesImg(icon_img, "Texture/jewelIcon/" .. cfg.icon)
			--LuaBehaviourUtil.setImg(luaBehaviour,"tx_img", cfg.icon, "jewel_ui")
		else
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"add", true)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"tx_mask", false)
		end
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"check", v.award == 1)
	end
end

function M:playGacha()
	self:setObjectVisible("UI_Jewel_chouka", false)
	self:setObjectVisible("UI_Jewel_chouka", true)
end

function M:closeGacha()
	self:setObjectVisible("UI_Jewel_chouka", false)
end

function M:destroy()
	if self.m_attr_node then
		self.m_attr_node:destroy()
		self.m_attr_node = nil
	end
	M.super.destroy(self)
end

return M