local M = class("OptionsTitleUpgradeView",LikeOO.OOPopBase)

M.m_uiName = "Options/OptionsTitleUpgrade"
M.m_size_type = 2

local attrs = {"combat", "maxLv", "hp", "atk", "def", "morale"}
function M:onEnter()

	local title_img_change = true
	self:setObjectVisible("ic_01", title_img_change == true)
	self:setObjectVisible("ic_02", title_img_change == true)
	self:setObjectVisible("ic_03", title_img_change == false)
	self.m_collect_attrs_node = self:findGameObject("collect_attrs_node")
	self.m_wear_attrs_node = self:findGameObject("wear_attrs_node")
	self.m_attr_node = self:findGameObject("attr_node")
	self.title_name_1_img = self:findGameObject("title_name_1_img")
	self.title_name_2_img = self:findGameObject("title_name_2_img")
	self:setTextByLanKey("text_collect_title", "title_text_0001")
	self:setTextByLanKey("text_wear_title", "title_text_0002")
	self.attrs_node = {}
	for i,v in ipairs(attrs) do
		self.attrs_node[v] = self:findGameObject("attrs_" .. v)
	end
	self:refreshUI()
end

function M:refreshUI()
	self:setTitleImage(self.m_model.m_old_title_id,self.title_name_1_img)
	self:setTitleImage(self.m_model.m_new_title_id,self.title_name_2_img)

	local wear_cfg_attrs = self.m_model:getTitleWearAttrById(self.m_model.m_old_title_id)
	local new_wear_cfg_attrs = self.m_model:getTitleWearAttrById(self.m_model.m_new_title_id)
	local wear_attrs = UserDataManager:appendNewAndOldAttrIds(wear_cfg_attrs,new_wear_cfg_attrs)
	self:setObjectVisible("text_wear_title", table.nums(wear_attrs)>0)
	self:updateLoopScroll(wear_attrs, self.m_wear_attrs_node, self.m_attr_node, true) -- 佩戴属性展示

	local collect_cfg_attrs = self.m_model:getTitleCollectAttrById(self.m_model.m_old_title_id)
	local new_collect_cfg_attrs = self.m_model:getTitleCollectAttrById(self.m_model.m_new_title_id)
	local collect_attrs = UserDataManager:appendNewAndOldAttrIds(collect_cfg_attrs,new_collect_cfg_attrs)
	self:setObjectVisible("text_collect_title", table.nums(collect_attrs)>0)
	self:updateLoopScroll(collect_attrs, self.m_collect_attrs_node, self.m_attr_node) -- 收集属性展示
end

-- 设置称号图片
function M:setTitleImage(title_id, gameObj)
	if title_id and title_id ~= 0 and gameObj then
		gameObj:SetActive(true)
		local name_img = gameObj:GetComponent("Image")
		local cfg = self.m_model:getTitleCfgById(title_id)
		UIUtil.destroyAllChild(name_img.gameObject.transform)
		if cfg.title_effect and cfg.title_effect ~= "" then
			name_img.enabled = false
			ResourceUtil:GetUIEffectItem("Headtitle/"..cfg.title_effect, gameObj)
		else
			name_img.enabled = true
			GameUtil:setTextureLoadTitleLanImgText(gameObj, cfg.icon) -- 设置称号图片
			name_img:SetNativeSize()
		end
	else
		Logger.logError("title_id == nil or gameObj == nil")
	end
end


--[[	
	属性列表
]]
function M:updateLoopScroll(attrs, parentNode, itemNode, wearAttrsFlag)
	local data = {}
	local levelUpAttrId = 999999
	if not wearAttrsFlag then
		local title_cfg_old = self.m_model:getTitleCfgById(self.m_model.m_old_title_id)
		local title_cfg_new = self.m_model:getTitleCfgById(self.m_model.m_new_title_id)
		local level_up_old = title_cfg_old.level_up or 0
		local level_up_new = title_cfg_new.level_up
		if level_up_new and level_up_new > 0 then
			data[1] = {levelUpAttrId, level_up_old, level_up_new}
		end
	end
	for i, v in pairs(attrs) do
		table.insert(data, {i, v[1], v[2]})
	end
	UIUtil.destroyAllChild(parentNode.transform)
	for k,cell_data in pairs(data) do
		local cell_object = GameUtil:instanceObject(itemNode, parentNode.transform)
		cell_object:SetActive(true)

		local cp
		local exchange_flag
		if cell_data[1] == levelUpAttrId then
			cp = Language:getTextByKey("title_text_0010")
			exchange_flag = false
		else
			cp = UserDataManager:getNewAttrsNameByAttrId(cell_data[1])
			exchange_flag = GameUtil:newAttrTransition(cell_data[1])
		end
		local transform = cell_object.transform
		UIUtil.setText(transform, cp, "name_text")
		
		local attr_value = cell_data[2] or 0
		attr_value = math.floor(attr_value * 10 + 0.5)/10
		if exchange_flag == true then
			UIUtil.setText(transform, GameUtil:formatNum(attr_value).."%", "value_text")
		else
			UIUtil.setText(transform, GameUtil:formatNum(attr_value), "value_text")
		end
		
		local new_attr_value = cell_data[3] or 0
		new_attr_value = math.floor(new_attr_value * 10 + 0.5)/10
		if exchange_flag == true then 
			UIUtil.setText(transform, GameUtil:formatNum(new_attr_value).."%", "value_new_text")
		else
			UIUtil.setText(transform, GameUtil:formatNum(new_attr_value), "value_new_text")
		end
		UIUtil.setObjectVisible(transform, attr_value ~= new_attr_value, "Image")
	end
end



return M