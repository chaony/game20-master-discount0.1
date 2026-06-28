local M = class("MartialSelectPopView",LikeOO.OOPopBase)

M.m_uiName = "Pub/MartialSelectPop"
M.m_size_type = 2

local bg_tab = {
	{"a_ui_qinglong", "a_ui_qinglong1"},
	{"a_ui_xuanwu", "a_ui_xuanwu1"},
	{"a_ui_zhuque", "a_ui_zhuque1"},
	{"a_ui_baihu", "a_ui_baihu1"},
}
function M:onEnter()
	self:setTextByLanKey("close_title_text", "Pub_str_0020")
	self:setTextByLanKey("yes_btn_text", "new_str_0315")
	self:setTextByLanKey("tips_text", "Pub_str_0033")
	self.m_down_time = {}
	self:refreshUI()
	self:initTick()
end

function M:refreshUI()
	local gray_img = self:findImage("gray_img")
	for i,v in ipairs(self.m_model.m_martial) do
		local cell = self:findGameObject("cell_" .. i)
		local rect = cell:GetComponent("RectTransform")
		local luaBehaviour = cell:GetComponent("LuaBehaviour")
		local image = UIUtil.findImage(cell.transform, "Image")
		local select_img = UIUtil.findImage(cell.transform, "select_img")
		local down_time_text = UIUtil.findText(cell.transform, "Image/Image/down_time_text")
		UIUtil.setText(cell.transform, 300, "Image/cost_bg/Text")
		if v == self.m_model.m_select then
			-- UIUtil.setImg(cell.transform, bg_tab[i][1], "pub_ui", "Image")
			--UIUtil.setScale(cell.transform, 1)
			select_img.gameObject:SetActive(false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"UI_Pub_ShiLiback_001", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"UI_Pub_ShiLifront_001", false)
		else
			-- UIUtil.setImg(cell.transform, bg_tab[i][2], "pub_ui", "Image")
			--UIUtil.setScale(cell.transform, 0.9)
			select_img.gameObject:SetActive(false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"UI_Pub_ShiLiback_001", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"UI_Pub_ShiLifront_001", false)
		end

		if self.m_model:isOpened(v) then
			self.m_down_time[v] = down_time_text
			UIUtil.setTextColor(cell.transform, GlobalConfig.COMMON_COLLOR.COMMON_4, "Image/Image/down_time_text")
			UIUtil.setObjectVisible(cell.transform, false, "Image/cost_bg")
			 image.material = nil
			--image.color = Color( 1, 1, 1)
		else
			self.m_down_time[v] = nil
			UIUtil.setTextColor(cell.transform, GlobalConfig.COMMON_COLLOR.COMMON_1, "Image/Image/down_time_text")
			UIUtil.setObjectVisible(cell.transform, true, "Image/cost_bg")
			UIUtil.setText(cell.transform, Language:getTextByKey("Pub_str_0007"), "Image/Image/down_time_text")
			 image.material = gray_img.material
			--image.color = Color( 0.53, 0.53, 0.53)
		end

	end
	--self:setObjectVisible("yes_btn", self.m_model.m_select ~= self.m_model.m_cur_martial)
end

function M:initTick()
	local function tick(dt)
		local data = self.m_model.m_end_ts
		local down_time = data - UserDataManager:getServerTime()
		if down_time >= 0 then
			local text = GameUtil:formatTimeBySecond(down_time)
			for k,v in pairs(self.m_down_time) do
				--v.text = Language:getTextByKey("Pub_str_0008") .. text
				v.text = text
			end
		end
	end
	tick(0)
	self.tick_id = self.m_control:setTimer(1, tick)
end

return M