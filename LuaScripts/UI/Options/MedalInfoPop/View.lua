local M = class("MedalInfoPopView",LikeOO.OOPopBase)

M.m_uiName = "Options/MedalInfoPop"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
	self.eqp_content = self:findGameObject("eqp_content")
	self.eqp_content_fitter = self.eqp_content:GetComponent("ContentImmediate")
	
	self.m_attr_node = self:findGameObject("attr_node") -- 基础属性的node
	self.m_attrs_node = self:findGameObject("attrs_node") -- 基础属性总节点
	
	self:setTextByLanKey("common_title_text", "medal_text_0009")
	self:refreshUI()
end

function M:refreshUI()
	self:refreshTopNode()
	self:refreshMiddleNode()
	self:refreshButtomNode()
	self.eqp_content_fitter:ForceRefreshSize()
end

function M:refreshButtomNode()
	self:setObjectVisible("btn_ok", false)
	--local isShowBtn = self.m_model.m_lookSelf and (self.m_model.m_overTimer > 0)
	--self:setObjectVisible("btn_ok", isShowBtn)
	--if isShowBtn then
	--	local wearText = self.m_model.m_isWear and "medal_text_0006" or "medal_text_0005"
	--	self:setTextByLanKey("text_btnText", wearText)
	--end
end

function M:refreshMiddleNode()
	local medalXlsxData = self.m_model.m_medalXlsxData
	self:setTextByLanKey("shuxing_text", "medal_text_0002")
	--self:updateBaseAttrLoopScroll()
	self:setTextByLanKey("text_shuxingDes", medalXlsxData.status_des)
	
	self:setTextByLanKey("text_unLock", "medal_text_0003")
	local unLockContent = Language:getTextByKey(medalXlsxData.lock_des)
	local effectType = medalXlsxData.type
	local isTeamEft = effectType == 2
	if isTeamEft then
		unLockContent = unLockContent .. "\n"..Language:getTextByKey("medal_text_0004")
	end
	unLockContent = unLockContent .. "\n"..Language:getTextByKey(medalXlsxData.des)
	self:setTextByLanKey("text_unLockDescribe", unLockContent)
end

function M:refreshTopNode() 
	local isExist = (self.m_model.m_overTimer > 0) and self.m_model.m_lookSelf
	self:setObjectVisible("timerNode", isExist)
	local iconView = self:findGameObject("MedalNode")
	GameUtil:updateMedalElement(iconView, self.m_model.m_medalId, false, self.m_model.m_lookSelf)
	local medalXlsxData = self.m_model.m_medalXlsxData
	self:setTextByLanKey("text_name", medalXlsxData.name)

	if isExist then
		self:setTextByLanKey("text_timerTitle", "medal_text_0001")
		local day = medalXlsxData.keep_time
		local overTimer = self.m_model.m_overTimer
		if self.m_model.m_lookSelf and overTimer > 0 then
			local medalOverT = TimeUtil.gmTime(overTimer)
			local timerFormat = string.format("%04d-%02d-%02d", medalOverT.year, medalOverT.month, medalOverT.day)
			self:setTextByLanKey("text_timer", "medal_text_0007", timerFormat)
		else
			self:setTextByLanKey("text_timer", "medal_text_0008", day)
		end
		local text_timer = self:findGameObject("text_timer")
		local textTimreRect = text_timer:GetComponent("RectTransform")
		local img_timerBg = self:findGameObject("img_timerBg")
		local rect = img_timerBg:GetComponent("RectTransform")
		self.m_control:setOnceTimer(0.2, function()
			local bgWidth = 14 + textTimreRect.sizeDelta.x
			rect.sizeDelta = Vector2(bgWidth, 26)
		end)
	end
end

--[[	
	基础属性列表
]]
--function M:updateBaseAttrLoopScroll()
--	local data = self.m_model:getFormatMedalAttr() -- 获取基础属性
--	UIUtil.destroyAllChild(self.m_attrs_node.transform)
--	for k,cell_data in ipairs(data) do
--		local cell_object = GameUtil:instanceObject(self.m_attr_node, self.m_attrs_node.transform)
--		cell_object:SetActive(true)
--		local transform = cell_object.transform
--		for i = 1, 2 do
--			if cell_data[i] then
--				local itemData = cell_data[i]
--				if itemData.itemType == 1 then
--					
--				else
--					local attr = itemData.attr
--					local cp = GameUtil:getAttrsName(attr[1]) .. ":"
--					local attr_name_text = UIUtil.setText(transform, cp, "attr_name_text"..i)
--					-- 四舍五入保留小数点后一位
--					local attr_value = attr[2] or 0
--					attr_value = math.floor(attr_value * 10 + 0.5)/10
--					local attr_value_text = nil
--					if GameUtil:attrTransition(attr[1]) == true then
--						attr_value_text = UIUtil.setText(transform, "+"..GameUtil:formatNum(attr_value).."%", "attr_value_text"..i)
--					else
--						attr_value_text = UIUtil.setText(transform, "+"..GameUtil:formatNum(attr_value), "attr_value_text"..i)
--					end
--
--					local attr_value_text_trans = UIUtil.findRectTransform(attr_value_text)
--					UIUtil.setLocalPosition(attr_value_text_trans, attr_name_text.preferredWidth + 20)
--				end
--			else
--				UIUtil.setText(transform, "", "attr_name_text"..i)
--				UIUtil.setText(transform, "", "attr_value_text"..i)
--			end
--		end
--	end
--end

function M:destroy()
    M.super.destroy(self)
end

return M