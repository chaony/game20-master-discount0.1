local M = class("TitleDetailView",LikeOO.OOPopBase)

M.m_uiName = "Title/TitleDetailPop"
M.m_size_type = 2

function M:onEnter()
	
	self.m_gray_image = self:findImage("gray_image")

	self.m_icon_node = self:findGameObject("icon_node")
	self.head_title_img = self:findGameObject("head_title_img")
	self.eqp_content = self:findGameObject("eqp_content")
	self.m_attr_node = self:findGameObject("attr_node") -- 基础属性的node
	self.m_attrs_node = self:findGameObject("attrs_node") -- 基础属性总节点
	self.m_cw_propey_node = self:findGameObject("cw_propey") -- 穿戴属性总节点
	
	self.eqp_content_fitter = self.eqp_content:GetComponent("ContentImmediate")
	local show_data = self.m_model.m_show_data
	local item_cfg = show_data.item_cfg
	self:setTextByLanKey("common_title_text", "title_text_0005")
	self:setTextByLanKey("shuxing_text", "title_text_0001")
	self:setTextByLanKey("text_wear_title", "title_text_0002")
	self:setTextByLanKey("des_text", item_cfg.des)
	self:setTextByLanKey("item_tips", item_cfg.lock_des)
	GameUtil:createItemElementByData(show_data, false, false, nil, self.m_icon_node.transform)
	
	GameUtil:setTextureLoadTitleLanImgText(self.head_title_img, item_cfg.icon)
	local name_img = self.head_title_img:GetComponent("Image")
	name_img:SetNativeSize()
	UIUtil.destroyAllChild(name_img.gameObject.transform)
	name_img.enabled = true
	if item_cfg.title_effect and item_cfg.title_effect ~= "" then
		name_img.enabled = false
		local effect = ResourceUtil:GetUIEffectItem("Headtitle/" .. item_cfg.title_effect, name_img.gameObject)
		effect.transform.anchoredPosition = Vector3.zero
	end
	self.today = self.m_model.m_today_btn_value
	self:setTextByLanKey("today_text", self.m_model.m_today_text)
	self:setObjectVisible("today_btn", self.m_model.m_isToday)
	if self.m_model.m_isToday then
		self:todayIsActive()
	end
	self:refreshUI()
end

function M:refreshUI()
	self:updateUseNum()
	local show_data = self.m_model.m_show_data
	local attr1 = show_data.item_cfg.attr1
	self:updateCollectAttrLoopScroll(self.m_attrs_node, self.m_attr_node, attr1) -- 收集属性
	local attr2 = show_data.item_cfg.attr2
	self:updateCollectAttrLoopScroll(self.m_cw_propey_node, self.m_attr_node, attr2, true) -- 佩戴属性
	--触发刷新自适应大小
	if self.eqp_content_fitter then
		self.eqp_content_fitter:ForceRefreshSize()
	end
end

function M:updateUseNum()
	if self.m_model.m_cost then-- 购买
		self:setObjectVisible("cost_node", self.m_model.m_show_buy_btn == true)
		self:setObjectVisible("use_btn", self.m_model.m_show_buy_btn == true)
		local data = RewardUtil:getProcessRewardData(self.m_model.m_cost)
		local cost_num = GameUtil:formatValueToString(data.data_num)
		local user_num = GameUtil:formatValueToString(data.user_num)
		local cost_num_text = self:setTextByLanKey("cost_num_text",  cost_num)
		cost_num_text.color = GlobalConfig.COMMON_COLLOR.COMMON_10
		self:setImg(data.icon_name, "item_icon", "cost_icon")
		local show_data = self.m_model.m_show_data
		self:setText("own_num_text", tostring(show_data.user_num))
	else -- 查看
		self:setObjectVisible("cost_node", false)
	end
end


--[[	
	基础属性列表
]]
function M:updateCollectAttrLoopScroll(parentNode, itemNode, attr, wearAttrsFlag )
	if not attr then return end
	local levelId = 999999
	local data = self.m_model:getFormatTitleCollectAttrByAttr(attr) -- 获取基础属性
	if not wearAttrsFlag then
		local title_cfg = self.m_model:getTitleCfgById(self.m_model.m_show_data.data_id)
		local level_up = title_cfg.level_up
		if level_up and level_up > 0 then
			table.insert(data,1,{{levelId, level_up}})
		end
	end
	UIUtil.destroyAllChild(parentNode.transform)
	for k,cell_data in ipairs(data) do
		local cell_object = GameUtil:instanceObject(itemNode, parentNode.transform)
		cell_object:SetActive(true)
		local transform = cell_object.transform
		for i = 1, 2 do
			if cell_data[i] then
				local attr_name_text = nil
				local attr_value_text = nil
				local attr = cell_data[i]
				if i == 1 and attr[1] == levelId then
					attr_name_text = UIUtil.setText(transform, Language:getTextByKey("title_text_0010"), "attr_name_text"..i)
					attr_value_text = UIUtil.setText(transform, "+"..tostring(attr[2]), "attr_value_text"..i)
				else
					local cp = UserDataManager:getNewAttrsNameByAttrId(attr[1]) .. ":"
					attr_name_text = UIUtil.setText(transform, cp, "attr_name_text"..i)
					-- 四舍五入保留小数点后一位
					local attr_value = attr[2] or 0
					attr_value = math.floor(attr_value * 10 + 0.5)/10
					if GameUtil:newAttrTransition(attr[1]) == true then
						attr_value_text = UIUtil.setText(transform, "+"..GameUtil:formatNum(attr_value).."%", "attr_value_text"..i)
					else
						attr_value_text = UIUtil.setText(transform, "+"..GameUtil:formatNum(attr_value), "attr_value_text"..i)
					end
				end

				local attr_value_text_trans = UIUtil.findRectTransform(attr_value_text)
				UIUtil.setLocalPosition(attr_value_text_trans, attr_name_text.preferredWidth + 20)
			else
				UIUtil.setText(transform, "", "attr_name_text"..i)
				UIUtil.setText(transform, "", "attr_value_text"..i)
			end
		end
	end
end

function M:todayIsActive(...)
	Logger.logError(self.today,"self.today~~~~~~~~~~")
	if self.today then
		self:setObjectVisible("yes", true)
		self.today_callback = true
		self.cur_server_ts = UserDataManager:getServerTime()
	else
		self:setObjectVisible("yes", false)
		self.today_callback = false
		self.cur_server_ts = nil
	end
end

return M