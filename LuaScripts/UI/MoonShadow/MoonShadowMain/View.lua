local M = class("MoonShadowMainView",LikeOO.OOPopBase)

M.m_uiName = "MoonShadow/MoonShadowMain"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
	self.m_btn_openID_cache = {
		{open_id = self.m_model.m_activity_openID_Date, btn_name = "date_btn", image_name_1 = "date_image_1", image_name_2 = "date_image_2"},
		{open_id = self.m_model.m_activity_openID_Gift, btn_name = "gift_btn", image_name_1 = "gift_image_1", image_name_2 = "gift_image_2"},
		{open_id = self.m_model.m_activity_openID_Battle, btn_name = "battle_btn", image_name_1 = "battle_image_1", image_name_2 = "battle_image_2"},
	}
	self:setTextByLanKey("close_title_text", "moon_shadow_str_001")
	self:setTextByLanKey("btn_name_date_text", "moon_shadow_str_002")
	self:setTextByLanKey("btn_name_gift_text", "moon_shadow_str_003")
	self:setTextByLanKey("btn_name_battle_text", "moon_shadow_str_004")
	self.m_gray_material = self:findText("material_node").material
	local _, tip_str = self.m_model:getActivityOpenStatus(self.m_model.m_activity_openID_MoonShadow)
	self:setText("time_text", tip_str)
	self:refreshUI()
end

function M:refreshUI()
	local btn_item
	local image_item_1
	local image_item_2
	local open_status
	for _, cfg_item in ipairs(self.m_btn_openID_cache) do
		btn_item = self:findButton(cfg_item.btn_name)
		open_status = self.m_model:getActivityOpenStatus(cfg_item.open_id)
		--btn_item.enabled = open_status ~= 0
		image_item_1 = self:findImage(cfg_item.image_name_1)
		image_item_2 = self:findImage(cfg_item.image_name_2)
		if open_status == 0 then
			image_item_1.material = self.m_gray_material
			image_item_2.material = self.m_gray_material
		end
	end
	self:refreshRedPoint()
end

function M:refreshRedPoint()
	self:setObjectVisible("date_red_point", (RedPointUtil:hasRedPointById(self.m_model.m_activity_openID_Date) == true and self.m_model:getActivityOpenStatus(self.m_model.m_activity_openID_Date) == 1) or self.m_model:hasMoonShadowDateRedPoint() == true)
	self:setObjectVisible("gift_red_point", RedPointUtil:hasRedPointById(self.m_model.m_activity_openID_Gift) == true and self.m_model:getActivityOpenStatus(self.m_model.m_activity_openID_Gift) == 1)
	self:setObjectVisible("battle_red_point", RedPointUtil:hasRedPointById(self.m_model.m_activity_openID_Battle) == true and self.m_model:getActivityOpenStatus(self.m_model.m_activity_openID_Battle) == 1)
end

return M